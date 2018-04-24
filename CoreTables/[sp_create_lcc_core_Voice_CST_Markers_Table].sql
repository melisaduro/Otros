USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_lcc_core_Voice_CST_KPIs_Table]    Script Date: 19/04/2018 14:27:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [sp_create_lcc_core_Voice_CST_Markers_Table]
		@Config [nvarchar](max)			= 'SpainOSP'
as

-- DESCRIPTION ----------------------------------------------------------------------------------------------------------------------
--
--		* COLLATE Latin1_General_CI_AS	-> database_default
--
--
--		* Base TABLE/VIEW:			callanalysis
--	

--use FY1718_VOICE_BURGOS_4G_H1
--declare @Config [nvarchar](max)			= 'SpainOSP'	
--***********************************************************************************************************************************
--		Variables:
--***********************************************************************************************************************************
-- Markers inicio/fin:
declare @CS_Marker_ini as varchar(256) = (select CS_Marker_ini_CST from lcc_core_Voice_Configuration_Table where Config=@Config)
declare @CS_Marker_end_Alert as varchar(256) = (select CS_Marker_end_CST_Alerting from lcc_core_Voice_Configuration_Table where Config=@Config)
declare @CS_Marker_end_Conn as varchar(256) = (select CS_Marker_end_CST_Connect from lcc_core_Voice_Configuration_Table where Config=@Config)
declare @VOLTE_Marker_ini as varchar(256) = (select VOLTE_Marker_ini_CST from lcc_core_Voice_Configuration_Table where Config=@Config)
declare @VOLTE_Marker_end_Alert as varchar(256) = (select VOLTE_Marker_end_CST_Alerting from lcc_core_Voice_Configuration_Table where Config=@Config)
declare @VOLTE_Marker_end_Conn as varchar(256) = (select VOLTE_Marker_end_CST_Connect from lcc_core_Voice_Configuration_Table where Config=@Config)


