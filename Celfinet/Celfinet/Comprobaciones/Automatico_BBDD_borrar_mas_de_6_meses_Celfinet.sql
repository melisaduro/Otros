
if (SELECT @@SERVERNAME)='SREPSQLBMVF'
begin

-- **********************************************************************************************************
--	Almacenamos las BBDD que tienen medidas de hace más de 6 meses
-- **********************************************************************************************************

declare @fecha_6_meses_margen_borrar as varchar (256)=(select CONVERT (date, DATEADD(MM, -6,GETDATE())))


select name, row_number()over( order by name) as id
into #ddbb
from sys.databases
where name like 'FY1617%'


create table #bbdd_eliminar
(
DDBB varchar(256),
starttime datetime
)


declare @id as integer = 1
declare @ddbb as varchar(256)

while @id <= (select max(id) from #ddbb)
	begin

		set @ddbb = (select name from #ddbb where id=@id)
		
		insert into #bbdd_eliminar
		exec ('select ''' + @DDBB + ''' as DDBB, 
			  max(starttime) as starttime
			  from ' + @DDBB + '.dbo.sessions
			  where starttime > '''+@fecha_6_meses_margen_borrar+'''

		')

		set @id = @id + 1

	end


-- **********************************************************************************************************
--	Borramos las BBDD que tienen medidas de hace más de 6 meses
-- **********************************************************************************************************


select DDBB, row_number()over( order by DDBB) as id
into #bbdd_borrado
from #bbdd_eliminar where starttime is null

set @id=1

while @id <= (select max(id) from #bbdd_borrado)
	begin

		set @ddbb = (select DDBB from #bbdd_borrado where id=@id)
		
		print ('drop database ' + @DDBB + '
		')

		set @id = @id + 1

	end

drop table #ddbb, #bbdd_eliminar, #bbdd_borrado

end
else 
select 'ALERT! You can not run this procedure on this server'