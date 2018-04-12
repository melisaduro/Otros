--StoredProcedure [dbo].[sp_MDD_Data_Youtube_GRID] 
-----------------------------
----- Testing Variables -----
-----------------------------

use OSP1617_Data_Rest_4G_H1_3

declare @ciudad as varchar(256) = 'almonte'
declare @simOperator as int = 4
declare @date as varchar(256) = ''
declare @Indoor as bit = 0 -- O = False, 1 = True
declare @Info as varchar (256) = 'Completed' --%% para procesados anteriores a 17/9/2015 y Completed para posteriores
declare @sheet as varchar(256) = '%%' --%%/LTE/WCDMA
declare @Tech as varchar (256) = '4G'
declare @methodology as varchar (256) = 'D16'
declare @report as varchar(256) = 'mun' --VDF (Reporte VDF), OSP (Reporte OSP), MUN (Municipal)

-------------------------------------------------------------------------------
-- GLOBAL FILTER:
-------------------------------------------------------------------------------	
declare @All_Tests_Tech as table (sessionid bigint, TestId bigint,tech varchar(5), hasCA varchar(2),[Collectionname] varchar(256),
lonid bigint, latid bigint)


If @Report='VDF'
begin
	insert into @All_Tests_Tech 
	select v.sessionid, v.testid,
		case when v.[% LTE]=1 then 'LTE'
			 when v.[% WCDMA]=1 then 'WCDMA'
			else 'Mixed' 
		end as tech,	
		'SC' hasCA,
		c.[Collectionname],
		c.lonid,
		c.latid
	from Lcc_Data_YOUTUBE v, testinfo t, lcc_position_Entity_List_Vodafone c
		Where t.testid=v.testid
			and t.valid=1
			and v.info like @Info
			and v.MNC = @simOperator	--MNC
			and v.MCC= 214						--MCC - Descartamos los valores erróneos
			and c.fileid=v.fileid
			and c.entity_name = @Ciudad
			and c.lonid=master.dbo.fn_lcc_longitude2lonid ([Longitud Final], [Latitud Final])
			and c.latid=master.dbo.fn_lcc_latitude2latid ([Latitud Final])
		group by v.sessionid, v.testid,
			case when v.[% LTE]=1 then 'LTE'
				 when v.[% WCDMA]=1 then 'WCDMA'
			else 'Mixed' end,
			v.[Longitud Final], v.[Latitud Final],
		c.[Collectionname],
		c.lonid,
		c.latid
end
If @Report='OSP'
begin
	insert into @All_Tests_Tech 
	select v.sessionid, v.testid,
		case when v.[% LTE]=1 then 'LTE'
			 when v.[% WCDMA]=1 then 'WCDMA'
			else 'Mixed' 
		end as tech,	
		'SC' hasCA,
		c.[Collectionname],
		c.lonid,
		c.latid
	from Lcc_Data_YOUTUBE v, testinfo t, lcc_position_Entity_List_Orange c
		Where t.testid=v.testid
			and t.valid=1
			and v.info like @Info
			and v.MNC = @simOperator	--MNC
			and v.MCC= 214						--MCC - Descartamos los valores erróneos
			and c.fileid=v.fileid
			and c.entity_name = @Ciudad
			and c.lonid=master.dbo.fn_lcc_longitude2lonid ([Longitud Final], [Latitud Final])
			and c.latid=master.dbo.fn_lcc_latitude2latid ([Latitud Final])
		group by v.sessionid, v.testid,
			case when v.[% LTE]=1 then 'LTE'
				 when v.[% WCDMA]=1 then 'WCDMA'
			else 'Mixed' end,
			v.[Longitud Final], v.[Latitud Final],
		c.[Collectionname],
		c.lonid,
		c.latid
end
If @Report='MUN'
begin
	insert into @All_Tests_Tech 
	select v.sessionid, v.testid,
		case when v.[% LTE]=1 then 'LTE'
			 when v.[% WCDMA]=1 then 'WCDMA'
			else 'Mixed' 
		end as tech,	
		'SC' hasCA,
		c.[Collectionname],
		c.lonid,
		c.latid
	from Lcc_Data_YOUTUBE v, testinfo t, lcc_position_Entity_List_Municipio c
		Where t.testid=v.testid
			and t.valid=1
			and v.info like @Info
			and v.MNC = @simOperator	--MNC
			and v.MCC= 214						--MCC - Descartamos los valores erróneos
			and c.fileid=v.fileid
			and c.entity_name = @Ciudad
			and c.lonid=master.dbo.fn_lcc_longitude2lonid ([Longitud Final], [Latitud Final])
			and c.latid=master.dbo.fn_lcc_latitude2latid ([Latitud Final])
		group by v.sessionid, v.testid,
			case when v.[% LTE]=1 then 'LTE'
				 when v.[% WCDMA]=1 then 'WCDMA'
			else 'Mixed' end,
			v.[Longitud Final], v.[Latitud Final],
		c.[Collectionname],
		c.lonid,
		c.latid
