declare @cmd nvarchar(4000)				
DECLARE @nameTabla varchar(256)								
DECLARE @Mes varchar(256)			
				
DECLARE @nameBD varchar(256)				
declare @it2 bigint				
declare @MaxBBDD bigint	
declare @MaxMes bigint				
declare @it1 bigint							
				
set @it1 = 1				
set @it2 = 1				
				
exec sp_lcc_dropifexists '_tmp_BBDD'	
			
select IDENTITY(int,1,1) id,name				
into _tmp_BBDD				
from sys.databases		
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
,'FY1718_DATA_MROAD_A1_H1'
,'FY1718_DATA_MROAD_A2_H1'
,'FY1718_DATA_MROAD_A3_H1'
,'FY1718_DATA_MROAD_A4_H1'
,'FY1718_DATA_MROAD_A5_H1'
,'FY1718_DATA_MROAD_A52_H1'
,'FY1718_DATA_MROAD_A6_H1'
,'FY1718_DATA_MROAD_A66_H1'
,'FY1718_DATA_MROAD_A68_H1'
,'FY1718_DATA_MROAD_A7_H1'
,'FY1718_DATA_MROAD_A8_H1'
,'FY1718_DATA_MROAD_A9_H1')
				
select @MaxBBDD = MAX(id) 				
from _tmp_BBDD		
		

select * from _tmp_BBDD	
			
while @it2 <= @MaxBBDD 				
begin				
				
	select @nameBD = name			
	from _tmp_BBDD			
	where id =@it2			
	print 'Nombre de la bbdd:  ' + @nameBD			
				

	set @cmd = '
		insert into [DASHBOARD].dbo.estudio_celdas_top12
			select f.fileid,
		n.duration,
		case  RIGHT(left(f.imsi,5),2)
			  when ''01'' then ''Vodafone''
			  when ''03'' then ''Orange''
			  when ''07'' then ''Movistar''
			  when ''04'' then ''Yoigo''
		end as operator,
		case when n.CGI <>'''' then n.CGI else convert(varchar(256),n.CId) end as Cell,
		f.CollectionName ,
		BCCH,
		case when SOF.BAND is null then n.technology else SOF.BAND collate Latin1_General_CI_AS end AS Band,
		case when isnull(sof.band,n.technology) like ''%LTE%'' then ''LTE''
			when isnull(sof.band,n.technology) like ''%UMTS%'' then ''UMTS''
			else ''GSM'' end as technology,
		[master].dbo.fn_lcc_getElement(4, collectionname,''_'') as Road,
		case when collectionname like ''%_1_VOLTE%'' then ''IDA VOZ''
			 when collectionname like ''%_2_VOLTE%'' then ''VUELTA VOZ''
			 when collectionname like ''%_1_4G%'' then ''IDA DATOS''
			 when collectionname like ''%_2_4G%'' then ''VUELTA DATOS''
		end as Round
	from '+@nameBD+'.dbo.filelist f,'+@nameBD+'.dbo.NetworkInfo n
	LEFT OUTER JOIN [AGRIDS].dbo.lcc_ref_servingOperator_Freq sof on n.BCCH=sof.Frequency
	where n.FileId=f.FileId
	and f.collectionname like ''%R6%'''			
						
				
		print @cmd	
		exec (@cmd)	
		set @it2 = @it2 +1					
		
end				
				
--truncate table [DASHBOARD].dbo.estudio_celdas_top12				
exec sp_lcc_dropifexists '_tmp_BBDD'

--98522
select * from 	[DASHBOARD].dbo.estudio_celdas_top12
WHERE CELL IS NULL

DELETE [DASHBOARD].dbo.estudio_celdas_top12
WHERE CELL IS NULL

--15099
select * from 	[DASHBOARD].dbo.estudio_celdas_top12
where technology='UMTS' AND CELL LIKE '%-%'

DELETE [DASHBOARD].dbo.estudio_celdas_top12
where technology='UMTS' AND CELL LIKE '%-%'

--589
select * from 	[DASHBOARD].dbo.estudio_celdas_top12
where technology='UMTS' AND CONVERT(INT,CELL) > 66000

DELETE [DASHBOARD].dbo.estudio_celdas_top12
where technology='UMTS' AND CONVERT(INT,CELL) > 66000

--1
select * from 	[DASHBOARD].dbo.estudio_celdas_top12
where bcch is null

DELETE [DASHBOARD].dbo.estudio_celdas_top12
where bcch is null


update [DASHBOARD].dbo.estudio_celdas_top12
set band=case when band='UMTS 2100' then 'UMTS2100'
			  when band='UMTS 900' then 'UMTS900'
			  when band='UMTS 800' then 'UMTS800'
			  when band='LTE E-UTRA 1' then 'LTE2100'
			  when band='LTE E-UTRA 3' then 'LTE1800'
			  when band='LTE E-UTRA 7' then 'LTE2600'
			  when band='LTE E-UTRA 20' then 'LTE800'
			  else band end

select case when band='LTE E-UTRA 1' then 'LTE2100'
			  when band='LTE E-UTRA 3' then 'LTE1800'
			  when band='LTE E-UTRA 7' then 'LTE2600'
			  when band='LTE E-UTRA 20' then 'LTE800'
			  else band end
from [DASHBOARD].dbo.estudio_celdas_top12

--- --- --- --- --- --- --- --- --- --- --- --- ---
--- --- --- --- --- --- --- --- --- --- --- --- ---

update [DASHBOARD].dbo.estudio_celdas_top12
set duration_seg=duration_mseg/1000.0

update [DASHBOARD].dbo.estudio_celdas_top12
set duration_min=duration_seg/60.0

update [DASHBOARD].dbo.estudio_celdas_top12
set duration_hor=duration_min/60.0

--- --- --- --- --- --- --- --- --- --- --- --- ---
--- --- --- --- --- --- --- --- --- --- --- --- ---

select *
from [DASHBOARD].dbo.estudio_celdas_top12
where road IS NULL

use FY1718_DATA_MROAD_A68_H1
--40007
select * from NetworkInfo

use FY1718_VOICE_MROAD_A68_H1
--379
select * from NetworkInfo t,filelist f
where t.fileid=1
and t.fileid=f.fileid

select * from filelist where fileid=1

select * from sessions where fileid=1
use FY1718_VOICE_MROAD_A68_H1
--669
select * from NetworkInfo
where fileid=1 ORDER BY MsgTime

select * from filelist where fileid=1

select * from sessions where fileid=1 ORDER BY STARTTIME

