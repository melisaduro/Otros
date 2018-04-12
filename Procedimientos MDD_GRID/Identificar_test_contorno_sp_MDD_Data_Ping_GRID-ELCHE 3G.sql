--StoredProcedure [dbo].[sp_MDD_Data_Ping_GRID] 

use FY1617_Data_Smaller_3G_H1_3

-----------------------------
----- Testing Variables -----
-----------------------------
declare @ciudad as varchar(256) = 'Elche'
declare @simOperator as int = 3
declare @date as varchar(256) = ''
declare @Indoor as bit = 0 -- O = False, 1 = True
declare @Info as varchar (256) = 'Completed' --%% para procesados anteriores a 17/9/2015 y Completed para posteriores
declare @sheet as varchar(256) = '%%' --%%/LTE/WCDMA
declare @Tech as varchar (256) = '3G'
declare @methodology as varchar (256) = 'D16'
declare @report as varchar(256) = 'MUN' --VDF (Reporte VDF), OSP (Reporte OSP), MUN (Municipal)

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
	from Lcc_Data_Latencias v, testinfo t, lcc_position_Entity_List_Vodafone c
	where t.testid=v.testid
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
	from Lcc_Data_Latencias v, testinfo t, lcc_position_Entity_List_Orange c
	where t.testid=v.testid
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
	from Lcc_Data_Latencias v, testinfo t, lcc_position_Entity_List_Municipio c
	where t.testid=v.testid
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
declare @dateMax datetime2(3)= (select max(c.endTime) from Lcc_Data_Latencias c, @All_Tests a where a.sessionid=c.sessionid and a.TestId=c.TestId)

declare @Meas_Round as varchar(256)= [master].dbo.fn_lcc_getElement(1, db_name(),'_') + '_' + [master].dbo.fn_lcc_getElement(5, db_name(),'_')

declare @Meas_Date as varchar(256)= (select right(convert(varchar(256),datepart(yy, @dateMax)),2) + '_'	 + convert(varchar(256),format(@dateMax,'MM')))
declare @entidad as varchar(256) = @ciudad

declare @medida as varchar(256) 
if @Indoor=1 and @entidad not like '%RLW%' and @entidad not like '%APT%' and @entidad not like '%STD%'
begin
	SET @medida = right(@ciudad,1)
end


declare @week as varchar(256)
set @week = 'W' +convert(varchar,DATEPART(iso_week, @dateMax))
-------------------------------------------------------------------------------
--	GENERAL SELECT		-------------------	  
-------------------------------------------------------------------------------
declare @data_ping  as table (
	[Database] [nvarchar](128) NULL,
	[mnc] [varchar](2) NULL,
	[Parcel] [varchar](50) NULL,
	[pings] [int] NULL,
	[rtt] [float] NULL,
	[ 0-5Ms] [int] NULL,
	[ 5-10Ms] [int] NULL,
	[ 10-15Ms] [int] NULL,
	[ 15-20Ms] [int] NULL,
	[ 20-25Ms] [int] NULL,
	[ 25-30Ms] [int] NULL,
	[ 30-35Ms] [int] NULL,
	[ 35-40Ms] [int] NULL,
	[ 40-45Ms] [int] NULL,
	[ 45-50Ms] [int] NULL,
	[ 50-55Ms] [int] NULL,
	[ 55-60Ms] [int] NULL,
	[ 60-65Ms] [int] NULL,
	[ 65-70Ms] [int] NULL,
	[ 70-75Ms] [int] NULL,
	[ 75-80Ms] [int] NULL,
	[ 80-85Ms] [int] NULL,
	[ 85-90Ms] [int] NULL,
	[ 90-95Ms] [int] NULL,
	[ 95-100Ms] [int] NULL,
	[ 100-105Ms] [int] NULL,
	[ 105-110Ms] [int] NULL,
	[ 110-115Ms] [int] NULL,
	[ 115-120Ms] [int] NULL,
	[ 120-125Ms] [int] NULL,
	[ 125-130Ms] [int] NULL,
	[ 130-135Ms] [int] NULL,
	[ 135-140Ms] [int] NULL,
	[ 140-145Ms] [int] NULL,
	[ 145-150Ms] [int] NULL,
	[ 150-155Ms] [int] NULL,
	[ 155-160Ms] [int] NULL,
	[ 160-165Ms] [int] NULL,
	[ 165-170Ms] [int] NULL,
	[ 170-175Ms] [int] NULL,
	[ 175-180Ms] [int] NULL,
	[ 180-185Ms] [int] NULL,
	[ 185-190Ms] [int] NULL,
	[ 190-195Ms] [int] NULL,
	[ 195-200Ms] [int] NULL,
	[ >200Ms] [int] NULL,
	[Meas_Week] [varchar](3) NULL,
	[Meas_Round] [varchar](256) NULL,
	[Meas_Date] [varchar](256) NULL,
	[Entidad] [varchar](256) NULL,
	[Region][varchar](256) NULL,
	[Num_Medida] [int] NULL,
	[Report_Type] [varchar](256) null,
	[Aggr_Type] [varchar](256) null,
	[Methodology] [varchar](50) null
)

