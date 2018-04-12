--select t.*, p.entorno
----into Dashboard.dbo.lcc_parcelas_MUN
--from  Dashboard.dbo.lcc_parcelas_OSP t, AGRIDS.dbo.lcc_parcelas p
--where t.Nombre=p.Nombre  
--and t.entidad_contenedora='cartagena'
--group by t.entidad_contenedora,t.nombre,p.entorno

select *
from  Dashboard.dbo.lcc_parcelas_osp
where entidad_contenedora='castellon'


/*Numerador*/

declare @entidad as varchar(256)='DURANGO'
declare @meas_date as varchar(256)='16_12'
declare @report_type as varchar(256)='MUN'

select
a.entidad,
a.parcel,
count(a.entidad) as Parcelas,
count(a.entidad)*0.25 as [Area(km2)],
a.Meas_date    
from(
select a.parcel, a.meas_date, a.entidad
from 
(select parcel,meas_Date,entidad
from AGGRData4G.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_CE
--where mnc=01
where Report_Type = @Report_type
and entidad=@entidad
and meas_date=@meas_date
group by parcel,meas_Date,entidad
Union all
select parcel,meas_Date,entidad
from AGGRData4G.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_NC
--where mnc=01
where Report_Type = @Report_type
and entidad=@entidad
and meas_date=@meas_date
group by parcel,meas_Date,entidad
Union all
select parcel,meas_Date,entidad
from AGGRData4G.dbo.lcc_aggr_sp_MDD_Data_Ping
--where mnc=01
where Report_Type = @Report_type
and entidad=@entidad
and meas_date=@meas_date
group by parcel,meas_Date,entidad 
Union all
select parcel,meas_Date,entidad
from AGGRData4G.dbo.lcc_aggr_sp_MDD_Data_UL_Thput_CE
--where mnc=01
where Report_Type = @Report_type
and entidad=@entidad
and meas_date=@meas_date
group by parcel,meas_Date,entidad
union all
select parcel,meas_Date,entidad
from AGGRData4G.dbo.lcc_aggr_sp_MDD_Data_UL_Thput_NC
--where mnc=01
where Report_Type = @Report_type
and entidad=@entidad
and meas_date=@meas_date
group by parcel,meas_Date,entidad
union all
select parcel,meas_Date,entidad
from AGGRData4G.dbo.lcc_aggr_sp_MDD_Data_Web
--where mnc=01
where Report_Type = @Report_type
and entidad=@entidad
and meas_date=@meas_date
group by parcel,meas_Date,entidad
union all
select parcel,meas_Date,entidad
from AGGRData4G.dbo.lcc_aggr_sp_MDD_Data_Youtube
--where mnc=01
where Report_Type = @Report_type
and entidad=@entidad
and meas_date=@meas_date
group by parcel,meas_Date,entidad
union all
select parcel,meas_Date,entidad
from AGGRData4G.dbo.lcc_aggr_sp_MDD_Data_Youtube_HD
--where mnc=01
where Report_Type = @Report_type
and entidad=@entidad
and meas_date=@meas_date
group by parcel,meas_Date,entidad) a, dashboard.dbo.lcc_parcelas_VDF p
where a.parcel=p.nombre and a.entidad=p.entidad_contenedora
group by parcel,meas_date,entidad ) a
group by a.entidad,a.meas_Date,a.parcel




