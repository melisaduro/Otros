
--select t.*, p.entorno
----into Dashboard.dbo.lcc_parcelas_MUN
--from  Dashboard.dbo.lcc_parcelas_OSP t, AGRIDS.dbo.lcc_parcelas p
--where t.Nombre=p.Nombre  
--and t.entidad_contenedora='cartagena'
--group by t.entidad_contenedora,t.nombre,p.entorno

--select * 
--into lcc_parcelas_OSP_20170925_con_pi
--from lcc_parcelas_OSP_20170925

--insert into lcc_parcelas_OSP_20170925_con_pi
--select entidad_contenedora,nombre from lcc_parcelas_OSP_poligono_industrial

drop table lcc_km2_totales
drop table lcc_km2_medidos
drop table lcc_km2_chequeo_mallado

--select * from lcc_parcelas_OSP_20170925_con_pi t1
--inner join lcc_parcelas_OSP_poligono_industrial t2
--on t1.entidad_contenedora=t2.entidad_contenedora
--and t1.nombre=t2.nombre
--where t1.entidad_contenedora='barcelona'

select  t.Entidad_contenedora,
count(t.total_parcelas) as total_parcelas
into lcc_km2_totales
from (
select  a.Entidad_contenedora,
count(a.nombre) as total_parcelas
--into lcc_km2_totales
from  Dashboard.dbo.lcc_parcelas_OSP_backup_2 a
group by a.entidad_contenedora,a.nombre) t
group by t.Entidad_contenedora


/*Numerador*/

select
a.entidad,
count(a.parcel) as Parcelas 
into lcc_km2_medidos
from(
select a.parcel, a.entidad,meas_round
from 
(select parcel,entidad,meas_round
			from AGGRData4G.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_CE
			where Report_Type = 'mun'
			and meas_round='FY1617_H2'
			group by parcel,entidad,meas_round
		Union all
			select parcel,entidad,meas_round
			from AGGRData4G.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_NC
			where Report_Type = 'mun'
			and meas_round='FY1617_H2'
			
			group by parcel,entidad,meas_round
		Union all
			select parcel,entidad,meas_round
			from AGGRData4G.dbo.lcc_aggr_sp_MDD_Data_Ping
			where Report_Type = 'mun'
			and meas_round='FY1617_H2'
			
			group by parcel,entidad,meas_round
		Union all
			select parcel,entidad,meas_round
			from AGGRData4G.dbo.lcc_aggr_sp_MDD_Data_UL_Thput_CE
			where Report_Type = 'mun'
			and meas_round='FY1617_H2'
			
			group by parcel,entidad,meas_round
		union all
			select parcel,entidad,meas_round
			from AGGRData4G.dbo.lcc_aggr_sp_MDD_Data_UL_Thput_NC
			where Report_Type = 'mun'
			and meas_round='FY1617_H2'
			
			group by parcel,entidad,meas_round
		union all
			select parcel,entidad,meas_round
			from AGGRData4G.dbo.lcc_aggr_sp_MDD_Data_Web
			where Report_Type = 'mun'
			
			group by parcel,entidad,meas_round
		union all
			select parcel,entidad,meas_round
			from AGGRData4G.dbo.lcc_aggr_sp_MDD_Data_Youtube
			where Report_Type = 'mun'
			and meas_round='FY1617_H2'
			
			group by parcel,entidad,meas_round
		union all
			select parcel,entidad,meas_round
			from AGGRData4G.dbo.lcc_aggr_sp_MDD_Data_Youtube_HD
			where Report_Type = 'mun'
			and meas_round='FY1617_H2'
			
			group by parcel,entidad,meas_round
		
		UNION ALL
			select parcel,entidad,meas_round
			from AGGRDATA3G.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_CE
			where Report_Type = 'mun'
			and meas_round='FY1617_H2'
			
			group by parcel,entidad,meas_round
		Union all
			select parcel,entidad,meas_round
			from AGGRDATA3G.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_NC
			where Report_Type = 'mun'
			and meas_round='FY1617_H2'
			
			group by parcel,entidad,meas_round
		Union all
			select parcel,entidad,meas_round
			from AGGRDATA3G.dbo.lcc_aggr_sp_MDD_Data_Ping
			where Report_Type = 'mun'
			and meas_round='FY1617_H2'
			
			group by parcel,entidad,meas_round
		Union all
			select parcel,entidad,meas_round
			from AGGRDATA3G.dbo.lcc_aggr_sp_MDD_Data_UL_Thput_CE
			where Report_Type = 'mun'
			and meas_round='FY1617_H2'
			
			group by parcel,entidad,meas_round
		union all
			select parcel,entidad,meas_round
			from AGGRDATA3G.dbo.lcc_aggr_sp_MDD_Data_UL_Thput_NC
			where Report_Type = 'mun'
			and meas_round='FY1617_H2'
			
			group by parcel,entidad,meas_round
		union all
			select parcel,entidad,meas_round
			from AGGRDATA3G.dbo.lcc_aggr_sp_MDD_Data_Web
			where Report_Type = 'mun'
			
			group by parcel,entidad,meas_round
		union all
			select parcel,entidad,meas_round
			from AGGRDATA3G.dbo.lcc_aggr_sp_MDD_Data_Youtube
			where Report_Type = 'mun'
			and meas_round='FY1617_H2'
			
			group by parcel,entidad,meas_round
		union all
			select parcel,entidad,meas_round
			from AGGRDATA3G.dbo.lcc_aggr_sp_MDD_Data_Youtube_HD
			where Report_Type = 'mun'
			and meas_round='FY1617_H2'
			
			group by parcel,entidad,meas_round
		) a, dashboard.dbo.lcc_parcelas_OSP_backup_2 p
where a.parcel=p.nombre and a.entidad=p.entidad_contenedora
and meas_round='FY1617_H2'
group by parcel,entidad,meas_round ) a
group by a.entidad



select m.Entidad,
	p.ine,
	p.scope,
	(m.Parcelas*1.0/t.total_parcelas)*100 as [Porcentaje_medido]

into lcc_km2_chequeo_mallado
from
lcc_km2_medidos m, lcc_km2_totales t, agrids_v2.dbo.lcc_ciudades_tipo_project_v9 p
where m.Entidad = t.Entidad_contenedora
and m.entidad=p.entity_name
and t.Entidad_contenedora=p.entity_name

select * from lcc_km2_chequeo_mallado

order by 4 asc




