use dashboard
declare @ruta_entidades as varchar (4000)='F:\VDF_Invalidate\calculo_Th.xlsx'

exec sp_lcc_dropifexists '_entidades'
exec sp_lcc_dropifexists 'Th_DL'
exec sp_lcc_dropifexists 'Th_UL'

exec  [dbo].[sp_importExcelFileAsText] @ruta_entidades, 'cities','_entidades'

declare @id int=1
declare @cmd nvarchar(4000)
declare @cmd2 nvarchar(4000)



create table Th_DL 
( ciudad varchar(256),
mnc varchar(2),
Count_Throughput_384k_NC int,
Count_Throughput_384k_CE int,
Count_Throughput_NC int,
Count_Throughput_CE int)


create table Th_UL 
( ciudad varchar(256),
mnc varchar(2),
Count_Throughput_384k_NC int,
Count_Throughput_384k_CE int,
Count_Throughput_NC int,
Count_Throughput_CE int)

--select entity,[round],meas_round,last_measurement_vdf,last_measurement_osp
--into _entidades
--from qlik.dbo._RI_Data_Completed_QLIK_20171019
--where last_measurement_vdf>0 and [round]<>''
--and report_type='VDF'
--and meas_round in ('Fase 2','Fase 3')
--and (entity like 'A[1-7]-%' or entity in ('AVE-Madrid-Barcelona','AVE-Madrid-Sevilla','AVE-Madrid-Valencia'))
--group by entity,[round],meas_round,last_measurement_vdf,last_measurement_osp
--order by entity

select identity(int,1,1) id,*
into #iterator
from [dbo].[_entidades]

select * from #iterator

