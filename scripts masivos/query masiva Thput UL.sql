declare @cmd nvarchar(4000)				
DECLARE @nameTabla varchar(256)			
DECLARE @entidad varchar(256) = 'MERIDA'						
DECLARE @pattern varchar(256) = 'FY1718%data%3G%'		
				
				
DECLARE @nameBD varchar(256)				
declare @it2 bigint				
declare @MaxBBDD bigint				
declare @it1 bigint				
declare @MaxTab bigint			
--drop table _PRUEBA_THPUT
CREATE TABLE DASHBOARD.[dbo]._PRUEBA_THPUT(
	[CollectionName] [varchar](100) NULL,
	[Throughput] [float] NULL,
	testid [int] NULL,
	valid [int] null,
	invalidReason [varchar](256) NULL)	
				
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
	
	
	set @cmd = 'if exists (select * from '+@nameBD +'.dbo.sysobjects where name=''Lcc_Data_HTTPTransfer_UL'')
	begin
				INSERT INTO DASHBOARD.DBO._PRUEBA_THPUT
				select COLLECTIONNAME,THROUGHPUT,t.TESTID,t.valid,t.invalidReason
				from '+@nameBD +'.dbo.Lcc_Data_HTTPTransfer_UL u, '+@nameBD +'.dbo.testinfo t
				where THROUGHPUT>5700
				and u.testid=t.testid
	end
			'
				
		
		
		--set @cmd='select * into '+@nameBD +'.dbo.'+ @nameTabla +'_backup_ALL from '+@nameBD +'.dbo.'+ @nameTabla
				
		print @cmd		
		exec (@cmd)
				
		
				
	set @it2 = @it2 +1			
end				

select * from 	DASHBOARD.DBO._PRUEBA_THPUT	
where valid=1	
				
exec sp_lcc_dropifexists '_tmp_BBDD'				


