USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_lcc_create_DashBoard_STATISTICS_STDV]    Script Date: 27/06/2017 17:07:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[sp_lcc_create_DashBoard_STATISTICS_STDV] 
	@database as varchar(256)
	,@sheetTech as varchar(256)
	,@table as varchar(256)
	,@step float
	,@N_ranges int
	,@Code as varchar(256)
	,@ini_range as float
	,@last_range as bit
as

-------------------------------------------------------------------------------
-- Definición del cálculo de la desviación típica para una distribución (con la corrección de Bessel)

--            Desv= sqrt( (SUM (x_i - x_m)^2 * f_i) /(N-1) )

-- sqrt =  raíz cuadrada
-- SUM =  sumatorio desde i=1 hasta n (siendo n el número total de intervalos)

-- x_i = valor medio del intervalo 
-- f_i = frecuencia absoluta de la clase
-- N = total de muestras en todos los intervalos = suma de las frecuencias absolutas
-- x_m =  media de todas las clases = SUM(x_i*f_i)/N

-------------------------------------------------------------------------------
-- Declaración de variables
--declare @database as varchar(256) = '[AGGRdata4G]'
--declare @sheetTech as varchar(256)	= '' -- or '_CE' '_NC' '_NC_LTE'
--declare @table as varchar(256) = 'lcc_aggr_sp_MDD_Data_DL_Thput_CE_LTE_4G'
--declare @step float= 5
--declare @N_ranges int= 31
--declare @Code varchar (256)='mbps'
--declare @ini_range as float=0
--declare @last_range as bit=1

declare @i int =0
declare @field as varchar(256)
DECLARE @SQLString nvarchar(4000)
declare @aggr as varchar(256)

-------------------------------------------------------------------------------
-- Creación de la tabla transpuesta

