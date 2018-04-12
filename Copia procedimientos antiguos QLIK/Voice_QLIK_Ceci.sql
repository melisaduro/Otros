USE FY1617_TEST_CECI

select * from _All_voice_melisa
--GO
--/****** Object:  StoredProcedure [dbo].[plcc_voice_Qlik_Ceci]    Script Date: 23/06/2017 12:29:01 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO



--CREATE PROCEDURE [dbo].[plcc_voice_Qlik_Melisa]

--	  @monthYear as nvarchar(50)
--	 ,@ReportWeek as nvarchar(50)
--	 ,@last_measurement as varchar(256)
--	 ,@id as varchar(50)

--AS
 
 
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
 

 declare @monthYear as nvarchar(50) = '201705'
 declare @ReportWeek as nvarchar(50) = 'W21'
 declare @last_measurement as varchar(256) = 'last_measurement_vdf'
 declare @id as varchar(50)='VDF'


----------------------------------------------- CREACIÓN INICIAL DE LAS TABLAS -------------------------------------------------------

--exec sp_lcc_dropifexists '_Actualizacion_Qlik'

-- TABLA de SEGUIMIENTO de la ejecución del Procedimiento Kpis Qlik:
	
	--if (select name from sys.tables where type='u' and name='_Actualizacion_Qlik') is null
	--begin
	--	CREATE TABLE [dbo].[_Actualizacion_Qlik](
	--		[Status] [varchar](255) NULL,
	--		[Date] [datetime] NULL
	--	) ON [primary]

	--	insert into [dbo].[_Actualizacion_Qlik]
	--	select '1.Inicio ejecucion Kpis Qlik Voz', getdate()
	--end


if (select name from sys.tables where name='lcc_ActWeek_Voice_Melisa') is null
begin
	CREATE TABLE [dbo].[lcc_ActWeek_Voice_Melisa](
	[Scope_Rest] [varchar](255) NULL,
	[operator] [varchar](8) NULL,
	[meas_tech] [varchar](256) NULL,
	[entity] [varchar](256) NULL,
	[report_type] [varchar](256) NULL,
	[id] [varchar](3) NOT NULL,
	[Calls] [int] NULL,
	[Blocks] [int] NULL,
	[MOC_Calls] [int] NULL,
	[MOC_Blocks] [int] NULL,
	[MTC_Calls] [int] NULL,
	[MTC_Blocks] [int] NULL,
	[Drops] [int] NULL,
	[NUMBERS OF CALLS Non Sustainability (NB)] [int] NULL,
	[NUMBERS OF CALLS Non Sustainability (WB)] [int] NULL,
	[CST_AL_MO] [float] NULL,
	[CST_AL_MT] [float] NULL,
	[CST_CO_MO] [float] NULL,
	[CST_CO_MT] [float] NULL,
	[CST_ALERTING] [float] NULL,
	[CST_CONNECT] [float] NULL,
	[AVERAGE VOICE QUALITY (MOS)] [float] NULL,
	[AVERAGE VOICE QUALITY NB (MOS)] [float] NULL,
	[Samples_DL+UL] [int] NULL,
	[Samples_DL+UL_NB] [int] NULL,
	[MOS_Below2_5_samples] [int] NULL,
	[MOS_NB_Below2_5_samples] [int] NULL,
	[WB AMR Only] [int] NULL,
	[Calls_Started_3G_WO_Fails] [int] NULL,
	[Calls_Started_2G_WO_Fails] [int] NULL,
	[Calls_Mixed] [int] NULL,
	[Calls_Started_4G_WO_Fails] [int] NULL,
	[Call_duration_3G] [float] NULL,
	[Call_duration_2G] [float] NULL,
	[CSFB_to_GSM_samples] [int] NULL,
	[CSFB_to_UMTS_samples] [int] NULL,
	[CSFB_samples] [int] NULL,
	[Zona_OSP] [nvarchar](5) NULL,
	[Zona_VDF] [nvarchar](7) NULL,
	[Provincia_comp] [nvarchar](255) NULL,
	[Type_Voice] [nvarchar](3) NOT NULL,
	[Population] [float] NULL,
	[MonthYear] [varchar](6) NOT NULL,
	[ReportWeek] [nvarchar](3) NOT NULL
	)

END

if (select name from sys.tables where name='lcc_voice_final_qlik_Melisa') is null
begin
	CREATE TABLE [dbo].[lcc_voice_final_qlik_Melisa](
	[Scope] [varchar](255) NULL,
	[operator] [varchar](8) NULL,
	[meas_tech] [varchar](256) NULL,
	[entity] [varchar](256) NULL,
	[report_type] [varchar](256) NULL,
	[id] [varchar](3) NOT NULL,
	[Calls] [int] NULL,
	[Blocks] [int] NULL,
	[MOC_Calls] [int] NULL,
	[MOC_Blocks] [int] NULL,
	[MTC_Calls] [int] NULL,
	[MTC_Blocks] [int] NULL,
	[Drops] [int] NULL,
	[NUMBERS OF CALLS Non Sustainability (NB)] [int] NULL,
	[NUMBERS OF CALLS Non Sustainability (WB)] [int] NULL,
	[CST_AL_MO] [float] NULL,
	[CST_AL_MT] [float] NULL,
	[CST_CO_MO] [float] NULL,
	[CST_CO_MT] [float] NULL,
	[CST_ALERTING] [float] NULL,
	[CST_CONNECT] [float] NULL,
	[AVERAGE VOICE QUALITY (MOS)] [float] NULL,
	[AVERAGE VOICE QUALITY NB (MOS)] [float] NULL,
	[Samples_DL+UL] [int] NULL,
	[Samples_DL+UL_NB] [int] NULL,
	[MOS_Below2_5_samples] [int] NULL,
	[MOS_NB_Below2_5_samples] [int] NULL,
	[WB AMR Only] [int] NULL,
	[Calls_Started_3G_WO_Fails] [int] NULL,
	[Calls_Started_2G_WO_Fails] [int] NULL,
	[Calls_Mixed] [int] NULL,
	[Calls_Started_4G_WO_Fails] [int] NULL,
	[Call_duration_3G] [float] NULL,
	[Call_duration_2G] [float] NULL,
	[CSFB_to_GSM_samples] [int] NULL,
	[CSFB_to_UMTS_samples] [int] NULL,
	[CSFB_samples] [int] NULL,
	[Zona_OSP] [nvarchar](5) NULL,
	[Zona_VDF] [nvarchar](7) NULL,
	[Provincia_comp] [nvarchar](255) NULL,
	[Type_Voice] [nvarchar](3) NOT NULL,
	[Population] [float] NULL,
	[MonthYear] [varchar](6) NOT NULL,
	[ReportWeek] [nvarchar](3) NOT NULL,
	[Percentil95_CST_MO_AL][float] NULL,
	[Percentil95_CST_MT_AL][float] NULL,
	[Percentil95_CST_MOMT_AL][float] NULL,
	[Percentil95_CST_MO_CO][float] NULL,
	[Percentil95_CST_MT_CO][float] NULL,
	[Percentil95_CST_MOMT_CO][float] NULL,
	[Percentil5_MOS_OVERALL][float] NULL,
	[Percentil5_MOS_NB][float] NULL,
	[Percentil95_CST_MO_AL_SCOPE][float] NULL,
	[Percentil95_CST_MT_AL_SCOPE][float] NULL,
	[Percentil95_CST_MOMT_AL_SCOPE][float] NULL,
	[Percentil95_CST_MO_CO_SCOPE][float] NULL,
	[Percentil95_CST_MT_CO_SCOPE][float] NULL,
	[Percentil95_CST_MOMT_CO_SCOPE][float] NULL,
	[Percentil5_MOS_OVERALL_SCOPE][float] NULL,
	[Percentil5_MOS_NB_SCOPE][float] NULL,
	[Percentil95_CST_MO_AL_SCOPE_QLIK][float] NULL,
	[Percentil95_CST_MT_AL_SCOPE_QLIK][float] NULL,
	[Percentil95_CST_MOMT_AL_SCOPE_QLIK][float] NULL,
	[Percentil95_CST_MO_CO_SCOPE_QLIK][float] NULL,
	[Percentil95_CST_MT_CO_SCOPE_QLIK][float] NULL,
	[Percentil95_CST_MOMT_CO_SCOPE_QLIK][float] NULL,
	[Percentil5_MOS_OVERALL_SCOPE_QLIK][float] NULL,
	[Percentil5_MOS_NB_SCOPE_QLIK][float] NULL,
	[Scope_Qlik][varchar](255) NULL

	)

END

-------------------------------------------------------------------------------------------------------------------------------------


if (select name from sys.tables where name='lcc_voice_final_qlik_Melisa') is not null
BEGIN	
	If(Select MonthYear+ReportWeek+id from lcc_voice_final_qlik_Melisa where MonthYear+ReportWeek+id = @monthYear+@ReportWeek+@id group by MonthYear+ReportWeek+id)<> ''
	BEGIN
	  set @monthYear = '666'
	  set @ReportWeek  = 'W66'
	END
END



----------------

	--insert into [dbo].[_Actualizacion_Qlik]
	--select '1.1 RI Voz Finalizado', getdate()

----------------

-----------------------------------------------PRIMERA PARTE DEL CÓDIGO-------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------
truncate table [lcc_ActWeek_Voice_Melisa]

exec('

exec QLIK.dbo.sp_lcc_dropifexists ''_All_voice_melisa''
exec QLIK.dbo.sp_lcc_dropifexists ''_base_entities_voice_melisa''



-- 1. Creamos una tabla con la suma de todos los attemps por operador, para la ponderación en los agregados, tipo carreteras y aves....
----------------------------------------------------------------------------------------------------------------------------------------------


Select entities.operator,entities.meas_Tech,entities.report_type,
		entities.entity as entidad,
		SUM(CST_MO_AL_samples) as CST_MO_AL_Samples_All,
		SUM(CST_MT_AL_samples) as CST_MT_AL_Samples_All,
		SUM(CST_MO_AL_samples+CST_MT_AL_samples) as CST_AL_Samples_All,
		SUM(CST_MO_CO_samples) as CST_MO_CO_Samples_All,
		SUM(CST_MT_CO_samples) as CST_MT_CO_Samples_All,
		SUM(CST_MO_CO_samples+CST_MT_CO_samples) as CST_CO_Samples_All,
		sum (MOS_Samples) as ''Mos_Samples_All'',
		sum (MOS_NB_Den) as ''MOS_NB_Den_ALL''
				  
into _All_voice_melisa


from 

-- Subquery para quedarnos con las entidades VDF y que todos los operadores tengan las mismas entidades.

	(Select entities_vdf.*, op.operator

	from (
		Select distinct(entity),report_type,meas_tech
		from [QLIK].dbo._RI_Voice_Completed_Qlik 
		where  ' +@last_measurement+ ' >0  and meas_tech not like ''%cover%'' and operator = ''Vodafone'') entities_vdf,

		(select operator from [QLIK].dbo._RI_Voice_Completed_Qlik group by operator) op

	) entities
	
left outer join (Select * from [QLIK].dbo._RI_Voice_Completed_Qlik where '+@last_measurement+' > 0 and meas_LA=0 and meas_tech not like ''%cover%'') l on (entities.entity=l.entity and entities.operator=l.operator and entities.report_type=l.report_type and entities.meas_tech = l.meas_tech) 


group by entities.entity,entities.operator,entities.meas_Tech,entities.report_type



-- 2. Nos creamos una tabla base con toda la información llave de cada entidad y todas las entidades vodafone--------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------


Select entities.operator,entities.meas_Tech,l.report_type,entities.entity,
		Case when i.Scope like ''%EXTRA%'' then LEFT(i.Scope,len(i.Scope)-5) else i.Scope end as Scope,v.Region_OSP as Zona_OSP,v.Region_VF as Zona_VDF,v.Provincia as Provincia_comp,i.population


into _base_entities_voice_melisa

from 

		(Select entities_vdf.*, op.operator

		from (

		    --Sacamos una tabla con todas las entidades que tiene vodafone (si una entidad no la tiene vodafone es que no se entrega) y las replicamos para cada uno de los operadores

				Select distinct(entity),report_type,meas_tech
				from [QLIK].dbo._RI_Voice_Completed_Qlik 
				where  '+@last_measurement+' > 0 and operator = ''Vodafone'' and meas_tech not like ''%cover%'') entities_vdf,

				(select operator from [QLIK].dbo._RI_Voice_Completed_Qlik group by operator) op

		) entities
	
left outer join 

		(Select * from [QLIK].dbo._RI_Voice_Completed_Qlik where '+@last_measurement+' > 0 and meas_LA=0 and meas_tech not like ''%cover%'') l on (entities.entity=l.entity and entities.operator=l.operator and entities.report_type=l.report_type and entities.meas_tech = l.meas_tech)

left outer join 

		agrids.dbo.lcc_dashboard_info_scopes_new i on (entities.entity = i.entities_BBDD)

left outer join 

	    [AGRIDS_v2].dbo.lcc_ciudades_tipo_Project_V9 v on (entities.entity = v.entity_name)

group by entities.operator,entities.meas_Tech,l.report_type, entities.entity,l.meas_tech,Case when i.Scope like ''%EXTRA%'' then LEFT(i.Scope,len(i.Scope)-5) else i.Scope end,v.Region_OSP,v.Region_VF,v.Provincia,i.population


----------------------------------------------------------------------------------------------------------------------------
	 
				
insert into lcc_ActWeek_Voice_Melisa


Select 
		Case when entities_vdf.scope like ''%EXTRA%'' then LEFT(entities_vdf.scope,len(entities_vdf.scope)-5) else entities_vdf.scope end as Scope_Rest,
		entities_vdf.operator,
		entities_vdf.meas_tech,
		entities_vdf.entity,
		entities_vdf.report_type,
		'''+@id+''' as id,
		sum(q.Calls) as Calls,
		sum(q.Blocks) as Blocks,
		sum(q.MOC_Calls) as MOC_Calls,
		sum(q.MOC_Blocks) as MOC_Blocks,
		sum(q.MTC_Calls) as MTC_Calls,
		sum(q.MTC_Blocks) as MTC_Blocks,
		sum(q.Drops) as Drops,
		sum(q.[NUMBERS OF CALLS Non Sustainability (NB)]) as [NUMBERS OF CALLS Non Sustainability (NB)],
		sum(q.[NUMBERS OF CALLS Non Sustainability (WB)]) as [NUMBERS OF CALLS Non Sustainability (WB)],
		sum(q.[CST_MO_AL_NUM])/nullif(a.CST_MO_AL_Samples_All,0) as CST_AL_MO,
		sum(q.[CST_MT_AL_NUM])/nullif(a.CST_MT_AL_Samples_All,0) as CST_AL_MT,
		sum(q.[CST_MO_CO_NUM])/nullif(a.CST_MO_CO_Samples_All,0) as CST_CO_MO,
		sum(q.[CST_MT_CO_NUM])/nullif(a.CST_MT_CO_Samples_All,0) as CST_CO_MT,
		sum(q.CST_ALERTING_NUM)/nullif(a.CST_AL_Samples_All,0) as CST_ALERTING,
		sum(q.CST_CONNECT_NUM)/nullif(a.CST_CO_Samples_All,0) as CST_CONNECT,
		sum(q.MOS_Num)/nullif(a.Mos_Samples_All,0) AS [AVERAGE VOICE QUALITY (MOS)],
		sum(q.MOS_NB_Num)/nullif(a.MOS_NB_Den_ALL,0) AS [AVERAGE VOICE QUALITY NB (MOS)],
		sum(q.[Samples_DL+UL]) as [Samples_DL+UL],
		sum(q.[Samples_DL+UL_NB]) as [Samples_DL+UL_NB],
		sum(q.[MOS_NB_Samples_Under_2.5])+sum(q.[MOS_Samples_Under_2.5]) as MOS_Below2_5_samples,
		sum(q.[MOS_NB_Samples_Under_2.5]) AS MOS_NB_Below2_5_samples,
		sum(q.[WB AMR Only]) as [WB AMR Only],  
		sum(q.Calls_Started_3G_WO_Fails) as Calls_Started_3G_WO_Fails,
		sum(q.Calls_Started_2G_WO_Fails) as Calls_Started_2G_WO_Fails,
		sum(q.Calls_Mixed) as Calls_Mixed,
		sum(q.Calls_Started_4G_WO_Fails) as Calls_Started_4G_WO_Fails,
		sum(q.Call_duration_3G) as Call_duration_3G,
		sum (q.Call_duration_2G) as Call_duration_2G,
		sum(q.CSFB_to_GSM_samples) as CSFB_to_GSM_samples,
		sum(q.CSFB_to_UMTS_samples) as CSFB_to_UMTS_samples,
		sum(q.CSFB_samples) as CSFB_samples, 

		entities_vdf.Zona_OSP,
		entities_vdf.Zona_VDF,
		entities_vdf.Provincia_comp,

		Case when entities_vdf.scope in (''SMALLER CITIES'',''MAIN CITIES'',''TOURISTIC AREA'',''MAIN HIGHWAYS'',''ADD-ON CITIES'',''ADD-ON CITIES EXTRA'') then ''M2M''
			 else ''M2F'' end as Type_Voice
		,entities_vdf.population as ''Population''
		,'''+@monthYear+''' as MonthYear
		,'''+@ReportWeek+''' as ReportWeek
		

from _base_entities_voice_melisa entities_vdf
	
	
left join
		  
		  (Select * from [QLIK].dbo._RI_Voice_Completed_Qlik q where '+@last_measurement+' > 0 and q.meas_tech not like ''%cover%'' and meas_LA=0) q on (q.entity = entities_vdf.entity and q.operator = entities_vdf.operator and q.report_type = entities_vdf.report_type and q.meas_tech = entities_vdf.meas_tech)

left join 

		 _All_voice_melisa a on (q.operator = a.operator and q.entity = a.entidad and entities_vdf.meas_Tech=a.meas_Tech and entities_vdf.report_type=a.report_type)

group by Case when entities_vdf.scope like ''%EXTRA%'' then LEFT(entities_vdf.scope,len(entities_vdf.scope)-5) else entities_vdf.scope end,entities_vdf.operator,entities_vdf.meas_tech,entities_vdf.report_type,entities_vdf.Zona_OSP,entities_vdf.Zona_VDF,entities_vdf.Provincia_comp,entities_vdf.population,entities_vdf.entity
		 ,a.Mos_Samples_All,a.CST_MO_AL_Samples_All,a.CST_MT_AL_Samples_All,a.CST_MO_CO_Samples_All,a.CST_MT_CO_Samples_All
		 ,a.CST_AL_Samples_All,a.CST_CO_Samples_All,Case when entities_vdf.scope in (''SMALLER CITIES'',''MAIN CITIES'',''TOURISTIC AREA'',''MAIN HIGHWAYS'',''ADD-ON CITIES'',''ADD-ON CITIES EXTRA'') then ''M2M'' else ''M2F'' end 
		 ,MOS_NB_Den_ALL

--UNION ALL


---- Añadimos la última vuelta de Carreteras ---------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------


--Select
--	''MAIN HIGHWAYS'' as Scope_Rest,
--	entities_vdf.operator,
--	entities_vdf.meas_tech+''_1'' as meas_tech,
--	entities_vdf.entity,
--	entities_vdf.report_type,
--	'''+@id+''' as id,
--	sum(q.Calls) as Calls,
--	sum(q.Blocks) as Blocks,
--	sum(q.MOC_Calls) as MOC_Calls,
--	sum(q.MOC_Blocks) as MOC_Blocks,
--	sum(q.MTC_Calls) as MTC_Calls,
--	sum(q.MTC_Blocks) as MTC_Blocks,
--	sum(q.Drops) as Drops,
--	sum(q.[NUMBERS OF CALLS Non Sustainability (NB)]) as [NUMBERS OF CALLS Non Sustainability (NB)],
--	sum(q.[NUMBERS OF CALLS Non Sustainability (WB)]) as [NUMBERS OF CALLS Non Sustainability (WB)],
--	sum(q.[CST_MO_AL_NUM])/nullif(sum(CST_MO_AL_samples),0) as CST_AL_MO,
--	sum(q.[CST_MT_AL_NUM])/nullif(sum(CST_MT_AL_samples),0) as CST_AL_MT,
--	sum(q.[CST_MO_CO_NUM])/nullif(sum(CST_MO_CO_samples),0) as CST_CO_MO,
--	sum(q.[CST_MT_CO_NUM])/nullif(sum(CST_MT_CO_samples),0) as CST_CO_MT,
--	sum(q.CST_ALERTING_NUM)/nullif(sum(CST_MO_AL_samples+CST_MT_AL_samples),0) as CST_ALERTING,
--	sum(q.CST_CONNECT_NUM)/nullif(sum(CST_MO_CO_samples+CST_MT_CO_samples),0) as CST_CONNECT,
--	sum(q.MOS_Num)/nullif(sum(MOS_Samples),0) AS [AVERAGE VOICE QUALITY (MOS)],
--	sum(q.MOS_NB_Num)/nullif(sum(MOS_NB_Den),0) AS [AVERAGE VOICE QUALITY NB (MOS)],
--	sum(q.[Samples_DL+UL]) as [Samples_DL+UL],
--	sum(q.[Samples_DL+UL_NB]) as [Samples_DL+UL_NB],
--	sum(q.[MOS_NB_Samples_Under_2.5])+sum(q.[MOS_Samples_Under_2.5]) as MOS_Below2_5_samples,
--	sum(q.[WB AMR Only]) as [WB AMR Only],  
--	sum(q.[MOS_NB_Samples_Under_2.5]) AS MOS_NB_Below2_5_samples,
--	sum(q.Calls_Started_3G_WO_Fails) as Calls_Started_3G_WO_Fails,
--	sum(q.Calls_Started_2G_WO_Fails) as Calls_Started_2G_WO_Fails,
--	sum(q.Calls_Mixed) as Calls_Mixed,
--	sum(q.Calls_Started_4G_WO_Fails) as Calls_Started_4G_WO_Fails,
--	sum(q.Call_duration_3G) as Call_duration_3G,
--	sum (q.Call_duration_2G) as Call_duration_2G,
--	sum(q.CSFB_to_GSM_samples) as CSFB_to_GSM_samples,
--	sum(q.CSFB_to_UMTS_samples) as CSFB_to_UMTS_samples,
--	sum(q.CSFB_samples) as CSFB_samples, 

--	entities_vdf.Zona_OSP,
--	entities_vdf.Zona_VDF,
--	entities_vdf.Provincia_comp,
--    ''M2M'' as Type_Voice,
--	entities_vdf.population as ''Population''
--	,'''+@monthYear+''' as MonthYear
--	,'''+@ReportWeek+''' as ReportWeek
		

--	from  _base_entities_voice_melisa entities_vdf
	
	
--	  left join
--		  [QLIK].dbo._RI_Voice_Completed_Qlik q
     
--				on (q.entity = entities_vdf.entity and q.operator = entities_vdf.operator and q.report_type = entities_vdf.report_type and q.meas_tech = entities_vdf.meas_tech)


--	where q.'+@last_measurement+' = 1 and meas_LA=0
--		  AND q.Scope = ''MAIN HIGHWAYS'' and (q.meas_tech = ''Road 4G'' or q.meas_tech =''Road 4GOnly'')

--	group by entities_vdf.scope,entities_vdf.operator,entities_vdf.meas_tech,entities_vdf.report_type,entities_vdf.Zona_OSP,entities_vdf.Zona_VDF,entities_vdf.Provincia_comp,entities_vdf.population,entities_vdf.entity


-- AÑADIMOS LOS PERCENTILES PARA CST Y MOS ----------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------


----------------

	--insert into [dbo].[_Actualizacion_Qlik]
	--select ''Fin 1.2 Añadidos Kpis Voz'', getdate()

----------------


exec [QLIK].[dbo].[plcc_voice_statistics] '+@last_measurement+'
exec [QLIK].[dbo].[plcc_voice_statistics_Columns_new] '''+@monthYear+''' ,'''+@ReportWeek+'''



----------------

	--insert into [dbo].[_Actualizacion_Qlik]
	--select ''Fin 1.3 Percentiles Ejecutados'', getdate()

----------------



insert into lcc_voice_final_qlik_Melisa


Select q.Scope_Rest as SCOPE,
	   q.operator as TECHNOLOGY,
	   q.Type_Voice	as TYPE_OF_TEST,
	   q.Scope_Rest as SCOPE
	   	
	q.*,[Percentil95_CST_MO_AL],[Percentil95_CST_MT_AL],[Percentil95_CST_MOMT_AL],[Percentil95_CST_MO_CO],[Percentil95_CST_MT_CO],
		  [Percentil95_CST_MOMT_CO],[Percentil5_MOS_OVERALL],[Percentil5_MOS_NB],[Percentil95_CST_MO_AL_SCOPE],[Percentil95_CST_MT_AL_SCOPE],
		  [Percentil95_CST_MOMT_AL_SCOPE],[Percentil95_CST_MO_CO_SCOPE],[Percentil95_CST_MT_CO_SCOPE],[Percentil95_CST_MOMT_CO_SCOPE],
		  [Percentil5_MOS_OVERALL_SCOPE],[Percentil5_MOS_NB_SCOPE],[Percentil95_CST_MO_AL_SCOPE_QLIK],[Percentil95_CST_MT_AL_SCOPE_QLIK],
		  [Percentil95_CST_MOMT_AL_SCOPE_QLIK],[Percentil95_CST_MO_CO_SCOPE_QLIK],[Percentil95_CST_MT_CO_SCOPE_QLIK],[Percentil95_CST_MOMT_CO_SCOPE_QLIK],
		  [Percentil5_MOS_OVERALL_SCOPE_QLIK],[Percentil5_MOS_NB_SCOPE_QLIK],[Scope_Qlik]

from lcc_ActWeek_Voice_Melisa q 
		        left join _Percentiles p on (q.entity=p.entidad and q.operator = case when mnc=01 then ''Vodafone'' when mnc=03 then ''Orange'' when mnc=07 then ''Movistar'' when mnc=04 then ''Yoigo'' end
											and q.id= Case when p.Report_QLIK=''MUN'' then ''OSP'' else p.Report_QLIK end and q.meas_tech=p.meas_tech and
											q.monthyear = p.monthyear and q.ReportWeek=p.ReportWeek)

where q.monthyear = '''+@monthYear+''' and q.ReportWeek = '''+@ReportWeek+'''


')

----------------

	--insert into [dbo].[_Actualizacion_Qlik]
	--select 'Fin 1.4 Tabla final rellena y Fin del código', getdate()

----------------

select * from QLIK.dbo.lcc_voice_final_qlik_Ceci_backup where scope_rest is null where monthyear = '201704' and reportweek = 'w17'
--select * from _All_voice_melisa
--delete from lcc_voice_final_qlik_Ceci where monthyear = '201703' and reportweek = 'W12'