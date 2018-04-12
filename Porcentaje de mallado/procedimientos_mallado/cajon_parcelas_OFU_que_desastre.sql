select m.provincia,m.municipio,parcel_500, entorno, count(1)
from AGRIDS_v2.dbo.[lcc_G2K5Absolute_INDEX_new] m, agrids.dbo.lcc_parcelas p
where p.nombre=m.parcel_500
and /*m.city_name='linares' and*/ municipio='linares'
and p.entorno not in ('RURAL','ROADS','ROC')
group by m.provincia,m.municipio,parcel_500,entorno


select nombre, entorno, entidad_contenedora
from agrids.dbo.lcc_parcelas
where  entidad_contenedora='linares'
and entorno not in ('RURAL','ROADS','ROC')
group by nombre, entorno, entidad_contenedora

select *
from agrids_v2.dbo.lcc_AGRIDS_contornos_VF
where entity_name='linares'

select *
from agrids.dbo.lcc_parcelas
where entidad_contenedora='barcelona'
and entorno='main'


select entity_name as entidad_contenedora, master.dbo.fn_lcc_getParcel(longitud,latitud) as Nombre
--into Dashboard.dbo.lcc_parcelas_VDF
from
(
select lonid, latid, entity_name, 
master.dbo.fn_lcc_latidtolatitude(latid) latitud,
 master.dbo.fn_lcc_lonidtolongitude(lonid,latid) longitud
from AGRIDS_v2.dbo.lcc_AGRIDS_contornos_VF lp
where entity_name='logrono'
) t
group by entity_name,master.dbo.fn_lcc_getParcel(longitud,latitud)



select t.*
from  Dashboard.dbo.lcc_parcelas_VDF t, AGRIDS.dbo.lcc_parcelas p
where t.Nombre=p.Nombre
and p.Entorno not in ('rural','roads')  
--and t.entidad_contenedora='carreno'
group by t.entidad_contenedora,t.nombre