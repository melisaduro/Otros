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
where name in ('FY1718_Data_ALBACETE_4G_H1_1','FY1718_DATA_ALICANTE_4G_H1_1','FY1718_DATA_CASTELLON_4G_H1_1','FY1718_DATA_ELCHE_4G_H1_1','FY1718_DATA_LOGRONO_4G_H1_1','FY1718_DATA_MURCIA_4G_H1_1','FY1718_DATA_PAMPLONA_4G_H1_1','FY1718_DATA_SEVILLA_4G_H1','FY1718_DATA_MADRID_4G_H1','FY1718_DATA_MALAGA_4G_H1','FY1718_VOICE_SEVILLA_4G_H1')


create table #bbddfileid
(
DDBB varchar(256),
Maximo_fileid int
)




declare @id as integer = 1
declare @ddbb as varchar(256)

while @id <= (select max(id) from _ddbb)
begin

set @ddbb = (select name from _ddbb where id=@id)


insert into #bbddfileid
exec ('select ''' + @DDBB + ''',
			max(fileid)
			

	  from ' + @DDBB + '.dbo.filelist
	  

')

set @id = @id + 1

end


select * from #bbddfileid

drop table _ddbb,#bbddfileid

