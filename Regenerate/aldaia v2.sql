if (select name from [FY1617_Data_Rest_3G_H2_6].sys.all_objects where name='lcc_input_gps') is null
begin

create table [FY1617_Data_Rest_3G_H2_6].[dbo].lcc_input_gps (
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

if (Select Tupla from  [FY1617_Data_Rest_3G_H2_6].[dbo].lcc_input_gps where Tupla= ('20170425_ADD_V_ALDAIA_1_3G, 20170425_ADD_V_ALDAIA_1_3G, FY1617_Data_Rest_3G_H2_6, FY1617_Data_Rest_3G_H2_6,, 03,, 01, 7.119')) is null
begin
insert into [FY1617_Data_Rest_3G_H2_6].[dbo].lcc_input_gps
values('20170425_ADD_V_ALDAIA_1_3G','20170425_ADD_V_ALDAIA_1_3G','FY1617_Data_Rest_3G_H2_6','FY1617_Data_Rest_3G_H2_6','03','01','7.119',
('20170425_ADD_V_ALDAIA_1_3G, 20170425_ADD_V_ALDAIA_1_3G, FY1617_Data_Rest_3G_H2_6, FY1617_Data_Rest_3G_H2_6, 03, 01, 7.119'))
END


SELECT q.CollectionName, q.fileid, q.sessionid, q.testid, q.indice, MAX(q.longitude) as longitude, MAX(q.latitude) as latitude
into FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN 
FROM (
Select f.collectionname, p.fileid, p.sessionid, p.testid, [master].[dbo].fn_lcc_getTimelink(CONVERT(time, DATEADD(s, 7.119,p.msgtime), 108)) as indice, p.longitude, p.latitude
from FY1617_Data_Rest_3G_H2_6.dbo.position p, FY1617_Data_Rest_3G_H2_6.dbo.filelist f
where f.CollectionName like '20170425_ADD_V_ALDAIA_1_3G' and f.fileid=p.fileid and right(left(f.imsi,5),2) = '03'
) q 
group by q.CollectionName, q.fileid, q.sessionid, q.testid, q.indice 

select * from _VUELTAORIGEN

--UPDATE 
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPBrowser
--SET 
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPBrowser.[Longitud Inicial] = FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.longitude,
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPBrowser.[Latitud Inicial] = FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.latitude
select _VUELTAORIGEN.longitude, _VUELTAORIGEN.latitude
FROM 
	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPBrowser, FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN
WHERE 
	[master].[dbo].fn_lcc_getTimelink(CONVERT(time, FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPBrowser.starttime, 108))=FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.indice 
	and FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPBrowser.CollectionName like '20170425_ADD_V_ALDAIA_1_3G' 
	and Lcc_Data_HTTPBrowser.mnc = '01' 
UNION ALL
--UPDATE 
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPBrowser
--SET 
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPBrowser.[Longitud Final] = FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.longitude,
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPBrowser.[Latitud Final] = FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.latitude

select _VUELTAORIGEN.longitude, _VUELTAORIGEN.latitude
FROM 
	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPBrowser, FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN
WHERE 
	[master].[dbo].fn_lcc_getTimelink(CONVERT(time, FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPBrowser.endTime, 108))=FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.indice 
	and FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPBrowser.CollectionName like '20170425_ADD_V_ALDAIA_1_3G'
	and Lcc_Data_HTTPBrowser.mnc = '01' 

UNION ALL
--UPDATE 
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_DL
--SET 
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_DL.[Longitud Inicial] = FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.longitude,
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_DL.[Latitud Inicial] = FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.latitude
select _VUELTAORIGEN.longitude, _VUELTAORIGEN.latitude
FROM 
	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_DL, FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN
WHERE 
	[master].[dbo].fn_lcc_getTimelink(CONVERT(time, FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_DL.starttime, 108))=FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.indice 
	and FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_DL.CollectionName like '20170425_ADD_V_ALDAIA_1_3G'
	and Lcc_Data_HTTPTransfer_DL.mnc = '01' 

UNION ALL
--UPDATE 
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_DL
--SET 
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_DL.[Longitud Final] = FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.longitude,
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_DL.[Latitud Final] = FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.latitude
select _VUELTAORIGEN.longitude, _VUELTAORIGEN.latitude
FROM 
	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_DL, FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN
WHERE 
	[master].[dbo].fn_lcc_getTimelink(CONVERT(time, FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_DL.endTime, 108))=FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.indice 
	and FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_DL.CollectionName like '20170425_ADD_V_ALDAIA_1_3G'
	and Lcc_Data_HTTPTransfer_DL.mnc = '01' 

UNION ALL
--UPDATE 
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_UL
--SET 
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_UL.[Longitud Inicial] = FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.longitude,
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_UL.[Latitud Inicial] = FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.latitude
select _VUELTAORIGEN.longitude, _VUELTAORIGEN.latitude 
FROM 
	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_UL, FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN
WHERE 
	[master].[dbo].fn_lcc_getTimelink(CONVERT(time, FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_UL.starttime, 108))=FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.indice 
	and FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_UL.CollectionName like '20170425_ADD_V_ALDAIA_1_3G'
	and Lcc_Data_HTTPTransfer_UL.mnc = '01' 

UNION ALL
--UPDATE 
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_UL
--SET 
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_UL.[Longitud Final] = FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.longitude,
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_UL.[Latitud Final] = FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.latitude
select _VUELTAORIGEN.longitude, _VUELTAORIGEN.latitude
FROM 
	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_UL, FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN
WHERE 
	[master].[dbo].fn_lcc_getTimelink(CONVERT(time, FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_UL.endTime, 108))=FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.indice 
	and FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_UL.CollectionName like '20170425_ADD_V_ALDAIA_1_3G'
	and Lcc_Data_HTTPTransfer_UL.mnc = '01' 

UNION ALL
--UPDATE 
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_Latencias
--SET 
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_Latencias.[Longitud Inicial] = FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.longitude,
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_Latencias.[Latitud Inicial] = FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.latitude
select _VUELTAORIGEN.longitude, _VUELTAORIGEN.latitude
FROM 
	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_Latencias, FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN
WHERE 
	[master].[dbo].fn_lcc_getTimelink(CONVERT(time, FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_Latencias.starttime, 108))=FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.indice 
	and FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_Latencias.CollectionName like '20170425_ADD_V_ALDAIA_1_3G'
	and Lcc_Data_Latencias.mnc = '01' 

UNION ALL
--UPDATE 
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_Latencias
--SET 
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_Latencias.[Longitud Final] = FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.longitude,
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_Latencias.[Latitud Final] = FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.latitude
select _VUELTAORIGEN.longitude, _VUELTAORIGEN.latitude
FROM 
	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_Latencias, FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN
WHERE 
	[master].[dbo].fn_lcc_getTimelink(CONVERT(time, FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_Latencias.endTime, 108))=FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.indice 
	and FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_Latencias.CollectionName like '20170425_ADD_V_ALDAIA_1_3G'
	and Lcc_Data_Latencias.mnc = '01'

UNION ALL
--UPDATE 
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_YOUTUBE
--SET 
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_YOUTUBE.[Longitud Inicial] = FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.longitude,
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_YOUTUBE.[Latitud Inicial] = FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.latitude
select _VUELTAORIGEN.longitude, _VUELTAORIGEN.latitude 
FROM 
	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_YOUTUBE, FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN
WHERE 
	[master].[dbo].fn_lcc_getTimelink(CONVERT(time, FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_YOUTUBE.starttime, 108))=FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.indice 
	and FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_YOUTUBE.CollectionName like '20170425_ADD_V_ALDAIA_1_3G'
	and Lcc_Data_YOUTUBE.mnc = '01'

UNION ALL
--UPDATE 
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_YOUTUBE
--SET 
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_YOUTUBE.[Longitud Final] = FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.longitude,
--	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_YOUTUBE.[Latitud Final] = FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.latitude
select _VUELTAORIGEN.longitude, _VUELTAORIGEN.latitude
FROM 
	FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_YOUTUBE, FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN
WHERE 
	[master].[dbo].fn_lcc_getTimelink(CONVERT(time, FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_YOUTUBE.endTime, 108))=FY1617_Data_Rest_3G_H2_6.dbo._VUELTAORIGEN.indice 
	and FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_YOUTUBE.CollectionName like '20170425_ADD_V_ALDAIA_1_3G'
	and Lcc_Data_YOUTUBE.mnc = '01'


--if (select name from [FY1617_Data_Rest_3G_H2_6].sys.all_objects where name='Lcc_Entity_gps') is null
--BEGIN

--create table [FY1617_Data_Rest_3G_H2_6].[dbo].Lcc_Entity_gps (
--	[fileid] [bigint] NULL,
--	Longitude [float] NULL,
--	Latitude [float] NULL
--)
--END

--insert into [FY1617_Data_Rest_3G_H2_6].[dbo].Lcc_Entity_gps
--SELECT p.*
--FROM 
--(
--		SELECT b.Fileid, b.[Longitud Final], b.[Latitud Final]
--		FROM FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPBrowser b
--		where b.CollectionName like '20170425_ADD_V_ALDAIA_1_3G'
--		and b.mnc = '01'
--		UNION ALL

--		SELECT d.Fileid, d.[Longitud Final], d.[Latitud Final]
--		FROM FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_DL d
--		where d.CollectionName like '20170425_ADD_V_ALDAIA_1_3G'
--		and b.mnc = '01'
--		UNION ALL

--		SELECT u.Fileid,u.[Longitud Final],u.[Latitud Final]
--		FROM FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_HTTPTransfer_UL u
--		where u.CollectionName like '20170425_ADD_V_ALDAIA_1_3G'
--		and b.mnc = '01'
--		UNION ALL

--		SELECT l.Fileid,l.[Longitud Final],l.[Latitud Final]
--		FROM FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_Latencias l
--		where l.CollectionName like '20170425_ADD_V_ALDAIA_1_3G'
--		and b.mnc = '01'
--		UNION ALL

--		SELECT y.Fileid, y.[Longitud Final], y.[Latitud Final]
--		FROM FY1617_Data_Rest_3G_H2_6.dbo.Lcc_Data_YOUTUBE y
--		where y.CollectionName like '20170425_ADD_V_ALDAIA_1_3G'
--		and b.mnc = '01'
--) p
--group by p.Fileid,p.[Longitud Final],p.[Latitud Final]


--drop table [FY1617_Data_Rest_3G_H2_6].[dbo]._VUELTAORIGEN 
