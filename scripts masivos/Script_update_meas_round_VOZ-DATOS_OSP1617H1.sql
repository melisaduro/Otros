declare @cmd nvarchar(4000)				
DECLARE @nameTabla varchar(256)							
DECLARE @pattern varchar(256) = '%AGGR%4G%'	
DECLARE @entidad varchar(256) 
				
				
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
where name like  @pattern	
	and name not like '%_old'			
				
select @MaxBBDD = MAX(id) 				
from _tmp_BBDD				
				
while @it2 <= @MaxBBDD 				
begin				
				
	select @nameBD = name			
	from _tmp_BBDD			
	where id =@it2			
	print 'Nombre de la bbdd:  ' + @nameBD			
				
	exec sp_lcc_dropifexists '_tmp_Tablas'			
	--declare @pattern as varchar (256) = 'ogrove'			
	set @cmd = 'select IDENTITY(int,1,1) id,name			
	into _tmp_Tablas			
	from ['+@nameBD +'].sys.tables			
	where name like ''lcc_aggr_%''	
	and name not like ''lcc_aggr_%backup%''	 
	and name not like ''%2017%''	
	and name not like ''%2016%''	
	and type=''U'''		
	print @cmd			
	exec (@cmd)			
				
	select @MaxTab = MAX(id) 			
	from _tmp_Tablas			
				
	set @it1 = 1			
				
	while @it1 <= @MaxTab			
	begin			
				
		select @nameTabla = name		
		from _tmp_Tablas		
		where id =@it1		
		print 'Nombre de la tabla:  ' + @nameTabla		
				
		--set @cmd = 'update '+@nameBD +'.dbo.'+ @nameTabla +'		
		--	set [meas_round] =''FY1617_H1''
		--	where [entidad] = ''FCB-STD'' and [meas_round]=''FY1617_H2'''

			set @cmd = 'select [meas_round] from '+@nameBD +'.dbo.'+ @nameTabla +'
			where [entidad] in (''FCB-STD'') group by [meas_round]'
		
		--set @cmd='select * into '+@nameBD +'.dbo.'+ @nameTabla +'_backup_ALL from '+@nameBD +'.dbo.'+ @nameTabla
				
		print @cmd		
		exec (@cmd)
				
		set @it1 = @it1 +1		
	end			
				
	set @it2 = @it2 +1			
end				
				
				
exec sp_lcc_dropifexists '_tmp_BBDD'				
exec sp_lcc_dropifexists '_tmp_Tablas'				
