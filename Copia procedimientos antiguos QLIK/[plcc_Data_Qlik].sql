USE [QLIK]
GO
/****** Object:  StoredProcedure [dbo].[plcc_Data_Qlik]    Script Date: 26/06/2017 18:38:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[plcc_Data_Qlik]

	  @monthYear as nvarchar(50)
	 ,@ReportWeek as nvarchar(50)
	 ,@last_measurement as varchar(256)
	 ,@id as varchar(50)
AS
-------------------------------------------------------EXPLICACIÓN-----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------

/* En la primera parte del código se sacan todos los Scopes, las carreteras y los AVEs saldrán con el acumulado de 4 y 3 vueltas respectivamente.
Se obtiene una tabla de entidades Vodafone (ya que si algo se invalida en este operador, directamente esa entidad no se entregaría) y se cruza 
con el resto de operadores para que, si estuviese invalidado en otro operador saliese a NULL.
   En la segunda parte del código se hace un Union ALL con el mismo código pero adaptado para sacar la última vuelta de las carreteras. Esto
se hace para el Scoring y el Q&D. En esta parte del código, si la última vuelta de las carreteras para algún operador estuviese invalidad directamente
nos quedamos con la última vuelta váldia
   Al final del código, y sin nada que ver con lo anterior, tenemos las ejecuciones de procedimientos para que CENTRAL pueda sacar la info
de carreteras por Región*/

-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------




 --declare @monthYear as nvarchar(50) = '201705'        --MES Y AÑO DE ACTUALIZACIÓN
 --declare @ReportWeek as nvarchar(50) = 'W19'          --SEMANA DE ACTUALIZACIÓN
 --declare @UpdateMeasur as bit =1
 --declare @last_measurement as varchar(256) = 'last_measurement_vdf'
 --declare @id as varchar(50)='VDF'

--exec plcc_RI_Data_OSP_Completed_NEW_v2                               --INICIALMENTE SE EJECUTA EL RI DE DATOS


----------------------------------  DEFINIMOS LA TABLA DE DATOS SI AÚN NO EXISTE --------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------

--exec sp_lcc_dropifexists '_Actualizacion_Qlik'

-- TABLA de SEGUIMIENTO de la ejecución del Procedimiento Kpis Qlik:
	
	if (select name from sys.tables where type='u' and name='_Actualizacion_Qlik') is null
	begin
		CREATE TABLE [dbo].[_Actualizacion_Qlik](
			[Status] [varchar](255) NULL,
			[Date] [datetime] NULL
		) ON [primary]

		insert into [dbo].[_Actualizacion_Qlik]
		select '2.Inicio ejecucion Kpis Qlik Datos', getdate()
	end
	

if (select name from sys.tables where name='lcc_ActWeek_Data') is null
begin
	CREATE TABLE [dbo].[lcc_ActWeek_Data](
	[Scope_Rest] [varchar](255) NULL,
	[Operator] [varchar](8) NULL,
	[meas_tech] [varchar](17) NOT NULL,
	[entity] [varchar](256) NULL,
	[final_date] [varchar](3) NULL,
	[id] [varchar](3) NOT NULL,
	[Att_DL_CE] [int] NULL,
	[Failed_Acc_DL_CE] [int] NULL,
	[Failed_Ret_DL_CE] [int] NULL,
	[D1] [float] NULL,
	[D2] [numeric](24, 12) NULL,
	[Num_Thput_3M] [int] NULL,
	[Num_Thput_1M] [int] NULL,
	[SessionTime_DL_CE] [float] NULL,
	[Att_UL_CE] [int] NULL,
	[Failed_Acc_UL_CE] [int] NULL,
	[Failed_Ret_UL_CE] [int] NULL,
	[D3] [float] NULL,
	[SessionTime_UL_CE] [float] NULL,
	[Att_DL_NC] [int] NULL,
	[Failed_Acc_DL_NC] [int] NULL,
	[Failed_Ret_DL_NC] [int] NULL,
	[MEAN DATA USER RATE_DL_NC] [float] NULL,
	[Att_UL_NC] [int] NULL,
	[Failed_Acc_UL_NC] [int] NULL,
	[Failed_Ret_UL_NC] [int] NULL,
	[MEAN DATA USER RATE_UL_NC] [float] NULL,
	[Latency_Att] [int] NULL,
	[LAT_AVG] [float] NULL,
	[LAT_MED] [int] NULL,
	[LAT_D4] [int] NULL,
	[LAT_MEDIAN] [int] NULL,
	[Web_Att] [int] NULL,
	[Web_Failed] [int] NULL,
	[Web_Dropped] [int] NULL,
	[Web_SessionTime_D5] [float] NULL,
	[WEB_IP_ACCESS_TIME] [numeric](38, 6) NULL,
	[WEB_HTTP_TRANSFER_TIME] [numeric](38, 6) NULL,
	[Web_HTTPS_Att] [int] NULL,
	[Web_HTTPS_Failed] [int] NULL,
	[Web_HTTPS_Dropped] [int] NULL,
	[Web_SessionTime_HTTPS_D5] [float] NULL,
	[WEB_IP_ACCESS_TIME_HTTPS] [numeric](38, 6) NULL,
	[WEB_HTTP_TRANSFER_TIME_HTTPS] [numeric](38, 6) NULL,
	[Web_Public_Att] [int] NULL,
	[Web_Public_Failed] [int] NULL,
	[Web_Public_Dropped] [int] NULL,
	[Web_SessionTime_Public_D5] [float] NULL,
	[WEB_IP_ACCESS_TIME_Public] [float] NULL,
	[WEB_HTTP_TRANSFER_TIME_Public] [float] NULL,
	[Att_YTB_SD] [int] NULL,
	[YTB_Failed_SD] [int] NULL,
	[YTB_Dropped_SD] [int] NULL,
	[YTB_B1_SD] [numeric](24, 12) NULL,
	[YTB_B2_SD] [numeric](25, 13) NULL,
	[Att_YTB_HD] [int] NULL,
	[YTB_Failed_HD] [int] NULL,
	[YTB_Dropped_HD] [int] NULL,
	[YTB_B1_HD] [numeric](24, 12) NULL,
	[YTB_AVG_START_TIME] [numeric](38, 6) NULL,
	[YTB_B2_HD] [int] NULL,
	[YTB_B2_HD_%] [numeric](25, 13) NULL,
	[YTB_B3_HD] [int] NULL,
	[YTB_B5_HD] [int] NULL,
	[YTB_B4_HD] [int] NULL,
	[YTB_B6_HD] [float] NULL,
	[Zona_OSP] [nvarchar](5) NULL,
	[Zona_VDF] [nvarchar](7) NULL,
	[Provincia_comp] [nvarchar](255) NULL,
	[Population] [float] NULL,
	[MonthYear] [varchar](6) NOT NULL,
	[ReportWeek] [varchar](3) NOT NULL
)
END


