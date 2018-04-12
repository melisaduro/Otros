
--- 'ELCHE'
 
use [FY1617_Data_SMALLER_3G_H1]


SELECT [Collectionname]
,[MeasDate]
,[Entity_name]
,[Type], count(1)
FROM [FY1617_Data_Smaller_3G_H1].[dbo].[lcc_position_Entity_List_Orange]
where entity_name = 'AVE-Santiago-Orense-R2'
	--and [Collectionname] in ('20160914_RW_INDOOR_OLM-ZAM-R2_4_4G','20160913_RW_INDOOR_OLM-ZAM-R2_3_4G')
group by [Collectionname]
,[MeasDate]
,[Entity_name]
,[Type]


--BACKUP

select *
into [FY1617_Data_AVE_Rest_H1].[dbo].[lcc_position_Entity_List_Orange_backup]
from [FY1617_Data_AVE_Rest_H1].[dbo].[lcc_position_Entity_List_Orange] 

--Asegurando que esas posiciones son las que me dan los test de mas ( en proc de agregado ver cada testid q [Collectionname]
-- tiene en la tabla de contorno)

begin transaction
select * from [FY1617_Data_AVE_Rest_H1].[dbo].[lcc_position_Entity_List_Orange]
where entity_name = 'AVE-Santiago-Orense-R2' 
and lonid in ('-13927') and latid IN ('95344')--Test DL_NC MOVISTAR
commit 

begin transaction
delete [FY1617_Data_AVE_Rest_H1].[dbo].[lcc_position_Entity_List_Orange]
where entity_name = 'AVE-Santiago-Orense-R2'
and lonid in ('-13281') and latid in ('94638') -- Test UL_NC YOIGO
COMMIT



--Agregamos

--Insertamos lo borrado (no haria falta)
--insert into [FY1617_Data_AVE_Rest_H1].[dbo].[lcc_position_Entity_List_Orange]
--select *
--from [FY1617_Data_AVE_Rest_H1].[dbo].[lcc_position_Entity_List_Orange_backup]
--where entity_name = 'AVE-Santiago-Orense-R2'
--and [Collectionname] in ('20160914_RW_INDOOR_OLM-ZAM-R2_4_4G','20160913_RW_INDOOR_OLM-ZAM-R2_3_4G')

