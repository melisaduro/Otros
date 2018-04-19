declare @cmd nvarchar(4000)				
DECLARE @nameTabla varchar(256)							
DECLARE @pattern varchar(256) = 'OSP1617%Voice%'		
DECLARE @Mes varchar(256)			
				
DECLARE @nameBD varchar(256)				
declare @it2 bigint				
declare @MaxBBDD bigint	
declare @MaxMes bigint				
declare @it1 bigint							
				
set @it1 = 1				
set @it2 = 1				
				
exec sp_lcc_dropifexists '_tmp_BBDD'	

declare @month as table	(
	ID INT NOT NULL,
	MES VARCHAR(256))
	
insert into @month
values (1,'1'),(2,'2'),(3,'3'),(4,'4'),(5,'5'),(6,'6'),(7,'7'),(8,'8'),(9,'9'),(10,'10'),(11,'11'),(12,'12')
				
select IDENTITY(int,1,1) id,name				
into _tmp_BBDD				
from sys.databases
--where name like @pattern 				
where name in ('FY1718_VOICE_MROAD_A1_H1'
,'FY1718_VOICE_MROAD_A2_H1'
,'FY1718_VOICE_MROAD_A3_H1'
,'FY1718_VOICE_MROAD_A4_H1'
,'FY1718_VOICE_MROAD_A5_H1'
,'FY1718_VOICE_MROAD_A52_H1'
,'FY1718_VOICE_MROAD_A6_H1'
,'FY1718_VOICE_MROAD_A66_H1'
,'FY1718_VOICE_MROAD_A68_H1'
,'FY1718_VOICE_MROAD_A7_H1'
,'FY1718_VOICE_MROAD_A8_H1'
,'FY1718_VOICE_MROAD_A9_H1'
,'FY1718_VOICE_AVE_ALB_ALI_H1'
,'FY1718_VOICE_AVE_BCN_FIG_H1'
,'FY1718_VOICE_AVE_COR_MAL_H1'
,'FY1718_VOICE_AVE_MAD_BCN_H1'
,'FY1718_VOICE_AVE_MAD_SEV_H1'
,'FY1718_VOICE_AVE_MAD_VALLA_H1'
,'FY1718_VOICE_AVE_MAD_VLC_H1'
,'FY1718_VOICE_AVE_MOT_ALB_H1'
,'FY1718_VOICE_AVE_OLM_ZAM_H1'
,'FY1718_VOICE_AVE_SGO_OUR_H1'
,'FY1718_VOICE_AVE_VALLA_LEO_H1'
,'FY1718_VOICE_ROAD_REST_H1'
,'FY1718_VOICE_ALBACETE_4G_H1'
,'FY1718_VOICE_ALICANTE_4G_H1'
,'FY1718_VOICE_BADAJOZ_4G_H1'
,'FY1718_VOICE_BARCELONA_4G_H1'
,'FY1718_VOICE_BILBAO_4G_H1'
,'FY1718_VOICE_BURGOS_4G_H1'
,'FY1718_VOICE_CARTAGENA_4G_H1'
,'FY1718_VOICE_CASTELLON_4G_H1'
,'FY1718_VOICE_CORDOBA_4G_H1'
,'FY1718_VOICE_CORUNA_4G_H1'
,'FY1718_VOICE_DONOSTI_4G_H1'
,'FY1718_VOICE_ELCHE_4G_H1'
,'FY1718_VOICE_GIJON_4G_H1'
,'FY1718_VOICE_GRANADA_4G_H1'
,'FY1718_VOICE_INDOOR_4G_H1'
,'FY1718_VOICE_JEREZ_4G_H1'
,'FY1718_VOICE_LLEIDA_4G_H1'
,'FY1718_VOICE_LOGRONO_4G_H1'
,'FY1718_VOICE_MADRID_4G_H1'
,'FY1718_VOICE_MALAGA_4G_H1'
,'FY1718_VOICE_MALLORCA_4G_H1'
,'FY1718_VOICE_MURCIA_4G_H1'
,'FY1718_VOICE_OVIEDO_4G_H1'
,'FY1718_VOICE_PALMAS_4G_H1'
,'FY1718_VOICE_PAMPLONA_4G_H1'
,'FY1718_VOICE_REST_4G_H1_11'
,'FY1718_VOICE_REST_4G_H1_12'
,'FY1718_VOICE_REST_4G_H1_13'
,'FY1718_VOICE_REST_4G_H1_14'
,'FY1718_VOICE_REST_4G_H1_15'
,'FY1718_VOICE_REST_4G_H1_16'
,'FY1718_VOICE_REST_4G_H1_21'
,'FY1718_VOICE_REST_4G_H1_22'
,'FY1718_VOICE_REST_4G_H1_23'
,'FY1718_VOICE_REST_4G_H1_24'
,'FY1718_VOICE_REST_4G_H1_25'
,'FY1718_VOICE_REST_4G_H1_26'
,'FY1718_VOICE_REST_4G_H1_27'
,'FY1718_VOICE_REST_4G_H1_28'
,'FY1718_VOICE_REST_4G_H1_29'
,'FY1718_VOICE_REST_4G_H1_31'
,'FY1718_VOICE_REST_4G_H1_32'
,'FY1718_VOICE_REST_4G_H1_33'
,'FY1718_VOICE_REST_4G_H1_34'
,'FY1718_VOICE_REST_4G_H1_35'
,'FY1718_VOICE_REST_4G_H1_36'
,'FY1718_VOICE_REST_4G_H1_37'
,'FY1718_VOICE_REST_4G_H1_38'
,'FY1718_VOICE_REST_4G_H1_39'
,'FY1718_VOICE_REST_4G_H1_41'
,'FY1718_VOICE_REST_4G_H1_42'
,'FY1718_VOICE_REST_4G_H1_43'
,'FY1718_VOICE_REST_4G_H1_44'
,'FY1718_VOICE_REST_4G_H1_45'
,'FY1718_VOICE_REST_4G_H1_46'
,'FY1718_VOICE_REST_4G_H1_47'
,'FY1718_VOICE_REST_4G_H1_48'
,'FY1718_VOICE_REST_4G_H1_49'
,'FY1718_VOICE_REST_4G_H1_51'
,'FY1718_VOICE_REST_4G_H1_52'
,'FY1718_VOICE_REST_4G_H1_53'
,'FY1718_VOICE_REST_4G_H1_54'
,'FY1718_VOICE_REST_4G_H1_55'
,'FY1718_VOICE_SANTANDER_4G_H1'
,'FY1718_VOICE_SEVILLA_4G_H1'
,'FY1718_VOICE_TENERIFE_4G_H1'
,'FY1718_VOICE_VALENCIA_4G_H1'
,'FY1718_VOICE_VALLADOLID_4G_H1'
,'FY1718_VOICE_VIGO_4G_H1'
,'FY1718_VOICE_VITORIA_4G_H1'
,'FY1718_VOICE_WILL_VOLTE_H1_1'
,'FY1718_VOICE_ZARAGOZA_4G_H1'
,'OSP1718_Coverage_1'
,'OSP1617_Voice_Rest_3G_H2'
,'OSP1617_Voice_Rest_3G_H2_2'
,'OSP1617_Voice_Rest_4G_H2'
,'OSP1617_Voice_Rest_4G_H2_2')
				
