

select name, row_number()over( order by name) as id
into _ddbb
from sys.databases
where name like 'FY1617%'


create table _bbdd_eliminar
(
DDBB varchar(256),
starttime datetime
)


declare @id as integer = 1
declare @ddbb as varchar(256)

while @id < (select max(id) from _ddbb)
begin

set @ddbb = (select name from _ddbb where id=@id)

--Recorremos din�micamente todas las BBDD para saber cu�les CST son mayores de 15seg.

insert into _bbdd_eliminar
exec ('select ''' + @DDBB + ''' as DDBB, 
	  max(starttime) as starttime
	  from ' + @DDBB + '.dbo.sessions
	  where starttime > ''2016-10-19''

')

set @id = @id + 1

end


select * from _bbdd_eliminar

drop table _ddbb, _bbdd_eliminar