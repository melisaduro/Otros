USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_lcc_core_Voice_CST_KPIs_Table]    Script Date: 19/04/2018 14:27:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[sp_create_lcc_core_Voice_CST_KPIs_Table]
		@Config [nvarchar](max)			= 'SpainOSP'
as

-- DESCRIPTION ----------------------------------------------------------------------------------------------------------------------
--
--		* COLLATE Latin1_General_CI_AS	-> database_default
--
--
--		* Base TABLE/VIEW:			callanalysis
--		
--		**** LEFT OUTER JOIN
--
--					ResultsKPIs			-- VF-KPIID		SQ-KPIID		KPI	Description
--											75001		  10108			Accessibility - Voice(CS) - Telephony M2M (10108)
--											75002		  10108			Accessibility - Voice(CS) - Call Setup Time Voice MtoM (10108)
--														  [from Dial to connect]

--											n/a			  10109			Accessibility - Voice(CS) - Telephony M2M Connect Net
--														  [Dial2Connect(origen) - AnswTime(destino)]
				
--											75010		  20103			Retainability - Voice(CS) - Telephony M2M (20103)
--														  [from Connect/Connect ACK t to Disconnect/Release/Release Complete]
--		
--										-- KPIIDs used in CU:
--														10100			CST_Alerting_M2F_CS		-- M2F (CS)
--														11000			CST_Alerting_M2F_VOLTE
--														10104			CST_Alerting_M2M		--could be used for M2M ??
--														10101			CST_Connect_M2F_CS
--														11010			CST_Connect_M2F_VOLTE
--														10109			CST_Connect_M2M_CSPS_net
--														10175			CSFB_Delay 
--														10178			CSFB_Service
--														10106			CST_Alerting_M2M_VOLTE

-------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------
-- (1)		SQ-KPIID selected by default:
--***********************************************************************************************************************************
declare @10108_access_cst_M2M as int	= 10108
declare @VF_75001_accessM2M		 as int	= 75001
declare @VF_75002_cstM2M		 as int	= 75002

declare @20103_retainM2M		 as int	= 20103
declare @VF_75010_retainM2M		 as int	= 75010


--***********************************************************************************************************************************
-- "Usados" en procesado M2F para el ALERTING:
declare @10100_CST_Alerting_M2F_CS as int=10100			-- los usamos en M2F para CS
--StartTime = ● GSM:	Timestamp of ‘Channel Request’.
			--● UMTS:	Timestamp of ‘RRCConncetionRequest’.
			--			(With establishment cause ‘originatingconversationalCall’)
			--			If not available, then ‘RRCConnectionSetup’. If not available, then ‘RRCConnectionSetupComplete’.
			--			If the phone is in a connected state (like Smartphones) the Dial marker is used.

			--● LTE CSFB:	LTE-RRCConnectionRequest
			--				(With establishment cause ‘mo_Data’)
			--				If not available, then EMM Extended Service Request

			--● ISDN/PSTN:	Timestamp of Dial command sent to the board

-- EndTime = GSM/UMTS:	Timestamp of ‘CC:Alerting’. 
--						If not available, then ‘CC:Connect’. 
--						If not available, then CC:ConnectAcknowledge’ 

declare @11000_CST_Alerting_M2F_VOLTE as int=11000 
--StartTime:	SIP: INVITE
--EndTime:		180 RINGING

--------------------
declare @10104_CST_Alerting_M2M as int=10104			-- podria usarse en M2M ??
-- Same as 10100 (always from calling side) -- Trigger messages always taken from the calling party (active side))	
--------------------

--***********************************************************************************************************************************
-- Usados en procesado M2F para el CONNECT:
declare @10101_CST_Connect_M2F_CS as int=10101 
--StartTime = ● GSM:	Timestamp of ‘Channel Request’.
			--● UMTS:	Timestamp of ‘RRCConncetionRequest’
			--			(With establishment cause ‘originatingconversationalCall’)
			--			If not available, then ‘RRCConnectionSetup’. If not available, then ‘RRCConnectionSetup-Complete’. 
			--			If the phone is in a connected state (like Smartphones) the Dial marker is used.

			--● LTE CSFB:	LTE-RRCConnectionRequest
			--				(With establishment cause ‘mo_Data’)
			--				If not available, then EMM Extended Service Request

			--● ISDN/PSTN: Timestamp of Dial command sent to the board

