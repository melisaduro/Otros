--USE [master]
--GO
--/****** Object:  StoredProcedure [dbo].[sp_create_Physical_Info_Table_FY1617]    Script Date: 26/03/2018 13:08:38 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

--ALTER procedure [dbo].[sp_create_Physical_Info_Table_FY1617]
--as

Begin


--------------------------------------------------------------------------------		
----		drop table lcc_Physical_Info_Table						    
----		select * from lcc_Physical_Info_Table	where msgtime>'2015-06-01 00:00:00.000' and testid=27177 and direction='uplink'

----	Si no existe la tabla, la crea vacia.
----	A continuación, tanto como si existe como si no, inserta en ella los testid a partir del maximo que tenga calculado
----
----	TEST INFO:
----		Info About	- Indica tecnologia la que se hace referencia
----		Direction	- Indica de que tipo de tabla se toma la info:	DL / UL
----		sessionid, testid, posid, networkid, msgtime

----
----	4G)	DL:	LTEPDSCHStatisticsInfo		- Info agregada
----			LTEPDSCHStatisticsCarrier	- Info por CC		
----												carrierIndex=0		-	PCC
----												carrierIndex=1...7	-	SCC:1...7
----
----			- Thput (NetPDSCHThroughput), Data Transfer (BytesTransferred), Transfer Time (BytesTransferred/NetPDSCHThroughput)
----			- Modulaciones, Shared channel use, RBs info, TM
----
----		COMENTARIO:
----		Si no hay CA, no aparece info en CC

----
----	4G)	UL:	LTEPUSCHStatisticsInfo
----
----			- Thput (NetPUSCHThroughput), Data Transfer (BytesTransferred), Transfer Time (BytesTransferred/NetPUSCHThroughput)
----			- Modulaciones, Shared channel use, RBs info			

----
----	3G)	UL:	HSUPAMACStatistics
----		
----			- Thput (EDCHThroughput), Data Transfer (AverageTBSize/8.0), Transfer Time (AverageTBSize/8.0)/EDCHThroughput)	
----			- AverageSG, TTI, HappyRate, DTXRate, AverageTBsize,	GrantedThroughput, ScheduledThroughput	
----
----			COMENTARIO: El transfer time no se calcula bien

----
----	3G)	DL:	HSDPAThroughput 
----		
----			- Thput (DSCHThroughput), Data Transfer (DSCHTBSize/8.0), Transfer Time	 (DSCHTBSize/8.0)/DSCHThroughput)

----
----	GPRS)	MsgGSMData	-	FINALMENTE NO SE SACA (al menos de momento)
----
----			- Thput, Data Transfer, Transfer Time	
----
----
----
----	Pendiente:
----		Revisar valores con test reales
----		Añadir info de Flilist? como en serving cell ¿?																	
--------------------------------------------------------------------------------


if (select name from sys.all_objects where name='lcc_Physical_Info_Table' and type='U') is null
begin
	----------------------------------------------------------------
	----	Si no existe, creamos la tabla final desde el inicio	--
	----------------------------------------------------------------
	--select 'No existe, por lo tanto creamos lcc_Physical_Info_Table' info
	CREATE TABLE [dbo].[lcc_Physical_Info_Table](
		[LTEPDSCHInfoId] [bigint] NULL,
		[Info about] [varchar](2) NOT NULL,
		[Direction] [varchar](8) NOT NULL,
		[sessionid] [bigint] NULL,
		[testid] [bigint] NULL,
		[posid] [bigint] NULL,
		[networkid] [bigint] NULL,
		[msgtime] [datetime2](3) NULL,
		[endtime] [datetime2](3) NULL,
		[duration] [int] NULL,

		-- Info agregada
		[Throughput] [real] NULL,
		[BytesTransferred] [float] NULL,
		[TransferTime] [float] NULL,
		[use_BPSK_num] [numeric](13, 1) NULL,
		[use_QPSK_num] [numeric](13, 1) NULL,
		[use_16QAM_num] [numeric](13, 1) NULL,
		[use_64QAM_num] [numeric](13, 1) NULL,
		[use_256QAM_num] [numeric](13, 1) NULL,
		[mod_use_denom] [int] NULL,
		[LTESharedChannelUse_num] [int] NULL,
		[LTESharedChannelUse_den] [int] NULL,
		[num_RBs_num] [int] NULL,
		[num_RBs_den] [int] NULL,
		[num_RBs_den_dedicated] [int] NULL,
		[TransmissionMode] [smallint] NULL,
		[MaxNumLayer] [int] NULL,
		[AvgMCS] [real] NULL,
		[AverageSG] [real] NULL,
		[TTI] [int] NULL,
		[HappyRate] [real] NULL,
		[DTXRate] [real] NULL,
		[AverageTBsize] [int] NULL,
		[GrantedThroughput] [real] NULL,
		[ScheduledThroughput] [real] NULL,
		[RetransRate] [real] NULL,
		[msgtimeID] [bigint] NULL,
		[number_Carrier] [int] NULL,

		-- Info por carrier - PCC
		[Throughput_PCC] [real] NULL,
		[BytesTransferred_PCC] [int] NULL,
		[TransferTime_PCC] [real] NULL,
		[use_QPSK_num_PCC] [numeric](13, 1) NULL,
		[use_16QAM_num_PCC] [numeric](13, 1) NULL,
		[use_64QAM_num_PCC] [numeric](13, 1) NULL,
		[use_256QAM_num_PCC] [numeric](13, 1) NULL,
		[mod_use_denom_PCC] [int] NULL,
		[LTESharedChannelUse_num_PCC] [int] NULL,
		[LTESharedChannelUse_den_PCC] [int] NULL,
		[num_RBs_num_PCC] [int] NULL,
		[num_RBs_den_PCC] [int] NULL,
		[num_RBs_den_dedicated_PCC] [int] NULL,
		[TransmissionMode_PCC] [smallint] NULL,
		[MaxNumLayer_PCC] [int] NULL,
		[AvgMCS_PCC] [real] NULL,	
		
		-- Info por carrier - SCCX
		[Throughput_SCC1] [real] NULL,
		[BytesTransferred_SCC1] [int] NULL,
		[TransferTime_SCC1] [real] NULL,
		[use_QPSK_num_SCC1] [numeric](13, 1) NULL,
		[use_16QAM_num_SCC1] [numeric](13, 1) NULL,
		[use_64QAM_num_SCC1] [numeric](13, 1) NULL,
		[use_256QAM_num_SCC1] [numeric](13, 1) NULL,
		[mod_use_denom_SCC1] [int] NULL,
		[LTESharedChannelUse_num_SCC1] [int] NULL,
		[LTESharedChannelUse_den_SCC1] [int] NULL,
		[num_RBs_num_SCC1] [int] NULL,
		[num_RBs_den_SCC1] [int] NULL,
		[num_RBs_den_dedicated_SCC1] [int] NULL,
		[TransmissionMode_SCC1] [smallint] NULL,
		[MaxNumLayer_SCC1] [int] NULL,
		[AvgMCS_SCC1] [real] NULL,
		
		[Throughput_SCC2] [real] NULL,
		[BytesTransferred_SCC2] [int] NULL,
		[TransferTime_SCC2] [real] NULL,
		[use_QPSK_num_SCC2] [numeric](13, 1) NULL,
		[use_16QAM_num_SCC2] [numeric](13, 1) NULL,
		[use_64QAM_num_SCC2] [numeric](13, 1) NULL,
		[use_256QAM_num_SCC2] [numeric](13, 1) NULL,
		[mod_use_denom_SCC2] [int] NULL,
		[LTESharedChannelUse_num_SCC2] [int] NULL,
		[LTESharedChannelUse_den_SCC2] [int] NULL,
		[num_RBs_num_SCC2] [int] NULL,
		[num_RBs_den_SCC2] [int] NULL,
		[num_RBs_den_dedicated_SCC2] [int] NULL,
		[TransmissionMode_SCC2] [smallint] NULL,
		[MaxNumLayer_SCC2] [int] NULL,
		[AvgMCS_SCC2] [real] NULL,
		
		[Throughput_SCC3] [real] NULL,
		[BytesTransferred_SCC3] [int] NULL,
		[TransferTime_SCC3] [real] NULL,
		[use_QPSK_num_SCC3] [numeric](13, 1) NULL,
		[use_16QAM_num_SCC3] [numeric](13, 1) NULL,
		[use_64QAM_num_SCC3] [numeric](13, 1) NULL,
		[use_256QAM_num_SCC3] [numeric](13, 1) NULL,
		[mod_use_denom_SCC3] [int] NULL,
		[LTESharedChannelUse_num_SCC3] [int] NULL,
		[LTESharedChannelUse_den_SCC3] [int] NULL,
		[num_RBs_num_SCC3] [int] NULL,
		[num_RBs_den_SCC3] [int] NULL,
		[num_RBs_den_dedicated_SCC3] [int] NULL,
		[TransmissionMode_SCC3] [smallint] NULL,
		[MaxNumLayer_SCC3] [int] NULL,
		[AvgMCS_SCC3] [real] NULL,
		
		[Throughput_SCC4] [real] NULL,
		[BytesTransferred_SCC4] [int] NULL,
		[TransferTime_SCC4] [real] NULL,
		[use_QPSK_num_SCC4] [numeric](13, 1) NULL,
		[use_16QAM_num_SCC4] [numeric](13, 1) NULL,
		[use_64QAM_num_SCC4] [numeric](13, 1) NULL,
		[use_256QAM_num_SCC4] [numeric](13, 1) NULL,
		[mod_use_denom_SCC4] [int] NULL,
		[LTESharedChannelUse_num_SCC4] [int] NULL,
		[LTESharedChannelUse_den_SCC4] [int] NULL,
		[num_RBs_num_SCC4] [int] NULL,
		[num_RBs_den_SCC4] [int] NULL,
		[num_RBs_den_dedicated_SCC4] [int] NULL,
		[TransmissionMode_SCC4] [smallint] NULL,
		[MaxNumLayer_SCC4] [int] NULL,
		[AvgMCS_SCC4] [real] NULL,
		
		[Throughput_SCC5] [real] NULL,
		[BytesTransferred_SCC5] [int] NULL,
		[TransferTime_SCC5] [real] NULL,
		[use_QPSK_num_SCC5] [numeric](13, 1) NULL,
		[use_16QAM_num_SCC5] [numeric](13, 1) NULL,
		[use_64QAM_num_SCC5] [numeric](13, 1) NULL,
		[use_256QAM_num_SCC5] [numeric](13, 1) NULL,
		[mod_use_denom_SCC5] [int] NULL,
		[LTESharedChannelUse_num_SCC5] [int] NULL,
		[LTESharedChannelUse_den_SCC5] [int] NULL,
		[num_RBs_num_SCC5] [int] NULL,
		[num_RBs_den_SCC5] [int] NULL,
		[num_RBs_den_dedicated_SCC5] [int] NULL,
		[TransmissionMode_SCC5] [smallint] NULL,
		[MaxNumLayer_SCC5] [int] NULL,
		[AvgMCS_SCC5] [real] NULL,
		
		[Throughput_SCC6] [real] NULL,
		[BytesTransferred_SCC6] [int] NULL,
		[TransferTime_SCC6] [real] NULL,
		[use_QPSK_num_SCC6] [numeric](13, 1) NULL,
		[use_16QAM_num_SCC6] [numeric](13, 1) NULL,
		[use_64QAM_num_SCC6] [numeric](13, 1) NULL,
		[use_256QAM_num_SCC6] [numeric](13, 1) NULL,
		[mod_use_denom_SCC6] [int] NULL,
		[LTESharedChannelUse_num_SCC6] [int] NULL,
		[LTESharedChannelUse_den_SCC6] [int] NULL,
		[num_RBs_num_SCC6] [int] NULL,
		[num_RBs_den_SCC6] [int] NULL,
		[num_RBs_den_dedicated_SCC6] [int] NULL,
		[TransmissionMode_SCC6] [smallint] NULL,
		[MaxNumLayer_SCC6] [int] NULL,
		[AvgMCS_SCC6] [real] NULL,
		
		[Throughput_SCC7] [real] NULL,
		[BytesTransferred_SCC7] [int] NULL,
		[TransferTime_SCC7] [real] NULL,
		[use_QPSK_num_SCC7] [numeric](13, 1) NULL,
		[use_16QAM_num_SCC7] [numeric](13, 1) NULL,
		[use_64QAM_num_SCC7] [numeric](13, 1) NULL,
		[use_256QAM_num_SCC7] [numeric](13, 1) NULL,
		[mod_use_denom_SCC7] [int] NULL,
		[LTESharedChannelUse_num_SCC7] [int] NULL,
		[LTESharedChannelUse_den_SCC7] [int] NULL,
		[num_RBs_num_SCC7] [int] NULL,
		[num_RBs_den_SCC7] [int] NULL,
		[num_RBs_den_dedicated_SCC7] [int] NULL,
		[TransmissionMode_SCC7] [smallint] NULL,
		[MaxNumLayer_SCC7] [int] NULL,
		[AvgMCS_SCC7] [real] NULL				)
end
	
	
-------------------
-- Creamos la tabla temporal con _CA vacia siempre
-------------------
 exec dbo.sp_lcc_DropIfExists '_CA'
CREATE TABLE _CA(
	[CarrierIndex] [smallint] NULL,
	[LTEPDSCHInfoId] [bigint] NULL,
	[Info about] [varchar](2) NOT NULL,
	[Direction] [varchar](8) NOT NULL,
	[sessionid] [bigint] NOT NULL,
	[testid] [bigint] NULL,
	[posid] [bigint] NULL,
	[networkid] [bigint] NULL,
	[msgtime] [datetime2](3) NULL,	
	[Throughput] [real] NULL,
	[BytesTransferred] [int] NULL,
	[TransferTime] [real] NULL,
	[use_QPSK_num] [numeric](13, 1) NULL,
	[use_16QAM_num] [numeric](13, 1) NULL,
	[use_64QAM_num] [numeric](13, 1) NULL,
	[use_256QAM_num] [numeric](13, 1) NULL,
	[mod_use_denom] [int] NULL,
	[LTESharedChannelUse_num] [int] NULL,
	[LTESharedChannelUse_den] [int] NULL,
	[num_RBs_num] [int] NULL,
	[num_RBs_den] [int] NULL,
	[num_RBs_den_dedicated] [int] NULL,
	[TransmissionMode] [smallint] NULL,
	[MaxNumLayer] [int] NULL,	
	[AvgMCS] [real] NULL			)
	

----------------------------------------
-- Se insertaran los valores en las tablas, siempre a partir del ultimo testid de lcc_Physical_Info_Table
declare @maxTestid as int=(select ISNULL(MAX(testid),0) from lcc_Physical_Info_Table)
select 'Updated lcc_Physical_Info_Table from testid='+CONVERT(varchar(256),@maxTestid)+' to testid='+CONVERT(varchar(256),(select max(TestId) from TestInfo)) info

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CAC 14/03/2017: En algunos test muy rapidos con thput altos, la info se quedaba vacia. Modificamos la lógica para corregir algunos casos.
-- Analizamos la información por test existente en el rango de ResultsKPIs correspondiente al tramo de descarga. Casos particulares:
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CASO 1. Tengamos sólo una info del testid en el tramo y esta sea la última, debemos tratarlos de otra forma:  incluimos el msgtime anterior (fuera 
--  de tramo para disponir de info del test (el que esta en el tramo tiene a null todo porque se coge su MsgTime y la info posterior que no existe).
-- CASO 2. Test que recogan únicamente una info y está se encuentre en el tramo: debemos asociar a ese MsgTime su info y no la posterior.
-- CASO 3. Test que no tiene info en el tramo pero si posterior: incluimos la primera información despues del tramo y asociamos su MsgTime.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

exec sp_lcc_dropifexists '_intervalos'	
select test.sessionid, test.testid, k.kpiid, k.StartTime, k.endTime,
	case when k.duration is not null then k.duration else DATEDIFF(ms,k.starttime,k.endtime) end as duration
into _intervalos
from  testinfo test
	inner join ResultsKpi k 
			on test.sessionid=k.sessionid and test.testid=k.testid and (k.kpiid=75502  or k.kpiid=77502 --DL
				or k.kpiid = 76002 or k.kpiid=78002	--UL
				or k.kpiid=76502 or k.kpiid=77002) --WEB
where test.testid > @maxTestid
exec dbo.sp_lcc_dropifexists '_temp_Test_Info_DL_4G'
CREATE TABLE [dbo].[_temp_Test_Info_DL_4G](
	[testid] [bigint] NULL,
	[MsgTimeAnterior] [datetime2](3) NULL, 
	[MsgTimePosterior] [datetime2](3) NULL,
	[InfoTramo] [bigint] NULL, 
	[InfoPosterior] [bigint] NULL,
	[Count_Info] [bigint] NULL
)
insert into _temp_Test_Info_DL_4G
select l.TestId, 
	max(case when l.msgtime < k.starttime then msgTime end) as 'MsgTimeAnterior',
	min(case when l.msgtime > k.endtime then msgTime end) as 'MsgTimePosterior',
	sum(case when l.msgtime between k.starttime and k.endtime then 1 else 0 end) as 'InfoTramo',
	sum(case when l.msgtime > k.endtime then 1 else 0 end) as 'InfoPosterior',
	count(1) as 'Count_Info'
from TestInfo test, LTEPDSCHStatisticsInfo l,	
	ResultsKpi k
where l.sessionid=k.sessionid and l.testid=k.testid and (k.kpiid=75502 or k.kpiid=76502 or k.kpiid=77002 or k.kpiid=77502)
	and test.testid=l.testid
	and l.TestId > @maxTestid
group by l.TestId


exec dbo.sp_lcc_dropifexists '_temp_Test_Info_UL_4G'
CREATE TABLE [dbo].[_temp_Test_Info_UL_4G](
	[testid] [bigint] NULL,
	[MsgTimeAnterior] [datetime2](3) NULL, 
	[MsgTimePosterior] [datetime2](3) NULL,
	[InfoTramo] [bigint] NULL, 
	[InfoPosterior] [bigint] NULL,
	[Count_Info] [bigint] NULL
)
insert into _temp_Test_Info_UL_4G
select l.TestId, 
	max(case when l.msgtime < k.starttime then msgTime end) as 'MsgTimeAnterior',
	min(case when l.msgtime > k.endtime then msgTime end) as 'MsgTimePosterior',
	sum(case when l.msgtime between k.starttime and k.endtime then 1 else 0 end) as 'InfoTramo',
	sum(case when l.msgtime > k.endtime then 1 else 0 end) as 'InfoPosterior',
	count(1) as 'Count_Info'
from TestInfo test, LTEPUSCHStatisticsInfo l,	
	ResultsKpi k
where l.sessionid=k.sessionid and l.testid=k.testid and (k.kpiid = 76002 or k.kpiid=78002)
	and test.testid=l.testid
	and l.TestId > @maxTestid
group by l.TestId

exec dbo.sp_lcc_dropifexists '_temp_Test_Info_DL_3G'
CREATE TABLE [dbo].[_temp_Test_Info_DL_3G](
	[testid] [bigint] NULL,
	[MsgTimeAnterior] [datetime2](3) NULL,
	[MsgTimePosterior] [datetime2](3) NULL,
	[InfoTramo] [bigint] NULL, 
	[InfoPosterior] [bigint] NULL,
	[Count_Info] [bigint] NULL
)
insert into _temp_Test_Info_DL_3G
select l.TestId, 
	max(case when l.msgtime < k.starttime then msgTime end) as 'MsgTimeAnterior',
	min(case when l.msgtime > k.endtime then msgTime end) as 'MsgTimePosterior',
	sum(case when l.msgtime between k.starttime and k.endtime then 1 else 0 end) as 'InfoTramo',
	sum(case when l.msgtime > k.endtime then 1 else 0 end) as 'InfoPosterior',
	count(1) as 'Count_Info'
from TestInfo test, HSDPAThroughput l,	
	ResultsKpi k
where l.sessionid=k.sessionid and l.testid=k.testid and (k.kpiid=75502 or k.kpiid=76502 or k.kpiid=77002 or k.kpiid=77502)
	and test.testid=l.testid
	and l.TestId > @maxTestid
group by l.TestId

exec dbo.sp_lcc_dropifexists '_temp_Test_Info_UL_3G'
CREATE TABLE [dbo].[_temp_Test_Info_UL_3G](
	[testid] [bigint] NULL,
	[MsgTimeAnterior] [datetime2](3) NULL,
	[MsgTimePosterior] [datetime2](3) NULL,
	[InfoTramo] [bigint] NULL, 
	[InfoPosterior] [bigint] NULL,
	[Count_Info] [bigint] NULL
)
insert into _temp_Test_Info_UL_3G
select l.TestId, 
	max(case when l.msgtime < k.starttime then msgTime end) as 'MsgTimeAnterior',
	min(case when l.msgtime > k.endtime then msgTime end) as 'MsgTimePosterior',
	sum(case when l.msgtime between k.starttime and k.endtime then 1 else 0 end) as 'InfoTramo',
	sum(case when l.msgtime > k.endtime then 1 else 0 end) as 'InfoPosterior',
	count(1) as 'Count_Info'
from TestInfo test, HSUPAMACStatistics l,	
	ResultsKpi k
where l.sessionid=k.sessionid and l.testid=k.testid and (k.kpiid = 76002 or k.kpiid=78002)
	and test.testid=l.testid
	and l.TestId > @maxTestid
group by l.TestId



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CAC 14/03/2017: 
-- También se detecta que el cálculo de RBs con las duraciones no es muy exacto en algunos casos. Modificamos su cálculo:
--		Antes: RBs = AVG(NumRBs/Duración) 
--		Ahora: RBs = (sum(NumRBs)/sum(NumRecords))/2
-- El cálculo de SharedChannelUse tampoco es correcto:
--		Antes: SharedChannelUse = sum(NumRBs)/sum(Duración*100) (valor similar a RBs en muchos casos)
--		Ahora: para todas las portadoras detectadas consideramos que es de 20Mhz-->max 100RB, se penaliza cuando sean de 10MhZ--> max 50RB
--			(sum(NumRBs_PCC+NumRBs_SCC1)/sum(NumRecords_PCC+NumRecords_SCC1))/(2*100)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------
-- Se rellena la tabla temporal con info de CA, solo si existe info en la bbdd (la tabla LTEPDSCHStatisticsCarrier correspondiente)
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LTEPDSCHStatisticsCarrier]') AND type in (N'U'))
begin

	--Ordenamos los carrierIndex para considerar cada carrier como la primera, segunda, etc ocurrencia
	--(se ha visto que la forma de rellenar los carrierIndex no se corresponde con: index=1 -> SCC1, index=2 -> SCC2, ...)
	--Info de CarrierIndex=0 --> PCC
	exec sp_lcc_dropifexists '_CA_carrierId'
	select c.*,
		case when c.carrierindex=0 then 0 else ROW_NUMBER() over (partition by l.testid,l.msgtime order by c.CarrierIndex asc)-1 end as carrierID
	into _CA_carrierId
	from _temp_Test_Info_DL_4G info,LTEPDSCHStatisticsInfo l
		join LTEPDSCHStatisticsCarrier c on c.LTEPDSCHInfoId = l.LTEPDSCHInfoId
	where info.testid=l.testid
	

	insert into _CA
	
	select 
		-- Test Info:
		c.carrierID as CarrierIndex,				--	0 :PCC,	1...7: SCC1...7
		l.LTEPDSCHInfoId,
		'4G' as 'Info about',
		'Downlink' as Direction, 
		l.sessionid, l.testid, l.posid, l.networkid, l.msgtime,

		-- THPUTs Info :
		--OLD c.NetPDSCHThroughput as 'Throughput',		-- KBytes/s
		c.NetPDSCHThroughput/1000.0 as 'Throughput',		-- KBytes/s Dato original en Bytes
		Convert(float,c.BytesTransferred) as 'BytesTransferred',	-- Bytes transferred
		--OLD Convert(float,c.BytesTransferred/NULLIF((c.NetPDSCHThroughput/1000.0),0)) as 'TransferTime',	-- Bytes/(Bytes/s) = s
		Convert(float,c.BytesTransferred/NULLIF(c.NetPDSCHThroughput,0)) as 'TransferTime',	-- Bytes/(Bytes/s) = s

		-- 4G Info:
		1.0*c.NumQPSK as use_QPSK_num,			-- Number of TBs using QPSK
		1.0*c.Num16QAM as use_16QAM_num,		-- Number of TBs using 16QAM	
		1.0*c.Num64QAM as use_64QAM_num,		-- Number of TBs using 64QAM
		1.0*c.Num256QAM as use_256QAM_num,		-- Number of TBs using 256QAM
		case when c.NumTBs is null then lfin.numTBs else c.NumTBs end as mod_use_denom,				-- Number of TBs

		case when c.NumRBs is null then lfin.numRbs else c.NumRBs end as LTESharedChannelUse_num,		-- Number of RBs (overall TBs)
		--(100*2*datediff(ms,l.msgtime,lfin.msgtime)) as LTESharedChannelUse_den,	
		case when c.NumRecords is null then lfin.NumRecords else c.NumRecords end as LTESharedChannelUse_den,	

		case when c.NumRBs is null then lfin.numRbs else c.NumRBs end as num_RBs_num,					-- Number of RBs (overall TBs)
		--(100*2*datediff(ms,l.msgtime,lfin.msgtime))/100 as num_RBs_den,				-- Para cada CC individual		
		case when c.NumRecords is null then lfin.NumRecords else c.NumRecords end as num_RBs_den,	-- Para cada CC individual
		case when c.NumTBs is null then lfin.numTBs else c.NumTBs end as num_RBs_den_dedicated,									

		c.TransmissionMode,
		c.MaxNumLayer,
		c.AvgMCS
		
	from _temp_Test_Info_DL_4G info, LTEPDSCHStatisticsInfo l
			left outer join LTEPDSCHStatisticsInfo lfin on lfin.sessionid = l.sessionid and lfin.testid=l.testid and lfin.msgid=l.msgid+1
			JOIN _CA_carrierId c ON c.LTEPDSCHInfoId = lfin.LTEPDSCHInfoId,
	--DGP 16/10/2015: Se linka con ResultsKpi para quedarnos sólo con los tramos de descarga
	-- ********************************************************************************************************
			ResultsKpi k
		
	where l.sessionid=k.sessionid and l.testid=k.testid and (k.kpiid=75502 or k.kpiid=76502 or k.kpiid=77002 or k.kpiid=77502)
		and ((
			--Si en el rango de tiempo de KPIs (Start/End de tabla K):
			-- tenemos varios informaciones (InfoTramo>=2) o 1 pero con información posterior(InfoPosterior>0),cogemos info del rango de KPIs.
			(info.InfoTramo>=2 or (info.InfoTramo<2 and info.InfoPosterior>0)) 
				and l.msgtime between k.starttime and k.endtime)
			or
			--Si en el rango de tiempo de KPIs (Start/End de tabla K):
			-- tenemos sólo 1 registro con info (InfoTramo=1, sin información posterior (InfoPosterior=0) pero sí anterior (Count_Info>1),
			-- cogemos info desde la última info anterior al fin del rango de KPIs.
			(info.InfoTramo=1 and info.InfoPosterior=0 and info.Count_Info>1 and l.msgtime between info.MsgTimeAnterior and k.endtime)
			)
		and info.testid=l.testid
		and l.TestId > @maxTestid
	union all
	select 
		-- Test Info:
		c.carrierID as CarrierIndex,				--	0 :PCC,	1...7: SCC1...7
		l.LTEPDSCHInfoId,
		'4G' as 'Info about',
		'Downlink' as Direction, 
		l.sessionid, l.testid, l.posid, l.networkid, l.msgtime,

		-- THPUTs Info :
		--OLD c.NetPDSCHThroughput as 'Throughput',		-- KBytes/s
		c.NetPDSCHThroughput/1000.0 as 'Throughput',		-- KBytes/s Dato original en Bytes
		Convert(float,c.BytesTransferred) as 'BytesTransferred',	-- Bytes transferred
		--OLD Convert(float,c.BytesTransferred/NULLIF((c.NetPDSCHThroughput/1000.0),0)) as 'TransferTime',	-- Bytes/(Bytes/s) = s
		Convert(float,c.BytesTransferred/NULLIF(c.NetPDSCHThroughput,0)) as 'TransferTime',	-- Bytes/(Bytes/s) = s

		-- 4G Info:
		1.0*c.NumQPSK as use_QPSK_num,			-- Number of TBs using QPSK
		1.0*c.Num16QAM as use_16QAM_num,		-- Number of TBs using 16QAM	
		1.0*c.Num64QAM as use_64QAM_num,		-- Number of TBs using 64QAM
		1.0*c.Num256QAM as use_256QAM_num,		-- Number of TBs using 256QAM
		case when c.NumTBs is null then l.numTBs else c.NumTBs end as mod_use_denom,				-- Number of TBs

		case when c.NumRBs is null then l.numRbs else c.NumRBs end as LTESharedChannelUse_num,		-- Number of RBs (overall TBs)
		--NULL as LTESharedChannelUse_den,
		case when c.NumRecords is null then l.NumRecords else c.NumRecords end as LTESharedChannelUse_den,			

		case when c.NumRBs is null then l.numRbs else c.NumRBs end as num_RBs_num,					-- Number of RBs (overall TBs)
		--NULL as num_RBs_den,				-- Para cada CC individual			
		case when c.NumRecords is null then l.NumRecords else c.NumRecords end as num_RBs_den,   -- Para cada CC individual
		case when c.NumTBs is null then l.numTBs else c.NumTBs end as num_RBs_den_dedicated,									

		c.TransmissionMode,
		c.MaxNumLayer,
		c.AvgMCS
		
	from _temp_Test_Info_DL_4G info, LTEPDSCHStatisticsInfo l
			JOIN _CA_carrierId c ON c.LTEPDSCHInfoId = l.LTEPDSCHInfoId,
	--DGP 16/10/2015: Se linka con ResultsKpi para quedarnos sólo con los tramos de descarga
	-- ********************************************************************************************************
		ResultsKpi k
		
	where l.sessionid=k.sessionid and l.testid=k.testid and (k.kpiid=75502 or k.kpiid=76502 or k.kpiid=77002 or k.kpiid=77502)
		and (
			--Si en el rango de tiempo de KPIs (Start/End de tabla K):
			-- tenemos sólo 1 registro con info (InfoTramo=1) y es la única info disponible (Count_Info=1),
			-- cogemos ese instante de tiempo y su info correspondiente (no la posterior ya que no existe).
			(l.msgtime between k.starttime and k.endtime and info.InfoTramo=1 and info.Count_Info=1)
			or
			--Si en el rango de tiempo de KPIs (Start/End de tabla K):
			-- no tenemos info (InfoTramo=0) pero si hay info posterior (InfoPosterior>0),
			-- cogemos info de la primera info posterior al fin del rango de KPIs.
			(info.InfoTramo=0 and InfoPosterior>0 and l.msgtime between k.starttime and info.MsgTimePosterior)
		)
		and info.testid=l.testid
		and l.TestId > @maxTestid
	-- ********************************************************************************************************

end 			
------------------------------------------
--- fjla, para evitar que se colapse tempdb se crea una tabla con el resultado de
---   insertar varias tablas en lugar de hacer union
exec dbo.sp_lcc_dropifexists '_temp'

CREATE TABLE [dbo].[_temp](
	[LTEPDSCHInfoId] [bigint]  NULL,
	[Info about] [varchar](256)  NULL,
	[Direction] [varchar](256)  NULL,
	[sessionid] [bigint]  NULL,
	[testid] [bigint] NULL,
	[posid] [bigint] NULL,
	[networkid] [bigint] NULL,
	[msgtime] [datetime2](3) NULL,
	[endtime] [datetime2](3) NULL,
	[duration] [int] NULL,
	[Throughput] [real] NULL,
	[BytesTransferred] [float] NULL,
	[TransferTime] [float] NULL,
	[use_BPSK_num] [float] NULL,
	[use_QPSK_num] [float] NULL,
	[use_16QAM_num] [float] NULL,
	[use_64QAM_num] [float] NULL,
	[use_256QAM_num] [float] NULL,
	[mod_use_denom] [int] NULL,
	[LTESharedChannelUse_num] [int] NULL,
	[LTESharedChannelUse_den] [int] NULL,
	[num_RBs_num] [int] NULL,
	[num_RBs_den] [int] NULL,
	[num_RBs_den_dedicated] [int] NULL,
	[TransmissionMode] [smallint] NULL,
	[MaxNumLayer] [int] NULL,
	[AvgMCS] [real] NULL,
	[AverageSG] [int] NULL,
	[TTI] [int] NULL,
	[HappyRate] [int] NULL,
	[DTXRate] [int] NULL,
	[AverageTBsize] [int] NULL,
	[GrantedThroughput] [int] NULL,
	[ScheduledThroughput] [int] NULL,
	[RetransRate] [int] NULL
) ON [MainGroup]
--------------------------------------------------- 4G DL: declare @maxTestid as int=0
		insert into _temp
		
		select 
			-- Test Info:
			l.LTEPDSCHInfoId,
			'4G' as 'Info about',
			'Downlink' as Direction, 
			l.sessionid, l.testid, l.posid, l.networkid, l.msgtime, lfin.msgtime as endTime, datediff(ms,l.msgtime, lfin.msgtime) as duration,

			-- THPUTs Info :
			--OLD l.NetPDSCHThroughput as 'Throughput',										-- KBytes/s
			lfin.NetPDSCHThroughput/1000.0 as 'Throughput',									-- KBytes/s Dato original en Bytes
			Convert(float,lfin.BytesTransferred) as 'BytesTransferred',									-- Bytes transferred
			--OLD Convert(float,l.BytesTransferred/NULLIF(1000.0*l.NetPDSCHThroughput,0)) as 'TransferTime',	-- Bytes / 1000*(KBytes/s) = s
			Convert(float,lfin.BytesTransferred/NULLIF(lfin.NetPDSCHThroughput,0)) as 'TransferTime',	-- Bytes / (Bytes/s) = s

			-- 4G Info:
			null as use_BPSK_num,
			1.0*lfin.NumQPSK as use_QPSK_num,			-- Number of TBs using QPSK
			1.0*lfin.Num16QAM as use_16QAM_num,		-- Number of TBs using 16QAM	
			1.0*lfin.Num64QAM as use_64QAM_num,		-- Number of TBs using 64QAM
			1.0*lfin.Num256QAM as use_256QAM_num,		-- Number of TBs using 256QAM
			lfin.numTBs as mod_use_denom,				-- Number of TBs

			lfin.NumRBs as LTESharedChannelUse_num,		-- Number of RBs (overall TBs)
			--(100*2*datediff(ms,l.msgtime,lfin.msgtime)) as LTESharedChannelUse_den,
			lfin.NumRecords as LTESharedChannelUse_den,

			lfin.NumRBs as num_RBs_num,					-- Number of RBs (overall TBs)
			--(100*2*datediff(ms,l.msgtime,lfin.msgtime))/100 as num_RBs_den,				-- para cada CC individual			
			lfin.NumRecords as num_RBs_den,             -- para cada CC individual
			lfin.NumTBs as num_RBs_den_dedicated,									

			lfin.TransmissionMode,
			lfin.MaxNumLayer,
			lfin.AvgMCS,

			-- 3G Info UL:
			null as AverageSG, 
			null as TTI,
			null as HappyRate, 
			null as DTXRate, 
			null as AverageTBsize,
			null as GrantedThroughput,
			null as ScheduledThroughput,
			null as RetransRate	
			
		from _temp_Test_Info_DL_4G info, LTEPDSCHStatisticsInfo l

		left outer join LTEPDSCHStatisticsInfo lfin on lfin.testid=l.testid and lfin.msgid=l.msgid+1,
		--DGP 16/10/2015: Se linka con ResultsKpi para quedarnos sólo con los tramos de descarga
		-- ********************************************************************************************************
				ResultsKpi k
		
		where l.sessionid=k.sessionid and l.testid=k.testid and (k.kpiid=75502 or k.kpiid=76502 or k.kpiid=77002 or k.kpiid=77502)
			and ((
				--Si en el rango de tiempo de KPIs (Start/End de tabla K):
				-- tenemos varios informaciones (InfoTramo>=2) o 1 pero con información posterior(InfoPosterior>0),cogemos info del rango de KPIs.
				(info.InfoTramo>=2 or (info.InfoTramo<2 and info.InfoPosterior>0)) 
					and l.msgtime between k.starttime and k.endtime)
				or
				--Si en el rango de tiempo de KPIs (Start/End de tabla K):
				-- tenemos sólo 1 registro con info (InfoTramo=1), sin información posterior (InfoPosterior=0) pero sí anterior (Count_Info>1),
				-- cogemos info desde la última info anterior al fin del rango de KPIs.
				(info.InfoTramo=1 and info.InfoPosterior=0 and info.Count_Info>1 and l.msgtime between info.MsgTimeAnterior and k.endtime)
			)
			and info.testid=l.testid
			and l.TestId > @maxTestid
		union all
		select 
			-- Test Info:
			l.LTEPDSCHInfoId,
			'4G' as 'Info about',
			'Downlink' as Direction, 
			l.sessionid, l.testid, l.posid, l.networkid, l.msgtime, null as endtime, 1 as duration,

			-- THPUTs Info :
			--OLD l.NetPDSCHThroughput as 'Throughput',										-- KBytes/s
			l.NetPDSCHThroughput/1000.0 as 'Throughput',									-- KBytes/s Dato original en Bytes
			Convert(float,l.BytesTransferred) as 'BytesTransferred',									-- Bytes transferred
			--OLD Convert(float,l.BytesTransferred/NULLIF(1000.0*l.NetPDSCHThroughput,0)) as 'TransferTime',	-- Bytes / 1000*(KBytes/s) = s
			Convert(float,l.BytesTransferred/NULLIF(l.NetPDSCHThroughput,0)) as 'TransferTime',	-- Bytes / (Bytes/s) = s

			-- 4G Info:
			null as use_BPSK_num,
			1.0*l.NumQPSK as use_QPSK_num,			-- Number of TBs using QPSK
			1.0*l.Num16QAM as use_16QAM_num,		-- Number of TBs using 16QAM	
			1.0*l.Num64QAM as use_64QAM_num,		-- Number of TBs using 64QAM
			1.0*l.Num256QAM as use_256QAM_num,		-- Number of TBs using 256QAM
			l.numTBs as mod_use_denom,				-- Number of TBs

			l.NumRBs as LTESharedChannelUse_num,		-- Number of RBs (overall TBs)
			--NULL as LTESharedChannelUse_den,
			l.NumRecords as LTESharedChannelUse_den,

			l.NumRBs as num_RBs_num,					-- Number of RBs (overall TBs)
			--NULL as num_RBs_den,				-- para cada CC individual			
			l.NumRecords as num_RBs_den,             -- para cada CC individual
			l.NumTBs as num_RBs_den_dedicated,									

			l.TransmissionMode,
			l.MaxNumLayer,
			l.AvgMCS,

			-- 3G Info UL:
			null as AverageSG, 
			null as TTI,
			null as HappyRate, 
			null as DTXRate, 
			null as AverageTBsize,
			null as GrantedThroughput,
			null as ScheduledThroughput,
			null as RetransRate	
			
		from _temp_Test_Info_DL_4G info, LTEPDSCHStatisticsInfo l,
		
		--DGP 16/10/2015: Se linka con ResultsKpi para quedarnos sólo con los tramos de descarga
		-- ********************************************************************************************************
				ResultsKpi k
		
		where l.sessionid=k.sessionid and l.testid=k.testid and (k.kpiid=75502 or k.kpiid=76502 or k.kpiid=77002 or k.kpiid=77502)
			and (
				--Si en el rango de tiempo de KPIs (Start/End de tabla K):
				-- tenemos sólo 1 registro con info (InfoTramo=1) y es la única info disponible (Count_Info=1),
				-- cogemos ese instante de tiempo y su info correspondiente (no la posterior ya que no existe).
				(l.msgtime between k.starttime and k.endtime and info.InfoTramo=1 and info.Count_Info=1)
				or
				--Si en el rango de tiempo de KPIs (Start/End de tabla K):
				-- no tenemos info (InfoTramo=0) pero si hay info posterior (InfoPosterior>0),
				-- cogemos info de la primera info posterior al fin del rango de KPIs.
				(info.InfoTramo=0 and InfoPosterior>0 and l.msgtime between k.starttime and info.MsgTimePosterior)
			)
			and info.testid=l.testid
			and l.TestId > @maxTestid

		-- ********************************************************************************************************
		
		--union all declare @maxTestid as int=0
		insert into _temp	
		--------------------------------------------------- 4G UL:	
		select 
			-- Test Info:
			null as LTEPDSCHInfoId,
			'4G' as 'Info about',			
			'Uplink' as Direction, 
			l.sessionid, l.testid, l.posid, l.networkid, l.msgtime, lfin.msgtime as endTime, datediff(ms,l.msgtime, lfin.msgtime) as duration,

			--THPUTs:
			--OLD l.NetPUSCHThroughput as 'Throughput',										-- KBytes/s
			lfin.NetPUSCHThroughput/1000.0 as 'Throughput',										-- KBytes/s Dato original Bytes
			Convert(float,lfin.BytesTransferred) as 'BytesTransferred',									-- Bytes transferred
			--OLD Convert(float,l.BytesTransferred/NULLIF(1000.0*l.NetPUSCHThroughput,0)) as 'TransferTime',	-- Bytes / 1000*(KBytes/s) = s
			Convert(float,lfin.BytesTransferred/NULLIF(lfin.NetPUSCHThroughput,0)) as 'TransferTime',	-- Bytes / (Bytes/s) = s

			-- 4G Info:
			1.0*lfin.NumBPSK as use_BPSK_num,
			1.0*lfin.NumQPSK as use_QPSK_num,			-- Number of TBs using QPSK
			1.0*lfin.Num16QAM as use_16QAM_num,		-- Number of TBs using 16QAM	
			1.0*lfin.Num64QAM as use_64QAM_num,		-- Number of TBs using 64QAM
			null as use_256QAM_num,		-- Number of TBs using 256QAM
			lfin.numTBs as mod_use_denom,				-- Number of TBs

			lfin.NumRBs as LTESharedChannelUse_num,		-- Number of RBs (overall TBs)
			--(100*2*datediff(ms,l.msgtime,lfin.msgtime)) as LTESharedChannelUse_den,
			lfin.NumRecords as LTESharedChannelUse_den,

			lfin.NumRBs as num_RBs_num,					-- Number of RBs (overall TBs)
			--(100*2*datediff(ms,l.msgtime,lfin.msgtime))/100 as num_RBs_den,				-- CUIDADO si hay Carrier Agregation!!!	-> valido para cada CC individual				
			lfin.NumRecords as num_RBs_den,
			lfin.NumTBs as num_RBs_den_dedicated,							

			null as TransmissionMode,
			null as MaxNumLayer,
			null as AvgMCS,

			-- 3G Info UL:
			null as AverageSG, 
			null as TTI,
			null as HappyRate, 
			null as DTXRate, 
			null as AverageTBsize,
			null as GrantedThroughput,
			null as ScheduledThroughput,
			null as RetransRate	
			
		from _temp_Test_Info_UL_4G info,LTEPUSCHStatisticsInfo l
		
		left outer join LTEPUSCHStatisticsInfo lfin on lfin.testid=l.testid and lfin.msgid=l.msgid+1,
		--DGP 16/10/2015: Se linka con ResultsKpi para quedarnos sólo con los tramos de descarga
		-- ********************************************************************************************************
				ResultsKpi k
		
		where l.sessionid=k.sessionid and l.testid=k.testid and (k.kpiid = 76002 or k.kpiid=78002)
			and (((info.InfoTramo>=2 or (info.InfoTramo<2 and info.InfoPosterior>0)) and l.msgtime between k.starttime and k.endtime)
				or
				(info.InfoTramo=1 and info.InfoPosterior=0 and info.Count_Info>1 and l.msgtime between info.MsgTimeAnterior and k.endtime))
			and info.testid=l.testid
			and l.TestId > @maxTestid
		union all
		select 
			-- Test Info:
			null as LTEPDSCHInfoId,
			'4G' as 'Info about',			
			'Uplink' as Direction, 
			l.sessionid, l.testid, l.posid, l.networkid, l.msgtime, null as endtime, 1 as duration,

			--THPUTs:
			--OLD l.NetPUSCHThroughput as 'Throughput',										-- KBytes/s
			l.NetPUSCHThroughput/1000.0 as 'Throughput',										-- KBytes/s Dato original Bytes
			Convert(float,l.BytesTransferred) as 'BytesTransferred',									-- Bytes transferred
			--OLD Convert(float,l.BytesTransferred/NULLIF(1000.0*l.NetPUSCHThroughput,0)) as 'TransferTime',	-- Bytes / 1000*(KBytes/s) = s
			Convert(float,l.BytesTransferred/NULLIF(l.NetPUSCHThroughput,0)) as 'TransferTime',	-- Bytes / (Bytes/s) = s

			-- 4G Info:
			1.0*l.NumBPSK as use_BPSK_num,
			1.0*l.NumQPSK as use_QPSK_num,			-- Number of TBs using QPSK
			1.0*l.Num16QAM as use_16QAM_num,		-- Number of TBs using 16QAM	
			1.0*l.Num64QAM as use_64QAM_num,		-- Number of TBs using 64QAM
			null as use_256QAM_num,		-- Number of TBs using 256QAM
			l.numTBs as mod_use_denom,				-- Number of TBs

			l.NumRBs as LTESharedChannelUse_num,		-- Number of RBs (overall TBs)
			--NULL as LTESharedChannelUse_den,
			l.NumRecords as LTESharedChannelUse_den,

			l.NumRBs as num_RBs_num,					-- Number of RBs (overall TBs)
			--NULL as num_RBs_den,				-- CUIDADO si hay Carrier Agregation!!!	-> valido para cada CC individual				
			l.NumRecords as num_RBs_den,
			l.NumTBs as num_RBs_den_dedicated,							

			null as TransmissionMode,
			null as MaxNumLayer,
			null as AvgMCS,

			-- 3G Info UL:
			null as AverageSG, 
			null as TTI,
			null as HappyRate, 
			null as DTXRate, 
			null as AverageTBsize,
			null as GrantedThroughput,
			null as ScheduledThroughput,
			null as RetransRate	
			
		from _temp_Test_Info_UL_4G info,LTEPUSCHStatisticsInfo l,		
		
		--DGP 16/10/2015: Se linka con ResultsKpi para quedarnos sólo con los tramos de descarga
		-- ********************************************************************************************************
				ResultsKpi k
		
		where l.sessionid=k.sessionid and l.testid=k.testid and (k.kpiid = 76002 or k.kpiid=78002)
			and (
				--Si en el rango de tiempo de KPIs (Start/End de tabla K):
				-- tenemos sólo 1 registro con info (InfoTramo=1) y es la única info disponible (Count_Info=1),
				-- cogemos ese instante de tiempo y su info correspondiente (no la posterior ya que no existe).
				(l.msgtime between k.starttime and k.endtime and info.InfoTramo=1 and info.Count_Info=1)
				or
				--Si en el rango de tiempo de KPIs (Start/End de tabla K):
				-- no tenemos info (InfoTramo=0) pero si hay info posterior (InfoPosterior>0),
				-- cogemos info de la primera info posterior al fin del rango de KPIs.
				(info.InfoTramo=0 and InfoPosterior>0 and l.msgtime between k.starttime and info.MsgTimePosterior)
			)
			and info.testid=l.testid
			and l.TestId > @maxTestid
		-- ********************************************************************************************************
		

		--union all	 declare @maxTestid as int=0
		insert into _temp
		--------------------------------------------------- 3G UL:	
		select 
			-- Test Info:
			--0 as CarrierIndex,				--0 :PCC,	1...7: SCC1...7
			null as LTEPDSCHInfoId,			
			'3G' as 'Info about',		
			'Uplink' as Direction, 
			l.sessionid, l.testid, l.posid, l.networkid, l.msgtime, lfin.msgtime as endTime, datediff(ms,l.msgtime, lfin.msgtime) as duration,

			-- THPUTs Info:
			l.EDCHThroughput/8.0  as 'Throughput',									-- EDCHThroughput: kb/s - queremos KBytes/s	Dato original Kbits				
			Convert(float,lfin.AverageTBSize/8.0) as 'BytesTransferred',				-- AverageTBSize:  b	- queremos Bytes
			Convert(float,lfin.AverageTBSize/NULLIF(1000.0*lfin.EDCHThroughput,0)) as 'TransferTime',		-- b/ 1000*(kb/s) = s	
			
			-- 4G Info:	
			null as use_BPSK_num,
			null as use_QPSK_num,			-- Number of TBs using QPSK
			null as use_16QAM_num,			-- Number of TBs using 16QAM	
			null as use_64QAM_num,			-- Number of TBs using 64QAM
			null as use_256QAM_num,		-- Number of TBs using 256QAM
			null as mod_use_denom,			-- Number of TBs

			null as LTESharedChannelUse_num,		-- Number of RBs (overall TBs)
			null as LTESharedChannelUse_den,

			null as num_RBs_num,					-- Number of RBs (overall TBs)
			null as num_RBs_den,					-- CUIDADO si hay Carrier Agregation!!!	-> valido para cada CC individual				
			null as num_RBs_den_dedicated,							

			null as TransmissionMode,
			null as MaxNumLayer,
			null as AvgMCS,

			--3G UL:
			lfin.AverageSG, 
			lfin.TTI,
			lfin.HappyRate, 
			lfin.DTXRate, 
			lfin.AverageTBsize,
			lfin.GrantedThroughput,
			lfin.ScheduledThroughput,
			lfin.RetransRate	
			
		from _temp_Test_Info_UL_3G info,HSUPAMACStatistics	l
		
		left outer join HSUPAMACStatistics lfin on lfin.testid=l.testid and lfin.msgid=l.msgid+1, 

		--DGP 16/10/2015: Se linka con ResultsKpi para quedarnos sólo con los tramos de descarga
		-- ********************************************************************************************************
				ResultsKpi k
		
		where l.sessionid=k.sessionid and l.testid=k.testid and (k.kpiid = 76002 or k.kpiid=78002)
			and (((info.InfoTramo>=2 or (info.InfoTramo<2 and info.InfoPosterior>0)) and l.msgtime between k.starttime and k.endtime)
				or
				(info.InfoTramo=1 and info.InfoPosterior=0 and info.Count_Info>1 and l.msgtime between info.MsgTimeAnterior and k.endtime))
			and info.testid=l.testid
			and l.TestId > @maxTestid
		union all
		select 
			-- Test Info:
			--0 as CarrierIndex,				--0 :PCC,	1...7: SCC1...7
			null as LTEPDSCHInfoId,			
			'3G' as 'Info about',		
			'Uplink' as Direction, 
			l.sessionid, l.testid, l.posid, l.networkid, l.msgtime, null as endtime, 1 as duration,

			-- THPUTs Info:
			l.EDCHThroughput/8.0  as 'Throughput',									-- EDCHThroughput: kb/s - queremos KBytes/s	Dato original Kbits				
			Convert(float,l.AverageTBSize/8.0) as 'BytesTransferred',				-- AverageTBSize:  b	- queremos Bytes
			Convert(float,l.AverageTBSize/NULLIF(1000.0*l.EDCHThroughput,0)) as 'TransferTime',		-- b/ 1000*(kb/s) = s	
			
			-- 4G Info:	
			null as use_BPSK_num,
			null as use_QPSK_num,			-- Number of TBs using QPSK
			null as use_16QAM_num,			-- Number of TBs using 16QAM	
			null as use_64QAM_num,			-- Number of TBs using 64QAM
			null as use_256QAM_num,		-- Number of TBs using 256QAM
			null as mod_use_denom,			-- Number of TBs

			null as LTESharedChannelUse_num,		-- Number of RBs (overall TBs)
			null as LTESharedChannelUse_den,

			null as num_RBs_num,					-- Number of RBs (overall TBs)
			null as num_RBs_den,					-- CUIDADO si hay Carrier Agregation!!!	-> valido para cada CC individual				
			null as num_RBs_den_dedicated,							

			null as TransmissionMode,
			null as MaxNumLayer,
			null as AvgMCS,

			--3G UL:
			l.AverageSG, 
			l.TTI,
			l.HappyRate, 
			l.DTXRate, 
			l.AverageTBsize,
			l.GrantedThroughput,
			l.ScheduledThroughput,
			l.RetransRate	
			
		from _temp_Test_Info_UL_3G info,HSUPAMACStatistics	l, 

		--DGP 16/10/2015: Se linka con ResultsKpi para quedarnos sólo con los tramos de descarga
		-- ********************************************************************************************************
				ResultsKpi k
		
		where l.sessionid=k.sessionid and l.testid=k.testid and (k.kpiid = 76002 or k.kpiid=78002)
			and (
				--Si en el rango de tiempo de KPIs (Start/End de tabla K):
				-- tenemos sólo 1 registro con info (InfoTramo=1) y es la única info disponible (Count_Info=1),
				-- cogemos ese instante de tiempo y su info correspondiente (no la posterior ya que no existe).
				(l.msgtime between k.starttime and k.endtime and info.InfoTramo=1 and info.Count_Info=1)
				or
				--Si en el rango de tiempo de KPIs (Start/End de tabla K):
				-- no tenemos info (InfoTramo=0) pero si hay info posterior (InfoPosterior>0),
				-- cogemos info de la primera info posterior al fin del rango de KPIs.
				(info.InfoTramo=0 and InfoPosterior>0 and l.msgtime between k.starttime and info.MsgTimePosterior)
			)
			and info.testid=l.testid
			and l.TestId > @maxTestid
		-- ********************************************************************************************************


		--union all	 declare @maxTestid as int=0
		insert into _temp
		--------------------------------------------------- 3G DL:	
		select 
			-- Test Info:
			null as LTEPDSCHInfoId,			
			'3G' as 'Info about',		
			'Downlink' as Direction, 
			l.sessionid, l.testid, l.posid, l.networkid, l.msgtime, lfin.msgtime as endTime, datediff(ms,l.msgtime, lfin.msgtime) as duration,

			-- THPUTs Info:
			l.DSCHThroughput/8000.0 as 'Throughput',					-- DSCHThroughput: bps	- queremos KBytes/s	
			Convert(float,lfin.DSCHTBSize/8.0) as 'BytesTransferred',		-- DSCHTBSize:  b		- queremos Bytes
			Convert(float,lfin.DSCHTBSize)/NULLIF(1.0*lfin.DSCHThroughput, 0) as 'TransferTime',		-- b / bps = s
			
			-- 4G Info:	
			null as use_BPSK_num,
			null as use_QPSK_num,			-- Number of TBs using QPSK
			null as use_16QAM_num,			-- Number of TBs using 16QAM	
			null as use_64QAM_num,			-- Number of TBs using 64QAM
			null as use_256QAM_num,		-- Number of TBs using 256QAM
			null as mod_use_denom,			-- Number of TBs

			null as LTESharedChannelUse_num,		-- Number of RBs (overall TBs)
			null as LTESharedChannelUse_den,

			null as num_RBs_num,					-- Number of RBs (overall TBs)
			null as num_RBs_den,					-- CUIDADO si hay Carrier Agregation!!!	-> valido para cada CC individual				
			null as num_RBs_den_dedicated,							

			null as TransmissionMode,
			null as MaxNumLayer,
			null as AvgMCS,

			--3G UL:
			null as AverageSG, 
			null as TTI,
			null as HappyRate, 
			null as DTXRate, 
			null as AverageTBsize,
			null as GrantedThroughput,
			null as ScheduledThroughput,
			null as RetransRate	
			
		from _temp_Test_Info_DL_3G info,HSDPAThroughput l
		
		left outer join HSDPAThroughput lfin on lfin.testid=l.testid and lfin.msgid=l.msgid+1,	
		--DGP 16/10/2015: Se linka con ResultsKpi para quedarnos sólo con los tramos de descarga
		-- ********************************************************************************************************
				ResultsKpi k
		
		where l.sessionid=k.sessionid and l.testid=k.testid and (k.kpiid=75502 or k.kpiid=76502 or k.kpiid=77002 or k.kpiid=77502)
			and (((info.InfoTramo>=2 or (info.InfoTramo<2 and info.InfoPosterior>0)) and l.msgtime between k.starttime and k.endtime)
				or
				(info.InfoTramo=1 and info.InfoPosterior=0 and info.Count_Info>1 and l.msgtime between info.MsgTimeAnterior and k.endtime))
			and info.testid=l.testid
			and l.TestId > @maxTestid
		union all
		select 
			-- Test Info:
			null as LTEPDSCHInfoId,			
			'3G' as 'Info about',		
			'Downlink' as Direction, 
			l.sessionid, l.testid, l.posid, l.networkid, l.msgtime, null as endtime, 1 as duration,

			-- THPUTs Info:
			l.DSCHThroughput/8000.0 as 'Throughput',					-- DSCHThroughput: bps	- queremos KBytes/s	
			Convert(float,l.DSCHTBSize/8.0) as 'BytesTransferred',		-- DSCHTBSize:  b		- queremos Bytes
			Convert(float,l.DSCHTBSize)/NULLIF(1.0*l.DSCHThroughput, 0) as 'TransferTime',		-- b / bps = s
			
			-- 4G Info:	
			null as use_BPSK_num,
			null as use_QPSK_num,			-- Number of TBs using QPSK
			null as use_16QAM_num,			-- Number of TBs using 16QAM	
			null as use_64QAM_num,			-- Number of TBs using 64QAM
			null as use_256QAM_num,		-- Number of TBs using 256QAM
			null as mod_use_denom,			-- Number of TBs

			null as LTESharedChannelUse_num,		-- Number of RBs (overall TBs)
			null as LTESharedChannelUse_den,

			null as num_RBs_num,					-- Number of RBs (overall TBs)
			null as num_RBs_den,					-- CUIDADO si hay Carrier Agregation!!!	-> valido para cada CC individual				
			null as num_RBs_den_dedicated,							

			null as TransmissionMode,
			null as MaxNumLayer,
			null as AvgMCS,

			--3G UL:
			null as AverageSG, 
			null as TTI,
			null as HappyRate, 
			null as DTXRate, 
			null as AverageTBsize,
			null as GrantedThroughput,
			null as ScheduledThroughput,
			null as RetransRate	
			
		from _temp_Test_Info_DL_3G info,HSDPAThroughput l,
			
		--DGP 16/10/2015: Se linka con ResultsKpi para quedarnos sólo con los tramos de descarga
		-- ********************************************************************************************************
				ResultsKpi k
		
		where l.sessionid=k.sessionid and l.testid=k.testid and (k.kpiid=75502 or k.kpiid=76502 or k.kpiid=77002 or k.kpiid=77502)
			and (
				--Si en el rango de tiempo de KPIs (Start/End de tabla K):
				-- tenemos sólo 1 registro con info (InfoTramo=1) y es la única info disponible (Count_Info=1),
				-- cogemos ese instante de tiempo y su info correspondiente (no la posterior ya que no existe).
				(l.msgtime between k.starttime and k.endtime and info.InfoTramo=1 and info.Count_Info=1)
				or
				--Si en el rango de tiempo de KPIs (Start/End de tabla K):
				-- no tenemos info (InfoTramo=0) pero si hay info posterior (InfoPosterior>0),
				-- cogemos info de la primera info posterior al fin del rango de KPIs.
				(info.InfoTramo=0 and InfoPosterior>0 and l.msgtime between k.starttime and info.MsgTimePosterior)
			)
			and info.testid=l.testid
			and l.TestId > @maxTestid
		-- ********************************************************************************************************

----------------------------------------


-- Se rellena la tabla final, con info agregada y por carrier (PCC, SCC1...SCC7)   declare @maxTestid as int=0
insert into lcc_Physical_Info_Table
([LTEPDSCHInfoId] ,	[Info about] ,	[Direction] ,	[sessionid] ,	[testid] ,	[posid] ,	[networkid],	[msgtime] ,[endtime] ,[duration] ,
	[Throughput] ,	[BytesTransferred],	[TransferTime] ,	[use_BPSK_num] ,	[use_QPSK_num] ,	[use_16QAM_num] ,
	[use_64QAM_num],[use_256QAM_num],	[mod_use_denom] ,	[LTESharedChannelUse_num] ,	[LTESharedChannelUse_den],	[num_RBs_num] ,
	[num_RBs_den] ,	[num_RBs_den_dedicated] ,	[TransmissionMode] ,	[MaxNumLayer],	[AvgMCS] ,	[AverageSG] ,	[TTI] ,
	[HappyRate] ,	[DTXRate] ,	[AverageTBsize] ,	[GrantedThroughput] ,	[ScheduledThroughput] ,	[RetransRate] ,[msgtimeID], [number_Carrier])

select t.*,
	ROW_NUMBER() over (partition by t.sessionid, t.testid order by t.msgtime asc) as msgtimeID, 0 as number_Carrier
from _temp t, testinfo test
where test.SessionId=t.SessionId and test.TestId=t.TestId
	and test.TestId > @maxTestid		--and test.valid=1		-- para estar a la par con Seving Cell Table


	-- Info 4G por carrier

	--Info PCC
	update lcc_Physical_Info_Table
		
	set 
		[Throughput_PCC]=pcc.Throughput, [BytesTransferred_PCC]=pcc.BytesTransferred, [TransferTime_PCC]=pcc.TransferTime,
	[use_QPSK_num_PCC]=pcc.use_QPSK_num, [use_16QAM_num_PCC]=pcc.use_16QAM_num, [use_64QAM_num_PCC]=pcc.use_64QAM_num, [use_256QAM_num_PCC]=pcc.use_256QAM_num, [mod_use_denom_PCC]=pcc.mod_use_denom,			
	[LTESharedChannelUse_num_PCC]=pcc.LTESharedChannelUse_num, [LTESharedChannelUse_den_PCC]=pcc.LTESharedChannelUse_den,
	[num_RBs_num_PCC]=pcc.num_RBs_num, [num_RBs_den_PCC]=pcc.num_RBs_den, [num_RBs_den_dedicated_PCC]=pcc.num_RBs_den_dedicated,									
	[TransmissionMode_PCC]=pcc.TransmissionMode, [MaxNumLayer_PCC]=pcc.MaxNumLayer, [AvgMCS_PCC]=pcc.AvgMCS,
	[number_Carrier]=[number_Carrier]+1
	
	from lcc_Physical_Info_Table t, 
	 _CA pcc 
	 where
	 t.LTEPDSCHInfoId=pcc.LTEPDSCHInfoId and pcc.CarrierIndex=0 and pcc.testid=t.testid

	--Info SCC1
	update lcc_Physical_Info_Table 
		
	set
		[Throughput_SCC1]=scc1.Throughput, [BytesTransferred_SCC1]=scc1.BytesTransferred, [TransferTime_SCC1]=scc1.TransferTime,
	[use_QPSK_num_SCC1]=scc1.use_QPSK_num, [use_16QAM_num_SCC1]=scc1.use_16QAM_num, [use_64QAM_num_SCC1]=scc1.use_64QAM_num, [use_256QAM_num_SCC1]=scc1.use_256QAM_num, [mod_use_denom_SCC1]=scc1.mod_use_denom,			
	[LTESharedChannelUse_num_SCC1]=scc1.LTESharedChannelUse_num, [LTESharedChannelUse_den_SCC1]=scc1.LTESharedChannelUse_den,
	[num_RBs_num_SCC1]=scc1.num_RBs_num, [num_RBs_den_SCC1]=scc1.num_RBs_den, [num_RBs_den_dedicated_SCC1]=scc1.num_RBs_den_dedicated,										
	[TransmissionMode_SCC1]=scc1.TransmissionMode, [MaxNumLayer_SCC1]=scc1.MaxNumLayer, [AvgMCS_SCC1]=scc1.AvgMCS,
	[number_Carrier]=[number_Carrier]+1

	from lcc_Physical_Info_Table t, 
	 _CA scc1 
	 where
	 t.LTEPDSCHInfoId=scc1.LTEPDSCHInfoId and scc1.CarrierIndex=1 and scc1.testid=t.testid
	
	--Info SCC2
	update lcc_Physical_Info_Table 
		
	set
		[Throughput_SCC2]=scc2.Throughput, [BytesTransferred_SCC2]=scc2.BytesTransferred, [TransferTime_SCC2]=scc2.TransferTime,
	[use_QPSK_num_SCC2]=scc2.use_QPSK_num, [use_16QAM_num_SCC2]=scc2.use_16QAM_num, [use_64QAM_num_SCC2]=scc2.use_64QAM_num, [use_256QAM_num_SCC2]=scc2.use_256QAM_num, [mod_use_denom_SCC2]=scc2.mod_use_denom,			
	[LTESharedChannelUse_num_SCC2]=scc2.LTESharedChannelUse_num, [LTESharedChannelUse_den_SCC2]=scc2.LTESharedChannelUse_den,
	[num_RBs_num_SCC2]=scc2.num_RBs_num, [num_RBs_den_SCC2]=scc2.num_RBs_den, [num_RBs_den_dedicated_SCC2]=scc2.num_RBs_den_dedicated,									
	[TransmissionMode_SCC2]=scc2.TransmissionMode, [MaxNumLayer_SCC2]=scc2.MaxNumLayer, [AvgMCS_SCC2]=scc2.AvgMCS,
	[number_Carrier]=[number_Carrier]+1

	from lcc_Physical_Info_Table t, 
	 _CA scc2 
	 where
	 t.LTEPDSCHInfoId=scc2.LTEPDSCHInfoId and scc2.CarrierIndex=2 and scc2.testid=t.testid

	--Info SCC3
	update lcc_Physical_Info_Table 
		
	set
		[Throughput_SCC3]=scc3.Throughput, [BytesTransferred_SCC3]=scc3.BytesTransferred, [TransferTime_SCC3]=scc3.TransferTime,
	[use_QPSK_num_SCC3]=scc3.use_QPSK_num, [use_16QAM_num_SCC3]=scc3.use_16QAM_num, [use_64QAM_num_SCC3]=scc3.use_64QAM_num, [use_256QAM_num_SCC3]=scc3.use_256QAM_num, [mod_use_denom_SCC3]=scc3.mod_use_denom,			
	[LTESharedChannelUse_num_SCC3]=scc3.LTESharedChannelUse_num, [LTESharedChannelUse_den_SCC3]=scc3.LTESharedChannelUse_den,
	[num_RBs_num_SCC3]=scc3.num_RBs_num, [num_RBs_den_SCC3]=scc3.num_RBs_den, [num_RBs_den_dedicated_SCC3]=scc3.num_RBs_den_dedicated,									
	[TransmissionMode_SCC3]=scc3.TransmissionMode, [MaxNumLayer_SCC3]=scc3.MaxNumLayer, [AvgMCS_SCC3]=scc3.AvgMCS,
	[number_Carrier]=[number_Carrier]+1

	from lcc_Physical_Info_Table t, 
	 _CA scc3 
	 where
	 t.LTEPDSCHInfoId=scc3.LTEPDSCHInfoId and scc3.CarrierIndex=3 and scc3.testid=t.testid

	--Info SCC4
	update lcc_Physical_Info_Table 
		
	set
		[Throughput_SCC4]=scc4.Throughput, [BytesTransferred_SCC4]=scc4.BytesTransferred, [TransferTime_SCC4]=scc4.TransferTime,
	[use_QPSK_num_SCC4]=scc4.use_QPSK_num, [use_16QAM_num_SCC4]=scc4.use_16QAM_num, [use_64QAM_num_SCC4]=scc4.use_64QAM_num, [use_256QAM_num_SCC4]=scc4.use_256QAM_num, [mod_use_denom_SCC4]=scc4.mod_use_denom,			
	[LTESharedChannelUse_num_SCC4]=scc4.LTESharedChannelUse_num, [LTESharedChannelUse_den_SCC4]=scc4.LTESharedChannelUse_den,
	[num_RBs_num_SCC4]=scc4.num_RBs_num, [num_RBs_den_SCC4]=scc4.num_RBs_den, [num_RBs_den_dedicated_SCC4]=scc4.num_RBs_den_dedicated,									
	[TransmissionMode_SCC4]=scc4.TransmissionMode, [MaxNumLayer_SCC4]=scc4.MaxNumLayer, [AvgMCS_SCC4]=scc4.AvgMCS,
	[number_Carrier]=[number_Carrier]+1

	from lcc_Physical_Info_Table t, 
	 _CA scc4 
	 where
	 t.LTEPDSCHInfoId=scc4.LTEPDSCHInfoId and scc4.CarrierIndex=4 and scc4.testid=t.testid

	--Info SCC5
	update lcc_Physical_Info_Table 
		
	set
		[Throughput_SCC5]=scc5.Throughput, [BytesTransferred_SCC5]=scc5.BytesTransferred, [TransferTime_SCC5]=scc5.TransferTime,
	[use_QPSK_num_SCC5]=scc5.use_QPSK_num, [use_16QAM_num_SCC5]=scc5.use_16QAM_num, [use_64QAM_num_SCC5]=scc5.use_64QAM_num, [use_256QAM_num_SCC5]=scc5.use_256QAM_num, [mod_use_denom_SCC5]=scc5.mod_use_denom,			
	[LTESharedChannelUse_num_SCC5]=scc5.LTESharedChannelUse_num, [LTESharedChannelUse_den_SCC5]=scc5.LTESharedChannelUse_den,
	[num_RBs_num_SCC5]=scc5.num_RBs_num, [num_RBs_den_SCC5]=scc5.num_RBs_den, [num_RBs_den_dedicated_SCC5]=scc5.num_RBs_den_dedicated,									
	[TransmissionMode_SCC5]=scc5.TransmissionMode, [MaxNumLayer_SCC5]=scc5.MaxNumLayer, [AvgMCS_SCC5]=scc5.AvgMCS,
	[number_Carrier]=[number_Carrier]+1

	from lcc_Physical_Info_Table t, 
	 _CA scc5 
	 where
	 t.LTEPDSCHInfoId=scc5.LTEPDSCHInfoId and scc5.CarrierIndex=5 and scc5.testid=t.testid

	--Info SCC6
	update lcc_Physical_Info_Table 
		
	set
		[Throughput_SCC6]=scc6.Throughput, [BytesTransferred_SCC6]=scc6.BytesTransferred, [TransferTime_SCC6]=scc6.TransferTime,
	[use_QPSK_num_SCC6]=scc6.use_QPSK_num, [use_16QAM_num_SCC6]=scc6.use_16QAM_num, [use_64QAM_num_SCC6]=scc6.use_64QAM_num, [use_256QAM_num_SCC6]=scc6.use_256QAM_num, [mod_use_denom_SCC6]=scc6.mod_use_denom,			
	[LTESharedChannelUse_num_SCC6]=scc6.LTESharedChannelUse_num, [LTESharedChannelUse_den_SCC6]=scc6.LTESharedChannelUse_den,
	[num_RBs_num_SCC6]=scc6.num_RBs_num, [num_RBs_den_SCC6]=scc6.num_RBs_den, [num_RBs_den_dedicated_SCC6]=scc6.num_RBs_den_dedicated,									
	[TransmissionMode_SCC6]=scc6.TransmissionMode, [MaxNumLayer_SCC6]=scc6.MaxNumLayer, [AvgMCS_SCC6]=scc6.AvgMCS,
	[number_Carrier]=[number_Carrier]+1

	from lcc_Physical_Info_Table t, 
	 _CA scc6 
	 where
	 t.LTEPDSCHInfoId=scc6.LTEPDSCHInfoId and scc6.CarrierIndex=6 and scc6.testid=t.testid

	--Info SCC7
	update lcc_Physical_Info_Table 
		
	set
		[Throughput_SCC7]=scc7.Throughput, [BytesTransferred_SCC7]=scc7.BytesTransferred, [TransferTime_SCC7]=scc7.TransferTime,
	[use_QPSK_num_SCC7]=scc7.use_QPSK_num, [use_16QAM_num_SCC7]=scc7.use_16QAM_num, [use_64QAM_num_SCC7]=scc7.use_64QAM_num, [use_256QAM_num_SCC7]=scc7.use_256QAM_num, [mod_use_denom_SCC7]=scc7.mod_use_denom,			
	[LTESharedChannelUse_num_SCC7]=scc7.LTESharedChannelUse_num, [LTESharedChannelUse_den_SCC7]=scc7.LTESharedChannelUse_den,
	[num_RBs_num_SCC7]=scc7.num_RBs_num, [num_RBs_den_SCC7]=scc7.num_RBs_den, [num_RBs_den_dedicated_SCC7]=scc7.num_RBs_den_dedicated,									
	[TransmissionMode_SCC7]=scc7.TransmissionMode, [MaxNumLayer_SCC7]=scc7.MaxNumLayer, [AvgMCS_SCC7]=scc7.AvgMCS,
	[number_Carrier]=[number_Carrier]+1

	from lcc_Physical_Info_Table t, 
	 _CA scc7 
	 where
	 t.LTEPDSCHInfoId=scc7.LTEPDSCHInfoId and scc7.CarrierIndex=7 and scc7.testid=t.testid

 -- Identificamos test que contengan info en el rango de tiempo de KPIs (Start/End de tabla K) y también un registro posterior:
-- (para incorporar info posterior nos basamos en que no haya info en rango pero se evalua de forma independiente por tecnología, en estos
-- test hay info en el rango de otra tecnología, por lo que, debemos borrar la info posterior incorporada)
exec sp_lcc_dropifexists '_test_Borrar_infoPost'	
select t.testid, count(1) as 'Num_Reg', 
	sum(case when t.msgtime between k.starttime and k.endtime then 1 else 0 end) as 'Reg_Interv',
	sum(case when k.endtime < t.msgtime then 1 else 0 end) as 'Reg_Post',
	sum(case when k.starttime > t.msgtime then 1 else 0 end) as 'Reg_Ant',
	max(msgtimeID) as 'MaxID'
into _test_Borrar_infoPost
from lcc_Physical_Info_Table t 
	inner join _intervalos k
	on t.sessionid=k.sessionid and t.testid=k.testid
group by t.testid
having count(1) <> sum(case when t.msgtime between k.starttime and k.endtime then 1 else 0 end)
	and count(1)>1 and sum(case when k.endtime < t.msgtime then 1 else 0 end)>0

delete lcc_Physical_Info_Table
from lcc_Physical_Info_Table p 
	inner join _test_Borrar_infoPost t on t.testid=p.testid
where p.msgtimeID=t.MaxID
end

-- Borrado de la tabla temporal
exec sp_lcc_dropifexists '_intervalos'
exec sp_lcc_dropifexists '_CA_carrierId'
exec sp_lcc_dropifexists '_CA'
exec sp_lcc_dropifexists '_temp'
exec dbo.sp_lcc_dropifexists '_temp_Test_Info_DL_4G'
exec dbo.sp_lcc_dropifexists '_temp_Test_Info_UL_4G'
exec dbo.sp_lcc_dropifexists '_temp_Test_Info_DL_3G'
exec dbo.sp_lcc_dropifexists '_temp_Test_Info_UL_3G'
exec sp_lcc_dropifexists '_test_Borrar_infoPost'

