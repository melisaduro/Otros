declare @cmd nvarchar(4000)				
DECLARE @nameTabla varchar(256)								
DECLARE @nameCol varchar(256)				
				
DECLARE @nameBD varchar(256)				
declare @it2 bigint				
declare @MaxBBDD bigint				
declare @it1 bigint				
declare @MaxTab bigint		
declare @it3 bigint	
declare @MaxCol bigint					
				
set @it1 = 1				
set @it2 = 1
set @it3=1		
		
--exec sp_lcc_dropifexists '_control'		
create table _control
(
traza varchar (1024),
columna varchar(1024),
bbdd varchar(1024),
tabla varchar(1024)
 
)

exec sp_lcc_dropifexists '_tmp_BBDD'				
				
select IDENTITY(int,1,1) id,name				
into _tmp_BBDD				
from sys.databases				
where name in ('FY1718_DATA_REST_4G_H1_12')--('FY1718_Data_Rest_4G_H1_16')--,'FY1718_VOICE_REST_4G_H1_12','FY1718_Voice_Rest_4G_H1_16')
	

				
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
	set @cmd = 'select IDENTITY(int,1,1) id,t.name			
	into _tmp_Tablas	
	FROM ['+@nameBD +'].sys.columns c
	inner JOIN ['+@nameBD +'].sys.tables  t   
	ON c.object_id = t.object_id
	WHERE (c.name LIKE ''%time%''
	or c.name like ''%date%''
	or c.name like ''%year%'')
	and t.name not like ''lcc%''
	group by t.name'		
	
	print @cmd			
	exec (@cmd)	


	select * from _tmp_Tablas	
	

	select @MaxTab = MAX(id) 			
	from _tmp_Tablas	
		
				
	set @it1 = 1	
	
				
	while @it1 <= @MaxTab			
	begin			
				
		select @nameTabla = name		
		from _tmp_Tablas		
		where id =@it1		
		print 'Nombre de la tabla:  ' + @nameTabla		

		exec sp_lcc_dropifexists '_tmp_Columns'			
		--declare @pattern as varchar (256) = 'ogrove'			
		set @cmd = 'select IDENTITY(int,1,1) id,c.name as [column]			
		into _tmp_Columns	
		FROM ['+@nameBD +'].sys.columns c
		inner JOIN ['+@nameBD +'].sys.tables  t   
		ON c.object_id = t.object_id
		WHERE (c.name LIKE ''%time%''
		or c.name like ''%date%''
		or c.name like ''%year%'')
		and t.name not like ''%lcc%''
		and t.name = '''+@nameTabla+'''
		group by c.name'		
	
		print @cmd			
		exec (@cmd)		

		select @MaxCol = MAX(id) 				
		from _tmp_Columns	

		set @it3=1	
		while  @it3 <= @MaxCol			
		begin	
			select @nameCol = [column]		
			from _tmp_Columns		
			where id =@it3
			print 'Nombre de la column:  ' + @nameCol		

			--set @cmd = 'select c.[Region_VF] from '+@nameBD +'.dbo.'+ @nameTabla +' c, Agrids.dbo.lcc_parcelas p where p.Nombre=c.parcel and (c.Region_VF is null or c.Region_OSP is null) and (c.[database] not like ''%Indoor%'' and c.[database] not like ''%AVE%'')'	
			
				
				set @cmd = '
						if Exists(Select 1 from '+@nameBD +'.dbo.'+ @nameTabla +'	
						where ('+@nameCol+' like ''%2012-%''	
								or '+@nameCol+' like ''%2011-%''))
						begin
								UPDATE '+@nameBD +'.dbo.'+ @nameTabla +'	
								set '+@nameCol+' = dateadd(ss,177965438,'+@nameCol+') 
									from '+@nameBD +'.dbo.'+ @nameTabla +'	
									where ('+@nameCol+' like ''%2012-%''	
											or '+@nameCol+' like ''%2011-%'')	
						end		
						
								
							
				'
				
				print @cmd		
				exec (@cmd)

				insert into _control
				select 'Update en columna ' +@nameCol+' en base de datos ' +@nameBD+' y tabla '+ @nameTabla,+@nameCol,+@nameBD,+ @nameTabla

			set @it3=@it3+1
		end
				
		set @it1 = @it1 +1		
	end			
				
	set @it2 = @it2 +1			
end				
select * from _control

exec sp_lcc_dropifexists '_tmp_BBDD'				
exec sp_lcc_dropifexists '_tmp_Tablas'				
exec sp_lcc_dropifexists '_tmp_Columns'	



--Usar select datediff (ss, '2011-12-31 23:38:29.000','2017-10-03 09:30:00.000')