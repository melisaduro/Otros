select *, master.dbo.fn_lcc_getParcel(longitud,latitud) parcela, 1 as Pixels

from
(
select lonid, latid, road, 
master.dbo.fn_lcc_latidtolatitude(latid) latitud,
 master.dbo.fn_lcc_lonidtolongitude(lonid,latid) longitud
from AGRIDS_v2.dbo.[lcc_G2K5Absolute_INDEX_new] lp
) t

select* from AGRIDS_V2.dbo.lcc_G2K5Absolute_INDEX_new f,
AGRIDs.lcc_parcelas v

select *
from agrids_v2.dbo.lcc_AGRIDS_Contornos_VF
where entity_name='linares'

select * 
from agrids_v2.dbo.lcc_AGRIDS_contornos_OSP
where INE='23055'

select m.provincia,m.city_name, parcel_500,entorno
from agrids_v2.dbo.lcc_G2K5Absolute_INDEX_new m, agrids.dbo.lcc_parcelas p
where road is null
and p.nombre=m.parcel_500
and entorno in ('MAIN','SMALLER','ADDON','TOURISTIC')
and municipio='linares'
group by m.provincia,m.city_name, parcel_500,entorno

select a.nombre,a.entidad_contenedora, count(a.nombre) as total_parcelas, 
		count(a.entidad_contenedora)*0.25*0.25 as [AreaTotal(km2)],
		a.entorno
from agrids.dbo.lcc_parcelas a
where a.entidad_contenedora='linares'
and a.entorno='addon'
group by a.nombre,a.entidad_contenedora,a.entorno






select a.parcel, a.meas_date, a.entidad,t.entorno
from 
(select parcel,meas_Date,entidad
from aggrdata4G.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_CE
--where mnc=01
where Report_Type = 'MUN'
and entidad='cordoba'
and meas_date='17_01'
group by parcel,meas_Date,entidad
Union all
select parcel,meas_Date,entidad
from aggrdata4G.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_NC
--where mnc=01
where Report_Type = 'MUN'
and entidad='LINARES'
and meas_date='17_02'
group by parcel,meas_Date,entidad
Union all
select parcel,meas_Date,entidad
from aggrdata4G.dbo.lcc_aggr_sp_MDD_Data_Ping
--where mnc=01
where Report_Type = 'MUN'
and entidad='LINARES'
and meas_date='17_02'
group by parcel,meas_Date,entidad
Union all
select parcel,meas_Date,entidad
from aggrdata4G.dbo.lcc_aggr_sp_MDD_Data_UL_Thput_CE
--where mnc=01
where Report_Type = 'MUN'
and entidad='LINARES'
and meas_date='17_02'
group by parcel,meas_Date,entidad
union all
select parcel,meas_Date,entidad
from aggrdata4G.dbo.lcc_aggr_sp_MDD_Data_UL_Thput_NC
--where mnc=01
where Report_Type = 'MUN'
and entidad='LINARES'
and meas_date='17_02'
group by parcel,meas_Date,entidad
union all
select parcel,meas_Date,entidad
from aggrdata4G.dbo.lcc_aggr_sp_MDD_Data_Web
--where mnc=01
where Report_Type = 'MUN'
and entidad='LINARES'
and meas_date='17_02'
group by parcel,meas_Date,entidad
union all
select parcel,meas_Date,entidad
from aggrdata4G.dbo.lcc_aggr_sp_MDD_Data_Youtube
--where mnc=01
where Report_Type = 'MUN'
and entidad='LINARES'
and meas_date='17_02'
group by parcel,meas_Date,entidad
union all
select parcel,meas_Date,entidad
from aggrdata4G.dbo.lcc_aggr_sp_MDD_Data_Youtube_HD
--where mnc=01
where Report_Type = 'MUN'
and entidad='LINARES'
and meas_date='17_02'
group by parcel,meas_Date,entidad) a
inner join agrids.dbo.lcc_parcelas t
on (a.parcel=t.nombre)
where  t.entorno like '%%' or t.entorno is null 
group by a.parcel, a.meas_date, a.entidad,t.entorno



select * from dashboard.dbo.lcc_km2_chequeo_mallado
where entidad='linares'


select master.dbo.fn_lcc_latidtolatitude(latid) latitud,
	master.dbo.fn_lcc_lonidtolongitude(lonid,latid) longitud
from agrids_v2.dbo.lcc_AGRIDS_Contornos_VF
where entity_name like 'carreno'

