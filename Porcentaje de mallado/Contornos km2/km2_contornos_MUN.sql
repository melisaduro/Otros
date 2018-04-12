
/*Denominador*/
select a.nombre,a.entidad_contenedora, count(a.nombre) as total_parcelas, 
		count(a.entidad_contenedora)*0.25*0.25 as [AreaTotal(km2)],
		a.entorno
from agrids.dbo.lcc_parcelas a
where a.entidad_contenedora='albacete'
and a.entorno in ('MAIN','SMALLER','ADDON','TOURISTIC','ROC')
group by a.nombre,a.entidad_contenedora,a.entorno

/*Denominador_2*/
select m.provincia, parcel_500,entorno
from agrids_v2.dbo.lcc_G2K5Absolute_INDEX_new m, agrids.dbo.lcc_parcelas p
where road is null
and p.nombre=m.parcel_500
and municipio='cordoba'
and entorno in ('MAIN','SMALLER','ADDON','TOURISTIC','ROC')
group by m.provincia, parcel_500,entorno

/*Numerador*/
declare @entidad as varchar(256)='cordoba'
declare @meas_date as varchar(256)='17_01'

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
where Report_Type = 'MUN'
and entidad=@entidad
and meas_date=@meas_date
group by parcel,meas_Date,entidad,entorno
Union all
select parcel,meas_Date,entidad,entorno
from DASHBOARD.dbo.UPDATE_AGGRData4G_lcc_aggr_sp_MDD_Data_DL_Thput_NC
--where mnc=01
where Report_Type = 'MUN'
and entidad=@entidad
and meas_date=@meas_date
group by parcel,meas_Date,entidad,entorno
Union all
select parcel,meas_Date,entidad,entorno
from DASHBOARD.dbo.UPDATE_AGGRData4G_lcc_aggr_sp_MDD_Data_Ping
--where mnc=01
where Report_Type = 'MUN'
and entidad=@entidad
and meas_date=@meas_date
group by parcel,meas_Date,entidad,entorno 
Union all
select parcel,meas_Date,entidad,entorno
from DASHBOARD.dbo.UPDATE_AGGRData4G_lcc_aggr_sp_MDD_Data_UL_Thput_CE
--where mnc=01
where Report_Type = 'MUN'
and entidad=@entidad
and meas_date=@meas_date
group by parcel,meas_Date,entidad,entorno
union all
select parcel,meas_Date,entidad,entorno
from DASHBOARD.dbo.UPDATE_AGGRData4G_lcc_aggr_sp_MDD_Data_UL_Thput_NC
--where mnc=01
where Report_Type = 'MUN'
and entidad=@entidad
and meas_date=@meas_date
group by parcel,meas_Date,entidad,entorno
union all
select parcel,meas_Date,entidad,entorno
from DASHBOARD.dbo.UPDATE_AGGRData4G_lcc_aggr_sp_MDD_Data_Web
--where mnc=01
where Report_Type = 'MUN'
and entidad=@entidad
and meas_date=@meas_date
group by parcel,meas_Date,entidad,entorno
union all
select parcel,meas_Date,entidad,entorno
from DASHBOARD.dbo.UPDATE_AGGRData4G_lcc_aggr_sp_MDD_Data_Youtube
--where mnc=01
where Report_Type = 'MUN'
and entidad=@entidad
and meas_date=@meas_date
group by parcel,meas_Date,entidad,entorno
union all
select parcel,meas_Date,entidad,entorno
from DASHBOARD.dbo.UPDATE_AGGRData4G_lcc_aggr_sp_MDD_Data_Youtube_HD
--where mnc=01
where Report_Type = 'MUN'
and entidad=@entidad
and meas_date=@meas_date
group by parcel,meas_Date,entidad,entorno) a
group by parcel,meas_date,entidad,entorno ) a
where  a.entorno like '%%' or a.entorno is null 
group by a.entidad,a.meas_Date,a.parcel



