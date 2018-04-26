USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_lcc_core_Voice_FR_Metrics_Table]    Script Date: 23/04/2018 13:55:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [dbo].[sp_lcc_core_Voice_FR_Metrics_Table] as

-- DESCRIPTION ------------------------------------------------------------------------------------------------------
--
--		* COLLATE Latin1_General_CI_AS	-> database_default
--
--		Código del createVoiceTable - _FAST_RETURN: 
--			OJO que ehay un cambio del codigo c¡original que mete dulicados (toma en cuenta el primer 4G de la sesion actual y la sguiente)             
--
--		Used KPIID:
--			38030		3G/4G InterSystemHO, UMTS->LTE (Idle reselect)
--			StartTime	Timestamp of the last UMTS RRC Message
--			EndTime		Timestamp of the first LTE RRC message or Timeout, whatever comes first
--
---------------------------------------------------------------------------------------------------------------------

exec SQKeyValueInit 'C:\L3KeyValue'

------------------------------------------------ select * from lcc_core_Voice_FR_Metrics_Table
exec sp_lcc_dropifexists 'lcc_core_Voice_FR_Metrics_Table'
select 
	db_name()+'_'+convert(varchar(256),s.sessionid)+'_'+isnull(convert(varchar(256),'NA'),'NA') COLLATE Latin1_General_CI_AS as key_BST, 
	db_name() COLLATE Latin1_General_CI_AS as ddbb,

	-- Cada una de las sesiones de voz:
	s.sessionid as sessionidA, 	sb.sessionid as sessionidB,
	s.info as callstatus, s.tech,

	------------------------
	-- FAST RETURN parte A:
	------------------------
	-- Fin de llamada en 3G:
	r.sessionid							as RRCConReleaseComplete_sessionid_A,  
	r.samples							as RRCConReleaseComplete_samples_A,
	r.RRCConReleaseComplete_last_time	as RRCConReleaseComplete_last_time_A,
		
	-- Primer mensaje 4G en la propia sesion - paso rapido
	l.LTERRCMessage_first_time			as LTERRCMessage_first_time_A,

	-- Calculo duraciones 2G-3G en la propia sesion:
	0.001*case when r.RRCConReleaseComplete_last_time < l.LTERRCMessage_first_time 
		 then datediff(ms,convert(datetime,r.RRCConReleaseComplete_last_time,109), convert(datetime,l.LTERRCMessage_first_time,109)) 
	end									as Duration_rel_compl_to_4g_A,
	
	c.dlEUTRACarrierFreq				as dlEUTRACarrierFreq_A,

	------------------------
	-- FAST RETURN parte B:
	------------------------
	-- Fin de llamada en 3G:
	rb.sessionid							as RRCConReleaseComplete_sessionid_B,  
	rb.samples								as RRCConReleaseComplete_samples_B,
	rb.RRCConReleaseComplete_last_time		as RRCConReleaseComplete_last_time_B,
		
	-- Primer mensaje 4G en la propia sesion - paso rapido
	lb.LTERRCMessage_first_time				as LTERRCMessage_first_time_B,

	-- Calculo duraciones 2G-3G en la propia sesion:
	0.001*case when rb.RRCConReleaseComplete_last_time < lb.LTERRCMessage_first_time 
		 then datediff(ms,convert(datetime,rb.RRCConReleaseComplete_last_time,109), convert(datetime,lb.LTERRCMessage_first_time,109)) 
	end									as Duration_rel_compl_to_4g_B,
	
	cb.dlEUTRACarrierFreq				as dlEUTRACarrierFreq_B


into lcc_core_Voice_FR_Metrics_Table

from 	
	------------------------
	-- FAST RETURN parte A:
	------------------------
	sessions s
			left outer join (
					select sessionid, sum(1) as samples, min(msgtime) as RRCConReleaseComplete_last_time 
					from WCDMARRCMessages
					where msgtype like 'RRCConnectionReleaseComplete'
					group by sessionid
			) r on r.sessionid=s.sessionid					

			------------------------
			-- Para la vuelta a 4G 
			left outer join (
				select vk.sessionid, sum(1) as samples, min(vk.EndTime) as LTERRCMessage_first_time
				from vresultskpi vk,
					(
						select sessionid, sum(1) as samples, min(msgtime) as RRCConReleaseComplete_time 
						from WCDMARRCMessages
						where msgtype like 'RRCConnectionReleaseComplete'
						group by sessionid
				) r
				where   vk.KPIId=38030 
					and vk.endtime>r.RRCConReleaseComplete_time		
					and vk.sessionid>=r.sessionid and vk.sessionid<=r.sessionid+1
				group by vk.sessionid

			) l on l.sessionid>=s.sessionid	and l.sessionid<s.sessionid+1			-- la condicion original mete duplicados: lb.sessionid<=s.sessionid+1

			------------------------
			-- Indicacion de paso a 4G
			left outer join (
				select 
					sessionid, sum(1) as samples, max(msgtime) RRCConnectionRelease_las_time,
					cast(max(dbo.SQUMTSKeyValue(bin_message,logchantype,L3_Message,'dlEUTRACarrierFreq'))as varchar(max)) as dlEUTRACarrierFreq	 
				from vlcc_Layer3_core
				where l3_message like 'RRCConnectionRelease' and channel like '% DL_DCCH'	
				group by sessionid

			) c on c.sessionid=s.SessionId,

	------------------------
	-- FAST RETURN parte B:
	------------------------
	Sessionsb sb
		left outer join (
				select sessionid, sum(1) as samples, min(msgtime) as RRCConReleaseComplete_last_time 
				from WCDMARRCMessages
				where msgtype like 'RRCConnectionReleaseComplete'
				group by sessionid
		) rb on rb.sessionid=sb.sessionid					

		------------------------
		-- Para la vuelta a 4G 
		left outer join (
			select vk.sessionid, sum(1) as samples, min(vk.EndTime) as LTERRCMessage_first_time
			from vresultskpi vk,
				(
					select sessionid, sum(1) as samples, min(msgtime) as RRCConReleaseComplete_time 
					from WCDMARRCMessages
					where msgtype like 'RRCConnectionReleaseComplete'
					group by sessionid
			) r
			where   vk.KPIId=38030		
				and vk.endtime>r.RRCConReleaseComplete_time
				and vk.sessionid>=r.sessionid and vk.sessionid<=r.sessionid+1
			group by vk.sessionid

		) lb on lb.sessionid>=sb.sessionid	and lb.sessionid<sb.sessionid+1		-- la condicion original mete duplicados: lb.sessionid<=sb.sessionid+1

		------------------------
		-- Indicacion de paso a 4G
		left outer join (
			select 
				sessionid, sum(1) as samples, max(msgtime) RRCConnectionRelease_las_time,
				cast(max(dbo.SQUMTSKeyValue(bin_message,logchantype,L3_Message,'dlEUTRACarrierFreq'))as varchar(max)) as dlEUTRACarrierFreq	 
			from vlcc_Layer3_core
			where l3_message like 'RRCConnectionRelease' and channel like '%DL_DCCH'	
			group by sessionid

		) cb on cb.sessionid=sb.SessionId

where	s.sessionType like 'CALL' -- solo me interesan las llamadas
	and s.info in ('Completed', 'Failed', 'Dropped')
	and s.sessionid=sb.sessionidA


