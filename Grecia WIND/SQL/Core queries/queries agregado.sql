use [BM_Analytics]

--CST
SELECT t2.*
  FROM [BM_Analytics].[dbo].[lcc_core_Master_Table] t1
  inner join [BM_Analytics].dbo.lcc_core_Voice_CST_KPIs_Table_SQ t2
  on t1.key_bst=t2.key_bst
  and t1.sessionid=t2.sessionid
  where sessiontype='call'
  and operator='vodafone'
  and session_status in ('Completed')

  SELECT t2.alerting_freq,t2.connect_freq,t1.operator,count(1)
  FROM [BM_Analytics].[dbo].[lcc_core_Master_Table] t1
  inner join [BM_Analytics].dbo.lcc_core_Voice_Metrics_Table t2
  on t1.key_bst=t2.key_bst
  --and t1.sessionid=t2.sessionid
  where sessiontype='call'
  and operator in ('vodafone','wind','cosmote')
  and session_status in ('Completed')
  group by  t2.alerting_freq,t2.connect_freq,t1.operator
  order by 3

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

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

select case	
		when (session_status<>'Failed' and (																		-- En llamadas terminadas (Completadas, Caídas o SR):
				(call_CSFB_inA=1 and call_CSFB_inB=1) or															--  - ambos hacen CSFB o			 [is_CSFB=2]
				(calltypeA='VOLTE' and call_SRVCC_inA=0) and (calltypeB='VOLTE'  and call_SRVCC_inB=0)				--  - ambos se mantienen en VOLTE	 [is_VOLTE=2]
			  ) ) OR
			  (session_status='Failed' and (																					-- En llamadas fallidas:	
				(call_CSFB_inA=1 and call_CSFB_inB=1) or																		--  - ambos llegan al CSFB o
				(calltypeA='VOLTE' and call_SRVCC_inA=0) and (calltypeB='VOLTE'  and call_SRVCC_inB=0) or						--  - ambos se mantienen en VOLTE o
				(call_CSFB_inA=1 and (sc_sideB.Initial_Technology like '%LTE%' and sc_sideB.Final_Technology like '%LTE%'))	or	--	- Solo A llega al CSFB y B se mantiene en 4G o
				(call_CSFB_inB=1 and (sc_sideA.Initial_Technology like '%LTE%' and sc_sideA.Final_Technology like '%LTE%'))	or	--	- A se mantiene en 4G y solo B llega al CSFB o
				((calltypeA='VOLTE' and call_SRVCC_inA=0) 
								and (sc_sideB.Initial_Technology like '%LTE%' and sc_sideB.Final_Technology like '%LTE%'))	or	--	- A se mantiene en VOLTE y B se mantiene en 4G o 
				((calltypeB='VOLTE'  and call_SRVCC_inB=0)
								and (sc_sideA.Initial_Technology like '%LTE%' and sc_sideA.Final_Technology like '%LTE%'))		--	- A se mantiene en 4G y B se mantiene en VOLTE
			  ) ) then 'VoiceReal4G'

		when (																										-- Aqui da igual el tipo de llamada, se tiene que cumplir que:
			 (call_CSFB_inA=0 and call_CSFB_inB=0) and																--  - ambos sin CSFB y		[is_CSFB=0]
			 (calltypeA='CS'  and calltypeB='CS') and																--  - ambos sin VOLTE y		[is_VOLTE=0]
			 ( (sc_sideA.Initial_Technology not like '%LTE%' and sc_sideA.Final_Technology not like '%LTE%') and	--	- A nada en 4G y 
				 (sc_sideB.Initial_Technology not like '%LTE%' and sc_sideB.Final_Technology not like '%LTE%'))		--	- B nada en 4G
			 ) then 'VoiceReal3G'
	else 'VoiceMixed' end as VoiceTech,
	call_CSFB_inA,			call_CSFB_inB,
	case 
		when (calltypeA='VOLTE' and call_SRVCC_inA=0) and (calltypeB='VOLTE'  and call_SRVCC_inB=0) then 2	-- Real VOLTE
		when (calltypeA='VOLTE' and call_SRVCC_inA=0) and  calltypeB='CS'		then 1
		when calltypeA='CS'		and (calltypeB='VOLTE' and call_SRVCC_inB=0)	then 1 
		when calltypeA='CS'		and calltypeB='CS'								then 0
	else 0 end as is_VOLTE,

	call_SRVCC_inA,			call_SRVCC_inB,
	case 
		when call_SRVCC_inA=1 and call_SRVCC_inB=1 then 2 
		when call_SRVCC_inA=1 or call_SRVCC_inB=1 then 1
	else 0 end as is_SRVCC,
	case --  Fatla la tech de la llamada (pero solo era en el caso de los fails, ahora solo cuentan end calls):
		when session_Status in ('Completed','Dropped') and ((call_CSFB_inA=1 or calltypeA='VOLTE') and (call_CSFB_inB=1 or calltypeB='VOLTE')) then 2 
		when session_Status in ('Completed','Dropped') and ((call_CSFB_inA=1 or calltypeA='VOLTE') or  (call_CSFB_inB=1 or calltypeB='VOLTE')) then 1
	else 0 end as Calls_Started_4G,
	operator
	
from lcc_core_Master_Table m
		LEFT OUTER JOIN lcc_core_Voice_Metrics_Table v				on m.key_BST=v.key_BST	
		LEFT OUTER JOIN lcc_core_Voice_Metrics_TimeStamp_Table vt	on m.key_BST=vt.key_BST	
				LEFT OUTER JOIN lcc_core_Voice_ServingCell_Session_Table_Dial2Discon sc_sideA on m.key_BST=sc_sideA.key_BST	and	sessionType='CALL'  and sc_sideA.side='A'
		LEFT OUTER JOIN lcc_core_Voice_ServingCell_Session_Table_Dial2Discon sc_sideB on m.key_BST=sc_sideB.key_BST	and	sessionType='CALL'  and sc_sideB.side='B'

		LEFT OUTER JOIN lcc_core_Voice_CR_Metrics_Table cr	on m.key_BST=cr.key_BST	
		LEFT OUTER JOIN lcc_core_Voice_FR_Metrics_Table fr  on m.key_BST=fr.key_BST	

		LEFT OUTER JOIN lcc_core_Voice_CEM_KPIs_Metrics_Table cem on m.key_BST=cem.key_BST

where m.sessionType='CALL' 
  and operator in ('vodafone','wind','cosmote')
  and session_status in ('Completed')
  	select * from Lcc_Data_HTTPTransfer_DL