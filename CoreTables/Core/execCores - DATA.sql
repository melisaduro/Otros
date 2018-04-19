
use [FY1718_DATA_BURGOS_4G_H1]

-- DATOS:
exec [dbo].[sp_lcc_core_Master_Table]
exec [dbo].[sp_lcc_core_GRID_Table] 'AGRIDS_v2', 'lcc_G2K5Absolute_INDEX_new', 1

exec [dbo].[sp_lcc_core_Data_DL_Capacity_Test_Table_IPThput_Detailed_10s]
exec [dbo].[sp_lcc_core_Data_DL_Capacity_Test_Table_KPIs]
exec [dbo].[sp_lcc_core_Data_DL_Capacity_Test_Table_Metrics]

exec [dbo].[sp_lcc_core_Data_DL_HTTPTransfer_Test_Table_IPThput_Detailed_10s]
exec [dbo].[sp_lcc_core_Data_DL_HTTPTransfer_Test_Table_KPIs]
exec [dbo].[sp_lcc_core_Data_DL_HTTPTransfer_Test_Table_Metrics]

exec [dbo].[sp_lcc_core_Data_UL_Capacity_Test_Table_IPThput_Detailed_10s]
exec [dbo].[sp_lcc_core_Data_UL_Capacity_Test_Table_KPIs]
exec [dbo].[sp_lcc_core_Data_UL_Capacity_Test_Table_Metrics]

exec [dbo].[sp_lcc_core_Data_UL_HTTPTransfer_Test_Table_IPThput_Detailed_10s]
exec [dbo].[sp_lcc_core_Data_UL_HTTPTransfer_Test_Table_KPIs]
exec [dbo].[sp_lcc_core_Data_UL_HTTPTransfer_Test_Table_Metrics]

exec [dbo].[sp_lcc_core_Data_Browser_HTTP_Test_Table_KPIs]
exec [dbo].[sp_lcc_core_Data_Browser_HTTP_Test_Table_Metrics]
exec [dbo].[sp_lcc_core_Data_Browser_HTTPS_Test_Table_KPIs]
exec [dbo].[sp_lcc_core_Data_Browser_HTTPS_Test_Table_Metrics]

exec [dbo].[sp_lcc_core_Data_Youtube_Test_Table_KPIs]
exec [dbo].[sp_lcc_core_Data_Youtube_Test_Table_Metrics]

exec [dbo].[sp_lcc_core_Data_Ping_Test_Table_KPIs]
exec [dbo].[sp_lcc_core_Data_Ping_Test_Table_Metrics]

exec [dbo].[sp_lcc_core_Data_Radio_Test_Table]
exec [dbo].[sp_lcc_core_Data_LTE_Tech]


--+++++++++++++++++++++++++++++++++++++++++++++++++++
exec sp_lcc_aggregation_detail2_0_fullDatabase
--+++++++++++++++++++++++++++++++++++++++++++++++++++

---------------------------------------
-- BORRAMOS CORE una vez aggr:
drop table #tables
select identity(int,1,1) id, name 
into #tables
from sys.tables 
where name like '%lcc_core_%' 
order by name

select * from #tables 

---------------------------------------
declare @table as varchar(256)
declare @it as int=1

while @it<= (select max(id) from  #tables)
begin
	set @table=(select name from #tables where id=@it)
	exec(
	'
	exec sp_lcc_dropifexists '+@table+'
	')

	set @it=@it+1
end -- while

--drop table #db