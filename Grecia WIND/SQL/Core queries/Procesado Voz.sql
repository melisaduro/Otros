select
	v.key_BST,[CMService_band],[Disconnect_band],[callingParty_CSFB],[CallConfirmed_band_Receiving_Party],[Disconnect_band_Receiving_Party],
	--------------------------------------------
	----------- Calls_Started_Ended_3G:
	case 
		when session_Status in ('Completed','Dropped') and (
			/*Calling Party:*/	(left([CMService_band],4) = 'UMTS'						and left([Disconnect_band],4) = 'UMTS'					and [callingParty_CSFB]=0)	-- Start/end in 3G
			AND 
			/*Called Party:*/	(left([CallConfirmed_band_Receiving_Party],4) = 'UMTS'	and left([Disconnect_band_Receiving_Party],4) = 'UMTS'	and [calledParty_CSFB]=0)	-- Start/end in 3G
			) then 2	-- both sides in 3G

		when session_Status in ('Completed','Dropped') and (
			/*Calling Party:*/	(left([CMService_band],4) = 'UMTS'						and left([Disconnect_band],4) = 'UMTS'					and [callingParty_CSFB]=0)	-- Start/end in 3G
			OR 
			/*Called Party:*/	(left([CallConfirmed_band_Receiving_Party],4) = 'UMTS'	and left([Disconnect_band_Receiving_Party],4) = 'UMTS'	and [calledParty_CSFB]=0)	-- Start/end in 3G
			) then 1	-- only one in 3G
	else 0 end as Calls_Started_Ended_3G,

	--------------------------------------------
	----------- Calls_Started_Ended_2G:
	case -- 2G:
		when session_Status in ('Completed','Dropped') and (
			/*Calling Party:*/	(left([CMService_band],3) = 'GSM'						and left([Disconnect_band],3) = 'GSM'					and [callingParty_CSFB]=0)	-- Start/end in 2G
			AND 
			/*Called Party:*/	(left([CallConfirmed_band_Receiving_Party],3) = 'GSM'	and left([Disconnect_band_Receiving_Party],3) = 'GSM'	and [calledParty_CSFB]=0)	-- Start/end in 2G
			) then 2	-- both sides in 2G

		when session_Status in ('Completed','Dropped') and (
			/*Calling Party:*/	(left([CMService_band],3) = 'GSM'						and left([Disconnect_band],3) = 'GSM'					and [callingParty_CSFB]=0)	-- Start/end in 2G
			OR 
			/*Called Party:*/	(left([CallConfirmed_band_Receiving_Party],3) = 'GSM'	and left([Disconnect_band_Receiving_Party],3) = 'GSM'	and [calledParty_CSFB]=0)	-- Start/end in 2G
			) then 1	-- only one in 2G
	else 0 end as Calls_Started_Ended_2G,
	
	--------------------------------------------	
	----------- Calls_Mixed:
	case 
		when session_Status in ('Completed','Dropped') and (
			/*Calling Party:*/	(left([CMService_band],3)					 <>left([Disconnect_band],3)					and [callingParty_CSFB]=0)	-- Start<>end 
			AND 
			/*Called Party:*/	(left([CallConfirmed_band_Receiving_Party],3)<>left([Disconnect_band_Receiving_Party],3)	and [calledParty_CSFB]=0)	-- Start<>end  
			) then 2	-- both different

		when session_Status in ('Completed','Dropped') and (
			/*Calling Party:*/	(left([CMService_band],3)					 <>left([Disconnect_band],3)					and [callingParty_CSFB]=0)	-- Start<>end 
			OR 
			/*Called Party:*/	(left([CallConfirmed_band_Receiving_Party],3)<>left([Disconnect_band_Receiving_Party],3)	and [calledParty_CSFB]=0)	-- Start<>end  
			) then 1	-- only one different
	else 0 end as Calls_Mixed,
	call_CSFB_inA,call_CSFB_inb,
	--------------------------------------------
	----------- Calls_Started_4G:
	case --  Fatla la tech de la llamada (pero solo era en el caso de los fails, ahora solo cuentan end calls):
		when session_Status in ('Completed','Dropped') and ((call_CSFB_inA=1 or calltypeA='VOLTE') and (call_CSFB_inB=1 or calltypeB='VOLTE')) then 2 
		when session_Status in ('Completed','Dropped') and ((call_CSFB_inA=1 or calltypeA='VOLTE') or  (call_CSFB_inB=1 or calltypeB='VOLTE')) then 1
	else 0 end as Calls_Started_4G,

	--------------------------------------------
	----------- Calls_Started_Ended_VOLTE:
	case 
		when session_Status in ('Completed','Dropped') and ((call_SRVCC_inA=0  and calltypeA='VOLTE') and (call_SRVCC_inB=0 and calltypeB='VOLTE')) then 2 
		when session_Status in ('Completed','Dropped') and ((call_SRVCC_inA=0  and calltypeA='VOLTE') or  (call_SRVCC_inB=0 and calltypeB='VOLTE')) then 1
	else 0 end as Calls_Started_Ended_VOLTE,

	--------------------------------------------
	----------- GSM_calls_After_CSFB:
	case 
		when session_Status in ('Completed','Dropped') and ((v.[CMService_band] like 'GSM%' and v.[callingParty_CSFB]=1) and (v.[CallConfirmed_band_Receiving_Party] like 'GSM%' and v.[calledParty_CSFB]=1)) then 2 
		when session_Status in ('Completed','Dropped') and ((v.[CMService_band] like 'GSM%' and v.[callingParty_CSFB]=1) or  (v.[CallConfirmed_band_Receiving_Party] like 'GSM%' and v.[calledParty_CSFB]=1)) then 1
	else 0 end as GSM_calls_After_CSFB,

	--------------------------------------------
	----------- UMTS_calls_After_CSFB:
	case 
		when session_Status in ('Completed','Dropped') and ((v.[CMService_band] like 'UMTS%' and v.[callingParty_CSFB]=1) and (v.[CallConfirmed_band_Receiving_Party] like 'UMTS%' and v.[calledParty_CSFB]=1)) then 2 
		when session_Status in ('Completed','Dropped') and ((v.[CMService_band] like 'UMTS%' and v.[callingParty_CSFB]=1) or  (v.[CallConfirmed_band_Receiving_Party] like 'UMTS%' and v.[calledParty_CSFB]=1)) then 1
	else 0 end as UMTS_calls_After_CSFB


from lcc_core_Master_Table m
		LEFT OUTER JOIN lcc_core_Voice_Metrics_Table v				on m.key_BST=v.key_BST	
		LEFT OUTER JOIN lcc_core_Voice_Metrics_TimeStamp_Table vt	on m.key_BST=vt.key_BST	

		LEFT OUTER JOIN lcc_core_Voice_ServingCell_Session_Table_Dial2Discon sc_sideA on m.key_BST=sc_sideA.key_BST	and	sessionType='CALL'  and sc_sideA.side='A'
		LEFT OUTER JOIN lcc_core_Voice_ServingCell_Session_Table_Dial2Discon sc_sideB on m.key_BST=sc_sideB.key_BST	and	sessionType='CALL'  and sc_sideB.side='B'

		LEFT OUTER JOIN lcc_core_Voice_CR_Metrics_Table cr	on m.key_BST=cr.key_BST	
		LEFT OUTER JOIN lcc_core_Voice_FR_Metrics_Table fr  on m.key_BST=fr.key_BST	

		LEFT OUTER JOIN lcc_core_Voice_CEM_KPIs_Metrics_Table cem on m.key_BST=cem.key_BST	

where m.sessionType='CALL' 
and mnc=5
and session_Status='Completed'