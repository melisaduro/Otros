USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_lcc_core_Voice_Metrics_Table]    Script Date: 23/04/2018 13:56:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[sp_lcc_core_Voice_Metrics_Table] as

-- DESCRIPTION ------------------------------------------------------------------------------------------------------
--
--		* COLLATE Latin1_General_CI_AS	-> database_default
--
--		* Base TABLE/VIEW:		callanalysis	-> both side are considered
--
--		* Updates with layer 3 info and lcc_core_Voice_Markers_Time
--
--		* DGP 21/02/2018: SRVCC Destination added
--
--		* DGP 01/03/2018: BSIC,SC,PCI & Cellid added for every Call Setup phase

--		* EMS 28/03/2018: isSRVCC added for GSM calls
--
---------------------------------------------------------------------------------------------------------------------

------------------------------------------------ select * from lcc_core_Voice_Metrics_Table

--select top 1 * from lcc_core_Voice_Markers_Time
--select top 1 * from vlcc_Layer3_comp_core
--select top 1 * from vlcc_Layer3_core


---------------------------------------------------------------------------------------------------------------------	
exec sp_lcc_dropifexists 'lcc_core_Voice_Metrics_Table'
select 
	db_name()+'_'+convert(varchar(256),s.sessionid)+'_'+isnull(convert(varchar(256),'NA'),'NA') COLLATE Latin1_General_CI_AS as key_BST, 
	db_name() COLLATE Latin1_General_CI_AS as ddbb,
	
	s.sessionid as sessionidA, s.sessionidB,
	s.calltype, s.calldir,

	------------------------------------
	s.disconClass, s.disconCause, s.disconLocation, s.codeDescription,
	------------------------------------

	convert(varchar(25),null) as calltypeA,		convert(varchar(25),null) as calltypeB,	
	convert(int, null) as call_CSFB_inA,		convert(int, null) as call_CSFB_inB,
	convert(int, null) as call_SRVCC_inA,		convert(int, null) as call_SRVCC_inB,   		

	------------------------------------
	convert(varchar(25),null) as callingParty_type,		convert(varchar(25),null) as calledParty_type,	
	convert(int, null) as callingParty_CSFB,			convert(int, null) as calledParty_CSFB,
	convert(int, null) as callingParty_SRVCC,			convert(int, null) as calledParty_SRVCC, 
	convert(int, null) as callingParty_SRVCC_Failure,			convert(int, null) as calledParty_SRVCC_Failure,
	convert(varchar(100), null)			as callingParty_SRVCC_Dest,
	convert(varchar(100), null)			as calledParty_SRVCC_Dest,

	------------------------------------
	----	Freq / Band Info:
	convert(varchar(100), null)			as CMService_freq,
	convert(varchar(100), null)			as CMService_band,
	convert(varchar(100), null)			as CMService_BSIC_SC_PCI,
	convert(varchar(100), null)			as CMService_CellId,
	convert(varchar(100), null)			as CallConfirmed_freq_Receiving_Party,
	convert(varchar(100), null)			as CallConfirmed_band_Receiving_Party,
	convert(varchar(100), null)			as CallConfirmed_BSIC_SC_PCI_Receiving_Party,
	convert(varchar(100), null)			as CallConfirmed_CellId_Receiving_Party,

	convert(int, null)					as Alerting_freq,
	convert(varchar(100), null)			as Alerting_band,
	convert(int, null)					as Alerting_BSIC_SC_PCI,
	convert(varchar(100), null)			as Alerting_CellId,
	convert(varchar(100), null)			as Alerting_freq_Receiving_Party,
	convert(varchar(100), null)			as Alerting_band_Receiving_Party,
	convert(varchar(100), null)			as Alerting_BSIC_SC_PCI_Receiving_Party,
	convert(varchar(100), null)			as Alerting_CellId_Receiving_Party,

	convert(int, null)					as Connect_freq,
	convert(varchar(100), null)			as Connect_band,
	convert(int, null)					as Connect_BSIC_SC_PCI,
	convert(varchar(100), null)			as Connect_CellId,
	convert(varchar(100), null)			as Connect_freq_Receiving_Party,
	convert(varchar(100), null)			as Connect_band_Receiving_Party,
	convert(varchar(100), null)			as Connect_BSIC_SC_PCI_Receiving_Party,
	convert(varchar(100), null)			as Connect_CellId_Receiving_Party,
	
	convert(varchar(100), null)			as Disconnect_freq,
	convert(varchar(100), null)			as Disconnect_band,
	convert(varchar(100), null)			as Disconnect_BSIC_SC_PCI,
	convert(varchar(100), null)			as Disconnect_CellId,
	convert(varchar(100), null)			as Disconnect_freq_Receiving_Party,
	convert(varchar(100), null)			as Disconnect_band_Receiving_Party,
	convert(varchar(100), null)			as Disconnect_BSIC_SC_PCI_Receiving_Party,
	convert(varchar(100), null)			as Disconnect_CellId_Receiving_Party,

	convert(varchar(100), null)			as VOLTE_Invite_req_freq,	
	convert(varchar(100), null)			as VOLTE_Invite_req_band,
	convert(varchar(100), null)			as VOLTE_Invite_req_BSIC_SC_PCI,	
	convert(varchar(100), null)			as VOLTE_Invite_req_CellId,	
	convert(varchar(100), null)			as VOLTE_Invite_req_freq_Receiving_Party, 
	convert(varchar(100), null)			as VOLTE_Invite_req_band_Receiving_Party, 	
	convert(varchar(100), null)			as VOLTE_Invite_req_BSIC_SC_PCI_Receiving_Party, 
	convert(varchar(100), null)			as VOLTE_Invite_req_CellId_Receiving_Party, 

	convert(varchar(100), null)			as VOLTE_Ringing_freq, 
	convert(varchar(100), null)			as VOLTE_Ringing_band, 
	convert(varchar(100), null)			as VOLTE_Ringing_BSIC_SC_PCI, 
	convert(varchar(100), null)			as VOLTE_Ringing_CellId, 
	convert(varchar(100), null)			as VOLTE_Ringing_freq_Receiving_Party,
	convert(varchar(100), null)			as VOLTE_Ringing_band_Receiving_Party,
	convert(varchar(100), null)			as VOLTE_Ringing_BSIC_SC_PCI_Receiving_Party,
	convert(varchar(100), null)			as VOLTE_Ringing_CellId_Receiving_Party,

	convert(varchar(100), null)			as VOLTE_InviteOK_freq,
	convert(varchar(100), null)			as VOLTE_InviteOK_band,
	convert(varchar(100), null)			as VOLTE_InviteOK_BSIC_SC_PCI,
	convert(varchar(100), null)			as VOLTE_InviteOK_CellId,
	convert(varchar(100), null)			as VOLTE_InviteOK_freq_receiving_Party,
	convert(varchar(100), null)			as VOLTE_InviteOK_band_receiving_Party,
	convert(varchar(100), null)			as VOLTE_InviteOK_BSIC_SC_PCI_receiving_Party,
	convert(varchar(100), null)			as VOLTE_InviteOK_CellId_receiving_Party,

	convert(varchar(100), null)			as VOLTE_Bye_req_freq,
	convert(varchar(100), null)			as VOLTE_Bye_req_band,
	convert(varchar(100), null)			as VOLTE_Bye_req_BSIC_SC_PCI,
	convert(varchar(100), null)			as VOLTE_Bye_req_CellId,
	convert(varchar(100), null)			as VOLTE_Bye_req_freq_receiving_Party,
	convert(varchar(100), null)			as VOLTE_Bye_req_band_receiving_Party,
	convert(varchar(100), null)			as VOLTE_Bye_req_BSIC_SC_PCI_receiving_Party,
	convert(varchar(100), null)			as VOLTE_Bye_req_CellId_receiving_Party,

	------------------------------------
	----	HO Info:
	convert(float, null)				as HOs_Duration_Avg_A,
	convert(float, null)				as HOs_Duration_Avg_B,

	convert(int, null)					as Handovers_A,
	convert(int, null)					as Handovers_B,

	convert(int, null)					as Handover_Failures_A,
	convert(int, null)					as Handover_Failures_B,

	convert(int, null)					as Handover_2G2G_Failures_A,	convert(int, null)					as Handover_2G3G_Failures_A,	
	convert(int, null)					as Handover_3G2G_Failures_A,	convert(int, null)					as Handover_3G3G_Failures_A,
	convert(int, null)					as Handover_4G3G_Failures_A,	convert(int, null)					as Handover_4G4G_Failures_A,
	convert(int, null)					as Handover_2G2G_Failures_B,	convert(int, null)					as Handover_2G3G_Failures_B,	
	convert(int, null)					as Handover_3G2G_Failures_B,	convert(int, null)					as Handover_3G3G_Failures_B,
	convert(int, null)					as Handover_4G3G_Failures_B,	convert(int, null)					as Handover_4G4G_Failures_B,
	

	------------------------------------
	----	Neighbors Info - Neighbors TOP 1
	convert(int, null)					as N1_BCCH_A,		convert(float, null)				as N1_RxLev_A,
	convert(int, null)					as N1_BCCH_B,		convert(float, null)				as N1_RxLev_B,

	convert(int, null)					as N1_PSC_A,		convert(float, null)				as N1_RSCP_A,
	convert(int, null)					as N1_PSC_B,		convert(float, null)				as N1_RSCP_B

