USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_create_lcc_core_Voice_CEM_KPIs_Metrics_Table]    Script Date: 24/04/2018 11:49:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [dbo].[sp_create_lcc_core_Voice_CEM_KPIs_Metrics_Table] 
		@Config [nvarchar](max)			= 'SpainOSP'
as

-- DESCRIPTION ------------------------------------------------------------------------------------------------------
--
--		* COLLATE Latin1_General_CI_AS	-> database_default
--
--		Código del createVoiceTable - varias tablas
--			De hecho se calculan KPIs ya calculados, y son éstos los que se muestran
--          
--	Used KPIID:
--
--15200		-	Data (PS), Activate PDP Context
--StartTime		Timestamp of the SM message ’Activate PDP Context request’
--EndTime		Timestamp of the SM message ’ Activate PDP Context accept’ or ’ Activate PDP Context reject’ or Timeout, whatever comes first
--
--38040		-	4G/3G – IntersystemHO (SRVCC)
--StartTime		Timestamp of the MobilityFromEUTRACommand message
--EndTime		Timestamp of the HandoverToUTRANComplete message or Timeout, whatever comes first
--
--38050		-	4G/2G – IntersystemHO (SRVCC)
--StartTime		Timestamp of the MobilityFromEUTRACommand message
--EndTime		Timestamp of the RR: Handover Complete message or Timeout, whatever comes first
--
--38060		-	4G/CDMA – IntersystemHO (SRVCC)
--StartTime		Timestamp of the MobilityFromEUTRACommand message
--EndTime		Timestamp of the CDMA: Handoff Completion Message (SRVCC) or Timeout, whatever comes first
--
--35105 ??
--35100 (3G, Handover), 35101 (3G, Cell Update),35106 (3G, Inter Frequency Reselection),
--35110 (3G, HSPA Cell Change), 35111 (3G, HSPA R99 Link Change),
--35020 (InterSystemHO, GSM->UMTS), 35030 (InterSystemHO, UMTS->GSM), 35040 (InterSystemHO, UMTS->GSM during Transfer),
--35041 (InterSystemHO, UMTS->GSM RAU), 35070 (InterSystemHO, UMTS->GSM (Idle reselect)), 35071 (InterSystemHO to Location Update, UMTS->GSM (Idle reselect)),
--35060 (InterSystemHO, GSM->UMTS (Idle reselect)),35061 (InterSystemHO to Location Update, GSM->UMTS (Idle reselect)),
--34050 (2G, Handover), 34060 (2G, Channel Modify), 34070 (2G, Intra Cell Handover)
--
--38100		-	4G Handover
--StartTime		Timestamp of the RRC Message ‘RRCConnectionReconfiguration’ with (handoverType = intraLTE)
--EndTime		Timestamp of the of the RRC Message ‘RRCConnectionReconfigurationComplete’ or Timeout, whatever comes first
--
---------------------------------------------------------------------------------------------------------------------
-- MODIFICATIONS --------------------------------------------------------------------------------------------------------------------
--
-- EMS 20/03/2018: Added Value5 = 'SRVCC' in SRVCC calculated
-------------------------

--use FY1718_VOICE_BURGOS_4G_H1
--declare @Config [nvarchar](max)= 'SpainOSP'
------------------------------------------------ select * from _lcc_c0re_Voice_CEM_KPIs_Metrics_Table
------------------------------------------------ select * from _lcc_c0re_Voice_CEM_KPIs_Metrics_Table_CEM
------------------------------------------------ select * from _lcc_c0re_Voice_CEM_KPIs_Metrics_Table_Neighbours
------------------------------------------------ select * from _lcc_c0re_Voice_CEM_KPIs_Metrics_Table_HandOvers

exec sp_lcc_dropifexists '_lcc_c0re_Voice_CEM_KPIs_Metrics_Table'
exec sp_lcc_dropifexists '_lcc_c0re_Voice_CEM_KPIs_Metrics_Table_CEM'
exec sp_lcc_dropifexists '_lcc_c0re_Voice_CEM_KPIs_Metrics_Table_Neighbours'
exec sp_lcc_dropifexists '_lcc_c0re_Voice_CEM_KPIs_Metrics_Table_HandOvers'

