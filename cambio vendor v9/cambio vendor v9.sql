select ran_vendor_or, provincia,count(1) as contador
from agrids_v2.dbo.lcc_ciudades_tipo_project_v9
group by ran_vendor_or, provincia
order by 2


--DISCREPANCIAS

----------
select t1.entity_name,t1.ran_vendor_or as RAN_VENDOR_OR_NEW,t2.ran_vendor_or as RAN_VENDOR_OR_NEW,t1.provincia
from agrids_v2.[dbo].[lcc_ciudades_tipo_project_v9_20180104] t1
inner join agrids_v2.[dbo].[lcc_ciudades_tipo_project_v9] t2
on t1.entity_name=t2.entity_name
where t1.provincia='albacete'
and t1.ran_vendor_or='Huawei'
union
select t1.entity_name,t1.ran_vendor_or as RAN_VENDOR_OR_NEW,t2.ran_vendor_or as RAN_VENDOR_OR_NEW,t1.provincia
from agrids_v2.[dbo].[lcc_ciudades_tipo_project_v9_20180104] t1
inner join agrids_v2.[dbo].[lcc_ciudades_tipo_project_v9] t2
on t1.entity_name=t2.entity_name
where t1.provincia='CACERES'
and t1.ran_vendor_or='Ericsson'
union
select t1.entity_name,t1.ran_vendor_or as RAN_VENDOR_OR_NEW,t2.ran_vendor_or as RAN_VENDOR_OR_NEW,t1.provincia
from agrids_v2.[dbo].[lcc_ciudades_tipo_project_v9_20180104] t1
inner join agrids_v2.[dbo].[lcc_ciudades_tipo_project_v9] t2
on t1.entity_name=t2.entity_name
where t1.provincia='JAEN'
and t1.ran_vendor_or='Ericsson'
union
select t1.entity_name,t1.ran_vendor_or as RAN_VENDOR_OR_NEW,t2.ran_vendor_or as RAN_VENDOR_OR_NEW,t1.provincia
from agrids_v2.[dbo].[lcc_ciudades_tipo_project_v9_20180104] t1
inner join agrids_v2.[dbo].[lcc_ciudades_tipo_project_v9] t2
on t1.entity_name=t2.entity_name
where t1.provincia='TARRAGONA'
and t1.ran_vendor_or='Huawei'
union 
select t1.entity_name,t1.ran_vendor_or as RAN_VENDOR_OR_NEW,t2.ran_vendor_or as RAN_VENDOR_OR_NEW,t1.provincia
from agrids_v2.[dbo].[lcc_ciudades_tipo_project_v9_20180104] t1
inner join agrids_v2.[dbo].[lcc_ciudades_tipo_project_v9] t2
on t1.entity_name=t2.entity_name
where t1.provincia='TERUEL'
and t1.ran_vendor_or='EricssoN'
union
select t1.entity_name,t1.ran_vendor_or as RAN_VENDOR_OR_NEW,t2.ran_vendor_or as RAN_VENDOR_OR_NEW,t1.provincia
from agrids_v2.[dbo].[lcc_ciudades_tipo_project_v9_20180104] t1
inner join agrids_v2.[dbo].[lcc_ciudades_tipo_project_v9] t2
on t1.entity_name=t2.entity_name
where t1.provincia='VALENCIA'
and t1.ran_vendor_or='EricssoN'
order by 3

-----------------UPDATE

-------

update agrids_v2.dbo.lcc_ciudades_tipo_project_v9
set ran_vendor_or='Ericsson'
where provincia='albacete'
and ran_vendor_or='Huawei'

update agrids_v2.dbo.lcc_ciudades_tipo_project_v9
set ran_vendor_or='Huawei'
where provincia='CACERES'
and ran_vendor_or='Ericsson'

update agrids_v2.dbo.lcc_ciudades_tipo_project_v9
set ran_vendor_or='Huawei'
where provincia='JAEN'
and ran_vendor_or='Ericsson'

update agrids_v2.dbo.lcc_ciudades_tipo_project_v9
set ran_vendor_or='Ericsson'
where provincia='TARRAGONA'
and ran_vendor_or='Huawei'

update agrids_v2.dbo.lcc_ciudades_tipo_project_v9
set ran_vendor_or='Huawei'
where provincia='TERUEL'
and ran_vendor_or='EricssoN'

