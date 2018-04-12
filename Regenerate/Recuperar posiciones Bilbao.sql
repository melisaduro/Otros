select  *
from lcc_calls_detailed
where sessionid= 6274


select *
from lcc_position_entity_list_vodafone
where fileid=56

select  master.dbo.fn_lcc_longitude2lonid ([Longitude_Fin_A], [Latitude_Fin_A]) as lonIDA
	,master.dbo.fn_lcc_longitude2lonid ([Longitude_Fin_B], [Latitude_Fin_B]) as LonidB
	,master.dbo.fn_lcc_latitude2latid ([Latitude_Fin_A]) as LAtA
	,master.dbo.fn_lcc_latitude2latid ([Latitude_Fin_B]) as LatB
	,*
from lcc_calls_detailed
where sessionid= 6274

--	lonIDA	LonidB	LAtA	LatB
--	-4752	-4763	96186	96207

--No tenemos la posicion del terminal A en la tabla de entorno
select *
from lcc_position_entity_list_vodafone
where ((lonid = -4752 and latid = 96186)
or (lonid = -4763 and latid = 96207))
and fileid= 56

--Tampoco en la de municipio
select *
from lcc_position_entity_list_municipio
where ((lonid = -4752 and latid = 96186)
or (lonid = -4763 and latid = 96207))
and fileid= 56

----------------------------------
----------------------------------
--En sp_lcc_create_Entity_position:
--La tabla de contorno se basa en _position_LonLat
Select e.fileid, e.lonid, e.latid, e.collectionname, e.MeasDate, e.Entity_name, e.[Type]
from (
	Select e.*
	from
	(select p.*, v.entity_name as 'Entity_name', 'Urban' as [Type],
			cast(p.fileid as Varchar) + ', ' + cast(p.lonid as Varchar) + ', ' + cast(p.latid as varchar) as tupla
	from AGRIDS_V2.dbo.lcc_AGRIDS_contornos_VF v, _position_LonLat p
	where
	p.lonid=v.lonid and p.latid=v.latid
	and v.entity_name is not null) e
)e, _position_Vodafone t			
where --e.fileid = t.fileid and 
	e.tupla <> (t.tupla)	
			
			
--Rellenamos _position_LonLat : tabla desde la que cargamos las tablas de entidad (todas las posiciones por log)
select 
	p.fileid,
	master.dbo.fn_lcc_longitude2lonid (isnull(p.[Longitude],0), isnull(p.[Latitude],0)) as lonid,
	master.dbo.fn_lcc_latitude2latid (isnull(p.[Latitude],0)) as latid,
	f.collectionname,
	master.dbo.fn_lcc_GetElement (1,f.collectionname,'_') as MeasDate
from position p, filelist f
where p.fileid =56
	and p.fileid=f.fileid
group by p.fileid, 
	master.dbo.fn_lcc_longitude2lonid (isnull(p.[Longitude],0), isnull(p.[Latitude],0)),
	master.dbo.fn_lcc_latitude2latid (isnull(p.[Latitude],0)),
	f.collectionname
order by 2,3

--lonid = -4752 and latid = 96186 No esta!!!!!!!!!!!!!

--CU donde rellena en gral la posicion final A:
Select	s.SessionId,
		p.longitude as longitude_fin_A,
		p.latitude as latitude_fin_A,
		master.dbo.fn_lcc_longitude2lonid (isnull(p.[Longitude],0), isnull(p.[Latitude],0)),
		master.dbo.fn_lcc_latitude2latid (isnull(p.[Latitude],0))
from sessions s,
	position p
where s.PosId=p.PosId
	and s.SessionId=p.SessionId
	and s.sessionid=6274


--CU update: en caso de estar vacia (no tiene gps), cogemos la posicion mas reciente

select  t1.longitude as longitude_fin_A,
		t2.latitude as latitude_fin_A,
		master.dbo.fn_lcc_longitude2lonid (isnull(t1.[Longitude],0), isnull(t2.[Latitude],0)),
		master.dbo.fn_lcc_latitude2latid (isnull(t2.[Latitude],0))
from (select top 1 longitude , 1 as id
	from lcc_calls_detailed lc, lcc_timelink_position l
	where l.timelink>=master.dbo.fn_lcc_gettimelink(lc.callendtimeStamp)
	and l.collectionname=lc.collectionname
	and side='A'
	and sessionid=6274) t1
inner join
	(select  top 1 latitude , 1 as id
	from lcc_calls_detailed lc, lcc_timelink_position l
	where l.timelink>=master.dbo.fn_lcc_gettimelink(lc.callendtimeStamp)
	and l.collectionname=lc.collectionname
	and side='A'
	and sessionid=6274) t2
on t1.id=t2.id


----------------------------------------------SOLUCION: Insertamos en la tabla LCC_Entity_GPS para recuperar las posiciones

select fileid, longitude, latitude
from Lcc_Entity_gps

use FY1617_Voice_Bilbao_3G_H2


create table [FY1617_Voice_Bilbao_3G_H2].[dbo].Lcc_Entity_gps (
	[fileid] [bigint] NULL,
	Longitude [float] NULL,
	Latitude [float] NULL
)


insert into [FY1617_Voice_Bilbao_3G_H2].[dbo].Lcc_Entity_gps
select p.*
from(
SELECT lc.Fileid,lc.longitude_fin_A,lc.latitude_fin_A 
FROM  [FY1617_Voice_Bilbao_3G_H2].dbo.lcc_Calls_Detailed lc
where lc.CollectionName like '%bilbao%')p
group by p.Fileid,p.longitude_fin_A,p.latitude_fin_A
order by timelink
----------------------------------------------------Lanzamos de nuevo el CU o directamente el create position para actualizar las tablas de lcc_entity_Vodafone


exec sp_lcc_create_Entity_position_List_aggr 0	
