USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_lcc_km2_medidos_v2_NEW_Report]    Script Date: 13/03/2017 12:58:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************

+++ Procedimiento que calcula la cantidad de parcelas que medimos, el área cubierta +++
+++ y el porcentaje medido con respecto al total de la entidad						+++

****************************************************************************************/


ALTER procedure [dbo].[sp_lcc_km2_medidos_v2_NEW_Report] (
	@prefix as varchar(256),
	@sheetTech as varchar (256),
	@LA as bit
	,@report as varchar(256)
)
as

-- Definición de variables
--declare @prefix as varchar(256)= 'UPDATE_AGGRData4G_'
--declare @sheetTech as varchar(256) =''
--declare @la bit=0
--declare @report as varchar (256)='MUN'

DECLARE @SQLString nvarchar(4000)
declare @LAfilter as varchar(4000)
declare @database as varchar (256)= 'DASHBOARD'
declare @tabla_reporte as varchar (500)


if @la = 1 
begin
	set @LAfilter ='((convert(int,SUBSTRING(a.meas_date,1,2))<16 and a.entorno not like ''%LA%'' and a.entorno in (''8G'',''32G''))
	or (convert(int,SUBSTRING(a.meas_date,1,2))=16 and convert(int,SUBSTRING(a.meas_date,4,2))<=7 and  a.entorno not like ''%LA%'' and a.entorno in (''8G'',''32G''))
	or (convert(int,SUBSTRING(a.meas_date,1,2))>16 and a.entorno like ''%%'' or a.entorno is null)
	or (convert(int,SUBSTRING(a.meas_date,1,2))=16 and convert(int,SUBSTRING(a.meas_date,4,2))>7 and a.entorno like ''%%'' or a.entorno is null))' 
end
else 
begin
	set @LAfilter= ' a.entorno like ''%%'' or a.entorno is null'
end

-- Para introducir el procedimiento el todas las BBDD del sistema
--exec sp_ms_marksystemobject sp_lcc_km2_medidos

-- Borra la tabla donde almacenamos los datos en el caso de que exista
exec dashboard.dbo.sp_lcc_dropifexists 'lcc_km2_chequeo_mallado'
exec dashboard.dbo.sp_lcc_dropifexists 'lcc_km2_medidos'
exec dashboard.dbo.sp_lcc_dropifexists 'lcc_km2_totales'

-- Sacamos el total de las parcelas para cada entidad
if @report='vdf'
	begin
		SET @SQLString =N'
						select  a.Entidad_contenedora,
						count(a.nombre) as total_parcelas,
						count(a.Entidad_contenedora)*0.25 as [AreaTotal(km2)]
						into dashboard.dbo.lcc_km2_totales
						from  Dashboard.dbo.lcc_parcelas_VDF a, AGRIDS.dbo.lcc_parcelas p
						where a.Nombre=p.Nombre
						and p.Entorno not in (''rural'',''roads'',''roc'')  
						group by a.entidad_contenedora'

		EXECUTE sp_executesql @SQLString
		
		set @tabla_reporte='Dashboard.dbo.lcc_parcelas_VDF'
	end

if @report='mun'
	begin
		SET @SQLString =N'
						select  a.Entidad_contenedora,
						count(a.nombre) as total_parcelas,
						count(a.Entidad_contenedora)*0.25 as [AreaTotal(km2)]
						into dashboard.dbo.lcc_km2_totales
						from  Dashboard.dbo.lcc_parcelas_OSP a
						group by a.entidad_contenedora'
		EXECUTE sp_executesql @SQLString
		set @tabla_reporte='Dashboard.dbo.lcc_parcelas_OSP'
	end

-- Calculamos las parcelas y el area que medimos de cada entidad