--EndTime = GSM/UMTS: Timestamp of ‘CC:Connect’

declare @11010_CST_Connect_M2F_VOLTE as int=11010 
--StartTime: SIP: INVITE
--EndTime:	 SIP: 200 OK
--------------------

--***********************************************************************************************************************************
-- Los KPIS para M2M se calculan a partir de los mensajes de capa 3.
--***********************************************************************************************************************************
-- Hay un kpiid relativamente nuevo (03/2016) que parece que funciona bien - se implemento, pero se quito luego
-- Se agrega por ir viendo si sirve o no -- Solo es valido a partir de D16
-- KPIID 10109 de SQ:	Dial2Connect(origen) - AnswTime(destino)
declare @10109_CST_Connect_M2M_CSPS_net as int = 10109
--StartTime = ● GSM:	Timestamp of ‘Channel Request’.
			--● UMTS:	Timestamp of ‘RRCConncetionRequest’.
			--			(With establishment cause ‘originatingconversationalCall’)
			--			If not available, then ‘RRCConnectionSetup’. If not available, then ‘RRCConnectionSetupComplete’.
			--			If the phone is in a connected state (like Smartphones) the Dial marker is used.

			--● LTE CSFB:	LTE-RRCConnectionRequest
			--				(With establishment cause ‘mo_Data’)
			--				If not available, then EMM Extended Service Request

			--● ISDN/PSTN: Timestamp of Dial command sent to the board

--EndTime = GSM/UMTS: CC : Connect

--Duration =  Time in ms between StartTime and EndTime minus the ‘accept delay’ on the called side. 
			--This is the time between CC:Alerting to CC:Connect for CS calls 
			--or the time between SIP: INVITE RINGING and SIP: INVITE OK for PS calls, for example, VoLTE


--***********************************************************************************************************************************
-- CSFB from LTE:
--	Currently, the LTE specification does not have a circuit-switched voice service. 
--	When a subscriber initiates a call while camping on an LTE cell, 
--	the network transfers the device to another radio access technology through process called Circuit Switched Fall Back (CSFB).
--***********************************************************************************************************************************
declare	@10175_CSFB_Delay as int = 10175 
--StartTime = LTE: EMM-Extended service Request
--EndTime	= UMTS: RRCConnectionRequest
			--GSM: CM Service Request/Paging Response

declare	@10178_CSFB_Service as int = 10178 
--StartTime =LTE: EMM-Extended service Request
--EndTime	= CC: Alering

declare @10106_CST_Alerting_M2M_VOLTE as int = 10106
--StartTime = IMS SIP INVITE: Request
--EndTime	= 180

