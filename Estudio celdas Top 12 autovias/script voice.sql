declare @cmd nvarchar(max)				
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
--,'FY1718_DATA_MROAD_A1_H1'
--,'FY1718_DATA_MROAD_A2_H1'
--,'FY1718_DATA_MROAD_A3_H1'
--,'FY1718_DATA_MROAD_A4_H1'
--,'FY1718_DATA_MROAD_A5_H1'
--,'FY1718_DATA_MROAD_A52_H1'
--,'FY1718_DATA_MROAD_A6_H1'
--,'FY1718_DATA_MROAD_A66_H1'
--,'FY1718_DATA_MROAD_A68_H1'
--,'FY1718_DATA_MROAD_A7_H1'
--,'FY1718_DATA_MROAD_A8_H1'
--,'FY1718_DATA_MROAD_A9_H1'
)
				
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
		use '+@nameBD+'
		------------- 4G Parte A
exec dbo.sp_lcc_dropifexists ''_lcc_4G_parte_A''
select n.fileid,
		m.sessionid,
		m.testid,
		m.msgtime,
		m.networkid,
		EARFCN as Freq,
		n.CId,
		case  RIGHT(left(f.imsi,5),2)
			  when ''01'' then ''Vodafone''
			  when ''03'' then ''Orange''
			  when ''07'' then ''Movistar''
			  when ''04'' then ''Yoigo''
		end as operator,
		n.CGI,
		n.technology,
		f.CollectionName,
		n.duration as duration,
		case when collectionname like ''%_1_VOLTE%'' then ''IDA VOZ''
			 when collectionname like ''%_2_VOLTE%'' then ''VUELTA VOZ''
			 when collectionname like ''%_1_4G%'' then ''IDA DATOS''
			 when collectionname like ''%_2_4G%'' then ''VUELTA DATOS''
		end as Round,
		''A'' as Side	  

INTO _lcc_4G_parte_A
	from LTEMeasurementReport m, NetworkInfo n, position p, sessions s, filelist f
	where m.networkid=n.NetworkId and p.PosId=m.PosId and m.SessionId=s.SessionId and s.FileId=f.FileId
		and f.collectionname like ''%R6%''
		and s.valid=1

------------- 4G Parte B
exec dbo.sp_lcc_dropifexists ''_lcc_4G_parte_B''
select n.fileid,
		m.sessionid,
		m.testid,
		m.msgtime,
		m.networkid,
		EARFCN as Freq,
		n.CId,
		case  RIGHT(left(f.imsi,5),2)
			  when ''01'' then ''Vodafone''
			  when ''03'' then ''Orange''
			  when ''07'' then ''Movistar''
			  when ''04'' then ''Yoigo''
		end as operator,
		n.CGI,
		n.technology,
		f.CollectionName,
		n.duration as duration,
		case when collectionname like ''%_1_VOLTE%'' then ''IDA VOZ''
			 when collectionname like ''%_2_VOLTE%'' then ''VUELTA VOZ''
			 when collectionname like ''%_1_4G%'' then ''IDA DATOS''
			 when collectionname like ''%_2_4G%'' then ''VUELTA DATOS''
		end as Round,
		''B'' as Side	  
INTO _lcc_4G_parte_B
	from LTEMeasurementReport m, NetworkInfo n, position p, sessionsB s, filelist f
	where m.networkid=n.NetworkId and p.PosId=m.PosId and m.SessionId=s.SessionId and s.FileId=f.FileId
				and f.collectionname like ''%R6%''
				and s.valid=1
	


------------- 3G Parte A
exec dbo.sp_lcc_dropifexists ''_lcc_3G_parte_A''
select  n.fileid,
		m.sessionid,
		m.testid,
		m.msgtime,
		m.networkid,
		mprim.FreqDL as Freq,
		n.CId,
		case  RIGHT(left(f.imsi,5),2)
			  when ''01'' then ''Vodafone''
			  when ''03'' then ''Orange''
			  when ''07'' then ''Movistar''
			  when ''04'' then ''Yoigo''
		end as operator,
		n.CGI,
		n.technology,
		f.CollectionName,
		n.duration as duration,
		case when collectionname like ''%_1_VOLTE%'' then ''IDA VOZ''
			 when collectionname like ''%_2_VOLTE%'' then ''VUELTA VOZ''
			 when collectionname like ''%_1_4G%'' then ''IDA DATOS''
			 when collectionname like ''%_2_4G%'' then ''VUELTA DATOS''
		end as Round,
		''A'' as Side	  
