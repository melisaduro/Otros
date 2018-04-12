--USE [master]
--GO
--/****** Object:  StoredProcedure [dbo].[sp_lcc_gps_regenerate]    Script Date: 09/05/2017 13:26:37 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--ALTER procedure [dbo].[sp_lcc_gps_regenerate]
--(
--	@CN_ORIGEN AS VARCHAR(256),
--	@CN_DESTINO AS varchar(256),
--	@DB_ORIGEN AS varchar(256),
--	@DB_DESTINO AS varchar(256),
--	@MNC_ORIGEN as varchar(256),
--	@MNC_DESTINO as varchar(256),
--	@GAP AS INT

--)
--as
--Testing variables

 use FY1617_Data_Rest_3G_H2_6

--CREO TABLA TEMPORAL VUELTAORIGEN QUE TIENE COORDENADAS CORRECTAS DE UN COLLECTIONNAME
DECLARE @CN_ORIGEN AS VARCHAR(256)='20170425_ADD_V_ALDAIA_1_3G' ---insertar collectionname origen del que se obtendrá coordenadas
DECLARE @CN_DESTINO AS varchar(256) ='20170425_ADD_V_ALDAIA_1_3G' --- insertar collectionname destino que se debe cambiar coordenadas.
DECLARE @DB_ORIGEN AS VARCHAR(256)='FY1617_Data_Rest_3G_H2_6' ---insertar collectionname origen del que se obtendrá coordenadas
DECLARE @DB_DESTINO AS varchar(256) ='FY1617_Data_Rest_3G_H2_6' --- insertar collectionname destino que se debe cambiar coordenadas.
DECLARE @MNC_ORIGEN as varchar(256) = '03'
DECLARE @MNC_DESTINO as varchar(256) = '01'
DECLARE @GAP as varchar(256) = '7.119'

----Crear tabla lcc_input_gps para info recursiva si no existe y si existe actualizarla -----
exec('
if (select name from ['+@DB_DESTINO+'].sys.all_objects where name=''lcc_input_gps'') is null
begin

create table ['+@DB_DESTINO+'].[dbo].lcc_input_gps (
	Collectionnname_origen [varchar] (256) NULL,
	Collectionnname_destino [varchar] (256) NULL,
	DB_origen [varchar] (256) NULL,
	DB_destino [varchar] (256) NULL,
	MNC_origen [varchar] (256) NULL,
	MNC_destino [varchar] (256) NULL,
	GAP [varchar] (256) NULL,
	Tupla [varchar] (256) NULL
)

end

if (Select Tupla from  ['+@DB_DESTINO+'].[dbo].lcc_input_gps where Tupla= ('''+@CN_ORIGEN+''+', '+''+@CN_DESTINO+''+', '+''+@DB_ORIGEN+''+', '+''+@DB_DESTINO+''+',, '+''+@MNC_ORIGEN+''+',, '+''+@MNC_DESTINO+''+', '+''+@GAP+''')) is null
begin
insert into ['+ @DB_DESTINO +'].[dbo].lcc_input_gps
values('''+@CN_ORIGEN+''','''+@CN_DESTINO+''','''+@DB_ORIGEN+''','''+@DB_DESTINO+''','''+@MNC_ORIGEN+''','''+@MNC_DESTINO+''','''+@GAP+''',
('''+@CN_ORIGEN+''+', '+''+@CN_DESTINO+''+', '+''+@DB_ORIGEN+''+', '+''+@DB_DESTINO+''+', '+''+@MNC_ORIGEN+''+', '+''+@MNC_DESTINO+''+', '+''+@GAP+'''))
END
')




---- Introducir BBDD de las que se cogen coordenadas -----
exec ('

SELECT q.CollectionName, q.fileid, q.sessionid, q.testid, q.indice, MAX(q.longitude) as longitude, MAX(q.latitude) as latitude
into ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN 
FROM (
Select f.collectionname, p.fileid, p.sessionid, p.testid, [master].[dbo].fn_lcc_getTimelink(CONVERT(time, DATEADD(s, ' + @GAP + ',p.msgtime), 108)) as indice, p.longitude, p.latitude
from ' + @DB_ORIGEN + '.dbo.position p, ' + @DB_ORIGEN + '.dbo.filelist f
where f.CollectionName like ''' + @CN_ORIGEN + ''' and f.fileid=p.fileid and right(left(f.imsi,5),2) = ''' + @MNC_ORIGEN + '''
) q 
group by q.CollectionName, q.fileid, q.sessionid, q.testid, q.indice ')

---- Introducir BBDD destino a modificar------


if @DB_DESTINO like '%Voice%'
begin
---ACTUALIZO COORDENADAS INICIALES VOZ: lcc_Calls_Detailed
exec ('

UPDATE 
	' + @DB_DESTINO + '.[dbo].lcc_Calls_Detailed
SET 
	' + @DB_DESTINO + '.dbo.lcc_Calls_Detailed.longitude_ini_A = ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.longitude,
	' + @DB_DESTINO + '.dbo.lcc_Calls_Detailed.latitude_ini_A = ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.latitude
FROM 
	' + @DB_DESTINO + '.dbo.lcc_Calls_Detailed, ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN
WHERE 
	[master].[dbo].fn_lcc_getTimelink(CONVERT(time, ' + @DB_DESTINO + '.dbo.lcc_Calls_Detailed.callStartTimeStamp, 108))=' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.indice 
	and ' + @DB_DESTINO + '.dbo.lcc_Calls_Detailed.CollectionName like ''' + @CN_DESTINO + '''
	and mnc = ' + @MNC_DESTINO + '
')

---ACTUALIZO COORDENADAS FINALES VOZ: lcc_Calls_Detailed
exec ('
UPDATE 
	' + @DB_DESTINO + '.[dbo].lcc_Calls_Detailed
SET 
	' + @DB_DESTINO + '.[dbo].lcc_Calls_Detailed.longitude_fin_A = ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.longitude,
	' + @DB_DESTINO + '.[dbo].lcc_Calls_Detailed.latitude_fin_A = ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.latitude
FROM 
	' + @DB_DESTINO + '.[dbo].lcc_Calls_Detailed, ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN
WHERE 
	[master].[dbo].fn_lcc_getTimelink(CONVERT(time, ' + @DB_DESTINO + '.dbo.lcc_Calls_Detailed.callEndTimeStamp, 108))=' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.indice 
	and ' + @DB_DESTINO + '.dbo.lcc_Calls_Detailed.CollectionName like ''' + @CN_DESTINO + '''
	and mnc = ' + @MNC_DESTINO + '
')


-------CREAR EL Lcc_Entity_gps (comprobar si existe y sino crearlo) para almacenar valores nuevos de coordenadas y poder actualizar la tabla de agrids.
exec('
if (select name from ['+@DB_DESTINO+'].sys.all_objects where name=''Lcc_Entity_gps'') is null
BEGIN

create table ['+@DB_DESTINO+'].[dbo].Lcc_Entity_gps (
	[fileid] [bigint] NULL,
	Longitude [float] NULL,
	Latitude [float] NULL
)

END

insert into ['+@DB_DESTINO+'].[dbo].Lcc_Entity_gps
select p.*
from(
SELECT lc.Fileid,lc.longitude_fin_A,lc.latitude_fin_A 
FROM ' + @DB_DESTINO + '.dbo.lcc_Calls_Detailed lc
where lc.CollectionName like ''' + @CN_DESTINO + '''
and lc.mnc = ''' + @MNC_DESTINO + '''
)p
group by p.Fileid,p.longitude_fin_A,p.latitude_fin_A 
')
end

---
if @DB_DESTINO like '%Data%'
begin
---ACTUALIZO COORDENADAS INICIALES DATOS: Lcc_Data_HTTPBrowser
exec ('
UPDATE 
	' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPBrowser
SET 
	' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPBrowser.[Longitud Inicial] = ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.longitude,
	' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPBrowser.[Latitud Inicial] = ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.latitude
FROM 
	' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPBrowser, ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN
WHERE 
	[master].[dbo].fn_lcc_getTimelink(CONVERT(time, ' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPBrowser.starttime, 108))=' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.indice 
	and ' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPBrowser.CollectionName like ''' + @CN_DESTINO + ''' 
	and Lcc_Data_HTTPBrowser.mnc = ''' + @MNC_DESTINO + ''' 
')
---ACTUALIZO COORDENADAS FINALES DATOS: Lcc_Data_HTTPBrowser
exec ('
UPDATE 
	' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPBrowser
SET 
	' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPBrowser.[Longitud Final] = ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.longitude,
	' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPBrowser.[Latitud Final] = ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.latitude
FROM 
	' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPBrowser, ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN
WHERE 
	[master].[dbo].fn_lcc_getTimelink(CONVERT(time, ' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPBrowser.endTime, 108))=' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.indice 
	and ' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPBrowser.CollectionName like ''' + @CN_DESTINO + '''
	and Lcc_Data_HTTPBrowser.mnc = ''' + @MNC_DESTINO + ''' 

')


---ACTUALIZO COORDENADAS INICIALES DATOS: [dbo].[Lcc_Data_HTTPTransfer_DL]
exec ('
UPDATE 
	' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_DL
SET 
	' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_DL.[Longitud Inicial] = ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.longitude,
	' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_DL.[Latitud Inicial] = ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.latitude
FROM 
	' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_DL, ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN
WHERE 
	[master].[dbo].fn_lcc_getTimelink(CONVERT(time, ' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_DL.starttime, 108))=' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.indice 
	and ' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_DL.CollectionName like ''' + @CN_DESTINO + '''
	and Lcc_Data_HTTPTransfer_DL.mnc = ''' + @MNC_DESTINO + ''' 

')
---ACTUALIZO COORDENADAS FINALES DATOS: [dbo].[Lcc_Data_HTTPTransfer_DL]
exec ('
UPDATE 
	' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_DL
SET 
	' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_DL.[Longitud Final] = ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.longitude,
	' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_DL.[Latitud Final] = ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.latitude
FROM 
	' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_DL, ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN
WHERE 
	[master].[dbo].fn_lcc_getTimelink(CONVERT(time, ' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_DL.endTime, 108))=' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.indice 
	and ' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_DL.CollectionName like ''' + @CN_DESTINO + '''
	and Lcc_Data_HTTPTransfer_DL.mnc = ''' + @MNC_DESTINO + ''' 

')


---ACTUALIZO COORDENADAS INICIALES DATOS: [dbo].[Lcc_Data_HTTPTransfer_UL]
exec ('
UPDATE 
	' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_UL
SET 
	' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_UL.[Longitud Inicial] = ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.longitude,
	' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_UL.[Latitud Inicial] = ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.latitude
FROM 
	' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_UL, ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN
WHERE 
	[master].[dbo].fn_lcc_getTimelink(CONVERT(time, ' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_UL.starttime, 108))=' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.indice 
	and ' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_UL.CollectionName like ''' + @CN_DESTINO + '''
	and Lcc_Data_HTTPTransfer_UL.mnc = ''' + @MNC_DESTINO + ''' 

')
---ACTUALIZO COORDENADAS FINALES DATOS: [dbo].[Lcc_Data_HTTPTransfer_UL]
exec ('
UPDATE 
	' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_UL
SET 
	' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_UL.[Longitud Final] = ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.longitude,
	' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_UL.[Latitud Final] = ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.latitude
FROM 
	' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_UL, ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN
WHERE 
	[master].[dbo].fn_lcc_getTimelink(CONVERT(time, ' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_UL.endTime, 108))=' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.indice 
	and ' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_UL.CollectionName like ''' + @CN_DESTINO + '''
	and Lcc_Data_HTTPTransfer_UL.mnc = ''' + @MNC_DESTINO + ''' 

')


---ACTUALIZO COORDENADAS INICIALES DATOS: [dbo].[Lcc_Data_Latencias]
exec ('
UPDATE 
	' + @DB_DESTINO + '.dbo.Lcc_Data_Latencias
SET 
	' + @DB_DESTINO + '.dbo.Lcc_Data_Latencias.[Longitud Inicial] = ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.longitude,
	' + @DB_DESTINO + '.dbo.Lcc_Data_Latencias.[Latitud Inicial] = ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.latitude
FROM 
	' + @DB_DESTINO + '.dbo.Lcc_Data_Latencias, ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN
WHERE 
	[master].[dbo].fn_lcc_getTimelink(CONVERT(time, ' + @DB_DESTINO + '.dbo.Lcc_Data_Latencias.starttime, 108))=' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.indice 
	and ' + @DB_DESTINO + '.dbo.Lcc_Data_Latencias.CollectionName like ''' + @CN_DESTINO + '''
	and Lcc_Data_Latencias.mnc = ''' + @MNC_DESTINO + ''' 

')
---ACTUALIZO COORDENADAS FINALES DATOS: [dbo].[Lcc_Data_Latencias]
exec ('
UPDATE 
	' + @DB_DESTINO + '.dbo.Lcc_Data_Latencias
SET 
	' + @DB_DESTINO + '.dbo.Lcc_Data_Latencias.[Longitud Final] = ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.longitude,
	' + @DB_DESTINO + '.dbo.Lcc_Data_Latencias.[Latitud Final] = ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.latitude
FROM 
	' + @DB_DESTINO + '.dbo.Lcc_Data_Latencias, ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN
WHERE 
	[master].[dbo].fn_lcc_getTimelink(CONVERT(time, ' + @DB_DESTINO + '.dbo.Lcc_Data_Latencias.endTime, 108))=' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.indice 
	and ' + @DB_DESTINO + '.dbo.Lcc_Data_Latencias.CollectionName like ''' + @CN_DESTINO + '''
	and Lcc_Data_Latencias.mnc = ''' + @MNC_DESTINO + '''

')


---ACTUALIZO COORDENADAS INICIALES DATOS: [dbo].[Lcc_Data_YOUTUBE]
exec ('
UPDATE 
	' + @DB_DESTINO + '.dbo.Lcc_Data_YOUTUBE
SET 
	' + @DB_DESTINO + '.dbo.Lcc_Data_YOUTUBE.[Longitud Inicial] = ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.longitude,
	' + @DB_DESTINO + '.dbo.Lcc_Data_YOUTUBE.[Latitud Inicial] = ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.latitude
FROM 
	' + @DB_DESTINO + '.dbo.Lcc_Data_YOUTUBE, ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN
WHERE 
	[master].[dbo].fn_lcc_getTimelink(CONVERT(time, ' + @DB_DESTINO + '.dbo.Lcc_Data_YOUTUBE.starttime, 108))=' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.indice 
	and ' + @DB_DESTINO + '.dbo.Lcc_Data_YOUTUBE.CollectionName like ''' + @CN_DESTINO + '''
	and Lcc_Data_YOUTUBE.mnc = ''' + @MNC_DESTINO + '''

')
---ACTUALIZO COORDENADAS FINALES DATOS: [dbo].[Lcc_Data_YOUTUBE]
exec ('
UPDATE 
	' + @DB_DESTINO + '.dbo.Lcc_Data_YOUTUBE
SET 
	' + @DB_DESTINO + '.dbo.Lcc_Data_YOUTUBE.[Longitud Final] = ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.longitude,
	' + @DB_DESTINO + '.dbo.Lcc_Data_YOUTUBE.[Latitud Final] = ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.latitude
FROM 
	' + @DB_DESTINO + '.dbo.Lcc_Data_YOUTUBE, ' + @DB_ORIGEN + '.dbo._VUELTAORIGEN
WHERE 
	[master].[dbo].fn_lcc_getTimelink(CONVERT(time, ' + @DB_DESTINO + '.dbo.Lcc_Data_YOUTUBE.endTime, 108))=' + @DB_ORIGEN + '.dbo._VUELTAORIGEN.indice 
	and ' + @DB_DESTINO + '.dbo.Lcc_Data_YOUTUBE.CollectionName like ''' + @CN_DESTINO + '''
	and Lcc_Data_YOUTUBE.mnc = ''' + @MNC_DESTINO + '''

')

-------CREAR EL Lcc_Entity_gps (comprobar si existe y sino crearlo) para almacenar valores nuevos de coordenadas y poder actualizar la tabla de agrids.
exec('
if (select name from ['+ @DB_DESTINO +'].sys.all_objects where name=''Lcc_Entity_gps'') is null
BEGIN

create table ['+@DB_DESTINO+'].[dbo].Lcc_Entity_gps (
	[fileid] [bigint] NULL,
	Longitude [float] NULL,
	Latitude [float] NULL
)
END

insert into ['+@DB_DESTINO+'].[dbo].Lcc_Entity_gps
SELECT p.*
FROM 
(
		SELECT b.Fileid, b.[Longitud Final], b.[Latitud Final]
		FROM ' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPBrowser b
		where b.CollectionName like ''' + @CN_DESTINO + '''
		and b.mnc = ''' + @MNC_DESTINO + '''
		UNION ALL

		SELECT d.Fileid, d.[Longitud Final], d.[Latitud Final]
		FROM ' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_DL d
		where d.CollectionName like ''' + @CN_DESTINO + '''
		and b.mnc = ''' + @MNC_DESTINO + '''
		UNION ALL

		SELECT u.Fileid,u.[Longitud Final],u.[Latitud Final]
		FROM ' + @DB_DESTINO + '.dbo.Lcc_Data_HTTPTransfer_UL u
		where u.CollectionName like ''' + @CN_DESTINO + '''
		and b.mnc = ''' + @MNC_DESTINO + '''
		UNION ALL

		SELECT l.Fileid,l.[Longitud Final],l.[Latitud Final]
		FROM ' + @DB_DESTINO + '.dbo.Lcc_Data_Latencias l
		where l.CollectionName like ''' + @CN_DESTINO + '''
		and b.mnc = ''' + @MNC_DESTINO + '''
		UNION ALL

		SELECT y.Fileid, y.[Longitud Final], y.[Latitud Final]
		FROM ' + @DB_DESTINO + '.dbo.Lcc_Data_YOUTUBE y
		where y.CollectionName like ''' + @CN_DESTINO + '''
		and b.mnc = ''' + @MNC_DESTINO + '''
) p
group by p.Fileid,p.[Longitud Final],p.[Latitud Final]

')

end

exec('
drop table ['+@DB_ORIGEN+'].[dbo]._VUELTAORIGEN ')

exec sp_lcc_create_Entity_position_List_aggr 0