select 
	db_name()+'_'+convert(varchar(256),s.sessionid)+'_'+isnull(convert(varchar(256),'NA'),'NA') COLLATE Latin1_General_CI_AS as key_BST, 
	db_name() COLLATE Latin1_General_CI_AS as ddbb,

	s.sessionid as sessionidA, sb.SessionId as sessionidB,
	s.info as callstatus,

	-----------
	-- Parte A:
	rtp.RTP_Jitter_DL as RTP_Jitter_DL_A,	
	rtp.RTP_Jitter_UL as RTP_Jitter_UL_A,	
	rtp.RTP_Delay_DL as RTP_Delay_DL_A,	
	rtp.RTP_Delay_UL as RTP_Delay_UL_A,
	pg.Paging_Success_Ratio as Paging_Success_Ratio_A,
	pdp.PDP_Activate_Ratio	as PDP_Activate_Ratio_A,
	srvcc.SRVCC_SR			as SRVCC_SR_A,

	-----------
	---- Parte B:
	rtpB.RTP_Jitter_DL as RTP_Jitter_DL_B,	
	rtpB.RTP_Jitter_UL as RTP_Jitter_UL_B,	
	rtpB.RTP_Delay_DL as RTP_Delay_DL_B,	
	rtpB.RTP_Delay_UL as RTP_Delay_UL_B,
	pgB.Paging_Success_Ratio	as Paging_Success_Ratio_B,
	pdpB.PDP_Activate_Ratio		as PDP_Activate_Ratio_B,
	srvccB.SRVCC_SR				as SRVCC_SR_B
 
into _lcc_c0re_Voice_CEM_KPIs_Metrics_Table_CEM
from
	-- PARTE A:	
	sessions s
			LEFT OUTER JOIN (-- RTP:
					select  r.sessionid, 
							avg(case when rs.Mode = 0 then 1.0*rs.AVGjitter end) as RTP_Jitter_DL,
							avg(case when rs.Mode = 1 then 1.0*rs.AVGjitter end) as RTP_Jitter_UL,
							avg(case when rs.Mode = 0 then 1.0*rs.AVGPDV end) as RTP_Delay_DL,
							avg(case when rs.Mode = 1 then 1.0*rs.AVGPDV end) as RTP_Delay_UL
					from  RTPStatistics rs, RTPStatisticsInfo r, sessions s
					where r.sessionid=s.sessionid and sessiontype='CALL'
						and r.RTPStatID=rs.RTPStatID 
					group by r.sessionid
			) rtp on s.sessionid=rtp.sessionid

			LEFT OUTER JOIN (-- PAGING:
					select r.sessionid,
						   1.0*sum(case when r.errorcode = 0 then 1 else 0 end)/count(r.errorcode) as Paging_Success_Ratio   
					from resultskpi r, sessions s
					where r.sessionid=s.sessionid and sessiontype='CALL'
						and (r.value3 like '%paging%' or r.value4 like '%paging%')
					group by r.sessionid
			) pg on s.sessionid=pg.sessionid	

			LEFT OUTER JOIN (-- PDP:
					select r.sessionid,
						   1.0*sum(case when r.errorcode = 0 then 1 else 0 end)/count(r.errorcode) as PDP_Activate_Ratio 
					from resultskpi r, sessions s
					where r.sessionid=s.sessionid and sessiontype='CALL' 
						and r.kpiid=15200 						
					group by r.sessionid					
			) pdp on s.sessionid=pdp.sessionid

			LEFT OUTER JOIN (-- SRVCC
					select  r.sessionid,
							case when (r.kpiid in (38040, 38050, 38060) and r.errorcode<>0) then 0 else 1 end as SRVCC_SR
					from resultskpi r, sessions s
					where r.sessionid=s.sessionid and sessiontype='CALL' 
						and r.kpiid in (38040, 38050, 38060)
						and Value5 = 'SRVCC'
					group by r.sessionid, r.kpiid,r.errorcode					
			) srvcc on s.sessionid=srvcc.sessionid
		,
		---- PARTE B:
		sessionsb sb 
			LEFT OUTER JOIN (-- RTP:
					select  r.sessionid, 
							avg(case when rs.Mode = 0 then 1.0*rs.AVGjitter end) as RTP_Jitter_DL,
							avg(case when rs.Mode = 1 then 1.0*rs.AVGjitter end) as RTP_Jitter_UL,
							avg(case when rs.Mode = 0 then 1.0*rs.AVGPDV end) as RTP_Delay_DL,
							avg(case when rs.Mode = 1 then 1.0*rs.AVGPDV end) as RTP_Delay_UL
					from  RTPStatistics rs, RTPStatisticsInfo r, sessionsb s
					where r.RTPStatID=rs.RTPStatID and r.sessionid=s.sessionid and sessiontype='CALL'
					group by r.sessionid
			) rtpB on sb.sessionid=rtpB.sessionid

			LEFT OUTER JOIN (-- PAGING:
					select r.sessionid,
						   1.0*sum(case when r.errorcode = 0 then 1 else 0 end)/count(r.errorcode) as Paging_Success_Ratio   
					from resultskpi r, sessionsb s
					where (r.value3 like '%paging%' or r.value4 like '%paging%')
						and r.sessionid=s.sessionid and sessiontype='CALL'
					group by r.sessionid
			) pgB on sB.sessionid=pgB.sessionid	

			LEFT OUTER JOIN (-- PDP:
					select r.sessionid,
						   1.0*sum(case when r.errorcode = 0 then 1 else 0 end)/count(r.errorcode) as PDP_Activate_Ratio 
					from resultskpi r, sessionsb s
					where r.sessionid=s.sessionid and sessiontype='CALL' 
						and r.kpiid=15200 						
					group by r.sessionid					
			) pdpB on sB.sessionid=pdpB.sessionid

			LEFT OUTER JOIN (-- SRVCC
					select  r.sessionid,
							case when (r.kpiid in (38040, 38050, 38060) and r.errorcode<>0) then 0 else 1 end as SRVCC_SR
					from resultskpi r, sessionsB s
					where r.sessionid=s.sessionid and sessiontype='CALL' 
						and r.kpiid in (38040, 38050, 38060)
						and value5 = 'SRVCC'
					group by r.sessionid, r.kpiid,r.errorcode					
			) srvccB on sB.sessionid=srvccB.sessionid