while @id<=(select max(id) from #iterator)
	begin

	declare @ciudad as varchar (256) = (select entity from #iterator where id=@id)
	declare @BBDDorigen as varchar (256)= (select [Database] from #iterator  where id=@id)

	--declare @ciudad as varchar (256)='AVE-Madrid-Valencia-R6'
	declare @sheet as varchar(256) = '%%' --%%/LTE/WCDMA



	--select [database],entidad,meas_Date,meas_week,date_reporting,week_reporting,report_type,meas_round
	--from [AGGRData4G].dbo.lcc_aggr_sp_MDD_Data_DL_Thput_CE
	--where entidad= @entidad
	--and meas_round like '%1617%'
	--group by [database], entidad,meas_Date,meas_week,date_reporting,week_reporting,report_type,meas_round
	--order by 2
	set @cmd=('

	use '+@BBDDorigen+'

	declare @All_Tests_Tech_DL as table (sessionid bigint, TestId bigint,tech varchar(5), hasCA varchar(2),MNC varchar(2))
	declare @All_Tests_Tech_UL as table (sessionid bigint, TestId bigint,tech varchar(5), hasCA varchar(2),MNC varchar(2))

	insert into @All_Tests_Tech_DL
		select v.sessionid, v.testid,
			case when v.[% LTE]=1 then ''LTE''
				 when v.[% WCDMA]=1 then ''WCDMA''
				else ''Mixed'' 
			end as tech,	
			''SC'' hasCA,v.MNC as MNC
		from Lcc_Data_HTTPTransfer_DL v, testinfo t, lcc_position_Entity_List_Vodafone c
		where t.testid=v.testid
			and t.valid=1
			and v.info like ''Completed''
			and v.MCC= 214						--MCC - Descartamos los valores erróneos
			and c.fileid=v.fileid
			and c.entity_name = '''+@Ciudad+'''
			and c.lonid=master.dbo.fn_lcc_longitude2lonid ([Longitud Final], [Latitud Final])
			and c.latid=master.dbo.fn_lcc_latitude2latid ([Latitud Final])
		group by v.sessionid, v.testid,
			case when v.[% LTE]=1 then ''LTE''
				 when v.[% WCDMA]=1 then ''WCDMA''
			else ''Mixed'' end,
			v.[Longitud Final], v.[Latitud Final],v.MNC 


	insert into @All_Tests_Tech_UL
		select v.sessionid, v.testid,
			case when v.[% LTE]=1 then ''LTE''
				 when v.[% WCDMA]=1 then ''WCDMA''
				else ''Mixed'' 
			end as tech,	
			''SC'' hasCA,v.MNC as MNC
		from Lcc_Data_HTTPTransfer_UL v, testinfo t, lcc_position_Entity_List_Vodafone c
		where t.testid=v.testid
			and t.valid=1
			and v.info like ''Completed''
			and v.MCC= 214						--MCC - Descartamos los valores erróneos
			and c.fileid=v.fileid
			and c.entity_name = '''+@Ciudad+'''
			and c.lonid=master.dbo.fn_lcc_longitude2lonid ([Longitud Final], [Latitud Final])
			and c.latid=master.dbo.fn_lcc_latitude2latid ([Latitud Final])
		group by v.sessionid, v.testid,
			case when v.[% LTE]=1 then ''LTE''
				 when v.[% WCDMA]=1 then ''WCDMA''
			else ''Mixed'' end,
			v.[Longitud Final], v.[Latitud Final],v.MNC 
	
	declare @All_Tests_DL as table (sessionid bigint, TestId bigint,mnc varchar(2))
	declare @All_Tests_UL as table (sessionid bigint, TestId bigint,mnc varchar(2))
	declare @sheet1 as varchar(255)
	declare @CA as varchar(255)


	If '''+@sheet+''' = ''CA'' --Para la hoja de CA del procesado de CA (medidas con Note4 = CollectionName_CA)
	begin
		set @sheet1 = ''LTE''
		set @CA=''%CA%''
	end
	else 
	begin
		set @sheet1 = '''+@sheet+'''
		set @CA=''%%''
	end

	insert into @All_Tests_DL
	select sessionid, testid,mnc
	from @All_Tests_Tech_DL
	where tech like @sheet1 
		and hasCA like @CA


	insert into @All_Tests_UL
	select sessionid, testid,mnc
	from @All_Tests_Tech_UL
	where tech like @sheet1
		and hasCA like @CA
	--select * from @All_Tests


	insert into [dashboard].dbo.Th_UL
	select  '''+@ciudad+''', 
			v.mnc,
			SUM(case when (v.direction=''Uplink'' and v.TestType=''UL_NC'' and ISNULL(v.Throughput,0)>384) then 1 else 0 end) as ''Count_Throughput_384k_NC'',	
			SUM(case when (v.direction=''Uplink'' and v.TestType=''UL_CE'' and ISNULL(v.Throughput,0)>384) then 1 else 0 end) as ''Count_Throughput_384k_CE'',
			SUM(case when (v.direction=''Uplink'' and v.TestType=''UL_NC'') then 1 else 0 end) as ''Count_Throughput_NC'',	
			SUM(case when (v.direction=''Uplink'' and v.TestType=''UL_CE'') then 1 else 0 end) as ''Count_Throughput_CE''
		from 
			TestInfo t,
			@All_Tests_UL a,
			Lcc_Data_HTTPTransfer_UL v
		where	
			a.Sessionid=t.Sessionid and a.TestId=t.TestId
			and t.valid=1
			and a.mnc=v.mnc
			and a.Sessionid=v.Sessionid and a.TestId=v.TestId
		
		group by v.mnc
		order by case v.mnc WHEN ''01'' THEN 1 WHEN ''07'' THEN 2 WHEN ''03'' THEN 3 WHEN ''04'' THEN 4 end

	insert into [dashboard].dbo.Th_DL
	select  '''+@ciudad+''', 
			v.mnc,
			SUM(case when (v.direction=''Downlink'' and v.TestType=''DL_NC'' and ISNULL(v.Throughput,0)>384) then 1 else 0 end) as ''Count_Throughput_384k_NC'',	
			SUM(case when (v.direction=''Downlink'' and v.TestType=''DL_CE'' and ISNULL(v.Throughput,0)>384) then 1 else 0 end) as ''Count_Throughput_384k_CE'',
			SUM(case when (v.direction=''Downlink'' and v.TestType=''DL_NC'') then 1 else 0 end) as ''Count_Throughput_NC'',	
			SUM(case when (v.direction=''Downlink'' and v.TestType=''DL_CE'') then 1 else 0 end) as ''Count_Throughput_CE''
		from 
			TestInfo t,
			@All_Tests_DL a,
			Lcc_Data_HTTPTransfer_DL v
		where	
			a.Sessionid=t.Sessionid and a.TestId=t.TestId
			and t.valid=1
			and a.mnc=v.mnc
			and a.Sessionid=v.Sessionid and a.TestId=v.TestId
		
		group by v.mnc
		order by case v.mnc WHEN ''01'' THEN 1 WHEN ''07'' THEN 2 WHEN ''03'' THEN 3 WHEN ''04'' THEN 4 end')

		print(@cmd)
		exec (@cmd)

		set @id=@id+1
end
	drop table #iterator
	