select @MaxBBDD = MAX(id) 				
from _tmp_BBDD		

select @MaxMes = MAX(id) 				
from @month	
print @MaxMes
		

select * from _tmp_BBDD	
			
while @it2 <= @MaxBBDD 				
begin				
				
	select @nameBD = name			
	from _tmp_BBDD			
	where id =@it2			
	print 'Nombre de la bbdd:  ' + @nameBD			
				

	set @it1 = 1

	while @it1 <= @MaxMes 
	begin
		select @Mes=Mes,
			   @nametabla=case when Mes in ('1','2','3','4','5','6','7','8','9') then 'Scanner_2G_0'+Mes else 'Scanner_2G_'+Mes end 
		from @month 
		where id=@it1
		
		set @cmd = '
			insert into [FY1718_SCANNER_GSM].dbo.'+@nametabla+'
			select li.channel, 
				   li.rssi, 
				   p.latitude, 
				   p.longitude, 
				   l.msgtime,
				   '''+@nameBD+'''
			from '+@nameBD+'.[dbo].[MsgScannerBCCHInfo] l, 
				 '+@nameBD+'.[dbo].[MsgScannerBCCH] li, 
				 '+@nameBD+'.[dbo].position p
		   where l.bcchscanid=li.bcchscanid
			and l.posid=p.posid
			and convert(varchar(4), month(p.msgtime))= '''+@Mes+'''
						
			insert into [FY1718_SCANNER_GSM].dbo.tabla_control
			select '''+@nameBD+''' as ''database'',
			ROWCOUNT_BIG () as Count_Reg,
			ROWCOUNT_BIG () as ''Count_Reg_insertados'',
			'''+@Mes+''' as ''Month'', 
			getdate() as ''Fecha'''			
						
				
		print @cmd	
		--exec (@cmd)	
		set @it1 = @it1 +1					
	end

	if (SELECT (CAST(mflog.LogSize AS FLOAT)*8)/(1024*1024) LogSizeGB
	   FROM sys.databases db
			LEFT JOIN (SELECT database_id, SUM(size) LogSize FROM sys.master_files
						WHERE type = 1 GROUP BY database_id, type) mflog ON mflog.database_id = db.database_id
		where DB_NAME(db.database_id)='FY1718_SCANNER_GSM') > 10  --Si el log de transacciones es mayor a 10GB hacemos un shrink
	BEGIN
		use FY1718_SCANNER_GSM
		-- Shrink the truncated log file to 1 MB.
		DBCC SHRINKFILE (FY1718_SCANNER_GSM, 1);
	END	

	set @it2 = @it2 +1			
end				
				
				
exec sp_lcc_dropifexists '_tmp_BBDD'		