where	s.sessionType like 'CALL' -- solo me interesan las llamadas
	and s.info in ('Completed', 'Failed', 'Dropped')
	and s.sessionid=sb.sessionidA


select 
	db_name()+'_'+convert(varchar(256),s.sessionid)+'_'+isnull(convert(varchar(256),'NA'),'NA') COLLATE Latin1_General_CI_AS as key_BST, 
	db_name() COLLATE Latin1_General_CI_AS as ddbb,

	s.sessionid as sessionidA, sb.SessionId as sessionidB,
	s.info as callstatus,

	-----------
	-- Parte A:
	----	Neighbors Info - Neighbors TOP 1
	gn.N1_BCCH as BCCH_N1_A,
	gn.N1_RxLev as RxLev_N1_A,
	wn.PSC as PSC_N1_A,
	wn.RSCP as RSCP_N1_A,
	ln.EARFCN_N1 as EARFCN_N1_A,	
	ln.PCI_N1 as PCI_N1_A,	
	ln.RSRP_N1 as RSRP_N1_A,	
	ln.RSRQ_N1 as RSRQ_N1_A,

	-----------
	---- Parte B:
	------	Neighbors Info - Neighbors TOP 1
	gnb.N1_BCCH as BCCH_N1_B,
	gnb.N1_RxLev as RxLev_N1_B,
	wnb.PSC as PSC_N1_B,
	wnb.RSCP as RSCP_N1_B,
	lnB.EARFCN_N1 as EARFCN_N1_B,	
	lnB.PCI_N1 as PCI_N1_B,		
	lnB.RSRP_N1 as  RSRP_N1_B,	
	lnB.RSRQ_N1 as RSRQ_N1_B

 
