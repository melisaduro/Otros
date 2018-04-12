USE [FY1617_TEST_CECI]
GO
/****** Object:  StoredProcedure [dbo].[plcc_voice_Qlik]    Script Date: 07/08/2017 13:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[plcc_voice_Qlik]

	  @monthYear as nvarchar(50)
	 ,@ReportWeek as nvarchar(50)
	 ,@last_measurement as varchar(256)
	 ,@id as varchar(50)
	 ,@report as varchar(50)		

AS
 
 
 ------------------------------------------------- EXPLICACIÓN CÓDIGO ----------------------------------------------------------


/* En la primera parte del código se sacan todos los Scopes, las carreteras y los AVEs saldrán con el acumulado de 4 y 3 vueltas respectivamente.
Se obtiene una tabla de entidades Vodafone (ya que si algo se invalida en este operador, directamente esa entidad no se entregaría) y se cruza 
con el resto de operadores para que, si estuviese invalidado en otro operador saliese a NULL.
   En la segunda parte del código se hace un Union ALL con el mismo código pero adaptado para sacar la última vuelta de las carreteras. Esto
se hace para el Scoring y el Q&D. En esta parte del código, si la última vuelta de las carreteras para algún operador estuviese invalidad directamente
nos quedamos con la última vuelta váldia
   Al final del código, y sin nada que ver con lo anterior, tenemos las ejecuciones de procedimientos para que CENTRAL pueda sacar la info
de carreteras por Región*/


-----------------------------------------------------------------------------------------------------------------------------------
 

 --declare @monthYear as nvarchar(50) = '201707'
 --declare @ReportWeek as nvarchar(50) = 'W30'
 --declare @last_measurement as varchar(256) = 'last_measurement_osp'
 --declare @id as varchar(50)='OSP'
 --declare @report as varchar(50)='D' --'D' para tabla DASHBOARD y 'Q' para tabla QLIK


----------------------------------------------- CREACIÓN INICIAL DE LAS TABLAS -------------------------------------------------------

exec sp_lcc_dropifexists '_Actualizacion_Qlik'
exec sp_lcc_dropifexists 'lcc_voice_final'

-- TABLA de SEGUIMIENTO de la ejecución del Procedimiento Kpis Qlik:
	
if (select name from sys.tables where type='u' and name='_Actualizacion_Qlik') is null
begin
	CREATE TABLE [dbo].[_Actualizacion_Qlik](
		[Status] [varchar](255) NULL,
		[Date] [datetime] NULL
	) ON [primary]

	insert into [dbo].[_Actualizacion_Qlik]
	select '1.Inicio ejecucion Kpis Qlik Voz', getdate()
end

if (select name from sys.tables where name='_All_voice') is null
begin
CREATE TABLE [dbo].[_All_voice](
	[SCOPE] [varchar](255) NULL,
	[TECHNOLOGY] [varchar](256) NULL,
	[TEST_TYPE] [nvarchar](256) NULL,
	[SCOPE_DASH] [varchar](255) NULL,
	[SCOPE_QLIK] [varchar](255) NULL,
	[ENTITIES_BBDD] [varchar](259) NULL,
	[ENTITIES_DASHBOARD] [varchar](255) NULL,
	[Calls] [float] NULL,
	[Blocks] [float] NULL,
	[MOC_Calls] [float] NULL,
	[MOC_Blocks] [float] NULL,
	[MTC_Calls] [float] NULL,
	[MTC_Blocks] [float] NULL,
	[Drops] [float] NULL,
	[NUMBERS OF CALLS Non Sustainability (NB)] [float] NULL,
	[NUMBERS OF CALLS Non Sustainability (WB)] [float] NULL,
	[CST_AL_MO] [float] NULL,
	[CST_AL_MT] [float] NULL,
	[CST_ALERTING] [float] NULL,
	[CST_CO_MO] [float] NULL,
	[CST_CO_MT] [float] NULL,
	[CST_CONNECT] [float] NULL,
	[AVERAGE VOICE QUALITY NB (MOS)] [float] NULL,
	[Samples_DL+UL_NB] [float] NULL,
	[MOS_NB_Below2_5_samples] [float] NULL,
	[AVERAGE VOICE QUALITY (MOS)] [float] NULL,
	[Samples_DL+UL] [float] NULL,
	[MOS_Below2_5_samples] [float] NULL,
	[VOLTE_AVG_RTT] [float] NULL,
	[WB AMR Only] [float] NULL,
	[AVERAGE WB AMR Only] [float] NULL,
	[Calls_Started_3G_WO_Fails] [float] NULL,
	[Calls_Started_2G_WO_Fails] [float] NULL,
	[Calls_Mixed] [float] NULL,
	[Calls_Started_4G_WO_Fails] [float] NULL,
	[Calls_Started_VOLTE_WO_Fails] [float] NULL,
	[Call_duration_3G] [float] NULL,
	[Call_duration_2G] [float] NULL,
	[CSFB_to_GSM_samples] [float] NULL,
	[CSFB_to_UMTS_samples] [float] NULL,
	[VOLTE_Calls_withSRVCC] [float] NULL,
	[URBAN_EXTENSION] [varchar](1) NOT NULL,
	[Population] [float] NULL,
	[SAMPLED_URBAN] [varchar](1) NOT NULL,
	[NUMBER_TEST_KM] [varchar](1) NOT NULL,
	[ROUTE] [varchar](1) NOT NULL,
	[ALGORITHM] [varchar](255) NULL,
	[LANGUAGE] [varchar](255) NULL,
	[PHONE_MODEL] [varchar](255) NULL,
	[FIRM_VERSION] [varchar](255) NULL,
	[LAST_ACQUISITION] [varchar](258) NULL,
	[Operador] [varchar](8) NULL,
	[MCC] [int] NULL,
	[MNC] [varchar](30) NULL,
	[OPCOS] [varchar](255) NULL,
	[RAN_VENDOR] [nvarchar](16) NULL,
	[SCENARIOS] [varchar](1000) NULL,
	[PROVINCIA] [nvarchar](255) NULL,
	[PROVINCIA_DASH] [nvarchar](255) NULL,
	[CCAA] [varchar](256) NULL,
	[CCAA_DASH] [varchar](256) NULL,
	[Zona_OSP] [nvarchar](10) NULL,
	[Zona_VDF] [nvarchar](10) NULL,
	[ORDEN_DASH] [varchar](255) NULL,
	--[report_type] [varchar](256) NULL,
	[id] [varchar](3) NOT NULL,
	[MonthYear] [varchar](10) NOT NULL,
	[ReportWeek] [varchar](10) NOT NULL
) ON [PRIMARY]