into lcc_core_Voice_Metrics_Table

from 
	(
		select	c.sessionid,c.posid,c.networkid,c.fileid,c.calltype,c.callDir,
				b.sessionid as SessionidB, c.callStatus, 
				c.disconClass, c.disconCause, c.disconLocation, c.codeDescription
		 from callanalysis c, sessions s, sessionsb b
		 where c.sessionid=s.sessionid 
			  and s.sessionid=b.sessionida 		
	) s


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Update lcc_core_Voice_Metrics_Table with Layer 3 info 
--		*******PENDIENTE:	Lo suyo seria coger los tiempos desde lcc_core_Voice_Metrics_TimeStamp_Table, para no repetir calculos en 2 procs diferentes (xsi cambia alguno)

------------------------------------------------------------------------------------------------ NO VOLTE:

----------------------- CMService:
update lcc_core_Voice_Metrics_Table
set CMService_freq = v.bcch,		CMService_band = v.RFBand,	CMService_BSIC_SC_PCI=case when v.RFBand like '%GSM%' then v.BSIC else v.psc end, CMService_CellId=v.Cid
from lcc_core_Voice_Metrics_Table c, 
	(	select  m.key_BST, m.sessionidA, m.sessionidB, msgtime,			l3_message,			bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by m.sessionidA, l3_message order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_Layer3_comp_core l
		where l3_message in ('CM Service Request') 
			and m.sessionidA=l.sessionid 
			and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))

		union all
		select  m.key_BST, m.sessionidA, m.sessionidB, msgtime,			l3_message,			bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by m.sessionidB, l3_message order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_Layer3_comp_core l
		where l3_message in ('CM Service Request') 
			and m.sessionidB=l.sessionid 
			and (calltype='M->M' and calldir='B->A')
	) v 
where c.key_BST=v.key_BST and v.id=1 

----------------------- Call Confirmed Receiving_Party:
update lcc_core_Voice_Metrics_Table
set		CallConfirmed_freq_Receiving_Party = v.bcch, CallConfirmed_band_Receiving_Party  = v.RFBand ,	CallConfirmed_BSIC_SC_PCI_Receiving_Party=case when v.RFBand like '%GSM%' then v.BSIC else v.psc end, CallConfirmed_CellId_Receiving_Party=v.Cid
from lcc_core_Voice_Metrics_Table c, 
	(select  m.key_BST, m.sessionidA, m.sessionidB, msgtime,		l3_message,			bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by m.sessionidB, l3_message order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_Layer3_comp_core l
		where l3_message in ('Call Confirmed') 
			and m.sessionidB=l.sessionid 
			and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))

		union all
		select  m.key_BST, m.sessionidA, m.sessionidB, msgtime,		l3_message,			bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by m.sessionidA, l3_message order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_Layer3_comp_core l
		where l3_message in ('Call Confirmed') 
			and m.sessionidA=l.sessionid 
			and (calltype='M->M' and calldir='B->A')	
	) v
where c.key_BST=v.key_BST and v.id=1 