select * from @All_Tests_Tech 

if @Indoor=0
begin
	insert into @data_ping
	select  
			db_name() as 'Database',
			v.mnc,
			master.dbo.fn_lcc_getParcel(v.[Longitud Final],v.[Latitud Final]) as Parcel,
			COUNT(v.testid) as 'pings',
			AVG(1.0*v.rtt) as 'rtt',

			SUM(case when (rtt >=0 and rtt <5) then 1 else 0 end ) as [ 0-5Ms],
			SUM(case when (rtt >=5 and rtt <10) then 1 else 0 end ) as [ 5-10Ms],
			SUM(case when (rtt >=10 and rtt <15) then 1 else 0 end ) as [ 10-15Ms],
			SUM(case when (rtt >=15 and rtt <20) then 1 else 0 end ) as [ 15-20Ms],
			SUM(case when (rtt >=20 and rtt <25) then 1 else 0 end ) as [ 20-25Ms],
			SUM(case when (rtt >=25 and rtt <30) then 1 else 0 end ) as [ 25-30Ms],
			SUM(case when (rtt >=30 and rtt <35) then 1 else 0 end ) as [ 30-35Ms],
			SUM(case when (rtt >=35 and rtt <40) then 1 else 0 end ) as [ 35-40Ms],
			SUM(case when (rtt >=40 and rtt <45) then 1 else 0 end ) as [ 40-45Ms],
			SUM(case when (rtt >=45 and rtt <50) then 1 else 0 end ) as [ 45-50Ms],
			SUM(case when (rtt >=50 and rtt <55) then 1 else 0 end ) as [ 50-55Ms],
			SUM(case when (rtt >=55 and rtt <60) then 1 else 0 end ) as [ 55-60Ms],
			SUM(case when (rtt >=60 and rtt <65) then 1 else 0 end ) as [ 60-65Ms],
			SUM(case when (rtt >=65 and rtt <70) then 1 else 0 end ) as [ 65-70Ms],
			SUM(case when (rtt >=70 and rtt <75) then 1 else 0 end ) as [ 70-75Ms],
			SUM(case when (rtt >=75 and rtt <80) then 1 else 0 end ) as [ 75-80Ms],
			SUM(case when (rtt >=80 and rtt <85) then 1 else 0 end ) as [ 80-85Ms],
			SUM(case when (rtt >=85 and rtt <90) then 1 else 0 end ) as [ 85-90Ms],
			SUM(case when (rtt >=90 and rtt <95) then 1 else 0 end ) as [ 90-95Ms],
			SUM(case when (rtt >=95 and rtt <100) then 1 else 0 end ) as [ 95-100Ms],
			SUM(case when (rtt >=100 and rtt <105) then 1 else 0 end ) as [ 100-105Ms],
			SUM(case when (rtt >=105 and rtt <110) then 1 else 0 end ) as [ 105-110Ms],
			SUM(case when (rtt >=110 and rtt <115) then 1 else 0 end ) as [ 110-115Ms],
			SUM(case when (rtt >=115 and rtt <120) then 1 else 0 end ) as [ 115-120Ms],
			SUM(case when (rtt >=120 and rtt <125) then 1 else 0 end ) as [ 120-125Ms],

			SUM(case when (rtt >=125 and rtt <130) then 1 else 0 end ) as [ 125-130Ms],
			SUM(case when (rtt >=130 and rtt <135) then 1 else 0 end ) as [ 130-135Ms],
			SUM(case when (rtt >=135 and rtt <140) then 1 else 0 end ) as [ 135-140Ms],
			SUM(case when (rtt >=140 and rtt <145) then 1 else 0 end ) as [ 140-145Ms],
			SUM(case when (rtt >=145 and rtt <150) then 1 else 0 end ) as [ 145-150Ms],
			SUM(case when (rtt >=150 and rtt <155) then 1 else 0 end ) as [ 150-155Ms],
			SUM(case when (rtt >=155 and rtt <160) then 1 else 0 end ) as [ 155-160Ms],
			SUM(case when (rtt >=160 and rtt <165) then 1 else 0 end ) as [ 160-165Ms],
			SUM(case when (rtt >=165 and rtt <170) then 1 else 0 end ) as [ 165-170Ms],
			SUM(case when (rtt >=170 and rtt <175) then 1 else 0 end ) as [ 170-175Ms],
			SUM(case when (rtt >=175 and rtt <180) then 1 else 0 end ) as [ 175-180Ms],
			SUM(case when (rtt >=180 and rtt <185) then 1 else 0 end ) as [ 180-185Ms],
			SUM(case when (rtt >=185 and rtt <190) then 1 else 0 end ) as [ 185-190Ms],
			SUM(case when (rtt >=190 and rtt <195) then 1 else 0 end ) as [ 190-195Ms],
			SUM(case when (rtt >=195 and rtt <200) then 1 else 0 end ) as [ 195-200Ms],
			SUM(case when (rtt >=200) then 1 else 0 end ) as [ >200Ms],

			@week as Meas_Week,
			@Meas_Round as Meas_Round,
			@Meas_Date as Meas_Date,
			@entidad as Entidad,
			lp.region as Region,
			null,
			@Report,
			'GRID',
			@Methodology
	from 
		TestInfo t,
		@All_Tests a,
		Lcc_Data_Latencias v,
		Agrids.dbo.lcc_parcelas lp

	where	
		a.Sessionid=t.Sessionid and a.TestId=t.TestId
		and t.valid=1
		and a.Sessionid=v.Sessionid and a.TestId=v.TestId
		and lp.Nombre= master.dbo.fn_lcc_getParcel(v.[Longitud Final],v.[Latitud Final])

	group by master.dbo.fn_lcc_getParcel(v.[Longitud Final],v.[Latitud Final]), v.MNC,lp.region