if (select name from sys.tables where name='lcc_Data_final_qlik') is null
begin
	CREATE TABLE [dbo].[lcc_Data_final_qlik](
	[Scope_Rest] [varchar](255) NULL,
	[Operator] [varchar](8) NULL,
	[meas_tech] [varchar](17) NOT NULL,
	[entity] [varchar](256) NULL,
	[final_date] [varchar](3) NULL,
	[id] [varchar](3) NOT NULL,
	[Att_DL_CE] [float] NULL,
	[Failed_Acc_DL_CE] [float] NULL,
	[Failed_Ret_DL_CE] [float] NULL,
	[D1] [float] NULL,
	[D2] [float] NULL,
	[Num_Thput_3M] [float] NULL,
	[Num_Thput_1M] [float] NULL,
	[SessionTime_DL_CE] [float] NULL,
	[Att_UL_CE] [float] NULL,
	[Failed_Acc_UL_CE] [float] NULL,
	[Failed_Ret_UL_CE] [float] NULL,
	[D3] [float] NULL,
	[SessionTime_UL_CE] [float] NULL,
	[Att_DL_NC] [float] NULL,
	[Failed_Acc_DL_NC] [float] NULL,
	[Failed_Ret_DL_NC] [float] NULL,
	[MEAN DATA USER RATE_DL_NC] [float] NULL,
	[Att_UL_NC] [float] NULL,
	[Failed_Acc_UL_NC] [float] NULL,
	[Failed_Ret_UL_NC] [float] NULL,
	[MEAN DATA USER RATE_UL_NC] [float] NULL,
	[Latency_Att] [float] NULL,
	[LAT_AVG] [float] NULL,
	[LAT_MED] [float] NULL,
	[LAT_D4] [float] NULL,
	[LAT_MEDIAN] [float] NULL,
	[Web_Att] [float] NULL,
	[Web_Failed] [float] NULL,
	[Web_Dropped] [float] NULL,
	[Web_SessionTime_D5] [float] NULL,
	[WEB_IP_ACCESS_TIME] [float] NULL,
	[WEB_HTTP_TRANSFER_TIME] [float] NULL,
	[Web_HTTPS_Att] [float] NULL,
	[Web_HTTPS_Failed] [float] NULL,
	[Web_HTTPS_Dropped] [float] NULL,
	[Web_SessionTime_HTTPS_D5] [float] NULL,
	[WEB_IP_ACCESS_TIME_HTTPS] [float] NULL,
	[WEB_HTTP_TRANSFER_TIME_HTTPS] [float] NULL,
	[Web_Public_Att] [float] NULL,
	[Web_Public_Failed] [float] NULL,
	[Web_Public_Dropped] [float] NULL,
	[Web_SessionTime_Public_D5] [float] NULL,
	[WEB_IP_ACCESS_TIME_Public] [float] NULL,
	[WEB_HTTP_TRANSFER_TIME_Public] [float] NULL,
	[Att_YTB_SD] [float] NULL,
	[YTB_Failed_SD] [float] NULL,
	[YTB_Dropped_SD] [float] NULL,
	[YTB_B1_SD] [float] NULL,
	[YTB_B2_SD] [float] NULL,
	[Att_YTB_HD] [float] NULL,
	[YTB_Failed_HD] [float] NULL,
	[YTB_Dropped_HD] [float] NULL,
	[YTB_B1_HD] [float] NULL,
	[YTB_AVG_START_TIME] [float] NULL,
	[YTB_B2_HD] [float] NULL,
	[YTB_B2_HD_%] [float] NULL,
	[YTB_B3_HD] [float] NULL,
	[YTB_B5_HD] [float] NULL,
	[YTB_B4_HD] [float] NULL,
	[YTB_B6_HD] [float] NULL,
	[Zona_OSP] [nvarchar](5) NULL,
	[Zona_VDF] [nvarchar](7) NULL,
	[Provincia_comp] [nvarchar](255) NULL,
	[Population] [float] NULL,
	[MonthYear] [varchar](6) NOT NULL,
	[ReportWeek] [varchar](3) NOT NULL,
	[Percentil10_DL_CE] [float] NULL,
	[Percentil90_DL_CE] [float] NULL,
	[Percentil10_UL_CE] [float] NULL,
	[Percentil90_UL_CE] [float] NULL,
	[Percentil10_DL_NC] [float] NULL,
	[Percentil90_DL_NC] [float] NULL,
	[Percentil10_UL_NC] [float] NULL,
	[Percentil90_UL_NC] [float] NULL,
	[Percentil_PING] [float] NULL,
	[Percentil10_DL_CE_SCOPE] [float] NULL,
	[Percentil90_DL_CE_SCOPE] [float] NULL,
	[Percentil10_UL_CE_SCOPE] [float] NULL,
	[Percentil90_UL_CE_SCOPE] [float] NULL,
	[Percentil10_DL_NC_SCOPE] [float] NULL,
	[Percentil90_DL_NC_SCOPE] [float] NULL,
	[Percentil10_UL_NC_SCOPE] [float] NULL,
	[Percentil90_UL_NC_SCOPE] [float] NULL,
	[Percentil_PING_SCOPE] [float] NULL,
	[Percentil10_DL_CE_SCOPE_QLIK] [float] NULL,
	[Percentil90_DL_CE_SCOPE_QLIK] [float] NULL,
	[Percentil10_UL_CE_SCOPE_QLIK] [float] NULL,
	[Percentil90_UL_CE_SCOPE_QLIK] [float] NULL,
	[Percentil10_DL_NC_SCOPE_QLIK] [float] NULL,
	[Percentil90_DL_NC_SCOPE_QLIK] [float] NULL,
	[Percentil10_UL_NC_SCOPE_QLIK] [float] NULL,
	[Percentil90_UL_NC_SCOPE_QLIK] [float] NULL,
	[Percentil_PING_SCOPE_QLIK] [float] NULL,
	[SCOPE_QLIK] [varchar](255) NULL
) ON [PRIMARY]

END

-- COMPROBAMOS QUE LA FECHA QUE VAMOS A AÑADIR NO EXISTA YA EN NUESTRA TABLA --------------------------------------------



if (select name from sys.tables where name='lcc_Data_final_qlik') is not null
BEGIN
	If(Select MonthYear+ReportWeek+id from lcc_Data_final_qlik where MonthYear+ReportWeek+id = @monthYear+@ReportWeek+@id group by MonthYear+ReportWeek+id)<> ''
	BEGIN
	  set @monthYear = '666'
	  set @ReportWeek  = 'W66'
END
 
END 

----------------

	insert into [dbo].[_Actualizacion_Qlik]
	select '2.1 RI Datos Finalizado', getdate()

----------------



-- HACEMOS LOS CÁLCULOS DEL DASHBOARD ------------------------------------------------------------------------------------

truncate table [lcc_ActWeek_Data]

