use dashboard
declare @cmd nvarchar(4000)											
				
				
DECLARE @nameBD varchar(256)				
declare @it2 bigint				
declare @MaxBBDD bigint				
declare @it1 bigint				
declare @MaxTab bigint		


set @it1 = 1				
set @it2 = 1				
				
exec sp_lcc_dropifexists '_tabla_agregado'	
exec sp_lcc_dropifexists 'lcc_pruebas_msn'			

create table lcc_pruebas_msn (
[database] varchar (256),
[entidad] varchar (256),
[navegaciones msn] int )
				
				
select [database],entidad,meas_round,meas_date,sum(navegaciones) as navegciones,sum([navegaciones public]) as publicas			
--into _tabla_agregado			
from AGGRData3G.dbo.lcc_aggr_sp_MDD_Data_Web	
where report_type='MUN'
and meas_round like '%1718%'
group by [database],entidad,meas_round,meas_date
	
	
		
				
select @MaxBBDD = MAX(id) 				
from _tabla_agregado				
				
while @it2 <= @MaxBBDD 				
begin				
				
	select @nameBD = [database]			
	from _tabla_agregado			
	where id =@it2			
	print 'Nombre de la bbdd:  ' + @nameBD					
	
	set @cmd = '
				insert into [dashboard].dbo.lcc_pruebas_msn
				
				select [DATABASE], ENTIDAD,sum ([navegaciones msn]) from (
				select '''+@nameBD +''' as [database],[master].dbo.fn_lcc_getElement(4, collectionname,''_'') as entidad,count(1) as [navegaciones msn]
				from '+@nameBD +'.dbo.Lcc_Data_HTTPBrowser b, '+@nameBD +'.dbo.testinfo t
				where b.testid=t.testid
				and t.valid=1
				and b.testtype =''MSN''
				group by collectionname) t
				group by [DATABASE],ENTIDAD
			'	
				
	print @cmd		
	exec (@cmd)		
		
				
	set @it2 = @it2 +1			
end				
				
				
	

select [database],ENTIDAD,[navegaciones msn] 
from [dashboard].dbo.lcc_pruebas_msn
group by [database],ENTIDAD,[navegaciones msn] 

select * from _tabla_agregado	
order by entidad	

--exec sp_lcc_dropifexists '_tabla_agregado'	


