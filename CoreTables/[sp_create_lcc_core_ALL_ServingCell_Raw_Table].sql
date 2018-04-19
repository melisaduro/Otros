USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_create_lcc_core_ALL_ServingCell_Raw_Table]    Script Date: 19/04/2018 11:02:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[sp_create_lcc_core_ALL_ServingCell_Raw_Table]
as

--****************************************************************************************************************************************
-- DESCRIPTION 
--
--		* key_BST:
--			- VOICE / IDLE	- sessionid_NA
--			- DATA	/ MOS	- sessiontid_testid
--
--		* COLLATE Latin1_General_CI_AS	-> database_default	
--
--		* Not BAND info (as in BM - LTE2600/LTE1800/...) 
--		  TECHNOLOGY info (LTE-UTRA3/7...) from Networkinfo
--
--		* ServingOperator	- Actually connected operator
--		* Operator			- SIM card operator				- from Networkinfo - more samples by fileid 
--
--		* Used:	NetworkInfo		
--				LTEMeasurementReport (4G) 
--				WCDMAActiveSet		 (3G)	where m.refCell=1	-- reference cell
--				MsgGsmReport		 (2G)
--
--****************************************************************************************************************************************


--****************************************************************************************************************************************
--	1) Creamos primero las tablas temporales CA: 
--****************************************************************************************************************************************
exec sp_lcc_dropifexists '_lcc_c0re_SCC'	
CREATE TABLE _lcc_c0re_SCC(
	[key_BST] [nvarchar](4000) NULL,			
	[ddbb] [nvarchar](255) NULL,

	[CarrierIndex_Orig] [smallint] NULL,
	[CarrierIndex] [smallint] NULL,
	[LTEMeasReportId] [bigint] NOT NULL,
	[sessionid] [bigint] NOT NULL,
	[testid] [bigint] NULL,
	[MsgId] [bigint] NOT NULL,
	[msgtime] [datetime2](3) NULL,
	[posid] [bigint] NULL,
	[networkid] [bigint] NULL,
	[Freq] [int] NULL,
	[cell] [int] NULL,
	[signal] [real] NULL,
	[quality] [real] NULL,
	[RSSI] [real] NULL,
	[SINR0] [real] NULL,
	[SINR1] [real] NULL,
	[technology] [nvarchar](255) NULL		
) 

----------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LTEMeasurementReportCarrier]') AND type in (N'U'))
begin
	--Ordenamos los carrierIndex para tomar cada carrier como la primera, segunda, etc ocurrencia
	--(se ha visto que la forma de rellenar los carrierIndex no se corresponde con: index=1 -> SCC1, index=2 -> SCC2, ...)
	-- NO hay info de CarrierIndex=0 --> PCC
	
	--Por cada info de carrier-msgtime de test, nos quedamos con el mejor nivel reportado (en PoC se han detectado n-registros)
	exec dbo.sp_lcc_dropifexists '_lcc_c0re_SCC_Temp'
	select 
		c.CarrierIndex,m.LTEMeasReportId,
		m.sessionid, m.testid, m.MsgId,	m.msgtime, m.posid,	m.networkid,
		c.EARFCN as Freq, c.PhyCellId as cell,
		max(c.RSRP) as signal, max(c.RSRQ) as quality, max(c.RSSI) as RSSI,max(c.SINR0) as SINR0, max(c.SINR1) as SINR1,
		n.technology
	into _lcc_c0re_SCC_Temp

	from LTEMeasurementReport m
			JOIN LTEMeasurementReportCarrier c ON c.LTEMeasReportId = m.LTEMeasReportId
			LEFT OUTER JOIN networkinfo n on m.networkid=n.networkid
			, sessions s, filelist f

	where m.sessionid=s.sessionid and s.fileid=f.fileid 

	group by c.CarrierIndex,m.LTEMeasReportId,
		m.sessionid, m.testid, m.MsgId,	m.msgtime, m.posid,	m.networkid,
		c.EARFCN, c.PhyCellId,
		n.technology

	----------------
	insert into _lcc_c0re_SCC
	select 
		db_name()+'_'+convert(varchar(256),sessionid)+'_'+isnull(convert(varchar(256),'NA'),testid) COLLATE Latin1_General_CI_AS as key_BST,
		db_name() COLLATE Latin1_General_CI_AS ddbb, 
		CarrierIndex  as CarrierIndex_Orig,
		ROW_NUMBER() over (partition by testid,msgtime order by CarrierIndex asc) as CarrierIndex,	-- SCC:1...7
		LTEMeasReportId,
		sessionid, testid, MsgId, msgtime, posid, networkid,
		Freq, cell,
		signal, quality, RSSI,
		SINR0, SINR1,
		technology
	from _lcc_c0re_SCC_Temp