---------------------------------
----------------------- Alerting:
update lcc_core_Voice_Metrics_Table
set		Alerting_freq = v.bcch,		Alerting_band = v.RFBand,	Alerting_BSIC_SC_PCI=case when v.RFBand like '%GSM%' then v.BSIC else v.psc end, Alerting_CellId=v.Cid
from lcc_core_Voice_Metrics_Table c, 
	(	select  m.key_BST, m.sessionidA, m.sessionidB,		msgtime,		l3_message,			bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by sessionidA, l3_message order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_Layer3_comp_core l
		where l3_message in ('Alerting')
			and m.sessionidA=l.sessionid  
			and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))	

		union all
		select  m.key_BST, m.sessionidA, m.sessionidB,		msgtime,		l3_message,			bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by sessionidB, l3_message order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_Layer3_comp_core l
		where l3_message in ('Alerting')
			and m.sessionidB=l.sessionid  
			and ( calltype='M->M' and calldir='B->A')	
	) v
where c.key_BST=v.key_BST and v.id=1

----------------------- Alerting Receiving_Party:
update lcc_core_Voice_Metrics_Table
set 	Alerting_freq_Receiving_Party = v.bcch,		Alerting_band_Receiving_Party = v.RFBand,	Alerting_BSIC_SC_PCI_Receiving_Party=case when v.RFBand like '%GSM%' then v.BSIC else v.psc end, Alerting_CellId_Receiving_Party=v.Cid 
from lcc_core_Voice_Metrics_Table c, 
	(	select  m.key_BST, m.sessionidA, m.sessionidB,		msgtime,		l3_message,			bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by sessionidB, l3_message order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_Layer3_comp_core l
		where l3_message in ('Alerting')
			and m.sessionidB=l.sessionid  
			and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))	

		union all
		select  m.key_BST, m.sessionidA, m.sessionidB,		msgtime,		l3_message,			bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by sessionidA, l3_message order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_Layer3_comp_core l
		where l3_message in ('Alerting')
			and m.sessionidA=l.sessionid  
			and (calltype='M->M' and calldir='B->A')	
	) v
where c.key_BST=v.key_BST and v.id=1 

---------------------------------
----------------------- Connect:
update lcc_core_Voice_Metrics_Table
set 	Connect_freq = v.bcch,		Connect_band = v.RFBand,	Connect_BSIC_SC_PCI=case when v.RFBand like '%GSM%' then v.BSIC else v.psc end, Connect_CellId=v.Cid
from lcc_core_Voice_Metrics_Table c, 
	(	select m.key_BST, m.sessionidA, m.sessionidB,		msgtime,		l3_message,			bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by sessionidA, l3_message order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_Layer3_comp_core l
		where l3_message in ('Connect')
			and m.sessionidA=l.sessionid  
			and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))

		union all
		select m.key_BST, m.sessionidA, m.sessionidB,		msgtime,		l3_message,			bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by sessionidB, l3_message order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_Layer3_comp_core l
		where l3_message in ('Connect')
			and m.sessionidB=l.sessionid  
			and (calltype='M->M' and calldir='B->A')
	) v
where c.key_BST=v.key_BST and v.id=1

----------------------- Connect Receiving_Party:
update lcc_core_Voice_Metrics_Table
set 	Connect_freq_Receiving_Party = v.bcch,		Connect_band_Receiving_Party = v.RFBand,	Connect_BSIC_SC_PCI_Receiving_Party=case when v.RFBand like '%GSM%' then v.BSIC else v.psc end, Connect_CellId_Receiving_Party=v.Cid 
from lcc_core_Voice_Metrics_Table c, 
	(	select m.key_BST, m.sessionidA, m.sessionidB,		msgtime,		l3_message,			bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by sessionidB, l3_message order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_Layer3_comp_core l
		where l3_message in ('Connect')
			and m.sessionidB=l.sessionid  
			and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))

		union all
		select m.key_BST, m.sessionidA, m.sessionidB,		msgtime,		l3_message,			bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by sessionidA, l3_message order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_Layer3_comp_core l
		where l3_message in ('Connect')
			and m.sessionidA=l.sessionid  
			and (calltype='M->M' and calldir='B->A')
	) v
where c.key_BST=v.key_BST and v.id=1

---------------------------------
----------------------- Disconnect:
update lcc_core_Voice_Metrics_Table
set 	Disconnect_freq = v.bcch,		Disconnect_band = v.RFBand,	Disconnect_BSIC_SC_PCI=case when v.RFBand like '%GSM%' then v.BSIC else v.psc end, Disconnect_CellId=v.Cid 
from lcc_core_Voice_Metrics_Table c, 
	(	select  m.key_BST, m.sessionidA, m.sessionidB,		msgtime,		l3_message,			bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by sessionidA, l3_message order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_Layer3_comp_core l
		where l3_message in ('Disconnect')
			and m.sessionidA=l.sessionid  
			and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))

		union all
		select  m.key_BST, m.sessionidA, m.sessionidB,		msgtime,		l3_message,			bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by sessionidB, l3_message order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_Layer3_comp_core l
		where l3_message in ('Disconnect')
			and m.sessionidB=l.sessionid  
			and (calltype='M->M' and calldir='B->A')
	) v
where c.key_BST=v.key_BST and v.id=1 

----------------------- Disconnect Receiving_Party:
update lcc_core_Voice_Metrics_Table
set 	Disconnect_freq_Receiving_Party = v.bcch,	Disconnect_band_Receiving_Party = v.RFBand,	Disconnect_BSIC_SC_PCI_Receiving_Party=case when v.RFBand like '%GSM%' then v.BSIC else v.psc end, Disconnect_CellId_Receiving_Party=v.Cid  
from lcc_core_Voice_Metrics_Table c, 
	(	select  m.key_BST, m.sessionidA, m.sessionidB,		msgtime,		l3_message,			bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by sessionidB, l3_message order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_Layer3_comp_core l
		where l3_message in ('Disconnect')
			and m.sessionidB=l.sessionid  
			and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))

		union all
		select  m.key_BST, m.sessionidA, m.sessionidB,		msgtime,		l3_message,			bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by sessionidA, l3_message order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_Layer3_comp_core l
		where l3_message in ('Disconnect')
			and m.sessionidA=l.sessionid  
			and (calltype='M->M' and calldir='B->A')
	) v
where c.key_BST=v.key_BST and v.id=1 

------------------------------------------------------------------------------------------------ VOLTE:

