-- Limite de 6 meses
declare @fecha_6_meses_margen_borrar as varchar (256)=(select CONVERT (date, DATEADD(MM, -6,GETDATE())))

-- Limite de 5 meses y medio
--declare @fecha_6_meses_margen_borrar as varchar (256)=(select convert(date, DATEADD(DD, -15,CONVERT (date, DATEADD(MM, -6,GETDATE())))))

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

--Recorremos dinámicamente todas las BBDD para saber cuáles CST son mayores de 15seg.

insert into _bbdd_eliminar
exec ('select ''' + @DDBB + ''' as DDBB, 
	  max(starttime) as starttime
	  from ' + @DDBB + '.dbo.sessions
	  where starttime > '''+@fecha_6_meses_margen_borrar+'''

')

set @id = @id + 1

end


select * from _bbdd_eliminar where starttime is null

drop table _ddbb, _bbdd_eliminar