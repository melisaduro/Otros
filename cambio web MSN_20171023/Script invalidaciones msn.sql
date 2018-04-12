use dashboard
declare @cmd nvarchar(4000)											
				
				
DECLARE @nameBD varchar(256)				
declare @it2 bigint				
declare @MaxBBDD bigint				
declare @it1 bigint				
declare @MaxTab bigint		

exec sp_lcc_dropifexists 'lcc_pruebas_msn_invalidaciones'

create table lcc_pruebas_msn_invalidaciones (
[database] varchar (256),
[entidad] varchar (256),
[invalidaciones msn] int )

declare @ruta_entidades as varchar (4000)='F:\VDF_Invalidate\invalidaciones_MSN.xlsx'
set @it1 = 1				
set @it2 = 1		

exec sp_lcc_dropifexists '_entidades_agregar'

exec  [dbo].[sp_importExcelFileAsText] @ruta_entidades, 'cities','_entidades_agregar'		
				

select identity(int,1,1) id,*
into #iterator
from [dbo].[_entidades_agregar]		


select * from #iterator

				
select @MaxBBDD = MAX(id) 				
from #iterator

print  @MaxBBDD				
				
while @it2 <= @MaxBBDD 				
begin				
				
	select @nameBD = [database]			
	from #iterator			
	where id =@it2			
	print 'Nombre de la bbdd:  ' + @nameBD					
	
	set @cmd = '
				--update '+@nameBD +'.dbo.testinfo
				--set valid=0, invalidReason=''LCC url MSN''
				--insert into lcc_pruebas_msn_invalidaciones
				--select '''+@nameBD +''' as [database],collectionname,count(t.testid) as [invalidaciones msn]
				--from '+@nameBD +'.dbo.Lcc_Data_HTTPBrowser b, '+@nameBD +'.dbo.testinfo t
				--where b.testid=t.testid
				--and t.invalidReason=''LCC url MSN''
				--and b.testtype =''MSN''
				--group by collectionname

				insert into lcc_pruebas_msn_invalidaciones
				select [DATABASE], ENTIDAD,sum ([invalidaciones msn]) from (
				select '''+@nameBD +''' as [database],[master].dbo.fn_lcc_getElement(4, collectionname,''_'') as entidad,count(t.testid) as [invalidaciones msn]
				from '+@nameBD +'.dbo.Lcc_Data_HTTPBrowser b, '+@nameBD +'.dbo.testinfo t
				where b.testid=t.testid
				and t.invalidReason=''LCC url MSN''
				and b.testtype =''MSN''
				group by collectionname) t
				group by [DATABASE],ENTIDAD
				'
				
	--print @cmd		
	exec (@cmd)		
		
				
	set @it2 = @it2 +1			
end				
				
				
drop table #iterator

select [database], sum([invalidaciones msn])
 from lcc_pruebas_msn_invalidaciones
 group by [database]

