USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_lcc_core_Voice_CR_Metrics_Table]    Script Date: 23/04/2018 23:36:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[sp_create_lcc_core_Voice_CR_Metrics_Table] 		
		@Config [nvarchar](max)			= 'SpainOSP'
as

-- DESCRIPTION ------------------------------------------------------------------------------------------------------
--
--		* COLLATE Latin1_General_CI_AS	-> database_default
--
--		* Base TABLE/VIEW:		callanalysis	-> both side are considered
--
--		* Updates with layer 3 info and lcc_markers_table
--			CMService_band/Disconnect for both sides - KPIS Star/End techn.
--
--		Código del createVoiceTable - _tCallRes: 
--			Se cuentan los mensajes de CellUpdate con causa 'radiolinkFailure','rlc_unrecoverableError' para el 3G
--			y los 'CM Re-Establishment Request’ para el 2G, tanto en el lado A como en el B
--
--			Pero en la tabla final (lcc_calls_Detailed), solo se tiene en cuenta los del lado A, para generar el campo CR_Affected_calls (campo agregado)

--			En principio el código funciona bien, quedan marcadas las llamadas en las que se han dado los casos descritos, 
--			pero si es verdad que vienen rodeados de huecos en capa 3, o se dan al final de llamada, por lo que no se llega realmente a ver que reconecta tras el intento 
--			(en estos casos la llamada sí que está marcada como completada, eso sí es cierto). 
--
--			Esto pasa principalmente con los CU-3G. Las llamadas con un CR attempt (2G) son caídas en los Benchmarker, 
--			en los FR sí que hay alguna (en los casos en los que hay más de un intento se ve bastante mejor que la llamada continua tras el intento). 

--		Conclusión:  
--			No sé el estado de la Issue abierta al respecto, pero parece tener sentido lo que sacamos en los FR (indoor/aves) por lo menos, 
--			en lo BM (roads) no le veo mucho sentido reportarlo, al menos de momento, ya que en principio esta desactivado 
--			(los CR-2G son dropps y los CU-3G… no los veo esclarecedores, pueden meter más ruido que información de primeras). 
-- 
--			Como los FR son M2F, el campo como tal, contando solo en el lado A estaría correcto (no hay lado B, claro).                
--
---------------------------------------------------------------------------------------------------------------------

exec SQKeyValueInit 'C:\L3KeyValue'

------------------------------------------------ select * from _lcc_c0re_Voice_CR_Metrics_Table
exec sp_lcc_dropifexists '_lcc_c0re_Voice_CR_Metrics_Table'
select 
	db_name()+'_'+convert(varchar(256),c.sessionidA)+'_'+isnull(convert(varchar(256),'NA'),'NA') COLLATE Latin1_General_CI_AS as key_BST, 
	db_name() COLLATE Latin1_General_CI_AS as ddbb,
	c.sessionid as sessionidA, sb.SessionId as sessionidB,
	c.callStatus,

	-- CR parte A:
	datediff(s,cu.CU_Last_Time, c.[callEndTimeStamp]) as second_CU_endCall_A,
	datediff(s,cr.CR_Last_Time, c.[callEndTimeStamp]) as second_CR_endCall_A,
		
	cu.RadioFailureCU_attempt	as RadioFailureCU_attempt_A,
	cu.CU_Last_Time				as CU_Last_Time_A,
	cr.CR_attempt				as CR_attempt_A,
	cr.CR_Last_Time				as CR_Last_Time_A,

	-- CR parte B:
	datediff(s,cub.CU_Last_Time, c.[callEndTimeStamp]) as second_CU_endCall_B,
	datediff(s,crb.CR_Last_Time, c.[callEndTimeStamp]) as second_CR_endCall_B,

	cub.RadioFailureCU_attempt	as RadioFailureCU_attempt_B,
	cub.CU_Last_Time			as CU_Last_Time_B,
	crb.CR_attempt				as CR_attempt_B,
	crb.CR_Last_Time			as CR_Last_Time_B

into _lcc_c0re_Voice_CR_Metrics_Table
from 
	CallAnalysis c

	------------------------
	-- CR parte A:
	------------------------
	left outer join 
		(select sessionid, sum(1) as RadioFailureCU_attempt, max(msgtime) as CU_Last_Time 
		from WCDMARRCMessages where msgType like 'cellUpdate'
			and dbo.SQUMTSKeyValue(msg,LogChanType,msgType,
				'UL_CCCH_Message;message;cellUpdate;cellUpdateCause') in ('radiolinkFailure','rlc_unrecoverableError')
		group by sessionid
		) cu on cu.sessionid=c.sessionid

	left outer join 
		(select sessionid, sum(1) as CR_attempt, max(msgtime) as CR_Last_Time 
		from [dbo].[vGSMmm] 
		where msg='CM Re-Establishment Request'
		group by sessionid
		) cr on cr.sessionid=c.sessionid

	, sessions s

	------------------------
	-- CR parte B:
	------------------------
	, sessionsb sb
		left outer join 
			(select sessionid, sum(1) as RadioFailureCU_attempt, max(msgtime) as CU_Last_Time 
			from WCDMARRCMessages where msgType like 'cellUpdate'
				and dbo.SQUMTSKeyValue(msg,LogChanType,msgType,
				'UL_CCCH_Message;message;cellUpdate;cellUpdateCause') in ('radiolinkFailure','rlc_unrecoverableError')
			group by sessionid) cub on cub.sessionid=sb.sessionid
	 
		left outer join 
			(select sessionid, sum(1) as CR_attempt, max(msgtime) as CR_Last_Time 
			from [dbo].[vGSMmm] 
			where msg='CM Re-Establishment Request'
			group by sessionid) crb on crb.sessionid=sb.sessionid

where 
	c.callstatus not in ('System Release', 'Not Set')
	and c.Sessionid=s.SessionId and s.valid=1
	and s.SessionId=sb.SessionIdA



--***********************************************************************************************************************************
--		Tabla CORE final:
--***********************************************************************************************************************************
------declare @Config as [nvarchar](max)='SpainOSP'
exec('
	exec sp_lcc_dropifexists ''lcc_core_Voice_'+@Config+'_CR_Metrics_Table''	
	select * 
	into lcc_core_Voice_'+@Config+'_CR_Metrics_Table
	from _lcc_c0re_Voice_CR_Metrics_Table
')

--***********************************************************************************************************************************
-- Borrado Tablas Intermedias:
--***********************************************************************************************************************************
exec sp_lcc_dropifexists '_lcc_c0re_Voice_CR_Metrics_Table'

------------------------------------- select * from _lcc_c0re_Voice_CR_Metrics_Table
