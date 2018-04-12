select count(1),a.entidad,a.Meas_Date,entorno
	from aggrdata4G.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_CE a
						left outer join agrids.dbo.lcc_parcelas_OLD b
						on a.parcel=b.nombre
	where Report_Type = 'VDF'
	and a.entidad='barcelona'
	and a.meas_date='17_01'
	group by a.entidad,a.Meas_Date,entorno

select count(1),a.entidad,a.Meas_Date,entorno
	from aggrdata4G.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_CE a
						left outer join agrids.dbo.lcc_parcelas b
						on a.parcel=b.nombre
	where Report_Type = 'VDF'
	and a.entidad='barcelona'
	and a.meas_date='17_01'
	group by a.entidad,a.Meas_Date,entorno

select count(1),a.entidad,a.Meas_Date
	from aggrdata4G.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_CE a
						left outer join agrids.dbo.lcc_parcelas_OLD b
						on a.parcel=b.nombre
	where Report_Type = 'VDF'
	and a.entidad='barcelona'
	and a.meas_date='17_01'
	group by a.entidad,a.Meas_Date

select count(1),a.entidad,a.Meas_Date
	from aggrdata4G.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_CE a
						left outer join agrids.dbo.lcc_parcelas b
						on a.parcel=b.nombre
	where Report_Type = 'VDF'
	and a.entidad='barcelona'
	and a.meas_date='17_01'
	group by a.entidad,a.Meas_Date