----------------------- VOLTE_Invite_req
update lcc_core_Voice_Metrics_Table
set VOLTE_Invite_req_freq = v.bcch,		VOLTE_Invite_req_band = v.RFBand,	VOLTE_Invite_req_BSIC_SC_PCI=case when v.RFBand like '%GSM%' then v.BSIC else v.psc end, VOLTE_Invite_req_CellId=v.Cid  
from lcc_core_Voice_Metrics_Table c, 
	(	select  m.key_BST, m.sessionidA, m.sessionidB, msgtime,			messageid,		bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by m.sessionidA, messageid order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_IMSSIPMessage_comp_core l
		where l.messageid='IMS SIP INVITE' and responseCode='Request'
			and m.sessionidA=l.sessionid 
			and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))

		union all
		select  m.key_BST, m.sessionidA, m.sessionidB, msgtime,			messageid,		bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by m.sessionidB, messageid order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_IMSSIPMessage_comp_core l
		where l.messageid='IMS SIP INVITE' and responseCode='Request'
			and m.sessionidB=l.sessionid 
			and (calltype='M->M' and calldir='B->A')
	) v 
where c.key_BST=v.key_BST and v.id=1 

----------------------- VOLTE_Invite_req Receiving_Party:
update lcc_core_Voice_Metrics_Table
set	VOLTE_Invite_req_freq_Receiving_Party = v.bcch, VOLTE_Invite_req_band_Receiving_Party  = v.RFBand ,	VOLTE_Invite_req_BSIC_SC_PCI_Receiving_Party=case when v.RFBand like '%GSM%' then v.BSIC else v.psc end, VOLTE_Invite_req_CellId_Receiving_Party=v.Cid  
from lcc_core_Voice_Metrics_Table c, 
	(select  m.key_BST, m.sessionidA, m.sessionidB, msgtime,			messageid,		bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by m.sessionidB, messageid order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_IMSSIPMessage_comp_core l
		where l.messageid='IMS SIP INVITE' and responseCode='Request'
			and m.sessionidB=l.sessionid 
			and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))

		union all
		select  m.key_BST, m.sessionidA, m.sessionidB, msgtime,			messageid,		bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by m.sessionidA, messageid order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_IMSSIPMessage_comp_core l
		where l.messageid='IMS SIP INVITE' and responseCode='Request'
			and m.sessionidA=l.sessionid 
			and (calltype='M->M' and calldir='B->A')	
	) v
where c.key_BST=v.key_BST and v.id=1 

---------------------------------
----------------------- VOLTE_Ringing:
update lcc_core_Voice_Metrics_Table
set	VOLTE_Ringing_freq = v.bcch,		VOLTE_Ringing_band = v.RFBand,	VOLTE_Ringing_BSIC_SC_PCI=case when v.RFBand like '%GSM%' then v.BSIC else v.psc end, VOLTE_Ringing_CellId=v.Cid 
from lcc_core_Voice_Metrics_Table c, 
	(	select  m.key_BST, m.sessionidA, m.sessionidB,		msgtime,			messageid,		bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by sessionidA, messageid order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_IMSSIPMessage_comp_core l
		where l.messageid='IMS SIP INVITE' and responseCode='Ringing' 
			and m.sessionidA=l.sessionid  
			and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))	

		union all
		select  m.key_BST, m.sessionidA, m.sessionidB,		msgtime,			messageid,		bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by sessionidB, messageid order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_IMSSIPMessage_comp_core l
		where l.messageid='IMS SIP INVITE' and responseCode='Ringing' 
			and m.sessionidB=l.sessionid  
			and ( calltype='M->M' and calldir='B->A')	
	) v
where c.key_BST=v.key_BST and v.id=1

----------------------- VOLTE_Ringing Receiving_Party:
update lcc_core_Voice_Metrics_Table
set VOLTE_Ringing_freq_Receiving_Party = v.bcch,		VOLTE_Ringing_band_Receiving_Party = v.RFBand,	VOLTE_Ringing_BSIC_SC_PCI_Receiving_Party=case when v.RFBand like '%GSM%' then v.BSIC else v.psc end, VOLTE_Ringing_CellId_Receiving_Party=v.Cid  
from lcc_core_Voice_Metrics_Table c, 
	(	select  m.key_BST, m.sessionidA, m.sessionidB,		msgtime,			messageid,		bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by sessionidB, messageid order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_IMSSIPMessage_comp_core l
		where l.messageid='IMS SIP INVITE' and responseCode='Ringing' 
			and m.sessionidB=l.sessionid  
			and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))	

		union all
		select  m.key_BST, m.sessionidA, m.sessionidB,		msgtime,			messageid,		bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by sessionidA, messageid order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_IMSSIPMessage_comp_core l
		where l.messageid='IMS SIP INVITE' and responseCode='Ringing' 
			and m.sessionidA=l.sessionid  
			and (calltype='M->M' and calldir='B->A')	
	) v
where c.key_BST=v.key_BST and v.id=1 

---------------------------------
----------------------- VOLTE_InviteOK:
update lcc_core_Voice_Metrics_Table
set VOLTE_InviteOK_freq = v.bcch,		VOLTE_InviteOK_band = v.RFBand,	VOLTE_InviteOK_BSIC_SC_PCI=case when v.RFBand like '%GSM%' then v.BSIC else v.psc end, VOLTE_InviteOK_CellId=v.Cid  
from lcc_core_Voice_Metrics_Table c, 
	(	select m.key_BST, m.sessionidA, m.sessionidB,		msgtime,			messageid,		bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by sessionidA, messageid order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_IMSSIPMessage_comp_core l
		where l.messageid='IMS SIP INVITE' and responseCode='OK' 
			and m.sessionidA=l.sessionid  
			and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))

		union all
		select m.key_BST, m.sessionidA, m.sessionidB,		msgtime,			messageid,		bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by sessionidB, messageid order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_IMSSIPMessage_comp_core l
		where l.messageid='IMS SIP INVITE' and responseCode='OK'  
			and m.sessionidB=l.sessionid  
			and (calltype='M->M' and calldir='B->A')
	) v
where c.key_BST=v.key_BST and v.id=1

