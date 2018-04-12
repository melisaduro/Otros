declare @cmd nvarchar(4000)				
DECLARE @nameTabla varchar(256)							
--DECLARE @pattern varchar(256) = 'FY1617_Voice_Rest_3G_H1_4'	
--DECLARE @pattern varchar(256) = 'FY1617_Voice_Rest_4G_H1_2'	
--DECLARE @pattern varchar(256) = 'FY1617_Voice_Rest_3G_H1_2'	

--DECLARE @pattern varchar(256) = 'FY1617_Voice_Rest_3G_H1'	
--DECLARE @pattern varchar(256) = 'FY1617_Voice_Rest_3G_H1_3'	
--DECLARE @pattern varchar(256) = 'FY1617_Voice_Rest_3G_H1_6'	
--DECLARE @pattern varchar(256) = 'FY1617_Voice_Rest_3G_H1_7'	
--DECLARE @pattern varchar(256) = 'FY1617_Voice_Rest_3G_H1_10'	
--DECLARE @pattern varchar(256) = 'FY1617_Voice_Rest_3G_H1_5'	


--DECLARE @pattern varchar(256) = 'FY1617_Voice_Rest_4G_H1_3'	
--DECLARE @pattern varchar(256) = 'FY1617_Voice_Rest_4G_H1_4'					
--DECLARE @pattern varchar(256) = 'FY1617_Voice_Rest_4G_H1_6'			
--DECLARE @pattern varchar(256) = 'FY1617_Voice_Rest_4G_H1_7'		
--DECLARE @pattern varchar(256) = 'FY1617_Voice_Rest_4G_H1_8'	
--DECLARE @pattern varchar(256) = 'FY1617_Voice_Rest_4G_H1_10'

--DECLARE @pattern varchar(256) = 'FY1617_Voice_Smaller_4G_H1_3'
--DECLARE @pattern varchar(256) = 'FY1617_Voice_Main_4G_H1_3'

--DECLARE @pattern varchar(256) = 'FY1617_Voice_Smaller_VOLTE_2'
DECLARE @pattern varchar(256) = 'FY1617_Voice_MRoad_VOLTE_2'

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
	and name not like '%_old' --and name <> 'FY1617_Voice_AVE_MAD_BCN_H2'
				
select @MaxBBDD = MAX(id) 				
from _tmp_BBDD				
				
while @it2 <= @MaxBBDD	
begin				
				
	select @nameBD = name			
	from _tmp_BBDD			
	where id =@it2			
	print 'Nombre de la bbdd:  ' + @nameBD			
		
	
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD MOS_UMTS900_NB_AVG [float] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD MOS_UMTS900_WB_AVG [float] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD MOS_UMTS2100_NB_AVG [float] NULL' exec (@cmd) 
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD MOS_UMTS2100_WB_AVG [float] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD MOS_LTE800_NB_AVG [float] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD MOS_LTE800_WB_AVG [float] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD MOS_LTE1800_NB_AVG [float] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD MOS_LTE1800_WB_AVG [float] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD MOS_LTE2100_NB_AVG [float] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD MOS_LTE2100_WB_AVG [float] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD MOS_LTE2600_NB_AVG [float] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD MOS_LTE2600_WB_AVG [float] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD Samples_NB_GSM900 [int] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD Samples_WB_GSM900 [int] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD Samples_NB_GSM1800 [int] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD Samples_WB_GSM1800 [int] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD Samples_NB_UMTS900 [int] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD Samples_WB_UMTS900 [int] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD Samples_NB_UMTS2100 [int] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD Samples_WB_UMTS2100 [int] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD Samples_NB_LTE800 [int] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD Samples_WB_LTE800 [int] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD Samples_NB_LTE1800 [int] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD Samples_WB_LTE1800 [int] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD Samples_NB_LTE2100 [int] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD Samples_WB_LTE2100 [int] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD Samples_NB_LTE2600 [int] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD Samples_WB_LTE2600 [int] NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD LTE2600_Duration [numeric](26,6) NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD LTE2100_Duration [numeric](26,6) NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD LTE1800_Duration [numeric](26,6) NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD LTE800_Duration [numeric](26,6) NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD UMTS2100_Duration [numeric](26,6) NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD UMTS900_Duration [numeric](26,6) NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD GSM900_Duration [numeric](26,6) NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD GSM1800_Duration [numeric](26,6) NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD UMTS2100_Duration_B [numeric](26,6) NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD UMTS900_Duration_B [numeric](26,6) NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD GSM900_Duration_B [numeric](26,6) NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD GSM1800_Duration_B [numeric](26,6) NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD LTE2600_Duration_B [numeric](26,6) NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD LTE2100_Duration_B [numeric](26,6) NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD LTE1800_Duration_B [numeric](26,6) NULL' exec (@cmd)
	set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_Calls_Detailed ADD LTE800_Duration_B [numeric](26,6) NULL' exec (@cmd)


	--print @cmd		
	--exec (@cmd)
				
	set @it2 = @it2 +1			
end				
				
				
exec sp_lcc_dropifexists '_tmp_BBDD'				
