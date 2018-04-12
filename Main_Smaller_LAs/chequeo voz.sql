
select   
 case when t.entidad like 'AVE-%' or t.entidad like 'MAD-___-R[0-9]%' 
 then  'AVE' 
 else p.entorno 
 end entorno,t.mnc,t.meas_round,t.Date_Reporting as meas_date,
 t.Week_Reporting as meas_week, 
 '3G' as meas_Tech, 
 t.entidad as vf_entity,t.Report_Type,t.Aggr_Type,
 sum(MO_Succeeded + MO_Blocks + MO_Drops + MT_Succeeded + MT_Blocks + MT_Drops) as Num_tests
from [AGGRVoice4G].dbo.[lcc_aggr_sp_MDD_Voice_Llamadas] t
 , agrids.dbo.lcc_parcelas_v2 p
where p.nombre=isnull(t.parcel,'0.00000 Long, 0.00000 Lat')
    and t.entidad='mallorca'
    and t.mnc=1
    and t.meas_round='Fy1617_H1'
 group by 
  case when t.entidad like 'AVE-%' or t.entidad like 'MAD-___-R[0-9]%' 
  then  'AVE' 
  else p.entorno 
  end ,t.mnc,t.meas_round,t.Date_Reporting,t.Week_Reporting,t.entidad,t.Report_Type,t.Aggr_Type
 order by t.meas_round,t.report_type




 --3G VOZ nuevo
select   
t.mnc,t.meas_round,t.Date_Reporting as meas_date,t.Week_Reporting as meas_week, '3G' as meas_Tech, 
	'CE_DL' as Test_type, 'Downlink' as Direction, t.entidad as vf_entity,t.Report_Type,t.Aggr_Type,
	sum(MO_Succeeded + MO_Blocks + MO_Drops + MT_Succeeded + MT_Blocks + MT_Drops) as Num_tests
from [AGGRVoice3G].dbo.lcc_aggr_sp_MDD_Voice_Llamadas t
 , agrids.dbo.vlcc_parcelas_osp p
where p.parcela=isnull(t.parcel,'0.00000 Long, 0.00000 Lat') and t.entidad = 'mallorca'--t.report_type = 'MUN'
group by 
	t.mnc,t.meas_round,t.Date_Reporting,t.Week_Reporting,t.entidad,t.Report_Type,t.Aggr_Type
order by vf_entity, meas_round, meas_date, meas_week