BEGIN TRANSACTION

select   
 case when t.entidad like 'AVE-%' or t.entidad like 'MAD-___-R[0-9]%' 
 then  'AVE' 
 else p.entorno 
 end entorno,t.mnc,t.meas_round,t.Date_Reporting as meas_date,
 t.Week_Reporting as meas_week, 
 '43' as meas_Tech, 
 'CE_DL' as Test_type, 
 'Downlink' as Direction, 
 t.entidad as vf_entity,t.Report_Type,t.Aggr_Type,
 sum(navegaciones) as Num_tests
from [AGGRData3G].dbo.[lcc_aggr_sp_MDD_Data_DL_Thput_CE] t
        left outer join [AGGRData3G].[dbo].[lcc_aggr_sp_MDD_Data_DL_Performance_CE] pf
  on isnull(t.parcel,'0.00000 Long, 0.00000 Lat')=isnull(pf.parcel,'0.00000 Long, 0.00000 Lat') 
  and t.mnc=pf.mnc 
  and t.Date_Reporting=pf.Date_Reporting 
  and t.entidad=pf.entidad 
  and t.Aggr_Type=pf.Aggr_Type 
  and t.Report_Type=pf.Report_Type 
  and t.meas_round=pf.meas_round 
  left outer join [AGGRData3G].[dbo].[lcc_aggr_sp_MDD_Data_DL_Technology_CE] te
        on isnull(t.parcel,'0.00000 Long, 0.00000 Lat')=isnull(te.parcel,'0.00000 Long, 0.00000 Lat') 
		and t.mnc=te.mnc and t.Date_Reporting=te.Date_Reporting 
		and t.entidad=te.entidad and t.Aggr_Type=te.Aggr_Type 
		and t.Report_Type=te.Report_Type 
		and t.meas_round=te.meas_round
 , agrids.dbo.lcc_parcelas_v2 p
where p.nombre=isnull(t.parcel,'0.00000 Long, 0.00000 Lat')
    and t.entidad='TIAS'
    and t.mnc=1
    and t.meas_round='Fy1617_H1'
 group by 
  case when t.entidad like 'AVE-%' or t.entidad like 'MAD-___-R[0-9]%' 
  then  'AVE' 
  else p.entorno 
  end ,t.mnc,t.meas_round,t.Date_Reporting,t.Week_Reporting,t.entidad,t.Report_Type,t.Aggr_Type
 order by t.meas_round,t.report_type,sum(t.navegaciones)