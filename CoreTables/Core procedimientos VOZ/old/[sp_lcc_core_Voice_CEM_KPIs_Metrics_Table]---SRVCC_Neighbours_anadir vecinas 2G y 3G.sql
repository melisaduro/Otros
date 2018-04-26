USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_lcc_core_Voice_CEM_KPIs_Metrics_Table]    Script Date: 23/04/2018 13:34:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [dbo].[sp_lcc_core_Voice_CEM_KPIs_Metrics_Table] as

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


------------------------------------------------ select * from lcc_core_Voice_CEM_KPIs_Metrics_Table
exec sp_lcc_dropifexists 'lcc_core_Voice_CEM_KPIs_Metrics_Table'

select 
	db_name()+'_'+convert(varchar(256),s.sessionid)+'_'+isnull(convert(varchar(256),'NA'),'NA') COLLATE Latin1_General_CI_AS as key_BST, 
	db_name() COLLATE Latin1_General_CI_AS as ddbb,

	s.sessionid as sessionidA, sb.SessionId as sessionidB,
	s.info as callstatus,

	-----------
	-- Parte A:
	rtp.RTP_Jitter_DL as RTP_Jitter_DL_A,	rtp.RTP_Jitter_UL as RTP_Jitter_UL_A,	rtp.RTP_Delay_DL as RTP_Delay_DL_A,	rtp.RTP_Delay_UL as RTP_Delay_UL_A,
	pg.Paging_Success_Ratio as Paging_Success_Ratio_A,
	pdp.PDP_Activate_Ratio	as PDP_Activate_Ratio_A,
	srvcc.SRVCC_SR			as SRVCC_SR_A,
	ln.EARFCN_N1 as EARFCN_N1_A,	ln.PCI_N1 as PCI_N1_A,	ln.RSRP_N1 as RSRP_N1_A,	ln.RSRQ_N1 as RSRQ_N1_A,
	ho2G3G.IRAT_HO2G3G_Ratio as IRAT_HO2G3G_Ratio_A,
	ho4G4G.num_HO_S1X2 as num_HO_S1X2_A,	ho4G4G.duration_S1X2_avg as duration_S1X2_avg_A,	ho4G4G.S1X2HO_SR as S1X2HO_SR_A,

	-----------
	-- Parte B:
	rtpB.RTP_Jitter_DL as RTP_Jitter_DL_B,	rtpB.RTP_Jitter_UL as RTP_Jitter_UL_B,	rtpB.RTP_Delay_DL as RTP_Delay_DL_B,	rtpB.RTP_Delay_UL as RTP_Delay_UL_B,
	pgB.Paging_Success_Ratio	as Paging_Success_Ratio_B,
	pdpB.PDP_Activate_Ratio		as PDP_Activate_Ratio_B,
	srvccB.SRVCC_SR				as SRVCC_SR_B,
	lnB.EARFCN_N1 as EARFCN_N1_B,	lnB.PCI_N1 as PCI_N1_B,		lnB.RSRP_N1 as  RSRP_N1_B,	lnB.RSRQ_N1 as RSRQ_N1_B,
	ho2G3GB.IRAT_HO2G3G_Ratio	as IRAT_HO2G3G_Ratio_B,
	ho4GB.num_HO_S1X2 as num_HO_S1X2_B,	ho4GB.duration_S1X2_avg as duration_S1X2_avg_B,	ho4GB.S1X2HO_SR as S1X2HO_SR_B
 
into lcc_core_Voice_CEM_KPIs_Metrics_Table
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

			LEFT OUTER JOIN (-- HO IRAT 2G/3G
					select  r.sessionid,
							1.0*sum(case when (r.kpiid in (35100,35101,35105,35106,35110,35111,35020,35030,35040,35041,35070,35071,35060,35061,34050,34060,34070) and r.errorcode<>0) then 0 else 1 end)/count(r.sessionid) as IRAT_HO2G3G_Ratio
					from resultskpi r, sessions s
					where r.sessionid=s.sessionid and sessiontype='CALL' 
						and r.kpiid in (35100,35101,35105,35106,35110,35111,35020,35030,35040,35041,35070,35071,35060,35061,34050,34060,34070)
					group by  r.sessionid						
			) ho2G3G ON s.sessionid=ho2G3G.sessionid

			LEFT OUTER JOIN (
					select  r.sessionid,
							count( r.sessionid ) as num_HO_S1X2,
							avg(r.duration) as duration_S1X2_avg,
							1.0*sum(case when (r.kpiid in (38100) and r.errorcode<>0) then 0 else 1 end)/count(r.sessionid) as S1X2HO_SR
					from resultskpi r, sessions s
					where r.sessionid=s.sessionid and sessiontype='CALL' 
						and r.kpiid in (38100)
					group by  r.sessionid			
			) ho4G4G on s.sessionid=ho4G4G.sessionid


			LEFT OUTER JOIN ( -- NEIGHBORS:
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
		-- PARTE B:
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

			LEFT OUTER JOIN (-- HO IRAT 2G/3G
					select  r.sessionid,
							1.0*sum(case when (r.kpiid in (35100,35101,35105,35106,35110,35111,35020,35030,35040,35041,35070,35071,35060,35061,34050,34060,34070) and r.errorcode<>0) then 0 else 1 end)/count(r.sessionid) as IRAT_HO2G3G_Ratio
					from resultskpi r, sessionsB s
					where r.sessionid=s.sessionid and sessiontype='CALL' 
						and r.kpiid in (35100,35101,35105,35106,35110,35111,35020,35030,35040,35041,35070,35071,35060,35061,34050,34060,34070)
					group by  r.sessionid						
			) ho2G3GB ON sB.sessionid=ho2G3GB.sessionid

			LEFT OUTER JOIN (
					select  r.sessionid,
							count( r.sessionid ) as num_HO_S1X2,
							avg(r.duration) as duration_S1X2_avg,
							1.0*sum(case when (r.kpiid in (38100) and r.errorcode<>0) then 0 else 1 end)/count(r.sessionid) as S1X2HO_SR
					from resultskpi r, sessionsB s
					where r.sessionid=s.sessionid and sessiontype='CALL' 
						and r.kpiid in (38100)
					group by  r.sessionid			
			) ho4GB on sB.sessionid=ho4GB.sessionid

			LEFT OUTER JOIN ( -- NEIGHBORS:
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
