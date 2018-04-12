/*Denominador*/
SELECT *
  FROM [DASHBOARD].[dbo].[lcc_parcelas_VDF]
  where entidad_contenedora ='linares'


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
where Report_Type = 'VDF'
and entidad=@entidad
and meas_date=@meas_date
group by parcel,meas_Date,entidad,entorno
Union all
select parcel,meas_Date,entidad,entorno
from DASHBOARD.dbo.UPDATE_AGGRData4G_lcc_aggr_sp_MDD_Data_DL_Thput_NC
--where mnc=01
where Report_Type = 'VDF'
and entidad=@entidad
and meas_date=@meas_date
group by parcel,meas_Date,entidad,entorno
Union all
select parcel,meas_Date,entidad,entorno
from DASHBOARD.dbo.UPDATE_AGGRData4G_lcc_aggr_sp_MDD_Data_Ping
--where mnc=01
where Report_Type = 'VDF'
and entidad=@entidad
and meas_date=@meas_date
group by parcel,meas_Date,entidad,entorno 
Union all
select parcel,meas_Date,entidad,entorno
from DASHBOARD.dbo.UPDATE_AGGRData4G_lcc_aggr_sp_MDD_Data_UL_Thput_CE
--where mnc=01
where Report_Type = 'VDF'
and entidad=@entidad
and meas_date=@meas_date
group by parcel,meas_Date,entidad,entorno
union all
select parcel,meas_Date,entidad,entorno
from DASHBOARD.dbo.UPDATE_AGGRData4G_lcc_aggr_sp_MDD_Data_UL_Thput_NC
--where mnc=01
where Report_Type = 'VDF'
and entidad=@entidad
and meas_date=@meas_date
group by parcel,meas_Date,entidad,entorno
union all
select parcel,meas_Date,entidad,entorno
from DASHBOARD.dbo.UPDATE_AGGRData4G_lcc_aggr_sp_MDD_Data_Web
--where mnc=01
where Report_Type = 'VDF'
and entidad=@entidad
and meas_date=@meas_date
group by parcel,meas_Date,entidad,entorno
union all
select parcel,meas_Date,entidad,entorno
from DASHBOARD.dbo.UPDATE_AGGRData4G_lcc_aggr_sp_MDD_Data_Youtube
--where mnc=01
where Report_Type = 'VDF'
and entidad=@entidad
and meas_date=@meas_date
group by parcel,meas_Date,entidad,entorno
union all
select parcel,meas_Date,entidad,entorno
from DASHBOARD.dbo.UPDATE_AGGRData4G_lcc_aggr_sp_MDD_Data_Youtube_HD
--where mnc=01
where Report_Type = 'VDF'
and entidad=@entidad
and meas_date=@meas_date
group by parcel,meas_Date,entidad,entorno) a
group by parcel,meas_date,entidad,entorno ) a
where  a.entorno like '%%' or a.entorno is null 
group by a.entidad,a.meas_Date,a.parcel