select entity_name
from agrids_v2.dbo.lcc_AGRIDS_Contornos_VF
group by entity_name
order by 1

select entity_name
from agrids_v2.dbo.lcc_AGRIDS_Contornos_OSP
where project not like '%solo cobertura%'
group by entity_name
order by 1

select d.entity_name,t.project
from agrids_v2.dbo.lcc_AGRIDS_Contornos_OSP d, agrids_v2.dbo.lcc_ciudades_tipo_Project_V9 t
where d.entity_name=t.entity_name
and d.project not in ('solo cobertura')
group by d.entity_name,t.project
order by 1

select t.entity_name,t.project
from agrids_v2.dbo.lcc_AGRIDS_Contornos_OSP t
left join agrids_v2.dbo.lcc_AGRIDS_Contornos_VF p
on (p.entity_name=t.entity_name)
where p.entity_name is null
group by t.entity_name,t.project

select *
from agrids_v2.dbo.lcc_Parcelas_nucleosOSP t, agrids.dbo.lcc_parcelas m
where t.entity_name ='linares'
and t.nombre=m.nombre


select
a.entidad,
a.parcel,
count(a.entidad) as Parcelas,
count(a.entidad)*0.25 as [Area(km2)],
a.Meas_date    
from(
select a.parcel, a.meas_date, a.entidad,a.entorno
from 
(select parcel,meas_Date,entidad,entorno
from DASHBOARD.dbo.UPDATE_AGGRData4G_lcc_aggr_sp_MDD_Data_DL_Thput_CE
--where mnc=01
where Report_Type = 'VDF'
and entidad='calella'
and meas_date='16_08'
group by parcel,meas_Date,entidad,entorno
Union all
select parcel,meas_Date,entidad,entorno
from DASHBOARD.dbo.UPDATE_AGGRData4G_lcc_aggr_sp_MDD_Data_DL_Thput_NC
--where mnc=01
where Report_Type = 'VDF'
and entidad='calella'
and meas_date='16_08'
group by parcel,meas_Date,entidad,entorno
Union all
select parcel,meas_Date,entidad,entorno
from DASHBOARD.dbo.UPDATE_AGGRData4G_lcc_aggr_sp_MDD_Data_Ping
--where mnc=01
where Report_Type = 'VDF'
and entidad='calella'
and meas_date='16_08'
group by parcel,meas_Date,entidad,entorno 
Union all
select parcel,meas_Date,entidad,entorno
from DASHBOARD.dbo.UPDATE_AGGRData4G_lcc_aggr_sp_MDD_Data_UL_Thput_CE
--where mnc=01
where Report_Type = 'VDF'
and entidad='calella'
and meas_date='16_08'
group by parcel,meas_Date,entidad,entorno
union all
select parcel,meas_Date,entidad,entorno
from DASHBOARD.dbo.UPDATE_AGGRData4G_lcc_aggr_sp_MDD_Data_UL_Thput_NC
--where mnc=01
where Report_Type = 'VDF'
and entidad='calella'
and meas_date='16_08'
group by parcel,meas_Date,entidad,entorno
union all
select parcel,meas_Date,entidad,entorno
from DASHBOARD.dbo.UPDATE_AGGRData4G_lcc_aggr_sp_MDD_Data_Web
--where mnc=01
where Report_Type = 'VDF'
and entidad='calella'
and meas_date='16_08'
group by parcel,meas_Date,entidad,entorno
union all
select parcel,meas_Date,entidad,entorno
from DASHBOARD.dbo.UPDATE_AGGRData4G_lcc_aggr_sp_MDD_Data_Youtube
--where mnc=01
where Report_Type = 'VDF'
and entidad='calella'
and meas_date='16_08'
group by parcel,meas_Date,entidad,entorno
union all
select parcel,meas_Date,entidad,entorno
from DASHBOARD.dbo.UPDATE_AGGRData4G_lcc_aggr_sp_MDD_Data_Youtube_HD
--where mnc=01
where Report_Type = 'VDF'
and entidad='calella'
and meas_date='16_08'
group by parcel,meas_Date,entidad,entorno) a
group by parcel,meas_date,entidad,entorno ) a
where  a.entorno like '%%' or a.entorno is null 
group by a.entidad,a.meas_Date,a.parcel

select parcel,meas_Date,entidad,entorno,meas_date
from DASHBOARD.dbo.UPDATE_AGGRData4G_lcc_aggr_sp_MDD_Data_DL_Thput_CE
where entidad like '%tarragona%'
group by parcel,meas_Date,entidad,entorno,meas_date
