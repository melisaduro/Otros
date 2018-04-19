USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_lcc_core_Voice_Metrics_TimeStamp_Table_PdteACT]    Script Date: 19/04/2018 11:35:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[sp_create_lcc_core_Voice_Metrics_TimeStamp_Table] 
		@Config [nvarchar](max)			= 'SpainOSP'
as

-- DESCRIPTION ----------------------------------------------------------------------------------------------------------------------
--
--		* COLLATE Latin1_General_CI_AS	-> database_default
--
--		* Info from CALLING PARTY is considered
--
--		* Used:		vlcc_Layer3_core (4G) & vIMSSIPMessage (VOLTE)
--
--		* VIP:		callStartTime_Dial / callSetupTime_ConACK / callEndTime_Disconnect
--
--					callStartTime_Dial			=			Dial		- MANDATORY
--					callEndTime_Disconnect		=			case when Disconnect_time is not null then Disconnect_time  else
--																case when Release_time is not null then Release_time else
--																	case when ReleaseComplete_time is not null then ReleaseComplete_time else
--																		 case when VoLTE_Bye_req_time is not null then VoLTE_Bye_req_time else
--																			case when VoLTE_ByeOK_time is not null then VoLTE_ByeOK_time else
--
--																-- WO Calling Party info, we get Receivin Party Info:		
--																					case when DisConnect_Receiving_Party_time is not null then DisConnect_Receiving_Party_time  else
--																						case when Release_Receiving_Party_time is not null then Release_Receiving_Party_time else
--																							case when ReleaseComplete_Receiving_Party_time is not null then ReleaseComplete_Receiving_Party_time else
--																								 case when VoLTE_Bye_req_time_Receiving_Party is not null then VoLTE_Bye_req_time_Receiving_Party  else
--																									case when VoLTE_ByeOK_time_Receiving_Party is not null then VoLTE_ByeOK_time_Receiving_Party 
--																										end end end end end end end end end end

--					callSetupTime_ConACK		=			case when ConnectACK_time is not null then ConnectACK_time else
--																case when VoLTE_InviteOK_time is not null then VoLTE_InviteOK_time 
--																	end end 
--
--		En CAIDAS Y COMPLETADAS => duracion:		callSetupTime_ConACK	=>	callEndTime_Disconnect
--		En BLOQUEOS				=> duracion:		callStartTime_Dial		=>	callEndTime_Disconnect (por definicion, la llamada no ha conectado)
--
--													-------------
--													-- callDuration_Dial2Disconnect 
--													update _lcc_c0re_Voice_Metrics_TimeStamp_Table
--													set callDuration_Dial2Disconnect=datediff(ms, callStartTime_Dial, callEndTime_Disconnect)
--
--													-------------
--													-- callDuration_ConACK2Disconnect 
--													update _lcc_c0re_Voice_Metrics_TimeStamp_Table
--													set callDuration_ConACK2Disconnect=datediff(ms, callSetupTime_ConACK, callEndTime_Disconnect)
--
--  FJLA 20180117 sustituyo las referencias a vlcc_layer3 por vlcc_layer3_comp
-------------------------------------------------------------------------------------------------------------------------------------
exec SQKeyValueInit 'C:\L3KeyValue_16.3'

--------------------------------------- 
-- 1) Buscampos todos los TMSI y los establishmentCause  que haya reportado el terminal: 
exec sp_lcc_dropifexists '_tmsi'
SELECT v.sessionid, v.msgtime,
	  dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'UL_CCCH_Message;message;c1;rrcConnectionRequest;criticalExtensions;rrcConnectionRequest_r8;ue_Identity;s_TMSI;m_TMSI') as m_TMSI,
	  dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'UL_CCCH_Message;message;c1;rrcConnectionRequest;criticalExtensions;rrcConnectionRequest_r8;establishmentCause') as establishmentCause
into _tmsi
FROM vlcc_layer3_core v
WHERE v.l3_message ='rrcConnectionRequest'
	  and dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'m_TMSI') <> ''
	  
--select distinct establishmentCause from _tmsi
--select * from _tmsi

-------------------------------------
-- 2) Los ordenamos por tiempo por sesion y TMSI:
exec sp_lcc_dropifexists '_rrcConnectionRequest_tmsi'
select 
	*, 
	ROW_NUMBER() OVER(partition by sessionid, m_TMSI ORDER BY msgtime ASC) AS id 
into _rrcConnectionRequest_tmsi
from _tmsi

--select * from _rrcConnectionRequest_tmsi

