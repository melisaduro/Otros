use FY1617_TEST_CECI
drop table #db
--drop table collectionnames_marzo
drop table _entidades_agregar
exec sp_lcc_dropifexists '_entidades'


exec  [dbo].[sp_importExcelFileAsText] 'F:\VDF_Invalidate\celfinet.xlsx', 'cities','_entidades'

select identity(int,1,1) id,*
into #db
from [dbo].[_entidades]

 create table FY1617_TEST_CECI.dbo.collectionnames_abril
 (  
	ddbb varchar(256) collate Latin1_General_CI_AS,
	collectionname varchar(256) collate Latin1_General_CI_AS,
	entidad varchar(256) collate Latin1_General_CI_AS);


 declare @id int=1
 while @id<=(select max(id) from #db)
 begin

 declare @ddbb as varchar(500) = (select [BBDDOrigen] from #db where id=@id)
 declare @entidad as varchar(500) = (select [Entidades] from #db where id=@id)



exec('

insert into collectionnames_abril
select '''+@ddbb+''', collectionname, master.dbo.fn_lcc_GetElement (4,collectionname,''_'') as entidad
from '+@ddbb+'.dbo.filelist
where collectionname like ''%'+@entidad+'%''
group by collectionname')

exec('select s.valid, s.sessionid, collectionname
from '+@ddbb+'.dbo.filelist f, sessions s
where collectionname not in (select collectionname from collectionnames_abril)
and f.fileid=s.fileid
group by s.valid, s.sessionid, collectionname')




set @id=@id+1


end

select * from collectionnames_abril
----select * from  #db
--select ddbb, collectionname, entidad, min(meas_date) as [Start], max(meas_date) as [End] from collectionnames_abril group by collectionname,ddbb, entidad
--order by 1

--select collectionname, entidad,ddbb from collectionnames_abril group by collectionname, entidad,ddbb
--order by 1
--select * from collectionnames_voz









