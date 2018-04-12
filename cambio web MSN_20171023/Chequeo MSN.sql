SELECT t1.ENTIDAD, SUM(t1.NAVEGACIONES) as navegaciones_WEB_nueva,SUM(t1.[NAVEGACIONES PUBLIC]) as navegaciones_public_nueva,SUM(t2.NAVEGACIONES) as navegaciones_web_antigua,SUM(t2.[NAVEGACIONES PUBLIC]) as navegaciones_public_antigua,count(t1.parcel),count(t2.parcel)
FROM FY1617_TEST_CECI.DBO.lcc_aggr_sp_MDD_Data_Web_sin_MSN_sin_MSN_3G t1 
inner join aggrdata3g.DBO.lcc_aggr_sp_MDD_Data_Web_3G t2
on t1.entidad=t2.entidad
and t1.parcel=t2.parcel
and t1.report_type=t2.report_type
and t1.mnc=t2.mnc
and t1.meas_round=t2.meas_round
and t1.date_reporting=t2.date_reporting
and t1.week_reporting=t2.week_reporting
group by t1.ENTIDAD


SELECT t1.ENTIDAD,SUM(t1.NAVEGACIONES) as navegaciones_WEB_nueva,SUM(t1.[NAVEGACIONES PUBLIC]) as navegaciones_public_nueva,SUM(t2.NAVEGACIONES) as navegaciones_web_antigua,SUM(t2.[NAVEGACIONES PUBLIC]) as navegaciones_public_antigua
FROM FY1617_TEST_CECI.DBO.lcc_aggr_sp_MDD_Data_Web_sin_MSN t1 
inner join aggrdata3g.DBO.lcc_aggr_sp_MDD_Data_Web t2
on t1.entidad=t2.entidad
and t1.parcel=t2.parcel
and t1.report_type=t2.report_type
and t1.mnc=t2.mnc
and t1.meas_round=t2.meas_round
and t1.date_reporting=t2.date_reporting
and t1.week_reporting=t2.week_reporting
group by t1.ENTIDAD

select date_reporting,week_reporting,meas_date,meas_week from aggrdata3g.DBO.lcc_aggr_sp_MDD_Data_Web 
where entidad='carreno'
and report_type='mun'
and meas_round like '%1718%'

update FY1617_TEST_CECI.DBO.lcc_aggr_sp_MDD_Data_Web_sin_MSN_sin_MSN_3G 
set week_reporting='W35'
where entidad='carreno'
and report_type='mun'
and meas_round like '%1718%'

SELECT t1.ENTIDAD, SUM(t1.NAVEGACIONES) as navegaciones_WEB_nueva,SUM(t1.[NAVEGACIONES PUBLIC]) as navegaciones_public_nueva,SUM(t2.NAVEGACIONES) as navegaciones_web_antigua,SUM(t2.[NAVEGACIONES PUBLIC]) as navegaciones_public_antigua
FROM FY1617_TEST_CECI.DBO.lcc_aggr_sp_MDD_Data_Web_sin_MSN_sin_MSN_3G t1 
inner join aggrdata3g.DBO.lcc_aggr_sp_MDD_Data_Web_3G t2
on t1.entidad=t2.entidad
and t1.parcel=t2.parcel
and t1.report_type=t2.report_type
and t1.mnc=t2.mnc
and t1.meas_round=t2.meas_round
group by t1.ENTIDAD

SELECT ENTIDAD,SUM(NAVEGACIONES),SUM([NAVEGACIONES PUBLIC])
FROM FY1617_TEST_CECI.DBO.lcc_aggr_sp_MDD_Data_Web_sin_MSN_sin_MSN_3G
group by ENTIDAD

select ENTIDAD,SUM(NAVEGACIONES),SUM([NAVEGACIONES PUBLIC])
FROM aggrdata3g.DBO.lcc_aggr_sp_MDD_Data_Web_3g
group by ENTIDAD

select [database],entidad,meas_round,meas_date,sum(navegaciones) as navegciones,sum([navegaciones public]) as publicas
from aggrdata3g.dbo.lcc_aggr_sp_MDD_Data_Web
where report_type='MUN'
and meas_round like '%1718%'
group by [database],entidad,meas_round,meas_date
order by 1

use FY1718_DATA_ALBACETE_3G_H1
select entidad, sum ([navegaciones msn]) from (
select [master].dbo.fn_lcc_getElement(4, collectionname,'_') as entidad,count(1) as [navegaciones msn]
from Lcc_Data_HTTPBrowser b, testinfo t
where b.testid=t.testid
and t.valid=1
and b.testtype ='MSN'
group by collectionname) t
group by entidad