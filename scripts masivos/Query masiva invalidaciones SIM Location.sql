
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
where name in (	'FY1718_Data_ALBACETE_4G_H1','FY1718_DATA_ALICANTE_4G_H1','FY1718_DATA_CARTAGENA_4G_H1','FY1718_DATA_CASTELLON_4G_H1',
'FY1718_DATA_ELCHE_4G_H1','FY1718_DATA_LOGRONO_4G_H1','FY1718_DATA_MADRID_4G_H1','FY1718_DATA_MALAGA_4G_H1','FY1718_DATA_MURCIA_4G_H1',
'FY1718_DATA_PAMPLONA_4G_H1','FY1718_DATA_VALENCIA_4G_H1','FY1718_DATA_ZARAGOZA_4G_H1')	
		
				
select @MaxBBDD = MAX(id) 				
from _tmp_BBDD				
				
while @it2 <= @MaxBBDD 				
begin				
				
	select @nameBD = name			
	from _tmp_BBDD			
	where id =@it2			
	print 'Nombre de la bbdd:  ' + @nameBD			
	
	
	set @cmd = '
			
		--update '+@nameBD +'.dbo.testinfo
		--set valid=0, invalidReason =''SIM Location''
		select  '''+@nameBD +''',count(1)
		from '+@nameBD +'.dbo.filelist f, '+@nameBD +'.dbo.sessions s, '+@nameBD +'.dbo.testinfo t
		where f.fileid=s.fileid
		and s.sessionid=t.sessionid
		and f.imsi= ''214012004443867''
		and t.direction in (''Uplink'',''Downlink'')
		and t.valid=1

			'
		
		print @cmd		
		exec (@cmd)
				
		
				
	set @it2 = @it2 +1			
end				

				
exec sp_lcc_dropifexists '_tmp_BBDD'				