INTO _lcc_3G_parte_A
	from WCDMAActiveSet m,
		 (Select sessionid, testid, msgtime, PrimScCode, FreqDL,
							row_number() over(partition by sessionid, testid,msgtime order by sessionid, testid, msgtime,RSCP_PSC) as id
							from WCDMAActiveSet
						 ) mprim,
		 position p, sessions s, filelist f,NetworkInfo n
			LEFT outer JOIN vBTSList ON vBTSList.CGI = n.CGI and  vBTSList.LAC = n.LAC	 			
	where m.networkid=n.NetworkId and p.PosId=m.PosId and m.SessionId=s.SessionId and s.FileId=f.FileId
	and mprim.sessionid=m.sessionid and mprim.testid=m.testid and mprim.msgtime=m.msgtime and mprim.PrimScCode=m.PrimScCode 
	and m.refcell=1 -- Nos quedamos con la celda primaria
			and f.collectionname like ''%R6%''
			and s.valid=1



------------- 3G Parte B
exec dbo.sp_lcc_dropifexists ''_lcc_3G_parte_B''
select  n.fileid,
		m.sessionid,
		m.testid,
		m.msgtime,
		m.networkid,
		mprim.FreqDL as Freq,
		n.CId,
		case  RIGHT(left(f.imsi,5),2)
			  when ''01'' then ''Vodafone''
			  when ''03'' then ''Orange''
			  when ''07'' then ''Movistar''
			  when ''04'' then ''Yoigo''
		end as operator,
		n.CGI,
		n.technology,
		f.CollectionName,
		n.duration as duration,
		case when collectionname like ''%_1_VOLTE%'' then ''IDA VOZ''
			 when collectionname like ''%_2_VOLTE%'' then ''VUELTA VOZ''
			 when collectionname like ''%_1_4G%'' then ''IDA DATOS''
			 when collectionname like ''%_2_4G%'' then ''VUELTA DATOS''
		end as Round,
		''B'' as Side	   
INTO _lcc_3G_parte_B
	from WCDMAActiveSet m,
		(Select sessionid, testid, msgtime, PrimScCode, FreqDL,
							row_number() over(partition by sessionid, testid,msgtime order by sessionid, testid, msgtime,RSCP_PSC) as id
							from WCDMAActiveSet
						 ) mprim,		
		 position p, sessionsB s, filelist f,NetworkInfo n
			LEFT outer JOIN vBTSList ON vBTSList.CGI = n.CGI and  vBTSList.LAC = n.LAC	 			
	where m.networkid=n.NetworkId and p.PosId=m.PosId and m.SessionId=s.SessionId and s.FileId=f.FileId
	and mprim.sessionid=m.sessionid and mprim.testid=m.testid and mprim.msgtime=m.msgtime and mprim.PrimScCode=m.PrimScCode 
	and m.refcell=1 -- Nos quedamos con la celda primaria
		and f.collectionname like ''%R6%''
		and s.valid=1


---------------- 2G Parte A
exec dbo.sp_lcc_dropifexists ''_lcc_2G_parte_A''
select  n.fileid,
		m.sessionid,
		m.testid,
		m.msgtime,
		m.networkid,
		n.BCCH as Freq,
		n.CId,
		case  RIGHT(left(f.imsi,5),2)
			  when ''01'' then ''Vodafone''
			  when ''03'' then ''Orange''
			  when ''07'' then ''Movistar''
			  when ''04'' then ''Yoigo''
		end as operator,
		n.CGI,
		n.technology,
		f.CollectionName,
		n.duration as duration,
		case when collectionname like ''%_1_VOLTE%'' then ''IDA VOZ''
			 when collectionname like ''%_2_VOLTE%'' then ''VUELTA VOZ''
			 when collectionname like ''%_1_4G%'' then ''IDA DATOS''
			 when collectionname like ''%_2_4G%'' then ''VUELTA DATOS''
		end as Round,
		''A'' as Side	  
INTO _lcc_2G_parte_A
	 from MsgGsmReport m, NetworkInfo n, position p, sessions s, filelist f
	 where m.networkid=n.NetworkId and p.PosId=m.PosId and m.SessionId=s.SessionId and s.FileId=f.FileId
		and f.collectionname like ''%R6%''
		and s.valid=1