into _lcc_c0re_Voice_CEM_KPIs_Metrics_Table_Neighbours
from
	-- PARTE A:	
	sessions s
			
			LEFT OUTER JOIN ( -- NEIGHBORS 2G:
							select  m.SessionId,				
									m.N1_BCCH, 				
									m.N1_RxLev,				
									m.msgtime,	
									ROW_NUMBER() over (partition by m.sessionid order by m.sessionid asc, m.msgtime desc, m.N1_rxlev asc) as id
							from MsgGSMLayer1 m, callanalysis mc
							where m.N1_BCCH is not null
							and m.sessionid=mc.sessionid
							group by m.SessionId, m.MsgTime, m.N1_BCCH, m.N1_RxLev
						) gn on s.sessionid=gn.sessionid and gn.id=1

			LEFT OUTER JOIN ( -- NEIGHBORS 3G:
							select	r.sessionid, 			
								r1.PSC, 					
								r1.RSCP, 				
								r.MsgTime, 
								ROW_NUMBER() over (partition by r.sessionid order by r.sessionid asc, r.msgtime desc, r1.RSCP asc) as id
							from callanalysis rc,WCDMAMeasReportInfo r
								left outer join	(select * from WCDMAMeasReport ) r1  on r1.MeasReportId=r.MeasReportId		
							where SetValue in ('N', 'M')						-- Monitored set
							and r.SessionId=rc.SessionId				-- side A info
							group by r.sessionid, r1.PSC, r1.RSCP, r.MsgTime
						)wn on s.sessionid=wn.sessionid and wn.id=1

			LEFT OUTER JOIN ( -- NEIGHBORS 4G:
					select 
						lc.sessionid,
						ln.ltemeasreportid,
						l.msgtime,
						ln.EARFCN as EARFCN_N1,
						ln.PhyCellId as PCI_N1,
						ln.RSRP as RSRP_N1,
						ln.RSRQ as RSRQ_N1,
						ln.carrierindex,
						row_number () over (partition by l.sessionid, ln.carrierindex order by l.msgtime asc, ln.RSRP desc) as id				
					from LTENeighbors ln, LTEmeasurementReport l, callanalysis lc
					where carrierindex=0 --Solo para la PCC
						and l.ltemeasreportid=ln.ltemeasreportid
						and lc.sessionid=l.sessionid
						and lc.CallendtimeStamp >= l.msgtime
			) ln on s.sessionid=ln.sessionid and ln.id=1 

		,
		---- PARTE B:
		sessionsb sb 
		
			LEFT OUTER JOIN ( -- NEIGHBORS 2G:
							select  m.SessionId,				
									m.N1_BCCH, 				
									m.N1_RxLev,				
									m.msgtime,	
									ROW_NUMBER() over (partition by m.sessionid order by m.sessionid asc, m.msgtime desc, m.N1_rxlev asc) as id
							from MsgGSMLayer1 m, callanalysis mc
							where m.N1_BCCH is not null
							and m.sessionid=mc.sessionid
							group by m.SessionId, m.MsgTime, m.N1_BCCH, m.N1_RxLev
						) gnB on sB.sessionid=gnB.sessionid and gnB.id=1

			LEFT OUTER JOIN ( -- NEIGHBORS 3G:
							select	r.sessionid, 			
								r1.PSC, 					
								r1.RSCP, 				
								r.MsgTime, 
								ROW_NUMBER() over (partition by r.sessionid order by r.sessionid asc, r.msgtime desc, r1.RSCP asc) as id
							from callanalysis rc,WCDMAMeasReportInfo r
								left outer join	(select * from WCDMAMeasReport ) r1  on r1.MeasReportId=r.MeasReportId		
							where SetValue in ('N', 'M')						-- Monitored set
							and r.SessionId=rc.SessionId				-- side A info
							group by r.sessionid, r1.PSC, r1.RSCP, r.MsgTime
						)wnB on sB.sessionid=wnB.sessionid and wnB.id=1

			LEFT OUTER JOIN ( -- NEIGHBORS 4G:
					select 
						lc.sessionid,
						ln.ltemeasreportid,
						l.msgtime,
						ln.EARFCN as EARFCN_N1,
						ln.PhyCellId as PCI_N1,
						ln.RSRP as RSRP_N1,
						ln.RSRQ as RSRQ_N1,
						ln.carrierindex,
						row_number () over (partition by l.sessionid, ln.carrierindex order by l.msgtime asc, ln.RSRP desc) as id				
					from LTENeighbors ln, LTEmeasurementReport l, callanalysis lc
					where carrierindex=0 --Solo para la PCC
						and l.ltemeasreportid=ln.ltemeasreportid
						and lc.sessionid=l.sessionid
						and lc.CallendtimeStamp >= l.msgtime
			) lnB on sB.sessionid=lnB.sessionid and lnB.id=1 

where	s.sessionType like 'CALL' -- solo me interesan las llamadas
	and s.info in ('Completed', 'Failed', 'Dropped')
	and s.sessionid=sb.sessionidA


