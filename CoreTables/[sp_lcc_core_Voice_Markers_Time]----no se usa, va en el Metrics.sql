USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_lcc_core_Voice_Markers_Time]    Script Date: 23/04/2018 13:55:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[sp_lcc_core_Voice_Markers_Time] as 


exec sp_lcc_dropifexists 'lcc_core_Voice_Markers_Time'
-------------------------------------
select 
	db_name()+'_'+isnull(convert(varchar(256),s.sessionid),'NA')+'_'+convert(varchar(256),'NA') COLLATE Latin1_General_CI_AS as key_BST,
	db_name() COLLATE Latin1_General_CI_AS as ddbb, 
	
	s.sessionid, s.fileid, 
	(select top 1 msgtime from Markers m 
			where m.sessionid=s.SessionId and m.MarkerText='dial' order by msgtime asc
		)
		as Dial_time ,
	(select top 1 msgtime from Markers m 
			where m.sessionid=s.SessionId and m.MarkerText='start dial' order by msgtime asc
		)
		as start_Dial_time ,
		(select top 1 msgtime from Markers m 
			where m.sessionid=s.SessionId and m.MarkerText='released' order by msgtime asc
		)
		as Release_time,
		(select top 1 msgtime from vlcc_Layer3_core l
			where l3_message='Alerting' and l.sessionid=s.sessionid order by msgtime asc
		)
		as Alerting_Time_A,
	 
		(select top 1 msgtime from vlcc_Layer3_core l
			where l3_message='Connect' and l.sessionid=s.sessionid order by msgtime asc
		)
		as Connect_Time_A,
	 
		(select top 1 msgtime from vlcc_Layer3_core l
			where l3_message='Extended service request' and l.sessionid=s.sessionid order by msgtime asc
		)
		as ExtendedSR_Time_A,
	 
		(select top 1 l.msgtime from vlcc_Layer3_core l, 
				(select top 1 msgtime from vlcc_Layer3_core l
						where l3_message='Extended service request' and l.sessionid=s.sessionid order by msgtime asc) e
			where l3_message='RRCConnectionRequest' and l.sessionid=s.sessionid 
			and l.msgtime> e.msgtime
			order by msgtime asc
		)
		as RRCConnect_Time_A,
	 
		(select top 1 msgtime from vlcc_Layer3_core l
			where l3_message='Alerting' and l.sessionid=b.sessionid order by msgtime asc
		)
		as Alerting_Time_B,
	 
		(select top 1 msgtime from vlcc_Layer3_core l
			where l3_message='Connect' and l.sessionid=b.sessionid order by msgtime asc
		)
		as Connect_Time_B,
		(select top 1 msgtime from vlcc_Layer3_core l
			where l3_message='Extended service request' and l.sessionid=b.sessionid order by msgtime asc
		)
		as ExtendedSR_Time_B,
	 
		(select top 1 l.msgtime from vlcc_Layer3_core l, 
				(select top 1 msgtime from vlcc_Layer3_core l
						where l3_message='Extended service request' and l.sessionid=b.sessionid order by msgtime asc) e
			where l3_message='RRCConnectionRequest' and l.sessionid=b.sessionid 
			and l.msgtime> e.msgtime
			order by msgtime asc
		)
		as RRCConnect_Time_B,

		(select top 1 msgtime from vIMSSIPMessage l
			where messageid='IMS SIP INVITE' and responseCode='Ringing' and l.sessionid=s.sessionid order by msgtime asc
		)
		as Ringing_time_A,

		(select top 1 msgtime from vIMSSIPMessage l
			where messageid='IMS SIP INVITE' and responseCode='OK' and l.sessionid=s.sessionid order by msgtime asc
		)
		as Accept_time_A,

		(select top 1 msgtime from vIMSSIPMessage l
			where messageid='IMS SIP INVITE' and responseCode='Ringing' and l.sessionid=b.sessionid order by msgtime asc
		)
		as Ringing_time_B,

		(select top 1 msgtime from vIMSSIPMessage l
			where messageid='IMS SIP INVITE' and responseCode='OK' and l.sessionid=b.sessionid order by msgtime asc
		)
		as Accept_time_B
into lcc_core_Voice_Markers_Time
from sessions s, SessionsB b

where s.SessionId=b.SessionIdA
and s.valid=1
 