exec sp_lcc_dropifexists '_lcc_c0re_Voice_Metrics_TimeStamp_Table'
----------------------------------------------------------------		select * from _lcc_c0re_Voice_Metrics_TimeStamp_Table					
select 
	db_name()+'_'+convert(varchar(256),s.sessionid)+'_'+isnull(convert(varchar(256),'NA'),'NA') COLLATE Latin1_General_CI_AS as key_BST, 
	db_name() COLLATE Latin1_General_CI_AS as ddbb,
	s.sessionid, s.sessionidB, validA, validB,
	s.calltype, s.calldir, s.callstatus

	-- Margenes de la llamada, que serán utilizados en otros calculos:
	,convert(datetime2(3),null)		callStartTime_Dial								-- mandatory
	,convert(datetime2(3),null)		callSetupTime_ConACK	
	,convert(int,null)				callSetupTime_ConACK_samples				
	,convert(datetime2(3),null)		callEndTime_Disconnect				
	,convert(int,null)				callEndTime_Disconnect_samples

	,convert(int,null)				callDuration_Dial2Disconnect
	,convert(int,null)				callDuration_ConACK2Disconnect

	-- START INFO:
	,convert(datetime2(3),null)		StartDial
	,convert(datetime2(3),null)		Dial

	--**************** NO VOLTE
	,convert(datetime2(3),null)		CMServiceRequest_time
	,convert(int,null)				CMServiceRequest_samples
	,convert(int,null)				CMServiceRequest_Freq 

	,convert(datetime2(3),null)		Paging_time
	,convert(int,null)				Paging_samples
	,convert(int,null)				Paging_Freq 

	,convert(datetime2(3),null)		PagingResponse_time
	,convert(int,null)				PagingResponse_samples
	,convert(int,null)				PagingResponse_Freq 

	,convert(datetime2(3),null)		Setup_time
	,convert(int,null)				Setup_samples
	,convert(int,null)				Setup_Freq 

	,convert(datetime2(3),null)		Setup_Receiving_Party_time
	,convert(int,null)				Setup_Receiving_Party_samples
	,convert(int,null)				Setup_Receiving_Party_Freq 

	,convert(datetime2(3),null)		CallProceeding_time
	,convert(int,null)				CallProceeding_samples
	,convert(int,null)				CallProceeding_Freq 

	,convert(datetime2(3),null)		CallConfirmed_time
	,convert(int,null)				CallConfirmed_samples
	,convert(int,null)				CallConfirmed_Freq 

	,convert(datetime2(3),null)		Progress_time		-- Solo para las FAILS??
	,convert(int,null)				Progress_samples
	,convert(int,null)				Progress_Freq 

	,convert(datetime2(3),null)		Alerting_time
	,convert(int,null)				Alerting_samples
	,convert(int,null)				Alerting_Freq 

	,convert(datetime2(3),null)		Alerting_Receiving_Party_time
	,convert(int,null)				Alerting_Receiving_Party_samples
	,convert(int,null)				Alerting_Receiving_Party_Freq 

	,convert(datetime2(3),null)		Connect_time
	,convert(int,null)				Connect_samples
	,convert(int,null)				Connect_Freq 

	,convert(datetime2(3),null)		Connect_Receiving_Party_time
	,convert(int,null)				Connect_Receiving_Party_samples
	,convert(int,null)				Connect_Receiving_Party_Freq 

	,convert(datetime2(3),null)		ConnectAck_time
	,convert(int,null)				ConnectAck_samples
	,convert(int,null)				ConnectAck_Freq 

	,convert(datetime2(3),null)		ConnectAck_Receiving_Party_time
	,convert(int,null)				ConnectAck_Receiving_Party_samples
	,convert(int,null)				ConnectAck_Receiving_Party_Freq 


	--**************** CSFB no VOLTE:
	,convert(datetime2(3),null)		LTE_RRCConnectionRequest_time
	,convert(int,null)				LTE_RRCConnectionRequest_samples
	,convert(int,null)				LTE_RRCConnectionRequest_Freq 

	,convert(datetime2(3),null)		LTE_RRCConnectionRequest_Receiving_Party_time
	,convert(int,null)				LTE_RRCConnectionRequest_Receiving_Party_samples
	,convert(int,null)				LTE_RRCConnectionRequest_Receiving_Party_Freq 

	,convert(datetime2(3),null)		LTE_ExtendedServiceRequest_time
	,convert(int,null)				LTE_ExtendedServiceRequest_samples
	,convert(int,null)				LTE_ExtendedServiceRequest_Freq 

	,convert(datetime2(3),null)		LTE_ExtendedServiceRequest_Receiving_Party_time
	,convert(int,null)				LTE_ExtendedServiceRequest_Receiving_Party_samples
	,convert(int,null)				LTE_ExtendedServiceRequest_Receiving_Party_Freq 

	,convert(datetime2(3),null)		LTE_RRCConnectionRelease_time
	,convert(int,null)				LTE_RRCConnectionRelease_samples
	,convert(int,null)				LTE_RRCConnectionRelease_Freq 

	,convert(datetime2(3),null)		LTE_RRCConnectionRelease_Receiving_Party_time
	,convert(int,null)				LTE_RRCConnectionRelease_Receiving_Party_samples
	,convert(int,null)				LTE_RRCConnectionRelease_Receiving_Party_Freq 

	,convert(datetime2(3),null)		UMTS_RRCConnectionRequest_time
	,convert(int,null)				UMTS_RRCConnectionRequest_samples
	,convert(int,null)				UMTS_RRCConnectionRequest_Freq 

	,convert(datetime2(3),null)		UMTS_RRCConnectionRequest_Receiving_Party_time
	,convert(int,null)				UMTS_RRCConnectionRequest_Receiving_Party_samples
	,convert(int,null)				UMTS_RRCConnectionRequest_Receiving_Party_Freq 


	--**************** End Call INFO no VOLTE:
	,convert(datetime2(3),null)		Disconnect_time
	,convert(int,null)				Disconnect_samples
	,convert(int,null)				Disconnect_Freq 

	,convert(datetime2(3),null)		DisConnect_Receiving_Party_time
	,convert(int,null)				DisConnect_Receiving_Party_samples
	,convert(int,null)				DisConnect_Receiving_Party_Freq 

	,convert(datetime2(3),null)		Release_time
	,convert(int,null)				Release_samples
	,convert(int,null)				Release_Freq 

	,convert(datetime2(3),null)		Release_Receiving_Party_time
	,convert(int,null)				Release_Receiving_Party_samples
	,convert(int,null)				Release_Receiving_Party_Freq 

	,convert(datetime2(3),null)		ReleaseComplete_time
	,convert(int,null)				ReleaseComplete_samples
	,convert(int,null)				ReleaseComplete_Freq 

	,convert(datetime2(3),null)		ReleaseComplete_Receiving_Party_time
	,convert(int,null)				ReleaseComplete_Receiving_Party_samples
	,convert(int,null)				ReleaseComplete_Receiving_Party_Freq 


	--**************** VOLTE:
	,convert(datetime2(3),null)		VoLTE_Invite_req_time
	,convert(int,null) 				VoLTE_Invite_req_samples
	,convert(datetime2(3),null) 	VoLTE_Invite_req_time_receiving_Party
	,convert(int,null) 				VoLTE_Invite_req_samples_receiving_Party

	,convert(datetime2(3),null) 	VoLTE_Trying_time
	,convert(int,null) 				VoLTE_Trying_samples
	,convert(datetime2(3),null)		VoLTE_Trying_time_receiving_Party
	,convert(int,null) 				VoLTE_Trying_samples_receiving_Party

	,convert(datetime2(3),null) 	VoLTE_SesProgress_time
	,convert(int,null) 				VoLTE_SesProgress_samples
	,convert(datetime2(3),null) 	VoLTE_SesProgress_time_receiving_Party
	,convert(int,null) 				VoLTE_SesProgress_samples_receiving_Party

	,convert(datetime2(3),null) 	VoLTE_Ringing_time
	,convert(int,null) 				VoLTE_Ringing_samples
	,convert(datetime2(3),null) 	VoLTE_Ringing_time_receiving_Party
	,convert(int,null) 				VoLTE_Ringing_samples_receiving_Party

	,convert(datetime2(3),null) 	VoLTE_InviteOK_time
	,convert(int,null) 				VoLTE_InviteOK_samples
	,convert(datetime2(3),null) 	VoLTE_InviteOK_time_receiving_Party
	,convert(int,null) 				VoLTE_InviteOK_samples_receiving_Party

	,convert(datetime2(3),null) 	VoLTE_ACK_time
	,convert(int,null) 				VoLTE_ACK_samples
	,convert(datetime2(3),null) 	VoLTE_ACK_time_receiving_Party
	,convert(int,null) 				VoLTE_ACK_samples_receiving_Party

	--**************** End Call INFO VOLTE:
	,convert(datetime2(3),null)		VoLTE_Bye_req_time
	,convert(int,null) 				VoLTE_Bye_req_samples
	,convert(datetime2(3),null) 	VoLTE_Bye_req_time_receiving_Party
	,convert(int,null) 				VoLTE_Bye_req_samples_receiving_Party

	,convert(datetime2(3),null) 	VoLTE_ByeOK_time
	,convert(int,null) 				VoLTE_ByeOK_samples
	,convert(datetime2(3),null) 	VoLTE_ByeOK_time_receiving_Party
	,convert(int,null) 				VoLTE_ByeOK_samples_receiving_Party

	--**************** other INFO:
	,convert(int,null)				Num_RABSetup_samples
	,convert(int,null)				Num_RABReconf_samples
	,convert(int,null)				Num_PhyChannelReconf_samples
	,convert(int,null)				Num_L3Msgs_samples

	,convert(datetime2(3),null)		NASTransportDL_AvisoDisp_time
	,convert(int,null)				NASTransportDL_AvisoDisp_samples
	,convert(varchar(1024),null)	NASTransportDL_AvisoDisp_msg 

	,convert(datetime2(3),null)		NASTransportDL_AvisoDisp_Receiving_Party_time
	,convert(int,null)				NASTransportDL_AvisoDisp_Receiving_Party_samples
	,convert(varchar(1024),null)	NASTransportDL_AvisoDisp_Receiving_Party_msg 

	into _lcc_c0re_Voice_Metrics_TimeStamp_Table
from
	(
		select c.sessionid,c.posid,c.networkid,c.fileid,c.calltype,c.callDir,
			  b.sessionid as SessionidB, c.callStatus, s.valid as validA, b.valid as validB
		 from callanalysis c, sessions s, sessionsb b
		 where c.sessionid=s.sessionid 
			  and s.sessionid=b.sessionida 		
	) s


---------------------------------------------------------------------------------------------------
-- Completar la info de manera controlada, desde el punto de vista del originante en el caso de M2M
---------------------------------------------------------------------------------------------------

--***************************************************************************************************** START Call INFO:
-------------
-- StartDial
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set StartDial=m.msgtime
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c, markers m
where c.sessionid=m.sessionid and m.markertext='Start Dial'

-------------
-- Dial
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set Dial=m.msgtime
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c, markers m
where c.sessionid=m.sessionid and m.markertext='Dial'



--***************************************************************************************************** END Call INFO no VOLTE:
-------------
-- Disconnect_time 
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [Disconnect_time]=m.msgtime,	[Disconnect_samples]=m.samples,
	Disconnect_Freq=case when (calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfA.BCCH 
					     when (calltype='M->M' and calldir='B->A') then rfB.BCCH end
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message like 'Disconnect' 
		  and m.msgtime>=isnull(c.Dial, c.StartDial)
		  and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='Disconnect' 
		  and m.msgtime>=isnull(c.Dial, c.StartDial)
		  and (calltype='M->M' and calldir='B->A')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 

-------------
-- DisConnect_Receiving_Party_time
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [DisConnect_Receiving_Party_time]=m.msgtime,	[DisConnect_Receiving_Party_samples]=m.samples,
	DisConnect_Receiving_Party_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfB.BCCH 
					   when  ( calltype='M->M' and calldir='B->A') then rfA.BCCH end
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message='Disconnect' 
		  and m.msgtime>=isnull(c.Dial, c.StartDial)
		  and (calltype<>'M->M' or (calltype='M->M' and calldir='B->A'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='Disconnect' 
		  and m.msgtime>=isnull(c.Dial, c.StartDial)
		  and (calltype='M->M' and calldir='A->B')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 


-------------
-- Release_time 
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [Release_time]=m.msgtime,	[Release_samples]=m.samples,
	Release_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfA.BCCH 
					   when  ( calltype='M->M' and calldir='B->A') then rfB.BCCH end
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message like 'Release' 
		  and m.msgtime>=isnull(c.Dial, c.StartDial)
		  and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='Release' 
		  and m.msgtime>=isnull(c.Dial, c.StartDial)
		  and (calltype='M->M' and calldir='B->A')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 

-------------
-- Release_Receiving_Party_time
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [Release_Receiving_Party_time]=m.msgtime,	[Release_Receiving_Party_samples]=m.samples,
	Release_Receiving_Party_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfB.BCCH 
					   when  ( calltype='M->M' and calldir='B->A') then rfA.BCCH end
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message='Release' 
		  and m.msgtime>=isnull(c.Dial, c.StartDial)
		  and (calltype<>'M->M' or (calltype='M->M' and calldir='B->A'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='Release' 
		  and m.msgtime>=isnull(c.Dial, c.StartDial)
		  and ( calltype='M->M' and calldir='A->B')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 


-------------
-- ReleaseComplete_time 
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [ReleaseComplete_time]=m.msgtime,	[ReleaseComplete_samples]=m.samples,
	ReleaseComplete_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfA.BCCH 
					   when  ( calltype='M->M' and calldir='B->A') then rfB.BCCH end					  
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message like 'Release Complete' 
		  and m.msgtime>=isnull(c.Dial, c.StartDial)
		  and ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='Release Complete' 
		  and m.msgtime>=isnull(c.Dial, c.StartDial)
		  and ( calltype='M->M' and calldir='B->A')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 

-------------
-- ReleaseComplete_Receiving_Party_time
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [ReleaseComplete_Receiving_Party_time]=m.msgtime,	[ReleaseComplete_Receiving_Party_samples]=m.samples,
	ReleaseComplete_Receiving_Party_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfB.BCCH 
					   when  ( calltype='M->M' and calldir='B->A') then rfA.BCCH end
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message='Release Complete' 
		  and m.msgtime>=isnull(c.Dial, c.StartDial)
		  and ( calltype<>'M->M' or (calltype='M->M' and calldir='B->A'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='Release Complete' 
		  and m.msgtime>=isnull(c.Dial, c.StartDial)
		  and ( calltype='M->M' and calldir='A->B')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 


--***************************************************************************************************** End Call INFO VOLTE:
-------------
-- BYE Request
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [VoLTE_Bye_req_time]=m.msgtime,[VoLTE_Bye_req_samples]=m.samples
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionid=m.sessionid 
		  --and m.l3_message='IMS BYE INVITE (Request)' 
		  and m.messageid='IMS SIP BYE' and responseCode='Request'
		  --and  m.msgtime>=c.VoLTE_InviteOK_time
		  and ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))
	group by c.sessionid
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionidb=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (Request)' 
		  and m.messageid='IMS SIP BYE' and responseCode='Request'
		  --and  m.msgtime>=c.VoLTE_InviteOK_time
		  and ( calltype='M->M' and calldir='B->A')
	group by c.sessionid
) m
where c.sessionid=m.sessionid 

-------------
-- BYE Request Receiving_Party
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [VoLTE_BYE_req_time_receiving_Party]=m.msgtime
   ,[VoLTE_BYE_req_samples_receiving_Party]=m.samples
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionid=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (Request)'  
		  and m.messageid='IMS SIP BYE' and responseCode='Request'
		  --and  m.msgtime>=c.VoLTE_InviteOK_time_receiving_Party
		  and ( calltype<>'M->M' or (calltype='M->M' and calldir='B->A'))
	group by c.sessionid
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionidb=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (Request)' 
		  and m.messageid='IMS SIP BYE' and responseCode='Request'
		  --and  m.msgtime>=c.VoLTE_InviteOK_time_receiving_Party
		  and ( calltype='M->M' and calldir='A->B')
	group by c.sessionid
) m
where c.sessionid=m.sessionid 

-------------
-- BYE OK
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [VoLTE_ByeOK_time]=m.msgtime
   ,[VoLTE_ByeOK_samples]=m.samples
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionid=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (OK)' 
		  and m.messageid='IMS SIP BYE' and responseCode='OK' 
		  --and  m.msgtime>=c.[VoLTE_Bye_req_time]
		  and ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))
	group by c.sessionid
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionidb=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (OK)' 
		  and m.messageid='IMS SIP BYE' and responseCode='OK' 
		  --and  m.msgtime>=c.[VoLTE_Bye_req_time]
		  and ( calltype='M->M' and calldir='B->A')
	group by c.sessionid
) m
where c.sessionid=m.sessionid 