select 
	db_name()+'_'+convert(varchar(256),s.sessionid)+'_'+isnull(convert(varchar(256),'NA'),'NA') COLLATE Latin1_General_CI_AS as key_BST, 
	db_name() COLLATE Latin1_General_CI_AS as ddbb,

	s.sessionid as sessionidA, sb.SessionId as sessionidB,
	s.info as callstatus,

	-----------
	-- Parte A:
	------	HO Info:
	ho.HOs_Duration_Avg as HOs_Duration_Avg_A,
	ho.Handovers as Handovers_A,
	ho.Handover_Failures as Handover_Failures_A,
	ho.Handover_2G2G_Failures as Handover_2G2G_Failures_A,
	ho.Handover_2G3G_Failures as Handover_2G3G_Failures_A,
	ho.Handover_3G2G_Failures as Handover_3G2G_Failures_A,
	ho.Handover_3G3G_Failures as Handover_3G3G_Failures_A,
	ho.Handover_4G3G_Failures as Handover_4G3G_Failures_A,
	ho.Handover_4G4G_Failures as Handover_4G4G_Failures_A,
	ho2G3G.IRAT_HO2G3G_Ratio as IRAT_HO2G3G_Ratio_A,
	ho4G4G.num_HO_S1X2 as num_HO_S1X2_A,	
	ho4G4G.duration_S1X2_avg as duration_S1X2_avg_A,	
	ho4G4G.S1X2HO_SR as S1X2HO_SR_A,

	-----------
	---- Parte B:
	--------	HO Info:
	hoB.HOs_Duration_Avg as HOs_Duration_Avg_B,
	hoB.Handovers as Handovers_B,
	hoB.Handover_Failures as Handover_Failures_B,
	hoB.Handover_2G2G_Failures as Handover_2G2G_Failures_B,
	hoB.Handover_2G3G_Failures as Handover_2G3G_Failures_B,
	hoB.Handover_3G2G_Failures as Handover_3G2G_Failures_B,
	hoB.Handover_3G3G_Failures as Handover_3G3G_Failures_B,
	hoB.Handover_4G3G_Failures as Handover_4G3G_Failures_B,
	hoB.Handover_4G4G_Failures as Handover_4G4G_Failures_B,
	ho2G3GB.IRAT_HO2G3G_Ratio	as IRAT_HO2G3G_Ratio_B,
	ho4GB.num_HO_S1X2 as num_HO_S1X2_B,
	ho4GB.duration_S1X2_avg as duration_S1X2_avg_B,	
	ho4GB.S1X2HO_SR as S1X2HO_SR_B
 