end
	

--****************************************************************************************************************************************
--	2) Obtenemos info por tecnologia:		select distinct homeoperator, operator from NetworkInfo
--****************************************************************************************************************************************

-- 4G Parte A
exec dbo.sp_lcc_dropifexists '_lcc_c0re_4G_Aside'
select
	s.sessionType,
	m.LTEMeasReportId as LTEMeasReportId, 	m.sessionid,	m.testid,	m.msgtime,	m.posid,	m.networkid,
	EARFCN as Freq,		PhyCellId as cell,	RSRP as signal,	RSRQ as quality,
	n.CId,
	null Hopping,
	RSSI,
	SINR0,	SINR1,
	null RNCID,
	p.longitude,		p.latitude,
	f.CallingModule,	RIGHT(left(f.imsi,5),2) as mnc, 
	op.operator, n.operator as ServingOperator,
	n.CGI,	n.lac,	n.RAC,	n.technology,
	f.CollectionName,
	'A' as Side	  

INTO _lcc_c0re_4G_Aside
from LTEMeasurementReport m, NetworkInfo n, position p, sessions s, filelist f
	LEFT OUTER JOIN	 (
			select fileid, homeOperator operator
			from
			(
				select *, row_number() over (partition by fileid order by duration desc) id
				from
				(
				select fileid, HomeOperator, sum(duration) duration
				from networkinfo group by fileid, homeoperator
				) t
			) t where id=1
	 ) op on f.fileid=op.FileId
where m.networkid=n.NetworkId and p.PosId=m.PosId and m.SessionId=s.SessionId and s.FileId=f.FileId

----------------	
-- 4G Parte B
exec dbo.sp_lcc_dropifexists '_lcc_c0re_4G_Bside'
select s.sessionType,
	m.LTEMeasReportId as LTEMeasReportId,	s.sessionidA as Sessionid,	m.testid,	m.msgtime,	m.posid,	m.networkid,
	EARFCN as Freq,		PhyCellId as cell,	RSRP as signal,	RSRQ as quality,
	n.CId,
	null Hopping,
	RSSI,
	SINR0,	SINR1,
	null RNCID,
	p.longitude,	p.latitude,
	f.CallingModule,	RIGHT(left(f.imsi,5),2) as mnc, op.operator, n.operator as ServingOperator,
	n.CGI,	n.lac,	n.RAC,	n.technology,		
	f.CollectionName,
	'B' as Side	  
INTO _lcc_c0re_4G_Bside
from LTEMeasurementReport m, NetworkInfo n, position p, sessionsB s, filelist f
	LEFT OUTER JOIN	 (
			select fileid, homeOperator operator
			from
			(
				select *, row_number() over (partition by fileid order by duration desc) id
				from
				(
				select fileid, HomeOperator, sum(duration) duration
				from networkinfo group by fileid, homeoperator
				) t
			) t where id=1
	 ) op on f.fileid=op.FileId
where m.networkid=n.NetworkId and p.PosId=m.PosId and m.SessionId=s.SessionId and s.FileId=f.FileId