-------------
-- BYE OK Receiving_Party
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [VoLTE_ByeOK_time_receiving_Party]=m.msgtime
   ,[VoLTE_ByeOK_samples_receiving_Party]=m.samples
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionid=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (OK)' 
		  and m.messageid='IMS SIP BYE' and responseCode='OK' 
		  --and  m.msgtime>=c.[VoLTE_BYE_req_time_receiving_Party]
		  and ( calltype<>'M->M' or (calltype='M->M' and calldir='B->A'))
	group by c.sessionid
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionidb=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (OK)' 
		  and m.messageid='IMS SIP BYE' and responseCode='OK' 
		  --and  m.msgtime>=c.[VoLTE_BYE_req_time_receiving_Party]
		  and ( calltype='M->M' and calldir='A->B')
	group by c.sessionid
) m
where c.sessionid=m.sessionid 


--***************************************************************************************************** no VOLTE
-------------
-- Alerting  - despues del DIAL
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set Alerting_time=m.msgtime,	Alerting_samples=m.samples,
	Alerting_Freq=case when (calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfA.BCCH 
					   when						 (calltype='M->M' and calldir='B->A')  then rfB.BCCH end
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message='Alerting' 
		  and m.msgtime>=isnull(c.Dial, c.StartDial)
		  and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='Alerting' 
		  and m.msgtime>=isnull(c.Dial, c.StartDial)
		  and (calltype='M->M' and calldir='B->A')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime

where c.sessionid=m.sessionid 

-------------
-- Alerting_Receiving_Party_time  - despues del DIAL
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set Alerting_Receiving_Party_time=m.msgtime,		Alerting_Receiving_Party_samples=m.samples,
	Alerting_Receiving_Party_Freq=case  when (calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfB.BCCH 
										when (calltype='M->M' and calldir='B->A') then rfA.BCCH end
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message='Alerting' 
		  and m.msgtime>=isnull(c.Dial, c.StartDial)
		  and (calltype<>'M->M' or (calltype='M->M' and calldir='B->A'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='Alerting' 
		  and m.msgtime>=isnull(c.Dial, c.StartDial)
		  and (calltype='M->M' and calldir='A->B')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 


-------------
-- Connect  - despues del ALERTING 
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [Connect_time]=m.msgtime,	[Connect_samples]=m.samples,
	Connect_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfA.BCCH 
					   when  ( calltype='M->M' and calldir='B->A') then rfB.BCCH end
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message='Connect' 
		  and m.msgtime>=isnull(c.[Alerting_time], isnull(c.Dial, c.StartDial))
		  and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='Connect' 
		  and m.msgtime>=isnull(c.[Alerting_time], isnull(c.Dial, c.StartDial))
		  and (calltype='M->M' and calldir='B->A')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 

-------------
-- Connect Receiving_Party  - despues del ALERTING
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [Connect_Receiving_Party_time]=m.msgtime,	[Connect_Receiving_Party_samples]=m.samples,
	Connect_Receiving_Party_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfB.BCCH 
					   when  ( calltype='M->M' and calldir='B->A') then rfA.BCCH end
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message='Connect' 
		  and m.msgtime>=isnull(c.[Alerting_Receiving_Party_time], isnull(c.Dial,c.StartDial))
		  and (calltype<>'M->M' or (calltype='M->M' and calldir='B->A'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='Connect' 
		  and m.msgtime>=isnull(c.[Alerting_Receiving_Party_time], isnull(c.Dial,c.StartDial))
		  and (calltype='M->M' and calldir='A->B')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 


-------------
-- Connect ACK  - despues del ALERTING
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [ConnectAck_time]=m.msgtime,	[ConnectAck_samples]=m.samples,
	ConnectAck_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfA.BCCH 
					   when  ( calltype='M->M' and calldir='B->A') then rfB.BCCH end
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message='Connect Acknowledge' 
		  and m.msgtime>=isnull(c.[Alerting_time], isnull(c.Dial, c.StartDial))
		  and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='Connect Acknowledge' 
		  and m.msgtime>=isnull(c.[Alerting_time], isnull(c.Dial, c.StartDial))
		  and ( calltype='M->M' and calldir='B->A')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 

-------------
-- Connect ACK Receiving_Party  - despues del ALERTING
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [ConnectAck_Receiving_Party_time]=m.msgtime,	[ConnectAck_Receiving_Party_samples]=m.samples,
	ConnectAck_Receiving_Party_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfB.BCCH 
					   when  ( calltype='M->M' and calldir='B->A') then rfA.BCCH end
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message='Connect Acknowledge' 
		  and m.msgtime>=isnull(c.[Alerting_time], isnull(c.Dial, c.StartDial))
		  and (calltype<>'M->M' or (calltype='M->M' and calldir='B->A'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='Connect Acknowledge' 
		  and m.msgtime>=isnull(c.[Alerting_time], isnull(c.Dial, c.StartDial))
		  and (calltype='M->M' and calldir='A->B')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 


--*****************************************************************************************************
-- A partir de aqui hay que tener cuidado con los umbrales de los tiempos, para tener en cuantas las FAILS

-------------
-- Setup_time													- (m.msgtime<=c.[Alerting_time] or (m.msgtime<=c.[Disconnect_time] or m.msgtime<=c.Release_time))
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [Setup_time]=m.msgtime,	[Setup_samples]=m.samples,
	Setup_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfA.BCCH 
					   when  ( calltype='M->M' and calldir='B->A') then rfB.BCCH end
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message='Setup' 
		  and m.msgtime>=isnull(c.Dial, c.StartDial) and m.msgtime<=isnull(c.[Alerting_time], isnull(c.[Disconnect_time], c.Release_time))
		  and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='Setup' 
		  and m.msgtime>=isnull(c.Dial, c.StartDial) and m.msgtime<=isnull(c.[Alerting_time], isnull(c.[Disconnect_time], c.Release_time))
		  and (calltype='M->M' and calldir='B->A')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 

-------------
-- Setup_Receiving_Party_time									- (m.msgtime<=c.Alerting_Receiving_Party_time or (m.msgtime<=c.[DisConnect_Receiving_Party_time] or m.msgtime<=c.Release_Receiving_Party_time or (m.msgtime<=c.[Disconnect_time] or m.msgtime<=c.Release_time)))
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [Setup_Receiving_Party_time]=m.msgtime,	[Setup_Receiving_Party_samples]=m.samples,
	Setup_Receiving_Party_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfB.BCCH 
					   when  ( calltype='M->M' and calldir='B->A') then rfA.BCCH end
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message='Setup' 
		  and m.msgtime>=isnull(c.Dial, c.StartDial) and m.msgtime<=isnull(c.Alerting_Receiving_Party_time, isnull(c.[DisConnect_Receiving_Party_time], isnull(c.Release_Receiving_Party_time, isnull(c.[Disconnect_time], c.Release_time))))
		  and (calltype<>'M->M' or (calltype='M->M' and calldir='B->A'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='Setup' 
		  and m.msgtime>=isnull(c.Dial, c.StartDial) and m.msgtime<=isnull(c.Alerting_Receiving_Party_time, isnull(c.[DisConnect_Receiving_Party_time], isnull(c.Release_Receiving_Party_time, isnull(c.[Disconnect_time], c.Release_time))))
		  and (calltype='M->M' and calldir='A->B')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 


-------------
-- CallProceeding_time											- (m.msgtime<=c.[Alerting_time] or (m.msgtime<=c.[Disconnect_time] or m.msgtime<=c.Release_time))
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [CallProceeding_time]=m.msgtime,[CallProceeding_samples]=m.samples,
	CallProceeding_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfA.BCCH 
					   when  ( calltype='M->M' and calldir='B->A') then rfB.BCCH end					   
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message='Call Proceeding' 
		  and m.msgtime>isnull(c.[Setup_time], isnull(c.Dial, c.StartDial)) and m.msgtime<=isnull(c.[Alerting_time], isnull(c.[Disconnect_time], c.Release_time))		  
		  and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='Call Proceeding' 
		  and m.msgtime>isnull(c.[Setup_time], isnull(c.Dial, c.StartDial)) and m.msgtime<=isnull(c.[Alerting_time], isnull(c.[Disconnect_time], c.Release_time))
		  and (calltype='M->M' and calldir='B->A')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 

-------------
-- CallConfirmed_time											- (m.msgtime<=c.Alerting_Receiving_Party_time or (m.msgtime<=c.[DisConnect_Receiving_Party_time] or m.msgtime<=c.Release_Receiving_Party_time or (m.msgtime<=c.[Disconnect_time] or m.msgtime<=c.Release_time)))
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [CallConfirmed_time]=m.msgtime,[CallConfirmed_samples]=m.samples,
	CallConfirmed_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfB.BCCH 
					   when  ( calltype='M->M' and calldir='B->A') then rfA.BCCH end
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message='Call Confirmed' 
		  and m.msgtime>isnull(c.[Setup_Receiving_Party_time], isnull(c.Dial, c.StartDial)) and m.msgtime<=isnull(c.Alerting_Receiving_Party_time, isnull(c.[DisConnect_Receiving_Party_time], isnull(c.Release_Receiving_Party_time, isnull(c.[Disconnect_time], c.Release_time))))		   
		  and (calltype<>'M->M' or (calltype='M->M' and calldir='B->A'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='Call Confirmed'
		  and m.msgtime>isnull(c.[Setup_Receiving_Party_time], isnull(c.Dial, c.StartDial)) and m.msgtime<=isnull(c.Alerting_Receiving_Party_time, isnull(c.[DisConnect_Receiving_Party_time], isnull(c.Release_Receiving_Party_time, isnull(c.[Disconnect_time], c.Release_time))))
		  and (calltype='M->M' and calldir='A->B')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 


-------------
-- Progress_time (solo esta en las FAILS?)						- (m.msgtime<=c.[Alerting_time] or (m.msgtime<=c.[Disconnect_time] or m.msgtime<=c.Release_time))
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set Progress_time=m.msgtime,	Progress_samples=m.samples,
	Progress_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfA.BCCH 
					   when  ( calltype='M->M' and calldir='B->A') then rfB.BCCH end	   
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message='Progress' 
		  and m.msgtime>isnull(c.[Setup_time], isnull(c.Dial, c.StartDial)) and m.msgtime<=isnull(c.[Alerting_time], isnull(c.[Disconnect_time], c.Release_time))
		  and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='Progress' 
		  and m.msgtime>isnull(c.[Setup_time], isnull(c.Dial, c.StartDial)) and m.msgtime<=isnull(c.[Alerting_time], isnull(c.[Disconnect_time], c.Release_time))
		  and (calltype='M->M' and calldir='B->A')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 


-------------
-- CMServiceRequest_time										- (m.msgtime<=c.[Disconnect_time] or m.msgtime<=c.Release_time))
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [CMServiceRequest_time]=m.msgtime,	[CMServiceRequest_samples]=m.samples,
	CMServiceRequest_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfA.BCCH 
					   when  ( calltype='M->M' and calldir='B->A') then rfB.BCCH end
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message='CM Service Request' 
		  and m.msgtime>=isnull(c.Dial, c.StartDial) and m.msgtime<=isnull(c.[Alerting_time], isnull(c.[Disconnect_time], c.Release_time))
		  and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='CM Service Request' 
		  and m.msgtime>=isnull(c.Dial, c.StartDial) and m.msgtime<=isnull(c.[Alerting_time], isnull(c.[Disconnect_time], c.Release_time))
		  and (calltype='M->M' and calldir='B->A')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 


--exec SQKeyValueInit 'C:\L3KeyValue'
------------- 
-- Paging_time													- (m.msgtime<=c.Alerting_Receiving_Party_time or (m.msgtime<=c.[DisConnect_Receiving_Party_time] or m.msgtime<=c.Release_Receiving_Party_time or (m.msgtime<=c.[Disconnect_time] or m.msgtime<=c.Release_time)))
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [Paging_time]=m.msgtime,	[Paging_samples]=m.samples,
	Paging_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfB.BCCH 
						when  ( calltype='M->M' and calldir='B->A') then rfA.BCCH end
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	SELECT m.sessionid, min(v.msgtime) msgtime , sum(1) as samples, m.m_TMSI, m.sessionidB
	FROM vlcc_layer3_core v, (
			select c.sessionid, m.m_TMSI, c.sessionidB, c.calldir, min(msgtime) as msgtime, sum(1) as samples
			from _lcc_c0re_Voice_Metrics_TimeStamp_Table c, _rrcConnectionRequest_tmsi m 
			where c.sessionid=m.sessionid 
				and (calltype='M->M' and calldir='B->A')
			group by c.sessionid, m.m_TMSI, c.sessionidB, c.calldir
			) m
	WHERE v.sessionid=m.sessionid and v.l3_message ='paging'
				  and (
					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[0] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[1] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[2] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[3] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[4] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[5] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI 
				  )
	group by m.sessionid, m.m_TMSI, m.sessionidB

	union all
	SELECT m.sessionid, min(v.msgtime) msgtime , sum(1) as samples, m.m_TMSI, m.sessionidB
	FROM vlcc_layer3_core v, (
			select c.sessionid, m.m_TMSI, c.sessionidB, c.calldir, min(msgtime) as msgtime, sum(1) as samples
			from _lcc_c0re_Voice_Metrics_TimeStamp_Table c, _rrcConnectionRequest_tmsi m 
			where c.sessionidB=m.sessionid 
				and (calltype='M->M' and calldir='A->B')
			group by c.sessionid, m.m_TMSI, c.sessionidB, c.calldir
			) m
	WHERE v.sessionid=m.sessionidB and v.l3_message ='paging'
				  and (
					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[0] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[1] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[2] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[3] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[4] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[5] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI 
				  )
	group by m.sessionid, m.m_TMSI, m.sessionidB
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime

where c.sessionid=m.sessionid



-- ********************************************************************************************
-- Hay casos en los que el PAGING se da en la sesion de IDLE anterior.
-- Para los casos nulos, vamos a ver si realmente hay un REQ y un PAGIN en la sesion previa
-- **********************************************
------------- 
-- Paging_time													- (m.msgtime<=c.Alerting_Receiving_Party_time or (m.msgtime<=c.[DisConnect_Receiving_Party_time] or m.msgtime<=c.Release_Receiving_Party_time or (m.msgtime<=c.[Disconnect_time] or m.msgtime<=c.Release_time)))
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [Paging_time]=m.msgtime,	[Paging_samples]=m.samples,
	Paging_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfB.BCCH 
					   when  ( calltype='M->M' and calldir='B->A') then rfA.BCCH end				   
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	SELECT m.sessionid, min(v.msgtime) msgtime , sum(1) as samples, m.m_TMSI, m.sessionidB
	FROM vlcc_layer3_core v, (
			select c.sessionid, m.m_TMSI, c.sessionidB, c.calldir, min(msgtime) as msgtime, sum(1) as samples
			from _lcc_c0re_Voice_Metrics_TimeStamp_Table c, _rrcConnectionRequest_tmsi m, sessions s
			where c.sessionid=s.sessionid and m.sessionid=s.prevsessionid
				and (calltype='M->M' and calldir='B->A')
			group by c.sessionid, m.m_TMSI, c.sessionidB, c.calldir
			) m,
			sessions s
	WHERE m.sessionid=s.sessionid and v.sessionid=s.prevsessionid and v.l3_message ='paging'
				  and (
					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[0] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[1] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[2] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[3] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[4] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[5] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI 
				  )
	group by m.sessionid, m.m_TMSI, m.sessionidB

	union all
	SELECT m.sessionid, min(v.msgtime) msgtime , sum(1) as samples, m.m_TMSI, m.sessionidB
	FROM vlcc_layer3_core v, (
			select c.sessionid, m.m_TMSI, c.sessionidB, c.calldir, min(msgtime) as msgtime, sum(1) as samples
			from _lcc_c0re_Voice_Metrics_TimeStamp_Table c, _rrcConnectionRequest_tmsi m, sessionsB s
			where c.sessionidB=s.sessionid and m.sessionid=s.prevsessionid
				and (calltype='M->M' and calldir='A->B')
			group by c.sessionid, m.m_TMSI, c.sessionidB, c.calldir
			) m,
			sessionsB s
	WHERE m.sessionid=s.sessionid and v.sessionid=s.prevsessionid and v.l3_message ='paging'
				  and (
					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[0] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[1] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[2] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[3] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[4] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[5] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI 
				  )
	group by m.sessionid, m.m_TMSI, m.sessionidB

) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime

where c.sessionid=m.sessionid  and c.paging_time is null


---- ********************************************************************************************
---- Hay casos en los que el PAGING se da en la sesion de IDLE posterior.
---- Para los casos nulos, vamos a ver si realmente hay un REQ y un PAGIN en la sesion previa
---- **********************************************
--------------- 
---- Paging_time													- (m.msgtime<=c.Alerting_Receiving_Party_time or (m.msgtime<=c.[DisConnect_Receiving_Party_time] or m.msgtime<=c.Release_Receiving_Party_time or (m.msgtime<=c.[Disconnect_time] or m.msgtime<=c.Release_time)))
--update _lcc_c0re_Voice_Metrics_TimeStamp_Table
--set [Paging_time]=m.msgtime,	[Paging_samples]=m.samples,
--	Paging_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfB.BCCH 
--					 when ( calltype='M->M' and calldir='B->A') then rfA.BCCH end				   
--from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
--(
--	SELECT m.sessionid, min(v.msgtime) msgtime , sum(1) as samples, m.m_TMSI, m.sessionidB
--	FROM vlcc_layer3 v, (
--			select c.sessionid, m.m_TMSI, c.sessionidB, c.calldir, min(msgtime) as msgtime, sum(1) as samples
--			from _lcc_c0re_Voice_Metrics_TimeStamp_Table c, _rrcConnectionRequest_tmsi m, sessions s
--			where c.sessionid=s.sessionid and m.sessionid=s.nextsessionid
--				and (calltype='M->M' and calldir='B->A')
--			group by c.sessionid, m.m_TMSI, c.sessionidB, c.calldir
--			) m,
--			sessions s
--	WHERE m.sessionid=s.sessionid and v.sessionid=s.nextsessionid and v.l3_message ='paging'
--				  and (
--					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[0] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
--					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[1] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
--					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[2] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
--					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[3] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
--					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[4] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
--					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[5] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI 
--				  )
--	group by m.sessionid, m.m_TMSI, m.sessionidB

--	union all
--	SELECT m.sessionid, min(v.msgtime) msgtime , sum(1) as samples, m.m_TMSI, m.sessionidB
--	FROM vlcc_layer3 v, (
--			select c.sessionid, m.m_TMSI, c.sessionidB, c.calldir, min(msgtime) as msgtime, sum(1) as samples
--			from _lcc_c0re_Voice_Metrics_TimeStamp_Table c, _rrcConnectionRequest_tmsi m, sessionsB s
--			where c.sessionidB=s.sessionid and m.sessionid=s.nextsessionid
--				and (calltype='M->M' and calldir='A->B')
--			group by c.sessionid, m.m_TMSI, c.sessionidB, c.calldir
--			) m,
--			sessionsB s
--	WHERE m.sessionid=s.sessionid and v.sessionid=s.nextsessionid and v.l3_message ='paging'
--				  and (
--					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[0] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
--					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[1] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
--					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[2] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
--					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[3] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
--					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[4] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI or
--					dbo.sqlterrckeyvalue(v.bin_message,v.LogChanType,'PCCH_Message;message;c1;paging;pagingRecordList;[5] pagingRecordList;element;ue_Identity;s_TMSI;m_TMSI')=m.m_TMSI 
--				  )
--	group by m.sessionid, m.m_TMSI, m.sessionidB

--) m
--LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
--LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime

--where c.sessionid=m.sessionid  and c.paging_time is null

-- ********************************************************************************************
-------------
-- PagingResponse_time											- (m.msgtime<=c.Alerting_Receiving_Party_time or (m.msgtime<=c.[DisConnect_Receiving_Party_time] or m.msgtime<=c.Release_Receiving_Party_time or (m.msgtime<=c.[Disconnect_time] or m.msgtime<=c.Release_time)))
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set PagingResponse_time=m.msgtime,	[PagingResponse_samples]=m.samples,
	PagingResponse_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfB.BCCH 
					   when  ( calltype='M->M' and calldir='B->A') then rfA.BCCH end
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message='Paging Response' 
		  and m.msgtime>=isnull(Paging_time, isnull(c.Dial, c.StartDial)) and m.msgtime<=isnull(c.Alerting_Receiving_Party_time, isnull(c.[DisConnect_Receiving_Party_time], isnull(c.Release_Receiving_Party_time, isnull(c.[Disconnect_time], c.Release_time))))
		  and (calltype<>'M->M' or (calltype='M->M' and calldir='B->A'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='Paging Response' 
		  and m.msgtime>=isnull(Paging_time, isnull(c.Dial, c.StartDial)) and m.msgtime<=isnull(c.Alerting_Receiving_Party_time, isnull(c.[DisConnect_Receiving_Party_time], isnull(c.Release_Receiving_Party_time, isnull(c.[Disconnect_time], c.Release_time))))
		  and (calltype='M->M' and calldir='A->B')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 


-------------
-- LTE_ExtendedServiceRequest_time								- (m.msgtime<=c.[Alerting_time] or (m.msgtime<=c.[Disconnect_time] or m.msgtime<=c.Release_time))
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [LTE_ExtendedServiceRequest_time]=m.msgtime,	[LTE_ExtendedServiceRequest_samples]=m.samples,
	LTE_ExtendedServiceRequest_Freq=case when  ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfA.BCCH 
										 when  ( calltype='M->M' and  calldir='B->A')                      then rfB.BCCH end
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message='Extended service request' and m.channel='LTE UL_EMM'
		  and m.msgtime>=isnull(c.Dial, c.StartDial) and m.msgtime<=isnull(c.[Alerting_time], isnull(c.[Disconnect_time], c.Release_time))
		  and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='Extended service request' and m.channel='LTE UL_EMM'
		  and m.msgtime>=isnull(c.Dial, c.StartDial)  and m.msgtime<=isnull(c.[Alerting_time], isnull(c.[Disconnect_time], c.Release_time))
		  and (calltype='M->M' and calldir='B->A')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 

-------------
-- LTE_ExtendedServiceRequest_Receiving_Party_time				- (m.msgtime<=c.Alerting_Receiving_Party_time or (m.msgtime<=c.[DisConnect_Receiving_Party_time] or m.msgtime<=c.Release_Receiving_Party_time or (m.msgtime<=c.[Disconnect_time] or m.msgtime<=c.Release_time)))
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [LTE_ExtendedServiceRequest_Receiving_Party_time]=m.msgtime,	[LTE_ExtendedServiceRequest_Receiving_Party_samples]=m.samples,
	LTE_ExtendedServiceRequest_Receiving_Party_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfB.BCCH 
					   when  ( calltype='M->M' and calldir='B->A') then rfA.BCCH end
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message='Extended service request' and m.channel='LTE UL_EMM'
		  and m.msgtime>=isnull(c.Dial, c.StartDial) and m.msgtime<=isnull(c.Alerting_Receiving_Party_time, isnull(c.[DisConnect_Receiving_Party_time], isnull(c.[DisConnect_Receiving_Party_time], isnull(c.Release_Receiving_Party_time, isnull(c.[Disconnect_time], c.Release_time)))))
		  and (calltype<>'M->M' or (calltype='M->M' and calldir='B->A'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='Extended service request' and m.channel='LTE UL_EMM'
		  and m.msgtime>=isnull(c.Dial, c.StartDial) and m.msgtime<=isnull(c.Alerting_Receiving_Party_time, isnull(c.[DisConnect_Receiving_Party_time], isnull(c.[DisConnect_Receiving_Party_time], isnull(c.Release_Receiving_Party_time, isnull(c.[Disconnect_time], c.Release_time)))))
		  and (calltype='M->M' and calldir='A->B')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 


-------------
-- LTE_RRCConnectionRequest_time								- (m.msgtime<=c.[Alerting_time] or (m.msgtime<=c.[Disconnect_time] or m.msgtime<=c.Release_time))
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [LTE_RRCConnectionRequest_time]=m.msgtime,	[LTE_RRCConnectionRequest_samples]=m.samples,
	LTE_RRCConnectionRequest_Freq=case when (calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfA.BCCH 
					   when  (calltype='M->M' and calldir='B->A') then rfB.BCCH end
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message='RRCConnectionRequest' and m.channel like 'LTE %'
		  and m.msgtime>=isnull(c.Dial, c.StartDial) and m.msgtime<=isnull(c.[LTE_ExtendedServiceRequest_time], isnull(c.[Alerting_time], isnull(c.[Disconnect_time], c.Release_time)))
		  and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='RRCConnectionRequest' and m.channel like 'LTE %'
		  and m.msgtime>=isnull(c.Dial, c.StartDial) and m.msgtime<=isnull(c.[LTE_ExtendedServiceRequest_time], isnull(c.[Alerting_time], isnull(c.[Disconnect_time], c.Release_time)))
		  and (calltype='M->M' and calldir='B->A')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 

-------------
-- LTE_RRCConnectionRequest_Receiving_Party_time				- (m.msgtime<=c.Alerting_Receiving_Party_time or (m.msgtime<=c.[DisConnect_Receiving_Party_time] or m.msgtime<=c.Release_Receiving_Party_time or (m.msgtime<=c.[Disconnect_time] or m.msgtime<=c.Release_time)))
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [LTE_RRCConnectionRequest_Receiving_Party_time]=m.msgtime,	[LTE_RRCConnectionRequest_Receiving_Party_samples]=m.samples,
	LTE_RRCConnectionRequest_Receiving_Party_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfB.BCCH 
					   when  ( calltype='M->M' and calldir='B->A') then rfA.BCCH end
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message='RRCConnectionRequest' and m.channel like 'LTE %'
		  and (m.msgtime>=[Paging_time]) and m.msgtime<=isnull(c.LTE_ExtendedServiceRequest_Receiving_Party_time,isnull(c.Alerting_Receiving_Party_time, isnull(c.[DisConnect_Receiving_Party_time], isnull(c.Release_Receiving_Party_time, isnull(c.[Disconnect_time],c.Release_time)))))
		  and (calltype<>'M->M' or (calltype='M->M' and calldir='B->A'))
		  and dbo.sqlterrckeyvalue(m.bin_message,m.LogChanType,'UL_CCCH_Message;message;c1;rrcConnectionRequest;criticalExtensions;rrcConnectionRequest_r8;establishmentCause') like '%mt%'
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='RRCConnectionRequest' and m.channel like 'LTE %'
		  and(m.msgtime>=c.[Paging_time]) and m.msgtime<=isnull(c.LTE_ExtendedServiceRequest_Receiving_Party_time,isnull(c.Alerting_Receiving_Party_time, isnull(c.[DisConnect_Receiving_Party_time], isnull(c.Release_Receiving_Party_time, isnull(c.[Disconnect_time],c.Release_time)))))
		  and (calltype='M->M' and  calldir='A->B')
		  and dbo.sqlterrckeyvalue(m.bin_message,m.LogChanType,'UL_CCCH_Message;message;c1;rrcConnectionRequest;criticalExtensions;rrcConnectionRequest_r8;establishmentCause') like '%mt%'
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 


-------------
-- LTE_RRCConnectionRelease_time								- (m.msgtime<=c.[Alerting_time] or (m.msgtime<=c.[Disconnect_time] or m.msgtime<=c.Release_time))
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [LTE_RRCConnectionRelease_time]=m.msgtime,	[LTE_RRCConnectionRelease_samples]=m.samples,
	LTE_RRCConnectionRelease_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfA.BCCH 
					   when  ( calltype='M->M' and calldir='B->A') then rfB.BCCH end					   
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message='RRCConnectionRelease' and m.channel like 'LTE %'
		  and m.msgtime>=isnull(c.[LTE_ExtendedServiceRequest_time],isnull(c.Dial, c.StartDial)) and m.msgtime<=isnull(c.[Alerting_time], isnull(c.[Disconnect_time], c.Release_time))
		  and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='RRCConnectionRelease' and m.channel like 'LTE %'
		  and m.msgtime>=isnull(c.[LTE_ExtendedServiceRequest_time],isnull(c.Dial, c.StartDial)) and m.msgtime<=isnull(c.[Alerting_time], isnull(c.[Disconnect_time], c.Release_time))
		  and (calltype='M->M' and calldir='B->A')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 

-------------
-- LTE_RRCConnectionRelease_Receiving_Party_time				- (m.msgtime<=c.Alerting_Receiving_Party_time or (m.msgtime<=c.[DisConnect_Receiving_Party_time] or m.msgtime<=c.Release_Receiving_Party_time or (m.msgtime<=c.[Disconnect_time] or m.msgtime<=c.Release_time)))
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [LTE_RRCConnectionRelease_Receiving_Party_time]=m.msgtime,	[LTE_RRCConnectionRelease_Receiving_Party_samples]=m.samples,
	LTE_RRCConnectionRelease_Receiving_Party_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfB.BCCH 
					   when  ( calltype='M->M' and calldir='B->A') then rfA.BCCH end
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message='RRCConnectionRelease' and m.channel like 'LTE %'
		  and m.msgtime>=isnull(c.LTE_ExtendedServiceRequest_Receiving_Party_time,isnull(c.Dial, c.StartDial)) and m.msgtime<=isnull(c.Alerting_Receiving_Party_time, isnull(c.[DisConnect_Receiving_Party_time], isnull(c.Release_Receiving_Party_time, isnull(c.[Disconnect_time], c.Release_time))))
		  and (calltype<>'M->M' or (calltype='M->M' and Calldir='B->A'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='RRCConnectionRelease' and m.channel like 'LTE %'
		  and m.msgtime>=isnull(c.LTE_ExtendedServiceRequest_Receiving_Party_time,isnull(c.Dial, c.StartDial)) and m.msgtime<=isnull(c.Alerting_Receiving_Party_time, isnull(c.[DisConnect_Receiving_Party_time], isnull(c.Release_Receiving_Party_time, isnull(c.[Disconnect_time], c.Release_time))))
		  and (calltype='M->M' and calldir='A->B')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 


------------- 
-- UMTS_RRCConnectionRequest_time								- (m.msgtime<=c.[Alerting_time] or (m.msgtime<=c.[Disconnect_time] or m.msgtime<=c.Release_time))
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [UMTS_RRCConnectionRequest_time]=m.msgtime,	[UMTS_RRCConnectionRequest_samples]=m.samples,
	UMTS_RRCConnectionRequest_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfA.BCCH 
					   when  ( calltype='M->M' and calldir='B->A') then rfB.BCCH end					   
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message='RRCConnectionRequest' and m.channel='RRC UL_CCCH'
		  and m.msgtime>=isnull(c.Dial, c.StartDial) and m.msgtime<=isnull(c.[Alerting_time], isnull(c.[Disconnect_time], c.Release_time))
		  and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='RRCConnectionRequest' and m.channel='RRC UL_CCCH'
		  and m.msgtime>=isnull(c.Dial, c.StartDial) and m.msgtime<=isnull(c.[Alerting_time], isnull(c.[Disconnect_time], c.Release_time))
		  and (calltype='M->M' and calldir='B->A')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 

------------- 
-- UMTS_RRCConnectionRequest_Receiving_Party_time				- (m.msgtime<=c.Alerting_Receiving_Party_time or (m.msgtime<=c.[DisConnect_Receiving_Party_time] or m.msgtime<=c.Release_Receiving_Party_time or (m.msgtime<=c.[Disconnect_time] or m.msgtime<=c.Release_time)))
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [UMTS_RRCConnectionRequest_Receiving_Party_time]=m.msgtime,	[UMTS_RRCConnectionRequest_Receiving_Party_samples]=m.samples,
	UMTS_RRCConnectionRequest_Receiving_Party_Freq=case when ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B')) then rfB.BCCH 
					   when  ( calltype='M->M' and calldir='B->A') then rfA.BCCH end
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionid=m.sessionid 
		  and m.l3_message='RRCConnectionRequest' and m.channel='RRC UL_CCCH'
		  and m.msgtime>=isnull(c.Dial, c.StartDial) and m.msgtime<=isnull(c.Alerting_Receiving_Party_time, isnull(c.[DisConnect_Receiving_Party_time], isnull(c.Release_Receiving_Party_time, isnull(c.[Disconnect_time], c.Release_time))))
		  and (calltype<>'M->M' or (calltype='M->M' and calldir='B->A'))
	group by c.sessionid, c.sessionidb
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
	where c.sessionidb=m.sessionid 
		  and m.l3_message='RRCConnectionRequest' and m.channel='RRC UL_CCCH'
		  and m.msgtime>=isnull(c.Dial, c.StartDial) and m.msgtime<=isnull(c.Alerting_Receiving_Party_time, isnull(c.[DisConnect_Receiving_Party_time], isnull(c.Release_Receiving_Party_time, isnull(c.[Disconnect_time], c.Release_time))))
		  and (calltype='M->M' and calldir='A->B')
	group by c.sessionid, c.sessionidb
) m
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfA on m.sessionid=rfA.sessionid and m.msgtime=rfA.msgtime
LEFT OUTER JOIN (select sessionid, msgtime, BCCH from vlcc_Layer3_core) rfB on m.sessionidb=rfB.sessionid and m.msgtime=rfB.msgtime
where c.sessionid=m.sessionid 


--***************************************************************************************************** VOLTE
-------------
-- Invite Request
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [VoLTE_Invite_req_time]=m.msgtime,[VoLTE_Invite_req_samples]=m.samples
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionid=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (Request)' 
		  and m.messageid='IMS SIP INVITE' and responseCode='Request'
		  and  m.msgtime>=c.Dial
		  and ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))
	group by c.sessionid
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionidb=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (Request)' 
		  and m.messageid='IMS SIP INVITE' and responseCode='Request'
		  and  m.msgtime>=c.Dial
		  and ( calltype='M->M' and calldir='B->A')
	group by c.sessionid
) m
where c.sessionid=m.sessionid 

-------------
-- Invite Request Receiving_Party
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [VoLTE_Invite_req_time_receiving_Party]=m.msgtime
   ,[VoLTE_Invite_req_samples_receiving_Party]=m.samples
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionid=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (Request)'  
		  and m.messageid='IMS SIP INVITE' and responseCode='Request'
		  and  m.msgtime>=c.dial
		  and ( calltype<>'M->M' or (calltype='M->M' and calldir='B->A'))
	group by c.sessionid
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionidb=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (Request)' 
		  and m.messageid='IMS SIP INVITE' and responseCode='Request'
		  and  m.msgtime>=c.dial
		  and ( calltype='M->M' and calldir='A->B')
	group by c.sessionid
) m
where c.sessionid=m.sessionid 

-------------
-- Invite Trying 
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [VoLTE_Trying_time]=m.msgtime,[VoLTE_Trying_samples]=m.samples
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionid=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (Trying)'  
		  and m.messageid='IMS SIP INVITE' and responseCode='Trying'
		  and  m.msgtime>=c.Dial
		  and ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))
	group by c.sessionid
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionidb=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (Trying)'   
		  and m.messageid='IMS SIP INVITE' and responseCode='Trying'
		  and  m.msgtime>=c.Dial
		  and ( calltype='M->M' and calldir='B->A')
	group by c.sessionid
) m
where c.sessionid=m.sessionid 

-------------
-- Invite Trying Receiving_Party
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [VoLTE_Trying_time_receiving_Party]=m.msgtime
   ,[VoLTE_Trying_samples_receiving_Party]=m.samples
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionid=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (Trying)'   
		  and m.messageid='IMS SIP INVITE' and responseCode='Trying'
		  and  m.msgtime>=c.dial
		  and ( calltype<>'M->M' or (calltype='M->M' and calldir='B->A'))
	group by c.sessionid
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionidb=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (Trying)'   
		  and m.messageid='IMS SIP INVITE' and responseCode='Trying'
		  and  m.msgtime>=c.dial
		  and ( calltype='M->M' and calldir='A->B')
	group by c.sessionid
) m
where c.sessionid=m.sessionid 

-------------
-- Session in progress 
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [VoLTE_SesProgress_time]=m.msgtime,[VoLTE_SesProgress_samples]=m.samples
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionid=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (Session in Progress)'  
		  and m.messageid='IMS SIP INVITE' and responseCode='Session in Progress' 
		  and  m.msgtime>=c.Dial
		  and ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))
	group by c.sessionid
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionidb=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (Session in Progress)'   
		  and m.messageid='IMS SIP INVITE' and responseCode='Session in Progress' 
		  and  m.msgtime>=c.Dial
		  and ( calltype='M->M' and calldir='B->A')
	group by c.sessionid
) m
where c.sessionid=m.sessionid 

-------------
-- Session in Progress Receiving_Party
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [VoLTE_SesProgress_time_receiving_Party]=m.msgtime
   ,[VoLTE_SesProgress_samples_receiving_Party]=m.samples
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionid=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (Session in Progress)'  
		  and m.messageid='IMS SIP INVITE' and responseCode='Session in Progress' 
		  and  m.msgtime>=c.dial
		  and ( calltype<>'M->M' or (calltype='M->M' and calldir='B->A'))
	group by c.sessionid
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionidb=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (Session in Progress)'   
		  and m.messageid='IMS SIP INVITE' and responseCode='Session in Progress' 
		  and  m.msgtime>=c.dial
		  and ( calltype='M->M' and calldir='A->B')
	group by c.sessionid
) m
where c.sessionid=m.sessionid 

-------------
-- Ringing
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [VoLTE_Ringing_time]=m.msgtime
   ,[VoLTE_Ringing_samples]=m.samples
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionid=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (Ringing)'   
		  and m.messageid='IMS SIP INVITE' and responseCode='Ringing' 
		  and  m.msgtime>=c.Dial
		  and ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))
	group by c.sessionid
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionidb=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (Ringing)'    
		  and m.messageid='IMS SIP INVITE' and responseCode='Ringing' 
		  and  m.msgtime>=c.Dial
		  and ( calltype='M->M' and calldir='B->A')
	group by c.sessionid
) m
where c.sessionid=m.sessionid 

-------------
-- Ringing Receiving_Party
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [VoLTE_Ringing_time_receiving_Party]=m.msgtime
   ,[VoLTE_Ringing_samples_receiving_Party]=m.samples
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionid=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (Ringing)' 
		  and m.messageid='IMS SIP INVITE' and responseCode='Ringing' 
		  and  m.msgtime>=c.dial
		  and ( calltype<>'M->M' or (calltype='M->M' and calldir='B->A'))
	group by c.sessionid
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionidb=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (Ringing)' 
		  and m.messageid='IMS SIP INVITE' and responseCode='Ringing' 
		  and  m.msgtime>=c.dial
		  and ( calltype='M->M' and calldir='A->B')
	group by c.sessionid
) m
where c.sessionid=m.sessionid 