-----------------------------------------------------------
-- (1.2)	Create table with SQ-KPIID selected by default:
--********************************************************************************
------------------------------------- select * from _lcc_c0re_Voice_CST_KPIs_Table_SQ
exec sp_lcc_dropifexists '_lcc_c0re_Voice_CST_KPIs_Table_SQ'
select 
	db_name()+'_'+convert(varchar(256),c.sessionidA)+'_'+isnull(convert(varchar(256),'NA'),'NA') COLLATE Latin1_General_CI_AS as key_BST, 
	db_name() COLLATE Latin1_General_CI_AS as ddbb,
	c.sessionid, c.sessionidA, c.side,
	c.calltype, c.calldir,

	---------------- Access-CST:	10108 - Accessibility - Voice(CS) - Telephony M2M Connect Net (Dial)
	kpi10108.StartTime	as kpi10108_StartTime,	kpi10108.Duration	as kpi10108_Duration, 					kpi10108.ErrorCode as kpi10108_ErrorCode,	
	/*kpi10108.Value3		as kpi10108_StartEvent,	kpi10108.Value4		as kpi10108_EndEvent,*/					kpi10108.kpiSamples as kpi10108_kpiSamples,
	case when kpi10108.ErrorCode<>0 then 1 else 0 end as kpi101081_Fail,

	---------------- Access:		75001 - Custom KPI - Accessibility - Voice(CS) - Telephony M2M (10108)
	VF_kpi75001.StartTime	as VF_kpi75001_StartTime,	VF_kpi75001.Duration	as VF_kpi75001_Duration,	VF_kpi75001.ErrorCode  as VF_kpi75001_ErrorCode,	
	/*VF_kpi75001.Value3		as VF_kpi75001_StartEvent,	VF_kpi75001.Value4		as VF_kpi75001_EndEvent,*/	VF_kpi75001.kpiSamples as VF_kpi75001_kpiSamples,
	case when VF_kpi75001.ErrorCode<>0 then 1 else 0 end as VF_kpi75001_Fail,

	---------------- CST:			75002 - Custom KPI - Accessibility - Voice(CS) - Call Setup Time Voice MtoM (10108)
	VF_kpi75002.StartTime	as VF_kpi75002_StartTime,	VF_kpi75002.Duration	as VF_kpi75002_Duration,	VF_kpi75002.ErrorCode  as VF_kpi75002_ErrorCode,	
	/*VF_kpi75002.Value3		as VF_kpi75002_StartEvent,	VF_kpi75002.Value4		as VF_kpi75002_EndEvent,*/	VF_kpi75002.kpiSamples as VF_kpi75002_kpiSamples,
	case when VF_kpi75002.ErrorCode<>0 then 1 else 0 end as VF_kpi75002_Fail,

	---------------- Retain:		20103 - Retainability - Voice(CS) - Telephony (Connect-Status) // 75010 - Custom KPI - Retainability - Voice(CS) - Telephony M2M (20103)
	kpi20103.StartTime	as kpi20103_StartTime,			kpi20103.Duration		as kpi20103_Duration,		kpi20103.ErrorCode	as kpi20103_ErrorCode,	
	kpi20103.Value3		as kpi20103_StartEvent,			kpi20103.Value4			as kpi20103_EndEvent,		kpi20103.kpiSamples as kpi20103_kpiSamples,
	case when kpi20103.ErrorCode<>0 then 1 else 0 end as kpi20103_Fail,

	VF_kpi75010.StartTime	as VF_kpi75010_StartTime,	VF_kpi75010.Duration	as VF_kpi75010_Duration,	VF_kpi75010.ErrorCode  as VF_kpi75010_ErrorCode,	
	VF_kpi75010.Value3		as VF_kpi75010_StartEvent,	VF_kpi75010.Value4		as VF_kpi75010_EndEvent,	VF_kpi75010.kpiSamples as VF_kpi75010_kpiSamples,
	case when VF_kpi75010.ErrorCode<>0 then 1 else 0 end as VF_kpi75010_Fail,


	---------------- "Usados" en procesado ----------------
	-- 10100 - Accessibility - Voice(CS) - Telephony
	kpi10100.StartTime	as kpi10100_StartTime,		kpi10100.Duration	as kpi10100_Duration,	kpi10100.ErrorCode	as kpi10100_ErrorCode,	
	kpi10100.Value3		as kpi10100_StartEvent,		kpi10100.Value4		as kpi10100_EndEvent,	kpi10100.kpiSamples as kpi10100_kpiSamples,
	case when kpi10100.ErrorCode<>0 then 1 else 0 end as kpi10100_Fail,

	-- 11000 - Accessibility - SIP - Post Dial Delay (Active State)
	kpi11000.StartTime	as kpi11000_StartTime,				kpi11000.Duration	as kpi11000_Duration,		kpi11000.ErrorCode	as kpi11000_ErrorCode,	
	/*kpi11000.Value3		as kpi11000_StartEvent,*/		kpi11000.Value4		as kpi11000_PostDialDelay,	kpi11000.kpiSamples as kpi11000_kpiSamples,
	case when kpi11000.ErrorCode<>0 then 1 else 0 end as kpi11000_Fail,

	-- 10104 - Accessibility - Voice(CS) - Telephony AB
	kpi10104.StartTime	as kpi10104_StartTime,		kpi10104.Duration	as kpi10104_Duration,	kpi10104.ErrorCode	as kpi10104_ErrorCode,	
	kpi10104.Value3		as kpi10104_StartEvent,		kpi10104.Value4		as kpi10104_EndEvent,	kpi10104.kpiSamples as kpi10104_kpiSamples,
	case when kpi10104.ErrorCode<>0 then 1 else 0 end as kpi10104_Fail,

	-- 10101 - Accessibility - Voice(CS) - Telephony Connect
	kpi10101.StartTime	as kpi10101_StartTime,		kpi10101.Duration	as kpi10101_Duration,	kpi10101.ErrorCode	as kpi10101_ErrorCode,	
	kpi10101.Value3		as kpi10101_StartEvent,		kpi10101.Value4		as kpi10101_EndEvent,	kpi10101.kpiSamples as kpi10101_kpiSamples,
	case when kpi10101.ErrorCode<>0 then 1 else 0 end as kpi10101_Fail,

	-- 11010 - Accessibility - SIP - Call Access
	kpi11010.StartTime	as kpi11010_StartTime,		kpi11010.Duration	as kpi11010_Duration,	kpi11010.ErrorCode	as kpi11010_ErrorCode,	
	kpi11010.Value3		as kpi11010_StartEvent,		kpi11010.Value4		as kpi11010_EndEvent,	kpi11010.kpiSamples as kpi11010_kpiSamples,
	case when kpi11010.ErrorCode<>0 then 1 else 0 end as kpi11010_Fail,

	-- 10109 - Accessibility - Voice(CS) - Telephony M2M Connect Net
	kpi10109.StartTime	as kpi10109_StartTime,		kpi10109.Duration	as kpi10109_Duration,	kpi10109.ErrorCode	as kpi10109_ErrorCode,	
	kpi10109.Value3		as kpi10109_StartEvent,		kpi10109.Value4		as kpi10109_EndEvent,	kpi10109.kpiSamples as kpi10109_kpiSamples,
	case when kpi10109.ErrorCode<>0 then 1 else 0 end as kpi10109_Fail,

	-- 10175 - Accessibility - Voice(LTE CSFB) - Telephony Fallback Delay
	kpi10175.StartTime	as kpi10175_StartTime,		kpi10175.Duration	as kpi10175_Duration,	kpi10175.ErrorCode	as kpi10175_ErrorCode,	
	kpi10175.Value3		as kpi10175_StartEvent,		kpi10175.Value4		as kpi10175_EndEvent,	kpi10175.kpiSamples as kpi10175_kpiSamples,
	kpi10175.Value5		as kpi10175_RRCCon_EstablishCause,
	case when kpi10175.ErrorCode<>0 then 1 else 0 end as kpi10175_Fail,

	-- 10178 - Accessibility - Voice(LTE CSFB) - Telephony Service
	kpi10178.StartTime	as kpi10178_StartTime,		kpi10178.Duration	as kpi10178_Duration,	kpi10178.ErrorCode	as kpi10178_ErrorCode,	
	kpi10178.Value3		as kpi10178_StartEvent,		kpi10178.Value4		as kpi10178_EndEvent,	kpi10178.kpiSamples as kpi10178_kpiSamples,
	kpi10178.Value5		as kpi10178_RRCCon_EstablishCause,
	case when kpi10178.ErrorCode<>0 then 1 else 0 end as kpi10178_Fail,

	-- 10106 - Accessibility - Voice(CS) - Telephony Overall (Alerting)
	kpi10106.StartTime	as kpi10106_StartTime,		kpi10106.Duration	as kpi10106_Duration,	kpi10106.ErrorCode	as kpi10106_ErrorCode,	
	kpi10106.Value3		as kpi10106_StartEvent,		kpi10106.Value4		as kpi10106_EndEvent,	kpi10106.kpiSamples as kpi10106_kpiSamples,
	kpi10106.Value5		as kpi10106_RRCCon_EstablishCause,
	case when kpi10106.ErrorCode<>0 then 1 else 0 end as kpi10106_Fail