exec('

exec QLIK.dbo.sp_lcc_dropifexists ''_All''
exec QLIK.dbo.sp_lcc_dropifexists ''_base_entities''


	

-- 1.Nos creamos una tabla con la suma de todos los attemps por operador, para la ponderación en los agregados, tipo carreteras y aves....
----------------------------------------------------------------------------------------------------------------------------------------------


Select entities.operator,entities.meas_Tech,l.report_type,entities.Test_type,
	   entities.entity as Entidad,
	   sum (l.Num_tests) as ''Att_All'',
	   sum (l.Failed) as ''Failed_All'',
	   sum (l.Throughput_Den) as ''Throughput_Den_All'',
	   sum (l.Session_time_Den) as ''SessionTime_Den_ALL'',
	   sum(l.Latency_Den) as ''Latency_All'',
	   sum(l.WEB_HTTP_TRANSFER_TIME_DEN) as ''WEB_HTTP_TRANSFER_TIME_All'',
	   sum(l.[WEB_IP_ACCESS_TIME_DEN]) as ''WEB_IP_ACCESS_TIME_All'',
	   sum(l.[WEB_IP_ACCESS_TIME_HTTPS_DEN]) as ''WEB_IP_ACCESS_TIME_HTTPS_All'',
	   sum(l.[WEB_TRANSFER_TIME_HTTPS_DEN]) as ''WEB_TRANSFER_TIME_HTTPS_All'',
	   sum(l.[WEB_IP_ACCESS_TIME_PUBLIC_DEN]) as ''WEB_IP_ACCESS_TIME_PUBLIC_All'',
	   sum(l.[WEB_TRANSFER_TIME_PUBLIC_DEN]) as ''WEB_TRANSFER_TIME_PUBLIC_All'',
	   sum(l.YTB_video_resolution_den) as ''YTB_video_resolution_All'',				
	   sum(l.YTB_video_mos_den) as ''YTB_video_mos_All'',
	   sum(l.avg_Video_startTime_Den) as ''avg_Video_startTime_Den_ALL'',
	   sum(l.Reproductions_WO_Interruptions_Den) as ''Reproductions_WO_Interruptions_ALL'',
	   sum(l.HD_reproduction_rate_den) AS ''HD_reproduction_rate_All''


into _All


from 

-- Subquery para quedarnos con las entidades VDF y que todos los operadores tengan las mismas entidades.

	(Select entities_vdf.*, op.operator

	from (
		Select distinct(entity),test_type/*,report_type*/,meas_tech
		from _RI_Data_Completed_Qlik 
		where  ' +@last_measurement+ ' <> 0 and operator = ''Vodafone'') entities_vdf,

		(select operator from _RI_Data_Completed_Qlik group by operator) op

	) entities
	
	left outer join (Select * from _RI_Data_Completed_Qlik where '+@last_measurement+' <> 0 and meas_LA=0) l on (entities.entity=l.entity and entities.test_type=l.test_type and entities.operator=l.operator /*and entities.report_type=l.report_type*/ and entities.meas_tech = l.meas_tech) /*and entities.round=l.round*/


group by entities.entity,entities.operator,entities.meas_Tech,l.report_type,entities.Test_type




-- 2. Nos creamos una tabla base con toda la información llave de cada entidad y todas las entidades vodafone --------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------


Select entities.operator,entities.meas_Tech,l.report_type,entities.Test_type,entities.entity,
		i.Scope,v.Region_OSP as Zona_OSP,v.Region_VF as Zona_VDF,v.Provincia as Provincia_comp,i.population


into _base_entities

from 

		(Select entities_vdf.*, op.operator

		from (

		    --Sacamos una tabla con todas las entidades que tiene vodafone (si una entidad no la tiene vodafone es que no se entrega) y las replicamos para cada uno de los operadores

			Select distinct(entity),test_type,meas_tech
			from _RI_Data_Completed_Qlik 
			where  '+@last_measurement+' <> 0 and operator = ''Vodafone'') entities_vdf,

			(select operator from _RI_Data_Completed_Qlik group by operator) op

		) entities
	
left outer join 

		(Select * from _RI_Data_Completed_Qlik where '+@last_measurement+' <> 0 and meas_LA=0) l on (entities.entity=l.entity and entities.test_type=l.test_type and entities.operator=l.operator /*and entities.report_type=l.report_type*/ and entities.meas_tech = l.meas_tech) /*and entities.round=l.round*/



left outer join 

		agrids.dbo.lcc_dashboard_info_scopes_new i on (entities.entity = i.entities_BBDD)


left outer join 
		[AGRIDS_v2].dbo.lcc_ciudades_tipo_Project_V9 v on (entities.entity = v.entity_name)

group by entities.operator,entities.meas_Tech,l.report_type,entities.Test_type, entities.entity,l.meas_tech,
		i.Scope,v.Region_OSP,v.Region_VF,v.Provincia,i.population


-- 3. A nuestra tabla base le vamos uniendo todos los KPIs de los distintos Test_Type y le vamos dando formato Dashboard -----------


insert into lcc_ActWeek_Data

Select 
	Case when q.scope like ''%EXTRA%'' then LEFT(q.scope,len(q.scope)-5) else q.scope end as Scope_Rest,
	upper(q.operator) as Operator,
	q.meas_tech,
	q.entity,
	null as final_date,
	--q.report_type,
	'''+@id+''' as id,
	dl_ce.Att_DL_CE,
	dl_ce.Failed_Acc_DL_CE,
	dl_ce.Failed_Ret_DL_CE,
	dl_ce.D1,
	dl_ce.D2,
	dl_ce.Num_Thput_3M,
	dl_ce.Num_Thput_1M,
	dl_ce.SessionTime_DL_CE,
	ul_ce.Att_UL_CE,
	ul_ce.Failed_Acc_UL_CE,
	ul_ce.Failed_Ret_UL_CE,
	ul_ce.D3,
	ul_ce.SessionTime_UL_CE,
	dl_nc.Att_DL_NC,
	dl_nc.Failed_Acc_DL_NC,
	dl_nc.Failed_Ret_DL_NC,
	dl_nc.[MEAN DATA USER RATE_DL_NC],
	ul_nc.Att_UL_NC,
	ul_nc.Failed_Acc_UL_NC,
	ul_nc.Failed_Ret_UL_NC,
	ul_nc.[MEAN DATA USER RATE_UL_NC],
	lat.Latency_Att,
	lat.LAT_AVG,
	lat.LAT_MED,
	lat.LAT_D4, 
	lat.LAT_MEDIAN,
	web.Web_Att,
	web.Web_Failed,
	web.Web_Dropped,
	web.Web_SessionTime_D5,
	web.WEB_IP_ACCESS_TIME,
	web.WEB_HTTP_TRANSFER_TIME,
	whttps.Web_HTTPS_Att,
	whttps.Web_HTTPS_Failed,
	whttps.Web_HTTPS_Dropped,
	whttps.Web_SessionTime_HTTPS_D5,
	whttps.WEB_IP_ACCESS_TIME_HTTPS,
	whttps.WEB_HTTP_TRANSFER_TIME_HTTPS,
	wpublic.Web_Public_Att,
	wpublic.Web_Public_Failed,
	wpublic.Web_Public_Dropped,
	wpublic.Web_SessionTime_Public_D5,	
	wpublic.WEB_IP_ACCESS_TIME_Public,
	wpublic.WEB_HTTP_TRANSFER_TIME_Public,
	ytbsd.Att_YTB_SD,
	ytbsd.YTB_Failed_SD,
	ytbsd.YTB_Dropped_SD,
	ytbsd.YTB_B1_SD,
	ytbsd.YTB_B2_SD,
	ytbhd.Att_YTB_HD,
	ytbhd.YTB_Failed_HD,
	ytbhd.YTB_Dropped_HD,
	ytbhd.YTB_B1_HD,								--No olvidar restarle a 1 este valor en Qlik!! 
	ytbhd.YTB_AVG_START_TIME,                                            
	ytbhd.YTB_B2_HD,
	ytbhd.[YTB_B2_HD_%],
	ytbhd.YTB_B3_HD,
	ytbhd.YTB_B5_HD,
	ytbhd.YTB_B4_HD,
	ytbhd.YTB_B6_HD,
	q.Zona_OSP,
	q.Zona_VDF,
	q.Provincia_comp,
	q.population as ''Population'',
	'''+@monthYear+''' as MonthYear,
	'''+@ReportWeek+''' as ReportWeek

from _base_entities q

------------------------------------------------KPIs DL CE---------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------

  left join 
       ( Select q.operator,q.meas_tech/*,q.report_type*/,
				q.entity as entity,
				sum(Num_tests) as ''Att_DL_CE'',
				sum(Failed) as ''Failed_Acc_DL_CE'',
				sum(Dropped)as ''Failed_Ret_DL_CE'',
				case when (a.Throughput_Den_All >0) then sum(Throughput_Num)/(a.Throughput_Den_All) end as ''D1'',
				case when a.Throughput_Den_All>0 then 1.0*sum(Throughput_3M_Num)/a.Throughput_Den_All end as ''D2'',
				sum(Throughput_3M_Num) as ''Num_Thput_3M'',
				sum(Throughput_1M_Num) as ''Num_Thput_1M'',
				case when SessionTime_Den_ALL >0 then sum(Session_time_Num)/a.SessionTime_Den_ALL end as ''SessionTime_DL_CE''				
		
			from  _RI_Data_Completed_Qlik q, _All a

			where q.operator = a.operator and q.meas_Tech=a.meas_Tech and q.report_type=a.report_type and q.test_type=a.test_type and
				 q.entity = a.entidad and q.'+@last_measurement+' <> 0  and q.meas_LA=0 and q.Test_type = ''CE_DL'' 
				 
			group by q.operator,q.meas_tech,/*,q.report_type*/a.Att_All,a.Throughput_Den_All,q.entity,a.SessionTime_Den_ALL
						) dl_ce on (q.operator= dl_ce.operator and q.meas_tech=dl_ce.meas_tech and q.entity=dl_ce.entity /*and q.report_type=dl_ce.report_type*/)


------------------------------------------------KPIs UL CE---------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------	
																												 
  left join 
       (Select q.operator,q.meas_tech/*,q.report_type*/,
				q.entity as entity,
				sum(Num_tests) as ''Att_UL_CE'',
				sum(Failed) as ''Failed_Acc_UL_CE'',
				sum(Dropped)as ''Failed_Ret_UL_CE'',
				case when a.Throughput_Den_All>0 then sum(Throughput_Num)/a.Throughput_Den_All end as ''D3'',
				case when a.SessionTime_Den_ALL >0 then sum(Session_time_Num)/(a.SessionTime_Den_ALL) end as ''SessionTime_UL_CE''

				
			from _RI_Data_Completed_Qlik q,_All a

			where q.operator = a.operator and q.meas_Tech=a.meas_Tech and q.report_type=a.report_type and q.Test_type=a.Test_type and
				q.entity = a.entidad and q.'+@last_measurement+' <> 0 and q.meas_tech not like ''%cover%'' and q.meas_LA=0 and q.Test_type = ''CE_UL'' 
			group by q.operator,q.meas_tech,/*q.report_type,*/a.Att_All,a.Throughput_Den_All,q.entity,a.SessionTime_Den_ALL
				 ) ul_ce  on (q.operator= ul_ce.operator and q.meas_tech=ul_ce.meas_tech and q.entity = ul_ce.entity /*and q.report_type=ul_ce.report_type*/)


------------------------------------------------KPIs DL NC---------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------			


	left join 
		(Select q.operator,q.meas_tech/*,q.report_type*/,
				q.entity as entity,
				sum(Num_tests) as ''Att_DL_NC'',
				sum(Failed) as ''Failed_Acc_DL_NC'',
				sum(Dropped)as ''Failed_Ret_DL_NC'',
				case when a.Throughput_Den_All>0 then sum(Throughput_Num)/a.Throughput_Den_All end as ''MEAN DATA USER RATE_DL_NC''

				
			from _RI_Data_Completed_Qlik q, _All a

			where q.operator = a.operator and q.meas_Tech=a.meas_Tech and q.report_type=a.report_type and q.Test_type=a.Test_type and
				q.entity = a.entidad and q.'+@last_measurement+' <> 0 and q.meas_tech not like ''%cover%'' and q.meas_LA=0 and q.Test_type = ''NC_DL'' 
			group by q.operator,q.meas_tech/*,q.report_type*/,a.Throughput_Den_All,q.entity
				 ) dl_nc on (q.operator= dl_nc.operator and q.meas_tech=dl_nc.meas_tech and q.entity =dl_nc.entity /*and q.report_type=dl_nc.report_type*/)


------------------------------------------------KPIs UL NC---------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------	
	left join 

		(Select q.operator,q.meas_tech/*,q.report_type*/,
				q.entity as entity,
				sum(Num_tests) as ''Att_UL_NC'',
				sum(Failed) as ''Failed_Acc_UL_NC'',
				sum(Dropped)as ''Failed_Ret_UL_NC'',
				case when a.Throughput_Den_All>0 then sum(Throughput_Num)/a.Throughput_Den_All end as ''MEAN DATA USER RATE_UL_NC''

				
			from _RI_Data_Completed_Qlik q, _All a

			where q.operator = a.operator and q.meas_Tech=a.meas_Tech and q.report_type=a.report_type and q.Test_type=a.Test_type and
				q.entity = a.entidad and q.'+@last_measurement+' <> 0 and q.meas_LA=0 and q.Test_type = ''NC_UL'' 
			group by q.operator,q.meas_tech,a.Throughput_Den_All,q.entity/*,q.report_type*/
				 ) ul_nc on (q.operator= ul_nc.operator and q.meas_tech=ul_nc.meas_tech and q.entity=ul_nc.entity /*and q.report_type=ul_nc.report_type*/)


------------------------------------------------KPIs LATENCIA---------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------	
	left join 

		(Select q.operator,q.meas_tech/*,q.report_type*/,
				q.entity as entity,
				sum(Latency_Den) as ''Latency_att'',
				case when a.Latency_All> 0  then floor(1.0*Sum(Latency_Num)/a.Latency_All) end as ''LAT_AVG'',
				0 as ''LAT_MED'',
				0 as ''LAT_D4'', 
				0 as ''LAT_MEDIAN''
					
		 from _RI_Data_Completed_Qlik q, _All a

	     where q.operator = a.operator and q.meas_Tech=a.meas_Tech and q.report_type=a.report_type and q.Test_type=a.Test_type and
				  q.entity = a.entidad  and
				  (q.Methodology =''D16'' or (q.Methodology=''D15'' and q.scope not in (''MAIN CITIES'',''SMALLER CITIES'') AND q.meas_tech =''4G'')
				   or (q.Methodology=''D15''and q.meas_tech <>''4G''))
				  and q.'+@last_measurement+' <> 0 and q.meas_tech not like ''%cover%'' and q.meas_LA=0 and q.Test_type = ''Ping'' 
		 group by q.operator,q.meas_tech,q.entity,a.Latency_All/*,q.report_type*/,SCOPE
				) lat on (q.operator= lat.operator and q.meas_tech=lat.meas_tech and q.entity=lat.entity /*and q.report_type=lat.report_type*/)

----------------------------------------------------WEB---------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------	
	left join 

		(Select q.operator,q.meas_tech/*,q.report_type*/,
				q.entity as entity,
				sum(Num_tests) as ''Web_Att'',
				sum(Failed) as ''Web_Failed'',
				sum(Dropped)as ''Web_Dropped'',
				case when a.SessionTime_Den_ALL >0 then sum(Session_time_Num)/a.SessionTime_Den_ALL end as ''Web_SessionTime_D5'',
				case when a.WEB_IP_ACCESS_TIME_All >0 then sum(WEB_IP_ACCESS_TIME_NUM)/a.WEB_IP_ACCESS_TIME_All end as ''WEB_IP_ACCESS_TIME'',
				case when a.WEB_HTTP_TRANSFER_TIME_All>0 then sum(WEB_HTTP_TRANSFER_TIME_NUM)/a.WEB_HTTP_TRANSFER_TIME_All end as ''WEB_HTTP_TRANSFER_TIME''
	
			from _RI_Data_Completed_Qlik q, _All a

			where q.operator = a.operator and q.meas_Tech=a.meas_Tech and q.report_type=a.report_type and q.Test_type=a.Test_type and
				  q.entity = a.entidad  
				  and q.'+@last_measurement+' <> 0 and q.meas_LA=0 and q.Test_type = ''WEB HTTP'' 
			group by q.operator,q.meas_tech,a.SessionTime_Den_ALL,a.WEB_IP_ACCESS_TIME_All,a.WEB_HTTP_TRANSFER_TIME_All,q.entity/*,q.report_type*/
				 ) web on (q.operator= web.operator and q.meas_tech=web.meas_tech and q.entity=web.entity /*and q.report_type=web.report_type*/)


----------------------------------------------------WEB HTTPS---------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------	
	left join 

		(Select q.operator,q.meas_tech/*,q.report_type*/,
				q.entity as entity,
				sum(Num_tests) as ''Web_HTTPS_Att'',
				sum(Failed) as ''Web_HTTPS_Failed'',
				sum(Dropped)as ''Web_HTTPS_Dropped'',
				case when a.SessionTime_Den_ALL >0 then sum(Session_time_Num)/a.SessionTime_Den_ALL end as ''Web_SessionTime_HTTPS_D5'',
				case when a.WEB_IP_ACCESS_TIME_HTTPS_All>0 then 1.00*sum([WEB_IP_ACCESS_TIME_HTTPS_NUM])/WEB_IP_ACCESS_TIME_HTTPS_All end as ''WEB_IP_ACCESS_TIME_HTTPS'',
				case when WEB_TRANSFER_TIME_HTTPS_All>0 then sum([WEB_TRANSFER_TIME_HTTPS_NUM])/WEB_TRANSFER_TIME_HTTPS_All end as ''WEB_HTTP_TRANSFER_TIME_HTTPS''
				
			from 
				 _RI_Data_Completed_Qlik q, _All a

			where q.operator = a.operator and q.meas_Tech=a.meas_Tech and q.report_type=a.report_type and q.Test_type=a.Test_type and
				q.entity = a.entidad and q.'+@last_measurement+' <> 0 and q.meas_LA=0 and q.Test_type = ''WEB HTTPS'' 
			group by q.operator,q.meas_tech,SessionTime_Den_ALL,WEB_IP_ACCESS_TIME_HTTPS_All,WEB_TRANSFER_TIME_HTTPS_All, q.entity/*,q.report_type*/
				) whttps on (q.operator= whttps.operator and q.meas_tech=whttps.meas_tech and q.entity=whttps.entity /*and q.report_type=whttps.report_type*/)

----------------------------------------------------WEB Public---------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------	
	left join 

		(Select q.operator,q.meas_tech/*,q.report_type*/,
				q.entity as entity,
				sum(Num_tests) as ''Web_Public_Att'',
				sum(Failed) as ''Web_Public_Failed'',
				sum(Dropped)as ''Web_Public_Dropped'',
				case when a.SessionTime_Den_ALL >0 then sum(Session_time_Num)/a.SessionTime_Den_ALL end as ''Web_SessionTime_Public_D5'',
				case when a.WEB_IP_ACCESS_TIME_PUBLIC_ALL >0 then sum(WEB_IP_ACCESS_TIME_PUBLIC_NUM)/a.WEB_IP_ACCESS_TIME_PUBLIC_ALL end as ''WEB_IP_ACCESS_TIME_Public'',
				case when a.WEB_TRANSFER_TIME_PUBLIC_All>0 then sum(WEB_TRANSFER_TIME_PUBLIC_NUM)/ a.WEB_TRANSFER_TIME_PUBLIC_All end as ''WEB_HTTP_TRANSFER_TIME_Public''
				
			from 
				 _RI_Data_Completed_Qlik q, _All a

			where q.operator = a.operator and q.meas_Tech=a.meas_Tech and q.report_type=a.report_type and q.Test_type=a.Test_type and
				q.entity = a.entidad and q.'+@last_measurement+' <> 0 and q.meas_LA=0 and q.Test_type = ''WEB PUBLIC'' 
			group by q.operator,q.meas_tech,SessionTime_Den_ALL,WEB_IP_ACCESS_TIME_PUBLIC_ALL,WEB_TRANSFER_TIME_PUBLIC_All, q.entity/*,q.report_type*/
				) wpublic on (q.operator= wpublic.operator and q.meas_tech=wpublic.meas_tech and q.entity=wpublic.entity /*and q.report_type=wpublic.report_type*/)




----------------------------------------------------YOUTUBE SD---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------	

	left join 

			(Select q.operator,q.meas_tech/*,q.report_type*/,
					q.entity as entity,
					sum(Num_tests) as ''Att_YTB_SD'',
					sum(Failed) as ''YTB_Failed_SD'',
					sum(Dropped)as ''YTB_Dropped_SD'',
					case when a.Att_All>0 then 1.0*sum(Failed)/a.Att_All end as ''YTB_B1_SD'',
					case when a.Reproductions_WO_Interruptions_ALL>0 then 1.00*sum(Reproductions_WO_Interruptions)/a.Reproductions_WO_Interruptions_ALL end as ''YTB_B2_SD''
				
				from  _RI_Data_Completed_Qlik q, _All a

				where q.operator = a.operator and q.meas_Tech=a.meas_Tech and q.report_type=a.report_type and q.Test_type=a.Test_type and
				q.entity = a.entidad and q.'+@last_measurement+' <> 0 and q.meas_LA=0 and q.Test_type = ''Youtube SD'' 
				    
				group by q.operator,q.meas_tech,a.Failed_All,a.Att_All,a.Reproductions_WO_Interruptions_ALL,q.entity/*,q.report_type*/
					 ) ytbsd on (q.operator= ytbsd.operator and q.meas_tech=ytbsd.meas_tech and q.entity=ytbsd.entity /*and q.report_type=ytbsd.report_type*/)

----------------------------------------------------YOUTUBE HD---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------


	left join 

		(Select q.operator,q.meas_tech/*,q.report_type*/,
				q.entity as entity,
				sum(Num_tests) as ''Att_YTB_HD'',
				sum(Failed) as ''YTB_Failed_HD'',
				sum(Dropped)as ''YTB_Dropped_HD'',
				case when a.Att_All >0 then 1.0*sum(Failed)/a.Att_All end as ''YTB_B1_HD'',             
				sum(Reproductions_WO_Interruptions) as ''YTB_B2_HD'',
				case when a.Reproductions_WO_Interruptions_ALL>0 then 1.00*sum(Reproductions_WO_Interruptions)/a.Reproductions_WO_Interruptions_ALL end as ''YTB_B2_HD_%'',
				sum(Success_Video_P3_num) as ''YTB_B3_HD'',
				case when a.avg_Video_startTime_Den_ALL>0 then sum(Avg_Video_StarTime_Num)/a.avg_Video_startTime_Den_ALL end as ''YTB_AVG_START_TIME'',
				case when a.YTB_video_resolution_All>0 then SUM(YTB_video_resolution_num)/a.YTB_video_resolution_All end as ''YTB_B5_HD'',
				SUM(HD_reproduction_rate_num) as ''YTB_B4_HD'',
				case when a.YTB_video_mos_All>0 then sum(YTB_video_mos_num)/a.YTB_video_mos_All end as ''YTB_B6_HD''

				 
			from _RI_Data_Completed_Qlik q,_All a

			where q.operator = a.operator and q.meas_Tech=a.meas_Tech and q.report_type=a.report_type and q.Test_type=a.Test_type and
				q.entity = a.entidad and q.'+@last_measurement+' <> 0 and q.meas_LA=0 and q.Test_type = ''Youtube HD'' 

			group by q.operator,q.meas_tech,a.Failed_All,a.Att_All,Reproductions_WO_Interruptions_ALL,a.YTB_video_resolution_All,HD_reproduction_rate_ALL,a.YTB_video_mos_All,
				     q.entity/*,q.report_type*/,avg_Video_startTime_Den_ALL
					) ytbhd on (q.operator= ytbhd.operator and q.meas_tech=ytbhd.meas_tech and q.entity=ytbhd.entity /*and q.report_type=ytbhd.report_type*/)

------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------


group by Case when q.scope like ''%EXTRA%'' then LEFT(q.scope,len(q.scope)-5) else q.scope end,q.operator,q.meas_tech,q.entity/*, q.report_type*/,q.Zona_OSP,q.Zona_VDF,q.Provincia_comp,q.population,
         dl_ce.Att_DL_CE,dl_ce.Failed_Acc_DL_CE,dl_ce.Failed_Ret_DL_CE,dl_ce.D1,dl_ce.D2,dl_ce.Num_Thput_3M,dl_ce.Num_Thput_1M,ul_ce.Att_UL_CE,
		 ul_ce.Failed_Acc_UL_CE,ul_ce.Failed_Ret_UL_CE,ul_ce.D3,dl_ce.SessionTime_DL_CE,ul_ce.SessionTime_UL_CE,dl_nc.Att_DL_NC,dl_nc.Failed_Acc_DL_NC,
		 dl_nc.Failed_Ret_DL_NC,dl_nc.[MEAN DATA USER RATE_DL_NC],ul_nc.Att_UL_NC,ul_nc.Failed_Acc_UL_NC,ul_nc.Failed_Ret_UL_NC,ul_nc.[MEAN DATA USER RATE_UL_NC]
		,ytbhd.Att_YTB_HD,ytbhd.YTB_Failed_HD,ytbhd.YTB_Dropped_HD,YTB_B1_HD,ytbhd.YTB_AVG_START_TIME,ytbhd.YTB_B2_HD,ytbhd.[YTB_B2_HD_%],ytbhd.YTB_B3_HD,ytbhd.YTB_B5_HD,ytbhd.YTB_B4_HD,
		 ytbhd.YTB_B6_HD,whttps.Web_HTTPS_Att,whttps.Web_HTTPS_Failed,whttps.Web_HTTPS_Dropped,whttps.Web_SessionTime_HTTPS_D5,web.Web_Att,
		 web.Web_Failed,web.Web_Dropped,web.Web_SessionTime_D5,wpublic.Web_Public_Att,wpublic.Web_Public_Failed,wpublic.Web_Public_Dropped,wpublic.Web_SessionTime_Public_D5,
		 wpublic.WEB_IP_ACCESS_TIME_Public,wpublic.WEB_HTTP_TRANSFER_TIME_Public,ytbsd.Att_YTB_SD,ytbsd.YTB_Failed_SD,ytbsd.YTB_Dropped_SD,ytbsd.YTB_B1_SD,ytbsd.YTB_B2_SD
		,lat.Latency_Att,lat.LAT_AVG,lat.LAT_D4,lat.LAT_MEDIAN,web.WEB_IP_ACCESS_TIME,web.WEB_HTTP_TRANSFER_TIME,whttps.WEB_IP_ACCESS_TIME_HTTPS,whttps.WEB_HTTP_TRANSFER_TIME_HTTPS
		,lat.LAT_MED



UNION ALL


-- 4. Hacemos lo mismo pero sólo para la última vuelta de cada carretera ----------------------------------------------------------------


Select 
	Case when q.scope like ''%EXTRA%'' then LEFT(q.scope,len(q.scope)-5) else q.scope end as Scope_Rest,
	upper(q.Operator) as Operator,
	q.meas_tech+''_1'' as meas_tech,
	q.entity as entity,
	dl_ce.final_date,
	--q.report_type,
	'''+@id+''' as id,
	dl_ce.Att_DL_CE,
	dl_ce.Failed_Acc_DL_CE,
	dl_ce.Failed_Ret_DL_CE,
	dl_ce.D1,
	dl_ce.D2,
	dl_ce.Num_Thput_3M,
	dl_ce.Num_Thput_1M,
	dl_ce.SessionTime_DL_CE,
	ul_ce.Att_UL_CE,
	ul_ce.Failed_Acc_UL_CE,
	ul_ce.Failed_Ret_UL_CE,
	ul_ce.D3,
	ul_ce.SessionTime_UL_CE,
	dl_nc.Att_DL_NC,
	dl_nc.Failed_Acc_DL_NC,
	dl_nc.Failed_Ret_DL_NC,
	dl_nc.[MEAN DATA USER RATE_DL_NC],
	ul_nc.Att_UL_NC,
	ul_nc.Failed_Acc_UL_NC,
	ul_nc.Failed_Ret_UL_NC,
	ul_nc.[MEAN DATA USER RATE_UL_NC],
	lat.Latency_Att,
	lat.LAT_AVG,
	lat.LAT_MED,
	lat.LAT_D4, 
	lat.LAT_MEDIAN,
	web.Web_Att,
	web.Web_Failed,
	web.Web_Dropped,
	web.Web_SessionTime_D5,
	web.WEB_IP_ACCESS_TIME,
	web.WEB_HTTP_TRANSFER_TIME,
	whttps.Web_HTTPS_Att,
	whttps.Web_HTTPS_Failed,
	whttps.Web_HTTPS_Dropped,
	whttps.Web_SessionTime_HTTPS_D5,
	whttps.WEB_IP_ACCESS_TIME_HTTPS,
	whttps.WEB_HTTP_TRANSFER_TIME_HTTPS,
	wpublic.Web_Public_Att,
	wpublic.Web_Public_Failed,
	wpublic.Web_Public_Dropped,
	wpublic.Web_SessionTime_Public_D5,
	wpublic.WEB_IP_ACCESS_TIME_Public,
	wpublic.WEB_HTTP_TRANSFER_TIME_Public,
	ytbsd.Att_YTB_SD,
	ytbsd.YTB_Failed_SD,
	ytbsd.YTB_Dropped_SD,
	ytbsd.YTB_B1_SD,
	ytbsd.YTB_B2_SD,
	ytbhd.Att_YTB_HD,
	ytbhd.YTB_Failed_HD,
	ytbhd.YTB_Dropped_HD,
	ytbhd.YTB_B1_HD,									--No olvidar restarle a 1 este valor en Qlik!!  
	ytbhd.YTB_AVG_START_TIME,                                    
	--ytbhd.YTB_HD_REPR_NO_COMPRESSION,          
	ytbhd.YTB_B2_HD,
	ytbhd.[YTB_B2_HD_%],
	ytbhd.YTB_B3_HD,
	ytbhd.YTB_B5_HD,
	ytbhd.YTB_B4_HD,
	ytbhd.YTB_B6_HD,
	q.Zona_OSP,
	q.Zona_VDF,
	q.Provincia_comp,
	--Case when q.scope in (''SMALLER CITIES'',''MAIN CITIES'',''TOURISTIC AREA'',''MAIN HIGHWAYS'',''ADD-ON CITIES'',''ADD-ON CITIES EXTRA'') then ''M2M'' else ''M2F'' end as Type_Voice,
	q.population as ''Population'',
	'''+@monthYear+''' as MonthYear,
	'''+@ReportWeek+''' as ReportWeek


from _base_entities q

------------------------------------------------KPIs DL CE---------------------------------------------------------------------------------
 -------------------------------------------------------------------------------------------------------------------------------------------

  left join 
       ( Select q.operator,q.meas_tech,
				max(meas_week) as final_date,
				q.entity as entity,
				sum(Num_tests) as ''Att_DL_CE'',
				sum(Failed) as ''Failed_Acc_DL_CE'',
				sum(Dropped)as ''Failed_Ret_DL_CE'',
				case when sum(Throughput_Den) >0  then sum(Throughput_Num)/sum(Throughput_Den) end as ''D1'',
				case when sum(Throughput_Den)>0 then 1.0*sum(Throughput_3M_Num)/sum(Throughput_Den) end as ''D2'',
				sum(Throughput_3M_Num) as ''Num_Thput_3M'',
				sum(Throughput_1M_Num) as ''Num_Thput_1M'',
				case when sum(Num_tests) >0 then sum(Session_time_Num)/sum(Num_tests) end as ''SessionTime_DL_CE''

			
			from  _RI_Data_Completed_Qlik q 
				 
			where q.meas_tech like ''%Road 4G%''and q.'+@last_measurement+' =1 and q.meas_LA=0 and q.Test_type = ''CE_DL'' 
				
			group by q.operator,q.report_type,q.entity,q.meas_tech
				) dl_ce on (q.operator= dl_ce.operator and q.entity=dl_ce.entity /*and q.report_type=dl_ce.report_type*/ and q.meas_tech = dl_ce.meas_tech)

------------------------------------------------KPIs UL CE---------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------																																			
																																				
																												 
  left join 
       (Select q.operator,q.meas_tech,
				--q.report_type,
				q.entity as entity,
				sum(Num_tests) as ''Att_UL_CE'',
				sum(Failed) as ''Failed_Acc_UL_CE'',
				sum(Dropped)as ''Failed_Ret_UL_CE'',
				case when sum(Throughput_Den)>0 then sum(Throughput_Num)/sum(Throughput_Den) end as ''D3'',
				case when sum(Session_time_Num) >0 then sum(Session_time_Num)/sum(Num_tests) end as ''SessionTime_UL_CE''

				
			from _RI_Data_Completed_Qlik q 

			where q.meas_tech like ''%Road 4G%'' and q.'+@last_measurement+' =1 and q.meas_LA=0 and q.Test_type = ''CE_UL'' 
		    
			group by q.operator/*,q.report_type*/,q.entity,q.meas_tech
				) ul_ce on (q.operator= ul_ce.operator and q.entity = ul_ce.entity /*and q.report_type=ul_ce.report_type*/ and q.meas_tech = ul_ce.meas_tech)

------------------------------------------------KPIs DL NC---------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------	


	left join 
		(Select q.operator,q.meas_tech,
				--q.report_type,
				q.entity as entity,
				sum(Num_tests) as ''Att_DL_NC'',
				sum(Failed) as ''Failed_Acc_DL_NC'',
				sum(Dropped)as ''Failed_Ret_DL_NC'',
				case when sum(Throughput_Den)>0 then sum(Throughput_Num)/NULLIF(sum(Throughput_Den),0) end as ''MEAN DATA USER RATE_DL_NC''

			
			from _RI_Data_Completed_Qlik q 

			where  q.meas_tech like ''%Road 4G%'' and q.'+@last_measurement+' =1 and q.meas_LA=0 and q.Test_type = ''NC_DL'' 
			
			group by q.operator/*q.report_type*/,q.entity,q.meas_tech
				 ) dl_nc on (q.operator= dl_nc.operator and q.entity =dl_nc.entity /*and q.report_type=dl_nc.report_type*/ and q.meas_tech = dl_nc.meas_tech)


------------------------------------------------KPIs UL NC---------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------	

	left join 

		(Select q.operator,q.meas_tech,
				--q.report_type,
				q.entity as entity,
				sum(Num_tests) as ''Att_UL_NC'',
				sum(Failed) as ''Failed_Acc_UL_NC'',
				sum(Dropped)as ''Failed_Ret_UL_NC'',
				case when sum(Throughput_Den)>0 then sum(Throughput_Num)/sum(Throughput_Den) end as ''MEAN DATA USER RATE_UL_NC''

				
			from _RI_Data_Completed_Qlik q 

			where q.meas_tech like ''%Road 4G%'' and q.'+@last_measurement+' =1 and q.meas_LA=0 and q.Test_type = ''NC_UL'' 
			
			group by q.operator,q.entity/*, q.report_type*/,q.meas_tech
				) ul_nc on (q.operator= ul_nc.operator and q.entity=ul_nc.entity /*and q.report_type=ul_nc.report_type*/ and q.meas_tech = ul_nc.meas_tech)


------------------------------------------------KPIs LATENCIA---------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------	

left join 

		(Select q.operator,q.meas_tech,
				--q.report_type,
				q.entity as entity,
				sum(Latency_Den) as ''Latency_att'',
				case when sum(Latency_Den)> 0  then floor(1.0*Sum(Latency_Num)/sum(Latency_Den)) end as ''LAT_AVG'',
				0 as ''LAT_MED'',
				0 as ''LAT_D4'', 
				0 as ''LAT_MEDIAN''
						
		  from _RI_Data_Completed_Qlik q 
 
	      where q.meas_tech like ''%Road 4G%'' and q.'+@last_measurement+' =1 and q.meas_LA=0 and q.Test_type = ''Ping'' 
		
		  group by q.operator,q.entity/*,q.report_type*/,q.meas_tech
				) lat on (q.operator= lat.operator and q.entity=lat.entity /*and q.report_type=lat.report_type*/ and q.meas_tech = lat.meas_tech)


----------------------------------------------------WEB---------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------	
	left join 

		(Select q.operator,q.meas_tech,
				--q.report_type,
				q.entity as entity,
				sum(Num_tests) as ''Web_Att'',
				sum(Failed) as ''Web_Failed'',
				sum(Dropped)as ''Web_Dropped'',
				case when sum(Session_time_Den) >0 then sum(Session_time_Num)/sum(Session_time_Den) end as ''Web_SessionTime_D5'',
				case when sum(WEB_IP_ACCESS_TIME_DEN) >0 then sum(WEB_IP_ACCESS_TIME_NUM)/sum(WEB_IP_ACCESS_TIME_DEN) end as ''WEB_IP_ACCESS_TIME'',
				case when sum(WEB_HTTP_TRANSFER_TIME_NUM)>0 then sum(WEB_HTTP_TRANSFER_TIME_NUM)/sum(WEB_HTTP_TRANSFER_TIME_DEN) end as ''WEB_HTTP_TRANSFER_TIME''

				
			from  _RI_Data_Completed_Qlik q

			where q.meas_tech like ''%Road 4G%'' and q.'+@last_measurement+' =1 and q.meas_LA=0 and q.Test_type = ''WEB HTTP'' 
			
			group by q.operator,q.entity/*,q.report_type*/,q.meas_tech
				) web on (q.operator= web.operator and q.entity=web.entity /*and q.report_type=web.report_type*/ and q.meas_tech = web.meas_tech)


----------------------------------------------------WEB HTTPS---------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------	
	left join 

		(Select q.operator,q.meas_tech,
				--q.report_type,
				q.entity as entity,
				sum(Num_tests) as ''Web_HTTPS_Att'',
				sum(Failed) as ''Web_HTTPS_Failed'',
				sum(Dropped)as ''Web_HTTPS_Dropped'',
				case when sum(Session_time_Num) >0 then sum(Session_time_Num)/sum(Session_time_Den) end as ''Web_SessionTime_HTTPS_D5'',
				case when sum([WEB_IP_ACCESS_TIME_HTTPS_NUM])>0 then sum([WEB_IP_ACCESS_TIME_HTTPS_NUM])/sum([WEB_IP_ACCESS_TIME_HTTPS_DEN]) end as ''WEB_IP_ACCESS_TIME_HTTPS'',
				case when sum([WEB_TRANSFER_TIME_HTTPS_NUM])>0 then sum([WEB_TRANSFER_TIME_HTTPS_NUM])/sum([WEB_TRANSFER_TIME_HTTPS_DEN]) end as ''WEB_HTTP_TRANSFER_TIME_HTTPS''

			
				
			from _RI_Data_Completed_Qlik q 

			where q.meas_tech like ''%Road 4G%'' and q.'+@last_measurement+' =1 and q.meas_LA=0 and q.Test_type = ''WEB HTTPS'' 
			group by q.operator,q.entity/*,q.report_type*/,q.meas_tech
				) whttps on (q.operator= whttps.operator and q.entity=whttps.entity /*and q.report_type=whttps.report_type*/ and q.meas_tech = whttps.meas_tech)

----------------------------------------------------WEB Public---------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------	
	left join 

		(Select q.operator,q.meas_tech/*,q.report_type*/,
				q.entity as entity,
				sum(Num_tests) as ''Web_Public_Att'',
				sum(Failed) as ''Web_Public_Failed'',
				sum(Dropped)as ''Web_Public_Dropped'',
				case when sum(Session_time_Den) >0 then sum(Session_time_Num)/sum(Session_time_Den) end as ''Web_SessionTime_Public_D5'',
				case when sum(WEB_IP_ACCESS_TIME_PUBLIC_DEN) >0 then sum(WEB_IP_ACCESS_TIME_PUBLIC_NUM)/sum(WEB_IP_ACCESS_TIME_PUBLIC_DEN) end as ''WEB_IP_ACCESS_TIME_Public'',
				case when sum(WEB_TRANSFER_TIME_PUBLIC_DEN)>0 then sum(WEB_TRANSFER_TIME_PUBLIC_NUM)/sum(WEB_TRANSFER_TIME_PUBLIC_DEN) end as ''WEB_HTTP_TRANSFER_TIME_Public''


				
			from 
				 _RI_Data_Completed_Qlik q

			where q.meas_tech like ''%Road 4G%'' and q.'+@last_measurement+' =1 and q.meas_LA=0 and q.Test_type = ''WEB PUBLIC'' 
			group by q.operator,q.meas_tech, q.entity/*,q.report_type*/
				) wpublic on (q.operator= wpublic.operator and q.meas_tech=wpublic.meas_tech and q.entity=wpublic.entity /*and q.report_type=wpublic.report_type*/)




----------------------------------------------------YOUTUBE SD---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------	

	left join 

			(Select q.operator,q.meas_tech,
					--q.report_type,
					q.entity as entity,
					sum(Num_tests) as ''Att_YTB_SD'',
					sum(Failed) as ''YTB_Failed_SD'',
					sum(Dropped)as ''YTB_Dropped_SD'',
					case when sum(Num_tests)>0 then 1.0*sum(Failed)/sum(Num_tests) end as ''YTB_B1_SD'',
					case when sum(Reproductions_WO_Interruptions)>0 then 1.00*sum(Reproductions_WO_Interruptions)/sum(Reproductions_WO_Interruptions_den) end as ''YTB_B2_SD''
	
				from  _RI_Data_Completed_Qlik q 

				where q.meas_tech like ''%Road 4G%'' and q.'+@last_measurement+' =1 and q.meas_LA=0 and q.Test_type = ''Youtube SD'' 
				    
				group by q.operator,q.entity/*,q.report_type*/,q.meas_tech
					) ytbsd on (q.operator= ytbsd.operator and q.entity=ytbsd.entity /*and q.report_type=ytbsd.report_type*/ and q.meas_tech = ytbsd.meas_tech)


----------------------------------------------------YOUTUBE HD---------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------


	left join 

		(Select q.operator,q.meas_tech,
				--q.report_type,
				q.entity as entity,
				sum(Num_tests) as ''Att_YTB_HD'',
				sum(Failed) as ''YTB_Failed_HD'',
				sum(Dropped)as ''YTB_Dropped_HD'',
				case when sum(Num_tests) >0 then 1.0*sum(Failed)/sum(Num_tests) end as ''YTB_B1_HD'',             
				sum(Reproductions_WO_Interruptions) as ''YTB_B2_HD'',
				case when sum(Reproductions_WO_Interruptions_den)>0 then 1.00*sum(Reproductions_WO_Interruptions)/sum(Reproductions_WO_Interruptions_den) end as ''YTB_B2_HD_%'',
				sum(Success_Video_P3_num) as ''YTB_B3_HD'',
				case when sum(avg_Video_startTime_Den)>0 then sum(Avg_Video_StarTime_Num)/sum(avg_Video_startTime_Den) end as ''YTB_AVG_START_TIME'',
				--sum([ReproduccionesHD]) as ''YTB_HD_REPR_NO_COMPRESSION'',
				case when sum(YTB_video_resolution_den)>0 then SUM(YTB_video_resolution_num)/sum(YTB_video_resolution_den) end as ''YTB_B5_HD'',
				SUM(HD_reproduction_rate_num) as ''YTB_B4_HD'',
				case when sum(YTB_video_mos_den)>0 then sum(YTB_video_mos_num)/sum(YTB_video_mos_den) end as ''YTB_B6_HD''
				
			from  _RI_Data_Completed_Qlik q 

			where q.meas_tech like ''%Road 4G%'' and q.'+@last_measurement+' =1 and q.meas_LA=0 and q.Test_type = ''Youtube HD'' 

			group by  q.operator,q.entity/*,q.report_type*/,q.meas_tech
				 ) ytbhd on (q.operator= ytbhd.operator and q.entity=ytbhd.entity /*and q.report_type=ytbhd.report_type*/ and q.meas_tech = ytbhd.meas_tech)


------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------

where q.meas_tech like ''%Road 4G%''


group by Case when q.scope like ''%EXTRA%'' then LEFT(q.scope,len(q.scope)-5) else q.scope end,q.operator, q.entity,
		 /*q.report_type,*/q.Zona_OSP,q.Zona_VDF,q.Provincia_comp,q.population,q.meas_tech,
         dl_ce.Att_DL_CE,dl_ce.Failed_Acc_DL_CE,dl_ce.Failed_Ret_DL_CE,dl_ce.D1,dl_ce.D2,dl_ce.Num_Thput_3M,dl_ce.Num_Thput_1M,ul_ce.Att_UL_CE,
		 ul_ce.Failed_Acc_UL_CE,ul_ce.Failed_Ret_UL_CE,ul_ce.D3,dl_ce.SessionTime_DL_CE,ul_ce.SessionTime_UL_CE,dl_nc.Att_DL_NC,dl_nc.Failed_Acc_DL_NC,
		 dl_nc.Failed_Ret_DL_NC,dl_nc.[MEAN DATA USER RATE_DL_NC],ul_nc.Att_UL_NC,ul_nc.Failed_Acc_UL_NC,ul_nc.Failed_Ret_UL_NC,ul_nc.[MEAN DATA USER RATE_UL_NC]
		,ytbhd.Att_YTB_HD,ytbhd.YTB_Failed_HD,ytbhd.YTB_Dropped_HD,YTB_B1_HD,ytbhd.YTB_AVG_START_TIME,ytbhd.YTB_B2_HD,ytbhd.[YTB_B2_HD_%],ytbhd.YTB_B3_HD,ytbhd.YTB_B5_HD,ytbhd.YTB_B4_HD,
		 ytbhd.YTB_B6_HD,whttps.Web_HTTPS_Att,whttps.Web_HTTPS_Failed,whttps.Web_HTTPS_Dropped,whttps.Web_SessionTime_HTTPS_D5,web.Web_Att,
		 web.Web_Failed,web.Web_Dropped,web.Web_SessionTime_D5,wpublic.Web_Public_Att,wpublic.Web_Public_Failed,wpublic.Web_Public_Dropped,wpublic.Web_SessionTime_Public_D5,wpublic.WEB_IP_ACCESS_TIME_Public,
		 wpublic.WEB_HTTP_TRANSFER_TIME_Public,ytbsd.Att_YTB_SD,ytbsd.YTB_Failed_SD,ytbsd.YTB_Dropped_SD,ytbsd.YTB_B1_SD,ytbsd.YTB_B2_SD
		,lat.Latency_Att,lat.LAT_AVG,lat.LAT_D4,lat.LAT_MEDIAN,web.WEB_IP_ACCESS_TIME,web.WEB_HTTP_TRANSFER_TIME,whttps.WEB_IP_ACCESS_TIME_HTTPS,whttps.WEB_HTTP_TRANSFER_TIME_HTTPS
		,dl_ce.final_date,lat.LAT_MED


-------------------------------------------- añadimos la información de percentiles --------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------

----------------

insert into [dbo].[_Actualizacion_Qlik]
select ''Fin 2.2 Inicio Percentiles ''''' + @id+ ''''' Datos'', getdate()

----------------


exec [QLIK].[dbo].[plcc_data_statistics_new] '+@last_measurement+'
exec [QLIK].[dbo].[plcc_data_statistics_Columns_new] '''+@monthYear+''' ,'''+@ReportWeek+'''

----------------

	insert into [dbo].[_Actualizacion_Qlik]
	select ''Fin 2.3 Percentiles Ejecutados'', getdate()

----------------

insert into lcc_Data_final_qlik

Select q.*,[Percentil10_DL_CE]*1000,[Percentil90_DL_CE]*1000,[Percentil10_UL_CE]*1000,[Percentil90_UL_CE]*1000,[Percentil10_DL_NC]*1000,
	[Percentil90_DL_NC]*1000,[Percentil10_UL_NC]*1000,[Percentil90_UL_NC]*1000,round([Percentil_PING],0),[Percentil10_DL_CE_SCOPE]*1000,[Percentil90_DL_CE_SCOPE]*1000,
	[Percentil10_UL_CE_SCOPE]*1000,[Percentil90_UL_CE_SCOPE]*1000,[Percentil10_DL_NC_SCOPE]*1000,[Percentil90_DL_NC_SCOPE]*1000,
	[Percentil10_UL_NC_SCOPE]*1000,[Percentil90_UL_NC_SCOPE]*1000,round([Percentil_PING_SCOPE],0),[Percentil10_DL_CE_SCOPE_QLIK]*1000,[Percentil90_DL_CE_SCOPE_QLIK]*1000,
	[Percentil10_UL_CE_SCOPE_QLIK]*1000,[Percentil90_UL_CE_SCOPE_QLIK]*1000,[Percentil10_DL_NC_SCOPE_QLIK]*1000,[Percentil90_DL_NC_SCOPE_QLIK]*1000,[Percentil10_UL_NC_SCOPE_QLIK]*1000,
	[Percentil90_UL_NC_SCOPE_QLIK]*1000,round([Percentil_PING_SCOPE_QLIK],0),[SCOPE_QLIK]


from lcc_ActWeek_Data q 
		        left join _Percentiles_Data p on (q.entity=p.entidad and q.operator = case when mnc=01 then ''Vodafone'' when mnc=03 then ''Orange'' when mnc=07 then ''Movistar'' when mnc=04 then ''Yoigo'' end
											 and q.id= Case when p.Report_QLIK=''MUN'' then ''OSP'' else p.Report_QLIK end and q.meas_tech=p.meas_tech and 
											 q.monthyear = p.monthyear and q.ReportWeek=p.ReportWeek)
where q.monthyear = '''+@monthYear+''' and q.ReportWeek = '''+@ReportWeek+'''


----------------

	insert into [dbo].[_Actualizacion_Qlik]
	select ''Fin 2.4 Dashboard Datos ''''' + @id+ ''''' Finalizado'', getdate()

----------------

')
						

--Drop table lcc_Data_final_qlik_Ceci