END

-------------------------------------------------------------------------------------------------------------------------------------


--if (select name from sys.tables where name='lcc_voice_final') is not null
--BEGIN	
--	If(Select MonthYear+ReportWeek+id from lcc_voice_final where MonthYear+ReportWeek+id = @monthYear+@ReportWeek+@id group by MonthYear+ReportWeek+id)<> ''
--	BEGIN
--	  set @monthYear = '666'
--	  set @ReportWeek  = 'W66'
--	END
--END





----------------

	insert into [dbo].[_Actualizacion_Qlik]
	select '1.1 RI Voz Finalizado', getdate()

----------------

-----------------------------------------------PRIMERA PARTE DEL CÓDIGO-------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------
truncate table [_All_Voice]

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1. Nos creamos una tabla base con toda la información llave de cada entidad y todas las entidades vodafone--------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------

exec('

exec FY1617_TEST_CECI.dbo.sp_lcc_dropifexists ''_base_entities_voice''

Select 	entities.operator,
		entities.meas_Tech,
		--l.report_type,
		entities.entity,
		Case when i.Scope like ''%EXTRA%'' then LEFT(i.Scope,len(i.Scope)-5) else i.Scope end as Scope_Qlik,
		v.Provincia as Provincia_comp,
		v.CCAA as CCAA_Comp,
		v.Region_VF as Zona_VDF,
		v.Region_OSP as Zona_OSP,
		v.pob13 as population

into _base_entities_voice
from 

		(Select entities_vdf.*

		from (

		    --Sacamos una tabla con todas las entidades que tiene vodafone (si una entidad no la tiene vodafone es que no se entrega) y las replicamos para cada uno de los operadores

				(Select distinct(entity),report_type,meas_tech,operator
				from [QLIK].dbo._RI_Voice_Completed_Qlik 
				where  '+@last_measurement+' > 0 
					and meas_tech not like ''%cover%''
					and meas_tech not like ''%volte%'')
				----Replicar para todos los operadores
					union all

				(Select distinct(entity),report_type,meas_tech,operator
				from [QLIK].dbo._RI_Voice_Completed_Qlik 
				where  '+@last_measurement+' > 0 
					and meas_round like ''%Fase 3%''
					and meas_tech like ''%volte%'')

					) entities_vdf

		) entities
	
left outer join 

		(Select * 
		from [QLIK].dbo._RI_Voice_Completed_Qlik 
		where '+@last_measurement+' > 0 
			and meas_LA=0 
			and meas_tech not like ''%cover%'') l 
			
		on (entities.entity=l.entity 
		and entities.operator=l.operator 
		and entities.report_type=l.report_type 
		and entities.meas_tech = l.meas_tech)

left outer join 

		agrids.dbo.vlcc_dashboard_info_scopes_new i on (entities.entity = i.entities_BBDD)

left outer join 

	    [AGRIDS_v2].dbo.lcc_ciudades_tipo_Project_V9 v on (entities.entity = v.entity_name)

group by entities.operator,
		 entities.meas_Tech,
		 --l.report_type, 
		 entities.entity,
		 Case when i.Scope like ''%EXTRA%'' then LEFT(i.Scope,len(i.Scope)-5) else i.Scope end,
		 v.Region_OSP,
		 v.Region_VF,
		 v.Provincia,
		 v.CCAA,
		 v.pob13')



-- 2. Nos creamos una tabla con toda la información, tanto para QLIK como para el DASHBOARD-------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------

	
exec(' insert into _All_Voice
		Select 
		v.type_scope as SCOPE,
		entities.meas_tech as TECHNOLOGY,
		q.calltype as TEST_TYPE,
		v.scope as SCOPE_DASH,
		entities.Scope_QLIK as SCOPE_QLIK,
		entities.entity as ENTITIES_BBDD,
		v.entities_dashboard as ENTITIES_DASHBOARD,
		sum(q.Calls) as Calls,
		sum(q.Blocks) as Blocks,
		sum(q.MOC_Calls) as MOC_Calls,
		sum(q.MOC_Blocks) as MOC_Blocks,
		sum(q.MTC_Calls) as MTC_Calls,
		sum(q.MTC_Blocks) as MTC_Blocks,
		sum(q.Drops) as Drops,
		sum(q.[NUMBERS OF CALLS Non Sustainability (NB)]) as [NUMBERS OF CALLS Non Sustainability (NB)],
		sum(q.[NUMBERS OF CALLS Non Sustainability (WB)]) as [NUMBERS OF CALLS Non Sustainability (WB)],
		sum(q.[CST_MO_AL_NUM])/nullif(SUM(q.CST_MO_AL_samples),0) as CST_AL_MO,
		sum(q.[CST_MT_AL_NUM])/nullif(SUM(q.CST_MT_AL_samples),0) as CST_AL_MT,
		sum(q.CST_ALERTING_NUM)/nullif(SUM(q.CST_MO_AL_samples+q.CST_MT_AL_samples),0) as CST_ALERTING,
		sum(q.[CST_MO_CO_NUM])/nullif(SUM(q.CST_MO_CO_samples),0) as CST_CO_MO,
		sum(q.[CST_MT_CO_NUM])/nullif(SUM(q.CST_MT_CO_samples),0) as CST_CO_MT,
		sum(q.CST_CONNECT_NUM)/nullif(SUM(q.CST_MO_CO_samples+q.CST_MT_CO_samples),0) as CST_CONNECT,
		sum(q.MOS_NB_Num)/nullif(sum (q.MOS_NB_Den),0) AS [AVERAGE VOICE QUALITY NB (MOS)],
		sum(q.[Samples_DL+UL_NB]) as [Samples_DL+UL_NB],
		sum(q.[MOS_NB_Samples_Under_2.5]) AS MOS_NB_Below2_5_samples,
		sum(q.MOS_Num)/nullif(sum(q.MOS_Samples),0) AS [AVERAGE VOICE QUALITY (MOS)],	
		sum(q.[Samples_DL+UL]) as [Samples_DL+UL],
		sum(q.[MOS_Overall_Samples_Under_2.5]) as MOS_Below2_5_samples,
		case when sum(q.VOLTE_SpeechDelay_Den)>0 then sum(q.[VOLTE_SpeechDelay_Num])/(sum(q.[VOLTE_SpeechDelay_Den])) end as VOLTE_AVG_RTT,
		sum(q.[WB AMR Only]) as [WB AMR Only],  
		sum(q.[WB_AMR_Only_Num])/nullif(sum(q.[WB_AMR_Only_Den]),0) as [AVERAGE WB AMR Only],
		sum(q.Calls_Started_3G_WO_Fails) as Calls_Started_3G_WO_Fails, 
		sum(q.Calls_Started_2G_WO_Fails) as Calls_Started_2G_WO_Fails,
		sum(q.Calls_Mixed) as Calls_Mixed,
		sum(q.Calls_Started_4G_WO_Fails) as Calls_Started_4G_WO_Fails,
		sum(q.VOLTE_Calls_Started_Ended_VOLTE) as Calls_Started_VOLTE_WO_Fails,
		sum(q.Call_duration_3G) as Call_duration_3G,
		sum(q.Call_duration_2G) as Call_duration_2G,
		sum(q.CSFB_to_GSM_samples) as CSFB_to_GSM_samples,
		sum(q.CSFB_to_UMTS_samples) as CSFB_to_UMTS_samples,
		sum(q.VOLTE_Calls_withSRVCC) as VOLTE_Calls_withSRVCC,
		'''' as URBAN_EXTENSION,		
		entities.population as [Population],
		--Prodedimiento km2 medidos
		'''' as SAMPLED_URBAN,
		'''' as NUMBER_TEST_KM,
		'''' as [ROUTE],
		t.[ALGORITHM] as [ALGORITHM],
		t.[SPEECH_LANGUAGE] as [LANGUAGE],
		t.SMARTPHONE_MODEL as PHONE_MODEL,
		t.FIRMWARE_VERSION as FIRM_VERSION,
		''20'' + max(q.Meas_Date) as LAST_ACQUISITION,
		entities.operator as Operador,
		t.MCC as MCC,
		convert(varchar,right(q.mnc,1)) as MNC,
		t.OPCOS as OPCOS,
		v.RAN_VENDOR_VDF as RAN_VENDOR,
		t.SCENARIO as SCENARIOS,
		entities.Provincia_comp as PROVINCIA,
		v.PROVINCIA_DASHBOARD as PROVINCIA_DASH,
		entities.CCAA_comp as CCAA,
		v.CCAA_DASHBOARD as CCAA_DASH,
		entities.Zona_OSP,
		entities.Zona_VDF,
		v.ORDER_DASHBOARD as ORDEN_DASH,
		--entities.report_type,
		'''+@id+''' as id,
	    '''+@monthYear+''' as MonthYear,
	    '''+@ReportWeek+''' as ReportWeek	
from _base_entities_voice entities
		
left join		  
		  (Select * from [QLIK].dbo._RI_Voice_Completed_Qlik 
			where '+@last_measurement+' > 0 
			and meas_tech not like ''%cover%'' 
			and meas_LA=0) q 
		   on (q.entity = entities.entity 
		   and q.operator = entities.operator 
		   --and q.report_type = entities.report_type 
		   and q.meas_tech = entities.meas_tech)
left outer join 
		[AGRIDS].dbo.[vlcc_dashboard_info_scopes_NEW] v
			on (entities.entity = v.entities_bbdd
				and v.report = case when '''+@id+'''=''OSP'' then ''MUN'' else '''+@id+''' end) 
left outer join		
		[AGRIDS].dbo.lcc_dashboard_info_Voice_FY1718 t
			on (t.scope=v.scope
			and t.technology=entities.meas_tech)
group by v.type_scope,
		entities.meas_tech,
		q.calltype,
		v.scope,
		entities.Scope_QLIK,
		entities.entity,
		v.entities_dashboard,
		entities.population,
		t.[ALGORITHM],
		t.[SPEECH_LANGUAGE],
		t.SMARTPHONE_MODEL,
		t.FIRMWARE_VERSION,
		entities.operator,
		t.MCC,
		convert(varchar,right(q.mnc,1)),
		t.OPCOS,
		v.RAN_VENDOR_VDF,
		t.SCENARIO,
		entities.Provincia_comp,
		v.PROVINCIA_DASHBOARD,
		entities.CCAA_comp,
		v.CCAA_DASHBOARD,
		entities.Zona_OSP,
		entities.Zona_VDF,
		v.ORDER_DASHBOARD--,
		--entities.report_type
union all
-- Añadimos la última vuelta de Carreteras ---------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------

	Select 
		v.type_scope as SCOPE,
		entities.meas_tech+''_1'' as TECHNOLOGY,
		q.calltype as TEST_TYPE,
		''MAIN HIGHWAYS LAST ROUND'' as SCOPE_DASH,
		''MAIN HIGHWAYS'' as SCOPE_QLIK,
		entities.entity as ENTITIES_BBDD,
		v.entities_dashboard as ENTITIES_DASHBOARD,
		sum(q.Calls) as Calls,
		sum(q.Blocks) as Blocks,
		sum(q.MOC_Calls) as MOC_Calls,
		sum(q.MOC_Blocks) as MOC_Blocks,
		sum(q.MTC_Calls) as MTC_Calls,
		sum(q.MTC_Blocks) as MTC_Blocks,
		sum(q.Drops) as Drops,
		sum(q.[NUMBERS OF CALLS Non Sustainability (NB)]) as [NUMBERS OF CALLS Non Sustainability (NB)],
		sum(q.[NUMBERS OF CALLS Non Sustainability (WB)]) as [NUMBERS OF CALLS Non Sustainability (WB)],
		sum(q.[CST_MO_AL_NUM])/nullif(SUM(q.CST_MO_AL_samples),0) as CST_AL_MO,
		sum(q.[CST_MT_AL_NUM])/nullif(SUM(q.CST_MT_AL_samples),0) as CST_AL_MT,
		sum(q.CST_ALERTING_NUM)/nullif(SUM(q.CST_MO_AL_samples+q.CST_MT_AL_samples),0) as CST_ALERTING,
		--Percentiles de CST_ALERTING
		sum(q.[CST_MO_CO_NUM])/nullif(SUM(q.CST_MO_CO_samples),0) as CST_CO_MO,
		sum(q.[CST_MT_CO_NUM])/nullif(SUM(q.CST_MT_CO_samples),0) as CST_CO_MT,
		sum(q.CST_CONNECT_NUM)/nullif(SUM(q.CST_MO_CO_samples+q.CST_MT_CO_samples),0) as CST_CONNECT,
		--Percentiles de CST_CONNECT
		sum(q.MOS_NB_Num)/nullif(sum (q.MOS_NB_Den),0) AS [AVERAGE VOICE QUALITY NB (MOS)],
		sum(q.[Samples_DL+UL_NB]) as [Samples_DL+UL_NB],
		--Desviacion estandar del MOS NB
		sum(q.[MOS_NB_Samples_Under_2.5]) AS MOS_NB_Below2_5_samples,
		--Percentil 5 de MOS_NB
		sum(q.MOS_Num)/nullif(sum(q.MOS_Samples),0) AS [AVERAGE VOICE QUALITY (MOS)],	
		sum(q.[Samples_DL+UL]) as [Samples_DL+UL],
		--Desviacion estandar del MOS
		sum(q.[MOS_Overall_Samples_Under_2.5]) as MOS_Below2_5_samples,
		--Percentil 5 de MOS_OVERALL
		case when sum(q.VOLTE_SpeechDelay_Den)>0 then sum(q.[VOLTE_SpeechDelay_Num])/(sum(q.[VOLTE_SpeechDelay_Den])) end as VOLTE_AVG_RTT,
		sum(q.[WB AMR Only]) as [WB AMR Only],  
		sum(q.[WB_AMR_Only_Num])/nullif(sum(q.[WB_AMR_Only_Den]),0) as [AVERAGE WB AMR Only],
		--Mediana Voice Quality WB AMR CODEC Only
		sum(q.Calls_Started_3G_WO_Fails) as Calls_Started_3G_WO_Fails, 
		sum(q.Calls_Started_2G_WO_Fails) as Calls_Started_2G_WO_Fails,
		sum(q.Calls_Mixed) as Calls_Mixed,
		sum(q.Calls_Started_4G_WO_Fails) as Calls_Started_4G_WO_Fails,
		sum(q.VOLTE_Calls_Started_Ended_VOLTE) as Calls_Started_VOLTE_WO_Fails,
		sum(q.Call_duration_3G) as Call_duration_3G,
		sum(q.Call_duration_2G) as Call_duration_2G,
		sum(q.CSFB_to_GSM_samples) as CSFB_to_GSM_samples,
		sum(q.CSFB_to_UMTS_samples) as CSFB_to_UMTS_samples,
		sum(q.VOLTE_Calls_withSRVCC) as VOLTE_Calls_withSRVCC,
		'''' as URBAN_EXTENSION,		
		entities.population as [Population],
		--Prodedimiento km2 medidos
		'''' as SAMPLED_URBAN,
		'''' as NUMBER_TEST_KM,
		'''' as [ROUTE],
		t.[ALGORITHM] as [ALGORITHM],
		t.[SPEECH_LANGUAGE] as [LANGUAGE],
		t.SMARTPHONE_MODEL as PHONE_MODEL,
		t.FIRMWARE_VERSION as FIRM_VERSION,
		''20'' + q.Meas_Date as LAST_ACQUISITION,
		entities.operator as Operador,
		t.MCC as MCC,
		convert(varchar,right(q.mnc,1)) as MNC,
		t.OPCOS as OPCOS,
		v.RAN_VENDOR_VDF as RAN_VENDOR,
		t.SCENARIO as SCENARIOS,
		entities.Provincia_comp as PROVINCIA,
		v.PROVINCIA_DASHBOARD as PROVINCIA_DASH,
		entities.CCAA_comp as CCAA,
		v.CCAA_DASHBOARD as CCAA_DASH,
		entities.Zona_OSP,
		entities.Zona_VDF,
		v.ORDER_DASHBOARD as ORDEN_DASH,
		--entities.report_type,
		'''+@id+''' as id,
	    '''+@monthYear+''' as MonthYear,
	    '''+@ReportWeek+''' as ReportWeek
from _base_entities_voice entities	
	
left join		  
		  (Select * from [QLIK].dbo._RI_Voice_Completed_Qlik) q 
		   on (q.entity = entities.entity 
		   and q.operator = entities.operator 
		   --and q.report_type = entities.report_type 
		   and q.meas_tech = entities.meas_tech)
left outer join 
		[AGRIDS].dbo.[vlcc_dashboard_info_scopes_NEW] v
			on (entities.entity = v.entities_bbdd
				and v.report = case when '''+@id+'''=''OSP'' then ''MUN'' else '''+@id+''' end) 

left outer join		
		[AGRIDS].dbo.lcc_dashboard_info_Voice_FY1718 t
			on (t.scope=v.scope
			and t.technology=entities.meas_tech)

where q.'+@last_measurement+' = 1 
	  and meas_LA=0
      and q.Scope = ''MAIN HIGHWAYS'' 
	  and (q.meas_tech like ''%Road%'')
group by v.type_scope,
		entities.meas_tech,
		q.calltype,
		v.scope,
		entities.Scope_QLIK,
		entities.entity,
		v.entities_dashboard,
		entities.population,
		t.[ALGORITHM],
		t.[SPEECH_LANGUAGE],
		t.SMARTPHONE_MODEL,
		t.FIRMWARE_VERSION,
		q.Meas_Date,
		entities.operator,
		t.MCC,
		convert(varchar,right(q.mnc,1)),
		t.OPCOS,
		v.RAN_VENDOR_VDF,
		t.SCENARIO,
		entities.Provincia_comp,
		v.PROVINCIA_DASHBOARD,
		entities.CCAA_comp,
		v.CCAA_DASHBOARD,
		entities.Zona_OSP,
		entities.Zona_VDF,
		v.ORDER_DASHBOARD--,
		--entities.report_type
')
		

-----------------------------------------------------------------------------------------------------------------------
-- AÑADIMOS LOS PERCENTILES Y DESVIACIONES TIPICAS PARA VST Y MOS------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

exec('

	insert into [dbo].[_Actualizacion_Qlik]
	select ''Fin 1.2 Añadidos Kpis Voz'', getdate()

----------------


exec [FY1617_TEST_CECI].[dbo].[plcc_voice_statistics] '+@last_measurement+'
exec [FY1617_TEST_CECI].[dbo].[plcc_voice_statistics_Columns_new] '''+@monthYear+''' ,'''+@ReportWeek+'''



----------------

insert into [dbo].[_Actualizacion_Qlik]
select ''Fin 1.3 Percentiles Ejecutados'', getdate()')


-----------------------------------------------------------------------------------------------------------------------
-- Contruimos la tabla final con todos los KPIs de voz ----------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
exec('
Select q.*
	  ,p.[Percentil95_CST_MO_AL]
      ,p.[Percentil95_CST_MT_AL]
      ,p.[Percentil95_CST_MOMT_AL]
      ,p.[Percentil95_CST_MO_CO]
      ,p.[Percentil95_CST_MT_CO]
      ,p.[Percentil95_CST_MOMT_CO]
      ,p.[Percentil5_MOS_OVERALL]
      ,p.[Percentil5_MOS_NB]
      ,p.[Median_MOS_WB]
      ,p.[Percentil95_CST_MO_AL_SCOPE]
      ,p.[Percentil95_CST_MT_AL_SCOPE]
      ,p.[Percentil95_CST_MOMT_AL_SCOPE]
      ,p.[Percentil95_CST_MO_CO_SCOPE]
      ,p.[Percentil95_CST_MT_CO_SCOPE]
      ,p.[Percentil95_CST_MOMT_CO_SCOPE]
      ,p.[Percentil5_MOS_OVERALL_SCOPE]
      ,p.[Percentil5_MOS_NB_SCOPE]
      ,p.[Median_MOS_WB_SCOPE]
      ,p.[Percentil95_CST_MO_AL_SCOPE_QLIK]
      ,p.[Percentil95_CST_MT_AL_SCOPE_QLIK]
      ,p.[Percentil95_CST_MOMT_AL_SCOPE_QLIK]
      ,p.[Percentil95_CST_MO_CO_SCOPE_QLIK]
      ,p.[Percentil95_CST_MT_CO_SCOPE_QLIK]
      ,p.[Percentil95_CST_MOMT_CO_SCOPE_QLIK]
      ,p.[Percentil5_MOS_OVERALL_SCOPE_QLIK]
      ,p.[Percentil5_MOS_NB_SCOPE_QLIK]
      ,p.[Median_MOS_WB_SCOPE_QLIK]
      ,r.[Desviacion_NB]
      ,r.[Desviacion_OVERALL]
      ,r.[Desviacion_NB_SCOPE]
      ,r.[Desviacion_OVERALL_SCOPE]
      ,r.[Desviacion_NB_SCOPE_QLIK]
      ,r.[Desviacion_OVERALL_SCOPE_QLIK]

into lcc_voice_final	  
from _All_Voice q 
		        left join _Percentiles p 
		        on (q.ENTITIES_BBDD=p.entidad 
		        	and q.operador = case when p.mnc=01 then ''Vodafone'' when p.mnc=03 then ''Orange'' when p.mnc=07 then ''Movistar'' when p.mnc=04 then ''Yoigo'' end
					and q.id= Case when p.Report_QLIK=''MUN'' then ''OSP'' else ''VDF'' end 
					and q.technology=p.meas_tech 
					and q.monthyear = p.monthyear 
					and q.ReportWeek=p.ReportWeek)
				

				left join _Desviaciones r 
		        on (q.ENTITIES_BBDD=r.entidad 
		        	and q.operador = case when r.mnc=01 then ''Vodafone'' when r.mnc=03 then ''Orange'' when r.mnc=07 then ''Movistar'' when r.mnc=04 then ''Yoigo'' end
					and q.id= Case when r.Report_QLIK=''MUN'' then ''OSP'' else ''VDF'' end 
					and q.technology=r.meas_tech 
					and r.monthyear = q.monthyear 
					and r.ReportWeek=q.ReportWeek)

where q.monthyear = '''+@monthYear+''' and q.ReportWeek = '''+@ReportWeek+'''

')

----------------

insert into [dbo].[_Actualizacion_Qlik]
select 'Fin 1.4 Tabla final rellena', getdate()


-----------------------------------------------------------------------------------------------------------------------
-- Contruimos la tabla especifica para QLIK o para el DASHBOARD en funcion de la entrada ------------------------------
-----------------------------------------------------------------------------------------------------------------------
exec FY1617_TEST_CECI.dbo.sp_lcc_dropifexists 'lcc_voice_final_dashboard'

exec('
if '''+@report+''' = ''D''
begin
	select 
		p.scope as SCOPE,
		case when p.technology like (''VOLTE ALL%'') then ''VOLTE_CAP'' when p.technology like (''VOLTE RealVOLTE%'') then ''VOLTE_REAL'' when p.technology like ''%4GOnly%'' then ''4G_ONLY'' when p.technology=''Road 4G'' then ''4G'' else p.technology end as TECHNOLOGY,
		p.test_type as TEST_TYPE,
		p.SCOPE_DASH as [TARGET ON SCOPE],
		p.ENTITIES_DASHBOARD as [CITIES_ROUTE_LINES_PLACE],
		p.calls as [CALL ATTEMPTS],
		p.blocks as [ACCESS FAILURES],
		case when p.test_type=''M2F'' then p.MOC_Calls else NULL end as [MO_CALL ATTEMPS],
		case when p.test_type=''M2F'' then p.MOC_Blocks else NULL end as [MO_CALL FAILURES],
		case when p.test_type=''M2F'' then p.MTC_Calls else NULL end  as [MT_CALL ATTEMPS],
		case when p.test_type=''M2F'' then p.MTC_Blocks else NULL end as [MT_CALL FAILURES],
		p.Drops as [VOICE DROPPED],
		p.[NUMBERS OF CALLS Non Sustainability (NB)],
		p.[NUMBERS OF CALLS Non Sustainability (WB)],
		case when p.test_type=''M2F'' then p.CST_AL_MO else NULL end as [CALL SETUP TIME AVG - MO - ALERTING],
		case when p.test_type=''M2F'' then p.CST_AL_MT else NULL end as [CALL SETUP TIME AVG - MT - ALERTING],
		p.CST_ALERTING as [CALL SETUP TIME AVG - ALERTING],
		case when p.test_type=''M2F'' then p.[Percentil95_CST_MO_AL] else NULL end as [CALL SETUP TIME 95TH - MO - ALERTING],
		case when p.test_type=''M2F'' then p.[Percentil95_CST_MT_AL] else NULL end as [CALL SETUP TIME 95TH - MT - ALERTING],
		p.[Percentil95_CST_MOMT_AL] as [CALL SETUP TIME 95TH - ALERTING],
		case when p.test_type=''M2F'' then p.CST_CO_MO else NULL end as [CALL SETUP TIME AVG - MO - CONNECT],
		case when p.test_type=''M2F'' then p.CST_CO_MT else NULL end as [CALL SETUP TIME AVG - MT - CONNECT],
		p.CST_CONNECT as [CALL SETUP TIME AVG - CONNECT],
		case when p.test_type=''M2F'' then p.[Percentil95_CST_MO_CO] else NULL end as [CALL SETUP TIME 95TH - MO - CONNECT],
		case when p.test_type=''M2F'' then p.[Percentil95_CST_MT_CO] else NULL end as [CALL SETUP TIME 95TH - MT - CONNECT],
		p.[Percentil95_CST_MOMT_CO] as [CALL SETUP TIME 95TH - CONNECT],
		p.[AVERAGE VOICE QUALITY NB (MOS)],
		p.[Samples_DL+UL_NB],
		case when p.test_type=''M2F'' then p.[Desviacion_NB] else null end as [STARDARD DESVIATION - NB],
		case when p.test_type=''M2F'' then p.MOS_NB_Below2_5_samples else null end as [NUMBERS OF VOICE SAMPLES < 2.5 - NB],
		case when p.test_type=''M2F'' then p.[Percentil5_MOS_NB] else null end as [5TH PERCENTILE - NB],
		p.[AVERAGE VOICE QUALITY (MOS)],	
		p.[Samples_DL+UL],
		case when p.test_type=''M2M'' then p.[Desviacion_OVERALL] ELSE NULL END as [STARDARD DESVIATION - OVERALL],
		case when p.test_type=''M2M'' then p.MOS_Below2_5_samples ELSE NULL END as [NUMBERS OF VOICE SAMPLES < 2.5 - OVERALL],
		case when p.test_type=''M2M'' then p.[Percentil5_MOS_OVERALL] ELSE NULL END as [5TH PERCENTILE - OVERALL],
		p.VOLTE_AVG_RTT as [VOLTE AVG. SPEECH DELAY],
		p.[WB AMR Only] as [NUMBERS OF CALL USING WB AMR CODEC ONLY],  
		p.[AVERAGE WB AMR Only] as [AVERAGE VOICE QUALITY WB AMR CODEC ONLY],
		case when p.operador=''YOIGO'' then NULL
			 when p.[WB AMR Only]=0 then NULL
			 else p.[Median_MOS_WB] end as [MEDIAN VOICE QUALITY WB AMR CODEC ONLY],
		p.Calls_Started_3G_WO_Fails as [VOICE CALLS STARTED AND TERMINATED ON 3G], 
		p.Calls_Started_2G_WO_Fails as [VOICE CALLS STARTED AND TERMINATED ON 2G],
		p.Calls_Mixed as [VOICE CALLS - MIXED],
		p.Calls_Started_4G_WO_Fails as [VOICE CALLS STARTED ON 4G],
		p.Calls_Started_VOLTE_WO_Fails as [VOICE CALLS STARTED AND TERMINATED ON VOLTE],
		p.Call_duration_3G as [3G TOTAL DURATION],
		p.Call_duration_2G as [2G TOTAL DURATION],
		p.CSFB_to_GSM_samples as  [CALLS ON 2G LAYER AFTER CSFB PROCEDURE],
		p.CSFB_to_UMTS_samples as [CALLS ON 3G LAYER AFTER CSFB PROCEDURE],
		p.VOLTE_Calls_withSRVCC as [CALLS WWITH SRVCC PROCEDURE],
		km.[AreaTotal(km2)] as URBAN_EXTENSION,
		p.[Population],
		convert(float,km.Porcentaje_medido)/100 as SAMPLED_URBAN,
		convert(float,p.calls)/convert(float,km.[AreaTotal(km2)])/(convert(float,km.Porcentaje_medido)/100) as NUMBER_TEST_KM,
		p.[ROUTE],
		p.[ALGORITHM],
		p.[LANGUAGE],
		p.PHONE_MODEL,
		p.FIRM_VERSION,
		p.LAST_ACQUISITION,
		p.Operador,
		p.MCC,
		p.MNC,
		p.OPCOS,
		p.RAN_VENDOR,
		p.SCENARIOS,
		p.PROVINCIA_DASH as PROVINCIA,
		p.CCAA_DASH as CCAA,
		case when p.id=''VDF'' then p.Zona_VDF else p.Zona_OSP end as ZONA
		
	into lcc_voice_final_dashboard
	from lcc_voice_final p
	left join lcc_km2_chequeo_mallado km
	on (p.ENTITIES_BBDD=km.entidad
		and (p.technology=km.techVoice 
			or replace(p.technology,''4GOnly'',''4G'')=km.techVoice 
			or replace(p.technology,''VOLTE ALL'',''VOLTE'')=km.techVoice 
			or replace(p.technology,''VOLTE RealVOLTE'',''VOLTE'')=km.techVoice)
		and p.LAST_ACQUISITION=''20'' + km.date_reporting)
	where p.technology not like ''%3G%''
		  and p.technology not like ''%VOLTE 4G%''
		  and p.SCOPE_DASH not like ''%ROUND%''
		  and scope is not null


end

if '''+@report+''' = ''Q''
begin
	select * 
	into lcc_voice_final_qlik
	from lcc_voice_final p
	where p.technology not like ''%3G%''
		  and p.technology not like ''%VOLTE 4G%''
		  and scope is not null

end



')


select 'Acabado con éxito'