update agrids_v2.dbo.lcc_ciudades_tipo_project_v9
set ran_vendor_or='Huawei'
where provincia='VALENCIA'
and ran_vendor_or='EricssoN'


------Nulos

select *
from agrids_v2.dbo.lcc_ciudades_tipo_project_v9
where ran_vendor_or is null

select ran_vendor_vdf,ran_vendor_mov,ran_vendor_or,provincia,count(1) as contador
from agrids_v2.dbo.lcc_ciudades_tipo_project_v9
group by ran_vendor_vdf,ran_vendor_mov,ran_vendor_or,provincia
order by 4

select * from agrids_v2.dbo.lcc_ciudades_tipo_project_v9
where ran_vendor_vdf='Ericsson'
and provincia='barcelona'

select t1.ran_vendor_vdf,t1.ran_vendor_mov,t1.ran_vendor_or
from agrids_v2.dbo.lcc_ciudades_tipo_project_v9 t1
left join (select * from agrids_v2.dbo.lcc_ciudades_tipo_project_v9
where ran_vendor_vdf is null and ran_vendor_mov is null) t2
on t1.entity_name=t2.entity_name
where t1.provincia='alicante'
group by t1.ran_vendor_vdf,t1.ran_vendor_mov,t1.ran_vendor_or

select t1.ran_vendor_vdf,t1.ran_vendor_mov,t1.ran_vendor_or,entity_name
from agrids_v2.dbo.lcc_ciudades_tipo_project_v9 t1
where entity_name in ('ALICANTE','MALLORCA','BARCELONA','CORDOBA','CORUNA','MADRID','MALAGA','PALMAS','SEVILLA','VALENCIA','BILBAO','ZARAGOZA')
ORDER BY 4

SELECT t1.ran_vendor_vdf,t1.ran_vendor_mov,t1.ran_vendor_or,T2.ENTITY_NAME,T1.ENTITY_NAME
FROM (SELECT * from agrids_v2.dbo.lcc_ciudades_tipo_project_v9 t1
where entity_name in ('ALICANTE','MALLORCA','BARCELONA','CORDOBA','CORUNA','MADRID','MALAGA','PALMAS','SEVILLA','VALENCIA','BILBAO','ZARAGOZA')) T1
INNER JOIN
(SELECT * from agrids_v2.dbo.lcc_ciudades_tipo_project_v9 t1
where ran_vendor_vdf is null and ran_vendor_mov is null) T2
ON T1.PROVINCIA=T2.PROVINCIA

begin transaction
UPDATE agrids_v2.dbo.lcc_ciudades_tipo_project_v9 
SET ran_vendor_vdf=t1.ran_vendor_vdf,ran_vendor_mov=t1.ran_vendor_mov,ran_vendor_or=t1.ran_vendor_or,ran_vendor_yoi=t1.ran_vendor_yoi
FROM (SELECT * from agrids_v2.dbo.lcc_ciudades_tipo_project_v9 t1
where ran_vendor_vdf is null and ran_vendor_mov is null) T2
INNER JOIN
(SELECT * from agrids_v2.dbo.lcc_ciudades_tipo_project_v9 t1
where entity_name in ('ALICANTE','MALLORCA','BARCELONA','CORDOBA','CORUNA','MADRID','MALAGA','PALMAS','SEVILLA','VALENCIA','BILBAO','ZARAGOZA')) T1
ON T1.PROVINCIA=T2.PROVINCIA
where t2.ran_vendor_vdf is null and t2.ran_vendor_mov is null
and t2.provincia='alicante'
and t2.scope='PLACES OF CONCENTRATION'
rollback

SELECT *
FROM agrids_v2.dbo.lcc_ciudades_tipo_project_v9
WHERE ENTITY_NAME IN ('ALI-RLW','ALI-APT')

begin transaction
UPDATE agrids_v2.dbo.lcc_ciudades_tipo_project_v9
SET ran_vendor_vdf=t1.ran_vendor_vdf,ran_vendor_mov=t1.ran_vendor_mov,ran_vendor_or=t1.ran_vendor_or,ran_vendor_yoi=t1.ran_vendor_yoi
from (select ran_vendor_vdf,ran_vendor_mov,ran_vendor_or,ran_vendor_yoi 
from agrids_v2.dbo.lcc_ciudades_tipo_project_v9 t1
where ENTITY_NAME in ('ZARAGOZA')) T1
WHERE ENTITY_NAME IN ('ZAR-RLW')
COMMIT