----------------------- VOLTE_InviteOK Receiving_Party:
update lcc_core_Voice_Metrics_Table
set VOLTE_InviteOK_freq_Receiving_Party = v.bcch,		VOLTE_InviteOK_band_Receiving_Party = v.RFBand,	VOLTE_InviteOK_BSIC_SC_PCI_Receiving_Party=case when v.RFBand like '%GSM%' then v.BSIC else v.psc end, VOLTE_InviteOK_CellId_Receiving_Party=v.Cid   
from lcc_core_Voice_Metrics_Table c, 
	(	select m.key_BST, m.sessionidA, m.sessionidB,		msgtime,			messageid,		bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by sessionidB, messageid order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_IMSSIPMessage_comp_core l
		where l.messageid='IMS SIP INVITE' and responseCode='OK' 
			and m.sessionidB=l.sessionid  
			and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))

		union all
		select m.key_BST, m.sessionidA, m.sessionidB,		msgtime,			messageid,		bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by sessionidA, messageid order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_IMSSIPMessage_comp_core l
		where l.messageid='IMS SIP INVITE' and responseCode='OK' 
			and m.sessionidA=l.sessionid  
			and (calltype='M->M' and calldir='B->A')
	) v
where c.key_BST=v.key_BST and v.id=1

---------------------------------
----------------------- VOLTE_Bye_req:
update lcc_core_Voice_Metrics_Table
set VOLTE_Bye_req_freq = v.bcch,		VOLTE_Bye_req_band = v.RFBand,	VOLTE_Bye_req_BSIC_SC_PCI=case when v.RFBand like '%GSM%' then v.BSIC else v.psc end, VOLTE_Bye_req_CellId=v.Cid  
from lcc_core_Voice_Metrics_Table c, 
	(	select  m.key_BST, m.sessionidA, m.sessionidB,		msgtime,			messageid,		bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by sessionidA, messageid order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_IMSSIPMessage_comp_core l
		where l.messageid='IMS SIP BYE' and responseCode='Request'
			and m.sessionidA=l.sessionid  
			and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))

		union all
		select  m.key_BST, m.sessionidA, m.sessionidB,		msgtime,			messageid,		bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by sessionidB, messageid order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_IMSSIPMessage_comp_core l
		where l.messageid='IMS SIP BYE' and responseCode='Request'
			and m.sessionidB=l.sessionid  
			and (calltype='M->M' and calldir='B->A')
	) v
where c.key_BST=v.key_BST and v.id=1 

----------------------- VOLTE_Bye_req Receiving_Party:
update lcc_core_Voice_Metrics_Table
set VOLTE_Bye_req_freq_Receiving_Party = v.bcch,	VOLTE_Bye_req_band_Receiving_Party = v.RFBand,	VOLTE_Bye_req_BSIC_SC_PCI_Receiving_Party=case when v.RFBand like '%GSM%' then v.BSIC else v.psc end, VOLTE_Bye_req_CellId_Receiving_Party=v.Cid   
from lcc_core_Voice_Metrics_Table c, 
	(	select  m.key_BST, m.sessionidA, m.sessionidB,		msgtime,			messageid,		bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by sessionidB, messageid order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_IMSSIPMessage_comp_core l
		where l.messageid='IMS SIP BYE' and responseCode='Request'
			and m.sessionidB=l.sessionid  
			and (calltype<>'M->M' or (calltype='M->M' and calldir='A->B'))

		union all
		select  m.key_BST, m.sessionidA, m.sessionidB,		msgtime,			messageid,		bcch,		RFband,		BSIC,		PSC,		Cid,
				row_number () over (partition by sessionidA, messageid order by msgtime asc) as id
		from lcc_core_Voice_Metrics_Table m, vlcc_IMSSIPMessage_comp_core l
		where l.messageid='IMS SIP BYE' and responseCode='Request'
			and m.sessionidA=l.sessionid  
			and (calltype='M->M' and calldir='B->A')
	) v
where c.key_BST=v.key_BST and v.id=1 
























































--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Update CallType VOLTE/CS for each side (only sessionType= 'CALL' are considered)

--------------------------- side A: 
update lcc_core_Voice_Metrics_Table
set calltypeA = side.SideType
from lcc_core_Voice_Metrics_Table m
	LEFT OUTER JOIN (
		select 
			s.sessionid, s.side,
			case 
			when il.responseCode = 'Trying' and lm.ExtendedSR_Time_A is null then 'VOLTE'
			else 'CS'
			end as 'SideType'
		from callanalysis s
			left outer join (select sessionid, responseCode 
								from vIMSSIPMessage
								where responseCode = 'Trying') il on il.sessionid=s.sessionid 
			left outer join lcc_core_Voice_markers_time lm on lm.sessionid=s.sessionid
		where s.side='A'
		group by s.sessionid, s.side, il.responseCode, lm.ExtendedSR_Time_A
	) side on m.sessionidA=side.sessionid

--------------------------- side B:
update lcc_core_Voice_Metrics_Table
set calltypeB = side.SideType
from lcc_core_Voice_Metrics_Table m
	LEFT OUTER JOIN	(
		select 
			s.sessionid, s.sessionidA, s.side,
			case 
			when il.responseCode = 'Trying' and lm.ExtendedSR_Time_B is null then 'VOLTE'
			else 'CS'
			end as 'SideType'
		from callanalysis s
			left outer join (select sessionid, responseCode 
								from vIMSSIPMessage
								where responseCode = 'Trying') il on il.sessionid=s.sessionid 
			left outer join lcc_core_Voice_markers_time lm on lm.sessionid=s.sessionidA 
		where s.side='B' 
		group by s.sessionid, s.sessionidA, s.side, il.responseCode, lm.ExtendedSR_Time_B
	) side on m.sessionidA=side.sessionidA


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Update CSFB info for each side (only sessionType= 'CALL' are considered)

---------------------------	side A:
update lcc_core_Voice_Metrics_Table
set call_CSFB_inA = side.isCSFB
from lcc_core_Voice_Metrics_Table m,
	(	select  
			s.sessionid, s.sessionidA, s.side,
			case when (ma.ExtendedSR_Time_A is not null) then 1 else 0 end as isCSFB
		from callanalysis s
			left outer join lcc_core_Voice_markers_time ma on ma.sessionid=s.sessionid
		where side='A'
	) side
where m.sessionidA=side.sessionidA

---------------------------	side B:
update lcc_core_Voice_Metrics_Table
set call_CSFB_inB = side.isCSFB
from lcc_core_Voice_Metrics_Table m,
	(	select  
			s.sessionid, sessionidA, s.side,
			case when (ma.ExtendedSR_Time_B is not null) then 1 else 0 end as isCSFB
		from callanalysis s
			left outer join lcc_core_Voice_markers_time ma on ma.sessionid=s.sessionidA
		where side='B'
	) side