into _lcc_c0re_Voice_CEM_KPIs_Metrics_Table_HandOvers
from
	-- PARTE A:	
	sessions s

			LEFT OUTER JOIN (select r.sessionid,  --HANDOVERS
								COUNT(Kpistatus) as Handovers,
								SUM(case when r.KPIStatus = 'Failed' then 1 else 0 end) as Handover_Failures,
								SUM(case when r.KPIId in (34050,34060,34070) and r.KPIStatus = 'Failed' then 1 else 0 end) as Handover_2G2G_Failures,
								SUM(case when r.KPIId in (35060,35061) and r.KPIStatus = 'Failed' then 1 else 0 end) as Handover_2G3G_Failures,
								SUM(case when r.KPIId in (35020,35030,35040,35041,35070,35071) and r.KPIStatus = 'Failed' then 1 else 0 end) as Handover_3G2G_Failures,
								SUM(case when r.KPIId in (35100,35101,35105,35106,35110,35111) and r.KPIStatus = 'Failed' then 1 else 0 end) as Handover_3G3G_Failures,
								SUM(case when r.KPIId in (38020,38030) and r.KPIStatus = 'Failed' then 1 else 0 end) as Handover_4G3G_Failures,
								SUM(case when r.KPIId = 38100 and r.KPIStatus = 'Failed' then 1 else 0 end) as Handover_4G4G_Failures,
								AVG(r.Duration) as HOs_Duration_Avg
	
							from vresultskpi r, sessions s
							where r.SessionId=s.SessionId and r.kpiid in (	34050,34060,34070,						--	2g
																			35060,35061,							--	2G/3G
																			35020,35030,35040,35041,35070,35071,	--	3G/2G
																			35100,35101,35105,35106,35110,35111,	--	3G
																			38020,38030,							--	4G/3G
																			38100									--	4G
																			)
							and sessiontype='CALL' 
							group by r.SessionId	
			) ho ON s.sessionid=ho.sessionid

			LEFT OUTER JOIN (-- HO IRAT 2G/3G
					select  r.sessionid,
							1.0*sum(case when (r.kpiid in (35100,35101,35105,35106,35110,35111,35020,35030,35040,35041,35070,35071,35060,35061,34050,34060,34070) and r.errorcode<>0) then 0 else 1 end)/count(r.sessionid) as IRAT_HO2G3G_Ratio
					from resultskpi r, sessions s
					where r.sessionid=s.sessionid and sessiontype='CALL' 
						and r.kpiid in (35100,35101,35105,35106,35110,35111,35020,35030,35040,35041,35070,35071,35060,35061,34050,34060,34070)
					group by  r.sessionid						
			) ho2G3G ON s.sessionid=ho2G3G.sessionid

			LEFT OUTER JOIN (--HO 4G/4G
					select  r.sessionid,
							count( r.sessionid ) as num_HO_S1X2,
							avg(r.duration) as duration_S1X2_avg,
							1.0*sum(case when (r.kpiid in (38100) and r.errorcode<>0) then 0 else 1 end)/count(r.sessionid) as S1X2HO_SR
					from resultskpi r, sessions s
					where r.sessionid=s.sessionid and sessiontype='CALL' 
						and r.kpiid in (38100)
					group by  r.sessionid			
			) ho4G4G on s.sessionid=ho4G4G.sessionid

		,
		---- PARTE B:
		sessionsb sb 

			LEFT OUTER JOIN (select r.sessionid,  --HANDOVERS
								COUNT(Kpistatus) as Handovers,
								SUM(case when r.KPIStatus = 'Failed' then 1 else 0 end) as Handover_Failures,
								SUM(case when r.KPIId in (34050,34060,34070) and r.KPIStatus = 'Failed' then 1 else 0 end) as Handover_2G2G_Failures,
								SUM(case when r.KPIId in (35060,35061) and r.KPIStatus = 'Failed' then 1 else 0 end) as Handover_2G3G_Failures,
								SUM(case when r.KPIId in (35020,35030,35040,35041,35070,35071) and r.KPIStatus = 'Failed' then 1 else 0 end) as Handover_3G2G_Failures,
								SUM(case when r.KPIId in (35100,35101,35105,35106,35110,35111) and r.KPIStatus = 'Failed' then 1 else 0 end) as Handover_3G3G_Failures,
								SUM(case when r.KPIId in (38020,38030) and r.KPIStatus = 'Failed' then 1 else 0 end) as Handover_4G3G_Failures,
								SUM(case when r.KPIId = 38100 and r.KPIStatus = 'Failed' then 1 else 0 end) as Handover_4G4G_Failures,
								AVG(r.Duration) as HOs_Duration_Avg
	
							from vresultskpi r, sessionsB s
							where r.SessionId=s.SessionId and r.kpiid in (	34050,34060,34070,						--	2g
																			35060,35061,							--	2G/3G
																			35020,35030,35040,35041,35070,35071,	--	3G/2G
																			35100,35101,35105,35106,35110,35111,	--	3G
																			38020,38030,							--	4G/3G
																			38100									--	4G
																			)
							and sessiontype='CALL' 
							group by r.SessionId	
			) hoB ON sB.sessionid=hoB.sessionid

			LEFT OUTER JOIN (-- HO IRAT 2G/3G
					select  r.sessionid,
							1.0*sum(case when (r.kpiid in (35100,35101,35105,35106,35110,35111,35020,35030,35040,35041,35070,35071,35060,35061,34050,34060,34070) and r.errorcode<>0) then 0 else 1 end)/count(r.sessionid) as IRAT_HO2G3G_Ratio
					from resultskpi r, sessionsB s
					where r.sessionid=s.sessionid and sessiontype='CALL' 
						and r.kpiid in (35100,35101,35105,35106,35110,35111,35020,35030,35040,35041,35070,35071,35060,35061,34050,34060,34070)
					group by  r.sessionid						
			) ho2G3GB ON sB.sessionid=ho2G3GB.sessionid

			
			LEFT OUTER JOIN (-- HO IRAT 4G/4G
					select  r.sessionid,
							count( r.sessionid ) as num_HO_S1X2,
							avg(r.duration) as duration_S1X2_avg,
							1.0*sum(case when (r.kpiid in (38100) and r.errorcode<>0) then 0 else 1 end)/count(r.sessionid) as S1X2HO_SR
					from resultskpi r, sessionsB s
					where r.sessionid=s.sessionid and sessiontype='CALL' 
						and r.kpiid in (38100)
					group by  r.sessionid			
			) ho4GB on sB.sessionid=ho4GB.sessionid


where	s.sessionType like 'CALL' -- solo me interesan las llamadas
	and s.info in ('Completed', 'Failed', 'Dropped')
	and s.sessionid=sb.sessionidA




