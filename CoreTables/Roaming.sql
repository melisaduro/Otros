select n.networkid, n.fileid,n.msgtime, n.cid, n.mcc, n.mnc, n.Operator
	,n.HOmcc, n.HOmnc , n.HomeOperator
	,n.technology,  n.cgi, n.bcch as freq, n.bsic,n.sc1, n.duration, 
	case when ns.msgtime is null then dateadd(ms,n.duration,n.msgtime) 
		else ns.msgtime end as msgtime_next,n.bcch			 
from networkinfo n 
left outer join networkinfo ns on n.fileid=ns.fileid and n.networkid=ns.networkid-1
where n.mnc<>n.HOmnc

select * 
from (
select n.networkid, n.fileid,n.msgtime, n.cid, n.mcc, n.mnc, n.Operator
	,n.HOmcc, n.HOmnc , case when n.HomeOperator like '%vodafone%' then 'Vodafone' else n.HomeOperator end as HomeOperator
	,n.technology,  n.cgi, n.bcch as freq, n.bsic,n.sc1, n.duration, 
	case when ns.msgtime is null then dateadd(ms,n.duration,n.msgtime) 
		else ns.msgtime end as msgtime_next,n.bcch,sof.Frequency,sof.ServingOperator collate Latin1_General_CI_AS as ServingOperator	 
from networkinfo n 
left outer join networkinfo ns on  n.fileid=ns.fileid and n.networkid=ns.networkid-1
LEFT OUTER JOIN [AGRIDS].dbo.lcc_ref_servingOperator_Freq sof on n.BCCH=sof.Frequency )t
where ServingOperator<>homeoperator 
and mnc=HOmnc