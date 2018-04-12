-----------------------------
--Microsoft Excel
-------------------------------
----exec sp_lcc_execute_Procedure_bbdd '%1617_Voice%', '[AGRIDS]', 'sp_entidades_importadas', 'lcc_tabla_Entidades_Importadas'
-------------------------------
--Aceptar   
-----------------------------

exec sp_lcc_execute_Procedure_bbdd_without_results '%1617_Voice_%', 'sp_lcc_alter_vlcc_ChequeoIntegridad_VOZ' 
exec sp_lcc_execute_Procedure_bbdd_without_results '%1617_Data_%', 'sp_lcc_alter_vlcc_ChequeoIntegridad_DATOS'

exec sp_lcc_execute_Procedure_bbdd_without_results '%1617_Voice_%', 'sp_lcc_create_vlcc_ChequeoIntegridad_VOZ' 
exec sp_lcc_execute_Procedure_bbdd_without_results '%1617_Data_%', 'sp_lcc_create_vlcc_ChequeoIntegridad_DATOS'

---- VOZ:
--exec [dbo].[sp_lcc_execute_Procedure_bbdd] 'FY1516_Voice_%4G%', '[VDF_FY1516_PRUEBAS]', 'sp_lcc_create_table_Paging3G4G', 'lcc_tablas_de_Paging34G'

---- DATOS:
--exec [dbo].[sp_lcc_execute_Procedure_bbdd] 'OSP1617_Voice', '[AGRIDS]', 'sp_entidades_importadas', 'lcc_tabla_Entidades_Importadas'


--insert  into lcc_ping_TTL_exceeded_all
--select * 
----into lcc_ping_TTL_exceeded_all
--from lcc_ping_TTL_exceeded


--select * from lcc_ping_TTL_exceeded_all
-----
-- Vacias:
--use FY1516_DATA_Main_4G_Q1_2
--use FY1516_DATA_MRoad_2G

-- select * from filelist