--****************************************************************************************************************************************
--		Creamos la tabla final:		
--****************************************************************************************************************************************
exec sp_lcc_dropifexists '_lcc_c0re_Voice_CEM_KPIs_Metrics_Table'
select 
	m.[key_BST],	m.ddbb,
	m.sessionid as sessionidA,	m.sessionidB,
	m.sessionType as callstatus,

	-----------
	-- Parte A:
	null as RTP_Jitter_DL_A,null as RTP_Jitter_UL_A,null as RTP_Delay_DL_A,null as RTP_Delay_UL_A,
	null as Paging_Success_Ratio_A,null as PDP_Activate_Ratio_A,null as SRVCC_SR_A,

	----	Neighbors Info - Neighbors TOP 1
	null as BCCH_N1_A,null as RxLev_N1_A,null as PSC_N1_A,null as RSCP_N1_A,null as EARFCN_N1_A,	
	null as PCI_N1_A,null as RSRP_N1_A,null as RSRQ_N1_A,

	------	HO Info:
	null as HOs_Duration_Avg_A,null as Handovers_A,null as Handover_Failures_A,null as Handover_2G2G_Failures_A,
	null as Handover_2G3G_Failures_A,null as Handover_3G2G_Failures_A,null as Handover_3G3G_Failures_A,
	null as Handover_4G3G_Failures_A,null as Handover_4G4G_Failures_A,null as IRAT_HO2G3G_Ratio_A,
	null as num_HO_S1X2_A,null as duration_S1X2_Avg_A,null as S1X2HO_SR_A,

	-----------
	-- Parte B:
	null as RTP_Jitter_DL_B,null as RTP_Jitter_UL_B,null as RTP_Delay_DL_B,null as RTP_Delay_UL_B,
	null as Paging_Success_Ratio_B,null as PDP_Activate_Ratio_B,null as SRVCC_SR_B,

	----	Neighbors Info - Neighbors TOP 1
	null as BCCH_N1_B,null as RxLev_N1_B,null as PSC_N1_B,null as RSCP_N1_B,null as EARFCN_N1_B,	
	null as PCI_N1_B,null as RSRP_N1_B,null as RSRQ_N1_B,

	------	HO Info:
	null as HOs_Duration_Avg_B,null as Handovers_B,null as Handover_Failures_B,null as Handover_2G2G_Failures_B,
	null as Handover_2G3G_Failures_B,null as Handover_3G2G_Failures_B,null as Handover_3G3G_Failures_B,
	null as Handover_4G3G_Failures_B,null as Handover_4G4G_Failures_B,null as IRAT_HO2G3G_Ratio_B,
	null as num_HO_S1X2_B,null as duration_S1X2_Avg_B,null as S1X2HO_SR_B

into _lcc_c0re_Voice_CEM_KPIs_Metrics_Table 
from	lcc_core_Master_table m	
where	m.sessionType like 'CALL' -- solo me interesan las llamadas
	and m.session_Status in ('Completed', 'Failed', 'Dropped')


--****************************************************************************************************************************************
--		Rellenamos de manera controlada - _lcc_c0re_Voice_CEM_KPIs_Metrics_Table
--****************************************************************************************************************************************
---------------- RTP,Paging,PDP,SRVCC
update _lcc_c0re_Voice_CEM_KPIs_Metrics_Table
set 
	-- Parte A:
	RTP_Jitter_DL_A=m.RTP_Jitter_DL_A,	
	RTP_Jitter_UL_A=m.RTP_Jitter_UL_A,	
	RTP_Delay_DL_A=m.RTP_Delay_DL_A,	
	RTP_Delay_UL_A=m.RTP_Delay_UL_A,
	Paging_Success_Ratio_A=m.Paging_Success_Ratio_A,
	PDP_Activate_Ratio_A=m.PDP_Activate_Ratio_A,
	SRVCC_SR_A=m.SRVCC_SR_A,
	-- Parte B:
	RTP_Jitter_DL_B=m.RTP_Jitter_DL_B,	
	RTP_Jitter_UL_B=m.RTP_Jitter_UL_B,	
	RTP_Delay_DL_B=m.RTP_Delay_DL_B,	
	RTP_Delay_UL_B=m.RTP_Delay_UL_B,
	Paging_Success_Ratio_B=m.Paging_Success_Ratio_B,
	PDP_Activate_Ratio_B=m.PDP_Activate_Ratio_B,
	SRVCC_SR_B=m.SRVCC_SR_B

from _lcc_c0re_Voice_CEM_KPIs_Metrics_Table g, _lcc_c0re_Voice_CEM_KPIs_Metrics_Table_CEM m
where g.key_BST=m.key_BST