---------------- 2G Parte B
exec dbo.sp_lcc_dropifexists ''_lcc_2G_parte_B''
select  n.fileid,
		m.sessionid,
		m.testid,
		m.msgtime,
		m.networkid,
		n.BCCH as Freq,
		n.CId,
		case  RIGHT(left(f.imsi,5),2)
			  when ''01'' then ''Vodafone''
			  when ''03'' then ''Orange''
			  when ''07'' then ''Movistar''
			  when ''04'' then ''Yoigo''
		end as operator,
		n.CGI,
		n.technology,
		f.CollectionName,
		n.duration as duration,
		case when collectionname like ''%_1_VOLTE%'' then ''IDA VOZ''
			 when collectionname like ''%_2_VOLTE%'' then ''VUELTA VOZ''
			 when collectionname like ''%_1_4G%'' then ''IDA DATOS''
			 when collectionname like ''%_2_4G%'' then ''VUELTA DATOS''
		end as Round,
		''B'' as Side	  
INTO _lcc_2G_parte_B
	 from MsgGsmReport m, NetworkInfo n, position p, sessionsB s, filelist f
	 where m.networkid=n.NetworkId and p.PosId=m.PosId and m.SessionId=s.SessionId and s.FileId=f.FileId
	 and f.collectionname like ''%R6%''
	 and s.valid=1

--------------- HACEMOS LA UNION DE TODAS LAS TEMPORALES
exec dbo.sp_lcc_dropifexists ''_lcc_tecnologias_partes''
--478222
SELECT * 
INTO _lcc_tecnologias_partes 
FROM _lcc_4G_parte_A
	UNION ALL
	SELECT * FROM _lcc_4G_parte_B
	UNION ALL
	SELECT * FROM _lcc_3G_parte_A
	UNION ALL
	SELECT * FROM _lcc_3G_parte_B
	UNION ALL
	SELECT * FROM _lcc_2G_parte_A
	UNION ALL
	SELECT * FROM _lcc_2G_parte_B

--41366
exec dbo.sp_lcc_dropifexists ''_lcc_tecnologias_partes_dup''
select fileid,
		sessionid,
	   testid,
	   networkid,
	   freq,
	   case when CGI <>'''' then CGI else convert(varchar(256),CId) end as Cell,
		operator,
		technology as band, 
		collectionname, 
		duration,
		[ROUND],
		side
into _lcc_tecnologias_partes_dup
from _lcc_tecnologias_partes
group by fileid,
		sessionid,
	   testid,
	   networkid,
	   freq,
	   case when CGI <>'''' then CGI else convert(varchar(256),CId) end,
		operator,
		technology, 
		collectionname, 
		duration,
		[ROUND],
		side
--3042

insert into [DASHBOARD].dbo.estudio_celdas_top12_v2
select	n.fileid,
		n.duration,
		n.operator,
		n.cell,
		n.collectionname,
		n.freq as BCCH,
		case when SOF.BAND is null then n.band else SOF.BAND collate Latin1_General_CI_AS end AS Band,
		case when isnull(sof.band,n.band) like ''%LTE%'' then ''LTE''
			when isnull(sof.band,n.band) like ''%UMTS%'' then ''UMTS''
			else ''GSM'' end as technology,
		[master].dbo.fn_lcc_getElement(4, collectionname,''_'') as Road,
		case when collectionname like ''%_1_VOLTE%'' then ''IDA VOZ''
			 when collectionname like ''%_2_VOLTE%'' then ''VUELTA VOZ''
			 when collectionname like ''%_1_4G%'' then ''IDA DATOS''
			 when collectionname like ''%_2_4G%'' then ''VUELTA DATOS''
		end as Round,
		side
from _lcc_tecnologias_partes_dup n
LEFT OUTER JOIN [AGRIDS].dbo.lcc_ref_servingOperator_Freq sof on n.Freq=sof.Frequency
	
	exec dbo.sp_lcc_dropifexists ''_lcc_4G_parte_A''
exec dbo.sp_lcc_dropifexists ''_lcc_4G_parte_B''
exec dbo.sp_lcc_dropifexists ''_lcc_3G_parte_A''
exec dbo.sp_lcc_dropifexists ''_lcc_3G_parte_B''
exec dbo.sp_lcc_dropifexists ''_lcc_2G_parte_A''
exec dbo.sp_lcc_dropifexists ''_lcc_2G_parte_B''
exec dbo.sp_lcc_dropifexists ''_lcc_tecnologias_partes''
exec dbo.sp_lcc_dropifexists ''_lcc_tecnologias_partes_dup''
'									
				
		--print @cmd	
		exec (@cmd)	
		set @it2 = @it2 +1					
		
end	