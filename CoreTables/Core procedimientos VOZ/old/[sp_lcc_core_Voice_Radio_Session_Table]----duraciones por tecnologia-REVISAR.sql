USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_lcc_core_Voice_Radio_Session_Table]    Script Date: 23/04/2018 13:58:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[sp_lcc_core_Voice_Radio_Session_Table] as
-----------------------
exec sp_lcc_dropifexists 'lcc_core_Voice_Radio_Session_Table'
select
	db_name()+'_'+convert(varchar(256),sessionid)+'_'+isnull(convert(varchar(256),'NA'),'NA') COLLATE Latin1_General_CI_AS as key_BST, 
	db_name() COLLATE Latin1_General_CI_AS as ddbb,
	fileid, sessionid,

	session_duration, sum(r.net_duration) as net_duration
	,sum(case when r.technology like 'GSM %' then r.net_duration end) [2G]
	,sum(case when r.technology like 'UMTS %' then r.net_duration end) [3G]
	,sum(case when r.technology like 'LTE %' then r.net_duration end) [4G]
	,sum(case when (mnc<>homnc or mcc<>homcc) then net_duration end ) Roaming_duration
	,sum(case when r.technology='GSM 900' then r.net_duration end) [GSM 900]
	,sum(case when r.technology='GSM 1800' then r.net_duration end) [GSM 1800]
	,sum(case when r.technology='GSM 1900' then r.net_duration end) [GSM 1900]
	,sum(case when r.technology='UMTS 900' then r.net_duration end) [UMTS 900]
	,sum(case when r.technology='UMTS 1700' then r.net_duration end) [UMTS 1700]
	,sum(case when r.technology='UMTS 2100' then r.net_duration end) [UMTS 2100]
	,sum(case when r.technology='LTE E-UTRA 1' then r.net_duration end) [LTE E-UTRA 1]
	,sum(case when r.technology='LTE E-UTRA 3' then r.net_duration end) [LTE E-UTRA 3]
	,sum(case when r.technology='LTE E-UTRA 5' then r.net_duration end) [LTE E-UTRA 5]
	,sum(case when r.technology='LTE E-UTRA 7' then r.net_duration end) [LTE E-UTRA 7]
	,sum(case when r.technology='LTE E-UTRA 8' then r.net_duration end) [LTE E-UTRA 8]
	,sum(case when r.technology='LTE E-UTRA 20' then r.net_duration end) [LTE E-UTRA 20]
	,sum(case when r.technology='LTE E-UTRA 28' then r.net_duration end) [LTE E-UTRA 28]
	,sum(case when r.technology='LTE E-UTRA 40' then r.net_duration end) [LTE E-UTRA 40]
	,sum(case when r.technology='LTE E-UTRA 41' then r.net_duration end) [LTE E-UTRA 41]

	,sum(case when r.technology not in
	('LTE E-UTRA 41','LTE E-UTRA 40','LTE E-UTRA 20','LTE E-UTRA 28','LTE E-UTRA 8','LTE E-UTRA 7' ,'LTE E-UTRA 5'
	,'LTE E-UTRA 3','LTE E-UTRA 1','UMTS 2100','UMTS 1700','UMTS 900'
	,'GSM 1900','GSM 1800','GSM 900') then r.net_duration end) NotAllocated_tech

into lcc_core_Voice_Radio_Session_Table  
from
  	 (
		select 
			s.sessionid,  s.fileid, s.starttime, s.duration session_duration
			, dateadd(ms,s.duration,s.starttime) sessionEnd
			, n.cid, n.mcc, n.mnc, n.Operator
					,n.HOmcc, n.HOmnc , n.HomeOperator
					,n.technology,  n.cgi, n.freq, n.bsic,n.sc1
			,n.msgtime as netw_start, n.msgtime_next as netw_end
			,sum(
					case 
					when  (n.msgtime<=s.starttime and n.msgtime_next>=dateadd(ms,s.duration,s.starttime))
					then s.duration 
				when (n.msgtime<=s.starttime and n.msgtime_next<dateadd(ms,s.duration,s.starttime) and n.msgtime_next>s.starttime)
					then datediff(ms,s.starttime,n.msgtime_next)
				when (n.msgtime between s.starttime and dateadd(ms,s.duration,s.starttime) and n.msgtime_next>=dateadd(ms,s.duration,s.starttime))
					then datediff(ms,n.msgtime,dateadd(ms,s.duration,s.starttime))
				when (n.msgtime between s.starttime and dateadd(ms,s.duration,s.starttime) and n.msgtime_next<dateadd(ms,s.duration,s.starttime))
					then n.duration
				end
				)  
				as net_duration	
		from (select sessionid, fileid, startTime, duration from sessions
				union all 
			  select sessionid, fileid, startTime, duration from sessionsb)  s 
					left outer join
							(
									select n.networkid, n.fileid,n.msgtime, n.cid, n.mcc, n.mnc, n.Operator
									,n.HOmcc, n.HOmnc , n.HomeOperator
									,n.technology,  n.cgi, n.bcch as freq, n.bsic,n.sc1, n.duration, 
		 							case when ns.msgtime is null then dateadd(ms,n.duration,n.msgtime) 
										else ns.msgtime end 
										as msgtime_next
			 
									from networkinfo n 
									left outer join networkinfo ns
									on  n.fileid=ns.fileid 
									and n.networkid=ns.networkid-1
							) n on n.fileid=s.fileid and 
								(
								(n.msgtime<=s.starttime and n.msgtime_next>=dateadd(ms,s.duration,s.starttime))
								or 
								(n.msgtime<=s.starttime and n.msgtime_next<dateadd(ms,s.duration,s.starttime) and n.msgtime_next>s.starttime)
								or 
								(n.msgtime between s.starttime and dateadd(ms,s.duration,s.starttime))
								)

		group by 
			s.sessionid,	s.fileid,	s.starttime,	s.duration,		dateadd(ms,s.duration,s.starttime), 
			n.cid,			n.mcc,		n.mnc,			n.Operator,		n.HOmcc,	n.HOmnc,	n.HomeOperator,
			n.technology,	n.cgi,		n.freq,			n.bsic,			n.sc1,
			n.msgtime ,		n.msgtime_next 
		) r

group by sessionid,  fileid, session_duration
 ------------------------








