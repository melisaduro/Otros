--Tiramos las tablas creadas en el DASHBOARD
drop table Dashboard.dbo.lcc_parcelas_OSP_NEW
drop table Dashboard.dbo.lcc_parcelas_VDF_NEW
drop table Dashboard.dbo.lcc_parcelas_OSP
drop table Dashboard.dbo.lcc_parcelas_VDF

--Generamos las tablas nuevas con las parcelas de 500x500
--18865
select entity_name as entidad_contenedora, master.dbo.fn_lcc_getParcel(longitud,latitud) as Nombre
into Dashboard.dbo.lcc_parcelas_VDF
from
(
select lonid, latid, entity_name, 
master.dbo.fn_lcc_latidtolatitude(latid) latitud,
 master.dbo.fn_lcc_lonidtolongitude(lonid,latid) longitud
from AGRIDS_v2.dbo.lcc_AGRIDS_contornos_VF lp
--where entity_name='logrono'
) t
group by entity_name,master.dbo.fn_lcc_getParcel(longitud,latitud)

--27246
select entity_name as entidad_contenedora, master.dbo.fn_lcc_getParcel(longitud,latitud) as Nombre
into Dashboard.dbo.lcc_parcelas_OSP
from
(
select lonid, latid, entity_name, 
master.dbo.fn_lcc_latidtolatitude(latid) latitud,
 master.dbo.fn_lcc_lonidtolongitude(lonid,latid) longitud
from AGRIDS_v2.dbo.lcc_AGRIDS_contornos_OSP lp
--where entity_name='logrono'
) t
group by entity_name,master.dbo.fn_lcc_getParcel(longitud,latitud)


---Realizamos el filtrado por entorno
--26060
select t.*
into Dashboard.dbo.lcc_parcelas_VDF_NEW
from  Dashboard.dbo.lcc_parcelas_VDF t, AGRIDS.dbo.lcc_parcelas p
where t.Nombre=p.Nombre
and p.Entorno not in ('rural','ROADS', 'ROC', 'main highways')  
group by t.entidad_contenedora,t.nombre

--17989
select t.*
into Dashboard.dbo.lcc_parcelas_OSP_NEW
from  Dashboard.dbo.lcc_parcelas_VDF t, AGRIDS.dbo.lcc_parcelas p
where t.Nombre=p.Nombre
and p.Entorno not in ('rural','ROADS', 'ROC', 'main highways')  
group by t.entidad_contenedora,t.nombre