-------------
-- Invite OK
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [VoLTE_InviteOK_time]=m.msgtime
   ,[VoLTE_InviteOK_samples]=m.samples
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionid=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (OK)' 
		  and m.messageid='IMS SIP INVITE' and responseCode='OK' 
		  and  m.msgtime>=c.Dial
		  and ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))
	group by c.sessionid
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionidb=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (OK)' 
		  and m.messageid='IMS SIP INVITE' and responseCode='OK' 
		  and  m.msgtime>=c.Dial
		  and ( calltype='M->M' and calldir='B->A')
	group by c.sessionid
) m
where c.sessionid=m.sessionid 

-------------
-- Invite OK Receiving_Party
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [VoLTE_InviteOK_time_receiving_Party]=m.msgtime
   ,[VoLTE_InviteOK_samples_receiving_Party]=m.samples
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionid=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (OK)' 
		  and m.messageid='IMS SIP INVITE' and responseCode='OK' 
		  and  m.msgtime>=c.dial
		  and ( calltype<>'M->M' or (calltype='M->M' and calldir='B->A'))
	group by c.sessionid
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionidb=m.sessionid 
		  --and m.l3_message='IMS SIP INVITE (OK)' 
		  and m.messageid='IMS SIP INVITE' and responseCode='OK' 
		  and  m.msgtime>=c.dial
		  and ( calltype='M->M' and calldir='A->B')
	group by c.sessionid
) m
where c.sessionid=m.sessionid 

