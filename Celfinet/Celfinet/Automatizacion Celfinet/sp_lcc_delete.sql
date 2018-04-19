USE [master]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[sp_lcc_delete]
as

-- Para hacer el procedimiento de sistema:
--exec sys.sp_MS_marksystemobject 'sp_lcc_delete'

-- **********************************************************************************************************
--	Eliminaremos todas las bases de datos del servidor una vez ya estén importadas en VO
-- **********************************************************************************************************


if (SELECT @@SERVERNAME)='SREPSQLBMVF'
begin

-- **********************************************************************************************************
--	Almacenamos todas las BBDD del servidor
-- **********************************************************************************************************


select name, row_number()over( order by name) as id
into #ddbb
from sys.databases
where name like 'FY%'


declare @id as integer = 1
declare @ddbb as varchar(256)


-- **********************************************************************************************************
--	Borramos las BBDD que tienen medidas de hace más de 6 meses
-- **********************************************************************************************************

while @id <= (select max(id) from #ddbb)
	begin

		set @ddbb = (select name from #ddbb where id=@id)
		
		exec ('drop database ' + @ddbb + '
		')

		set @id = @id + 1

	end

drop table #ddbb

end
else 
select 'ALERT! You can not run this procedure on this server'