where m.sessionidB=side.sessionid 


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Update SRVCC info for each side (only sessionType= 'CALL' are considered)

---------------------------	side A:
update lcc_core_Voice_Metrics_Table
set call_SRVCC_inA = side.isSRVCC
from lcc_core_Voice_Metrics_Table m,
	(	select  
			s.sessionidA, s.sessionidB, calldir,
			case when calltypeA='VOLTE' and (Disconnect_band like '%UMTS%' or Disconnect_band like '%GSM%') then 1 else 0 end as isSRVCC
		from lcc_core_Voice_Metrics_Table s
		where calldir like 'A->%'	

		union all
		select  
			s.sessionidA, s.sessionidB, calldir,
			case when calltypeA='VOLTE' and (Disconnect_band_Receiving_Party like '%UMTS%' or Disconnect_band_Receiving_Party like '%GSM%') then 1 else 0 end as isSRVCC
		from lcc_core_Voice_Metrics_Table s
		where calldir like '%->A'	
	) side
where m.sessionidA=side.sessionidA

---------------------------	side B:
update lcc_core_Voice_Metrics_Table
set call_SRVCC_inB = side.isSRVCC
from lcc_core_Voice_Metrics_Table m,
	(	select  
			s.sessionidA, s.sessionidB,
			case when calltypeB='VOLTE' and Disconnect_band like '%UMTS%' then 1 else 0 end as isSRVCC
		from lcc_core_Voice_Metrics_Table s
		where calldir like 'B->%'
		
		union all
		select  
			s.sessionidA, s.sessionidB,
			case when calltypeB='VOLTE' and Disconnect_band_Receiving_Party like '%UMTS%' then 1 else 0 end as isSRVCC
		from lcc_core_Voice_Metrics_Table s
		where calldir like '%->B'			
	) side
where m.sessionidB=side.sessionidB 


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Update HO info for each side (only sessionType= 'CALL' are considered)

---------------------------	side A:
update lcc_core_Voice_Metrics_Table
set 
	Handovers_A = side.Handovers_A,
	Handover_Failures_A = side.Handover_Failures_A,
	Handover_2G2G_Failures_A = side.Handover_2G2G_Failures_A,	Handover_2G3G_Failures_A = side.Handover_2G3G_Failures_A,	
	Handover_3G2G_Failures_A = side.Handover_3G2G_Failures_A,	Handover_3G3G_Failures_A = side.Handover_3G3G_Failures_A,
	Handover_4G3G_Failures_A = side.Handover_4G3G_Failures_A,	Handover_4G4G_Failures_A = side.Handover_4G4G_Failures_A,
	HOs_Duration_Avg_A = side.HOs_Duration_Avg_A
from lcc_core_Voice_Metrics_Table m,
	(	select v.sessionid as sessionidA,
			COUNT(Kpistatus) as Handovers_A,
			SUM(case when v.KPIStatus = 'Failed' then 1 else 0 end) as Handover_Failures_A,
			SUM(case when v.KPIId in (34050,34060,34070) and v.KPIStatus = 'Failed' then 1 else 0 end) as Handover_2G2G_Failures_A,
			SUM(case when v.KPIId in (35060,35061) and v.KPIStatus = 'Failed' then 1 else 0 end) as Handover_2G3G_Failures_A,
			SUM(case when v.KPIId in (35020,35030,35040,35041,35070,35071) and v.KPIStatus = 'Failed' then 1 else 0 end) as Handover_3G2G_Failures_A,
			SUM(case when v.KPIId in (35100,35101,35105,35106,35110,35111) and v.KPIStatus = 'Failed' then 1 else 0 end) as Handover_3G3G_Failures_A,
			SUM(case when v.KPIId in (38020,38030) and v.KPIStatus = 'Failed' then 1 else 0 end) as Handover_4G3G_Failures_A,
			SUM(case when v.KPIId = 38100 and v.KPIStatus = 'Failed' then 1 else 0 end) as Handover_4G4G_Failures_A,
			AVG(v.Duration) as HOs_Duration_Avg_A
	
		from vresultskpi v, Sessions s
		where v.SessionId=s.SessionId and v.kpiid in (	34050,34060,34070,						--	2g
														35060,35061,							--	2G/3G
														35020,35030,35040,35041,35070,35071,	--	3G/2G
														35100,35101,35105,35106,35110,35111,	--	3G
														38020,38030,							--	4G/3G
														38100									--	4G
														)
		group by v.SessionId	
	) side
where m.sessionidA=side.sessionidA


---------------------------	side B:
update lcc_core_Voice_Metrics_Table
set 
	Handovers_B = side.Handovers_B,
	Handover_Failures_B = side.Handover_Failures_B,
	Handover_2G2G_Failures_B = side.Handover_2G2G_Failures_B,	Handover_2G3G_Failures_B = side.Handover_2G3G_Failures_B,	
	Handover_3G2G_Failures_B = side.Handover_3G2G_Failures_B,	Handover_3G3G_Failures_B = side.Handover_3G3G_Failures_B,
	Handover_4G3G_Failures_B = side.Handover_4G3G_Failures_B,	Handover_4G4G_Failures_B = side.Handover_4G4G_Failures_B,
	HOs_Duration_Avg_B = side.HOs_Duration_Avg_B
from lcc_core_Voice_Metrics_Table m,
	(	select v.sessionid as sessionidB,
				COUNT(Kpistatus) as Handovers_B,
				SUM(case when v.KPIStatus = 'Failed' then 1 else 0 end) as Handover_Failures_B,
				SUM(case when v.KPIId in (34050,34060,34070) and v.KPIStatus = 'Failed' then 1 else 0 end) as Handover_2G2G_Failures_B,
				SUM(case when v.KPIId in (35060,35061) and v.KPIStatus = 'Failed' then 1 else 0 end) as Handover_2G3G_Failures_B,
				SUM(case when v.KPIId in (35020,35030,35040,35041,35070,35071) and v.KPIStatus = 'Failed' then 1 else 0 end) as Handover_3G2G_Failures_B,
				SUM(case when v.KPIId in (35100,35101,35105,35106,35110,35111) and v.KPIStatus = 'Failed' then 1 else 0 end) as Handover_3G3G_Failures_B,
				SUM(case when v.KPIId in (38020,38030) and v.KPIStatus = 'Failed' then 1 else 0 end) as Handover_4G3G_Failures_B,
				SUM(case when v.KPIId = 38100 and v.KPIStatus = 'Failed' then 1 else 0 end) as Handover_4G4G_Failures_B,
				AVG(v.Duration) as HOs_Duration_Avg_B

		from vresultskpi v, SessionsB s
		where v.SessionId=s.SessionId and v.kpiid in (	34050,34060,34070, --2g
														35060,35061, --2G/3G
														35020,35030,35040,35041,35070,35071, --3G/2G
														35100,35101,35105,35106,35110,35111, --3G
														38020,38030, -- 4G/3G
														38100 -- 4G
														)
		group by v.SessionId	
	) side
