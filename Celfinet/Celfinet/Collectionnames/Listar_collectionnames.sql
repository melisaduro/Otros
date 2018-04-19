
use master
if (select name from sys.all_objects where type='u' and name='lcc_iterator') is not null drop table lcc_iterator
if (select name from sys.all_objects where type='u' and name='lcc_Result') is not null drop table lcc_Result

create table lcc_result
(
  ddbb   varchar(255) not null,
  collectionname   varchar(255) null

) on [primary]

select identity(int,1,1) id,name 
into lcc_iterator
from sys.databases

declare @it int=1
declare @cmd varchar(max)
declare @ddbb varchar(255)
while @it<=(select max(id) from lcc_iterator)
begin
    set @ddbb=(select name from lcc_iterator where id=@it)
	set @cmd='
	if ((select name from ['+@ddbb+'].sys.all_objects where type=''u'' and name=''filelist'') is not null
		 and (select name from ['+@ddbb+'].sys.all_objects where type=''u'' and name=''sessions'') is not null
		and (select name from ['+@ddbb+'].sys.all_objects where type=''u'' and name=''testinfo'') is not null
	   )
	begin
	--- is a swissqual ddbb
	insert into master.dbo.lcc_Result
	select ''['+@ddbb+']'' as ddbb, f.Collectionname 
	from ['+@ddbb+'].dbo.filelist f, 
		 ['+@ddbb+'].dbo.sessions s, 
		 ['+@ddbb+'].dbo.testinfo t
	where f.fileid=s.fileid and s.sessionid=t.sessionid 
	and s.valid=1 and t.valid=1
	 group by f.CollectionName

	end'

	exec (@cmd)
	set @it=@it+1

end

select * from  lcc_result

if (select name from sys.all_objects where type='u' and name='lcc_iterator') is not null drop table lcc_iterator
if (select name from sys.all_objects where type='u' and name='lcc_Result') is not null drop table lcc_Result