end

declare @All_Tests as table (sessionid bigint, TestId bigint)
declare @sheet1 as varchar(255)
declare @CA as varchar(255)

If @sheet = 'CA' --Para la hoja de CA del procesado de CA (medidas con Note4 = CollectionName_CA)
begin
	set @sheet1 = 'LTE'
	set @CA='%CA%'
end
else 
begin
	set @sheet1 = @sheet
	set @CA='%%'
end

insert into @All_Tests
select sessionid, testid
from @All_Tests_Tech 
where tech like @sheet1 
	and hasCA like @CA


------ Metemos en variables algunos campos calculados ----------------
declare @dateMax datetime2(3)= (select max(c.endTime) from Lcc_Data_YOUTUBE c, @All_Tests a where a.sessionid=c.sessionid and a.TestId=c.TestId)
declare @Meas_Date as varchar(256)= (select right(convert(varchar(256),datepart(yy, @dateMax)),2) + '_'	 + convert(varchar(256),format(@dateMax,'MM')))

declare @Meas_Round as varchar(256)= [master].dbo.fn_lcc_getElement(1, db_name(),'_') + '_' + [master].dbo.fn_lcc_getElement(5, db_name(),'_')

--declare @Meas_Date as varchar(256)= (select right(convert(varchar(256),datepart(yy, endTime)),2) + '_'	 + convert(varchar(256),format(endTime,'MM'))
--	from Lcc_Data_YOUTUBE where TestId=(select max(c.TestId) from Lcc_Data_YOUTUBE c, @All_Tests a where a.sessionid=c.sessionid and a.TestId=c.TestId))

declare @entidad as varchar(256) = @ciudad

declare @medida as varchar(256) 
if @Indoor=1 and @entidad not like '%RLW%' and @entidad not like '%APT%' and @entidad not like '%STD%'
begin
	SET @medida = right(@ciudad,1)
end
  
declare @week as varchar(256)
set @week = 'W' +convert(varchar,DATEPART(iso_week, @dateMax))

-------------------------------------------------------------------------------
--	GENERAL SELECT		-------------------	  select * from Lcc_Data_YOUTUBE
-------------------------------------------------------------------------------
declare @data_YTB  as table (
	[Database] [nvarchar](128) NULL,
	[mnc] [varchar](2) NULL,
	[Parcel] [varchar](50) NULL,
	[Reproducciones] [int] NULL,
	[Fails] [int] NULL,
	[Time To First Image] [numeric](38, 6) NULL,
	[Time To First Image max] [numeric](20, 7) NULL,
	[Num. Interruptions] [int] NULL,
	[ReproduccionesSinInt] [int] NULL,
	[Service success ratio W/o interruptions] [numeric](13, 1) NULL,
	[Reproduction ratio W/o interruptions] [numeric](24, 12) NULL,
	[Successful video download] [int] NULL,
	[Meas_Week] [varchar](3) NULL,
	[Meas_Round] [varchar](256) NULL,
	[Meas_Date] [varchar](256) NULL,
	[Entidad] [varchar](256) NULL,
	[Region][varchar](256) NULL,
	[Num_Medida] [int] NULL,
	[Report_Type] [varchar](256) null,
	[Aggr_Type] [varchar](256) null
)

select * from @All_Tests_Tech

