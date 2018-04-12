USE FY1718_GRECIA_WIND
--GO
--/****** Object:  StoredProcedure [dbo].[sp_MDD_Data_NED_Libro_Resumen_KPIs_Extra_4G_FY1718_GRID]    Script Date: 26/03/2018 16:09:42 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

--ALTER PROCEDURE [dbo].[sp_MDD_Data_NED_Libro_Resumen_KPIs_Extra_4G_FY1718_GRID] (
--	 --Variables de entrada
-- 				@ciudad as varchar(256),			-- si NED: valor,	si paso1: '%%'
--				@simOperator as int,
--				@sheet as varchar(256),				-- all: %%, 4H: 'LTE', 3G: 'WCDMA'
--				@Tech as varchar (256),				-- Para seleccionar entre 3G, 4G y CA
--				@Report as varchar (256)	
--				)
--AS


-- **********************************************************************************************************************************************	
--		CODIGO QUE CREA LAS PESTAÑAS DEL DASHBOARD con la informacion de los KPIs Extra:
--
--	Se cojen los TEST IDs correspondientes a las fechas e imes de cada una de las tablas por servicio disponible
--	
--	Se realizan todos los filtrados al inicio del codigo a la hora de sacar los test de las tablas generales existentes:
--		Filtrado por pagina del dashboard - tecnologia
--		Filtrado por ciudad		- NED
--		Filtrado por provincia	- paso1
--
--
-- **********************************************************************************************************************************************	

-- select distinct imei, mnc from Lcc_Data_HTTPTransfer_DL_3C
---------------------------
--- Testing Variables -----
---------------------------
--use FY1718_TEST_CECI

----exec sp_MDD_Data_NED_Libro_Resumen_KPIs_Extra_4G_FY1617_GRID 'MOLINSDEREI', '%%', 1, '%%', '%%', '4G', '%%', 'VDF'

--declare @ciudad as varchar(256) = 'BILBAO'
--declare @provincia as varchar(256) = '%%'
declare @simOperator as int = 5
declare @sheet as varchar(256) = '%%' --%%/LTE/WCDMA
--declare @date as varchar(256) = ''
declare @Tech as varchar (256) = '4G'
declare @environ as varchar(256) = '%%'
--declare @report as varchar(256) = 'MUN' --VDF (Reporte VDF), OSP (Reporte OSP), MUN (Municipal)

-----------------------------
create table #All_Tests_DL_tech (
	[SessionId] bigint,
	[TestId] bigint,
	[tech] varchar (256),
	[Longitud Final] float,
	[Latitud Final] float,
	[hasCA] varchar(256)
)

create table #All_Tests_UL_tech (
	[SessionId] bigint,
	[TestId] bigint,
	[tech] varchar (256),
	[Longitud Final] float,
	[Latitud Final] float,
	[hasCA] varchar(256)
)

-------------------------------------------------------------------------------
--	FILTROS GLOBALES:
-------------------------------------------------------------------------------		


begin
	insert into #All_Tests_DL_Tech
	select v.sessionid, v.testid,
		case when v.[% LTE]=1 then 'LTE'
			 when v.[% WCDMA]=1 then 'WCDMA'
		else 'Mixed' end as tech,
		v.[Longitud Final], v.[Latitud Final],
		case when v.[% CA] >0 then 'CA'
		else 'SC' end as hasCA

	from Lcc_Data_HTTPTransfer_DL v, testinfo t
	Where t.testid=v.testid
		and t.valid=1
		--and v.collectionname like @Date + '%' + @ciudad + '%' + @Tech and
		and v.info='completed' --DGP 17/09/2015: Filtramos solo los tests marcados como completados
		and v.MNC = @simOperator	--MNC
		and v.MCC= 202					--MCC - Descartamos los valores erróneos


	group by v.sessionid, v.testid,
		case when v.[% LTE]=1 then 'LTE'
			 when v.[% WCDMA]=1 then 'WCDMA'
		else 'Mixed' end,
		v.[Longitud Final], v.[Latitud Final],
		case when v.[% CA] >0 then 'CA'
		else 'SC' end 


	--- UL - #All_Tests_UL
	insert into #All_Tests_UL_Tech
	select v.sessionid, v.testid, 
		case when v.[% LTE]=1 then 'LTE'
			 when v.[% WCDMA]=1 then 'WCDMA'
		else 'Mixed' end as tech,
		v.[Longitud Final], v.[Latitud Final],
		'SC' hasCA

	from Lcc_Data_HTTPTransfer_UL v
	Where --v.collectionname like @Date + '%' + @ciudad + '%' + @Tech and
		v.info='completed' --DGP 17/09/2015: Filtramos solo los tests marcados como completados
		and v.MNC = @simOperator	--MNC
		and v.MCC= 202						--MCC - Descartamos los valores erróneos
		
	group by v.sessionid, v.testid, 
		case when v.[% LTE]=1 then 'LTE'
			 when v.[% WCDMA]=1 then 'WCDMA'
		else 'Mixed' end,
		v.[Longitud Final], v.[Latitud Final]
end


-- Juntamos todos los id:
select * into #All_Tests_all_Tech from #All_Tests_DL_Tech union all
select * from #All_Tests_UL_Tech 


-- En funcion de la pestaña que sea, se filtra por la tecnologia de interes
--	declare @sheet as varchar(256) = 'LTE'

--DGP 16/09/2015: Cambiamos el procesado para sacar el procesado para CA only
--------------------------------------------------------------------------------
declare @sheet1 as varchar(255)
declare @CA as varchar(255)

If @sheet = 'CA'
begin
	set @sheet1 = 'LTE'
	set @CA='%CA%'
end
else 
begin
	set @sheet1 = @sheet
	set @CA='%%'
end
-------------------------------------------------------------------------------
select * into #All_Tests from #All_Tests_all_Tech where tech like @sheet1


------------------------------------------------------------------------------------
------------------------------- SELECT GENERAL
---------------- All Sheet for KPI dATA Aggregated Info Book
-- DGP 23/11/2015: Se le aplica el filtro por GPS a las medidas de BenchMarker
------------------------------------------------------------------------------------
select testid,RSRP_avg from Lcc_Data_HTTPTransfer_DL where mnc=5 
if (db_name() like '%Indoor%' or db_name() like '%AVE%')
begin
select 
	-- DOWNLINK CE
	log10(AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then (power(10.0E0,dl.RSRP_avg/10.0E0)) end))*10.0 as 'RSRP_DL_CE',
	log10(AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then (power(10.0E0,dl.RSRQ_avg/10.0E0)) end))*10.0 as 'RSRQ_DL_CE',
	log10(AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then (power(10.0E0,dl.SINR_avg/10.0E0)) end))*10.0 as 'SINR_DL_CE',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[RBs When Allocated] end) as 'RBs',
	MAX(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then abs(ceiling(dl.[RBs When Allocated])) end) as 'Max RBs',

	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[CQI 4G] end) as 'CQI',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then 1.0*dl.[% RI1] end)  as '% RI_1',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then 1.0*dl.[% RI2] end)  as '% RI_2',

	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then 1.0*dl.[% MIMO] end) as '% MIMO',
	
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% GSM] end) as '% GSM',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% WCDMA] end) as '% WCDMA',	
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% LTE] end) as '% LTE',

	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% U2100] end) as '% U2100',	
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% U900] end) as '% U900',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% LTE2600] end) as '% L2600',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% LTE2100] end) as '% L2100',		
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% LTE1800] end) as '% L1800',	
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% LTE800] end) as '% L800',
	
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% QPSK 4G] end) as 'QPSK-4G',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% 16QAM 4G] end) as '16QAM-4G',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% 64QAM 4G] end) as '64QAM-4G',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% 256QAM 4G] end) as '256QAM-4G',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% SC] end) as '% SC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% CA] end) as '% CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% 3C] end) as '% 3C',

	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[HSPA_PCT] end) as '% HSPA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[HSPA+_PCT] end) as '% HSPA+',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[HSPA_DC_PCT] end) as '% HSPA DC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[HSPA+_DC_PCT] end) as '% HSPA+ DC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[5Mhz Bandwidth % SC] end) as '% LTE 5Mhz SC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[10Mhz Bandwidth % SC] end) as '% LTE 10Mhz SC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[15Mhz Bandwidth % SC] end) as '% LTE 15Mhz SC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[20Mhz Bandwidth % SC] end) as '% LTE 20Mhz SC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[15Mhz Bandwidth % CA] end) as '% LTE 15Mhz CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[20Mhz Bandwidth % CA] end) as '% LTE 20Mhz CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[25Mhz Bandwidth % CA] end) as '% LTE 25Mhz CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[30Mhz Bandwidth % CA] end) as '% LTE 30Mhz CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[35Mhz Bandwidth % CA] end) as '% LTE 35Mhz CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[40Mhz Bandwidth % CA] end) as '% LTE 40Mhz CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[25Mhz Bandwidth % 3C] end) as '% LTE 25Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[30Mhz Bandwidth % 3C] end) as '% LTE 30Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[35Mhz Bandwidth % 3C] end) as '% LTE 35Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[40Mhz Bandwidth % 3C] end) as '% LTE 40Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[45Mhz Bandwidth % 3C] end) as '% LTE 45Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[50Mhz Bandwidth % 3C] end) as '% LTE 50Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[55Mhz Bandwidth % 3C] end) as '% LTE 55Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[60Mhz Bandwidth % 3C] end) as '% LTE 60Mhz 3C',

	---- UPLINK CE
	log10(AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then (power(10.0E0,ul.RSRP_avg/10.0E0)) end))*10.0 as 'RSRP_UL_CE',
	log10(AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then (power(10.0E0,ul.RSRQ_avg/10.0E0)) end))*10.0 as 'RSRQ_UL_CE',
	log10(AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then (power(10.0E0,ul.SINR_avg/10.0E0)) end))*10.0 as 'SINR_UL_CE',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[RBs When Allocated] end) as 'RBs',
	MAX(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then abs(ceiling(ul.[RBs When Allocated])) end) as 'Max RBs',

	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[CQI 4G] end) as 'CQI',
	--AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then 1.0*ul.[Rank Indicator] end)  as 'RI',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then 1.0*ul.[% RI1] end)  as '% RI_1',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then 1.0*ul.[% RI2] end)  as '% RI_2',


	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then 1.0*ul.[% MIMO] end) as '% MIMO',
	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% GSM] end) as '% GSM',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% WCDMA] end) as '% WCDMA',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% LTE] end) as '% LTE',

	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% U2100] end) as '% U2100',	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% U900] end) as '% U900',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% LTE2600] end) as '% L2600',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% LTE2100] end) as '% L2100',		
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% LTE1800] end) as '% L1800',	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% LTE800] end) as '% L800',
	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% BPSK 4G] end) as 'BPSK-4G',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% QPSK 4G] end) as 'QPSK-4G',	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% 16QAM 4G] end) as '16QAM-4G',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% 64QAM 4G] end) as '64QAM-4G',
	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[HSPA_PCT] end) as '% HSPA',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[HSPA+_PCT] end) as '% HSPA+',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[HSPA_DC_PCT] end) as '% HSPA DC',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[HSPA+_DC_PCT] end) as '% HSPA+ DC',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[5Mhz Bandwidth % SC] end) as '% LTE 5Mhz SC',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[10Mhz Bandwidth % SC] end) as '% LTE 10Mhz SC',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[15Mhz Bandwidth % SC] end) as '% LTE 15Mhz SC',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[20Mhz Bandwidth % SC] end) as '% LTE 20Mhz SC',


	---- DOWNLINK NC
	log10(AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then (power(10.0E0,dl.RSRP_avg/10.0E0)) end))*10.0 as 'RSCP_DL_NC',
	log10(AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then (power(10.0E0,dl.RSRQ_avg/10.0E0)) end))*10.0 as 'RSRQ_DL_NC',
	log10(AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then (power(10.0E0,dl.SINR_avg/10.0E0)) end))*10.0 as 'SINR_DL_NC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[RBs When Allocated] end) as 'RBs',
	MAX(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then abs(ceiling(dl.[RBs When Allocated])) end) as 'Max RBs',

	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[CQI 4G] end) as 'CQI',
	--AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then 1.0*dl.[Rank Indicator PCC] end)  as 'RI',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then 1.0*dl.[% RI1] end)  as '% RI_1',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then 1.0*dl.[% RI2] end)  as '% RI_2',

	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then 1.0*dl.[% MIMO] end) as '% MIMO',
		
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% GSM] end) as '% GSM',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% WCDMA] end) as '% WCDMA',	
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% LTE] end) as '% LTE',

	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% U2100] end) as '% U2100',	
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% U900] end) as '% U900',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% LTE2600] end) as '% L2600',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% LTE2100] end) as '% L2100',		
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% LTE1800] end) as '% L1800',	
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% LTE800] end) as '% L800',
	
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% QPSK 4G] end) as 'QPSK-4G',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% 16QAM 4G] end) as '16QAM-4G',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% 64QAM 4G] end) as '64QAM-4G',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% 256QAM 4G] end) as '256QAM-4G',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% SC] end) as '% SC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% CA] end) as '% CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% 3C] end) as '% 3C',

	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[HSPA_PCT] end) as '% HSPA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[HSPA+_PCT] end) as '% HSPA+',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[HSPA_DC_PCT] end) as '% HSPA DC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[HSPA+_DC_PCT] end) as '% HSPA+ DC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[5Mhz Bandwidth % SC] end) as '% LTE 5Mhz SC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[10Mhz Bandwidth % SC] end) as '% LTE 10Mhz SC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[15Mhz Bandwidth % SC] end) as '% LTE 15Mhz SC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[20Mhz Bandwidth % SC] end) as '% LTE 20Mhz SC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[15Mhz Bandwidth % CA] end) as '% LTE 15Mhz CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[20Mhz Bandwidth % CA] end) as '% LTE 20Mhz CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[25Mhz Bandwidth % CA] end) as '% LTE 25Mhz CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[30Mhz Bandwidth % CA] end) as '% LTE 30Mhz CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[35Mhz Bandwidth % CA] end) as '% LTE 35Mhz CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[40Mhz Bandwidth % CA] end) as '% LTE 40Mhz CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[25Mhz Bandwidth % 3C] end) as '% LTE 25Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[30Mhz Bandwidth % 3C] end) as '% LTE 30Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[35Mhz Bandwidth % 3C] end) as '% LTE 35Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[40Mhz Bandwidth % 3C] end) as '% LTE 40Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[45Mhz Bandwidth % 3C] end) as '% LTE 45Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[50Mhz Bandwidth % 3C] end) as '% LTE 50Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[55Mhz Bandwidth % 3C] end) as '% LTE 55Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[60Mhz Bandwidth % 3C] end) as '% LTE 60Mhz 3C',
	---- UPLINK NC
	log10(AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then (power(10.0E0,ul.RSRP_avg/10.0E0)) end))*10.0 as 'RSCP_UL_NC',
	log10(AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then (power(10.0E0,ul.RSRQ_avg/10.0E0)) end))*10.0 as 'RSRQ_UL_NC',
	log10(AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then (power(10.0E0,ul.SINR_avg/10.0E0)) end))*10.0 as 'SINR_UL_NC',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[RBs When Allocated] end) as 'RBs',
	MAX(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then abs(ceiling(ul.[RBs When Allocated])) end) as 'Max RBs',

	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[CQI 4G] end) as 'CQI',
	--AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then 1.0*ul.[Rank Indicator] end)  as 'RI',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then 1.0*ul.[% RI1] end)  as '% RI_1',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then 1.0*ul.[% RI2] end)  as '% RI_2',

	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then 1.0*ul.[% MIMO] end) as '% MIMO',
	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% GSM] end) as '% GSM',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% WCDMA] end) as '% WCDMA',	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% LTE] end) as '% LTE',

	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% U2100] end) as '% U2100',	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% U900] end) as '% U900',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% LTE2600] end) as '% L2600',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% LTE2100] end) as '% L2100',		
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% LTE1800] end) as '% L1800',	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% LTE800] end) as '% L800',
	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% BPSK 4G] end) as 'BPSK',	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% QPSK 4G] end) as 'QPSK',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% 16QAM 4G] end) as '16QAM',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% 64QAM 4G] end) as '64QAM',
	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[HSPA_PCT] end) as '% HSPA',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[HSPA+_PCT] end) as '% HSPA+',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[HSPA_DC_PCT] end) as '% HSPA DC',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[HSPA+_DC_PCT] end) as '% HSPA+ DC',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[5Mhz Bandwidth % SC] end) as '% LTE 5Mhz SC',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[10Mhz Bandwidth % SC] end) as '% LTE 10Mhz SC',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[15Mhz Bandwidth % SC] end) as '% LTE 15Mhz SC',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[20Mhz Bandwidth % SC] end) as '% LTE 20Mhz SC'


from 
	TestInfo test,
	#All_Tests t
		LEFT OUTER JOIN Lcc_Data_HTTPTransfer_DL dl		on dl.sessionid=t.sessionid and dl.testid=t.testid
		LEFT OUTER JOIN Lcc_Data_HTTPTransfer_UL ul		on ul.sessionid=t.sessionid and ul.testid=t.testid

where test.SessionId=t.SessionId and test.TestId=t.TestId
	and test.valid=1
	-- DGP 16/09/2015: Si estamos en la hoja CA solo sacamos los resultados con Carrier Aggregation
	and t.hasCA like @CA	

	OPTION (OPTIMIZE FOR UNKNOWN)
end

else
begin
select 
	-- DOWNLINK CE
	log10(AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then (power(10.0E0,dl.RSRP_avg/10.0E0)) end))*10.0 as 'RSRP_DL_CE',
	log10(AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then (power(10.0E0,dl.RSRQ_avg/10.0E0)) end))*10.0 as 'RSRQ_DL_CE',
	log10(AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then (power(10.0E0,dl.SINR_avg/10.0E0)) end))*10.0 as 'SINR_DL_CE',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[RBs When Allocated] end) as 'RBs',
	MAX(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then abs(ceiling(dl.[RBs When Allocated])) end) as 'Max RBs',

	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[CQI 4G] end) as 'CQI',
	--AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then 1.0*dl.[Rank Indicator PCC] end)  as 'RI',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then 1.0*dl.[% RI1] end)  as '% RI_1',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then 1.0*dl.[% RI2] end)  as '% RI_2',

	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then 1.0*dl.[% MIMO] end) as '% MIMO',
	
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% GSM] end) as '% GSM',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% WCDMA] end) as '% WCDMA',	
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% LTE] end) as '% LTE',

	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% U2100] end) as '% U2100',	
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% U900] end) as '% U900',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% LTE2600] end) as '% L2600',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% LTE2100] end) as '% L2100',		
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% LTE1800] end) as '% L1800',	
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% LTE800] end) as '% L800',
	
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% QPSK 4G] end) as 'QPSK-4G',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% 16QAM 4G] end) as '16QAM-4G',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% 64QAM 4G] end) as '64QAM-4G',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% 256QAM 4G] end) as '256QAM-4G',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% SC] end) as '% SC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% CA] end) as '% CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[% 3C] end) as '% 3C',

	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[HSPA_PCT] end) as '% HSPA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[HSPA+_PCT] end) as '% HSPA+',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[HSPA_DC_PCT] end) as '% HSPA DC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[HSPA+_DC_PCT] end) as '% HSPA+ DC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[5Mhz Bandwidth % SC] end) as '% LTE 5Mhz SC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[10Mhz Bandwidth % SC] end) as '% LTE 10Mhz SC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[15Mhz Bandwidth % SC] end) as '% LTE 15Mhz SC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[20Mhz Bandwidth % SC] end) as '% LTE 20Mhz SC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[15Mhz Bandwidth % CA] end) as '% LTE 15Mhz CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[20Mhz Bandwidth % CA] end) as '% LTE 20Mhz CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[25Mhz Bandwidth % CA] end) as '% LTE 25Mhz CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[30Mhz Bandwidth % CA] end) as '% LTE 30Mhz CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[35Mhz Bandwidth % CA] end) as '% LTE 35Mhz CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[40Mhz Bandwidth % CA] end) as '% LTE 40Mhz CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[25Mhz Bandwidth % 3C] end) as '% LTE 25Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[30Mhz Bandwidth % 3C] end) as '% LTE 30Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[35Mhz Bandwidth % 3C] end) as '% LTE 35Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[40Mhz Bandwidth % 3C] end) as '% LTE 40Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[45Mhz Bandwidth % 3C] end) as '% LTE 45Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[50Mhz Bandwidth % 3C] end) as '% LTE 50Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[55Mhz Bandwidth % 3C] end) as '% LTE 55Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_CE') then dl.[60Mhz Bandwidth % 3C] end) as '% LTE 60Mhz 3C',

	---- UPLINK CE
	log10(AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then (power(10.0E0,ul.RSRP_avg/10.0E0)) end))*10.0 as 'RSRP_UL_CE',
	log10(AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then (power(10.0E0,ul.RSRQ_avg/10.0E0)) end))*10.0 as 'RSRQ_UL_CE',
	log10(AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then (power(10.0E0,ul.SINR_avg/10.0E0)) end))*10.0 as 'SINR_UL_CE',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[RBs When Allocated] end) as 'RBs',
	MAX(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then abs(ceiling(ul.[RBs When Allocated])) end) as 'Max RBs',

	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[CQI 4G] end) as 'CQI',
	--AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then 1.0*ul.[Rank Indicator] end)  as 'RI',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then 1.0*ul.[% RI1] end)  as '% RI_1',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then 1.0*ul.[% RI2] end)  as '% RI_2',

	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then 1.0*ul.[% MIMO] end) as '% MIMO',
	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% GSM] end) as '% GSM',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% WCDMA] end) as '% WCDMA',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% LTE] end) as '% LTE',

	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% U2100] end) as '% U2100',	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% U900] end) as '% U900',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% LTE2600] end) as '% L2600',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% LTE2100] end) as '% L2100',		
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% LTE1800] end) as '% L1800',	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% LTE800] end) as '% L800',
	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% BPSK 4G] end) as 'BPSK',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% QPSK 4G] end) as 'QPSK',	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% 16QAM 4G] end) as '16QAM',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[% 64QAM 4G] end) as '64QAM',
	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[HSPA_PCT] end) as '% HSPA',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[HSPA+_PCT] end) as '% HSPA+',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[HSPA_DC_PCT] end) as '% HSPA DC',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[HSPA+_DC_PCT] end) as '% HSPA+ DC',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[5Mhz Bandwidth % SC] end) as '% LTE 5Mhz SC',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[10Mhz Bandwidth % SC] end) as '% LTE 10Mhz SC',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[15Mhz Bandwidth % SC] end) as '% LTE 15Mhz SC',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_CE') then ul.[20Mhz Bandwidth % SC] end) as '% LTE 20Mhz SC',


	---- DOWNLINK NC
	log10(AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then (power(10.0E0,dl.RSRP_avg/10.0E0)) end))*10.0 as 'RSCP_DL_NC',
	log10(AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then (power(10.0E0,dl.RSRQ_avg/10.0E0)) end))*10.0 as 'RSRQ_DL_NC',
	log10(AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then (power(10.0E0,dl.SINR_avg/10.0E0)) end))*10.0 as 'SINR_DL_NC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[RBs When Allocated] end) as 'RBs',
	MAX(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then abs(ceiling(dl.[RBs When Allocated])) end) as 'Max RBs',

	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[CQI 4G] end) as 'CQI',
	--AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then 1.0*dl.[Rank Indicator PCC] end)  as 'RI',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then 1.0*dl.[% RI1] end)  as '% RI_1',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then 1.0*dl.[% RI2] end)  as '% RI_2',

	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then 1.0*dl.[% MIMO] end) as '% MIMO',
		
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% GSM] end) as '% GSM',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% WCDMA] end) as '% WCDMA',	
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% LTE] end) as '% LTE',

	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% U2100] end) as '% U2100',	
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% U900] end) as '% U900',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% LTE2600] end) as '% L2600',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% LTE2100] end) as '% L2100',		
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% LTE1800] end) as '% L1800',	
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% LTE800] end) as '% L800',
	
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% QPSK 4G] end) as 'QPSK-4G',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% 16QAM 4G] end) as '16QAM-4G',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% 64QAM 4G] end) as '64QAM-4G',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% 256QAM 4G] end) as '256QAM-4G',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% SC] end) as '% SC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% CA] end) as '% CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[% 3C] end) as '% 3C',

	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[HSPA_PCT] end) as '% HSPA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[HSPA+_PCT] end) as '% HSPA+',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[HSPA_DC_PCT] end) as '% HSPA DC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[HSPA+_DC_PCT] end) as '% HSPA+ DC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[5Mhz Bandwidth % SC] end) as '% LTE 5Mhz SC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[10Mhz Bandwidth % SC] end) as '% LTE 10Mhz SC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[15Mhz Bandwidth % SC] end) as '% LTE 15Mhz SC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[20Mhz Bandwidth % SC] end) as '% LTE 20Mhz SC',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[15Mhz Bandwidth % CA] end) as '% LTE 15Mhz CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[20Mhz Bandwidth % CA] end) as '% LTE 20Mhz CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[25Mhz Bandwidth % CA] end) as '% LTE 25Mhz CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[30Mhz Bandwidth % CA] end) as '% LTE 30Mhz CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[35Mhz Bandwidth % CA] end) as '% LTE 35Mhz CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[40Mhz Bandwidth % CA] end) as '% LTE 40Mhz CA',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[25Mhz Bandwidth % 3C] end) as '% LTE 25Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[30Mhz Bandwidth % 3C] end) as '% LTE 30Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[35Mhz Bandwidth % 3C] end) as '% LTE 35Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[40Mhz Bandwidth % 3C] end) as '% LTE 40Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[45Mhz Bandwidth % 3C] end) as '% LTE 45Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[50Mhz Bandwidth % 3C] end) as '% LTE 50Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[55Mhz Bandwidth % 3C] end) as '% LTE 55Mhz 3C',
	AVG(case when (dl.direction='Downlink' and dl.TestType='DL_NC') then dl.[60Mhz Bandwidth % 3C] end) as '% LTE 60Mhz 3C',
	---- UPLINK NC
	log10(AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then (power(10.0E0,ul.RSRP_avg/10.0E0)) end))*10.0 as 'RSCP_UL_NC',
	log10(AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then (power(10.0E0,ul.RSRQ_avg/10.0E0)) end))*10.0 as 'RSRQ_UL_NC',
	log10(AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then (power(10.0E0,ul.SINR_avg/10.0E0)) end))*10.0 as 'SINR_UL_NC',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[RBs When Allocated] end) as 'RBs',
	MAX(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then abs(ceiling(ul.[RBs When Allocated])) end) as 'Max RBs',

	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[CQI 4G] end) as 'CQI',
	--AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then 1.0*ul.[Rank Indicator] end)  as 'RI',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then 1.0*ul.[% RI1] end)  as '% RI_1',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then 1.0*ul.[% RI2] end)  as '% RI_2',

	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then 1.0*ul.[% MIMO] end) as '% MIMO',
	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% GSM] end) as '% GSM',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% WCDMA] end) as '% WCDMA',	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% LTE] end) as '% LTE',

	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% U2100] end) as '% U2100',	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% U900] end) as '% U900',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% LTE2600] end) as '% L2600',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% LTE2100] end) as '% L2100',		
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% LTE1800] end) as '% L1800',	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% LTE800] end) as '% L800',
	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% BPSK 4G] end) as 'BPSK',	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% QPSK 4G] end) as 'QPSK',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% 16QAM 4G] end) as '16QAM',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[% 64QAM 4G] end) as '64QAM',
	
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[HSPA_PCT] end) as '% HSPA',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[HSPA+_PCT] end) as '% HSPA+',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[HSPA_DC_PCT] end) as '% HSPA DC',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[HSPA+_DC_PCT] end) as '% HSPA+ DC',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[5Mhz Bandwidth % SC] end) as '% LTE 5Mhz SC',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[10Mhz Bandwidth % SC] end) as '% LTE 10Mhz SC',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[15Mhz Bandwidth % SC] end) as '% LTE 15Mhz SC',
	AVG(case when (ul.direction='Uplink' and ul.TestType='UL_NC') then ul.[20Mhz Bandwidth % SC] end) as '% LTE 20Mhz SC'


from 
	TestInfo test,
	#All_Tests t
		LEFT OUTER JOIN Lcc_Data_HTTPTransfer_DL dl		on dl.sessionid=t.sessionid and dl.testid=t.testid
		LEFT OUTER JOIN Lcc_Data_HTTPTransfer_UL ul		on ul.sessionid=t.sessionid and ul.testid=t.testid

where test.SessionId=t.SessionId and test.TestId=t.TestId
	and test.valid=1
	-- DGP 16/09/2015: Si estamos en la hoja CA solo sacamos los resultados con Carrier Aggregation
	and t.hasCA like @CA	

	OPTION (OPTIMIZE FOR UNKNOWN)
end
	
drop table
#All_Tests_DL_Tech, #All_Tests_UL_Tech, #All_Tests, #All_Tests_all_Tech



