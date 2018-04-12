declare @cmd nvarchar(4000)				
DECLARE @nameTabla varchar(256)							
DECLARE @pattern varchar(256) = 'AGGRData3G'

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
--AGGRDATA3G		
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_CE_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_CE_LTE_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_NC_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_NC_LTE_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Thput_CE_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Thput_CE_LTE_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Thput_NC_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Thput_NC_LTE_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Web_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Web_Public ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Web_Public_3G ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Youtube ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Youtube_3G ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Youtube_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Youtube_HD_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)

--AGGRDATA4G
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_All_Test_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_All_Test_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Performance_CE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Performance_CE_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Performance_CE_LTE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Performance_CE_LTE_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Performance_NC_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Performance_NC_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Performance_NC_LTE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Performance_NC_LTE_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Technology_CE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Technology_CE_LTE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Technology_NC_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Technology_NC_LTE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_CE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_CE_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_CE_LTE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_CE_LTE_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_NC_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_NC_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_NC_LTE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_NC_LTE_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Ping_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Ping_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Performance_CE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Performance_CE_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Performance_CE_LTE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Performance_CE_LTE_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Performance_NC_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Performance_NC_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Performance_NC_LTE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Performance_NC_LTE_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Technology_CE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Technology_CE_LTE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Technology_NC_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Technology_NC_LTE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Thput_CE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Thput_CE_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Thput_CE_LTE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Thput_CE_LTE_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Thput_NC_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Thput_NC_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Thput_NC_LTE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Thput_NC_LTE_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Web_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Web_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Web_Kepler_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Web_Mobile_Kepler_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Web_Public ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Web_Public_3G ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Web_Public_4G ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Web_Public_CA_ONLY ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Web_Time_Kepler_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Web_Time_Mobile_Kepler_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Youtube ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Youtube_3G ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Youtube_4G ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Youtube_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Youtube_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Youtube_CA_ONLY ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Youtube_HD_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Youtube_HD_CA ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)

--AGGRDATA4G_ROAD
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_All_Test_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Performance_CE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Performance_CE_LTE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Performance_NC_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Performance_NC_LTE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Technology_CE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Technology_CE_LTE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Technology_NC_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Technology_NC_LTE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_CE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_CE_LTE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_NC_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_DL_Thput_NC_LTE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Ping_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Performance_CE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Performance_CE_LTE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Performance_NC_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Performance_NC_LTE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Technology_CE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Technology_CE_LTE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Technology_NC_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Technology_NC_LTE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Thput_CE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Thput_CE_LTE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Thput_NC_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_UL_Thput_NC_LTE_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Web_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Web_Kepler_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Web_Mobile_Kepler_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Web_Public ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Web_Public_3G ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Web_Public_4G ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Web_Time_Kepler_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Web_Time_Mobile_Kepler_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Youtube ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Youtube_3G ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Youtube_4G ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Youtube_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)
--set @cmd = 'ALTER TABLE '+@nameBD +'.dbo.lcc_aggr_sp_MDD_Data_Youtube_HD_4GDevice ADD [Region_OSP] [varchar](256) NULL' exec(@cmd)


	--print @cmd		
	--exec (@cmd)
				
	set @it2 = @it2 +1			
end				
				
				
exec sp_lcc_dropifexists '_tmp_BBDD'				