where m.sessionidB=side.sessionidB


--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Update Neighbors info for each side (only sessionType= 'CALL' are considered)

---------------------------	GSM - side A:
update lcc_core_Voice_Metrics_Table
set N1_BCCH_A=side.N1_BCCH,	N1_RxLev_A=side.N1_RxLev
from lcc_core_Voice_Metrics_Table m,
	(	select  m.SessionId as sessionidA,				m.N1_BCCH, 				m.N1_RxLev,				m.msgtime,				c.Disconnect_time,
				ROW_NUMBER() over (partition by m.sessionid order by m.sessionid asc, m.msgtime desc, m.N1_rxlev asc) as id
		from MsgGSMLayer1 m, lcc_core_Voice_Metrics_TimeStamp_Table c
		where m.N1_BCCH is not null
			and m.SessionId=c.SessionIdA				-- side A info
			and m.MsgTime <= c.Disconnect_time
			and m.MsgTime >=dateadd(s,-5,c.Disconnect_time)
			and calldir like 'A->%'
		group by m.SessionId, m.MsgTime, m.N1_BCCH, m.N1_RxLev, c.Disconnect_time

		union all
		select  m.SessionId as sessionidA,				m.N1_BCCH, 				m.N1_RxLev,				m.msgtime,				c.DisConnect_Receiving_Party_time,
				ROW_NUMBER() over (partition by m.sessionid order by m.sessionid asc, m.msgtime desc, m.N1_rxlev asc) as id
		from MsgGSMLayer1 m, lcc_core_Voice_Metrics_TimeStamp_Table c
		where m.N1_BCCH is not null
			and m.SessionId=c.SessionIdA				-- side A info
			and m.MsgTime <= c.DisConnect_Receiving_Party_time
			and m.MsgTime >=dateadd(s,-5,c.DisConnect_Receiving_Party_time)
			and calldir like '%->A'
		group by m.SessionId, m.MsgTime, m.N1_BCCH, m.N1_RxLev, c.DisConnect_Receiving_Party_time
	) side
where m.sessionidA=side.sessionidA and side.id=1

---------------------------	GSM - side B:
update lcc_core_Voice_Metrics_Table
set N1_BCCH_B=side.N1_BCCH,	N1_RxLev_B=side.N1_RxLev
from lcc_core_Voice_Metrics_Table m,
	(	select  m.SessionId as sessionidB,				m.N1_BCCH, 				m.N1_RxLev,				m.msgtime,				c.Disconnect_time,
				ROW_NUMBER() over (partition by m.sessionid order by m.sessionid asc, m.msgtime desc, m.N1_rxlev asc) as id
		from MsgGSMLayer1 m, lcc_core_Voice_Metrics_TimeStamp_Table c
		where m.N1_BCCH is not null
			and m.SessionId=c.SessionIdB				-- side B info
			and m.MsgTime <= c.Disconnect_time
			and m.MsgTime >=dateadd(s,-5,c.Disconnect_time)
			and calldir like 'B->%'
		group by m.SessionId, m.MsgTime, m.N1_BCCH, m.N1_RxLev, c.Disconnect_time

		union all
		select  m.SessionId as sessionidB,				m.N1_BCCH, 				m.N1_RxLev,				m.msgtime,				c.DisConnect_Receiving_Party_time,
				ROW_NUMBER() over (partition by m.sessionid order by m.sessionid asc, m.msgtime desc, m.N1_rxlev asc) as id
		from MsgGSMLayer1 m, lcc_core_Voice_Metrics_TimeStamp_Table c
		where m.N1_BCCH is not null
			and m.SessionId=c.SessionIdB				-- side B info
			and m.MsgTime <= c.DisConnect_Receiving_Party_time
			and m.MsgTime >=dateadd(s,-5,c.DisConnect_Receiving_Party_time)
			and calldir like '%->B'
		group by m.SessionId, m.MsgTime, m.N1_BCCH, m.N1_RxLev, c.DisConnect_Receiving_Party_time
	) side
where m.sessionidB=side.sessionidB and side.id=1

---------------------------	WCDMA - side A:
update lcc_core_Voice_Metrics_Table
set N1_PSC_A=side.N1_PSC,	N1_RSCP_A=side.N1_RSCP
from lcc_core_Voice_Metrics_Table m,
	(
		select  r2.SessionId as SessionIdA,		r2.PSC as N1_PSC,		r2.RSCP as N1_RSCP,		r2.msgtime,		r2.Disconnect_time,
				ROW_NUMBER() over (partition by r2.sessionid order by r2.sessionid asc, r2.msgtime desc, r2.RSCP asc) as id
		from (
				select	r1.sessionid, 			r.PSC, 					r.RSCP, 				r1.MsgTime, 	c.Disconnect_time 
				from lcc_core_Voice_Metrics_TimeStamp_Table c, WCDMAMeasReportInfo r1
						left outer join	(select * from WCDMAMeasReport ) r  on r1.MeasReportId=r.MeasReportId		
				where SetValue in ('N', 'M')						-- Monitored set
						and r1.SessionId=c.SessionIdA				-- side A info
						and r1.MsgTime <= c.Disconnect_time	-- We get info before end/block/drop of the call )
						and calldir like 'A->%'
				group by r1.SessionId, r1.MsgTime, r.PSC, r.RSCP, c.Disconnect_time

				union all
				select	r1.sessionid, 			r.PSC, 					r.RSCP, 				r1.MsgTime, 	c.DisConnect_Receiving_Party_time 
				from lcc_core_Voice_Metrics_TimeStamp_Table c, WCDMAMeasReportInfo r1
						left outer join	(select * from WCDMAMeasReport ) r  on r1.MeasReportId=r.MeasReportId		
				where SetValue in ('N', 'M')						-- Monitored set
						and r1.SessionId=c.SessionIdA				-- side A info
						and r1.MsgTime <= c.DisConnect_Receiving_Party_time	-- We get info before end/block/drop of the call )
						and calldir like '%->A'
				group by r1.SessionId, r1.MsgTime, r.PSC, r.RSCP, c.DisConnect_Receiving_Party_time
		) r2
	) side
