
use DASHBOARD

declare @cmd nvarchar(4000)				
DECLARE @nameTabla varchar(256)			
		

				
				
DECLARE @nameBD varchar(256)				
declare @it2 bigint				
declare @MaxBBDD bigint				
declare @it1 bigint				
declare @MaxTab bigint			

				
set @it1 = 1				
set @it2 = 1				
				
exec sp_lcc_dropifexists '_tmp_BBDD'				
				
select IDENTITY(int,1,1) id,name				
into _tmp_BBDD				
from sys.databases				
where name like '%BBDD_TEST_17%'

select * from _tmp_BBDD

select @MaxBBDD = MAX(id) 				
from _tmp_BBDD				
				
while @it2 <= @MaxBBDD 				
begin				
				
	select @nameBD = name			
	from _tmp_BBDD			
	where id =@it2			
	print 'Nombre de la bbdd:  ' + @nameBD			
	
	
	set @cmd = '
			
		select  max(fileid),max(sessionid)
		from '+@nameBD +'.[dbo].[lcc_position_Entity_List_Municipio] f
		where entity_name=''GETAFE''
	

			'
		
		--print @cmd		
		exec (@cmd)
				
		
				
	set @it2 = @it2 +1			
end				

				
exec sp_lcc_dropifexists '_tmp_BBDD'				


