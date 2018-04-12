USE [FY1617_TEST_CECI]
GO
/****** Object:  StoredProcedure [dbo].[plcc_voice_Qlik]    Script Date: 26/06/2017 18:37:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[plcc_voice_Qlik]

	  @monthYear as nvarchar(50)
	 ,@ReportWeek as nvarchar(50)
	 ,@last_measurement as varchar(256)
	 ,@id as varchar(50)

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
 

 --declare @monthYear as nvarchar(50) = '201704'
 --declare @ReportWeek as nvarchar(50) = 'W17'
 --declare @last_measurement as varchar(256) = 'last_measurement_osp'
 --declare @id as varchar(50)='OSP'


----------------------------------------------- CREACIÓN INICIAL DE LAS TABLAS -------------------------------------------------------

exec sp_lcc_dropifexists '_Actualizacion_Qlik'

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


if (select name from sys.tables where name='_All_Voice') is null
begin
	CREATE TABLE [dbo].[_All_Voice](
	[SCOPE] [varchar](255) NULL,
	[TECHNOLOGY] [varchar](256) NULL,
	[TEST_TYPE] [nvarchar](256) NULL,
	[SCOPE_DASH] [varchar](255) NULL,
	[SCOPE_QLIK] [varchar](255) NULL,
	[ENTITIES_BBDD] [varchar](500) NULL,
	[ENTITIES_DASHBOARD] [varchar](500) NULL,
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
	[URBAN_EXTENSION] [varchar](255) NOT NULL,
	[Population_VDF] [varchar](255) NULL,
	[Population_OSP] [float] NULL,
	[SAMPLED_URBAN] [varchar](255) NOT NULL,
	[NUMBER_TEST_KM] [varchar](255) NOT NULL,
	[ROUTE] [varchar](255) NOT NULL,
	[ALGORITHM] [varchar](255) NULL,
	[LANGUAGE] [varchar](255) NULL,
	[PHONE_MODEL] [varchar](255) NULL,
	[FIRM_VERSION] [varchar](255) NULL,
	[LAST_ACQUISITION] [varchar](255) NULL,
	[Operador] [varchar](255) NULL,
	[MCC] [int] NULL,
	[MNC] [varchar](255) NULL,
	[OPCOS] [varchar](255) NULL,
	[RAN_VENDOR] [nvarchar](255) NULL,
	[SCENARIOS] [varchar](1000) NULL,
	[PROVINCIA] [nvarchar](255) NULL,
	[PROVINCIA_DASH] [nvarchar](255) NULL,
	[CCAA] [varchar](255) NULL,
	[CCAA_DASH] [varchar](255) NULL,
	[Zona_OSP] [nvarchar](255) NULL,
	[Zona_VDF] [nvarchar](255) NULL,
	[ORDEN_DASH] [varchar](255) NULL,
	[report_type] [varchar](255) NULL
	)

END

if (select name from sys.tables where name='lcc_voice_final_qlik') is null
begin
	CREATE TABLE [dbo].[lcc_voice_final_qlik](
	[SCOPE] [varchar](255) NULL,
	[TECHNOLOGY] [varchar](256) NULL,
	[TEST_TYPE] [nvarchar](256) NULL,
	[SCOPE_DASH] [varchar](255) NULL,
	[SCOPE_QLIK] [varchar](255) NULL,
	[ENTITIES_BBDD] [varchar](500) NULL,
	[ENTITIES_DASHBOARD] [varchar](500) NULL,
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
	[URBAN_EXTENSION] [varchar](255) NOT NULL,
	[Population_VDF] [varchar](255) NULL,
	[Population_OSP] [float] NULL,
	[SAMPLED_URBAN] [varchar](255) NOT NULL,
	[NUMBER_TEST_KM] [varchar](255) NOT NULL,
	[ROUTE] [varchar](255) NOT NULL,
	[ALGORITHM] [varchar](255) NULL,
	[LANGUAGE] [varchar](255) NULL,
	[PHONE_MODEL] [varchar](255) NULL,
	[FIRM_VERSION] [varchar](255) NULL,
	[LAST_ACQUISITION] [varchar](255) NULL,
	[Operador] [varchar](255) NULL,
	[MCC] [int] NULL,
	[MNC] [varchar](255) NULL,
	[OPCOS] [varchar](255) NULL,
	[RAN_VENDOR] [nvarchar](255) NULL,
	[SCENARIOS] [varchar](1000) NULL,
	[PROVINCIA] [nvarchar](255) NULL,
	[PROVINCIA_DASH] [nvarchar](255) NULL,
	[CCAA] [varchar](255) NULL,
	[CCAA_DASH] [varchar](255) NULL,
	[Zona_OSP] [nvarchar](255) NULL,
	[Zona_VDF] [nvarchar](255) NULL,
	[ORDEN_DASH] [varchar](255) NULL,
	[report_type] [varchar](255) NULL,
	[Percentil95_CST_MO_AL] [float] NULL,
	[Percentil95_CST_MT_AL] [float] NULL,
	[Percentil95_CST_MOMT_AL] [float] NULL,
	[Percentil95_CST_MO_CO] [float] NULL,
	[Percentil95_CST_MT_CO] [float] NULL,
	[Percentil95_CST_MOMT_CO] [float] NULL,
	[Percentil5_MOS_OVERALL] [float] NULL,
	[Percentil5_MOS_NB] [float] NULL,
	[Percentil5_MOS_WB] [float] NULL,
	[Percentil95_CST_MO_AL_SCOPE] [float] NULL,
	[Percentil95_CST_MT_AL_SCOPE] [float] NULL,
	[Percentil95_CST_MOMT_AL_SCOPE] [float] NULL,
	[Percentil95_CST_MO_CO_SCOPE] [float] NULL,
	[Percentil95_CST_MT_CO_SCOPE] [float] NULL,
	[Percentil95_CST_MOMT_CO_SCOPE] [float] NULL,
	[Percentil5_MOS_OVERALL_SCOPE] [float] NULL,
	[Percentil5_MOS_NB_SCOPE] [float] NULL,
	[Percentil5_MOS_WB_SCOPE] [float] NULL,
	[Percentil95_CST_MO_AL_SCOPE_QLIK] [float] NULL,
	[Percentil95_CST_MT_AL_SCOPE_QLIK] [float] NULL,
	[Percentil95_CST_MOMT_AL_SCOPE_QLIK] [float] NULL,
	[Percentil95_CST_MO_CO_SCOPE_QLIK] [float] NULL,
	[Percentil95_CST_MT_CO_SCOPE_QLIK] [float] NULL,
	[Percentil95_CST_MOMT_CO_SCOPE_QLIK] [float] NULL,
	[Percentil5_MOS_OVERALL_SCOPE_QLIK] [float] NULL,
	[Percentil5_MOS_NB_SCOPE_QLIK] [float] NULL,
	[Percentil5_MOS_WB_SCOPE_QLIK] [float] NULL,
	[Desviacion_NB] [float] NULL,
	[Desviacion_OVERALL] [float] NULL,
	[Desviacion_NB_SCOPE] [float] NULL,
	[Desviacion_OVERALL_SCOPE] [float] NULL,
	[Desviacion_NB_SCOPE_QLIK] [float] NULL,
	[Desviacion_OVERALL_SCOPE_QLIK] [float] NULL,
	[Scope_Qlik] [varchar](255) NULL
) ON [PRIMARY]

END

-------------------------------------------------------------------------------------------------------------------------------------


if (select name from sys.tables where name='lcc_voice_final_qlik') is not null
BEGIN	
	If(Select MonthYear+ReportWeek+id from lcc_voice_final_qlik where MonthYear+ReportWeek+id = @monthYear+@ReportWeek+@id group by MonthYear+ReportWeek+id)<> ''
	BEGIN
	  set @monthYear = '666'
	  set @ReportWeek  = 'W66'
	END
END



----------------

	insert into [dbo].[_Actualizacion_Qlik]
	select '1.1 RI Voz Finalizado', getdate()

----------------

-----------------------------------------------PRIMERA PARTE DEL CÓDIGO-------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------
truncate table [lcc_ActWeek_Voice]

exec('

exec QLIK.dbo.sp_lcc_dropifexists ''_All_voice''
exec QLIK.dbo.sp_lcc_dropifexists ''_base_entities_voice''



-- 1. Nos creamos una tabla base con toda la información llave de cada entidad y todas las entidades vodafone--------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------

insert into _base_entities_voice
Select 	entities.operator,
		entities.meas_Tech,
		l.report_type,
		entities.entity,
		Case when i.Scope like '%EXTRA%' then LEFT(i.Scope,len(i.Scope)-5) else i.Scope end as Scope_Qlik,
		v.Region_OSP as Zona_OSP,
		v.Region_VF as Zona_VDF,
		v.Provincia as Provincia_comp,
		v.CCAA as CCAA_Comp,
		i.population_vf,
		i.population_osp

from 

		(Select entities_vdf.*

		from (

		    --Sacamos una tabla con todas las entidades que tiene vodafone (si una entidad no la tiene vodafone es que no se entrega) y las replicamos para cada uno de los operadores

				Select distinct(entity),report_type,meas_tech,operator
				from [QLIK].dbo._RI_Voice_Completed_Qlik 
				where  '+@last_measurement+' > 0 
					and meas_tech not like ''%cover%''
					) entities_vdf

				--(select operator from [QLIK].dbo._RI_Voice_Completed_Qlik group by operator) op

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
		 l.report_type, 
		 entities.entity,
		 l.meas_tech,
		 Case when i.Scope like ''%EXTRA%'' then LEFT(i.Scope,len(i.Scope)-5) else i.Scope end,
		 v.Region_OSP,
		 v.Region_VF,
		 v.Provincia,
		 v.CCAA,
		 i.population_vf,
		 i.population_osp



-- 2. Nos creamos una tabla con toda la información, tanto para QLIK como para el DASHBOARD-------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------

insert into _All_voice				
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

		sum(q.[MOS_NB_Samples_Under_2.5])+sum(q.[MOS_Samples_Under_2.5]) as MOS_Below2_5_samples,

		--Percentil 5 de MOS_OVERALL

		case when sum(q.VOLTE_SpeechDelay_Den)>0 then sum(q.[VOLTE_SpeechDelay_Num])/(sum(q.[VOLTE_SpeechDelay_Den])) end as VOLTE_AVG_RTT,

		sum(q.[WB AMR Only]) as [WB AMR Only],  
		sum(q.[Avg WB AMR Only]) as [AVERAGE WB AMR Only],

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
		'' as URBAN_EXTENSION,
		
		entities.population_vf as [Population_VDF],
		entities.population_osp as [Population_OSP],

		--Prodedimiento km2 medidos

		'' as SAMPLED_URBAN,
		'' as NUMBER_TEST_KM,
		'' as [ROUTE],
		t.[ALGORITHM] as [ALGORITHM],
		t.[SPEECH_LANGUAGE] as [LANGUAGE],
		t.SMARTPHONE_MODEL as PHONE_MODEL,
		t.FIRMWARE_VERSION as FIRM_VERSION,
		'20' + q.Meas_Date as LAST_ACQUISITION,
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
		entities.report_type
		--Case when @id in ('OSP','MUN') then  else entities_vdf.Zona_VDF as ZONA
		
from _base_entities_voice_melisa entities
		
left join
		  
		  (Select * from [QLIK].dbo._RI_Voice_Completed_Qlik q 
		  where last_measurement_osp >0 
			and q.meas_tech not like '%cover%' 
			and meas_LA=0) q 
		   on (q.entity = entities.entity 
		   and q.operator = entities.operator 
		   and q.report_type = entities.report_type 
		   and q.meas_tech = entities.meas_tech)

left outer join 

	    (select * from [AGRIDS].dbo.[vlcc_dashboard_info_scopes_NEW]) v--@id v 
			on (entities.entity = v.entities_bbdd
			and entities.report_type = v.report) 

left outer join
		
		[AGRIDS].dbo.lcc_dashboard_info_Voice t
			on (t.scope=v.scope
			and t.technology=entities.meas_tech)
group by v.type_scope,
		entities.meas_tech,
		q.calltype,
		v.scope,
		entities.Scope_QLIK,
		entities.entity,
		v.entities_dashboard,
		entities.population_vf,
		entities.population_osp,
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
		v.ORDER_DASHBOARD,
		entities.report_type
order by
		v.scope,
		entities.Scope_QLIK,
		v.type_scope,
		entities.entity

-- AÑADIMOS LOS PERCENTILES Y DESVIACIONES TIPICAS PARA VST Y MOS------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------


----------------

	insert into [dbo].[_Actualizacion_Qlik]
	select ''Fin 1.2 Añadidos Kpis Voz'', getdate()

----------------


exec [QLIK].[dbo].[plcc_voice_statistics] '+@last_measurement+'
exec [QLIK].[dbo].[plcc_voice_statistics_Columns_new] '''+@monthYear+''' ,'''+@ReportWeek+'''



----------------

insert into [dbo].[_Actualizacion_Qlik]
select ''Fin 1.3 Percentiles Ejecutados'', getdate()

----------------


insert into lcc_voice_final_qlik

Select q.*
	  ,[Percentil95_CST_MO_AL]
      ,[Percentil95_CST_MT_AL]
      ,[Percentil95_CST_MOMT_AL]
      ,[Percentil95_CST_MO_CO]
      ,[Percentil95_CST_MT_CO]
      ,[Percentil95_CST_MOMT_CO]
      ,[Percentil5_MOS_OVERALL]
      ,[Percentil5_MOS_NB]
      ,[Percentil5_MOS_WB]
      ,[Percentil95_CST_MO_AL_SCOPE]
      ,[Percentil95_CST_MT_AL_SCOPE]
      ,[Percentil95_CST_MOMT_AL_SCOPE]
      ,[Percentil95_CST_MO_CO_SCOPE]
      ,[Percentil95_CST_MT_CO_SCOPE]
      ,[Percentil95_CST_MOMT_CO_SCOPE]
      ,[Percentil5_MOS_OVERALL_SCOPE]
      ,[Percentil5_MOS_NB_SCOPE]
      ,[Percentil5_MOS_WB_SCOPE]
      ,[Percentil95_CST_MO_AL_SCOPE_QLIK]
      ,[Percentil95_CST_MT_AL_SCOPE_QLIK]
      ,[Percentil95_CST_MOMT_AL_SCOPE_QLIK]
      ,[Percentil95_CST_MO_CO_SCOPE_QLIK]
      ,[Percentil95_CST_MT_CO_SCOPE_QLIK]
      ,[Percentil95_CST_MOMT_CO_SCOPE_QLIK]
      ,[Percentil5_MOS_OVERALL_SCOPE_QLIK]
      ,[Percentil5_MOS_NB_SCOPE_QLIK]
      ,[Percentil5_MOS_WB_SCOPE_QLIK]
      ,[Desviacion_NB]
      ,[Desviacion_OVERALL]
      ,[Desviacion_NB_SCOPE]
      ,[Desviacion_OVERALL_SCOPE]
      ,[Desviacion_NB_SCOPE_QLIK]
      ,[Desviacion_OVERALL_SCOPE_QLIK]
      ,[Scope_Qlik]

from lcc_ActWeek_Voice q 
		        left join _Percentiles p 
		        on (q.entity=p.entidad 
		        	and q.operator = case when mnc=01 then ''Vodafone'' when mnc=03 then ''Orange'' when mnc=07 then ''Movistar'' when mnc=04 then ''Yoigo'' end
					and q.id= Case when p.Report_QLIK=''MUN'' then ''OSP'' else p.Report_QLIK end 
					and q.meas_tech=p.meas_tech 
					and q.monthyear = p.monthyear 
					and q.ReportWeek=p.ReportWeek)
				where q.monthyear = '''+@monthYear+''' and q.ReportWeek = '''+@ReportWeek+'''

				left join _Desviaciones r 
		        on (r.entity=p.entidad 
		        	and r.operator = case when mnc=01 then ''Vodafone'' when mnc=03 then ''Orange'' when mnc=07 then ''Movistar'' when mnc=04 then ''Yoigo'' end
					and r.id= Case when p.Report_QLIK=''MUN'' then ''OSP'' else p.Report_QLIK end 
					and r.meas_tech=p.meas_tech 
					and r.monthyear = p.monthyear 
					and r.ReportWeek=p.ReportWeek)
				where r.monthyear = '''+@monthYear+''' and r.ReportWeek = '''+@ReportWeek+'''

')

----------------

	insert into [dbo].[_Actualizacion_Qlik]
	select 'Fin 1.4 Tabla final rellena y Fin del código', getdate()

----------------

--select * into lcc_voice_final_qlik from lcc_voice_final_qlik_Ceci where monthyear = '201704' and reportweek = 'w17'

--delete from lcc_voice_final_qlik_Ceci where monthyear = '201703' and reportweek = 'W12'