-- Se crea la estructura de la tabla con los campos base
set @SQLString= N'
				exec dashboard.dbo.sp_lcc_dropifexists '''+@table+'_transpose_step1''
				Create table [DASHBOARD].[dbo].['+@table+'_transpose_step1](
						mnc varchar(256),
						entidad varchar(256),
						Meas_Date varchar(256),
						id int,
						x_i float,
						f_i float,
						xf float
						)'
EXECUTE sp_executesql @SQLString

-- Se insertan las filas por rangos con su correspondiente conteo (teniendo en cuenta el paso del histograma y el número total de rangos)
while @i< @N_ranges-1
begin
	if @step*@i = 0
		set @field=convert(varchar,@ini_range)+ '-' +  convert(varchar,@step+@ini_range)
	else set @field= convert(varchar,@step*@i+@ini_range) + '-' + convert(varchar,@step*(@i+1)+@ini_range)

	if @Code in ('NB','WB')
		set @field=@field+' '
	else if @Code in ('Mbps') or @Code in ('Mbps_N')
		set @field= ' '+@field
	else if @Code in ('overall')
		set @field= @field+' '
	else set @field= ' '+@field+' '

	-- Para el caso de voz Aggr_overall hay que sumar dos campos
	if @Code <> 'overall'
		set @aggr ='sum(['+@field+@Code+'])'
	else 
		set @aggr ='sum(['+@field+'WB]) + sum(['+@field+'NB])'


	set @SQLString= N'
					insert into [DASHBOARD].[dbo].['+@table+'_transpose_step1]
					select mnc,entidad,Meas_Date
							,'+convert(varchar,@i) + ' as id
							,'+convert(varchar,(@step*@i+@ini_range+@step/2))+' as x_i
							,'+@aggr+' as f_i
							,'+convert(varchar,(@step*@i+@ini_range+@step/2))+' * ('+@aggr+') as xf
					from '+ @database + '.[dbo].['+@table+']
					group by mnc,entidad,Meas_Date'
	set @i=@i+1
	EXECUTE sp_executesql @SQLString
end

-- Se añade el último rango
if @last_range= 1
begin
	if @Code in ('Mbps') or @Code in ('Mbps_N')
		set @field=' >' + convert(varchar,@step*(@N_ranges-1))
	else set @field=' >' + convert(varchar,@step*(@N_ranges-1))+' '

	set @SQLString= N'
					insert into [DASHBOARD].[dbo].['+@table+'_transpose_step1]
					select mnc,entidad,Meas_Date
							,'+convert(varchar,@N_ranges-1) + ' as id
							,'+convert(varchar,(@step*(@N_ranges-1)+@ini_range+@step/2))+' as x_i
							,sum(['+@field+@Code+']) as f_i
							,'+convert(varchar,(@step*(@N_ranges-1)+@ini_range+@step/2))+' * sum(['+@field+@Code+']) as xf
					from '+ @database + '.[dbo].['+@table+']
					group by mnc,entidad,Meas_Date'
	EXECUTE sp_executesql @SQLString
end
else
begin
	set @field= convert(varchar,@step*(@N_ranges-1)+@ini_range) + '-' + convert(varchar,@step*(@N_ranges)+@ini_range)
	if @Code in ('NB','WB')
		set @field=@field+' '
	else if @Code in ('overall')
		set @field= @field+' '
	else set @field= ' '+@field

	-- Para el caso de voz Aggr_overall hay que sumar dos campos
	if @Code <> 'overall'
		set @aggr ='sum(['+@field+@Code+'])'
	else 
		set @aggr ='sum(['+@field+'WB]) + sum(['+@field+'NB])'

set @SQLString= N'
				insert into [DASHBOARD].[dbo].['+@table+'_transpose_step1]
					select mnc,entidad,Meas_Date
							,'+convert(varchar,@N_ranges-1) + ' as id
							,'+convert(varchar,(@step*(@N_ranges-1)+@ini_range+@step/2))+' as x_i
							,'+@aggr+' as f_i
							,'+convert(varchar,(@step*(@N_ranges-1)+@ini_range+@step/2))+' * ('+@aggr+') as xf
					from '+ @database + '.[dbo].['+@table+']
					group by mnc,entidad,Meas_Date'
	EXECUTE sp_executesql @SQLString
end

-------------------------------------------------------------------------------
-- Cálculo de la desviación típica
-- Se añaden los campos calculados necesarios para obtener la desviación típica
SET @SQLString= N'
				exec dashboard.dbo.sp_lcc_dropifexists ''lcc_STDV' + @sheetTech +'_step1''
				select	a.mnc,a.entidad,a.Meas_Date
						,nullif((select sum(b.f_i) 
								from [DASHBOARD].[dbo].['+@table+'_transpose_step1] b
								where b.entidad=a.entidad and b.mnc=a.mnc and b.Meas_Date=a.Meas_Date),0) as N
						,nullif((select sum(b.xf) 
								from [DASHBOARD].[dbo].['+@table+'_transpose_step1] b
								where b.entidad=a.entidad and b.mnc=a.mnc and b.Meas_Date=a.Meas_Date),0) as xf_total
						,nullif((select sum(b.xf) 
								from [DASHBOARD].[dbo].['+@table+'_transpose_step1] b
								where b.entidad=a.entidad and b.mnc=a.mnc and b.Meas_Date=a.Meas_Date),0)
								/
								nullif((select sum(b.f_i) 
								from [DASHBOARD].[dbo].['+@table+'_transpose_step1] b
								where b.entidad=a.entidad and b.mnc=a.mnc and b.Meas_Date=a.Meas_Date),0) as x_m
				into [DASHBOARD].[dbo].[lcc_STDV' + @sheetTech +'_step1]
				from [DASHBOARD].[dbo].['+@table+'_transpose_step1] a 
				group by a.mnc,a.entidad,a.Meas_Date
				';
EXECUTE sp_executesql @SQLString


SET @SQLString= N'
				exec dashboard.dbo.sp_lcc_dropifexists ''lcc_STDV' + @sheetTech +'''
				select	a.mnc,a.entidad,a.Meas_Date,
						case when a.N =1 then sqrt( b.desv_step1/ (a.N))
						else sqrt( b.desv_step1/ (a.N-1) ) end as DESV	
				into [DASHBOARD].[dbo].[lcc_STDV' + @sheetTech +']
				from [DASHBOARD].[dbo].[lcc_STDV' + @sheetTech +'_step1] a,
					(select	b.entidad,b.mnc,b.meas_date,
							sum(power(b.x_i-a.x_m,2)*b.f_i) as desv_step1
					from [DASHBOARD].[dbo].['+@table+'_transpose_step1] b,
					[DASHBOARD].[dbo].[lcc_STDV' + @sheetTech +'_step1] a 
					where a.mnc=b.mnc and a.entidad=b.entidad and a.Meas_date=b.Meas_Date
					group by b.mnc,b.entidad,b.Meas_Date) b
				where a.mnc=b.mnc and a.entidad=b.entidad and a.Meas_date=b.Meas_Date
				';

EXECUTE sp_executesql @SQLString

---------------------------------------------------------------------------------
---- Limpieza de tablas temporales
SET @SQLString= N'
				exec dashboard.dbo.sp_lcc_dropifexists '''+@table+'_transpose_step1''' +
				' exec dashboard.dbo.sp_lcc_dropifexists ''lcc_STDV' + @sheetTech +'_step1'''
EXECUTE sp_executesql @SQLString