end
else
begin
	insert into @data_ping
	select  
			db_name() as 'Database',
			v.mnc,
			null,
			COUNT(v.testid) as 'pings',
			AVG(1.0*v.rtt) as 'rtt',

			SUM(case when (rtt >=0 and rtt <5) then 1 else 0 end ) as [ 0-5Ms],
			SUM(case when (rtt >=5 and rtt <10) then 1 else 0 end ) as [ 5-10Ms],
			SUM(case when (rtt >=10 and rtt <15) then 1 else 0 end ) as [ 10-15Ms],
			SUM(case when (rtt >=15 and rtt <20) then 1 else 0 end ) as [ 15-20Ms],
			SUM(case when (rtt >=20 and rtt <25) then 1 else 0 end ) as [ 20-25Ms],
			SUM(case when (rtt >=25 and rtt <30) then 1 else 0 end ) as [ 25-30Ms],
			SUM(case when (rtt >=30 and rtt <35) then 1 else 0 end ) as [ 30-35Ms],
			SUM(case when (rtt >=35 and rtt <40) then 1 else 0 end ) as [ 35-40Ms],
			SUM(case when (rtt >=40 and rtt <45) then 1 else 0 end ) as [ 40-45Ms],
			SUM(case when (rtt >=45 and rtt <50) then 1 else 0 end ) as [ 45-50Ms],
			SUM(case when (rtt >=50 and rtt <55) then 1 else 0 end ) as [ 50-55Ms],
			SUM(case when (rtt >=55 and rtt <60) then 1 else 0 end ) as [ 55-60Ms],
			SUM(case when (rtt >=60 and rtt <65) then 1 else 0 end ) as [ 60-65Ms],
			SUM(case when (rtt >=65 and rtt <70) then 1 else 0 end ) as [ 65-70Ms],
			SUM(case when (rtt >=70 and rtt <75) then 1 else 0 end ) as [ 70-75Ms],
			SUM(case when (rtt >=75 and rtt <80) then 1 else 0 end ) as [ 75-80Ms],
			SUM(case when (rtt >=80 and rtt <85) then 1 else 0 end ) as [ 80-85Ms],
			SUM(case when (rtt >=85 and rtt <90) then 1 else 0 end ) as [ 85-90Ms],
			SUM(case when (rtt >=90 and rtt <95) then 1 else 0 end ) as [ 90-95Ms],
			SUM(case when (rtt >=95 and rtt <100) then 1 else 0 end ) as [ 95-100Ms],
			SUM(case when (rtt >=100 and rtt <105) then 1 else 0 end ) as [ 100-105Ms],
			SUM(case when (rtt >=105 and rtt <110) then 1 else 0 end ) as [ 105-110Ms],
			SUM(case when (rtt >=110 and rtt <115) then 1 else 0 end ) as [ 110-115Ms],
			SUM(case when (rtt >=115 and rtt <120) then 1 else 0 end ) as [ 115-120Ms],
			SUM(case when (rtt >=120 and rtt <125) then 1 else 0 end ) as [ 120-125Ms],
			SUM(case when (rtt >=125 and rtt <130) then 1 else 0 end ) as [ 125-130Ms],
			SUM(case when (rtt >=130 and rtt <135) then 1 else 0 end ) as [ 130-135Ms],
			SUM(case when (rtt >=135 and rtt <140) then 1 else 0 end ) as [ 135-140Ms],
			SUM(case when (rtt >=140 and rtt <145) then 1 else 0 end ) as [ 140-145Ms],
			SUM(case when (rtt >=145 and rtt <150) then 1 else 0 end ) as [ 145-150Ms],
			SUM(case when (rtt >=150 and rtt <155) then 1 else 0 end ) as [ 150-155Ms],
			SUM(case when (rtt >=155 and rtt <160) then 1 else 0 end ) as [ 155-160Ms],
			SUM(case when (rtt >=160 and rtt <165) then 1 else 0 end ) as [ 160-165Ms],
			SUM(case when (rtt >=165 and rtt <170) then 1 else 0 end ) as [ 165-170Ms],
			SUM(case when (rtt >=170 and rtt <175) then 1 else 0 end ) as [ 170-175Ms],
			SUM(case when (rtt >=175 and rtt <180) then 1 else 0 end ) as [ 175-180Ms],
			SUM(case when (rtt >=180 and rtt <185) then 1 else 0 end ) as [ 180-185Ms],
			SUM(case when (rtt >=185 and rtt <190) then 1 else 0 end ) as [ 185-190Ms],
			SUM(case when (rtt >=190 and rtt <195) then 1 else 0 end ) as [ 190-195Ms],
			SUM(case when (rtt >=195 and rtt <200) then 1 else 0 end ) as [ 195-200Ms],
			SUM(case when (rtt >=200) then 1 else 0 end ) as [ >200Ms],

			@week as Meas_Week,
			@Meas_Round as Meas_Round,
			@Meas_Date as Meas_Date,
			@entidad as Entidad,
			null,
			@medida as 'Num_Medida',
			@Report,
			'GRID',
			@Methodology
	from 
		TestInfo t,
		@All_Tests a,
		Lcc_Data_Latencias v

	where	
		a.Sessionid=t.Sessionid and a.TestId=t.TestId
		and t.valid=1
		and a.Sessionid=v.Sessionid and a.TestId=v.TestId

	group by v.MNC
end

select * from @data_ping
