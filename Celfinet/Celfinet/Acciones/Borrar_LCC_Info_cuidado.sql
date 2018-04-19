

select identity(int,1,1) id, *
into erase
from
(select name,type,type_desc

 from sys.all_objects
where name like '!_%' escape '!' and type_desc='user_table'

union


select name,type,type_desc from sys.all_objects
where name like '%lcc!_%' escape '!' 

union 

select name,type,type_desc from sys.all_objects
where name like 'cu!_%' escape '!' 
) t

declare @it as int=1
declare @cmd as varchar(8000)
while @it<=(select max(id) from erase)
begin
set @cmd=
 case (select type from erase where id=@it) 
  when 'U' then
  ' drop table ['+(select name from erase where type='U' and id=@it)+']'
  when 'V' then
  ' drop View ['+(select name from erase where type='V' and id=@it)+']'
  when 'FN' then
  ' drop Function ['+(select name from erase where type='FN' and id=@it)+']'
  when 'P' then
  ' drop Procedure ['+(select name from erase where type='P' and id=@it)+']'
  
  end 
  exec (@cmd)
  set @it=@it+1
end

drop table erase