---------------- 
-- 3G Parte A
exec dbo.sp_lcc_dropifexists '_lcc_c0re_3G_Aside'
select  s.sessionType,
	null as LTEMeasReportId,	m.sessionid,	m.testid,	m.msgtime,	m.posid,	m.networkid,
	mprim.FreqDL as Freq,
	mprim.PrimScCode as cell,
	m.AggrRSCP as signal,
	m.AggrEcIo as quality,
	n.CId,
	null Hopping,
	null RSSI,
	null SINR0,
	null SINR1,
	vBTSList.RNC,
	p.longitude,		p.latitude,
	f.CallingModule,	RIGHT(left(f.imsi,5),2) as mnc, 
	op.operator, n.operator as ServingOperator,
	n.CGI,	n.lac,	n.RAC,	n.technology,
	f.CollectionName,
	'A' as Side	  

INTO _lcc_c0re_3G_Aside
from WCDMAActiveSet m, 
	(Select sessionid, testid, msgtime, PrimScCode, FreqDL,
					row_number() over(partition by sessionid, testid, msgtime order by sessionid, testid, msgtime, RSCP_PSC) as id
					from WCDMAActiveSet
					) mprim
	, position p, sessions s, filelist f
			LEFT OUTER JOIN ( 
				select fileid, homeOperator operator
				from (
						select *, row_number() over (partition by fileid order by duration desc) id
						from
						(
							select fileid, HomeOperator, sum(duration) duration
							from networkinfo group by fileid, homeoperator
						) t
					 ) t where id=1
			) op on op.fileid=f.fileid
	, NetworkInfo n
		LEFT outer JOIN vBTSList ON vBTSList.CGI = n.CGI and  vBTSList.LAC = n.LAC	
	 					
where m.networkid=n.NetworkId		and p.PosId=m.PosId			and m.SessionId=s.SessionId and s.FileId=f.FileId
	and mprim.sessionid=m.sessionid and mprim.testid=m.testid	and mprim.msgtime=m.msgtime and mprim.PrimScCode=m.PrimScCode 
	and m.refcell=1 -- Nos quedamos con la celda primaria

----------------
-- 3G Parte B
exec dbo.sp_lcc_dropifexists '_lcc_c0re_3G_Bside'
select  s.sessionType,
	null as LTEMeasReportId,		s.sessionidA as sessionid,	m.testid,	m.msgtime,	m.posid,	m.networkid,
	m.FreqDL as Freq,
	m.PrimScCode as cell,
	m.AggrRSCP as signal,	m.AggrEcIo as quality,
	n.CId,
	null Hopping,
	null RSSI,	null SINR0,	null SINR1,
	vBTSList.RNC,
	p.longitude,	p.latitude,
	f.CallingModule,	RIGHT(left(f.imsi,5),2) as mnc, 	op.operator, n.operator as ServingOperator,
	n.CGI,	n.lac,	n.RAC,	n.technology,
	f.CollectionName,
	'B' as Side	  
INTO _lcc_c0re_3G_Bside
from WCDMAActiveSet m,
	(Select sessionid, testid, msgtime, PrimScCode, FreqDL,
						row_number() over(partition by sessionid, testid,msgtime order by sessionid, testid, msgtime,RSCP_PSC) as id
						from WCDMAActiveSet
						) mprim
	, position p, sessionsB s, filelist f
			LEFT OUTER JOIN ( 
				select fileid, homeOperator operator
				from (
						select *, row_number() over (partition by fileid order by duration desc) id
						from
						(
							select fileid, HomeOperator, sum(duration) duration
							from networkinfo group by fileid, homeoperator
						) t
					 ) t where id=1
			) op on op.fileid=f.fileid
		,NetworkInfo n
			LEFT outer JOIN vBTSList ON vBTSList.CGI = n.CGI and  vBTSList.LAC = n.LAC	 			
	where m.networkid=n.NetworkId and p.PosId=m.PosId and m.SessionId=s.SessionId and s.FileId=f.FileId
	and mprim.sessionid=m.sessionid and mprim.testid=m.testid and mprim.msgtime=m.msgtime and mprim.PrimScCode=m.PrimScCode 
	and m.refcell=1 -- Nos quedamos con la celda primaria


