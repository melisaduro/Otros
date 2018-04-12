--USE [master]
--GO
--/****** Object:  StoredProcedure [dbo].[sp_create_markers_time]    Script Date: 12/09/2017 12:53:35 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--ALTER procedure [dbo].[sp_create_markers_time] as 

--if (select name from sys.all_objects where name='lcc_markers_time' and type='U') is null
BEGIN


--MDM 11/02/2017 modificaciones: 
-- Antes se almacenaba el primer registro de cada evento (top 1 order by msgtime asc), ahora el último (varios intentos de una llamada pero la buena es la última).
-- Evento Connect de VOLTE ( Accept_Time_X) se añade la condición Message like '%200 OK%'.
-- Nuevos eventos
--------drop table [lcc_markers_time]
-- We create the table from the beginning
--------	
select 'Created lcc_markers_time from the Beginning' info

	CREATE TABLE [dbo].[lcc_markers_time](
		[sessionid] [bigint] NOT NULL,
		[fileid] [bigint] NULL,
		
		[Dial_time] [datetime] NULL,
		[start_Dial_time] [datetime] NULL,
		[ExtendedSR_time_A] [varchar](50) NULL,	 
		[ExtendedSR_time_B] [varchar](50) NULL,
		[RRCConnect_time_A] [varchar](50) NULL,	 
		[RRCConnect_time_B] [varchar](50) NULL,	
		[CMServiceRequest_time_A] [varchar](50) NULL,
		[CMServiceRequest_time_B] [varchar](50) NULL,
		[CallConfirmed_time_A] [varchar](50) NULL,
		[CallConfirmed_time_B] [varchar](50) NULL,
		[Alerting_time_A] [varchar](50) NULL,	
		[Alerting_time_B] [varchar](50) NULL,	 
		[Connect_time_A] [varchar](50) NULL,	
		[Connect_time_B] [varchar](50) NULL,	 
		[ConnectAck_time_A] [varchar](50) NULL,
		[ConnectAck_time_B] [varchar](50) NULL,
		[Disconnect_time_A] [varchar](50) NULL,
		[Disconnect_time_B] [varchar](50) NULL,
		[Request_time_A] [varchar](50) NULL,
		[Request_time_B] [varchar](50) NULL,
		[Trying_time_A] [varchar](50) NULL,
		[Trying_time_B] [varchar](50) NULL,
		[Ringing_time_A] [varchar](50) NULL,
		[Ringing_time_B] [varchar](50) NULL,
		[Accept_time_A] [varchar](50) NULL,		
		[Accept_time_B] [varchar](50) NULL,	
		[ConnectAckVOLTE_time_A] [varchar](50) NULL,
		[ConnectAckVOLTE_time_B] [varchar](50) NULL,
		[DisconnectVOLTE_time_A] [varchar](50) NULL,
		[DisconnectVOLTE_time_B] [varchar](50) NULL,
		[Release_time] [datetime] NULL,	
		
		[Dial_tech] [varchar](25) null,
		[start_Dial_tech] [varchar](25) null,
		[ExtendedSR_tech_A] [varchar](25) null,	 
		[ExtendedSR_tech_B] [varchar](25) null,
		[RRCConnect_tech_A] [varchar](25) null,	 
		[RRCConnect_tech_B] [varchar](25) null,	
		[CMServiceRequest_tech_A] [varchar](25) null,
		[CMServiceRequest_tech_B] [varchar](25) null,
		[CallConfirmed_tech_A] [varchar](25) null,
		[CallConfirmed_tech_B] [varchar](25) null,
		[Alerting_tech_A] [varchar](25) null,	
		[Alerting_tech_B] [varchar](25) null,	 
		[Connect_tech_A] [varchar](25) null,	
		[Connect_tech_B] [varchar](25) null,	 
		[ConnectAck_tech_A] [varchar](25) null,
		[ConnectAck_tech_B] [varchar](25) null,
		[Disconnect_tech_A] [varchar](25) null,
		[Disconnect_tech_B] [varchar](25) null,
		[Request_tech_A] [varchar](50) NULL,
		[Request_tech_B] [varchar](50) NULL,
		[Trying_tech_A] [varchar](25) null,
		[Trying_tech_B] [varchar](25) null,
		[Ringing_tech_A] [varchar](25) null,
		[Ringing_tech_B] [varchar](25) null,
		[Accept_tech_A] [varchar](25) null,		 
		[Accept_tech_B] [varchar](25) null,	
		[ConnectAckVOLTE_tech_A] [varchar](25) null,
		[ConnectAckVOLTE_tech_B] [varchar](25) null,
		[DisconnectVOLTE_tech_A] [varchar](25) null,
		[DisconnectVOLTE_tech_B] [varchar](25) null,
		[Release_tech] [varchar](25) null,

		[Dial_bcch] int null,
		[start_Dial_bcch] int null,
		[ExtendedSR_bcch_A] int null,	 
		[ExtendedSR_bcch_B] int null,
		[RRCConnect_bcch_A] int null,	 
		[RRCConnect_bcch_B] int null,	
		[CMServiceRequest_bcch_A] int null,
		[CMServiceRequest_bcch_B] int null,
		[CallConfirmed_bcch_A] int null,
		[CallConfirmed_bcch_B] int null,
		[Alerting_bcch_A] int null,	
		[Alerting_bcch_B] int null,	 
		[Connect_bcch_A] int null,	
		[Connect_bcch_B] int null,	 
		[ConnectAck_bcch_A] int null,
		[ConnectAck_bcch_B] int null,
		[Disconnect_bcch_A] int null,
		[Disconnect_bcch_B] int null,
		[Request_bcch_A] [varchar](50) NULL,
		[Request_bcch_B] [varchar](50) NULL,
		[Trying_bcch_A] int null,
		[Trying_bcch_B] int null,
		[Ringing_bcch_A] int null,
		[Ringing_bcch_B] int null,
		[Accept_bcch_A] int null,		 
		[Accept_bcch_B] int null,	
		[ConnectAckVOLTE_bcch_A] int null,
		[ConnectAckVOLTE_bcch_B] int null,
		[DisconnectVOLTE_bcch_A] int null,
		[DisconnectVOLTE_bcch_B] int null,
		[Release_bcch] int null,

		[min_Time_Mos] [varchar](50) NULL,
		[max_Time_Mos] [varchar](50) NULL

	)

END

BEGIN

--------
-- We insert new fields in the table
--------
declare @maxSession as int=0--(select isnull(MAX(sessionid),0) from lcc_markers_time)
select 'Updated lcc_markers_time from session='+CONVERT(varchar(256),@maxSession)+' to Session='+CONVERT(varchar(256),(select max(sessionid) from Sessions)) info


---------------------------------------------------------------------------------------------------------------------------------------------------
--Utilizamos dos lógicas para identificar los eventos de la llamada:
---------------------------------------------------------------------------------------------------------------------------------------------------
--1ª lcc_markers_time_MOS: acotamos los eventos más cercanos al MOS reportado: 
--	Tomamos los eventos desde el Dial - ... - ConnectAck anteriores más cercanos al primer registro de MOS de la llamada
--	Tomamos los eventos del Disconnect-Release posteriores más cercanos al último registro de MOS de la llamada
--2ª lcc_markers_time_Last (sólo para llamadas tipo Fail): recogemos los últimos eventos de cada tipo reportados en la ventana de la llamada (no tendremos muestras de MOS)

--Como en fallos no se reportará MOS, los eventos no localizados en la primera lógica, se informarán con los de la segunda.

exec sp_lcc_dropifexists '_mos_MOS'
select m.sessionid, sb.sessionid as sessionidB, min(t.startTime) as min_Time_Mos,max(t.startTime) as max_Time_Mos
into _mos_MOS
from dbo.ResultsLQ08Avg m, TestInfo t, sessionsB sb
where m.sessionid > @MaxSession
	and m.sessionid=t.sessionid 
	and m.sessionid=sb.sessionidA 
	and m.TestId=t.TestId 
	and Appl in (10, 110, 1010, 20, 120, 12, 1012, 22) 
group by m.sessionid, sb.sessionid


---------------------------------------------------------------------------------------------------------------------
--Calculo todas las ocurrencias de los eventos buscados, despues acotaremos por mos o por  último evento registrado:
--(se ordenan ya por tiempos,para quedarnos despues el último)
---------------------------------------------------------------------------------------------------------------------
exec sp_lcc_dropifexists '_Markers_all'
select  m.sessionid,
		m.msgtime,
		m.MarkerText,
		n.bcch,
		case when n.technology like 'LTE E-UTRA%' then case when n.technology like '%20%' then 'LTE800'
															when n.technology like '%7%' then 'LTE2600'
															when n.technology like '%3%' then 'LTE1800'
															when n.technology like '%1%' then 'LTE2100' end
		else replace(n.technology,' ','') end as technology,
		row_number () over (partition by m.sessionid, m.MarkerText order by m.msgtime desc) as id
into _Markers_all
from Markers m 
	inner join NetworkInfo n on m.NetworkId=n.NetworkId
	left join [AGRIDS].dbo.lcc_ref_servingOperator_Freq sof on n.BCCH=sof.Frequency
where m.sessionid > @MaxSession
	and m.MarkerText in ('dial', 'start dial', 'released')


exec sp_lcc_dropifexists '_vlcc_Layer3_comp_all'
select  sessionid,
		msgtime,
		l3_message,
		bcch,
		case when m.RFband like 'LTE E-UTRA%' then sof.band collate Latin1_General_CI_AS else replace(m.RFband,' ','') end as technology,
		row_number () over (partition by sessionid, l3_message order by msgtime desc) as id
into _vlcc_Layer3_comp_all
from vlcc_Layer3_comp m
	left join [AGRIDS].dbo.lcc_ref_servingOperator_Freq sof on m.BCCH=sof.Frequency
where sessionid > @MaxSession
	and l3_message in ('alerting', 'connect','Extended service request', 'disconnect', 'CM Service Request', 'Call Confirmed','Connect Acknowledge','RRCConnectionRequest')

exec sp_lcc_dropifexists '_vIMSSIPMessage_all'
select  sessionid,
		msgtime,
		case when messageid='IMS SIP INVITE' and responseCode='Request' then 'Request' 
			when messageid='IMS SIP INVITE' and responseCode='Ringing' then 'Alerting'
			when messageid='IMS SIP INVITE' and responseCode='OK' and Message like '%200 OK%' then 'Connect' 
			when messageid='IMS SIP INVITE' and responseCode='Trying' then 'Trying'
			when messageid='IMS SIP ACK' and responseCode='Request' then  'ConnectAck' 
			when messageid='IMS SIP BYE' and responseCode='OK' and Message like '%200 OK%' then 'Disconnect'
		end as message,
		bcch,
		case when m.RFband like 'LTE E-UTRA%' then sof.band collate Latin1_General_CI_AS else replace(m.RFband,' ','') end as technology,
		row_number () over (partition by sessionid, case when messageid='IMS SIP INVITE' and responseCode='Request' then 'Request'
								when messageid='IMS SIP INVITE' and responseCode='Ringing' then 'Alerting'
								when messageid='IMS SIP INVITE' and responseCode='OK' and Message like '%200 OK%' then 'Connect' 
								when messageid='IMS SIP INVITE' and responseCode='Trying' then 'Trying'
								when messageid='IMS SIP ACK' and responseCode='Request' then  'ConnectAck' 
								when messageid='IMS SIP BYE' and responseCode='OK' and Message like '%200 OK%' then 'Disconnect'
							end order by msgtime desc) as id
into _vIMSSIPMessage_all
from vlcc_IMSSIPMessage_comp m
	left join [AGRIDS].dbo.lcc_ref_servingOperator_Freq sof on m.BCCH=sof.Frequency
where sessionid > @MaxSession
	and ((messageid='IMS SIP INVITE' and responseCode='Request')
		or
		(messageid='IMS SIP INVITE' and responseCode='Ringing')
		or
		(messageid='IMS SIP INVITE' and responseCode='OK' and Message like '%200 OK%')
		or
		(messageid='IMS SIP INVITE' and responseCode='Trying')
		or
		(messageid='IMS SIP ACK' and responseCode='Request')
		or
		(messageid='IMS SIP BYE' and responseCode='OK' and Message like '%200 OK%')
	)



---------------------------------------------------
--Calculo 1ª lcc_markers_time_MOS:
---------------------------------------------------
exec sp_lcc_dropifexists '_Markers_MOS_ant'
select  m.*,mos.sessionidB,
		row_number () over (partition by m.sessionid, m.MarkerText order by m.msgtime desc) as idMos
into _Markers_MOS_ant
from _Markers_all m
	inner join _mos_MOS mos on m.sessionid=mos.sessionid or m.sessionid=mos.sessionidB
where m.MarkerText in ('dial', 'start dial')
	and m.msgtime<= mos.min_Time_Mos

delete _Markers_MOS_ant where idMos <> 1

exec sp_lcc_dropifexists '_vlcc_Layer3_comp_MOS_ant'
select  m.*,
		row_number () over (partition by m.sessionid, l3_message order by m.msgtime desc) as idMos
into _vlcc_Layer3_comp_MOS_ant
from _vlcc_Layer3_comp_all m
	inner join _mos_MOS mos on m.sessionid=mos.sessionid or m.sessionid=mos.sessionidB
	--Acotamos a los momentos posteriores al Dial
	left join _Markers_MOS_ant e on (m.sessionid=e.sessionid or m.sessionid=e.sessionidB) and e.MarkerText='Dial'
where l3_message in ('alerting', 'connect','Extended service request', 'CM Service Request', 'Call Confirmed','Connect Acknowledge')
	and m.msgtime<= mos.min_Time_Mos
	and m.msgtime>=e.msgtime

delete _vlcc_Layer3_comp_MOS_ant where idMos <> 1

exec sp_lcc_dropifexists '_vIMSSIPMessage_MOS_ant'
select  m.*,
		row_number () over (partition by m.sessionid, message order by m.msgtime desc) as idMos
into _vIMSSIPMessage_MOS_ant
from _vIMSSIPMessage_all m
	inner join _mos_MOS mos on m.sessionid=mos.sessionid or m.sessionid=mos.sessionidB
	--Acotamos a los momentos posteriores al Dial
	left join _Markers_MOS_ant e on (m.sessionid=e.sessionid or m.sessionid=e.sessionidB) and e.MarkerText='Dial'
where message in ('Request','Alerting','Connect','Trying','ConnectAck')
	and m.msgtime<= mos.min_Time_Mos
	and m.msgtime>=e.msgtime

delete _vIMSSIPMessage_MOS_ant where idMos <> 1



exec sp_lcc_dropifexists '_Markers_MOS_post'
select  m.*,
		row_number () over (partition by m.sessionid, m.MarkerText order by m.msgtime asc) as idMos
into _Markers_MOS_post
from _Markers_all m 
	inner join _mos_MOS mos on m.sessionid=mos.sessionid or m.sessionid=mos.sessionidB
where m.MarkerText in ('released')
	and m.msgtime> mos.max_Time_Mos

delete _Markers_MOS_post where idMos <> 1

exec sp_lcc_dropifexists '_vlcc_Layer3_comp_MOS_post'
select  m.*,
		row_number () over (partition by m.sessionid, l3_message order by msgtime asc) as idMos
into _vlcc_Layer3_comp_MOS_post
from _vlcc_Layer3_comp_all m
	inner join _mos_MOS mos on m.sessionid=mos.sessionid or m.sessionid=mos.sessionidB
where l3_message in ('disconnect')
	and m.msgtime> mos.max_Time_Mos

delete _vlcc_Layer3_comp_MOS_post where idMos <> 1

exec sp_lcc_dropifexists '_vlcc_Layer3_comp_MOS_ant_RRC'
select m.*,
		row_number () over (partition by m.sessionid, m.l3_message order by m.msgtime desc) as idMos
into _vlcc_Layer3_comp_MOS_ant_RRC
from _vlcc_Layer3_comp_all m 
	inner join _mos_MOS mos on m.sessionid=mos.sessionid or m.sessionid=mos.sessionidB
	--Acotamos el momento de RRCConnectionRequest a despues del Extended SR
	left join _vlcc_Layer3_comp_MOS_ant e on m.sessionid=e.sessionid and e.l3_message='Extended service request'
	--Acotamos el momento de RRCConnectionRequest a antes del Disconnect
	left join _vlcc_Layer3_comp_MOS_post f on m.sessionid=f.sessionid
where m.l3_message in ('RRCConnectionRequest')
	and m.msgtime> e.msgtime
	and m.msgtime< f.msgtime
	and m.msgtime<= mos.min_Time_Mos

insert into _vlcc_Layer3_comp_MOS_ant
select *
from _vlcc_Layer3_comp_MOS_ant_RRC 
where idMos=1


exec sp_lcc_dropifexists '_vIMSSIPMessage_MOS_post'
select  m.*,
		row_number () over (partition by m.sessionid, message order by msgtime asc) as idMos
into _vIMSSIPMessage_MOS_post
from _vIMSSIPMessage_all m
	inner join _mos_MOS mos on m.sessionid=mos.sessionid or m.sessionid=mos.sessionidB
where message='Disconnect' 
	and m.msgtime> mos.max_Time_Mos

delete _vIMSSIPMessage_MOS_post where idMos <> 1



---------------------------------------------------
--Calculo 2º lcc_markers_time_Last: Si no tenemos speech de voz tomamos los eventos sin acotar (sólo para el caso de las llamadas tipo Failed)
---------------------------------------------------
exec sp_lcc_dropifexists '_Markers_last'

select m.*,sb.sessionid as sessionidB,
		row_number () over (partition by m.sessionid, m.MarkerText order by m.msgtime asc) as idLast
into _Markers_last
from _Markers_all m 
inner join sessionsb sb
on m.sessionid=sb.sessionidA 
--left join  callanalysis c on m.sessionid=c.sessionid
--where c.callStatus in ('Dropped','Failed')

delete from _Markers_last where idLast<>1

exec sp_lcc_dropifexists '_vlcc_Layer3_comp_last'

select m.*,
		row_number () over (partition by m.sessionid, l3_message order by m.msgtime asc) as idLast
into _vlcc_Layer3_comp_last
from _vlcc_Layer3_comp_all m
--Acotamos a los momentos posteriores al Dial
left join _Markers_MOS_ant e1 on (m.sessionid=e1.sessionid or m.sessionid=e1.sessionidB) and e1.MarkerText='Dial'
left join _Markers_last e2 on (m.sessionid=e2.sessionid or m.sessionid=e2.sessionidB) and e2.MarkerText='Dial'
--left join callanalysis c on m.sessionid=c.sessionid
where m.l3_message in ('alerting', 'connect','Extended service request', 'disconnect', 'CM Service Request', 'Call Confirmed','Connect Acknowledge')
	and m.msgtime>=isnull(e1.msgtime,e2.msgtime)

delete from _vlcc_Layer3_comp_last where idLast<>1

exec sp_lcc_dropifexists '_vlcc_Layer3_comp_last_RRC'
select  m.sessionid,m.msgtime,m.l3_message,m.bcch,m.technology,m.id,
		row_number () over (partition by m.sessionid, m.l3_message order by m.msgtime asc) as idLast
into _vlcc_Layer3_comp_last_RRC
from _vlcc_Layer3_comp_all m 
	left join _vlcc_Layer3_comp_last e on m.sessionid=e.sessionid and e.l3_message='Extended service request'
	left join _vlcc_Layer3_comp_last f on m.sessionid=f.sessionid and e.l3_message='Disconnect'
	--left join callanalysis c on m.sessionid=c.sessionid
where m.l3_message in ('RRCConnectionRequest')
	and m.msgtime> e.msgtime
	and m.msgtime< f.msgtime
	--and c.callstatus in ('Dropped','Failed')

insert into _vlcc_Layer3_comp_last
select *
from _vlcc_Layer3_comp_last_RRC 
where idLast=1

exec sp_lcc_dropifexists '_vIMSSIPMessage_last'

select m.*,
		row_number () over (partition by m.sessionid, message order by m.msgtime asc) as idLast
into _vIMSSIPMessage_last
from _vIMSSIPMessage_all m
--left join callanalysis c on m.sessionid=c.sessionid
--where c.callstatus in ('Dropped','Failed')

delete _vIMSSIPMessage_last where idLast <> 1

---------------------------------------------------
--Tablas con informacion de los eventos
---------------------------------------------------
--Eventos anterios al MOS vs Eventos ultimos
exec sp_lcc_dropifexists '_Dial'
select s.sessionid, s.fileid, 
	case when Dial_time_ant.msgtime is not null then Dial_time_ant.msgtime else Dial_time_last.msgtime end as Dial_time,
	case when Dial_time_ant.bcch is not null then Dial_time_ant.bcch else Dial_time_last.bcch end as Dial_bcch,
	case when Dial_time_ant.technology is not null then Dial_time_ant.technology else Dial_time_last.technology end as Dial_tech
into _Dial
from sessions s inner join SessionsB b on s.SessionId=b.SessionIdA
	left join _Markers_MOS_ant Dial_time_ant 
		on Dial_time_ant.sessionid=s.SessionId and Dial_time_ant.MarkerText='dial'
	left join _Markers_last Dial_time_last 
		on Dial_time_last.sessionid=s.SessionId and Dial_time_last.MarkerText='dial'
where s.valid=1
	and s.SessionId > @maxSession

exec sp_lcc_dropifexists '_start_Dial'
select s.sessionid, s.fileid, 
	case when start_Dial_time_ant.msgtime is not null then start_Dial_time_ant.msgtime else start_Dial_time_last.msgtime end as start_Dial_time,
	case when start_Dial_time_ant.bcch is not null then start_Dial_time_ant.bcch else start_Dial_time_last.bcch end as start_Dial_bcch,
	case when start_Dial_time_ant.technology is not null then start_Dial_time_ant.technology else start_Dial_time_last.technology end as start_Dial_tech
into _start_Dial
from sessions s inner join SessionsB b on s.SessionId=b.SessionIdA
	left join _Markers_MOS_ant start_Dial_time_ant 
		on start_Dial_time_ant.sessionid=s.SessionId and start_Dial_time_ant.MarkerText='start dial'
	left join _Markers_last start_Dial_time_last 
		on start_Dial_time_last.sessionid=s.SessionId and start_Dial_time_last.MarkerText='start dial'
where s.valid=1
	and s.SessionId > @maxSession

exec sp_lcc_dropifexists '_Alerting'
select s.sessionid, s.fileid, 
	case when Alerting_time_ant_A.msgtime is not null then Alerting_time_ant_A.msgtime else Alerting_time_last_A.msgtime end as Alerting_time_A,
	case when Alerting_time_ant_A.bcch is not null then Alerting_time_ant_A.bcch else Alerting_time_last_A.bcch end as Alerting_bcch_A,
	case when Alerting_time_ant_A.technology is not null then Alerting_time_ant_A.technology else Alerting_time_last_A.technology end as Alerting_tech_A,
	case when Alerting_time_ant_B.msgtime is not null then Alerting_time_ant_B.msgtime else Alerting_time_last_B.msgtime end as Alerting_time_B,
	case when Alerting_time_ant_B.bcch is not null then Alerting_time_ant_B.bcch else Alerting_time_last_B.bcch end as Alerting_bcch_B,
	case when Alerting_time_ant_B.technology is not null then Alerting_time_ant_B.technology else Alerting_time_last_B.technology end as Alerting_tech_B
into _Alerting
from sessions s inner join SessionsB b on s.SessionId=b.SessionIdA
	left join _vlcc_Layer3_comp_MOS_ant Alerting_time_ant_A 
		on Alerting_time_ant_A.sessionid=s.SessionId and Alerting_time_ant_A.l3_message='Alerting'
	left join _vlcc_Layer3_comp_last Alerting_time_last_A 
		on Alerting_time_last_A.sessionid=s.SessionId and Alerting_time_last_A.l3_message='Alerting'
		
	left join _vlcc_Layer3_comp_MOS_ant Alerting_time_ant_B 
		on Alerting_time_ant_B.sessionid=b.SessionId and Alerting_time_ant_B.l3_message='Alerting'
	left join _vlcc_Layer3_comp_last Alerting_time_last_B 
		on Alerting_time_last_B.sessionid=b.SessionId and Alerting_time_last_B.l3_message='Alerting'
where s.valid=1
	and s.SessionId > @maxSession

exec sp_lcc_dropifexists '_Connect'
select s.sessionid, s.fileid, 
	case when Connect_time_ant_A.msgtime is not null then Connect_time_ant_A.msgtime else Connect_time_last_A.msgtime end as Connect_time_A,
	case when Connect_time_ant_A.bcch is not null then Connect_time_ant_A.bcch else Connect_time_last_A.bcch end as Connect_bcch_A,
	case when Connect_time_ant_A.technology is not null then Connect_time_ant_A.technology else Connect_time_last_A.technology end as Connect_tech_A,
	case when Connect_time_ant_B.msgtime is not null then Connect_time_ant_B.msgtime else Connect_time_last_B.msgtime end as Connect_time_B,
	case when Connect_time_ant_B.bcch is not null then Connect_time_ant_B.bcch else Connect_time_last_B.bcch end as Connect_bcch_B,
	case when Connect_time_ant_B.technology is not null then Connect_time_ant_B.technology else Connect_time_last_B.technology end as Connect_tech_B
into _Connect
from sessions s inner join SessionsB b on s.SessionId=b.SessionIdA
	left join _vlcc_Layer3_comp_MOS_ant Connect_time_ant_A 
		on Connect_time_ant_A.sessionid=s.SessionId and Connect_time_ant_A.l3_message='Connect'
	left join _vlcc_Layer3_comp_last Connect_time_last_A 
		on Connect_time_last_A.sessionid=s.SessionId and Connect_time_last_A.l3_message='Connect'
		
	left join _vlcc_Layer3_comp_MOS_ant Connect_time_ant_B 
		on Connect_time_ant_B.sessionid=b.SessionId and Connect_time_ant_B.l3_message='Connect'
	left join _vlcc_Layer3_comp_last Connect_time_last_B 
		on Connect_time_last_B.sessionid=b.SessionId and Connect_time_last_B.l3_message='Connect'
where s.valid=1
	and s.SessionId > @maxSession	

exec sp_lcc_dropifexists '_ExtendedSR'
select s.sessionid, s.fileid, 
	case when ExtendedSR_time_ant_A.msgtime is not null then ExtendedSR_time_ant_A.msgtime else ExtendedSR_time_last_A.msgtime end as ExtendedSR_time_A,
	case when ExtendedSR_time_ant_A.bcch is not null then ExtendedSR_time_ant_A.bcch else ExtendedSR_time_last_A.bcch end as ExtendedSR_bcch_A,
	case when ExtendedSR_time_ant_A.technology is not null then ExtendedSR_time_ant_A.technology else ExtendedSR_time_last_A.technology end as ExtendedSR_tech_A,
	case when ExtendedSR_time_ant_B.msgtime is not null then ExtendedSR_time_ant_B.msgtime else ExtendedSR_time_last_B.msgtime end as ExtendedSR_time_B,
	case when ExtendedSR_time_ant_B.bcch is not null then ExtendedSR_time_ant_B.bcch else ExtendedSR_time_last_B.bcch end as ExtendedSR_bcch_B,
	case when ExtendedSR_time_ant_B.technology is not null then ExtendedSR_time_ant_B.technology else ExtendedSR_time_last_B.technology end as ExtendedSR_tech_B
into _ExtendedSR
from sessions s inner join SessionsB b on s.SessionId=b.SessionIdA
	left join _vlcc_Layer3_comp_MOS_ant ExtendedSR_time_ant_A 
		on ExtendedSR_time_ant_A.sessionid=s.SessionId and ExtendedSR_time_ant_A.l3_message='Extended service request'
	left join _vlcc_Layer3_comp_last ExtendedSR_time_last_A 
		on ExtendedSR_time_last_A.sessionid=s.SessionId and ExtendedSR_time_last_A.l3_message='Extended service request'
		
	left join _vlcc_Layer3_comp_MOS_ant ExtendedSR_time_ant_B 
		on ExtendedSR_time_ant_B.sessionid=b.SessionId and ExtendedSR_time_ant_B.l3_message='Extended service request'
	left join _vlcc_Layer3_comp_last ExtendedSR_time_last_B 
		on ExtendedSR_time_last_B.sessionid=b.SessionId and ExtendedSR_time_last_B.l3_message='Extended service request'
where s.valid=1
	and s.SessionId > @maxSession	

exec sp_lcc_dropifexists '_RRCConnect'
select s.sessionid, s.fileid, 
	case when RRCConnect_time_ant_A.msgtime is not null then RRCConnect_time_ant_A.msgtime else RRCConnect_time_last_A.msgtime end as RRCConnect_time_A,
	case when RRCConnect_time_ant_A.bcch is not null then RRCConnect_time_ant_A.bcch else RRCConnect_time_last_A.bcch end as RRCConnect_bcch_A,
	case when RRCConnect_time_ant_A.technology is not null then RRCConnect_time_ant_A.technology else RRCConnect_time_last_A.technology end as RRCConnect_tech_A,
	case when RRCConnect_time_ant_B.msgtime is not null then RRCConnect_time_ant_B.msgtime else RRCConnect_time_last_B.msgtime end as RRCConnect_time_B,
	case when RRCConnect_time_ant_B.bcch is not null then RRCConnect_time_ant_B.bcch else RRCConnect_time_last_B.bcch end as RRCConnect_bcch_B,
	case when RRCConnect_time_ant_B.technology is not null then RRCConnect_time_ant_B.technology else RRCConnect_time_last_B.technology end as RRCConnect_tech_B
into _RRCConnect
from sessions s inner join SessionsB b on s.SessionId=b.SessionIdA
	left join _vlcc_Layer3_comp_MOS_ant RRCConnect_time_ant_A 
		on RRCConnect_time_ant_A.sessionid=s.SessionId and RRCConnect_time_ant_A.l3_message='RRCConnectionRequest'
	left join _vlcc_Layer3_comp_last RRCConnect_time_last_A 
		on RRCConnect_time_last_A.sessionid=s.SessionId and RRCConnect_time_last_A.l3_message='RRCConnectionRequest'
		
	left join _vlcc_Layer3_comp_MOS_ant RRCConnect_time_ant_B 
		on RRCConnect_time_ant_B.sessionid=b.SessionId and RRCConnect_time_ant_B.l3_message='RRCConnectionRequest'
	left join _vlcc_Layer3_comp_last RRCConnect_time_last_B 
		on RRCConnect_time_last_B.sessionid=b.SessionId and RRCConnect_time_last_B.l3_message='RRCConnectionRequest'
where s.valid=1
	and s.SessionId > @maxSession	

exec sp_lcc_dropifexists '_Ringing'
select s.sessionid, s.fileid, 
	case when Ringing_time_ant_A.msgtime is not null then Ringing_time_ant_A.msgtime else Ringing_time_last_A.msgtime end as Ringing_time_A,
	case when Ringing_time_ant_A.bcch is not null then Ringing_time_ant_A.bcch else Ringing_time_last_A.bcch end as Ringing_bcch_A,
	case when Ringing_time_ant_A.technology is not null then Ringing_time_ant_A.technology else Ringing_time_last_A.technology end as Ringing_tech_A,
	case when Ringing_time_ant_B.msgtime is not null then Ringing_time_ant_B.msgtime else Ringing_time_last_B.msgtime end as Ringing_time_B,
	case when Ringing_time_ant_B.bcch is not null then Ringing_time_ant_B.bcch else Ringing_time_last_B.bcch end as Ringing_bcch_B,
	case when Ringing_time_ant_B.technology is not null then Ringing_time_ant_B.technology else Ringing_time_last_B.technology end as Ringing_tech_B
into _Ringing
from sessions s inner join SessionsB b on s.SessionId=b.SessionIdA
	left join _vIMSSIPMessage_MOS_ant Ringing_time_ant_A 
		on Ringing_time_ant_A.sessionid=s.SessionId and Ringing_time_ant_A.message='Alerting'
	left join _vIMSSIPMessage_last Ringing_time_last_A 
		on Ringing_time_last_A.sessionid=s.SessionId and Ringing_time_last_A.message='Alerting'
		
	left join _vIMSSIPMessage_MOS_ant Ringing_time_ant_B 
		on Ringing_time_ant_B.sessionid=b.SessionId and Ringing_time_ant_B.message='Alerting'
	left join _vIMSSIPMessage_last Ringing_time_last_B 
		on Ringing_time_last_B.sessionid=b.SessionId and Ringing_time_last_B.message='Alerting'
where s.valid=1
	and s.SessionId > @maxSession

exec sp_lcc_dropifexists '_Accept'
select s.sessionid, s.fileid, 
	case when Accept_time_ant_A.msgtime is not null then Accept_time_ant_A.msgtime else Accept_time_last_A.msgtime end as Accept_time_A,
	case when Accept_time_ant_A.bcch is not null then Accept_time_ant_A.bcch else Accept_time_last_A.bcch end as Accept_bcch_A,
	case when Accept_time_ant_A.technology is not null then Accept_time_ant_A.technology else Accept_time_last_A.technology end as Accept_tech_A,
	case when Accept_time_ant_B.msgtime is not null then Accept_time_ant_B.msgtime else Accept_time_last_B.msgtime end as Accept_time_B,
	case when Accept_time_ant_B.bcch is not null then Accept_time_ant_B.bcch else Accept_time_last_B.bcch end as Accept_bcch_B,
	case when Accept_time_ant_B.technology is not null then Accept_time_ant_B.technology else Accept_time_last_B.technology end as Accept_tech_B
into _Accept
from sessions s inner join SessionsB b on s.SessionId=b.SessionIdA
	left join _vIMSSIPMessage_MOS_ant Accept_time_ant_A 
		on Accept_time_ant_A.sessionid=s.SessionId and Accept_time_ant_A.message='Connect'
	left join _vIMSSIPMessage_last Accept_time_last_A 
		on Accept_time_last_A.sessionid=s.SessionId and Accept_time_last_A.message='Connect'
		
	left join _vIMSSIPMessage_MOS_ant Accept_time_ant_B 
		on Accept_time_ant_B.sessionid=b.SessionId and Accept_time_ant_B.message='Connect'
	left join _vIMSSIPMessage_last Accept_time_last_B 
		on Accept_time_last_B.sessionid=b.SessionId and Accept_time_last_B.message='Connect'
where s.valid=1
	and s.SessionId > @maxSession

exec sp_lcc_dropifexists '_CMServiceRequest'
select s.sessionid, s.fileid, 
	case when CMServiceRequest_time_ant_A.msgtime is not null then CMServiceRequest_time_ant_A.msgtime else CMServiceRequest_time_last_A.msgtime end as CMServiceRequest_time_A,
	case when CMServiceRequest_time_ant_A.bcch is not null then CMServiceRequest_time_ant_A.bcch else CMServiceRequest_time_last_A.bcch end as CMServiceRequest_bcch_A,
	case when CMServiceRequest_time_ant_A.technology is not null then CMServiceRequest_time_ant_A.technology else CMServiceRequest_time_last_A.technology end as CMServiceRequest_tech_A,
	case when CMServiceRequest_time_ant_B.msgtime is not null then CMServiceRequest_time_ant_B.msgtime else CMServiceRequest_time_last_B.msgtime end as CMServiceRequest_time_B,
	case when CMServiceRequest_time_ant_B.bcch is not null then CMServiceRequest_time_ant_B.bcch else CMServiceRequest_time_last_B.bcch end as CMServiceRequest_bcch_B,
	case when CMServiceRequest_time_ant_B.technology is not null then CMServiceRequest_time_ant_B.technology else CMServiceRequest_time_last_B.technology end as CMServiceRequest_tech_B
into _CMServiceRequest
from sessions s inner join SessionsB b on s.SessionId=b.SessionIdA
	left join _vlcc_Layer3_comp_MOS_ant CMServiceRequest_time_ant_A 
		on CMServiceRequest_time_ant_A.sessionid=s.SessionId and CMServiceRequest_time_ant_A.l3_message='CM Service Request'
	left join _vlcc_Layer3_comp_last CMServiceRequest_time_last_A 
		on CMServiceRequest_time_last_A.sessionid=s.SessionId and CMServiceRequest_time_last_A.l3_message='CM Service Request'
		
	left join _vlcc_Layer3_comp_MOS_ant CMServiceRequest_time_ant_B 
		on CMServiceRequest_time_ant_B.sessionid=b.SessionId and CMServiceRequest_time_ant_B.l3_message='CM Service Request'
	left join _vlcc_Layer3_comp_last CMServiceRequest_time_last_B 
		on CMServiceRequest_time_last_B.sessionid=b.SessionId and CMServiceRequest_time_last_B.l3_message='CM Service Request'
where s.valid=1
	and s.SessionId > @maxSession	

exec sp_lcc_dropifexists '_CallConfirmed'
select s.sessionid, s.fileid, 
	case when CallConfirmed_time_ant_A.msgtime is not null then CallConfirmed_time_ant_A.msgtime else CallConfirmed_time_last_A.msgtime end as CallConfirmed_time_A,
	case when CallConfirmed_time_ant_A.bcch is not null then CallConfirmed_time_ant_A.bcch else CallConfirmed_time_last_A.bcch end as CallConfirmed_bcch_A,
	case when CallConfirmed_time_ant_A.technology is not null then CallConfirmed_time_ant_A.technology else CallConfirmed_time_last_A.technology end as CallConfirmed_tech_A,
	case when CallConfirmed_time_ant_B.msgtime is not null then CallConfirmed_time_ant_B.msgtime else CallConfirmed_time_last_B.msgtime end as CallConfirmed_time_B,
	case when CallConfirmed_time_ant_B.bcch is not null then CallConfirmed_time_ant_B.bcch else CallConfirmed_time_last_B.bcch end as CallConfirmed_bcch_B,
	case when CallConfirmed_time_ant_B.technology is not null then CallConfirmed_time_ant_B.technology else CallConfirmed_time_last_B.technology end as CallConfirmed_tech_B
into _CallConfirmed
from sessions s inner join SessionsB b on s.SessionId=b.SessionIdA
	left join _vlcc_Layer3_comp_MOS_ant CallConfirmed_time_ant_A 
		on CallConfirmed_time_ant_A.sessionid=s.SessionId and CallConfirmed_time_ant_A.l3_message='Call Confirmed'
	left join _vlcc_Layer3_comp_last CallConfirmed_time_last_A 
		on CallConfirmed_time_last_A.sessionid=s.SessionId and CallConfirmed_time_last_A.l3_message='Call Confirmed'
		
	left join _vlcc_Layer3_comp_MOS_ant CallConfirmed_time_ant_B 
		on CallConfirmed_time_ant_B.sessionid=b.SessionId and CallConfirmed_time_ant_B.l3_message='Call Confirmed'
	left join _vlcc_Layer3_comp_last CallConfirmed_time_last_B 
		on CallConfirmed_time_last_B.sessionid=b.SessionId and CallConfirmed_time_last_B.l3_message='Call Confirmed'
where s.valid=1
	and s.SessionId > @maxSession	

exec sp_lcc_dropifexists '_ConnectAck'
select s.sessionid, s.fileid, 
	case when ConnectAck_time_ant_A.msgtime is not null then ConnectAck_time_ant_A.msgtime else ConnectAck_time_last_A.msgtime end as ConnectAck_time_A,
	case when ConnectAck_time_ant_A.bcch is not null then ConnectAck_time_ant_A.bcch else ConnectAck_time_last_A.bcch end as ConnectAck_bcch_A,
	case when ConnectAck_time_ant_A.technology is not null then ConnectAck_time_ant_A.technology else ConnectAck_time_last_A.technology end as ConnectAck_tech_A,
	case when ConnectAck_time_ant_B.msgtime is not null then ConnectAck_time_ant_B.msgtime else ConnectAck_time_last_B.msgtime end as ConnectAck_time_B,
	case when ConnectAck_time_ant_B.bcch is not null then ConnectAck_time_ant_B.bcch else ConnectAck_time_last_B.bcch end as ConnectAck_bcch_B,
	case when ConnectAck_time_ant_B.technology is not null then ConnectAck_time_ant_B.technology else ConnectAck_time_last_B.technology end as ConnectAck_tech_B
into _ConnectAck
from sessions s inner join SessionsB b on s.SessionId=b.SessionIdA
	left join _vlcc_Layer3_comp_MOS_ant ConnectAck_time_ant_A 
		on ConnectAck_time_ant_A.sessionid=s.SessionId and ConnectAck_time_ant_A.l3_message='Connect Acknowledge'
	left join _vlcc_Layer3_comp_last ConnectAck_time_last_A 
		on ConnectAck_time_last_A.sessionid=s.SessionId and ConnectAck_time_last_A.l3_message='Connect Acknowledge'
		
	left join _vlcc_Layer3_comp_MOS_ant ConnectAck_time_ant_B 
		on ConnectAck_time_ant_B.sessionid=b.SessionId and ConnectAck_time_ant_B.l3_message='Connect Acknowledge'
	left join _vlcc_Layer3_comp_last ConnectAck_time_last_B 
		on ConnectAck_time_last_B.sessionid=b.SessionId and ConnectAck_time_last_B.l3_message='Connect Acknowledge'
where s.valid=1
	and s.SessionId > @maxSession

exec sp_lcc_dropifexists '_Request'
select s.sessionid, s.fileid, 
	case when Request_time_ant_A.msgtime is not null then Request_time_ant_A.msgtime else Request_time_last_A.msgtime end as Request_time_A,
	case when Request_time_ant_A.bcch is not null then Request_time_ant_A.bcch else Request_time_last_A.bcch end as Request_bcch_A,
	case when Request_time_ant_A.technology is not null then Request_time_ant_A.technology else Request_time_last_A.technology end as Request_tech_A,
	case when Request_time_ant_B.msgtime is not null then Request_time_ant_B.msgtime else Request_time_last_B.msgtime end as Request_time_B,
	case when Request_time_ant_B.bcch is not null then Request_time_ant_B.bcch else Request_time_last_B.bcch end as Request_bcch_B,
	case when Request_time_ant_B.technology is not null then Request_time_ant_B.technology else Request_time_last_B.technology end as Request_tech_B
into _Request
from sessions s inner join SessionsB b on s.SessionId=b.SessionIdA
	left join _vIMSSIPMessage_MOS_ant Request_time_ant_A 
		on Request_time_ant_A.sessionid=s.SessionId and Request_time_ant_A.message='Request'
	left join _vIMSSIPMessage_last Request_time_last_A 
		on Request_time_last_A.sessionid=s.SessionId and Request_time_last_A.message='Request'
		
	left join _vIMSSIPMessage_MOS_ant Request_time_ant_B 
		on Request_time_ant_B.sessionid=b.SessionId and Request_time_ant_B.message='Request'
	left join _vIMSSIPMessage_last Request_time_last_B 
		on Request_time_last_B.sessionid=b.SessionId and Request_time_last_B.message='Request'
where s.valid=1
	and s.SessionId > @maxSession	

exec sp_lcc_dropifexists '_Trying'
select s.sessionid, s.fileid, 
	case when Trying_time_ant_A.msgtime is not null then Trying_time_ant_A.msgtime else Trying_time_last_A.msgtime end as Trying_time_A,
	case when Trying_time_ant_A.bcch is not null then Trying_time_ant_A.bcch else Trying_time_last_A.bcch end as Trying_bcch_A,
	case when Trying_time_ant_A.technology is not null then Trying_time_ant_A.technology else Trying_time_last_A.technology end as Trying_tech_A,
	case when Trying_time_ant_B.msgtime is not null then Trying_time_ant_B.msgtime else Trying_time_last_B.msgtime end as Trying_time_B,
	case when Trying_time_ant_B.bcch is not null then Trying_time_ant_B.bcch else Trying_time_last_B.bcch end as Trying_bcch_B,
	case when Trying_time_ant_B.technology is not null then Trying_time_ant_B.technology else Trying_time_last_B.technology end as Trying_tech_B
into _Trying
from sessions s inner join SessionsB b on s.SessionId=b.SessionIdA
	left join _vIMSSIPMessage_MOS_ant Trying_time_ant_A 
		on Trying_time_ant_A.sessionid=s.SessionId and Trying_time_ant_A.message='Trying'
	left join _vIMSSIPMessage_last Trying_time_last_A 
		on Trying_time_last_A.sessionid=s.SessionId and Trying_time_last_A.message='Trying'
		
	left join _vIMSSIPMessage_MOS_ant Trying_time_ant_B 
		on Trying_time_ant_B.sessionid=b.SessionId and Trying_time_ant_B.message='Trying'
	left join _vIMSSIPMessage_last Trying_time_last_B 
		on Trying_time_last_B.sessionid=b.SessionId and Trying_time_last_B.message='Trying'
where s.valid=1
	and s.SessionId > @maxSession	

exec sp_lcc_dropifexists '_ConnectAckVOLTE'
select s.sessionid, s.fileid, 
	case when ConnectAckVOLTE_time_ant_A.msgtime is not null then ConnectAckVOLTE_time_ant_A.msgtime else ConnectAckVOLTE_time_last_A.msgtime end as ConnectAckVOLTE_time_A,
	case when ConnectAckVOLTE_time_ant_A.bcch is not null then ConnectAckVOLTE_time_ant_A.bcch else ConnectAckVOLTE_time_last_A.bcch end as ConnectAckVOLTE_bcch_A,
	case when ConnectAckVOLTE_time_ant_A.technology is not null then ConnectAckVOLTE_time_ant_A.technology else ConnectAckVOLTE_time_last_A.technology end as ConnectAckVOLTE_tech_A,
	case when ConnectAckVOLTE_time_ant_B.msgtime is not null then ConnectAckVOLTE_time_ant_B.msgtime else ConnectAckVOLTE_time_last_B.msgtime end as ConnectAckVOLTE_time_B,
	case when ConnectAckVOLTE_time_ant_B.bcch is not null then ConnectAckVOLTE_time_ant_B.bcch else ConnectAckVOLTE_time_last_B.bcch end as ConnectAckVOLTE_bcch_B,
	case when ConnectAckVOLTE_time_ant_B.technology is not null then ConnectAckVOLTE_time_ant_B.technology else ConnectAckVOLTE_time_last_B.technology end as ConnectAckVOLTE_tech_B
into _ConnectAckVOLTE
from sessions s inner join SessionsB b on s.SessionId=b.SessionIdA
	left join _vIMSSIPMessage_MOS_ant ConnectAckVOLTE_time_ant_A 
		on ConnectAckVOLTE_time_ant_A.sessionid=s.SessionId and ConnectAckVOLTE_time_ant_A.message='ConnectAck'
	left join _vIMSSIPMessage_last ConnectAckVOLTE_time_last_A 
		on ConnectAckVOLTE_time_last_A.sessionid=s.SessionId and ConnectAckVOLTE_time_last_A.message='ConnectAck'
		
	left join _vIMSSIPMessage_MOS_ant ConnectAckVOLTE_time_ant_B 
		on ConnectAckVOLTE_time_ant_B.sessionid=b.SessionId and ConnectAckVOLTE_time_ant_B.message='ConnectAck'
	left join _vIMSSIPMessage_last ConnectAckVOLTE_time_last_B 
		on ConnectAckVOLTE_time_last_B.sessionid=b.SessionId and ConnectAckVOLTE_time_last_B.message='ConnectAck'
where s.valid=1
	and s.SessionId > @maxSession


--Eventos posteriore al MOS vs Eventos ultimos
exec sp_lcc_dropifexists '_released'
select s.sessionid, s.fileid, 
	case when released_time_post.msgtime is not null then released_time_post.msgtime else released_time_last.msgtime end as released_time,
	case when released_time_post.bcch is not null then released_time_post.bcch else released_time_last.bcch end as released_bcch,
	case when released_time_post.technology is not null then released_time_post.technology else released_time_last.technology end as released_tech
into _released
from sessions s inner join SessionsB b on s.SessionId=b.SessionIdA
	left join _Markers_MOS_post released_time_post 
		on released_time_post.sessionid=s.SessionId and released_time_post.MarkerText='released'
	left join _Markers_last released_time_last 
		on released_time_last.sessionid=s.SessionId and released_time_last.MarkerText='released'
where s.valid=1
	and s.SessionId > @maxSession

exec sp_lcc_dropifexists '_Disconnect'
select s.sessionid, s.fileid, 
	case when Disconnect_time_post_A.msgtime is not null then Disconnect_time_post_A.msgtime else Disconnect_time_last_A.msgtime end as Disconnect_time_A,
	case when Disconnect_time_post_A.bcch is not null then Disconnect_time_post_A.bcch else Disconnect_time_last_A.bcch end as Disconnect_bcch_A,
	case when Disconnect_time_post_A.technology is not null then Disconnect_time_post_A.technology else Disconnect_time_last_A.technology end as Disconnect_tech_A,
	case when Disconnect_time_post_B.msgtime is not null then Disconnect_time_post_B.msgtime else Disconnect_time_last_B.msgtime end as Disconnect_time_B,
	case when Disconnect_time_post_B.bcch is not null then Disconnect_time_post_B.bcch else Disconnect_time_last_B.bcch end as Disconnect_bcch_B,
	case when Disconnect_time_post_B.technology is not null then Disconnect_time_post_B.technology else Disconnect_time_last_B.technology end as Disconnect_tech_B
into _Disconnect
from sessions s inner join SessionsB b on s.SessionId=b.SessionIdA
	left join _vlcc_Layer3_comp_MOS_post Disconnect_time_post_A 
		on Disconnect_time_post_A.sessionid=s.SessionId and Disconnect_time_post_A.l3_message='Disconnect'
	left join _vlcc_Layer3_comp_last Disconnect_time_last_A 
		on Disconnect_time_last_A.sessionid=s.SessionId and Disconnect_time_last_A.l3_message='Disconnect'		
	left join _vlcc_Layer3_comp_MOS_post Disconnect_time_post_B 
		on Disconnect_time_post_B.sessionid=b.SessionId and Disconnect_time_post_B.l3_message='Disconnect'
	left join _vlcc_Layer3_comp_last Disconnect_time_last_B 
		on Disconnect_time_last_B.sessionid=b.SessionId and Disconnect_time_last_B.l3_message='Disconnect'
where s.valid=1
	and s.SessionId > @maxSession

exec sp_lcc_dropifexists '_DisconnectVOLTE'
select s.sessionid, s.fileid, 
	case when DisconnectVOLTE_time_post_A.msgtime is not null then DisconnectVOLTE_time_post_A.msgtime else DisconnectVOLTE_time_last_A.msgtime end as DisconnectVOLTE_time_A,
	case when DisconnectVOLTE_time_post_A.bcch is not null then DisconnectVOLTE_time_post_A.bcch else DisconnectVOLTE_time_last_A.bcch end as DisconnectVOLTE_bcch_A,
	case when DisconnectVOLTE_time_post_A.technology is not null then DisconnectVOLTE_time_post_A.technology else DisconnectVOLTE_time_last_A.technology end as DisconnectVOLTE_tech_A,
	case when DisconnectVOLTE_time_post_B.msgtime is not null then DisconnectVOLTE_time_post_B.msgtime else DisconnectVOLTE_time_last_B.msgtime end as DisconnectVOLTE_time_B,
	case when DisconnectVOLTE_time_post_B.bcch is not null then DisconnectVOLTE_time_post_B.bcch else DisconnectVOLTE_time_last_B.bcch end as DisconnectVOLTE_bcch_B,
	case when DisconnectVOLTE_time_post_B.technology is not null then DisconnectVOLTE_time_post_B.technology else DisconnectVOLTE_time_last_B.technology end as DisconnectVOLTE_tech_B
into _DisconnectVOLTE
from sessions s inner join SessionsB b on s.SessionId=b.SessionIdA
	left join _vIMSSIPMessage_MOS_post DisconnectVOLTE_time_post_A 
		on DisconnectVOLTE_time_post_A.sessionid=s.SessionId and DisconnectVOLTE_time_post_A.message='Disconnect'
	left join _vIMSSIPMessage_last DisconnectVOLTE_time_last_A 
		on DisconnectVOLTE_time_last_A.sessionid=s.SessionId and DisconnectVOLTE_time_last_A.message='Disconnect'
		
	left join _vIMSSIPMessage_MOS_post DisconnectVOLTE_time_post_B 
		on DisconnectVOLTE_time_post_B.sessionid=b.SessionId and DisconnectVOLTE_time_post_B.message='Disconnect'
	left join _vIMSSIPMessage_last DisconnectVOLTE_time_last_B 
		on DisconnectVOLTE_time_last_B.sessionid=b.SessionId and DisconnectVOLTE_time_last_B.message='Disconnect'
where s.valid=1
	and s.SessionId > @maxSession


insert into lcc_markers_time
select s.sessionid, s.fileid, 
	
	Dial.Dial_time as Dial_time,
	start_Dial.start_Dial_time as start_Dial_time ,
	ExtendedSR.ExtendedSR_Time_A as ExtendedSR_Time_A,	 
	ExtendedSR.ExtendedSR_Time_B as ExtendedSR_Time_B,
	RRCConnect.RRCConnect_Time_A as RRCConnect_Time_A,	 
	RRCConnect.RRCConnect_Time_B as RRCConnect_Time_B,	
	CMServiceRequest.CMServiceRequest_Time_A as CMServiceRequest_Time_A,
	CMServiceRequest.CMServiceRequest_Time_B as CMServiceRequest_Time_B,
	CallConfirmed.CallConfirmed_Time_A as CallConfirmed_Time_A,
	CallConfirmed.CallConfirmed_Time_B as CallConfirmed_Time_B,
	Alerting.Alerting_time_A as Alerting_Time_A,	
	Alerting.Alerting_time_B as Alerting_Time_B,	 
	Conn.Connect_time_A as Connect_Time_A,	
	Conn.Connect_time_B as Connect_Time_B,	 
	ConnectAck.ConnectAck_Time_A as ConnectAck_Time_A,
	ConnectAck.ConnectAck_Time_B as ConnectAck_Time_B,
	Disconnect.Disconnect_Time_A as Disconnect_Time_A,
	Disconnect.Disconnect_Time_B as Disconnect_Time_B,
	Request.Request_Time_A as Request_Time_A,
	Request.Request_Time_B as Request_Time_B,
	Trying.Trying_Time_A as Trying_Time_A,
	Trying.Trying_Time_B as Trying_Time_B,
	Ringing.Ringing_time_A as Ringing_time_A,
	Ringing.Ringing_time_B as Ringing_time_B,
	Accept.Accept_time_A as Accept_time_A,		 
	Accept.Accept_time_B as Accept_time_B,	
	ConnectAckVOLTE.ConnectAckVOLTE_Time_A as ConnectAckVOLTE_Time_A,
	ConnectAckVOLTE.ConnectAckVOLTE_Time_B as  ConnectAckVOLTE_Time_B,
	DisconnectVOLTE.DisconnectVOLTE_Time_A as DisconnectVOLTE_Time_A,
	DisconnectVOLTE.DisconnectVOLTE_Time_B as DisconnectVOLTE_Time_B,
	Release.released_time as Release_time,

	Dial.Dial_tech as Dial_tech,
	start_Dial.start_Dial_tech as start_Dial_tech ,
	ExtendedSR.ExtendedSR_tech_A as ExtendedSR_tech_A,	 
	ExtendedSR.ExtendedSR_tech_B as ExtendedSR_tech_B,
	RRCConnect.RRCConnect_tech_A as RRCConnect_tech_A,	 
	RRCConnect.RRCConnect_tech_B as RRCConnect_tech_B,	
	CMServiceRequest.CMServiceRequest_tech_A as CMServiceRequest_tech_A,
	CMServiceRequest.CMServiceRequest_tech_B as CMServiceRequest_tech_B,
	CallConfirmed.CallConfirmed_tech_A as CallConfirmed_tech_A,
	CallConfirmed.CallConfirmed_tech_B as CallConfirmed_tech_B,
	Alerting.Alerting_tech_A as Alerting_tech_A,	
	Alerting.Alerting_tech_B as Alerting_tech_B,	 
	Conn.Connect_tech_A as Connect_tech_A,	
	Conn.Connect_tech_B as Connect_tech_B,	 
	ConnectAck.ConnectAck_tech_A as ConnectAck_tech_A,
	ConnectAck.ConnectAck_tech_B as ConnectAck_tech_B,
	Disconnect.Disconnect_tech_A as Disconnect_tech_A,
	Disconnect.Disconnect_tech_B as Disconnect_tech_B,
	Request.Request_tech_A as Request_tech_A,
	Request.Request_tech_B as Request_tech_B,
	Trying.Trying_tech_A as Trying_tech_A,
	Trying.Trying_tech_B as Trying_tech_B,
	Ringing.Ringing_tech_A as Ringing_tech_A,
	Ringing.Ringing_tech_B as Ringing_tech_B,
	Accept.Accept_tech_A as Accept_tech_A,		 
	Accept.Accept_tech_B as Accept_tech_B,	
	ConnectAckVOLTE.ConnectAckVOLTE_tech_A as ConnectAckVOLTE_tech_A,
	ConnectAckVOLTE.ConnectAckVOLTE_tech_B as  ConnectAckVOLTE_tech_B,
	DisconnectVOLTE.DisconnectVOLTE_tech_A as DisconnectVOLTE_tech_A,
	DisconnectVOLTE.DisconnectVOLTE_tech_B as DisconnectVOLTE_tech_B,
	Release.released_tech as Release_tech,

	Dial.Dial_bcch as Dial_bcch,
	start_Dial.start_Dial_bcch as start_Dial_bcch ,
	ExtendedSR.ExtendedSR_bcch_A as ExtendedSR_bcch_A,	 
	ExtendedSR.ExtendedSR_bcch_B as ExtendedSR_bcch_B,
	RRCConnect.RRCConnect_bcch_A as RRCConnect_bcch_A,	 
	RRCConnect.RRCConnect_bcch_B as RRCConnect_bcch_B,	
	CMServiceRequest.CMServiceRequest_bcch_A as CMServiceRequest_bcch_A,
	CMServiceRequest.CMServiceRequest_bcch_B as CMServiceRequest_bcch_B,
	CallConfirmed.CallConfirmed_bcch_A as CallConfirmed_bcch_A,
	CallConfirmed.CallConfirmed_bcch_B as CallConfirmed_bcch_B,
	Alerting.Alerting_bcch_A as Alerting_bcch_A,	
	Alerting.Alerting_bcch_B as Alerting_bcch_B,	 
	Conn.Connect_bcch_A as Connect_bcch_A,	
	Conn.Connect_bcch_B as Connect_bcch_B,	 
	ConnectAck.ConnectAck_bcch_A as ConnectAck_bcch_A,
	ConnectAck.ConnectAck_bcch_B as ConnectAck_bcch_B,
	Disconnect.Disconnect_bcch_A as Disconnect_bcch_A,
	Disconnect.Disconnect_bcch_B as Disconnect_bcch_B,
	Request.Request_bcch_A as Request_bcch_A,
	Request.Request_bcch_B as Request_bcch_B,
	Trying.Trying_bcch_A as Trying_bcch_A,
	Trying.Trying_bcch_B as Trying_bcch_B,
	Ringing.Ringing_bcch_A as Ringing_bcch_A,
	Ringing.Ringing_bcch_B as Ringing_bcch_B,
	Accept.Accept_bcch_A as Accept_bcch_A,		 
	Accept.Accept_bcch_B as Accept_bcch_B,	
	ConnectAckVOLTE.ConnectAckVOLTE_bcch_A as ConnectAckVOLTE_bcch_A,
	ConnectAckVOLTE.ConnectAckVOLTE_bcch_B as  ConnectAckVOLTE_bcch_B,
	DisconnectVOLTE.DisconnectVOLTE_bcch_A as DisconnectVOLTE_bcch_A,
	DisconnectVOLTE.DisconnectVOLTE_bcch_B as DisconnectVOLTE_bcch_B,
	Release.released_bcch as Release_bcch,

	Time_Mos.min_Time_Mos as min_Time_Mos,
	Time_Mos.max_Time_Mos as max_Time_Mos

from sessions s inner join SessionsB b on s.SessionId=b.SessionIdA

	left join _Dial Dial
		on Dial.sessionid=s.SessionId
	
	left join _start_Dial start_Dial
		on start_Dial.sessionid=s.SessionId

	left join _released Release
		on Release.sessionid=s.SessionId
	
	left join _Alerting Alerting 
		on Alerting.sessionid=s.SessionId
	 
	left join _Connect Conn
		on Conn.sessionid=s.SessionId 
	 
	left join _ExtendedSR ExtendedSR
		on ExtendedSR.sessionid=s.SessionId
	 
	left join _RRCConnect RRCConnect 
		on RRCConnect.sessionid=s.SessionId
	 
	left join _Ringing Ringing
		on Ringing.sessionid=s.SessionId

	left join _Accept Accept
		on Accept.sessionid=s.SessionId

	left join _CMServiceRequest CMServiceRequest
		on CMServiceRequest.sessionid=s.SessionId
	 
	left join _CallConfirmed CallConfirmed
		on CallConfirmed.sessionid=s.SessionId
	 
	left join _ConnectAck ConnectAck
		on ConnectAck.sessionid=s.SessionId
	
	left join _Disconnect Disconnect
		on Disconnect.sessionid=s.SessionId
	
	left join  _Trying Trying
		on Trying.sessionid=s.SessionId

	left join  _Request Request
		on Request.sessionid=s.SessionId
	
	left join _ConnectAckVOLTE ConnectAckVOLTE
		on ConnectAckVOLTE.sessionid=s.SessionId
	
	left join _DisconnectVOLTE DisconnectVOLTE 
		on DisconnectVOLTE.sessionid=s.SessionId
	
	left join _mos_MOS Time_Mos 
		on Time_Mos.sessionid=s.SessionId

where s.valid=1
	and s.SessionId > @maxSession
   

drop table _mos_MOS,_Markers_all,_vlcc_Layer3_comp_all,_vIMSSIPMessage_all,_Markers_MOS_ant,_vlcc_Layer3_comp_MOS_ant,_vlcc_Layer3_comp_MOS_ant_RRC,
_vIMSSIPMessage_MOS_ant,_Markers_MOS_post,_vlcc_Layer3_comp_MOS_post,_vIMSSIPMessage_MOS_post,
_Markers_last,_vlcc_Layer3_comp_last,_vlcc_Layer3_comp_last_RRC,_vIMSSIPMessage_last,
_Dial,_start_Dial,_Alerting,_Connect,_ExtendedSR,_RRCConnect,_Ringing,_Accept,_CMServiceRequest,_CallConfirmed,_ConnectAck,
_Trying,_Request,_ConnectAckVOLTE,_released,_Disconnect,_DisconnectVOLTE

END

