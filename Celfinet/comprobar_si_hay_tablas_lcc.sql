--select 
--	case
--		when count (1) > 1 then 'Si'
--		else 'No' end as 'Limpiar',
--	case 
--		when count (1) > 1 then count (1)
--		else '' end as contador
--from FY1617_Data_Rest_3G_H2_4.sys.tables
--where name like '%lcc%'


select name, row_number()over( order by name) as id
into _ddbb
from sys.databases
where name like 'FY1617%'


create table _bbdd_eliminar
(
DDBB varchar(256),
Limpiar varchar (30)
)


declare @id as integer = 1
declare @ddbb as varchar(256)

while @id < (select max(id) from _ddbb)
begin

set @ddbb = (select name from _ddbb where id=@id)

--Recorremos dinámicamente todas las BBDD para saber cuáles CST son mayores de 15seg.

insert into _bbdd_eliminar
exec ('select 
			''' + @DDBB + ''' as DDBB, 
			case
				when count (1) > 1 then ''Si''
				else ''No'' 
			end as ''Limpiar''

	  from ' + @DDBB + '.sys.tables
	  where name like ''%lcc%''

')

set @id = @id + 1

end


select * from _bbdd_eliminar where limpiar='Si'

drop table _ddbb, _bbdd_eliminar