---------------- 
-- 2G Parte A
exec dbo.sp_lcc_dropifexists '_lcc_c0re_2G_Aside'
select  s.sessionType,
	null as LTEMeasReportId,	m.sessionid,		m.testid,				m.msgtime,				m.posid,		m.networkid,
	n.BCCH as Freq,				n.BSIC as cell,		m.RxLev as signal,		m.RxQual as quality,	n.CId,			m.Hopping,
	null RSSI,					null SINR0,			null SINR1,				null RNCID,		
	p.longitude,		p.latitude,
	f.CallingModule,	RIGHT(left(f.imsi,5),2) as mnc, 
	op.operator, n.operator as ServingOperator,
	n.CGI,	n.lac,	n.RAC,	n.technology,
	f.CollectionName,
	'A' as Side	  

INTO _lcc_c0re_2G_Aside
from MsgGsmReport m, NetworkInfo n, position p, sessions s, filelist f
			LEFT OUTER JOIN ( 
				select fileid, homeOperator operator
				from (
						select *, row_number() over (partition by fileid order by duration desc) id
						from
						(
							select fileid, HomeOperator, sum(duration) duration
							from networkinfo group by fileid, homeoperator
						) t
					 ) t where id=1
			) op on op.fileid=f.fileid
where m.networkid=n.NetworkId and p.PosId=m.PosId and m.SessionId=s.SessionId and s.FileId=f.FileId

---------------- 
-- 2G Parte B
exec dbo.sp_lcc_dropifexists '_lcc_c0re_2G_Bside'
select  s.sessionType,
	null as LTEMeasReportId,	s.sessionidA as sessionid,		m.testid,			m.msgtime,				m.posid,	m.networkid,
	n.BCCH as Freq,				n.BSIC as cell,					m.RxLev as signal,	m.RxQual as quality,	n.CId,	m.Hopping,
	null RSSI,					null SINR0,						null SINR1,			null RNCID,
	p.longitude,		p.latitude,
	f.CallingModule,	RIGHT(left(f.imsi,5),2) as mnc, 
	op.operator, n.operator as ServingOperator,
	n.CGI,	n.lac,	n.RAC, n.technology,
	f.CollectionName,
	'B' as Side
INTO _lcc_c0re_2G_Bside
from MsgGsmReport m, NetworkInfo n, position p, sessionsB s, filelist f
			LEFT OUTER JOIN ( 
				select fileid, homeOperator operator
				from (
						select *, row_number() over (partition by fileid order by duration desc) id
						from
						(
							select fileid, HomeOperator, sum(duration) duration
							from networkinfo group by fileid, homeoperator
						) t
					 ) t where id=1
			) op on op.fileid=f.fileid
where m.networkid=n.NetworkId and p.PosId=m.PosId and m.SessionId=s.SessionId and s.FileId=f.FileId

--------------------------------
-- HACEMOS LA UNION DE TODAS LAS TEMPORALES
exec dbo.sp_lcc_dropifexists '_lcc_c0re_tecnologias_partes'
SELECT * 
INTO _lcc_c0re_tecnologias_partes 
FROM _lcc_c0re_4G_Aside
	UNION ALL
	SELECT * FROM _lcc_c0re_4G_Bside
	UNION ALL
	SELECT * FROM _lcc_c0re_3G_Aside
	UNION ALL
	SELECT * FROM _lcc_c0re_3G_Bside
	UNION ALL
	SELECT * FROM _lcc_c0re_2G_Aside
	UNION ALL
	SELECT * FROM _lcc_c0re_2G_Bside


