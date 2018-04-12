USE [QLIK]
GO
/****** Object:  StoredProcedure [dbo].[sp_lcc_create_DashBoard_STATISTICS_STDV]    Script Date: 27/06/2017 15:29:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[sp_lcc_create_DashBoard_STATISTICS_STDV] 
	@table as varchar(256)
	,@step float
	,@N_ranges int
	,@ini_range as float
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
--declare @table as varchar(256) = '_tmp_Desviaciones'
--declare @step float= 5
--declare @N_ranges int=41
--declare @ini_range as float=0



declare @i int =0
declare @field as varchar(256)
DECLARE @SQLString nvarchar(4000)
declare @aggr as varchar(256)

-------------------------------------------------------------------------------
-- Creación de la tabla transpuesta

-- Se crea la estructura de la tabla con los campos base
set @SQLString= N'
				exec sp_lcc_dropifexists '''+@table+'_transpose_step1''
				Create table ['+@table+'_transpose_step1](
						mnc varchar(256),
						entidad varchar(256),
						Date_Reporting varchar(256),
						Report_Type [varchar](255),
						Test_type [varchar](255),
						Meas_Tech [varchar](255),
						Aggr float,
						id int,
						x_i float,
						f_i float,
						xf float
						)'
EXECUTE sp_executesql @SQLString

-- Se insertan las filas por rangos con su correspondiente conteo (teniendo en cuenta el paso del histograma y el número total de rangos)
while @i< @N_ranges-1
begin
	set @SQLString= N'
					insert into ['+@table+'_transpose_step1]
					select mnc,
						   entidad,
						   Meas_Date,
						   Date_Reporting,
						   Report_Type,
						   Test_type,
						   Meas_Tech,
						   sum(['+convert(varchar,(@i+1))+']) as Aggr,
						   '+convert(varchar,@i) +' as id,
						   '+convert(varchar,(@step*@i+@ini_range+@step/2))+' as x_i,
							sum(['+convert(varchar,(@i+1))+']) as f_i,
							'+convert(varchar,(@step*@i+@ini_range+@step/2))+' * (sum(['+convert(varchar,(@i+1))+'])) as xf
					from ['+@table+']
					group by mnc,Date_Reporting,entidad,Report_Type,Test_type,Meas_Tech
					order by id'
	set @i=@i+1
	EXECUTE sp_executesql @SQLString
end

-------------------------------------------------------------------------------
-- Cálculo de la desviación típica
-- Se añaden los campos calculados necesarios para obtener la desviación típica
SET @SQLString= N'
				exec sp_lcc_dropifexists '''+@table+'_transpose''
				select	a.entidad,a.mnc,a.Date_Reporting,a.Report_Type,a.Test_type,a.Meas_Tech,a.id,a.range_inf, a.aggr,
						,nullif((select sum(b.f_i) 
								from ['+@table+'_transpose_step1] b
								where b.entidad=a.entidad and b.mnc=a.mnc and b.Date_Reporting=a.Date_Reporting and b.Report_Type=a.Report_Type and b.Test_type=a.Test_type and b.Meas_Tech=a.Meas_Tech and b.id<=a.id
								),0) as N
						,nullif((select sum(b.xf) 
								from ['+@table+'_transpose_step1] b
								where b.entidad=a.entidad and b.mnc=a.mnc and b.Date_Reporting=a.Date_Reporting and b.Report_Type=a.Report_Type and b.Test_type=a.Test_type and b.Meas_Tech=a.Meas_Tech and b.id<=a.id
								),0) as xf_total
						,nullif((select sum(b.xf) 
								from ['+@table+'_transpose_step1] b
								where b.entidad=a.entidad and b.mnc=a.mnc and b.Date_Reporting=a.Date_Reporting and b.Report_Type=a.Report_Type and b.Test_type=a.Test_type and b.Meas_Tech=a.Meas_Tech and b.id<=a.id
								),0)
								/
								nullif((select sum(b.f_i) 
								from ['+@table+'_transpose_step1] b
								where b.entidad=a.entidad and b.mnc=a.mnc and b.Date_Reporting=a.Date_Reporting and b.Report_Type=a.Report_Type and b.Test_type=a.Test_type and b.Meas_Tech=a.Meas_Tech and b.id<=a.id
								),0) as x_m
				into ['+@table+'_transpose]
				from ['+@table+'_transpose_step1] a 
				group by a.mnc,a.entidad,a.Date_Reporting,a.Report_Type,a.Test_type,a.Meas_Tech,a.id,a.range_inf,a.aggr
				order by a.entidad,a.mnc,a.id'
EXECUTE sp_executesql @SQLString


SET @SQLString= N'
				exec dashboard.dbo.sp_lcc_dropifexists _Resultados_STDV
				select	a.entidad,
						a.mnc, 
						a.Date_Reporting,
						a.Report_Type,
						a.Test_type,
						a.Meas_Tech,
						a.id,
						case when a.N =1 then sqrt( b.desv_step1/ (a.N))
						else sqrt( b.desv_step1/ (a.N-1) ) end as DESV
				into _Resultados_STDV
				from ['+@table+'_transpose] a,
					(select	b.entidad,
							b.mnc,
							b.Date_Reporting,
							b.Report_Type,
							b.Test_type,
							b.Meas_Tech,
							b.id,
							sum(power(b.x_i-a.x_m,2)*b.f_i) as desv_step1
					from ['+@table+'_transpose_step1]  b,
					['+@table+'_transpose] a 
					where a.mnc=b.mnc and a.entidad=b.entidad and a.Date_Reporting=b.Date_Reporting,a.Test_type=b.Test_type,a.Meas_Tech=b.Meas_Tech,a.id=b.id
					group by b.entidad,b.mnc,b.Date_Reporting,b.Report_Type,b.Test_type,b.Meas_Tech,b.id) b
				where a.mnc=b.mnc and a.entidad=b.entidad and a.Date_Reporting=b.Date_Reporting and a.Report_Type=b.Report_Type and a.Test_type=b.Test_type and a.Meas_Tech=b.Meas_Tech and a.id=b.id'

EXECUTE sp_executesql @SQLString

---------------------------------------------------------------------------------
---- Limpieza de tablas temporales
SET @SQLString= N'
				exec sp_lcc_dropifexists '''+@table+'_transpose''' +
				'exec sp_lcc_dropifexists '''+@table+'_transpose_step1'''
EXECUTE sp_executesql @SQLString