---------------- HOs
update _lcc_c0re_Voice_CEM_KPIs_Metrics_Table
set 
	-- Parte A:
	HOs_Duration_Avg_A=m.HOs_Duration_Avg_A,	
	Handovers_A=m.Handovers_A,	
	Handover_Failures_A=m.Handover_Failures_A,	
	Handover_2G2G_Failures_A=m.Handover_2G2G_Failures_A,
	Handover_2G3G_Failures_A=m.Handover_2G3G_Failures_A,
	Handover_3G2G_Failures_A=m.Handover_3G2G_Failures_A,
	Handover_3G3G_Failures_A=m.Handover_3G3G_Failures_A,
	Handover_4G3G_Failures_A=m.Handover_4G3G_Failures_A,	
	Handover_4G4G_Failures_A=m.Handover_4G4G_Failures_A,
	IRAT_HO2G3G_Ratio_A=m.IRAT_HO2G3G_Ratio_A,
	num_HO_S1X2_A=m.num_HO_S1X2_A,
	duration_S1X2_avg_A=m.duration_S1X2_avg_A,
	S1X2HO_SR_A=m.S1X2HO_SR_A,

	-- Parte B:
	HOs_Duration_Avg_B=m.HOs_Duration_Avg_B,	
	Handovers_B=m.Handovers_B,	
	Handover_Failures_B=m.Handover_Failures_B,	
	Handover_2G2G_Failures_B=m.Handover_2G2G_Failures_B,
	Handover_2G3G_Failures_B=m.Handover_2G3G_Failures_B,
	Handover_3G2G_Failures_B=m.Handover_3G2G_Failures_B,
	Handover_3G3G_Failures_B=m.Handover_3G3G_Failures_B,
	Handover_4G3G_Failures_B=m.Handover_4G3G_Failures_B,	
	Handover_4G4G_Failures_B=m.Handover_4G4G_Failures_B,
	IRAT_HO2G3G_Ratio_B=m.IRAT_HO2G3G_Ratio_B,
	num_HO_S1X2_B=m.num_HO_S1X2_B,
	duration_S1X2_Avg_B=m.duration_S1X2_Avg_B,
	S1X2HO_SR_B=m.S1X2HO_SR_B

from _lcc_c0re_Voice_CEM_KPIs_Metrics_Table g, _lcc_c0re_Voice_CEM_KPIs_Metrics_Table_HandOvers m
where g.key_BST=m.key_BST


---------------- NEIGHBORS
update _lcc_c0re_Voice_CEM_KPIs_Metrics_Table
set 
	-- Parte A:
	BCCH_N1_A=m.BCCH_N1_A,	
	RxLev_N1_A=m.RxLev_N1_A,	
	PSC_N1_A=m.PSC_N1_A,	
	RSCP_N1_A=m.RSCP_N1_A,
	EARFCN_N1_A=m.EARFCN_N1_A,
	PCI_N1_A=m.PCI_N1_A,
	RSRP_N1_A=m.RSRP_N1_A,
	RSRQ_N1_A=m.RSRQ_N1_A,

	-- Parte B:
	BCCH_N1_B=m.BCCH_N1_B,	
	RxLev_N1_B=m.RxLev_N1_B,	
	PSC_N1_B=m.PSC_N1_B,	
	RSCP_N1_B=m.RSCP_N1_B,
	EARFCN_N1_B=m.EARFCN_N1_B,
	PCI_N1_B=m.PCI_N1_B,
	RSRP_N1_B=m.RSRP_N1_B,
	RSRQ_N1_B=m.RSRQ_N1_B

from _lcc_c0re_Voice_CEM_KPIs_Metrics_Table g, _lcc_c0re_Voice_CEM_KPIs_Metrics_Table_Neighbours m
where g.key_BST=m.key_BST


--***********************************************************************************************************************************
--		Tabla CORE final:
--***********************************************************************************************************************************
------declare @Config as [nvarchar](max)='SpainOSP'
exec('
	exec sp_lcc_dropifexists ''lcc_core_Voice_'+@Config+'_CEM_KPIs_Metrics_Table''	
	select * 
	into lcc_core_Voice_'+@Config+'_CEM_KPIs_Metrics_Table
	from _lcc_c0re_Voice_CEM_KPIs_Metrics_Table
')

--***********************************************************************************************************************************
-- Borrado Tablas Intermedias:
--***********************************************************************************************************************************
exec sp_lcc_dropifexists '_lcc_c0re_Voice_CEM_KPIs_Metrics_Table'
exec sp_lcc_dropifexists '_lcc_c0re_Voice_CEM_KPIs_Metrics_Table_CEM'
exec sp_lcc_dropifexists '_lcc_c0re_Voice_CEM_KPIs_Metrics_Table_Neighbours'
exec sp_lcc_dropifexists '_lcc_c0re_Voice_CEM_KPIs_Metrics_Table_HandOvers'


------------------------------------------------ select * from _lcc_c0re_Voice_Metrics_Table