where m.sessionidA=side.sessionidA and side.id=1

---------------------------	WCDMA - side B:
update lcc_core_Voice_Metrics_Table
set N1_PSC_B=side.N1_PSC,	N1_RSCP_B=side.N1_RSCP
from lcc_core_Voice_Metrics_Table m,
	(
		select  r2.SessionId as SessionIdB,		r2.PSC as N1_PSC,		r2.RSCP as N1_RSCP,		r2.msgtime,		r2.Disconnect_time,
				ROW_NUMBER() over (partition by r2.sessionid order by r2.sessionid asc, r2.msgtime desc, r2.RSCP asc) as id

		from (
				select	r1.sessionid, 			r.PSC, 					r.RSCP, 				r1.MsgTime, 	c.Disconnect_time 
				from lcc_core_Voice_Metrics_TimeStamp_Table c, WCDMAMeasReportInfo r1
						left outer join	(select * from WCDMAMeasReport ) r  on r1.MeasReportId=r.MeasReportId	
				where SetValue in ('N', 'M')						-- Monitored set
						and r1.SessionId=c.SessionIdB				-- side A info
						and r1.MsgTime <= c.Disconnect_time	-- We get info before end/block/drop of the call )
						and calldir like 'B->%'
				group by r1.SessionId, r1.MsgTime, r.PSC, r.RSCP, c.Disconnect_time

				union all
				select	r1.sessionid, 			r.PSC, 					r.RSCP, 				r1.MsgTime, 	c.DisConnect_Receiving_Party_time 
				from lcc_core_Voice_Metrics_TimeStamp_Table c, WCDMAMeasReportInfo r1
						left outer join	(select * from WCDMAMeasReport ) r  on r1.MeasReportId=r.MeasReportId	
				where SetValue in ('N', 'M')						-- Monitored set
						and r1.SessionId=c.SessionIdB				-- side A info
						and r1.MsgTime <= c.DisConnect_Receiving_Party_time	-- We get info before end/block/drop of the call )
						and calldir like '%->B'
				group by r1.SessionId, r1.MsgTime, r.PSC, r.RSCP, c.DisConnect_Receiving_Party_time
		) r2
	) side
where m.sessionidB=side.sessionidB and side.id=1

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Update lcc_core_Voice_Metrics_Table - CALLED/CALLING Party:
update lcc_core_Voice_Metrics_Table
set 
	callingParty_type=callTypeA,		calledParty_type=callTypeB,	
	callingParty_CSFB=call_CSFB_inA,	calledParty_CSFB=call_CSFB_inB,
	callingParty_SRVCC=call_SRVCC_inA,	calledParty_SRVCC=call_SRVCC_inB,
	callingParty_SRVCC_Failure=0,		calledParty_SRVCC_Failure=0
--select * 
from lcc_core_Voice_Metrics_Table
where callDir like 'A->%'


update lcc_core_Voice_Metrics_Table
set 
	callingParty_type=callTypeB,		calledParty_type=callTypeA,	
	callingParty_CSFB=call_CSFB_inB,	calledParty_CSFB=call_CSFB_inA,
	callingParty_SRVCC=call_SRVCC_inB,	calledParty_SRVCC=call_SRVCC_inA,
	callingParty_SRVCC_Failure=0,		calledParty_SRVCC_Failure=0
--select *  
from lcc_core_Voice_Metrics_Table
where callDir like '%->A'



--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Update lcc_core_Voice_Metrics_Table - SRVCC Destination Calling Party:
update lcc_core_Voice_Metrics_Table
set callingParty_SRVCC_Failure=case when callingParty_SRVCC=1 then SRVCC_Failures_A end,
	callingParty_SRVCC_Dest=case when callingParty_SRVCC=1 then SRVCC_Dest_A end
	
	
from lcc_core_Voice_Metrics_Table m,
	(	select v.sessionid as sessionidA,
			case when v.KPIStatus = 'Failed' then 1 else 0 end as SRVCC_Failures_A,
			--case when v.value4 = 'HandoverToUTRANComplete' then 'UMTS' else 'GSM' end as SRVCC_Dest_A
			n.technology as SRVCC_Dest_A
	
		from vresultskpi v, Sessions s, Networkinfo n, networkidrelation nid
		where v.SessionId=s.SessionId and v.kpiid in (	38040,					--To UTRAN
														38050					--To GSM
														)
			  and value5 in ('SRVCC','PS Handover')
			  and nid.sessionid=v.sessionid
			  and nid.networkid=N.networkid
			  and n.msgtime=v.endtime
		group by v.SessionId,n.technology,v.KPIStatus
	) side
where m.sessionidA=side.sessionidA

-- Update lcc_core_Voice_Metrics_Table - SRVCC Destination Calling Party:
update lcc_core_Voice_Metrics_Table
set calledParty_SRVCC_Failure=case when calledParty_SRVCC=1 then SRVCC_Failures_B end,
	calledParty_SRVCC_Dest=case when calledParty_SRVCC=1 then SRVCC_Dest_B end
	
	
from lcc_core_Voice_Metrics_Table m,
	(	select v.sessionid as sessionidB,
			case when v.KPIStatus = 'Failed' then 1 else 0 end as SRVCC_Failures_B,
			--case when v.value4 = 'HandoverToUTRANComplete' then 'UMTS' else 'GSM' end as SRVCC_Dest_B
			n.technology as SRVCC_Dest_B
	
		from vresultskpi v, SessionsB s, Networkinfo n, networkidrelation nid
		where v.SessionId=s.SessionId and v.kpiid in (	38040,					--To UTRAN
														38050					--To GSM
														)
			  and v.value5 in ('SRVCC','PS Handover')
			  and nid.sessionid=v.sessionid
			  and nid.networkid=N.networkid
			  and n.msgtime=v.endtime
		group by v.SessionId,n.technology,v.KPIStatus
	) side
where m.sessionidB=side.sessionidB


------------------------------------------------ select * from lcc_core_Voice_Metrics_Table