--****************************************************************************************************************************************
-- Tabla temporal de la serving final
--****************************************************************************************************************************************
exec dbo.sp_lcc_dropifexists '_lcc_c0re_Serving_Cell_Table'
CREATE TABLE [dbo].[_lcc_c0re_Serving_Cell_Table](
		[sessionType] varchar(255) NULL,		
		[LTEMeasReportId] [bigint] NULL,
		[sessionid] [bigint] NULL,
		[testid] [bigint] NULL,
		[msgtime] [datetime2](3) NULL,
		[posid] [bigint] NULL,
		[networkid] [bigint] NULL,
		[Freq] [int] NULL,
		[cell] [int] NULL,
		[signal] [real] NULL,
		[quality] [real] NULL,
		[CId] [int] NULL,
		[Hopping] [bit] NULL,
		[RSSI] [real] NULL,
		[SINR0] [real] NULL,
		[SINR1] [real] NULL,
		[RNCID] [int] NULL,
		[longitude] [float] NULL,
		[latitude] [float] NULL,
		[CallingModule] [char](255) NULL,
		[mnc] [varchar](255) NULL,
		[operator] [varchar](255) NULL,
		[ServingOperator] [varchar](255) NULL,
		[CGI] [varchar](255) NULL,
		[lac] [int] NULL,
		[RAC] [int] NULL,
		[technology] [varchar](255) NULL,
		[CollectionName] [varchar](255) NULL,
		--[band] [nvarchar](255) NULL,
		
		-- Info columnas por portadoras		
		[Freq_SCC1] [int] NULL,
		[cell_SCC1] [int] NULL,
		[signal_SCC1] [int] NULL,
		[quality_SCC1] [int] NULL,
		[RSSI_SCC1] [int] NULL,
		[SINR0_SCC1] [int] NULL,
		[SINR1_SCC1] [int] NULL,
		--[band_SCC1] [nvarchar](255) NULL,
		[technology_SCC1] [nvarchar](255) NULL,

		[Freq_SCC2] [int] NULL,
		[cell_SCC2] [int] NULL,
		[signal_SCC2] [int] NULL,
		[quality_SCC2] [int] NULL,
		[RSSI_SCC2] [int] NULL,
		[SINR0_SCC2] [int] NULL,
		[SINR1_SCC2] [int] NULL,
		--[band_SCC2] [nvarchar](255) NULL,
		[technology_SCC2] [nvarchar](255) NULL,
		
		[Freq_SCC3] [int] NULL,
		[cell_SCC3] [int] NULL,
		[signal_SCC3] [int] NULL,
		[quality_SCC3] [int] NULL,
		[RSSI_SCC3] [int] NULL,
		[SINR0_SCC3] [int] NULL,
		[SINR1_SCC3] [int] NULL,
		--[band_SCC3] [nvarchar](255) NULL,
		[technology_SCC3] [nvarchar](255) NULL,
		
		[Freq_SCC4] [int] NULL,
		[cell_SCC4] [int] NULL,
		[signal_SCC4] [int] NULL,
		[quality_SCC4] [int] NULL,
		[RSSI_SCC4] [int] NULL,
		[SINR0_SCC4] [int] NULL,
		[SINR1_SCC4] [int] NULL,
		--[band_SCC4] [nvarchar](255) NULL,
		[technology_SCC4] [nvarchar](255) NULL,
		
		[Freq_SCC5] [int] NULL,
		[cell_SCC5] [int] NULL,
		[signal_SCC5] [int] NULL,
		[quality_SCC5] [int] NULL,
		[RSSI_SCC5] [int] NULL,
		[SINR0_SCC5] [int] NULL,
		[SINR1_SCC5] [int] NULL,
		--[band_SCC5] [nvarchar](255) NULL,
		[technology_SCC5] [nvarchar](255) NULL,
		
		[Freq_SCC6] [int] NULL,
		[cell_SCC6] [int] NULL,
		[signal_SCC6] [int] NULL,
		[quality_SCC6] [int] NULL,
		[RSSI_SCC6] [int] NULL,
		[SINR0_SCC6] [int] NULL,
		[SINR1_SCC6] [int] NULL,
		--[band_SCC6] [nvarchar](255) NULL,
		[technology_SCC6] [nvarchar](255) NULL,
		
		[Freq_SCC7] [int] NULL,
		[cell_SCC7] [int] NULL,
		[signal_SCC7] [int] NULL,
		[quality_SCC7] [int] NULL,
		[RSSI_SCC7] [int] NULL,
		[SINR0_SCC7] [int] NULL,
		[SINR1_SCC7] [int] NULL,
		--[band_SCC7] [nvarchar](255) NULL,
		[technology_SCC7] [nvarchar](255) NULL,

		[Side] [Varchar](255) NULL			
)


