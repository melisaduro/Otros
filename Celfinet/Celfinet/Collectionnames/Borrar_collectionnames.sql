-- drop table correct_collections_to_delete

use master
if (select name from sys.all_objects where type='u' and name='lcc_iterator') is not null drop table lcc_iterator
if (select name from sys.all_objects where type='u' and name='lcc_correct_collectionnames') is not null drop table lcc_correct_collectionnames

select identity(int,1,1) id,  ddbb
into lcc_iterator
from
(
select distinct ddbb from
 [correct_collections_to_delete] -- el listado de collectionnames que se tienen que quedar se deben importar en la tabla [correct_collections_to_delete]
 ) t

select identity(int,1,1) id, ddbb, collectionname 
into lcc_correct_collectionnames
from [correct_collections_to_delete]

declare @it int=1
declare @it2 as int=1
declare @cmd varchar(max)
declare @ddbb varchar(255)
while @it<=(select max(id) from lcc_iterator)
begin
    set @ddbb=(select ddbb from lcc_iterator where id=@it)


				-----------------------
				set @cmd='update '+@ddbb+'.dbo.sessions 
			set valid=0
			from '+@ddbb+'.dbo.FileList f, '+@ddbb+'.dbo.sessions s,
			(
			select distinct f.CollectionName from '+@ddbb+'.dbo.filelist f
			where f.CollectionName not in
			 (Select CollectionName collate SQL_Latin1_General_CP1_CI_AS 
			 from master.dbo.lcc_correct_collectionnames where ddbb='''+@ddbb+''' ) 

			 ) t
			 where f.FileId=s.FileId
			 and f.CollectionName=t.CollectionName
			 and s. valid=1
			 '
			 exec ( @cmd)
				-----------------------

			set @cmd='	
			 Delete from '+@ddbb+'.dbo.Filelist
			where collectionname in
			(
			select distinct f.CollectionName from '+@ddbb+'.dbo.filelist f
			where f.CollectionName not in
			 (Select CollectionName collate SQL_Latin1_General_CP1_CI_AS 
			 from master.dbo.lcc_correct_collectionnames where ddbb='''+@ddbb+''' ) 

			 )'
 
			 exec (@cmd )
				-----------------------
				--- borra las sessionids de todas las tablas de la bbdd que no tengan un collectionname asociado

			if (select name from sys.all_objects where type='u' and name='_iterator') is not null drop table _iterator
			if (select name from sys.all_objects where type='u' and name='_sessions_toDelete') is not null drop table _sessions_toDelete

			set @cmd='	
			 select  f.collectionname,s.sessionid, s.fileid, f.fileid as f_fileid
			into _sessions_toDelete
			 from  
			'+@ddbb+'.dbo.sessions s 
			  left outer join '+@ddbb+'.dbo.filelist f
				   on f.fileid=s.fileid
			where f.fileid is   null'
 
			 exec (@cmd )

 

			set @cmd='	
			select identity(int,1,1) it, o.name 
			into _iterator
			from '+@ddbb+'.sys.all_objects o,
			(select object_id from '+@ddbb+'.sys.all_columns 
			where name=''sessionid'') c
			where o.object_id=c.object_id
			and o.type=''u''
			'
 
			 exec (@cmd )

 
			set @it2=1
			while @it2<=(select max(it) from _iterator)
			begin
				set @cmd='
				delete from  '+@ddbb+'.dbo.'+(select name from _iterator where it=@it2)+'
				where sessionid in (select sessionid from _sessions_toDelete)
				'
				exec (@cmd)

				set @it2=@it2+1

			end

			if (select name from sys.all_objects where type='u' and name='_iterator') is not null drop table _iterator
			if (select name from sys.all_objects where type='u' and name='_sessions_toDelete') is not null drop table _sessions_toDelete
			 -----------------------------------------------------


	set @it=@it+1

end



if (select name from sys.all_objects where type='u' and name='lcc_iterator') is not null drop table lcc_iterator
if (select name from sys.all_objects where type='u' and name='lcc_correct_collectionnames') is not null drop table lcc_correct_collectionnames




	