-------------
-- SIP ACK 
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [VoLTE_ACK_time]=m.msgtime
   ,[VoLTE_ACK_samples]=m.samples
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionid=m.sessionid 
		  --and m.l3_message='IMS SIP ACK (Request)'
		  and m.messageid='IMS SIP ACK' and responseCode='Request'  
		  and  m.msgtime>=c.Dial
		  and ( calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))
	group by c.sessionid
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionidb=m.sessionid 
		  --and m.l3_message='IMS SIP ACK (Request)' 
		  and m.messageid='IMS SIP ACK' and responseCode='Request'  
		  and  m.msgtime>=c.Dial
		  and ( calltype='M->M' and calldir='B->A')
	group by c.sessionid
) m
where c.sessionid=m.sessionid 

-------------
-- SIP ACK Receiving_Party
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [VoLTE_ACK_time_receiving_Party]=m.msgtime
   ,[VoLTE_ACK_samples_receiving_Party]=m.samples
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionid=m.sessionid 
		  --and m.l3_message='IMS SIP ACK (Request)'
		  and m.messageid='IMS SIP ACK' and responseCode='Request'   
		  and  m.msgtime>=c.dial
		  and ( calltype<>'M->M' or (calltype='M->M' and calldir='B->A'))
	group by c.sessionid