--------------------------------
--	fjla añadir insert into en lugar de union all, esto ralentiza el proceso y llena el tempdb	   
--------------------------------
insert into _lcc_c0re_Serving_Cell_Table
select	t.sessionType,
		t.LTEMeasReportId, t.sessionid,	t.testid, t.msgtime, t.posid, t.networkid, t.Freq, t.cell, t.signal, t.quality,
		t.CId, t.Hopping, t.RSSI, t.SINR0, t.SINR1, t.RNCID, t.longitude, t.latitude, t.CallingModule, t.mnc, 
		t.operator, t.ServingOperator, t.CGI, t.LAC, t.RAC, t.technology, t.CollectionName,

		-- New columns - radio info per carrier - SCC:1...7
		s1.Freq as Freq_SCC1, s1.cell as cell_SCC1, s1.signal as signal_SCC1, s1.quality as quality_SCC1, s1.RSSI as RSSI_SCC1, s1.SINR0 as SINR0_SCC1, s1.SINR1 as SINR1_SCC1, s1.technology as technology_SCC1,
		s2.Freq as Freq_SCC2, s2.cell as cell_SCC2, s2.signal as signal_SCC2, s2.quality as quality_SCC2, s2.RSSI as RSSI_SCC2, s2.SINR0 as SINR0_SCC2, s2.SINR1 as SINR1_SCC2, s2.technology as technology_SCC2,
		s3.Freq as Freq_SCC3, s3.cell as cell_SCC3, s3.signal as signal_SCC3, s3.quality as quality_SCC3, s3.RSSI as RSSI_SCC3, s3.SINR0 as SINR0_SCC3, s3.SINR1 as SINR1_SCC3, s3.technology as technology_SCC3,
		s4.Freq as Freq_SCC4, s4.cell as cell_SCC4, s4.signal as signal_SCC4, s4.quality as quality_SCC4, s4.RSSI as RSSI_SCC4, s4.SINR0 as SINR0_SCC4, s4.SINR1 as SINR1_SCC4, s4.technology as technology_SCC4,
		s5.Freq as Freq_SCC5, s5.cell as cell_SCC5, s5.signal as signal_SCC5, s5.quality as quality_SCC5, s5.RSSI as RSSI_SCC5, s5.SINR0 as SINR0_SCC5, s5.SINR1 as SINR1_SCC5, s5.technology as technology_SCC5,
		s6.Freq as Freq_SCC6, s6.cell as cell_SCC6, s6.signal as signal_SCC6, s6.quality as quality_SCC6, s6.RSSI as RSSI_SCC6, s6.SINR0 as SINR0_SCC6, s6.SINR1 as SINR1_SCC6, s6.technology as technology_SCC6,
		s7.Freq as Freq_SCC7, s7.cell as cell_SCC7, s7.signal as signal_SCC7, s7.quality as quality_SCC7, s7.RSSI as RSSI_SCC7, s7.SINR0 as SINR0_SCC7, s7.SINR1 as SINR1_SCC7, s7.technology as technology_SCC7,

		-- Side of session
		t.side
from
	_lcc_c0re_tecnologias_partes	 t	
		-- New columns - radio info per carrier - SCC:1...7
		LEFT OUTER JOIN _lcc_c0re_SCC s1 on (t.LTEMeasReportId=s1.LTEMeasReportId and s1.CarrierIndex=1)
		LEFT OUTER JOIN _lcc_c0re_SCC s2 on (t.LTEMeasReportId=s2.LTEMeasReportId and s2.CarrierIndex=2)
		LEFT OUTER JOIN _lcc_c0re_SCC s3 on (t.LTEMeasReportId=s3.LTEMeasReportId and s3.CarrierIndex=3)
		LEFT OUTER JOIN _lcc_c0re_SCC s4 on (t.LTEMeasReportId=s4.LTEMeasReportId and s4.CarrierIndex=4)
		LEFT OUTER JOIN _lcc_c0re_SCC s5 on (t.LTEMeasReportId=s5.LTEMeasReportId and s5.CarrierIndex=5)
		LEFT OUTER JOIN _lcc_c0re_SCC s6 on (t.LTEMeasReportId=s6.LTEMeasReportId and s6.CarrierIndex=6)
		LEFT OUTER JOIN _lcc_c0re_SCC s7 on (t.LTEMeasReportId=s7.LTEMeasReportId and s7.CarrierIndex=7)