SET @SQLString =N'
					select
						a.entidad,
						count(a.entidad) as Parcelas,
						count(a.entidad)*0.25 as [Area(km2)],
						a.Meas_date						
					into dashboard.dbo.lcc_km2_medidos
					from(
						select a.parcel, a.meas_date, a.entidad,a.entorno
						from 
							(select parcel,meas_Date,entidad,entorno
								from '+@database+'.dbo.'+@prefix+'lcc_aggr_sp_MDD_Data_DL_Thput_CE'+@sheetTech+'
								--where mnc=01
								where Report_Type = '''+@report+'''
								group by parcel,meas_Date,entidad,entorno
							Union all
								select parcel,meas_Date,entidad,entorno
								from '+@database+'.dbo.'+@prefix+'lcc_aggr_sp_MDD_Data_DL_Thput_NC'+@sheetTech+'
								--where mnc=01
								where Report_Type = '''+@report+'''
								group by parcel,meas_Date,entidad,entorno
							Union all
								select parcel,meas_Date,entidad,entorno
								from '+@database+'.dbo.'+@prefix+'lcc_aggr_sp_MDD_Data_Ping'+@sheetTech+'
								--where mnc=01
								where Report_Type = '''+@report+'''
								group by parcel,meas_Date,entidad,entorno 
							Union all
								select parcel,meas_Date,entidad,entorno
								from '+@database+'.dbo.'+@prefix+'lcc_aggr_sp_MDD_Data_UL_Thput_CE'+@sheetTech+'
								--where mnc=01
								where Report_Type = '''+@report+'''
								group by parcel,meas_Date,entidad,entorno
							union all
								select parcel,meas_Date,entidad,entorno
								from '+@database+'.dbo.'+@prefix+'lcc_aggr_sp_MDD_Data_UL_Thput_NC'+@sheetTech+'
								--where mnc=01
								where Report_Type = '''+@report+'''
								group by parcel,meas_Date,entidad,entorno
							union all
								select parcel,meas_Date,entidad,entorno
								from '+@database+'.dbo.'+@prefix+'lcc_aggr_sp_MDD_Data_Web'+@sheetTech+'
								--where mnc=01
								where Report_Type = '''+@report+'''
								group by parcel,meas_Date,entidad,entorno
							union all
								select parcel,meas_Date,entidad,entorno
								from '+@database+'.dbo.'+@prefix+'lcc_aggr_sp_MDD_Data_Youtube'+@sheetTech+'
								--where mnc=01
								where Report_Type = '''+@report+'''
								group by parcel,meas_Date,entidad,entorno
							union all
								select parcel,meas_Date,entidad,entorno
								from '+@database+'.dbo.'+@prefix+'lcc_aggr_sp_MDD_Data_Youtube_HD'+@sheetTech+'
								--where mnc=01
								where Report_Type = '''+@report+'''
								group by parcel,meas_Date,entidad,entorno) a, '+@tabla_reporte+' p
								where a.parcel=p.nombre and a.entidad=p.entidad_contenedora
								group by parcel,meas_date,entidad,entorno ) a
							where '+ @LAfilter +' 
							group by a.entidad,a.meas_Date'



EXECUTE sp_executesql @SQLString

----Cruzamos las tablas de las parcelas que medimos con las totales para sacar los porcentajes
select m.Entidad,
m.meas_date,
m.Parcelas,
m.[Area(km2)],
--db_name() DDBB,
(m.Parcelas*1.0/t.total_parcelas)*100 as [Porcentaje_medido],
--case 
--	when ((m.Parcelas*1.0/t.total_parcelas)*100) >1 then 1
--	else (m.Parcelas*1.0/t.total_parcelas)*100 end as [Porcentaje_medido],
t.total_parcelas,
t.[AreaTotal(km2)]
--m.Entorno
into dashboard.dbo.lcc_km2_chequeo_mallado
from
dashboard.dbo.lcc_km2_medidos m, dashboard.dbo.lcc_km2_totales t
where m.Entidad = t.Entidad_contenedora

-- Borramos las tablas temporales
drop table dashboard.dbo.lcc_km2_medidos,dashboard.dbo.lcc_km2_totales