exec sp_lcc_dropifexists '_lcc_c0re_Voice_Metrics_Table'
exec('
select * into _lcc_c0re_Voice_Metrics_Table 
from lcc_core_Voice_'+@Config+'_Metrics_Table
')

exec sp_lcc_dropifexists '_lcc_c0re_Voice_Metrics_TimeStamp_Table'
exec('
select * into _lcc_c0re_Voice_Metrics_TimeStamp_Table 
from lcc_core_Voice_'+@Config+'_Metrics_TimeStamp_Table
')

-----------------------------------------------------------
-- (1.2)	Create table with SQ-KPIID selected by default:
--********************************************************************************
------------------------------------- select * from _lcc_c0re_Voice_CST_KPIs_Table
exec sp_lcc_dropifexists '_lcc_c0re_Voice_CST_Markers_Table'
select 
	db_name()+'_'+convert(varchar(256),s.sessionid)+'_'+isnull(convert(varchar(256),'NA'),'NA') COLLATE Latin1_General_CI_AS as key_BST, 
	db_name() COLLATE Latin1_General_CI_AS as ddbb,
	
	s.sessionid as sessionidA, s.sessionidB,
	s.calltype, s.calldir,

	------------------------------------
	s.disconClass, s.disconCause, s.disconLocation, s.codeDescription,
	------------------------------------

	convert(varchar(25),null) as callingParty_type,		convert(varchar(25),null) as calledParty_type,	
	convert(int, null) as alertingMO,		convert(int, null) as alertingMT,
	convert(int, null) as connectMO,		convert(int, null) as connectMT

into _lcc_c0re_Voice_CST_Markers_Table

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
-- Update lcc_core_Voice_Metrics_Table - CALLED/CALLING Party:
update _lcc_c0re_Voice_CST_Markers_Table
set 
	callingParty_type=callTypeA,		calledParty_type=callTypeB
--select *
from _lcc_c0re_Voice_CST_Markers_Table m,_lcc_c0re_Voice_Metrics_Table c
where c.callDir like 'A->%'
and m.sessionidA=c.sessionidA


update _lcc_c0re_Voice_CST_Markers_Table
set 
	callingParty_type=callTypeB,		calledParty_type=callTypeA
--select *
from _lcc_c0re_Voice_CST_Markers_Table m,_lcc_c0re_Voice_Metrics_Table c
where c.callDir like '%->A'
and m.sessionidB=c.sessionidB


exec('
update _lcc_c0re_Voice_CST_Markers_Table
set 
	alertingMO=case when c.calltype <>''M->M'' then -- M2F:		M->L or M->?
					case 
							when callingParty_type=''CS''		then datediff(ms, '+@CS_Marker_ini+', '+@CS_Marker_end_Alert+')
							when callingParty_type=''VOLTE''	then datediff(ms, '+@VOLTE_Marker_ini+', '+@VOLTE_Marker_end_Alert+')
						end
					else								-- M2M:		Metrics Table  - CallingParty side
						case 
							when callingParty_type=''CS''		then datediff(ms, '+@CS_Marker_ini+', '+@CS_Marker_end_Alert+')
							when callingParty_type=''VOLTE''	then datediff(ms, '+@VOLTE_Marker_ini+', '+@VOLTE_Marker_end_Alert+')
						end
					end
	 
--select *
from _lcc_c0re_Voice_CST_Markers_Table m, _lcc_c0re_Voice_Metrics_TimeStamp_Table c
where m.callDir like ''A->%''
and m.sessionidA=c.sessionidA
')

exec('
update _lcc_c0re_Voice_CST_Markers_Table
set 
	alertingMT=case when c.calltype <>''M->M'' then -- M2F:		M->L or M->?
					case 
							when calledParty_type=''CS''		then datediff(ms, '+@CS_Marker_ini+', '+@CS_Marker_end_Alert+')
							when calledParty_type=''VOLTE''	then datediff(ms, '+@VOLTE_Marker_ini+', '+@VOLTE_Marker_end_Alert+')
						end
					else								-- M2M:		Metrics Table  - CallingParty side
						case 
							when calledParty_type=''CS''		then datediff(ms, '+@CS_Marker_ini+', '+@CS_Marker_end_Alert+')
							when calledParty_type=''VOLTE''		then datediff(ms, '+@VOLTE_Marker_ini+', '+@VOLTE_Marker_end_Alert+')
						end
					end
	 
--select *
from _lcc_c0re_Voice_CST_Markers_Table m, _lcc_c0re_Voice_Metrics_TimeStamp_Table c
where m.callDir like ''%->A''
and m.sessionidB=c.sessionidB
')


exec('
update _lcc_c0re_Voice_CST_Markers_Table
set 
	connectMO=case when c.calltype <>''M->M'' then -- M2F:		M->L or M->?
					case 
							when calledParty_type=''CS''		then datediff(ms, '+@CS_Marker_ini+', '+@CS_Marker_end_Conn+')
							when calledParty_type=''VOLTE''	then datediff(ms, '+@VOLTE_Marker_ini+', '+@VOLTE_Marker_end_Conn+')
						end
					else								-- M2M:		Metrics Table  - CallingParty side
						case 
							when callingParty_type=''CS'' and calledParty_type=''CS''			then datediff(ms, '+@CS_Marker_ini+', '+@CS_Marker_end_Conn+') - datediff(ms, [Alerting_Receiving_Party_time], [Connect_Receiving_Party_time])
							when callingParty_type=''VOLTE'' and calledParty_type=''CS''		then datediff(ms, '+@CS_Marker_ini+', '+@CS_Marker_end_Conn+') - datediff(ms, [VoLTE_Ringing_time_receiving_Party], [VoLTE_InviteOK_time_receiving_Party])
							when callingParty_type=''CS'' and calledParty_type=''VOLTE''		then datediff(ms, '+@VOLTE_Marker_ini+', '+@VOLTE_Marker_end_Conn+') - datediff(ms, [Alerting_Receiving_Party_time], [Connect_Receiving_Party_time])
							when callingParty_type=''VOLTE'' and calledParty_type=''VOLTE''		then datediff(ms, '+@VOLTE_Marker_ini+', '+@VOLTE_Marker_end_Conn+') - datediff(ms, [VoLTE_Ringing_time_receiving_Party], [VoLTE_InviteOK_time_receiving_Party])
						end
					end
	 
--select *
from _lcc_c0re_Voice_CST_Markers_Table m, _lcc_c0re_Voice_Metrics_TimeStamp_Table c
where m.callDir like ''A->%''
and m.sessionidA=c.sessionidA
')


exec('
update _lcc_c0re_Voice_CST_Markers_Table
set 
	connectMT=case when c.calltype <>''M->M'' then -- M2F:		M->L or M->?
					case 
							when callingParty_type=''CS''		then datediff(ms, '+@CS_Marker_ini+', '+@CS_Marker_end_Conn+')
							when callingParty_type=''VOLTE''	then datediff(ms, '+@VOLTE_Marker_ini+', '+@VOLTE_Marker_end_Conn+')
						end
					else								-- M2M:		Metrics Table  - CallingParty side
						case 
							when callingParty_type=''CS'' and calledParty_type=''CS''			then datediff(ms, '+@CS_Marker_ini+', '+@CS_Marker_end_Conn+') - datediff(ms, [Alerting_Receiving_Party_time], [Connect_Receiving_Party_time])
							when callingParty_type=''VOLTE'' and calledParty_type=''CS''		then datediff(ms, '+@VOLTE_Marker_ini+', '+@VOLTE_Marker_end_Conn+') - datediff(ms, [Alerting_Receiving_Party_time], [Connect_Receiving_Party_time])
							when callingParty_type=''CS'' and calledParty_type=''VOLTE''		then datediff(ms, '+@CS_Marker_ini+', '+@CS_Marker_end_Conn+') - datediff(ms, [VoLTE_Ringing_time_receiving_Party], [VoLTE_InviteOK_time_receiving_Party])
							when callingParty_type=''VOLTE'' and calledParty_type=''VOLTE''		then datediff(ms, '+@VOLTE_Marker_ini+', '+@VOLTE_Marker_end_Conn+') - datediff(ms, [VoLTE_Ringing_time_receiving_Party], [VoLTE_InviteOK_time_receiving_Party])
						end
					end
	 
--select *
from _lcc_c0re_Voice_CST_Markers_Table m, _lcc_c0re_Voice_Metrics_TimeStamp_Table c
where m.callDir like ''A->%''
and m.sessionidA=c.sessionidA
')
		
--***********************************************************************************************************************************
--		Tabla CORE final:
--***********************************************************************************************************************************
------declare @Config as [nvarchar](max)='SpainOSP'
exec('
	exec sp_lcc_dropifexists ''lcc_core_Voice_'+@Config+'_CST_Markers_Table''	
	select * 
	into lcc_core_Voice_'+@Config+'_CST_Markers_Table
	from _lcc_c0re_Voice_CST_Markers_Table
')


------------------------------------- select * from _lcc_c0re_Voice_CST_Markers_Table

