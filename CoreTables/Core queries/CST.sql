USE [BM_Analytics]
GO

/****** Object:  View [dbo].[vlcc_core_Voice_CST_CallingParty]    Script Date: 27/03/2018 11:06:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [dbo].[vlcc_core_Voice_CST_CallingParty] AS
-------------------------------------------------------------------------------

--	[Direction]  = callDir  ----> A->B			&	B->A		(M2M and M2F)
--  [TypeOfTest] = callType ----> M->M (M2M)	&	M->L/M->?	(M2F)

--	lcc_core_Voice_CST_CallingParty_Table_Metrics	-> Calling Party Info
--  lcc_core_Voice_CST_Table_KPIs_SQ				-> Both side Info

--	Only Completed Calls and Dropped calls are considered

--	La subquery presenta los calsculos del CST para llamadas en 4G (only) o en VOLTE (4G/VOLTE con nomenclatura de VOLTE)
--	La query principal calculo campos de control, para saber cuando los intervalos estarían completos y OK
-------------------------------------------------------------------------------

select cst.*, 
    case when isnull(cst2alerting,0)>0 then 1 else 0 end as cst2alerting_samples,
    case when isnull(cst2connect,0)>0 then 1 else 0 end as cst2connect_samples,
    floor([cst2alerting]/1000.0)*1000.0 as cst2alerting_hist,
    floor([cst2connect]/1000.0)*1000.0  as cst2connect_hist,

	-----------
	-- Control de intervalos:
	-----------
	--cst2connect - 
	--([Dial->LTE_RRCConnectionRequest]+[LTE_RRCConnectionRequest->ExtendedServiceRequest]+[ExtendedServiceRequest->LTE_RRCConnectionRelease]+
	--[LTE_RRCConnectionRelease->UMTS_RRCConnectionRequest]+[UMTS_RRCConnectionRequest->ServiceRequest]+[ServiceRequest->Setup]+
	--[Setup->CallProceeding]+[CallProceeding->Alerting_ReceivingParty]+[Connect_ReceivingParty->Connect]) as diff_cst2connect_4G,

	-----------
	case when (
		[Dial>LTE_RRCConnectionRequest_time]+[LTE_RRCConnectionRequest_time>LTE_ExtendedServiceRequest_time]+
		[LTE_ExtendedServiceRequest_time>LTE_ExtendedServiceRequest_time]+[LTE_RRCConnectionRelease_time>UMTS_RRCConnectionRequest_time]+
		[UMTS_RRCConnectionRequest_time>CMServiceRequest_time]+[CMServiceRequest_time>Setup_time]+[Setup_time>CallProceeding_time]+
		[CallProceeding_time>Alerting_Receiving_Party_time]+[Alerting_Receiving_Party_time>Connect_Receiving_Party_time]+
		[Connect_Receiving_Party_time>Connect_time])>0 then 0 
	else 1 end as [AllMsgCS_ok],

	-------------
	--cst2connect - 
	--([Dial->VoLTE_Invite_Req]+[VoLTE_Invite_Req->VoLTE_Trying]+[VoLTE_Trying->VoLTE_SesProgress]+
	--[VoLTE_SesProgress->VoLTE_Ringing_ReceivingParty]+
	--[VoLTE_InviteOK_ReceivingParty->VoLTE_InviteOK]) as diff_cst2connect_VOLTE,

	-----------
	case when (
		[VoLTE_Invite_req_time>VoLTE_Trying_time]+[VoLTE_Trying_time>VoLTE_SesProgress_time]+
		[VoLTE_SesProgress_time>VoLTE_Ringing_time_receiving_Party]+[VoLTE_Ringing_time_receiving_Party>VoLTE_InviteOK_time_receiving_Party]+
		[VoLTE_InviteOK_time_receiving_Party>VoLTE_InviteOK_time])>0 then 0 
	else 1 end as AllMsgVOLTE_ok

from (

	select
		m.key_BST,
		1 as samplesKPI_SQ_CST, 

		------------------------------
		--	CST - From DIAL to ALERTING:
		case when [Direction] like 'A->%' then  /**** MOC ****/
					case
						when (m.[TypeOfTest]<>'M->M') then	-- M2F:		M->L or M->?
							case 
								when v.calltypeA='CS'		then k_Aside.[kpi10100_Duration]	-- 10100 - Accessibility - Voice(CS) - Telephony
								when v.calltypeA='VOLTE'	then k_Aside.[kpi11000_Duration]	-- 11000 - Accessibility - SIP - Post Dial Delay (Active State)
							end
						else								-- M2M:		Metrics Table  - CallingParty side
							case 
								when v.calltypeA='CS'		then datediff(ms, me.[Dial], me.[Alerting_time])
								when v.calltypeA='VOLTE'	then datediff(ms, me.[Dial], me.[VoLTE_Ringing_time])
							end
					end
			 when [Direction] like '%->A' then  /**** MTC ****/ 
					case
						when (m.[TypeOfTest]<>'M->M') then	-- M2F:		M->L or M->?
							case 
								when v.calltypeB='CS'		then k_Bside.[kpi10100_Duration]	-- 10100 - Accessibility - Voice(CS) - Telephony
								when v.calltypeB='VOLTE'	then k_Bside.[kpi11000_Duration]	-- 11000 - Accessibility - SIP - Post Dial Delay (Active State)
							end
						else								-- M2M:		Metrics Table  - CallingParty side
							case 
								when v.calltypeB='CS'		then datediff(ms, me.[Dial], me.[Alerting_time])
								when v.calltypeB='VOLTE'	then datediff(ms, me.[Dial], me.[VoLTE_Ringing_time])
							end
					end
		end as cst2alerting,

		 --Tech Info - Calling Party:
		case when [Direction] like 'A->%' then  /**** MOC ****/
					case
						when (m.[TypeOfTest]<>'M->M') then	-- M2F:		M->L or M->?
							case 
								when v.calltypeA='CS'		then v.[Alerting_freq]	
								when v.calltypeA='VOLTE'	then [VOLTE_Ringing_freq]	
							end
						else								-- M2M:		Metrics Table  - CallingParty side
							case 
								when v.calltypeA='CS'		then v.[Alerting_freq]
								when v.calltypeA='VOLTE'	then [VOLTE_Ringing_freq]
							end
					end
			 when [Direction] like '%->A' then  /**** MTC ****/ 
					case
						when (m.[TypeOfTest]<>'M->M') then	-- M2F:		M->L or M->?
							case 
								when v.calltypeB='CS'		then v.[Alerting_freq]	-- 10100 - Accessibility - Voice(CS) - Telephony
								when v.calltypeB='VOLTE'	then [VOLTE_Ringing_freq]	-- 11000 - Accessibility - SIP - Post Dial Delay (Active State)
							end
						else								-- M2M:		Metrics Table  - CallingParty side
							case 
								when v.calltypeB='CS'		then v.[Alerting_freq]
								when v.calltypeB='VOLTE'	then [VOLTE_Ringing_freq]
							end
					end
		end as [Alerting_freq],

		case when [Direction] like 'A->%' then  /**** MOC ****/
					case
						when (m.[TypeOfTest]<>'M->M') then	-- M2F:		M->L or M->?
							case 
								when v.calltypeA='CS'		then [Alerting_band]	
								when v.calltypeA='VOLTE'	then [VOLTE_Ringing_band]	
							end
						else								-- M2M:		Metrics Table  - CallingParty side
							case 
								when v.calltypeA='CS'		then [Alerting_band]
								when v.calltypeA='VOLTE'	then [VOLTE_Ringing_band]
							end
					end
			 when [Direction] like '%->A' then  /**** MTC ****/ 
					case
						when (m.[TypeOfTest]<>'M->M') then	-- M2F:		M->L or M->?
							case 
								when v.calltypeB='CS'		then [Alerting_band]	
								when v.calltypeB='VOLTE'	then [VOLTE_Ringing_band]	
							end
						else								-- M2M:		Metrics Table  - CallingParty side
							case 
								when v.calltypeB='CS'		then [Alerting_band]
								when v.calltypeB='VOLTE'	then [VOLTE_Ringing_band]
							end
					end
		end as [Alerting_band],

		
		------------------------------
		--	CST - From DIAL to CONNECT:
		case when [Direction] like 'A->%' then  /**** MOC ****/
					case
						when (m.[TypeOfTest]<>'M->M') then	-- M2F:		M->L or M->?
							case 
								when v.calltypeA='CS'		then k_Aside.[kpi10100_Duration]	-- 10100 - Accessibility - Voice(CS) - Telephony
								when v.calltypeA='VOLTE'	then k_Aside.[kpi11000_Duration]	-- 11000 - Accessibility - SIP - Post Dial Delay (Active State)
							end
						else								-- M2M:		Metrics Table  - CallingParty side
							case 
								when v.calltypeA='CS'		and v.calltypeB='CS'	then datediff(ms, me.[Dial], me.[Connect_time])			- datediff(ms, [Alerting_Receiving_Party_time],		 [Connect_Receiving_Party_time])
								when v.calltypeA='VOLTE'	and v.calltypeB='VOLTE'	then datediff(ms, me.[Dial], me.[VoLTE_InviteOK_time])	- datediff(ms, [VoLTE_Ringing_time_receiving_Party], [VoLTE_InviteOK_time_receiving_Party])
								when v.calltypeA='VOLTE'	and v.calltypeB='CS'	then datediff(ms, me.[Dial], me.[VoLTE_InviteOK_time])	- datediff(ms, [Alerting_Receiving_Party_time],		 [Connect_Receiving_Party_time])
								when v.calltypeA='CS'		and v.calltypeB='VOLTE'	then datediff(ms, me.[Dial], me.[Connect_time])			- datediff(ms, [VoLTE_Ringing_time_receiving_Party], [VoLTE_InviteOK_time_receiving_Party])
							end
					end
			 when [Direction] like '%->A' then  /**** MTC ****/ 
					case
						when (m.[TypeOfTest]<>'M->M') then	-- M2F:		M->L or M->?
							case 
								when v.calltypeB='CS'		then k_Bside.[kpi10100_Duration]	-- 10100 - Accessibility - Voice(CS) - Telephony
								when v.calltypeB='VOLTE'	then k_Bside.[kpi11000_Duration]	-- 11000 - Accessibility - SIP - Post Dial Delay (Active State)
							end
						else								-- M2M:		Metrics Table  - CallingParty side
							case 
								when v.calltypeA='CS'		and v.calltypeB='CS'	then datediff(ms, me.[Dial], me.[Connect_time])			- datediff(ms, [Alerting_Receiving_Party_time],		 [Connect_Receiving_Party_time])
								when v.calltypeA='VOLTE'	and v.calltypeB='VOLTE'	then datediff(ms, me.[Dial], me.[VoLTE_InviteOK_time])	- datediff(ms, [VoLTE_Ringing_time_receiving_Party], [VoLTE_InviteOK_time_receiving_Party])
								when v.calltypeA='VOLTE'	and v.calltypeB='CS'	then datediff(ms, me.[Dial], me.[Connect_time])			- datediff(ms, [VoLTE_Ringing_time_receiving_Party], [VoLTE_InviteOK_time_receiving_Party])
								when v.calltypeA='CS'		and v.calltypeB='VOLTE'	then datediff(ms, me.[Dial], me.[VoLTE_InviteOK_time])	- datediff(ms, [Alerting_Receiving_Party_time],		 [Connect_Receiving_Party_time])
												
							end
					end
		end as cst2connect,

		-- Tech Info - Calling Party:
		case when [Direction] like 'A->%' then  /**** MOC ****/
					case
						when (m.[TypeOfTest]<>'M->M') then	-- M2F:		M->L or M->?
							case 
								when v.calltypeA='CS'		then v.[Connect_freq]	
								when v.calltypeA='VOLTE'	then [VOLTE_InviteOK_freq]	
							end
						else								-- M2M:		Metrics Table  - CallingParty side
							case 
								when v.calltypeA='CS'		and v.calltypeB='CS'	then v.[Connect_freq]	
								when v.calltypeA='VOLTE'	and v.calltypeB='VOLTE'	then [VOLTE_InviteOK_freq]
								when v.calltypeA='VOLTE'	and v.calltypeB='CS'	then [VOLTE_InviteOK_freq]
								when v.calltypeA='CS'		and v.calltypeB='VOLTE'	then v.[Connect_freq]	
							end
					end
			 when [Direction] like '%->A' then  /**** MTC ****/ 
					case
						when (m.[TypeOfTest]<>'M->M') then	-- M2F:		M->L or M->?
							case 
								when v.calltypeB='CS'		then v.[Connect_freq]	-- 10100 - Accessibility - Voice(CS) - Telephony
								when v.calltypeB='VOLTE'	then [VOLTE_InviteOK_freq]	-- 11000 - Accessibility - SIP - Post Dial Delay (Active State)
							end
						else								-- M2M:		Metrics Table  - CallingParty side
							case 
								when v.calltypeA='CS'		and v.calltypeB='CS'	then v.[Connect_freq]	
								when v.calltypeA='VOLTE'	and v.calltypeB='VOLTE'	then [VOLTE_InviteOK_freq]
								when v.calltypeA='VOLTE'	and v.calltypeB='CS'	then v.[Connect_freq]
								when v.calltypeA='CS'		and v.calltypeB='VOLTE'	then [VOLTE_InviteOK_freq]	
							end
					end
		end as [Connect_freq],

		case when [Direction] like 'A->%' then  /**** MOC ****/
					case
						when (m.[TypeOfTest]<>'M->M') then	-- M2F:		M->L or M->?
							case 
								when v.calltypeA='CS'		then [Connect_band]	
								when v.calltypeA='VOLTE'	then [VOLTE_InviteOK_band]	
							end
						else								-- M2M:		Metrics Table  - CallingParty side
							case 
								when v.calltypeA='CS'		and v.calltypeB='CS'	then [Connect_band]	
								when v.calltypeA='VOLTE'	and v.calltypeB='VOLTE'	then [VOLTE_InviteOK_band]
								when v.calltypeA='VOLTE'	and v.calltypeB='CS'	then [VOLTE_InviteOK_band]
								when v.calltypeA='CS'		and v.calltypeB='VOLTE'	then [Connect_band]	
							end
					end
			 when [Direction] like '%->A' then  /**** MTC ****/ 
					case
						when (m.[TypeOfTest]<>'M->M') then	-- M2F:		M->L or M->?
							case 
								when v.calltypeB='CS'		then [Connect_band]	-- 10100 - Accessibility - Voice(CS) - Telephony
								when v.calltypeB='VOLTE'	then [VOLTE_InviteOK_band]	-- 11000 - Accessibility - SIP - Post Dial Delay (Active State)
							end
						else								-- M2M:		Metrics Table  - CallingParty side
							case 
								when v.calltypeA='CS'		and v.calltypeB='CS'	then [Connect_band]	
								when v.calltypeA='VOLTE'	and v.calltypeB='VOLTE'	then [VOLTE_InviteOK_band]
								when v.calltypeA='VOLTE'	and v.calltypeB='CS'	then [Connect_band]
								when v.calltypeA='CS'		and v.calltypeB='VOLTE'	then [VOLTE_InviteOK_band]	
							end
					end
		end as [Connect_band],

		-- **************************************************************************************************************
		-- NOTA: 
		--	* En la creacion de la tabal Metrics Timestamp, se tiene en cuenta que todos los mensajes sean posterior al DIAL
		--	* En el caso de que no se haya detectado un mensaje, no se calcula el intevalo correspondiente
		--			- por lo que el valor final (suma de intervalos) puede discrepar del valos del CST total
		--	
		--	* Sería necesario calcular un campo extra para tener en cuenta esa diferencia de tiempos que sera desconocida
		-- **************************************************************************************************************
	
		----------------
		case when callingParty_type='CS' then isnull(datediff(ms, [Dial], [Connect_time]),0)
		else 0 end as [Dial->Connect],

		case when callingParty_type='CS' then isnull(datediff(ms, [Dial], [ConnectAck_time]),0)
		else 0 end as [Dial->ConnectAck_time],

		case
			when callingParty_type='CS'		then isnull(datediff(ms, [Dial], [Connect_time]) ,0)
			when callingParty_type='VOLTE'	then isnull(datediff(ms, [Dial], [VoLTE_InviteOK_time]),0)
		else 0 end as [Dial->VoLTE_InviteOK],
	
		----------------
		-- Diff Times - callingParty_type='CS':	4G
		----------------	
		case when callingParty_type='CS' then isnull(datediff(ms, [Dial], [LTE_RRCConnectionRequest_time]),0)
		else 0 end as [Dial->LTE_RRCConnectionRequest],
	
		case when callingParty_type='CS' and datediff(ms, [Dial], [LTE_ExtendedServiceRequest_time]) >= isnull(datediff(ms, [Dial], [LTE_RRCConnectionRequest_time]),0) 
			then isnull(datediff(ms, [Dial], [LTE_ExtendedServiceRequest_time]) - isnull(datediff(ms, [Dial], [LTE_RRCConnectionRequest_time]),0) ,0)
		else 0 end as [LTE_RRCConnectionRequest->ExtendedServiceRequest],

		case when callingParty_type='CS' and datediff(ms, [Dial], [LTE_RRCConnectionRelease_time])>=datediff(ms, [Dial], [LTE_ExtendedServiceRequest_time])
			then isnull(datediff(ms, [Dial], [LTE_RRCConnectionRelease_time])-datediff(ms, [Dial], [LTE_ExtendedServiceRequest_time]), 0)	
		else 0 end	as [ExtendedServiceRequest->LTE_RRCConnectionRelease],

		case when callingParty_type='CS' and datediff(ms, [Dial], [UMTS_RRCConnectionRequest_time])>=datediff(ms, [Dial], [LTE_RRCConnectionRelease_time])
			then isnull(datediff(ms, [Dial], [UMTS_RRCConnectionRequest_time])-datediff(ms, [Dial], [LTE_RRCConnectionRelease_time]), 0)	
		else 0 end	as [LTE_RRCConnectionRelease->UMTS_RRCConnectionRequest],

		case when callingParty_type='CS' and datediff(ms, [Dial], [CMServiceRequest_time])>=datediff(ms, [Dial], [UMTS_RRCConnectionRequest_time])
			then isnull(datediff(ms, [Dial], [CMServiceRequest_time])-datediff(ms, [Dial], [UMTS_RRCConnectionRequest_time]), 0)
		else 0 end	as [UMTS_RRCConnectionRequest->ServiceRequest],

		case when callingParty_type='CS' and datediff(ms, [Dial], [Setup_time])>=datediff(ms, [Dial], [CMServiceRequest_time])
			then isnull(datediff(ms, [Dial], [Setup_time])-datediff(ms, [Dial], [CMServiceRequest_time]), 0)
		else 0 end	as [ServiceRequest->Setup],

		case when callingParty_type='CS' and datediff(ms, [Dial], [CallProceeding_time])>=datediff(ms, [Dial], [Setup_time])
			then isnull(datediff(ms, [Dial], [CallProceeding_time])-datediff(ms, [Dial], [Setup_time]), 0)	
		else 0 end	as [Setup->CallProceeding],

		case 
			when callingParty_type='CS' and calledParty_type='CS' and datediff(ms, [Dial], [Alerting_Receiving_Party_time])>=datediff(ms, [Dial], [CallProceeding_time])
				then isnull(datediff(ms, [Dial], [Alerting_Receiving_Party_time])-datediff(ms, [Dial], [CallProceeding_time]), 0)	
		else 0 end as [CallProceeding->Alerting_ReceivingParty], 				-- para la pestaña de 4G


		----------------  ANSWERING TIME
		case when calledParty_type='CS' and datediff(ms, [Dial], [Connect_Receiving_Party_time])>=datediff(ms, [Dial], Alerting_Receiving_Party_time)
			then isnull(datediff(ms, [Dial], [Connect_Receiving_Party_time])-datediff(ms, [Dial], Alerting_Receiving_Party_time),0)
		else 0 end as [Alerting_ReceivingParty->Connect_ReceivingParty],


		---------------- CST till CONNECT
		case 
			when callingParty_type='CS'		and calledParty_type='CS' and datediff(ms, [Dial], [Connect_time])>=datediff(ms, [Dial], Connect_Receiving_Party_time)
				then isnull(datediff(ms, [Dial], [Connect_time])-datediff(ms, [Dial], Connect_Receiving_Party_time), 0)
		else 0 end as [Connect_ReceivingParty->Connect],
			

		---------------- CST till ALERTING
		case 
			when callingParty_type='CS'		and calledParty_type='CS'	and	datediff(ms, [Dial], [Alerting_time])>=datediff(ms, [Dial], [Alerting_Receiving_Party_time])
				then isnull(datediff(ms, [Dial], [Alerting_time])-datediff(ms, [Dial], [Alerting_Receiving_Party_time]), 0)
		else 0 end as [Alerting_ReceivingParty->Alerting],						-- para la pestaña de 4G


		-- ***********************************************************************************************************************
		-- Diff Times -callingParty_type='VOLTE'	- VOLTE
		----------------				
		case when callingParty_type='VOLTE'	then isnull(datediff(ms, [Dial], [VoLTE_Invite_req_time]),0)
		else 0 end as [Dial->VoLTE_Invite_Req],

		----------------			
		case when callingParty_type='VOLTE'	and datediff(ms, [Dial], [VoLTE_Trying_time])>= datediff(ms, [Dial], [VoLTE_Invite_req_time])
			then isnull(datediff(ms, [Dial], [VoLTE_Trying_time])-datediff(ms, [Dial], [VoLTE_Invite_req_time]), 0)
		else 0 end as [VoLTE_Invite_Req->VoLTE_Trying],

		case when callingParty_type='VOLTE'	and datediff(ms, [Dial], [VoLTE_SesProgress_time])>=datediff(ms, [Dial], [VoLTE_Trying_time])
			then isnull(datediff(ms, [Dial], [VoLTE_SesProgress_time])-datediff(ms, [Dial], [VoLTE_Trying_time]), 0)	
		else 0 end as [VoLTE_Trying->VoLTE_SesProgress],

		---------------
		-- Mixed CALLS:
		-- ***********************************************************************************************************************
		-- Diff Times - Called Party/calledParty_type = 'CS'/'VOLTE'		- 4G o VOLTE
		case 
			when callingParty_type='CS'		and calledParty_type='CS'	and datediff(ms, [Dial], [Alerting_Receiving_Party_time])>=datediff(ms, [Dial], [CallProceeding_time])
				then isnull(datediff(ms, [Dial], [Alerting_Receiving_Party_time])-datediff(ms, [Dial], [CallProceeding_time]), 0)	

			when callingParty_type='CS'		and calledParty_type='VOLTE' and datediff(ms, [Dial], [VoLTE_Ringing_time_receiving_Party])>=datediff(ms, [Dial], [CallProceeding_time])
				then isnull(datediff(ms, [Dial], [VoLTE_Ringing_time_receiving_Party])-datediff(ms, [Dial], [CallProceeding_time]), 0)

			when callingParty_type='VOLTE'	and calledParty_type='CS'	and datediff(ms, [Dial], [Alerting_Receiving_Party_time])>=datediff(ms, [Dial], [VoLTE_SesProgress_time])
				then isnull(datediff(ms, [Dial], [Alerting_Receiving_Party_time])-datediff(ms, [Dial], [VoLTE_SesProgress_time]), 0)
				
			when callingParty_type='VOLTE'	and calledParty_type='VOLTE' and datediff(ms, [Dial], [VoLTE_Ringing_time_receiving_Party])>=datediff(ms, [Dial], [VoLTE_SesProgress_time])	
				then isnull(datediff(ms, [Dial], [VoLTE_Ringing_time_receiving_Party])-datediff(ms, [Dial], [VoLTE_SesProgress_time]), 0)	
		else 0 end as [VoLTE_SesProgress->VoLTE_Ringing_ReceivingParty],		-- para la pestaña de VOLTE - tendra la mezcla

		----------------  ANSWERING TIME	
		case 
			when calledParty_type='CS' and	datediff(ms, [Dial], [Connect_Receiving_Party_time])>=datediff(ms, [Dial], Alerting_Receiving_Party_time)
				then isnull(datediff(ms, [Dial], [Connect_Receiving_Party_time])-datediff(ms, [Dial], Alerting_Receiving_Party_time), 0)	

			when calledParty_type='VOLTE' and datediff(ms, [Dial], [VoLTE_InviteOK_time_receiving_Party])>=datediff(ms, [Dial], [VoLTE_Ringing_time_receiving_Party])
				then isnull(datediff(ms, [Dial], [VoLTE_InviteOK_time_receiving_Party])-datediff(ms, [Dial], [VoLTE_Ringing_time_receiving_Party]), 0)	

		else 0 end as [VoLTE_Ringing_ReceivingParty->VoLTE_InviteOK_ReceivingParty],	
	
		---------------- CST till CONNECT/INVITE_OK:
		case 
			when callingParty_type='CS'		and calledParty_type='CS'	and datediff(ms, [Dial], [Connect_time])>=datediff(ms, [Dial], Connect_Receiving_Party_time)
				then isnull(datediff(ms, [Dial], [Connect_time])-datediff(ms, [Dial], Connect_Receiving_Party_time), 0)

			when callingParty_type='CS'		and calledParty_type='VOLTE' and datediff(ms, [Dial], [Connect_time])>=datediff(ms, [Dial], [VoLTE_InviteOK_time_receiving_Party])
				then isnull(datediff(ms, [Dial], [Connect_time])-datediff(ms, [Dial], [VoLTE_InviteOK_time_receiving_Party]), 0)

			when callingParty_type='VOLTE'	and calledParty_type='CS'	and datediff(ms, [Dial], [VoLTE_InviteOK_time])>=datediff(ms, [Dial], Connect_Receiving_Party_time)
				then isnull(datediff(ms, [Dial], [VoLTE_InviteOK_time])-datediff(ms, [Dial], Connect_Receiving_Party_time), 0)

			when callingParty_type='VOLTE'	and calledParty_type='VOLTE' and datediff(ms, [Dial], [VoLTE_InviteOK_time])>=datediff(ms, [Dial], [VoLTE_InviteOK_time_receiving_Party])
				then isnull(datediff(ms, [Dial], [VoLTE_InviteOK_time])-datediff(ms, [Dial], [VoLTE_InviteOK_time_receiving_Party]), 0)

		else 0 end as [VoLTE_InviteOK_ReceivingParty->VoLTE_InviteOK],
		
		---------------- CST till ALERTING/RINGING:	
		case 
			when callingParty_type='CS'		and calledParty_type='CS'	and datediff(ms, [Dial], [Alerting_time])>=datediff(ms, [Dial], [Alerting_Receiving_Party_time])
				then isnull(datediff(ms, [Dial], [Alerting_time])-datediff(ms, [Dial], [Alerting_Receiving_Party_time]), 0)

			when callingParty_type='CS'		and calledParty_type='VOLTE' and datediff(ms, [Dial], [Alerting_time])>=datediff(ms, [Dial], [VoLTE_Ringing_time_receiving_Party])
				then isnull(datediff(ms, [Dial], [Alerting_time])-datediff(ms, [Dial], [VoLTE_Ringing_time_receiving_Party]), 0)

			when callingParty_type='VOLTE'	and calledParty_type='CS'	and datediff(ms, [Dial], [VoLTE_Ringing_time])>=datediff(ms, [Dial], [Alerting_Receiving_Party_time])
				then isnull(datediff(ms, [Dial], [VoLTE_Ringing_time])-datediff(ms, [Dial], [Alerting_Receiving_Party_time]), 0)

			when callingParty_type='VOLTE'	and calledParty_type='VOLTE' and datediff(ms, [Dial], [VoLTE_Ringing_time])>=datediff(ms, [Dial], [VoLTE_Ringing_time_receiving_Party])
				then isnull(datediff(ms, [Dial], [VoLTE_Ringing_time])-datediff(ms, [Dial], [VoLTE_Ringing_time_receiving_Party]), 0)	
		else 0 end as [VoLTE_Ringing_ReceivingParty->VoLTE_Ringing],			-- para la pestaña de VOLTE


		-- ***********************************************************************************************************************
		-- CONTROL DE LA INFO:
		--		* Hay que comprobar que se reciben todos los mensjaes indicados
		--		* Y se cumple el orden de los tiempos
		--	*** Los casos que no cumplan esto, deberian de contarse como intervalo a parte para que la grafica por tramos salga ok
		--	*** Comprobado en el NQDI que pueden faltar mensajes o reportarse en orden erroneo (dif de ms que no da valores negativos si se tuvieran en cuenta)
		case when 
			[Dial] is not null and  
			[LTE_RRCConnectionRequest_time] is not null and [LTE_ExtendedServiceRequest_time] is not null and 
				[LTE_RRCConnectionRelease_time] is not null and [UMTS_RRCConnectionRequest_time] is not null and 
			[CMServiceRequest_time] is not null and [Setup_time] is not null and [CallProceeding_time] is not null and
			[Alerting_Receiving_Party_time] is not null and [Connect_Receiving_Party_time] is not null and [Connect_time] is not null 
		then 1 else 0 end as AllMsgCS,
		case when 
			[Dial] is not null and  
			([VoLTE_Invite_req_time] is not null or [LTE_RRCConnectionRequest_time] is not null) and  
			[VoLTE_Trying_time] is not null and  
			([VoLTE_SesProgress_time] is not null or [CallProceeding_time] is not null) and  
			([VoLTE_Ringing_time_receiving_Party] is not null or [Alerting_Receiving_Party_time] is not null) and  
			([VoLTE_InviteOK_time_receiving_Party] is not null or [Connect_Receiving_Party_time] is not null) and  
			([VoLTE_InviteOK_time] is not null or [Connect_time] is not null)
		then 1 else 0 end as AllMsgVOLTE,

		case when [Dial]<=[LTE_RRCConnectionRequest_time] then 0								else 1 end as 'Dial>LTE_RRCConnectionRequest_time' ,
		case when [LTE_RRCConnectionRequest_time]<=[LTE_ExtendedServiceRequest_time] then 0		else 1 end as 'LTE_RRCConnectionRequest_time>LTE_ExtendedServiceRequest_time',
		case when [LTE_ExtendedServiceRequest_time]<=[LTE_ExtendedServiceRequest_time] then 0	else 1 end as 'LTE_ExtendedServiceRequest_time>LTE_ExtendedServiceRequest_time',
		case when [LTE_RRCConnectionRelease_time]<=[UMTS_RRCConnectionRequest_time] then 0		else 1 end as 'LTE_RRCConnectionRelease_time>UMTS_RRCConnectionRequest_time',
		case when [UMTS_RRCConnectionRequest_time]<=[CMServiceRequest_time] then 0				else 1 end as 'UMTS_RRCConnectionRequest_time>CMServiceRequest_time',
		case when [CMServiceRequest_time]<=[Setup_time] then 0									else 1 end as 'CMServiceRequest_time>Setup_time',
		case when [Setup_time]<=[CallProceeding_time] then 0									else 1 end as 'Setup_time>CallProceeding_time',
		case when [CallProceeding_time]<=[Alerting_Receiving_Party_time] then 0					else 1 end as 'CallProceeding_time>Alerting_Receiving_Party_time',
		case when [Alerting_Receiving_Party_time]<=[Connect_Receiving_Party_time] then 0		else 1 end as 'Alerting_Receiving_Party_time>Connect_Receiving_Party_time',
		case when [Connect_Receiving_Party_time]<=[Connect_time] then 0							else 1 end as 'Connect_Receiving_Party_time>Connect_time',
		case when [Alerting_Receiving_Party_time]<=[Alerting_time] then 0						else 1 end as 'Alerting_Receiving_Party_time>Alerting_time',

		case when [VoLTE_Invite_req_time]<=[VoLTE_Trying_time] then 0									else 1 end as 'VoLTE_Invite_req_time>VoLTE_Trying_time',
		case when [VoLTE_Trying_time]<=[VoLTE_SesProgress_time] then 0									else 1 end as 'VoLTE_Trying_time>VoLTE_SesProgress_time',
		case when [VoLTE_SesProgress_time]<=[VoLTE_Ringing_time_receiving_Party] then 0					else 1 end as 'VoLTE_SesProgress_time>VoLTE_Ringing_time_receiving_Party',
		case when [VoLTE_Ringing_time_receiving_Party]<=[VoLTE_InviteOK_time_receiving_Party] then 0	else 1 end as 'VoLTE_Ringing_time_receiving_Party>VoLTE_InviteOK_time_receiving_Party',
		case when [VoLTE_InviteOK_time_receiving_Party]<=[VoLTE_InviteOK_time] then 0					else 1 end as 'VoLTE_InviteOK_time_receiving_Party>VoLTE_InviteOK_time',
		case when [VoLTE_Ringing_time_receiving_Party]<=[VoLTE_Ringing_time] then 0						else 1 end as 'VoLTE_Ringing_time_receiving_Party>VoLTE_Ringing_time'

	from	lcc_core_Voice_Metrics_Table v, 
			lcc_core_Master_Table m
				LEFT OUTER JOIN lcc_core_Voice_Metrics_TimeStamp_Table	me		on m.key_BST=me.key_BST  
				LEFT OUTER JOIN lcc_core_Voice_CST_KPIs_Table_SQ				k_Aside	on m.key_BST=k_Aside.key_BST and k_Aside.side='A'
				LEFT OUTER JOIN lcc_core_Voice_CST_KPIs_Table_SQ				k_Bside	on m.key_BST=k_Bside.key_BST and k_Bside.side='B'

	where 
		m.key_BST=v.key_BST	and	sessionType='CALL' and session_Status  in ('Completed','Dropped')

) cst

GO