if @Indoor=0
begin
	insert into @data_YTB
	select  
		db_name() as 'Database',
		v.mnc,
		master.dbo.fn_lcc_getParcel(v.[Longitud Final],v.[Latitud Final]) as Parcel,
		SUM(case when (v.typeoftest like '%YouTube%' and v.testname like '%SD%') then 1 else 0 end) as 'Reproducciones',
		SUM(case when (v.typeoftest like '%YouTube%' and v.testname like '%SD%' and v.Fails = 'Failed') then 1 else 0 end) as 'Fails',
	
		AVG(case when (v.typeoftest like '%YouTube%' and v.testname like '%SD%') then v.[Time To First Image [s]]] end) as 'Time To First Image',
		MAX(case when (v.typeoftest like '%YouTube%' and v.testname like '%SD%') then 1.0*(v.[Time To First Image [s]]])end) as 'Time To First Image max',	
		SUM(case when (v.typeoftest like '%YouTube%' and v.testname like '%SD%') then v.[Num. Interruptions] end) as 'Num. Interruptions',
		SUM(case when (v.typeoftest like '%YouTube%' and v.testname like '%SD%' and v.[End Status] ='W/O Interruptions') then 1 else 0 end) as 'ReproduccionesSinInt',

		case when SUM(case when v.typeoftest like '%YouTube%' and v.testname like '%SD%' then 1 else 0 end)>0 then
			(1 - (1.0*(SUM(case when (v.typeoftest like '%YouTube%' and v.testname like '%SD%' and v.Fails = 'Failed') then 1 else 0 end)) / 
			(SUM(case when (v.typeoftest like '%YouTube%' and v.testname like '%SD%') then 1 else 0 end)))) 
		else null end as 'Service success ratio W/o interruptions',	--B1
	
		case when SUM(case when v.typeoftest like '%YouTube%' and v.testname like '%SD%' then 1 else 0 end)>0 then
			1.0*(SUM(case when (v.typeoftest like '%YouTube%' and v.testname like '%SD%' and v.[End Status]='W/O Interruptions') then 1 else 0 end)) 
			/ (SUM(case when (v.typeoftest like '%YouTube%' and v.testname like '%SD%') then 1 else 0 end)) 
		else null end as 'Reproduction ratio W/o interruptions',	-- B2
	
		SUM(case when v.typeoftest like '%YouTube%' and v.testname like '%SD%' and v.[Succeesful_Video_Download]='Successful' then 1 else 0 end) as 'Successful video download',  --B3
		
		@week as Meas_Week,
		@Meas_Round as Meas_Round,
		@Meas_Date as Meas_Date,
		@entidad as Entidad,
		lp.region as Region,
		null,
		@Report,
		'GRID' 
	from 
		TestInfo t,
		@All_Tests a,
		Lcc_Data_YOUTUBE v,
		Agrids.dbo.lcc_parcelas lp
	where	
		a.Sessionid=t.Sessionid and a.TestId=t.TestId
		and t.valid=1
		and a.Sessionid=v.Sessionid and a.TestId=v.TestId
		and v.typeoftest like '%YouTube%' and v.testname like '%SD%'
		and lp.Nombre= master.dbo.fn_lcc_getParcel(v.[Longitud Final],v.[Latitud Final])
	group by master.dbo.fn_lcc_getParcel(v.[Longitud Final],v.[Latitud Final]), v.MNC,lp.Region
end
else
begin
	insert into @data_YTB
	select  
		db_name() as 'Database',
		v.mnc,
		null as Parcel,
		SUM(case when (v.typeoftest like '%YouTube%' and v.testname like '%SD%') then 1 else 0 end) as 'Reproducciones',
		SUM(case when (v.typeoftest like '%YouTube%' and v.testname like '%SD%' and v.Fails = 'Failed') then 1 else 0 end) as 'Fails',
	
		AVG(case when (v.typeoftest like '%YouTube%' and v.testname like '%SD%') then v.[Time To First Image [s]]] end) as 'Time To First Image',
		MAX(case when (v.typeoftest like '%YouTube%' and v.testname like '%SD%') then 1.0*(v.[Time To First Image [s]]])end) as 'Time To First Image max',	
		SUM(case when (v.typeoftest like '%YouTube%' and v.testname like '%SD%') then v.[Num. Interruptions] end) as 'Num. Interruptions',
		SUM(case when (v.typeoftest like '%YouTube%' and v.testname like '%SD%' and v.[End Status] ='W/O Interruptions') then 1 else 0 end) as 'ReproduccionesSinInt',

		case when SUM(case when v.typeoftest like '%YouTube%' and v.testname like '%SD%' then 1 else 0 end)>0 then
			(1 - (1.0*(SUM(case when (v.typeoftest like '%YouTube%' and v.testname like '%SD%' and v.Fails = 'Failed') then 1 else 0 end)) / 
			(SUM(case when (v.typeoftest like '%YouTube%' and v.testname like '%SD%') then 1 else 0 end)))) 
		else null end as 'Service success ratio W/o interruptions',	--B1
	
		case when SUM(case when v.typeoftest like '%YouTube%' and v.testname like '%SD%' then 1 else 0 end)>0 then
			1.0*(SUM(case when (v.typeoftest like '%YouTube%' and v.testname like '%SD%' and v.[End Status]='W/O Interruptions') then 1 else 0 end)) 
			/ (SUM(case when (v.typeoftest like '%YouTube%' and v.testname like '%SD%') then 1 else 0 end)) 
		else null end as 'Reproduction ratio W/o interruptions',	-- B2
	
		SUM(case when v.typeoftest like '%YouTube%' and v.testname like '%SD%' and v.[Succeesful_Video_Download]='Successful' then 1 else 0 end) as 'Successful video download',  --B3
		
		@week as Meas_Week,
		@Meas_Round as Meas_Round,
		@Meas_Date as Meas_Date,
		@entidad as Entidad,
		null,
		@medida as 'Num_Medida',
		@Report,
		'GRID' 
	from 
		TestInfo t,
		@All_Tests a,
		Lcc_Data_YOUTUBE v
	where	
		a.Sessionid=t.Sessionid and a.TestId=t.TestId
		and t.valid=1
		and a.Sessionid=v.Sessionid and a.TestId=v.TestId
		and v.typeoftest like '%YouTube%' and v.testname like '%SD%'
	group by v.MNC
end

select * from @data_YTB