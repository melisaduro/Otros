
use [FY1718_VOICE_BURGOS_4G_H1]		

-- VOZ:
exec [dbo].[sp_lcc_core_Master_Table]
exec [dbo].[sp_lcc_core_GRID_Table] 'AGRIDS_v2', 'lcc_G2K5Absolute_INDEX_new', 1
exec [dbo].[sp_lcc_core_Voice_Create_Views]

--exec [dbo].[sp_lcc_core_Voice_Metrics_TimeStamp_Table]
--exec [dbo].[sp_lcc_core_Voice_Metrics_Table]
exec [dbo].[sp_lcc_core_Voice_Metrics_TimeStamp_Table_PdteACT]
exec [dbo].[sp_lcc_core_Voice_Metrics_Table_PdteACT]

exec [dbo].[sp_lcc_core_Voice_CST_KPIs_Table]

exec [dbo].[sp_lcc_core_Voice_MOS_Table]
exec [dbo].[sp_lcc_core_Voice_Radio_Session_Table]
exec [dbo].[sp_lcc_core_Voice_ServingCell_Session_Table_Dial2Discon]

exec [dbo].[sp_lcc_core_Voice_CEM_KPIs_Metrics_Table]
exec [dbo].[sp_lcc_core_Voice_CR_Metrics_Table]
exec [dbo].[sp_lcc_core_Voice_FR_Metrics_Table]


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