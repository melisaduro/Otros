

drop table #bbdd
select identity(int,1,1) id, name 
into #bbdd 
from sys.databases  where (name like 'FY1617_Data_%H2%' or name like '%FY1617%data%indoor%H1%' or name like '%OSP1617%data%')

select * from #bbdd

----
declare @db as varchar(256)
declare @i as int=1

while @i<=(select max(id) from #bbdd)
begin
	set @db=(select name from #bbdd where id=@i)
	print @db

	exec('alter table ' + @db +'.dbo.Lcc_Data_HTTPTransfer_DL ADD [% RI1] [numeric](24, 12) NULL, [% RI2] [numeric](24, 12) NULL, [% RI1_SCC1] [numeric](24, 12) NULL, [% RI2_SCC1] [numeric](24, 12) NULL')
	exec('alter table ' + @db + '.dbo.Lcc_Data_HTTPTransfer_uL ADD	[% RI1] [numeric](24, 12) NULL,	[% RI2] [numeric](24, 12) NULL')
	set @i=@i+1
end 