union 
	select c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vIMSSIPMessage   m
	where c.sessionidb=m.sessionid 
		  --and m.l3_message='IMS SIP ACK (Request)' 
		  and m.messageid='IMS SIP ACK' and responseCode='Request'  
		  and  m.msgtime>=c.dial
		  and ( calltype='M->M' and calldir='A->B')
	group by c.sessionid
) m
where c.sessionid=m.sessionid 


--***************************************************************************************************** other INFO
-------------
-- Num RAB Setups in both sides
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [Num_RABSetup_samples]=m.samples
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select sessionid,  sum(samples) as samples
	from
	 (
		select c.sessionid,  sum(1) as samples
		from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
		where c.sessionid=m.sessionid 
			  and m.l3_message='RadioBearerSetup' 
			  and  m.msgtime>c.dial and m.msgtime<c.[ConnectAck_time]
		  
		group by c.sessionid
	  union all
		select c.sessionid, sum(1) as samples
		from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
		where c.sessionidb=m.sessionid 
			  and m.l3_message='RadioBearerSetup' 
			  and  m.msgtime>c.dial and m.msgtime<c.[ConnectAck_time]
		  
		group by c.sessionid
	 ) m 
	 group by sessionid
) m
where c.sessionid=m.sessionid 

-------------
-- Num RAB Reconf in both sides
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [Num_RABReconf_samples]=m.samples
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select sessionid,  sum(samples) as samples
	from
	 (
		select c.sessionid,  sum(1) as samples
		from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
		where c.sessionid=m.sessionid 
			  and m.l3_message='RadioBearerReconfiguration' 
			  and  m.msgtime>c.dial and m.msgtime<c.[ConnectAck_time]
		  
		group by c.sessionid
	  union all
		select c.sessionid, sum(1) as samples
		from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
		where c.sessionidb=m.sessionid 
			  and m.l3_message='RadioBearerReconfiguration' 
			  and  m.msgtime>c.dial and m.msgtime<c.[ConnectAck_time]
		  
		group by c.sessionid
	 ) m 
	 group by sessionid
) m
where c.sessionid=m.sessionid 