--------------------------------
--Por session y side, ordenamos por instantes de tiempo
--------------------------------
exec dbo.sp_lcc_dropifexists '_lcc_c0re_Serving_Cell_Table_id'		
select *,	
	ROW_NUMBER() over (partition by sessionid, side order by msgtime asc) as idSide
into _lcc_c0re_Serving_Cell_Table_id
from _lcc_c0re_Serving_Cell_Table


--------------------------------
--Para poder detectar posteriormente duplicados en mismo instante de tiempo:
--Por session, side, msgTime identificamos la información anterior para en el caso de duplicados, se ordene por freq-technology anterior
--------------------------------
exec dbo.sp_lcc_dropifexists '_lcc_c0re_Serving_Cell_Table_info_Dup'		
select
	t1.*,
	t2.idSide as idAnterior,
	t2.freq as freqAnterior,
	t2.technology as technologyAnterior
into _lcc_c0re_Serving_Cell_Table_info_Dup
from (
		select sessionid,side,msgtime,min(idSide) as minIdSide,max(idSide) as maxIdSide, count(1) as 'Num_registros'
		from _lcc_c0re_Serving_Cell_Table_id
		group by sessionid,side,msgtime
	) t1
	left join  _lcc_c0re_Serving_Cell_Table_id t2
	on t1.sessionid=t2.sessionid and t1.minIdSide=t2.idSide +1 and t1.side=t2.side
order by 1,2,3 asc