into _lcc_c0re_Voice_CST_KPIs_Table_SQ
from callanalysis c

		-- Only first KPIID value is considered (as in Metrics procedure):
		LEFT OUTER JOIN (select r.sessionid, r.kpiid, r.StartTime, r.Duration, r.ErrorCode, r.Value1, r.Value2, r.Value3, r.Value4, r.Value5,
								m.kpiSamples
						 from ResultsKPI r,
							 (	select sessionid, KPIID, min(MsgID) as minMsgID, count(*) as kpiSamples from ResultsKPI 
								where KPIId	= @10108_access_cst_M2M
								group by sessionid, KPIID	) m
						 where r.msgid=m.minMsgID					 
		) kpi10108 on (c.sessionid=kpi10108.sessionid)

		LEFT OUTER JOIN (select r.sessionid, r.kpiid, r.StartTime, r.Duration, r.ErrorCode, r.Value1, r.Value2, r.Value3, r.Value4, r.Value5,
								m.kpiSamples
						 from ResultsKPI r,
							 (	select sessionid, KPIID, min(MsgID) as minMsgID, count(*) as kpiSamples from ResultsKPI 
								where KPIId	= @VF_75001_accessM2M
								group by sessionid, KPIID	) m
						 where r.msgid=m.minMsgID					 
		) VF_kpi75001 on (c.sessionid=VF_kpi75001.sessionid)

		LEFT OUTER JOIN (select r.sessionid, r.kpiid, r.StartTime, r.Duration, r.ErrorCode, r.Value1, r.Value2, r.Value3, r.Value4, r.Value5,
								m.kpiSamples
						 from ResultsKPI r,
							 (	select sessionid, KPIID, min(MsgID) as minMsgID, count(*) as kpiSamples from ResultsKPI 
								where KPIId	= @VF_75002_cstM2M
								group by sessionid, KPIID	) m
						 where r.msgid=m.minMsgID
						 
		) VF_kpi75002 on (c.sessionid=VF_kpi75002.sessionid)

		LEFT OUTER JOIN (select r.sessionid, r.kpiid, r.StartTime, r.Duration, r.ErrorCode, r.Value1, r.Value2, r.Value3, r.Value4, r.Value5,
								m.kpiSamples
						 from ResultsKPI r,
							 (	select sessionid, KPIID, min(MsgID) as minMsgID, count(*) as kpiSamples from ResultsKPI 
								where KPIId	= @20103_retainM2M
								group by sessionid, KPIID	) m
						 where r.msgid=m.minMsgID					 
		) kpi20103 on (c.sessionid=kpi20103.sessionid)

		LEFT OUTER JOIN (select r.sessionid, r.kpiid, r.StartTime, r.Duration, r.ErrorCode, r.Value1, r.Value2, r.Value3, r.Value4, r.Value5,
								m.kpiSamples
						 from ResultsKPI r,
							 (	select sessionid, KPIID, min(MsgID) as minMsgID, count(*) as kpiSamples from ResultsKPI 
								where KPIId	= @VF_75010_retainM2M
								group by sessionid, KPIID	) m
						 where r.msgid=m.minMsgID					 
		) VF_kpi75010 on (c.sessionid=VF_kpi75010.sessionid)


		---------------- "Usados" en procesado ----------------
		LEFT OUTER JOIN (select r.sessionid, r.kpiid, r.StartTime, r.Duration, r.ErrorCode, r.Value1, r.Value2, r.Value3, r.Value4, r.Value5,
								m.kpiSamples
						 from ResultsKPI r,
							 (	select sessionid, KPIID, min(MsgID) as minMsgID, count(*) as kpiSamples from ResultsKPI 
								where KPIId	= @10100_CST_Alerting_M2F_CS
								group by sessionid, KPIID	) m
						 where r.msgid=m.minMsgID					 
		) kpi10100 on (c.sessionid=kpi10100.sessionid)

		LEFT OUTER JOIN (select r.sessionid, r.kpiid, r.StartTime, r.Duration, r.ErrorCode, r.Value1, r.Value2, r.Value3, r.Value4, r.Value5,
								m.kpiSamples
						 from ResultsKPI r,
							 (	select sessionid, KPIID, min(MsgID) as minMsgID, count(*) as kpiSamples from ResultsKPI 
								where KPIId	= @11000_CST_Alerting_M2F_VOLTE
								group by sessionid, KPIID	) m
						 where r.msgid=m.minMsgID					 
		) kpi11000 on (c.sessionid=kpi11000.sessionid)

		LEFT OUTER JOIN (select r.sessionid, r.kpiid, r.StartTime, r.Duration, r.ErrorCode, r.Value1, r.Value2, r.Value3, r.Value4, r.Value5,
								m.kpiSamples
						 from ResultsKPI r,
							 (	select sessionid, KPIID, min(MsgID) as minMsgID, count(*) as kpiSamples from ResultsKPI 
								where KPIId	= @10104_CST_Alerting_M2M
								group by sessionid, KPIID	) m
						 where r.msgid=m.minMsgID					 
		) kpi10104 on (c.sessionid=kpi10104.sessionid)


		LEFT OUTER JOIN (select r.sessionid, r.kpiid, r.StartTime, r.Duration, r.ErrorCode, r.Value1, r.Value2, r.Value3, r.Value4, r.Value5,
								m.kpiSamples
						 from ResultsKPI r,
							 (	select sessionid, KPIID, min(MsgID) as minMsgID, count(*) as kpiSamples from ResultsKPI 
								where KPIId	= @10101_CST_Connect_M2F_CS
								group by sessionid, KPIID	) m
						 where r.msgid=m.minMsgID					 
		) kpi10101 on (c.sessionid=kpi10101.sessionid)

		LEFT OUTER JOIN (select r.sessionid, r.kpiid, r.StartTime, r.Duration, r.ErrorCode, r.Value1, r.Value2, r.Value3, r.Value4, r.Value5,
								m.kpiSamples
						 from ResultsKPI r,
							 (	select sessionid, KPIID, min(MsgID) as minMsgID, count(*) as kpiSamples from ResultsKPI 
								where KPIId	= @11010_CST_Connect_M2F_VOLTE
								group by sessionid, KPIID	) m
						 where r.msgid=m.minMsgID					 
		) kpi11010 on (c.sessionid=kpi11010.sessionid)


		LEFT OUTER JOIN (select r.sessionid, r.kpiid, r.StartTime, r.Duration, r.ErrorCode, r.Value1, r.Value2, r.Value3, r.Value4, r.Value5,
								m.kpiSamples
						 from ResultsKPI r,
							 (	select sessionid, KPIID, min(MsgID) as minMsgID, count(*) as kpiSamples from ResultsKPI 
								where KPIId	= @10109_CST_Connect_M2M_CSPS_net
								group by sessionid, KPIID	) m
						 where r.msgid=m.minMsgID					 
		) kpi10109 on (c.sessionid=kpi10109.sessionid)


		LEFT OUTER JOIN (select r.sessionid, r.kpiid, r.StartTime, r.Duration, r.ErrorCode, r.Value1, r.Value2, r.Value3, r.Value4, r.Value5,
								m.kpiSamples
						 from ResultsKPI r,
							 (	select sessionid, KPIID, min(MsgID) as minMsgID, count(*) as kpiSamples from ResultsKPI 
								where KPIId	= @10175_CSFB_Delay
								group by  sessionid, KPIID	) m
						 where r.msgid=m.minMsgID					 
		) kpi10175 on (c.sessionid=kpi10175.sessionid)

		LEFT OUTER JOIN (select r.sessionid, r.kpiid, r.StartTime, r.Duration, r.ErrorCode, r.Value1, r.Value2, r.Value3, r.Value4, r.Value5,
								m.kpiSamples
						 from ResultsKPI r,
							 (	select sessionid, min(MsgID) as minMsgID, count(*) as kpiSamples from ResultsKPI 
								where KPIId	= @10178_CSFB_Service
								group by sessionid, KPIID	) m
						 where r.msgid=m.minMsgID					 
		) kpi10178 on (c.sessionid=kpi10178.sessionid)

		LEFT OUTER JOIN (select r.sessionid, r.kpiid, r.StartTime, r.Duration, r.ErrorCode, r.Value1, r.Value2, r.Value3, r.Value4, r.Value5,
								m.kpiSamples
						 from ResultsKPI r,
							 (	select sessionid, min(MsgID) as minMsgID, count(*) as kpiSamples from ResultsKPI 
								where KPIId	= @10106_CST_Alerting_M2M_VOLTE
								group by sessionid, KPIID	) m
						 where r.msgid=m.minMsgID					 
		) kpi10106 on (c.sessionid=kpi10106.sessionid)

option (optimize for unknown)

--***********************************************************************************************************************************
--		Tabla CORE final:
--***********************************************************************************************************************************
------declare @Config as [nvarchar](max)='SpainOSP'
exec('
	exec sp_lcc_dropifexists ''lcc_core_Voice_'+@Config+'_CST_KPIs_Table_SQ''	
	select * 
	into lcc_core_Voice_'+@Config+'_CST_KPIs_Table_SQ
	from _lcc_c0re_Voice_CST_KPIs_Table_SQ
')


------------------------------------- select * from lcc_core_Voice_CST_KPIs_Table_SQ