-------------
-- Num Phy Reconf in both sides
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [Num_PhyChannelReconf_samples]=m.samples
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select sessionid,  sum(samples) as samples
	from
	 (
		select c.sessionid,  sum(1) as samples
		from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
		where c.sessionid=m.sessionid 
			  and m.l3_message='PhysicalChannelReconfiguration' 
			  and  m.msgtime>c.dial and m.msgtime<c.[ConnectAck_time]
		  
		group by c.sessionid
	  union all
		select c.sessionid, sum(1) as samples
		from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
		where c.sessionidb=m.sessionid 
			  and m.l3_message='PhysicalChannelReconfiguration' 
			  and  m.msgtime>c.dial and m.msgtime<c.[ConnectAck_time]
		  
		group by c.sessionid
	 ) m 
	 group by sessionid
) m
where c.sessionid=m.sessionid 

---------------
-- Num layer3 in both sides
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set [Num_L3Msgs_samples]=m.samples
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select sessionid,  sum(samples) as samples
	from
	 (
		select c.sessionid,  sum(1) as samples
		from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
		where c.sessionid=m.sessionid 
			  
			  and  m.msgtime>c.dial and m.msgtime<c.[ConnectAck_time]
		  
		group by c.sessionid
	  union all
		select c.sessionid, sum(1) as samples
		from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
		where c.sessionidb=m.sessionid 
			  
			  and  m.msgtime>c.dial and m.msgtime<c.[ConnectAck_time]
		  
		group by c.sessionid
		----- si la llamada es volte
		union all
		select c.sessionid,  sum(1) as samples
		from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
		where c.sessionid=m.sessionid 
			  
			  and  m.msgtime>c.dial and m.msgtime<c.[VoLTE_ACK_time]
		  
		group by c.sessionid
	  union all
		select c.sessionid, sum(1) as samples
		from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,  vlcc_Layer3_core   m
		where c.sessionidb=m.sessionid 
			  
			  and  m.msgtime>c.dial and m.msgtime<c.[VoLTE_ACK_time]
		  
		group by c.sessionid
	 ) m 
	 group by sessionid
) m
where c.sessionid=m.sessionid 

