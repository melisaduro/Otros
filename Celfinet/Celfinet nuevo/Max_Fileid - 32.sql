--		when count (1) > 1 then count (1)
--		else '' end as contador
--from FY1617_Data_Rest_3G_H2_4.sys.tables
--where name like '%lcc%'


select name, row_number()over( order by name) as id
into _ddbb
from sys.databases
where name like 'FY1617%'
and name not like '%Coverage%'
and name not like '%prueba%'
and name not like '%backup%'
and name not like '%qatar%'
and name not like '%greece%'
and name not like '%localizacion%'
and name not like '%serbia%'
and name not like '%test%'
and name not like '%scn%'
and name not like '%scan%'

create table #bbddfileid
(
DDBB varchar(256),
maximo_fileid int
)




declare @id as integer = 1
declare @ddbb as varchar(256)

while @id <= (select max(id) from _ddbb)
begin

set @ddbb = (select name from _ddbb where id=@id)

--Recorremos dinámicamente todas las BBDD para saber cuáles CST son mayores de 15seg.

insert into #bbddfileid
exec ('select ''' + @DDBB + ''',
			max(fileid)
			

	  from ' + @DDBB + '.dbo.filelist
	  

')

set @id = @id + 1

end


select * from #bbddfileid

drop table _ddbb,#bbddfileid