--------------------------------------------------------------------------------------------------------------------------------
--Tabla CORE final:
--------------------------------------------------------------------------------------------------------------------------------
exec dbo.sp_lcc_dropifexists 'lcc_core_ServingCell_RAW_Table'
select
	case 
		when t1.sessionType='Data' then 
			db_name()+'_'+convert(varchar(256),t1.sessionid)+'_'+isnull(convert(varchar(256),t1.testid),'NA') COLLATE Latin1_General_CI_AS 
		when t1.sessionType in ('CALL', 'IDLE') then 
			db_name()+'_'+convert(varchar(256),t1.sessionid)+'_'+convert(varchar(256),'NA') COLLATE Latin1_General_CI_AS 
	end as key_BST, 	
	db_name() COLLATE Latin1_General_CI_AS as ddbb 
	
	,t1.[Side]
	,t1.msgtime
	,t1.[ServingOperator]		,t1.[CId]
	,master.dbo.fn_lcc_calculate_eNodeBIDFromNetworkInfo4G(t1.CId) as macro_eNBID_LTEcid
	,master.dbo.fn_lcc_calculate_cIDFromNetworkInfo4G(t1.CId) as sector_ID_LTEcid
	
	,t1.[CGI]		,t1.[LAC]	,t1.[RAC]
	,t1.[Hopping]	,t1.[RNCID]

	,t1.[Technology]		,t1.[Freq]		,t1.[Cell]		,t1.[Signal]		,t1.[Quality]		,t1.[RSSI]		,t1.[SINR0]			,t1.[SINR1]
	,t1.[Technology_SCC1]	,t1.[Freq_SCC1]	,t1.[Cell_SCC1]	,t1.[Signal_SCC1]	,t1.[Quality_SCC1]	,t1.[RSSI_SCC1]	,t1.[SINR0_SCC1]	,t1.[SINR1_SCC1]
	,t1.[Technology_SCC2]	,t1.[Freq_SCC2]	,t1.[Cell_SCC2]	,t1.[Signal_SCC2]	,t1.[Quality_SCC2]	,t1.[RSSI_SCC2]	,t1.[SINR0_SCC2]	,t1.[SINR1_SCC2]
	,t1.[Technology_SCC3]	,t1.[Freq_SCC3]	,t1.[Cell_SCC3]	,t1.[Signal_SCC3]	,t1.[Quality_SCC3]	,t1.[RSSI_SCC3]	,t1.[SINR0_SCC3]	,t1.[SINR1_SCC3]
	,t1.[Technology_SCC4]	,t1.[Freq_SCC4]	,t1.[Cell_SCC4]	,t1.[Signal_SCC4]	,t1.[Quality_SCC4]	,t1.[RSSI_SCC4]	,t1.[SINR0_SCC4]	,t1.[SINR1_SCC4]	  
	,t1.[Technology_SCC5]	,t1.[Freq_SCC5]	,t1.[Cell_SCC5]	,t1.[Signal_SCC5]	,t1.[Quality_SCC5]	,t1.[RSSI_SCC5]	,t1.[SINR0_SCC5]	,t1.[SINR1_SCC5]	  
	,t1.[Technology_SCC6]	,t1.[Freq_SCC6]	,t1.[Cell_SCC6]	,t1.[Signal_SCC6]	,t1.[Quality_SCC6]	,t1.[RSSI_SCC6]	,t1.[SINR0_SCC6]	,t1.[SINR1_SCC6]
	,t1.[Technology_SCC7]	,t1.[Freq_SCC7]	,t1.[Cell_SCC7]	,t1.[Signal_SCC7]	,t1.[Quality_SCC7]	,t1.[RSSI_SCC7]	,t1.[SINR0_SCC7]	,t1.[SINR1_SCC7]

	,ROW_NUMBER() over (partition by t1.sessionid order by t1.sessionid, t1.msgtime asc)	as id
	,ROW_NUMBER() over (partition by t1.sessionid, t1.msgtime order by t1.signal desc)		as msgtimeID
	,ROW_NUMBER() over (partition by t1.sessionid, t1.side 
		order by t1.msgtime asc, case when t2.Num_registros>1 then (case when t1.technology=t2.technologyAnterior and t1.freq=t2.freqAnterior then 1
																when t1.technology=t2.technologyAnterior and t1.freq<>t2.freqAnterior then 2
																else 3 end) else t2.Num_registros end asc
	) as idSide
	,ROW_NUMBER() over (partition by t1.sessionid, t1.side ,t1.testid
		order by t1.msgtime asc, case when t2.Num_registros>1 then (case when t1.technology=t2.technologyAnterior and t1.freq=t2.freqAnterior then 1
																when t1.technology=t2.technologyAnterior and t1.freq<>t2.freqAnterior then 2
																else 3 end) else t2.Num_registros end asc
	) as idSide_Test
	--,convert(nvarchar(255),null) as Band

into lcc_core_ServingCell_RAW_Table
from 
	_lcc_c0re_Serving_Cell_Table t1
	inner join _lcc_c0re_Serving_Cell_Table_info_Dup t2
		on t1.sessionid=t2.sessionid and t1.msgtime=t2.msgtime and t1.side=t2.side

----------------------------------------------------------------- select * from lcc_core_Serving_Cell_Table
		
--------------------------------
-- Drop temporal table
--------------------------------
exec dbo.sp_lcc_dropifexists '_lcc_c0re_SCC'
exec dbo.sp_lcc_dropifexists '_lcc_c0re_SCC_Temp'
exec dbo.sp_lcc_dropifexists '_lcc_c0re_4G_Aside'
exec dbo.sp_lcc_dropifexists '_lcc_c0re_4G_Bside'
exec dbo.sp_lcc_dropifexists '_lcc_c0re_3G_Aside'
exec dbo.sp_lcc_dropifexists '_lcc_c0re_3G_Bside'
exec dbo.sp_lcc_dropifexists '_lcc_c0re_2G_Aside'
exec dbo.sp_lcc_dropifexists '_lcc_c0re_2G_Bside'
exec dbo.sp_lcc_dropifexists '_lcc_c0re_tecnologias_partes'
exec dbo.sp_lcc_dropifexists '_lcc_c0re_Serving_Cell_Table'
exec dbo.sp_lcc_dropifexists '_lcc_c0re_Serving_Cell_Table_id'		
exec dbo.sp_lcc_dropifexists '_lcc_c0re_Serving_Cell_Table_info_Dup'		