------------- 
-- NASTransportDL_AvisoDisp_time				
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set		NASTransportDL_AvisoDisp_time=m.msgtime,		NASTransportDL_AvisoDisp_samples=m.samples,
		NASTransportDL_AvisoDisp_msg=m.sm
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select  c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb,
		[dbo].[SQLTENASKeyValue](Msg, Direction,'SM') as SM
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c, [dbo].[LTENASMessages] m
	where c.sessionid=m.sessionid 
		and (calltype='M->M' and calldir='A->B')
		and MsgTypeName='Downlink NAS transport'
		and [dbo].[SQLTENASKeyValue](Msg, Direction,'SM') like 'Aviso%de%disponibilidad%' 
	group by c.sessionid, c.sessionidb, [dbo].[SQLTENASKeyValue](Msg, Direction,'SM')

	union all
	select  c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb,
		[dbo].[SQLTENASKeyValue](Msg, Direction,'SM')  as SM
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c, [dbo].[LTENASMessages] m
	where c.sessionidB=m.sessionid 
		and (calltype='M->M' and calldir='B->A')
		and MsgTypeName='Downlink NAS transport'
		and [dbo].[SQLTENASKeyValue](Msg, Direction,'SM') like 'Aviso%de%disponibilidad%' 
	group by c.sessionid, c.sessionidb, [dbo].[SQLTENASKeyValue](Msg, Direction,'SM')
 
) m
where c.sessionid=m.sessionid 

------------- 
-- NASTransportDL_AvisoDisp_time				
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set		NASTransportDL_AvisoDisp_Receiving_Party_time=m.msgtime,		NASTransportDL_AvisoDisp_Receiving_Party_samples=m.samples,
		NASTransportDL_AvisoDisp_Receiving_Party_msg=m.sm
from _lcc_c0re_Voice_Metrics_TimeStamp_Table c,
(
	select  c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb,
		[dbo].[SQLTENASKeyValue](Msg, Direction,'SM') as SM
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c, [dbo].[LTENASMessages] m
	where c.sessionid=m.sessionid 
		and (calltype='M->M' and calldir='B->A')
		and MsgTypeName='Downlink NAS transport'
		and [dbo].[SQLTENASKeyValue](Msg, Direction,'SM') like 'Aviso%de%disponibilidad%' 
	group by c.sessionid, c.sessionidb, [dbo].[SQLTENASKeyValue](Msg, Direction,'SM')

	union all
	select  c.sessionid, min(m.msgtime) as msgtime, sum(1) as samples, c.sessionidb,
		[dbo].[SQLTENASKeyValue](Msg, Direction,'SM')  as SM
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table c, [dbo].[LTENASMessages] m
	where c.sessionidB=m.sessionid 
		and (calltype='M->M' and calldir='A->B')
		and MsgTypeName='Downlink NAS transport'
		and [dbo].[SQLTENASKeyValue](Msg, Direction,'SM') like 'Aviso%de%disponibilidad%' 
	group by c.sessionid, c.sessionidb, [dbo].[SQLTENASKeyValue](Msg, Direction,'SM')
 
) m
where c.sessionid=m.sessionid 


--***************************************************************************************************** Info MARGENES DE LA LLAMADA:
-------------
-- callStartTime_Dial - DIAL INFO
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set callStartTime_Dial=Dial

-------------
-- callSetupTime_ConACK - Connect Info INFO
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set callSetupTime_ConACK= case when ConnectACK_time is not null then ConnectACK_time else
											case when VoLTE_InviteOK_time is not null then VoLTE_InviteOK_time 
												end end 

update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set callSetupTime_ConACK_samples= case when ConnectACK_samples is not null then ConnectACK_samples else
											case when VoLTE_InviteOK_samples is not null then VoLTE_InviteOK_samples 
												end end 

-------------
-- callEndTime_Disconnect - Disconnect Info INFO
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set callEndTime_Disconnect=case when Disconnect_time is not null then Disconnect_time  else
											case when Release_time is not null then Release_time else
												case when ReleaseComplete_time is not null then ReleaseComplete_time else
													 case when VoLTE_Bye_req_time is not null then VoLTE_Bye_req_time else
														case when VoLTE_ByeOK_time is not null then VoLTE_ByeOK_time else

										-- WO Calling Party info, we get Receiving Party Info:		
															case when DisConnect_Receiving_Party_time is not null then DisConnect_Receiving_Party_time  else
																case when Release_Receiving_Party_time is not null then Release_Receiving_Party_time else
																	case when ReleaseComplete_Receiving_Party_time is not null then ReleaseComplete_Receiving_Party_time else
																		 case when VoLTE_Bye_req_time_Receiving_Party is not null then VoLTE_Bye_req_time_Receiving_Party  else
																			case when VoLTE_ByeOK_time_Receiving_Party is not null then VoLTE_ByeOK_time_Receiving_Party 
																				end end end end end end end end end end

update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set callEndTime_Disconnect_samples=case when Disconnect_samples is not null then Disconnect_samples  else
											case when Release_samples is not null then Release_samples else
												case when ReleaseComplete_samples is not null then ReleaseComplete_samples else
													 case when VoLTE_Bye_req_samples is not null then VoLTE_Bye_req_samples else
														case when VoLTE_ByeOK_samples is not null then VoLTE_ByeOK_samples else

										-- WO Calling Party info, we get Receiving Party Info:		
															case when Disconnect_Receiving_Party_samples is not null then Disconnect_Receiving_Party_samples  else
																case when Release_Receiving_Party_samples is not null then Release_Receiving_Party_samples else
																	case when ReleaseComplete_Receiving_Party_samples is not null then ReleaseComplete_Receiving_Party_samples else
																		 case when VoLTE_Bye_req_samples_Receiving_Party is not null then VoLTE_Bye_req_samples_Receiving_Party  else
																			case when VoLTE_ByeOK_samples_Receiving_Party is not null then VoLTE_ByeOK_samples_Receiving_Party 
																				end end end end end end end end end end

-------------
-- callDuration_Dial2Disconnect 
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set callDuration_Dial2Disconnect=datediff(ms, callStartTime_Dial, callEndTime_Disconnect)

-------------
-- callDuration_ConACK2Disconnect 
update _lcc_c0re_Voice_Metrics_TimeStamp_Table
set callDuration_ConACK2Disconnect=datediff(ms, callSetupTime_ConACK, callEndTime_Disconnect)


----------------------------------------------------	select * from _lcc_c0re_Voice_Metrics_TimeStamp_Table

--***********************************************************************************************************************************
--		Tabla CORE final:
--***********************************************************************************************************************************
------declare @Config as [nvarchar](max)='SpainOSP'
exec('
	exec sp_lcc_dropifexists ''lcc_core_Voice_'+@Config+'_Metrics_TimeStamp_Table''	
	select * 
	into lcc_core_Voice_'+@Config+'_Metrics_TimeStamp_Table
	from _lcc_c0re_Voice_Metrics_TimeStamp_Table
')

--***********************************************************************************************************************************
-- Borrado Tablas Intermedias:
--***********************************************************************************************************************************
exec sp_lcc_dropifexists '_lcc_c0re_Voice_Metrics_TimeStamp_Table'

-- Se corrrige el nombre de la columna, para dejarlo acorde al resto de tablas				
exec sp_rename 'lcc_core_Voice_Metrics_TimeStamp_Table.sessionid', 'sessionidA', 'COLUMN'

----------------------------------------------------	select * from lcc_core_Voice_Metrics_TimeStamp_Table	

