
--- 'AVE-SANTIAGO-ORENSE-R2'
select *
FROM [FY1617_Data_AVE_Rest_H1].[dbo].[lcc_position_Entity_List_Orange]


SELECT [Collectionname]
,[MeasDate]
,[Entity_name]
,[Type], count(1)
FROM [FY1617_Data_AVE_Rest_H1].[dbo].[lcc_position_Entity_List_Orange]
where entity_name = 'AVE-Madrid-Valladolid-R2'
	and [Collectionname] in ('20160914_RW_INDOOR_OLM-ZAM-R2_4_4G','20160913_RW_INDOOR_OLM-ZAM-R2_3_4G')
group by [Collectionname]
,[MeasDate]
,[Entity_name]
,[Type]


--BACKUP
begin transaction
select *
into [FY1617_Data_AVE_Rest_H1].[dbo].[lcc_position_Entity_List_Orange_backup]
from [FY1617_Data_AVE_Rest_H1].[dbo].[lcc_position_Entity_List_Orange]

--Asegurando que esas posiciones son las que me dan los test de mas ( en proc de agregado ver cada testid q [Collectionname]
-- tiene en la tabla de contorno)
delete [FY1617_Data_AVE_Rest_H1].[dbo].[lcc_position_Entity_List_Orange]
where entity_name = 'AVE-Madrid-Valladolid-R2'
and [Collectionname] in ('20160914_RW_INDOOR_OLM-ZAM-R2_4_4G','20160913_RW_INDOOR_OLM-ZAM-R2_3_4G')

COMMIT

--Agregamos

--Insertamos lo borrado (no haria falta)
insert into [FY1617_Data_AVE_Rest_H1].[dbo].[lcc_position_Entity_List_Orange]
select *
from [FY1617_Data_AVE_Rest_H1].[dbo].[lcc_position_Entity_List_Orange_backup]
where entity_name = 'AVE-Madrid-Valladolid-R2'
and [Collectionname] in ('20160914_RW_INDOOR_OLM-ZAM-R2_4_4G','20160913_RW_INDOOR_OLM-ZAM-R2_3_4G')

