declare @cmd nvarchar(4000)				
DECLARE @nameTabla varchar(256)							
DECLARE @pattern varchar(256) = 'FY1718%VOICE%'		
DECLARE @MONTH varchar(256)='1'				
				
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
and name like '%road%'
	and name not like '%_old'
	and name not like '%PRUEBA%'
	and name not like '%SCANNER%'	
	and name not like '%SMALLCELLS%'	
	and name not like '%YOIGO%'		
				
select @MaxBBDD = MAX(id) 				
from _tmp_BBDD				

select * from _tmp_BBDD	
			
while @it2 <= @MaxBBDD 				
begin				
				
	select @nameBD = name			
	from _tmp_BBDD			
	where id =@it2			
	print 'Nombre de la bbdd:  ' + @nameBD			
				
	
			
	--declare @pattern as varchar (256) = 'ogrove'			
	set @cmd = '
		insert into [FY1718_SCANNER_GSM_LTE_WCDMA].dbo.Scanner_2G_01
		select li.channel, 
			   li.rssi, 
			   p.latitude, 
			   p.longitude, 
			   l.msgtime
		from '+@nameBD+'.[dbo].[MsgScannerBCCHInfo] l, 
			 '+@nameBD+'.[dbo].[MsgScannerBCCH] li, 
			 '+@nameBD+'.[dbo].position p
	   where l.bcchscanid=li.bcchscanid
		and l.posid=p.posid
		and convert(varchar(4), month(p.msgtime))= '''+@month+''''		
	print @cmd			
	exec (@cmd)	
	
	set @cmd = '
		insert into [FY1718_SCANNER_GSM_LTE_WCDMA].dbo.tabla_control
		select '''+@nameBD+''' as ''database'',count(1) as ''Count_Reg'', ROWCOUNT_BIG () as ''Count_Reg_insertados''
		from '+@nameBD+'.[dbo].[MsgScannerBCCHInfo] l, 
			 '+@nameBD+'.[dbo].[MsgScannerBCCH] li, 
			 '+@nameBD+'.[dbo].position p
	   where l.bcchscanid=li.bcchscanid
		and l.posid=p.posid
		and convert(varchar(4), month(p.msgtime))= '''+@month+''''			
	--print @cmd	
	exec (@cmd)	
	
							
	
	set @it2 = @it2 +1			
end				
				
				
exec sp_lcc_dropifexists '_tmp_BBDD'		
