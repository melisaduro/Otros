USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_lcc_create_Data_Tables_KPIID_FY1617_ITALY]    Script Date: 27/03/2018 10:30:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [dbo].[sp_lcc_create_Data_Tables_KPIID_FY1617_ITALY] 
as

--select * into Lcc_Data_HTTPBrowser_oldMet from [dbo].[Lcc_Data_HTTPBrowser]
--select * into Lcc_Data_HTTPTransfer_DL_oldMet from [dbo].[Lcc_Data_HTTPTransfer_DL]
--select * into Lcc_Data_HTTPTransfer_UL_oldMet from [dbo].[Lcc_Data_HTTPTransfer_UL]
--select * into Lcc_Data_Latencias_oldMet from [dbo].[Lcc_Data_Latencias]
--select * into Lcc_Data_YOUTUBE_oldMet from [dbo].[Lcc_Data_YOUTUBE]

--exec dbo.sp_lcc_DropIfExists 'Lcc_Data_HTTPTransfer_DL'
--exec dbo.sp_lcc_DropIfExists 'Lcc_Data_HTTPTransfer_UL'
--exec dbo.sp_lcc_DropIfExists 'Lcc_Data_HTTPBrowser'
--exec dbo.sp_lcc_DropIfExists 'Lcc_Data_YOUTUBE'
--exec dbo.sp_lcc_DropIfExists 'Lcc_Data_Latencias'
--drop table #maxTestID

--select * into Lcc_Data_HTTPTransfer_DL from Lcc_Data_HTTPTransfer_DL_oldMethod
--select * into Lcc_Data_HTTPTransfer_UL from Lcc_Data_HTTPTransfer_UL_oldMethod
--select * into Lcc_Data_HTTPBrowser from Lcc_Data_HTTPBrowser_oldMethod
--select * into Lcc_Data_YOUTUBE from Lcc_Data_YOUTUBE_oldMethod
--select * into Lcc_Data_Latencias from Lcc_Data_Latencias_oldMethod


-- NOTAS MENTALES:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	 ********************************************************
--				[sp_Invalidate_Data_After_Import]		-- OJOOO!!! que hay un proc previo que hace cosas para este proc!!
--	 ********************************************************
--
--	OJO!!:
--		- Si hay cambios en:
--			* los tamaños de ficheros:	1/3/500M
--			* el server:				46.24.7.18
--
--	DL/UL:
--		- Tamaños de ficheros:
--			* CE - 3MB
--			* NC - 500MB		-> activado Fixed Duration
--		- Se anulan los resultados test con thput bajos:
--			* CE:	 384Kbps - DataTransferred=null,  TransferTime=null, Throughput=null, [IP Access Time (ms)]=null, ErrorType='Retainability'
--			* DL_NC: 128Kbps - DataTransferred=null,  TransferTime=null, Throughput=null, [IP Access Time (ms)]=null, ErrorType='Retainability'
--			* UL_NC:  64Kbps - DataTransferred=null,  TransferTime=null, Throughput=null, [IP Access Time (ms)]=null, ErrorType='Retainability'
-- WEB:
--		- Urls brow:
--			* kepler/mkepler
--			* kepler2/mkepler2
--		- Session Time incluye el tiempo de DNS (si procede)
--		- Se anulan test que duren mas de 10s - se supone que lo hace la herramienta pero no es así
--			* (transferT>10000 or sessionT>10000): 		ErrorCause='Transfer Timeout',		ErrorType='Retainability', Throughput=null, sessionT=null,
--			* ([IPAccessT]>10000):						ErrorCause='IP Connection Timeout', ErrorType='Accessibility', Throughput=null,	sessionT=null, IPAccessT=null, transferT=null
-- PING:
--		- Test Ping cuentan sólo los success de 32B en cell DCH
--			* cuando llegue el super job con tiempo de IDLE adecuado, comprobar y eliminar la parte de CELL_DCH
--
-- ALL:
--		- Los calculos KPIs se calculan usando los KPIID dados. 
--		  Para test fallidos, no se reportan valores.
--			* se calculan las columnas "_nu" con la metodología antigua para tener información de dichos test.
--			* para los test de browser, la forma antigua es la misma, calculo a la italiana con los KPIID dados.
--		
--		- INVALIDACIONES VARIAS:
--			*	Invalidación de errores de Herramienta										- invalidReason='LCC UEServer Issues'
--			*	Invalidación de tests no marcados como completados							- invalidReason='LCC Not Completed Test'
--			*	Invalidación de tests Youtube con Freeze tras descargar el video completo	- Invalidreason=Invalidreason+' LCC - Freezing after DL Time'
--			*	Invalidamos los tests de Main o Smaller fuera de contorno					- invalidReason='LCC OutOfBounds'
--			*	Invalidamos los tests marcados como fallo por timeout erróneamente			- invalidReason='LCC UL Wrong Timeout'
--			*	Invalidamos los tests con Error<>0 pero test dado por OK (falta triggers)	- invalidReason=invalidReason + ' || LCC Start/End Time missing (at Session/Test end)'

--		- ANULACIONES FINALES:
--			*	Anulamos todos los valores en el caso de errores (where  errortype is not null):
--					- Lcc_Data_HTTPTransfer_DL / Lcc_Data_HTTPTransfer_UL	->	DataTransferred=null,  TransferTime=null, Throughput=null, [IP Access Time (ms)]=null
--					- Lcc_Data_HTTPBrowser									->  [IP Service Setup Time (s)]=null,	[Transfer Time (s)]=null,	[Session Time (s)]=null,	[DNS Resolution (s)]=null

--		- CONVERSIONES VARIAS:
--			*	Convertimos a completadas los tests marcados como fallo erróneamente - Lcc_Data_HTTPBrowser
--			*	En los test de BROW, los campos _nu se calculan con los KPIID tambien (método antiguo)
--					-[DataTransferred]=b.[DataTransferred_nu],
--					-[ErrorCause]=null,
--					-[ErrorType]=null,
--					-[Throughput]=b.[ThputApp_nu],
--					-[IP Service Setup Time (s)]=b.[IP_AccessTime_sec_nu],
--					-[Transfer Time (s)]=b.[Transfer_Time_sec_nu],
--					-[Session Time (s)]=b.[Session_Time_sec_nu],
--					-[DNS Resolution (s)]=b.[DNSTime_nu]	
--	

--************************************************************************************************************
--****************************************** Declaracion de Varibles *****************************************
--************************************************************************************************************

--	(17) Throughput, Bytes Transferred, Errors y Times 4G/3G - HTTP BROWSER
declare @IPAccessTimeWEB as int = 10400
declare @DNSHostResolution as int = 31100

--	(18) TABLA INTERMEDIA Youtube a partir de la vista de SQ 
declare @Player_Access_Timeout as int = 10
declare @Player_Download_Timeout as int = 10 
declare @Video_Access_Timeout as int = 10
declare @Video_Reproduction_Timeout as int = 25

declare @Player_IPServiceAccess_Time as int = 10620
declare @Video_Transfer as int = 20621
declare @min_Interrupt_Duration as int = 1000

-- Nuevos KPIs
declare @Service_Access_Success_Ratio_B1 as int = 79001
declare @Reproductions_Wo_Interruptions_B2 as int = 79002
declare @SuccessFul_Video_Download_B3 as int = 79003
declare @Youtube_HD_Status_B4 as int = 79004
declare @Youtube_Average_Resolution_B5 as int = 79005
declare @Youtube_Visual_Quality_B6 as int = 79006
declare @Youtube_Time_To_First_Image as int = 79007



--	(19) TABLA INTERMEDIA Results KPI
declare @Downlink_Accessibility as int = 75501	-- El duration no es valido (y no lo sera en la vida) - Issue: 470007 
declare @Downlink_Retainability as int = 75502
declare @Downlink_Throughput_D1 as int = 75503	-- Bytes Transferred (value3) no valido - Issue: 470000

declare @Uplink_Accessibility as int = 76001	-- El duration no es valido (y no lo sera en la vida) - Issue: 470007 
declare @Uplink_Retainability as int = 76002
declare @Uplink_Throughput_D3 as int = 76003	-- Bytes Transferred (value3) no valido - Issue: 470000

--Capacity
declare @Downlink_NC_Accessibility_CAP as int = 77501		-- El duration no es valido (y no lo sera en la vida) - Issue: 470007 
declare @Downlink_NC_Retainability_CAP as int = 77502
declare @Downlink_NC_MeanDataUserRate_CAP as int = 77503	-- Bytes Transferred (value3) no valido - Issue: 470000

--Capacity
declare @Uplink_NC_Accessibility_CAP as int = 78001		-- El duration no es valido (y no lo sera en la vida) - Issue: 470007 
declare @Uplink_NC_Retainability_CAP as int = 78002
declare @Uplink_NC_MeanDataUserRate_CAP as int = 78003	-- Bytes Transferred (value3) no valido - Issue: 470000


declare @Latency as int = 78501
declare @sizePing as int = 32

declare @Browser_Accessibility as int = 76501
declare @Browser_Retainability as int = 76502
declare @Browser_TCP_Thput as int  = 30405
declare @Browser_SessionTime as int = 76503
declare @DNSTime as int = 31100

declare @Browser_Accessibility_HTTPS as int = 77001
declare @Browser_Retainability_HTTPS as int = 77002
declare @Browser_TCP_Thput_HTTPS as int  = 30404


--	(20) TABLA INTERMEDIAS DOWNLINK KPI SWISSQUAL
declare @low_Thput_DL_NC as int = 128
declare @low_Thput_DL_CE as int = 384
declare @low_Thput_UL_NC as int = 64
declare @low_Thput_UL_CE as int = 384

--	(22) TABLA INTERMEDIAS BROWSING KPI SWISSQUAL
declare @Browser_Transfer_Timeout as int = 10000
declare @Browser_IP_Connection_Timeout as int = 10000



--************************************************************************************************************************************
--****************************************** CREAMOS LAS TABLAS FINALES VACIAS SI NO EXISTEN *****************************************
--************************************************************************************************************************************

-- Se inicializa el plugin para decodificar de capa 3
exec SQKeyValueInit 'C:\L3KeyValue'

if (select name from sys.all_objects where name='Lcc_Data_HTTPTransfer_DL' and type='U') is null
begin
	CREATE TABLE [dbo].[Lcc_Data_HTTPTransfer_DL](
		[MTU] [char](10) NULL,
		[IMEI] [varchar](50) NULL,
		[CollectionName] [varchar](100) NULL,
		[MCC] [varchar](3) NULL,
		[MNC] [varchar](2) NULL,
		[startDate] [varchar](50) NULL,
		[startTime] [datetime2](3) NULL,
		[endTime] [datetime2](3) NULL,
		[SessionId] [bigint] NULL,
		[FileId] [bigint] NOT NULL,
		[TestId] [bigint] NOT NULL,
		[typeoftest] [varchar](50) NULL,
		[direction] [varchar](20) NULL,
		[info] [varchar](50) NULL,
		[TestType] [varchar](5) NULL,
		[ServiceType] [varchar](1) NULL,
		[IP Access Time (ms)] [int] NULL,
		[DataTransferred] [float] NULL,
		[TransferTime] [float] NULL,
		[ErrorCause] [varchar](1024) NULL,
		[ErrorType] [varchar](1024) NULL,
		[Throughput] [float] NULL,
		[Throughput_MAX] [real] NULL,
		[DataTransferred_PCC] [float] NULL,
		[TransferTime_PCC] [float] NULL,
		[Throughput_PCC] [float] NULL,
		[Throughput_MAX_PCC] [real] NULL,
		[DataTransferred_SCC1] [float] NULL,
		[TransferTime_SCC1] [float] NULL,
		[Throughput_SCC1] [float] NULL,
		[Throughput_MAX_SCC1] [real] NULL,
		[DataTransferred_SCC2] [float] NULL,
		[TransferTime_SCC2] [float] NULL,
		[Throughput_SCC2] [float] NULL,
		[Throughput_MAX_SCC2] [real] NULL,		
		[RLC_MAX] [float] NULL,
		[% LTE] [float] NULL,
		[% WCDMA] [float] NULL,
		[% GSM] [float] NULL,
		[% F1 U2100] [float] NULL,
		[% F2 U2100] [float] NULL,
		[% F3 U2100] [float] NULL,
		[% F1 U900] [float] NULL,
		[% F2 U900] [float] NULL,
		[% U2100] [float] NULL,
		[% U900] [float] NULL,
		[% LTE2600] [float] NULL,
		[% LTE2100] [float] NULL,
		[% LTE1800] [float] NULL,
		[% LTE800] [float] NULL,
		[DCS %] [float] NULL,
		[GSM %] [float] NULL,
		[EGSM %] [float] NULL,
		[Roaming_VF] [float] NULL,
		[Roaming_MV] [float] NULL,
		[Roaming_OR] [float] NULL,
		[Roaming_YO] [float] NULL,
		[Roaming_U900] [float] NULL,
		[Roaming_U2100] [float] NULL,
		[Roaming_LTE800] [float] NULL,
		[Roaming_LTE1800] [float] NULL,
		[Roaming_LTE2100] [float] NULL,
		[Roaming_LTE2600] [float] NULL,
		[Duration_roaming_VF] [float] NULL,
		[Duration_roaming_MV] [float] NULL,
		[Duration_roaming_OR] [float] NULL,
		[Duration_roaming_YO] [float] NULL,
		[Duration_roaming_U900] [float] NULL,
		[Duration_roaming_U2100] [float] NULL,
		[Duration_roaming_LTE800] [float] NULL,
		[Duration_roaming_LTE1800] [float] NULL,
		[Duration_roaming_LTE2100] [float] NULL,
		[Duration_roaming_LTE2600] [float] NULL,
		[% LTE2600_SCC1] [float] NULL,
		[% LTE2100_SCC1] [float] NULL,
		[% LTE1800_SCC1] [float] NULL,
		[% LTE800_SCC1] [float] NULL,
		[% LTE2600_SCC2] [float] NULL,
		[% LTE2100_SCC2] [float] NULL,
		[% LTE1800_SCC2] [float] NULL,
		[% LTE800_SCC2] [float] NULL,		
		[% QPSK 3G] [float] NULL,
		[% 16QAM 3G] [float] NULL,
		[% 64QAM 3G] [float] NULL,
		[Num Codes] [float] NULL,
		[Max Codes] [int] NULL,
		[% Dual Carrier] [float] NULL,
		[Carriers] [int] NULL,
		[% QPSK 4G] [float] NULL,
		[% 16QAM 4G] [float] NULL,
		[% 64QAM 4G] [float] NULL,
		[% 256QAM 4G] [float] NULL,
		[% QPSK 4G PCC] [float] NULL,
		[% 16QAM 4G PCC] [float] NULL,
		[% 64QAM 4G PCC] [float] NULL,
		[% 256QAM 4G PCC] [float] NULL,
		[% QPSK 4G SCC1] [float] NULL,
		[% 16QAM 4G SCC1] [float] NULL,
		[% 64QAM 4G SCC1] [float] NULL,
		[% 256QAM 4G SCC1] [float] NULL,
		[% QPSK 4G SCC2] [float] NULL,
		[% 16QAM 4G SCC2] [float] NULL,
		[% 64QAM 4G SCC2] [float] NULL,	
		[% 256QAM 4G SCC2] [float] NULL,	
		[HSPA_PCT] [float] NULL,
		[HSPA+_PCT] [float] NULL,
		[HSPA_DC_PCT] [float] NULL,
		[HSPA+_DC_PCT] [float] NULL,
		[5Mhz Bandwidth % SC] [float] NULL,
		[10Mhz Bandwidth % SC] [float] NULL,
		[15Mhz Bandwidth % SC] [float] NULL,
		[20Mhz Bandwidth % SC] [float] NULL,
		[15Mhz Bandwidth % CA] [float] NULL,
		[20Mhz Bandwidth % CA] [float] NULL,
		[25Mhz Bandwidth % CA] [float] NULL,
		[30Mhz Bandwidth % CA] [float] NULL,
		[35Mhz Bandwidth % CA] [float] NULL,
		[40Mhz Bandwidth % CA] [float] NULL,		
		[25Mhz Bandwidth % 3C] [float] NULL,
		[30Mhz Bandwidth % 3C] [float] NULL,
		[35Mhz Bandwidth % 3C] [float] NULL,
		[40Mhz Bandwidth % 3C] [float] NULL,
		[45Mhz Bandwidth % 3C] [float] NULL,
		[50Mhz Bandwidth % 3C] [float] NULL,
		[55Mhz Bandwidth % 3C] [float] NULL,
		[60Mhz Bandwidth % 3C] [float] NULL,
		[5Mhz Bandwidth PCC %] [float] NULL,
		[10Mhz Bandwidth PCC %] [float] NULL,
		[15Mhz Bandwidth PCC %] [float] NULL,
		[20Mhz Bandwidth PCC %] [float] NULL,
		[5Mhz Bandwidth SCC1 %] [float] NULL,
		[10Mhz Bandwidth SCC1 %] [float] NULL,
		[15Mhz Bandwidth SCC1 %] [float] NULL,
		[20Mhz Bandwidth SCC1 %] [float] NULL,
		[5Mhz Bandwidth SCC2 %] [float] NULL,
		[10Mhz Bandwidth SCC2 %] [float] NULL,
		[15Mhz Bandwidth SCC2 %] [float] NULL,
		[20Mhz Bandwidth SCC2 %] [float] NULL,		
		[CQI 3G] [float] NULL,
		[% SCCH] [float] NULL,
		[Procesos HARQ] [int] NULL,
		[BLER DSCH] [float] NULL,
		[DTX DSCH] [int] NULL,
		[ACKs] [int] NULL,
		[% NACKs] [float] NULL,
		[Retrx DSCH] [float] NULL,
		[RETRX MAC] [varchar](1) NULL,
		[BLER RLC] [float] NULL,
		[RLC Thput] [float] NULL,
		[RBs] [float] NULL,
		[Max RBs] [float] NULL,
		[Min RBs] [float] NULL,
		[RBs When Allocated] [float] NULL,
		[% TM Invalid] [float] NULL,
		[% TM 1: Single Antenna Port 0 ] [float] NULL,
		[% TM 2: TD Rank 1] [float] NULL,
		[% TM 3: OL SM] [float] NULL,
		[% TM 4: CL SM] [float] NULL,
		[% TM 5: MU MIMO] [float] NULL,
		[% TM 6: CL RANK1 PC] [float] NULL,
		[% TM 7: Single Antenna Port 5] [float] NULL,
		[% TM Unknown] [float] NULL,
		[Shared channel use] [float] NULL,
		[RBs PCC] [float] NULL,
		[Max RBs PCC] [float] NULL,
		[Min RBs PCC] [float] NULL,
		[RBs When Allocated PCC] [float] NULL,
		[% TM Invalid PCC] [float] NULL,
		[% TM 1: Single Antenna Port 0 PCC] [float] NULL,
		[% TM 2: TD Rank 1 PCC] [float] NULL,
		[% TM 3: OL SM PCC] [float] NULL,
		[% TM 4: CL SM PCC] [float] NULL,
		[% TM 5: MU MIMO PCC] [float] NULL,
		[% TM 6: CL RANK1 PC PCC] [float] NULL,
		[% TM 7: Single Antenna Port 5 PCC] [float] NULL,
		[% TM Unknown PCC] [float] NULL,
		[CQI 4G PCC] [float] NULL,
		[RBs SCC1] [float] NULL,
		[Max RBs SCC1] [float] NULL,
		[Min RBs SCC1] [float] NULL,
		[RBs When Allocated SCC1] [float] NULL,
		[% TM Invalid SCC1] [float] NULL,
		[% TM 1: Single Antenna Port 0 SCC1] [float] NULL,
		[% TM 2: TD Rank 1 SCC1] [float] NULL,
		[% TM 3: OL SM SCC1] [float] NULL,
		[% TM 4: CL SM SCC1] [float] NULL,
		[% TM 5: MU MIMO SCC1] [float] NULL,
		[% TM 6: CL RANK1 PC SCC1] [float] NULL,
		[% TM 7: Single Antenna Port 5 SCC1] [float] NULL,
		[% TM Unknown SCC1] [float] NULL,
		[CQI 4G SCC1] [float] NULL,
		[RBs SCC2] [float] NULL,
		[Max RBs SCC2] [float] NULL,
		[Min RBs SCC2] [float] NULL,
		[RBs When Allocated SCC2] [float] NULL,		
		[% TM Invalid SCC2] [float] NULL,
		[% TM 1: Single Antenna Port 0 SCC2] [float] NULL,
		[% TM 2: TD Rank 1 SCC2] [float] NULL,
		[% TM 3: OL SM SCC2] [float] NULL,
		[% TM 4: CL SM SCC2] [float] NULL,
		[% TM 5: MU MIMO SCC2] [float] NULL,
		[% TM 6: CL RANK1 PC SCC2] [float] NULL,
		[% TM 7: Single Antenna Port 5 SCC2] [float] NULL,
		[% TM Unknown SCC2] [float] NULL,		
		[CQI 4G SCC2] [float] NULL,
		[RxLev] [float] NULL,
		[RxQual] [float] NULL,
		[BCCH_Ini] [int] NULL,
		[BSIC_Ini] [int] NULL,
		[RxLev_Ini] [real] NULL,
		[RxQual_Ini] [real] NULL,
		[BCCH_Fin] [int] NULL,
		[BSIC_Fin] [int] NULL,
		[RxLev_Fin] [real] NULL,
		[RxQual_Fin] [real] NULL,
		[RxLev_min] [real] NULL,
		[RxQual_min] [real] NULL,
		[RSCP_avg] [float] NULL,
		[EcI0_avg] [float] NULL,
		[PSC_Ini] [int] NULL,
		[RSCP_Ini] [real] NULL,
		[EcIo_Ini] [real] NULL,
		[UARFCN_Ini] [int] NULL,
		[PSC_Fin] [int] NULL,
		[RSCP_Fin] [real] NULL,
		[EcIo_Fin] [real] NULL,
		[UARFCN_Fin] [int] NULL,
		[RSCP_min] [real] NULL,
		[EcIo_min] [real] NULL,
		[RSRP_avg] [float] NULL,
		[RSRQ_avg] [float] NULL,
		[SINR_avg] [float] NULL,
		[PCI_Ini] [int] NULL,
		[RSRP_Ini] [real] NULL,
		[RSRQ_Ini] [real] NULL,
		[SINR_Ini] [float] NULL,
		[EARFCN_Ini] [int] NULL,
		[PCI_Fin] [int] NULL,
		[RSRP_Fin] [real] NULL,
		[RSRQ_Fin] [real] NULL,
		[SINR_Fin] [float] NULL,
		[EARFCN_Fin] [int] NULL,
		[CellId_Ini] [int] NULL,
		[LAC/TAC_Ini] [int] NULL,
		[RNC_Ini] [int] NULL,
		[CellId_Fin] [int] NULL,
		[LAC/TAC_Fin] [int] NULL,
		[RNC_Fin] [int] NULL,
		[Longitud Inicial] [float] NULL,
		[Latitud Inicial] [float] NULL,
		[Longitud Final] [float] NULL,
		[Latitud Final] [float] NULL,

		-- @DGP: usa de CA
		[Blocks_NoCA] [float] NULL,
		[Blocks_CA] [float] NULL,
		[% SC] [float] NULL,
		[% CA] [float] NULL,
		[% 3C] [float] NULL,
		-- @ERC: Valores sin updates para montar los libros externos de errores de datos
		[ThputApp_nu] [float] NULL,
		[DataTransferred_nu] [float] NULL,
		[SessionTime_nu] [float] NULL,
		[TransferTime_nu] [float] NULL,
		[IPAccessTime_sec_nu] [float] NULL,
		-- @ERC: Valores sin updates para montar los libros externos de errores de datos
		[Tech_Ini] [varchar](50) NULL,
		[Tech_Fin] [varchar](50) NULL,
		-- @DGP: Uso de Dual Carrier desglosado por banda
		[% Dual Carrier U2100] [float] NULL,
		[% Dual Carrier U900] [float] NULL,
		-- @DGP: UL interferences
		[UL_Interference] [real] null,

		-- @ERC: KPIID de P3
		[SessionTime] [float] NULL,

		--@DGP: KPI EXTRAS CEM
		[PDP_Activate_Ratio] [float] NULL,
		[Paging_Success_Ratio] [float] NULL,
		[EARFCN_N1] [int] NULL,
		[PCI_N1] [int] NULL,
		[RSRP_N1] [real] NULL,
		[RSRQ_N1] [real] NULL,
		[num_HO_S1X2] [int] NULL,
		[duration_S1X2_avg] [float] NULL,
		[S1X2HO_SR] [float] NULL,
		[Max_Window_Size] [int] NULL,
		
		[TCP_HandShake_Average] [float] NULL,

		--@CAC: CQI por tecnologia
		[CQI UMTS900] [float] NULL,
		[CQI UMTS2100] [float] NULL,		
		[CQI LTE2600] [float] NULL,
		[CQI LTE1800] [float] NULL,
		[CQI LTE800] [float] NULL,
		[CQI LTE2100] [float] NULL,
		[IMSI] [varchar] (50) NULL,

		--@ERC: Cambio MIMO y RI
		[% MIMO] [float] NULL,
		[% RI2_TM2] [float] NULL,
		[% RI2_TM3] [float] NULL,
		[% RI2_TM4] [float] NULL,
		[% MIMO_PCC] [float] NULL,
		[% RI2_TM2_PCC] [float] NULL,
		[% RI2_TM3_PCC] [float] NULL,
		[% RI2_TM4_PCC] [float] NULL,

		[% MIMO_SCC1] [float] NULL,
		[% RI2_TM2_SCC1] [float] NULL,
		[% RI2_TM3_SCC1] [float] NULL,
		[% RI2_TM4_SCC1] [float] NULL,

		[% MIMO_SCC2] [float] NULL,
		[% RI2_TM2_SCC2] [float] NULL,
		[% RI2_TM3_SCC2] [float] NULL,
		[% RI2_TM4_SCC2] [float] NULL,

		[% RI1] [float] NULL,
		[% RI2] [float] NULL,
		[% RI1_PCC] [float] NULL,
		[% RI2_PCC] [float] NULL,
		[% RI1_SCC1] [float] NULL,
		[% RI2_SCC1] [float] NULL,
		[% RI1_SCC2] [float] NULL,
		[% RI2_SCC2] [float] NULL,

		
		--@ERC: Cambio CQI y MIMO/RI:
		[CQI 4G] [float] NULL,
		[CQI LTE2600 PCC] [float] NULL,
		[CQI LTE1800 PCC] [float] NULL,
		[CQI LTE800 PCC] [float] NULL,
		[CQI LTE2100 PCC] [float] NULL,

		[CQI LTE2600 SCC1] [float] NULL,
		[CQI LTE1800 SCC1] [float] NULL,
		[CQI LTE800 SCC1] [float] NULL,
		[CQI LTE2100 SCC1] [float] NULL,

		[CQI LTE2600 SCC2] [float] NULL,
		[CQI LTE1800 SCC2] [float] NULL,
		[CQI LTE800 SCC2] [float] NULL,
		[CQI LTE2100 SCC2] [float] NULL, 

		-- 20170321 - @ERC: Nuevos KPis y parametros:
		[ASideDevice] [varchar](256) NULL,
		[BSideDevice] [varchar](256) NULL,
		[SWVersion] [varchar](256) NULL,

		[HSPA_PCT real] [float] NULL,
		[HSPA+_PCT real] [float] NULL,
		[HSPA_DC_PCT real] [float] NULL,
		[HSPA+_DC_PCT real] [float] NULL,
		[5Mhz Bandwidth % SC real] [float] NULL,
		[10Mhz Bandwidth % SC real] [float] NULL,
		[15Mhz Bandwidth % SC real] [float] NULL,
		[20Mhz Bandwidth % SC real] [float] NULL,
		[15Mhz Bandwidth % CA real] [float] NULL,
		[20Mhz Bandwidth % CA real] [float] NULL,
		[25Mhz Bandwidth % CA real] [float] NULL,
		[30Mhz Bandwidth % CA real] [float] NULL,
		[35Mhz Bandwidth % CA real] [float] NULL,
		[40Mhz Bandwidth % CA real] [float] NULL,		
		[25Mhz Bandwidth % 3C real] [float] NULL,
		[30Mhz Bandwidth % 3C real] [float] NULL,
		[35Mhz Bandwidth % 3C real] [float] NULL,
		[40Mhz Bandwidth % 3C real] [float] NULL,
		[45Mhz Bandwidth % 3C real] [float] NULL,
		[50Mhz Bandwidth % 3C real] [float] NULL,
		[55Mhz Bandwidth % 3C real] [float] NULL,
		[60Mhz Bandwidth % 3C real] [float] NULL,
		[5Mhz Bandwidth PCC % real] [float] NULL,
		[10Mhz Bandwidth PCC % real] [float] NULL,
		[15Mhz Bandwidth PCC % real] [float] NULL,
		[20Mhz Bandwidth PCC % real] [float] NULL,
		[5Mhz Bandwidth SCC1 % real] [float] NULL,
		[10Mhz Bandwidth SCC1 % real] [float] NULL,
		[15Mhz Bandwidth SCC1 % real] [float] NULL,
		[20Mhz Bandwidth SCC1 % real] [float] NULL,
		[5Mhz Bandwidth SCC2 % real] [float] NULL,
		[10Mhz Bandwidth SCC2 % real] [float] NULL,
		[15Mhz Bandwidth SCC2 % real] [float] NULL,
		[20Mhz Bandwidth SCC2 % real] [float] NULL,
		[BW_PCC_est] [int] null,
		[Info_Update] [varchar](256) NULL
)
end

if (select name from sys.all_objects where name='Lcc_Data_HTTPTransfer_UL' and type='U') is null
begin
	CREATE TABLE [dbo].[Lcc_Data_HTTPTransfer_UL](
		[MTU] [char](10) NULL,
		[IMEI] [varchar](50) NULL,
		[CollectionName] [varchar](100) NULL,
		[MCC] [varchar](3) NULL,
		[MNC] [varchar](2) NULL,
		[startDate] [varchar](50) NULL,
		[startTime] [datetime2](3) NULL,
		[endTime] [datetime2](3) NULL,
		[SessionId] [bigint] NULL,
		[FileId] [bigint] NOT NULL,
		[TestId] [bigint] NOT NULL,
		[typeoftest] [varchar](50) NULL,
		[direction] [varchar](20) NULL,
		[info] [varchar](50) NULL,
		[TestType] [varchar](5) NULL,
		[ServiceType] [varchar](1) NULL,
		[IP Access Time (ms)] [int] NULL,
		[DataTransferred] [float] NULL,
		[TransferTime] [float] NULL,
		[ErrorCause] [varchar](1024) NULL,
		[ErrorType] [varchar](1024) NULL,
		[Throughput] [float] NULL,
		[Throughput_MAX] [real] NULL,
		[RLC_MAX] [float] NULL,
		[% LTE] [float] NULL,
		[% WCDMA] [float] NULL,
		[% GSM] [float] NULL,
		[% F1 U2100] [float] NULL,
		[% F2 U2100] [float] NULL,
		[% F3 U2100] [float] NULL,
		[% F1 U900] [float] NULL,
		[% F2 U900] [float] NULL,
		[% U2100] [float] NULL,
		[% U900] [float] NULL,
		[% LTE2600] [float] NULL,
		[% LTE2100] [float] NULL,
		[% LTE1800] [float] NULL,
		[% LTE800] [float] NULL,
		[DCS %] [float] NULL,
		[GSM %] [float] NULL,
		[EGSM %] [float] NULL,
		[Roaming_VF] [float] NULL,
		[Roaming_MV] [float] NULL,
		[Roaming_OR] [float] NULL,
		[Roaming_YO] [float] NULL,
		[Roaming_U900] [float] NULL,
		[Roaming_U2100] [float] NULL,
		[Roaming_LTE800] [float] NULL,
		[Roaming_LTE1800] [float] NULL,
		[Roaming_LTE2100] [float] NULL,
		[Roaming_LTE2600] [float] NULL,
		[Duration_roaming_VF] [float] NULL,
		[Duration_roaming_MV] [float] NULL,
		[Duration_roaming_OR] [float] NULL,
		[Duration_roaming_YO] [float] NULL,
		[Duration_roaming_U900] [float] NULL,
		[Duration_roaming_U2100] [float] NULL,
		[Duration_roaming_LTE800] [float] NULL,
		[Duration_roaming_LTE1800] [float] NULL,
		[Duration_roaming_LTE2100] [float] NULL,
		[Duration_roaming_LTE2600] [float] NULL,
		[% SF22] [float] NULL,
		[% SF22andSF42] [float] NULL,
		[% SF4] [float] NULL,
		[% SF42] [float] NULL,
		[HSUPA 2.0] [varchar](1) NULL,
		[% TTI 2ms] [int] NULL,
		[Carriers] [int] NULL,
		[% Dual Carrier] [float] NULL,
		[% BPSK 4G] [float] NULL,
		[% QPSK 4G] [float] NULL,
		[% 16QAM 4G] [float] NULL,
		[% 64QAM 4G] [float] NULL,
		[HSPA_PCT] [float] NULL,
		[HSPA+_PCT] [float] NULL,
		[HSPA_DC_PCT] [float] NULL,
		[HSPA+_DC_PCT] [float] NULL,
		[5Mhz Bandwidth % SC] [float] NULL,
		[10Mhz Bandwidth % SC] [float] NULL,
		[15Mhz Bandwidth % SC] [float] NULL,
		[20Mhz Bandwidth % SC] [float] NULL,
		[CQI 3G] [float] NULL,
		[HappyRate] [float] NULL,
		[Happy Rate MAX] [real] NULL,
		[Serving Grant] [float] NULL,
		[DTX] [float] NULL,
		[avg TBs size] [int] NULL,
		[% SHO] [float] NULL,
		[ReTrx PDU] [varchar](1) NULL,
		[RBs] [float] NULL,
		[Max RBs] [float] NULL,
		[Min RBs] [float] NULL,
		[RBs When Allocated] [float] NULL,
		[CQI 4G] [float] NULL,
		[Shared channel use] [float] NULL,
		[% TM Invalid] [float] NULL,
		[% TM 1: Single Antenna Port 0] [float] NULL,
		[% TM 2: TD Rank 1] [float] NULL,
		[% TM 3: OL SM] [float] NULL,
		[% TM 4: CL SM] [float] NULL,
		[% TM 5: MU MIMO] [float] NULL,
		[% TM 6: CL RANK1 PC] [float] NULL,
		[% TM 7: Single Antenna Port 5] [float] NULL,
		[% TM 8] [float] NULL,
		[% TM 9] [float] NULL,
		[% TM Unknown] [float] NULL,
		[RxLev] [float] NULL,
		[RxQual] [float] NULL,
		[BCCH_Ini] [int] NULL,
		[BSIC_Ini] [int] NULL,
		[RxLev_Ini] [real] NULL,
		[RxQual_Ini] [real] NULL,
		[BCCH_Fin] [int] NULL,
		[BSIC_Fin] [int] NULL,
		[RxLev_Fin] [real] NULL,
		[RxQual_Fin] [real] NULL,
		[RxLev_min] [real] NULL,
		[RxQual_min] [real] NULL,
		[RSCP_avg] [float] NULL,
		[EcI0_avg] [float] NULL,
		[PSC_Ini] [int] NULL,
		[RSCP_Ini] [real] NULL,
		[EcIo_Ini] [real] NULL,
		[UARFCN_Ini] [int] NULL,
		[PSC_Fin] [int] NULL,
		[RSCP_Fin] [real] NULL,
		[EcIo_Fin] [real] NULL,
		[UARFCN_Fin] [int] NULL,
		[RSCP_min] [real] NULL,
		[EcIo_min] [real] NULL,
		[RSRP_avg] [float] NULL,
		[RSRQ_avg] [float] NULL,
		[SINR_avg] [float] NULL,
		[PCI_Ini] [int] NULL,
		[RSRP_Ini] [real] NULL,
		[RSRQ_Ini] [real] NULL,
		[SINR_Ini] [float] NULL,
		[EARFCN_Ini] [int] NULL,
		[PCI_Fin] [int] NULL,
		[RSRP_Fin] [real] NULL,
		[RSRQ_Fin] [real] NULL,
		[SINR_Fin] [float] NULL,
		[EARFCN_Fin] [int] NULL,
		[CellId_Ini] [int] NULL,
		[LAC/TAC_Ini] [int] NULL,
		[RNC_Ini] [int] NULL,
		[CellId_Fin] [int] NULL,
		[LAC/TAC_Fin] [int] NULL,
		[RNC_Fin] [int] NULL,
		[Longitud Inicial] [float] NULL,
		[Latitud Inicial] [float] NULL,
		[Longitud Final] [float] NULL,
		[Latitud Final] [float] NULL,
		-- @ERC: Valores sin updates para montar los libros externos de errores de datos
		[ThputApp_nu] [float] NULL,
		[DataTransferred_nu] [float] NULL,
		[SessionTime_nu] [float] NULL,
		[TransferTime_nu] [float] NULL,
		[IPAccessTime_sec_nu] [float] NULL,
		-- @ERC: Valores sin updates para montar los libros externos de errores de datos
		[Tech_Ini] [varchar](50) NULL,
		[Tech_Fin] [varchar](50) NULL,
		-- @DGP: Uso de Dual Carrier desglosado por banda
		[% Dual Carrier U2100] [float] NULL,
		[% Dual Carrier U900] [float] NULL,
		-- @DGP: UL interferences
		[UL_Interference] [real] null,
		
		-- @ERC: KPIID de P3
		[SessionTime] [float] NULL,

		--@DGP: KPI EXTRAS CEM
		[PDP_Activate_Ratio] [float] NULL,
		[Paging_Success_Ratio] [float] NULL,
		[EARFCN_N1] [int] NULL,
		[PCI_N1] [int] NULL,
		[RSRP_N1] [real] NULL,
		[RSRQ_N1] [real] NULL,
		[num_HO_S1X2] [int] NULL,
		[duration_S1X2_avg] [float] NULL,
		[S1X2HO_SR] [float] NULL,
		[Max_Window_Size] [int] NULL,
		
		[TCP_HandShake_Average] [float] NULL,

		--@CAC: CQI por tecnologia		
		[CQI UMTS900] [float] NULL,
		[CQI UMTS2100] [float] NULL,
		[CQI LTE2600] [float] NULL,
		[CQI LTE1800] [float] NULL,
		[CQI LTE800] [float] NULL,
		[CQI LTE2100] [float] NULL,
		[IMSI] [varchar] (50) NULL,

		--@ERC: 
		[% MIMO] [float] NULL,
		[% RI2_TM2] [float] NULL,
		[% RI2_TM3] [float] NULL,
		[% RI2_TM4] [float] NULL,

		[% RI1] [float] NULL,
		[% RI2] [float] NULL,
		
		-- 20170321 - @ERC: Nuevos KPis y parametros:
		[ASideDevice] [varchar](256) NULL,
		[BSideDevice] [varchar](256) NULL,
		[SWVersion] [varchar](256) NULL,

		[HSPA_PCT real] [float] NULL,
		[HSPA+_PCT real] [float] NULL,
		[HSPA_DC_PCT real] [float] NULL,
		[HSPA+_DC_PCT real] [float] NULL,
		[5Mhz Bandwidth % SC real] [float] NULL,
		[10Mhz Bandwidth % SC real] [float] NULL,
		[15Mhz Bandwidth % SC real] [float] NULL,
		[20Mhz Bandwidth % SC real] [float] NULL,
		[BW_PCC_est] [int] null,
		[Info_Update] [varchar](256) NULL
	) 
end

if (select name from sys.all_objects where name='Lcc_Data_HTTPBrowser' and type='U') is null
begin
	CREATE TABLE [dbo].[Lcc_Data_HTTPBrowser](
		[MTU] [char](10) NULL,
		[IMEI] [varchar](50) NULL,
		[CollectionName] [varchar](100) NULL,
		[MCC] [varchar](3) NULL,
		[MNC] [varchar](2) NULL,
		[startDate] [varchar](50) NULL,
		[startTime] [datetime2](3) NULL,
		[endTime] [datetime2](3) NULL,
		[SessionId] [bigint] NULL,
		[FileId] [bigint] NOT NULL,
		[TestId] [bigint] NOT NULL,
		[typeoftest] [varchar](50) NULL,
		[direction] [varchar](20) NULL,
		[info] [varchar](50) NULL,
		[TestType] [varchar](23) NULL,
		[ServiceType] [varchar](1) NULL,
		[DataTransferred] [Float] NULL,
		[ErrorCause] [varchar](1031) NULL,
		[ErrorType] [varchar](13) NULL,
		[Throughput] [float] NULL,
		[Throughput_MAX] [real] NULL,	
		[DataTransferred_PCC] [float] NULL,
		[TransferTime_PCC] [float] NULL,
		[Throughput_PCC] [float] NULL,
		[Throughput_MAX_PCC] [real] NULL,
		[DataTransferred_SCC1] [float] NULL,
		[TransferTime_SCC1] [float] NULL,
		[Throughput_SCC1] [float] NULL,
		[Throughput_MAX_SCC1] [real] NULL,
		[DataTransferred_SCC2] [float] NULL,
		[TransferTime_SCC2] [float] NULL,
		[Throughput_SCC2] [float] NULL,
		[Throughput_MAX_SCC2] [real] NULL,
		[IP Service Setup Time (s)] [float] NULL,
		[DNS Resolution (s)] [float] NULL,
		[Transfer Time (s)] [float] NULL,
		[Session Time (s)] [float] NULL,
		[% LTE] [float] NULL,
		[% WCDMA] [float] NULL,
		[% GSM] [float] NULL,
		[% F1 U2100] [float] NULL,
		[% F2 U2100] [float] NULL,
		[% F3 U2100] [float] NULL,
		[% F1 U900] [float] NULL,
		[% F2 U900] [float] NULL,
		[% U2100] [float] NULL,
		[% U900] [float] NULL,
		[% LTE2600] [float] NULL,
		[% LTE2100] [float] NULL,
		[% LTE1800] [float] NULL,
		[% LTE800] [float] NULL,
		[DCS %] [float] NULL,
		[GSM %] [float] NULL,
		[EGSM %] [float] NULL,
		[Roaming_VF] [float] NULL,
		[Roaming_MV] [float] NULL,
		[Roaming_OR] [float] NULL,
		[Roaming_YO] [float] NULL,
		[Roaming_U900] [float] NULL,
		[Roaming_U2100] [float] NULL,
		[Roaming_LTE800] [float] NULL,
		[Roaming_LTE1800] [float] NULL,
		[Roaming_LTE2100] [float] NULL,
		[Roaming_LTE2600] [float] NULL,
		[Duration_roaming_VF] [float] NULL,
		[Duration_roaming_MV] [float] NULL,
		[Duration_roaming_OR] [float] NULL,
		[Duration_roaming_YO] [float] NULL,
		[Duration_roaming_U900] [float] NULL,
		[Duration_roaming_U2100] [float] NULL,
		[Duration_roaming_LTE800] [float] NULL,
		[Duration_roaming_LTE1800] [float] NULL,
		[Duration_roaming_LTE2100] [float] NULL,
		[Duration_roaming_LTE2600] [float] NULL,
		[% LTE2600_SCC1] [float] NULL,
		[% LTE2100_SCC1] [float] NULL,
		[% LTE1800_SCC1] [float] NULL,
		[% LTE800_SCC1] [float] NULL,
		[% LTE2600_SCC2] [float] NULL,
		[% LTE2100_SCC2] [float] NULL,
		[% LTE1800_SCC2] [float] NULL,
		[% LTE800_SCC2] [float] NULL,		
		[% QPSK 3G] [float] NULL,
		[% 16QAM 3G] [float] NULL,
		[% 64QAM 3G] [float] NULL,
		[Num Codes] [float] NULL,
		[Max Codes] [int] NULL,
		[Carriers] [int] NULL,
		[% Dual Carrier] [float] NULL,
		[% QPSK 4G] [float] NULL,
		[% 16QAM 4G] [float] NULL,
		[% 64QAM 4G] [float] NULL,
		[% 256QAM 4G] [float] NULL,
		[% QPSK 4G PCC] [float] NULL,
		[% 16QAM 4G PCC] [float] NULL,
		[% 64QAM 4G PCC] [float] NULL,
		[% 256QAM 4G PCC] [float] NULL,
		[% QPSK 4G SCC1] [float] NULL,
		[% 16QAM 4G SCC1] [float] NULL,
		[% 64QAM 4G SCC1] [float] NULL,
		[% 256QAM 4G SCC1] [float] NULL,
		[% QPSK 4G SCC2] [float] NULL,
		[% 16QAM 4G SCC2] [float] NULL,
		[% 64QAM 4G SCC2] [float] NULL,	
		[% 256QAM 4G SCC2] [float] NULL,
		[HSPA_PCT] [float] NULL,
		[HSPA+_PCT] [float] NULL,
		[HSPA_DC_PCT] [float] NULL,
		[HSPA+_DC_PCT] [float] NULL,
		[5Mhz Bandwidth % SC] [float] NULL,
		[10Mhz Bandwidth % SC] [float] NULL,
		[15Mhz Bandwidth % SC] [float] NULL,
		[20Mhz Bandwidth % SC] [float] NULL,
		[15Mhz Bandwidth % CA] [float] NULL,
		[20Mhz Bandwidth % CA] [float] NULL,
		[25Mhz Bandwidth % CA] [float] NULL,
		[30Mhz Bandwidth % CA] [float] NULL,
		[35Mhz Bandwidth % CA] [float] NULL,
		[40Mhz Bandwidth % CA] [float] NULL,
		[25Mhz Bandwidth % 3C] [float] NULL,
		[30Mhz Bandwidth % 3C] [float] NULL,
		[35Mhz Bandwidth % 3C] [float] NULL,
		[40Mhz Bandwidth % 3C] [float] NULL,
		[45Mhz Bandwidth % 3C] [float] NULL,
		[50Mhz Bandwidth % 3C] [float] NULL,
		[55Mhz Bandwidth % 3C] [float] NULL,
		[60Mhz Bandwidth % 3C] [float] NULL,
		[5Mhz Bandwidth PCC %] [float] NULL,
		[10Mhz Bandwidth PCC %] [float] NULL,
		[15Mhz Bandwidth PCC %] [float] NULL,
		[20Mhz Bandwidth PCC %] [float] NULL,
		[5Mhz Bandwidth SCC1 %] [float] NULL,
		[10Mhz Bandwidth SCC1 %] [float] NULL,
		[15Mhz Bandwidth SCC1 %] [float] NULL,
		[20Mhz Bandwidth SCC1 %] [float] NULL,
		[5Mhz Bandwidth SCC2 %] [float] NULL,
		[10Mhz Bandwidth SCC2 %] [float] NULL,
		[15Mhz Bandwidth SCC2 %] [float] NULL,
		[20Mhz Bandwidth SCC2 %] [float] NULL,		
		[CQI 3G] [float] NULL,
		[% SCCH] [float] NULL,
		[Procesos HARQ] [int] NULL,
		[BLER DSCH] [float] NULL,
		[DTX DSCH] [int] NULL,
		[ACKs] [int] NULL,
		[% NACKs] [float] NULL,
		[Retrx DSCH] [float] NULL,
		[BLER RLC] [float] NULL,
		[RLC Thput] [float] NULL,
		[RBs] [float] NULL,
		[Max RBs] [float] NULL,
		[Min RBs] [float] NULL,
		[RBs When Allocated] [float] NULL,
		[Shared channel use] [float] NULL,
		[RBs PCC] [float] NULL,
		[Max RBs PCC] [float] NULL,
		[Min RBs PCC] [float] NULL,
		[RBs When Allocated PCC] [float] NULL,
		[CQI 4G PCC] [float] NULL,
		[RBs SCC1] [float] NULL,
		[Max RBs SCC1] [float] NULL,
		[Min RBs SCC1] [float] NULL,
		[RBs When Allocated SCC1] [float] NULL,
		[CQI 4G SCC1] [float] NULL,
		[RBs SCC2] [float] NULL,
		[Max RBs SCC2] [float] NULL,
		[Min RBs SCC2] [float] NULL,
		[RBs When Allocated SCC2] [float] NULL,
		[CQI 4G SCC2] [float] NULL,
		[RxLev] [float] NULL,
		[RxQual] [float] NULL,
		[BCCH_Ini] [int] NULL,
		[BSIC_Ini] [int] NULL,
		[RxLev_Ini] [real] NULL,
		[RxQual_Ini] [real] NULL,
		[BCCH_Fin] [int] NULL,
		[BSIC_Fin] [int] NULL,
		[RxLev_Fin] [real] NULL,
		[RxQual_Fin] [real] NULL,
		[RxLev_min] [real] NULL,
		[RxQual_min] [real] NULL,
		[RSCP_avg] [float] NULL,
		[EcI0_avg] [float] NULL,
		[PSC_Ini] [int] NULL,
		[RSCP_Ini] [real] NULL,
		[EcIo_Ini] [real] NULL,
		[UARFCN_Ini] [int] NULL,
		[PSC_Fin] [int] NULL,
		[RSCP_Fin] [real] NULL,
		[EcIo_Fin] [real] NULL,
		[UARFCN_Fin] [int] NULL,
		[RSCP_min] [real] NULL,
		[EcIo_min] [real] NULL,
		[RSRP_avg] [float] NULL,
		[RSRQ_avg] [float] NULL,
		[SINR_avg] [float] NULL,
		[PCI_Ini] [int] NULL,
		[RSRP_Ini] [real] NULL,
		[RSRQ_Ini] [real] NULL,
		[SINR_Ini] [float] NULL,
		[EARFCN_Ini] [int] NULL,
		[PCI_Fin] [int] NULL,
		[RSRP_Fin] [real] NULL,
		[RSRQ_Fin] [real] NULL,
		[SINR_Fin] [float] NULL,
		[EARFCN_Fin] [int] NULL,
		[CellId_Ini] [int] NULL,
		[LAC/TAC_Ini] [int] NULL,
		[RNC_Ini] [int] NULL,
		[CellId_Fin] [int] NULL,
		[LAC/TAC_Fin] [int] NULL,
		[RNC_Fin] [int] NULL,
		[Longitud Inicial] [float] NULL,
		[Latitud Inicial] [float] NULL,
		[Longitud Final] [float] NULL,
		[Latitud Final] [float] NULL,
		[% SC] [float] NULL,
		[% CA] [float] NULL,
		[% 3C] [float] NULL,
		-- @ERC: Valores sin updates para montar los libros externos de errores de datos
		[DataTransferred_nu] [float] NULL, 		
		[ThputApp_nu] [float] NULL,
		-- @ERC: Valores sin updates para montar los libros externos de errores de datos
		[IP_AccessTime_sec_nu] [float] NULL,
		[Transfer_Time_sec_nu] [float] NULL,
		[Session_Time_sec_nu] [float] NULL,
		[DNSTime_nu] [float] NULL,
		-- @ERC: Valores sin updates para montar los libros externos de errores de datos
		[Tech_Ini] [varchar](50) NULL,
		[Tech_Fin] [varchar](50) NULL,
		-- @DGP: Uso de Dual Carrier desglosado por banda
		[% Dual Carrier U2100] [float] NULL,
		[% Dual Carrier U900] [float] NULL,
		-- @DGP: UL interferences
		[UL_Interference] [real] null,
		[Protocol] [varchar] (50) null,

		--@DGP: KPI EXTRAS CEM
		[PDP_Activate_Ratio] [float] NULL,
		[Paging_Success_Ratio] [float] NULL,
		[EARFCN_N1] [int] NULL,
		[PCI_N1] [int] NULL,
		[RSRP_N1] [real] NULL,
		[RSRQ_N1] [real] NULL,
		[num_HO_S1X2] [int] NULL,
		[duration_S1X2_avg] [float] NULL,
		[S1X2HO_SR] [float] NULL,
		[Max_Window_Size] [int] NULL,
		
		[TCP_HandShake_Average] [float] NULL,
		[CQI UMTS900] [float] NULL,
		[CQI UMTS2100] [float] NULL,
		[IMSI] [varchar] (50) NULL,
		
		[% MIMO] [float] NULL,
		[% RI2_TM2] [float] NULL,
		[% RI2_TM3] [float] NULL,
		[% RI2_TM4] [float] NULL,
		[% MIMO_PCC] [float] NULL,
		[% RI2_TM2_PCC] [float] NULL,
		[% RI2_TM3_PCC] [float] NULL,
		[% RI2_TM4_PCC] [float] NULL,

		[% MIMO_SCC1] [float] NULL,
		[% RI2_TM2_SCC1] [float] NULL,
		[% RI2_TM3_SCC1] [float] NULL,
		[% RI2_TM4_SCC1] [float] NULL,

		[% MIMO_SCC2] [float] NULL,
		[% RI2_TM2_SCC2] [float] NULL,
		[% RI2_TM3_SCC2] [float] NULL,
		[% RI2_TM4_SCC2] [float] NULL,

		[% RI1] [float] NULL,
		[% RI2] [float] NULL,
		[% RI1_PCC] [float] NULL,
		[% RI2_PCC] [float] NULL,
		[% RI1_SCC1] [float] NULL,
		[% RI2_SCC1] [float] NULL,
		[% RI1_SCC2] [float] NULL,
		[% RI2_SCC2] [float] NULL,
		[CQI 4G] [float] NULL,
		[CQI LTE2600 PCC] [float] NULL,
		[CQI LTE1800 PCC] [float] NULL,
		[CQI LTE800 PCC] [float] NULL,
		[CQI LTE2100 PCC] [float] NULL,

		-- 20170321 - @ERC: Nuevos KPis y parametros:
		[ASideDevice] [varchar](256) NULL,
		[BSideDevice] [varchar](256) NULL,
		[SWVersion] [varchar](256) NULL,

		[url] [varchar](256) NULL,

		[HSPA_PCT real] [float] NULL,
		[HSPA+_PCT real] [float] NULL,
		[HSPA_DC_PCT real] [float] NULL,
		[HSPA+_DC_PCT real] [float] NULL,
		[5Mhz Bandwidth % SC real] [float] NULL,
		[10Mhz Bandwidth % SC real] [float] NULL,
		[15Mhz Bandwidth % SC real] [float] NULL,
		[20Mhz Bandwidth % SC real] [float] NULL,
		[15Mhz Bandwidth % CA real] [float] NULL,
		[20Mhz Bandwidth % CA real] [float] NULL,
		[25Mhz Bandwidth % CA real] [float] NULL,
		[30Mhz Bandwidth % CA real] [float] NULL,
		[35Mhz Bandwidth % CA real] [float] NULL,
		[40Mhz Bandwidth % CA real] [float] NULL,		
		[25Mhz Bandwidth % 3C real] [float] NULL,
		[30Mhz Bandwidth % 3C real] [float] NULL,
		[35Mhz Bandwidth % 3C real] [float] NULL,
		[40Mhz Bandwidth % 3C real] [float] NULL,
		[45Mhz Bandwidth % 3C real] [float] NULL,
		[50Mhz Bandwidth % 3C real] [float] NULL,
		[55Mhz Bandwidth % 3C real] [float] NULL,
		[60Mhz Bandwidth % 3C real] [float] NULL,
		[5Mhz Bandwidth PCC % real] [float] NULL,
		[10Mhz Bandwidth PCC % real] [float] NULL,
		[15Mhz Bandwidth PCC % real] [float] NULL,
		[20Mhz Bandwidth PCC % real] [float] NULL,
		[5Mhz Bandwidth SCC1 % real] [float] NULL,
		[10Mhz Bandwidth SCC1 % real] [float] NULL,
		[15Mhz Bandwidth SCC1 % real] [float] NULL,
		[20Mhz Bandwidth SCC1 % real] [float] NULL,
		[5Mhz Bandwidth SCC2 % real] [float] NULL,
		[10Mhz Bandwidth SCC2 % real] [float] NULL,
		[15Mhz Bandwidth SCC2 % real] [float] NULL,
		[20Mhz Bandwidth SCC2 % real] [float] NULL,
		[BW_PCC_est] [int] null,
		[Info_Update] [varchar](256) NULL
	)
end

if (select name from sys.all_objects where name='Lcc_Data_YOUTUBE' and type='U') is null
begin
	CREATE TABLE [dbo].[Lcc_Data_YOUTUBE](
		[MTU] [char](10) NULL,
		[IMEI] [varchar](50) NULL,
		[CollectionName] [varchar](100) NULL,
		[MCC] [varchar](3) NULL,
		[MNC] [varchar](2) NULL,
		[startDate] [varchar](50) NULL,
		[startTime] [datetime2](3) NULL,
		[endTime] [datetime2](3) NULL,
		[SessionId] [bigint] NULL,
		[FileId] [bigint] NOT NULL,
		[TestId] [bigint] NOT NULL,
		[typeoftest] [varchar](50) NULL,
		[direction] [varchar](20) NULL,
		[info] [varchar](50) NULL,
		[testname] [varchar](50) NULL,
		[Video Resolution] [varchar](50) NULL,
		[Fails] [varchar](10) NULL,
		[Cause] [varchar](50) NULL,
		[Block Time] [datetime2](3) NULL,
		[Time To First Image [s]]] [float] NULL,
		[Num. Interruptions] [int] NULL,
		[Video Freezing Impairment] [varchar](12) NULL,
		[Accumulated Video Freezing Duration [s]]] [int] NULL,
		[Average Video Freezing Duration [s]]] [int] NULL,
		[Maximum Video Freezing Duration [s]]] [int] NULL,
		[End Status] [varchar](17) NULL,
		[Successful_Video_Download] [varchar](17) NULL,
		[% LTE] [float] NULL,
		[% WCDMA] [float] NULL,
		[% GSM] [float] NULL,
		[% F1 U2100] [float] NULL,
		[% F2 U2100] [float] NULL,
		[% F3 U2100] [float] NULL,
		[% F1 U900] [float] NULL,
		[% F2 U900] [float] NULL,
		[% U2100] [float] NULL,
		[% U900] [float] NULL,
		[% LTE2600] [float] NULL,
		[% LTE2100] [float] NULL,
		[% LTE1800] [float] NULL,
		[% LTE800] [float] NULL,
		[DCS %] [float] NULL,
		[GSM %] [float] NULL,
		[EGSM %] [float] NULL,
		[Roaming_VF] [float] NULL,
		[Roaming_MV] [float] NULL,
		[Roaming_OR] [float] NULL,
		[Roaming_YO] [float] NULL,
		[Roaming_U900] [float] NULL,
		[Roaming_U2100] [float] NULL,
		[Roaming_LTE800] [float] NULL,
		[Roaming_LTE1800] [float] NULL,
		[Roaming_LTE2100] [float] NULL,
		[Roaming_LTE2600] [float] NULL,
		[Duration_roaming_VF] [float] NULL,
		[Duration_roaming_MV] [float] NULL,
		[Duration_roaming_OR] [float] NULL,
		[Duration_roaming_YO] [float] NULL,
		[Duration_roaming_U900] [float] NULL,
		[Duration_roaming_U2100] [float] NULL,
		[Duration_roaming_LTE800] [float] NULL,
		[Duration_roaming_LTE1800] [float] NULL,
		[Duration_roaming_LTE2100] [float] NULL,
		[Duration_roaming_LTE2600] [float] NULL,
		[% LTE2600_SCC1] [float] NULL,
		[% LTE2100_SCC1] [float] NULL,
		[% LTE1800_SCC1] [float] NULL,
		[% LTE800_SCC1] [float]  NULL,
		[% LTE2600_SCC2] [float] NULL,
		[% LTE2100_SCC2] [float] NULL,
		[% LTE1800_SCC2] [float] NULL,
		[% LTE800_SCC2] [float] NULL,		
		[RxLev] [float] NULL,
		[RxQual] [float] NULL,
		[BCCH_Ini] [int] NULL,
		[BSIC_Ini] [int] NULL,
		[RxLev_Ini] [real] NULL,
		[RxQual_Ini] [real] NULL,
		[BCCH_Fin] [int] NULL,
		[BSIC_Fin] [int] NULL,
		[RxLev_Fin] [real] NULL,
		[RxQual_Fin] [real] NULL,
		[RxLev_min] [real] NULL,
		[RxQual_min] [real] NULL,
		[RSCP_avg] [float] NULL,
		[EcI0_avg] [float] NULL,
		[PSC_Ini] [int] NULL,
		[RSCP_Ini] [real] NULL,
		[EcIo_Ini] [real] NULL,
		[UARFCN_Ini] [int] NULL,
		[PSC_Fin] [int] NULL,
		[RSCP_Fin] [real] NULL,
		[EcIo_Fin] [real] NULL,
		[UARFCN_Fin] [int] NULL,
		[RSCP_min] [real] NULL,
		[EcIo_min] [real] NULL,
		[RSRP_avg] [float] NULL,
		[RSRQ_avg] [float] NULL,
		[SINR_avg] [float] NULL,
		[PCI_Ini] [int] NULL,
		[RSRP_Ini] [real] NULL,
		[RSRQ_Ini] [real] NULL,
		[SINR_Ini] [float] NULL,
		[EARFCN_Ini] [int] NULL,
		[PCI_Fin] [int] NULL,
		[RSRP_Fin] [real] NULL,
		[RSRQ_Fin] [real] NULL,
		[SINR_Fin] [float] NULL,
		[EARFCN_Fin] [int] NULL,
		[CellId_Ini] [int] NULL,
		[LAC/TAC_Ini] [int] NULL,
		[RNC_Ini] [int] NULL,
		[CellId_Fin] [int] NULL,
		[LAC/TAC_Fin] [int] NULL,
		[RNC_Fin] [int] NULL,
		[Longitud Inicial] [float] NULL,
		[Latitud Inicial] [float] NULL,
		[Longitud Final] [float] NULL,
		[Latitud Final] [float] NULL,
		-- @ERC: Valores sin updates para montar los libros externos de errores de datos
		[Tech_Ini] [varchar](50) NULL,
		[Tech_Fin] [varchar](50) NULL,

		--@DGP: KPI EXTRAS CEM
		[PDP_Activate_Ratio] [float] NULL,
		[Paging_Success_Ratio] [float] NULL,
		[EARFCN_N1] [int] NULL,
		[PCI_N1] [int] NULL,
		[RSRP_N1] [real] NULL,
		[RSRQ_N1] [real] NULL,
		[num_HO_S1X2] [int] NULL,
		[duration_S1X2_avg] [float] NULL,
		[S1X2HO_SR] [float] NULL,
		[Max_Window_Size] [int] NULL,
		[Buffering_Time_Sec] [float] NULL,
		[Video_MOS] [Float] NULL,
		[TCP_HandShake_Average] [float] NULL,
		[IMSI] [varchar] (50) NULL,
		
		-- 20170321 - @ERC: Nuevos KPis y parametros:
		[ASideDevice] [varchar](256) NULL,
		[BSideDevice] [varchar](256) NULL,
		[SWVersion] [varchar](256) NULL,
		[url] [varchar](256) NULL,
		[YTBVersion] [varchar](256) NULL,
		
		-- 20170401 - @ERC: Nuevos KPis - resoluciones y VMOS por resoluciones
		[1st Resolution] [int] NULL,
		[2nd Resolution] [int] NULL,
		[FirstChangeFromInit] [int] NULL,
		[initialResolution] [int] NULL,
		[finalResolution] [int] NULL,
		[Duration] [int] NULL,
		[TestQualityAvg_B6] [float] NULL,
		[TestQualityAvg_Calc] [float] NULL,
		[144p-VideoDuration] [int] NULL,
		[144p-VideoMOS] [float] NULL,
		[% 144p] [float] NULL,
		[240p-VideoDuration] [int] NULL,
		[240p-VideoMOS] [float] NULL,
		[% 240p] [float] NULL,
		[360p-VideoDuration] [int] NULL,
		[360p-VideoMOS] [float] NULL,
		[% 360p] [float] NULL,
		[480p-VideoDuration] [int] NULL,
		[480p-VideoMOS] [float] NULL,
		[% 480p] [float] NULL,
		[720p-VideoDuration] [int] NULL,
		[720p-VideoMOS] [float] NULL,
		[% 720p] [float] NULL,
		[1080p-VideoDuration] [int] NULL,
		[1080p-VideoMOS] [float] NULL,
		[% 1080p] [float] NULL,
		[Info_Update] [varchar](256) NULL
)
end

if (select name from sys.all_objects where name='Lcc_Data_Latencias' and type='U') is null
begin
	CREATE TABLE [dbo].[Lcc_Data_Latencias](
		[MTU] [char](10) NULL,
		[IMEI] [varchar](50) NULL,
		[CollectionName] [varchar](100) NULL,
		[MCC] [varchar](3) NULL,
		[MNC] [varchar](2) NULL,
		[startDate] [varchar](50) NULL,
		[startTime] [datetime2](3) NULL,
		[endTime] [datetime2](3) NULL,
		[SessionId] [bigint] NULL,
		[FileId] [bigint] NOT NULL,
		[TestId] [bigint] NOT NULL,
		[typeoftest] [varchar](50) NULL,
		[direction] [varchar](20) NULL,
		[info] [varchar](50) NULL,
		[RTT] [int] NULL,
		[% LTE] [float] NULL,
		[% WCDMA] [float] NULL,
		[% GSM] [float] NULL,
		[% F1 U2100] [float] NULL,
		[% F2 U2100] [float] NULL,
		[% F3 U2100] [float] NULL,
		[% F1 U900] [float] NULL,
		[% F2 U900] [float] NULL,
		[% U2100] [float] NULL,
		[% U900] [float] NULL,
		[% LTE2600] [float] NULL,
		[% LTE2100] [float] NULL,
		[% LTE1800] [float] NULL,
		[% LTE800] [float] NULL,
		[DCS %] [float] NULL,
		[GSM %] [float] NULL,
		[EGSM %] [float] NULL,
		[Roaming_VF] [float] NULL,
		[Roaming_MV] [float] NULL,
		[Roaming_OR] [float] NULL,
		[Roaming_YO] [float] NULL,
		[Roaming_U900] [float] NULL,
		[Roaming_U2100] [float] NULL,
		[Roaming_LTE800] [float] NULL,
		[Roaming_LTE1800] [float] NULL,
		[Roaming_LTE2100] [float] NULL,
		[Roaming_LTE2600] [float] NULL,
		[Duration_roaming_VF] [float] NULL,
		[Duration_roaming_MV] [float] NULL,
		[Duration_roaming_OR] [float] NULL,
		[Duration_roaming_YO] [float] NULL,
		[Duration_roaming_U900] [float] NULL,
		[Duration_roaming_U2100] [float] NULL,
		[Duration_roaming_LTE800] [float] NULL,
		[Duration_roaming_LTE1800] [float] NULL,
		[Duration_roaming_LTE2100] [float] NULL,
		[Duration_roaming_LTE2600] [float] NULL,
		[% LTE2600_SCC1] [float] NULL,
		[% LTE2100_SCC1] [float] NULL,
		[% LTE1800_SCC1] [float] NULL,
		[% LTE800_SCC1] [float] NULL,
		[% LTE2600_SCC2] [float] NULL,
		[% LTE2100_SCC2] [float] NULL,
		[% LTE1800_SCC2] [float] NULL,
		[% LTE800_SCC2] [float] NULL,		
		[Longitud Inicial] [float] NULL,
		[Latitud Inicial] [float] NULL,
		[Longitud Final] [float] NULL,
		[Latitud Final] [float] NULL,

		--@DGP: KPI EXTRAS CEM
		[PDP_Activate_Ratio] [float] NULL,
		[Paging_Success_Ratio] [float] NULL,
		[EARFCN_N1] [int] NULL,
		[PCI_N1] [int] NULL,
		[RSRP_N1] [real] NULL,
		[RSRQ_N1] [real] NULL,
		[num_HO_S1X2] [int] NULL,
		[duration_S1X2_avg] [float] NULL,
		[S1X2HO_SR] [float] NULL,
		[TCP_HandShake_Average] [float] NULL,
		[IMSI] [varchar] (50) NULL,
		
		-- 20170321 - @ERC: Nuevos KPis y parametros:
		[ASideDevice] [varchar](256) NULL,
		[BSideDevice] [varchar](256) NULL,
		[SWVersion] [varchar](256) NULL,
		[Info_Update] [varchar](256) NULL
)
end

--********************************************************************************************************************
--****************************************** FILTRADOS POR TESTID de INTERES *****************************************
--********************************************************************************************************************

-- Se cogen el ultimo testid de cada tabla 		
select MAX(testid) as maxTestID into #maxTestID from Lcc_Data_HTTPTransfer_DL union all
select MAX(testid) as maxTestID from Lcc_Data_HTTPTransfer_UL union all
select MAX(testid) as maxTestID from Lcc_Data_HTTPBrowser union all
select MAX(testid) as maxTestID from Lcc_Data_YOUTUBE union all
select MAX(testid) as maxTestID from Lcc_Data_Latencias 


-- Se calculara la info general (tablas intermedias) a partir del testid minimo de la tabla anterior (el primero de de los ultimos)
-- Luego cada tabla final cogera el que le corresponda
declare @maxTestid as int=(select min(ISNULL(maxTestID,0)) from #maxTestID)

declare @maxTestid_DL as int=(select ISNULL(MAX(testid),0) from Lcc_Data_HTTPTransfer_DL)
declare @maxTestid_UL as int=(select ISNULL(MAX(testid),0) from Lcc_Data_HTTPTransfer_UL)
declare @maxTestid_BR as int=(select ISNULL(MAX(testid),0) from Lcc_Data_HTTPBrowser)
declare @maxTestid_YTB as int=(select ISNULL(MAX(testid),0) from Lcc_Data_YOUTUBE)
declare @maxTestid_LAT as int=(select ISNULL(MAX(testid),0) from Lcc_Data_Latencias)

declare @maxSessionid as int=(select ISNULL(min(SessionId),0) from testinfo where testid = @maxTestid)

--La mínima session (si es null el testid lo pasamos a 0 para que se quede con este como mínimo)
declare @minSessionid as int=(select ISNULL(min(SessionId),0) from testinfo where testid = (select min(ISNULL(maxTestID,0)) from #maxTestID))


select 'Calculated SERVING CELL INFO from testid='+CONVERT(varchar(256),@maxTestid)+' to testid='+CONVERT(varchar(256),(select max(TestId) from TestInfo)) info
select 'Calculated PHYSICAL INFO from testid='+CONVERT(varchar(256),@maxTestid)+' to testid='+CONVERT(varchar(256),(select max(TestId) from TestInfo)) info

select 'Updated Lcc_Data_HTTPTransfer_DL from testid='+CONVERT(varchar(256),@maxTestid_DL)+' to testid='+CONVERT(varchar(256),(select max(TestId) from TestInfo)) info
select 'Updated Lcc_Data_HTTPTransfer_UL from testid='+CONVERT(varchar(256),@maxTestid_UL)+' to testid='+CONVERT(varchar(256),(select max(TestId) from TestInfo)) info
select 'Updated Lcc_Data_HTTPBrowser from testid='+CONVERT(varchar(256),@maxTestid_BR)+' to testid='+CONVERT(varchar(256),(select max(TestId) from TestInfo)) info
select 'Updated Lcc_Data_YOUTUBE from testid='+CONVERT(varchar(256),@maxTestid_YTB)+' to testid='+CONVERT(varchar(256),(select max(TestId) from TestInfo)) info
select 'Updated Lcc_Data_Latencias from testid='+CONVERT(varchar(256),@maxTestid_LAT)+' to testid='+CONVERT(varchar(256),(select max(TestId) from TestInfo)) info



--***************************************************************************************************************************
--************************************************ INICIO TABLAS INTERMEDIAS ************************************************
--***************************************************************************************************************************
select 'INICIO TABLAS INTERMEDIAS' info

------------------------------ (1) SERVING CELL  4G/3G/2G	------------------------------
--select 'Se crean las tablas intermedias: (1) SERVING CELL  4G/3G/2G' info
--------------
 --GSM/WCDMA/LTE Radio AVG (Radio Values)		
exec sp_lcc_dropifexists '_TECH_RADIO_AVG_Data'			
select  
	t.sessionid, t.testid, 
	
	-- Para la PCC:
	log10(avg(power(10.0E0,(case when t.band in ('GSM','DCS', 'EGSM') then 1.0 * t.signal end)/10.0E0)))*10 as RxLev,
	log10(avg(power(10.0E0,(case when t.band in ('GSM','DCS', 'EGSM') then 1.0 * t.quality end)/10.0E0)))*10 as RxQual,
	MIN(case when t.band in ('GSM','DCS', 'EGSM') then t.signal  end) as RxLev_min,		
	MIN(case when t.band in ('GSM','DCS', 'EGSM') then t.quality  end) as RxQual_min,		
	MAX(case when t.band in ('GSM','DCS', 'EGSM') then t.signal  end) as RxLev_max,		
	MAX(case when t.band in ('GSM','DCS', 'EGSM') then t.quality  end) as RxQual_max,		
	
	log10(avg(power(10.0E0,(case when t.band  like '%UMTS%' then 1.0 * t.signal end)/10.0E0)))*10 as RSCP,
	log10(avg(power(10.0E0,(case when t.band  like '%UMTS%' then 1.0 * t.quality end)/10.0E0)))*10 as EcIo,
	MIN(case when t.band like '%UMTS%' then t.signal  end) as RSCP_min,		
	MIN(case when t.band like '%UMTS%' then t.quality  end) as EcIo_min,		
	MAX(case when t.band like '%UMTS%' then t.signal  end) as RSCP_max,		
	MAX(case when t.band like '%UMTS%' then t.quality  end) as EcIo_max,	
	
	log10(avg(power(10.0E0,(case when t.band  like '%LTE%' then 1.0 * t.signal end)/10.0E0)))*10 as RSRP,
	log10(avg(power(10.0E0,(case when t.band  like '%LTE%' then 1.0 * t.quality end)/10.0E0)))*10 as RSRQ,
	log10(AVG((POWER(CAST(10 AS float), (case when t.band  like '%LTE%' then 1.0 * t.SINR0 end)/10.0) 
			+ POWER(CAST(10 AS float), (case when t.band  like '%LTE%' then 1.0 * t.SINR1 end)/10.0))/2.0))*10 as SINR,
	MIN(case when t.band like '%LTE%' then t.signal  end) as RSRP_min,		
	MIN(case when t.band like '%LTE%' then t.quality  end) as RSRQ_min,		
	log10(MIN((POWER(CAST(10 AS float), (case when t.band  like '%LTE%' then 1.0 * t.SINR0 end)/10.0) 
			+ POWER(CAST(10 AS float), (case when t.band  like '%LTE%' then 1.0 * t.SINR1 end)/10.0))/2.0))*10 as SINR_min,
	MAX(case when t.band like '%LTE%' then t.signal  end) as RSRP_max,			
	MAX(case when t.band like '%LTE%' then t.quality  end) as RSRQ_max,			
	log10(MAX((POWER(CAST(10 AS float), (case when t.band  like '%LTE%' then 1.0 * t.SINR0 end)/10.0) 
			+ POWER(CAST(10 AS float), (case when t.band  like '%LTE%' then 1.0 * t.SINR1 end)/10.0))/2.0))*10 as SINR_max,	
	
	-- Para las SCC 
	-- SCC1
	log10(avg(power(10.0E0,(case when t.band_SCC1  like '%LTE%' then 1.0 * t.signal_SCC1 end)/10.0E0)))*10 as RSRP_SCC1,
	log10(avg(power(10.0E0,(case when t.band_SCC1  like '%LTE%' then 1.0 * t.quality_SCC1 end)/10.0E0)))*10 as RSRQ_SCC1,
	log10(AVG((POWER(CAST(10 AS float), (case when t.band_SCC1  like '%LTE%' then 1.0 * t.SINR0_SCC1 end)/10.0) 
			+ POWER(CAST(10 AS float), (case when t.band_SCC1  like '%LTE%' then 1.0 * t.SINR1_SCC1 end)/10.0))/2.0))*10 as SINR_SCC1,
	MIN(case when t.band_SCC1 like '%LTE%' then t.signal_SCC1  end) as RSRP_min_SCC1,		
	MIN(case when t.band_SCC1 like '%LTE%' then t.quality_SCC1 end) as RSRQ_min_SCC1,		
	log10(MIN((POWER(CAST(10 AS float), (case when t.band_SCC1  like '%LTE%' then 1.0 * t.SINR0_SCC1 end)/10.0) 
			+ POWER(CAST(10 AS float), (case when t.band_SCC1  like '%LTE%' then 1.0 * t.SINR1_SCC1 end)/10.0))/2.0))*10 as SINR_min_SCC1,
	MAX(case when t.band_SCC1 like '%LTE%' then t.signal_SCC1  end) as RSRP_max_SCC1,			
	MAX(case when t.band_SCC1 like '%LTE%' then t.quality_SCC1  end) as RSRQ_max_SCC1,			
	log10(MAX((POWER(CAST(10 AS float), (case when t.band_SCC1  like '%LTE%' then 1.0 * t.SINR0_SCC1 end)/10.0) 
			+ POWER(CAST(10 AS float), (case when t.band_SCC1  like '%LTE%' then 1.0 * t.SINR1_SCC1 end)/10.0))/2.0))*10 as SINR_max_SCC1,
	
	-- SCC2
	log10(avg(power(10.0E0,(case when t.band_SCC2  like '%LTE%' then 1.0 * t.signal_SCC2 end)/10.0E0)))*10 as RSRP_SCC2,
	log10(avg(power(10.0E0,(case when t.band_SCC2  like '%LTE%' then 1.0 * t.quality_SCC2 end)/10.0E0)))*10 as RSRQ_SCC2,
	log10(AVG((POWER(CAST(10 AS float), (case when t.band_SCC2  like '%LTE%' then 1.0 * t.SINR0_SCC2 end)/10.0) 
			+ POWER(CAST(10 AS float), (case when t.band_SCC2  like '%LTE%' then 1.0 * t.SINR1_SCC2 end)/10.0))/2.0))*10 as SINR_SCC2,
	MIN(case when t.band_SCC2 like '%LTE%' then t.signal_SCC2  end) as RSRP_min_SCC2,		
	MIN(case when t.band_SCC2 like '%LTE%' then t.quality_SCC2 end) as RSRQ_min_SCC2,		
	log10(MIN((POWER(CAST(10 AS float), (case when t.band_SCC2  like '%LTE%' then 1.0 * t.SINR0_SCC2 end)/10.0) 
			+ POWER(CAST(10 AS float), (case when t.band_SCC2  like '%LTE%' then 1.0 * t.SINR1_SCC2 end)/10.0))/2.0))*10 as SINR_min_SCC2,
	MAX(case when t.band_SCC2 like '%LTE%' then t.signal_SCC2  end) as RSRP_max_SCC2,			
	MAX(case when t.band_SCC2 like '%LTE%' then t.quality_SCC2  end) as RSRQ_max_SCC2,			
	log10(MAX((POWER(CAST(10 AS float), (case when t.band_SCC2  like '%LTE%' then 1.0 * t.SINR0_SCC2 end)/10.0) 
			+ POWER(CAST(10 AS float), (case when t.band_SCC2  like '%LTE%' then 1.0 * t.SINR1_SCC2 end)/10.0))/2.0))*10 as SINR_max_SCC2	
into _TECH_RADIO_AVG_Data
from lcc_Serving_Cell_Table t
where t.testid > @maxTestid
group by t.sessionid, t.testid
order by t.SessionId, t.testid

-------------- 
-- GSM/WCDMA/LTE Radio Initial (Radio Values)				
exec sp_lcc_dropifexists '_TECH_RADIO_INI_Data'			
select 
	t.sessionid, t.testid, t.longitude, t.latitude, 
	-- Para la PCC:
	case when t.band in ('GSM','DCS', 'EGSM') then t.Freq  end as BCCH,
	case when t.band in ('GSM','DCS', 'EGSM') then t.signal  end as RxLev,
	case when t.band in ('GSM','DCS', 'EGSM') then t.quality  end as RxQual,
	case when t.band in ('GSM','DCS', 'EGSM') then t.cell  end as BSIC,
	case when t.band like ('%UMTS%') then t.Freq  end as UARFCN,
	case when t.band like ('%UMTS%') then t.signal  end as RSCP,
	case when t.band like ('%UMTS%') then t.quality  end as EcIo,
	case when t.band like ('%UMTS%') then t.cell  end as PSC,
	t.RNCID,
	case when t.band like ('%LTE%') then t.Freq  end as EARFCN,
	case when t.band like ('%LTE%') then t.signal  end as RSRP,
	case when t.band like ('%LTE%') then t.quality  end as RSRQ,
	case when t.band like ('%LTE%') then 
		(10*LOG10(
         (POWER(CAST(10 AS float), (t.SINR0)/10.0)
         +POWER(CAST(10 AS float), (t.SINR1)/10.0)
         )/2.0  ))									end as SINR,	
	case when t.band like ('%LTE%') then t.cell  end as PCI,
	t.CId,
	t.LAC,
	-- @ERC: Se añade tecnologia inicio de test - correspondiente al primer msgid reportado
	t.band as Tech_Ini
	 
into _TECH_RADIO_INI_Data
from lcc_Serving_Cell_Table t
		left outer join 
				(Select sessionid, testid, min(id) as id
				 from lcc_Serving_Cell_Table where testid > @maxTestid
				 group by sessionid, testid) mi on t.SessionId=mi.SessionId
where t.id=mi.id 
	and t.testid > @maxTestid
order by t.SessionId, t.testid

--------------
-- GSM/WCDMA/LTE Radio Final (Radio Values)					
exec sp_lcc_dropifexists '_TECH_RADIO_FIN_Data'			
select 
	t.sessionid, t.testid, t.longitude, t.latitude,
	-- Para la PCC:	
	case when t.band in ('GSM','DCS', 'EGSM') then t.Freq end as BCCH,
	case when t.band in ('GSM','DCS', 'EGSM') then t.signal  end as RxLev,
	case when t.band in ('GSM','DCS', 'EGSM') then t.quality  end as RxQual,
	case when t.band in ('GSM','DCS', 'EGSM') then t.cell end as BSIC,
	case when t.band like ('%UMTS%') then t.Freq  end as UARFCN,
	case when t.band like ('%UMTS%') then t.signal end as RSCP,
	case when t.band like ('%UMTS%') then t.quality  end as EcIo,
	case when t.band like ('%UMTS%') then t.cell end as PSC,
	t.RNCID,
	case when t.band like ('%LTE%') then t.Freq  end as EARFCN,
	case when t.band like ('%LTE%') then t.signal  end as RSRP,
	case when t.band like ('%LTE%') then t.quality  end as RSRQ,
	case when t.band like ('%LTE%') then 
		(10*LOG10(
         (POWER(CAST(10 AS float), (t.SINR0)/10.0)
         +POWER(CAST(10 AS float), (t.SINR1)/10.0)
         )/2.0  ))										end as SINR,	
	case when t.band like ('%LTE%') then t.cell  end as PCI,
	t.CId,
	t.LAC,
	-- @ERC: Se añade tecnologia final de test - correspondiente al ultimo msgid reportado
	t.band as Tech_Fin
	 
into _TECH_RADIO_FIN_Data
from lcc_Serving_Cell_Table t
		left outer join 
				(Select sessionid, testid, max(id) as id
				 from lcc_Serving_Cell_Table where testid > @maxTestid
				 group by sessionid,testid)mi on t.SessionId=mi.SessionId
where t.id=mi.id 
	and t.testid > @maxTestid
order by t.SessionId, t.testid

-------------------------------------------------------------------------------------------------------------------------------------
-- Identificamos el operador de cada test
-------------------------------------------------------------------------------------------------------------------------------------
exec sp_lcc_dropifexists '_test_Operator'	
select t.testid, RIGHT(left(f.imsi,5),2) as mnc, 
	case  RIGHT(left(f.imsi,5),2)
		when '01' then 'Vodafone'
		when '03' then 'Orange'
		when '07' then 'Movistar'
		when '04' then 'Yoigo'
	end as operator
into _test_Operator
from testinfo t, sessions s, filelist f
where t.SessionId=s.SessionId and s.FileId=f.FileId
	and t.valid=1
	and t.testid > @maxTestid

-------------------------------------------------------------------------------------------------------------------------------------
--Acotamos ciertos KPIs al momento de descarga CE/NC, subida CE/NC y navegación. Teniendo en cuenta el acceso (para fails) o no.
-------------------------------------------------------------------------------------------------------------------------------------
--Inicio, Fin: KPIs Retainability
exec sp_lcc_dropifexists '_intervalos'	
select t.sessionid,t.testid,k.kpiid,k.StartTime,k.endTime,
	case when k.duration is not null then k.duration else DATEDIFF(ms,k.starttime,k.endtime) end as duration
into _intervalos
from  testinfo t
	inner join ResultsKpi k 
			on t.sessionid=k.sessionid and t.testid=k.testid and (k.kpiid=75502  or k.kpiid=77502 --DL
				or k.kpiid = 76002 or k.kpiid=78002	--UL
				or k.kpiid=76502 or k.kpiid=77002) --WEB
where t.valid=1
	and t.testid > @maxTestid

--Inicio: KPIs Accessibility. Fin: KPIs Retainability
exec sp_lcc_dropifexists '_intervalos_all'
--DL_CE:
select t.sessionid,t.testid,
	'DL_CE' as kpiid,
	case when k1.testid is not null then k1.StartTime else k2.StartTime end as StartTime,
	case when k2.testid is not null then k2.endTime else k1.endTime end as endTime,
	case when k1.testid is not null and k2.testid is not null then DATEDIFF(ms,k1.StartTime,k2.endTime) 
		when k1.testid is not null then (case when k1.duration is not null then k1.duration else DATEDIFF(ms,k1.starttime,k1.endtime) end)
		when k2.testid is not null then (case when k2.duration is not null then k2.duration else DATEDIFF(ms,k2.starttime,k2.endtime) end)
	end as duration
into _intervalos_all
from  testinfo t	
	left join ResultsKpi k1 on t.sessionid=k1.sessionid and t.testid=k1.testid and k1.kpiid=75501	--DL_CE Access
	left join ResultsKpi k2 on t.sessionid=k2.sessionid and t.testid=k2.testid and k2.kpiid=75502	--DL_CE Retain
where t.valid=1
	and t.testid > @maxTestid and (k1.testid is not null or k2.testid is not null)
--DL_NC:
insert into _intervalos_all
select t.sessionid,t.testid,
	'DL_NC' as kpiid,
	case when k1.testid is not null then k1.StartTime else k2.StartTime end as StartTime,
	case when k2.testid is not null then k2.endTime else k1.endTime end as endTime,
	case when k1.testid is not null and k2.testid is not null then DATEDIFF(ms,k1.StartTime,k2.endTime) 
		when k1.testid is not null then (case when k1.duration is not null then k1.duration else DATEDIFF(ms,k1.starttime,k1.endtime) end)
		when k2.testid is not null then (case when k2.duration is not null then k2.duration else DATEDIFF(ms,k2.starttime,k2.endtime) end)
	end as duration
from  testinfo t	
	left join ResultsKpi k1 on t.sessionid=k1.sessionid and t.testid=k1.testid and k1.kpiid=77501	--DL_NC Access
	left join ResultsKpi k2 on t.sessionid=k2.sessionid and t.testid=k2.testid and k2.kpiid=77502	--DL_NC Retain
where t.valid=1
	and t.testid > @maxTestid and (k1.testid is not null or k2.testid is not null)
--UL_CE:
insert into _intervalos_all
select t.sessionid,t.testid,
	'UL_CE' as kpiid,
	case when k1.testid is not null then k1.StartTime else k2.StartTime end as StartTime,
	case when k2.testid is not null then k2.endTime else k1.endTime end as endTime,
	case when k1.testid is not null and k2.testid is not null then DATEDIFF(ms,k1.StartTime,k2.endTime) 
		when k1.testid is not null then (case when k1.duration is not null then k1.duration else DATEDIFF(ms,k1.starttime,k1.endtime) end)
		when k2.testid is not null then (case when k2.duration is not null then k2.duration else DATEDIFF(ms,k2.starttime,k2.endtime) end)
	end as duration
from  testinfo t	
	left join ResultsKpi k1 on t.sessionid=k1.sessionid and t.testid=k1.testid and k1.kpiid=76001	--UL_CE Access
	left join ResultsKpi k2 on t.sessionid=k2.sessionid and t.testid=k2.testid and k2.kpiid=76002	--UL_CE Retain
where t.valid=1
	and t.testid > @maxTestid and (k1.testid is not null or k2.testid is not null)
--UL_NC:
insert into _intervalos_all
select t.sessionid,t.testid,
	'UL_NC' as kpiid,
	case when k1.testid is not null then k1.StartTime else k2.StartTime end as StartTime,
	case when k2.testid is not null then k2.endTime else k1.endTime end as endTime,
	case when k1.testid is not null and k2.testid is not null then DATEDIFF(ms,k1.StartTime,k2.endTime) 
		when k1.testid is not null then (case when k1.duration is not null then k1.duration else DATEDIFF(ms,k1.starttime,k1.endtime) end)
		when k2.testid is not null then (case when k2.duration is not null then k2.duration else DATEDIFF(ms,k2.starttime,k2.endtime) end)
	end as duration
from  testinfo t	
	left join ResultsKpi k1 on t.sessionid=k1.sessionid and t.testid=k1.testid and k1.kpiid=78001	--UL_NC Access
	left join ResultsKpi k2 on t.sessionid=k2.sessionid and t.testid=k2.testid and k2.kpiid=78002	--UL_NC Retain
where t.valid=1
	and t.testid > @maxTestid and (k1.testid is not null or k2.testid is not null)
--HTTP:
insert into _intervalos_all
select t.sessionid,t.testid,
	'HTTP' as kpiid,
	case when k1.testid is not null then k1.StartTime else k2.StartTime end as StartTime,
	case when k2.testid is not null then k2.endTime else k1.endTime end as endTime,
	case when k1.testid is not null and k2.testid is not null then DATEDIFF(ms,k1.StartTime,k2.endTime) 
		when k1.testid is not null then (case when k1.duration is not null then k1.duration else DATEDIFF(ms,k1.starttime,k1.endtime) end)
		when k2.testid is not null then (case when k2.duration is not null then k2.duration else DATEDIFF(ms,k2.starttime,k2.endtime) end)
	end as duration
from  testinfo t	
	left join ResultsKpi k1 on t.sessionid=k1.sessionid and t.testid=k1.testid and k1.kpiid=76501	--HTTP Access
	left join ResultsKpi k2 on t.sessionid=k2.sessionid and t.testid=k2.testid and k2.kpiid=76502	--HTTP Retain
where t.valid=1
	and t.testid > @maxTestid and (k1.testid is not null or k2.testid is not null)
--HTTPS:
insert into _intervalos_all
select t.sessionid,t.testid,
	'HTTPS' as kpiid,
	case when k1.testid is not null then k1.StartTime else k2.StartTime end as StartTime,
	case when k2.testid is not null then k2.endTime else k1.endTime end as endTime,
	case when k1.testid is not null and k2.testid is not null then DATEDIFF(ms,k1.StartTime,k2.endTime) 
		when k1.testid is not null then (case when k1.duration is not null then k1.duration else DATEDIFF(ms,k1.starttime,k1.endtime) end)
		when k2.testid is not null then (case when k2.duration is not null then k2.duration else DATEDIFF(ms,k2.starttime,k2.endtime) end)
	end as duration
from  testinfo t	
	left join ResultsKpi k1 on t.sessionid=k1.sessionid and t.testid=k1.testid and k1.kpiid=77001	--HTTPS Access
	left join ResultsKpi k2 on t.sessionid=k2.sessionid and t.testid=k2.testid and k2.kpiid=77002	--HTTPS Retain
where t.valid=1
	and t.testid > @maxTestid and (k1.testid is not null or k2.testid is not null)


-------------------------------------------------------------------------------------------------------------------------------------
-- Calculos de las duraciones Serving Cell
-------------------------------------------------------------------------------------------------------------------------------------
--Estimamos el BW dependiendo de la banda de LTE por si la tabla de sistema del BW no se rellena (en test muy rápidos de CE suele pasar)
--Duracion de cada información: inicio = msgTime, fin = msgTime posterior o fin de test
exec sp_lcc_dropifexists '_lcc_Serving_Cell_Table_info'		
select ini.*
	, case when ini.band='LTE2600' then 20 when ini.band='LTE2100' then 5 when ini.band='LTE1800' then 20 when ini.band='LTE800' then 10 end as DLBandWidth_est
	, case when ini.band_SCC1='LTE2600' then 20 when ini.band_SCC1='LTE2100' then 5 when ini.band_SCC1='LTE1800' then 20 when ini.band_SCC1='LTE800' then 10 end as DLBandWidth_SCC1_est
	, case when ini.band_SCC2='LTE2600' then 20 when ini.band_SCC2='LTE2100' then 5 when ini.band_SCC2='LTE1800' then 20 when ini.band_SCC2='LTE800' then 10 end as DLBandWidth_SCC2_est
	,ini.MsgTime as time_ini
	,isnull(fin.MsgTime,DATEADD(ms, t.duration ,t.startTime)) as time_fin
	,DATEDIFF(ms, ini.MsgTime , isnull(fin.MsgTime,DATEADD(ms, t.duration ,t.startTime))) as duration
into _lcc_Serving_Cell_Table_info
from lcc_Serving_Cell_Table ini 
	inner join testinfo t
		on (ini.sessionid = t.sessionid and ini.TestId=t.TestId)			
	left join lcc_Serving_Cell_Table fin
		on (ini.sessionid = fin.sessionid and ini.TestId=fin.TestId and ini.side = fin.side
			and ini.idSide_Test = fin.idSide_Test -1)
where t.valid=1
	and t.testid > @maxTestid

--Acotamos al momento de la descarga, subida, etc, teniendo en cuenta el acceso:
exec sp_lcc_dropifexists '_lcc_Serving_Cell_Table_info_acotada_acc'
select c.*
	,case when k.starttime <= c.time_ini then c.time_ini
		else k.starttime
	end as time_ini_acotado
	,case when c.time_fin <= k.endtime then c.time_fin
		else k.endtime
	end as time_fin_acotado
	,case when k.starttime <= c.time_ini and c.time_fin <= k.endtime then c.duration						--Ini/Fin de la info dentro
		when c.time_ini <= k.starttime and k.endtime <= c.time_fin then k.duration							--Ini anterior y fin dentro, acotamos
		when c.time_ini <= k.starttime and c.time_fin <= k.endtime then DATEDIFF(ms,k.starttime,c.time_fin) --Ini/Fin de la info fuera pero conteniendolo, acotamos
		when k.starttime <= time_ini and k.endtime <= c.time_fin then DATEDIFF(ms,c.time_ini,k.endtime)		--Ini dentro pero fin posterior, acotamos
	end as duration_acotada
into _lcc_Serving_Cell_Table_info_acotada_acc
from  testinfo t
	inner join _intervalos_all k 
		on t.sessionid=k.sessionid and t.testid=k.testid
	left join _lcc_Serving_Cell_Table_info c
		on t.sessionid=c.sessionid and t.testid=c.testid
			and k.starttime < c.time_fin
			and k.endtime > c.time_ini
where t.testid > @maxTestid

--Acotamos al momento de la descarga, subida, etc, SIN tener en cuenta el acceso:
exec sp_lcc_dropifexists '_lcc_Serving_Cell_Table_info_acotada'
select c.*
	,case when k.starttime <= c.time_ini then c.time_ini
		else k.starttime
	end as time_ini_acotado
	,case when c.time_fin <= k.endtime then c.time_fin
		else k.endtime
	end as time_fin_acotado
	,case when k.starttime <= c.time_ini and c.time_fin <= k.endtime then c.duration						--Ini/Fin de la info dentro
		when c.time_ini <= k.starttime and k.endtime <= c.time_fin then k.duration							--Ini anterior y fin dentro, acotamos
		when c.time_ini <= k.starttime and c.time_fin <= k.endtime then DATEDIFF(ms,k.starttime,c.time_fin) --Ini/Fin de la info fuera pero conteniendolo, acotamos
		when k.starttime <= time_ini and k.endtime <= c.time_fin then DATEDIFF(ms,c.time_ini,k.endtime)		--Ini dentro pero fin posterior, acotamos
	end as duration_acotada
into _lcc_Serving_Cell_Table_info_acotada
from  testinfo t
	inner join _intervalos k 
		on t.sessionid=k.sessionid and t.testid=k.testid
	left join _lcc_Serving_Cell_Table_info c
		on t.sessionid=c.sessionid and t.testid=c.testid
			and k.starttime < c.time_fin
			and k.endtime > c.time_ini
where t.testid > @maxTestid

-------------------------------------------------------------------------------------------------------------------------------------
-- Calculo por test de desgloses de tecnologia, uso de roaming y estimacion de BW a partir de la tabla de lcc serving
-------------------------------------------------------------------------------------------------------------------------------------
--Info acotada al momento de la descarga, subida, navegacion y reproduccion
exec sp_lcc_dropifexists '_Serving_Info_acotado'			
select 
	td.sessionid, td.testid, 
	----------------------------------------------------------------------
	--Info tecnologia, roaming
	----------------------------------------------------------------------	
	-- Frecuencias U2100:
	1.0*sum(case when td.Freq in (10638,10788,10713,10563) then td.duration_acotada end) as Duration_F1_U2100,
	1.0*sum(case when td.Freq in (10663,10813,10738,10588) then td.duration_acotada end) as Duration_F2_U2100,
	1.0*sum(case when td.Freq in (10688,10838,10763,10613) then td.duration_acotada end) as Duration_F3_U2100,	
	-- Frecuencias U900:
	1.0*sum(case when td.Freq in (3062, 3011, 2959) then td.duration_acotada end) as Duration_F1_U900,
	1.0*sum(case when td.Freq in (3087, 3022) then td.duration_acotada end) as Duration_F2_U900,	
	-- Desglose tecnologia (referida a primera carrier):
	1.0*sum(case when td.band like '%LTE%' then td.duration_acotada end) as Duration_LTE,
	1.0*sum(case when td.band like '%UMTS%' then td.duration_acotada end) as Duration_WCDMA,
	1.0*sum(case when td.band in ('GSM','DCS','EGSM') then td.duration_acotada end) as Duration_GSM,
	--Desglose 4G:
	1.0*sum(case when td.band like 'LTE800' then td.duration_acotada end) as Duration_LTE_800, 
	1.0*sum(case when td.band like 'LTE1800' then td.duration_acotada end) as Duration_LTE_1800,
	1.0*sum(case when td.band like 'LTE2100' then td.duration_acotada end) as Duration_LTE_2100,  
	1.0*sum(case when td.band like 'LTE2600' then td.duration_acotada end) as Duration_LTE_2600, 
	--Desglose 3G:
	1.0*sum(case when td.band like 'UMTS2100' then td.duration_acotada end) as Duration_UMTS_2100, 
	1.0*sum(case when td.band like 'UMTS900' then td.duration_acotada end) as Duration_UMTS_900, 
	--Desglose 2G:
	1.0*sum(case when td.band like 'DCS' then td.duration_acotada end) as Duration_GMS_DCS, 
	1.0*sum(case when td.band like 'EGSM' then td.duration_acotada end) as Duration_GSM_EGSM,
	1.0*sum(case when td.band like 'GSM' then td.duration_acotada end) as Duration_GSM_GSM,
	--Desglose 4G SCC1:
	1.0*sum(case when td.band_SCC1 like 'LTE800' then td.duration_acotada end) as Duration_LTE_800_SCC1, 
	1.0*sum(case when td.band_SCC1 like 'LTE1800' then td.duration_acotada end) as Duration_LTE_1800_SCC1, 
	1.0*sum(case when td.band_SCC1 like 'LTE2100' then td.duration_acotada end) as Duration_LTE_2100_SCC1,
	1.0*sum(case when td.band_SCC1 like 'LTE2600' then td.duration_acotada end) as Duration_LTE_2600_SCC1,
	--Desglose 4G SCC2:
	1.0*sum(case when td.band_SCC2 like 'LTE800' then td.duration_acotada end) as Duration_LTE_800_SCC2, 
	1.0*sum(case when td.band_SCC2 like 'LTE1800' then td.duration_acotada end) as Duration_LTE_1800_SCC2, 
	1.0*sum(case when td.band_SCC2 like 'LTE2100' then td.duration_acotada end) as Duration_LTE_2100_SCC2,
	1.0*sum(case when td.band_SCC2 like 'LTE2600' then td.duration_acotada end) as Duration_LTE_2600_SCC2,
	-- Info de SC / CA / 3C :
	1.0*sum(case when td.band like '%LTE%' and td.band_SCC1 is null and td.band_SCC2 is null then td.duration_acotada else 0 end) as Duration_LTE_SC,
	1.0*sum(case when td.band_SCC1 is not null and td.band_SCC2 is null then td.duration_acotada else 0 end) as Duration_LTE_CA,
	1.0*sum(case when td.band_SCC1 is not null and td.band_SCC2 is not null then td.duration_acotada else 0 end) as Duration_LTE_3C,
	--Info de roaming por operador:
	1.0*sum(case when td.operator <> 'Vodafone' and td.ServingOperator='Vodafone' then td.duration_acotada end) as Roaming_VF, 
	1.0*sum(case when td.operator <> 'Movistar' and td.ServingOperator='Movistar' then td.duration_acotada end) as Roaming_MV, 
	1.0*sum(case when td.operator <> 'Orange' and td.ServingOperator='Orange' then td.duration_acotada end) as Roaming_OR, 
	1.0*sum(case when td.operator <> 'Yoigo' and td.ServingOperator='Yoigo' then td.duration_acotada end) as Roaming_YO,
	1.0*sum(case when td.operator <> 'Vodafone' and td.ServingOperator='Vodafone' and td.band not like '%LTE%' then td.duration_acotada end) as Roaming_VF_sin_LTE, 
	1.0*sum(case when td.operator <> 'Movistar' and td.ServingOperator='Movistar' and td.band not like '%LTE%' then td.duration_acotada end) as Roaming_MV_sin_LTE, 
	1.0*sum(case when td.operator <> 'Orange' and td.ServingOperator='Orange' and td.band not like '%LTE%' then td.duration_acotada end) as Roaming_OR_sin_LTE, 
	1.0*sum(case when td.operator <> 'Yoigo' and td.ServingOperator='Yoigo' and td.band not like '%LTE%' then td.duration_acotada end) as Roaming_YO_sin_LTE,
	1.0*sum(case when td.operator <> 'Vodafone' and td.ServingOperator='Vodafone' and td.band not like '%UMTS%' then td.duration_acotada end) as Roaming_VF_sin_UMTS, 
	1.0*sum(case when td.operator <> 'Movistar' and td.ServingOperator='Movistar' and td.band not like '%UMTS%' then td.duration_acotada end) as Roaming_MV_sin_UMTS, 
	1.0*sum(case when td.operator <> 'Orange' and td.ServingOperator='Orange' and td.band not like '%UMTS%' then td.duration_acotada end) as Roaming_OR_sin_UMTS, 
	1.0*sum(case when td.operator <> 'Yoigo' and td.ServingOperator='Yoigo' and td.band not like '%UMTS%' then td.duration_acotada end) as Roaming_YO_sin_UMTS,
	1.0*sum(case when td.operator <> 'Vodafone' and td.ServingOperator='Vodafone' and td.band not like '%UMTS%' and td.band not like '%LTE%' then td.duration_acotada end) as Roaming_VF_sin_UMTS_LTE, 
	1.0*sum(case when td.operator <> 'Movistar' and td.ServingOperator='Movistar' and td.band not like '%UMTS%' and td.band not like '%LTE%' then td.duration_acotada end) as Roaming_MV_sin_UMTS_LTE, 
	1.0*sum(case when td.operator <> 'Orange' and td.ServingOperator='Orange' and td.band not like '%UMTS%' and td.band not like '%LTE%' then td.duration_acotada end) as Roaming_OR_sin_UMTS_LTE, 
	1.0*sum(case when td.operator <> 'Yoigo' and td.ServingOperator='Yoigo' and td.band not like '%UMTS%' and td.band not like '%LTE%' then td.duration_acotada end) as Roaming_YO_sin_UMTS_LTE,

	--Desglose de roaming por banda:
	1.0*sum(case when td.operator <> td.ServingOperator and td.Band='UMTS900' then td.duration_acotada end) as Roaming_U900,
	1.0*sum(case when td.operator <> td.ServingOperator and td.Band='UMTS2100' then td.duration_acotada end) as Roaming_U2100,
	1.0*sum(case when td.operator <> td.ServingOperator and td.Band='LTE800' then td.duration_acotada end) as Roaming_LTE800,
	1.0*sum(case when td.operator <> td.ServingOperator and td.Band='LTE1800' then td.duration_acotada end) as Roaming_LTE1800,
	1.0*sum(case when td.operator <> td.ServingOperator and td.Band='LTE2100' then td.duration_acotada end) as Roaming_LTE2100,
	1.0*sum(case when td.operator <> td.ServingOperator and td.Band='LTE2600' then td.duration_acotada end) as Roaming_LTE2600,

	--Duraciones para calculo de LTE a traves de tabla de BW:
	1.0*sum(td.duration_acotada) as Duration_total,
	1.0*sum(case when td.band not like '%LTE%' then td.duration_acotada end) as Duration_total_sin_LTE,
	1.0*sum(case when td.band not like '%UMTS%' then td.duration_acotada end) as Duration_total_sin_UMTS,
	1.0*sum(case when td.band not like '%UMTS%' and td.band not like '%LTE%' then td.duration_acotada end) as Duration_total_sin_UMTS_LTE,
	1.0*sum(case when td.band_SCC1 is not null then td.duration_acotada end) as Duration_SCC1, 
	1.0*sum(case when td.band_SCC2 is not null then td.duration_acotada end) as Duration_SCC2, 

	----------------------------------------------------------------------
	-- Informacion de BW a partir de la tabla de Serving
	----------------------------------------------------------------------
	--% PCC (respecto a su partipacion en el test):
	isnull(1.0*sum(case when td.DLBandWidth_est=20 then td.duration_acotada end),0)/ NULLIF(sum(case when td.band like '%LTE%' then td.duration_acotada end),0) as pctLTE_20Mhz_PCC, 		
	isnull(1.0*sum(case when td.DLBandWidth_est=15 then td.duration_acotada end),0)/ NULLIF(sum(case when td.band like '%LTE%' then td.duration_acotada end),0) as pctLTE_15Mhz_PCC, 	
	isnull(1.0*sum(case when td.DLBandWidth_est=10 then td.duration_acotada end),0)/ NULLIF(sum(case when td.band like '%LTE%' then td.duration_acotada end),0) as pctLTE_10Mhz_PCC, 
	isnull(1.0*sum(case when td.DLBandWidth_est=5 then td.duration_acotada end),0)/ NULLIF(sum(case when td.band like '%LTE%' then td.duration_acotada end),0) as pctLTE_5Mhz_PCC, 
	--% SCC1 (respecto a su partipacion en el test):
	isnull(1.0*sum(case when td.DLBandWidth_SCC1_est=20 then td.duration_acotada end),0)/ NULLIF(sum(case when td.band_SCC1 like '%LTE%' then td.duration_acotada end),0) as pctLTE_20Mhz_SCC1, 		
	isnull(1.0*sum(case when td.DLBandWidth_SCC1_est=15 then td.duration_acotada end),0)/ NULLIF(sum(case when td.band_SCC1 like '%LTE%' then td.duration_acotada end),0) as pctLTE_15Mhz_SCC1, 	
	isnull(1.0*sum(case when td.DLBandWidth_SCC1_est=10 then td.duration_acotada end),0)/ NULLIF(sum(case when td.band_SCC1 like '%LTE%' then td.duration_acotada end),0) as pctLTE_10Mhz_SCC1, 
	isnull(1.0*sum(case when td.DLBandWidth_SCC1_est=5 then td.duration_acotada end),0)/ NULLIF(sum(case when td.band_SCC1 like '%LTE%' then td.duration_acotada end),0) as pctLTE_5Mhz_SCC1, 
	--% SCC2 (respecto a su partipacion en el test):
	isnull(1.0*sum(case when td.DLBandWidth_SCC2_est=20 then td.duration_acotada end),0)/ NULLIF(sum(case when td.band_SCC2 like '%LTE%' then td.duration_acotada end),0) as pctLTE_20Mhz_SCC2, 		
	isnull(1.0*sum(case when td.DLBandWidth_SCC2_est=15 then td.duration_acotada end),0)/ NULLIF(sum(case when td.band_SCC2 like '%LTE%' then td.duration_acotada end),0) as pctLTE_15Mhz_SCC2, 	
	isnull(1.0*sum(case when td.DLBandWidth_SCC2_est=10 then td.duration_acotada end),0)/ NULLIF(sum(case when td.band_SCC2 like '%LTE%' then td.duration_acotada end),0) as pctLTE_10Mhz_SCC2,
	isnull(1.0*sum(case when td.DLBandWidth_SCC2_est=5 then td.duration_acotada end),0)/ NULLIF(sum(case when td.band_SCC2 like '%LTE%' then td.duration_acotada end),0) as pctLTE_5Mhz_SCC2,
	-- Duraciones de SC
	1.0*sum(case when td.DLBandWidth_SCC1_est is null and td.DLBandWidth_SCC2_est is null and td.DLBandWidth_est=20 then td.duration_acotada end) as DurationLTE_20Mhz_SC, 		
	1.0*sum(case when td.DLBandWidth_SCC1_est is null and td.DLBandWidth_SCC2_est is null and td.DLBandWidth_est=15 then td.duration_acotada end) as DurationLTE_15Mhz_SC, 	
	1.0*sum(case when td.DLBandWidth_SCC1_est is null and td.DLBandWidth_SCC2_est is null and td.DLBandWidth_est=10 then td.duration_acotada end) as DurationLTE_10Mhz_SC, 
	1.0*sum(case when td.DLBandWidth_SCC1_est is null and td.DLBandWidth_SCC2_est is null and td.DLBandWidth_est=5 then td.duration_acotada end) as DurationLTE_5Mhz_SC, 
	-- Duraciones de DC
	1.0*sum(case when td.DLBandWidth_SCC2_est is null and (td.DLBandWidth_est+td.DLBandWidth_SCC1_est)=40 then td.duration_acotada end) as DurationLTE_40Mhz_CA, 		
	1.0*sum(case when td.DLBandWidth_SCC2_est is null and (td.DLBandWidth_est+td.DLBandWidth_SCC1_est)=35 then td.duration_acotada end) as DurationLTE_35Mhz_CA, 	
	1.0*sum(case when td.DLBandWidth_SCC2_est is null and (td.DLBandWidth_est+td.DLBandWidth_SCC1_est)=30 then td.duration_acotada end) as DurationLTE_30Mhz_CA, 
	1.0*sum(case when td.DLBandWidth_SCC2_est is null and (td.DLBandWidth_est+td.DLBandWidth_SCC1_est)=25 then td.duration_acotada end) as DurationLTE_25Mhz_CA, 
	1.0*sum(case when td.DLBandWidth_SCC2_est is null and (td.DLBandWidth_est+td.DLBandWidth_SCC1_est)=20 then td.duration_acotada end) as DurationLTE_20Mhz_CA, 
	1.0*sum(case when td.DLBandWidth_SCC2_est is null and (td.DLBandWidth_est+td.DLBandWidth_SCC1_est)=15 then td.duration_acotada end) as DurationLTE_15Mhz_CA,
	-- Duraciones de 3C
	1.0*sum(case when td.DLBandWidth_est+td.DLBandWidth_SCC1_est+td.DLBandWidth_SCC2_est=60 then td.duration_acotada end) as DurationLTE_60Mhz_3C,
	1.0*sum(case when td.DLBandWidth_est+td.DLBandWidth_SCC1_est+td.DLBandWidth_SCC2_est=55 then td.duration_acotada end) as DurationLTE_55Mhz_3C,
	1.0*sum(case when td.DLBandWidth_est+td.DLBandWidth_SCC1_est+td.DLBandWidth_SCC2_est=50 then td.duration_acotada end) as DurationLTE_50Mhz_3C,
	1.0*sum(case when td.DLBandWidth_est+td.DLBandWidth_SCC1_est+td.DLBandWidth_SCC2_est=45 then td.duration_acotada end) as DurationLTE_45Mhz_3C,
	1.0*sum(case when td.DLBandWidth_est+td.DLBandWidth_SCC1_est+td.DLBandWidth_SCC2_est=40 then td.duration_acotada end) as DurationLTE_40Mhz_3C, 		
	1.0*sum(case when td.DLBandWidth_est+td.DLBandWidth_SCC1_est+td.DLBandWidth_SCC2_est=35 then td.duration_acotada end) as DurationLTE_35Mhz_3C, 	
	1.0*sum(case when td.DLBandWidth_est+td.DLBandWidth_SCC1_est+td.DLBandWidth_SCC2_est=30 then td.duration_acotada end) as DurationLTE_30Mhz_3C, 
	1.0*sum(case when td.DLBandWidth_est+td.DLBandWidth_SCC1_est+td.DLBandWidth_SCC2_est=25 then td.duration_acotada end) as DurationLTE_25Mhz_3C,
	--Duraciones de PCC
	1.0*sum(case when td.DLBandWidth_est=20 then td.duration_acotada end) as DurationLTE_20Mhz_PCC, 
	1.0*sum(case when td.DLBandWidth_est=15 then td.duration_acotada end) as DurationLTE_15Mhz_PCC,
	1.0*sum(case when td.DLBandWidth_est=10 then td.duration_acotada end) as DurationLTE_10Mhz_PCC,  
	1.0*sum(case when td.DLBandWidth_est=5 then td.duration_acotada end) as DurationLTE_5Mhz_PCC, 
	--Duraciones de SCC1
	1.0*sum(case when td.DLBandWidth_SCC1_est=20 then td.duration_acotada end) as DurationLTE_20Mhz_SCC1, 
	1.0*sum(case when td.DLBandWidth_SCC1_est=15 then td.duration_acotada end) as DurationLTE_15Mhz_SCC1,
	1.0*sum(case when td.DLBandWidth_SCC1_est=10 then td.duration_acotada end) as DurationLTE_10Mhz_SCC1,  
	1.0*sum(case when td.DLBandWidth_SCC1_est=5 then td.duration_acotada end) as DurationLTE_5Mhz_SCC1, 
	--Duraciones de SCC2
	1.0*sum(case when td.DLBandWidth_SCC2_est=20 then td.duration_acotada end) as DurationLTE_20Mhz_SCC2, 
	1.0*sum(case when td.DLBandWidth_SCC2_est=15 then td.duration_acotada end) as DurationLTE_15Mhz_SCC2,
	1.0*sum(case when td.DLBandWidth_SCC2_est=10 then td.duration_acotada end) as DurationLTE_10Mhz_SCC2,  
	1.0*sum(case when td.DLBandWidth_SCC2_est=5 then td.duration_acotada end) as DurationLTE_5Mhz_SCC2

into _Serving_Info_acotado
from _lcc_Serving_Cell_Table_info_acotada td
where td.band is not NULL
group by td.sessionid, td.TestId
order by td.sessionid, td.TestId

--Info acotada al momento de la descarga, subida, navegacion y reproduccion, teniendo en cuenta el acceso:
exec sp_lcc_dropifexists '_Serving_Info_acotado_acc'			
select 
	td.sessionid, td.testid, 
	----------------------------------------------------------------------
	--Info tecnologia, roaming
	----------------------------------------------------------------------	
	-- Frecuencias U2100:
	1.0*sum(case when td.Freq in (10638,   10788,  10713,  10563) then td.duration_acotada end) as Duration_F1_U2100,
	1.0*sum(case when td.Freq in (10663,	10813,	10738,	10588) then td.duration_acotada end) as Duration_F2_U2100,
	1.0*sum(case when td.Freq in (10688,	10838,	10763,	10613) then td.duration_acotada end) as Duration_F3_U2100,	
	-- Frecuencias U900:
	1.0*sum(case when td.Freq in (3062, 3011, 2959) then td.duration_acotada end) as Duration_F1_U900,
	1.0*sum(case when td.Freq in (3087, 3022) then td.duration_acotada end) as Duration_F2_U900,
	-- Desglose tecnologia (referida a primera carrier):
	1.0*sum(case when td.band like '%LTE%' then td.duration_acotada end) as Duration_LTE,
	1.0*sum(case when td.band like '%UMTS%' then td.duration_acotada end) as Duration_WCDMA,
	1.0*sum(case when td.band in ('GSM','DCS','EGSM') then td.duration_acotada end) as Duration_GSM,
	--Desglose 4G:
	1.0*sum(case when td.band like 'LTE800' then td.duration_acotada end) as Duration_LTE_800, 
	1.0*sum(case when td.band like 'LTE1800' then td.duration_acotada end) as Duration_LTE_1800,
	1.0*sum(case when td.band like 'LTE2100' then td.duration_acotada end) as Duration_LTE_2100,  
	1.0*sum(case when td.band like 'LTE2600' then td.duration_acotada end) as Duration_LTE_2600, 
	--Desglose 3G:
	1.0*sum(case when td.band like 'UMTS2100' then td.duration_acotada end) as Duration_UMTS_2100, 
	1.0*sum(case when td.band like 'UMTS900' then td.duration_acotada end) as Duration_UMTS_900, 
	--Desglose 2G:
	1.0*sum(case when td.band like 'DCS' then td.duration_acotada end) as Duration_GMS_DCS, 
	1.0*sum(case when td.band like 'EGSM' then td.duration_acotada end) as Duration_GSM_EGSM,
	1.0*sum(case when td.band like 'GSM' then td.duration_acotada end) as Duration_GSM_GSM,
	--Desglose 4G SCC1:
	1.0*sum(case when td.band_SCC1 like 'LTE800' then td.duration_acotada end) as Duration_LTE_800_SCC1, 
	1.0*sum(case when td.band_SCC1 like 'LTE1800' then td.duration_acotada end) as Duration_LTE_1800_SCC1, 
	1.0*sum(case when td.band_SCC1 like 'LTE2100' then td.duration_acotada end) as Duration_LTE_2100_SCC1,
	1.0*sum(case when td.band_SCC1 like 'LTE2600' then td.duration_acotada end) as Duration_LTE_2600_SCC1,
	--Desglose 4G SCC2:
	1.0*sum(case when td.band_SCC2 like 'LTE800' then td.duration_acotada end) as Duration_LTE_800_SCC2, 
	1.0*sum(case when td.band_SCC2 like 'LTE1800' then td.duration_acotada end) as Duration_LTE_1800_SCC2, 
	1.0*sum(case when td.band_SCC2 like 'LTE2100' then td.duration_acotada end) as Duration_LTE_2100_SCC2,
	1.0*sum(case when td.band_SCC2 like 'LTE2600' then td.duration_acotada end) as Duration_LTE_2600_SCC2,
	-- Info de SC / CA / 3C :
	1.0*sum(case when td.band like '%LTE%' and td.band_SCC1 is null and td.band_SCC2 is null then td.duration_acotada else 0 end) as Duration_LTE_SC,
	1.0*sum(case when td.band_SCC1 is not null and td.band_SCC2 is null then td.duration_acotada else 0 end) as Duration_LTE_CA,
	1.0*sum(case when td.band_SCC1 is not null and td.band_SCC2 is not null then td.duration_acotada else 0 end) as Duration_LTE_3C,
	--Info de roaming por operador:
	1.0*sum(case when td.operator <> 'Vodafone' and td.ServingOperator='Vodafone' then td.duration_acotada end) as Roaming_VF, 
	1.0*sum(case when td.operator <> 'Movistar' and td.ServingOperator='Movistar' then td.duration_acotada end) as Roaming_MV, 
	1.0*sum(case when td.operator <> 'Orange' and td.ServingOperator='Orange' then td.duration_acotada end) as Roaming_OR, 
	1.0*sum(case when td.operator <> 'Yoigo' and td.ServingOperator='Yoigo' then td.duration_acotada end) as Roaming_YO,
	1.0*sum(case when td.operator <> 'Vodafone' and td.ServingOperator='Vodafone' and td.band not like '%LTE%' then td.duration_acotada end) as Roaming_VF_sin_LTE, 
	1.0*sum(case when td.operator <> 'Movistar' and td.ServingOperator='Movistar' and td.band not like '%LTE%' then td.duration_acotada end) as Roaming_MV_sin_LTE, 
	1.0*sum(case when td.operator <> 'Orange' and td.ServingOperator='Orange' and td.band not like '%LTE%' then td.duration_acotada end) as Roaming_OR_sin_LTE, 
	1.0*sum(case when td.operator <> 'Yoigo' and td.ServingOperator='Yoigo' and td.band not like '%LTE%' then td.duration_acotada end) as Roaming_YO_sin_LTE,
	1.0*sum(case when td.operator <> 'Vodafone' and td.ServingOperator='Vodafone' and td.band not like '%UMTS%' then td.duration_acotada end) as Roaming_VF_sin_UMTS, 
	1.0*sum(case when td.operator <> 'Movistar' and td.ServingOperator='Movistar' and td.band not like '%UMTS%' then td.duration_acotada end) as Roaming_MV_sin_UMTS, 
	1.0*sum(case when td.operator <> 'Orange' and td.ServingOperator='Orange' and td.band not like '%UMTS%' then td.duration_acotada end) as Roaming_OR_sin_UMTS, 
	1.0*sum(case when td.operator <> 'Yoigo' and td.ServingOperator='Yoigo' and td.band not like '%UMTS%' then td.duration_acotada end) as Roaming_YO_sin_UMTS,
	1.0*sum(case when td.operator <> 'Vodafone' and td.ServingOperator='Vodafone' and td.band not like '%UMTS%' and td.band not like '%LTE%' then td.duration_acotada end) as Roaming_VF_sin_UMTS_LTE, 
	1.0*sum(case when td.operator <> 'Movistar' and td.ServingOperator='Movistar' and td.band not like '%UMTS%' and td.band not like '%LTE%' then td.duration_acotada end) as Roaming_MV_sin_UMTS_LTE, 
	1.0*sum(case when td.operator <> 'Orange' and td.ServingOperator='Orange' and td.band not like '%UMTS%' and td.band not like '%LTE%' then td.duration_acotada end) as Roaming_OR_sin_UMTS_LTE, 
	1.0*sum(case when td.operator <> 'Yoigo' and td.ServingOperator='Yoigo' and td.band not like '%UMTS%' and td.band not like '%LTE%' then td.duration_acotada end) as Roaming_YO_sin_UMTS_LTE,

	--Desglose de roaming por banda:
	1.0*sum(case when td.operator <> td.ServingOperator and td.Band='UMTS900' then td.duration_acotada end) as Roaming_U900,
	1.0*sum(case when td.operator <> td.ServingOperator and td.Band='UMTS2100' then td.duration_acotada end) as Roaming_U2100,
	1.0*sum(case when td.operator <> td.ServingOperator and td.Band='LTE800' then td.duration_acotada end) as Roaming_LTE800,
	1.0*sum(case when td.operator <> td.ServingOperator and td.Band='LTE1800' then td.duration_acotada end) as Roaming_LTE1800,
	1.0*sum(case when td.operator <> td.ServingOperator and td.Band='LTE2100' then td.duration_acotada end) as Roaming_LTE2100,
	1.0*sum(case when td.operator <> td.ServingOperator and td.Band='LTE2600' then td.duration_acotada end) as Roaming_LTE2600,

	--Duraciones para calculo de LTE a traves de tabla de BW:
	1.0*sum(td.duration_acotada) as Duration_total,
	1.0*sum(case when td.band not like '%LTE%' then td.duration_acotada end) as Duration_total_sin_LTE,
	1.0*sum(case when td.band not like '%UMTS%' then td.duration_acotada end) as Duration_total_sin_UMTS,
	1.0*sum(case when td.band not like '%UMTS%' and td.band not like '%LTE%' then td.duration_acotada end) as Duration_total_sin_UMTS_LTE,
	1.0*sum(case when td.band_SCC1 is not null then td.duration_acotada end) as Duration_SCC1, 
	1.0*sum(case when td.band_SCC2 is not null then td.duration_acotada end) as Duration_SCC2, 

	----------------------------------------------------------------------
	-- Informacion de BW a partir de la tabla de Serving
	----------------------------------------------------------------------
	--% PCC (respecto a su partipacion en el test):
	isnull(1.0*sum(case when td.DLBandWidth_est=20 then td.duration_acotada end),0)/ NULLIF(sum(case when td.band like '%LTE%' then td.duration_acotada end),0) as pctLTE_20Mhz_PCC, 		
	isnull(1.0*sum(case when td.DLBandWidth_est=15 then td.duration_acotada end),0)/ NULLIF(sum(case when td.band like '%LTE%' then td.duration_acotada end),0) as pctLTE_15Mhz_PCC, 	
	isnull(1.0*sum(case when td.DLBandWidth_est=10 then td.duration_acotada end),0)/ NULLIF(sum(case when td.band like '%LTE%' then td.duration_acotada end),0) as pctLTE_10Mhz_PCC, 
	isnull(1.0*sum(case when td.DLBandWidth_est=5 then td.duration_acotada end),0)/ NULLIF(sum(case when td.band like '%LTE%' then td.duration_acotada end),0) as pctLTE_5Mhz_PCC, 
	--% SCC1 (respecto a su partipacion en el test):
	isnull(1.0*sum(case when td.DLBandWidth_SCC1_est=20 then td.duration_acotada end),0)/ NULLIF(sum(case when td.band_SCC1 like '%LTE%' then td.duration_acotada end),0) as pctLTE_20Mhz_SCC1, 		
	isnull(1.0*sum(case when td.DLBandWidth_SCC1_est=15 then td.duration_acotada end),0)/ NULLIF(sum(case when td.band_SCC1 like '%LTE%' then td.duration_acotada end),0) as pctLTE_15Mhz_SCC1, 	
	isnull(1.0*sum(case when td.DLBandWidth_SCC1_est=10 then td.duration_acotada end),0)/ NULLIF(sum(case when td.band_SCC1 like '%LTE%' then td.duration_acotada end),0) as pctLTE_10Mhz_SCC1, 
	isnull(1.0*sum(case when td.DLBandWidth_SCC1_est=5 then td.duration_acotada end),0)/ NULLIF(sum(case when td.band_SCC1 like '%LTE%' then td.duration_acotada end),0) as pctLTE_5Mhz_SCC1, 
	--% SCC2 (respecto a su partipacion en el test):
	isnull(1.0*sum(case when td.DLBandWidth_SCC2_est=20 then td.duration_acotada end),0)/ NULLIF(sum(case when td.band_SCC2 like '%LTE%' then td.duration_acotada end),0) as pctLTE_20Mhz_SCC2, 		
	isnull(1.0*sum(case when td.DLBandWidth_SCC2_est=15 then td.duration_acotada end),0)/ NULLIF(sum(case when td.band_SCC2 like '%LTE%' then td.duration_acotada end),0) as pctLTE_15Mhz_SCC2, 	
	isnull(1.0*sum(case when td.DLBandWidth_SCC2_est=10 then td.duration_acotada end),0)/ NULLIF(sum(case when td.band_SCC2 like '%LTE%' then td.duration_acotada end),0) as pctLTE_10Mhz_SCC2,
	isnull(1.0*sum(case when td.DLBandWidth_SCC2_est=5 then td.duration_acotada end),0)/ NULLIF(sum(case when td.band_SCC2 like '%LTE%' then td.duration_acotada end),0) as pctLTE_5Mhz_SCC2,
	-- Duraciones de SC
	1.0*sum(case when td.DLBandWidth_SCC1_est is null and td.DLBandWidth_SCC2_est is null and td.DLBandWidth_est=20 then td.duration_acotada end) as DurationLTE_20Mhz_SC, 		
	1.0*sum(case when td.DLBandWidth_SCC1_est is null and td.DLBandWidth_SCC2_est is null and td.DLBandWidth_est=15 then td.duration_acotada end) as DurationLTE_15Mhz_SC, 	
	1.0*sum(case when td.DLBandWidth_SCC1_est is null and td.DLBandWidth_SCC2_est is null and td.DLBandWidth_est=10 then td.duration_acotada end) as DurationLTE_10Mhz_SC, 
	1.0*sum(case when td.DLBandWidth_SCC1_est is null and td.DLBandWidth_SCC2_est is null and td.DLBandWidth_est=5 then td.duration_acotada end) as DurationLTE_5Mhz_SC, 
	-- Duraciones de DC
	1.0*sum(case when td.DLBandWidth_SCC2_est is null and (td.DLBandWidth_est+td.DLBandWidth_SCC1_est)=40 then td.duration_acotada end) as DurationLTE_40Mhz_CA, 		
	1.0*sum(case when td.DLBandWidth_SCC2_est is null and (td.DLBandWidth_est+td.DLBandWidth_SCC1_est)=35 then td.duration_acotada end) as DurationLTE_35Mhz_CA, 	
	1.0*sum(case when td.DLBandWidth_SCC2_est is null and (td.DLBandWidth_est+td.DLBandWidth_SCC1_est)=30 then td.duration_acotada end) as DurationLTE_30Mhz_CA, 
	1.0*sum(case when td.DLBandWidth_SCC2_est is null and (td.DLBandWidth_est+td.DLBandWidth_SCC1_est)=25 then td.duration_acotada end) as DurationLTE_25Mhz_CA, 
	1.0*sum(case when td.DLBandWidth_SCC2_est is null and (td.DLBandWidth_est+td.DLBandWidth_SCC1_est)=20 then td.duration_acotada end) as DurationLTE_20Mhz_CA, 
	1.0*sum(case when td.DLBandWidth_SCC2_est is null and (td.DLBandWidth_est+td.DLBandWidth_SCC1_est)=15 then td.duration_acotada end) as DurationLTE_15Mhz_CA,
	-- Duraciones de 3C
	1.0*sum(case when td.DLBandWidth_est+td.DLBandWidth_SCC1_est+td.DLBandWidth_SCC2_est=60 then td.duration_acotada end) as DurationLTE_60Mhz_3C,
	1.0*sum(case when td.DLBandWidth_est+td.DLBandWidth_SCC1_est+td.DLBandWidth_SCC2_est=55 then td.duration_acotada end) as DurationLTE_55Mhz_3C,
	1.0*sum(case when td.DLBandWidth_est+td.DLBandWidth_SCC1_est+td.DLBandWidth_SCC2_est=50 then td.duration_acotada end) as DurationLTE_50Mhz_3C,
	1.0*sum(case when td.DLBandWidth_est+td.DLBandWidth_SCC1_est+td.DLBandWidth_SCC2_est=45 then td.duration_acotada end) as DurationLTE_45Mhz_3C,
	1.0*sum(case when td.DLBandWidth_est+td.DLBandWidth_SCC1_est+td.DLBandWidth_SCC2_est=40 then td.duration_acotada end) as DurationLTE_40Mhz_3C, 		
	1.0*sum(case when td.DLBandWidth_est+td.DLBandWidth_SCC1_est+td.DLBandWidth_SCC2_est=35 then td.duration_acotada end) as DurationLTE_35Mhz_3C, 	
	1.0*sum(case when td.DLBandWidth_est+td.DLBandWidth_SCC1_est+td.DLBandWidth_SCC2_est=30 then td.duration_acotada end) as DurationLTE_30Mhz_3C, 
	1.0*sum(case when td.DLBandWidth_est+td.DLBandWidth_SCC1_est+td.DLBandWidth_SCC2_est=25 then td.duration_acotada end) as DurationLTE_25Mhz_3C,
	--Duraciones de PCC
	1.0*sum(case when td.DLBandWidth_est=20 then td.duration_acotada end) as DurationLTE_20Mhz_PCC, 
	1.0*sum(case when td.DLBandWidth_est=15 then td.duration_acotada end) as DurationLTE_15Mhz_PCC,
	1.0*sum(case when td.DLBandWidth_est=10 then td.duration_acotada end) as DurationLTE_10Mhz_PCC,  
	1.0*sum(case when td.DLBandWidth_est=5 then td.duration_acotada end) as DurationLTE_5Mhz_PCC, 
	--Duraciones de SCC1
	1.0*sum(case when td.DLBandWidth_SCC1_est=20 then td.duration_acotada end) as DurationLTE_20Mhz_SCC1, 
	1.0*sum(case when td.DLBandWidth_SCC1_est=15 then td.duration_acotada end) as DurationLTE_15Mhz_SCC1,
	1.0*sum(case when td.DLBandWidth_SCC1_est=10 then td.duration_acotada end) as DurationLTE_10Mhz_SCC1,  
	1.0*sum(case when td.DLBandWidth_SCC1_est=5 then td.duration_acotada end) as DurationLTE_5Mhz_SCC1, 
	--Duraciones de SCC2
	1.0*sum(case when td.DLBandWidth_SCC2_est=20 then td.duration_acotada end) as DurationLTE_20Mhz_SCC2, 
	1.0*sum(case when td.DLBandWidth_SCC2_est=15 then td.duration_acotada end) as DurationLTE_15Mhz_SCC2,
	1.0*sum(case when td.DLBandWidth_SCC2_est=10 then td.duration_acotada end) as DurationLTE_10Mhz_SCC2,  
	1.0*sum(case when td.DLBandWidth_SCC2_est=5 then td.duration_acotada end) as DurationLTE_5Mhz_SCC2

into _Serving_Info_acotado_acc
from _lcc_Serving_Cell_Table_info_acotada_acc td
where td.band is not NULL
group by td.sessionid, td.TestId
order by td.sessionid, td.TestId

--Sin acotar: para YTB y LAT (pero solo informacion de uso de LTE):
exec sp_lcc_dropifexists '_Serving_Info'			
select 
	td.sessionid, td.testid, 
	----------------------------------------------------------------------
	--Info tecnologia, roaming
	----------------------------------------------------------------------	
	-- Frecuencias U2100:
	1.0*sum(case when td.Freq in (10638,   10788,  10713,  10563) then td.duration end) as Duration_F1_U2100,
	1.0*sum(case when td.Freq in (10663,	10813,	10738,	10588) then td.duration end) as Duration_F2_U2100,
	1.0*sum(case when td.Freq in (10688,	10838,	10763,	10613) then td.duration end) as Duration_F3_U2100,	
	-- Frecuencias U900:
	1.0*sum(case when td.Freq in (3062, 3011, 2959) then td.duration end) as Duration_F1_U900,
	1.0*sum(case when td.Freq in (3087, 3022) then td.duration end) as Duration_F2_U900,
	-- Desglose tecnologia (referida a primera carrier):
	1.0*sum(case when td.band like '%LTE%' then td.duration end) as Duration_LTE,
	1.0*sum(case when td.band like '%UMTS%' then td.duration end) as Duration_WCDMA,
	1.0*sum(case when td.band in ('GSM','DCS','EGSM') then td.duration end) as Duration_GSM,
	--Desglose 4G:
	1.0*sum(case when td.band like 'LTE800' then td.duration end) as Duration_LTE_800, 
	1.0*sum(case when td.band like 'LTE1800' then td.duration end) as Duration_LTE_1800,
	1.0*sum(case when td.band like 'LTE2100' then td.duration end) as Duration_LTE_2100,  
	1.0*sum(case when td.band like 'LTE2600' then td.duration end) as Duration_LTE_2600, 
	--Desglose 3G:
	1.0*sum(case when td.band like 'UMTS2100' then td.duration end) as Duration_UMTS_2100, 
	1.0*sum(case when td.band like 'UMTS900' then td.duration end) as Duration_UMTS_900, 
	--Desglose 2G:
	1.0*sum(case when td.band like 'DCS' then td.duration end) as Duration_GMS_DCS, 
	1.0*sum(case when td.band like 'EGSM' then td.duration end) as Duration_GSM_EGSM,
	1.0*sum(case when td.band like 'GSM' then td.duration end) as Duration_GSM_GSM,
	--Desglose 4G SCC1:
	1.0*sum(case when td.band_SCC1 like 'LTE800' then td.duration end) as Duration_LTE_800_SCC1, 
	1.0*sum(case when td.band_SCC1 like 'LTE1800' then td.duration end) as Duration_LTE_1800_SCC1, 
	1.0*sum(case when td.band_SCC1 like 'LTE2100' then td.duration end) as Duration_LTE_2100_SCC1,
	1.0*sum(case when td.band_SCC1 like 'LTE2600' then td.duration end) as Duration_LTE_2600_SCC1,
	--Desglose 4G SCC2:
	1.0*sum(case when td.band_SCC2 like 'LTE800' then td.duration end) as Duration_LTE_800_SCC2, 
	1.0*sum(case when td.band_SCC2 like 'LTE1800' then td.duration end) as Duration_LTE_1800_SCC2, 
	1.0*sum(case when td.band_SCC2 like 'LTE2100' then td.duration end) as Duration_LTE_2100_SCC2,
	1.0*sum(case when td.band_SCC2 like 'LTE2600' then td.duration end) as Duration_LTE_2600_SCC2,
	-- Info de SC / CA / 3C :
	1.0*sum(case when td.band like '%LTE%' and td.band_SCC1 is null and td.band_SCC2 is null then td.duration else 0 end) as Duration_LTE_SC,
	1.0*sum(case when td.band_SCC1 is not null and td.band_SCC2 is null then td.duration else 0 end) as Duration_LTE_CA,
	1.0*sum(case when td.band_SCC1 is not null and td.band_SCC2 is not null then td.duration else 0 end) as Duration_LTE_3C,
	--Info de roaming por operador:
	1.0*sum(case when td.operator <> 'Vodafone' and td.ServingOperator='Vodafone' then td.duration end) as Roaming_VF, 
	1.0*sum(case when td.operator <> 'Movistar' and td.ServingOperator='Movistar' then td.duration end) as Roaming_MV, 
	1.0*sum(case when td.operator <> 'Orange' and td.ServingOperator='Orange' then td.duration end) as Roaming_OR, 
	1.0*sum(case when td.operator <> 'Yoigo' and td.ServingOperator='Yoigo' then td.duration end) as Roaming_YO,
	1.0*sum(case when td.operator <> 'Vodafone' and td.ServingOperator='Vodafone' and td.band not like '%LTE%' then td.duration end) as Roaming_VF_sin_LTE, 
	1.0*sum(case when td.operator <> 'Movistar' and td.ServingOperator='Movistar' and td.band not like '%LTE%' then td.duration end) as Roaming_MV_sin_LTE, 
	1.0*sum(case when td.operator <> 'Orange' and td.ServingOperator='Orange' and td.band not like '%LTE%' then td.duration end) as Roaming_OR_sin_LTE, 
	1.0*sum(case when td.operator <> 'Yoigo' and td.ServingOperator='Yoigo' and td.band not like '%LTE%' then td.duration end) as Roaming_YO_sin_LTE,
	1.0*sum(case when td.operator <> 'Vodafone' and td.ServingOperator='Vodafone' and td.band not like '%UMTS%' then td.duration end) as Roaming_VF_sin_UMTS, 
	1.0*sum(case when td.operator <> 'Movistar' and td.ServingOperator='Movistar' and td.band not like '%UMTS%' then td.duration end) as Roaming_MV_sin_UMTS, 
	1.0*sum(case when td.operator <> 'Orange' and td.ServingOperator='Orange' and td.band not like '%UMTS%' then td.duration end) as Roaming_OR_sin_UMTS, 
	1.0*sum(case when td.operator <> 'Yoigo' and td.ServingOperator='Yoigo' and td.band not like '%UMTS%' then td.duration end) as Roaming_YO_sin_UMTS,
	1.0*sum(case when td.operator <> 'Vodafone' and td.ServingOperator='Vodafone' and td.band not like '%UMTS%' and td.band not like '%LTE%' then td.duration end) as Roaming_VF_sin_UMTS_LTE, 
	1.0*sum(case when td.operator <> 'Movistar' and td.ServingOperator='Movistar' and td.band not like '%UMTS%' and td.band not like '%LTE%' then td.duration end) as Roaming_MV_sin_UMTS_LTE, 
	1.0*sum(case when td.operator <> 'Orange' and td.ServingOperator='Orange' and td.band not like '%UMTS%' and td.band not like '%LTE%' then td.duration end) as Roaming_OR_sin_UMTS_LTE, 
	1.0*sum(case when td.operator <> 'Yoigo' and td.ServingOperator='Yoigo' and td.band not like '%UMTS%' and td.band not like '%LTE%' then td.duration end) as Roaming_YO_sin_UMTS_LTE,

	--Desglose de roaming por banda:
	1.0*sum(case when td.operator <> td.ServingOperator and td.Band='UMTS900' then td.duration end) as Roaming_U900,
	1.0*sum(case when td.operator <> td.ServingOperator and td.Band='UMTS2100' then td.duration end) as Roaming_U2100,
	1.0*sum(case when td.operator <> td.ServingOperator and td.Band='LTE800' then td.duration end) as Roaming_LTE800,
	1.0*sum(case when td.operator <> td.ServingOperator and td.Band='LTE1800' then td.duration end) as Roaming_LTE1800,
	1.0*sum(case when td.operator <> td.ServingOperator and td.Band='LTE2100' then td.duration end) as Roaming_LTE2100,
	1.0*sum(case when td.operator <> td.ServingOperator and td.Band='LTE2600' then td.duration end) as Roaming_LTE2600,

	--Duraciones para calculo de LTE a traves de tabla de BW:
	1.0*sum(td.duration) as Duration_total,
	1.0*sum(case when td.band not like '%LTE%' then td.duration end) as Duration_total_sin_LTE,
	1.0*sum(case when td.band not like '%UMTS%' then td.duration end) as Duration_total_sin_UMTS,
	1.0*sum(case when td.band not like '%UMTS%' and td.band not like '%LTE%' then td.duration end) as Duration_total_sin_UMTS_LTE,
	1.0*sum(case when td.band_SCC1 is not null then td.duration end) as Duration_SCC1, 
	1.0*sum(case when td.band_SCC2 is not null then td.duration end) as Duration_SCC2, 

	----------------------------------------------------------------------
	-- Informacion de BW a partir de la tabla de Serving
	----------------------------------------------------------------------
	--% PCC (respecto a su partipacion en el test):
	isnull(1.0*sum(case when td.DLBandWidth_est=20 then td.duration end),0)/ NULLIF(sum(case when td.band like '%LTE%' then td.duration end),0) as pctLTE_20Mhz_PCC, 		
	isnull(1.0*sum(case when td.DLBandWidth_est=15 then td.duration end),0)/ NULLIF(sum(case when td.band like '%LTE%' then td.duration end),0) as pctLTE_15Mhz_PCC, 	
	isnull(1.0*sum(case when td.DLBandWidth_est=10 then td.duration end),0)/ NULLIF(sum(case when td.band like '%LTE%' then td.duration end),0) as pctLTE_10Mhz_PCC, 
	isnull(1.0*sum(case when td.DLBandWidth_est=5 then td.duration end),0)/ NULLIF(sum(case when td.band like '%LTE%' then td.duration end),0) as pctLTE_5Mhz_PCC, 
	--% SCC1 (respecto a su partipacion en el test):
	isnull(1.0*sum(case when td.DLBandWidth_SCC1_est=20 then td.duration end),0)/ NULLIF(sum(case when td.band_SCC1 like '%LTE%' then td.duration end),0) as pctLTE_20Mhz_SCC1, 		
	isnull(1.0*sum(case when td.DLBandWidth_SCC1_est=15 then td.duration end),0)/ NULLIF(sum(case when td.band_SCC1 like '%LTE%' then td.duration end),0) as pctLTE_15Mhz_SCC1, 	
	isnull(1.0*sum(case when td.DLBandWidth_SCC1_est=10 then td.duration end),0)/ NULLIF(sum(case when td.band_SCC1 like '%LTE%' then td.duration end),0) as pctLTE_10Mhz_SCC1, 
	isnull(1.0*sum(case when td.DLBandWidth_SCC1_est=5 then td.duration end),0)/ NULLIF(sum(case when td.band_SCC1 like '%LTE%' then td.duration end),0) as pctLTE_5Mhz_SCC1, 
	--% SCC2 (respecto a su partipacion en el test):
	isnull(1.0*sum(case when td.DLBandWidth_SCC2_est=20 then td.duration end),0)/ NULLIF(sum(case when td.band_SCC2 like '%LTE%' then td.duration end),0) as pctLTE_20Mhz_SCC2, 		
	isnull(1.0*sum(case when td.DLBandWidth_SCC2_est=15 then td.duration end),0)/ NULLIF(sum(case when td.band_SCC2 like '%LTE%' then td.duration end),0) as pctLTE_15Mhz_SCC2, 	
	isnull(1.0*sum(case when td.DLBandWidth_SCC2_est=10 then td.duration end),0)/ NULLIF(sum(case when td.band_SCC2 like '%LTE%' then td.duration end),0) as pctLTE_10Mhz_SCC2,
	isnull(1.0*sum(case when td.DLBandWidth_SCC2_est=5 then td.duration end),0)/ NULLIF(sum(case when td.band_SCC2 like '%LTE%' then td.duration end),0) as pctLTE_5Mhz_SCC2,
	-- Duraciones de SC
	1.0*sum(case when td.DLBandWidth_SCC1_est is null and td.DLBandWidth_SCC2_est is null and td.DLBandWidth_est=20 then td.duration end) as DurationLTE_20Mhz_SC, 		
	1.0*sum(case when td.DLBandWidth_SCC1_est is null and td.DLBandWidth_SCC2_est is null and td.DLBandWidth_est=15 then td.duration end) as DurationLTE_15Mhz_SC, 	
	1.0*sum(case when td.DLBandWidth_SCC1_est is null and td.DLBandWidth_SCC2_est is null and td.DLBandWidth_est=10 then td.duration end) as DurationLTE_10Mhz_SC, 
	1.0*sum(case when td.DLBandWidth_SCC1_est is null and td.DLBandWidth_SCC2_est is null and td.DLBandWidth_est=5 then td.duration end) as DurationLTE_5Mhz_SC, 
	-- Duraciones de DC
	1.0*sum(case when td.DLBandWidth_SCC2_est is null and (td.DLBandWidth_est+td.DLBandWidth_SCC1_est)=40 then td.duration end) as DurationLTE_40Mhz_CA, 		
	1.0*sum(case when td.DLBandWidth_SCC2_est is null and (td.DLBandWidth_est+td.DLBandWidth_SCC1_est)=35 then td.duration end) as DurationLTE_35Mhz_CA, 	
	1.0*sum(case when td.DLBandWidth_SCC2_est is null and (td.DLBandWidth_est+td.DLBandWidth_SCC1_est)=30 then td.duration end) as DurationLTE_30Mhz_CA, 
	1.0*sum(case when td.DLBandWidth_SCC2_est is null and (td.DLBandWidth_est+td.DLBandWidth_SCC1_est)=25 then td.duration end) as DurationLTE_25Mhz_CA, 
	1.0*sum(case when td.DLBandWidth_SCC2_est is null and (td.DLBandWidth_est+td.DLBandWidth_SCC1_est)=20 then td.duration end) as DurationLTE_20Mhz_CA, 
	1.0*sum(case when td.DLBandWidth_SCC2_est is null and (td.DLBandWidth_est+td.DLBandWidth_SCC1_est)=15 then td.duration end) as DurationLTE_15Mhz_CA,
	-- Duraciones de 3C
	1.0*sum(case when td.DLBandWidth_est+td.DLBandWidth_SCC1_est+td.DLBandWidth_SCC2_est=60 then td.duration end) as DurationLTE_60Mhz_3C,
	1.0*sum(case when td.DLBandWidth_est+td.DLBandWidth_SCC1_est+td.DLBandWidth_SCC2_est=55 then td.duration end) as DurationLTE_55Mhz_3C,
	1.0*sum(case when td.DLBandWidth_est+td.DLBandWidth_SCC1_est+td.DLBandWidth_SCC2_est=50 then td.duration end) as DurationLTE_50Mhz_3C,
	1.0*sum(case when td.DLBandWidth_est+td.DLBandWidth_SCC1_est+td.DLBandWidth_SCC2_est=45 then td.duration end) as DurationLTE_45Mhz_3C,
	1.0*sum(case when td.DLBandWidth_est+td.DLBandWidth_SCC1_est+td.DLBandWidth_SCC2_est=40 then td.duration end) as DurationLTE_40Mhz_3C, 		
	1.0*sum(case when td.DLBandWidth_est+td.DLBandWidth_SCC1_est+td.DLBandWidth_SCC2_est=35 then td.duration end) as DurationLTE_35Mhz_3C, 	
	1.0*sum(case when td.DLBandWidth_est+td.DLBandWidth_SCC1_est+td.DLBandWidth_SCC2_est=30 then td.duration end) as DurationLTE_30Mhz_3C, 
	1.0*sum(case when td.DLBandWidth_est+td.DLBandWidth_SCC1_est+td.DLBandWidth_SCC2_est=25 then td.duration end) as DurationLTE_25Mhz_3C,
	--Duraciones de PCC
	1.0*sum(case when td.DLBandWidth_est=20 then td.duration end) as DurationLTE_20Mhz_PCC, 
	1.0*sum(case when td.DLBandWidth_est=15 then td.duration end) as DurationLTE_15Mhz_PCC,
	1.0*sum(case when td.DLBandWidth_est=10 then td.duration end) as DurationLTE_10Mhz_PCC,  
	1.0*sum(case when td.DLBandWidth_est=5 then td.duration end) as DurationLTE_5Mhz_PCC, 
	--Duraciones de SCC1
	1.0*sum(case when td.DLBandWidth_SCC1_est=20 then td.duration end) as DurationLTE_20Mhz_SCC1, 
	1.0*sum(case when td.DLBandWidth_SCC1_est=15 then td.duration end) as DurationLTE_15Mhz_SCC1,
	1.0*sum(case when td.DLBandWidth_SCC1_est=10 then td.duration end) as DurationLTE_10Mhz_SCC1,  
	1.0*sum(case when td.DLBandWidth_SCC1_est=5 then td.duration end) as DurationLTE_5Mhz_SCC1, 
	--Duraciones de SCC2
	1.0*sum(case when td.DLBandWidth_SCC2_est=20 then td.duration end) as DurationLTE_20Mhz_SCC2, 
	1.0*sum(case when td.DLBandWidth_SCC2_est=15 then td.duration end) as DurationLTE_15Mhz_SCC2,
	1.0*sum(case when td.DLBandWidth_SCC2_est=10 then td.duration end) as DurationLTE_10Mhz_SCC2,  
	1.0*sum(case when td.DLBandWidth_SCC2_est=5 then td.duration end) as DurationLTE_5Mhz_SCC2

into _Serving_Info
from _lcc_Serving_Cell_Table_info td
where td.band is not NULL
group by td.sessionid, td.TestId
order by td.sessionid, td.TestId

-------------------------------------------------------------------------------------------------------------------------------------
-- Calculamos info de radio 4G de las carriers en el momento inicial y final que son detectadas
-------------------------------------------------------------------------------------------------------------------------------------
--En PCC filtramos porque sea info de LTE (en SCC1-SCC2 no hace falta porque se rellenan sólo cuando es LTE)
exec sp_lcc_dropifexists '_tech_INI_PCC'			
select 
	t.sessionid, t.testid, t.longitude, t.latitude,	
	case when t.band like ('%LTE%') then t.Freq  end as EARFCN,	
	case when t.band like ('%LTE%') then t.cell  end as PCI,
	t.band as Band,
	t.DLBandWidth_est as DLBandWidth
into _tech_INI_PCC
from _lcc_Serving_Cell_Table_info t
	left outer join 
			(Select sessionid, testid, min(idSide_Test) as idMin
				from _lcc_Serving_Cell_Table_info
				where testid > @maxtestid and band like '%LTE%'
				group by sessionid, testid) mi
	on t.sessionid=mi.sessionid and t.TestId=mi.TestId
where t.idSide_Test=mi.idMin 
	and t.testid > @maxtestid
order by t.sessionid, t.testid
					
exec sp_lcc_dropifexists '_tech_FIN_PCC'			
select 
	t.sessionid, t.testid, t.longitude, t.latitude,	
	case when t.band like ('%LTE%') then t.Freq  end as EARFCN,	
	case when t.band like ('%LTE%') then t.cell  end as PCI,
	t.band as Band,
	t.DLBandWidth_est as DLBandWidth 
into _tech_FIN_PCC
from _lcc_Serving_Cell_Table_info t
		left outer join 
				(Select sessionid, testid, max(idSide_Test) as idMax
				 from _lcc_Serving_Cell_Table_info 
				 where testid > @maxtestid and band like '%LTE%'
				 group by sessionid,testid) mi
	on t.sessionid=mi.sessionid and t.TestId=mi.TestId
where t.idSide_Test=mi.idMax 
	and t.testid > @maxtestid
order by t.sessionid, t.testid

exec sp_lcc_dropifexists '_tech_INI_SCC1'			
select 
	t.sessionid, t.testid, t.longitude, t.latitude,	
	case when t.band_SCC1 like ('%LTE%') then t.Freq_SCC1  end as EARFCN,	
	case when t.band_SCC1 like ('%LTE%') then t.cell_SCC1  end as PCI,
	t.band_SCC1 as Band,
	t.DLBandWidth_SCC1_est as DLBandWidth
into _tech_INI_SCC1
from _lcc_Serving_Cell_Table_info t
	left outer join 
			(Select sessionid, testid, min(idSide_Test) as idMin
				from _lcc_Serving_Cell_Table_info
				where testid > @maxtestid and band_SCC1 is not null
				group by sessionid, testid) mi
	on t.sessionid=mi.sessionid and t.TestId=mi.TestId
where t.idSide_Test=mi.idMin 
	and t.testid > @maxtestid
order by t.sessionid, t.testid
					
exec sp_lcc_dropifexists '_tech_FIN_SCC1'			
select 
	t.sessionid, t.testid, t.longitude, t.latitude,	
	case when t.band like ('%LTE%') then t.Freq_SCC1  end as EARFCN,	
	case when t.band like ('%LTE%') then t.cell_SCC1  end as PCI,
	t.band_SCC1 as Band,
	t.DLBandWidth_SCC1_est as DLBandWidth	 
into _tech_FIN_SCC1
from _lcc_Serving_Cell_Table_info t
	left outer join 
			(Select sessionid, testid, max(idSide_Test) as idMax
				from _lcc_Serving_Cell_Table_info 
				where testid > @maxtestid and band_SCC1 is not null
				group by sessionid,testid) mi
	on t.sessionid=mi.sessionid and t.TestId=mi.TestId
where t.idSide_Test=mi.idMax 
	and t.testid > @maxtestid
order by t.sessionid, t.testid

exec sp_lcc_dropifexists '_tech_INI_SCC2'			
select 
	t.sessionid, t.testid, t.longitude, t.latitude,	
	case when t.band_SCC2 like ('%LTE%') then t.Freq_SCC2  end as EARFCN,	
	case when t.band_SCC2 like ('%LTE%') then t.cell_SCC2  end as PCI,
	t.band_SCC2 as Band,
	t.DLBandWidth_SCC2_est as DLBandWidth
into _tech_INI_SCC2
from _lcc_Serving_Cell_Table_info t
	left outer join 
			(Select sessionid, testid, min(idSide_Test) as idMin
				from _lcc_Serving_Cell_Table_info
				where testid > @maxtestid and band_SCC2 is not null
				group by sessionid, testid) mi
	on t.sessionid=mi.sessionid and t.TestId=mi.TestId
where t.idSide_Test=mi.idMin 
	and t.testid > @maxtestid
order by t.sessionid, t.testid
					
exec sp_lcc_dropifexists '_tech_FIN_SCC2'			
select 
	t.sessionid, t.testid, t.longitude, t.latitude,	
	case when t.band like ('%LTE%') then t.Freq_SCC2  end as EARFCN,	
	case when t.band like ('%LTE%') then t.cell_SCC2  end as PCI,
	t.band_SCC2 as Band,
	t.DLBandWidth_SCC2_est as DLBandWidth	 
into _tech_FIN_SCC2
from _lcc_Serving_Cell_Table_info t
	left outer join 
			(Select sessionid, testid, max(idSide_Test) as idMax
				from _lcc_Serving_Cell_Table_info 
				where testid > @maxtestid and band_SCC2 is not null
				group by sessionid,testid) mi
	on t.sessionid=mi.sessionid and t.TestId=mi.TestId
where t.idSide_Test=mi.idMax 
	and t.testid > @maxtestid
order by t.sessionid, t.testid


exec sp_lcc_dropifexists '_tech_Carriers'
select t.Operator,
	ini_PCC.sessionid, ini_PCC.testid, ini_PCC.longitude, ini_PCC.latitude,	
	--Para asignar banda y BW a cada carrier, exigimos que tengan la misma banda al inicio-fin.
	case when ini_PCC.Band=fin_PCC.Band then ini_PCC.Band end as Band,
	case when ini_PCC.Band=fin_PCC.Band then ini_PCC.DLBandWidth end as DLBandWidth,
	case when ini_SCC1.Band=fin_SCC1.Band then ini_SCC1.Band end as Band_SCC1,
	case when ini_SCC1.Band=fin_SCC1.Band then ini_SCC1.DLBandWidth end as DLBandWidth_SCC1,
	case when ini_SCC2.Band=fin_SCC2.Band then ini_SCC2.Band end as Band_SCC2,
	case when ini_SCC2.Band=fin_SCC2.Band then ini_SCC2.DLBandWidth end as DLBandWidth_SCC2,
	--Para determinar que hace roaming, exigimos que tengan la misma banda y que servingvOperator<>Operator al inicio-fin
	case when ini_PCC.Band=fin_PCC.Band and sofIni.ServingOperator<>t.Operator and sofFin.ServingOperator<>t.Operator and sofIni.ServingOperator=sofFin.ServingOperator then 1 else 0 end as 'Roaming',
	case when ini_PCC.Band=fin_PCC.Band and sofIni.ServingOperator<>t.Operator and sofFin.ServingOperator<>t.Operator and sofIni.ServingOperator=sofFin.ServingOperator then sofIni.ServingOperator end as 'Ope_Roaming',
	k.duration,
	k.duration as durationAcc,

	ini_PCC.EARFCN as EARFCN_ini,ini_PCC.PCI as PCI_ini,ini_PCC.Band as Band_ini,ini_PCC.DLBandWidth as DLBandWidth_ini,
	fin_PCC.EARFCN as EARFCN_fin,fin_PCC.PCI as PCI_fin,fin_PCC.Band as Band_fin,fin_PCC.DLBandWidth as DLBandWidth_fin,
	ini_SCC1.EARFCN as EARFCN_ini_SCC1,ini_SCC1.PCI as PCI_ini_SCC1,ini_SCC1.Band as Band_ini_SCC1,ini_SCC1.DLBandWidth as DLBandWidth_ini_SCC1,
	fin_SCC1.EARFCN as EARFCN_fin_SCC1,fin_SCC1.PCI as PCI_fin_SCC1,fin_SCC1.Band as Band_fin_SCC1,fin_SCC1.DLBandWidth as DLBandWidth_fin_SCC1,
	ini_SCC2.EARFCN as EARFCN_ini_SCC2,ini_SCC2.PCI as PCI_ini_SCC2,ini_SCC2.Band as Band_ini_SCC2,ini_SCC2.DLBandWidth as DLBandWidth_ini_SCC2,
	fin_SCC2.EARFCN as EARFCN_fin_SCC2,fin_SCC2.PCI as PCI_fin_SCC2,fin_SCC2.Band as Band_fin_SCC2,fin_SCC2.DLBandWidth as DLBandWidth_fin_SCC2
into _tech_Carriers
from _test_Operator t 
	inner join _tech_INI_PCC ini_PCC	on t.testid=ini_PCC.testid
	left join _tech_FIN_PCC fin_PCC		on ini_PCC.sessionid=fin_PCC.sessionid and ini_PCC.TestId=fin_PCC.TestId 
	left join _tech_INI_SCC1 ini_SCC1	on ini_PCC.sessionid=ini_SCC1.sessionid and ini_PCC.TestId=ini_SCC1.TestId 
	left join _tech_FIN_SCC1 fin_SCC1	on ini_PCC.sessionid=fin_SCC1.sessionid and ini_PCC.TestId=fin_SCC1.TestId 
	left join _tech_INI_SCC2 ini_SCC2	on ini_PCC.sessionid=ini_SCC2.sessionid and ini_PCC.TestId=ini_SCC2.TestId 
	left join _tech_FIN_SCC2 fin_SCC2	on ini_PCC.sessionid=fin_SCC2.sessionid and ini_PCC.TestId=fin_SCC2.TestId 
	LEFT OUTER JOIN [AGRIDS].dbo.lcc_ref_servingOperator_Freq sofIni on ini_PCC.EARFCN=sofIni.Frequency
	LEFT OUTER JOIN [AGRIDS].dbo.lcc_ref_servingOperator_Freq sofFin on fin_PCC.EARFCN=sofFin.Frequency
	left join _intervalos k on t.testid=k.testid
	left join _intervalos_all ka on t.testid=ka.testid

	
	
-------------------------------------------------------------------------------------------------------------------------------------
-- 4G: Calculo de las duraciones de BW desde la tabla de sistema
-------------------------------------------------------------------------------------------------------------------------------------
--Info de BW en Carriers. 
--Ordenamos por carrierindex con información (no siempre se rellena en orden):
--Se debe particionar por test,instante de tiempo y el Id de la información
exec sp_lcc_dropifexists '_lcc_BandWidth_Carriers'
select 
	ca.LTECACellInfoid,	ca.CarrierIndex  as CarrierIndex_Orig,
	ROW_NUMBER() over (partition by t.testid,t.msgtime,t.LTECACellInfoid order by ca.CarrierIndex asc) as CarrierIndex,	-- SCC:1...7
	t.testid,t.sessionid,t.msgtime,
	ca.DLBandWidth as DLBandWidth,
	ca.EARFCN as EARFCN,
	ca.PCI as PCI,
	sof.band
into _lcc_BandWidth_Carriers
from testinfo tt, LTEServingCellInfo  t
	inner join LTECACellInfo ca on ca.LTECACellInfoid=t.LTECACellInfoid
	LEFT OUTER JOIN [AGRIDS].dbo.lcc_ref_servingOperator_Freq sof on ca.EARFCN=sof.Frequency
where t.testid=tt.testid and tt.valid=1
	and t.testid > @maxTestid 
order by t.SessionId, t.testid

--Tabla con info de BW en columnas:
-- (para la primera carrier estimamos el BW dependiendo de la banda de LTE si no está relleno)
exec sp_lcc_dropifexists '_lcc_BandWidth_Table_duration_Data'
select 
	t.testid,t.sessionid,t.msgtime,
	case when t.DLBandWidth is not null then t.DLBandWidth
		else (case when sof.band='LTE2600' then 20 when sof.band='LTE2100' then 5 when sof.band='LTE1800' then 20 when sof.band='LTE800' then 10 end)
	end as DLBandWidth,
	t.DL_EARFCN as EARFCN,
	t.PhyCellId as PCI,
	case when t.ULBandWidth is not null then t.ULBandWidth
		else (case when sof.band='LTE2600' then 20 when sof.band='LTE2100' then 5 when sof.band='LTE1800' then 20 when sof.band='LTE800' then 10 end)
	end as ULBandWidth,
	sof.band, tt.operator, sof.ServingOperator,
	t.DLBandWidth as DLBandWidth_real,

	s1.DLBandWidth as DLBandWidth_SCC1, s1.EARFCN as EARFCN_SCC1, s1.PCI as PCI_SCC1, s1.band as band_SCC1,
	s2.DLBandWidth as DLBandWidth_SCC2, s2.EARFCN as EARFCN_SCC2, s2.PCI as PCI_SCC2, s2.band as band_SCC2,
	s3.DLBandWidth as DLBandWidth_SCC3, s3.EARFCN as EARFCN_SCC3, s3.PCI as PCI_SCC3, s3.band as band_SCC3,
	s4.DLBandWidth as DLBandWidth_SCC4, s4.EARFCN as EARFCN_SCC4, s4.PCI as PCI_SCC4, s4.band as band_SCC4,
	s5.DLBandWidth as DLBandWidth_SCC5, s5.EARFCN as EARFCN_SCC5, s5.PCI as PCI_SCC5, s5.band as band_SCC5,
	s6.DLBandWidth as DLBandWidth_SCC6, s6.EARFCN as EARFCN_SCC6, s6.PCI as PCI_SCC6, s6.band as band_SCC6,
	s7.DLBandWidth as DLBandWidth_SCC7, s7.EARFCN as EARFCN_SCC7, s7.PCI as PCI_SCC7, s7.band as band_SCC7,
	ROW_NUMBER() over (partition by t.sessionid, t.testid order by t.msgtime asc) as durationID
into _lcc_BandWidth_Table_duration_Data
from _test_Operator tt, LTEServingCellInfo  t
	LEFT OUTER JOIN [AGRIDS].dbo.lcc_ref_servingOperator_Freq sof on t.DL_EARFCN=sof.Frequency
	LEFT OUTER JOIN _lcc_BandWidth_Carriers s1 on (t.LTECACellInfoid=s1.LTECACellInfoid and t.testId=s1.testId and t.msgtime=s1.msgtime and s1.CarrierIndex=1)
	LEFT OUTER JOIN _lcc_BandWidth_Carriers s2 on (t.LTECACellInfoid=s2.LTECACellInfoid and t.testId=s2.testId and t.msgtime=s2.msgtime and s2.CarrierIndex=2)
	LEFT OUTER JOIN _lcc_BandWidth_Carriers s3 on (t.LTECACellInfoid=s3.LTECACellInfoid and t.testId=s3.testId and t.msgtime=s3.msgtime and s3.CarrierIndex=3)
	LEFT OUTER JOIN _lcc_BandWidth_Carriers s4 on (t.LTECACellInfoid=s4.LTECACellInfoid and t.testId=s4.testId and t.msgtime=s4.msgtime and s4.CarrierIndex=4)
	LEFT OUTER JOIN _lcc_BandWidth_Carriers s5 on (t.LTECACellInfoid=s5.LTECACellInfoid and t.testId=s5.testId and t.msgtime=s5.msgtime and s5.CarrierIndex=5)
	LEFT OUTER JOIN _lcc_BandWidth_Carriers s6 on (t.LTECACellInfoid=s6.LTECACellInfoid and t.testId=s6.testId and t.msgtime=s6.msgtime and s6.CarrierIndex=6)
	LEFT OUTER JOIN _lcc_BandWidth_Carriers s7 on (t.LTECACellInfoid=s7.LTECACellInfoid and t.testId=s7.testId and t.msgtime=s7.msgtime and s7.CarrierIndex=7)
where t.testid=tt.testid
	and t.testid > @maxTestid
order by t.SessionId, t.testid


-- Calculos de las duraciones uso BandWidth: inicio = msgTime, fin = msgTime posterior o fin de test
exec sp_lcc_dropifexists '_BW_RADIO_DURATION_Data'		
select ini.*
	,ini.MsgTime as time_ini
	,isnull(fin.MsgTime,DATEADD(ms, t.duration ,t.startTime)) as time_fin
	,DATEDIFF(ms, ini.MsgTime , isnull(fin.MsgTime,DATEADD(ms, t.duration ,t.startTime))) as duration
into _BW_RADIO_DURATION_Data
from _lcc_BandWidth_Table_duration_Data ini 
	inner join testinfo t
		on (ini.sessionid = t.sessionid and ini.TestId=t.TestId)			
	left join _lcc_BandWidth_Table_duration_Data fin
		on (ini.sessionid = fin.sessionid and ini.TestId = fin.TestId
			and ini.durationID = fin.durationID -1)

--Acotamos al momento de la descarga, subida, etc, teniendo en cuenta el acceso:
exec sp_lcc_dropifexists '_BW_RADIO_DURATION_Data_acotada_all'
select c.*
	,case when k.starttime <= c.time_ini then c.time_ini
		else k.starttime
	end as time_ini_acotado
	,case when c.time_fin <= k.endtime then c.time_fin
		else k.endtime
	end as time_fin_acotado
	,case when k.starttime <= c.time_ini and c.time_fin <= k.endtime then c.duration						--Ini/Fin de la info dentro
		when c.time_ini <= k.starttime and k.endtime <= c.time_fin then k.duration							--Ini anterior y fin dentro, acotamos
		when c.time_ini <= k.starttime and c.time_fin <= k.endtime then DATEDIFF(ms,k.starttime,c.time_fin) --Ini/Fin de la info fuera pero conteniendolo, acotamos
		when k.starttime <= time_ini and k.endtime <= c.time_fin then DATEDIFF(ms,c.time_ini,k.endtime)		--Ini dentro pero fin posterior, acotamos
	end as duration_acotada
into _BW_RADIO_DURATION_Data_acotada_all
from  testinfo t
	inner join _intervalos_all k --ResultsKPI
		on t.sessionid=k.sessionid and t.testid=k.testid
	left join _BW_RADIO_DURATION_Data c --LTEServingCellInfo
		on t.SessionId = c.SessionId  and t.testid=c.testid
			and k.starttime < c.time_fin
			and k.endtime > c.time_ini
where c.testid is not null

--Acotamos al momento de la descarga, subida, etc, SIN tener en cuenta el acceso:
exec sp_lcc_dropifexists '_BW_RADIO_DURATION_Data_acotada'
select c.*
	,case when k.starttime <= c.time_ini then c.time_ini
		else k.starttime
	end as time_ini_acotado
	,case when c.time_fin <= k.endtime then c.time_fin
		else k.endtime
	end as time_fin_acotado
	,case when k.starttime <= c.time_ini and c.time_fin <= k.endtime then c.duration						--Ini/Fin de la info dentro
		when c.time_ini <= k.starttime and k.endtime <= c.time_fin then k.duration							--Ini anterior y fin dentro, acotamos
		when c.time_ini <= k.starttime and c.time_fin <= k.endtime then DATEDIFF(ms,k.starttime,c.time_fin) --Ini/Fin de la info fuera pero conteniendolo, acotamos
		when k.starttime <= time_ini and k.endtime <= c.time_fin then DATEDIFF(ms,c.time_ini,k.endtime)		--Ini dentro pero fin posterior, acotamos
	end as duration_acotada
into _BW_RADIO_DURATION_Data_acotada
from  testinfo t
	inner join _intervalos k 
		on t.sessionid=k.sessionid and t.testid=k.testid
	left join _BW_RADIO_DURATION_Data c
		on t.SessionId = c.SessionId  and t.testid=c.testid
			and k.starttime < c.time_fin
			and k.endtime > c.time_ini
where c.testid is not null

-------------------------------------------------------------------------------------------------------------------------------------
-- 4G: Calculo del BW por test y del uso de LTE a partir de la tabla de sistema de BW
-------------------------------------------------------------------------------------------------------------------------------------
--Info acotada al momento de la descarga, subida, navegacion y reproduccion
exec sp_lcc_dropifexists '_BW_acotado'			
select 
	sessionid, testid, 	
	----------------------------------------------------------------------
	-- Info de uso de BW
	----------------------------------------------------------------------
	--Single Carrier:
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is null and max(DLBandWidth_SCC2) is null and max(DLBandWidth)=20 then  1.0
		else isnull(1.0*sum(case when DLBandWidth_SCC1 is null and DLBandWidth_SCC2 is null and DLBandWidth=20 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_20Mhz_SC,			
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is null and max(DLBandWidth_SCC2) is null and max(DLBandWidth)=15 then  1.0
		else isnull(1.0*sum(case when DLBandWidth_SCC1 is null and DLBandWidth_SCC2 is null and DLBandWidth=15 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_15Mhz_SC,	
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is null and max(DLBandWidth_SCC2) is null and max(DLBandWidth)=10 then  1.0
		else isnull(1.0*sum(case when DLBandWidth_SCC1 is null and DLBandWidth_SCC2 is null and DLBandWidth=10 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_10Mhz_SC,
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is null and max(DLBandWidth_SCC2) is null and max(DLBandWidth)=5 then  1.0
		else isnull(1.0*sum(case when DLBandWidth_SCC1 is null and DLBandWidth_SCC2 is null and DLBandWidth=5 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_5Mhz_SC, 

	--Carrier Agregation (exigimos sólo doble carrier):
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is null and max(DLBandWidth+DLBandWidth_SCC1)=40 then  1.0
		else isnull(1.0*sum(case when DLBandWidth_SCC2 is null and (DLBandWidth+DLBandWidth_SCC1)=40 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_40Mhz_CA,			
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is null and max(DLBandWidth+DLBandWidth_SCC1)=35 then  1.0
		else isnull(1.0*sum(case when DLBandWidth_SCC2 is null and (DLBandWidth+DLBandWidth_SCC1)=35 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_35Mhz_CA,	
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is null and max(DLBandWidth+DLBandWidth_SCC1)=30 then  1.0
		else isnull(1.0*sum(case when DLBandWidth_SCC2 is null and (DLBandWidth+DLBandWidth_SCC1)=30 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_30Mhz_CA,
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is null and max(DLBandWidth+DLBandWidth_SCC1)=25 then  1.0
		else isnull(1.0*sum(case when DLBandWidth_SCC2 is null and (DLBandWidth+DLBandWidth_SCC1)=25 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_25Mhz_CA,
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is null and max(DLBandWidth+DLBandWidth_SCC1)=20 then  1.0
		else isnull(1.0*sum(case when DLBandWidth_SCC2 is null and (DLBandWidth+DLBandWidth_SCC1)=20 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_20Mhz_CA,
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is null and max(DLBandWidth+DLBandWidth_SCC1)=15 then  1.0
		else isnull(1.0*sum(case when DLBandWidth_SCC2 is null and (DLBandWidth+DLBandWidth_SCC1)=15 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_15Mhz_CA,

	--Triple Carrier:
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is not null and max(DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2)=60 then  1.0
		else isnull(1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=60 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_60Mhz_3C,	
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is not null and max(DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2)=55 then  1.0
		else isnull(1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=55 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_55Mhz_3C,	
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is not null and max(DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2)=50 then  1.0
		else isnull(1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=50 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_50Mhz_3C,	
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is not null and max(DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2)=45 then  1.0
		else isnull(1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=45 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_45Mhz_3C,	
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is not null and max(DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2)=40 then  1.0
		else isnull(1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=40 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_40Mhz_3C,			
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is not null and max(DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2)=35 then  1.0
		else isnull(1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=35 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_35Mhz_3C,	
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is not null and max(DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2)=30 then  1.0
		else isnull(1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=30 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_30Mhz_3C,
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is not null and max(DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2)=25 then  1.0
		else isnull(1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=25 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_25Mhz_3C, 
	
	--Primera Carrier (sea single o no)
	case when max(durationID)=1 and max(DLBandWidth)=20 then  1.0
		else isnull(1.0*sum(case when DLBandWidth=20 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_20Mhz_PCC,			
	case when max(durationID)=1 and max(DLBandWidth)=15 then  1.0
		else isnull(1.0*sum(case when DLBandWidth=15 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_15Mhz_PCC,	
	case when max(durationID)=1 and max(DLBandWidth)=10 then  1.0
		else isnull(1.0*sum(case when DLBandWidth=10 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_10Mhz_PCC,	
	case when max(durationID)=1 and max(DLBandWidth)=5 then  1.0
		else isnull(1.0*sum(case when DLBandWidth=5 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_5Mhz_PCC, 

	--Segunda Carrier
	isnull(1.0*sum(case when DLBandWidth_SCC1=20 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0) as pctLTE_20Mhz_SCC1,			
	isnull(1.0*sum(case when DLBandWidth_SCC1=15 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0) as pctLTE_15Mhz_SCC1,	
	isnull(1.0*sum(case when DLBandWidth_SCC1=10 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0) as pctLTE_10Mhz_SCC1,	
	isnull(1.0*sum(case when DLBandWidth_SCC1=5 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0) as pctLTE_5Mhz_SCC1, 

	--Tercera Carrier:
	isnull(1.0*sum(case when DLBandWidth_SCC2=20 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0) as pctLTE_20Mhz_SCC2,			
	isnull(1.0*sum(case when DLBandWidth_SCC2=15 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0) as pctLTE_15Mhz_SCC2,	
	isnull(1.0*sum(case when DLBandWidth_SCC2=10 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0) as pctLTE_10Mhz_SCC2,	
	isnull(1.0*sum(case when DLBandWidth_SCC2=5 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0) as pctLTE_5Mhz_SCC2, 

	-- Duraciones (para calculo posterior teniendo en cuenta info de 3G en tablas _Tech_Duration_Distribution)
	1.0*sum(case when DLBandWidth_SCC1 is null and DLBandWidth_SCC2 is null and DLBandWidth=20 then duration_acotada end) as DurationLTE_20Mhz_SC, 		
	1.0*sum(case when DLBandWidth_SCC1 is null and DLBandWidth_SCC2 is null and DLBandWidth=15 then duration_acotada end) as DurationLTE_15Mhz_SC, 	
	1.0*sum(case when DLBandWidth_SCC1 is null and DLBandWidth_SCC2 is null and DLBandWidth=10 then duration_acotada end) as DurationLTE_10Mhz_SC, 
	1.0*sum(case when DLBandWidth_SCC1 is null and DLBandWidth_SCC2 is null and DLBandWidth=5 then duration_acotada end) as DurationLTE_5Mhz_SC, 

	1.0*sum(case when DLBandWidth_SCC2 is null and (DLBandWidth+DLBandWidth_SCC1)=40 then duration_acotada end) as DurationLTE_40Mhz_CA, 		
	1.0*sum(case when DLBandWidth_SCC2 is null and (DLBandWidth+DLBandWidth_SCC1)=35 then duration_acotada end) as DurationLTE_35Mhz_CA, 	
	1.0*sum(case when DLBandWidth_SCC2 is null and (DLBandWidth+DLBandWidth_SCC1)=30 then duration_acotada end) as DurationLTE_30Mhz_CA, 
	1.0*sum(case when DLBandWidth_SCC2 is null and (DLBandWidth+DLBandWidth_SCC1)=25 then duration_acotada end) as DurationLTE_25Mhz_CA, 
	1.0*sum(case when DLBandWidth_SCC2 is null and (DLBandWidth+DLBandWidth_SCC1)=20 then duration_acotada end) as DurationLTE_20Mhz_CA, 
	1.0*sum(case when DLBandWidth_SCC2 is null and (DLBandWidth+DLBandWidth_SCC1)=15 then duration_acotada end) as DurationLTE_15Mhz_CA,
	
	1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=60 then duration_acotada end) as DurationLTE_60Mhz_3C,
	1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=55 then duration_acotada end) as DurationLTE_55Mhz_3C,
	1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=50 then duration_acotada end) as DurationLTE_50Mhz_3C,
	1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=45 then duration_acotada end) as DurationLTE_45Mhz_3C,
	1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=40 then duration_acotada end) as DurationLTE_40Mhz_3C, 		
	1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=35 then duration_acotada end) as DurationLTE_35Mhz_3C, 	
	1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=30 then duration_acotada end) as DurationLTE_30Mhz_3C, 
	1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=25 then duration_acotada end) as DurationLTE_25Mhz_3C, 
	
	1.0*sum(case when DLBandWidth=20 then duration_acotada end) as DurationLTE_20Mhz_PCC, 		
	1.0*sum(case when DLBandWidth=15 then duration_acotada end) as DurationLTE_15Mhz_PCC, 	
	1.0*sum(case when DLBandWidth=10 then duration_acotada end) as DurationLTE_10Mhz_PCC, 
	1.0*sum(case when DLBandWidth=5 then duration_acotada end) as DurationLTE_5Mhz_PCC, 

	1.0*sum(case when DLBandWidth_SCC1=20 then duration_acotada end) as DurationLTE_20Mhz_SCC1, 		
	1.0*sum(case when DLBandWidth_SCC1=15 then duration_acotada end) as DurationLTE_15Mhz_SCC1, 	
	1.0*sum(case when DLBandWidth_SCC1=10 then duration_acotada end) as DurationLTE_10Mhz_SCC1, 
	1.0*sum(case when DLBandWidth_SCC1=5 then duration_acotada end) as DurationLTE_5Mhz_SCC1,

	1.0*sum(case when DLBandWidth_SCC2=20 then duration_acotada end) as DurationLTE_20Mhz_SCC2, 		
	1.0*sum(case when DLBandWidth_SCC2=15 then duration_acotada end) as DurationLTE_15Mhz_SCC2, 	
	1.0*sum(case when DLBandWidth_SCC2=10 then duration_acotada end) as DurationLTE_10Mhz_SCC2,
	1.0*sum(case when DLBandWidth_SCC2=5 then duration_acotada end) as DurationLTE_5Mhz_SCC2,
	----------------------------------------------------------------------
	--Informacion de tecnologia LTE a partir de la tabla de BW
	----------------------------------------------------------------------
	1.0*sum(duration_acotada) as Duration_LTE,
	--PCC
	1.0*sum(case when band like 'LTE800' then duration_acotada end) as Duration_LTE_800, 
	1.0*sum(case when band like 'LTE1800' then duration_acotada end) as Duration_LTE_1800,
	1.0*sum(case when band like 'LTE2100' then duration_acotada end) as Duration_LTE_2100,  
	1.0*sum(case when band like 'LTE2600' then duration_acotada end) as Duration_LTE_2600, 
	--SCC1
	1.0*sum(case when band_SCC1 like 'LTE800' then duration_acotada end) as Duration_LTE_800_SCC1, 
	1.0*sum(case when band_SCC1 like 'LTE1800' then duration_acotada end) as Duration_LTE_1800_SCC1,
	1.0*sum(case when band_SCC1 like 'LTE2100' then duration_acotada end) as Duration_LTE_2100_SCC1,  
	1.0*sum(case when band_SCC1 like 'LTE2600' then duration_acotada end) as Duration_LTE_2600_SCC1, 
	--SCC2
	1.0*sum(case when band_SCC2 like 'LTE800' then duration_acotada end) as Duration_LTE_800_SCC2, 
	1.0*sum(case when band_SCC2 like 'LTE1800' then duration_acotada end) as Duration_LTE_1800_SCC2,
	1.0*sum(case when band_SCC2 like 'LTE2100' then duration_acotada end) as Duration_LTE_2100_SCC2,  
	1.0*sum(case when band_SCC2 like 'LTE2600' then duration_acotada end) as Duration_LTE_2600_SCC2,

	1.0*sum(case when band_SCC1 is not null then duration_acotada end) as Duration_LTE_SCC1,
	1.0*sum(case when band_SCC2 is not null then duration_acotada end) as Duration_LTE_SCC2,

	1.0*sum(case when band_SCC1 is null and band_SCC2 is null then duration_acotada else 0 end) as Duration_LTE_SC,
	1.0*sum(case when band_SCC1 is not null and band_SCC2 is null then duration_acotada else 0 end) as Duration_LTE_CA,
	1.0*sum(case when band_SCC1 is not null and band_SCC2 is not null then duration_acotada else 0 end) as Duration_LTE_3C,
	
	--Info de roaming por operador:
	1.0*sum(case when operator <> 'Vodafone' and ServingOperator='Vodafone' then duration_acotada end) as Roaming_LTE_VF, 
	1.0*sum(case when operator <> 'Movistar' and ServingOperator='Movistar' then duration_acotada end) as Roaming_LTE_MV, 
	1.0*sum(case when operator <> 'Orange' and ServingOperator='Orange' then duration_acotada end) as Roaming_LTE_OR, 
	1.0*sum(case when operator <> 'Yoigo' and ServingOperator='Yoigo' then duration_acotada end) as Roaming_LTE_YO, 
	--Desglose de roaming por banda:
	1.0*sum(case when operator <> ServingOperator and Band='LTE800' then duration_acotada end) as Roaming_LTE800,
	1.0*sum(case when operator <> ServingOperator and Band='LTE1800' then duration_acotada end) as Roaming_LTE1800,
	1.0*sum(case when operator <> ServingOperator and Band='LTE2100' then duration_acotada end) as Roaming_LTE2100,
	1.0*sum(case when operator <> ServingOperator and Band='LTE2600' then duration_acotada end) as Roaming_LTE2600,

	--Campo de control para saber si el BW de la primera carrier se ha estimado por banda o no
	max(case when DLBandWidth_real is null then 1 else 0 end) as DLBandWidth_est

into _BW_acotado
from _BW_RADIO_DURATION_Data_acotada
where band is not null
group by sessionid, TestId
order by sessionid, TestId

--Info acotada al momento de la descarga, subida, navegacion y reproduccion, teniendo en cuenta el acceso:
exec sp_lcc_dropifexists '_BW_acotado_acc'			
select 
	sessionid, testid, 	
	----------------------------------------------------------------------
	-- Info de uso de BW
	----------------------------------------------------------------------
	--Single Carrier:
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is null and max(DLBandWidth_SCC2) is null and max(DLBandWidth)=20 then  1.0
		else isnull(1.0*sum(case when DLBandWidth_SCC1 is null and DLBandWidth_SCC2 is null and DLBandWidth=20 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_20Mhz_SC,
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is null and max(DLBandWidth_SCC2) is null and max(DLBandWidth)=15 then  1.0
		else isnull(1.0*sum(case when DLBandWidth_SCC1 is null and DLBandWidth_SCC2 is null and DLBandWidth=15 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_15Mhz_SC, 
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is null and max(DLBandWidth_SCC2) is null and max(DLBandWidth)=10 then  1.0
		else isnull(1.0*sum(case when DLBandWidth_SCC1 is null and DLBandWidth_SCC2 is null and DLBandWidth=10 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_10Mhz_SC, 
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is null and max(DLBandWidth_SCC2) is null and max(DLBandWidth)=5 then  1.0
		else isnull(1.0*sum(case when DLBandWidth_SCC1 is null and DLBandWidth_SCC2 is null and DLBandWidth=5 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_5Mhz_SC, 

	--Carrier Agregation (exigimos sólo doble carrier):
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is null and max(DLBandWidth+DLBandWidth_SCC1)=40 then  1.0
		else isnull(1.0*sum(case when DLBandWidth_SCC2 is null and (DLBandWidth+DLBandWidth_SCC1)=40 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_40Mhz_CA, 
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is null and max(DLBandWidth+DLBandWidth_SCC1)=35 then  1.0
		else isnull(1.0*sum(case when DLBandWidth_SCC2 is null and (DLBandWidth+DLBandWidth_SCC1)=35 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_35Mhz_CA, 
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is null and max(DLBandWidth+DLBandWidth_SCC1)=30 then  1.0
		else isnull(1.0*sum(case when DLBandWidth_SCC2 is null and (DLBandWidth+DLBandWidth_SCC1)=30 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_30Mhz_CA, 
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is null and max(DLBandWidth+DLBandWidth_SCC1)=25 then  1.0
		else isnull(1.0*sum(case when DLBandWidth_SCC2 is null and (DLBandWidth+DLBandWidth_SCC1)=25 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_25Mhz_CA, 
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is null and max(DLBandWidth+DLBandWidth_SCC1)=20 then  1.0
		else isnull(1.0*sum(case when DLBandWidth_SCC2 is null and (DLBandWidth+DLBandWidth_SCC1)=20 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_20Mhz_CA,
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is null and max(DLBandWidth+DLBandWidth_SCC1)=15 then  1.0
		else isnull(1.0*sum(case when DLBandWidth_SCC2 is null and (DLBandWidth+DLBandWidth_SCC1)=15 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_15Mhz_CA,

	--Triple Carrier:
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is not null and max(DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2)=60 then  1.0
		else isnull(1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=60 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_60Mhz_3C, 
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is not null and max(DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2)=55 then  1.0
		else isnull(1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=55 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_55Mhz_3C, 
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is not null and max(DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2)=50 then  1.0
		else isnull(1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=50 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_50Mhz_3C, 
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is not null and max(DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2)=45 then  1.0
		else isnull(1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=45 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_45Mhz_3C, 
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is not null and max(DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2)=40 then  1.0
		else isnull(1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=40 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_40Mhz_3C, 
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is not null and max(DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2)=35 then  1.0
		else isnull(1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=35 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_35Mhz_3C, 
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is not null and max(DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2)=30 then  1.0
		else isnull(1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=30 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_30Mhz_3C, 
	case when max(durationID)=1 and max(DLBandWidth_SCC1) is not null and max(DLBandWidth_SCC2) is not null and max(DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2)=25 then  1.0
		else isnull(1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=25 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_25Mhz_3C, 
	
	--Primera Carrier (sea single o no)
	case when max(durationID)=1 and max(DLBandWidth)=20 then  1.0
		else isnull(1.0*sum(case when DLBandWidth=20 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_20Mhz_PCC, 
	case when max(durationID)=1 and max(DLBandWidth)=15 then  1.0
		else isnull(1.0*sum(case when DLBandWidth=15 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_15Mhz_PCC, 	
	case when max(durationID)=1 and max(DLBandWidth)=10 then  1.0
		else isnull(1.0*sum(case when DLBandWidth=10 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_10Mhz_PCC, 
	case when max(durationID)=1 and max(DLBandWidth)=5 then  1.0
		else isnull(1.0*sum(case when DLBandWidth=5 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0)
	end as pctLTE_5Mhz_PCC, 

	--Segunda Carrier
	isnull(1.0*sum(case when DLBandWidth_SCC1=20 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0) as pctLTE_20Mhz_SCC1, 
	isnull(1.0*sum(case when DLBandWidth_SCC1=15 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0) as pctLTE_15Mhz_SCC1, 
	isnull(1.0*sum(case when DLBandWidth_SCC1=10 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0) as pctLTE_10Mhz_SCC1, 
	isnull(1.0*sum(case when DLBandWidth_SCC1=5 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0) as pctLTE_5Mhz_SCC1, 

	--Tercera Carrier:
	isnull(1.0*sum(case when DLBandWidth_SCC2=20 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0) as pctLTE_20Mhz_SCC2,
	isnull(1.0*sum(case when DLBandWidth_SCC2=15 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0) as pctLTE_15Mhz_SCC2, 
	isnull(1.0*sum(case when DLBandWidth_SCC2=10 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0) as pctLTE_10Mhz_SCC2, 
	isnull(1.0*sum(case when DLBandWidth_SCC2=5 then duration_acotada end),0) / NULLIF(sum(duration_acotada),0) as pctLTE_5Mhz_SCC2, 

	-- Duraciones (para calculo posterior teniendo en cuenta info de 3G en tablas _Tech_Duration_Distribution)
	1.0*sum(case when DLBandWidth_SCC1 is null and DLBandWidth_SCC2 is null and DLBandWidth=20 then duration_acotada end) as DurationLTE_20Mhz_SC, 		
	1.0*sum(case when DLBandWidth_SCC1 is null and DLBandWidth_SCC2 is null and DLBandWidth=15 then duration_acotada end) as DurationLTE_15Mhz_SC, 	
	1.0*sum(case when DLBandWidth_SCC1 is null and DLBandWidth_SCC2 is null and DLBandWidth=10 then duration_acotada end) as DurationLTE_10Mhz_SC, 
	1.0*sum(case when DLBandWidth_SCC1 is null and DLBandWidth_SCC2 is null and DLBandWidth=5 then duration_acotada end) as DurationLTE_5Mhz_SC, 

	1.0*sum(case when DLBandWidth_SCC2 is null and (DLBandWidth+DLBandWidth_SCC1)=40 then duration_acotada end) as DurationLTE_40Mhz_CA, 		
	1.0*sum(case when DLBandWidth_SCC2 is null and (DLBandWidth+DLBandWidth_SCC1)=35 then duration_acotada end) as DurationLTE_35Mhz_CA, 	
	1.0*sum(case when DLBandWidth_SCC2 is null and (DLBandWidth+DLBandWidth_SCC1)=30 then duration_acotada end) as DurationLTE_30Mhz_CA, 
	1.0*sum(case when DLBandWidth_SCC2 is null and (DLBandWidth+DLBandWidth_SCC1)=25 then duration_acotada end) as DurationLTE_25Mhz_CA, 
	1.0*sum(case when DLBandWidth_SCC2 is null and (DLBandWidth+DLBandWidth_SCC1)=20 then duration_acotada end) as DurationLTE_20Mhz_CA, 
	1.0*sum(case when DLBandWidth_SCC2 is null and (DLBandWidth+DLBandWidth_SCC1)=15 then duration_acotada end) as DurationLTE_15Mhz_CA,
	
	1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=60 then duration_acotada end) as DurationLTE_60Mhz_3C,
	1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=55 then duration_acotada end) as DurationLTE_55Mhz_3C,
	1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=50 then duration_acotada end) as DurationLTE_50Mhz_3C,
	1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=45 then duration_acotada end) as DurationLTE_45Mhz_3C,
	1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=40 then duration_acotada end) as DurationLTE_40Mhz_3C, 		
	1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=35 then duration_acotada end) as DurationLTE_35Mhz_3C, 	
	1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=30 then duration_acotada end) as DurationLTE_30Mhz_3C, 
	1.0*sum(case when DLBandWidth+DLBandWidth_SCC1+DLBandWidth_SCC2=25 then duration_acotada end) as DurationLTE_25Mhz_3C, 
	
	1.0*sum(case when DLBandWidth=20 then duration_acotada end) as DurationLTE_20Mhz_PCC, 		
	1.0*sum(case when DLBandWidth=15 then duration_acotada end) as DurationLTE_15Mhz_PCC, 	
	1.0*sum(case when DLBandWidth=10 then duration_acotada end) as DurationLTE_10Mhz_PCC, 
	1.0*sum(case when DLBandWidth=5 then duration_acotada end) as DurationLTE_5Mhz_PCC, 

	1.0*sum(case when DLBandWidth_SCC1=20 then duration_acotada end) as DurationLTE_20Mhz_SCC1, 		
	1.0*sum(case when DLBandWidth_SCC1=15 then duration_acotada end) as DurationLTE_15Mhz_SCC1, 	
	1.0*sum(case when DLBandWidth_SCC1=10 then duration_acotada end) as DurationLTE_10Mhz_SCC1, 
	1.0*sum(case when DLBandWidth_SCC1=5 then duration_acotada end) as DurationLTE_5Mhz_SCC1,

	1.0*sum(case when DLBandWidth_SCC2=20 then duration_acotada end) as DurationLTE_20Mhz_SCC2, 		
	1.0*sum(case when DLBandWidth_SCC2=15 then duration_acotada end) as DurationLTE_15Mhz_SCC2, 	
	1.0*sum(case when DLBandWidth_SCC2=10 then duration_acotada end) as DurationLTE_10Mhz_SCC2,
	1.0*sum(case when DLBandWidth_SCC2=5 then duration_acotada end) as DurationLTE_5Mhz_SCC2,
	----------------------------------------------------------------------
	--Informacion de tecnologia LTE a partir de la tabla de BW
	----------------------------------------------------------------------
	1.0*sum(duration_acotada) as Duration_LTE,
	--PCC
	1.0*sum(case when band like 'LTE800' then duration_acotada end) as Duration_LTE_800, 
	1.0*sum(case when band like 'LTE1800' then duration_acotada end) as Duration_LTE_1800,
	1.0*sum(case when band like 'LTE2100' then duration_acotada end) as Duration_LTE_2100,  
	1.0*sum(case when band like 'LTE2600' then duration_acotada end) as Duration_LTE_2600, 
	--SCC1
	1.0*sum(case when band_SCC1 like 'LTE800' then duration_acotada end) as Duration_LTE_800_SCC1, 
	1.0*sum(case when band_SCC1 like 'LTE1800' then duration_acotada end) as Duration_LTE_1800_SCC1,
	1.0*sum(case when band_SCC1 like 'LTE2100' then duration_acotada end) as Duration_LTE_2100_SCC1,  
	1.0*sum(case when band_SCC1 like 'LTE2600' then duration_acotada end) as Duration_LTE_2600_SCC1, 
	--SCC2
	1.0*sum(case when band_SCC2 like 'LTE800' then duration_acotada end) as Duration_LTE_800_SCC2, 
	1.0*sum(case when band_SCC2 like 'LTE1800' then duration_acotada end) as Duration_LTE_1800_SCC2,
	1.0*sum(case when band_SCC2 like 'LTE2100' then duration_acotada end) as Duration_LTE_2100_SCC2,  
	1.0*sum(case when band_SCC2 like 'LTE2600' then duration_acotada end) as Duration_LTE_2600_SCC2,

	1.0*sum(case when band_SCC1 is not null then duration_acotada end) as Duration_LTE_SCC1,
	1.0*sum(case when band_SCC2 is not null then duration_acotada end) as Duration_LTE_SCC2,

	1.0*sum(case when band_SCC1 is null and band_SCC2 is null then duration_acotada else 0 end) as Duration_LTE_SC,
	1.0*sum(case when band_SCC1 is not null and band_SCC2 is null then duration_acotada else 0 end) as Duration_LTE_CA,
	1.0*sum(case when band_SCC1 is not null and band_SCC2 is not null then duration_acotada else 0 end) as Duration_LTE_3C,

	--Info de roaming por operador:
	1.0*sum(case when operator <> 'Vodafone' and ServingOperator='Vodafone' then duration_acotada end) as Roaming_LTE_VF, 
	1.0*sum(case when operator <> 'Movistar' and ServingOperator='Movistar' then duration_acotada end) as Roaming_LTE_MV, 
	1.0*sum(case when operator <> 'Orange' and ServingOperator='Orange' then duration_acotada end) as Roaming_LTE_OR, 
	1.0*sum(case when operator <> 'Yoigo' and ServingOperator='Yoigo' then duration_acotada end) as Roaming_LTE_YO, 
	--Desglose de roaming por banda:
	1.0*sum(case when operator <> ServingOperator and Band='LTE800' then duration_acotada end) as Roaming_LTE800,
	1.0*sum(case when operator <> ServingOperator and Band='LTE1800' then duration_acotada end) as Roaming_LTE1800,
	1.0*sum(case when operator <> ServingOperator and Band='LTE2100' then duration_acotada end) as Roaming_LTE2100,
	1.0*sum(case when operator <> ServingOperator and Band='LTE2600' then duration_acotada end) as Roaming_LTE2600,

	--Campo de control para saber si el BW de la primera carrier se ha estimado por banda o no
	max(case when DLBandWidth_real is null then 1 else 0 end) as DLBandWidth_est

into _BW_acotado_acc
from _BW_RADIO_DURATION_Data_acotada_all
where band is not null
group by sessionid, TestId
order by sessionid, TestId

--Sin acotar: para YTB y LAT (pero solo informacion de uso de LTE y roaming):
exec sp_lcc_dropifexists '_BW'			
select 
	sessionid, testid, 	
	----------------------------------------------------------------------
	--Informacion de tecnologia LTE a partir de la tabla de BW
	----------------------------------------------------------------------
	1.0*sum(duration) as Duration_LTE,
	--PCC
	1.0*sum(case when band like 'LTE800' then duration end) as Duration_LTE_800, 
	1.0*sum(case when band like 'LTE1800' then duration end) as Duration_LTE_1800,
	1.0*sum(case when band like 'LTE2100' then duration end) as Duration_LTE_2100,  
	1.0*sum(case when band like 'LTE2600' then duration end) as Duration_LTE_2600, 
	--SCC1
	1.0*sum(case when band_SCC1 like 'LTE800' then duration end) as Duration_LTE_800_SCC1, 
	1.0*sum(case when band_SCC1 like 'LTE1800' then duration end) as Duration_LTE_1800_SCC1,
	1.0*sum(case when band_SCC1 like 'LTE2100' then duration end) as Duration_LTE_2100_SCC1,  
	1.0*sum(case when band_SCC1 like 'LTE2600' then duration end) as Duration_LTE_2600_SCC1, 
	--SCC2
	1.0*sum(case when band_SCC2 like 'LTE800' then duration end) as Duration_LTE_800_SCC2, 
	1.0*sum(case when band_SCC2 like 'LTE1800' then duration end) as Duration_LTE_1800_SCC2,
	1.0*sum(case when band_SCC2 like 'LTE2100' then duration end) as Duration_LTE_2100_SCC2,  
	1.0*sum(case when band_SCC2 like 'LTE2600' then duration end) as Duration_LTE_2600_SCC2,

	1.0*sum(case when band_SCC1 is not null then duration end) as Duration_LTE_SCC1,
	1.0*sum(case when band_SCC2 is not null then duration end) as Duration_LTE_SCC2,

	1.0*sum(case when band_SCC1 is null and band_SCC2 is null then duration else 0 end) as Duration_LTE_SC,
	1.0*sum(case when band_SCC1 is not null and band_SCC2 is null then duration else 0 end) as Duration_LTE_CA,
	1.0*sum(case when band_SCC1 is not null and band_SCC2 is not null then duration else 0 end) as Duration_LTE_3C,

	--Info de roaming por operador:
	1.0*sum(case when operator <> 'Vodafone' and ServingOperator='Vodafone' then duration end) as Roaming_LTE_VF, 
	1.0*sum(case when operator <> 'Movistar' and ServingOperator='Movistar' then duration end) as Roaming_LTE_MV, 
	1.0*sum(case when operator <> 'Orange' and ServingOperator='Orange' then duration end) as Roaming_LTE_OR, 
	1.0*sum(case when operator <> 'Yoigo' and ServingOperator='Yoigo' then duration end) as Roaming_LTE_YO, 
	--Desglose de roaming por banda:
	1.0*sum(case when operator <> ServingOperator and Band='LTE800' then duration end) as Roaming_LTE800,
	1.0*sum(case when operator <> ServingOperator and Band='LTE1800' then duration end) as Roaming_LTE1800,
	1.0*sum(case when operator <> ServingOperator and Band='LTE2100' then duration end) as Roaming_LTE2100,
	1.0*sum(case when operator <> ServingOperator and Band='LTE2600' then duration end) as Roaming_LTE2600

into _BW
from _BW_RADIO_DURATION_Data
where band is not null
group by sessionid, TestId
order by sessionid, TestId

-------------------------------------------------------------------------------------------------------------------------------------
-- 3G: Calculo de las duraciones de Modulaciones, Codigos, Uso Dual Carrier y Retransmisiones 3G
-- La información se calcula hacia atrás en cada intervalo, de forma análoga a las modulaciones de 4G (tabla lcc_Physical_Info_Table)
-------------------------------------------------------------------------------------------------------------------------------------
-- DGP 29/10/2015: Se linka con la tabla networkinfo para sacar las tecnologías usadas en cada test y así desglosar por banda el DC
-- *********************************************************************************************************************************
-- DGP 19/05/2016: Se cambia la forma de calcular el uso de códigos, pues en QPs cuando hay SC no se rellena el desglose por Carrier
-- *********************************************************************************************************************************

--Ordenamos la informacion por test-instante de tiempo e incorporamos la banda y frecuencia reportada en networkinfo
exec sp_lcc_dropifexists '_MOD_3G_id'
select h.*,n.technology,n.bcch as Freq,t.operator, sof.ServingOperator,
	ROW_NUMBER() over (partition by h.sessionid, h.testid order by h.msgtime asc) as durationID
into _MOD_3G_id
from HSDPAModulation h
	inner join networkinfo n on n.networkid=h.networkid
	inner join _test_Operator t on h.testid=t.testid
	left join [AGRIDS].dbo.lcc_ref_servingOperator_Freq sof on n.bcch=sof.Frequency
where AvgNumCodeChannels <> 0 -- DGP 17/09/2015: se descartan los tests con code=0 por darse en periodos de negociación de la medida
	and h.testId > @maxTestid	 


-- Calculos de las duraciones: inicio = msgTime, fin = msgTime posterior o fin de test
exec sp_lcc_dropifexists '_MOD_3G_duration'		
select 
	ini.sessionid, ini.testid, ini.posid, ini.networkid, 
	ini.msgtime as time_ini, 
	isnull(fin.MsgTime,DATEADD(ms, t.duration ,t.startTime)) as time_fin, 
	datediff(ms,ini.msgtime, isnull(fin.MsgTime,DATEADD(ms, t.duration ,t.startTime))) as duration,
	fin.numsamples, fin.modschemeqpsk, fin.ModScheme16QAM, fin.ModScheme64QAM, 
	fin.AvgNumCodeChannels, fin.AvgNumCodeChannels_C0, fin.AvgNumCodeChannels_C1, 
	fin.EnabledDualCarrier, fin.NumRetransmissions, fin.RateRetransmissions, fin.enabled64QAM,fin.technology,fin.Freq,fin.operator,fin.ServingOperator
into _MOD_3G_duration
from _MOD_3G_id ini 
	inner join testinfo t
		on (ini.sessionid = t.sessionid and ini.TestId=t.TestId)			
	left join _MOD_3G_id fin
		on (ini.sessionid = fin.sessionid and ini.TestId = fin.TestId
			and ini.durationID = fin.durationID -1)

--Info acotada al momento de la descarga, subida, navegacion y reproduccion
exec sp_lcc_dropifexists '_MOD_3G_duration_acotada'
select c.*
	,case when k.starttime <= c.time_ini then c.time_ini
		else k.starttime
	end as time_ini_acotado
	,case when c.time_fin <= k.endtime then c.time_fin
		else k.endtime
	end as time_fin_acotado
	,case when k.starttime <= c.time_ini and c.time_fin <= k.endtime then c.duration						--Ini/Fin de la info dentro
		when c.time_ini <= k.starttime and k.endtime <= c.time_fin then k.duration							--Ini anterior y fin dentro, acotamos
		when c.time_ini <= k.starttime and c.time_fin <= k.endtime then DATEDIFF(ms,k.starttime,c.time_fin) --Ini/Fin de la info fuera pero conteniendolo, acotamos
		when k.starttime <= time_ini and k.endtime <= c.time_fin then DATEDIFF(ms,c.time_ini,k.endtime)		--Ini dentro pero fin posterior, acotamos
	end as duration_acotada
into _MOD_3G_duration_acotada
from  testinfo t
	inner join _intervalos k 
		on t.sessionid=k.sessionid and t.testid=k.testid
	left join _MOD_3G_duration c
		on t.SessionId = c.SessionId  and t.testid=c.testid
			and k.starttime < c.time_fin
			and k.endtime > c.time_ini
where c.testid is not null

--Info acotada al momento de la descarga, subida, navegacion y reproduccion, teniendo en cuenta el acceso:
exec sp_lcc_dropifexists '_MOD_3G_duration_acotada_acc'
select c.*
	,case when k.starttime <= c.time_ini then c.time_ini
		else k.starttime
	end as time_ini_acotado
	,case when c.time_fin <= k.endtime then c.time_fin
		else k.endtime
	end as time_fin_acotado
	,case when k.starttime <= c.time_ini and c.time_fin <= k.endtime then c.duration						--Ini/Fin de la info dentro
		when c.time_ini <= k.starttime and k.endtime <= c.time_fin then k.duration							--Ini anterior y fin dentro, acotamos
		when c.time_ini <= k.starttime and c.time_fin <= k.endtime then DATEDIFF(ms,k.starttime,c.time_fin) --Ini/Fin de la info fuera pero conteniendolo, acotamos
		when k.starttime <= time_ini and k.endtime <= c.time_fin then DATEDIFF(ms,c.time_ini,k.endtime)		--Ini dentro pero fin posterior, acotamos
	end as duration_acotada
into _MOD_3G_duration_acotada_acc
from testinfo t
	inner join _intervalos_all k 
		on t.sessionid=k.sessionid and t.testid=k.testid
	left join _MOD_3G_duration c
		on t.SessionId = c.SessionId  and t.testid=c.testid
			and k.starttime < c.time_fin
			and k.endtime > c.time_ini
where c.testid is not null


-------------------------------------------------------------------------------------------------------------------------------------
-- 3G: Calculo de Modulaciones, Codigos, Uso Dual Carrier y Retransmisiones 3G
-------------------------------------------------------------------------------------------------------------------------------------
--Info acotada al momento de la descarga, subida, navegacion y reproduccion
exec sp_lcc_dropifexists '_MOD_3G_acotado'			
select 
	h.testid, h.sessionid, 
	case when sum(h.numsamples)=0 then 0.0 else 1.0*SUM(h.modschemeqpsk)/SUM(h.numsamples) end as Percent_QPSK,
	case when sum(h.numsamples)=0 then 0.0 else 1.0*SUM(h.ModScheme16QAM)/SUM(h.numsamples) end  as Percent_16QAM,
	case when sum(h.numsamples)=0 then 0.0 else 1.0*SUM(h.ModScheme64QAM)/SUM(h.numsamples) end  as Percent_64QAM,
	
	case when (AVG(h.AvgNumCodeChannels_C0) is null and AVG(h.AvgNumCodeChannels_C1) is null) then AVG(1.0*h.AvgNumCodeChannels)
		 else AVG(1.0*h.AvgNumCodeChannels_C0+h.AvgNumCodeChannels_C1)
		 end AS Average_codes,
	case when AVG(h.AvgNumCodeChannels_C0) is null then AVG(1.0*h.AvgNumCodeChannels)
		 else AVG(1.0*h.AvgNumCodeChannels_C0)
	end AS Average_codes_C0,	
	AVG(1.0*h.AvgNumCodeChannels_C1) AS Average_codes_C1,
		
	case when (MAX(h.AvgNumCodeChannels_C0) is null and MAX(h.AvgNumCodeChannels_C1) is null) then MAX(1.0*h.AvgNumCodeChannels)
		 else MAX(1.0*h.AvgNumCodeChannels_C0+h.AvgNumCodeChannels_C1)
		 end AS max_codes,
	case when MAX(h.AvgNumCodeChannels_C0) is null then MAX(h.AvgNumCodeChannels)
		 else MAX(1.0*h.AvgNumCodeChannels_C0)
		 end AS max_codes_C0,
	MAX(h.AvgNumCodeChannels_C1) AS max_codes_C1,
	
	1.0*SUM(h.EnabledDualCarrier)/SUM(1) as DualCarrier_use,
	1.0*sum(case when (h.technology='UMTS 2100') then h.EnabledDualCarrier else 0.0 end)/SUM(1) as DualCarrier_use_U2100,
	1.0*sum(case when (h.technology='UMTS 900') then h.EnabledDualCarrier else 0.0 end)/SUM(1) as DualCarrier_use_U900,
	SUM(h.NumRetransmissions) as sumNumRetransmissions,
	AVG(h.RateRetransmissions) as avgRateRetransmissions,

	1.0*SUM(case when h.EnabledDualCarrier=0 and h.enabled64QAM=0 then isnull(h.duration_acotada,0) end) as 'sumDurationHSPA',
	1.0*SUM(case when h.EnabledDualCarrier=0 and h.enabled64QAM=1 then isnull(h.duration_acotada,0) end) as 'sumDurationHSPA+',
	1.0*SUM(case when h.EnabledDualCarrier=1 and h.enabled64QAM=0 then isnull(h.duration_acotada,0) end) as 'sumDurationHSPA_DC',
	1.0*SUM(case when h.EnabledDualCarrier=1 and h.enabled64QAM=1 then isnull(h.duration_acotada,0) end) as 'sumDurationHSPA+_DC',
	1.0*SUM(case when h.EnabledDualCarrier=1 then isnull(h.duration_acotada,0) end) as 'sumDurationDualCarrier',
	1.0*sum(case when h.EnabledDualCarrier=1 and h.technology='UMTS 2100' then isnull(h.duration_acotada,0) end) as sumDurationDualCarrier_use_U2100,
	1.0*sum(case when h.EnabledDualCarrier=1 and h.technology='UMTS 900' then isnull(h.duration_acotada,0) end) as sumDurationDualCarrier_use_U900,


	----------------------------------------------------------------------
	--Informacion de tecnologia 3G
	----------------------------------------------------------------------	
	-- Frecuencias U2100:
	1.0*sum(case when h.Freq in (10638,   10788,  10713,  10563) then h.duration_acotada end) as Duration_F1_U2100,
	1.0*sum(case when h.Freq in (10663,	10813,	10738,	10588) then h.duration_acotada end) as Duration_F2_U2100,
	1.0*sum(case when h.Freq in (10688,	10838,	10763,	10613) then h.duration_acotada end) as Duration_F3_U2100,	
	-- Frecuencias U900:
	1.0*sum(case when h.Freq in (3062, 3011, 2959) then h.duration_acotada end) as Duration_F1_U900,
	1.0*sum(case when h.Freq in (3087, 3022) then h.duration_acotada end) as Duration_F2_U900,
	-- Desglose tecnologia (referida a primera carrier):
	1.0*sum(case when h.technology like '%UMTS%' then h.duration_acotada end) as Duration_WCDMA,
	--Desglose 3G:
	1.0*sum(case when h.technology like 'UMTS 2100' then h.duration_acotada end) as Duration_UMTS_2100, 
	1.0*sum(case when h.technology like 'UMTS 900' then h.duration_acotada end) as Duration_UMTS_900,

	--Info de roaming por operador:
	1.0*sum(case when h.operator <> 'Vodafone' and h.ServingOperator='Vodafone' then h.duration_acotada end) as Roaming_UMTS_VF, 
	1.0*sum(case when h.operator <> 'Movistar' and h.ServingOperator='Movistar' then h.duration_acotada end) as Roaming_UMTS_MV, 
	1.0*sum(case when h.operator <> 'Orange' and h.ServingOperator='Orange' then h.duration_acotada end) as Roaming_UMTS_OR, 
	1.0*sum(case when h.operator <> 'Yoigo' and h.ServingOperator='Yoigo' then h.duration_acotada end) as Roaming_UMTS_YO, 
	--Desglose de roaming por banda:
	1.0*sum(case when h.operator <> h.ServingOperator and h.technology='UMTS 900' then h.duration_acotada end) as Roaming_U900,
	1.0*sum(case when h.operator <> h.ServingOperator and h.technology='UMTS 2100' then h.duration_acotada end) as Roaming_U2100

into _MOD_3G_acotado
from _MOD_3G_duration_acotada h
group by h.sessionid,h.TestId

--Info acotada al momento de la descarga, subida, navegacion y reproduccion, teniendo en cuenta el acceso
exec sp_lcc_dropifexists '_MOD_3G_acotado_acc'			
select 
	h.testid, h.sessionid, 
	case when sum(h.numsamples)=0 then 0.0 else 1.0*SUM(h.modschemeqpsk)/SUM(h.numsamples) end as Percent_QPSK,
	case when sum(h.numsamples)=0 then 0.0 else 1.0*SUM(h.ModScheme16QAM)/SUM(h.numsamples) end  as Percent_16QAM,
	case when sum(h.numsamples)=0 then 0.0 else 1.0*SUM(h.ModScheme64QAM)/SUM(h.numsamples) end  as Percent_64QAM,
	
	case when (AVG(h.AvgNumCodeChannels_C0) is null and AVG(h.AvgNumCodeChannels_C1) is null) then AVG(1.0*h.AvgNumCodeChannels)
		 else AVG(1.0*h.AvgNumCodeChannels_C0+h.AvgNumCodeChannels_C1)
		 end AS Average_codes,
	case when AVG(h.AvgNumCodeChannels_C0) is null then AVG(1.0*h.AvgNumCodeChannels)
		 else AVG(1.0*h.AvgNumCodeChannels_C0)
	end AS Average_codes_C0,	
	AVG(1.0*h.AvgNumCodeChannels_C1) AS Average_codes_C1,
		
	case when (MAX(h.AvgNumCodeChannels_C0) is null and MAX(h.AvgNumCodeChannels_C1) is null) then MAX(1.0*h.AvgNumCodeChannels)
		 else MAX(1.0*h.AvgNumCodeChannels_C0+h.AvgNumCodeChannels_C1)
		 end AS max_codes,
	case when MAX(h.AvgNumCodeChannels_C0) is null then MAX(h.AvgNumCodeChannels)
		 else MAX(1.0*h.AvgNumCodeChannels_C0)
		 end AS max_codes_C0,
	MAX(h.AvgNumCodeChannels_C1) AS max_codes_C1,
	
	1.0*SUM(h.EnabledDualCarrier)/SUM(1) as DualCarrier_use,
	1.0*sum(case when (h.technology='UMTS 2100') then h.EnabledDualCarrier else 0.0 end)/SUM(1) as DualCarrier_use_U2100,
	1.0*sum(case when (h.technology='UMTS 900') then h.EnabledDualCarrier else 0.0 end)/SUM(1) as DualCarrier_use_U900,
	SUM(h.NumRetransmissions) as sumNumRetransmissions,
	AVG(h.RateRetransmissions) as avgRateRetransmissions,

	1.0*SUM(case when h.EnabledDualCarrier=0 and h.enabled64QAM=0 then isnull(h.duration_acotada,0) end) as 'sumDurationHSPA',
	1.0*SUM(case when h.EnabledDualCarrier=0 and h.enabled64QAM=1 then isnull(h.duration_acotada,0) end) as 'sumDurationHSPA+',
	1.0*SUM(case when h.EnabledDualCarrier=1 and h.enabled64QAM=0 then isnull(h.duration_acotada,0) end) as 'sumDurationHSPA_DC',
	1.0*SUM(case when h.EnabledDualCarrier=1 and h.enabled64QAM=1 then isnull(h.duration_acotada,0) end) as 'sumDurationHSPA+_DC',
	1.0*SUM(case when h.EnabledDualCarrier=1 then isnull(h.duration_acotada,0) end) as 'sumDurationDualCarrier',
	1.0*sum(case when h.EnabledDualCarrier=1 and h.technology='UMTS 2100' then isnull(h.duration_acotada,0) end) as sumDurationDualCarrier_use_U2100,
	1.0*sum(case when h.EnabledDualCarrier=1 and h.technology='UMTS 900' then isnull(h.duration_acotada,0) end) as sumDurationDualCarrier_use_U900,


	----------------------------------------------------------------------
	--Informacion de tecnologia LTE a partir de la tabla de BW
	----------------------------------------------------------------------	
	-- Frecuencias U2100:
	1.0*sum(case when h.Freq in (10638,   10788,  10713,  10563) then h.duration_acotada end) as Duration_F1_U2100,
	1.0*sum(case when h.Freq in (10663,	10813,	10738,	10588) then h.duration_acotada end) as Duration_F2_U2100,
	1.0*sum(case when h.Freq in (10688,	10838,	10763,	10613) then h.duration_acotada end) as Duration_F3_U2100,	
	-- Frecuencias U900:
	1.0*sum(case when h.Freq in (3062, 3011, 2959) then h.duration_acotada end) as Duration_F1_U900,
	1.0*sum(case when h.Freq in (3087, 3022) then h.duration_acotada end) as Duration_F2_U900,
	-- Desglose tecnologia (referida a primera carrier):
	1.0*sum(case when h.technology like '%UMTS%' then h.duration_acotada end) as Duration_WCDMA,
	--Desglose 3G:
	1.0*sum(case when h.technology like 'UMTS 2100' then h.duration_acotada end) as Duration_UMTS_2100, 
	1.0*sum(case when h.technology like 'UMTS 900' then h.duration_acotada end) as Duration_UMTS_900,

	--Info de roaming por operador:
	1.0*sum(case when h.operator <> 'Vodafone' and h.ServingOperator='Vodafone' then h.duration_acotada end) as Roaming_UMTS_VF, 
	1.0*sum(case when h.operator <> 'Movistar' and h.ServingOperator='Movistar' then h.duration_acotada end) as Roaming_UMTS_MV, 
	1.0*sum(case when h.operator <> 'Orange' and h.ServingOperator='Orange' then h.duration_acotada end) as Roaming_UMTS_OR, 
	1.0*sum(case when h.operator <> 'Yoigo' and h.ServingOperator='Yoigo' then h.duration_acotada end) as Roaming_UMTS_YO, 
	--Desglose de roaming por banda:
	1.0*sum(case when h.operator <> h.ServingOperator and h.technology='UMTS 900' then h.duration_acotada end) as Roaming_U900,
	1.0*sum(case when h.operator <> h.ServingOperator and h.technology='UMTS 2100' then h.duration_acotada end) as Roaming_U2100

into _MOD_3G_acotado_acc
from _MOD_3G_duration_acotada_acc h
group by h.sessionid,h.TestId

--Sin acotar: para YTB y LAT (pero solo informacion de uso de 3G):
exec sp_lcc_dropifexists '_MOD_3G'
select 
	h.testid, h.sessionid, 
	----------------------------------------------------------------------
	--Informacion de tecnologia LTE a partir de la tabla de BW
	----------------------------------------------------------------------	
	-- Frecuencias U2100:
	1.0*sum(case when h.Freq in (10638,   10788,  10713,  10563) then h.duration end) as Duration_F1_U2100,
	1.0*sum(case when h.Freq in (10663,	10813,	10738,	10588) then h.duration end) as Duration_F2_U2100,
	1.0*sum(case when h.Freq in (10688,	10838,	10763,	10613) then h.duration end) as Duration_F3_U2100,	
	-- Frecuencias U900:
	1.0*sum(case when h.Freq in (3062, 3011, 2959) then h.duration end) as Duration_F1_U900,
	1.0*sum(case when h.Freq in (3087, 3022) then h.duration end) as Duration_F2_U900,
	-- Desglose tecnologia (referida a primera carrier):
	1.0*sum(case when h.technology like '%UMTS%' then h.duration end) as Duration_WCDMA,
	--Desglose 3G:
	1.0*sum(case when h.technology like 'UMTS 2100' then h.duration end) as Duration_UMTS_2100, 
	1.0*sum(case when h.technology like 'UMTS 900' then h.duration end) as Duration_UMTS_900,

	--Info de roaming por operador:
	1.0*sum(case when h.operator <> 'Vodafone' and h.ServingOperator='Vodafone' then h.duration end) as Roaming_UMTS_VF, 
	1.0*sum(case when h.operator <> 'Movistar' and h.ServingOperator='Movistar' then h.duration end) as Roaming_UMTS_MV, 
	1.0*sum(case when h.operator <> 'Orange' and h.ServingOperator='Orange' then h.duration end) as Roaming_UMTS_OR, 
	1.0*sum(case when h.operator <> 'Yoigo' and h.ServingOperator='Yoigo' then h.duration end) as Roaming_UMTS_YO, 
	--Desglose de roaming por banda:
	1.0*sum(case when h.operator <> h.ServingOperator and h.technology='UMTS 900' then h.duration end) as Roaming_U900,
	1.0*sum(case when h.operator <> h.ServingOperator and h.technology='UMTS 2100' then h.duration end) as Roaming_U2100

into _MOD_3G
from _MOD_3G_duration h
group by h.sessionid,h.TestId

-------------------------------------------------------------------------------------------------------------------------------------
-- Calculo por test de desgloses de tecnologia, uso de roaming, con siguiente criterio:
-- LTE si hay informacion en tabla de BW del test, se recoge de ahí, sino de Serving
-- Resto de tecnologias de Serving
-------------------------------------------------------------------------------------------------------------------------------------
--Info acotada al momento de la descarga, subida, navegacion y reproduccion:
exec sp_lcc_dropifexists '_PCT_TECH_Data_acotado'			
select 
	t.sessionid, t.testid, 
	-- Frecuencias U2100:
	case when m.testid is not null then m.Duration_F1_U2100 else td.Duration_F1_U2100 end 
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pct_F1_U2100,
	case when m.testid is not null then m.Duration_F2_U2100 else td.Duration_F2_U2100 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pct_F2_U2100,
	case when m.testid is not null then m.Duration_F3_U2100 else td.Duration_F3_U2100 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pct_F3_U2100,	
	-- Frecuencias U900:
	case when m.testid is not null then m.Duration_F1_U900 else td.Duration_F1_U900 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pct_F1_U900,
	case when m.testid is not null then m.Duration_F2_U900 else td.Duration_F2_U900 end 
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pct_F2_U900,
	-- Desglose tecnologia (referida a primera carrier):
	case when bw.testid is not null then bw.Duration_LTE else td.Duration_LTE end 
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE,
	case when m.testid is not null then m.Duration_WCDMA else td.Duration_WCDMA end 
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctWCDMA,
	td.Duration_GSM
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctGSM,
	--Desglose 4G:
	case when bw.testid is not null then bw.Duration_LTE_800 else td.Duration_LTE_800 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_800, 
	case when bw.testid is not null then bw.Duration_LTE_1800 else td.Duration_LTE_1800 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_1800,
	case when bw.testid is not null then bw.Duration_LTE_2100 else td.Duration_LTE_2100 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_2100,  
	case when bw.testid is not null then bw.Duration_LTE_2600 else td.Duration_LTE_2600 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_2600, 
	--Desglose 3G:
	case when m.testid is not null then m.Duration_UMTS_2100 else td.Duration_UMTS_2100 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctUMTS_2100, 
	case when m.testid is not null then m.Duration_UMTS_900 else td.Duration_UMTS_900 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctUMTS_900, 
	--Desglose 2G:
	td.Duration_GMS_DCS
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctGMS_DCS, 
	td.Duration_GSM_EGSM
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctGSM_EGSM,
	td.Duration_GSM_GSM
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctGSM_GSM,
	--Desglose 4G SCC1:
	case when bw.testid is not null then bw.Duration_LTE_800_SCC1 else td.Duration_LTE_800_SCC1 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_800_SCC1, 
	case when bw.testid is not null then bw.Duration_LTE_1800_SCC1 else td.Duration_LTE_1800_SCC1 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_1800_SCC1, 
	case when bw.testid is not null then bw.Duration_LTE_2100_SCC1 else td.Duration_LTE_2100_SCC1 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_2100_SCC1,
	case when bw.testid is not null then bw.Duration_LTE_2600_SCC1 else td.Duration_LTE_2600_SCC1 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_2600_SCC1,
	--Desglose 4G SCC2:
	case when bw.testid is not null then bw.Duration_LTE_800_SCC2 else td.Duration_LTE_800_SCC2 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_800_SCC2, 
	case when bw.testid is not null then bw.Duration_LTE_1800_SCC2 else td.Duration_LTE_1800_SCC2 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_1800_SCC2, 
	case when bw.testid is not null then bw.Duration_LTE_2100_SCC2 else td.Duration_LTE_2100_SCC2 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_2100_SCC2,
	case when bw.testid is not null then bw.Duration_LTE_2600_SCC2 else td.Duration_LTE_2600_SCC2 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_2600_SCC2,
	-- Info de SC / CA / 3C :
	case when bw.testid is not null then bw.Duration_LTE_SC else td.Duration_LTE_SC end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_SC,
	case when bw.testid is not null then bw.Duration_LTE_CA else td.Duration_LTE_CA end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_CA,
	case when bw.testid is not null then bw.Duration_LTE_3C else td.Duration_LTE_3C end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_3C,
	--Info de roaming por operador (como se saca de serving, se divide entre su total)
	case when m.testid is not null and bw.testid is not null then isnull(m.Roaming_UMTS_VF,0)+isnull(bw.Roaming_LTE_VF,0)+ isnull(td.Roaming_VF_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Roaming_UMTS_VF,0)+ isnull(td.Roaming_VF_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Roaming_LTE_VF,0)+ isnull(td.Roaming_VF_sin_LTE,0)
	else td.Roaming_VF end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_VF, 
	case when m.testid is not null and bw.testid is not null then isnull(m.Roaming_UMTS_MV,0)+isnull(bw.Roaming_LTE_MV,0)+ isnull(td.Roaming_MV_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Roaming_UMTS_MV,0)+ isnull(td.Roaming_MV_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Roaming_LTE_MV,0)+ isnull(td.Roaming_MV_sin_LTE,0)
	else td.Roaming_MV end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_MV, 
	case when m.testid is not null and bw.testid is not null then isnull(m.Roaming_UMTS_OR,0)+isnull(bw.Roaming_LTE_OR,0)+ isnull(td.Roaming_OR_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Roaming_UMTS_OR,0)+ isnull(td.Roaming_OR_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Roaming_LTE_OR,0)+ isnull(td.Roaming_OR_sin_LTE,0)
	else td.Roaming_OR end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_OR, 
	case when m.testid is not null and bw.testid is not null then isnull(m.Roaming_UMTS_YO,0)+isnull(bw.Roaming_LTE_YO,0)+ isnull(td.Roaming_YO_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Roaming_UMTS_YO,0)+ isnull(td.Roaming_YO_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Roaming_LTE_YO,0)+ isnull(td.Roaming_YO_sin_LTE,0)
	else td.Roaming_YO end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_YO, 
	--Info de roaming por banda (como se saca de serving, se divide entre su total)
	case when m.testid is not null then m.Roaming_U900 else td.Roaming_U900 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_U900,
	case when m.testid is not null then m.Roaming_U2100 else td.Roaming_U2100 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_U2100,
	case when bw.testid is not null then bw.Roaming_LTE800 else td.Roaming_LTE800 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_LTE800,
	case when bw.testid is not null then bw.Roaming_LTE1800 else td.Roaming_LTE1800 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_LTE1800,
	case when bw.testid is not null then bw.Roaming_LTE2100 else td.Roaming_LTE2100 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_LTE2100,
	case when bw.testid is not null then bw.Roaming_LTE2600 else td.Roaming_LTE2600 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_LTE2600,
	--Duracion de roaming por operador
	case when m.testid is not null and bw.testid is not null then isnull(m.Roaming_UMTS_VF,0)+isnull(bw.Roaming_LTE_VF,0)+ isnull(td.Roaming_VF_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Roaming_UMTS_VF,0)+ isnull(td.Roaming_VF_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Roaming_LTE_VF,0)+ isnull(td.Roaming_VF_sin_LTE,0)
	else td.Roaming_VF end as Duration_Roaming_VF,
	case when m.testid is not null and bw.testid is not null then isnull(m.Roaming_UMTS_MV,0)+isnull(bw.Roaming_LTE_MV,0)+ isnull(td.Roaming_MV_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Roaming_UMTS_MV,0)+ isnull(td.Roaming_MV_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Roaming_LTE_MV,0)+ isnull(td.Roaming_MV_sin_LTE,0)
	else td.Roaming_MV end as Duration_Roaming_MV, 
	case when m.testid is not null and bw.testid is not null then isnull(m.Roaming_UMTS_OR,0)+isnull(bw.Roaming_LTE_OR,0)+ isnull(td.Roaming_OR_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Roaming_UMTS_OR,0)+ isnull(td.Roaming_OR_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Roaming_LTE_OR,0)+ isnull(td.Roaming_OR_sin_LTE,0)
	else td.Roaming_OR end as Duration_Roaming_OR, 
	case when m.testid is not null and bw.testid is not null then isnull(m.Roaming_UMTS_YO,0)+isnull(bw.Roaming_LTE_YO,0)+ isnull(td.Roaming_YO_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Roaming_UMTS_YO,0)+ isnull(td.Roaming_YO_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Roaming_LTE_YO,0)+ isnull(td.Roaming_YO_sin_LTE,0)
	else td.Roaming_YO end as Duration_Roaming_YO,
	--Duracion de roaming por banda
	case when m.testid is not null then m.Roaming_U900 else td.Roaming_U900 end as Duration_Roaming_U900,
	case when m.testid is not null then m.Roaming_U2100 else td.Roaming_U2100 end as Duration_Roaming_U2100,
	case when bw.testid is not null then bw.Roaming_LTE800 else td.Roaming_LTE800 end as Duration_Roaming_LTE800,
	case when bw.testid is not null then bw.Roaming_LTE1800 else td.Roaming_LTE1800 end as Duration_Roaming_LTE1800,
	case when bw.testid is not null then bw.Roaming_LTE2100 else td.Roaming_LTE2100 end as Duration_Roaming_LTE2100,
	case when bw.testid is not null then bw.Roaming_LTE2600 else td.Roaming_LTE2600 end as Duration_Roaming_LTE2600

into _PCT_TECH_Data_acotado
from testinfo t
	 left join _Serving_Info_acotado td on td.sessionid=t.sessionid and td.testid=t.testid
	 left join _BW_acotado bw on bw.sessionid=t.sessionid and bw.testid=t.testid
	 left join _MOD_3G_acotado m on m.sessionid=t.sessionid and m.testid=t.testid
where td.testid is not null or bw.testid is not null or m.testid is not null

--Info acotada al momento de la descarga, subida, navegacion y reproduccion, teniendo en cuenta el acceso:
exec sp_lcc_dropifexists '_PCT_TECH_Data_acotado_acc'			
select 
	t.sessionid, t.testid, 
	-- Frecuencias U2100:
	case when m.testid is not null then m.Duration_F1_U2100 else td.Duration_F1_U2100 end 
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pct_F1_U2100,
	case when m.testid is not null then m.Duration_F2_U2100 else td.Duration_F2_U2100 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pct_F2_U2100,
	case when m.testid is not null then m.Duration_F3_U2100 else td.Duration_F3_U2100 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pct_F3_U2100,	
	-- Frecuencias U900:
	case when m.testid is not null then m.Duration_F1_U900 else td.Duration_F1_U900 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pct_F1_U900,
	case when m.testid is not null then m.Duration_F2_U900 else td.Duration_F2_U900 end 
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pct_F2_U900,
	-- Desglose tecnologia (referida a primera carrier):
	case when bw.testid is not null then bw.Duration_LTE else td.Duration_LTE end 
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE,
	case when m.testid is not null then m.Duration_WCDMA else td.Duration_WCDMA end 
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctWCDMA,
	td.Duration_GSM
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctGSM,
	--Desglose 4G:
	case when bw.testid is not null then bw.Duration_LTE_800 else td.Duration_LTE_800 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_800, 
	case when bw.testid is not null then bw.Duration_LTE_1800 else td.Duration_LTE_1800 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_1800,
	case when bw.testid is not null then bw.Duration_LTE_2100 else td.Duration_LTE_2100 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_2100,  
	case when bw.testid is not null then bw.Duration_LTE_2600 else td.Duration_LTE_2600 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_2600, 
	--Desglose 3G:
	case when m.testid is not null then m.Duration_UMTS_2100 else td.Duration_UMTS_2100 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctUMTS_2100, 
	case when m.testid is not null then m.Duration_UMTS_900 else td.Duration_UMTS_900 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctUMTS_900, 
	--Desglose 2G:
	td.Duration_GMS_DCS
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctGMS_DCS, 
	td.Duration_GSM_EGSM
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctGSM_EGSM,
	td.Duration_GSM_GSM
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctGSM_GSM,
	--Desglose 4G SCC1:
	case when bw.testid is not null then bw.Duration_LTE_800_SCC1 else td.Duration_LTE_800_SCC1 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_800_SCC1, 
	case when bw.testid is not null then bw.Duration_LTE_1800_SCC1 else td.Duration_LTE_1800_SCC1 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_1800_SCC1, 
	case when bw.testid is not null then bw.Duration_LTE_2100_SCC1 else td.Duration_LTE_2100_SCC1 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_2100_SCC1,
	case when bw.testid is not null then bw.Duration_LTE_2600_SCC1 else td.Duration_LTE_2600_SCC1 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_2600_SCC1,
	--Desglose 4G SCC2:
	case when bw.testid is not null then bw.Duration_LTE_800_SCC2 else td.Duration_LTE_800_SCC2 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_800_SCC2, 
	case when bw.testid is not null then bw.Duration_LTE_1800_SCC2 else td.Duration_LTE_1800_SCC2 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_1800_SCC2, 
	case when bw.testid is not null then bw.Duration_LTE_2100_SCC2 else td.Duration_LTE_2100_SCC2 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_2100_SCC2,
	case when bw.testid is not null then bw.Duration_LTE_2600_SCC2 else td.Duration_LTE_2600_SCC2 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_2600_SCC2,
	-- Info de SC / CA / 3C :
	case when bw.testid is not null then bw.Duration_LTE_SC else td.Duration_LTE_SC end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_SC,
	case when bw.testid is not null then bw.Duration_LTE_CA else td.Duration_LTE_CA end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_CA,
	case when bw.testid is not null then bw.Duration_LTE_3C else td.Duration_LTE_3C end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_3C,
	--Info de roaming por operador (como se saca de serving, se divide entre su total)
	case when m.testid is not null and bw.testid is not null then isnull(m.Roaming_UMTS_VF,0)+isnull(bw.Roaming_LTE_VF,0)+ isnull(td.Roaming_VF_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Roaming_UMTS_VF,0)+ isnull(td.Roaming_VF_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Roaming_LTE_VF,0)+ isnull(td.Roaming_VF_sin_LTE,0)
	else td.Roaming_VF end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_VF, 
	case when m.testid is not null and bw.testid is not null then isnull(m.Roaming_UMTS_MV,0)+isnull(bw.Roaming_LTE_MV,0)+ isnull(td.Roaming_MV_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Roaming_UMTS_MV,0)+ isnull(td.Roaming_MV_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Roaming_LTE_MV,0)+ isnull(td.Roaming_MV_sin_LTE,0)
	else td.Roaming_MV end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_MV, 
	case when m.testid is not null and bw.testid is not null then isnull(m.Roaming_UMTS_OR,0)+isnull(bw.Roaming_LTE_OR,0)+ isnull(td.Roaming_OR_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Roaming_UMTS_OR,0)+ isnull(td.Roaming_OR_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Roaming_LTE_OR,0)+ isnull(td.Roaming_OR_sin_LTE,0)
	else td.Roaming_OR end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_OR, 
	case when m.testid is not null and bw.testid is not null then isnull(m.Roaming_UMTS_YO,0)+isnull(bw.Roaming_LTE_YO,0)+ isnull(td.Roaming_YO_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Roaming_UMTS_YO,0)+ isnull(td.Roaming_YO_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Roaming_LTE_YO,0)+ isnull(td.Roaming_YO_sin_LTE,0)
	else td.Roaming_YO end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_YO, 
	--Info de roaming por banda (como se saca de serving, se divide entre su total)
	case when m.testid is not null then m.Roaming_U900 else td.Roaming_U900 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_U900,
	case when m.testid is not null then m.Roaming_U2100 else td.Roaming_U2100 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_U2100,
	case when bw.testid is not null then bw.Roaming_LTE800 else td.Roaming_LTE800 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_LTE800,
	case when bw.testid is not null then bw.Roaming_LTE1800 else td.Roaming_LTE1800 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_LTE1800,
	case when bw.testid is not null then bw.Roaming_LTE2100 else td.Roaming_LTE2100 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_LTE2100,
	case when bw.testid is not null then bw.Roaming_LTE2600 else td.Roaming_LTE2600 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_LTE2600,
	--Duracion de roaming por operador
	case when m.testid is not null and bw.testid is not null then isnull(m.Roaming_UMTS_VF,0)+isnull(bw.Roaming_LTE_VF,0)+ isnull(td.Roaming_VF_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Roaming_UMTS_VF,0)+ isnull(td.Roaming_VF_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Roaming_LTE_VF,0)+ isnull(td.Roaming_VF_sin_LTE,0)
	else td.Roaming_VF end as Duration_Roaming_VF,
	case when m.testid is not null and bw.testid is not null then isnull(m.Roaming_UMTS_MV,0)+isnull(bw.Roaming_LTE_MV,0)+ isnull(td.Roaming_MV_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Roaming_UMTS_MV,0)+ isnull(td.Roaming_MV_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Roaming_LTE_MV,0)+ isnull(td.Roaming_MV_sin_LTE,0)
	else td.Roaming_MV end as Duration_Roaming_MV, 
	case when m.testid is not null and bw.testid is not null then isnull(m.Roaming_UMTS_OR,0)+isnull(bw.Roaming_LTE_OR,0)+ isnull(td.Roaming_OR_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Roaming_UMTS_OR,0)+ isnull(td.Roaming_OR_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Roaming_LTE_OR,0)+ isnull(td.Roaming_OR_sin_LTE,0)
	else td.Roaming_OR end as Duration_Roaming_OR, 
	case when m.testid is not null and bw.testid is not null then isnull(m.Roaming_UMTS_YO,0)+isnull(bw.Roaming_LTE_YO,0)+ isnull(td.Roaming_YO_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Roaming_UMTS_YO,0)+ isnull(td.Roaming_YO_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Roaming_LTE_YO,0)+ isnull(td.Roaming_YO_sin_LTE,0)
	else td.Roaming_YO end as Duration_Roaming_YO,
	--Duracion de roaming por banda
	case when m.testid is not null then m.Roaming_U900 else td.Roaming_U900 end as Duration_Roaming_U900,
	case when m.testid is not null then m.Roaming_U2100 else td.Roaming_U2100 end as Duration_Roaming_U2100,
	case when bw.testid is not null then bw.Roaming_LTE800 else td.Roaming_LTE800 end as Duration_Roaming_LTE800,
	case when bw.testid is not null then bw.Roaming_LTE1800 else td.Roaming_LTE1800 end as Duration_Roaming_LTE1800,
	case when bw.testid is not null then bw.Roaming_LTE2100 else td.Roaming_LTE2100 end as Duration_Roaming_LTE2100,
	case when bw.testid is not null then bw.Roaming_LTE2600 else td.Roaming_LTE2600 end as Duration_Roaming_LTE2600

into _PCT_TECH_Data_acotado_acc
from testinfo t
	 left join _Serving_Info_acotado_acc td on td.sessionid=t.sessionid and td.testid=t.testid
	 left join _BW_acotado_acc bw on bw.sessionid=t.sessionid and bw.testid=t.testid
	 left join _MOD_3G_acotado_acc m on m.sessionid=t.sessionid and m.testid=t.testid
where td.testid is not null or bw.testid is not null

--Sin acotar: para YTB y LAT
exec sp_lcc_dropifexists '_PCT_TECH_Data'			
select 
	t.sessionid, t.testid, 
	-- Frecuencias U2100:
	case when m.testid is not null then m.Duration_F1_U2100 else td.Duration_F1_U2100 end 
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pct_F1_U2100,
	case when m.testid is not null then m.Duration_F2_U2100 else td.Duration_F2_U2100 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pct_F2_U2100,
	case when m.testid is not null then m.Duration_F3_U2100 else td.Duration_F3_U2100 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pct_F3_U2100,	
	-- Frecuencias U900:
	case when m.testid is not null then m.Duration_F1_U900 else td.Duration_F1_U900 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pct_F1_U900,
	case when m.testid is not null then m.Duration_F2_U900 else td.Duration_F2_U900 end 
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pct_F2_U900,
	-- Desglose tecnologia (referida a primera carrier):
	case when bw.testid is not null then bw.Duration_LTE else td.Duration_LTE end 
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE,
	case when m.testid is not null then m.Duration_WCDMA else td.Duration_WCDMA end 
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctWCDMA,
	td.Duration_GSM
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctGSM,
	--Desglose 4G:
	case when bw.testid is not null then bw.Duration_LTE_800 else td.Duration_LTE_800 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_800, 
	case when bw.testid is not null then bw.Duration_LTE_1800 else td.Duration_LTE_1800 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_1800,
	case when bw.testid is not null then bw.Duration_LTE_2100 else td.Duration_LTE_2100 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_2100,  
	case when bw.testid is not null then bw.Duration_LTE_2600 else td.Duration_LTE_2600 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_2600, 
	--Desglose 3G:
	case when m.testid is not null then m.Duration_UMTS_2100 else td.Duration_UMTS_2100 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctUMTS_2100, 
	case when m.testid is not null then m.Duration_UMTS_900 else td.Duration_UMTS_900 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctUMTS_900, 
	--Desglose 2G:
	td.Duration_GMS_DCS
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctGMS_DCS, 
	td.Duration_GSM_EGSM
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctGSM_EGSM,
	td.Duration_GSM_GSM
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctGSM_GSM,
	--Desglose 4G SCC1:
	case when bw.testid is not null then bw.Duration_LTE_800_SCC1 else td.Duration_LTE_800_SCC1 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_800_SCC1, 
	case when bw.testid is not null then bw.Duration_LTE_1800_SCC1 else td.Duration_LTE_1800_SCC1 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_1800_SCC1, 
	case when bw.testid is not null then bw.Duration_LTE_2100_SCC1 else td.Duration_LTE_2100_SCC1 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_2100_SCC1,
	case when bw.testid is not null then bw.Duration_LTE_2600_SCC1 else td.Duration_LTE_2600_SCC1 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_2600_SCC1,
	--Desglose 4G SCC2:
	case when bw.testid is not null then bw.Duration_LTE_800_SCC2 else td.Duration_LTE_800_SCC2 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_800_SCC2, 
	case when bw.testid is not null then bw.Duration_LTE_1800_SCC2 else td.Duration_LTE_1800_SCC2 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_1800_SCC2, 
	case when bw.testid is not null then bw.Duration_LTE_2100_SCC2 else td.Duration_LTE_2100_SCC2 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_2100_SCC2,
	case when bw.testid is not null then bw.Duration_LTE_2600_SCC2 else td.Duration_LTE_2600_SCC2 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_2600_SCC2,
	-- Info de SC / CA / 3C :
	case when bw.testid is not null then bw.Duration_LTE_SC else td.Duration_LTE_SC end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_SC,
	case when bw.testid is not null then bw.Duration_LTE_CA else td.Duration_LTE_CA end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_CA,
	case when bw.testid is not null then bw.Duration_LTE_3C else td.Duration_LTE_3C end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as pctLTE_3C,
	--Info de roaming por operador (como se saca de serving, se divide entre su total)
	case when m.testid is not null and bw.testid is not null then isnull(m.Roaming_UMTS_VF,0)+isnull(bw.Roaming_LTE_VF,0)+ isnull(td.Roaming_VF_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Roaming_UMTS_VF,0)+ isnull(td.Roaming_VF_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Roaming_LTE_VF,0)+ isnull(td.Roaming_VF_sin_LTE,0)
	else td.Roaming_VF end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_VF, 
	case when m.testid is not null and bw.testid is not null then isnull(m.Roaming_UMTS_MV,0)+isnull(bw.Roaming_LTE_MV,0)+ isnull(td.Roaming_MV_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Roaming_UMTS_MV,0)+ isnull(td.Roaming_MV_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Roaming_LTE_MV,0)+ isnull(td.Roaming_MV_sin_LTE,0)
	else td.Roaming_MV end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_MV, 
	case when m.testid is not null and bw.testid is not null then isnull(m.Roaming_UMTS_OR,0)+isnull(bw.Roaming_LTE_OR,0)+ isnull(td.Roaming_OR_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Roaming_UMTS_OR,0)+ isnull(td.Roaming_OR_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Roaming_LTE_OR,0)+ isnull(td.Roaming_OR_sin_LTE,0)
	else td.Roaming_OR end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_OR, 
	case when m.testid is not null and bw.testid is not null then isnull(m.Roaming_UMTS_YO,0)+isnull(bw.Roaming_LTE_YO,0)+ isnull(td.Roaming_YO_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Roaming_UMTS_YO,0)+ isnull(td.Roaming_YO_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Roaming_LTE_YO,0)+ isnull(td.Roaming_YO_sin_LTE,0)
	else td.Roaming_YO end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_YO, 
	--Info de roaming por banda (como se saca de serving, se divide entre su total)
	case when m.testid is not null then m.Roaming_U900 else td.Roaming_U900 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_U900,
	case when m.testid is not null then m.Roaming_U2100 else td.Roaming_U2100 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_U2100,
	case when bw.testid is not null then bw.Roaming_LTE800 else td.Roaming_LTE800 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_LTE800,
	case when bw.testid is not null then bw.Roaming_LTE1800 else td.Roaming_LTE1800 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_LTE1800,
	case when bw.testid is not null then bw.Roaming_LTE2100 else td.Roaming_LTE2100 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_LTE2100,
	case when bw.testid is not null then bw.Roaming_LTE2600 else td.Roaming_LTE2600 end
		/ NULLIF(case when m.testid is not null and bw.testid is not null then isnull(m.Duration_WCDMA,0)+isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Duration_WCDMA,0)+ isnull(td.Duration_total_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Duration_LTE,0)+ isnull(td.Duration_total_sin_LTE,0)
	else td.Duration_total end,0) as Roaming_LTE2600,
	--Duracion de roaming por operador
	case when m.testid is not null and bw.testid is not null then isnull(m.Roaming_UMTS_VF,0)+isnull(bw.Roaming_LTE_VF,0)+ isnull(td.Roaming_VF_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Roaming_UMTS_VF,0)+ isnull(td.Roaming_VF_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Roaming_LTE_VF,0)+ isnull(td.Roaming_VF_sin_LTE,0)
	else td.Roaming_VF end as Duration_Roaming_VF,
	case when m.testid is not null and bw.testid is not null then isnull(m.Roaming_UMTS_MV,0)+isnull(bw.Roaming_LTE_MV,0)+ isnull(td.Roaming_MV_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Roaming_UMTS_MV,0)+ isnull(td.Roaming_MV_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Roaming_LTE_MV,0)+ isnull(td.Roaming_MV_sin_LTE,0)
	else td.Roaming_MV end as Duration_Roaming_MV, 
	case when m.testid is not null and bw.testid is not null then isnull(m.Roaming_UMTS_OR,0)+isnull(bw.Roaming_LTE_OR,0)+ isnull(td.Roaming_OR_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Roaming_UMTS_OR,0)+ isnull(td.Roaming_OR_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Roaming_LTE_OR,0)+ isnull(td.Roaming_OR_sin_LTE,0)
	else td.Roaming_OR end as Duration_Roaming_OR, 
	case when m.testid is not null and bw.testid is not null then isnull(m.Roaming_UMTS_YO,0)+isnull(bw.Roaming_LTE_YO,0)+ isnull(td.Roaming_YO_sin_UMTS_LTE,0)  
			when m.testid is not null and bw.testid is null then isnull(m.Roaming_UMTS_YO,0)+ isnull(td.Roaming_YO_sin_UMTS,0)
			when m.testid is null and bw.testid is not null then isnull(bw.Roaming_LTE_YO,0)+ isnull(td.Roaming_YO_sin_LTE,0)
	else td.Roaming_YO end as Duration_Roaming_YO,
	--Duracion de roaming por banda
	case when m.testid is not null then m.Roaming_U900 else td.Roaming_U900 end as Duration_Roaming_U900,
	case when m.testid is not null then m.Roaming_U2100 else td.Roaming_U2100 end as Duration_Roaming_U2100,
	case when bw.testid is not null then bw.Roaming_LTE800 else td.Roaming_LTE800 end as Duration_Roaming_LTE800,
	case when bw.testid is not null then bw.Roaming_LTE1800 else td.Roaming_LTE1800 end as Duration_Roaming_LTE1800,
	case when bw.testid is not null then bw.Roaming_LTE2100 else td.Roaming_LTE2100 end as Duration_Roaming_LTE2100,
	case when bw.testid is not null then bw.Roaming_LTE2600 else td.Roaming_LTE2600 end as Duration_Roaming_LTE2600

into _PCT_TECH_Data
from testinfo t
	 left join _Serving_Info td on td.sessionid=t.sessionid and td.testid=t.testid
	 left join _BW bw on bw.sessionid=t.sessionid and bw.testid=t.testid
	 left join _MOD_3G m on m.sessionid=t.sessionid and m.testid=t.testid
where td.testid is not null or bw.testid is not null


-------------------------------------------------------------------------------------------------------------------------------------
-- Calculo por test de KPIs de 4G a partir de la tabla lcc_Physical_Info_Table
-- la información ya acotada al momento de la descarga, subida, navegacion y reproduccion
-------------------------------------------------------------------------------------------------------------------------------------

-- RBs DL desglosados por carrier:
exec sp_lcc_dropifexists '_RBs_carrier_DL'
select 
	l.direction, l.sessionid, l.testid,
	
	-- PCC:
	((1.0*sum(l.num_RBs_num_PCC)/nullif(sum(num_RBs_den_PCC),0)))/2 as num_RBs_PCC,
	--Min entre el max y 100 (máximo teórico de RBS): 0.5 * ((@val1 + @val2) - ABS(@val1 - @val2)) 
	0.5 * ((CEILING(max(ROUND((1.0*l.num_RBs_num_PCC/nullif(num_RBs_den_PCC,0))/2,0))) + 100) - ABS(CEILING(max(ROUND((1.0*l.num_RBs_num_PCC/nullif(num_RBs_den_PCC,0))/2,0))) - 100)) as maxRBs_PCC,		-- max de los numRB
	FLOOR(MIN(ROUND((1.0*l.num_RBs_num_PCC/nullif(num_RBs_den_PCC,0))/2,0))) as minRBs_PCC,			-- min de los numRBs
	ROUND((1.0*sum(l.num_RBs_num_PCC)/nullif(sum(num_RBs_den_PCC),0))/2,0) as Rbs_round_PCC,
	ROUND(1.0*sum(l.num_RBs_num_PCC)/nullif(sum(num_RBs_den_dedicated_PCC),0),0) as Rbs_dedicated_round_PCC,	
	
	-- SCC1:
	((1.0*sum(l.num_RBs_num_SCC1)/nullif(sum(num_RBs_den_SCC1),0)))/2 as num_RBs_SCC1,
	--Min entre el max y 100 (máximo teórico de RBS): 0.5 * ((@val1 + @val2) - ABS(@val1 - @val2)) 
	0.5 * ((CEILING(max(ROUND((1.0*l.num_RBs_num_SCC1/nullif(num_RBs_den_SCC1,0))/2,0))) + 100) - ABS(CEILING(max(ROUND((1.0*l.num_RBs_num_SCC1/nullif(num_RBs_den_SCC1,0))/2,0))) - 100))  as maxRBs_SCC1,		-- max de los numRB
	FLOOR(MIN(ROUND((1.0*l.num_RBs_num_SCC1/nullif(num_RBs_den_SCC1,0))/2,0))) as minRBs_SCC1,			-- min de los numRBs
	ROUND((1.0*sum(l.num_RBs_num_SCC1)/nullif(sum(num_RBs_den_SCC1),0))/2,0) as Rbs_round_SCC1,
	ROUND(1.0*sum(l.num_RBs_num_SCC1)/nullif(sum(num_RBs_den_dedicated_SCC1),0),0) as Rbs_dedicated_round_SCC1,

	-- SCC2:
	((1.0*sum(l.num_RBs_num_SCC2)/nullif(sum(num_RBs_den_SCC2),0)))/2 as num_RBs_SCC2,
	--Min entre el max y 100 (máximo teórico de RBS): 0.5 * ((@val1 + @val2) - ABS(@val1 - @val2)) 
	0.5 * ((CEILING(max(ROUND((1.0*l.num_RBs_num_SCC2/nullif(num_RBs_den_SCC2,0))/2,0))) + 100) - ABS(CEILING(max(ROUND((1.0*l.num_RBs_num_SCC2/nullif(num_RBs_den_SCC2,0))/2,0))) - 100))  as maxRBs_SCC2,		-- max de los numRB
	FLOOR(MIN(ROUND((1.0*l.num_RBs_num_SCC2/nullif(num_RBs_den_SCC2,0))/2,0))) as minRBs_SCC2,			-- min de los numRBs
	ROUND((1.0*sum(l.num_RBs_num_SCC2)/nullif(sum(num_RBs_den_SCC2),0))/2,0) as Rbs_round_SCC2,
	ROUND(1.0*sum(l.num_RBs_num_SCC2)/nullif(sum(num_RBs_den_dedicated_SCC2),0),0) as Rbs_dedicated_round_SCC2,
	
	-- @DGP: codigo para CA
	sum(case when l.num_RBs_num_SCC1 is null then 1 end) as Blocks_NoCA,
	isnull(sum(case when l.num_RBs_num_SCC1 is not null then 1 end),0) as Blocks_CA,

	--Valdria para test puros de 4G, lo usamos para ponderar en el test los RBs de cada carrier
	1.0*isnull(sum(case when l.number_Carrier=1 then l.duration end),0)/nullif(sum(l.duration),0) as [% SC],
	1.0*isnull(sum(case when l.number_Carrier=2 then l.duration end),0)/nullif(sum(l.duration),0) as [% CA],
	1.0*isnull(sum(case when l.number_Carrier=3 then l.duration end),0)/nullif(sum(l.duration),0) as [% 3C],
	--Por cada tramo de tiempo contamos el numero de carrier y por cada carrier
	100*SUM(number_Carrier)/nullif(sum(case when l.duration is not null then 1 else 0 end),0) as 'maxRbs'
into _RBs_carrier_DL	
from lcc_Physical_Info_Table l
where l.[Info about]='4G' 	-- Info LTE - PDSCH
	and l.direction='Downlink'
	and l.testId > @maxTestid
group by  l.direction, l.sessionid, l.testid
order by l.sessionid, l.testid

----------------
-- RBs / Shared Channel Use DL:
exec sp_lcc_dropifexists '_RBs_DL'			
select 
	l.direction, l.sessionid, l.testid,
	-- ALL:
	isnull(num_RBs_PCC,0)+isnull(num_RBs_SCC1,0)+isnull(num_RBs_SCC2,0) as num_RBs,
	isnull(maxRBs_PCC,0)+isnull(maxRBs_SCC1,0)+isnull(maxRBs_SCC2,0) as maxRBs,		-- max de los numRB
	isnull(minRBs_PCC,0)+isnull(minRBs_SCC1,0)+isnull(minRBs_SCC2,0) as minRBs,		-- min de los numRBs
	
	isnull(Rbs_round_PCC,0)+isnull(Rbs_round_SCC1,0)+isnull(Rbs_round_SCC2,0) as Rbs_round,
	isnull(Rbs_dedicated_round_PCC,0)+isnull(Rbs_dedicated_round_SCC1,0)+isnull(Rbs_dedicated_round_SCC2,0) as Rbs_dedicated_round,

	--Ponderado por numero de carrier:
	--PCC --> SC + CA + 3C, SCc1 --> SC + CA + 3C, SCC2 --> 3C
	(isnull(num_RBs_PCC,0)*(isnull([% SC],0)+isnull([% CA],0)+isnull([% 3C],0)))
		+(isnull(num_RBs_SCC1,0)*(isnull([% CA],0)+isnull([% 3C],0)))
		+(isnull(num_RBs_SCC2,0)*isnull([% 3C],0)) as num_RBs_pond,
	(isnull(Rbs_round_PCC,0)*(isnull([% SC],0)+isnull([% CA],0)+isnull([% 3C],0)))
		+(isnull(Rbs_round_SCC1,0)*(isnull([% CA],0)+isnull([% 3C],0)))
		+(isnull(Rbs_round_SCC2,0)*isnull([% 3C],0)) as Rbs_round_pond,
	(isnull(Rbs_dedicated_round_PCC,0)*(isnull([% SC],0)+isnull([% CA],0)+isnull([% 3C],0)))
		+(isnull(Rbs_dedicated_round_SCC1,0)*(isnull([% CA],0)+isnull([% 3C],0)))
		+(isnull(Rbs_dedicated_round_SCC2,0)*isnull([% 3C],0)) as Rbs_dedicated_round_pond,

	--SharedChannelUse: Rbs ponderados por numero de carrier entre los Rbs maximos
	(1.0*(isnull(Rbs_round_PCC,0)*(isnull([% SC],0)+isnull([% CA],0)+isnull([% 3C],0)))
		+(isnull(Rbs_round_SCC1,0)*(isnull([% CA],0)+isnull([% 3C],0)))
		+(isnull(Rbs_round_SCC2,0)*isnull([% 3C],0)))
		/NULLIF(maxRbs,0) as 'Percent_LTESharedChannelUse'
into _RBs_DL	
from _RBs_carrier_DL l
order by l.sessionid, l.testid

----------------
--  RBs / Shared Channel Use UL:
exec sp_lcc_dropifexists '_RBs_UL'			
select 
	l.direction, l.sessionid, l.testid,
	
	((1.0*sum(l.num_RBs_num)/nullif(sum(num_RBs_den),0)))/2 as num_RBs,	
	--Min entre el max y 100 (máximo teórico de RBS): 0.5 * ((@val1 + @val2) - ABS(@val1 - @val2)) 
	0.5 * ((CEILING(max(ROUND((1.0*l.num_RBs_num/nullif(num_RBs_den,0))/2,0))) + 100) - ABS(CEILING(max(ROUND((1.0*l.num_RBs_num/nullif(num_RBs_den,0))/2,0))) - 100)) as maxRBs,		-- max de los numRB
	FLOOR(MIN(ROUND((1.0*l.num_RBs_num/nullif(num_RBs_den,0))/2,0))) as minRBs,			-- min de los numRBs
	ROUND((1.0*sum(l.num_RBs_num)/nullif(sum(num_RBs_den),0))/2,0) as Rbs_round,
	ROUND(1.0*sum(l.num_RBs_num)/nullif(sum(num_RBs_den_dedicated),0),0) as Rbs_dedicated_round,
	--SharedChannelUse: Rbs entre los Rbs maximos
	(1.0*SUM(l.LTESharedChannelUse_num) / NULLIF(SUM(l.LTESharedChannelUse_den),0))/(2*100) as 'Percent_LTESharedChannelUse'
into _RBs_UL	
from lcc_Physical_Info_Table l
where l.[Info about]='4G' 	-- Info LTE - PUSCH
	and direction='Uplink'
	and l.testId > @maxTestid
group by  l.direction, l.sessionid, l.testid
order by l.sessionid, l.testid

----------------
-- Modulaciones 4G 
exec sp_lcc_dropifexists '_MOD_4G'			
select 
	l.direction, l.sessionid, l.testid,
	1.0*SUM(l.use_BPSK_num) / NULLIF(SUM(cast(l.mod_use_denom as float)),0) as '% BPSK',
	1.0*SUM(l.use_QPSK_num) / NULLIF(SUM(cast(l.mod_use_denom as float)),0) as '% QPSK',
	1.0*SUM(l.use_16QAM_num) / NULLIF(SUM(cast(l.mod_use_denom as float)),0) as '% 16QAM',
	1.0*SUM(l.use_64QAM_num) / NULLIF(SUM(cast(l.mod_use_denom as float)),0) as '% 64QAM',
	1.0*SUM(l.use_256QAM_num) / NULLIF(SUM(cast(l.mod_use_denom as float)),0) as '% 256QAM',
	-- PCC
	--1.0*SUM(l.use_BPSK_num_PCC) / NULLIF(SUM(cast(l.mod_use_denom_PCC as float)),0) as '% BPSK PCC',
	1.0*SUM(l.use_QPSK_num_PCC) / NULLIF(SUM(cast(l.mod_use_denom_PCC as float)),0) as '% QPSK PCC',
	1.0*SUM(l.use_16QAM_num_PCC) / NULLIF(SUM(cast(l.mod_use_denom_PCC as float)),0) as '% 16QAM PCC',
	1.0*SUM(l.use_64QAM_num_PCC) / NULLIF(SUM(cast(l.mod_use_denom_PCC as float)),0) as '% 64QAM PCC',
	1.0*SUM(l.use_256QAM_num_PCC) / NULLIF(SUM(cast(l.mod_use_denom_PCC as float)),0) as '% 256QAM PCC',
	-- SCC1
	--1.0*SUM(l.use_BPSK_num_SCC1) / NULLIF(SUM(cast(l.mod_use_denom_SCC1 as float)),0) as '% BPSK SCC1',
	1.0*SUM(l.use_QPSK_num_SCC1) / NULLIF(SUM(cast(l.mod_use_denom_SCC1 as float)),0) as '% QPSK SCC1',
	1.0*SUM(l.use_16QAM_num_SCC1) / NULLIF(SUM(cast(l.mod_use_denom_SCC1 as float)),0) as '% 16QAM SCC1',
	1.0*SUM(l.use_64QAM_num_SCC1) / NULLIF(SUM(cast(l.mod_use_denom_SCC1 as float)),0) as '% 64QAM SCC1',
	1.0*SUM(l.use_256QAM_num_SCC1) / NULLIF(SUM(cast(l.mod_use_denom_SCC1 as float)),0) as '% 256QAM SCC1',
	-- SCC2
	--1.0*SUM(l.use_BPSK_num_SCC1) / NULLIF(SUM(cast(l.mod_use_denom_SCC2 as float)),0) as '% BPSK SCC1',
	1.0*SUM(l.use_QPSK_num_SCC2) / NULLIF(SUM(cast(l.mod_use_denom_SCC2 as float)),0) as '% QPSK SCC2',
	1.0*SUM(l.use_16QAM_num_SCC2) / NULLIF(SUM(cast(l.mod_use_denom_SCC2 as float)),0) as '% 16QAM SCC2',
	1.0*SUM(l.use_64QAM_num_SCC2) / NULLIF(SUM(cast(l.mod_use_denom_SCC2 as float)),0) as '% 64QAM SCC2'	,
	1.0*SUM(l.use_256QAM_num_SCC2) / NULLIF(SUM(cast(l.mod_use_denom_SCC2 as float)),0) as '% 256QAM SCC2'
into _MOD_4G
from lcc_Physical_Info_Table l 
where l.[Info about]='4G'	-- Info LTE - PDSCH / PUSCH
	and l.testId > @maxTestid
group by l.direction, l.sessionid, l.testid

----------------
--Informacion de SC / CA / 3C a partir de la tabla lcc physical
exec sp_lcc_dropifexists '_Carrier'
select
	l.sessionid, l.testid,
	1.0*isnull(sum(case when l.number_Carrier=1 then l.duration end),0)/nullif(sum(cast(l.duration as float)),0) as [% SC],
	1.0*isnull(sum(case when l.number_Carrier=2 then l.duration end),0)/nullif(sum(cast(l.duration as float)),0) as [% CA],
	1.0*isnull(sum(case when l.number_Carrier=3 then l.duration end),0)/nullif(sum(cast(l.duration as float)),0) as [% 3C]

into _Carrier	
from lcc_Physical_Info_Table l
where l.direction='Downlink'
	and l.testId > @maxTestid
group by  l.direction, l.sessionid, l.testid
order by l.sessionid, l.testid

----------------
-- Transmission Mode 4G DL
-- ERC - 20170112 - Cambio forma de calculo, por duraciones	
exec sp_lcc_dropifexists '_TM_DL'			
select 
	direction, sessionid, testid, 
	1.0*SUM(case when TransmissionMode=0 then duration else 0 end)/nullif(SUM(duration),0) as 'percTM0',
	1.0*SUM(case when TransmissionMode=1 then duration else 0 end)/nullif(SUM(duration),0) as 'percTM1',
	1.0*SUM(case when TransmissionMode=2 then duration else 0 end)/nullif(SUM(duration),0) as 'percTM2',
	1.0*SUM(case when TransmissionMode=3 then duration else 0 end)/nullif(SUM(duration),0) as 'percTM3',
	1.0*SUM(case when TransmissionMode=4 then duration else 0 end)/nullif(SUM(duration),0) as 'percTM4',
	1.0*SUM(case when TransmissionMode=5 then duration else 0 end)/nullif(SUM(duration),0) as 'percTM5', 
	1.0*SUM(case when TransmissionMode=6 then duration else 0 end)/nullif(SUM(duration),0) as 'percTM6', 
	1.0*SUM(case when TransmissionMode=7 then duration else 0 end)/nullif(SUM(duration),0) as 'percTM7',
	1.0*SUM(case when TransmissionMode is NULL then duration else 0 end)/nullif(SUM(duration),0) as 'percTMunknown',

	-- PCC:
	1.0*SUM(case when TransmissionMode_PCC=0 then duration else 0 end)/nullif(SUM(duration),0) as 'percTM0 PCC',
	1.0*SUM(case when TransmissionMode_PCC=1 then duration else 0 end)/nullif(SUM(duration),0) as 'percTM1 PCC',
	1.0*SUM(case when TransmissionMode_PCC=2 then duration else 0 end)/nullif(SUM(duration),0) as 'percTM2 PCC',
	1.0*SUM(case when TransmissionMode_PCC=3 then duration else 0 end)/nullif(SUM(duration),0) as 'percTM3 PCC',
	1.0*SUM(case when TransmissionMode_PCC=4 then duration else 0 end)/nullif(SUM(duration),0) as 'percTM4 PCC',
	1.0*SUM(case when TransmissionMode_PCC=5 then duration else 0 end)/nullif(SUM(duration),0) as 'percTM5 PCC', 
	1.0*SUM(case when TransmissionMode_PCC=6 then duration else 0 end)/nullif(SUM(duration),0) as 'percTM6 PCC', 
	1.0*SUM(case when TransmissionMode_PCC=7 then duration else 0 end)/nullif(SUM(duration),0) as 'percTM7 PCC',
	1.0*SUM(case when TransmissionMode_PCC is NULL then duration else 0 end)/nullif(SUM(duration),0) as 'percTMunknown PCC',
	
	-- SCC1:
	1.0*SUM(case when number_Carrier=2 then (case when TransmissionMode_SCC1=0 then duration else 0 end) end)/nullif(SUM(duration),0) as 'percTM0 SCC1',
	1.0*SUM(case when number_Carrier=2 then (case when TransmissionMode_SCC1=1 then duration else 0 end) end)/nullif(SUM(duration),0) as 'percTM1 SCC1',
	1.0*SUM(case when number_Carrier=2 then (case when TransmissionMode_SCC1=2 then duration else 0 end) end)/nullif(SUM(duration),0) as 'percTM2 SCC1',
	1.0*SUM(case when number_Carrier=2 then (case when TransmissionMode_SCC1=3 then duration else 0 end) end)/nullif(SUM(duration),0) as 'percTM3 SCC1',
	1.0*SUM(case when number_Carrier=2 then (case when TransmissionMode_SCC1=4 then duration else 0 end) end)/nullif(SUM(duration),0) as 'percTM4 SCC1',
	1.0*SUM(case when number_Carrier=2 then (case when TransmissionMode_SCC1=5 then duration else 0 end) end)/nullif(SUM(duration),0) as 'percTM5 SCC1', 
	1.0*SUM(case when number_Carrier=2 then (case when TransmissionMode_SCC1=6 then duration else 0 end) end)/nullif(SUM(duration),0) as 'percTM6 SCC1', 
	1.0*SUM(case when number_Carrier=2 then (case when TransmissionMode_SCC1=7 then duration else 0 end) end)/nullif(SUM(duration),0) as 'percTM7 SCC1',
	1.0*SUM(case when number_Carrier=2 then (case when TransmissionMode_SCC1 is NULL then duration else 0 end) end)/nullif(SUM(duration),0) as 'percTMunknown SCC1',

	-- SCC2:
	1.0*SUM(case when number_Carrier=3 then (case when TransmissionMode_SCC2=0 then duration else 0 end) end)/nullif(SUM(duration),0) as 'percTM0 SCC2',
	1.0*SUM(case when number_Carrier=3 then (case when TransmissionMode_SCC2=1 then duration else 0 end) end)/nullif(SUM(duration),0) as 'percTM1 SCC2',
	1.0*SUM(case when number_Carrier=3 then (case when TransmissionMode_SCC2=2 then duration else 0 end) end)/nullif(SUM(duration),0) as 'percTM2 SCC2',
	1.0*SUM(case when number_Carrier=3 then (case when TransmissionMode_SCC2=3 then duration else 0 end) end)/nullif(SUM(duration),0) as 'percTM3 SCC2',
	1.0*SUM(case when number_Carrier=3 then (case when TransmissionMode_SCC2=4 then duration else 0 end) end)/nullif(SUM(duration),0) as 'percTM4 SCC2',
	1.0*SUM(case when number_Carrier=3 then (case when TransmissionMode_SCC2=5 then duration else 0 end) end)/nullif(SUM(duration),0) as 'percTM5 SCC2', 
	1.0*SUM(case when number_Carrier=3 then (case when TransmissionMode_SCC2=6 then duration else 0 end) end)/nullif(SUM(duration),0) as 'percTM6 SCC2', 
	1.0*SUM(case when number_Carrier=3 then (case when TransmissionMode_SCC2=7 then duration else 0 end) end)/nullif(SUM(duration),0) as 'percTM7 SCC2',
	1.0*SUM(case when number_Carrier=3 then (case when TransmissionMode_SCC2 is NULL then duration else 0 end) end)/nullif(SUM(duration),0) as 'percTMunknown SCC2'
				
into _TM_DL     
from lcc_Physical_Info_Table l 
where l.[Info about]='4G'								-- Info LTE - PDSCH / PUSCH
		and l.testId > @maxTestid
group by direction, sessionid, testid


-------------------------------------------------------------------------------------------------------------------------------------
-- 4G: Calculo de las duraciones de CQI / TM / RI desde la tabla de sistema
-------------------------------------------------------------------------------------------------------------------------------------
-- ERC - 20170112:	Se modifica el cálculo del RI, para hacerlo por duraciones y no por average		(c)
--					Se modifica el cálculo del TM_UL, para hacerlo por duraciones y no por average	(d)			
--						-> Para ello se calcula la duración de cada entrada en la tabla _PUCCHCQI_4G		(a y b)
--					%MIMO -> RI = 2 con
--								TM2 Transmit Diversity - diversity configuration) <> MIMO	- (TD Rank 1) - ¿? no lo veo claro
--								TM3 MIMO (RI=2) without UE feedback - open loop				- (OL SM)
--								TM4 MIMO (RI=2) with UE feedback - closed loop				- (CL SM)
--CAC XX/11/2017: modificado el cálculo de duraciones


--Info en Carriers. 
exec sp_lcc_dropifexists '_SCC_CQI'			
CREATE TABLE _SCC_CQI(
	[sessionid] [bigint] NULL,
	[TestId] [bigint] NULL,
	[msgtime]  [datetime2](3) NULL,
	[LTEPUCCHCQIId] [bigint] NULL,
	[CarrierIndex_Orig] [smallint] NULL,
	[CarrierIndex] [smallint] NULL,
	[TxMode] [tinyint] NULL,
	[RankIndex] [int] NULL,
	[PMI] [tinyint] NULL,
	[NumSamplesCQI0] [int] NULL,
	[NumSamplesCQI1] [int] NULL,
	[CQI0] [real] NULL,
	[CQI1] [real] NULL
)
	
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LTEPUCCHCQICarrier]') AND type in (N'U'))
begin
	--Ordenamos por carrierindex con información (no siempre se rellena en orden):
	--Se debe particionar por test,instante de tiempo y el Id de la información
	insert 	into _SCC_CQI
	select 
		sessionid, TestId,msgtime,	
		c.LTEPUCCHCQIId,
		c.CarrierIndex  as CarrierIndex_Orig,
		ROW_NUMBER() over (partition by l.testid,l.msgtime,l.LTEPUCCHCQIId order by c.CarrierIndex asc) as CarrierIndex,	-- SCC:1...7
		c.TxMode,
		c.RankIndex + 1 as RankIndex,		-- viene de la vista asi - - valores 0 o 1 - fran tiene otra cosa en las vistas - revisar
		c.PMI,
		c.NumSamplesCQI0,
		c.NumSamplesCQI1,
		c.CQI0,
		c.CQI1
	from LTEPUCCHCQI l
		JOIN LTEPUCCHCQICarrier c ON c.LTEPUCCHCQIId = l.LTEPUCCHCQIId
	where l.testId > @maxTestid
end

--Tabla con info de CQI / TM / RI en columnas:
exec sp_lcc_dropifexists '_PUCCHCQI_4G'			
select 
	pcc.LTEPUCCHCQIId as pcc_LTEPUCCHCQIId,
	--Contamos el numero de carriers por instante de tiempo
	1+case when s1.LTEPUCCHCQIId is not null then 1 else 0 end+case when s2.LTEPUCCHCQIId is not null then 1 else 0 end as number_Carrier,

	s1.LTEPUCCHCQIId as s1_LTEPUCCHCQIId, s2.LTEPUCCHCQIId as s2_LTEPUCCHCQIId, s3.LTEPUCCHCQIId as s3_LTEPUCCHCQIId, 
	s4.LTEPUCCHCQIId as s4_LTEPUCCHCQIId, s5.LTEPUCCHCQIId as s5_LTEPUCCHCQIId, s6.LTEPUCCHCQIId as s6_LTEPUCCHCQIId, 
	s7.LTEPUCCHCQIId as s7_LTEPUCCHCQIId, 

	pcc.msgtime,pcc.sessionid, pcc.TestId,	tech.band,

	-- ALL: Se hacen directamente los calculos de ambas antenas
	(pcc.numsamplescqi0*isnull(pcc.cqi0,0)+pcc.numsamplescqi1*isnull(pcc.cqi1,0))/(pcc.numsamplescqi0+pcc.numsamplescqi1) as CQI_PCC,
	(s1.numsamplescqi0*isnull(s1.cqi0,0)+s1.numsamplescqi1*isnull(s1.cqi1,0))/(s1.numsamplescqi0+s1.numsamplescqi1) as CQI_SCC1,
	(s2.numsamplescqi0*isnull(s2.cqi0,0)+s2.numsamplescqi1*isnull(s2.cqi1,0))/(s2.numsamplescqi0+s2.numsamplescqi1) as CQI_SCC2,
	-- CQI
	(pcc.numsamplescqi0*isnull(pcc.cqi0,0)+pcc.numsamplescqi1*isnull(pcc.cqi1,0)
		+isnull(s1.numsamplescqi0,0)*isnull(s1.cqi0,0)+isnull(s1.numsamplescqi1,0)*isnull(s1.cqi1,0)
		+isnull(s2.numsamplescqi0,0)*isnull(s2.cqi0,0)+isnull(s2.numsamplescqi1,0)*isnull(s2.cqi1,0)
	)/(isnull(pcc.numsamplescqi0,0)+isnull(pcc.numsamplescqi1,0)+isnull(s1.numsamplescqi0,0)+isnull(s1.numsamplescqi1,0)+isnull(s2.numsamplescqi0,0)+isnull(s2.numsamplescqi1,0)) as CQI,
	-- Informacion PCC: 
	pcc.TxMode as TxMode_PCC,		
	pcc.RankIndex + 1 as RankIndex_PCC,				-- viene de la vista asi - valores 0 o 1
	pcc.PMI as PMI_PCC,	
	pcc.NumSamplesCQI0 as NumSamplesCQI0_PCC,		pcc.NumSamplesCQI1 as NumSamplesCQI1_PCC,
	pcc.CQI0 as CQI0_PCC,							pcc.CQI1 as CQI1_PCC,

	-- SCCx:
	-- ERC - 20170112: Se quitan los +1 que se estaban metiendo aqui, cuando ya se estaban haciendo antes (arriba)
	s1.TxMode as TxMode_SCC1, s1.RankIndex as RankIndex_SCC1, s1.PMI as PMI_SCC1, s1.NumSamplesCQI0 as NumSamplesCQI0_SCC1, s1.NumSamplesCQI1 as NumSamplesCQI1_SCC1, s1.CQI0 as CQI0_SCC1, s1.CQI1 as CQI1_SCC1,
	s2.TxMode as TxMode_SCC2, s2.RankIndex as RankIndex_SCC2, s2.PMI as PMI_SCC2, s2.NumSamplesCQI0 as NumSamplesCQI0_SCC2, s2.NumSamplesCQI1 as NumSamplesCQI1_SCC2, s2.CQI0 as CQI0_SCC2, s2.CQI1 as CQI1_SCC2,
	s3.TxMode as TxMode_SCC3, s3.RankIndex as RankIndex_SCC3, s3.PMI as PMI_SCC3, s3.NumSamplesCQI0 as NumSamplesCQI0_SCC3, s3.NumSamplesCQI1 as NumSamplesCQI1_SCC3, s3.CQI0 as CQI0_SCC3, s3.CQI1 as CQI1_SCC3,
	s4.TxMode as TxMode_SCC4, s4.RankIndex as RankIndex_SCC4, s4.PMI as PMI_SCC4, s4.NumSamplesCQI0 as NumSamplesCQI0_SCC4, s4.NumSamplesCQI1 as NumSamplesCQI1_SCC4, s4.CQI0 as CQI0_SCC4, s4.CQI1 as CQI1_SCC4,
	s5.TxMode as TxMode_SCC5, s5.RankIndex as RankIndex_SCC5, s5.PMI as PMI_SCC5, s5.NumSamplesCQI0 as NumSamplesCQI0_SCC5, s5.NumSamplesCQI1 as NumSamplesCQI1_SCC5, s5.CQI0 as CQI0_SCC5, s5.CQI1 as CQI1_SCC5,
	s6.TxMode as TxMode_SCC6, s6.RankIndex as RankIndex_SCC6, s6.PMI as PMI_SCC6, s6.NumSamplesCQI0 as NumSamplesCQI0_SCC6, s6.NumSamplesCQI1 as NumSamplesCQI1_SCC6, s6.CQI0 as CQI0_SCC6, s6.CQI1 as CQI1_SCC6,
	s7.TxMode as TxMode_SCC7, s7.RankIndex as RankIndex_SCC7, s7.PMI as PMI_SCC7, s7.NumSamplesCQI0 as NumSamplesCQI0_SCC7, s7.NumSamplesCQI1 as NumSamplesCQI1_SCC7, s7.CQI0 as CQI0_SCC7, s7.CQI1 as CQI1_SCC7,
	
	ROW_NUMBER() over (partition by pcc.sessionid, pcc.testid order by pcc.msgtime asc) as durationID

into _PUCCHCQI_4G
from LTEPUCCHCQI pcc
	inner join _lcc_Serving_Cell_Table_info tech 
		on pcc.sessionid=tech.sessionid and pcc.testid=tech.testid 
			and tech.time_ini <= pcc.MsgTime and pcc.MsgTime <tech.Time_fin
	LEFT OUTER JOIN _SCC_CQI s1 on (pcc.LTEPUCCHCQIId=s1.LTEPUCCHCQIId and pcc.testId=s1.testId and pcc.msgtime=s1.msgtime and s1.CarrierIndex=1)
	LEFT OUTER JOIN _SCC_CQI s2 on (pcc.LTEPUCCHCQIId=s2.LTEPUCCHCQIId and pcc.testId=s2.testId and pcc.msgtime=s2.msgtime and s2.CarrierIndex=2)
	LEFT OUTER JOIN _SCC_CQI s3 on (pcc.LTEPUCCHCQIId=s3.LTEPUCCHCQIId and pcc.testId=s3.testId and pcc.msgtime=s3.msgtime and s3.CarrierIndex=3)
	LEFT OUTER JOIN _SCC_CQI s4 on (pcc.LTEPUCCHCQIId=s4.LTEPUCCHCQIId and pcc.testId=s4.testId and pcc.msgtime=s4.msgtime and s4.CarrierIndex=4)
	LEFT OUTER JOIN _SCC_CQI s5 on (pcc.LTEPUCCHCQIId=s5.LTEPUCCHCQIId and pcc.testId=s5.testId and pcc.msgtime=s5.msgtime and s5.CarrierIndex=5)
	LEFT OUTER JOIN _SCC_CQI s6 on (pcc.LTEPUCCHCQIId=s6.LTEPUCCHCQIId and pcc.testId=s6.testId and pcc.msgtime=s6.msgtime and s6.CarrierIndex=6)
	LEFT OUTER JOIN _SCC_CQI s7 on (pcc.LTEPUCCHCQIId=s7.LTEPUCCHCQIId and pcc.testId=s7.testId and pcc.msgtime=s7.msgtime and s7.CarrierIndex=7)
where pcc.testId > @maxTestid	
order by pcc.sessionid, pcc.TestId			

-- Calculos de las duraciones CQI / TM / RI: inicio = msgTime, fin = msgTime posterior o fin de test
exec sp_lcc_dropifexists '_PUCCHCQI_4G_Duration'		
select ini.*
	,ini.MsgTime as time_ini
	,isnull(fin.MsgTime,DATEADD(ms, t.duration ,t.startTime)) as time_fin
	,DATEDIFF(ms, ini.MsgTime , isnull(fin.MsgTime,DATEADD(ms, t.duration ,t.startTime))) as duration
into _PUCCHCQI_4G_Duration
from _PUCCHCQI_4G ini 
	inner join testinfo t
		on (ini.sessionid = t.sessionid and ini.TestId=t.TestId)			
	left join _PUCCHCQI_4G fin
		on (ini.sessionid = fin.sessionid and ini.TestId = fin.TestId
			and ini.durationID = fin.durationID -1)

--Info acotada al momento de la descarga, subida, navegacion y reproduccion
exec sp_lcc_dropifexists '_PUCCHCQI_4G_Duration_acotada'
select c.*
	,case when k.starttime <= c.time_ini then c.time_ini
		else k.starttime
	end as time_ini_acotado
	,case when c.time_fin <= k.endtime then c.time_fin
		else k.endtime
	end as time_fin_acotado
	,case when k.starttime <= c.time_ini and c.time_fin <= k.endtime then c.duration						--Ini/Fin de la info dentro
		when c.time_ini <= k.starttime and k.endtime <= c.time_fin then k.duration							--Ini anterior y fin dentro, acotamos
		when c.time_ini <= k.starttime and c.time_fin <= k.endtime then DATEDIFF(ms,k.starttime,c.time_fin) --Ini/Fin de la info fuera pero conteniendolo, acotamos
		when k.starttime <= time_ini and k.endtime <= c.time_fin then DATEDIFF(ms,c.time_ini,k.endtime)		--Ini dentro pero fin posterior, acotamos
	end as duration_acotada
into _PUCCHCQI_4G_Duration_acotada
from  testinfo t
	inner join _intervalos k 
		on t.sessionid=k.sessionid and t.testid=k.testid
	left join _PUCCHCQI_4G_Duration c
		on t.SessionId = c.SessionId  and t.testid=c.testid
			and k.starttime < c.time_fin
			and k.endtime > c.time_ini
where t.valid=1
	and t.testid > @maxTestid

--Info acotada al momento de la descarga, subida, navegacion y reproduccion, teniendo en cuenta el acceso:
exec sp_lcc_dropifexists '_PUCCHCQI_4G_Duration_acotada_all'
select c.*
	,case when k.starttime <= c.time_ini then c.time_ini
		else k.starttime
	end as time_ini_acotado
	,case when c.time_fin <= k.endtime then c.time_fin
		else k.endtime
	end as time_fin_acotado
	,case when k.starttime <= c.time_ini and c.time_fin <= k.endtime then c.duration						--Ini/Fin de la info dentro
		when c.time_ini <= k.starttime and k.endtime <= c.time_fin then k.duration							--Ini anterior y fin dentro, acotamos
		when c.time_ini <= k.starttime and c.time_fin <= k.endtime then DATEDIFF(ms,k.starttime,c.time_fin) --Ini/Fin de la info fuera pero conteniendolo, acotamos
		when k.starttime <= time_ini and k.endtime <= c.time_fin then DATEDIFF(ms,c.time_ini,k.endtime)		--Ini dentro pero fin posterior, acotamos
	end as duration_acotada
into _PUCCHCQI_4G_Duration_acotada_all
from  testinfo t
	inner join _intervalos_all k 
		on t.sessionid=k.sessionid and t.testid=k.testid
	left join _PUCCHCQI_4G_Duration c
		on t.SessionId = c.SessionId  and t.testid=c.testid
			and k.starttime < c.time_fin
			and k.endtime > c.time_ini
where t.valid=1
	and t.testid > @maxTestid

-------------------------------------------------------------------------------------------------------------------------------------
-- 4G: Calculo de CQI / TM / RI desde la tabla de sistema
-------------------------------------------------------------------------------------------------------------------------------------
--Info acotada al momento de la descarga, subida, navegacion y reproduccion
exec sp_lcc_dropifexists '_CQI_4G_acotado'			
select 
	sessionid, TestId, 
	-- Resumen:
	1.0*sum(CQI*duration_acotada)/nullif(sum(duration_acotada),0) as avgCQI,
	1.0*sum(CQI_PCC*duration_acotada)/NULLIF(1.0*sum(case when CQI_PCC is not null then duration_acotada end),0) as avgCQI_PCC,
	1.0*sum(CQI_SCC1*duration_acotada)/NULLIF(1.0*sum(case when CQI_SCC1 is not null then duration_acotada end),0) as avgCQI_SCC1,
	1.0*sum(CQI_SCC2*duration_acotada)/NULLIF(1.0*sum(case when CQI_SCC2 is not null then duration_acotada end),0) as avgCQI_SCC2, 
	-- MIMO en alguna carrier 
	1.0*sum(case when (RankIndex_PCC=2 and txmode_PCC in (2,3,4)) 
			or (RankIndex_SCC1=2 and txmode_SCC1 in (2,3,4)) 
			or (RankIndex_SCC2=2 and txmode_SCC2 in (2,3,4)) then duration_acotada end *1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_any_MIMO,
	-- MIMO en todas las carriers
	1.0*sum(case when RankIndex_PCC=2 and txmode_PCC in (2,3,4)
			and RankIndex_SCC1=2 and txmode_SCC1 in (2,3,4)
			and RankIndex_SCC2=2 and txmode_SCC2 in (2,3,4) then duration_acotada end *1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_all_MIMO,
	-- MIMO global (ponderando por cuantas carrier lo tengan en cada instante de tiempo)
	1.0*sum((1.0*((case when RankIndex_PCC=2 and txmode_PCC in (2,3,4) then 1 else 0 end)+
		(case when RankIndex_SCC1=2 and txmode_SCC1 in (2,3,4) then 1 else 0 end)+
		(case when RankIndex_SCC2=2 and txmode_SCC2 in (2,3,4) then 1 else 0 end))/number_Carrier)*duration_acotada*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_MIMO,
	--RI=1 en alguna carrier
	1.0*sum(case when RankIndex_PCC=1 or RankIndex_SCC1=1 or RankIndex_SCC2=1 then duration_acotada	end *1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_any_RI1,
	1.0*sum(case when RankIndex_PCC=2 or RankIndex_SCC1=2 or RankIndex_SCC2=2 then duration_acotada	end *1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_any_RI2,
	-- Combianciones de RI entre las 3 carriers:
	1.0*sum(case when RankIndex_PCC=1 and RankIndex_SCC1 is null and RankIndex_SCC2 is null then duration_acotada end *1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_1nullnull,	
	1.0*sum(case when RankIndex_PCC=1 and RankIndex_SCC1=1 and RankIndex_SCC2 is null then duration_acotada end*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_11null,
	1.0*sum(case when RankIndex_PCC=1 and RankIndex_SCC1=1 and RankIndex_SCC2=1 then duration_acotada end*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_111,
	1.0*sum(case when RankIndex_PCC=1 and RankIndex_SCC1=1 and RankIndex_SCC2=2 then duration_acotada end*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_112,
	1.0*sum(case when RankIndex_PCC=1 and RankIndex_SCC1=2 and RankIndex_SCC2 is null then duration_acotada end*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_12null,
	1.0*sum(case when RankIndex_PCC=1 and RankIndex_SCC1=2 and RankIndex_SCC2=1 then duration_acotada end*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_121,
	1.0*sum(case when RankIndex_PCC=1 and RankIndex_SCC1=2 and RankIndex_SCC2=2 then duration_acotada end*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_122,
	1.0*sum(case when RankIndex_PCC=2 and RankIndex_SCC1 is null and RankIndex_SCC2 is null then duration_acotada end *1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_2nullnull,	
	1.0*sum(case when RankIndex_PCC=2 and RankIndex_SCC1=1 and RankIndex_SCC2 is null then duration_acotada end*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_21null,
	1.0*sum(case when RankIndex_PCC=2 and RankIndex_SCC1=1 and RankIndex_SCC2=1 then duration_acotada end*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_211,
	1.0*sum(case when RankIndex_PCC=2 and RankIndex_SCC1=1 and RankIndex_SCC2=2 then duration_acotada end*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_212,
	1.0*sum(case when RankIndex_PCC=2 and RankIndex_SCC1=2 and RankIndex_SCC2 is null then duration_acotada end*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_22null,
	1.0*sum(case when RankIndex_PCC=2 and RankIndex_SCC1=2 and RankIndex_SCC2=1 then duration_acotada end*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_221,
	1.0*sum(case when RankIndex_PCC=2 and RankIndex_SCC1=2 and RankIndex_SCC2=2 then duration_acotada end*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_222,
	--RI=1 global (ponderando por cuantas carrier lo tengan en cada instante de tiempo)
	1.0*sum((1.0*((case when RankIndex_PCC=1 then 1 else 0 end)+
		(case when RankIndex_SCC1=1 then 1 else 0 end)+
		(case when RankIndex_SCC2=1 then 1 else 0 end))/number_Carrier)*duration_acotada*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI1,
	--RI=2 global (ponderando por cuantas carrier lo tengan en cada instante de tiempo)
	1.0*sum((1.0*((case when RankIndex_PCC=2 then 1 else 0 end)+
		(case when RankIndex_SCC1=2 then 1 else 0 end)+
		(case when RankIndex_SCC2=2 then 1 else 0 end))/number_Carrier)*duration_acotada*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI2,
	--RI=2 y TM=2 global (ponderando por cuantas carrier lo tengan en cada instante de tiempo)
	1.0*sum((1.0*((case when RankIndex_PCC=2 and txmode_PCC in (2) then 1 else 0 end)+
		(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1=2 and TxMode_SCC1 in (2) then 1 else 0 end)+
		(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2=2 and TxMode_SCC2 in (2) then 1 else 0 end))/number_Carrier)*duration_acotada*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI2_TM2,
	--RI=2 y TM=3 global (ponderando por cuantas carrier lo tengan en cada instante de tiempo)
	1.0*sum((1.0*((case when RankIndex_PCC=2 and txmode_PCC in (3) then 1 else 0 end)+
		(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1=2 and TxMode_SCC1 in (3) then 1 else 0 end)+
		(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2=2 and TxMode_SCC2 in (3) then 1 else 0 end))/number_Carrier)*duration_acotada*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI2_TM3,
	--RI=2 y TM=4 global (ponderando por cuantas carrier lo tengan en cada instante de tiempo)
	1.0*sum((1.0*((case when RankIndex_PCC=2 and txmode_PCC in (4) then 1 else 0 end)+
		(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1=2 and TxMode_SCC1 in (4) then 1 else 0 end)+
		(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2=2 and TxMode_SCC2 in (4) then 1 else 0 end))/number_Carrier)*duration_acotada*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI2_TM4,
	
	--Informacion PCC:		
	1.0*(sum(case when RankIndex_PCC=2 and txmode_PCC in (2,3,4) then duration_acotada*1.0 else 0 end) / nullif(sum(case when RankIndex_PCC in (1,2) then duration_acotada*1.0 end),0)) as perc_MIMO_PCC,
	1.0*(sum(case when RankIndex_PCC=1 then duration_acotada*1.0 else 0 end) / nullif(sum(case when RankIndex_PCC in (1,2) then duration_acotada*1.0 end),0)) as perc_RI1_PCC,
	1.0*(sum(case when RankIndex_PCC=2 then duration_acotada*1.0 else 0 end) / nullif(sum(case when RankIndex_PCC in (1,2) then duration_acotada*1.0 end),0)) as perc_RI2_PCC,
	1.0*(sum(case when RankIndex_PCC=2 and txmode_PCC in (3,4) then duration_acotada*1.0 else 0 end) / nullif(sum(case when RankIndex_PCC in (1,2) then duration_acotada*1.0 end),0)) as perc_RI2_TM_3_4_PCC,	
	1.0*(sum(case when RankIndex_PCC=2 and txmode_PCC in (2) then duration_acotada*1.0 else 0 end) / nullif(sum(case when RankIndex_PCC in (1,2) then duration_acotada*1.0 end ),0)) as perc_RI2_TM2_PCC,	
	1.0*(sum(case when RankIndex_PCC=2 and txmode_PCC in (3) then duration_acotada*1.0 else 0 end) / nullif(sum(case when RankIndex_PCC in (1,2) then duration_acotada*1.0 end),0)) as perc_RI2_TM3_PCC,
	1.0*(sum(case when RankIndex_PCC=2 and txmode_PCC in (4) then duration_acotada*1.0 else 0 end) / nullif(sum(case when RankIndex_PCC in (1,2) then duration_acotada*1.0 end),0)) as perc_RI2_TM4_PCC,
	--Informacion SCC1 (sobre la duracion total de SCC1 reportada): 
	1.0*(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1=2 and TxMode_SCC1 in (2,3,4) then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1 in (1,2) then duration_acotada*1.0 end),0))					as perc_MIMO_SCC1,
	1.0*(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1=1 then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1 in (1,2) then duration_acotada*1.0 end),0))					as perc_RI1_SCC1,
	1.0*(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1=2 then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1 in (1,2) then duration_acotada*1.0 end ),0))					as perc_RI2_SCC1,
	1.0*(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1=2 and TxMode_SCC1 in (3,4) then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1 in (1,2) then duration_acotada*1.0 end),0)) as perc_RI2_TM_3_4_SCC1,		
	(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1=2 and TxMode_SCC1 in (2) then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1 in (1,2) then duration_acotada*1.0 end),0))*1.0 as perc_RI2_TM2_SCC1,
	(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1=2 and TxMode_SCC1 in (3) then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1 in (1,2) then duration_acotada*1.0 end),0))*1.0 as perc_RI2_TM3_SCC1,
	(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1=2 and TxMode_SCC1 in (4) then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1 in (1,2) then duration_acotada*1.0 end),0))*1.0 as perc_RI2_TM4_SCC1,
	--Informacion SCC2 Informacion (sobre la duracion total de SCC2 reportada): 
	1.0*(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2=2 and TxMode_SCC2 in (2,3,4) then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2 in (1,2) then duration_acotada*1.0 end),0))					as perc_MIMO_SCC2,
	1.0*(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2=1 then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2 in (1,2) then duration_acotada*1.0 end),0))					as perc_RI1_SCC2,
	1.0*(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2=2 then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2 in (1,2) then duration_acotada*1.0 end ),0))					as perc_RI2_SCC2,
	1.0*(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2=2 and TxMode_SCC2 in (3,4) then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2 in (1,2) then duration_acotada*1.0 end),0)) as perc_RI2_TM_3_4_SCC2,		
	(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2=2 and TxMode_SCC2 in (2) then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2 in (1,2) then duration_acotada*1.0 end),0))*1.0 as perc_RI2_TM2_SCC2,
	(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2=2 and TxMode_SCC2 in (3) then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2 in (1,2) then duration_acotada*1.0 end),0))*1.0 as perc_RI2_TM3_SCC2,
	(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2=2 and TxMode_SCC2 in (4) then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2 in (1,2) then duration_acotada*1.0 end),0))*1.0 as perc_RI2_TM4_SCC2,
	-- CQI Desglose por banda
	-- ALL: se deja para UL pero NO esta bien calculado para DL con CA ó 3C
	1.0*sum(case when band like 'LTE2600' then CQI*duration_acotada end) / NULLIF(1.0*sum(duration_acotada),0) AS 'avgCQI_LTE2600',
	1.0*sum(case when band like 'LTE800' then CQI*duration_acotada end) / NULLIF(1.0*sum(duration_acotada),0) AS 'avgCQI_LTE800',
	1.0*sum(case when band like 'LTE2100' then CQI*duration_acotada end) / NULLIF(1.0*sum(duration_acotada),0) AS 'avgCQI_LTE2100',
	1.0*sum(case when band like 'LTE1800' then CQI*duration_acotada end) / NULLIF(1.0*sum(duration_acotada),0) AS 'avgCQI_LTE1800',
	-- PCC:
	1.0*sum(case when band like 'LTE2600' then CQI_PCC*duration_acotada end) / NULLIF(1.0*sum(case when CQI_PCC is not null then duration_acotada end),0) AS 'avgCQI_PCC_LTE2600',
	1.0*sum(case when band like 'LTE800' then CQI_PCC*duration_acotada end) / NULLIF(1.0*sum(case when CQI_PCC is not null then duration_acotada end),0) AS 'avgCQI_PCC_LTE800',
	1.0*sum(case when band like 'LTE2100' then CQI_PCC*duration_acotada end) / NULLIF(1.0*sum(case when CQI_PCC is not null then duration_acotada end),0) AS 'avgCQI_PCC_LTE2100',
	1.0*sum(case when band like 'LTE1800' then CQI_PCC*duration_acotada end) / NULLIF(1.0*sum(case when CQI_PCC is not null then duration_acotada end),0) AS 'avgCQI_PCC_LTE1800'--,
	--SCC1:
	--1.0*sum(case when band like 'LTE2600' then CQI_SCC1*duration_acotada end) / NULLIF(1.0*sum(case when CQI_SCC1 is not null then duration_acotada end),0) AS 'avgCQI_SCC1_LTE2600',
	--1.0*sum(case when band like 'LTE800' then CQI_SCC1*duration_acotada end) / NULLIF(1.0*sum(case when CQI_SCC1 is not null then duration_acotada end),0) AS 'avgCQI_SCC1_LTE800',
	--1.0*sum(case when band like 'LTE2100' then CQI_SCC1*duration_acotada end) / NULLIF(1.0*sum(case when CQI_SCC1 is not null then duration_acotada end),0) AS 'avgCQI_SCC1_LTE2100',
	--1.0*sum(case when band like 'LTE1800' then CQI_SCC1*duration_acotada end) / NULLIF(1.0*sum(case when CQI_SCC1 is not null then duration_acotada end),0) AS 'avgCQI_SCC1_LTE1800',
	--SCC2:
	--1.0*sum(case when band like 'LTE2600' then CQI_SCC2*duration_acotada end) / NULLIF(1.0*sum(case when CQI_SCC2 is not null then duration_acotada end),0) AS 'avgCQI_SCC2_LTE2600',
	--1.0*sum(case when band like 'LTE800' then CQI_SCC2*duration_acotada end) / NULLIF(1.0*sum(case when CQI_SCC2 is not null then duration_acotada end),0) AS 'avgCQI_SCC2_LTE800',
	--1.0*sum(case when band like 'LTE2100' then CQI_SCC2*duration_acotada end) / NULLIF(1.0*sum(case when CQI_SCC2 is not null then duration_acotada end),0) AS 'avgCQI_SCC2_LTE2100',
	--1.0*sum(case when band like 'LTE1800' then CQI_SCC2*duration_acotada end) / NULLIF(1.0*sum(case when CQI_SCC2 is not null then duration_acotada end),0) AS 'avgCQI_SCC2_LTE1800'
				
into _CQI_4G_acotado
from _PUCCHCQI_4G_duration_acotada 
group by sessionid, TestId
order by sessionid, TestId

--Info acotada al momento de la descarga, subida, navegacion y reproduccion, teniendo en cuenta el acceso:
exec sp_lcc_dropifexists '_CQI_4G_acotado_acc'			
select 
	sessionid, TestId, 
	-- Resumen:
	1.0*sum(CQI*duration_acotada)/nullif(sum(duration_acotada),0) as avgCQI,
	1.0*sum(CQI_PCC*duration_acotada)/NULLIF(1.0*sum(case when CQI_PCC is not null then duration_acotada end),0) as avgCQI_PCC,
	1.0*sum(CQI_SCC1*duration_acotada)/NULLIF(1.0*sum(case when CQI_SCC1 is not null then duration_acotada end),0) as avgCQI_SCC1,
	1.0*sum(CQI_SCC2*duration_acotada)/NULLIF(1.0*sum(case when CQI_SCC2 is not null then duration_acotada end),0) as avgCQI_SCC2, 
	-- MIMO en alguna carrier 
	1.0*sum(case when (RankIndex_PCC=2 and txmode_PCC in (2,3,4)) 
			or (RankIndex_SCC1=2 and txmode_SCC1 in (2,3,4)) 
			or (RankIndex_SCC2=2 and txmode_SCC2 in (2,3,4)) then duration_acotada end *1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_any_MIMO,
	-- MIMO en todas las carriers
	1.0*sum(case when RankIndex_PCC=2 and txmode_PCC in (2,3,4)
			and RankIndex_SCC1=2 and txmode_SCC1 in (2,3,4)
			and RankIndex_SCC2=2 and txmode_SCC2 in (2,3,4) then duration_acotada end *1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_all_MIMO,
	-- MIMO global (ponderando por cuantas carrier lo tengan en cada instante de tiempo)
	1.0*sum((1.0*((case when RankIndex_PCC=2 and txmode_PCC in (2,3,4) then 1 else 0 end)+
		(case when RankIndex_SCC1=2 and txmode_SCC1 in (2,3,4) then 1 else 0 end)+
		(case when RankIndex_SCC2=2 and txmode_SCC2 in (2,3,4) then 1 else 0 end))/number_Carrier)*duration_acotada*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_MIMO,
	--RI=1 en alguna carrier
	1.0*sum(case when RankIndex_PCC=1 or RankIndex_SCC1=1 or RankIndex_SCC2=1 then duration_acotada	end *1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_any_RI1,
	1.0*sum(case when RankIndex_PCC=2 or RankIndex_SCC1=2 or RankIndex_SCC2=2 then duration_acotada	end *1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_any_RI2,
	-- Combianciones de RI entre las 3 carriers:
	1.0*sum(case when RankIndex_PCC=1 and RankIndex_SCC1 is null and RankIndex_SCC2 is null then duration_acotada end *1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_1nullnull,	
	1.0*sum(case when RankIndex_PCC=1 and RankIndex_SCC1=1 and RankIndex_SCC2 is null then duration_acotada end*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_11null,
	1.0*sum(case when RankIndex_PCC=1 and RankIndex_SCC1=1 and RankIndex_SCC2=1 then duration_acotada end*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_111,
	1.0*sum(case when RankIndex_PCC=1 and RankIndex_SCC1=1 and RankIndex_SCC2=2 then duration_acotada end*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_112,
	1.0*sum(case when RankIndex_PCC=1 and RankIndex_SCC1=2 and RankIndex_SCC2 is null then duration_acotada end*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_12null,
	1.0*sum(case when RankIndex_PCC=1 and RankIndex_SCC1=2 and RankIndex_SCC2=1 then duration_acotada end*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_121,
	1.0*sum(case when RankIndex_PCC=1 and RankIndex_SCC1=2 and RankIndex_SCC2=2 then duration_acotada end*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_122,
	1.0*sum(case when RankIndex_PCC=2 and RankIndex_SCC1 is null and RankIndex_SCC2 is null then duration_acotada end *1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_2nullnull,	
	1.0*sum(case when RankIndex_PCC=2 and RankIndex_SCC1=1 and RankIndex_SCC2 is null then duration_acotada end*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_21null,
	1.0*sum(case when RankIndex_PCC=2 and RankIndex_SCC1=1 and RankIndex_SCC2=1 then duration_acotada end*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_211,
	1.0*sum(case when RankIndex_PCC=2 and RankIndex_SCC1=1 and RankIndex_SCC2=2 then duration_acotada end*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_212,
	1.0*sum(case when RankIndex_PCC=2 and RankIndex_SCC1=2 and RankIndex_SCC2 is null then duration_acotada end*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_22null,
	1.0*sum(case when RankIndex_PCC=2 and RankIndex_SCC1=2 and RankIndex_SCC2=1 then duration_acotada end*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_221,
	1.0*sum(case when RankIndex_PCC=2 and RankIndex_SCC1=2 and RankIndex_SCC2=2 then duration_acotada end*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI_222,
	--RI=1 global (ponderando por cuantas carrier lo tengan en cada instante de tiempo)
	1.0*sum((1.0*((case when RankIndex_PCC=1 then 1 else 0 end)+
		(case when RankIndex_SCC1=1 then 1 else 0 end)+
		(case when RankIndex_SCC2=1 then 1 else 0 end))/number_Carrier)*duration_acotada*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI1,
	--RI=2 global (ponderando por cuantas carrier lo tengan en cada instante de tiempo)
	1.0*sum((1.0*((case when RankIndex_PCC=2 then 1 else 0 end)+
		(case when RankIndex_SCC1=2 then 1 else 0 end)+
		(case when RankIndex_SCC2=2 then 1 else 0 end))/number_Carrier)*duration_acotada*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI2,
	--RI=2 y TM=2 global (ponderando por cuantas carrier lo tengan en cada instante de tiempo)
	1.0*sum((1.0*((case when RankIndex_PCC=2 and txmode_PCC in (2) then 1 else 0 end)+
		(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1=2 and TxMode_SCC1 in (2) then 1 else 0 end)+
		(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2=2 and TxMode_SCC2 in (2) then 1 else 0 end))/number_Carrier)*duration_acotada*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI2_TM2,
	--RI=2 y TM=3 global (ponderando por cuantas carrier lo tengan en cada instante de tiempo)
	1.0*sum((1.0*((case when RankIndex_PCC=2 and txmode_PCC in (3) then 1 else 0 end)+
		(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1=2 and TxMode_SCC1 in (3) then 1 else 0 end)+
		(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2=2 and TxMode_SCC2 in (3) then 1 else 0 end))/number_Carrier)*duration_acotada*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI2_TM3,
	--RI=2 y TM=4 global (ponderando por cuantas carrier lo tengan en cada instante de tiempo)
	1.0*sum((1.0*((case when RankIndex_PCC=2 and txmode_PCC in (4) then 1 else 0 end)+
		(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1=2 and TxMode_SCC1 in (4) then 1 else 0 end)+
		(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2=2 and TxMode_SCC2 in (4) then 1 else 0 end))/number_Carrier)*duration_acotada*1.0)/NULLIF(sum(duration_acotada*1.0),0) as perc_RI2_TM4,
	
	--Informacion PCC:		
	1.0*(sum(case when RankIndex_PCC=2 and txmode_PCC in (2,3,4) then duration_acotada*1.0 else 0 end) / nullif(sum(case when RankIndex_PCC in (1,2) then duration_acotada*1.0 end),0)) as perc_MIMO_PCC,
	1.0*(sum(case when RankIndex_PCC=1 then duration_acotada*1.0 else 0 end) / nullif(sum(case when RankIndex_PCC in (1,2) then duration_acotada*1.0 end),0)) as perc_RI1_PCC,
	1.0*(sum(case when RankIndex_PCC=2 then duration_acotada*1.0 else 0 end) / nullif(sum(case when RankIndex_PCC in (1,2) then duration_acotada*1.0 end),0)) as perc_RI2_PCC,
	1.0*(sum(case when RankIndex_PCC=2 and txmode_PCC in (3,4) then duration_acotada*1.0 else 0 end) / nullif(sum(case when RankIndex_PCC in (1,2) then duration_acotada*1.0 end),0)) as perc_RI2_TM_3_4_PCC,	
	1.0*(sum(case when RankIndex_PCC=2 and txmode_PCC in (2) then duration_acotada*1.0 else 0 end) / nullif(sum(case when RankIndex_PCC in (1,2) then duration_acotada*1.0 end ),0)) as perc_RI2_TM2_PCC,	
	1.0*(sum(case when RankIndex_PCC=2 and txmode_PCC in (3) then duration_acotada*1.0 else 0 end) / nullif(sum(case when RankIndex_PCC in (1,2) then duration_acotada*1.0 end),0)) as perc_RI2_TM3_PCC,
	1.0*(sum(case when RankIndex_PCC=2 and txmode_PCC in (4) then duration_acotada*1.0 else 0 end) / nullif(sum(case when RankIndex_PCC in (1,2) then duration_acotada*1.0 end),0)) as perc_RI2_TM4_PCC,
	--Informacion SCC1 (sobre la duracion total de SCC1 reportada): 
	1.0*(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1=2 and TxMode_SCC1 in (2,3,4) then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1 in (1,2) then duration_acotada*1.0 end),0))					as perc_MIMO_SCC1,
	1.0*(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1=1 then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1 in (1,2) then duration_acotada*1.0 end),0))					as perc_RI1_SCC1,
	1.0*(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1=2 then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1 in (1,2) then duration_acotada*1.0 end ),0))					as perc_RI2_SCC1,
	1.0*(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1=2 and TxMode_SCC1 in (3,4) then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1 in (1,2) then duration_acotada*1.0 end),0)) as perc_RI2_TM_3_4_SCC1,		
	(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1=2 and TxMode_SCC1 in (2) then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1 in (1,2) then duration_acotada*1.0 end),0))*1.0 as perc_RI2_TM2_SCC1,
	(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1=2 and TxMode_SCC1 in (3) then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1 in (1,2) then duration_acotada*1.0 end),0))*1.0 as perc_RI2_TM3_SCC1,
	(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1=2 and TxMode_SCC1 in (4) then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s1_LTEPUCCHCQIId is not null and RankIndex_SCC1 in (1,2) then duration_acotada*1.0 end),0))*1.0 as perc_RI2_TM4_SCC1,
	--Informacion SCC2 Informacion (sobre la duracion total de SCC2 reportada): 
	1.0*(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2=2 and TxMode_SCC2 in (2,3,4) then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2 in (1,2) then duration_acotada*1.0 end),0))					as perc_MIMO_SCC2,
	1.0*(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2=1 then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2 in (1,2) then duration_acotada*1.0 end),0))					as perc_RI1_SCC2,
	1.0*(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2=2 then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2 in (1,2) then duration_acotada*1.0 end ),0))					as perc_RI2_SCC2,
	1.0*(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2=2 and TxMode_SCC2 in (3,4) then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2 in (1,2) then duration_acotada*1.0 end),0)) as perc_RI2_TM_3_4_SCC2,		
	(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2=2 and TxMode_SCC2 in (2) then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2 in (1,2) then duration_acotada*1.0 end),0))*1.0 as perc_RI2_TM2_SCC2,
	(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2=2 and TxMode_SCC2 in (3) then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2 in (1,2) then duration_acotada*1.0 end),0))*1.0 as perc_RI2_TM3_SCC2,
	(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2=2 and TxMode_SCC2 in (4) then duration_acotada*1.0 else 0 end) / 
		nullif(sum(case when s2_LTEPUCCHCQIId is not null and RankIndex_SCC2 in (1,2) then duration_acotada*1.0 end),0))*1.0 as perc_RI2_TM4_SCC2,
	-- CQI Desglose por banda
	-- ALL: se deja para UL pero NO esta bien calculado para DL con CA ó 3C
	1.0*sum(case when band like 'LTE2600' then CQI*duration_acotada end) / NULLIF(1.0*sum(duration_acotada),0) AS 'avgCQI_LTE2600',
	1.0*sum(case when band like 'LTE800' then CQI*duration_acotada end) / NULLIF(1.0*sum(duration_acotada),0) AS 'avgCQI_LTE800',
	1.0*sum(case when band like 'LTE2100' then CQI*duration_acotada end) / NULLIF(1.0*sum(duration_acotada),0) AS 'avgCQI_LTE2100',
	1.0*sum(case when band like 'LTE1800' then CQI*duration_acotada end) / NULLIF(1.0*sum(duration_acotada),0) AS 'avgCQI_LTE1800',
	-- PCC:
	1.0*sum(case when band like 'LTE2600' then CQI_PCC*duration_acotada end) / NULLIF(1.0*sum(case when CQI_PCC is not null then duration_acotada end),0) AS 'avgCQI_PCC_LTE2600',
	1.0*sum(case when band like 'LTE800' then CQI_PCC*duration_acotada end) / NULLIF(1.0*sum(case when CQI_PCC is not null then duration_acotada end),0) AS 'avgCQI_PCC_LTE800',
	1.0*sum(case when band like 'LTE2100' then CQI_PCC*duration_acotada end) / NULLIF(1.0*sum(case when CQI_PCC is not null then duration_acotada end),0) AS 'avgCQI_PCC_LTE2100',
	1.0*sum(case when band like 'LTE1800' then CQI_PCC*duration_acotada end) / NULLIF(1.0*sum(case when CQI_PCC is not null then duration_acotada end),0) AS 'avgCQI_PCC_LTE1800'--,
	--SCC1:
	--1.0*sum(case when band like 'LTE2600' then CQI_SCC1*duration_acotada end) / NULLIF(1.0*sum(case when CQI_SCC1 is not null then duration_acotada end),0) AS 'avgCQI_SCC1_LTE2600',
	--1.0*sum(case when band like 'LTE800' then CQI_SCC1*duration_acotada end) / NULLIF(1.0*sum(case when CQI_SCC1 is not null then duration_acotada end),0) AS 'avgCQI_SCC1_LTE800',
	--1.0*sum(case when band like 'LTE2100' then CQI_SCC1*duration_acotada end) / NULLIF(1.0*sum(case when CQI_SCC1 is not null then duration_acotada end),0) AS 'avgCQI_SCC1_LTE2100',
	--1.0*sum(case when band like 'LTE1800' then CQI_SCC1*duration_acotada end) / NULLIF(1.0*sum(case when CQI_SCC1 is not null then duration_acotada end),0) AS 'avgCQI_SCC1_LTE1800',
	--SCC2:
	--1.0*sum(case when band like 'LTE2600' then CQI_SCC2*duration_acotada end) / NULLIF(1.0*sum(case when CQI_SCC2 is not null then duration_acotada end),0) AS 'avgCQI_SCC2_LTE2600',
	--1.0*sum(case when band like 'LTE800' then CQI_SCC2*duration_acotada end) / NULLIF(1.0*sum(case when CQI_SCC2 is not null then duration_acotada end),0) AS 'avgCQI_SCC2_LTE800',
	--1.0*sum(case when band like 'LTE2100' then CQI_SCC2*duration_acotada end) / NULLIF(1.0*sum(case when CQI_SCC2 is not null then duration_acotada end),0) AS 'avgCQI_SCC2_LTE2100',
	--1.0*sum(case when band like 'LTE1800' then CQI_SCC2*duration_acotada end) / NULLIF(1.0*sum(case when CQI_SCC2 is not null then duration_acotada end),0) AS 'avgCQI_SCC2_LTE1800'
		
into _CQI_4G_acotado_acc
from _PUCCHCQI_4G_duration_acotada_all
group by sessionid, TestId
order by sessionid, TestId


-- ERC - 20170112 - d) Transmission Mode 4G UL	
--Info acotada al momento de la descarga, subida, navegacion y reproduccion
exec sp_lcc_dropifexists '_TM_UL_acotado'			
select 
	sessionid, testid, 		
	
	-- ERC - 20170112: Se calcula el % por duraciones	
	-- PCC:
	1.0*SUM(case when TxMode_PCC=0 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM0',
	1.0*SUM(case when TxMode_PCC=1 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM1',
	1.0*SUM(case when TxMode_PCC=2 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM2',
	1.0*SUM(case when TxMode_PCC=3 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM3',
	1.0*SUM(case when TxMode_PCC=4 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM4',
	1.0*SUM(case when TxMode_PCC=5 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM5',   
	1.0*SUM(case when TxMode_PCC=6 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM6',   
	1.0*SUM(case when TxMode_PCC=7 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM7',   
	1.0*SUM(case when TxMode_PCC=8 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM8',
	1.0*SUM(case when TxMode_PCC=9 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM9',
	1.0*SUM(case when TxMode_PCC is NULL then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTMunknown',
	
	-- SCC1:	- De momento solo para la SCC1
	1.0*SUM(case when TxMode_SCC1=0 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM0_SCC1',
	1.0*SUM(case when TxMode_SCC1=1 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM1_SCC1',
	1.0*SUM(case when TxMode_SCC1=2 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM2_SCC1',
	1.0*SUM(case when TxMode_SCC1=3 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM3_SCC1',
	1.0*SUM(case when TxMode_SCC1=4 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM4_SCC1',
	1.0*SUM(case when TxMode_SCC1=5 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM5_SCC1',   
	1.0*SUM(case when TxMode_SCC1=6 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM6_SCC1',   
	1.0*SUM(case when TxMode_SCC1=7 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM7_SCC1',   
	1.0*SUM(case when TxMode_SCC1=8 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM8_SCC1',
	1.0*SUM(case when TxMode_SCC1=9 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM9_SCC1',
	1.0*SUM(case when TxMode_SCC1 is NULL then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTMunknown_SCC1'	
			   
into _TM_UL_acotado     
from _PUCCHCQI_4G_duration_acotada 
group by sessionid, testid

--Info acotada al momento de la descarga, subida, navegacion y reproduccion, teniendo en cuenta el acceso:
exec sp_lcc_dropifexists '_TM_UL_acotado_acc'			
select 
	sessionid, testid, 		
	
	-- ERC - 20170112: Se calcula el % por duraciones	
	-- PCC:
	1.0*SUM(case when TxMode_PCC=0 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM0',
	1.0*SUM(case when TxMode_PCC=1 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM1',
	1.0*SUM(case when TxMode_PCC=2 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM2',
	1.0*SUM(case when TxMode_PCC=3 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM3',
	1.0*SUM(case when TxMode_PCC=4 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM4',
	1.0*SUM(case when TxMode_PCC=5 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM5',   
	1.0*SUM(case when TxMode_PCC=6 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM6',   
	1.0*SUM(case when TxMode_PCC=7 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM7',   
	1.0*SUM(case when TxMode_PCC=8 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM8',
	1.0*SUM(case when TxMode_PCC=9 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM9',
	1.0*SUM(case when TxMode_PCC is NULL then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTMunknown',
	
	-- SCC1:	- De momento solo para la SCC1
	1.0*SUM(case when TxMode_SCC1=0 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM0_SCC1',
	1.0*SUM(case when TxMode_SCC1=1 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM1_SCC1',
	1.0*SUM(case when TxMode_SCC1=2 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM2_SCC1',
	1.0*SUM(case when TxMode_SCC1=3 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM3_SCC1',
	1.0*SUM(case when TxMode_SCC1=4 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM4_SCC1',
	1.0*SUM(case when TxMode_SCC1=5 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM5_SCC1',   
	1.0*SUM(case when TxMode_SCC1=6 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM6_SCC1',   
	1.0*SUM(case when TxMode_SCC1=7 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM7_SCC1',   
	1.0*SUM(case when TxMode_SCC1=8 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM8_SCC1',
	1.0*SUM(case when TxMode_SCC1=9 then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTM9_SCC1',
	1.0*SUM(case when TxMode_SCC1 is NULL then duration_acotada else 0 end)/nullif(SUM(duration_acotada),0) as 'percTMunknown_SCC1'	
			   
into _TM_UL_acotado_acc 
from _PUCCHCQI_4G_duration_acotada_all
group by sessionid, testid

-------------------------------------------------------------------------------------------------------------------------------------
-- 3G: Calculo de las duraciones de CQI / Ack / Nack /Dtx / HS BLER / Dual Carrier desde la tabla de sistema
-------------------------------------------------------------------------------------------------------------------------------------
-- DGP 29/10/2015: Se linka con la tabla networkinfo para sacar las tecnologías usadas en cada test y así desglosar por banda el DC
-- *********************************************************************************************************************************

-- Calculos de las duraciones HSDPACQI
exec sp_lcc_dropifexists '_CQI_3G_id'
select h.*,n.technology,tech.band,
	ROW_NUMBER() over (partition by h.sessionid, h.testid order by h.msgtime asc) as durationID
into _CQI_3G_id	
from HSDPACQI h	-- 	contains data for the UL DPCCH	
	inner join networkinfo n on n.networkid=h.networkid
	inner join _lcc_Serving_Cell_Table_info tech 
		on h.sessionid=tech.sessionid and h.testid=tech.testid 
			and tech.time_ini <= h.MsgTime and h.MsgTime <tech.Time_fin
where h.testId > @maxTestid	

exec sp_lcc_dropifexists '_CQI_3G_all'		
select ini.*
	,ini.MsgTime as time_ini
	,isnull(fin.MsgTime,DATEADD(ms, t.duration ,t.startTime)) as time_fin
	,DATEDIFF(ms, ini.MsgTime , isnull(fin.MsgTime,DATEADD(ms, t.duration ,t.startTime))) as duration
into _CQI_3G_all
from _CQI_3G_id ini 
	inner join testinfo t
		on (ini.sessionid = t.sessionid and ini.TestId=t.TestId)			
	left join _CQI_3G_id fin
		on (ini.sessionid = fin.sessionid and ini.TestId = fin.TestId
			and ini.durationID = fin.durationID -1)

--Info acotada al momento de la descarga, subida, navegacion y reproduccion
exec sp_lcc_dropifexists '_CQI_3G_duration_acotada'
select c.*
	,case when k.starttime <= c.time_ini then c.time_ini
		else k.starttime
	end as time_ini_acotado
	,case when c.time_fin <= k.endtime then c.time_fin
		else k.endtime
	end as time_fin_acotado
	,case when k.starttime <= c.time_ini and c.time_fin <= k.endtime then c.duration						--Ini/Fin de la info dentro
		when c.time_ini <= k.starttime and k.endtime <= c.time_fin then k.duration							--Ini anterior y fin dentro, acotamos
		when c.time_ini <= k.starttime and c.time_fin <= k.endtime then DATEDIFF(ms,k.starttime,c.time_fin) --Ini/Fin de la info fuera pero conteniendolo, acotamos
		when k.starttime <= time_ini and k.endtime <= c.time_fin then DATEDIFF(ms,c.time_ini,k.endtime)		--Ini dentro pero fin posterior, acotamos
	end as duration_acotada
into _CQI_3G_duration_acotada
from  testinfo t
	inner join _intervalos k 
		on t.sessionid=k.sessionid and t.testid=k.testid
	left join _CQI_3G_all c
		on t.sessionid=c.sessionid and t.testid=c.testid
			and k.starttime < c.time_fin
			and k.endtime > c.time_ini
where t.valid=1
	and t.testid > @maxTestid

--Info acotada al momento de la descarga, subida, navegacion y reproduccion, teniendo en cuenta el acceso:
exec sp_lcc_dropifexists '_CQI_3G_duration_acotada_all'
select c.*
	,case when k.starttime <= c.time_ini then c.time_ini
		else k.starttime
	end as time_ini_acotado
	,case when c.time_fin <= k.endtime then c.time_fin
		else k.endtime
	end as time_fin_acotado
	,case when k.starttime <= c.time_ini and c.time_fin <= k.endtime then c.duration						--Ini/Fin de la info dentro
		when c.time_ini <= k.starttime and k.endtime <= c.time_fin then k.duration							--Ini anterior y fin dentro, acotamos
		when c.time_ini <= k.starttime and c.time_fin <= k.endtime then DATEDIFF(ms,k.starttime,c.time_fin) --Ini/Fin de la info fuera pero conteniendolo, acotamos
		when k.starttime <= time_ini and k.endtime <= c.time_fin then DATEDIFF(ms,c.time_ini,k.endtime)		--Ini dentro pero fin posterior, acotamos
	end as duration_acotada
into _CQI_3G_duration_acotada_all
from  testinfo t
	inner join _intervalos_all k 
		on t.sessionid=k.sessionid and t.testid=k.testid
	left join _CQI_3G_all c
		on t.sessionid=c.sessionid and t.testid=c.testid
			and k.starttime < c.time_fin
			and k.endtime > c.time_ini
where t.valid=1
	and t.testid > @maxTestid

-------------------------------------------------------------------------------------------------------------------------------------
-- 3G: Calculo de CQI / Ack / Nack /Dtx / HS BLER / Dual Carrier desde la tabla de sistema
-------------------------------------------------------------------------------------------------------------------------------------
--Info acotada al momento de la descarga, subida, navegacion y reproduccion
exec sp_lcc_dropifexists '_CQI_3G_acotado'			
select 
	h.sessionid, h.TestId,
	sum(1.0*h.sumCQI)/NULLIF(sum(h.NumCQI),0) AS CQI,
	sum(1.0*h.SumCQI_C0)/case when sum(h.NumCQI_C0)=0 then 1 else sum(h.NumCQI_C0)end AS CQI_c0,
	sum(1.0*h.SumCQI_C1)/case when sum(h.NumCQI_C1)=0 then 1 else sum(h.NumCQI_C1)end AS CQI_c1,
	case when sum(h.numsamples)=0 then 0.0 else 1.0*sum(h.numack)/sum(h.NumSamples) end as NumAck_DL,
	case when sum(h.numsamples)=0 then 0.0 else 1.0*sum(h.numNack)/sum(h.NumSamples) end as NumNack_DL,
	case when sum(h.numsamples)=0 then 0.0 else 1.0*sum(h.numDTX)/sum(h.numSamples) end as numDtx_DL,
	sum(h.numack) as ackNum,	sum(h.numNack) as nackNum,	sum(h.numDTX) as dtxnum,	sum(h.numsamples) as numsamples,
	AVG(h.BLER) as avgBLER,	1.0*SUM(h.EnabledDualCarrier)/SUM(1) as DualCarrier_use,
	1.0*sum(case when (h.technology='UMTS 2100') then h.EnabledDualCarrier else 0.0 end)/SUM(1) as DualCarrier_use_U2100,
	1.0*sum(case when (h.technology='UMTS 900') then h.EnabledDualCarrier else 0.0 end)/SUM(1) as DualCarrier_use_U900,

	1.0*sum(case when band like 'UMTS900' then sumCQI end)/NULLIF(sum(case when band like 'UMTS900' then NumCQI end),0)  as 'CQI_UMTS900',
	1.0*sum(case when band like 'UMTS2100' then sumCQI end)/NULLIF(sum(case when band like 'UMTS2100' then NumCQI end),0) as 'CQI_UMTS2100'

into _CQI_3G_acotado	
from _CQI_3G_duration_acotada h
group by h.sessionid,h.TestId

--Info acotada al momento de la descarga, subida, navegacion y reproduccion, teniendo en cuenta el acceso:
exec sp_lcc_dropifexists '_CQI_3G_acotado_acc'			
select 
	h.sessionid, h.TestId,
	sum(1.0*h.sumCQI)/NULLIF(sum(h.NumCQI),0) AS CQI,
	sum(1.0*h.SumCQI_C0)/case when sum(h.NumCQI_C0)=0 then 1 else sum(h.NumCQI_C0)end AS CQI_c0,
	sum(1.0*h.SumCQI_C1)/case when sum(h.NumCQI_C1)=0 then 1 else sum(h.NumCQI_C1)end AS CQI_c1,
	case when sum(h.numsamples)=0 then 0.0 else 1.0*sum(h.numack)/sum(h.NumSamples) end as NumAck_DL,
	case when sum(h.numsamples)=0 then 0.0 else 1.0*sum(h.numNack)/sum(h.NumSamples) end as NumNack_DL,
	case when sum(h.numsamples)=0 then 0.0 else 1.0*sum(h.numDTX)/sum(h.numSamples) end as numDtx_DL,
	sum(h.numack) as ackNum,	sum(h.numNack) as nackNum,	sum(h.numDTX) as dtxnum,	sum(h.numsamples) as numsamples,
	AVG(h.BLER) as avgBLER,	1.0*SUM(h.EnabledDualCarrier)/SUM(1) as DualCarrier_use,
	1.0*sum(case when (h.technology='UMTS 2100') then h.EnabledDualCarrier else 0.0 end)/SUM(1) as DualCarrier_use_U2100,
	1.0*sum(case when (h.technology='UMTS 900') then h.EnabledDualCarrier else 0.0 end)/SUM(1) as DualCarrier_use_U900,

	1.0*sum(case when band like 'UMTS900' then sumCQI end)/NULLIF(sum(case when band like 'UMTS900' then NumCQI end),0)  as 'CQI_UMTS900',
	1.0*sum(case when band like 'UMTS2100' then sumCQI end)/NULLIF(sum(case when band like 'UMTS2100' then NumCQI end),0) as 'CQI_UMTS2100'

into _CQI_3G_acotado_acc
from _CQI_3G_duration_acotada_all h
group by h.sessionid,h.TestId


------------------------------ (6) HSSCH_Use 3G ------------------------------
--select 'Se crean las tablas intermedias: (6) HSSCH_Use 3G' info
----------------
exec sp_lcc_dropifexists '_SCCH_USE_3G'			
select 
	sessionid, testid, 1.0*sum(numScchValid)/nullif(sum(numscchdecodeattempted),0) as hscch_use 
into _SCCH_USE_3G
from HSDPAScch
where testId > @maxTestid	
group by sessionid, testid


------------------------------ (7) HARQ_PROCESSES 3G  ------------------------------
--select 'Se crean las tablas intermedias: (7) HARQ_PROCESSES 3G' info			
----------------
exec sp_lcc_dropifexists '_HARQ'			
select 
	sessionid, testid, AVG(NumHarqProc) as NumHarqProc_avg 
into _HARQ	
from HSDPAHarq
where testId > @maxTestid	
group by sessionid, testid


------------------------------ (8) Serving Grant, TTI, HappyRate, DTX, TBs y Retransmisiones 3G ------------------------------
--select 'Se crean las tablas intermedias: (8) Serving Grant, TTI, HappyRate, DTX, TBs y Retransmisiones 3G' info			
----------------

exec sp_lcc_dropifexists '_ULMAC'			
select 
	sessionid, TestId, 
	AVG(AverageSG) as AverageSG, 
	SUM(case when TTI=10 then 1 end) as sumTTI_10ms, 	SUM(case when TTI=2 then 1 end) as sumTTI_2ms, 
	SUM(case when TTI in (2,10) then 1 end) as sumTTI_ms, 		
	AVG(HappyRate) as AverageHappyRate, 	max(HappyRate) as maxHappyRate,
	AVG(DTXRate) as AverageDTXRate, 	AVG(convert(bigint,AverageTBsize)) as AverageTBsize,
	AVG(RetransRate) as avgRetransRate
into _ULMAC
from lcc_Physical_Info_Table 
where [Info about]='3G' and Direction='Uplink'
	and testId > @maxTestid	
group by testid, sessionid		

------------------------------ (9) Spreading Factor ------------------------------
--select 'Se crean las tablas intermedias: (9) Spreading Factor' info			
---------------- 
exec sp_lcc_dropifexists '_tSF'			
select 
	sessionid, TestId, 
	SUM(DurationSF42) as sumDurationSF42,			-- duracion 2*SF4 activo
	sum(DurationSF22) as sumDurationSF22,			-- duracion 2*SF2 activo
	SUM(DurationSF4) as sumDurationSF4,						-- duracion SF4 activo			
	SUM(DurationSF22andSF42) as sumDurationSF22andSF42,		-- duracion 2*SF4+2*SF2
	SUM(isnull(DurationSF42,0)+ isnull(DurationSF22,0)+ isnull(DurationSF4,0)+ isnull(DurationSF22andSF42,0)) as sumDurationALL
into _tSF	
from HSUPASpreadingFactor
where testId > @maxTestid	
group by testid, sessionid	

---------------- 
exec sp_lcc_dropifexists '_SF'			
select 
	tes.SessionId, hsu.TestId, 
	1.0 * hsu.sumDurationSF42 / NULLIF(hsu.sumDurationALL, 0) * 100 as PercentSF42,
	1.0 * hsu.sumDurationSF22 / NULLIF(hsu.sumDurationALL, 0) * 100 as PercentSF22,
	1.0 * hsu.sumDurationSF4 / NULLIF(hsu.sumDurationALL, 0) * 100 as PercentSF4,
	1.0 * hsu.sumDurationSF22andSF42 / NULLIF(hsu.sumDurationALL, 0) * 100 as PercentSF22andSF42
into _SF
from
	_tSF hsu, TestInfo tes 
where
	tes.TestId = hsu.TestId	and tes.SessionId=hsu.SessionId

------------------------------ (10) SHO 3G	------------------------------	
--select 'Se crean las tablas intermedias: (10) SHO 3G' info			
----------------
exec sp_lcc_dropifexists '_SHOs'			
select  
	sessionid, testid,
	1.0*(SUM(case when (HoStatus like '%Active Set Update%' Or HoStatus like '%ActiveSetUpdate%') then 1 else 0 end)
		/SUM(1)) as 'percSHO'
into _SHOs
from HandoverInfo
where testId > @maxTestid	
group by SessionId, TestId

------------------------------ (11) UL Interferences 3G------------------------------
--select 'Se crean las tablas intermedias: (11) UL Interferences 3G' info			
----------------
exec sp_lcc_dropifexists '_UL_Int'			
select sessionid, testid,
	nullif(avg (cast (dbo.SQUMTSKeyValue(Msg, LogChanType, msgType,'ul_Interference') as float)),0) as UL_Interference
into _UL_Int
from WCDMARRCMessages
where msgType like 'SysInfoType7' 
	and TestId > @maxTestid
group by sessionid, testid

------------------------------ (12)	TABLAS INTERMEDIAS RRC State para Latencias:  En TEORIA no lo piden desde GLOBAL ------------------------------
--select 'Se crean las tablas intermedias: (12)	TABLAS INTERMEDIAS RRC State para Latencias' info	
----------------
exec sp_lcc_dropifexists '_tempStateRCC'		
select SessionId, MsgTime, RRCState, 
	case when RRCState =0 then	'Disconnected'
		when RRCState = 1 then	'Connecting'
		when RRCState = 2 then	'CELL FACH'
		when RRCState = 3 then	'CELL DCH'
		when RRCState = 4 then	'CELL PCH'
		when RRCState = 5 then	'URA PCH'
	end as 'RRCState_Desc',
	ROW_NUMBER() over (PARTITION by SessionId order by MsgTime) as id
into _tempStateRCC
from WCDMARRCState
where SessionId >= @minSessionid

----------------
exec sp_lcc_dropifexists '_stateRCC'		
select ini.SessionId, ini.MsgTime as time_ini,
	isnull(fin.MsgTime,DATEADD(ms, s.duration ,s.startTime)) as time_fin, ini.RRCState, 
	ini.RRCState_Desc, ini.id
into _stateRCC
from _tempStateRCC ini 
	inner join sessions s
	on (ini.sessionid = s.sessionid)
	left join _tempStateRCC fin
	on (ini.sessionid = fin.sessionid
		and ini.id = fin.id -1)
order by 1, 2


------------------------------ (13) Throughput, Data Transferred, BLER RLC	3G ------------------------------
--select 'Se crean las tablas intermedias: (13) Throughput, Data Transferred, BLER RLC 3G' info	
----------------
exec sp_lcc_dropifexists '_THPUT_RLC'			
select 	
	t.SessionId, t.TestId, 
	Avg(t.DLThrpt) as 'AvgRLCDLThrpt',		max(t.DLThrpt) as 'maxRLCDLThrpt',
	Sum(t.DLkbit) as 'SumRLCDLkbit',		Avg(t.ULThrpt) as 'AvgRLCULThrpt',
	max(t.ULThrpt) as 'maxRLCULThrpt',		Sum(t.ULkbit) as 'SumRLCULkbit',
	AVG(t.ULBLER_RLC) as 'AvgRLCULBLER',	AVG(t.DLBLER_RLC) as 'AvgRLCDLBLER' 
	 
into _THPUT_RLC	
from 
	(Select
		s.SessionId, s.TestId, s.MsgTime, s.PosId, s.NetworkId,
		Case when s.Direction=1 Then s.SDUThPut else NULL end as ULThrpt,
		Case when s.Direction=0 Then s.SDUThPut else NULL end as DLThrpt,
		s.duration,s.Direction,
		Case when s.Direction=1 Then s.numSDUBytes*0.008 else NULL end as ULkbit,
		Case when s.Direction=0 Then s.numSDUBytes*0.008 else NULL end as DLkbit,
		numPDUGood, numPDUError, numPDUNAK,
		Case when s.Direction=1 Then
			case when (numPDUGood+numPDUError)>0 then (1.0*numPDUError/(numPDUGood+numPDUError)) else null end 
		end as ULBLER_RLC,
		Case when s.Direction=0 Then
			case when (numPDUGood+numPDUError)>0 then (1.0*numPDUError/(numPDUGood+numPDUError)) else null end 
		end as DLBLER_RLC
		
	From
		WCDMARLCStatistics s
	where s.testId > @maxTestid
	) t 
group by t.SessionId, t.TestId
order by t.SessionId, t.TestId


------------------------------ (14) Throughput Fisico, Data Transferred, Transer Time, Errores, Host, Fixed Duration 4G/3G	------------------------------
--select 'Se crean las tablas intermedias: (14) Throughput Fisico, Data Transferred, Transer Time, Errores, Host, Fixed Duration 4G/3G' info	
----------------
exec sp_lcc_dropifexists '_THPUT'			
select 
	ph.Direction,
	ph.sessionid, ph.testid, 
	AVG(8.0*ph.Throughput)  as avgThput_kbps,		max(8.0*ph.Throughput)  as maxThput_kbps,	min(8.0*ph.Throughput)  as minThput_kbps,
	MAX(ph.BytesTransferred*8.0) as 'DataTransferred',		-- es la suma de las carriers
	AVG((ph.BytesTransferred*8.0)/NULLIF(8000.0*ph.Throughput,0)) as 'TransferTime',	-- es la media de las carriers
	e.ErrorCode as 'ErrorCode',	e.msg as 'ErrorMsg', e.RemoteFilename, e.LocalFilename, e.operation, e.host,	e.FixedDuration,
	
	-- PCC:
	AVG(8.0*ph.Throughput_PCC)  as avgThput_kbps_PCC,	max(8.0*ph.Throughput_PCC)  as maxThput_kbps_PCC,	min(8.0*ph.Throughput_PCC)  as minThput_kbps_PCC,
	sum(ph.BytesTransferred_PCC*8.0) as 'DataTransferred_PCC', 
	AVG((ph.BytesTransferred_PCC*8.0)/NULLIF(8000.0*ph.Throughput_PCC,0)) as 'TransferTime_PCC',
	
	-- SCC1:
	AVG(8.0*ph.Throughput_SCC1)  as avgThput_kbps_SCC1,	max(8.0*ph.Throughput_SCC1)  as maxThput_kbps_SCC1,	min(8.0*ph.Throughput_SCC1)  as minThput_kbps_SCC1,
	sum(ph.BytesTransferred_SCC1*8.0) as 'DataTransferred_SCC1', 
	AVG((ph.BytesTransferred_SCC1*8.0)/NULLIF(8000.0*ph.Throughput_SCC1,0)) as 'TransferTime_SCC1',

	-- SCC2:
	AVG(8.0*ph.Throughput_SCC2)  as avgThput_kbps_SCC2,	max(8.0*ph.Throughput_SCC2)  as maxThput_kbps_SCC2,	min(8.0*ph.Throughput_SCC2)  as minThput_kbps_SCC2,
	sum(ph.BytesTransferred_SCC2*8.0) as 'DataTransferred_SCC2', 
	AVG((ph.BytesTransferred_SCC2*8.0)/NULLIF(8000.0*ph.Throughput_SCC2,0)) as 'TransferTime_SCC2'
into _THPUT
from lcc_Physical_Info_Table ph
	LEFT OUTER JOIN
		(select r.sessionid, r.testid, r.ErrorCode, e.*, tp.RemoteFilename, tp.LocalFilename, tp.operation, tp.host, tp.FixedDuration
			from ResultsHTTPTransferTest r
				LEFT OUTER JOIN ResultsHTTPTransferParameters tp on (r.TestId=tp.TestId and r.SessionId=tp.SessionId)
				LEFT OUTER JOIN ErrorCodes e on (e.code = r.ErrorCode)
			where LastBlock=1	-- cogemos el ultimo bloque ya que es el que contiene la info del final de test	
				and r.testId > @maxTestid
		) e on e.SessionId=ph.sessionid and e.TestId=ph.testid
where ph.testid > @maxTestid	

group by ph.Direction, ph.sessionid, ph.testid, 
		e.ErrorCode, e.msg, e.RemoteFilename, e.LocalFilename, 
		e.operation, e.host, e.FixedDuration


------------------------------ (15)	Nuevo cálcuco IP Access Service ------------------------------
--select 'Se crean las tablas intermedias: (15)	Calculo IP Access Service' info	
-- Para el KPIID 10401/02
--	El tiempo de acceso, se calcula de forma manual - CR creado a tal efecto.
--	Issue: 470007 

----------------
-- CREAMOS LA TABLA CON TODOS LOS GETs Y PUTs, DL Y UL , NC Y CE 
exec sp_lcc_dropifexists '_lcc_gets'
select 
	testid as 'testid_get',msgtime as 'msgtime_get',protocol as 'protocol_get', 
	msg as 'msg_get',src as 'src_get',dst as 'dst_get'
into _lcc_gets
from [dbo].[MsgEthereal]
where (msg like '%GET /%/[3-5]%m% HTTP/1.1%' or msg like '%GET /[0-9]% HTTP/1.1%'
	OR msg like '%PUT /%/[1-5]%m% HTTP/1.1%' or msg like '%PUT /[0-9]% HTTP/1.1%' or msg like '%PUT /prueba% HTTP/1.1%')
	and testId > @maxTestid	
group by testid, msgtime,protocol, msg,src,dst

----------------
-- CREAMOS LA TABLA CON TODOS LOS 200 OK PARA DOWNLINK
exec sp_lcc_dropifexists '_lcc_200'
select 
	m.testid as 'testid_200',m.msgtime as 'msgtime_200',m.protocol as 'protocol_200',
	m.msg as 'msg_200',m.src as 'src_200',m.dst as 'dst_200'
       --row_number() over(partition by testid order by msg, msgtime desc) as 'id_200'
into _lcc_200
from [dbo].[MsgEthereal] m, Testinfo t
where m.testid = t.testid
	and m.msg like '%200 OK%'
	and t.direction <> 'Uplink'					-- Filtramos para evitar 200OK en sessiones Uplink
	and m.testId > @maxTestid	
group by m.testid, m.msgtime,m.protocol, m.msg,m.src,m.dst

----------------
-- TABLA RELACIÓN 80 SYN CON 200 OK DL/ 80 SYN CON PUT UL 
exec sp_lcc_dropifexists '_lcc_ip_service'
Select 
	testid_get,msgtime_get,protocol_get,msg_get,src_get,dst_get,Ip_Service,
	id_dif
into _lcc_ip_service
from
	(select t.*,m.testid as 'testid_80', m.msgtime as 'MsgTime_80',
		m.protocol as 'protocol_80',m.msg as 'msg_80', m.src as 'src_80',
		m.dst as 'dst_80',
		Datediff(ms,m.msgtime,t.msgtime_200) as 'Ip_Service',                --DIFERENCIA DE TIEMPO ENTRE 80 SYN Y 200OK
		row_number() over(partition by m.testid order by Datediff(ms,m.msgtime,t.msgtime_200) desc) as 'id_dif'		-- La ordenacion es DESC para quedarnos con el primer 80 SYN del terminal, el mas alejado del 200OK
	from [dbo].[MsgEthereal] m 
	left outer join 
		(select *
		from(
			select *, 
				row_number() over(partition by g.testid_get order by Datediff(ms,g.msgtime_get,l.msgtime_200) asc) -- La ordenación es ascendente para quedarnos con el 200OK más cercano al GET
				 as 'id_dif_200',                                           --Ordenamos según la diferencia de tiempo entre el get y el 200 ok
				Datediff(ms,g.msgtime_get,l.msgtime_200) as 'dif_tiempo'
			from _lcc_gets g left outer join _lcc_200 l on (g.src_get = l.dst_200 and g.dst_get = l.src_200)
		where g.testid_get = l.testid_200) k

	where k.id_dif_200 = 1) t on (t.src_200 = m.dst and t.dst_200=m.src)
	where m.msg like '%80%[[SYN]]%' and t.testid_200 = m.testid and t.msgtime_get > = m.msgtime) th
where th.id_dif = 1 

union all

select 
	testid_get,msgtime_get,protocol_get,msg_get,src_get,dst_get, Ip_Service,
	id_dif_80
from (
	Select *, Datediff(ms,m.msgtime,l.msgtime_get) as 'Ip_Service',
		row_number() over(partition by m.testid order by Datediff(ms,m.msgtime,l.msgtime_get) desc) as 'id_dif_80'			-- La ordenacion es DESC para quedarnos con el primer 80 SYN del terminal, el mas alejado del 200OK
	from  [dbo].[MsgEthereal] m 
				left outer join _lcc_gets l on (l.src_get=m.src and l.dst_get = m.dst)
	where m.msg like '%80%[[SYN]]%' and l.msgtime_get > = m.msgtime and l.msg_get like '%put%' and
	m.testid = l.testid_get) u

where u.id_dif_80 = 1 


------------------------------ (16) Throughput, Bytes Transferred, Errors y Times 4G/3G - HTTP TRANSFER ------------------------------
--select 'Se crean las tablas intermedias: (16) Throughput, Bytes Transferred, Errors y Times 4G/3G - HTTP TRANSFER' info	
----------------
-- Forma antigua de calcular las cosas sin KPIID:
--	- Se calcula para mantener las columnas de _nu ya que los test fallidos pierden la info correspondiente y puede interesar saber los resultados
--	- No se realizaran los UPDATES antiguos
exec sp_lcc_dropifexists '_THPUT_Transf'			
select 	
	tt.SessionId, tt.TestId, tt.PosId, tt.NetworkId,			
	NULLIF(tt.BytesTransferred, 0) as 'DataTransferred_nu',	

	NULLIF(tt.Duration*0.001, 0) as 'SessionTime_nu',	-- hay que añadirle el tomepo del DNS, se hace despues de quedarnos con los valores validos	

	-- @FLA: se añaden case para evitar ipaccesstime mayores que el sessiontime	
	case when ISNULL(ipt.Ip_Service*0.001,0)<	ISNULL(tt.Duration*0.001,0)  then	
	    NULLIF(ISNULL(tt.Duration*0.001,0) - ISNULL(ipt.Ip_Service*0.001,0), 0)  
	else NULLIF(ISNULL(tt.Duration*0.001,0), 0) end	as'TransferTime_nu',	

	case when ISNULL(ipt.Ip_Service*0.001,0)<	ISNULL(tt.Duration*0.001,0)  then		
	    NULLIF(tt.BytesTransferred*0.008, 0) / NULLIF(ISNULL(tt.Duration*0.001,0) - ISNULL(ipt.Ip_Service*0.001,0), 0) 						
	else NULLIF(tt.BytesTransferred*0.008, 0) / NULLIF(ISNULL(tt.Duration*0.001,0), 0) 	end as 'ThputApp_nu',						
					
	NULLIF(ipt.Ip_Service*0.001, 0) as 'IPAccessTime_nu'						

into _THPUT_Transf
From ResultsHTTPTransferTest tt 
		LEFT OUTER JOIN _lcc_ip_service ipt on (ipt.Testid_get = tt.Testid)

where tt.testId > @maxTestid and
	tt.lastBlock=1	
	
--CAC 10/08/2017: se incorpora información análoga para test de NC
exec sp_lcc_dropifexists '_THPUT_Transf_NC'			
select 	
	tt.SessionId, tt.TestId, tt.PosId, tt.NetworkId,			
	NULLIF(tt.BytesTransferredGet, 0) as 'DataTransferred_nu_DL',
	NULLIF(tt.BytesTransferredPut, 0) as 'DataTransferred_nu_UL',

	NULLIF(tt.Duration*0.001, 0) as 'SessionTime_nu',	-- hay que añadirle el tomepo del DNS, se hace despues de quedarnos con los valores validos	

	-- @FLA: se añaden case para evitar ipaccesstime mayores que el sessiontime	
	case when ISNULL(ipt.Ip_Service*0.001,0)<	ISNULL(tt.Duration*0.001,0)  then	
	    NULLIF(ISNULL(tt.Duration*0.001,0) - ISNULL(ipt.Ip_Service*0.001,0), 0)  
	else NULLIF(ISNULL(tt.Duration*0.001,0), 0) end	as'TransferTime_nu',	

	case when ISNULL(ipt.Ip_Service*0.001,0)<	ISNULL(tt.Duration*0.001,0)  then		
	    NULLIF(tt.BytesTransferredGet*0.008, 0) / NULLIF(ISNULL(tt.Duration*0.001,0) - ISNULL(ipt.Ip_Service*0.001,0), 0) 						
	else NULLIF(tt.BytesTransferredGet*0.008, 0) / NULLIF(ISNULL(tt.Duration*0.001,0), 0) 	end as 'ThputApp_nu_DL',						
	
	case when ISNULL(ipt.Ip_Service*0.001,0)<	ISNULL(tt.Duration*0.001,0)  then		
	    NULLIF(tt.BytesTransferredPut*0.008, 0) / NULLIF(ISNULL(tt.Duration*0.001,0) - ISNULL(ipt.Ip_Service*0.001,0), 0) 						
	else NULLIF(tt.BytesTransferredPut*0.008, 0) / NULLIF(ISNULL(tt.Duration*0.001,0), 0) 	end as 'ThputApp_nu_UL',
					
	NULLIF(ipt.Ip_Service*0.001, 0) as 'IPAccessTime_nu'						

into _THPUT_Transf_NC
From ResultsCapacityTest tt 
		LEFT OUTER JOIN _lcc_ip_service ipt on (ipt.Testid_get = tt.Testid)

where tt.testId > @maxTestid and
	tt.lastBlock=1	

--********************************************************************************************************************
--***************************************** Nuevos calculos basados en KPIID *****************************************
--********************************************************************************************************************

exec sp_lcc_dropifexists '_ETSIYouTubeKPIs'
select
	v.sessionid, v.testid, 
	case when B5.errorcode=0 then cast(B5.value1 as varchar) + 'p' end as [Image Resolution],
	v.[IP Service Access],
	v.[IP Service Access Time [s]]],
	r.msgtime as 'Block Time',  --Tiempo de bloqueo para los fallos en el acceso

	--20170523: @ERC - se añade el IPServiceAccesTime (kpiid 10625) para obtener este campo - igual que los Italianos
	(v.[Video Play Start Time [s]]]+v.[IP Service Access Time [s]]]) as 'Time To First Image [s]',

	-- De momento se desactiva el B7 hasta confirmación de Global + VFE
	--B7.duration/1000.0 as 'Time To First Image [s]',
	
	v.[Minimum freeze duration [ms]]],
	v.[Maximum duration of single freeze [s]]],
	v.[Maximum duration of all freezes [s]]],
	v.[Maximum number of freezes],

	v.[Video Freeze Occurrences] as [Video Freeze Occurrences > 120ms],
	ISNULL(f.NumFreezings_300,0) as [Video Freeze Occurrences > 300ms],		-- Este es el nuestro

	v.[Video Freezing Impairment] as [Video Freezing Impairment > 120ms],
	case when ISNULL(f.NumFreezings_300,0)>0 then 'Freezings' 
		else 'No Freezings' end as [Video Freezing Impairment > 300ms],		-- Este es el nuestro
		
	v.[Accumulated Video Freezing Duration [s]]] as [Accumulated Video Freezing Duration [s]] > 120ms],
	0.001*f.AccFreezingTime_300 as [Accumulated Video Freezing Duration [s]] > 300ms],

	v.[Video Maximum Freezing Duration [s]]] as [Video Maximum Freezing Duration [s]] > 120ms],
	0.001*f.MaxFreezingTime_300 as [Video Maximum Freezing Duration [s]] > 300ms],

	0.001*f.AvgFreezingTime_300 as [Video Average Freezing Duration [s]] > 300ms],

	v.[Video Freezing Time Proportion [%]]] as [Video Freezing Time Proportion [%]] as >120ms],
	null as [Video Freezing Time Proportion [%]] as >300ms],
	
	case when B6.errorcode=0 then B6.value1 end as VMOS,

	--DGP 16/03/2016: Se cambia la forma de calcular los campos para tener en cuenta como fallo los nulls
	-- Clasificacion de los posibles fallos
	case when B1.errorcode=0 then 'Successful'
		 else B1.Value4
		end  as 'status_B1',

	case when B2.errorcode=0 then 'Successful'
		 else B2.Value4
		end  as 'status_B2',

	case when B3.errorcode=0 then 'Successful'
		 else B3.Value4
		end  as 'status_B3',

	case when B4.errorcode=0 then B4.Value3	end  as 'status_B4',

		kpi10620.StartTime as 'StartIPserviceAccess',
		ytbPlayer.AccessDuration as 'Duration10620',		--Player IP Service Access Time
		ytbPlayer.DownloadDuration as 'Duration20620',		--Player Download Time

		--Del KPI 20620 al KPI10621 hay un salto de tiempo que recuperamos con el KPI10625
		v.[IP Service Access Time [s]]] as 'Duration10625',		--IP Service Access Time
		ytbVideoPlay.ReproductionDelay as 'Duration30621',		--Video Reproduction start Delay

		--Video PlayOut Duration: Desde el Start of Video Transfer hasta el final (End of vedo playback)
		kpi20621.Duration as 'Duration20621',

		--DGP 16/03/2016: Se cambia la forma de calcular los campos para tener en cuenta como fallo los nulls
		--case when isnull(kpi20621.ErrorCode,0)=0 then 'Successful' else 'Failed'  end as 'status20621'
		case when (kpi20621.ErrorCode <> 0 or kpi20621.ErrorCode is null) then 'Failed' else 'Successful'  end as 'status20621'

into _ETSIYouTubeKPIs
from testinfo t, vETSIYouTubeKPIs v
		-- Tabla ResultsVideoStream, tiene el momento del Fail - Block Time
		LEFT OUTER JOIN ResultsVideoStream r on (v.TestId=r.TestId and v.sessionid=r.SessionId)
		
		-- En la vista de SQ, el tiempo minimo para las interrupciones es de 120ms, cuando nos piden 300ms:
		LEFT OUTER JOIN (Select sessionid, testid, 
							sum(case when duration>= @min_Interrupt_Duration then 1 else 0 end) as NumFreezings_300,
							avg(case when duration>= @min_Interrupt_Duration then Duration*1.0 else null end)  as AvgFreezingTime_300,
							max(case when duration>= @min_Interrupt_Duration then Duration*1.0 else null end)  as MaxFreezingTime_300,
							sum(case when duration>= @min_Interrupt_Duration then Duration*1.0 else 0 end)  as AccFreezingTime_300
						 from  ResultsVQFreezings group by sessionid, testid) f on v.sessionid=f.sessionid and v.TestId=f.TestId 
		LEFT OUTER JOIN vETSIYouTubePlayer ytbPlayer	on (v.SessionId=ytbPlayer.SessionId and v.TestId=ytbPlayer.testid)
		LEFT OUTER JOIN vETSIYouTubeStream ytbVideoPlay	on (v.SessionId=ytbVideoPlay.SessionId and v.TestId=ytbVideoPlay.testid)
		LEFT OUTER JOIN ResultsKPI kpi10620 on (v.TestId = kpi10620.TestId and kpi10620.KPIId = @Player_IPServiceAccess_Time)
		LEFT OUTER JOIN ResultsKPI kpi20621 on (v.TestId = kpi20621.TestId and kpi20621.KPIId = @Video_Transfer)
		
		--Desarrollo de nuevos KPIs ITALIA
		LEFT OUTER JOIN ResultsKPI B1 on (v.TestId = B1.TestId and B1.KPIId = @Service_Access_Success_Ratio_B1)
		LEFT OUTER JOIN ResultsKPI B2 on (v.TestId = B2.TestId and B2.KPIId = @Reproductions_Wo_Interruptions_B2)
		LEFT OUTER JOIN ResultsKPI B3 on (v.TestId = B3.TestId and B3.KPIId = @SuccessFul_Video_Download_B3)
		LEFT OUTER JOIN ResultsKPI B4 on (v.TestId = B4.TestId and B4.KPIId = @Youtube_HD_Status_B4)
		LEFT OUTER JOIN ResultsKPI B5 on (v.TestId = B5.TestId and B5.KPIId = @Youtube_Average_Resolution_B5)
		LEFT OUTER JOIN ResultsKPI B6 on (v.TestId = B6.TestId and B6.KPIId = @Youtube_Visual_Quality_B6)
		LEFT OUTER JOIN ResultsKPI B7 on (v.TestId = B7.TestId and B7.KPIId = @Youtube_Time_To_First_Image)

where	v.TestId > @maxTestid and
	t.testid=v.testid and t.valid=1 


-- select * from _ETSIYouTubeKPIs
------------------------------------------------------------
-- @ERC: 20170401 - Nuevos campos de Youtube:
------------------------------------------------------------
-- Ordenamos y nos quedamos con la info relevante de las tablas del sistema:
-- declare @maxTestid as int=35465
exec sp_lcc_dropifexists '_ResultsVq06TimeDom_ord'
SELECT 
	ROW_NUMBER() over (partition by dini.sessionid, dini.testid order by dini.msgid asc) as verResID_ini,
	ROW_NUMBER() over (partition by dini.sessionid, dini.testid order by dini.msgid desc) as verResID_fin,
	ROW_NUMBER() over (partition by dini.sessionid, dini.testid, dini.VerResolution order by dini.msgid asc) as verResID,
	case when dini.testid=dfin.testid and dini.verResolution=dfin.verresolution then 0 else 1 end as changeRes,		-- campo para saber la info del primer cambio de resolucion
	dini.*
into _ResultsVq06TimeDom_ord
FROM testinfo t, ResultsVq06TimeDom dini, ResultsVq06TimeDom dfin
where t.testid>@maxTestid
	and dini.testid=t.testid and t.valid=1
	and dini.testid=dfin.testid and dini.msgid=dfin.msgid+1

----------------------------------------------
-- Cogemos la info a partir del ultimo testid, y nos ahorramos meter el filtro en todos los left outer join de despues:
-- declare @maxTestid as int=35465
exec sp_lcc_dropifexists '_ResultsVQ08ClipAvg'
select r.* 
into _ResultsVQ08ClipAvg 
from ResultsVQ08ClipAvg r, testinfo t
where  t.testid>@maxTestid
	and r.testid=t.testid and t.valid=1

----------------------------------------------
-- Cogemos la info a partir del ultimo testid, y nos ahorramos meter el filtro en todos los left outer join de despues:
-- declare @maxTestid as int=35465
exec sp_lcc_dropifexists '_ResultsVideoStreamAvg'
select r.* 
into _ResultsVideoStreamAvg 
from ResultsVideoStreamAvg r, testinfo t
where  t.testid>@maxTestid
	and r.testid=t.testid and t.valid=1
	

----------------------
-- Tabla base, inicialmente nos quedamos con la resolucion inicial y final por test - SOLO CUENTAN LOS TEST NO FALLIDOS DE YTB!!
-- declare @maxTestid as int=35465
exec sp_lcc_dropifexists '_resolutionYTB' 
select 
	ini.sessionid, ini.testid, 
	ini.VerResolution as ini_Res,
	fin.VerResolution as fin_Res,
	d.duration
into _resolutionYTB
from _ResultsVq06TimeDom_ord ini		-- _ord ya esta flitrada por @maxtestid
	LEFT OUTER JOIN (----------------------
					 -- Resolucion final:
					select 
						sessionid, testid, VerResolution
					from _ResultsVq06TimeDom_ord
					where verResID_fin=1 
					) fin on ini.sessionid=fin.sessionid and ini.testid=fin.testid

	LEFT OUTER JOIN (----------------------
					 -- Duracion total:
					select 
						sessionid, testid, sum(deltatime) as duration
					from _ResultsVq06TimeDom_ord
					group by sessionid, testid
					) d on ini.sessionid=d.sessionid and ini.testid=d.testid
where ini.verResID_ini=1 
order by ini.sessionid, ini.testid


----------------------
-- Tabla intermedia final con la nueva info de las resoluciones:
exec sp_lcc_dropifexists '_vResolutionInfo'
select 
	t.sessionid, t.testid, 
	Res1.VerResolution as '1st Resolution',
	Res2.VerResolution as '2nd Resolution',
	f.FirstChangeFromInit,

	t.ini_Res as initialResolution, 
	t.fin_Res as finalResolution, 
	t.duration as Duration,

	vsAVG.TestQualityAvg as TestQualityAvg_B6,
	cAVG.TestQualityAvg as TestQualityAvg_Calc,

	d144p.VideoDuration as '144p-VideoDuration',
	vm144p.VMOSbyResol as '144p-VideoMOS',
	1.0*d144p.VideoDuration/nullif(t.duration,0) as '% 144p',

	d240p.VideoDuration as '240p-VideoDuration',
	vm240p.VMOSbyResol as '240p-VideoMOS',
	1.0*d240p.VideoDuration/nullif(t.duration,0) as '% 240p',

	d360p.VideoDuration as '360p-VideoDuration',
	vm360p.VMOSbyResol as '360p-VideoMOS',
	1.0*d360p.VideoDuration/nullif(t.duration,0) as '% 360p',

	d480p.VideoDuration as '480p-VideoDuration',
	vm480p.VMOSbyResol as '480p-VideoMOS',
	1.0*d480p.VideoDuration/nullif(t.duration,0) as '% 480p',

	d720p.VideoDuration as '720p-VideoDuration',
	vm720p.VMOSbyResol as '720p-VideoMOS',
	1.0*d720p.VideoDuration/nullif(t.duration,0) as '% 720p',

	d1080p.VideoDuration as '1080p-VideoDuration',
	vm1080p.VMOSbyResol as '1080p-VideoMOS',
	1.0*d1080p.VideoDuration/nullif(t.duration,0) as '% 1080p'

into _vResolutionInfo

from _resolutionYTB t	-- Tabla inicial con los testid y las resoluciones ini/fin

------------------------------
-- Primer cambio de resolucion:
	LEFT OUTER JOIN (select t.sessionid, t.testid, t.degtime as FirstChangeFromInit, ROW_NUMBER() over (partition by t.sessionid, t.testid order by t.verResID_ini asc) as idRes
					from _ResultsVq06TimeDom_ord t		
					where changeRes=1 and verResID=1 
					) f on f.testid=t.testid and idRes=1

------------------------------
-- VMOS por cada tipo de resolucion		-		se tienen en cuenta: 144p, 240p, 360p, 720p, 1080p:
	LEFT OUTER JOIN (select testid, verResolution, avg(visualQuality) as VMOSbyResol
					from _ResultsVQ08ClipAvg o8, ClipVideoInfo c
					where o8.clipid=c.clipid and verResolution=144
					group by testid, verResolution) vm144p on vm144p.testid=t.testid

	LEFT OUTER JOIN (select testid, verResolution, avg(visualQuality) as VMOSbyResol
					from _ResultsVQ08ClipAvg o8, ClipVideoInfo c
					where o8.clipid=c.clipid and verResolution=240
					group by testid, verResolution) vm240p on vm240p.testid=t.testid

	LEFT OUTER JOIN (select testid, verResolution, avg(visualQuality) as VMOSbyResol
					from _ResultsVQ08ClipAvg o8, ClipVideoInfo c
					where o8.clipid=c.clipid and verResolution=360
					group by testid, verResolution) vm360p on vm360p.testid=t.testid

	LEFT OUTER JOIN (select testid, verResolution, avg(visualQuality) as VMOSbyResol
					from _ResultsVQ08ClipAvg o8, ClipVideoInfo c
					where o8.clipid=c.clipid and verResolution=480
					group by testid, verResolution) vm480p on vm480p.testid=t.testid

	LEFT OUTER JOIN (select testid, verResolution, avg(visualQuality) as VMOSbyResol
					from _ResultsVQ08ClipAvg o8, ClipVideoInfo c
					where o8.clipid=c.clipid and verResolution=720
					group by testid, verResolution) vm720p on vm720p.testid=t.testid

	LEFT OUTER JOIN (select testid, verResolution, avg(visualQuality) as VMOSbyResol
					from _ResultsVQ08ClipAvg o8, ClipVideoInfo c
					where o8.clipid=c.clipid and verResolution=1080
					group by testid, verResolution) vm1080p on vm1080p.testid=t.testid

-- Valores medio de VMOS calculados	-	B6 reportado (no se usara) y el calculado con los de las resoluciones
--									-	Aqui hay discrepancias, pero parece ser cosa de los calculos de SQ de los decimales, que en las resoluciones deja valor final con un decimal solo
	LEFT OUTER JOIN (select sessionid, testid, TestQualityAvg 
					from _ResultsVideoStreamAvg) vsAVG on vsAVG.testid=t.testid 

	LEFT OUTER JOIN (select testid, avg(visualQuality) as TestQualityAvg
					from _ResultsVQ08ClipAvg o8, ClipVideoInfo c
					where o8.clipid=c.clipid 
					group by testid) cAVG on cAVG.testid=t.testid 

------------------------------
-- Duraciones [s y %] por cada tipo de resolucion		-		se tienen en cuenta: 144p, 240p, 360p, 720p, 1080p:
	LEFT OUTER JOIN (select	d.sessionid, d.testid, CASE WHEN SUM(DeltaTime) > 0 THEN SUM(DeltaTime) ELSE NULL END as VideoDuration	-- VideoDuration tal y como se calcula en el cu italiano
					FROM _ResultsVq06TimeDom_ord d, testinfo t
					where d.testid=t.testid and t.valid=1	and VerResolution=144
					group by d.sessionid, d.testid)	d144p on d144p.testid=t.testid 

	LEFT OUTER JOIN (select d.sessionid, d.testid, CASE WHEN SUM(DeltaTime) > 0 THEN SUM(DeltaTime) ELSE NULL END as VideoDuration	-- VideoDuration tal y como se calcula en el cu italiano
					FROM _ResultsVq06TimeDom_ord d, testinfo t
					where d.testid=t.testid and t.valid=1 and VerResolution=240
					group by d.sessionid, d.testid)	d240p on d240p.testid=t.testid 
	
	LEFT OUTER JOIN (select d.sessionid, d.testid, CASE WHEN SUM(DeltaTime) > 0 THEN SUM(DeltaTime) ELSE NULL END as VideoDuration	-- VideoDuration tal y como se calcula en el cu italiano
					FROM _ResultsVq06TimeDom_ord d, testinfo t
					where d.testid=t.testid and t.valid=1 and VerResolution=360
					group by d.sessionid, d.testid)	d360p on d360p.testid=t.testid 

	LEFT OUTER JOIN (select d.sessionid, d.testid, CASE WHEN SUM(DeltaTime) > 0 THEN SUM(DeltaTime) ELSE NULL END as VideoDuration	-- VideoDuration tal y como se calcula en el cu italiano
					FROM _ResultsVq06TimeDom_ord d, testinfo t
					where d.testid=t.testid and t.valid=1 and VerResolution=480
					group by d.sessionid, d.testid)	d480p on d480p.testid=t.testid 

	LEFT OUTER JOIN (select d.sessionid, d.testid, CASE WHEN SUM(DeltaTime) > 0 THEN SUM(DeltaTime) ELSE NULL END as VideoDuration	-- VideoDuration tal y como se calcula en el cu italiano
					FROM _ResultsVq06TimeDom_ord d, testinfo t
					where d.testid=t.testid and t.valid=1 and VerResolution=720
					group by d.sessionid, d.testid)	d720p on d720p.testid=t.testid 

	LEFT OUTER JOIN (select d.sessionid, d.testid, CASE WHEN SUM(DeltaTime) > 0 THEN SUM(DeltaTime) ELSE NULL END as VideoDuration	-- VideoDuration tal y como se calcula en el cu italiano
					FROM _ResultsVq06TimeDom_ord d, testinfo t
					where d.testid=t.testid and t.valid=1 and VerResolution=1080
					group by d.sessionid, d.testid)	d1080p on d1080p.testid=t.testid 

--	Cogemos la primera y segunda resolución para ver el cambio inicial que se produce y cuando:
	LEFT OUTER JOIN (select t.sessionid, t.testid, t.verResID_ini, t.VerResolution, ROW_NUMBER() over (partition by t.sessionid, t.testid order by t.verResID_ini asc) as idRes
					from _ResultsVq06TimeDom_ord t where verResID=1) Res1 on Res1.testid=t.testid  and Res1.idRes=1

	LEFT OUTER JOIN (select t.sessionid, t.testid, t.verResID_ini, t.VerResolution, ROW_NUMBER() over (partition by t.sessionid, t.testid order by t.verResID_ini asc) as idRes
					from _ResultsVq06TimeDom_ord t where verResID=2) Res2 on Res2.testid=t.testid  and Res2.idRes=2

-- De momento no hace falta, asi que no se calcula:
	--LEFT OUTER JOIN (select t.sessionid, t.testid, t.verResID_ini, t.VerResolution, 
	--					ROW_NUMBER() over (partition by t.sessionid, t.testid order by t.verResID_ini asc) as idRes
	--					--, *
	--				from #ResultsVq06TimeDom_ord t
	--				where verResID=3) Res3 on Res3.testid=t.testid  and Res3.idRes=3

	--LEFT OUTER JOIN (select t.sessionid, t.testid, t.verResID_ini, t.VerResolution, 
	--					ROW_NUMBER() over (partition by t.sessionid, t.testid order by t.verResID_ini asc) as idRes
	--					--, *
	--				from #ResultsVq06TimeDom_ord t
	--				where verResID=4) Res4 on Res4.testid=t.testid  and Res4.idRes=4

	--LEFT OUTER JOIN (select t.sessionid, t.testid, t.verResID_ini, t.VerResolution, 
	--					ROW_NUMBER() over (partition by t.sessionid, t.testid order by t.verResID_ini asc) as idRes
	--					--, *
	--				from #ResultsVq06TimeDom_ord t
	--				where verResID=5) Res5 on Res5.testid=t.testid  and Res5.idRes=5

order by t.sessionid, t.testid


------------------		select * from _vResolutionInfo

------------------------------ (18)	TABLA INTERMEDIA Results KPI ------------------------------
select 'Se crean las tablas intermedias:   (18)	TABLA INTERMEDIA Results KPI' info	
----------------
exec sp_lcc_dropifexists '_lcc_ResultsKPI'

select	r.* ,		-- e.*, 
		isnull(tp.Operation, tc.Direction) as Operation, 			isnull(tp.protocol, tc.protocol) as protocol,
		isnull(tp.Host, tc.UriList) as Host,						isnull(tp.LocalFilename, tc.LocalFilename) as LocalFilename,
		isnull(tp.RemoteFilename,'500MB.bin') as RemoteFilename,	isnull(tp.BufferSize, tc.BufferSize) as BufferSize,
		tp.FixedDuration
		
		--@ERC:	
		--,isnull(tt.msg, ttc.msg) as transferMSG,
		--br.msg as browserMSG

into _lcc_ResultsKPI
from testinfo t, sessions s, filelist f, vResultsKPI r
	--LEFT OUTER JOIN ErrorCodes e on (e.code = r.ErrorCode)	
	LEFT OUTER JOIN ResultsHTTPTransferParameters tp On(tp.TestId=r.TestId)
	--LEFT OUTER JOIN
	--	(select tt.testid, m.msg 
	--	 from ResultsHTTPTransferTest tt
	--		LEFT OUTER JOIN ErrorCodes m on (m.code = tt.ErrorCode)	
	--	 where  tt.lastBlock=1 and tt.testId > @maxTestid
	--	) tt on tt.testid=r.testid	

	--Capacity
	LEFT OUTER JOIN ResultsCapacityTestParameters tc on (tc.TestId=r.TestId)
	--LEFT OUTER JOIN
	--	(select tt.testid, m.msg 
	--	 from ResultsCapacityTest tt LEFT OUTER JOIN ErrorCodes m on (m.code = tt.ErrorCode)	
	--	 where  tt.lastBlock=1 and tt.testId > @maxTestid
	--	) ttc on ttc.testid=r.testid	
	--LEFT OUTER JOIN
	--	(select tt.testid, m.msg 
	--	 from ResultsHTTPBrowserTest tt LEFT OUTER JOIN ErrorCodes m on (m.code = tt.ErrorCode)	
	--	 where  tt.testId > @maxTestid
	--	) br on br.testid=r.testid	

where r.testid=t.testid and s.sessionid=t.sessionid and s.fileid=f.fileid and

	 KPIID in (@Downlink_Accessibility,	@Downlink_Retainability,	@Downlink_Throughput_D1,		-- DL:		Access, Retain, D1
				@Uplink_Accessibility,		@Uplink_Retainability,		@Uplink_Throughput_D3,			-- UL:		Access, Retain, D3

				@Downlink_NC_Accessibility_CAP, @Downlink_NC_Retainability_CAP, @Downlink_NC_MeanDataUserRate_CAP,		-- DL NC:	Access, Retain, D1
				@Uplink_NC_Accessibility_CAP,	@Uplink_NC_Retainability_CAP,	@Uplink_NC_MeanDataUserRate_CAP,		-- UL NC:	Access, Retain, D3

				@Browser_Accessibility, @Browser_Retainability, @Browser_SessionTime, @Browser_TCP_Thput, 	-- BROWSER:	Access, Retain, Session Time avg, IP Service Access Time avg, Transfer Time avg
				@Browser_Accessibility_HTTPS, @Browser_Retainability_HTTPS, @Browser_TCP_Thput_HTTPS,   -- BROWSER HTTPS
				@DNSTime,							-- BROWSER: DNS Time

				@Latency							-- Latency
				)
	and r.testId > @maxTestid	



-- El KPIID del timepo de DNS mete duplicados/triplicados
-- Ordenamos los valores y nos vamos a quedar con el menor
exec sp_lcc_dropifexists '_lcc_ResultsKPI_DNSTime'
select ROW_NUMBER() over (partition by sessionid, testid order by duration asc) as durationID, * 
into _lcc_ResultsKPI_DNSTime
from _lcc_ResultsKPI
where kpiid=@DNSTime

-- Limpiamos la tabla _lcc_ResultsKPI
delete _lcc_ResultsKPI
where kpiid=@DNSTime

-- Actualizamos con un unico valor de DNS:
-- Se cogen solo los valores de las query de DNS por nuestro server y de youtube en todo caso, auqnue este ultimo no hace falta
insert into _lcc_ResultsKPI
--select MsgId, 	SessionId, 	TestId, 	NetworkId, 	PosId, 	KPIId, 	StartTime, 	EndTime, 	Duration, 	ErrorCode, 	Sum, 	Counter, 	Value1, 	Value2, 	Value3, 	Value4, 	Value5, 	TriggerTime, 	ErrorCodeImport, 	Description, 	Options, 	errorId, 	type, 	code, 	msg, 	Operation, 	protocol, 	Host, 	LocalFilename, 	RemoteFilename, 	BufferSize, 	FixedDuration, 	transferMSG, 	browserMSG
select    MsgId,	SessionId,	TestId,	NetworkId,	PosId,	KPIId,	StartTime,	EndTime,	Duration,	ErrorCode,	Sum,	Counter,	Value1,	Value2,	Value3,	Value4,	Value5,	TriggerTime,	ErrorCodeImport,	Description,	Options,	errorId,	type,	code,	msg,	KPIName,	KPIStatus,	KPICause,	IdName,	KpiNameStatus,	Operation,	protocol,	Host,	LocalFilename,	RemoteFilename,	BufferSize,	FixedDuration
from _lcc_ResultsKPI_DNSTime
where durationid=1 and (value3 like '%youtube%' or value4 like '%46.24.7.18%')

-- @ERC: Actualizamos el valor de SessionTime del método antiguo para incluirle el valor del DNS
update _THPUT_Transf
set sessiontime_nu=isnull(sessiontime_nu,0) + isnull(k.duration,0)
from _THPUT_Transf th, _lcc_ResultsKPI k
where th.testid=k.testid and k.kpiid=@DNSTime

--CAC 10/08/2017: se procede de forma análoga para la tabla con info de NC
update _THPUT_Transf_NC
set sessiontime_nu=isnull(sessiontime_nu,0) + isnull(k.duration,0)
from _THPUT_Transf_NC th, _lcc_ResultsKPI k
where th.testid=k.testid and k.kpiid=@DNSTime


------------------------------ (19) TABLA INTERMEDIAS DOWNLINK KPI SWISSQUAL ------------------------------
select 'Se crean las tablas intermedias:  (19) TABLA INTERMEDIAS DOWNLINK KPI SWISSQUAL' info	
----------------
-- Se calcula cada KPIID para cada tipo de test:

exec sp_lcc_dropifexists '_lcc_http_DL'
select 
	t.SessionId, t.TestId,
	case when access.operation='GET' and access.RemoteFilename like '%500%' then 'DL_NC' 
		 when access.operation='GET' and access.RemoteFilename like '%3M%' then 'DL_CE'
	else null end as TestType,

	-- Calculo manual - ISSUE abierta con Sq, sin propuesta de cambio por su parte de momento
	ipt.Ip_Service as 'IP Access Time (ms)',
	--access.Duration as 'IP Access Time (ms)',			-- el del KPIID
	
	-- Thput Info - ResultKPIs
	tcpThput.Value3 as 'DataTransferred',										-- Number of transferred bytes
	tcpThput.Duration*0.001 as 'TransferTime', 									-- Time in ms between StartTime and EndTime			
	tcpThput.value1*0.008 as 'Throughput',										-- Value1: Throughput [Bytes/sec]
	(isnull(dns.Duration,0) + isnull(ipt.Ip_Service, 0) + isnull(tcpThput.Duration, 0))/1000.0 as SessionTime,	--	en seg -> falta sumarle el DNS Time

	-- Lo primero ver que tipo es:
	case when access.ErrorCode = 0 and retain.ErrorCode = 0 then null
	else
		case when access.ErrorCode = 0 and retain.ErrorCode <> 0 then 'Retainability'
			 when access.ErrorCode = 0 and retain.ErrorCode is null then 'Retainability'
			 when access.ErrorCode <> 0 then 'Accessibility'			 
		end
	end as ErrorType,

	-- Luego la causa del error:
	case when access.ErrorCode = 0 and retain.ErrorCode = 0 then null
	else
		case when access.ErrorCode = 0 and retain.ErrorCode <> 0 then retain.KPICause
			 when access.ErrorCode = 0 and retain.ErrorCode is null then retain.KPICause
			 when access.ErrorCode <> 0 then access.KPICause			 
		end
	end as ErrorCause
	 		
into _lcc_http_DL
from
	filelist f, sessions s, testinfo t
		LEFT OUTER JOIN _lcc_ResultsKPI access on access.testid=t.testid and access.kpiid = @Downlink_Accessibility		-- Downlink - Accessibility
		LEFT OUTER JOIN _lcc_ResultsKPI retain on retain.testid=t.testid and retain.kpiid = @Downlink_Retainability		-- Downlink - Retainability
		LEFT OUTER JOIN _lcc_ResultsKPI tcpThput on tcpThput.testid=t.testid and tcpThput.kpiid = @Downlink_Throughput_D1		-- Downlink -Throughput Mean User data rate (NED KPI D1)
		LEFT OUTER JOIN _lcc_ResultsKPI dns on dns.testid=t.testid and dns.kpiid=@DNSHostResolution
		LEFT OUTER JOIN _lcc_ip_service ipt on ipt.Testid_get = t.Testid

where t.sessionid=s.sessionid and s.FileId=f.fileid
	and access.operation='GET' and access.RemoteFilename like '%3M%'
	and t.typeoftest='HTTPTransfer' and t.direction='Downlink'
	and t.testid > @maxtestid

union all
--------------------
---- Es vez un union all:
--insert into _lcc_http_DL
select 
	t.SessionId, t.TestId,
	case when access.operation='GET' and access.RemoteFilename like '%500%' then 'DL_NC' 
		 when access.operation='GET' and access.RemoteFilename like '%3M%' then 'DL_CE'
	else null end as TestType,

	-- Calculo manual - ISSUE abierta con Sq, sin propuesta de cambio por su parte de momento
	ipt.Ip_Service as 'IP Access Time (ms)',
	--access.Duration as 'IP Access Time (ms)',		-- el del KPIID			
	
	-- Thput Info - ResultKPIs
	tcpThput.Value3 as 'DataTransferred',										-- Number of transferred bytes
	tcpThput.Duration*0.001 as 'TransferTime', 									-- Time in ms between StartTime and EndTime			
	tcpThput.value1*0.008 as 'Throughput',										-- Value1: Throughput [Bytes/sec]
	(isnull(dns.Duration,0) + isnull(ipt.Ip_Service, 0) + isnull(tcpThput.Duration, 0))/1000.0 as SessionTime,	--	en ms -> falta sumarle el DNS Time

	-- Lo primero ver que tipo es:
	case when access.ErrorCode = 0 and retain.ErrorCode = 0 then null
	else
		case when access.ErrorCode = 0 and retain.ErrorCode <> 0 then 'Retainability'
			 when access.ErrorCode = 0 and retain.ErrorCode is null then 'Retainability'
			 when access.ErrorCode <> 0 then 'Accessibility'			 
		end
	end as ErrorType,

	-- Luego la causa del error:
	case when access.ErrorCode = 0 and retain.ErrorCode = 0 then null
	else
		case when access.ErrorCode = 0 and retain.ErrorCode <> 0 then retain.KPICause
			 when access.ErrorCode = 0 and retain.ErrorCode is null then retain.KPICause
			 when access.ErrorCode <> 0 then access.KPICause			 
		end
	end as ErrorCause
	 		
from
	filelist f, sessions s, testinfo t
		LEFT OUTER JOIN _lcc_ResultsKPI access on access.testid=t.testid and access.kpiid in (@Downlink_NC_Accessibility_CAP)	-- Downlink NC - Accessibility
		LEFT OUTER JOIN _lcc_ResultsKPI retain on retain.testid=t.testid and retain.kpiid in (@Downlink_NC_Retainability_CAP)	-- Downlink NC - Retainability
		LEFT OUTER JOIN _lcc_ResultsKPI tcpThput on tcpThput.testid=t.testid and tcpThput.kpiid in (@Downlink_NC_MeanDataUserRate_CAP)			-- Downlink NC -Throughput Mean User data rate (NED KPI D1)
		LEFT OUTER JOIN _lcc_ResultsKPI dns on dns.testid=t.testid and dns.kpiid=@DNSHostResolution		
		LEFT OUTER JOIN _lcc_ip_service ipt on ipt.Testid_get = t.Testid

where t.sessionid=s.sessionid and s.FileId=f.fileid
	and access.operation='GET' and access.RemoteFilename like '%500%'
	and t.typeoftest in ('HTTPTransfer','Capacity') and t.direction='Downlink'
	and t.testid > @maxtestid

-- *********************************************************************************************************
-- @ERC: 20161212 - se añade para asegurara la limpieza de los KPIs de los test fallidos (afecta al SessionTime por su calculo manual)
update _lcc_http_DL
set Throughput=null, DataTransferred=null,	
	SessionTime=null, [IP Access Time (ms)]=null, TransferTime=null
where ErrorType is not null


------------------------------ (20) TABLA INTERMEDIAS UPLINK KPI SWISSQUAL ------------------------------
select 'Se crean las tablas intermedias:  (20) TABLA INTERMEDIAS UPLINK KPI SWISSQUAL' info	
----------------
-- Se calcula cada KPIID para cada tipo de test:

exec sp_lcc_dropifexists '_lcc_http_UL'
select 
	t.SessionId, t.TestId,
	case when access.operation='PUT' and access.LocalFilename like '%500%' then 'UL_NC' 
		 when access.operation='PUT' and access.LocalFilename like '%1M%' then 'UL_CE'
	else null end as TestType,

	-- Calculo manual - ISSUE abierta con Sq, sin propuesta de cambio por su parte de momento
	ipt.Ip_Service as 'IP Access Time (ms)',
	--access.Duration as prueba,			
	
	-- Thput Info - ResultKPIs
	tcpThput.Value3 as 'DataTransferred',										-- Number of transferred bytes
	tcpThput.Duration*0.001 as 'TransferTime', 									-- Time in ms between StartTime and EndTime			
	tcpThput.value1*0.008 as 'Throughput',										-- Value1: Throughput [Bytes/sec]
	(isnull(dns.Duration,0) + isnull(ipt.Ip_Service, 0) + isnull(tcpThput.Duration, 0))/1000.0 as SessionTime,	--	en ms -> falta sumarle el DNS Time

	-- Lo primero ver que tipo de Error es:
	case when access.ErrorCode = 0 and retain.ErrorCode = 0 then null
	else
		case when access.ErrorCode = 0 and retain.ErrorCode <> 0 then 'Retainability'
			 when access.ErrorCode = 0 and retain.ErrorCode is null then 'Retainability'
			 when access.ErrorCode <> 0 then 'Accessibility'		 
		end
	end as ErrorType,

	-- Luego la causa del error, que sera directamente la del KPIID:
	case when access.ErrorCode = 0 and retain.ErrorCode = 0 then null
	else
		case when access.ErrorCode = 0 and retain.ErrorCode <> 0 then retain.KPICause
			 when access.ErrorCode = 0 and retain.ErrorCode is null then retain.KPICause
			 when access.ErrorCode <> 0 then access.KPICause			 
		end
	end as ErrorCause
	 		
into _lcc_http_UL
from
	filelist f, sessions s, testinfo t
		LEFT OUTER JOIN _lcc_ResultsKPI access on access.testid=t.testid and access.kpiid  = @Uplink_Accessibility			-- Uplink - Accessibility
		LEFT OUTER JOIN _lcc_ResultsKPI retain on retain.testid=t.testid and retain.kpiid = @Uplink_Retainability		-- Uplink - Retainability
		LEFT OUTER JOIN _lcc_ResultsKPI tcpThput on tcpThput.testid=t.testid and tcpThput.kpiid = @Uplink_Throughput_D3		-- Uplink -Throughput Mean User data rate (NED KPI D1)
		LEFT OUTER JOIN _lcc_ResultsKPI dns on dns.testid=t.testid and dns.kpiid=@DNSHostResolution		
		LEFT OUTER JOIN _lcc_ip_service ipt on (ipt.Testid_get = t.Testid)

where t.sessionid=s.sessionid and s.FileId=f.fileid
	and access.operation='PUT' and access.LocalFilename like '%1M%'
	and t.typeoftest='HTTPTransfer' and t.direction='Uplink'
	and t.testid>@maxtestid

union all
---------
select 
	t.SessionId, t.TestId,
	case when access.operation='PUT' and access.LocalFilename like '%500%' then 'UL_NC' 
		 when access.operation='PUT' and access.LocalFilename like '%1M%' then 'UL_CE'
	else null end as TestType,

	-- Calculo manual - ISSUE abierta con Sq, sin propuesta de cambio por su parte de momento
	ipt.Ip_Service as 'IP Access Time (ms)',
	--access.Duration as prueba,			
	
	-- Thput Info - ResultKPIs
	tcpThput.Value3 as 'DataTransferred',										-- Number of transferred bytes
	tcpThput.Duration*0.001 as 'TransferTime', 									-- Time in ms between StartTime and EndTime			
	tcpThput.value1*0.008 as 'Throughput',										-- Value1: Throughput [Bytes/sec]
	(isnull(dns.Duration,0) + isnull(ipt.Ip_Service, 0) + isnull(tcpThput.Duration, 0))/1000.0 as SessionTime,	--	en ms -> falta sumarle el DNS Time

	-- Lo primero ver que tipo de Error es:
	case when access.ErrorCode = 0 and retain.ErrorCode = 0 then null
	else
		case when access.ErrorCode = 0 and retain.ErrorCode <> 0 then 'Retainability'
			 when access.ErrorCode = 0 and retain.ErrorCode is null then 'Retainability'
			 when access.ErrorCode <> 0 then 'Accessibility'			 
		end
	end as ErrorType,

	-- Luego la causa del error, que sera directamente la del KPIID:
	case when access.ErrorCode = 0 and retain.ErrorCode = 0 then null
	else
		case when access.ErrorCode = 0 and retain.ErrorCode <> 0 then retain.KPICause
			 when access.ErrorCode = 0 and retain.ErrorCode is null then retain.KPICause
			 when access.ErrorCode <> 0 then access.KPICause			 
		end
	end as ErrorCause
	 		
from
	filelist f, sessions s, testinfo t
		LEFT OUTER JOIN _lcc_ResultsKPI access on access.testid=t.testid and access.kpiid  in (@Uplink_NC_Accessibility_CAP)			-- Uplink - Accessibility
		LEFT OUTER JOIN _lcc_ResultsKPI retain on retain.testid=t.testid and retain.kpiid in ( @Uplink_NC_Retainability_CAP)		-- Uplink - Retainability
		LEFT OUTER JOIN _lcc_ResultsKPI tcpThput on tcpThput.testid=t.testid and tcpThput.kpiid in (@Uplink_NC_MeanDataUserRate_CAP)		-- Uplink -Throughput Mean User data rate (NED KPI D1)
		LEFT OUTER JOIN _lcc_ResultsKPI dns on dns.testid=t.testid and dns.kpiid=@DNSHostResolution				
		LEFT OUTER JOIN _lcc_ip_service ipt on (ipt.Testid_get = t.Testid)

where t.sessionid=s.sessionid and s.FileId=f.fileid
	and access.operation='PUT' and access.LocalFilename like '%500%'
	and t.typeoftest in ('HTTPTransfer','Capacity') and t.direction='Uplink'
	and t.testid>@maxtestid


-- *********************************************************************************************************
-- @ERC: 20161212 - se añade para asegurara la limpieza de los KPIs de los test fallidos (afecta al SessionTime por su calculo manual)
update _lcc_http_UL
set Throughput=null, DataTransferred=null,	
	SessionTime=null, [IP Access Time (ms)]=null, TransferTime=null
where ErrorType is not null


------------------------------ (21) TABLA INTERMEDIAS BROWSING KPI SWISSQUAL ------------------------------
select 'Se crean las tablas intermedias:  (21) TABLA INTERMEDIAS BROWSING KPI SWISSQUAL' info	
----------------
---- Se calcula cada KPIID para cada tipo de test:

exec sp_lcc_dropifexists '_lcc_http_browser'
select 
	t.SessionId, t.TestId, 

	--Type TEST - ResultKPIs
	case when access.value5 like '%//kepler.%' then 'Kepler 0s Pause'
		 when access.value5 like '%//kepler2.%' then 'Kepler 30s Pause'
		 when access.value5 like '%//mkepler.%' then 'Mobile Kepler 0s Pause' 
		 when access.value5 like '%//mkepler2.%' then 'Mobile Kepler 30s Pause' 
		 when access.value5 like '%m.ebay.es%' Then 'Ebay'
		 when access.value5 like '%google.es%' Then 'Google'
		 when access.value5 like '%elpais.com%' Then 'El Pais'
		 when access.value5 like '%youtube.com%' Then 'Youtube'

		 when access.value5 like '%elmundo.es%' Then 'El Mundo'

		 --when access.value5 like '%msn.com%' Then 'MSN'
		 when access.value5 like '%msn.com/es-es/eltiempo/mapas/madrid' Then 'MSN'	-- url fallida para OSP
		 when access.value5 like '%msn.com/es-es/eltiempo/' Then 'MSN 2'			-- temporal de pruebas
		 when access.value5 like '%20minutos.es%' Then '20 Minutos'
		 when access.value5 like '%marca.com%' Then 'Marca'

		 when access.value5 like '%amazon.com%' Then 'Amazon'
		 when access.value5 like '%netflix.com%' Then 'Netflix'

	 else null end  as TestType,

	 case when access.value5 like '%https%' then 'HTTPS'
		 else 'HTTP' end  as Protocol,

	-- Thput Info - ResultKPIs
	tcpThput.Value3 as DataTransferred,			-- Size of file
	tcpThput.Value1*0.008 as Throughput,		-- Throughput [Bytes/sec]

	-- Times Info - ResultKPIs:
	access.Duration as 'IPAccessT',
	retain.Duration as 'transferT',
	case when access.value5 like '%https%' then (access.duration + retain.duration + isnull(dns.Duration,0))
		 else sessionT.Duration + isnull(dns.Duration,0) 
		 end as 'sessionT',		-- salen mas de un valor en algunos test ¿?
	dns.Duration as DNST,

	-- Sin anular:
	tcpThput.Value3 as DataTransferred_nu,			-- Size of file
	tcpThput.Value1*0.008 as ThputApp_nu,			-- Throughput [Bytes/sec]
	access.Duration as 'IPAccessTime_nu',
	retain.Duration as 'TransferTime_nu',
	sessionT.Duration + isnull(dns.Duration,0) as 'SessionTime_nu',		
	dns.Duration as DNSTime_nu,

	-- Errores KPIID:
	-- Lo primero ver que tipo es:
	case when access.ErrorCode = 0 and retain.ErrorCode = 0 then null
	else
		case when access.ErrorCode = 0 and retain.ErrorCode <> 0 then 'Retainability'
			 when access.ErrorCode = 0 and retain.ErrorCode is null then 'Retainability'
			 when access.ErrorCode <> 0 then 'Accessibility'
			 
		end
	end as ErrorType,

	-- Luego la causa del error:
	case when access.ErrorCode = 0 and retain.ErrorCode = 0 then null
	else
		case when access.ErrorCode = 0 and retain.ErrorCode <> 0 then retain.KPICause
			 when access.ErrorCode = 0 and retain.ErrorCode is null then retain.KPICause
			 when access.ErrorCode <> 0 then access.KPICause			 
		end
	end as ErrorCause, 

	access.value5 as url

into _lcc_http_browser
from
	filelist f, sessions s, testinfo t
		LEFT OUTER JOIN _lcc_ResultsKPI access on access.testid=t.testid and access.kpiid in (@Browser_Accessibility, @Browser_Accessibility_HTTPS)		-- Browser - Accessibility
		LEFT OUTER JOIN _lcc_ResultsKPI retain on retain.testid=t.testid and retain.kpiid in (@Browser_Retainability, @Browser_Retainability_HTTPS)		-- Browser - Retainability
		LEFT OUTER JOIN _lcc_ResultsKPI sessionT on sessionT.testid=t.testid and sessionT.kpiid=@Browser_SessionTime									-- Browser - Session Time avg	
		LEFT OUTER JOIN _lcc_ResultsKPI dns on dns.testid=t.testid and dns.kpiid=@DNSTime																-- Browser - DNS Time								
		LEFT OUTER JOIN _lcc_ResultsKPI tcpThput on tcpThput.testid=t.testid and tcpThput.kpiid in (@Browser_TCP_Thput, @Browser_TCP_Thput_HTTPS)		-- Browser - TCP Throughput			

where t.sessionid=s.sessionid and s.FileId=f.fileid
	and t.typeoftest='HTTPBrowser' 
	and t.testid>@maxtestid

order by t.startTime


----------------	
-- Se anulan los test que duren mas de 10s - se supone que lo hace la herramienta pero no es así y los de por validos
--declare @Browser_Transfer_Timeout as int = 10000
--declare @Browser_IP_Connection_Timeout as int = 10000

----------------
-- Se anulan los test que duren mas de 10s - se supone que lo hace la herramienta pero no es así
update _lcc_http_browser
set ErrorCause='Error: IP Connection Timeout', ErrorType='Accessibility', Throughput=null, DataTransferred=null,
	sessionT=null, IPAccessT=null, transferT=null
where [IPAccessT]>@Browser_IP_Connection_Timeout
	--and ErrorType is null

update _lcc_http_browser
set ErrorCause='Error: Transfer Timeout', ErrorType='Retainability', Throughput=null, DataTransferred=null,
	sessionT=null, IPAccessT=null, transferT=null
where (transferT>@Browser_Transfer_Timeout or sessionT>@Browser_Transfer_Timeout)
	and ErrorType is null



------------------------------ (22) TABLA INTERMEDIAS LATENCIAS KPI SWISSQUAL ------------------------------
select 'Se crean las tablas intermedias:  (22) TABLA INTERMEDIAS LATENCIAS KPI SWISSQUAL' info	
exec sp_lcc_dropifexists '_lcc_http_latencias'

select  p.sessionid,
		p.testid,
		p.Duration,
		p.Size

into _lcc_http_latencias
from
	(select 
		t.SessionId, t.TestId, 
		percentile_cont(0.5)
		within group (order by ping.duration)
		over (partition by ping.testid) as Duration,
		ping.size

	from
		filelist f, sessions s, testinfo t
			LEFT OUTER JOIN 
				(
				select p.TestId, p.Duration, s.RRCState, s.RRCState_Desc, p.value2 as size,
					   cast(p.value3 as int) as 'index', pmax.MaxInd
				from _lcc_ResultsKPI p 
							left join _stateRCC s on (p.SessionId = s.SessionId	and p.endTime between s.time_ini and s.time_fin)
							left join (Select sessionid, testid, max(cast(value3 as int)) as maxind from _lcc_ResultsKPI where kpiid=@Latency and value2=@sizePing and errorCode=0 group by sessionid, testid) pmax on (pmax.SessionId = p.SessionId	and pmax.testid=p.testid)
				where p.kpiid=@Latency and p.value2=@sizePing and p.errorCode=0	
					and (s.RRCState_Desc is null or s.RRCState_Desc = 'CELL DCH')	
				) ping on ping.testid=t.testid

	where t.sessionid=s.sessionid and s.FileId=f.fileid
		and t.typeoftest='Ping'
		and ping.size=@sizePing
		and ping.[index] between ping.maxind-4 and ping.maxind
		and t.testid>@maxtestid) p
group by p.sessionid, p.testid, p.Duration,	p.Size 


------------------------------ (24) TABLAS KPIS EXTRAS CEM SWISSQUAL------------------------------

exec sp_lcc_dropifexists '_Paging'	
--Paging
select r.sessionid,
	   r.testid,
	   1.0*sum(case when r.errorcode = 0 then 1 else 0 end)/count(r.errorcode) as Paging_Success_Ratio

into _Paging	   
from resultskpi r
where r.testid > @maxtestid

group by r.sessionid, r.testid

exec sp_lcc_dropifexists '_PDP'	
--PDP
select r.sessionid,
	   r.testid,
	   1.0*sum(case when r.errorcode = 0 then 1 else 0 end)/count(r.errorcode) as PDP_Activate_Ratio

into _PDP	   
from resultskpi r
where r.kpiid=15200
and r.testid > @maxtestid

group by r.sessionid, r.testid

exec sp_lcc_dropifexists '_NEIGH'	
-- Neighbors
select  l.sessionid,
		l.testid,
		l.EARFCN as EARFCN_PCC,
		l.PhyCellId as PCI_PCC,
		10*LOG10(AVG(POWER(CAST(10 AS float), (l.RSRP)/10.0))) as RSRP_PCC,
		10*LOG10(AVG(POWER(CAST(10 AS float), (l.RSRQ)/10.0))) as RSRQ_PCC,
		ln.EARFCN_N1,
		ln.PCI_N1,
		10*LOG10(AVG(POWER(CAST(10 AS float), (ln.RSRP_N1)/10.0))) as RSRP_N1,
		10*LOG10(AVG(POWER(CAST(10 AS float), (ln.RSRQ_N1)/10.0))) as RSRQ_N1

into _NEIGH
from LTEmeasurementReport l

left outer join 
			( select 
				ln.ltemeasreportid,
				l.msgtime,
				ln.EARFCN as EARFCN_N1,
				ln.PhyCellId as PCI_N1,
				ln.RSRP as RSRP_N1,
				ln.RSRQ as RSRQ_N1,
				ln.carrierindex,
				row_number () over (partition by l.sessionid, l.testid order by l.msgtime asc, ln.RSRP desc) as id
				
				from LTENeighbors ln, LTEmeasurementReport l, testinfo t
				where carrierindex=0 --Solo para la PCC
				and l.ltemeasreportid=ln.ltemeasreportid
				and t.sessionid=l.sessionid and l.testid=t.testid
				and l.msgtime >= dateadd(ss, -1, dateadd(ms, t.duration, t.starttime))
				and l.testid > @maxtestid
			) ln on l.ltemeasreportid=ln.ltemeasreportid and ln.id=1

where ln.EARFCN_N1 is not null

group by l.sessionid, l.testid,l.EARFCN,l.PhyCellId, ln.EARFCN_N1, ln.PCI_N1, l.msgtime
order by l.sessionid, l.testid

exec sp_lcc_dropifexists '_4GHO'	
--HO 4G/4G
select  r.sessionid,
		r.testid,
		count( r.sessionid ) as num_HO_S1X2,
		avg(r.duration) as duration_S1X2_avg,
		1.0*sum(case when (r.kpiid in (38100) and r.errorcode<>0) then 0 else 1 end)/count(r.sessionid) as S1X2HO_SR

into _4GHO
from resultskpi r
where r.kpiid in (38100)
and r.testid > @maxtestid
group by  r.sessionid, r.testid

exec sp_lcc_dropifexists '_Window'	
-- Windows Size

select  m.sessionid,
		m.testid,
		max(m.Win) as Max_Win

into _Window
from
(
		select m.sessionid,
		m.testid,
		max(cast (substring(m.msg, charindex('win=',m.msg)+4,len(m.msg)-charindex('win=',m.msg)+4) as int)) as Win

		from msgethereal m

		where m.protocol='tcp'
		and m.msg like '%win=%' and m.msg not like '%urg%'
		and m.testid > @maxtestid
		group by m.sessionid, m.testid

		) m

group by m.sessionid, m.testid

exec sp_lcc_dropifexists '_BUFFER'	
-- Youtube Buffer

select 
		v.sessionid,
		v.testid,
		v.[Video IP Service Access Time [s]]] as Video_IPService_Time,
		v.[video reproduction start delay [s]]] as Buffering_Time, --KPIID: 30621
		(v.[Video Play Start Time [s]]]+v.[IP Service Access Time [s]]]) as [Time To First Image [s]]]

into _BUFFER
from vETSIYouTubeKPIs v

where v.testid > @maxtestid


-------------------------------------------------------------------------------------------------------------------------------------
-- Calculo distribución de las conexiones por tecnología, con siguiente criterio:
-- 3G a partir de HSDPAModulation
-- 4G a partir de la tabla de BW si hay información y sino de la estimación del BW de lcc Serving
-------------------------------------------------------------------------------------------------------------------------------------

--Info acotada al momento de la descarga, subida, navegacion y reproduccion
exec sp_lcc_dropifexists '_Tech_Duration_Distribution_acotado_Serv'
select t.sessionid, t.testid,	

	1.0*isnull(m3.sumDurationDualCarrier_use_U2100,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as DualCarrier_U2100,
	1.0*isnull(m3.sumDurationDualCarrier_use_U900,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as DualCarrier_U900,
	1.0*isnull(m3.sumDurationDualCarrier,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as DualCarrier_3G,
	1.0*isnull(m3.[sumDurationHSPA],0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as HSPA_PCT,		
	1.0*isnull(m3.[sumDurationHSPA+],0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as [HSPA+_PCT],
	1.0*isnull(m3.[sumDurationHSPA_DC],0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as [HSPA_DC_PCT],
	1.0*isnull(m3.[sumDurationHSPA+_DC],0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as [HSPA+_DC_PCT],
	1.0*isnull(bw.DurationLTE_20Mhz_SC,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_20Mhz_SC_PCT,
	1.0*isnull(bw.DurationLTE_15Mhz_SC,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_15Mhz_SC_PCT, 
	1.0*isnull(bw.DurationLTE_10Mhz_SC,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_10Mhz_SC_PCT, 
	1.0*isnull(bw.DurationLTE_5Mhz_SC,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_5Mhz_SC_PCT, 
	1.0*isnull(bw.DurationLTE_40Mhz_CA,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_40Mhz_CA_PCT, 
	1.0*isnull(bw.DurationLTE_35Mhz_CA,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_35Mhz_CA_PCT, 
	1.0*isnull(bw.DurationLTE_30Mhz_CA,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_30Mhz_CA_PCT,
	1.0*isnull(bw.DurationLTE_25Mhz_CA,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_25Mhz_CA_PCT,
	1.0*isnull(bw.DurationLTE_20Mhz_CA,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_20Mhz_CA_PCT, 
	1.0*isnull(bw.DurationLTE_15Mhz_CA,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_15Mhz_CA_PCT,
	1.0*isnull(bw.DurationLTE_60Mhz_3C,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_60Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_55Mhz_3C,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_55Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_50Mhz_3C,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_50Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_45Mhz_3C,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_45Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_40Mhz_3C,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_40Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_35Mhz_3C,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_35Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_30Mhz_3C,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_30Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_25Mhz_3C,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_25Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_20Mhz_PCC,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_20Mhz_PCC_PCT, 
	1.0*isnull(bw.DurationLTE_15Mhz_PCC,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_15Mhz_PCC_PCT, 
	1.0*isnull(bw.DurationLTE_10Mhz_PCC,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_10Mhz_PCC_PCT,
	1.0*isnull(bw.DurationLTE_5Mhz_PCC,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_5Mhz_PCC_PCT,
	1.0*isnull(bw.DurationLTE_20Mhz_SCC1,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_20Mhz_SCC1_PCT,
	1.0*isnull(bw.DurationLTE_15Mhz_SCC1,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_15Mhz_SCC1_PCT, 
	1.0*isnull(bw.DurationLTE_10Mhz_SCC1,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_10Mhz_SCC1_PCT,
	1.0*isnull(bw.DurationLTE_5Mhz_SCC1,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_5Mhz_SCC1_PCT,
	1.0*isnull(bw.DurationLTE_20Mhz_SCC2,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_20Mhz_SCC2_PCT, 
	1.0*isnull(bw.DurationLTE_15Mhz_SCC2,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_15Mhz_SCC2_PCT,
	1.0*isnull(bw.DurationLTE_10Mhz_SCC2,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_10Mhz_SCC2_PCT,
	1.0*isnull(bw.DurationLTE_5Mhz_SCC2,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_5Mhz_SCC2_PCT,
	(1.0*isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0))
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as SC_PCT,
	(1.0*isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0))
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as CA_PCT,
	(1.0*isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0))
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as '3C_PCT'

into _Tech_Duration_Distribution_acotado_Serv
from testinfo t
	inner join _Serving_Info_acotado bw on bw.sessionid=t.sessionid and bw.testid=t.testid
	left join _MOD_3G_acotado m3 on m3.sessionid=t.sessionid and m3.testid=t.testid
	 
where t.testid > @maxtestid

--Info acotada al momento de la descarga, teniendo en cuenta el acceso:
exec sp_lcc_dropifexists '_Tech_Duration_Distribution_acotado_acc_Serv'
select t.sessionid, t.testid,
	1.0*isnull(m3.sumDurationDualCarrier_use_U2100,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as DualCarrier_U2100,
	1.0*isnull(m3.sumDurationDualCarrier_use_U900,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as DualCarrier_U900,
	1.0*isnull(m3.sumDurationDualCarrier,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as DualCarrier_3G,
	1.0*isnull(m3.[sumDurationHSPA],0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as HSPA_PCT,		
	1.0*isnull(m3.[sumDurationHSPA+],0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as [HSPA+_PCT],
	1.0*isnull(m3.[sumDurationHSPA_DC],0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as [HSPA_DC_PCT],
	1.0*isnull(m3.[sumDurationHSPA+_DC],0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as [HSPA+_DC_PCT],
	1.0*isnull(bw.DurationLTE_20Mhz_SC,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_20Mhz_SC_PCT,
	1.0*isnull(bw.DurationLTE_15Mhz_SC,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_15Mhz_SC_PCT, 
	1.0*isnull(bw.DurationLTE_10Mhz_SC,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_10Mhz_SC_PCT, 
	1.0*isnull(bw.DurationLTE_5Mhz_SC,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_5Mhz_SC_PCT, 
	1.0*isnull(bw.DurationLTE_40Mhz_CA,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_40Mhz_CA_PCT, 
	1.0*isnull(bw.DurationLTE_35Mhz_CA,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_35Mhz_CA_PCT, 
	1.0*isnull(bw.DurationLTE_30Mhz_CA,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_30Mhz_CA_PCT,
	1.0*isnull(bw.DurationLTE_25Mhz_CA,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_25Mhz_CA_PCT,
	1.0*isnull(bw.DurationLTE_20Mhz_CA,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_20Mhz_CA_PCT, 
	1.0*isnull(bw.DurationLTE_15Mhz_CA,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_15Mhz_CA_PCT,
	1.0*isnull(bw.DurationLTE_60Mhz_3C,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_60Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_55Mhz_3C,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_55Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_50Mhz_3C,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_50Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_45Mhz_3C,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_45Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_40Mhz_3C,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_40Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_35Mhz_3C,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_35Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_30Mhz_3C,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_30Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_25Mhz_3C,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_25Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_20Mhz_PCC,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_20Mhz_PCC_PCT, 
	1.0*isnull(bw.DurationLTE_15Mhz_PCC,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_15Mhz_PCC_PCT, 
	1.0*isnull(bw.DurationLTE_10Mhz_PCC,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_10Mhz_PCC_PCT,
	1.0*isnull(bw.DurationLTE_5Mhz_PCC,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_5Mhz_PCC_PCT,
	1.0*isnull(bw.DurationLTE_20Mhz_SCC1,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_20Mhz_SCC1_PCT,
	1.0*isnull(bw.DurationLTE_15Mhz_SCC1,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_15Mhz_SCC1_PCT, 
	1.0*isnull(bw.DurationLTE_10Mhz_SCC1,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_10Mhz_SCC1_PCT,
	1.0*isnull(bw.DurationLTE_5Mhz_SCC1,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_5Mhz_SCC1_PCT,
	1.0*isnull(bw.DurationLTE_20Mhz_SCC2,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_20Mhz_SCC2_PCT, 
	1.0*isnull(bw.DurationLTE_15Mhz_SCC2,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_15Mhz_SCC2_PCT,
	1.0*isnull(bw.DurationLTE_10Mhz_SCC2,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_10Mhz_SCC2_PCT,
	1.0*isnull(bw.DurationLTE_5Mhz_SCC2,0)
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_5Mhz_SCC2_PCT,
	(1.0*isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0))
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as SC_PCT,
	(1.0*isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0))
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as CA_PCT,
	(1.0*isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0))
			/ nullif(isnull(bw.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else bw.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as '3C_PCT'

into _Tech_Duration_Distribution_acotado_acc_Serv
from testinfo t
	 inner join _Serving_Info_acotado_acc bw on bw.sessionid=t.sessionid and bw.testid=t.testid
	 left  join _MOD_3G_acotado m3 on m3.sessionid=t.sessionid and m3.testid=t.testid	 
where t.testid > @maxtestid

--Info acotada al momento de la descarga, subida, navegacion y reproduccion
exec sp_lcc_dropifexists '_Tech_Duration_Distribution_acotado'
select t.sessionid, t.testid,
	1.0*isnull(m3.sumDurationDualCarrier_use_U2100,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as DualCarrier_U2100,
	1.0*isnull(m3.sumDurationDualCarrier_use_U900,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as DualCarrier_U900,
	1.0*isnull(m3.sumDurationDualCarrier,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as DualCarrier_3G,
	1.0*isnull(m3.[sumDurationHSPA],0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as HSPA_PCT,		
	1.0*isnull(m3.[sumDurationHSPA+],0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as [HSPA+_PCT],
	1.0*isnull(m3.[sumDurationHSPA_DC],0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as [HSPA_DC_PCT],
	1.0*isnull(m3.[sumDurationHSPA+_DC],0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as [HSPA+_DC_PCT],
	1.0*isnull(bw.DurationLTE_20Mhz_SC,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_20Mhz_SC_PCT,
	1.0*isnull(bw.DurationLTE_15Mhz_SC,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_15Mhz_SC_PCT, 
	1.0*isnull(bw.DurationLTE_10Mhz_SC,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_10Mhz_SC_PCT, 
	1.0*isnull(bw.DurationLTE_5Mhz_SC,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_5Mhz_SC_PCT, 
	1.0*isnull(bw.DurationLTE_40Mhz_CA,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_40Mhz_CA_PCT, 
	1.0*isnull(bw.DurationLTE_35Mhz_CA,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_35Mhz_CA_PCT, 
	1.0*isnull(bw.DurationLTE_30Mhz_CA,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_30Mhz_CA_PCT,
	1.0*isnull(bw.DurationLTE_25Mhz_CA,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_25Mhz_CA_PCT,
	1.0*isnull(bw.DurationLTE_20Mhz_CA,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_20Mhz_CA_PCT, 
	1.0*isnull(bw.DurationLTE_15Mhz_CA,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_15Mhz_CA_PCT,
	1.0*isnull(bw.DurationLTE_60Mhz_3C,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_60Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_55Mhz_3C,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_55Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_50Mhz_3C,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_50Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_45Mhz_3C,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_45Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_40Mhz_3C,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_40Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_35Mhz_3C,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_35Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_30Mhz_3C,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_30Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_25Mhz_3C,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_25Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_20Mhz_PCC,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_20Mhz_PCC_PCT, 
	1.0*isnull(bw.DurationLTE_15Mhz_PCC,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_15Mhz_PCC_PCT, 
	1.0*isnull(bw.DurationLTE_10Mhz_PCC,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_10Mhz_PCC_PCT,
	1.0*isnull(bw.DurationLTE_5Mhz_PCC,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_5Mhz_PCC_PCT,
	1.0*isnull(bw.DurationLTE_20Mhz_SCC1,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_20Mhz_SCC1_PCT,
	1.0*isnull(bw.DurationLTE_15Mhz_SCC1,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_15Mhz_SCC1_PCT, 
	1.0*isnull(bw.DurationLTE_10Mhz_SCC1,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_10Mhz_SCC1_PCT,
	1.0*isnull(bw.DurationLTE_5Mhz_SCC1,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_5Mhz_SCC1_PCT,
	1.0*isnull(bw.DurationLTE_20Mhz_SCC2,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_20Mhz_SCC2_PCT, 
	1.0*isnull(bw.DurationLTE_15Mhz_SCC2,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_15Mhz_SCC2_PCT,
	1.0*isnull(bw.DurationLTE_10Mhz_SCC2,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_10Mhz_SCC2_PCT,
	1.0*isnull(bw.DurationLTE_5Mhz_SCC2,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_5Mhz_SCC2_PCT,
	(1.0*isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0))
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as SC_PCT,
	(1.0*isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0))
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as CA_PCT,
	(1.0*isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0))
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as '3C_PCT'
	,DLBandWidth_est

into _Tech_Duration_Distribution_acotado
from testinfo t
	inner join _BW_acotado bw on bw.sessionid=t.sessionid and bw.testid=t.testid --Rellenamos solo los test que tengan info en tabla BW
	left join _MOD_3G_acotado m3 on m3.sessionid=t.sessionid and m3.testid=t.testid
	left join _Serving_Info_acotado td on td.sessionid=t.sessionid and td.testid=t.testid
where t.testid > @maxtestid

--Info acotada al momento de la descarga, subida, navegacion y reproduccion, teniendo en cuenta el acceso:
exec sp_lcc_dropifexists '_Tech_Duration_Distribution_acotado_acc'
select t.sessionid, t.testid,
	1.0*isnull(m3.sumDurationDualCarrier_use_U2100,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as DualCarrier_U2100,
	1.0*isnull(m3.sumDurationDualCarrier_use_U900,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as DualCarrier_U900,
	1.0*isnull(m3.sumDurationDualCarrier,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as DualCarrier_3G,
	1.0*isnull(m3.[sumDurationHSPA],0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as HSPA_PCT,		
	1.0*isnull(m3.[sumDurationHSPA+],0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as [HSPA+_PCT],
	1.0*isnull(m3.[sumDurationHSPA_DC],0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as [HSPA_DC_PCT],
	1.0*isnull(m3.[sumDurationHSPA+_DC],0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as [HSPA+_DC_PCT],
	1.0*isnull(bw.DurationLTE_20Mhz_SC,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_20Mhz_SC_PCT,
	1.0*isnull(bw.DurationLTE_15Mhz_SC,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_15Mhz_SC_PCT, 
	1.0*isnull(bw.DurationLTE_10Mhz_SC,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_10Mhz_SC_PCT, 
	1.0*isnull(bw.DurationLTE_5Mhz_SC,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_5Mhz_SC_PCT, 
	1.0*isnull(bw.DurationLTE_40Mhz_CA,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_40Mhz_CA_PCT, 
	1.0*isnull(bw.DurationLTE_35Mhz_CA,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_35Mhz_CA_PCT, 
	1.0*isnull(bw.DurationLTE_30Mhz_CA,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_30Mhz_CA_PCT,
	1.0*isnull(bw.DurationLTE_25Mhz_CA,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_25Mhz_CA_PCT,
	1.0*isnull(bw.DurationLTE_20Mhz_CA,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_20Mhz_CA_PCT, 
	1.0*isnull(bw.DurationLTE_15Mhz_CA,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_15Mhz_CA_PCT,
	1.0*isnull(bw.DurationLTE_60Mhz_3C,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_60Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_55Mhz_3C,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_55Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_50Mhz_3C,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_50Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_45Mhz_3C,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_45Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_40Mhz_3C,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_40Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_35Mhz_3C,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_35Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_30Mhz_3C,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_30Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_25Mhz_3C,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_25Mhz_3C_PCT,
	1.0*isnull(bw.DurationLTE_20Mhz_PCC,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_20Mhz_PCC_PCT, 
	1.0*isnull(bw.DurationLTE_15Mhz_PCC,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_15Mhz_PCC_PCT, 
	1.0*isnull(bw.DurationLTE_10Mhz_PCC,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_10Mhz_PCC_PCT,
	1.0*isnull(bw.DurationLTE_5Mhz_PCC,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_5Mhz_PCC_PCT,
	1.0*isnull(bw.DurationLTE_20Mhz_SCC1,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_20Mhz_SCC1_PCT,
	1.0*isnull(bw.DurationLTE_15Mhz_SCC1,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_15Mhz_SCC1_PCT, 
	1.0*isnull(bw.DurationLTE_10Mhz_SCC1,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_10Mhz_SCC1_PCT,
	1.0*isnull(bw.DurationLTE_5Mhz_SCC1,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_5Mhz_SCC1_PCT,
	1.0*isnull(bw.DurationLTE_20Mhz_SCC2,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_20Mhz_SCC2_PCT, 
	1.0*isnull(bw.DurationLTE_15Mhz_SCC2,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_15Mhz_SCC2_PCT,
	1.0*isnull(bw.DurationLTE_10Mhz_SCC2,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_10Mhz_SCC2_PCT,
	1.0*isnull(bw.DurationLTE_5Mhz_SCC2,0)
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as LTE_5Mhz_SCC2_PCT,
	(1.0*isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0))
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as SC_PCT,
	(1.0*isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0))
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as CA_PCT,
	(1.0*isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0))
			/ nullif(isnull(td.Duration_total_sin_UMTS_LTE,0) + isnull(case when m3.testid is not null then m3.Duration_WCDMA else td.Duration_WCDMA end,0)
			+isnull(bw.DurationLTE_20Mhz_SC,0)+isnull(bw.DurationLTE_15Mhz_SC,0)+isnull(bw.DurationLTE_10Mhz_SC,0)+isnull(bw.DurationLTE_5Mhz_SC,0)
			+isnull(bw.DurationLTE_40Mhz_CA,0)+isnull(bw.DurationLTE_35Mhz_CA,0)+isnull(bw.DurationLTE_30Mhz_CA,0)+isnull(bw.DurationLTE_25Mhz_CA,0)+isnull(bw.DurationLTE_20Mhz_CA,0)+isnull(bw.DurationLTE_15Mhz_CA,0)
			+isnull(bw.DurationLTE_60Mhz_3C,0)+isnull(bw.DurationLTE_55Mhz_3C,0)+isnull(bw.DurationLTE_50Mhz_3C,0)+isnull(bw.DurationLTE_45Mhz_3C,0)+isnull(bw.DurationLTE_40Mhz_3C,0)+isnull(bw.DurationLTE_35Mhz_3C,0)+isnull(bw.DurationLTE_30Mhz_3C,0)+isnull(bw.DurationLTE_25Mhz_3C,0)
			,0) as '3C_PCT'
	,DLBandWidth_est

into _Tech_Duration_Distribution_acotado_acc
from testinfo t
	inner join _BW_acotado_acc bw on bw.sessionid=t.sessionid and bw.testid=t.testid --Rellenamos solo los test que tengan info en tabla BW
	left join _MOD_3G_acotado_acc m3 on m3.sessionid=t.sessionid and m3.testid=t.testid
	left join _Serving_Info_acotado_acc td on td.sessionid=t.sessionid and td.testid=t.testid
where t.testid > @maxtestid


-------------------------------------------------------------------------------------------------------------------------------------
-- Tiempos de TCP 3-Way HandShake
exec sp_lcc_dropifexists '_Syn_HS'
select sessionid, testid, msgtime

into _Syn_HS
from msgethereal
where msg like '%>%80%SYN]%'
and protocol = 'TCP'
and testid > @maxtestid
group by sessionid, testid, msgtime

exec sp_lcc_dropifexists '_Syn_Ack_HS'
select  m.sessionid,
		m.testid, 
		p.msgtime as time_ini,
		m.msgtime as time_fin, 
		datediff (ms, p.msgtime, m.msgtime) as Timediff,
		m.msg,
		row_number() over (partition by m.testid order by m.msgtime asc) as id

into _Syn_Ack_HS
from msgethereal m, _Syn_HS p
where m.msg like '%80%ACK]%' and m.msg not like '%SYN%'
and m.protocol = 'TCP'
and p.testid=m.testid
and m.msgtime>p.msgtime
and m.testid > @maxtestid

exec sp_lcc_dropifexists '_TCP_3WAY_HANDSHAKE'
select sessionid, testid,
		avg(TimeDiff) as TCP_HandShake_Average

into _TCP_3WAY_HANDSHAKE
from _Syn_Ack_HS
where id=1
group by sessionid, testid


--***********************************************************************************************************************
--************************************************ INICIO TABLAS FINALES ************************************************
--***********************************************************************************************************************
select 'INICIO TABLAS FINALES' info

-- (1)
-- *****************************************
------		TABLA FINAL HTTP DL		  ------		select * from Lcc_Data_HTTPTransfer_DL -- _lcc_http_DL	
-- *****************************************
select 'Inicio creacion tabla Lcc_Data_HTTPTransfer_DL' info

--Test con ErrorType <> 'Accessibility', limitamos algunos KPIs al momento de la descarga
insert Lcc_Data_HTTPTransfer_DL
select 
	-- Info general 
	f.CallingModule as MTU,	f.IMEI,	f.CollectionName, LEFT(f.IMSI,3) as MCC, RIGHT(LEFT(f.IMSI,5),2) as MNC, 
	t.startDate, t.startTime, DATEADD(ms, t.duration ,t.startTime) as endTime,			 	
	t.SessionId, f.FileId, t.TestId, t.typeoftest, t.direction, s.info,

	--_lcc_http_DL:
	dl_kpiid.TestType as TestType, '0' as ServiceType,	
	dl_kpiid.[IP Access Time (ms)],	dl_kpiid.DataTransferred,	dl_kpiid.TransferTime,			
	dl_kpiid.ErrorCause as ErrorCause,	dl_kpiid.ErrorType as ErrorType,		
	dl_kpiid.Throughput as Throughput,	null as Throughput_MAX,

	-- PCC:
	thput.DataTransferred_PCC as DataTransferred_PCC,		
	thput.TransferTime_PCC as TransferTime_PCC,
	thput.avgThput_kbps_PCC as Throughput_PCC,	
	thput.maxThput_kbps_PCC as Throughput_MAX_PCC,
		
	-- SCC1:	
	thput.DataTransferred_SCC1 as DataTransferred_SCC1,		
	thput.TransferTime_SCC1 as TransferTime_SCC1,
	thput.avgThput_kbps_SCC1 as Throughput_SCC1,	
	thput.maxThput_kbps_SCC1 as Throughput_MAX_SCC1,
	
	-- SCC2:	
	thput.DataTransferred_SCC2 as DataTransferred_SCC2,		
	thput.TransferTime_SCC2 as TransferTime_SCC2,
	thput.avgThput_kbps_SCC2 as Throughput_SCC2,	
	thput.maxThput_kbps_SCC2 as Throughput_MAX_SCC2,

	-- 3G:	
	thput_rlc.maxRLCDLThrpt as RLC_MAX,	

	-- Technology:		- tech info DL
	-- PCC:
	ISNULL(pctTech.pctLTE, 0) as '% LTE', 	ISNULL(pctTech.pctWCDMA, 0) as '% WCDMA',	ISNULL(pctTech.pctGSM, 0) as '% GSM',
	
	ISNULL(pctTech.pct_F1_U2100, 0) as '% F1 U2100',	ISNULL(pctTech.pct_F2_U2100, 0) as '% F2 U2100',	ISNULL(pctTech.pct_F3_U2100, 0) as '% F3 U2100',
	ISNULL(pctTech.pct_F1_U900, 0) as '% F1 U900',		ISNULL(pctTech.pct_F2_U900, 0) as '% F2 U900',
	
	ISNULL(pctTech.pctUMTS_2100, 0) as '% U2100',	ISNULL(pctTech.pctUMTS_900, 0) as '% U900',		ISNULL(pctTech.pctLTE_2600, 0) as '% LTE2600',
	ISNULL(pctTech.pctLTE_2100, 0) as '% LTE2100',	ISNULL(pctTech.pctLTE_1800, 0) as '% LTE1800',	ISNULL(pctTech.pctLTE_800, 0) as '% LTE800',	
	
	ISNULL(pctTech.pctGMS_DCS, 0) as 'DCS %',	ISNULL(pctTech.pctGSM_GSM, 0) as 'GSM %',	ISNULL(pctTech.pctGSM_EGSM, 0) as 'EGSM %',
	
	ISNULL(pctTech.Roaming_VF, 0) as 'Roaming_VF',ISNULL(pctTech.Roaming_MV, 0) as 'Roaming_MV',ISNULL(pctTech.Roaming_OR, 0) as 'Roaming_OR',ISNULL(pctTech.Roaming_YO, 0) as 'Roaming_YO',
	ISNULL(pctTech.Roaming_U900, 0) as 'Roaming_U900',ISNULL(pctTech.Roaming_U2100, 0) as 'Roaming_U2100',
	ISNULL(pctTech.Roaming_LTE800, 0) as 'Roaming_LTE800',ISNULL(pctTech.Roaming_LTE1800, 0) as 'Roaming_LTE1800',ISNULL(pctTech.Roaming_LTE2100, 0) as 'Roaming_LTE2100',ISNULL(pctTech.Roaming_LTE2600, 0) as 'Roaming_LTE2600',

	ISNULL(pctTech.Duration_Roaming_VF, 0) as 'Duration_roaming_VF',ISNULL(pctTech.Duration_Roaming_MV, 0) as 'Duration_roaming_MV',ISNULL(pctTech.Duration_Roaming_OR, 0) as 'Duration_roaming_OR',ISNULL(pctTech.Duration_Roaming_YO, 0) as 'Duration_roaming_YO',
	ISNULL(pctTech.Duration_Roaming_U900, 0) as 'Duration_roaming_U900',ISNULL(pctTech.Duration_Roaming_U2100, 0) as 'Duration_roaming_U2100',
	ISNULL(pctTech.Duration_Roaming_LTE800, 0) as 'Duration_roaming_LTE800',ISNULL(pctTech.Duration_Roaming_LTE1800, 0) as 'Duration_roaming_LTE1800',ISNULL(pctTech.Duration_Roaming_LTE2100, 0) as 'Duration_roaming_LTE2100',ISNULL(pctTech.Duration_Roaming_LTE2600, 0) as 'Duration_roaming_LTE2600',

	-- SCC1:
	ISNULL(pctTech.pctLTE_2600_SCC1, 0) as '% LTE2600_SCC1', ISNULL(pctTech.pctLTE_2100_SCC1, 0) as '% LTE2100_SCC1', ISNULL(pctTech.pctLTE_1800_SCC1, 0) as '% LTE1800_SCC1', ISNULL(pctTech.pctLTE_800_SCC1, 0) as '% LTE800_SCC1',	

	-- SCC1:
	ISNULL(pctTech.pctLTE_2600_SCC2, 0) as '% LTE2600_SCC2', ISNULL(pctTech.pctLTE_2100_SCC2, 0) as '% LTE2100_SCC2', ISNULL(pctTech.pctLTE_1800_SCC2, 0) as '% LTE1800_SCC2', ISNULL(pctTech.pctLTE_800_SCC2, 0) as '% LTE800_SCC2',	

	---------------------------------			
	-- 3G:
	mod3G.Percent_QPSK as '% QPSK 3G',		mod3G.Percent_16QAM as '% 16QAM 3G',		mod3G.Percent_64QAM as '% 64QAM 3G',		
	mod3G.Average_codes as 'Num Codes',		mod3G.max_codes as 'Max Codes',				
	case when tdd.testid is not null then tdd.DualCarrier_3G else tddServ.DualCarrier_3G end as '% Dual Carrier',			
	case when pctTech.pctWCDMA>0 then (case when mod3G.DualCarrier_use > 0 then 2 else 1 end) end as 'Carriers',
	---------------------------------
	-- 4G:			
	-- CA
	mod4G.[% QPSK] as '% QPSK 4G',	mod4G.[% 16QAM] as '% 16QAM 4G',	mod4G.[% 64QAM] as '% 64QAM 4G',	mod4G.[% 256QAM] as '% 256QAM 4G',
	-- PCC:
	mod4G.[% QPSK PCC] as '% QPSK 4G PCC',	mod4G.[% 16QAM PCC] as '% 16QAM 4G PCC',	mod4G.[% 64QAM PCC] as '% 64QAM 4G PCC',	mod4G.[% 256QAM PCC] as '% 256QAM 4G PCC',
	-- SCC1:
	mod4G.[% QPSK SCC1] as '% QPSK 4G SCC1',	mod4G.[% 16QAM SCC1] as '% 16QAM 4G SCC1',	mod4G.[% 64QAM SCC1] as '% 64QAM 4G SCC1',	mod4G.[% 256QAM SCC1] as '% 256QAM 4G SCC1',
	-- SCC2:
	mod4G.[% QPSK SCC2] as '% QPSK 4G SCC2',	mod4G.[% 16QAM SCC2] as '% 16QAM 4G SCC2',	mod4G.[% 64QAM SCC2] as '% 64QAM 4G SCC2',	mod4G.[% 256QAM SCC2] as '% 256QAM 4G SCC2',
	
	case when tdd.testid is not null then tdd.HSPA_PCT else tddServ.HSPA_PCT end as 'HSPA_PCT',
	case when tdd.testid is not null then tdd.[HSPA+_PCT] else tddServ.[HSPA+_PCT] end as 'HSPA+_PCT',
	case when tdd.testid is not null then tdd.[HSPA_DC_PCT] else tddServ.[HSPA_DC_PCT] end as 'HSPA_DC_PCT',	
	case when tdd.testid is not null then tdd.[HSPA+_DC_PCT] else tddServ.[HSPA+_DC_PCT] end as 'HSPA+_DC_PCT',		
	-- SC
	case when tdd.testid is not null then tdd.LTE_5Mhz_SC_PCT else tddServ.LTE_5Mhz_SC_PCT end as '5Mhz Bandwidth % SC', 
	case when tdd.testid is not null then tdd.LTE_10Mhz_SC_PCT else tddServ.LTE_10Mhz_SC_PCT end as '10Mhz Bandwidth % SC',	
	case when tdd.testid is not null then tdd.LTE_15Mhz_SC_PCT else tddServ.LTE_15Mhz_SC_PCT end as '15Mhz Bandwidth % SC',	
	case when tdd.testid is not null then tdd.LTE_20Mhz_SC_PCT else tddServ.LTE_20Mhz_SC_PCT end as '20Mhz Bandwidth % SC',
	-- CA
	case when tdd.testid is not null then tdd.LTE_15Mhz_CA_PCT else tddServ.LTE_15Mhz_CA_PCT end as '15Mhz Bandwidth % CA',	
	case when tdd.testid is not null then tdd.LTE_20Mhz_CA_PCT else tddServ.LTE_20Mhz_CA_PCT end as '20Mhz Bandwidth % CA',	
	case when tdd.testid is not null then tdd.LTE_25Mhz_CA_PCT else tddServ.LTE_25Mhz_CA_PCT end as '25Mhz Bandwidth % CA',
	case when tdd.testid is not null then tdd.LTE_30Mhz_CA_PCT else tddServ.LTE_30Mhz_CA_PCT end as '30Mhz Bandwidth % CA',	
	case when tdd.testid is not null then tdd.LTE_35Mhz_CA_PCT else tddServ.LTE_35Mhz_CA_PCT end as '35Mhz Bandwidth % CA',	
	case when tdd.testid is not null then tdd.LTE_40Mhz_CA_PCT else tddServ.LTE_40Mhz_CA_PCT end as '40Mhz Bandwidth % CA',
	-- 3C
	case when tdd.testid is not null then tdd.LTE_25Mhz_3C_PCT else tddServ.LTE_25Mhz_3C_PCT end as '25Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_30Mhz_3C_PCT else tddServ.LTE_30Mhz_3C_PCT end as '30Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_35Mhz_3C_PCT else tddServ.LTE_35Mhz_3C_PCT end as '35Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_40Mhz_3C_PCT else tddServ.LTE_40Mhz_3C_PCT end as '40Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_45Mhz_3C_PCT else tddServ.LTE_45Mhz_3C_PCT end as '45Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_50Mhz_3C_PCT else tddServ.LTE_50Mhz_3C_PCT end as '50Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_55Mhz_3C_PCT else tddServ.LTE_55Mhz_3C_PCT end as '55Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_60Mhz_3C_PCT else tddServ.LTE_60Mhz_3C_PCT end as '60Mhz Bandwidth % 3C',
	
	--PCC
	case when tdd.testid is not null then tdd.LTE_5Mhz_PCC_PCT else tddServ.LTE_5Mhz_PCC_PCT end as '5Mhz Bandwidth PCC %', 
	case when tdd.testid is not null then tdd.LTE_10Mhz_PCC_PCT else tddServ.LTE_10Mhz_PCC_PCT end as '10Mhz Bandwidth PCC %', 
	case when tdd.testid is not null then tdd.LTE_15Mhz_PCC_PCT else tddServ.LTE_15Mhz_PCC_PCT end as '15Mhz Bandwidth PCC %', 
	case when tdd.testid is not null then tdd.LTE_20Mhz_PCC_PCT else tddServ.LTE_20Mhz_PCC_PCT end as '20Mhz Bandwidth PCC %',
	--SCC1
	case when tdd.testid is not null then tdd.LTE_5Mhz_SCC1_PCT else tddServ.LTE_5Mhz_SCC1_PCT end as '5Mhz Bandwidth SCC1 %',
	case when tdd.testid is not null then tdd.LTE_10Mhz_SCC1_PCT else tddServ.LTE_10Mhz_SCC1_PCT end as '10Mhz Bandwidth SCC1 %', 
	case when tdd.testid is not null then tdd.LTE_15Mhz_SCC1_PCT else tddServ.LTE_15Mhz_SCC1_PCT end as '15Mhz Bandwidth SCC1 %', 
	case when tdd.testid is not null then tdd.LTE_20Mhz_SCC1_PCT else tddServ.LTE_20Mhz_SCC1_PCT end as '20Mhz Bandwidth SCC1 %',
	--SCC2
	case when tdd.testid is not null then tdd.LTE_5Mhz_SCC2_PCT else tddServ.LTE_5Mhz_SCC2_PCT end as '5Mhz Bandwidth SCC2 %', 
	case when tdd.testid is not null then tdd.LTE_10Mhz_SCC2_PCT else tddServ.LTE_10Mhz_SCC2_PCT end as '10Mhz Bandwidth SCC2 %', 
	case when tdd.testid is not null then tdd.LTE_15Mhz_SCC2_PCT else tddServ.LTE_15Mhz_SCC2_PCT end as '15Mhz Bandwidth SCC2 %', 
	case when tdd.testid is not null then tdd.LTE_20Mhz_SCC2_PCT else tddServ.LTE_20Mhz_SCC2_PCT end as '20Mhz Bandwidth SCC2 %',
	---------------							
	-- Performance:	
	-- 3G:
	cqi3G.CQI as 'CQI 3G',
	100.0*hs3G.hscch_use as '% SCCH',		hq.NumHarqProc_avg as 'Procesos HARQ',	
	cqi3G.avgBLER as 'BLER DSCH',			100.0*cqi3G.numDtx_DL as 'DTX DSCH',	100.0*cqi3G.NumAck_DL as 'ACKs',		100.0*cqi3G.NumNack_DL as '% NACKs',			
	mod3G.avgRateRetransmissions as 'Retrx DSCH',		'' as 'RETRX MAC',												
	thput_rlc.AvgRLCDLBLER as 'BLER RLC',	thput_rlc.AvgRLCDLThrpt as 'RLC Thput',

	-- 4G:
	rbs.Rbs_round_pond as 'RBs',	rbs.maxRBs as 'Max RBs',	rbs.minRBs as 'Min RBs',	rbs.Rbs_dedicated_round_pond as 'RBs When Allocated',	
	
	-- ni idea de como se coge
	tm.percTM0 as '% TM Invalid',
	tm.percTM1 as '% TM 1: Single Antenna Port 0 ',	
	tm.percTM2 as '% TM 2: TD Rank 1',	
	tm.percTM3 as '% TM 3: OL SM',
	tm.percTM4 as '% TM 4: CL SM',
	tm.percTM5 as '% TM 5: MU MIMO',	
	tm.percTM6 as '% TM 6: CL RANK1 PC',	
	tm.percTM7 as '% TM 7: Single Antenna Port 5',
	tm.percTMunknown as '% TM Unknown',    
	
	rbs.Percent_LTESharedChannelUse as 'Shared channel use',	 
			
	-- PCC:
	rbs_c.Rbs_round_PCC as 'RBs PCC',	rbs_c.maxRBs_PCC as 'Max RBs PCC',	rbs_c.minRBs_PCC as 'Min RBs PCC',	rbs_c.Rbs_dedicated_round_PCC as 'RBs When Allocated PCC',	
	
	tm.[percTM0 PCC] as '% TM Invalid PCC',
	tm.[percTM1 PCC] as '% TM 1: Single Antenna Port 0 PCC',	
	tm.[percTM2 PCC] as '% TM 2: TD Rank 1 PCC',	
	tm.[percTM3 PCC] as '% TM 3: OL SM PCC',
	tm.[percTM4 PCC] as '% TM 4: CL SM PCC',
	tm.[percTM5 PCC] as '% TM 5: MU MIMO PCC',	
	tm.[percTM6 PCC] as '% TM 6: CL RANK1 PC PCC',	
	tm.[percTM7 PCC] as '% TM 7: Single Antenna Port 5 PCC',
	tm.[percTMunknown PCC] as '% TM Unknown PCC',   

	-- ERC: Se cambia el calculo de los CQIs
	cqi4G.avgCQI_PCC as 'CQI 4G PCC',		
	--cqi4G.AverageRI_PCC as 'Rank Indicator PCC',	
		
	-- SCC1:
	rbs_c.Rbs_round_SCC1 as 'RBs SCC1',
	rbs_c.maxRBs_SCC1 as 'Max RBs SCC1',
	rbs_c.minRBs_SCC1 as 'Min RBs SCC1',
	rbs_c.Rbs_dedicated_round_SCC1 as 'RBs When Allocated SCC1',	
	
	tm.[percTM0 SCC1] as '% TM Invalid SCC1',
	tm.[percTM1 SCC1] as '% TM 1: Single Antenna Port 0 SCC1',	
	tm.[percTM2 SCC1] as '% TM 2: TD Rank 1 SCC1',	
	tm.[percTM3 SCC1] as '% TM 3: OL SM SCC1',
	tm.[percTM4 SCC1] as '% TM 4: CL SM SCC1',
	tm.[percTM5 SCC1] as '% TM 5: MU MIMO SCC1',	
	tm.[percTM6 SCC1] as '% TM 6: CL RANK1 PC SCC1',	
	tm.[percTM7 SCC1] as '% TM 7: Single Antenna Port 5 SCC1',
	tm.[percTMunknown SCC1] as '% TM Unknown SCC1',   

	cqi4G.avgCQI_SCC1 as 'CQI 4G SCC1',		
	--cqi4G.AverageRI_SCC1 as 'Rank Indicator SCC1',	
	
	-- SCC2:
	rbs_c.Rbs_round_SCC2 as 'RBs SCC2',
	rbs_c.maxRBs_SCC2 as 'Max RBs SCC2',
	rbs_c.minRBs_SCC2 as 'Min RBs SCC2',
	rbs_c.Rbs_dedicated_round_SCC2 as 'RBs When Allocated SCC2',	
	
	tm.[percTM0 SCC2] as '% TM Invalid SCC2',
	tm.[percTM1 SCC2] as '% TM 1: Single Antenna Port 0 SCC2',	
	tm.[percTM2 SCC2] as '% TM 2: TD Rank 1 SCC2',	
	tm.[percTM3 SCC2] as '% TM 3: OL SM SCC2',
	tm.[percTM4 SCC2] as '% TM 4: CL SM SCC2',
	tm.[percTM5 SCC2] as '% TM 5: MU MIMO SCC2',	
	tm.[percTM6 SCC2] as '% TM 6: CL RANK1 PC SCC2',	
	tm.[percTM7 SCC2] as '% TM 7: Single Antenna Port 5 SCC2',
	tm.[percTMunknown SCC2] as '% TM Unknown SCC2',   

	cqi4G.avgCQI_SCC2 as 'CQI 4G SCC2',		
	--cqi4G.AverageRI_SCC2 as 'Rank Indicator SCC2',	
	
	-- INFO RADIO:
	tra.RxLev, 	tra.RxQual, 
	tri.BCCH as BCCH_Ini, tri.BSIC as BSIC_Ini, tri.RxLev as RxLev_Ini, tri.RxQual as RxQual_Ini, 
	trf.BCCH as BCCH_Fin, trf.BSIC as BSIC_Fin,	trf.RxLev as RxLev_Fin,	trf.RxQual as RxQual_Fin,
	tra.RxLev_min, tra.RxQual_min,
	tra.RSCP as 'RSCP_avg',	tra.EcIo as 'EcI0_avg',
	tri.PSC as PSC_Ini,	tri.RSCP as RSCP_Ini, tri.EcIo as EcIo_Ini,	tri.UARFCN as UARFCN_Ini,
	trf.PSC as PSC_Fin,	trf.RSCP as RSCP_Fin, trf.EcIo as EcIo_Fin,	trf.UARFCN as UARFCN_Fin,
	tra.RSCP_min, tra.EcIo_min,
	tra.RSRP as 'RSRP_avg', tra.RSRQ as 'RSRQ_avg', tra.SINR as 'SINR_avg',
	tri.PCI as PCI_Ini,	tri.RSRP as RSRP_Ini, tri.RSRQ as RSRQ_Ini,	tri.SINR as SINR_Ini, tri.EARFCN as EARFCN_Ini,
	trf.PCI as PCI_Fin,	trf.RSRP as RSRP_Fin, trf.RSRQ as RSRQ_Fin, trf.SINR as SINR_Fin, trf.EARFCN as EARFCN_Fin,
	tri.CId as CellId_Ini, tri.LAC as 'LAC/TAC_Ini', tri.RNCID as RNC_Ini,
	trf.CId as CellId_Fin, trf.LAC as 'LAC/TAC_Fin', trf.RNCID as RNC_Fin,

	-- INFO PARCELA:
	tri.longitude as 'Longitud Inicial',	tri.latitude as 'Latitud Inicial',	
	trf.longitude as 'Longitud Final',		trf.latitude as 'Latitud Final',

	-- @DGP: uso de CA
	--rbs_c.[Blocks_NoCA],	
	--rbs_c.[Blocks_CA],	
	null as [Blocks_NoCA],
	null as [Blocks_CA],
	
	--Si se recoge informacion de BW calculamos SC/CA/3C de alli, sino de la tabla physical
	case when tdd.testid is not null then tdd.SC_PCT else ca.[% SC] end as [% SC],
	case when tdd.testid is not null then tdd.CA_PCT else ca.[% CA] end as [% CA],
	case when tdd.testid is not null then tdd.[3C_PCT] else ca.[% 3C] end as [% 3C],
		
	-- @ERC: Valores calculados a la antigua que se mantienen en caso de querer info en los test fallidos (KPIID no se rellena en esos casos)
	--CAC 10/08/2017: se incorpora información análoga para test de NC
	case when TestType = 'DL_CE' then thput_Transf.[ThputApp_nu] else thput_Transf_NC.[ThputApp_nu_DL] end as [ThputApp_nu],		
	case when TestType = 'DL_CE' then thput_Transf.[DataTransferred_nu] else thput_Transf_NC.[DataTransferred_nu_DL] end as [DataTransferred_nu],		
	case when TestType = 'DL_CE' then thput_Transf.[SessionTime_nu] else thput_Transf_NC.[SessionTime_nu] end as [SessionTime_nu],	
	case when TestType = 'DL_CE' then thput_Transf.[TransferTime_nu] else thput_Transf_NC.[TransferTime_nu] end as [TransferTime_nu],	
	case when TestType = 'DL_CE' then 1000.0*thput_Transf.[IPAccessTime_nu] else 1000.0*thput_Transf_NC.[IPAccessTime_nu] end as [IPAccessTime_sec_nu],	
		
	-- @ERC: Se añade info de tecnologia inicio/fin para añadir en el reporte
	tri.Tech_Ini,	trf.Tech_Fin,		
	
	case when tdd.testid is not null then tdd.DualCarrier_U2100 else tddServ.DualCarrier_U2100 end as '% Dual Carrier U2100',	
	case when tdd.testid is not null then tdd.DualCarrier_U900 else tddServ.DualCarrier_U900 end as '% Dual Carrier U900',
	
	-- @DGP: Se añade la interferencia UL media
	ulint.UL_Interference, 

	-- @ERC: KPIID de P3 - de momento asi, mas adelante (cd funcionen los kpiid) la suma del transfer, dns e ip access
	nullif(dl_kpiid.[SessionTime],0) as SessionTime,
	pdp.PDP_Activate_Ratio,
	pag.Paging_Success_Ratio,
	neigh.EARFCN_N1,		neigh.PCI_N1,			neigh.RSRP_N1,			neigh.RSRQ_N1,
	ho4G.num_HO_S1X2,
	ho4G.duration_S1X2_avg,
	ho4G.S1X2HO_SR,
	win.Max_Win as Max_Window_Size,
	
	tcphs.TCP_HandShake_Average,

	--@CAC: CQI por tecnologia; ERC: Se cambia el calculo del CQI
	cqi3G.CQI_UMTS900 as 'CQI UMTS900',		cqi3G.CQI_UMTS2100 as 'CQI UMTS2100',	
	--cqi4G.avgCQI_LTE2600 as 'CQI LTE2600',	cqi4G.avgCQI_LTE1800 as 'CQI LTE1800',
	--cqi4G.avgCQI_LTE800 as 'CQI LTE800',	cqi4G.avgCQI_LTE2100 as 'CQI LTE2100',
	null as 'CQI LTE2600',	null as 'CQI LTE1800',
	null as 'CQI LTE800',	null as 'CQI LTE2100',
	f.IMSI,

	--@ERC: MIMO y RI:
	cqi4G.perc_MIMO as '% MIMO',
	cqi4G.perc_RI2_TM2 as '% RI2_TM2',
	cqi4G.perc_RI2_TM3 as '% RI2_TM3',
	cqi4G.perc_RI2_TM4 as '% RI2_TM4',

	cqi4G.perc_MIMO_PCC as '% MIMO_PCC',
	cqi4G.perc_RI2_TM2_PCC as '% RI2_TM2_PCC',
	cqi4G.perc_RI2_TM3_PCC as '% RI2_TM3_PCC',
	cqi4G.perc_RI2_TM4_PCC as '% RI2_TM4_PCC',

	cqi4G.perc_MIMO_SCC1 as '% MIMO_SCC1',
	cqi4G.perc_RI2_TM2_SCC1 as '% RI2_TM2_SCC1',
	cqi4G.perc_RI2_TM3_SCC1 as '% RI2_TM3_SCC1',
	cqi4G.perc_RI2_TM4_SCC1 as '% RI2_TM4_SCC1',

	cqi4G.perc_MIMO_SCC2 as '% MIMO_SCC2',
	cqi4G.perc_RI2_TM2_SCC2 as '% RI2_TM2_SCC2',
	cqi4G.perc_RI2_TM3_SCC2 as '% RI2_TM3_SCC2',
	cqi4G.perc_RI2_TM4_SCC2 as '% RI2_TM4_SCC2',

	cqi4G.perc_RI1 as '% RI1',
	cqi4G.perc_RI2 as '% RI2',

	cqi4G.perc_RI1_PCC as '% RI1_PCC',
	cqi4G.perc_RI2_PCC as '% RI2_PCC',

	cqi4G.perc_RI1_SCC1 as '% RI1_SCC1',
	cqi4G.perc_RI2_SCC1 as '% RI2_SCC1',

	cqi4G.perc_RI1_SCC2 as '% RI1_SCC2',
	cqi4G.perc_RI2_SCC2 as '% RI2_SCC2',

	--ERC: Se añaden nuevos campos por el cambio del CQI
	cqi4G.avgCQI as 'CQI 4G',

	cqi4G.avgCQI_PCC_LTE2600	as 'CQI LTE2600 PCC',	cqi4G.avgCQI_PCC_LTE1800 as 'CQI LTE1800 PCC',
	cqi4G.avgCQI_PCC_LTE800		as 'CQI LTE800 PCC',	cqi4G.avgCQI_PCC_LTE2100 as 'CQI LTE2100 PCC',

	--cqi4G.avgCQI_SCC1_LTE2600 as 'CQI LTE2600 SCC1',	cqi4G.avgCQI_SCC1_LTE1800 as 'CQI LTE1800 SCC1',
	--cqi4G.avgCQI_SCC1_LTE800	as 'CQI LTE800 SCC1',	cqi4G.avgCQI_SCC1_LTE2100 as 'CQI LTE2100 SCC1',

	--cqi4G.avgCQI_SCC2_LTE2600 as 'CQI LTE2600 SCC2',	cqi4G.avgCQI_SCC2_LTE1800 as 'CQI LTE1800 SCC2',
	--cqi4G.avgCQI_SCC2_LTE800	as 'CQI LTE800 SCC2',	cqi4G.avgCQI_SCC2_LTE2100 as 'CQI LTE2100 SCC2', 

	null as 'CQI LTE2600 SCC1',	null as 'CQI LTE1800 SCC1',
	null as 'CQI LTE800 SCC1',	null as 'CQI LTE2100 SCC1',

	null as 'CQI LTE2600 SCC2',	null as 'CQI LTE1800 SCC2',
	null as 'CQI LTE800 SCC2',	null as 'CQI LTE2100 SCC2',

	-- 20170321 - @ERC: Nuevos KPis y parametros:
	f.ASideDevice, f.BSideDevice, f.SWVersion,

	tdd.HSPA_PCT as 'HSPA_PCT real',
	tdd.[HSPA+_PCT] as 'HSPA+_PCT real',
	tdd.[HSPA_DC_PCT] as 'HSPA_DC_PCT real',
	tdd.[HSPA+_DC_PCT] as 'HSPA+_DC_PCT real',
	-- SC
	tdd.LTE_5Mhz_SC_PCT as '5Mhz Bandwidth % SC real ', 
	tdd.LTE_10Mhz_SC_PCT as '10Mhz Bandwidth % SC real ',	
	tdd.LTE_15Mhz_SC_PCT as '15Mhz Bandwidth % SC real ',	
	tdd.LTE_20Mhz_SC_PCT as '20Mhz Bandwidth % SC real ',
	-- CA
	tdd.LTE_15Mhz_CA_PCT as '15Mhz Bandwidth % CA real ',	
	tdd.LTE_20Mhz_CA_PCT as '20Mhz Bandwidth % CA real ',	
	tdd.LTE_25Mhz_CA_PCT as '25Mhz Bandwidth % CA real ',
	tdd.LTE_30Mhz_CA_PCT as '30Mhz Bandwidth % CA real ',	
	tdd.LTE_35Mhz_CA_PCT as '35Mhz Bandwidth % CA real ',	
	tdd.LTE_40Mhz_CA_PCT as '40Mhz Bandwidth % CA real ',
	-- 3C
	tdd.LTE_25Mhz_3C_PCT as '25Mhz Bandwidth % 3C real ',	
	tdd.LTE_30Mhz_3C_PCT as '30Mhz Bandwidth % 3C real ',	
	tdd.LTE_35Mhz_3C_PCT as '35Mhz Bandwidth % 3C real ',	
	tdd.LTE_40Mhz_3C_PCT as '40Mhz Bandwidth % 3C real ',	
	tdd.LTE_45Mhz_3C_PCT as '45Mhz Bandwidth % 3C real ',	
	tdd.LTE_50Mhz_3C_PCT as '50Mhz Bandwidth % 3C real ',	
	tdd.LTE_55Mhz_3C_PCT as '55Mhz Bandwidth % 3C real ',	
	tdd.LTE_60Mhz_3C_PCT as '60Mhz Bandwidth % 3C real ',

	--PCC
	tdd.LTE_5Mhz_PCC_PCT as '5Mhz Bandwidth PCC % real ', 
	tdd.LTE_10Mhz_PCC_PCT as '10Mhz Bandwidth PCC % real ', 
	tdd.LTE_15Mhz_PCC_PCT as '15Mhz Bandwidth PCC % real ', 
	tdd.LTE_20Mhz_PCC_PCT as '20Mhz Bandwidth PCC % real ',
	--SCC1
	tdd.LTE_5Mhz_SCC1_PCT as '5Mhz Bandwidth SCC1 % real ', 
	tdd.LTE_10Mhz_SCC1_PCT as '10Mhz Bandwidth SCC1 % real ', 
	tdd.LTE_15Mhz_SCC1_PCT as '15Mhz Bandwidth SCC1 % real ', 
	tdd.LTE_20Mhz_SCC1_PCT as '20Mhz Bandwidth SCC1 % real ',
	--SCC2
	tdd.LTE_5Mhz_SCC2_PCT as '5Mhz Bandwidth SCC2 % real ',
	tdd.LTE_10Mhz_SCC2_PCT as '10Mhz Bandwidth SCC2 % real ', 
	tdd.LTE_15Mhz_SCC2_PCT as '15Mhz Bandwidth SCC2 % real ', 
	tdd.LTE_20Mhz_SCC2_PCT as '20Mhz Bandwidth SCC2 % real ',

	tdd.DLBandWidth_est as 'BW_PCC_est',
	null as 'Info_Update'

--into Lcc_Data_HTTPTransfer_DL
from 
	FileList f,	Sessions s, TestInfo t
	-- COMUNES:
		LEFT OUTER JOIN _PCT_TECH_Data_acotado		pctTech		on pctTech.TestId=t.TestId and pctTech.SessionId=t.SessionId
		LEFT OUTER JOIN _lcc_http_DL	dl_kpiid	on dl_kpiid.testid=t.testid and dl_kpiid.sessionid=t.SessionId
		LEFT OUTER JOIN _THPUT thput				on (t.SessionId=thput.SessionId and t.TestId=thput.testid and thput.direction='Downlink')	
		LEFT OUTER JOIN _THPUT_Transf thput_Transf	on (t.SessionId=thput_Transf.SessionId and t.TestId=thput_Transf.testid)		
		--CAC 10/08/2017: se incorpora información análoga para test de NC
		LEFT OUTER JOIN _THPUT_Transf_NC thput_Transf_NC on (t.SessionId=thput_Transf_NC.SessionId and t.TestId=thput_Transf_NC.testid)
		LEFT OUTER JOIN _THPUT_RLC		thput_rlc		on (t.SessionId=thput_rlc.SessionId and t.TestId=thput_rlc.testid)	
			
		LEFT OUTER JOIN _TECH_RADIO_INI_Data	tri	on (t.SessionId=tri.SessionId and t.TestId=tri.testid)
		LEFT OUTER JOIN _TECH_RADIO_FIN_Data	trf	on (t.SessionId=trf.SessionId and t.TestId=trf.testid)
		LEFT OUTER JOIN _TECH_RADIO_AVG_Data	tra	on (t.SessionId=tra.SessionId and t.TestId=tra.testid)

	-- 3G:	
		LEFT OUTER JOIN _CQI_3G_acotado cqi3G		on cqi3G.TestId=t.TestId and cqi3G.SessionId=t.SessionId
		LEFT OUTER JOIN _scch_use_3G hs3G	on hs3G.TestId=t.TestId and hs3G.SessionId=t.SessionId
		LEFT OUTER JOIN _MOD_3G_acotado mod3G		on mod3G.TestId=t.TestId and mod3G.SessionId=t.SessionId
		LEFT OUTER JOIN _HARQ hq			on hq.TestId=t.TestId and hq.SessionId=t.SessionId
		LEFT OUTER JOIN _UL_Int ulint		on ulint.TestId=t.TestId and ulint.SessionId=t.SessionId
	-- 4G:		
		LEFT OUTER JOIN _MOD_4G mod4G			on (t.SessionId=mod4G.SessionId and t.TestId=mod4G.testid and mod4G.direction='Downlink') 
		LEFT OUTER JOIN _cqi_4G_acotado cqi4G			on (t.SessionId=cqi4G.SessionId and t.TestId=cqi4G.testid)
		LEFT OUTER JOIN _RBs_carrier_DL rbs_c	on (t.SessionId=rbs_c.SessionId and t.TestId=rbs_c.testid and rbs_c.direction='Downlink') 
		LEFT OUTER JOIN _RBs_DL rbs				on (t.SessionId=rbs.SessionId and t.TestId=rbs.testid and rbs.direction='Downlink') 
		LEFT OUTER JOIN _TM_DL tm				on (t.SessionId=tm.SessionId and t.TestId=tm.testid and tm.direction='Downlink')

	-- KPI EXTRA:
		LEFT OUTER JOIN _PDP pdp		on pdp.TestId=t.TestId and pdp.SessionId=t.SessionId
		LEFT OUTER JOIN _Paging pag		on pag.TestId=t.TestId and pag.SessionId=t.SessionId
		LEFT OUTER JOIN _NEIGH neigh		on neigh.TestId=t.TestId and neigh.SessionId=t.SessionId
		LEFT OUTER JOIN _4GHO ho4G			on ho4G.TestId=t.TestId and ho4G.SessionId=t.SessionId		
		LEFT OUTER JOIN _Window win			on win.TestId=t.TestId and win.SessionId=t.SessionId	
	--OSP:

		LEFT OUTER JOIN _Tech_Duration_Distribution_acotado tdd		on (tdd.sessionid=t.sessionid and tdd.testid=t.testid)
		LEFT OUTER JOIN _Tech_Duration_Distribution_acotado_Serv tddServ		on (tddServ.sessionid=t.sessionid and tddServ.testid=t.testid)
		LEFT OUTER JOIN _TCP_3WAY_HANDSHAKE tcphs			on (tcphs.sessionid=t.sessionid and tcphs.testid=t.testid)

	--
		LEFT OUTER JOIN _Carrier ca				on (t.SessionId=ca.SessionId and t.TestId=ca.testid) 
	
	
where 
	t.SessionId=s.SessionId and s.FileId=f.FileId
	and s.sessionType='data' 
	and t.typeoftest in ('HTTPTransfer','Capacity') and t.direction='Downlink'
	and s.valid=1 and t.valid=1
	and (ErrorType is null or ErrorType<>'Accessibility')

	and t.testid > @maxTestid_DL
	and RIGHT(LEFT(f.IMSI,5),2) in (1,7,3,4)
order by f.FileId, t.SessionId, t.TestId

--Test con ErrorType = 'Accessibility' tenemos en cuenta el acceso
insert Lcc_Data_HTTPTransfer_DL
select 
	-- Info general 
	f.CallingModule as MTU,	f.IMEI,	f.CollectionName, LEFT(f.IMSI,3) as MCC, RIGHT(LEFT(f.IMSI,5),2) as MNC, 
	t.startDate, t.startTime, DATEADD(ms, t.duration ,t.startTime) as endTime,			 	
	t.SessionId, f.FileId, t.TestId, t.typeoftest, t.direction, s.info,

	--_lcc_http_DL:
	dl_kpiid.TestType as TestType, '0' as ServiceType,	
	dl_kpiid.[IP Access Time (ms)],	dl_kpiid.DataTransferred,	dl_kpiid.TransferTime,			
	dl_kpiid.ErrorCause as ErrorCause,	dl_kpiid.ErrorType as ErrorType,		
	dl_kpiid.Throughput as Throughput,	null as Throughput_MAX,

	-- PCC:
	thput.DataTransferred_PCC as DataTransferred_PCC,		
	thput.TransferTime_PCC as TransferTime_PCC,
	thput.avgThput_kbps_PCC as Throughput_PCC,	
	thput.maxThput_kbps_PCC as Throughput_MAX_PCC,
		
	-- SCC1:	
	thput.DataTransferred_SCC1 as DataTransferred_SCC1,		
	thput.TransferTime_SCC1 as TransferTime_SCC1,
	thput.avgThput_kbps_SCC1 as Throughput_SCC1,	
	thput.maxThput_kbps_SCC1 as Throughput_MAX_SCC1,
	
	-- SCC2:	
	thput.DataTransferred_SCC2 as DataTransferred_SCC2,		
	thput.TransferTime_SCC2 as TransferTime_SCC2,
	thput.avgThput_kbps_SCC2 as Throughput_SCC2,	
	thput.maxThput_kbps_SCC2 as Throughput_MAX_SCC2,

	-- 3G:	
	thput_rlc.maxRLCDLThrpt as RLC_MAX,	

	-- Technology:		- tech info DL
	-- PCC:
	ISNULL(pctTech.pctLTE, 0) as '% LTE', 	ISNULL(pctTech.pctWCDMA, 0) as '% WCDMA',	ISNULL(pctTech.pctGSM, 0) as '% GSM',
	
	ISNULL(pctTech.pct_F1_U2100, 0) as '% F1 U2100',	ISNULL(pctTech.pct_F2_U2100, 0) as '% F2 U2100',	ISNULL(pctTech.pct_F3_U2100, 0) as '% F3 U2100',
	ISNULL(pctTech.pct_F1_U900, 0) as '% F1 U900',		ISNULL(pctTech.pct_F2_U900, 0) as '% F2 U900',
	
	ISNULL(pctTech.pctUMTS_2100, 0) as '% U2100',	ISNULL(pctTech.pctUMTS_900, 0) as '% U900',		ISNULL(pctTech.pctLTE_2600, 0) as '% LTE2600',
	ISNULL(pctTech.pctLTE_2100, 0) as '% LTE2100',	ISNULL(pctTech.pctLTE_1800, 0) as '% LTE1800',	ISNULL(pctTech.pctLTE_800, 0) as '% LTE800',	
	
	ISNULL(pctTech.pctGMS_DCS, 0) as 'DCS %',	ISNULL(pctTech.pctGSM_GSM, 0) as 'GSM %',	ISNULL(pctTech.pctGSM_EGSM, 0) as 'EGSM %',
	
	ISNULL(pctTech.Roaming_VF, 0) as 'Roaming_VF',ISNULL(pctTech.Roaming_MV, 0) as 'Roaming_MV',ISNULL(pctTech.Roaming_OR, 0) as 'Roaming_OR',ISNULL(pctTech.Roaming_YO, 0) as 'Roaming_YO',
	ISNULL(pctTech.Roaming_U900, 0) as 'Roaming_U900',ISNULL(pctTech.Roaming_U2100, 0) as 'Roaming_U2100',
	ISNULL(pctTech.Roaming_LTE800, 0) as 'Roaming_LTE800',ISNULL(pctTech.Roaming_LTE1800, 0) as 'Roaming_LTE1800',ISNULL(pctTech.Roaming_LTE2100, 0) as 'Roaming_LTE2100',ISNULL(pctTech.Roaming_LTE2600, 0) as 'Roaming_LTE2600',

	ISNULL(pctTech.Duration_Roaming_VF, 0) as 'Duration_roaming_VF',ISNULL(pctTech.Duration_Roaming_MV, 0) as 'Duration_roaming_MV',ISNULL(pctTech.Duration_Roaming_OR, 0) as 'Duration_roaming_OR',ISNULL(pctTech.Duration_Roaming_YO, 0) as 'Duration_roaming_YO',
	ISNULL(pctTech.Duration_Roaming_U900, 0) as 'Duration_roaming_U900',ISNULL(pctTech.Duration_Roaming_U2100, 0) as 'Duration_roaming_U2100',
	ISNULL(pctTech.Duration_Roaming_LTE800, 0) as 'Duration_roaming_LTE800',ISNULL(pctTech.Duration_Roaming_LTE1800, 0) as 'Duration_roaming_LTE1800',ISNULL(pctTech.Duration_Roaming_LTE2100, 0) as 'Duration_roaming_LTE2100',ISNULL(pctTech.Duration_Roaming_LTE2600, 0) as 'Duration_roaming_LTE2600',

	-- SCC1:
	ISNULL(pctTech.pctLTE_2600_SCC1, 0) as '% LTE2600_SCC1', ISNULL(pctTech.pctLTE_2100_SCC1, 0) as '% LTE2100_SCC1', ISNULL(pctTech.pctLTE_1800_SCC1, 0) as '% LTE1800_SCC1', ISNULL(pctTech.pctLTE_800_SCC1, 0) as '% LTE800_SCC1',	

	-- SCC1:
	ISNULL(pctTech.pctLTE_2600_SCC2, 0) as '% LTE2600_SCC2', ISNULL(pctTech.pctLTE_2100_SCC2, 0) as '% LTE2100_SCC2', ISNULL(pctTech.pctLTE_1800_SCC2, 0) as '% LTE1800_SCC2', ISNULL(pctTech.pctLTE_800_SCC2, 0) as '% LTE800_SCC2',	

	---------------------------------			
	-- 3G:
	mod3G.Percent_QPSK as '% QPSK 3G',		mod3G.Percent_16QAM as '% 16QAM 3G',		mod3G.Percent_64QAM as '% 64QAM 3G',		
	mod3G.Average_codes as 'Num Codes',		mod3G.max_codes as 'Max Codes',				case when tdd.testid is not null then tdd.DualCarrier_3G else tddServ.DualCarrier_3G end as '% Dual Carrier',			
	case when pctTech.pctWCDMA>0 then (case when mod3G.DualCarrier_use > 0 then 2 else 1 end) end as 'Carriers',
	---------------------------------
	-- 4G:			
	-- CA
	mod4G.[% QPSK] as '% QPSK 4G',	mod4G.[% 16QAM] as '% 16QAM 4G',	mod4G.[% 64QAM] as '% 64QAM 4G',	mod4G.[% 256QAM] as '% 256QAM 4G',
	-- PCC:
	mod4G.[% QPSK PCC] as '% QPSK 4G PCC',	mod4G.[% 16QAM PCC] as '% 16QAM 4G PCC',	mod4G.[% 64QAM PCC] as '% 64QAM 4G PCC',	mod4G.[% 256QAM PCC] as '% 256QAM 4G PCC',
	-- SCC1:
	mod4G.[% QPSK SCC1] as '% QPSK 4G SCC1',	mod4G.[% 16QAM SCC1] as '% 16QAM 4G SCC1',	mod4G.[% 64QAM SCC1] as '% 64QAM 4G SCC1',	mod4G.[% 256QAM SCC1] as '% 256QAM 4G SCC1',
	-- SCC2:
	mod4G.[% QPSK SCC2] as '% QPSK 4G SCC2',	mod4G.[% 16QAM SCC2] as '% 16QAM 4G SCC2',	mod4G.[% 64QAM SCC2] as '% 64QAM 4G SCC2',	mod4G.[% 256QAM SCC2] as '% 256QAM 4G SCC2',
	
	case when tdd.testid is not null then tdd.HSPA_PCT else tddServ.HSPA_PCT end as 'HSPA_PCT',
	case when tdd.testid is not null then tdd.[HSPA+_PCT] else tddServ.[HSPA+_PCT] end as 'HSPA+_PCT',
	case when tdd.testid is not null then tdd.[HSPA_DC_PCT] else tddServ.[HSPA_DC_PCT] end as 'HSPA_DC_PCT',	
	case when tdd.testid is not null then tdd.[HSPA+_DC_PCT] else tddServ.[HSPA+_DC_PCT] end as 'HSPA+_DC_PCT',		
	-- SC
	case when tdd.testid is not null then tdd.LTE_5Mhz_SC_PCT else tddServ.LTE_5Mhz_SC_PCT end as '5Mhz Bandwidth % SC', 
	case when tdd.testid is not null then tdd.LTE_10Mhz_SC_PCT else tddServ.LTE_10Mhz_SC_PCT end as '10Mhz Bandwidth % SC',	
	case when tdd.testid is not null then tdd.LTE_15Mhz_SC_PCT else tddServ.LTE_15Mhz_SC_PCT end as '15Mhz Bandwidth % SC',	
	case when tdd.testid is not null then tdd.LTE_20Mhz_SC_PCT else tddServ.LTE_20Mhz_SC_PCT end as '20Mhz Bandwidth % SC',
	-- CA
	case when tdd.testid is not null then tdd.LTE_15Mhz_CA_PCT else tddServ.LTE_15Mhz_CA_PCT end as '15Mhz Bandwidth % CA',	
	case when tdd.testid is not null then tdd.LTE_20Mhz_CA_PCT else tddServ.LTE_20Mhz_CA_PCT end as '20Mhz Bandwidth % CA',	
	case when tdd.testid is not null then tdd.LTE_25Mhz_CA_PCT else tddServ.LTE_25Mhz_CA_PCT end as '25Mhz Bandwidth % CA',
	case when tdd.testid is not null then tdd.LTE_30Mhz_CA_PCT else tddServ.LTE_30Mhz_CA_PCT end as '30Mhz Bandwidth % CA',	
	case when tdd.testid is not null then tdd.LTE_35Mhz_CA_PCT else tddServ.LTE_35Mhz_CA_PCT end as '35Mhz Bandwidth % CA',	
	case when tdd.testid is not null then tdd.LTE_40Mhz_CA_PCT else tddServ.LTE_40Mhz_CA_PCT end as '40Mhz Bandwidth % CA',
	-- 3C
	case when tdd.testid is not null then tdd.LTE_25Mhz_3C_PCT else tddServ.LTE_25Mhz_3C_PCT end as '25Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_30Mhz_3C_PCT else tddServ.LTE_30Mhz_3C_PCT end as '30Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_35Mhz_3C_PCT else tddServ.LTE_35Mhz_3C_PCT end as '35Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_40Mhz_3C_PCT else tddServ.LTE_40Mhz_3C_PCT end as '40Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_45Mhz_3C_PCT else tddServ.LTE_45Mhz_3C_PCT end as '45Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_50Mhz_3C_PCT else tddServ.LTE_50Mhz_3C_PCT end as '50Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_55Mhz_3C_PCT else tddServ.LTE_55Mhz_3C_PCT end as '55Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_60Mhz_3C_PCT else tddServ.LTE_60Mhz_3C_PCT end as '60Mhz Bandwidth % 3C',

	--PCC
	case when tdd.testid is not null then tdd.LTE_5Mhz_PCC_PCT else tddServ.LTE_5Mhz_PCC_PCT end as '5Mhz Bandwidth PCC %', 
	case when tdd.testid is not null then tdd.LTE_10Mhz_PCC_PCT else tddServ.LTE_10Mhz_PCC_PCT end as '10Mhz Bandwidth PCC %', 
	case when tdd.testid is not null then tdd.LTE_15Mhz_PCC_PCT else tddServ.LTE_15Mhz_PCC_PCT end as '15Mhz Bandwidth PCC %', 
	case when tdd.testid is not null then tdd.LTE_20Mhz_PCC_PCT else tddServ.LTE_20Mhz_PCC_PCT end as '20Mhz Bandwidth PCC %',
	--SCC1
	case when tdd.testid is not null then tdd.LTE_5Mhz_SCC1_PCT else tddServ.LTE_5Mhz_SCC1_PCT end as '5Mhz Bandwidth SCC1 %',
	case when tdd.testid is not null then tdd.LTE_10Mhz_SCC1_PCT else tddServ.LTE_10Mhz_SCC1_PCT end as '10Mhz Bandwidth SCC1 %', 
	case when tdd.testid is not null then tdd.LTE_15Mhz_SCC1_PCT else tddServ.LTE_15Mhz_SCC1_PCT end as '15Mhz Bandwidth SCC1 %', 
	case when tdd.testid is not null then tdd.LTE_20Mhz_SCC1_PCT else tddServ.LTE_20Mhz_SCC1_PCT end as '20Mhz Bandwidth SCC1 %',
	--SCC2
	case when tdd.testid is not null then tdd.LTE_5Mhz_SCC2_PCT else tddServ.LTE_5Mhz_SCC2_PCT end as '5Mhz Bandwidth SCC2 %', 
	case when tdd.testid is not null then tdd.LTE_10Mhz_SCC2_PCT else tddServ.LTE_10Mhz_SCC2_PCT end as '10Mhz Bandwidth SCC2 %', 
	case when tdd.testid is not null then tdd.LTE_15Mhz_SCC2_PCT else tddServ.LTE_15Mhz_SCC2_PCT end as '15Mhz Bandwidth SCC2 %', 
	case when tdd.testid is not null then tdd.LTE_20Mhz_SCC2_PCT else tddServ.LTE_20Mhz_SCC2_PCT end as '20Mhz Bandwidth SCC2 %',
	---------------							
	-- Performance:	
	-- 3G:
	cqi3G.CQI as 'CQI 3G',
	100.0*hs3G.hscch_use as '% SCCH',		hq.NumHarqProc_avg as 'Procesos HARQ',	
	cqi3G.avgBLER as 'BLER DSCH',			100.0*cqi3G.numDtx_DL as 'DTX DSCH',	100.0*cqi3G.NumAck_DL as 'ACKs',		100.0*cqi3G.NumNack_DL as '% NACKs',			
	mod3G.avgRateRetransmissions as 'Retrx DSCH',		'' as 'RETRX MAC',												
	thput_rlc.AvgRLCDLBLER as 'BLER RLC',	thput_rlc.AvgRLCDLThrpt as 'RLC Thput',

	-- 4G:
	rbs.Rbs_round_pond as 'RBs',	rbs.maxRBs as 'Max RBs',	rbs.minRBs as 'Min RBs',	rbs.Rbs_dedicated_round_pond as 'RBs When Allocated',
	
	-- ni idea de como se coge
	tm.percTM0 as '% TM Invalid',
	tm.percTM1 as '% TM 1: Single Antenna Port 0 ',	
	tm.percTM2 as '% TM 2: TD Rank 1',	
	tm.percTM3 as '% TM 3: OL SM',
	tm.percTM4 as '% TM 4: CL SM',
	tm.percTM5 as '% TM 5: MU MIMO',	
	tm.percTM6 as '% TM 6: CL RANK1 PC',	
	tm.percTM7 as '% TM 7: Single Antenna Port 5',
	tm.percTMunknown as '% TM Unknown',    
	
	rbs.Percent_LTESharedChannelUse as 'Shared channel use',	 
			
	-- PCC:
	rbs_c.Rbs_round_PCC as 'RBs PCC',	rbs_c.maxRBs_PCC as 'Max RBs PCC',	rbs_c.minRBs_PCC as 'Min RBs PCC',	rbs_c.Rbs_dedicated_round_PCC as 'RBs When Allocated PCC',	
	
	tm.[percTM0 PCC] as '% TM Invalid PCC',
	tm.[percTM1 PCC] as '% TM 1: Single Antenna Port 0 PCC',	
	tm.[percTM2 PCC] as '% TM 2: TD Rank 1 PCC',	
	tm.[percTM3 PCC] as '% TM 3: OL SM PCC',
	tm.[percTM4 PCC] as '% TM 4: CL SM PCC',
	tm.[percTM5 PCC] as '% TM 5: MU MIMO PCC',	
	tm.[percTM6 PCC] as '% TM 6: CL RANK1 PC PCC',	
	tm.[percTM7 PCC] as '% TM 7: Single Antenna Port 5 PCC',
	tm.[percTMunknown PCC] as '% TM Unknown PCC',   

	-- ERC: Se cambia el calculo de los CQIs
	cqi4G.avgCQI_PCC as 'CQI 4G PCC',		
	--cqi4G.AverageRI_PCC as 'Rank Indicator PCC',	
	
	-- SCC1:
	rbs_c.Rbs_round_SCC1 as 'RBs SCC1',
	rbs_c.maxRBs_SCC1 as 'Max RBs SCC1',
	rbs_c.minRBs_SCC1 as 'Min RBs SCC1',
	rbs_c.Rbs_dedicated_round_SCC1 as 'RBs When Allocated SCC1',	
	
	tm.[percTM0 SCC1] as '% TM Invalid SCC1',
	tm.[percTM1 SCC1] as '% TM 1: Single Antenna Port 0 SCC1',	
	tm.[percTM2 SCC1] as '% TM 2: TD Rank 1 SCC1',	
	tm.[percTM3 SCC1] as '% TM 3: OL SM SCC1',
	tm.[percTM4 SCC1] as '% TM 4: CL SM SCC1',
	tm.[percTM5 SCC1] as '% TM 5: MU MIMO SCC1',	
	tm.[percTM6 SCC1] as '% TM 6: CL RANK1 PC SCC1',	
	tm.[percTM7 SCC1] as '% TM 7: Single Antenna Port 5 SCC1',
	tm.[percTMunknown SCC1] as '% TM Unknown SCC1',   

	cqi4G.avgCQI_SCC1 as 'CQI 4G SCC1',		
	--cqi4G.AverageRI_SCC1 as 'Rank Indicator SCC1',	
	
	-- SCC2:
	rbs_c.Rbs_round_SCC2 as 'RBs SCC2',
	rbs_c.maxRBs_SCC2 as 'Max RBs SCC2',
	rbs_c.minRBs_SCC2 as 'Min RBs SCC2',
	rbs_c.Rbs_dedicated_round_SCC2 as 'RBs When Allocated SCC2',	
	
	tm.[percTM0 SCC2] as '% TM Invalid SCC2',
	tm.[percTM1 SCC2] as '% TM 1: Single Antenna Port 0 SCC2',	
	tm.[percTM2 SCC2] as '% TM 2: TD Rank 1 SCC2',	
	tm.[percTM3 SCC2] as '% TM 3: OL SM SCC2',
	tm.[percTM4 SCC2] as '% TM 4: CL SM SCC2',
	tm.[percTM5 SCC2] as '% TM 5: MU MIMO SCC2',	
	tm.[percTM6 SCC2] as '% TM 6: CL RANK1 PC SCC2',	
	tm.[percTM7 SCC2] as '% TM 7: Single Antenna Port 5 SCC2',
	tm.[percTMunknown SCC2] as '% TM Unknown SCC2',   

	cqi4G.avgCQI_SCC2 as 'CQI 4G SCC2',		
	--cqi4G.AverageRI_SCC2 as 'Rank Indicator SCC2',	
	
	-- INFO RADIO:
	tra.RxLev, 	tra.RxQual, 
	tri.BCCH as BCCH_Ini, tri.BSIC as BSIC_Ini, tri.RxLev as RxLev_Ini, tri.RxQual as RxQual_Ini, 
	trf.BCCH as BCCH_Fin, trf.BSIC as BSIC_Fin,	trf.RxLev as RxLev_Fin,	trf.RxQual as RxQual_Fin,
	tra.RxLev_min, tra.RxQual_min,
	tra.RSCP as 'RSCP_avg',	tra.EcIo as 'EcI0_avg',
	tri.PSC as PSC_Ini,	tri.RSCP as RSCP_Ini, tri.EcIo as EcIo_Ini,	tri.UARFCN as UARFCN_Ini,
	trf.PSC as PSC_Fin,	trf.RSCP as RSCP_Fin, trf.EcIo as EcIo_Fin,	trf.UARFCN as UARFCN_Fin,
	tra.RSCP_min, tra.EcIo_min,
	tra.RSRP as 'RSRP_avg', tra.RSRQ as 'RSRQ_avg', tra.SINR as 'SINR_avg',
	tri.PCI as PCI_Ini,	tri.RSRP as RSRP_Ini, tri.RSRQ as RSRQ_Ini,	tri.SINR as SINR_Ini, tri.EARFCN as EARFCN_Ini,
	trf.PCI as PCI_Fin,	trf.RSRP as RSRP_Fin, trf.RSRQ as RSRQ_Fin, trf.SINR as SINR_Fin, trf.EARFCN as EARFCN_Fin,
	tri.CId as CellId_Ini, tri.LAC as 'LAC/TAC_Ini', tri.RNCID as RNC_Ini,
	trf.CId as CellId_Fin, trf.LAC as 'LAC/TAC_Fin', trf.RNCID as RNC_Fin,

	-- INFO PARCELA:
	tri.longitude as 'Longitud Inicial',	tri.latitude as 'Latitud Inicial',	
	trf.longitude as 'Longitud Final',		trf.latitude as 'Latitud Final',

	-- @DGP: uso de CA
	--rbs_c.[Blocks_NoCA],	
	--rbs_c.[Blocks_CA],	
	null as [Blocks_NoCA],
	null as [Blocks_CA],
	
	--Si se recoge informacion de BW calculamos SC/CA/3C de alli, sino de la tabla serving (no de physical como resto de test)
	case when tdd.testid is not null then tdd.SC_PCT else tddServ.SC_PCT end as [% SC],
	case when tdd.testid is not null then tdd.CA_PCT else tddServ.CA_PCT end as [% CA],
	case when tdd.testid is not null then tdd.[3C_PCT] else tddServ.[3C_PCT] end as [% 3C],
		
	-- @ERC: Valores calculados a la antigua que se mantienen en caso de querer info en los test fallidos (KPIID no se rellena en esos casos)
	--CAC 10/08/2017: se incorpora información análoga para test de NC
	case when TestType = 'DL_CE' then thput_Transf.[ThputApp_nu] else thput_Transf_NC.[ThputApp_nu_DL] end as [ThputApp_nu],		
	case when TestType = 'DL_CE' then thput_Transf.[DataTransferred_nu] else thput_Transf_NC.[DataTransferred_nu_DL] end as [DataTransferred_nu],		
	case when TestType = 'DL_CE' then thput_Transf.[SessionTime_nu] else thput_Transf_NC.[SessionTime_nu] end as [SessionTime_nu],	
	case when TestType = 'DL_CE' then thput_Transf.[TransferTime_nu] else thput_Transf_NC.[TransferTime_nu] end as [TransferTime_nu],	
	case when TestType = 'DL_CE' then 1000.0*thput_Transf.[IPAccessTime_nu] else 1000.0*thput_Transf_NC.[IPAccessTime_nu] end as [IPAccessTime_sec_nu],	
		
	-- @ERC: Se añade info de tecnologia inicio/fin para añadir en el reporte
	tri.Tech_Ini,	trf.Tech_Fin,		
	
	case when tdd.testid is not null then tdd.DualCarrier_U2100 else tddServ.DualCarrier_U2100 end as '% Dual Carrier U2100',	
	case when tdd.testid is not null then tdd.DualCarrier_U900 else tddServ.DualCarrier_U900 end as '% Dual Carrier U900',

	-- @DGP: Se añade la interferencia UL media
	ulint.UL_Interference, 

	-- @ERC: KPIID de P3 - de momento asi, mas adelante (cd funcionen los kpiid) la suma del transfer, dns e ip access
	nullif(dl_kpiid.[SessionTime],0) as SessionTime,
	pdp.PDP_Activate_Ratio,
	pag.Paging_Success_Ratio,
	neigh.EARFCN_N1,		neigh.PCI_N1,			neigh.RSRP_N1,			neigh.RSRQ_N1,
	ho4G.num_HO_S1X2,
	ho4G.duration_S1X2_avg,
	ho4G.S1X2HO_SR,
	win.Max_Win as Max_Window_Size,
	
	tcphs.TCP_HandShake_Average,

	--@CAC: CQI por tecnologia; ERC: Se cambia el calculo del CQI
	cqi3G.CQI_UMTS900 as 'CQI UMTS900',		cqi3G.CQI_UMTS2100 as 'CQI UMTS2100',	
	--cqi4G.avgCQI_LTE2600 as 'CQI LTE2600',	cqi4G.avgCQI_LTE1800 as 'CQI LTE1800',
	--cqi4G.avgCQI_LTE800 as 'CQI LTE800',	cqi4G.avgCQI_LTE2100 as 'CQI LTE2100',
	null as 'CQI LTE2600',	null as 'CQI LTE1800',
	null as 'CQI LTE800',	null as 'CQI LTE2100',
	f.IMSI,

	--@ERC: MIMO y RI:
	cqi4G.perc_MIMO as '% MIMO',
	cqi4G.perc_RI2_TM2 as '% RI2_TM2',
	cqi4G.perc_RI2_TM3 as '% RI2_TM3',
	cqi4G.perc_RI2_TM4 as '% RI2_TM4',
	cqi4G.perc_MIMO_PCC as '% MIMO_PCC',
	cqi4G.perc_RI2_TM2_PCC as '% RI2_TM2_PCC',
	cqi4G.perc_RI2_TM3_PCC as '% RI2_TM3_PCC',
	cqi4G.perc_RI2_TM4_PCC as '% RI2_TM4_PCC',

	cqi4G.perc_MIMO_SCC1 as '% MIMO_SCC1',
	cqi4G.perc_RI2_TM2_SCC1 as '% RI2_TM2_SCC1',
	cqi4G.perc_RI2_TM3_SCC1 as '% RI2_TM3_SCC1',
	cqi4G.perc_RI2_TM4_SCC1 as '% RI2_TM4_SCC1',

	cqi4G.perc_MIMO_SCC2 as '% MIMO_SCC2',
	cqi4G.perc_RI2_TM2_SCC2 as '% RI2_TM2_SCC2',
	cqi4G.perc_RI2_TM3_SCC2 as '% RI2_TM3_SCC2',
	cqi4G.perc_RI2_TM4_SCC2 as '% RI2_TM4_SCC2',

	cqi4G.perc_RI1 as '% RI1',
	cqi4G.perc_RI2 as '% RI2',

	cqi4G.perc_RI1_PCC as '% RI1_PCC',
	cqi4G.perc_RI2_PCC as '% RI2_PCC',

	cqi4G.perc_RI1_SCC1 as '% RI1_SCC1',
	cqi4G.perc_RI2_SCC1 as '% RI2_SCC1',

	cqi4G.perc_RI1_SCC2 as '% RI1_SCC2',
	cqi4G.perc_RI2_SCC2 as '% RI2_SCC2',

	--ERC: Se añaden nuevos campos por el cambio del CQI
	cqi4G.avgCQI as 'CQI 4G',

	cqi4G.avgCQI_PCC_LTE2600	as 'CQI LTE2600 PCC',	cqi4G.avgCQI_PCC_LTE1800 as 'CQI LTE1800 PCC',
	cqi4G.avgCQI_PCC_LTE800		as 'CQI LTE800 PCC',	cqi4G.avgCQI_PCC_LTE2100 as 'CQI LTE2100 PCC',

	--cqi4G.avgCQI_SCC1_LTE2600 as 'CQI LTE2600 SCC1',	cqi4G.avgCQI_SCC1_LTE1800 as 'CQI LTE1800 SCC1',
	--cqi4G.avgCQI_SCC1_LTE800	as 'CQI LTE800 SCC1',	cqi4G.avgCQI_SCC1_LTE2100 as 'CQI LTE2100 SCC1',

	--cqi4G.avgCQI_SCC2_LTE2600 as 'CQI LTE2600 SCC2',	cqi4G.avgCQI_SCC2_LTE1800 as 'CQI LTE1800 SCC2',
	--cqi4G.avgCQI_SCC2_LTE800	as 'CQI LTE800 SCC2',	cqi4G.avgCQI_SCC2_LTE2100 as 'CQI LTE2100 SCC2', 

	null as 'CQI LTE2600 SCC1',	null as 'CQI LTE1800 SCC1',
	null as 'CQI LTE800 SCC1',	null as 'CQI LTE2100 SCC1',

	null as 'CQI LTE2600 SCC2',	null as 'CQI LTE1800 SCC2',
	null as 'CQI LTE800 SCC2',	null as 'CQI LTE2100 SCC2', 

	-- 20170321 - @ERC: Nuevos KPis y parametros:
	f.ASideDevice, f.BSideDevice, f.SWVersion,

	tdd.HSPA_PCT as 'HSPA_PCT real',
	tdd.[HSPA+_PCT] as 'HSPA+_PCT real',
	tdd.[HSPA_DC_PCT] as 'HSPA_DC_PCT real',
	tdd.[HSPA+_DC_PCT] as 'HSPA+_DC_PCT real',
	-- SC
	tdd.LTE_5Mhz_SC_PCT as '5Mhz Bandwidth % SC real ', 
	tdd.LTE_10Mhz_SC_PCT as '10Mhz Bandwidth % SC real ',	
	tdd.LTE_15Mhz_SC_PCT as '15Mhz Bandwidth % SC real ',	
	tdd.LTE_20Mhz_SC_PCT as '20Mhz Bandwidth % SC real ',
	-- CA
	tdd.LTE_15Mhz_CA_PCT as '15Mhz Bandwidth % CA real ',	
	tdd.LTE_20Mhz_CA_PCT as '20Mhz Bandwidth % CA real ',	
	tdd.LTE_25Mhz_CA_PCT as '25Mhz Bandwidth % CA real ',
	tdd.LTE_30Mhz_CA_PCT as '30Mhz Bandwidth % CA real ',	
	tdd.LTE_35Mhz_CA_PCT as '35Mhz Bandwidth % CA real ',	
	tdd.LTE_40Mhz_CA_PCT as '40Mhz Bandwidth % CA real ',
	-- 3C
	tdd.LTE_25Mhz_3C_PCT as '25Mhz Bandwidth % 3C real ',	
	tdd.LTE_30Mhz_3C_PCT as '30Mhz Bandwidth % 3C real ',	
	tdd.LTE_35Mhz_3C_PCT as '35Mhz Bandwidth % 3C real ',	
	tdd.LTE_40Mhz_3C_PCT as '40Mhz Bandwidth % 3C real ',	
	tdd.LTE_45Mhz_3C_PCT as '45Mhz Bandwidth % 3C real ',	
	tdd.LTE_50Mhz_3C_PCT as '50Mhz Bandwidth % 3C real ',	
	tdd.LTE_55Mhz_3C_PCT as '55Mhz Bandwidth % 3C real ',	
	tdd.LTE_60Mhz_3C_PCT as '60Mhz Bandwidth % 3C real ',

	--PCC
	tdd.LTE_5Mhz_PCC_PCT as '5Mhz Bandwidth PCC % real ', 
	tdd.LTE_10Mhz_PCC_PCT as '10Mhz Bandwidth PCC % real ', 
	tdd.LTE_15Mhz_PCC_PCT as '15Mhz Bandwidth PCC % real ', 
	tdd.LTE_20Mhz_PCC_PCT as '20Mhz Bandwidth PCC % real ',
	--SCC1
	tdd.LTE_5Mhz_SCC1_PCT as '5Mhz Bandwidth SCC1 % real ', 
	tdd.LTE_10Mhz_SCC1_PCT as '10Mhz Bandwidth SCC1 % real ', 
	tdd.LTE_15Mhz_SCC1_PCT as '15Mhz Bandwidth SCC1 % real ', 
	tdd.LTE_20Mhz_SCC1_PCT as '20Mhz Bandwidth SCC1 % real ',
	--SCC2
	tdd.LTE_5Mhz_SCC2_PCT as '5Mhz Bandwidth SCC2 % real ',
	tdd.LTE_10Mhz_SCC2_PCT as '10Mhz Bandwidth SCC2 % real ', 
	tdd.LTE_15Mhz_SCC2_PCT as '15Mhz Bandwidth SCC2 % real ', 
	tdd.LTE_20Mhz_SCC2_PCT as '20Mhz Bandwidth SCC2 % real ',

	tdd.DLBandWidth_est as 'BW_PCC_est',
	null as 'Info_Update'

--into Lcc_Data_HTTPTransfer_DL
from 
	FileList f,	Sessions s, TestInfo t
	-- COMUNES:
		LEFT OUTER JOIN _BW_acotado_acc	pctBw	on pctBw.TestId=t.TestId and pctBw.SessionId=t.SessionId 
		LEFT OUTER JOIN _PCT_TECH_Data_acotado_acc	pctTech	on pctTech.TestId=t.TestId and pctTech.SessionId=t.SessionId
		LEFT OUTER JOIN _lcc_http_DL	dl_kpiid	on dl_kpiid.testid=t.testid and dl_kpiid.sessionid=t.SessionId
		LEFT OUTER JOIN _THPUT thput				on (t.SessionId=thput.SessionId and t.TestId=thput.testid and thput.direction='Downlink')	
		LEFT OUTER JOIN _THPUT_Transf thput_Transf	on (t.SessionId=thput_Transf.SessionId and t.TestId=thput_Transf.testid)		
		--CAC 10/08/2017: se incorpora información análoga para test de NC
		LEFT OUTER JOIN _THPUT_Transf_NC thput_Transf_NC on (t.SessionId=thput_Transf_NC.SessionId and t.TestId=thput_Transf_NC.testid)
		LEFT OUTER JOIN _THPUT_RLC		thput_rlc		on (t.SessionId=thput_rlc.SessionId and t.TestId=thput_rlc.testid)	
			
		LEFT OUTER JOIN _TECH_RADIO_INI_Data	tri	on (t.SessionId=tri.SessionId and t.TestId=tri.testid)
		LEFT OUTER JOIN _TECH_RADIO_FIN_Data	trf	on (t.SessionId=trf.SessionId and t.TestId=trf.testid)
		LEFT OUTER JOIN _TECH_RADIO_AVG_Data	tra	on (t.SessionId=tra.SessionId and t.TestId=tra.testid)

	-- 3G:	
		LEFT OUTER JOIN _CQI_3G_acotado_acc cqi3G		on cqi3G.TestId=t.TestId and cqi3G.SessionId=t.SessionId
		LEFT OUTER JOIN _scch_use_3G hs3G	on hs3G.TestId=t.TestId and hs3G.SessionId=t.SessionId
		LEFT OUTER JOIN _MOD_3G_acotado_acc mod3G		on mod3G.TestId=t.TestId and mod3G.SessionId=t.SessionId
		LEFT OUTER JOIN _HARQ hq			on hq.TestId=t.TestId and hq.SessionId=t.SessionId
		LEFT OUTER JOIN _UL_Int ulint		on ulint.TestId=t.TestId and ulint.SessionId=t.SessionId
	-- 4G:		
		LEFT OUTER JOIN _MOD_4G mod4G			on (t.SessionId=mod4G.SessionId and t.TestId=mod4G.testid and mod4G.direction='Downlink') 
		LEFT OUTER JOIN _cqi_4G_acotado_acc cqi4G	on (t.SessionId=cqi4G.SessionId and t.TestId=cqi4G.testid)
		LEFT OUTER JOIN _RBs_carrier_DL rbs_c	on (t.SessionId=rbs_c.SessionId and t.TestId=rbs_c.testid and rbs_c.direction='Downlink') 
		LEFT OUTER JOIN _RBs_DL rbs				on (t.SessionId=rbs.SessionId and t.TestId=rbs.testid and rbs.direction='Downlink') 
		LEFT OUTER JOIN _TM_DL tm				on (t.SessionId=tm.SessionId and t.TestId=tm.testid and tm.direction='Downlink')

	-- KPI EXTRA:
		LEFT OUTER JOIN _PDP pdp		on pdp.TestId=t.TestId and pdp.SessionId=t.SessionId
		LEFT OUTER JOIN _Paging pag		on pag.TestId=t.TestId and pag.SessionId=t.SessionId
		LEFT OUTER JOIN _NEIGH neigh		on neigh.TestId=t.TestId and neigh.SessionId=t.SessionId
		LEFT OUTER JOIN _4GHO ho4G			on ho4G.TestId=t.TestId and ho4G.SessionId=t.SessionId		
		LEFT OUTER JOIN _Window win			on win.TestId=t.TestId and win.SessionId=t.SessionId	
	--OSP:

		LEFT OUTER JOIN _Tech_Duration_Distribution_acotado_acc tdd				on (tdd.sessionid=t.sessionid and tdd.testid=t.testid)
		LEFT OUTER JOIN _Tech_Duration_Distribution_acotado_acc_Serv tddServ	on (tddServ.sessionid=t.sessionid and tddServ.testid=t.testid)
		LEFT OUTER JOIN _TCP_3WAY_HANDSHAKE tcphs			on (tcphs.sessionid=t.sessionid and tcphs.testid=t.testid)

	--
		LEFT OUTER JOIN _Carrier ca				on (t.SessionId=ca.SessionId and t.TestId=ca.testid) 
	

where 
	t.SessionId=s.SessionId and s.FileId=f.FileId
	and s.sessionType='data' 
	and t.typeoftest in ('HTTPTransfer','Capacity') and t.direction='Downlink'
	and s.valid=1 and t.valid=1
	and ErrorType='Accessibility'

	and t.testid > @maxTestid_DL
	and RIGHT(LEFT(f.IMSI,5),2) in (1,7,3,4)
order by f.FileId, t.SessionId, t.TestId


select 'Fin creacion tabla Lcc_Data_HTTPTransfer_DL' info


-- (2)
-- ***************************************
------		TABLA FINAL HTTP UL		------			select * from _lcc_http_UL --Lcc_Data_HTTPTransfer_UL 	
-- ***************************************
select 'Inicio creacion tabla Lcc_Data_HTTPTransfer_UL' info

--Test con ErrorType <> 'Accessibility', limitamos algunos KPIs al momento de la subida
insert into Lcc_Data_HTTPTransfer_UL
select 
	f.CallingModule as MTU,	f.IMEI,		f.CollectionName,	LEFT(f.IMSI,3) as MCC,	RIGHT(LEFT(f.IMSI,5),2) as MNC,	t.startDate,			
	t.startTime,	DATEADD(ms, t.duration ,t.startTime) as endTime,	t.SessionId, f.FileId, t.TestId, t.typeoftest, t.direction, s.info,
	
	-- _lcc_http_UL:
	ul_kpiid.TestType as TestType,	'1' as ServiceType,
	ul_kpiid.[IP Access Time (ms)] ,		ul_kpiid.DataTransferred as DataTransferred,	ul_kpiid.TransferTime as TransferTime, 
	ul_kpiid.ErrorCause as ErrorCause,	ul_kpiid.ErrorType as ErrorType,	
	ul_kpiid.Throughput as Throughput,	'' as Throughput_MAX,

	-- 3G:	
	thput_rlc.maxRLCULThrpt as RLC_MAX,		
	
	-- Technology:		- tech info UL
	ISNULL(pctTech.pctLTE, 0) as '% LTE',	ISNULL(pctTech.pctWCDMA, 0) as '% WCDMA',	ISNULL(pctTech.pctGSM, 0) as '% GSM',	

	ISNULL(pctTech.pct_F1_U2100, 0) as '% F1 U2100',	ISNULL(pctTech.pct_F2_U2100, 0) as '% F2 U2100',	ISNULL(pctTech.pct_F3_U2100, 0) as '% F3 U2100',
	ISNULL(pctTech.pct_F1_U900, 0) as '% F1 U900',	ISNULL(pctTech.pct_F2_U900, 0) as '% F2 U900',
	
	ISNULL(pctTech.pctUMTS_2100, 0) as '% U2100',	ISNULL(pctTech.pctUMTS_900, 0) as '% U900',	ISNULL(pctTech.pctLTE_2600, 0) as '% LTE2600',
	ISNULL(pctTech.pctLTE_2100, 0) as '% LTE2100',	ISNULL(pctTech.pctLTE_1800, 0) as '% LTE1800',
	ISNULL(pctTech.pctLTE_800, 0) as '% LTE800',	
	
	ISNULL(pctTech.[pctGMS_DCS], 0) as 'DCS %',	ISNULL(pctTech.[pctGSM_EGSM], 0) as 'GSM %',	ISNULL(pctTech.[pctGSM_GSM], 0) as 'EGSM %',

	ISNULL(pctTech.Roaming_VF, 0) as 'Roaming_VF',ISNULL(pctTech.Roaming_MV, 0) as 'Roaming_MV',ISNULL(pctTech.Roaming_OR, 0) as 'Roaming_OR',ISNULL(pctTech.Roaming_YO, 0) as 'Roaming_YO',
	ISNULL(pctTech.Roaming_U900, 0) as 'Roaming_U900',ISNULL(pctTech.Roaming_U2100, 0) as 'Roaming_U2100',
	ISNULL(pctTech.Roaming_LTE800, 0) as 'Roaming_LTE800',ISNULL(pctTech.Roaming_LTE1800, 0) as 'Roaming_LTE1800',ISNULL(pctTech.Roaming_LTE2100, 0) as 'Roaming_LTE2100',ISNULL(pctTech.Roaming_LTE2600, 0) as 'Roaming_LTE2600',

	ISNULL(pctTech.Duration_Roaming_VF, 0) as 'Duration_roaming_VF',ISNULL(pctTech.Duration_Roaming_MV, 0) as 'Duration_roaming_MV',ISNULL(pctTech.Duration_Roaming_OR, 0) as 'Duration_roaming_OR',ISNULL(pctTech.Duration_Roaming_YO, 0) as 'Duration_roaming_YO',
	ISNULL(pctTech.Duration_Roaming_U900, 0) as 'Duration_roaming_U900',ISNULL(pctTech.Duration_Roaming_U2100, 0) as 'Duration_roaming_U2100',
	ISNULL(pctTech.Duration_Roaming_LTE800, 0) as 'Duration_roaming_LTE800',ISNULL(pctTech.Duration_Roaming_LTE1800, 0) as 'Duration_roaming_LTE1800',ISNULL(pctTech.Duration_Roaming_LTE2100, 0) as 'Duration_roaming_LTE2100',ISNULL(pctTech.Duration_Roaming_LTE2600, 0) as 'Duration_roaming_LTE2600',

	-- 3G:
	sf.PercentSF22 as '% SF22',	sf.PercentSF22andSF42 as '% SF22andSF42',	sf.PercentSF4 as '% SF4',	sf.PercentSF42 as '% SF42',
	
	'' as 'HSUPA 2.0',	case when umac.sumTTI_ms <> 0 then ((1.0*umac.sumTTI_2ms)/(1.0*umac.sumTTI_ms)) else null end as '% TTI 2ms',
	
	--case when cqi3G.DualCarrier_use > 0 then 2 else 1 end as Carriers,	cqi3G.DualCarrier_use as [% Dual Carrier],
	case when pctTech.pctWCDMA>0 then 1 end as Carriers,	null as [% Dual Carrier],		
	
	-- 4G:	
	mod4G.[% BPSK] as '% BPSK 4G',	mod4G.[% QPSK] as '% QPSK 4G',	mod4G.[% 16QAM] as '% 16QAM 4G',	mod4G.[% 64QAM] as '% 64QAM 4G',

	case when tdd.testid is not null then tdd.HSPA_PCT else tddServ.HSPA_PCT end as 'HSPA_PCT',
	case when tdd.testid is not null then tdd.[HSPA+_PCT] else tddServ.[HSPA+_PCT] end as 'HSPA+_PCT',
	case when tdd.testid is not null then tdd.[HSPA_DC_PCT] else tddServ.[HSPA_DC_PCT] end as 'HSPA_DC_PCT',
	case when tdd.testid is not null then tdd.[HSPA+_DC_PCT] else tddServ.[HSPA+_DC_PCT] end as 'HSPA+_DC_PCT',
	-- PCC
	case when tdd.testid is not null then tdd.LTE_5Mhz_PCC_PCT else tddServ.LTE_5Mhz_PCC_PCT end as '5Mhz Bandwidth % SC', 
	case when tdd.testid is not null then tdd.LTE_10Mhz_PCC_PCT else tddServ.LTE_10Mhz_PCC_PCT end as '10Mhz Bandwidth % SC',	
	case when tdd.testid is not null then tdd.LTE_15Mhz_PCC_PCT else tddServ.LTE_15Mhz_PCC_PCT end as '15Mhz Bandwidth % SC',	
	case when tdd.testid is not null then tdd.LTE_20Mhz_PCC_PCT else tddServ.LTE_20Mhz_PCC_PCT end as '20Mhz Bandwidth % SC',

	-- Performance
	-- 3G:
	cqi3G.CQI as 'CQI 3G',
	0.01*umac.AverageHappyRate as 'HappyRate', 	0.01*umac.maxHappyRate as 'Happy Rate MAX',umac.AverageSG as 'Serving Grant', 	
	umac.AverageDTXRate as 'DTX',	umac.AverageTBsize as 'avg TBs size',
	sho.percSHO as '% SHO',	'' as 'ReTrx PDU',
	
	-- 4G:
	rbs.Rbs_round as 'RBs',	rbs.maxRBs as 'Max RBs',	rbs.minRBs as 'Min RBs',	rbs.Rbs_dedicated_round as 'RBs When Allocated',
	
	cqi4G.avgCQI as 'CQI 4G',
	--cqi4G.AverageRI_PCC as 'Rank Indicator',	
	rbs.Percent_LTESharedChannelUse as 'Shared channel use',
	
	tm.percTM0 as '% TM Invalid',
	tm.percTM1 as '% TM 1: Single Antenna Port 0',
	tm.percTM2 as '% TM 2: TD Rank 1',	
	tm.percTM3 as '% TM 3: OL SM',	
	tm.percTM4 as '% TM 4: CL SM',
	tm.percTM5 as '% TM 5: MU MIMO',
	tm.percTM6 as '% TM 6: CL RANK1 PC',
	tm.percTM7 as '% TM 7: Single Antenna Port 5',
	tm.percTM8 as '% TM 8',
	tm.percTM9 as '% TM 9',
	tm.percTMunknown as '% TM Unknown',        	

	-- INFO RADIO:
	tra.RxLev,	tra.RxQual,
	tri.BCCH as BCCH_Ini,	tri.BSIC as BSIC_Ini,	tri.RxLev as RxLev_Ini,	tri.RxQual as RxQual_Ini,
	trf.BCCH as BCCH_Fin,	trf.BSIC as BSIC_Fin,	trf.RxLev as RxLev_Fin,	trf.RxQual as RxQual_Fin,
	tra.RxLev_min,	tra.RxQual_min,
	tra.RSCP as 'RSCP_avg',	tra.EcIo as 'EcI0_avg',
	tri.PSC as PSC_Ini,	tri.RSCP as RSCP_Ini,	tri.EcIo as EcIo_Ini,	tri.UARFCN as UARFCN_Ini,
	trf.PSC as PSC_Fin,	trf.RSCP as RSCP_Fin,	trf.EcIo as EcIo_Fin,	trf.UARFCN as UARFCN_Fin,
	tra.RSCP_min,	tra.EcIo_min,
	tra.RSRP as 'RSRP_avg',	tra.RSRQ as 'RSRQ_avg',	tra.SINR as 'SINR_avg',
	tri.PCI as PCI_Ini,	tri.RSRP as RSRP_Ini,	tri.RSRQ as RSRQ_Ini,	tri.SINR as SINR_Ini,		tri.EARFCN as EARFCN_Ini,
	trf.PCI as PCI_Fin,	trf.RSRP as RSRP_Fin,	trf.RSRQ as RSRQ_Fin,	trf.SINR as SINR_Fin,		trf.EARFCN as EARFCN_Fin,
	tri.CId as CellId_Ini,	tri.LAC as 'LAC/TAC_Ini',	tri.RNCID as RNC_Ini,
	trf.CId as CellId_Fin,	trf.LAC as 'LAC/TAC_Fin',	trf.RNCID as RNC_Fin,

	---------------
	-- INFO PARCELA:
	tri.longitude as 'Longitud Inicial',	tri.latitude as 'Latitud Inicial',	
	trf.longitude as 'Longitud Final',	trf.latitude as 'Latitud Final',

	-- @ERC: Valores sin updates para montar los libros externos de errores de datos
	--CAC 10/08/2017: se incorpora información análoga para test de NC
	--thput_Transf.[ThputApp_nu],			thput_Transf.[DataTransferred_nu],		thput_Transf.[SessionTime_nu],		
	--thput_Transf.[TransferTime_nu],		1000.0*thput_Transf.[IPAccessTime_nu] as [IPAccessTime_sec_nu], -- este no se borra ya que no se calculan kpi en DL/UL, pero si se hiciera mas adelante -> bastaria un update al otro campo		
	
	case when TestType = 'UL_CE' then thput_Transf.[ThputApp_nu] else thput_Transf_NC.[ThputApp_nu_UL] end as [ThputApp_nu],		
	case when TestType = 'UL_CE' then thput_Transf.[DataTransferred_nu] else thput_Transf_NC.[DataTransferred_nu_UL] end as [DataTransferred_nu],		
	case when TestType = 'UL_CE' then thput_Transf.[SessionTime_nu] else thput_Transf_NC.[SessionTime_nu] end as [SessionTime_nu],	
	case when TestType = 'UL_CE' then thput_Transf.[TransferTime_nu] else thput_Transf_NC.[TransferTime_nu] end as [TransferTime_nu],	
	case when TestType = 'UL_CE' then 1000.0*thput_Transf.[IPAccessTime_nu] else 1000.0*thput_Transf_NC.[IPAccessTime_nu] end as [IPAccessTime_sec_nu],	
	

	-- @ERC: Se añade info de tecnologia inicio/fin para añadir en el reporte
	tri.Tech_Ini,	trf.Tech_Fin,		
	
	-- @DGP: Se añade la info de uso de DC por banda
	--cqi3G.DualCarrier_use_U2100 as '% Dual Carrier U2100',	cqi3G.DualCarrier_use_U900 as '% Dual Carrier U900',

	null as '% Dual Carrier U2100',	null as '% Dual Carrier U900',
	-- @DGP: Se añade la interferencia UL media
	ulint.UL_Interference,

	-- @ERC: KPIID de P3 - de momento asi, mas adelante (cd funcionen los kpiid) la suma del transfer, dns e ip access
	nullif(ul_kpiid.[SessionTime],0) as SessionTime,
	
	pdp.PDP_Activate_Ratio,
	pag.Paging_Success_Ratio,
	neigh.EARFCN_N1,	neigh.PCI_N1,		neigh.RSRP_N1,	neigh.RSRQ_N1,
	ho4G.num_HO_S1X2,	ho4G.duration_S1X2_avg,	ho4G.S1X2HO_SR,
	win.Max_Win as Max_Window_Size,
	
	tcphs.TCP_HandShake_Average,

	--@CAC: CQI por tecnologia
	cqi3G.CQI_UMTS900 as 'CQI UMTS900',		cqi3G.CQI_UMTS2100 as 'CQI UMTS2100',	
	cqi4G.avgCQI_LTE2600	as 'CQI LTE2600',		cqi4G.avgCQI_LTE1800 as 'CQI LTE1800',
	cqi4G.avgCQI_LTE800		as 'CQI LTE800',		cqi4G.avgCQI_LTE2100 as 'CQI LTE2100',f.IMSI,

	--@ERC: MIMO
	cqi4G.perc_MIMO_PCC as '% MIMO',
	cqi4G.perc_RI2_TM2_PCC as '% RI2_TM2',
	cqi4G.perc_RI2_TM3_PCC as '% RI2_TM3',
	cqi4G.perc_RI2_TM4_PCC as '% RI2_TM4',

	cqi4G.perc_RI1_PCC as '% RI1',
	cqi4G.perc_RI2_PCC as '% RI2', 

	-- 20170321 - @ERC: Nuevos KPis y parametros:
	f.ASideDevice, f.BSideDevice, f.SWVersion,

	tdd.HSPA_PCT as 'HSPA_PCT real',
	tdd.[HSPA+_PCT] as 'HSPA+_PCT real',
	tdd.[HSPA_DC_PCT] as 'HSPA_DC_PCT real',
	tdd.[HSPA+_DC_PCT] as 'HSPA+_DC_PCT real',
	-- SC
	tdd.LTE_5Mhz_PCC_PCT as '5Mhz Bandwidth % SC real ', 
	tdd.LTE_10Mhz_PCC_PCT as '10Mhz Bandwidth % SC real ',	
	tdd.LTE_15Mhz_PCC_PCT as '15Mhz Bandwidth % SC real ',	
	tdd.LTE_20Mhz_PCC_PCT as '20Mhz Bandwidth % SC real ',

	tdd.DLBandWidth_est as 'BW_PCC_est',
	null as 'Info_Update'
		
--into Lcc_Data_HTTPTransfer_UL
from 
	FileList f, Sessions s, TestInfo t
	-- COMUNES:
		LEFT OUTER JOIN _BW_acotado		pctBw		on pctBw.TestId=t.TestId and pctBw.SessionId=t.SessionId
		LEFT OUTER JOIN _PCT_TECH_Data_acotado		pctTech		on (pctTech.TestId=t.TestId and pctTech.SessionId=t.SessionId )
		LEFT OUTER JOIN _lcc_http_UL ul_kpiid		on (ul_kpiid.TestId=t.TestId and ul_kpiid.SessionId=t.SessionId )
		LEFT OUTER JOIN _THPUT thput				on (t.SessionId=thput.SessionId and t.TestId=thput.testid and thput.direction='Uplink')	
		LEFT OUTER JOIN _THPUT_Transf thput_Transf	on (t.SessionId=thput_Transf.SessionId and t.TestId=thput_Transf.testid)		
		--CAC 10/08/2017: se incorpora información análoga para test de NC
		LEFT OUTER JOIN _THPUT_Transf_NC thput_Transf_NC on (t.SessionId=thput_Transf_NC.SessionId and t.TestId=thput_Transf_NC.testid)
		LEFT OUTER JOIN _THPUT_RLC thput_rlc		on (t.SessionId=thput_rlc.SessionId and t.TestId=thput_rlc.testid)
		
		LEFT OUTER JOIN _TECH_RADIO_INI_Data tri	on (t.SessionId=tri.SessionId and t.TestId=tri.testid)
		LEFT OUTER JOIN _TECH_RADIO_FIN_Data trf	on (t.SessionId=trf.SessionId and t.TestId=trf.testid)
		LEFT OUTER JOIN _TECH_RADIO_AVG_Data tra	on (t.SessionId=tra.SessionId and t.TestId=tra.testid)	
	
	-- 3G:
		LEFT OUTER JOIN _SF sf				on sf.TestId=t.TestId and sf.SessionId=t.SessionId
		LEFT OUTER JOIN _ULMAC umac			on umac.TestId=t.TestId and umac.SessionId=t.SessionId
		LEFT OUTER JOIN _CQI_3G_acotado		cqi3G		on cqi3G.TestId=t.TestId and cqi3G.SessionId=t.SessionId
		LEFT OUTER JOIN _SHOs sho			on sho.TestId=t.TestId and sho.SessionId=t.SessionId
		LEFT OUTER JOIN _UL_Int ulint		on ulint.TestId=t.TestId and ulint.SessionId=t.SessionId		
	-- 4G:
		LEFT OUTER JOIN _MOD_4G mod4G			on (t.SessionId=mod4G.SessionId and t.TestId=mod4G.testid and mod4G.Direction='Uplink') 
		LEFT OUTER JOIN _CQI_4G_acotado		cqi4G		on (t.SessionId=cqi4G.SessionId and t.TestId=cqi4G.testid)
		LEFT OUTER JOIN _RBs_UL rbs				on (t.SessionId=rbs.SessionId and t.TestId=rbs.testid and rbs.Direction='Uplink') 
		LEFT OUTER JOIN _TM_UL_acotado		tm			on (t.SessionId=tm.SessionId and t.TestId=tm.testid)
		
	-- KPI EXTRA:
		LEFT OUTER JOIN _PDP pdp		on pdp.TestId=t.TestId and pdp.SessionId=t.SessionId
		LEFT OUTER JOIN _Paging pag		on pag.TestId=t.TestId and pag.SessionId=t.SessionId
		LEFT OUTER JOIN _NEIGH neigh		on neigh.TestId=t.TestId and neigh.SessionId=t.SessionId
		LEFT OUTER JOIN _4GHO ho4G			on ho4G.TestId=t.TestId and ho4G.SessionId=t.SessionId		
		LEFT OUTER JOIN _Window win			on win.TestId=t.TestId and win.SessionId=t.SessionId	

	--OSP:
		LEFT OUTER JOIN _Tech_Duration_Distribution_acotado tdd				on (tdd.sessionid=t.sessionid and tdd.testid=t.testid)
		LEFT OUTER JOIN _Tech_Duration_Distribution_acotado_Serv tddServ	on (tddServ.sessionid=t.sessionid and tddServ.testid=t.testid)
		LEFT OUTER JOIN _TCP_3WAY_HANDSHAKE tcphs			on (tcphs.sessionid=t.sessionid and tcphs.testid=t.testid)

where 
	t.SessionId=s.SessionId and s.FileId=f.FileId
	and s.sessionType='data'  
	and t.typeoftest in ('HTTPTransfer','Capacity') and t.direction='Uplink'
	and s.valid=1 and t.valid=1
	and (ErrorType is null or ErrorType<>'Accessibility')

	and t.testid > @maxTestid_UL
	and RIGHT(LEFT(f.IMSI,5),2) in (1,7,3,4)	
order by f.FileId, t.SessionId, t.TestId	

--Test con ErrorType = 'Accessibility' tenemos en cuenta el acceso
insert into Lcc_Data_HTTPTransfer_UL
select 
	f.CallingModule as MTU,	f.IMEI,		f.CollectionName,	LEFT(f.IMSI,3) as MCC,	RIGHT(LEFT(f.IMSI,5),2) as MNC,	t.startDate,			
	t.startTime,	DATEADD(ms, t.duration ,t.startTime) as endTime,	t.SessionId, f.FileId, t.TestId, t.typeoftest, t.direction, s.info,
	
	-- _lcc_http_UL:
	ul_kpiid.TestType as TestType,	'1' as ServiceType,
	ul_kpiid.[IP Access Time (ms)] ,		ul_kpiid.DataTransferred as DataTransferred,	ul_kpiid.TransferTime as TransferTime, 
	ul_kpiid.ErrorCause as ErrorCause,	ul_kpiid.ErrorType as ErrorType,	
	ul_kpiid.Throughput as Throughput,	'' as Throughput_MAX,

	-- 3G:	
	thput_rlc.maxRLCULThrpt as RLC_MAX,		
	
	-- Technology:		- tech info UL
	ISNULL(pctTech.pctLTE, 0) as '% LTE',	ISNULL(pctTech.pctWCDMA, 0) as '% WCDMA',	ISNULL(pctTech.pctGSM, 0) as '% GSM',	

	ISNULL(pctTech.pct_F1_U2100, 0) as '% F1 U2100',	ISNULL(pctTech.pct_F2_U2100, 0) as '% F2 U2100',	ISNULL(pctTech.pct_F3_U2100, 0) as '% F3 U2100',
	ISNULL(pctTech.pct_F1_U900, 0) as '% F1 U900',	ISNULL(pctTech.pct_F2_U900, 0) as '% F2 U900',
	
	ISNULL(pctTech.pctUMTS_2100, 0) as '% U2100',	ISNULL(pctTech.pctUMTS_900, 0) as '% U900',	ISNULL(pctTech.pctLTE_2600, 0) as '% LTE2600',
	ISNULL(pctTech.pctLTE_2100, 0) as '% LTE2100',	ISNULL(pctTech.pctLTE_1800, 0) as '% LTE1800',
	ISNULL(pctTech.pctLTE_800, 0) as '% LTE800',	
	
	ISNULL(pctTech.[pctGMS_DCS], 0) as 'DCS %',	ISNULL(pctTech.[pctGSM_EGSM], 0) as 'GSM %',	ISNULL(pctTech.[pctGSM_GSM], 0) as 'EGSM %',

	ISNULL(pctTech.Roaming_VF, 0) as 'Roaming_VF',ISNULL(pctTech.Roaming_MV, 0) as 'Roaming_MV',ISNULL(pctTech.Roaming_OR, 0) as 'Roaming_OR',ISNULL(pctTech.Roaming_YO, 0) as 'Roaming_YO',
	ISNULL(pctTech.Roaming_U900, 0) as 'Roaming_U900',ISNULL(pctTech.Roaming_U2100, 0) as 'Roaming_U2100',
	ISNULL(pctTech.Roaming_LTE800, 0) as 'Roaming_LTE800',ISNULL(pctTech.Roaming_LTE1800, 0) as 'Roaming_LTE1800',ISNULL(pctTech.Roaming_LTE2100, 0) as 'Roaming_LTE2100',ISNULL(pctTech.Roaming_LTE2600, 0) as 'Roaming_LTE2600',

	ISNULL(pctTech.Duration_Roaming_VF, 0) as 'Duration_roaming_VF',ISNULL(pctTech.Duration_Roaming_MV, 0) as 'Duration_roaming_MV',ISNULL(pctTech.Duration_Roaming_OR, 0) as 'Duration_roaming_OR',ISNULL(pctTech.Duration_Roaming_YO, 0) as 'Duration_roaming_YO',
	ISNULL(pctTech.Duration_Roaming_U900, 0) as 'Duration_roaming_U900',ISNULL(pctTech.Duration_Roaming_U2100, 0) as 'Duration_roaming_U2100',
	ISNULL(pctTech.Duration_Roaming_LTE800, 0) as 'Duration_roaming_LTE800',ISNULL(pctTech.Duration_Roaming_LTE1800, 0) as 'Duration_roaming_LTE1800',ISNULL(pctTech.Duration_Roaming_LTE2100, 0) as 'Duration_roaming_LTE2100',ISNULL(pctTech.Duration_Roaming_LTE2600, 0) as 'Duration_roaming_LTE2600',

	-- 3G:
	sf.PercentSF22 as '% SF22',	sf.PercentSF22andSF42 as '% SF22andSF42',	sf.PercentSF4 as '% SF4',	sf.PercentSF42 as '% SF42',
	
	'' as 'HSUPA 2.0',	case when umac.sumTTI_ms <> 0 then ((1.0*umac.sumTTI_2ms)/(1.0*umac.sumTTI_ms)) else null end as '% TTI 2ms',
	
	--case when cqi3G.DualCarrier_use > 0 then 2 else 1 end as Carriers,	cqi3G.DualCarrier_use as [% Dual Carrier],
	case when pctTech.pctWCDMA>0 then 1 end as Carriers,	null as [% Dual Carrier],		
	
	-- 4G:	
	mod4G.[% BPSK] as '% BPSK 4G',	mod4G.[% QPSK] as '% QPSK 4G',	mod4G.[% 16QAM] as '% 16QAM 4G',	mod4G.[% 64QAM] as '% 64QAM 4G',

	case when tdd.testid is not null then tdd.HSPA_PCT else tddServ.HSPA_PCT end as 'HSPA_PCT',
	case when tdd.testid is not null then tdd.[HSPA+_PCT] else tddServ.[HSPA+_PCT] end as 'HSPA+_PCT',
	case when tdd.testid is not null then tdd.[HSPA_DC_PCT] else tddServ.[HSPA_DC_PCT] end as 'HSPA_DC_PCT',
	case when tdd.testid is not null then tdd.[HSPA+_DC_PCT] else tddServ.[HSPA+_DC_PCT] end as 'HSPA+_DC_PCT',
	-- PCC
	case when tdd.testid is not null then tdd.LTE_5Mhz_PCC_PCT else tddServ.LTE_5Mhz_PCC_PCT end as '5Mhz Bandwidth % SC', 
	case when tdd.testid is not null then tdd.LTE_10Mhz_PCC_PCT else tddServ.LTE_10Mhz_PCC_PCT end as '10Mhz Bandwidth % SC',	
	case when tdd.testid is not null then tdd.LTE_15Mhz_PCC_PCT else tddServ.LTE_15Mhz_PCC_PCT end as '15Mhz Bandwidth % SC',	
	case when tdd.testid is not null then tdd.LTE_20Mhz_PCC_PCT else tddServ.LTE_20Mhz_PCC_PCT end as '20Mhz Bandwidth % SC',

	-- Performance
	-- 3G:
	cqi3G.CQI as 'CQI 3G',
	0.01*umac.AverageHappyRate as 'HappyRate', 	0.01*umac.maxHappyRate as 'Happy Rate MAX',umac.AverageSG as 'Serving Grant', 	
	umac.AverageDTXRate as 'DTX',	umac.AverageTBsize as 'avg TBs size',
	sho.percSHO as '% SHO',	'' as 'ReTrx PDU',
	
	-- 4G:
	rbs.Rbs_round as 'RBs',	rbs.maxRBs as 'Max RBs',	rbs.minRBs as 'Min RBs',	rbs.Rbs_dedicated_round as 'RBs When Allocated',
	
	cqi4G.avgCQI as 'CQI 4G',
	--cqi4G.AverageRI_PCC as 'Rank Indicator',	
	rbs.Percent_LTESharedChannelUse as 'Shared channel use',
	
	tm.percTM0 as '% TM Invalid',
	tm.percTM1 as '% TM 1: Single Antenna Port 0',
	tm.percTM2 as '% TM 2: TD Rank 1',	
	tm.percTM3 as '% TM 3: OL SM',	
	tm.percTM4 as '% TM 4: CL SM',
	tm.percTM5 as '% TM 5: MU MIMO',
	tm.percTM6 as '% TM 6: CL RANK1 PC',
	tm.percTM7 as '% TM 7: Single Antenna Port 5',
	tm.percTM8 as '% TM 8',
	tm.percTM9 as '% TM 9',
	tm.percTMunknown as '% TM Unknown',        	

	-- INFO RADIO:
	tra.RxLev,	tra.RxQual,
	tri.BCCH as BCCH_Ini,	tri.BSIC as BSIC_Ini,	tri.RxLev as RxLev_Ini,	tri.RxQual as RxQual_Ini,
	trf.BCCH as BCCH_Fin,	trf.BSIC as BSIC_Fin,	trf.RxLev as RxLev_Fin,	trf.RxQual as RxQual_Fin,
	tra.RxLev_min,	tra.RxQual_min,
	tra.RSCP as 'RSCP_avg',	tra.EcIo as 'EcI0_avg',
	tri.PSC as PSC_Ini,	tri.RSCP as RSCP_Ini,	tri.EcIo as EcIo_Ini,	tri.UARFCN as UARFCN_Ini,
	trf.PSC as PSC_Fin,	trf.RSCP as RSCP_Fin,	trf.EcIo as EcIo_Fin,	trf.UARFCN as UARFCN_Fin,
	tra.RSCP_min,	tra.EcIo_min,
	tra.RSRP as 'RSRP_avg',	tra.RSRQ as 'RSRQ_avg',	tra.SINR as 'SINR_avg',
	tri.PCI as PCI_Ini,	tri.RSRP as RSRP_Ini,	tri.RSRQ as RSRQ_Ini,	tri.SINR as SINR_Ini,		tri.EARFCN as EARFCN_Ini,
	trf.PCI as PCI_Fin,	trf.RSRP as RSRP_Fin,	trf.RSRQ as RSRQ_Fin,	trf.SINR as SINR_Fin,		trf.EARFCN as EARFCN_Fin,
	tri.CId as CellId_Ini,	tri.LAC as 'LAC/TAC_Ini',	tri.RNCID as RNC_Ini,
	trf.CId as CellId_Fin,	trf.LAC as 'LAC/TAC_Fin',	trf.RNCID as RNC_Fin,

	---------------
	-- INFO PARCELA:
	tri.longitude as 'Longitud Inicial',	tri.latitude as 'Latitud Inicial',	
	trf.longitude as 'Longitud Final',	trf.latitude as 'Latitud Final',

	-- @ERC: Valores sin updates para montar los libros externos de errores de datos
	--CAC 10/08/2017: se incorpora información análoga para test de NC
	--thput_Transf.[ThputApp_nu],			thput_Transf.[DataTransferred_nu],		thput_Transf.[SessionTime_nu],		
	--thput_Transf.[TransferTime_nu],		1000.0*thput_Transf.[IPAccessTime_nu] as [IPAccessTime_sec_nu], -- este no se borra ya que no se calculan kpi en DL/UL, pero si se hiciera mas adelante -> bastaria un update al otro campo		
	
	case when TestType = 'UL_CE' then thput_Transf.[ThputApp_nu] else thput_Transf_NC.[ThputApp_nu_UL] end as [ThputApp_nu],		
	case when TestType = 'UL_CE' then thput_Transf.[DataTransferred_nu] else thput_Transf_NC.[DataTransferred_nu_UL] end as [DataTransferred_nu],		
	case when TestType = 'UL_CE' then thput_Transf.[SessionTime_nu] else thput_Transf_NC.[SessionTime_nu] end as [SessionTime_nu],	
	case when TestType = 'UL_CE' then thput_Transf.[TransferTime_nu] else thput_Transf_NC.[TransferTime_nu] end as [TransferTime_nu],	
	case when TestType = 'UL_CE' then 1000.0*thput_Transf.[IPAccessTime_nu] else 1000.0*thput_Transf_NC.[IPAccessTime_nu] end as [IPAccessTime_sec_nu],	
	

	-- @ERC: Se añade info de tecnologia inicio/fin para añadir en el reporte
	tri.Tech_Ini,	trf.Tech_Fin,		
	
	-- @DGP: Se añade la info de uso de DC por banda
	--cqi3G.DualCarrier_use_U2100 as '% Dual Carrier U2100',	cqi3G.DualCarrier_use_U900 as '% Dual Carrier U900',

	null as '% Dual Carrier U2100',	null as '% Dual Carrier U900',
	-- @DGP: Se añade la interferencia UL media
	ulint.UL_Interference,

	-- @ERC: KPIID de P3 - de momento asi, mas adelante (cd funcionen los kpiid) la suma del transfer, dns e ip access
	nullif(ul_kpiid.[SessionTime],0) as SessionTime,
	
	pdp.PDP_Activate_Ratio,
	pag.Paging_Success_Ratio,
	neigh.EARFCN_N1,	neigh.PCI_N1,		neigh.RSRP_N1,	neigh.RSRQ_N1,
	ho4G.num_HO_S1X2,	ho4G.duration_S1X2_avg,	ho4G.S1X2HO_SR,
	win.Max_Win as Max_Window_Size,
	
	tcphs.TCP_HandShake_Average,

	--@CAC: CQI por tecnologia
	cqi3G.CQI_UMTS900 as 'CQI UMTS900',		cqi3G.CQI_UMTS2100 as 'CQI UMTS2100',
	cqi4G.avgCQI_LTE2600	as 'CQI LTE2600',		cqi4G.avgCQI_LTE1800 as 'CQI LTE1800',
	cqi4G.avgCQI_LTE800		as 'CQI LTE800',		cqi4G.avgCQI_LTE2100 as 'CQI LTE2100',f.IMSI,

	--@ERC: MIMO
	cqi4G.perc_MIMO_PCC as '% MIMO',
	cqi4G.perc_RI2_TM2_PCC as '% RI2_TM2',
	cqi4G.perc_RI2_TM3_PCC as '% RI2_TM3',
	cqi4G.perc_RI2_TM4_PCC as '% RI2_TM4',

	cqi4G.perc_RI1_PCC as '% RI1',
	cqi4G.perc_RI2_PCC as '% RI2', 

	-- 20170321 - @ERC: Nuevos KPis y parametros:
	f.ASideDevice, f.BSideDevice, f.SWVersion,

	tdd.HSPA_PCT as 'HSPA_PCT real',
	tdd.[HSPA+_PCT] as 'HSPA+_PCT real',
	tdd.[HSPA_DC_PCT] as 'HSPA_DC_PCT real',
	tdd.[HSPA+_DC_PCT] as 'HSPA+_DC_PCT real',
	-- SC
	tdd.LTE_5Mhz_PCC_PCT as '5Mhz Bandwidth % SC real ', 
	tdd.LTE_10Mhz_PCC_PCT as '10Mhz Bandwidth % SC real ',	
	tdd.LTE_15Mhz_PCC_PCT as '15Mhz Bandwidth % SC real ',	
	tdd.LTE_20Mhz_PCC_PCT as '20Mhz Bandwidth % SC real ',

	tdd.DLBandWidth_est as 'BW_PCC_est',
	null as 'Info_Update'
	
--into Lcc_Data_HTTPTransfer_UL
from 
	FileList f, Sessions s, TestInfo t
	-- COMUNES:
		LEFT OUTER JOIN _BW_acotado_acc	pctBw	on pctBw.TestId=t.TestId and pctBw.SessionId=t.SessionId
		LEFT OUTER JOIN _PCT_TECH_Data_acotado_acc	pctTech	on (pctTech.TestId=t.TestId and pctTech.SessionId=t.SessionId )
		LEFT OUTER JOIN _lcc_http_UL ul_kpiid		on (ul_kpiid.TestId=t.TestId and ul_kpiid.SessionId=t.SessionId )
		LEFT OUTER JOIN _THPUT thput				on (t.SessionId=thput.SessionId and t.TestId=thput.testid and thput.direction='Uplink')	
		LEFT OUTER JOIN _THPUT_Transf thput_Transf	on (t.SessionId=thput_Transf.SessionId and t.TestId=thput_Transf.testid)		
		--CAC 10/08/2017: se incorpora información análoga para test de NC
		LEFT OUTER JOIN _THPUT_Transf_NC thput_Transf_NC on (t.SessionId=thput_Transf_NC.SessionId and t.TestId=thput_Transf_NC.testid)
		LEFT OUTER JOIN _THPUT_RLC thput_rlc		on (t.SessionId=thput_rlc.SessionId and t.TestId=thput_rlc.testid)
		
		LEFT OUTER JOIN _TECH_RADIO_INI_Data tri	on (t.SessionId=tri.SessionId and t.TestId=tri.testid)
		LEFT OUTER JOIN _TECH_RADIO_FIN_Data trf	on (t.SessionId=trf.SessionId and t.TestId=trf.testid)
		LEFT OUTER JOIN _TECH_RADIO_AVG_Data tra	on (t.SessionId=tra.SessionId and t.TestId=tra.testid)	
	
	-- 3G:
		LEFT OUTER JOIN _SF sf				on sf.TestId=t.TestId and sf.SessionId=t.SessionId
		LEFT OUTER JOIN _ULMAC umac			on umac.TestId=t.TestId and umac.SessionId=t.SessionId
		LEFT OUTER JOIN _CQI_3G_acotado_acc cqi3G	on cqi3G.TestId=t.TestId and cqi3G.SessionId=t.SessionId
		LEFT OUTER JOIN _SHOs sho			on sho.TestId=t.TestId and sho.SessionId=t.SessionId
		LEFT OUTER JOIN _UL_Int ulint		on ulint.TestId=t.TestId and ulint.SessionId=t.SessionId		
	-- 4G:
		LEFT OUTER JOIN _MOD_4G mod4G			on (t.SessionId=mod4G.SessionId and t.TestId=mod4G.testid and mod4G.Direction='Uplink') 
		LEFT OUTER JOIN _CQI_4G_acotado_acc cqi4G	on (t.SessionId=cqi4G.SessionId and t.TestId=cqi4G.testid)
		LEFT OUTER JOIN _RBs_UL rbs				on (t.SessionId=rbs.SessionId and t.TestId=rbs.testid and rbs.Direction='Uplink') 
		LEFT OUTER JOIN _TM_UL_acotado_acc tm		on (t.SessionId=tm.SessionId and t.TestId=tm.testid)

	-- KPI EXTRA:
		LEFT OUTER JOIN _PDP pdp		on pdp.TestId=t.TestId and pdp.SessionId=t.SessionId
		LEFT OUTER JOIN _Paging pag		on pag.TestId=t.TestId and pag.SessionId=t.SessionId
		LEFT OUTER JOIN _NEIGH neigh		on neigh.TestId=t.TestId and neigh.SessionId=t.SessionId
		LEFT OUTER JOIN _4GHO ho4G			on ho4G.TestId=t.TestId and ho4G.SessionId=t.SessionId		
		LEFT OUTER JOIN _Window win			on win.TestId=t.TestId and win.SessionId=t.SessionId	

	--OSP:
		LEFT OUTER JOIN _Tech_Duration_Distribution_acotado_acc tdd				on (tdd.sessionid=t.sessionid and tdd.testid=t.testid)
		LEFT OUTER JOIN _Tech_Duration_Distribution_acotado_acc_Serv tddServ	on (tddServ.sessionid=t.sessionid and tddServ.testid=t.testid)
		LEFT OUTER JOIN _TCP_3WAY_HANDSHAKE tcphs			on (tcphs.sessionid=t.sessionid and tcphs.testid=t.testid)

where 
	t.SessionId=s.SessionId and s.FileId=f.FileId
	and s.sessionType='data'  
	and t.typeoftest in ('HTTPTransfer','Capacity') and t.direction='Uplink'
	and s.valid=1 and t.valid=1
	and ErrorType='Accessibility'

	and t.testid > @maxTestid_UL
	and RIGHT(LEFT(f.IMSI,5),2) in (1,7,3,4)	
order by f.FileId, t.SessionId, t.TestId	

select 'Fin creacion tabla Lcc_Data_HTTPTransfer_UL' info


-- (3)
-- *********************************************
----		TABLA FINAL HTTP Browser		----	select * from Lcc_Data_HTTPTransfer_UL -- _lcc_http_DL
-- *********************************************	
select 'Inicio creacion tabla Lcc_Data_HTTPBrowser' info

--Test con ErrorType <> 'Accessibility', limitamos algunos KPIs al momento de la navegacion
insert into Lcc_Data_HTTPBrowser
select
	-- Info general 
	f.CallingModule as MTU,	f.IMEI,		f.CollectionName,	LEFT(f.IMSI,3) as MCC,	RIGHT(LEFT(f.IMSI,5),2) as MNC,	t.startDate,
	t.startTime,	DATEADD(ms, t.duration ,t.startTime) as endTime,	t.SessionId, f.FileId, t.TestId, t.typeoftest, t.direction, s.info,

	-- _lcc_http_browser
	br_kpiid.Testtype as TestType, '2' as 'ServiceType',	
	br_kpiid.DataTransferred as 'DataTransferred',		
	br_kpiid.ErrorCause as 'ErrorCause',
	br_kpiid.ErrorType,
	br_kpiid.Throughput as 'Throughput',	

	thput.maxThput_kbps as Throughput_MAX,
	
	-- PCC:
	thput.DataTransferred_PCC as DataTransferred_PCC,	thput.TransferTime_PCC as TransferTime_PCC,	
	thput.avgThput_kbps_PCC as Throughput_PCC,			thput.maxThput_kbps_PCC as Throughput_MAX_PCC,
		
	-- SCC1:
	thput.DataTransferred_SCC1 as DataTransferred_SCC1,		thput.TransferTime_SCC1 as TransferTime_SCC1,
	thput.avgThput_kbps_SCC1 as Throughput_SCC1,			thput.maxThput_kbps_SCC1 as Throughput_MAX_SCC1,

	-- SCC2:
	thput.DataTransferred_SCC2 as DataTransferred_SCC2,		thput.TransferTime_SCC2 as TransferTime_SCC2,
	thput.avgThput_kbps_SCC2 as Throughput_SCC2,			thput.maxThput_kbps_SCC2 as Throughput_MAX_SCC2,
	
	-- Web Time Kepler y Web Time Mobile Kepler:
	-- Times:
	br_kpiid.IPAccessT/1000.0 as 'IP Service Setup Time (s)',
	isnull(br_kpiid.DNST/1000.0,0 )as 'DNS Resolution (s)',	
	br_kpiid.transferT/1000.0 as 'Transfer Time (s)',
	br_kpiid.sessionT/1000.0  as 'Session Time (s)',		-- es la suma del DNs time y el session time

	-- Technology:		- tech info DL
	-- PCC:
	ISNULL(pctTech.pctLTE, 0) as '% LTE',	ISNULL(pctTech.pctWCDMA, 0) as '% WCDMA',	ISNULL(pctTech.pctGSM, 0) as '% GSM',
	ISNULL(pctTech.pct_F1_U2100, 0) as '% F1 U2100',	ISNULL(pctTech.pct_F2_U2100, 0) as '% F2 U2100',	ISNULL(pctTech.pct_F3_U2100, 0) as '% F3 U2100',
	ISNULL(pctTech.pct_F1_U900, 0) as '% F1 U900',		ISNULL(pctTech.pct_F2_U900, 0) as '% F2 U900',		
	ISNULL(pctTech.pctUMTS_2100, 0) as '% U2100',	ISNULL(pctTech.pctUMTS_900, 0) as '% U900',		ISNULL(pctTech.pctLTE_2600, 0) as '% LTE2600',
	ISNULL(pctTech.pctLTE_2100, 0) as '% LTE2100',	ISNULL(pctTech.pctLTE_1800, 0) as '% LTE1800',	ISNULL(pctTech.pctLTE_800, 0) as '% LTE800',			
	ISNULL(pctTech.[pctGMS_DCS], 0) as 'DCS %',		ISNULL(pctTech.[pctGSM_EGSM], 0) as 'GSM %',	ISNULL(pctTech.[pctGSM_GSM], 0) as 'EGSM %',
	
	ISNULL(pctTech.Roaming_VF, 0) as 'Roaming_VF',ISNULL(pctTech.Roaming_MV, 0) as 'Roaming_MV',ISNULL(pctTech.Roaming_OR, 0) as 'Roaming_OR',ISNULL(pctTech.Roaming_YO, 0) as 'Roaming_YO',
	ISNULL(pctTech.Roaming_U900, 0) as 'Roaming_U900',ISNULL(pctTech.Roaming_U2100, 0) as 'Roaming_U2100',
	ISNULL(pctTech.Roaming_LTE800, 0) as 'Roaming_LTE800',ISNULL(pctTech.Roaming_LTE1800, 0) as 'Roaming_LTE1800',ISNULL(pctTech.Roaming_LTE2100, 0) as 'Roaming_LTE2100',ISNULL(pctTech.Roaming_LTE2600, 0) as 'Roaming_LTE2600',

	ISNULL(pctTech.Duration_Roaming_VF, 0) as 'Duration_roaming_VF',ISNULL(pctTech.Duration_Roaming_MV, 0) as 'Duration_roaming_MV',ISNULL(pctTech.Duration_Roaming_OR, 0) as 'Duration_roaming_OR',ISNULL(pctTech.Duration_Roaming_YO, 0) as 'Duration_roaming_YO',
	ISNULL(pctTech.Duration_Roaming_U900, 0) as 'Duration_roaming_U900',ISNULL(pctTech.Duration_Roaming_U2100, 0) as 'Duration_roaming_U2100',
	ISNULL(pctTech.Duration_Roaming_LTE800, 0) as 'Duration_roaming_LTE800',ISNULL(pctTech.Duration_Roaming_LTE1800, 0) as 'Duration_roaming_LTE1800',ISNULL(pctTech.Duration_Roaming_LTE2100, 0) as 'Duration_roaming_LTE2100',ISNULL(pctTech.Duration_Roaming_LTE2600, 0) as 'Duration_roaming_LTE2600',

	-- SCC1:
	ISNULL(pctTech.pctLTE_2600_SCC1, 0) as '% LTE2600_SCC1', ISNULL(pctTech.pctLTE_2100_SCC1, 0) as '% LTE2100_SCC1', ISNULL(pctTech.pctLTE_1800_SCC1, 0) as '% LTE1800_SCC1', ISNULL(pctTech.pctLTE_800_SCC1, 0) as '% LTE800_SCC1',	

	-- SCC1:
	ISNULL(pctTech.pctLTE_2600_SCC2, 0) as '% LTE2600_SCC2', ISNULL(pctTech.pctLTE_2100_SCC2, 0) as '% LTE2100_SCC2', ISNULL(pctTech.pctLTE_1800_SCC2, 0) as '% LTE1800_SCC2', ISNULL(pctTech.pctLTE_800_SCC2, 0) as '% LTE800_SCC2',	

	-- 3G:
	mod3G.Percent_QPSK as '% QPSK 3G',		mod3G.Percent_16QAM as '% 16QAM 3G',		mod3G.Percent_64QAM as '% 64QAM 3G',		
	mod3G.Average_codes as 'Num Codes',		mod3G.max_codes as 'Max Codes',	
	case when pctTech.pctWCDMA>0 then (case when mod3G.DualCarrier_use > 0 then 2 else 1 end) end as 'Carriers',
	case when tdd.testid is not null then tdd.DualCarrier_3G else tddServ.DualCarrier_3G end as [% Dual Carrier],
	
	-- 4G:			
	-- CA
	mod4G.[% QPSK] as '% QPSK 4G',	mod4G.[% 16QAM] as '% 16QAM 4G',	mod4G.[% 64QAM] as '% 64QAM 4G',	mod4G.[% 256QAM] as '% 256QAM 4G',
	-- PCC:
	mod4G.[% QPSK PCC] as '% QPSK 4G PCC',	mod4G.[% 16QAM PCC] as '% 16QAM 4G PCC',	mod4G.[% 64QAM PCC] as '% 64QAM 4G PCC',	mod4G.[% 256QAM PCC] as '% 256QAM 4G ',
	-- SCC1:
	mod4G.[% QPSK SCC1] as '% QPSK 4G SCC1',	mod4G.[% 16QAM SCC1] as '% 16QAM 4G SCC1',	mod4G.[% 64QAM SCC1] as '% 64QAM 4G SCC1',	mod4G.[% 256QAM SCC1] as '% 256QAM 4G SCC1',
	-- SCC2:
	mod4G.[% QPSK SCC2] as '% QPSK 4G SCC2',	mod4G.[% 16QAM SCC2] as '% 16QAM 4G SCC2',	mod4G.[% 64QAM SCC2] as '% 64QAM 4G SCC2',	mod4G.[% 256QAM SCC2] as '% 256QAM 4G SCC2',
		
	case when tdd.testid is not null then tdd.HSPA_PCT else tddServ.HSPA_PCT end as 'HSPA_PCT',
	case when tdd.testid is not null then tdd.[HSPA+_PCT] else tddServ.[HSPA+_PCT] end as 'HSPA+_PCT',
	case when tdd.testid is not null then tdd.[HSPA_DC_PCT] else tddServ.[HSPA_DC_PCT] end as 'HSPA_DC_PCT',
	case when tdd.testid is not null then tdd.[HSPA+_DC_PCT] else tddServ.[HSPA+_DC_PCT] end as 'HSPA+_DC_PCT',
	-- SC
	case when tdd.testid is not null then tdd.LTE_5Mhz_SC_PCT else tddServ.LTE_5Mhz_SC_PCT end as '5Mhz Bandwidth % SC', 
	case when tdd.testid is not null then tdd.LTE_10Mhz_SC_PCT else tddServ.LTE_10Mhz_SC_PCT end as '10Mhz Bandwidth % SC',	
	case when tdd.testid is not null then tdd.LTE_15Mhz_SC_PCT else tddServ.LTE_15Mhz_SC_PCT end as '15Mhz Bandwidth % SC',	
	case when tdd.testid is not null then tdd.LTE_20Mhz_SC_PCT else tddServ.LTE_20Mhz_SC_PCT end as '20Mhz Bandwidth % SC',
	-- CA
	case when tdd.testid is not null then tdd.LTE_15Mhz_CA_PCT else tddServ.LTE_15Mhz_CA_PCT end as '15Mhz Bandwidth % CA',	
	case when tdd.testid is not null then tdd.LTE_20Mhz_CA_PCT else tddServ.LTE_20Mhz_CA_PCT end as '20Mhz Bandwidth % CA',	
	case when tdd.testid is not null then tdd.LTE_25Mhz_CA_PCT else tddServ.LTE_25Mhz_CA_PCT end as '25Mhz Bandwidth % CA',
	case when tdd.testid is not null then tdd.LTE_30Mhz_CA_PCT else tddServ.LTE_30Mhz_CA_PCT end as '30Mhz Bandwidth % CA',	
	case when tdd.testid is not null then tdd.LTE_35Mhz_CA_PCT else tddServ.LTE_35Mhz_CA_PCT end as '35Mhz Bandwidth % CA',	
	case when tdd.testid is not null then tdd.LTE_40Mhz_CA_PCT else tddServ.LTE_40Mhz_CA_PCT end as '40Mhz Bandwidth % CA',
	-- 3C
	case when tdd.testid is not null then tdd.LTE_25Mhz_3C_PCT else tddServ.LTE_25Mhz_3C_PCT end as '25Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_30Mhz_3C_PCT else tddServ.LTE_30Mhz_3C_PCT end as '30Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_35Mhz_3C_PCT else tddServ.LTE_35Mhz_3C_PCT end as '35Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_40Mhz_3C_PCT else tddServ.LTE_40Mhz_3C_PCT end as '40Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_45Mhz_3C_PCT else tddServ.LTE_45Mhz_3C_PCT end as '45Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_50Mhz_3C_PCT else tddServ.LTE_50Mhz_3C_PCT end as '50Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_55Mhz_3C_PCT else tddServ.LTE_55Mhz_3C_PCT end as '55Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_60Mhz_3C_PCT else tddServ.LTE_60Mhz_3C_PCT end as '60Mhz Bandwidth % 3C',

	--PCC
	case when tdd.testid is not null then tdd.LTE_5Mhz_PCC_PCT else tddServ.LTE_5Mhz_PCC_PCT end as '5Mhz Bandwidth PCC %', 
	case when tdd.testid is not null then tdd.LTE_10Mhz_PCC_PCT else tddServ.LTE_10Mhz_PCC_PCT end as '10Mhz Bandwidth PCC %', 
	case when tdd.testid is not null then tdd.LTE_15Mhz_PCC_PCT else tddServ.LTE_15Mhz_PCC_PCT end as '15Mhz Bandwidth PCC %', 
	case when tdd.testid is not null then tdd.LTE_20Mhz_PCC_PCT else tddServ.LTE_20Mhz_PCC_PCT end as '20Mhz Bandwidth PCC %',
	--SCC1
	case when tdd.testid is not null then tdd.LTE_5Mhz_SCC1_PCT else tddServ.LTE_5Mhz_SCC1_PCT end as '5Mhz Bandwidth SCC1 %',
	case when tdd.testid is not null then tdd.LTE_10Mhz_SCC1_PCT else tddServ.LTE_10Mhz_SCC1_PCT end as '10Mhz Bandwidth SCC1 %', 
	case when tdd.testid is not null then tdd.LTE_15Mhz_SCC1_PCT else tddServ.LTE_15Mhz_SCC1_PCT end as '15Mhz Bandwidth SCC1 %', 
	case when tdd.testid is not null then tdd.LTE_20Mhz_SCC1_PCT else tddServ.LTE_20Mhz_SCC1_PCT end as '20Mhz Bandwidth SCC1 %',
	--SCC2
	case when tdd.testid is not null then tdd.LTE_5Mhz_SCC2_PCT else tddServ.LTE_5Mhz_SCC2_PCT end as '5Mhz Bandwidth SCC2 %', 
	case when tdd.testid is not null then tdd.LTE_10Mhz_SCC2_PCT else tddServ.LTE_10Mhz_SCC2_PCT end as '10Mhz Bandwidth SCC2 %', 
	case when tdd.testid is not null then tdd.LTE_15Mhz_SCC2_PCT else tddServ.LTE_15Mhz_SCC2_PCT end as '15Mhz Bandwidth SCC2 %', 
	case when tdd.testid is not null then tdd.LTE_20Mhz_SCC2_PCT else tddServ.LTE_20Mhz_SCC2_PCT end as '20Mhz Bandwidth SCC2 %',

	-- Performance:	
	-- 3G:
	cqi3G.CQI as 'CQI 3G',
	100.0*hs3G.hscch_use as '% SCCH',		hq.NumHarqProc_avg as 'Procesos HARQ',	
	cqi3G.avgBLER as 'BLER DSCH',			100.0*cqi3G.numDtx_DL as 'DTX DSCH',	100.0*cqi3G.NumAck_DL as 'ACKs',		100.0*cqi3G.NumNack_DL as '% NACKs',			
	mod3G.avgRateRetransmissions as 'Retrx DSCH',										
	thput_rlc.AvgRLCDLBLER as 'BLER RLC',	thput_rlc.AvgRLCDLThrpt as 'RLC Thput',

	-- 4G:
	rbs.Rbs_round_pond as 'RBs',	rbs.maxRBs as 'Max RBs',	rbs.minRBs as 'Min RBs',	rbs.Rbs_dedicated_round_pond as 'RBs When Allocated',	
	rbs.Percent_LTESharedChannelUse as 'Shared channel use',	 
	-- PCC:
	rbs_c.Rbs_round_PCC as 'RBs PCC',	rbs_c.maxRBs_PCC as 'Max RBs PCC',	rbs_c.minRBs_PCC as 'Min RBs PCC',	rbs_c.Rbs_dedicated_round_PCC as 'RBs When Allocated PCC',	
	cqi4G.avgCQI_PCC as 'CQI 4G PCC',		
	-- SCC1:
	rbs_c.Rbs_round_SCC1 as 'RBs SCC1',
	rbs_c.maxRBs_SCC1 as 'Max RBs SCC1',
	rbs_c.minRBs_SCC1 as 'Min RBs SCC1',
	rbs_c.Rbs_dedicated_round_SCC1 as 'RBs When Allocated SCC1',	
	cqi4G.avgCQI_SCC1 as 'CQI 4G SCC1',		
	-- SCC2:
	rbs_c.Rbs_round_SCC2 as 'RBs SCC2',
	rbs_c.maxRBs_SCC2 as 'Max RBs SCC2',
	rbs_c.minRBs_SCC2 as 'Min RBs SCC2',
	rbs_c.Rbs_dedicated_round_SCC2 as 'RBs When Allocated SCC2',	
	cqi4G.avgCQI_SCC2 as 'CQI 4G SCC2',		
	
	-- INFO RADIO:
	tra.RxLev,	tra.RxQual,
	tri.BCCH as BCCH_Ini,	tri.BSIC as BSIC_Ini,	tri.RxLev as RxLev_Ini,	tri.RxQual as RxQual_Ini,
	trf.BCCH as BCCH_Fin,	trf.BSIC as BSIC_Fin,	trf.RxLev as RxLev_Fin,	trf.RxQual as RxQual_Fin,
	tra.RxLev_min,	tra.RxQual_min,
	tra.RSCP as 'RSCP_avg',	tra.EcIo as 'EcI0_avg',
	tri.PSC as PSC_Ini,	tri.RSCP as RSCP_Ini,	tri.EcIo as EcIo_Ini,	tri.UARFCN as UARFCN_Ini,
	trf.PSC as PSC_Fin,	trf.RSCP as RSCP_Fin,	trf.EcIo as EcIo_Fin,	trf.UARFCN as UARFCN_Fin,
	tra.RSCP_min,	tra.EcIo_min,
	tra.RSRP as 'RSRP_avg',	tra.RSRQ as 'RSRQ_avg',	tra.SINR as 'SINR_avg',
	tri.PCI as PCI_Ini,	tri.RSRP as RSRP_Ini,	tri.RSRQ as RSRQ_Ini,	tri.SINR as SINR_Ini,		tri.EARFCN as EARFCN_Ini,
	trf.PCI as PCI_Fin,	trf.RSRP as RSRP_Fin,	trf.RSRQ as RSRQ_Fin,	trf.SINR as SINR_Fin,		trf.EARFCN as EARFCN_Fin,
	tri.CId as CellId_Ini,	tri.LAC as 'LAC/TAC_Ini',	tri.RNCID as RNC_Ini,
	trf.CId as CellId_Fin,	trf.LAC as 'LAC/TAC_Fin',	trf.RNCID as RNC_Fin,

	-- INFO PARCELA:	
	tri.longitude as 'Longitud Inicial',	tri.latitude as 'Latitud Inicial',	
	trf.longitude as 'Longitud Final',		trf.latitude as 'Latitud Final',

	--Si se recoge informacion de BW calculamos SC/CA/3C de alli, sino de la tabla physical
	case when tdd.testid is not null then tdd.SC_PCT else ca.[% SC] end as [% SC],
	case when tdd.testid is not null then tdd.CA_PCT else ca.[% CA] end as [% CA],
	case when tdd.testid is not null then tdd.[3C_PCT] else ca.[% 3C] end as [% 3C],

	-- @ERC: Valores sin updates para si hiciera falta montar los libros externos de errores de datos mas adelante
	br_kpiid.DataTransferred_nu as DataTransferred_nu,		br_kpiid.ThputApp_nu as ThputApp_nu,				br_kpiid.IPAccessTime_nu/1000.0 as IP_AccessTime_sec_nu,		
	br_kpiid.TransferTime_nu/1000.0 as Transfer_Time_sec_nu,		br_kpiid.SessionTime_nu/1000.0  as SessionTime_sec_nu,		br_kpiid.DNSTime_nu/1000.0 as DNSTime_nu,  

	-- @ERC: Se añade info de tecnologia inicio/fin para añadir en el reporte
	tri.Tech_Ini,	trf.Tech_Fin,		
	
	case when tdd.testid is not null then tdd.DualCarrier_U2100 else tddServ.DualCarrier_U2100 end as '% Dual Carrier U2100',	
	case when tdd.testid is not null then tdd.DualCarrier_U900 else tddServ.DualCarrier_U900 end as '% Dual Carrier U900',
	
	-- @DGP: Se añade la interferencia UL media
	ulint.UL_Interference,

	br_kpiid.Protocol,

	pdp.PDP_Activate_Ratio,
	pag.Paging_Success_Ratio,
	neigh.EARFCN_N1,
	neigh.PCI_N1,
	neigh.RSRP_N1,
	neigh.RSRQ_N1,
	ho4G.num_HO_S1X2,
	ho4G.duration_S1X2_avg,
	ho4G.S1X2HO_SR,
	win.Max_Win as Max_Window_Size,
	
	tcphs.TCP_HandShake_Average,

	cqi3G.CQI_UMTS900 as 'CQI UMTS900',		cqi3G.CQI_UMTS2100 as 'CQI UMTS2100',	
	
	f.IMSI,

	cqi4G.perc_MIMO as '% MIMO',
	cqi4G.perc_RI2_TM2 as '% RI2_TM2',
	cqi4G.perc_RI2_TM3 as '% RI2_TM3',
	cqi4G.perc_RI2_TM4 as '% RI2_TM4',

	cqi4G.perc_MIMO_PCC as '% MIMO_PCC',
	cqi4G.perc_RI2_TM2_PCC as '% RI2_TM2_PCC',
	cqi4G.perc_RI2_TM3_PCC as '% RI2_TM3_PCC',
	cqi4G.perc_RI2_TM4_PCC as '% RI2_TM4_PCC',

	cqi4G.perc_MIMO_SCC1 as '% MIMO_SCC1',
	cqi4G.perc_RI2_TM2_SCC1 as '% RI2_TM2_SCC1',
	cqi4G.perc_RI2_TM3_SCC1 as '% RI2_TM3_SCC1',
	cqi4G.perc_RI2_TM4_SCC1 as '% RI2_TM4_SCC1',

	cqi4G.perc_MIMO_SCC2 as '% MIMO_SCC2',
	cqi4G.perc_RI2_TM2_SCC2 as '% RI2_TM2_SCC2',
	cqi4G.perc_RI2_TM3_SCC2 as '% RI2_TM3_SCC2',
	cqi4G.perc_RI2_TM4_SCC2 as '% RI2_TM4_SCC2',

	cqi4G.perc_RI1 as '% RI1',
	cqi4G.perc_RI2 as '% RI2',
	cqi4G.perc_RI1_PCC as '% RI1_PCC',
	cqi4G.perc_RI2_PCC as '% RI2_PCC',
	cqi4G.perc_RI1_SCC1 as '% RI1_SCC1',
	cqi4G.perc_RI2_SCC1 as '% RI2_SCC1',
	cqi4G.perc_RI1_SCC2 as '% RI1_SCC2',
	cqi4G.perc_RI2_SCC2 as '% RI2_SCC2',

	cqi4G.avgCQI as 'CQI 4G',

	cqi4G.avgCQI_PCC_LTE2600	as 'CQI LTE2600 PCC',	cqi4G.avgCQI_PCC_LTE1800 as 'CQI LTE1800 PCC',
	cqi4G.avgCQI_PCC_LTE800		as 'CQI LTE800 PCC',	cqi4G.avgCQI_PCC_LTE2100 as 'CQI LTE2100 PCC',
	

	-- 20170321 - @ERC: Nuevos KPis y parametros:
	f.ASideDevice, f.BSideDevice, f.SWVersion,
	br_kpiid.url,

	tdd.HSPA_PCT as 'HSPA_PCT real',
	tdd.[HSPA+_PCT] as 'HSPA+_PCT real',
	tdd.[HSPA_DC_PCT] as 'HSPA_DC_PCT real',
	tdd.[HSPA+_DC_PCT] as 'HSPA+_DC_PCT real',
	-- SC
	tdd.LTE_5Mhz_SC_PCT as '5Mhz Bandwidth % SC real ', 
	tdd.LTE_10Mhz_SC_PCT as '10Mhz Bandwidth % SC real ',	
	tdd.LTE_15Mhz_SC_PCT as '15Mhz Bandwidth % SC real ',	
	tdd.LTE_20Mhz_SC_PCT as '20Mhz Bandwidth % SC real ',
	-- CA
	tdd.LTE_15Mhz_CA_PCT as '15Mhz Bandwidth % CA real ',	
	tdd.LTE_20Mhz_CA_PCT as '20Mhz Bandwidth % CA real ',	
	tdd.LTE_25Mhz_CA_PCT as '25Mhz Bandwidth % CA real ',
	tdd.LTE_30Mhz_CA_PCT as '30Mhz Bandwidth % CA real ',	
	tdd.LTE_35Mhz_CA_PCT as '35Mhz Bandwidth % CA real ',	
	tdd.LTE_40Mhz_CA_PCT as '40Mhz Bandwidth % CA real ',
	-- 3C
	tdd.LTE_25Mhz_3C_PCT as '25Mhz Bandwidth % 3C real ',	
	tdd.LTE_30Mhz_3C_PCT as '30Mhz Bandwidth % 3C real ',	
	tdd.LTE_35Mhz_3C_PCT as '35Mhz Bandwidth % 3C real ',	
	tdd.LTE_40Mhz_3C_PCT as '40Mhz Bandwidth % 3C real ',	
	tdd.LTE_45Mhz_3C_PCT as '45Mhz Bandwidth % 3C real ',	
	tdd.LTE_50Mhz_3C_PCT as '50Mhz Bandwidth % 3C real ',	
	tdd.LTE_55Mhz_3C_PCT as '55Mhz Bandwidth % 3C real ',	
	tdd.LTE_60Mhz_3C_PCT as '60Mhz Bandwidth % 3C real ',

	--PCC
	tdd.LTE_5Mhz_PCC_PCT as '5Mhz Bandwidth PCC % real ', 
	tdd.LTE_10Mhz_PCC_PCT as '10Mhz Bandwidth PCC % real ', 
	tdd.LTE_15Mhz_PCC_PCT as '15Mhz Bandwidth PCC % real ', 
	tdd.LTE_20Mhz_PCC_PCT as '20Mhz Bandwidth PCC % real ',
	--SCC1
	tdd.LTE_5Mhz_SCC1_PCT as '5Mhz Bandwidth SCC1 % real ', 
	tdd.LTE_10Mhz_SCC1_PCT as '10Mhz Bandwidth SCC1 % real ', 
	tdd.LTE_15Mhz_SCC1_PCT as '15Mhz Bandwidth SCC1 % real ', 
	tdd.LTE_20Mhz_SCC1_PCT as '20Mhz Bandwidth SCC1 % real ',
	--SCC2
	tdd.LTE_5Mhz_SCC2_PCT as '5Mhz Bandwidth SCC2 % real ',
	tdd.LTE_10Mhz_SCC2_PCT as '10Mhz Bandwidth SCC2 % real ', 
	tdd.LTE_15Mhz_SCC2_PCT as '15Mhz Bandwidth SCC2 % real ', 
	tdd.LTE_20Mhz_SCC2_PCT as '20Mhz Bandwidth SCC2 % real ',

	tdd.DLBandWidth_est as 'BW_PCC_est',
	null as 'Info_Update'
	
--into Lcc_Data_HTTPBrowser	 
from 
	FileList f,	Sessions s, TestInfo t
		LEFT OUTER JOIN _BW_acotado		pctBw		on pctBw.TestId=t.TestId and pctBw.SessionId=t.SessionId
		LEFT OUTER JOIN _PCT_TECH_Data_acotado		pctTech		on pctTech.TestId=t.TestId and pctTech.SessionId=t.SessionId 
		LEFT OUTER JOIN _lcc_http_browser br_kpiid		on br_kpiid.TestId=t.TestId and br_kpiid.SessionId=t.SessionId 
		LEFT OUTER JOIN _THPUT thput					on thput.SessionId=t.SessionId and thput.TestId=t.TestId and thput.direction='Downlink'		
		LEFT OUTER JOIN _TECH_RADIO_INI_Data tri		on t.SessionId=tri.SessionId and t.TestId=tri.testid
		LEFT OUTER JOIN _TECH_RADIO_FIN_Data trf		on t.SessionId=trf.SessionId and t.TestId=trf.testid
		LEFT OUTER JOIN _TECH_RADIO_AVG_Data tra		on t.SessionId=tra.SessionId and t.TestId=tra.testid
		LEFT OUTER JOIN _CQI_3G_acotado		cqi3G		on cqi3G.TestId=t.TestId and cqi3G.SessionId=t.SessionId
		LEFT OUTER JOIN _UL_Int ulint			on ulint.TestId=t.TestId and ulint.SessionId=t.SessionId

		-- KPI EXTRA:
		LEFT OUTER JOIN _PDP pdp		on pdp.TestId=t.TestId and pdp.SessionId=t.SessionId
		LEFT OUTER JOIN _Paging pag		on pag.TestId=t.TestId and pag.SessionId=t.SessionId
		LEFT OUTER JOIN _NEIGH neigh		on neigh.TestId=t.TestId and neigh.SessionId=t.SessionId
		LEFT OUTER JOIN _4GHO ho4G			on ho4G.TestId=t.TestId and ho4G.SessionId=t.SessionId		
		LEFT OUTER JOIN _Window win			on win.TestId=t.TestId and win.SessionId=t.SessionId	

		--OSP:
		LEFT OUTER JOIN _Tech_Duration_Distribution_acotado tdd				on (tdd.sessionid=t.sessionid and tdd.testid=t.testid)
		LEFT OUTER JOIN _Tech_Duration_Distribution_acotado_Serv tddServ	on (tddServ.sessionid=t.sessionid and tddServ.testid=t.testid)
		LEFT OUTER JOIN _TCP_3WAY_HANDSHAKE tcphs			on (tcphs.sessionid=t.sessionid and tcphs.testid=t.testid)

		LEFT OUTER JOIN _MOD_3G_acotado mod3G		on mod3G.TestId=t.TestId and mod3G.SessionId=t.SessionId
		LEFT OUTER JOIN _scch_use_3G hs3G	on hs3G.TestId=t.TestId and hs3G.SessionId=t.SessionId
		LEFT OUTER JOIN _HARQ hq			on hq.TestId=t.TestId and hq.SessionId=t.SessionId	
		LEFT OUTER JOIN _THPUT_RLC		thput_rlc		on (t.SessionId=thput_rlc.SessionId and t.TestId=thput_rlc.testid)

		LEFT OUTER JOIN _MOD_4G mod4G			on (t.SessionId=mod4G.SessionId and t.TestId=mod4G.testid and mod4G.direction='Downlink') 
		LEFT OUTER JOIN _RBs_DL rbs				on (t.SessionId=rbs.SessionId and t.TestId=rbs.testid and rbs.direction='Downlink') 
		LEFT OUTER JOIN _RBs_carrier_DL rbs_c	on (t.SessionId=rbs_c.SessionId and t.TestId=rbs_c.testid and rbs_c.direction='Downlink') 	
		LEFT OUTER JOIN _cqi_4G_acotado cqi4G	on (t.SessionId=cqi4G.SessionId and t.TestId=cqi4G.testid)
		LEFT OUTER JOIN _Carrier ca				on (t.SessionId=ca.SessionId and t.TestId=ca.testid) 
where 
	t.SessionId=s.SessionId and s.FileId=f.FileId
	and s.sessionType='data' 
	and t.typeoftest='HTTPBrowser' 
	and s.valid=1 and t.valid=1
	and (ErrorType is null or ErrorType<>'Accessibility')

	and t.testid > @maxTestid_BR
	and RIGHT(LEFT(f.IMSI,5),2) in (1,7,3,4)	

	
order by f.FileId, t.SessionId, t.TestId

--Test con ErrorType = 'Accessibility' tenemos en cuenta el acceso
insert into Lcc_Data_HTTPBrowser
select
	-- Info general 
	f.CallingModule as MTU,	f.IMEI,		f.CollectionName,	LEFT(f.IMSI,3) as MCC,	RIGHT(LEFT(f.IMSI,5),2) as MNC,	t.startDate,
	t.startTime,	DATEADD(ms, t.duration ,t.startTime) as endTime,	t.SessionId, f.FileId, t.TestId, t.typeoftest, t.direction, s.info,

	-- _lcc_http_browser
	br_kpiid.Testtype as TestType, '2' as 'ServiceType',	
	br_kpiid.DataTransferred as 'DataTransferred',		
	br_kpiid.ErrorCause as 'ErrorCause',
	br_kpiid.ErrorType,
	br_kpiid.Throughput as 'Throughput',	

	thput.maxThput_kbps as Throughput_MAX,
	
	-- PCC:
	thput.DataTransferred_PCC as DataTransferred_PCC,	thput.TransferTime_PCC as TransferTime_PCC,	
	thput.avgThput_kbps_PCC as Throughput_PCC,			thput.maxThput_kbps_PCC as Throughput_MAX_PCC,
		
	-- SCC1:
	thput.DataTransferred_SCC1 as DataTransferred_SCC1,		thput.TransferTime_SCC1 as TransferTime_SCC1,
	thput.avgThput_kbps_SCC1 as Throughput_SCC1,			thput.maxThput_kbps_SCC1 as Throughput_MAX_SCC1,

	-- SCC2:
	thput.DataTransferred_SCC2 as DataTransferred_SCC2,		thput.TransferTime_SCC2 as TransferTime_SCC2,
	thput.avgThput_kbps_SCC2 as Throughput_SCC2,			thput.maxThput_kbps_SCC2 as Throughput_MAX_SCC2,
	
	-- Web Time Kepler y Web Time Mobile Kepler:
	-- Times:
	br_kpiid.IPAccessT/1000.0 as 'IP Service Setup Time (s)',
	isnull(br_kpiid.DNST/1000.0,0 )as 'DNS Resolution (s)',	
	br_kpiid.transferT/1000.0 as 'Transfer Time (s)',
	br_kpiid.sessionT/1000.0  as 'Session Time (s)',		-- es la suma del DNs time y el session time

	-- Technology:		- tech info DL
	-- PCC:
	ISNULL(pctTech.pctLTE, 0) as '% LTE',	ISNULL(pctTech.pctWCDMA, 0) as '% WCDMA',	ISNULL(pctTech.pctGSM, 0) as '% GSM',
	ISNULL(pctTech.pct_F1_U2100, 0) as '% F1 U2100',	ISNULL(pctTech.pct_F2_U2100, 0) as '% F2 U2100',	ISNULL(pctTech.pct_F3_U2100, 0) as '% F3 U2100',
	ISNULL(pctTech.pct_F1_U900, 0) as '% F1 U900',		ISNULL(pctTech.pct_F2_U900, 0) as '% F2 U900',		
	ISNULL(pctTech.pctUMTS_2100, 0) as '% U2100',	ISNULL(pctTech.pctUMTS_900, 0) as '% U900',		ISNULL(pctTech.pctLTE_2600, 0) as '% LTE2600',
	ISNULL(pctTech.pctLTE_2100, 0) as '% LTE2100',	ISNULL(pctTech.pctLTE_1800, 0) as '% LTE1800',	ISNULL(pctTech.pctLTE_800, 0) as '% LTE800',			
	ISNULL(pctTech.[pctGMS_DCS], 0) as 'DCS %',		ISNULL(pctTech.[pctGSM_EGSM], 0) as 'GSM %',	ISNULL(pctTech.[pctGSM_GSM], 0) as 'EGSM %',
	
	ISNULL(pctTech.Roaming_VF, 0) as 'Roaming_VF',ISNULL(pctTech.Roaming_MV, 0) as 'Roaming_MV',ISNULL(pctTech.Roaming_OR, 0) as 'Roaming_OR',ISNULL(pctTech.Roaming_YO, 0) as 'Roaming_YO',
	ISNULL(pctTech.Roaming_U900, 0) as 'Roaming_U900',ISNULL(pctTech.Roaming_U2100, 0) as 'Roaming_U2100',
	ISNULL(pctTech.Roaming_LTE800, 0) as 'Roaming_LTE800',ISNULL(pctTech.Roaming_LTE1800, 0) as 'Roaming_LTE1800',ISNULL(pctTech.Roaming_LTE2100, 0) as 'Roaming_LTE2100',ISNULL(pctTech.Roaming_LTE2600, 0) as 'Roaming_LTE2600',

	ISNULL(pctTech.Duration_Roaming_VF, 0) as 'Duration_roaming_VF',ISNULL(pctTech.Duration_Roaming_MV, 0) as 'Duration_roaming_MV',ISNULL(pctTech.Duration_Roaming_OR, 0) as 'Duration_roaming_OR',ISNULL(pctTech.Duration_Roaming_YO, 0) as 'Duration_roaming_YO',
	ISNULL(pctTech.Duration_Roaming_U900, 0) as 'Duration_roaming_U900',ISNULL(pctTech.Duration_Roaming_U2100, 0) as 'Duration_roaming_U2100',
	ISNULL(pctTech.Duration_Roaming_LTE800, 0) as 'Duration_roaming_LTE800',ISNULL(pctTech.Duration_Roaming_LTE1800, 0) as 'Duration_roaming_LTE1800',ISNULL(pctTech.Duration_Roaming_LTE2100, 0) as 'Duration_roaming_LTE2100',ISNULL(pctTech.Duration_Roaming_LTE2600, 0) as 'Duration_roaming_LTE2600',

	-- SCC1:
	ISNULL(pctTech.pctLTE_2600_SCC1, 0) as '% LTE2600_SCC1', ISNULL(pctTech.pctLTE_2100_SCC1, 0) as '% LTE2100_SCC1', ISNULL(pctTech.pctLTE_1800_SCC1, 0) as '% LTE1800_SCC1', ISNULL(pctTech.pctLTE_800_SCC1, 0) as '% LTE800_SCC1',	

	-- SCC1:
	ISNULL(pctTech.pctLTE_2600_SCC2, 0) as '% LTE2600_SCC2', ISNULL(pctTech.pctLTE_2100_SCC2, 0) as '% LTE2100_SCC2', ISNULL(pctTech.pctLTE_1800_SCC2, 0) as '% LTE1800_SCC2', ISNULL(pctTech.pctLTE_800_SCC2, 0) as '% LTE800_SCC2',	

	-- 3G:
	mod3G.Percent_QPSK as '% QPSK 3G',		mod3G.Percent_16QAM as '% 16QAM 3G',		mod3G.Percent_64QAM as '% 64QAM 3G',		
	mod3G.Average_codes as 'Num Codes',		mod3G.max_codes as 'Max Codes',	
	case when pctTech.pctWCDMA>0 then (case when mod3G.DualCarrier_use > 0 then 2 else 1 end) end as 'Carriers',
	case when tdd.testid is not null then tdd.DualCarrier_3G else tddServ.DualCarrier_3G end as [% Dual Carrier],

	-- 4G:			
	-- CA
	mod4G.[% QPSK] as '% QPSK 4G',	mod4G.[% 16QAM] as '% 16QAM 4G',	mod4G.[% 64QAM] as '% 64QAM 4G',	mod4G.[% 256QAM] as '% 256QAM 4G',
	-- PCC:
	mod4G.[% QPSK PCC] as '% QPSK 4G PCC',	mod4G.[% 16QAM PCC] as '% 16QAM 4G PCC',	mod4G.[% 64QAM PCC] as '% 64QAM 4G PCC',	mod4G.[% 256QAM PCC] as '% 256QAM 4G ',
	-- SCC1:
	mod4G.[% QPSK SCC1] as '% QPSK 4G SCC1',	mod4G.[% 16QAM SCC1] as '% 16QAM 4G SCC1',	mod4G.[% 64QAM SCC1] as '% 64QAM 4G SCC1',	mod4G.[% 256QAM SCC1] as '% 256QAM 4G SCC1',
	-- SCC2:
	mod4G.[% QPSK SCC2] as '% QPSK 4G SCC2',	mod4G.[% 16QAM SCC2] as '% 16QAM 4G SCC2',	mod4G.[% 64QAM SCC2] as '% 64QAM 4G SCC2',	mod4G.[% 256QAM SCC2] as '% 256QAM 4G SCC2',
		
	case when tdd.testid is not null then tdd.HSPA_PCT else tddServ.HSPA_PCT end as 'HSPA_PCT',
	case when tdd.testid is not null then tdd.[HSPA+_PCT] else tddServ.[HSPA+_PCT] end as 'HSPA+_PCT',
	case when tdd.testid is not null then tdd.[HSPA_DC_PCT] else tddServ.[HSPA_DC_PCT] end as 'HSPA_DC_PCT',
	case when tdd.testid is not null then tdd.[HSPA+_DC_PCT] else tddServ.[HSPA+_DC_PCT] end as 'HSPA+_DC_PCT',
	-- SC
	case when tdd.testid is not null then tdd.LTE_5Mhz_SC_PCT else tddServ.LTE_5Mhz_SC_PCT end as '5Mhz Bandwidth % SC', 
	case when tdd.testid is not null then tdd.LTE_10Mhz_SC_PCT else tddServ.LTE_10Mhz_SC_PCT end as '10Mhz Bandwidth % SC',	
	case when tdd.testid is not null then tdd.LTE_15Mhz_SC_PCT else tddServ.LTE_15Mhz_SC_PCT end as '15Mhz Bandwidth % SC',	
	case when tdd.testid is not null then tdd.LTE_20Mhz_SC_PCT else tddServ.LTE_20Mhz_SC_PCT end as '20Mhz Bandwidth % SC',
	-- CA
	case when tdd.testid is not null then tdd.LTE_15Mhz_CA_PCT else tddServ.LTE_15Mhz_CA_PCT end as '15Mhz Bandwidth % CA',	
	case when tdd.testid is not null then tdd.LTE_20Mhz_CA_PCT else tddServ.LTE_20Mhz_CA_PCT end as '20Mhz Bandwidth % CA',	
	case when tdd.testid is not null then tdd.LTE_25Mhz_CA_PCT else tddServ.LTE_25Mhz_CA_PCT end as '25Mhz Bandwidth % CA',
	case when tdd.testid is not null then tdd.LTE_30Mhz_CA_PCT else tddServ.LTE_30Mhz_CA_PCT end as '30Mhz Bandwidth % CA',	
	case when tdd.testid is not null then tdd.LTE_35Mhz_CA_PCT else tddServ.LTE_35Mhz_CA_PCT end as '35Mhz Bandwidth % CA',	
	case when tdd.testid is not null then tdd.LTE_40Mhz_CA_PCT else tddServ.LTE_40Mhz_CA_PCT end as '40Mhz Bandwidth % CA',
	-- 3C
	case when tdd.testid is not null then tdd.LTE_25Mhz_3C_PCT else tddServ.LTE_25Mhz_3C_PCT end as '25Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_30Mhz_3C_PCT else tddServ.LTE_30Mhz_3C_PCT end as '30Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_35Mhz_3C_PCT else tddServ.LTE_35Mhz_3C_PCT end as '35Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_40Mhz_3C_PCT else tddServ.LTE_40Mhz_3C_PCT end as '40Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_45Mhz_3C_PCT else tddServ.LTE_45Mhz_3C_PCT end as '45Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_50Mhz_3C_PCT else tddServ.LTE_50Mhz_3C_PCT end as '50Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_55Mhz_3C_PCT else tddServ.LTE_55Mhz_3C_PCT end as '55Mhz Bandwidth % 3C',	
	case when tdd.testid is not null then tdd.LTE_60Mhz_3C_PCT else tddServ.LTE_60Mhz_3C_PCT end as '60Mhz Bandwidth % 3C',

	--PCC
	case when tdd.testid is not null then tdd.LTE_5Mhz_PCC_PCT else tddServ.LTE_5Mhz_PCC_PCT end as '5Mhz Bandwidth PCC %', 
	case when tdd.testid is not null then tdd.LTE_10Mhz_PCC_PCT else tddServ.LTE_10Mhz_PCC_PCT end as '10Mhz Bandwidth PCC %', 
	case when tdd.testid is not null then tdd.LTE_15Mhz_PCC_PCT else tddServ.LTE_15Mhz_PCC_PCT end as '15Mhz Bandwidth PCC %', 
	case when tdd.testid is not null then tdd.LTE_20Mhz_PCC_PCT else tddServ.LTE_20Mhz_PCC_PCT end as '20Mhz Bandwidth PCC %',
	--SCC1
	case when tdd.testid is not null then tdd.LTE_5Mhz_SCC1_PCT else tddServ.LTE_5Mhz_SCC1_PCT end as '5Mhz Bandwidth SCC1 %',
	case when tdd.testid is not null then tdd.LTE_10Mhz_SCC1_PCT else tddServ.LTE_10Mhz_SCC1_PCT end as '10Mhz Bandwidth SCC1 %', 
	case when tdd.testid is not null then tdd.LTE_15Mhz_SCC1_PCT else tddServ.LTE_15Mhz_SCC1_PCT end as '15Mhz Bandwidth SCC1 %', 
	case when tdd.testid is not null then tdd.LTE_20Mhz_SCC1_PCT else tddServ.LTE_20Mhz_SCC1_PCT end as '20Mhz Bandwidth SCC1 %',
	--SCC2
	case when tdd.testid is not null then tdd.LTE_5Mhz_SCC2_PCT else tddServ.LTE_5Mhz_SCC2_PCT end as '5Mhz Bandwidth SCC2 %', 
	case when tdd.testid is not null then tdd.LTE_10Mhz_SCC2_PCT else tddServ.LTE_10Mhz_SCC2_PCT end as '10Mhz Bandwidth SCC2 %', 
	case when tdd.testid is not null then tdd.LTE_15Mhz_SCC2_PCT else tddServ.LTE_15Mhz_SCC2_PCT end as '15Mhz Bandwidth SCC2 %', 
	case when tdd.testid is not null then tdd.LTE_20Mhz_SCC2_PCT else tddServ.LTE_20Mhz_SCC2_PCT end as '20Mhz Bandwidth SCC2 %',

	-- Performance:	
	-- 3G:
	cqi3G.CQI as 'CQI 3G',
	100.0*hs3G.hscch_use as '% SCCH',		hq.NumHarqProc_avg as 'Procesos HARQ',	
	cqi3G.avgBLER as 'BLER DSCH',			100.0*cqi3G.numDtx_DL as 'DTX DSCH',	100.0*cqi3G.NumAck_DL as 'ACKs',		100.0*cqi3G.NumNack_DL as '% NACKs',			
	mod3G.avgRateRetransmissions as 'Retrx DSCH',										
	thput_rlc.AvgRLCDLBLER as 'BLER RLC',	thput_rlc.AvgRLCDLThrpt as 'RLC Thput',

	-- 4G:
	rbs.Rbs_round_pond as 'RBs',	rbs.maxRBs as 'Max RBs',	rbs.minRBs as 'Min RBs',	rbs.Rbs_dedicated_round_pond as 'RBs When Allocated',	
	rbs.Percent_LTESharedChannelUse as 'Shared channel use',	 
	-- PCC:
	rbs_c.Rbs_round_PCC as 'RBs PCC',	rbs_c.maxRBs_PCC as 'Max RBs PCC',	rbs_c.minRBs_PCC as 'Min RBs PCC',	rbs_c.Rbs_dedicated_round_PCC as 'RBs When Allocated PCC',	
	cqi4G.avgCQI_PCC as 'CQI 4G PCC',		
	-- SCC1:
	rbs_c.Rbs_round_SCC1 as 'RBs SCC1',
	rbs_c.maxRBs_SCC1 as 'Max RBs SCC1',
	rbs_c.minRBs_SCC1 as 'Min RBs SCC1',
	rbs_c.Rbs_dedicated_round_SCC1 as 'RBs When Allocated SCC1',	
	cqi4G.avgCQI_SCC1 as 'CQI 4G SCC1',		
	-- SCC2:
	rbs_c.Rbs_round_SCC2 as 'RBs SCC2',
	rbs_c.maxRBs_SCC2 as 'Max RBs SCC2',
	rbs_c.minRBs_SCC2 as 'Min RBs SCC2',
	rbs_c.Rbs_dedicated_round_SCC2 as 'RBs When Allocated SCC2',	
	cqi4G.avgCQI_SCC2 as 'CQI 4G SCC2',		
	
	-- INFO RADIO:
	tra.RxLev,	tra.RxQual,
	tri.BCCH as BCCH_Ini,	tri.BSIC as BSIC_Ini,	tri.RxLev as RxLev_Ini,	tri.RxQual as RxQual_Ini,
	trf.BCCH as BCCH_Fin,	trf.BSIC as BSIC_Fin,	trf.RxLev as RxLev_Fin,	trf.RxQual as RxQual_Fin,
	tra.RxLev_min,	tra.RxQual_min,
	tra.RSCP as 'RSCP_avg',	tra.EcIo as 'EcI0_avg',
	tri.PSC as PSC_Ini,	tri.RSCP as RSCP_Ini,	tri.EcIo as EcIo_Ini,	tri.UARFCN as UARFCN_Ini,
	trf.PSC as PSC_Fin,	trf.RSCP as RSCP_Fin,	trf.EcIo as EcIo_Fin,	trf.UARFCN as UARFCN_Fin,
	tra.RSCP_min,	tra.EcIo_min,
	tra.RSRP as 'RSRP_avg',	tra.RSRQ as 'RSRQ_avg',	tra.SINR as 'SINR_avg',
	tri.PCI as PCI_Ini,	tri.RSRP as RSRP_Ini,	tri.RSRQ as RSRQ_Ini,	tri.SINR as SINR_Ini,		tri.EARFCN as EARFCN_Ini,
	trf.PCI as PCI_Fin,	trf.RSRP as RSRP_Fin,	trf.RSRQ as RSRQ_Fin,	trf.SINR as SINR_Fin,		trf.EARFCN as EARFCN_Fin,
	tri.CId as CellId_Ini,	tri.LAC as 'LAC/TAC_Ini',	tri.RNCID as RNC_Ini,
	trf.CId as CellId_Fin,	trf.LAC as 'LAC/TAC_Fin',	trf.RNCID as RNC_Fin,

	-- INFO PARCELA:	
	tri.longitude as 'Longitud Inicial',	tri.latitude as 'Latitud Inicial',	
	trf.longitude as 'Longitud Final',		trf.latitude as 'Latitud Final',

	--Si se recoge informacion de BW calculamos SC/CA/3C de alli, sino de la tabla serving (no de physical como resto de test)
	case when tdd.testid is not null then tdd.SC_PCT else tddServ.SC_PCT end as [% SC],
	case when tdd.testid is not null then tdd.CA_PCT else tddServ.CA_PCT end as [% CA],
	case when tdd.testid is not null then tdd.[3C_PCT] else tddServ.[3C_PCT] end as [% 3C],

	-- @ERC: Valores sin updates para si hiciera falta montar los libros externos de errores de datos mas adelante
	br_kpiid.DataTransferred_nu as DataTransferred_nu,		br_kpiid.ThputApp_nu as ThputApp_nu,				br_kpiid.IPAccessTime_nu/1000.0 as IP_AccessTime_sec_nu,		
	br_kpiid.TransferTime_nu/1000.0 as Transfer_Time_sec_nu,		br_kpiid.SessionTime_nu/1000.0  as SessionTime_sec_nu,		br_kpiid.DNSTime_nu/1000.0 as DNSTime_nu,  

	-- @ERC: Se añade info de tecnologia inicio/fin para añadir en el reporte
	tri.Tech_Ini,	trf.Tech_Fin,		
	
	case when tdd.testid is not null then tdd.DualCarrier_U2100 else tddServ.DualCarrier_U2100 end as '% Dual Carrier U2100',	
	case when tdd.testid is not null then tdd.DualCarrier_U900 else tddServ.DualCarrier_U900 end as '% Dual Carrier U900',
	
	-- @DGP: Se añade la interferencia UL media
	ulint.UL_Interference,

	br_kpiid.Protocol,

	pdp.PDP_Activate_Ratio,
	pag.Paging_Success_Ratio,
	neigh.EARFCN_N1,
	neigh.PCI_N1,
	neigh.RSRP_N1,
	neigh.RSRQ_N1,
	ho4G.num_HO_S1X2,
	ho4G.duration_S1X2_avg,
	ho4G.S1X2HO_SR,
	win.Max_Win as Max_Window_Size,
	
	tcphs.TCP_HandShake_Average,

	cqi3G.CQI_UMTS900 as 'CQI UMTS900',		cqi3G.CQI_UMTS2100 as 'CQI UMTS2100',	
	
	f.IMSI,

	cqi4G.perc_MIMO as '% MIMO',
	cqi4G.perc_RI2_TM2 as '% RI2_TM2',
	cqi4G.perc_RI2_TM3 as '% RI2_TM3',
	cqi4G.perc_RI2_TM4 as '% RI2_TM4',

	cqi4G.perc_MIMO_PCC as '% MIMO_PCC',
	cqi4G.perc_RI2_TM2_PCC as '% RI2_TM2_PCC',
	cqi4G.perc_RI2_TM3_PCC as '% RI2_TM3_PCC',
	cqi4G.perc_RI2_TM4_PCC as '% RI2_TM4_PCC',

	cqi4G.perc_MIMO_SCC1 as '% MIMO_SCC1',
	cqi4G.perc_RI2_TM2_SCC1 as '% RI2_TM2_SCC1',
	cqi4G.perc_RI2_TM3_SCC1 as '% RI2_TM3_SCC1',
	cqi4G.perc_RI2_TM4_SCC1 as '% RI2_TM4_SCC1',

	cqi4G.perc_MIMO_SCC2 as '% MIMO_SCC2',
	cqi4G.perc_RI2_TM2_SCC2 as '% RI2_TM2_SCC2',
	cqi4G.perc_RI2_TM3_SCC2 as '% RI2_TM3_SCC2',
	cqi4G.perc_RI2_TM4_SCC2 as '% RI2_TM4_SCC2',

	cqi4G.perc_RI1 as '% RI1',
	cqi4G.perc_RI2 as '% RI2',
	cqi4G.perc_RI1_PCC as '% RI1_PCC',
	cqi4G.perc_RI2_PCC as '% RI2_PCC',
	cqi4G.perc_RI1_SCC1 as '% RI1_SCC1',
	cqi4G.perc_RI2_SCC1 as '% RI2_SCC1',
	cqi4G.perc_RI1_SCC2 as '% RI1_SCC2',
	cqi4G.perc_RI2_SCC2 as '% RI2_SCC2',

	cqi4G.avgCQI as 'CQI 4G',

	cqi4G.avgCQI_PCC_LTE2600	as 'CQI LTE2600 PCC',	cqi4G.avgCQI_PCC_LTE1800 as 'CQI LTE1800 PCC',
	cqi4G.avgCQI_PCC_LTE800		as 'CQI LTE800 PCC',	cqi4G.avgCQI_PCC_LTE2100 as 'CQI LTE2100 PCC',
	

	-- 20170321 - @ERC: Nuevos KPis y parametros:
	f.ASideDevice, f.BSideDevice, f.SWVersion,
	br_kpiid.url,

	tdd.HSPA_PCT as 'HSPA_PCT real',
	tdd.[HSPA+_PCT] as 'HSPA+_PCT real',
	tdd.[HSPA_DC_PCT] as 'HSPA_DC_PCT real',
	tdd.[HSPA+_DC_PCT] as 'HSPA+_DC_PCT real',
	-- SC
	tdd.LTE_5Mhz_SC_PCT as '5Mhz Bandwidth % SC real ', 
	tdd.LTE_10Mhz_SC_PCT as '10Mhz Bandwidth % SC real ',	
	tdd.LTE_15Mhz_SC_PCT as '15Mhz Bandwidth % SC real ',	
	tdd.LTE_20Mhz_SC_PCT as '20Mhz Bandwidth % SC real ',
	-- CA
	tdd.LTE_15Mhz_CA_PCT as '15Mhz Bandwidth % CA real ',	
	tdd.LTE_20Mhz_CA_PCT as '20Mhz Bandwidth % CA real ',	
	tdd.LTE_25Mhz_CA_PCT as '25Mhz Bandwidth % CA real ',
	tdd.LTE_30Mhz_CA_PCT as '30Mhz Bandwidth % CA real ',	
	tdd.LTE_35Mhz_CA_PCT as '35Mhz Bandwidth % CA real ',	
	tdd.LTE_40Mhz_CA_PCT as '40Mhz Bandwidth % CA real ',
	-- 3C
	tdd.LTE_25Mhz_3C_PCT as '25Mhz Bandwidth % 3C real ',	
	tdd.LTE_30Mhz_3C_PCT as '30Mhz Bandwidth % 3C real ',	
	tdd.LTE_35Mhz_3C_PCT as '35Mhz Bandwidth % 3C real ',	
	tdd.LTE_40Mhz_3C_PCT as '40Mhz Bandwidth % 3C real ',	
	tdd.LTE_45Mhz_3C_PCT as '45Mhz Bandwidth % 3C real ',	
	tdd.LTE_50Mhz_3C_PCT as '50Mhz Bandwidth % 3C real ',	
	tdd.LTE_55Mhz_3C_PCT as '55Mhz Bandwidth % 3C real ',	
	tdd.LTE_60Mhz_3C_PCT as '60Mhz Bandwidth % 3C real ',

	--PCC
	tdd.LTE_5Mhz_PCC_PCT as '5Mhz Bandwidth PCC % real ', 
	tdd.LTE_10Mhz_PCC_PCT as '10Mhz Bandwidth PCC % real ', 
	tdd.LTE_15Mhz_PCC_PCT as '15Mhz Bandwidth PCC % real ', 
	tdd.LTE_20Mhz_PCC_PCT as '20Mhz Bandwidth PCC % real ',
	--SCC1
	tdd.LTE_5Mhz_SCC1_PCT as '5Mhz Bandwidth SCC1 % real ', 
	tdd.LTE_10Mhz_SCC1_PCT as '10Mhz Bandwidth SCC1 % real ', 
	tdd.LTE_15Mhz_SCC1_PCT as '15Mhz Bandwidth SCC1 % real ', 
	tdd.LTE_20Mhz_SCC1_PCT as '20Mhz Bandwidth SCC1 % real ',
	--SCC2
	tdd.LTE_5Mhz_SCC2_PCT as '5Mhz Bandwidth SCC2 % real ',
	tdd.LTE_10Mhz_SCC2_PCT as '10Mhz Bandwidth SCC2 % real ', 
	tdd.LTE_15Mhz_SCC2_PCT as '15Mhz Bandwidth SCC2 % real ', 
	tdd.LTE_20Mhz_SCC2_PCT as '20Mhz Bandwidth SCC2 % real ',

	tdd.DLBandWidth_est as 'BW_PCC_est',
	null as 'Info_Update'
	
--into Lcc_Data_HTTPBrowser	 
from 
	FileList f,	Sessions s, TestInfo t
		LEFT OUTER JOIN _BW_acotado_acc	pctBw	on pctBw.TestId=t.TestId and pctBw.SessionId=t.SessionId
		LEFT OUTER JOIN _PCT_TECH_Data_acotado_acc	pctTech	on pctTech.TestId=t.TestId and pctTech.SessionId=t.SessionId 
		LEFT OUTER JOIN _lcc_http_browser br_kpiid		on br_kpiid.TestId=t.TestId and br_kpiid.SessionId=t.SessionId 
		LEFT OUTER JOIN _THPUT thput					on thput.SessionId=t.SessionId and thput.TestId=t.TestId and thput.direction='Downlink'		
		LEFT OUTER JOIN _TECH_RADIO_INI_Data tri		on t.SessionId=tri.SessionId and t.TestId=tri.testid
		LEFT OUTER JOIN _TECH_RADIO_FIN_Data trf		on t.SessionId=trf.SessionId and t.TestId=trf.testid
		LEFT OUTER JOIN _TECH_RADIO_AVG_Data tra		on t.SessionId=tra.SessionId and t.TestId=tra.testid
		LEFT OUTER JOIN _CQI_3G_acotado_acc cqi3G	on cqi3G.TestId=t.TestId and cqi3G.SessionId=t.SessionId
		LEFT OUTER JOIN _UL_Int ulint			on ulint.TestId=t.TestId and ulint.SessionId=t.SessionId

		-- KPI EXTRA:
		LEFT OUTER JOIN _PDP pdp		on pdp.TestId=t.TestId and pdp.SessionId=t.SessionId
		LEFT OUTER JOIN _Paging pag		on pag.TestId=t.TestId and pag.SessionId=t.SessionId
		LEFT OUTER JOIN _NEIGH neigh		on neigh.TestId=t.TestId and neigh.SessionId=t.SessionId
		LEFT OUTER JOIN _4GHO ho4G			on ho4G.TestId=t.TestId and ho4G.SessionId=t.SessionId		
		LEFT OUTER JOIN _Window win			on win.TestId=t.TestId and win.SessionId=t.SessionId	

		--OSP:
		LEFT OUTER JOIN _Tech_Duration_Distribution_acotado_acc tdd				on (tdd.sessionid=t.sessionid and tdd.testid=t.testid)
		LEFT OUTER JOIN _Tech_Duration_Distribution_acotado_acc_Serv tddServ	on (tddServ.sessionid=t.sessionid and tddServ.testid=t.testid)
		LEFT OUTER JOIN _TCP_3WAY_HANDSHAKE tcphs			on (tcphs.sessionid=t.sessionid and tcphs.testid=t.testid)

		LEFT OUTER JOIN _MOD_3G_acotado_acc mod3G		on mod3G.TestId=t.TestId and mod3G.SessionId=t.SessionId
		LEFT OUTER JOIN _scch_use_3G hs3G	on hs3G.TestId=t.TestId and hs3G.SessionId=t.SessionId
		LEFT OUTER JOIN _HARQ hq			on hq.TestId=t.TestId and hq.SessionId=t.SessionId	
		LEFT OUTER JOIN _THPUT_RLC		thput_rlc		on (t.SessionId=thput_rlc.SessionId and t.TestId=thput_rlc.testid)

		LEFT OUTER JOIN _MOD_4G mod4G			on (t.SessionId=mod4G.SessionId and t.TestId=mod4G.testid and mod4G.direction='Downlink') 
		LEFT OUTER JOIN _RBs_DL rbs				on (t.SessionId=rbs.SessionId and t.TestId=rbs.testid and rbs.direction='Downlink') 
		LEFT OUTER JOIN _RBs_carrier_DL rbs_c	on (t.SessionId=rbs_c.SessionId and t.TestId=rbs_c.testid and rbs_c.direction='Downlink') 	
		LEFT OUTER JOIN _cqi_4G_acotado_acc cqi4G	on (t.SessionId=cqi4G.SessionId and t.TestId=cqi4G.testid)
		LEFT OUTER JOIN _Carrier ca				on (t.SessionId=ca.SessionId and t.TestId=ca.testid)
where 
	t.SessionId=s.SessionId and s.FileId=f.FileId
	and s.sessionType='data' 
	and t.typeoftest='HTTPBrowser' 
	and s.valid=1 and t.valid=1
	and ErrorType='Accessibility'
	
	and t.testid > @maxTestid_BR
	and RIGHT(LEFT(f.IMSI,5),2) in (1,7,3,4)	

	
order by f.FileId, t.SessionId, t.TestId

select 'Fin creacion tabla Lcc_Data_HTTPBrowser' info


-- (4)
-- *************************************
----		TABLA FINAL Youtube		----			select * from Lcc_Data_HTTPTransfer_DL -- _lcc_http_DL
-- *************************************
select 'Inicio creacion tabla from Lcc_Data_YOUTUBE' info

insert into Lcc_Data_YOUTUBE
select 
	-- Info general 
	f.CallingModule as MTU,	f.IMEI,		f.CollectionName,	LEFT(f.IMSI,3) as MCC,	RIGHT(LEFT(f.IMSI,5),2) as MNC,	t.startDate,
	t.startTime,	DATEADD(ms, t.duration ,t.startTime) as endTime,	t.SessionId, f.FileId, t.TestId, t.typeoftest, t.direction, s.info,
	
	t.testname, ytb.[Image Resolution] as 'Video Resolution',

	--	B1 :	YouTube Service Access Success Ratio [%]  
	case when ytb.status_B1 = 'Successful' then null else 'Failed' end as 'Fails',
	case when ytb.status_B1 = 'Successful' then null else ytb.status_B1 end as 'Cause',
	case when ytb.status_B1 = 'Successful' then null else
		case when ytb.status_B1 = 'Player Access Timeout exceeded' then dateadd(ms,ytb.Duration10620*1000, ytb.StartIPserviceAccess)
			when ytb.status_B1 = 'Player Download Timeout exceeded' then dateadd(ms, (ytb.Duration10620+ytb.Duration20620)*1000, ytb.StartIPserviceAccess)
			when ytb.status_B1 = 'Video Access Timeout exceeded' then dateadd(ms, ytb.Duration10625*1000, ytb.StartIPserviceAccess)
			when ytb.status_B1 = 'Video Reproduction Timeout exceeded' then dateadd(ms, (ytb.Duration10625+ytb.Duration30621)*1000, ytb.StartIPserviceAccess)
			else ytb.[Block Time] --Si no es error por timeout, el tiempo de bloqueo será el de antes
		end 
	end as 'Block Time',	
	
	-- Tiempo hasta el Start of video playback - first frame displayed in player - Video Access Time (KPI 10621+el KPI 30621)
	case when ytb.status_B1 = 'Successful' then ytb.[Time To First Image [s]]] end as '[Time To First Image [s]]]',
	
	ytb.[Video Freeze Occurrences > 300ms] as 'Num. Interruptions',
	ytb.[Video Freezing Impairment > 300ms],
		 
	ytb.[Accumulated Video Freezing Duration [s]] > 300ms] as 'Accumulated Video Freezing Duration [s]',
	ytb.[Video Average Freezing Duration [s]] > 300ms] as 'Average Video Freezing Duration [s]',
	ytb.[Video Maximum Freezing Duration [s]] > 300ms] as 'Maximum Video Freezing Duration [s]',
	
	-- B2:	 B1.1 success + freezing events and Playout (status20621):
	--case when ytb.status_B2 <> 'Successful' then 'W Interruptions'
	--else  'W/O Interruptions' end as 'End Status',  

	-- @ERC: 20170221 - Se modifica el calculo del End_Status  -> es un parche a la espera de resolucion de SQ
	--					El status_B2, depende del errorCode que no se asigna correctamente por SQ
	--					Se añade la condicion para el End_Status de que no haya Fails tampoco (B1=OK) de momento
/*
		case when B1.errorcode=0 then 'Successful'
		 else B1.Value4
		end  as 'status_B1',

		case when B2.errorcode=0 then 'Successful'
			 else B2.Value4
			end  as 'status_B2',
*/

	case 
		when ytb.status_B2 = 'Successful' AND ytb.status_B1 = 'Successful' then 'W/O Interruptions'
	else  'W Interruptions' end as 'End Status',  

	-- B3:	distinto a los requisitos de P3:
	case when  ytb.status_B3 <> 'Successful' then 'Failed'
		 else 'Successful' end as 'Successful_Video_Download',

	-- Technology:		info tech DL
	-- PCC:
	ISNULL(pctTech.pctLTE, 0) as '% LTE',				ISNULL(pctTech.pctWCDMA, 0) as '% WCDMA',			ISNULL(pctTech.pctGSM, 0) as '% GSM',
	ISNULL(pctTech.pct_F1_U2100, 0) as '% F1 U2100',	ISNULL(pctTech.pct_F2_U2100, 0) as '% F2 U2100',	ISNULL(pctTech.pct_F3_U2100, 0) as '% F3 U2100',
	ISNULL(pctTech.pct_F1_U900, 0) as '% F1 U900',		ISNULL(pctTech.pct_F2_U900, 0) as '% F2 U900',			
	ISNULL(pctTech.pctUMTS_2100, 0) as '% U2100',	ISNULL(pctTech.pctUMTS_900, 0) as '% U900',				ISNULL(pctTech.pctLTE_2600, 0) as '% LTE2600',
	ISNULL(pctTech.pctLTE_2100, 0) as '% LTE2100',	ISNULL(pctTech.pctLTE_1800, 0) as '% LTE1800',			ISNULL(pctTech.pctLTE_800, 0) as '% LTE800',			
	ISNULL(pctTech.[pctGMS_DCS], 0) as 'DCS %',		ISNULL(pctTech.[pctGSM_EGSM], 0) as 'GSM %',			ISNULL(pctTech.[pctGSM_GSM], 0) as 'EGSM %',
	
	ISNULL(pctTech.Roaming_VF, 0) as 'Roaming_VF',ISNULL(pctTech.Roaming_MV, 0) as 'Roaming_MV',ISNULL(pctTech.Roaming_OR, 0) as 'Roaming_OR',ISNULL(pctTech.Roaming_YO, 0) as 'Roaming_YO',
	ISNULL(pctTech.Roaming_U900, 0) as 'Roaming_U900',ISNULL(pctTech.Roaming_U2100, 0) as 'Roaming_U2100',
	ISNULL(pctTech.Roaming_LTE800, 0) as 'Roaming_LTE800',ISNULL(pctTech.Roaming_LTE1800, 0) as 'Roaming_LTE1800',ISNULL(pctTech.Roaming_LTE2100, 0) as 'Roaming_LTE2100',ISNULL(pctTech.Roaming_LTE2600, 0) as 'Roaming_LTE2600',

	ISNULL(pctTech.Duration_Roaming_VF, 0) as 'Duration_roaming_VF',ISNULL(pctTech.Duration_Roaming_MV, 0) as 'Duration_roaming_MV',ISNULL(pctTech.Duration_Roaming_OR, 0) as 'Duration_roaming_OR',ISNULL(pctTech.Duration_Roaming_YO, 0) as 'Duration_roaming_YO',
	ISNULL(pctTech.Duration_Roaming_U900, 0) as 'Duration_roaming_U900',ISNULL(pctTech.Duration_Roaming_U2100, 0) as 'Duration_roaming_U2100',
	ISNULL(pctTech.Duration_Roaming_LTE800, 0) as 'Duration_roaming_LTE800',ISNULL(pctTech.Duration_Roaming_LTE1800, 0) as 'Duration_roaming_LTE1800',ISNULL(pctTech.Duration_Roaming_LTE2100, 0) as 'Duration_roaming_LTE2100',ISNULL(pctTech.Duration_Roaming_LTE2600, 0) as 'Duration_roaming_LTE2600',

	-- SCC1:
	ISNULL(pctTech.pctLTE_2600_SCC1, 0) as '% LTE2600_SCC1',	ISNULL(pctTech.pctLTE_2100_SCC1, 0) as '% LTE2100_SCC1', ISNULL(pctTech.pctLTE_1800_SCC1, 0) as '% LTE1800_SCC1',	ISNULL(pctTech.pctLTE_800_SCC1, 0) as '% LTE800_SCC1',	
	-- SCC2:
	ISNULL(pctTech.pctLTE_2600_SCC2, 0) as '% LTE2600_SCC2',	ISNULL(pctTech.pctLTE_2100_SCC2, 0) as '% LTE2100_SCC2',	ISNULL(pctTech.pctLTE_1800_SCC2, 0) as '% LTE1800_SCC2',	ISNULL(pctTech.pctLTE_800_SCC2, 0) as '% LTE800_SCC2',	

	-- INFO RADIO:
	tra.RxLev,	tra.RxQual,
	tri.BCCH as BCCH_Ini,	tri.BSIC as BSIC_Ini,	tri.RxLev as RxLev_Ini,	tri.RxQual as RxQual_Ini,
	trf.BCCH as BCCH_Fin,	trf.BSIC as BSIC_Fin,	trf.RxLev as RxLev_Fin,	trf.RxQual as RxQual_Fin,
	tra.RxLev_min,	tra.RxQual_min,
	tra.RSCP as 'RSCP_avg',	tra.EcIo as 'EcI0_avg',
	tri.PSC as PSC_Ini,	tri.RSCP as RSCP_Ini,	tri.EcIo as EcIo_Ini,	tri.UARFCN as UARFCN_Ini,
	trf.PSC as PSC_Fin,	trf.RSCP as RSCP_Fin,	trf.EcIo as EcIo_Fin,	trf.UARFCN as UARFCN_Fin,
	tra.RSCP_min,	tra.EcIo_min,
	tra.RSRP as 'RSRP_avg',	tra.RSRQ as 'RSRQ_avg',	tra.SINR as 'SINR_avg',
	tri.PCI as PCI_Ini,	tri.RSRP as RSRP_Ini,	tri.RSRQ as RSRQ_Ini,	tri.SINR as SINR_Ini,		tri.EARFCN as EARFCN_Ini,
	trf.PCI as PCI_Fin,	trf.RSRP as RSRP_Fin,	trf.RSRQ as RSRQ_Fin,	trf.SINR as SINR_Fin,		trf.EARFCN as EARFCN_Fin,
	tri.CId as CellId_Ini,	tri.LAC as 'LAC/TAC_Ini',	tri.RNCID as RNC_Ini,
	trf.CId as CellId_Fin,	trf.LAC as 'LAC/TAC_Fin',	trf.RNCID as RNC_Fin,

	-- INFO PARCELA:
	tri.longitude as 'Longitud Inicial',	tri.latitude as 'Latitud Inicial',	
	trf.longitude as 'Longitud Final',		trf.latitude as 'Latitud Final'	,

	-- @ERC: Se añade info de tecnologia inicio/fin para añadir en el reporte
	tri.Tech_Ini,	trf.Tech_Fin,

	pdp.PDP_Activate_Ratio,
	pag.Paging_Success_Ratio,
	neigh.EARFCN_N1,
	neigh.PCI_N1,
	neigh.RSRP_N1,
	neigh.RSRQ_N1,
	ho4G.num_HO_S1X2,
	ho4G.duration_S1X2_avg,
	ho4G.S1X2HO_SR,
	win.Max_Win as Max_Window_Size,
	buf.Buffering_Time as Buffering_Time_Sec,
	ytb.VMOS as Video_MOS,
	tcphs.TCP_HandShake_Average,
	f.IMSI, 

	-- 20170321 - @ERC: Nuevos KPis y parametros:
	f.ASideDevice, f.BSideDevice, f.SWVersion,
	r.url,
	master.dbo.fn_lcc_getElement(1, master.dbo.fn_lcc_getElement(2, player,'v'),' ') as 'YTBVersion' ,

	-- 20170401 - @ERC: Nuevos KPis - resoluciones y VMOS por resoluciones
	res.[1st Resolution],		res.[2nd Resolution],
	res.[FirstChangeFromInit],
	res.[initialResolution],	res.[finalResolution],
	res.[Duration],				res.[TestQualityAvg_B6],	res.[TestQualityAvg_Calc],
	res.[144p-VideoDuration],	res.[144p-VideoMOS],		ISNULL(res.[% 144p],0),
	res.[240p-VideoDuration],	res.[240p-VideoMOS],		ISNULL(res.[% 240p],0),
	res.[360p-VideoDuration],	res.[360p-VideoMOS],		ISNULL(res.[% 360p],0),
	res.[480p-VideoDuration],	res.[480p-VideoMOS],		ISNULL(res.[% 480p],0),
	res.[720p-VideoDuration],	res.[720p-VideoMOS],		ISNULL(res.[% 720p],0),
	res.[1080p-VideoDuration],	res.[1080p-VideoMOS],		ISNULL(res.[% 1080p],0),
	null as 'Info_Update'
	
--into Lcc_Data_YOUTUBE		
from 
	FileList f,	Sessions s, TestInfo t
		LEFT OUTER JOIN _PCT_TECH_Data pctTech			on pctTech.TestId=t.TestId and pctTech.SessionId=t.SessionId 
		LEFT OUTER JOIN _TECH_RADIO_INI_Data tri		on (t.SessionId=tri.SessionId and t.TestId=tri.testid)
		LEFT OUTER JOIN _TECH_RADIO_FIN_Data trf		on (t.SessionId=trf.SessionId and t.TestId=trf.testid)
		LEFT OUTER JOIN _TECH_RADIO_AVG_Data tra		on (t.SessionId=tra.SessionId and t.TestId=tra.testid)	
		LEFT OUTER JOIN _ETSIYouTubeKPIs ytb			on (t.SessionId=ytb.SessionId and t.TestId=ytb.testid)

	-- KPI EXTRA:
		LEFT OUTER JOIN _PDP pdp		on pdp.TestId=t.TestId and pdp.SessionId=t.SessionId
		LEFT OUTER JOIN _Paging pag		on pag.TestId=t.TestId and pag.SessionId=t.SessionId
		LEFT OUTER JOIN _NEIGH neigh		on neigh.TestId=t.TestId and neigh.SessionId=t.SessionId
		LEFT OUTER JOIN _4GHO ho4G			on ho4G.TestId=t.TestId and ho4G.SessionId=t.SessionId		
		LEFT OUTER JOIN _Window win			on win.TestId=t.TestId and win.SessionId=t.SessionId	
		LEFT OUTER JOIN _Buffer buf			on buf.TestId=t.TestId and buf.SessionId=t.SessionId	
		LEFT OUTER JOIN ResultsVideoStream r	on r.TestId=t.TestId and r.SessionId=t.SessionId	
	--OSP:
		LEFT OUTER JOIN _TCP_3WAY_HANDSHAKE tcphs		on (tcphs.sessionid=t.sessionid and tcphs.testid=t.testid)

	---- 20170321 - @ERC: Nuevos KPis y parametros:
		LEFT OUTER JOIN _vResolutionInfo res			on (res.sessionid=t.sessionid and res.testid=t.testid)
					
where 
	t.SessionId=s.SessionId and s.FileId=f.FileId
	and s.sessionType='data' 
	and t.typeoftest like '%YouTube%' 
	and t.valid=1 and s.valid=1 
	
	and t.testid > @maxTestid_YTB
	and RIGHT(LEFT(f.IMSI,5),2) in (1,7,3,4)	
	
	
order by f.FileId, t.SessionId, t.TestId

select 'Fin creacion tabla Lcc_Data_YOUTUBE' info


---- (5)
---- *************************************
------		TABLA FINAL Latencias	  ----			select * from Lcc_Data_Latencias -- _lcc_http_DL
---- *************************************
select 'Inicio creacion tabla Lcc_Data_Latencias' info

insert into Lcc_Data_Latencias
select
	-- Info general 
	f.CallingModule as MTU,	f.IMEI,		f.CollectionName,	LEFT(f.IMSI,3) as MCC,	RIGHT(LEFT(f.IMSI,5),2) as MNC,	t.startDate,
	t.startTime,	DATEADD(ms, t.duration ,t.startTime) as endTime,	t.SessionId, f.FileId, t.TestId, t.typeoftest, t.direction, s.info,
	
	-- _lcc_http_latencias:
	_lat_kpiid.Duration ,
	
--------------
-- Technology:		- tech info DL
	-- PCC:
	ISNULL(pctTech.pctLTE, 0) as '% LTE',				ISNULL(pctTech.pctWCDMA, 0) as '% WCDMA',			ISNULL(pctTech.pctGSM, 0) as '% GSM',
	ISNULL(pctTech.pct_F1_U2100, 0) as '% F1 U2100',	ISNULL(pctTech.pct_F2_U2100, 0) as '% F2 U2100',	ISNULL(pctTech.pct_F3_U2100, 0) as '% F3 U2100',
	ISNULL(pctTech.pct_F1_U900, 0) as '% F1 U900',		ISNULL(pctTech.pct_F2_U900, 0) as '% F2 U900',		
	ISNULL(pctTech.pctUMTS_2100, 0) as '% U2100',	ISNULL(pctTech.pctUMTS_900, 0) as '% U900',				ISNULL(pctTech.pctLTE_2600, 0) as '% LTE2600',
	ISNULL(pctTech.pctLTE_2100, 0) as '% LTE2100',	ISNULL(pctTech.pctLTE_1800, 0) as '% LTE1800',			ISNULL(pctTech.pctLTE_800, 0) as '% LTE800',			
	ISNULL(pctTech.[pctGMS_DCS], 0) as 'DCS %',		ISNULL(pctTech.[pctGSM_EGSM], 0) as 'GSM %',			ISNULL(pctTech.[pctGSM_GSM], 0) as 'EGSM %',
	
	ISNULL(pctTech.Roaming_VF, 0) as 'Roaming_VF',ISNULL(pctTech.Roaming_MV, 0) as 'Roaming_MV',ISNULL(pctTech.Roaming_OR, 0) as 'Roaming_OR',ISNULL(pctTech.Roaming_YO, 0) as 'Roaming_YO',
	ISNULL(pctTech.Roaming_U900, 0) as 'Roaming_U900',ISNULL(pctTech.Roaming_U2100, 0) as 'Roaming_U2100',
	ISNULL(pctTech.Roaming_LTE800, 0) as 'Roaming_LTE800',ISNULL(pctTech.Roaming_LTE1800, 0) as 'Roaming_LTE1800',ISNULL(pctTech.Roaming_LTE2100, 0) as 'Roaming_LTE2100',ISNULL(pctTech.Roaming_LTE2600, 0) as 'Roaming_LTE2600',

	ISNULL(pctTech.Duration_Roaming_VF, 0) as 'Duration_roaming_VF',ISNULL(pctTech.Duration_Roaming_MV, 0) as 'Duration_roaming_MV',ISNULL(pctTech.Duration_Roaming_OR, 0) as 'Duration_roaming_OR',ISNULL(pctTech.Duration_Roaming_YO, 0) as 'Duration_roaming_YO',
	ISNULL(pctTech.Duration_Roaming_U900, 0) as 'Duration_roaming_U900',ISNULL(pctTech.Duration_Roaming_U2100, 0) as 'Duration_roaming_U2100',
	ISNULL(pctTech.Duration_Roaming_LTE800, 0) as 'Duration_roaming_LTE800',ISNULL(pctTech.Duration_Roaming_LTE1800, 0) as 'Duration_roaming_LTE1800',ISNULL(pctTech.Duration_Roaming_LTE2100, 0) as 'Duration_roaming_LTE2100',ISNULL(pctTech.Duration_Roaming_LTE2600, 0) as 'Duration_roaming_LTE2600',

	-- SCC1:	- De momento solo se calcula para la SCC1
	ISNULL(pctTech.pctLTE_2600_SCC1, 0) as '% LTE2600_SCC1',	ISNULL(pctTech.pctLTE_2100_SCC1, 0) as '% LTE2100_SCC1',    ISNULL(pctTech.pctLTE_1800_SCC1, 0) as '% LTE1800_SCC1',	ISNULL(pctTech.pctLTE_800_SCC1, 0) as '% LTE800_SCC1',	
	-- SCC2:
	ISNULL(pctTech.pctLTE_2600_SCC2, 0) as '% LTE2600_SCC2',	ISNULL(pctTech.pctLTE_2100_SCC2, 0) as '% LTE2100_SCC2',	ISNULL(pctTech.pctLTE_1800_SCC2, 0) as '% LTE1800_SCC2',	ISNULL(pctTech.pctLTE_800_SCC2, 0) as '% LTE800_SCC2',	

	-- INFO RADIO: 
	tri.longitude as 'Longitud Inicial',	tri.latitude as 'Latitud Inicial',	
	trf.longitude as 'Longitud Final',		trf.latitude as 'Latitud Final'	,

	pdp.PDP_Activate_Ratio,
	pag.Paging_Success_Ratio,
	neigh.EARFCN_N1,
	neigh.PCI_N1,
	neigh.RSRP_N1,
	neigh.RSRQ_N1,
	ho4G.num_HO_S1X2,
	ho4G.duration_S1X2_avg,
	ho4G.S1X2HO_SR,
	tcphs.TCP_HandShake_Average,
	f.IMSI, 

	-- 20170321 - @ERC: Nuevos KPis y parametros:
	f.ASideDevice, f.BSideDevice, f.SWVersion,
	null as 'Info_Update'
	
--into Lcc_Data_Latencias
from 
	FileList f,	Sessions s, 
	TestInfo t
		LEFT OUTER JOIN _TECH_RADIO_INI_Data tri		on (t.SessionId=tri.SessionId and t.TestId=tri.testid)
		LEFT OUTER JOIN _TECH_RADIO_FIN_Data trf		on (t.SessionId=trf.SessionId and t.TestId=trf.testid)
		LEFT OUTER JOIN _TECH_RADIO_AVG_Data tra		on (t.SessionId=tra.SessionId and t.TestId=tra.testid)
		LEFT OUTER JOIN _PCT_TECH_Data pctTech			on (pctTech.TestId=t.TestId and pctTech.SessionId=t.SessionId)
		LEFT OUTER JOIN _lcc_http_latencias _lat_kpiid	on (_lat_kpiid.SessionId=t.SessionId and _lat_kpiid.TestId=t.TestId)

	-- KPI EXTRA:
		LEFT OUTER JOIN _PDP pdp		on pdp.TestId=t.TestId and pdp.SessionId=t.SessionId
		LEFT OUTER JOIN _Paging pag		on pag.TestId=t.TestId and pag.SessionId=t.SessionId
		LEFT OUTER JOIN _NEIGH neigh		on neigh.TestId=t.TestId and neigh.SessionId=t.SessionId
		LEFT OUTER JOIN _4GHO ho4G			on ho4G.TestId=t.TestId and ho4G.SessionId=t.SessionId		

	--OSP:
		LEFT OUTER JOIN _TCP_3WAY_HANDSHAKE tcphs			on (tcphs.sessionid=t.sessionid and tcphs.testid=t.testid)

where 
	t.SessionId=s.SessionId and s.FileId=f.FileId
	and s.sessionType='data' 
	and t.typeoftest='Ping'
	and t.valid=1 and s.valid=1 
	
	and _lat_kpiid.size=@sizePing

	and t.testid > @maxTestid_LAT
	and RIGHT(LEFT(f.IMSI,5),2) in (1,7,3,4)
order by f.FileId, t.SessionId, t.TestId	

select 'Fin creacion tabla Lcc_Data_Latencias' info




---- (6)
---- *************************************
---- ACTUALIZACION MUESTRAS GPS	  ----
---- *************************************

-- ********************************************************************************************************
--DGP 27/11/2015: Se actualizan los campos sin GPS, con la posición válida más cercana en el tiempo.
--DGP 07/03/2016: Se hacía hacia adelante en el tiempo, se añade ahora hacia atrás por si se da al final
--CAC 06/02/2017: Se almacenan las nuevas posiciones en la tabla Lcc_Entity_gps para tenerlas en cuenta
-- en las tablas de contorno. Además se corrige la ordenación para coger la más cercana en el tiempo
-- antes: order by (startTime/endTime asc/desc), ahora: order by (timelink asc/desc)
-- ********************************************************************************************************

if (select name from sys.all_objects where name='Lcc_Entity_gps' and type='U') is null
begin
	CREATE TABLE [dbo].[Lcc_Entity_gps](
		[fileid] [bigint] NULL,
		[Longitude] [float] NULL,
		[Latitude] [float] NULL
	)
end
-------------------------------------------------------------------------
--Parte Inicial hacia Adelante en el tiempo
-------------------------------------------------------------------------
--insertamos en la tabla de gps las posiciones que vamos a simular para que se tengan en cuenta en la tabla de contornos
insert into Lcc_Entity_gps
select Fileid,(select top 1 longitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc) as longitude,
	(select top 1 latitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc) as latitude
from Lcc_Data_HTTPTransfer_DL lc
where
	(lc.[longitud Inicial] is null or lc.[longitud Inicial]=0)
	and lc.testid > @maxTestid_DL

insert into Lcc_Entity_gps
select Fileid,(select top 1 longitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc) as longitude,
	(select top 1 latitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc) as latitude
from Lcc_Data_HTTPTransfer_UL lc
where
	(lc.[longitud Inicial] is null or lc.[longitud Inicial]=0)
	and lc.testid > @maxTestid_UL

insert into Lcc_Entity_gps
select Fileid,(select top 1 longitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc) as longitude,
	(select top 1 latitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc) as latitude
from Lcc_Data_HTTPBrowser lc
where
	(lc.[longitud Inicial] is null or lc.[longitud Inicial]=0)
	and lc.testid > @maxTestid_BR

insert into Lcc_Entity_gps
select Fileid,(select top 1 longitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc) as longitude,
	(select top 1 latitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc) as latitude
from Lcc_Data_Latencias lc
where
	(lc.[longitud Inicial] is null or lc.[longitud Inicial]=0)
	and lc.testid > @maxTestid_LAT

insert into Lcc_Entity_gps
select Fileid,(select top 1 longitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc) as longitude,
	(select top 1 latitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc) as latitude
from Lcc_Data_YOUTUBE lc
where
	(lc.[longitud Inicial] is null or lc.[longitud Inicial]=0)
	and lc.testid > @maxTestid_YTB

--Insertamos las posiciones simuladas

update Lcc_Data_HTTPTransfer_DL
set [longitud Inicial]=(select top 1 longitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc),
	[latitud Inicial]=(select top 1 latitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc),
	Info_Update=isnull(Info_Update,'')+';1'
from Lcc_Data_HTTPTransfer_DL lc
where
(lc.[longitud Inicial] is null or lc.[longitud Inicial]=0)
and lc.testid > @maxTestid_DL

update Lcc_Data_HTTPTransfer_UL
set [longitud Inicial]=(select top 1 longitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc),
	[latitud Inicial]=(select top 1 latitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc),
	Info_Update=isnull(Info_Update,'')+';1'
from Lcc_Data_HTTPTransfer_UL lc
where
	(lc.[longitud Inicial] is null or lc.[longitud Inicial]=0)
	and lc.testid > @maxTestid_UL

update Lcc_Data_HTTPBrowser
set [longitud Inicial]=(select top 1 longitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc),
	[latitud Inicial]=(select top 1 latitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc),
	Info_Update=isnull(Info_Update,'')+';1'
from Lcc_Data_HTTPBrowser lc
where
	(lc.[longitud Inicial] is null or lc.[longitud Inicial]=0)
	and lc.testid > @maxTestid_BR

update Lcc_Data_Latencias
set [longitud Inicial]=(select top 1 longitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc),
	[latitud Inicial]=(select top 1 latitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc),
	Info_Update=isnull(Info_Update,'')+';1'
from Lcc_Data_Latencias lc
where
	(lc.[longitud Inicial] is null or lc.[longitud Inicial]=0)
	and lc.testid > @maxTestid_LAT

update Lcc_Data_YOUTUBE
set [longitud Inicial]=(select top 1 longitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc),
	[latitud Inicial]=(select top 1 latitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc),
	Info_Update=isnull(Info_Update,'')+';1'
from Lcc_Data_YOUTUBE lc
where
	(lc.[longitud Inicial] is null or lc.[longitud Inicial]=0)
	and lc.testid > @maxTestid_YTB
	


-------------------------------------------------------------------------
--Parte Inicial hacia Atras en el tiempo
-------------------------------------------------------------------------
insert into Lcc_Entity_gps
select Fileid,(select top 1 longitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc) as longitude,
	(select top 1 latitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc) as latitude
from Lcc_Data_HTTPTransfer_DL lc
where
	(lc.[longitud Inicial] is null or lc.[longitud Inicial]=0)
	and lc.testid > @maxTestid_DL

insert into Lcc_Entity_gps
select Fileid,(select top 1 longitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc) as longitude,
	(select top 1 latitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc) as latitude
from Lcc_Data_HTTPTransfer_UL lc
where
	(lc.[longitud Inicial] is null or lc.[longitud Inicial]=0)
	and lc.testid > @maxTestid_UL

insert into Lcc_Entity_gps
select Fileid,(select top 1 longitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc) as longitude,
	(select top 1 latitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc) as latitude
from Lcc_Data_HTTPBrowser lc
where
	(lc.[longitud Inicial] is null or lc.[longitud Inicial]=0)
	and lc.testid > @maxTestid_BR

insert into Lcc_Entity_gps
select Fileid,(select top 1 longitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc) as longitude,
	(select top 1 latitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc) as latitude
from Lcc_Data_Latencias lc
where
	(lc.[longitud Inicial] is null or lc.[longitud Inicial]=0)
	and lc.testid > @maxTestid_LAT

insert into Lcc_Entity_gps
select Fileid,(select top 1 longitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc) as longitude,
	(select top 1 latitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc) as latitude
from Lcc_Data_YOUTUBE lc
where
	(lc.[longitud Inicial] is null or lc.[longitud Inicial]=0)
	and lc.testid > @maxTestid_YTB

--Insertamos las posiciones simuladas
update Lcc_Data_HTTPTransfer_DL
set [longitud Inicial]=(select top 1 longitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc),
	[latitud Inicial]=(select top 1 latitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc),
	Info_Update=isnull(Info_Update,'')+';1'
from Lcc_Data_HTTPTransfer_DL lc
where
	(lc.[longitud Inicial] is null or lc.[longitud Inicial]=0)
	and lc.testid > @maxTestid_DL

update Lcc_Data_HTTPTransfer_UL
set [longitud Inicial]=(select top 1 longitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc),
	[latitud Inicial]=(select top 1 latitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc),
	Info_Update=isnull(Info_Update,'')+';1'
from Lcc_Data_HTTPTransfer_UL lc
where
	(lc.[longitud Inicial] is null or lc.[longitud Inicial]=0)
	and lc.testid > @maxTestid_UL

update Lcc_Data_HTTPBrowser
set [longitud Inicial]=(select top 1 longitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc),
	[latitud Inicial]=(select top 1 latitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc),
	Info_Update=isnull(Info_Update,'')+';1'
from Lcc_Data_HTTPBrowser lc
where
	(lc.[longitud Inicial] is null or lc.[longitud Inicial]=0)
	and lc.testid > @maxTestid_BR

update Lcc_Data_Latencias
set [longitud Inicial]=(select top 1 longitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc),
	[latitud Inicial]=(select top 1 latitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc),
	Info_Update=isnull(Info_Update,'')+';1'
from Lcc_Data_Latencias lc
where
	(lc.[longitud Inicial] is null or lc.[longitud Inicial]=0)
	and lc.testid > @maxTestid_LAT

update Lcc_Data_YOUTUBE
set [longitud Inicial]=(select top 1 longitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc),
	[latitud Inicial]=(select top 1 latitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.startTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc),
	Info_Update=isnull(Info_Update,'')+';1'
from Lcc_Data_YOUTUBE lc
where
	(lc.[longitud Inicial] is null or lc.[longitud Inicial]=0)
	and lc.testid > @maxTestid_YTB


-------------------------------------------------------------------------
--Parte Final hacia Adelante en el tiempo
-------------------------------------------------------------------------
--insertamos en la tabla de gps las posiciones que vamos a simular para que se tengan en cuenta en la tabla de contornos
insert into Lcc_Entity_gps
select Fileid,(select top 1 longitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc) as longitude,
	(select top 1 latitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc) as latitude
from Lcc_Data_HTTPTransfer_DL lc
where
	(lc.[longitud Final] is null or lc.[longitud Final]=0)
	and lc.testid > @maxTestid_DL

insert into Lcc_Entity_gps
select Fileid,(select top 1 longitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc) as longitude,
	(select top 1 latitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc) as latitude
from Lcc_Data_HTTPTransfer_UL lc
where
	(lc.[longitud Final] is null or lc.[longitud Final]=0)
	and lc.testid > @maxTestid_UL

insert into Lcc_Entity_gps
select Fileid,(select top 1 longitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc) as longitude,
	(select top 1 latitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc) as latitude
from Lcc_Data_HTTPBrowser lc
where
	(lc.[longitud Final] is null or lc.[longitud Final]=0)
	and lc.testid > @maxTestid_BR

insert into Lcc_Entity_gps
select Fileid,(select top 1 longitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc) as longitude,
	(select top 1 latitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc) as latitude
from Lcc_Data_Latencias lc
where
	(lc.[longitud Final] is null or lc.[longitud Final]=0)
	and lc.testid > @maxTestid_LAT

insert into Lcc_Entity_gps
select Fileid,(select top 1 longitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc) as longitude,
	(select top 1 latitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc) as latitude
from Lcc_Data_YOUTUBE lc
where
	(lc.[longitud Final] is null or lc.[longitud Final]=0)
	and lc.testid > @maxTestid_YTB

--Insertamos las posiciones simuladas
update Lcc_Data_HTTPTransfer_DL
set [longitud Final]=(select top 1 longitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc),
	[latitud Final]=(select top 1 latitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc),
	Info_Update=isnull(Info_Update,'')+';1'
from Lcc_Data_HTTPTransfer_DL lc
where
	(lc.[longitud Final] is null or lc.[longitud Final]=0)
	and lc.testid > @maxTestid_DL

update Lcc_Data_HTTPTransfer_UL
set [longitud Final]=(select top 1 longitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc),
	[latitud Final]=(select top 1 latitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc),
	Info_Update=isnull(Info_Update,'')+';1'
from Lcc_Data_HTTPTransfer_UL lc
where
	(lc.[longitud Final] is null or lc.[longitud Final]=0)
	and lc.testid > @maxTestid_UL

update Lcc_Data_HTTPBrowser
set [longitud Final]=(select top 1 longitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc),
	[latitud Final]=(select top 1 latitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc),
	Info_Update=isnull(Info_Update,'')+';1'
from Lcc_Data_HTTPBrowser lc
where
	(lc.[longitud Final] is null or lc.[longitud Final]=0)
	and lc.testid > @maxTestid_BR

update Lcc_Data_Latencias
set [longitud Final]=(select top 1 longitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc),
	[latitud Final]=(select top 1 latitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc),
	Info_Update=isnull(Info_Update,'')+';1'
from Lcc_Data_Latencias lc
where
	(lc.[longitud Final] is null or lc.[longitud Final]=0)
	and lc.testid > @maxTestid_LAT

update Lcc_Data_YOUTUBE
set [longitud Final]=(select top 1 longitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc),
	[latitud Final]=(select top 1 latitude from lcc_timelink_position 
						where timelink>=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink asc),
	Info_Update=isnull(Info_Update,'')+';1'
from Lcc_Data_YOUTUBE lc
where
	(lc.[longitud Final] is null or lc.[longitud Final]=0)
	and lc.testid > @maxTestid_YTB

-------------------------------------------------------------------------
--Parte Final hacia Atras en el tiempo
-------------------------------------------------------------------------
insert into Lcc_Entity_gps
select Fileid,(select top 1 longitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc) as longitude,
	(select top 1 latitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc) as latitude
from Lcc_Data_HTTPTransfer_DL lc
where
	(lc.[longitud Final] is null or lc.[longitud Final]=0)
	and lc.testid > @maxTestid_DL

insert into Lcc_Entity_gps
select Fileid,(select top 1 longitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc) as longitude,
	(select top 1 latitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc) as latitude
from Lcc_Data_HTTPTransfer_UL lc
where
	(lc.[longitud Final] is null or lc.[longitud Final]=0)
	and lc.testid > @maxTestid_UL

insert into Lcc_Entity_gps
select Fileid,(select top 1 longitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc) as longitude,
	(select top 1 latitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc) as latitude
from Lcc_Data_HTTPBrowser lc
where
	(lc.[longitud Final] is null or lc.[longitud Final]=0)
	and lc.testid > @maxTestid_BR

insert into Lcc_Entity_gps
select Fileid,(select top 1 longitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc) as longitude,
	(select top 1 latitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc) as latitude
from Lcc_Data_Latencias lc
where
	(lc.[longitud Final] is null or lc.[longitud Final]=0)
	and lc.testid > @maxTestid_LAT

insert into Lcc_Entity_gps
select Fileid,(select top 1 longitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc) as longitude,
	(select top 1 latitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc) as latitude
from Lcc_Data_YOUTUBE lc
where
	(lc.[longitud Final] is null or lc.[longitud Final]=0)
	and lc.testid > @maxTestid_YTB

--Insertamos las posiciones simuladas
update Lcc_Data_HTTPTransfer_DL
set [longitud Final]=(select top 1 longitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc),
	[latitud Final]=(select top 1 latitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc),
	Info_Update=isnull(Info_Update,'')+';1'
from Lcc_Data_HTTPTransfer_DL lc
where
	(lc.[longitud Final] is null or lc.[longitud Final]=0)
	and lc.testid > @maxTestid_DL

update Lcc_Data_HTTPTransfer_UL
set [longitud Final]=(select top 1 longitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc),
	[latitud Final]=(select top 1 latitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc),
	Info_Update=isnull(Info_Update,'')+';1'
from Lcc_Data_HTTPTransfer_UL lc
where
	(lc.[longitud Final] is null or lc.[longitud Final]=0)
	and lc.testid > @maxTestid_UL

update Lcc_Data_HTTPBrowser
set [longitud Final]=(select top 1 longitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc),
	[latitud Final]=(select top 1 latitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc),
	Info_Update=isnull(Info_Update,'')+';1'
from Lcc_Data_HTTPBrowser lc
where
	(lc.[longitud Final] is null or lc.[longitud Final]=0)
	and lc.testid > @maxTestid_BR

update Lcc_Data_Latencias
set [longitud Final]=(select top 1 longitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc),
	[latitud Final]=(select top 1 latitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc),
	Info_Update=isnull(Info_Update,'')+';1'
from Lcc_Data_Latencias lc
where
	(lc.[longitud Final] is null or lc.[longitud Final]=0)
	and lc.testid > @maxTestid_LAT

update Lcc_Data_YOUTUBE
set [longitud Final]=(select top 1 longitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc),
	[latitud Final]=(select top 1 latitude from lcc_timelink_position 
						where timelink<=master.dbo.fn_lcc_gettimelink(lc.endTime)
						and collectionname=lc.collectionname
						and side='A'
						order by timelink desc),
	Info_Update=isnull(Info_Update,'')+';1'
from Lcc_Data_YOUTUBE lc
where
	(lc.[longitud Final] is null or lc.[longitud Final]=0)
	and lc.testid > @maxTestid_YTB


--Para quitar simulaciones no encontradas
delete Lcc_Entity_gps
where latitude is null and longitude is null


---- (7)
---- *************************************
----		INVALIDACIONES VARIAS	  
---- *************************************
-------------------------------------------------------------------------------------------------------------------------------------
-- DGP 09/09/2015:
-- Invalidación de errores de Herramienta 
-------------------------------------------------------------------------------------------------------------------------------------
update testinfo
set valid=0, invalidReason='LCC UEServer Issues'
where testid in (	
	select testid from Lcc_Data_HTTPTransfer_DL
	where errorcause in ('Error: Measurement abort','Error: Reference file not found',
		'Error: Exception', 'Error: Browser Navigation Error: INET_E_RESOURCE_NOT_FOUND',
		'Error: HTTP: Service unavailable')
	and testid > @maxTestid_DL
	union all
	select testid from Lcc_Data_HTTPTransfer_UL
	where errorcause in ('Error: Measurement abort','Error: Reference file not found',
		'Error: Exception', 'Error: Browser Navigation Error: INET_E_RESOURCE_NOT_FOUND',
		'Error: HTTP: Service unavailable')
	and testid > @maxTestid_UL
	union all
	select testid from Lcc_Data_HTTPBrowser
	where errorcause in ('Error: Measurement abort','Error: Reference file not found',
		'Error: Exception', 'Error: Browser Navigation Error: INET_E_RESOURCE_NOT_FOUND',
		'Error: HTTP: Service unavailable')		
	and testid > @maxTestid_BR	
)

-------------------------------------------------------------------------------------------------------------------------------------
-- DGP 08/10/2015:
-- Invalidación de tests no marcados como completados 
-------------------------------------------------------------------------------------------------------------------------------------
update testinfo
set valid=0, invalidReason='LCC Not Completed Test'
where testid in (	
	select testid from Lcc_Data_HTTPTransfer_DL
	where info <> 'Completed'
	and testid > @maxTestid_DL
	union all
	select testid from Lcc_Data_HTTPTransfer_UL
	where info <> 'Completed'
	and testid > @maxTestid_UL
	union all
	select testid from Lcc_Data_HTTPBrowser
	where info <> 'Completed'	
	and testid > @maxTestid_BR					
	union all
	select testid from Lcc_Data_Latencias
	where info <> 'Completed'
	and testid > @maxTestid_LAT					
	union all
	select testid from Lcc_Data_YOUTUBE
	where info <> 'Completed'	
	and testid > @maxTestid_YTB	
)

-------------------------------------------------------------------------------------------------------------------------------------
-- DGP 14/10/2015:
-- Invalidación de tests Youtube con Freeze tras descargar el video completo 
-------------------------------------------------------------------------------------------------------------------------------------
update testinfo
set valid=0, Invalidreason=Invalidreason+' || LCC - Freezing after DL Time'
where testid in
		(select y.testid
			from [ResultsVq06TimeDom] y
			left outer join ResultsKpi r on r.sessionid=y.sessionid and r.testid=y.testid and r.kpiid=20625
			where y.sessionid=r.sessionid
			and y.testid=r.testid
			and y.degtime > r.duration
			and y.deltatime > (select settings from SQGeneralSettings where settingID=13)
			and y.testid > @maxTestid_YTB	
			group by y.testid)

-------------------------------------------------------------------------------------------------------------------------------------
-- DGP 04/11/2015:
-- Anulamos todos los valores temporales en el caso de errores 
-------------------------------------------------------------------------------------------------------------------------------------
update Lcc_Data_HTTPTransfer_DL
set DataTransferred=null,  TransferTime=null, Throughput=null, [IP Access Time (ms)]=null,
	DataTransferred_PCC=null,  TransferTime_PCC=null, Throughput_PCC=null,
	DataTransferred_SCC1=null,  TransferTime_SCC1=null, Throughput_SCC1=null,
	DataTransferred_SCC2=null,  TransferTime_SCC2=null, Throughput_SCC2=null,
	Info_Update=isnull(Info_Update,'')+';2'
where  errortype is not null
and info='completed'
and testid > @maxTestid_DL

update Lcc_Data_HTTPTransfer_UL
set DataTransferred=null,  TransferTime=null, Throughput=null, [IP Access Time (ms)]=null,
	Info_Update=isnull(Info_Update,'')+';2'
where  errortype is not null
and info='completed'
and testid > @maxTestid_UL

update Lcc_Data_HTTPBrowser
set [IP Service Setup Time (s)]=null,	[Transfer Time (s)]=null,	[Session Time (s)]=null,	[DNS Resolution (s)]=null,
	[Throughput]=null, [DataTransferred]=null,		-- añadido: 02022017
	DataTransferred_PCC=null,  TransferTime_PCC=null, Throughput_PCC=null,
	DataTransferred_SCC1=null,  TransferTime_SCC1=null, Throughput_SCC1=null,
	DataTransferred_SCC2=null,  TransferTime_SCC2=null, Throughput_SCC2=null,
	Info_Update=isnull(Info_Update,'')+';2'
where errortype is not null
and info='completed'
and testid > @maxTestid_BR

-------------------------------------------------------------------------------------------------------------------------------------
-- DGP 10/11/2015:
-- Convertimos a completadas los tests marcados como fallo erróneamente 
-------------------------------------------------------------------------------------------------------------------------------------
exec sp_lcc_dropifexists '_VALIDABLE_WEB'		
select
	b.testid,
	case
		when b.errorcause is null then 0
		   when b.errorcause like '%timeout%' and isnull(r.num_ok,0)>=75 and b.testtype like 'Kepl%' and b.session_time_sec_nu<10 and isnull(r.num_rst,0)=0 then 1
		   when b.errorcause like '%timeout%' and isnull(r.num_ok,0)>=22 and b.testtype like 'Mobile%' and b.session_time_sec_nu<10 and isnull(r.num_rst,0)=0 then 1
		   else 0
	end as validable_test
into _VALIDABLE_WEB
from Lcc_Data_HTTPBrowser b
	left outer join (
						select testid,
							   sum(case when msg like '80%RST%' then 1 else 0 end) as num_rst,
							   sum(case when msg='HTTP/1.1 200 OK' then 1 else 0 end) as num_ok
						from msgethereal 
						where testid > @maxTestid_BR
						group by testid
	) r on r.testid=b.testid
where b.errorcause like '%timeout%'
and b.testid > @maxTestid_BR

-- Nos vale volver a coger los valores de _nu porque para BROW se usan los KPIID en ambos metodos
update Lcc_Data_HTTPBrowser
set [DataTransferred]=b.[DataTransferred_nu],
	[ErrorCause]=null,
	[ErrorType]=null,
	[Throughput]=b.[ThputApp_nu],
	[IP Service Setup Time (s)]=b.[IP_AccessTime_sec_nu],
	[Transfer Time (s)]=b.[Transfer_Time_sec_nu],
	[Session Time (s)]=b.[Session_Time_sec_nu],
	[DNS Resolution (s)]=b.[DNSTime_nu],
	Info_Update=isnull(Info_Update,'')+';3'
from Lcc_Data_HTTPBrowser b,
	_VALIDABLE_WEB r
where b.info='completed'
	and r.testid=b.testid and r.validable_test=1
	and b.testid > @maxTestid_BR


-------------------------------------------------------------------------------------------------------------------------------------
-- DGP 12/11/2015:
-- Invalidamos los tests marcados como fallo por timeout erróneamente 
-------------------------------------------------------------------------------------------------------------------------------------
update testinfo
set valid=0, invalidReason='LCC UL Wrong Timeout'
where testid in (
select testid from Lcc_Data_HTTPTransfer_UL
where errorcause like '%timeout%'
	and datatransferred_nu=1024000		-- El _nu corresponde al método antiguo
	and sessiontime_nu <21
	and testtype='UL_CE'
	and testid > @maxTestid_UL)

-------------------------------------------------------------------------------------------------------------------------------------
-- ERC 03/01/2016:
-- Invalidamos los tests con Error Code Import<>0
-------------------------------------------------------------------------------------------------------------------------------------
-- Se invalidan los test cuyos KPIID no pueden calcularse por tener fallido el trigger, pero el test se esta dando como valido
update testinfo
set valid=0, invalidReason=invalidReason + ' || LCC Start/End Time missing (at Session/Test end)'
from testinfo t, Lcc_Data_HTTPTransfer_DL h
where t.testid=h.testid	
	and h.ErrorCause='Error: Start/End Time missing (at Session/Test end)'
	and t.InvalidReason not like '%|| LCC Start/End Time missing (at Session/Test end)'		-- Por no añadir la causa en reprocesados
	and t.testid>@maxTestid_DL

update testinfo
set valid=0, invalidReason=invalidReason + ' || LCC Start/End Time missing (at Session/Test end)'
from testinfo t, Lcc_Data_HTTPTransfer_UL h
where t.testid=h.testid	
	and h.ErrorCause='Error: Start/End Time missing (at Session/Test end)'
	and t.InvalidReason not like '%|| LCC Start/End Time missing (at Session/Test end)'		-- Por no añadir la causa en reprocesados
	and t.testid>@maxTestid_UL

update testinfo
set valid=0, invalidReason=invalidReason + ' || LCC Start/End Time missing (at Session/Test end)'
from testinfo t, Lcc_Data_HTTPBrowser h
where t.testid=h.testid	
	and h.ErrorCause='Error: Start/End Time missing (at Session/Test end)'
	and t.InvalidReason not like '%|| LCC Start/End Time missing (at Session/Test end)'		-- Por no añadir la causa en reprocesados
	and t.testid>@maxTestid_BR


-------------------------------------------------------------------------------------------------------------------------------------
-- DGP 18/02/2016:
-- Invalidamos los tests afectados por el URA PCH 
-------------------------------------------------------------------------------------------------------------------------------------
exec dbo.sp_lcc_DropIfExists '_URAstate'

select tant.msgtime as initime,t.msgtime as endtime, 
	        tant.rrcstate as rrcstate, t.rrcstate as newRrcState,
			tnext.rrcstate as next_RRCState, tnext.msgtime as nextRRC_time
,s.fileid as fileid 
into _URAstate 
from wcdmarrcstate t, wcdmarrcstate tant, wcdmarrcstate tnext, sessions s, sessions sant, sessions snext
where t.sessionid=s.sessionid and tant.sessionid=sant.sessionid and tnext.sessionid=snext.sessionid
and s.fileid=sant.fileid and s.fileid=snext.FileId
and t.MsgId=tant.MsgId+1 and t.MsgId=tnext.msgid-1
and s.sessionid > @maxSessionid


exec dbo.sp_lcc_DropIfExists '_URA'

select t.*, datediff(s,r.initime,t.starttime) timeInRRCstate,r.rrcstate, 
r.newRRCState, datediff(s,t.starttime,r.endtime) timeToRRCstate_Change,
1 as samples
into _URA
from
(
	select 
	 master.dbo.fn_lcc_getElement(4,collectionname,'_') city
	,CollectionName,imei,mnc,starttime,endtime,sessionid,testid,fileid,
	testtype,errorcause,errortype,info
	from [dbo].[Lcc_Data_HTTPBrowser]
	union all
	select master.dbo.fn_lcc_getElement(4,collectionname,'_') city
	,CollectionName,imei,mnc,starttime,endtime,sessionid,testid,fileid,
	testtype,errorcause,errortype,info
	 from [dbo].[Lcc_Data_HTTPTransfer_DL]
	 union all
	select master.dbo.fn_lcc_getElement(4,collectionname,'_') city
	,CollectionName,imei,mnc,starttime,endtime,sessionid,testid,fileid,
	testname testtype,fails errorcause, cause errortype,info 
	from [dbo].[Lcc_Data_YOUTUBE]
	union all
	select 
	master.dbo.fn_lcc_getElement(4,collectionname,'_') city
	,CollectionName,imei,mnc,starttime,endtime,sessionid,testid,fileid,
	testtype,errorcause,errortype,info 
	from [dbo].[Lcc_Data_HTTPTransfer_UL] 
) t
left outer join _URAstate r 
   on t.fileid=r.fileid
      and t.startTime between r.initime and r.endtime


update testinfo
set valid=0, invalidreason='LCC_URAPCH_Issue'
from testinfo t, _URA i
where i.rrcstate=5 and i.timeToRRCstate_Change>=10
	and i.errortype is not null
	and t.testid=i.testid
	and t.sessionid > @maxSessionid
	and t.valid=1

-------------------------------------------------------------------------------------------------------------------------------------
--DGP 11/03/2016:
--  Ponemos a NULL la info de Radio de los tests en los que no exista esa info 
-------------------------------------------------------------------------------------------------------------------------------------

update Lcc_Data_HTTPTransfer_DL
set [% GSM]=null, [% WCDMA]=null, [% LTE]=null, [% F1 U2100]=null, [% F2 U2100]=null, [% F3 U2100]=null, [% F1 U900]=null,
	[% F2 U900]=null, [% U2100]=null, [% U900]=null, [% LTE2600]=null, [% LTE2100]=null, [% LTE1800]=null,
	[% LTE800]=null, [DCS %]=null, [GSM %]=null, [EGSM %]=null, 
	[% LTE2600_SCC1]=null, [% LTE2100_SCC1]=null, [% LTE1800_SCC1]=null, [% LTE800_SCC1]=null,
	[% LTE2600_SCC2]=null, [% LTE2100_SCC2]=null, [% LTE1800_SCC2]=null, [% LTE800_SCC2]=null,
	[Roaming_VF]=NULL,[Roaming_MV]=NULL,[Roaming_OR]=NULL,[Roaming_YO]=NULL,
	[Roaming_U900]=NULL,[Roaming_U2100]=NULL,[Roaming_LTE800]=NULL,[Roaming_LTE1800]=NULL,[Roaming_LTE2100]=NULL,[Roaming_LTE2600]=NULL,
	[Duration_roaming_VF]=NULL,[Duration_roaming_MV]=NULL,[Duration_roaming_OR]=NULL,[Duration_roaming_YO]=NULL,
	[Duration_roaming_U900]=NULL,[Duration_roaming_U2100]=NULL,[Duration_roaming_LTE800]=NULL,[Duration_roaming_LTE1800]=NULL,[Duration_roaming_LTE2100]=NULL,[Duration_roaming_LTE2600]=NULL,
	Info_Update=isnull(Info_Update,'')+';4'
where
	([% GSM] = 0 and [% WCDMA]=0 and [% LTE]=0)
	and testid > @maxTestid_DL

update Lcc_Data_HTTPTransfer_UL
set [% GSM]=null, [% WCDMA]=null, [% LTE]=null, [% F1 U2100]=null, [% F2 U2100]=null, [% F3 U2100]=null, [% F1 U900]=null,
	[% F2 U900]=null, [% U2100]=null, [% U900]=null, [% LTE2600]=null, [% LTE2100]=null, [% LTE1800]=null,
	[% LTE800]=null, [DCS %]=null, [GSM %]=null, [EGSM %]=null,
	[Roaming_VF]=NULL,[Roaming_MV]=NULL,[Roaming_OR]=NULL,[Roaming_YO]=NULL,
	[Roaming_U900]=NULL,[Roaming_U2100]=NULL,[Roaming_LTE800]=NULL,[Roaming_LTE1800]=NULL,[Roaming_LTE2100]=NULL,[Roaming_LTE2600]=NULL,
	[Duration_roaming_VF]=NULL,[Duration_roaming_MV]=NULL,[Duration_roaming_OR]=NULL,[Duration_roaming_YO]=NULL,
	[Duration_roaming_U900]=NULL,[Duration_roaming_U2100]=NULL,[Duration_roaming_LTE800]=NULL,[Duration_roaming_LTE1800]=NULL,[Duration_roaming_LTE2100]=NULL,[Duration_roaming_LTE2600]=NULL,
	Info_Update=isnull(Info_Update,'')+';4'
where
	([% GSM] = 0 and [% WCDMA]=0 and [% LTE]=0)
	and testid > @maxTestid_UL

update Lcc_Data_HTTPBrowser
set [% GSM]=null, [% WCDMA]=null, [% LTE]=null, [% F1 U2100]=null, [% F2 U2100]=null, [% F3 U2100]=null, [% F1 U900]=null,
	[% F2 U900]=null, [% U2100]=null, [% U900]=null, [% LTE2600]=null, [% LTE2100]=null, [% LTE1800]=null,
	[% LTE800]=null, [DCS %]=null, [GSM %]=null, [EGSM %]=null, 
	[% LTE2600_SCC1]=null, [% LTE2100_SCC1]=null, [% LTE1800_SCC1]=null, [% LTE800_SCC1]=null,
	[% LTE2600_SCC2]=null, [% LTE2100_SCC2]=null, [% LTE1800_SCC2]=null, [% LTE800_SCC2]=null,
	[Roaming_VF]=NULL,[Roaming_MV]=NULL,[Roaming_OR]=NULL,[Roaming_YO]=NULL,
	[Roaming_U900]=NULL,[Roaming_U2100]=NULL,[Roaming_LTE800]=NULL,[Roaming_LTE1800]=NULL,[Roaming_LTE2100]=NULL,[Roaming_LTE2600]=NULL,
	[Duration_roaming_VF]=NULL,[Duration_roaming_MV]=NULL,[Duration_roaming_OR]=NULL,[Duration_roaming_YO]=NULL,
	[Duration_roaming_U900]=NULL,[Duration_roaming_U2100]=NULL,[Duration_roaming_LTE800]=NULL,[Duration_roaming_LTE1800]=NULL,[Duration_roaming_LTE2100]=NULL,[Duration_roaming_LTE2600]=NULL,
	Info_Update=isnull(Info_Update,'')+';4'
where
	([% GSM] = 0 and [% WCDMA]=0 and [% LTE]=0)
	and testid > @maxTestid_BR

update Lcc_Data_YOUTUBE
set [% GSM]=null, [% WCDMA]=null, [% LTE]=null, [% F1 U2100]=null, [% F2 U2100]=null, [% F3 U2100]=null, [% F1 U900]=null,
	[% F2 U900]=null, [% U2100]=null, [% U900]=null, [% LTE2600]=null, [% LTE2100]=null, [% LTE1800]=null,
	[% LTE800]=null, [DCS %]=null, [GSM %]=null, [EGSM %]=null, 
	[% LTE2600_SCC1]=null, [% LTE2100_SCC1]=null, [% LTE1800_SCC1]=null, [% LTE800_SCC1]=null,
	[% LTE2600_SCC2]=null, [% LTE2100_SCC2]=null, [% LTE1800_SCC2]=null, [% LTE800_SCC2]=null,
	[Roaming_VF]=NULL,[Roaming_MV]=NULL,[Roaming_OR]=NULL,[Roaming_YO]=NULL,
	[Roaming_U900]=NULL,[Roaming_U2100]=NULL,[Roaming_LTE800]=NULL,[Roaming_LTE1800]=NULL,[Roaming_LTE2100]=NULL,[Roaming_LTE2600]=NULL,
	[Duration_roaming_VF]=NULL,[Duration_roaming_MV]=NULL,[Duration_roaming_OR]=NULL,[Duration_roaming_YO]=NULL,
	[Duration_roaming_U900]=NULL,[Duration_roaming_U2100]=NULL,[Duration_roaming_LTE800]=NULL,[Duration_roaming_LTE1800]=NULL,[Duration_roaming_LTE2100]=NULL,[Duration_roaming_LTE2600]=NULL,
	Info_Update=isnull(Info_Update,'')+';4'
where
	([% GSM] = 0 and [% WCDMA]=0 and [% LTE]=0)
	and testid > @maxTestid_YTB

update Lcc_Data_Latencias
set [% GSM]=null, [% WCDMA]=null, [% LTE]=null, [% F1 U2100]=null, [% F2 U2100]=null, [% F3 U2100]=null, [% F1 U900]=null,
	[% F2 U900]=null, [% U2100]=null, [% U900]=null, [% LTE2600]=null, [% LTE2100]=null, [% LTE1800]=null,
	[% LTE800]=null, [DCS %]=null, [GSM %]=null, [EGSM %]=null, 
	[% LTE2600_SCC1]=null, [% LTE2100_SCC1]=null, [% LTE1800_SCC1]=null, [% LTE800_SCC1]=null,
	[% LTE2600_SCC2]=null, [% LTE2100_SCC2]=null, [% LTE1800_SCC2]=null, [% LTE800_SCC2]=null,
	[Roaming_VF]=NULL,[Roaming_MV]=NULL,[Roaming_OR]=NULL,[Roaming_YO]=NULL,
	[Roaming_U900]=NULL,[Roaming_U2100]=NULL,[Roaming_LTE800]=NULL,[Roaming_LTE1800]=NULL,[Roaming_LTE2100]=NULL,[Roaming_LTE2600]=NULL,
	[Duration_roaming_VF]=NULL,[Duration_roaming_MV]=NULL,[Duration_roaming_OR]=NULL,[Duration_roaming_YO]=NULL,
	[Duration_roaming_U900]=NULL,[Duration_roaming_U2100]=NULL,[Duration_roaming_LTE800]=NULL,[Duration_roaming_LTE1800]=NULL,[Duration_roaming_LTE2100]=NULL,[Duration_roaming_LTE2600]=NULL,
	Info_Update=isnull(Info_Update,'')+';4'
where
	([% GSM] = 0 and [% WCDMA]=0 and [% LTE]=0)
	and testid > @maxTestid_LAT


-------------------------------------------------------------------------------------------------------------------------------------
-- Incoherencias en información de carriers
-- (no siempre las tablas de sistema detectan las carriers a la vez)
-------------------------------------------------------------------------------------------------------------------------------------
--Si la tabla de sistema de BW esta vacia, puede haber incoherencias SC/CA/3C vs Desgloses BW / Desgloses tecn Carriers	(se comprueba para DL y para WEB):
-- Lcc_Data_HTTPTransfer_DL
update Lcc_Data_HTTPTransfer_DL
set [% GSM]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% WCDMA]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, 
	[% LTE]=[% SC]+[% CA]+[% 3C],
	[% U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% LTE2600]=null, [% LTE2100]=null, [% LTE1800]=null, [% LTE800]=null,
	[DCS %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [GSM %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [EGSM %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% F1 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F2 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F3 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F1 U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F2 U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,	 
	[% LTE2600_SCC1]=null, [% LTE2100_SCC1]=null, [% LTE1800_SCC1]=null, [% LTE800_SCC1]=null,
	[% LTE2600_SCC2]=null, [% LTE2100_SCC2]=null, [% LTE1800_SCC2]=null, [% LTE800_SCC2]=null,
	[Roaming_VF]=NULL,[Roaming_MV]=NULL,[Roaming_OR]=NULL,[Roaming_YO]=NULL,
	[Roaming_U900]=NULL,[Roaming_U2100]=NULL,[Roaming_LTE800]=NULL,[Roaming_LTE1800]=NULL,[Roaming_LTE2100]=NULL,[Roaming_LTE2600]=NULL,
	[Duration_roaming_VF]=NULL,[Duration_roaming_MV]=NULL,[Duration_roaming_OR]=NULL,[Duration_roaming_YO]=NULL,
	[Duration_roaming_U900]=NULL,[Duration_roaming_U2100]=NULL,[Duration_roaming_LTE800]=NULL,[Duration_roaming_LTE1800]=NULL,[Duration_roaming_LTE2100]=NULL,[Duration_roaming_LTE2600]=NULL,
	[HSPA_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA+_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA_DC_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA+_DC_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[5Mhz Bandwidth % SC]=NULL,[10Mhz Bandwidth % SC]=NULL,[15Mhz Bandwidth % SC]=NULL,[20Mhz Bandwidth % SC]=NULL,
	[15Mhz Bandwidth % CA]=NULL,[20Mhz Bandwidth % CA]=NULL,[25Mhz Bandwidth % CA]=NULL,[30Mhz Bandwidth % CA]=NULL,[35Mhz Bandwidth % CA]=NULL,[40Mhz Bandwidth % CA]=NULL,		
	[25Mhz Bandwidth % 3C]=NULL,[30Mhz Bandwidth % 3C]=NULL,[35Mhz Bandwidth % 3C]=NULL,[40Mhz Bandwidth % 3C]=NULL,[45Mhz Bandwidth % 3C]=NULL,[50Mhz Bandwidth % 3C]=NULL,[55Mhz Bandwidth % 3C]=NULL,[60Mhz Bandwidth % 3C]=NULL,
	[5Mhz Bandwidth PCC %]=NULL,[10Mhz Bandwidth PCC %]=NULL,[15Mhz Bandwidth PCC %]=NULL,[20Mhz Bandwidth PCC %]=NULL,
	[5Mhz Bandwidth SCC1 %]=NULL,[10Mhz Bandwidth SCC1 %]=NULL,[15Mhz Bandwidth SCC1 %]=NULL,[20Mhz Bandwidth SCC1 %]=NULL,
	[5Mhz Bandwidth SCC2 %]=NULL,[10Mhz Bandwidth SCC2 %]=NULL,[15Mhz Bandwidth SCC2 %]=NULL,[20Mhz Bandwidth SCC2 %]=NULL,
	Info_Update=isnull(Info_Update,'')+';5'	--Anulada info tecnologia y BW. Incoherencia SC vs BW
where [5Mhz Bandwidth % SC real] is null  --La tabla de BW no contiene información
	and testid > @maxTestid_DL
	and round(isnull([% SC],0),6)<>
		round(isnull([5Mhz Bandwidth % SC],0)+isnull([10Mhz Bandwidth % SC],0)+isnull([15Mhz Bandwidth % SC],0)+isnull([20Mhz Bandwidth % SC],0),6)

update Lcc_Data_HTTPTransfer_DL
set [% GSM]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% WCDMA]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% LTE]=[% SC]+[% CA]+[% 3C],
	[% U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% LTE2600]=null, [% LTE2100]=null, [% LTE1800]=null, [% LTE800]=null,
	[DCS %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [GSM %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [EGSM %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% F1 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F2 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F3 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F1 U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F2 U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,	 
	[% LTE2600_SCC1]=null, [% LTE2100_SCC1]=null, [% LTE1800_SCC1]=null, [% LTE800_SCC1]=null,
	[% LTE2600_SCC2]=null, [% LTE2100_SCC2]=null, [% LTE1800_SCC2]=null, [% LTE800_SCC2]=null,
	[Roaming_VF]=NULL,[Roaming_MV]=NULL,[Roaming_OR]=NULL,[Roaming_YO]=NULL,
	[Roaming_U900]=NULL,[Roaming_U2100]=NULL,[Roaming_LTE800]=NULL,[Roaming_LTE1800]=NULL,[Roaming_LTE2100]=NULL,[Roaming_LTE2600]=NULL,
	[Duration_roaming_VF]=NULL,[Duration_roaming_MV]=NULL,[Duration_roaming_OR]=NULL,[Duration_roaming_YO]=NULL,
	[Duration_roaming_U900]=NULL,[Duration_roaming_U2100]=NULL,[Duration_roaming_LTE800]=NULL,[Duration_roaming_LTE1800]=NULL,[Duration_roaming_LTE2100]=NULL,[Duration_roaming_LTE2600]=NULL,
	[HSPA_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA+_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA_DC_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA+_DC_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[5Mhz Bandwidth % SC]=NULL,[10Mhz Bandwidth % SC]=NULL,[15Mhz Bandwidth % SC]=NULL,[20Mhz Bandwidth % SC]=NULL,
	[15Mhz Bandwidth % CA]=NULL,[20Mhz Bandwidth % CA]=NULL,[25Mhz Bandwidth % CA]=NULL,[30Mhz Bandwidth % CA]=NULL,[35Mhz Bandwidth % CA]=NULL,[40Mhz Bandwidth % CA]=NULL,		
	[25Mhz Bandwidth % 3C]=NULL,[30Mhz Bandwidth % 3C]=NULL,[35Mhz Bandwidth % 3C]=NULL,[40Mhz Bandwidth % 3C]=NULL,[45Mhz Bandwidth % 3C]=NULL,[50Mhz Bandwidth % 3C]=NULL,[55Mhz Bandwidth % 3C]=NULL,[60Mhz Bandwidth % 3C]=NULL,
	[5Mhz Bandwidth PCC %]=NULL,[10Mhz Bandwidth PCC %]=NULL,[15Mhz Bandwidth PCC %]=NULL,[20Mhz Bandwidth PCC %]=NULL,
	[5Mhz Bandwidth SCC1 %]=NULL,[10Mhz Bandwidth SCC1 %]=NULL,[15Mhz Bandwidth SCC1 %]=NULL,[20Mhz Bandwidth SCC1 %]=NULL,
	[5Mhz Bandwidth SCC2 %]=NULL,[10Mhz Bandwidth SCC2 %]=NULL,[15Mhz Bandwidth SCC2 %]=NULL,[20Mhz Bandwidth SCC2 %]=NULL,
	Info_Update=isnull(Info_Update,'')+';6'	--Anulada info tecnologia y BW. Incoherencia CA vs BW
where [5Mhz Bandwidth % SC real] is null  --La tabla de BW no contiene información
	and testid > @maxTestid_DL
	and round(isnull([% CA],0),6)<>
		round(isnull([15Mhz Bandwidth % CA],0)+isnull([20Mhz Bandwidth % CA],0)+isnull([25Mhz Bandwidth % CA],0)+isnull([30Mhz Bandwidth % CA],0)+isnull([35Mhz Bandwidth % CA],0)+isnull([40Mhz Bandwidth % CA],0),6)

update Lcc_Data_HTTPTransfer_DL
set [% GSM]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% WCDMA]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, 
	[% LTE]=[% SC]+[% CA]+[% 3C],
	[% U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% LTE2600]=null, [% LTE2100]=null, [% LTE1800]=null, [% LTE800]=null,
	[DCS %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [GSM %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [EGSM %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% F1 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F2 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F3 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F1 U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F2 U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,	 
	[% LTE2600_SCC1]=null, [% LTE2100_SCC1]=null, [% LTE1800_SCC1]=null, [% LTE800_SCC1]=null,
	[% LTE2600_SCC2]=null, [% LTE2100_SCC2]=null, [% LTE1800_SCC2]=null, [% LTE800_SCC2]=null,
	[Roaming_VF]=NULL,[Roaming_MV]=NULL,[Roaming_OR]=NULL,[Roaming_YO]=NULL,
	[Roaming_U900]=NULL,[Roaming_U2100]=NULL,[Roaming_LTE800]=NULL,[Roaming_LTE1800]=NULL,[Roaming_LTE2100]=NULL,[Roaming_LTE2600]=NULL,
	[Duration_roaming_VF]=NULL,[Duration_roaming_MV]=NULL,[Duration_roaming_OR]=NULL,[Duration_roaming_YO]=NULL,
	[Duration_roaming_U900]=NULL,[Duration_roaming_U2100]=NULL,[Duration_roaming_LTE800]=NULL,[Duration_roaming_LTE1800]=NULL,[Duration_roaming_LTE2100]=NULL,[Duration_roaming_LTE2600]=NULL,
	[HSPA_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA+_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA_DC_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA+_DC_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[5Mhz Bandwidth % SC]=NULL,[10Mhz Bandwidth % SC]=NULL,[15Mhz Bandwidth % SC]=NULL,[20Mhz Bandwidth % SC]=NULL,
	[15Mhz Bandwidth % CA]=NULL,[20Mhz Bandwidth % CA]=NULL,[25Mhz Bandwidth % CA]=NULL,[30Mhz Bandwidth % CA]=NULL,[35Mhz Bandwidth % CA]=NULL,[40Mhz Bandwidth % CA]=NULL,		
	[25Mhz Bandwidth % 3C]=NULL,[30Mhz Bandwidth % 3C]=NULL,[35Mhz Bandwidth % 3C]=NULL,[40Mhz Bandwidth % 3C]=NULL,[45Mhz Bandwidth % 3C]=NULL,[50Mhz Bandwidth % 3C]=NULL,[55Mhz Bandwidth % 3C]=NULL,[60Mhz Bandwidth % 3C]=NULL,
	[5Mhz Bandwidth PCC %]=NULL,[10Mhz Bandwidth PCC %]=NULL,[15Mhz Bandwidth PCC %]=NULL,[20Mhz Bandwidth PCC %]=NULL,
	[5Mhz Bandwidth SCC1 %]=NULL,[10Mhz Bandwidth SCC1 %]=NULL,[15Mhz Bandwidth SCC1 %]=NULL,[20Mhz Bandwidth SCC1 %]=NULL,
	[5Mhz Bandwidth SCC2 %]=NULL,[10Mhz Bandwidth SCC2 %]=NULL,[15Mhz Bandwidth SCC2 %]=NULL,[20Mhz Bandwidth SCC2 %]=NULL,
	Info_Update=isnull(Info_Update,'')+';7'	--Anulada info tecnologia y BW. Incoherencia 3C vs BW
where [5Mhz Bandwidth % SC real] is null  --La tabla de BW no contiene información
	and testid > @maxTestid_DL
	and round(isnull([% 3C],0),6)<>
		round(isnull([25Mhz Bandwidth % 3C],0)+isnull([30Mhz Bandwidth % 3C],0)+isnull([35Mhz Bandwidth % 3C],0)+isnull([40Mhz Bandwidth % 3C],0)+isnull([45Mhz Bandwidth % 3C],0)+isnull([50Mhz Bandwidth % 3C],0)+isnull([55Mhz Bandwidth % 3C],0)+isnull([60Mhz Bandwidth % 3C],0),6)


update Lcc_Data_HTTPTransfer_DL
set [% GSM]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% WCDMA]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, 
	[% LTE]=[% SC]+[% CA]+[% 3C],
	[% U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% LTE2600]=null, [% LTE2100]=null, [% LTE1800]=null, [% LTE800]=null, 
	[DCS %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [GSM %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [EGSM %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% F1 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F2 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F3 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F1 U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F2 U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,	 
	[% LTE2600_SCC1]=null, [% LTE2100_SCC1]=null, [% LTE1800_SCC1]=null, [% LTE800_SCC1]=null,
	[% LTE2600_SCC2]=null, [% LTE2100_SCC2]=null, [% LTE1800_SCC2]=null, [% LTE800_SCC2]=null,
	[Roaming_VF]=NULL,[Roaming_MV]=NULL,[Roaming_OR]=NULL,[Roaming_YO]=NULL,
	[Roaming_U900]=NULL,[Roaming_U2100]=NULL,[Roaming_LTE800]=NULL,[Roaming_LTE1800]=NULL,[Roaming_LTE2100]=NULL,[Roaming_LTE2600]=NULL,
	[Duration_roaming_VF]=NULL,[Duration_roaming_MV]=NULL,[Duration_roaming_OR]=NULL,[Duration_roaming_YO]=NULL,
	[Duration_roaming_U900]=NULL,[Duration_roaming_U2100]=NULL,[Duration_roaming_LTE800]=NULL,[Duration_roaming_LTE1800]=NULL,[Duration_roaming_LTE2100]=NULL,[Duration_roaming_LTE2600]=NULL,
	[HSPA_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA+_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA_DC_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA+_DC_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[5Mhz Bandwidth % SC]=NULL,[10Mhz Bandwidth % SC]=NULL,[15Mhz Bandwidth % SC]=NULL,[20Mhz Bandwidth % SC]=NULL,
	[15Mhz Bandwidth % CA]=NULL,[20Mhz Bandwidth % CA]=NULL,[25Mhz Bandwidth % CA]=NULL,[30Mhz Bandwidth % CA]=NULL,[35Mhz Bandwidth % CA]=NULL,[40Mhz Bandwidth % CA]=NULL,		
	[25Mhz Bandwidth % 3C]=NULL,[30Mhz Bandwidth % 3C]=NULL,[35Mhz Bandwidth % 3C]=NULL,[40Mhz Bandwidth % 3C]=NULL,[45Mhz Bandwidth % 3C]=NULL,[50Mhz Bandwidth % 3C]=NULL,[55Mhz Bandwidth % 3C]=NULL,[60Mhz Bandwidth % 3C]=NULL,
	[5Mhz Bandwidth PCC %]=NULL,[10Mhz Bandwidth PCC %]=NULL,[15Mhz Bandwidth PCC %]=NULL,[20Mhz Bandwidth PCC %]=NULL,
	[5Mhz Bandwidth SCC1 %]=NULL,[10Mhz Bandwidth SCC1 %]=NULL,[15Mhz Bandwidth SCC1 %]=NULL,[20Mhz Bandwidth SCC1 %]=NULL,
	[5Mhz Bandwidth SCC2 %]=NULL,[10Mhz Bandwidth SCC2 %]=NULL,[15Mhz Bandwidth SCC2 %]=NULL,[20Mhz Bandwidth SCC2 %]=NULL,
	Info_Update=isnull(Info_Update,'')+';8'	--Anulada info tecnologia y BW. Incoherencia Carriers vs PCC
where [5Mhz Bandwidth % SC real] is null  --La tabla de BW no contiene información
	and testid > @maxTestid_DL
	and round(isnull([% SC],0)+isnull([% CA],0)+isnull([% 3C],0),6)<>
		round(isnull([% LTE2600],0)+isnull([% LTE1800],0)+isnull([% LTE800],0)+isnull([% LTE2100],0),6)

update Lcc_Data_HTTPTransfer_DL
set [% GSM]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% WCDMA]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% LTE]=[% SC]+[% CA]+[% 3C],
	[% U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, 
	[% LTE2600]=null, [% LTE2100]=null, [% LTE1800]=null, [% LTE800]=null, 
	[DCS %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [GSM %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [EGSM %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% F1 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F2 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F3 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F1 U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F2 U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,	 
	[% LTE2600_SCC1]=null, [% LTE2100_SCC1]=null, [% LTE1800_SCC1]=null, [% LTE800_SCC1]=null,
	[% LTE2600_SCC2]=null, [% LTE2100_SCC2]=null, [% LTE1800_SCC2]=null, [% LTE800_SCC2]=null,
	[Roaming_VF]=NULL,[Roaming_MV]=NULL,[Roaming_OR]=NULL,[Roaming_YO]=NULL,
	[Roaming_U900]=NULL,[Roaming_U2100]=NULL,[Roaming_LTE800]=NULL,[Roaming_LTE1800]=NULL,[Roaming_LTE2100]=NULL,[Roaming_LTE2600]=NULL,
	[Duration_roaming_VF]=NULL,[Duration_roaming_MV]=NULL,[Duration_roaming_OR]=NULL,[Duration_roaming_YO]=NULL,
	[Duration_roaming_U900]=NULL,[Duration_roaming_U2100]=NULL,[Duration_roaming_LTE800]=NULL,[Duration_roaming_LTE1800]=NULL,[Duration_roaming_LTE2100]=NULL,[Duration_roaming_LTE2600]=NULL,
	[HSPA_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA+_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA_DC_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA+_DC_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[5Mhz Bandwidth % SC]=NULL,[10Mhz Bandwidth % SC]=NULL,[15Mhz Bandwidth % SC]=NULL,[20Mhz Bandwidth % SC]=NULL,
	[15Mhz Bandwidth % CA]=NULL,[20Mhz Bandwidth % CA]=NULL,[25Mhz Bandwidth % CA]=NULL,[30Mhz Bandwidth % CA]=NULL,[35Mhz Bandwidth % CA]=NULL,[40Mhz Bandwidth % CA]=NULL,		
	[25Mhz Bandwidth % 3C]=NULL,[30Mhz Bandwidth % 3C]=NULL,[35Mhz Bandwidth % 3C]=NULL,[40Mhz Bandwidth % 3C]=NULL,[45Mhz Bandwidth % 3C]=NULL,[50Mhz Bandwidth % 3C]=NULL,[55Mhz Bandwidth % 3C]=NULL,[60Mhz Bandwidth % 3C]=NULL,
	[5Mhz Bandwidth PCC %]=NULL,[10Mhz Bandwidth PCC %]=NULL,[15Mhz Bandwidth PCC %]=NULL,[20Mhz Bandwidth PCC %]=NULL,
	[5Mhz Bandwidth SCC1 %]=NULL,[10Mhz Bandwidth SCC1 %]=NULL,[15Mhz Bandwidth SCC1 %]=NULL,[20Mhz Bandwidth SCC1 %]=NULL,
	[5Mhz Bandwidth SCC2 %]=NULL,[10Mhz Bandwidth SCC2 %]=NULL,[15Mhz Bandwidth SCC2 %]=NULL,[20Mhz Bandwidth SCC2 %]=NULL,
	Info_Update=isnull(Info_Update,'')+';9'	--Anulada info tecnologia y BW. Incoherencia Carriers vs SCC1
where [5Mhz Bandwidth % SC real] is null  --La tabla de BW no contiene información
	and testid > @maxTestid_DL
	and round(+isnull([% CA],0)+isnull([% 3C],0),6)<>
		round(isnull([% LTE2600_SCC1],0)+isnull([% LTE1800_SCC1],0)+isnull([% LTE800_SCC1],0)+isnull([% LTE2100_SCC1],0),6)

update Lcc_Data_HTTPTransfer_DL
set [% GSM]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, 
	[% WCDMA]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% LTE]=[% SC]+[% CA]+[% 3C],
	[% U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% LTE2600]=null, [% LTE2100]=null, [% LTE1800]=null, [% LTE800]=null, 
	[DCS %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [GSM %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [EGSM %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% F1 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F2 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F3 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F1 U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F2 U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,	 
	[% LTE2600_SCC1]=null, [% LTE2100_SCC1]=null, [% LTE1800_SCC1]=null, [% LTE800_SCC1]=null,
	[% LTE2600_SCC2]=null, [% LTE2100_SCC2]=null, [% LTE1800_SCC2]=null, [% LTE800_SCC2]=null,
	[Roaming_VF]=NULL,[Roaming_MV]=NULL,[Roaming_OR]=NULL,[Roaming_YO]=NULL,
	[Roaming_U900]=NULL,[Roaming_U2100]=NULL,[Roaming_LTE800]=NULL,[Roaming_LTE1800]=NULL,[Roaming_LTE2100]=NULL,[Roaming_LTE2600]=NULL,
	[Duration_roaming_VF]=NULL,[Duration_roaming_MV]=NULL,[Duration_roaming_OR]=NULL,[Duration_roaming_YO]=NULL,
	[Duration_roaming_U900]=NULL,[Duration_roaming_U2100]=NULL,[Duration_roaming_LTE800]=NULL,[Duration_roaming_LTE1800]=NULL,[Duration_roaming_LTE2100]=NULL,[Duration_roaming_LTE2600]=NULL,
	[HSPA_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA+_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA_DC_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA+_DC_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[5Mhz Bandwidth % SC]=NULL,[10Mhz Bandwidth % SC]=NULL,[15Mhz Bandwidth % SC]=NULL,[20Mhz Bandwidth % SC]=NULL,
	[15Mhz Bandwidth % CA]=NULL,[20Mhz Bandwidth % CA]=NULL,[25Mhz Bandwidth % CA]=NULL,[30Mhz Bandwidth % CA]=NULL,[35Mhz Bandwidth % CA]=NULL,[40Mhz Bandwidth % CA]=NULL,		
	[25Mhz Bandwidth % 3C]=NULL,[30Mhz Bandwidth % 3C]=NULL,[35Mhz Bandwidth % 3C]=NULL,[40Mhz Bandwidth % 3C]=NULL,[45Mhz Bandwidth % 3C]=NULL,[50Mhz Bandwidth % 3C]=NULL,[55Mhz Bandwidth % 3C]=NULL,[60Mhz Bandwidth % 3C]=NULL,
	[5Mhz Bandwidth PCC %]=NULL,[10Mhz Bandwidth PCC %]=NULL,[15Mhz Bandwidth PCC %]=NULL,[20Mhz Bandwidth PCC %]=NULL,
	[5Mhz Bandwidth SCC1 %]=NULL,[10Mhz Bandwidth SCC1 %]=NULL,[15Mhz Bandwidth SCC1 %]=NULL,[20Mhz Bandwidth SCC1 %]=NULL,
	[5Mhz Bandwidth SCC2 %]=NULL,[10Mhz Bandwidth SCC2 %]=NULL,[15Mhz Bandwidth SCC2 %]=NULL,[20Mhz Bandwidth SCC2 %]=NULL,
	Info_Update=isnull(Info_Update,'')+';10'	--Anulada info tecnologia y BW. Incoherencia Carriers vs SCC2
where [5Mhz Bandwidth % SC real] is null  --La tabla de BW no contiene información
	and testid > @maxTestid_DL
	and round(isnull([% 3C],0),6)<>
		round(isnull([% LTE2600_SCC2],0)+isnull([% LTE1800_SCC2],0)+isnull([% LTE800_SCC2],0)+isnull([% LTE2100_SCC2],0),6)

-- Lcc_Data_HTTPBrowser
update Lcc_Data_HTTPBrowser
set [% GSM]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, 
	[% WCDMA]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% LTE]=[% SC]+[% CA]+[% 3C],
	[% U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% LTE2600]=null, [% LTE2100]=null, [% LTE1800]=null, [% LTE800]=null, 
	[DCS %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [GSM %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [EGSM %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% F1 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F2 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F3 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F1 U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F2 U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,	 
	[% LTE2600_SCC1]=null, [% LTE2100_SCC1]=null, [% LTE1800_SCC1]=null, [% LTE800_SCC1]=null,
	[% LTE2600_SCC2]=null, [% LTE2100_SCC2]=null, [% LTE1800_SCC2]=null, [% LTE800_SCC2]=null,
	[Roaming_VF]=NULL,[Roaming_MV]=NULL,[Roaming_OR]=NULL,[Roaming_YO]=NULL,
	[Roaming_U900]=NULL,[Roaming_U2100]=NULL,[Roaming_LTE800]=NULL,[Roaming_LTE1800]=NULL,[Roaming_LTE2100]=NULL,[Roaming_LTE2600]=NULL,
	[Duration_roaming_VF]=NULL,[Duration_roaming_MV]=NULL,[Duration_roaming_OR]=NULL,[Duration_roaming_YO]=NULL,
	[Duration_roaming_U900]=NULL,[Duration_roaming_U2100]=NULL,[Duration_roaming_LTE800]=NULL,[Duration_roaming_LTE1800]=NULL,[Duration_roaming_LTE2100]=NULL,[Duration_roaming_LTE2600]=NULL,
	[HSPA_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA+_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA_DC_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA+_DC_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[5Mhz Bandwidth % SC]=NULL,[10Mhz Bandwidth % SC]=NULL,[15Mhz Bandwidth % SC]=NULL,[20Mhz Bandwidth % SC]=NULL,
	[15Mhz Bandwidth % CA]=NULL,[20Mhz Bandwidth % CA]=NULL,[25Mhz Bandwidth % CA]=NULL,[30Mhz Bandwidth % CA]=NULL,[35Mhz Bandwidth % CA]=NULL,[40Mhz Bandwidth % CA]=NULL,		
	[25Mhz Bandwidth % 3C]=NULL,[30Mhz Bandwidth % 3C]=NULL,[35Mhz Bandwidth % 3C]=NULL,[40Mhz Bandwidth % 3C]=NULL,[45Mhz Bandwidth % 3C]=NULL,[50Mhz Bandwidth % 3C]=NULL,[55Mhz Bandwidth % 3C]=NULL,[60Mhz Bandwidth % 3C]=NULL,
	[5Mhz Bandwidth PCC %]=NULL,[10Mhz Bandwidth PCC %]=NULL,[15Mhz Bandwidth PCC %]=NULL,[20Mhz Bandwidth PCC %]=NULL,
	[5Mhz Bandwidth SCC1 %]=NULL,[10Mhz Bandwidth SCC1 %]=NULL,[15Mhz Bandwidth SCC1 %]=NULL,[20Mhz Bandwidth SCC1 %]=NULL,
	[5Mhz Bandwidth SCC2 %]=NULL,[10Mhz Bandwidth SCC2 %]=NULL,[15Mhz Bandwidth SCC2 %]=NULL,[20Mhz Bandwidth SCC2 %]=NULL,
	Info_Update=isnull(Info_Update,'')+';5'	--Anulada info tecnologia y BW. Incoherencia SC vs BW
where [5Mhz Bandwidth % SC real] is null  --La tabla de BW no contiene información
	and testid > @maxTestid_BR
	and round(isnull([% SC],0),6)<>
		round(isnull([5Mhz Bandwidth % SC],0)+isnull([10Mhz Bandwidth % SC],0)+isnull([15Mhz Bandwidth % SC],0)+isnull([20Mhz Bandwidth % SC],0),6)

update Lcc_Data_HTTPBrowser
set [% GSM]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, 
	[% WCDMA]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, 
	[% LTE]=[% SC]+[% CA]+[% 3C],
	[% U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, 
	[% LTE2600]=null, [% LTE2100]=null, [% LTE1800]=null, [% LTE800]=null, 
	[DCS %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [GSM %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [EGSM %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% F1 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F2 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F3 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F1 U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F2 U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,	 
	[% LTE2600_SCC1]=null, [% LTE2100_SCC1]=null, [% LTE1800_SCC1]=null, [% LTE800_SCC1]=null,
	[% LTE2600_SCC2]=null, [% LTE2100_SCC2]=null, [% LTE1800_SCC2]=null, [% LTE800_SCC2]=null,
	[Roaming_VF]=NULL,[Roaming_MV]=NULL,[Roaming_OR]=NULL,[Roaming_YO]=NULL,
	[Roaming_U900]=NULL,[Roaming_U2100]=NULL,[Roaming_LTE800]=NULL,[Roaming_LTE1800]=NULL,[Roaming_LTE2100]=NULL,[Roaming_LTE2600]=NULL,
	[Duration_roaming_VF]=NULL,[Duration_roaming_MV]=NULL,[Duration_roaming_OR]=NULL,[Duration_roaming_YO]=NULL,
	[Duration_roaming_U900]=NULL,[Duration_roaming_U2100]=NULL,[Duration_roaming_LTE800]=NULL,[Duration_roaming_LTE1800]=NULL,[Duration_roaming_LTE2100]=NULL,[Duration_roaming_LTE2600]=NULL,
	[HSPA_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA+_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA_DC_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA+_DC_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[5Mhz Bandwidth % SC]=NULL,[10Mhz Bandwidth % SC]=NULL,[15Mhz Bandwidth % SC]=NULL,[20Mhz Bandwidth % SC]=NULL,
	[15Mhz Bandwidth % CA]=NULL,[20Mhz Bandwidth % CA]=NULL,[25Mhz Bandwidth % CA]=NULL,[30Mhz Bandwidth % CA]=NULL,[35Mhz Bandwidth % CA]=NULL,[40Mhz Bandwidth % CA]=NULL,		
	[25Mhz Bandwidth % 3C]=NULL,[30Mhz Bandwidth % 3C]=NULL,[35Mhz Bandwidth % 3C]=NULL,[40Mhz Bandwidth % 3C]=NULL,[45Mhz Bandwidth % 3C]=NULL,[50Mhz Bandwidth % 3C]=NULL,[55Mhz Bandwidth % 3C]=NULL,[60Mhz Bandwidth % 3C]=NULL,
	[5Mhz Bandwidth PCC %]=NULL,[10Mhz Bandwidth PCC %]=NULL,[15Mhz Bandwidth PCC %]=NULL,[20Mhz Bandwidth PCC %]=NULL,
	[5Mhz Bandwidth SCC1 %]=NULL,[10Mhz Bandwidth SCC1 %]=NULL,[15Mhz Bandwidth SCC1 %]=NULL,[20Mhz Bandwidth SCC1 %]=NULL,
	[5Mhz Bandwidth SCC2 %]=NULL,[10Mhz Bandwidth SCC2 %]=NULL,[15Mhz Bandwidth SCC2 %]=NULL,[20Mhz Bandwidth SCC2 %]=NULL,
	Info_Update=isnull(Info_Update,'')+';6'	--Anulada info tecnologia y BW. Incoherencia CA vs BW
where [5Mhz Bandwidth % SC real] is null  --La tabla de BW no contiene información
	and testid > @maxTestid_BR
	and round(isnull([% CA],0),6)<>
		round(isnull([15Mhz Bandwidth % CA],0)+isnull([20Mhz Bandwidth % CA],0)+isnull([25Mhz Bandwidth % CA],0)+isnull([30Mhz Bandwidth % CA],0)+isnull([35Mhz Bandwidth % CA],0)+isnull([40Mhz Bandwidth % CA],0),6)

update Lcc_Data_HTTPBrowser
set [% GSM]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, 
	[% WCDMA]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, 
	[% LTE]=[% SC]+[% CA]+[% 3C],
	[% U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, 
	[% LTE2600]=null, [% LTE2100]=null, [% LTE1800]=null, [% LTE800]=null, 
	[DCS %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [GSM %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [EGSM %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% F1 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F2 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F3 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F1 U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F2 U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,	 
	[% LTE2600_SCC1]=null, [% LTE2100_SCC1]=null, [% LTE1800_SCC1]=null, [% LTE800_SCC1]=null,
	[% LTE2600_SCC2]=null, [% LTE2100_SCC2]=null, [% LTE1800_SCC2]=null, [% LTE800_SCC2]=null,
	[Roaming_VF]=NULL,[Roaming_MV]=NULL,[Roaming_OR]=NULL,[Roaming_YO]=NULL,
	[Roaming_U900]=NULL,[Roaming_U2100]=NULL,[Roaming_LTE800]=NULL,[Roaming_LTE1800]=NULL,[Roaming_LTE2100]=NULL,[Roaming_LTE2600]=NULL,
	[Duration_roaming_VF]=NULL,[Duration_roaming_MV]=NULL,[Duration_roaming_OR]=NULL,[Duration_roaming_YO]=NULL,
	[Duration_roaming_U900]=NULL,[Duration_roaming_U2100]=NULL,[Duration_roaming_LTE800]=NULL,[Duration_roaming_LTE1800]=NULL,[Duration_roaming_LTE2100]=NULL,[Duration_roaming_LTE2600]=NULL,
	[HSPA_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA+_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA_DC_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA+_DC_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[5Mhz Bandwidth % SC]=NULL,[10Mhz Bandwidth % SC]=NULL,[15Mhz Bandwidth % SC]=NULL,[20Mhz Bandwidth % SC]=NULL,
	[15Mhz Bandwidth % CA]=NULL,[20Mhz Bandwidth % CA]=NULL,[25Mhz Bandwidth % CA]=NULL,[30Mhz Bandwidth % CA]=NULL,[35Mhz Bandwidth % CA]=NULL,[40Mhz Bandwidth % CA]=NULL,		
	[25Mhz Bandwidth % 3C]=NULL,[30Mhz Bandwidth % 3C]=NULL,[35Mhz Bandwidth % 3C]=NULL,[40Mhz Bandwidth % 3C]=NULL,[45Mhz Bandwidth % 3C]=NULL,[50Mhz Bandwidth % 3C]=NULL,[55Mhz Bandwidth % 3C]=NULL,[60Mhz Bandwidth % 3C]=NULL,
	[5Mhz Bandwidth PCC %]=NULL,[10Mhz Bandwidth PCC %]=NULL,[15Mhz Bandwidth PCC %]=NULL,[20Mhz Bandwidth PCC %]=NULL,
	[5Mhz Bandwidth SCC1 %]=NULL,[10Mhz Bandwidth SCC1 %]=NULL,[15Mhz Bandwidth SCC1 %]=NULL,[20Mhz Bandwidth SCC1 %]=NULL,
	[5Mhz Bandwidth SCC2 %]=NULL,[10Mhz Bandwidth SCC2 %]=NULL,[15Mhz Bandwidth SCC2 %]=NULL,[20Mhz Bandwidth SCC2 %]=NULL,
	Info_Update=isnull(Info_Update,'')+';7'	--Anulada info tecnologia y BW. Incoherencia 3C vs BW
where [5Mhz Bandwidth % SC real] is null  --La tabla de BW no contiene información
	and testid > @maxTestid_BR
	and round(isnull([% 3C],0),6)<>
		round(isnull([25Mhz Bandwidth % 3C],0)+isnull([30Mhz Bandwidth % 3C],0)+isnull([35Mhz Bandwidth % 3C],0)+isnull([40Mhz Bandwidth % 3C],0)+isnull([45Mhz Bandwidth % 3C],0)+isnull([50Mhz Bandwidth % 3C],0)+isnull([55Mhz Bandwidth % 3C],0)+isnull([60Mhz Bandwidth % 3C],0),6)


update Lcc_Data_HTTPBrowser
set [% GSM]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, 
	[% WCDMA]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, 
	[% LTE]=[% SC]+[% CA]+[% 3C],
	[% U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, 
	[% LTE2600]=null, [% LTE2100]=null, [% LTE1800]=null, [% LTE800]=null, 
	[DCS %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [GSM %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [EGSM %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% F1 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F2 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F3 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F1 U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F2 U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,	 
	[% LTE2600_SCC1]=null, [% LTE2100_SCC1]=null, [% LTE1800_SCC1]=null, [% LTE800_SCC1]=null,
	[% LTE2600_SCC2]=null, [% LTE2100_SCC2]=null, [% LTE1800_SCC2]=null, [% LTE800_SCC2]=null,
	[Roaming_VF]=NULL,[Roaming_MV]=NULL,[Roaming_OR]=NULL,[Roaming_YO]=NULL,
	[Roaming_U900]=NULL,[Roaming_U2100]=NULL,[Roaming_LTE800]=NULL,[Roaming_LTE1800]=NULL,[Roaming_LTE2100]=NULL,[Roaming_LTE2600]=NULL,
	[Duration_roaming_VF]=NULL,[Duration_roaming_MV]=NULL,[Duration_roaming_OR]=NULL,[Duration_roaming_YO]=NULL,
	[Duration_roaming_U900]=NULL,[Duration_roaming_U2100]=NULL,[Duration_roaming_LTE800]=NULL,[Duration_roaming_LTE1800]=NULL,[Duration_roaming_LTE2100]=NULL,[Duration_roaming_LTE2600]=NULL,
	[HSPA_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA+_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA_DC_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA+_DC_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[5Mhz Bandwidth % SC]=NULL,[10Mhz Bandwidth % SC]=NULL,[15Mhz Bandwidth % SC]=NULL,[20Mhz Bandwidth % SC]=NULL,
	[15Mhz Bandwidth % CA]=NULL,[20Mhz Bandwidth % CA]=NULL,[25Mhz Bandwidth % CA]=NULL,[30Mhz Bandwidth % CA]=NULL,[35Mhz Bandwidth % CA]=NULL,[40Mhz Bandwidth % CA]=NULL,		
	[25Mhz Bandwidth % 3C]=NULL,[30Mhz Bandwidth % 3C]=NULL,[35Mhz Bandwidth % 3C]=NULL,[40Mhz Bandwidth % 3C]=NULL,[45Mhz Bandwidth % 3C]=NULL,[50Mhz Bandwidth % 3C]=NULL,[55Mhz Bandwidth % 3C]=NULL,[60Mhz Bandwidth % 3C]=NULL,
	[5Mhz Bandwidth PCC %]=NULL,[10Mhz Bandwidth PCC %]=NULL,[15Mhz Bandwidth PCC %]=NULL,[20Mhz Bandwidth PCC %]=NULL,
	[5Mhz Bandwidth SCC1 %]=NULL,[10Mhz Bandwidth SCC1 %]=NULL,[15Mhz Bandwidth SCC1 %]=NULL,[20Mhz Bandwidth SCC1 %]=NULL,
	[5Mhz Bandwidth SCC2 %]=NULL,[10Mhz Bandwidth SCC2 %]=NULL,[15Mhz Bandwidth SCC2 %]=NULL,[20Mhz Bandwidth SCC2 %]=NULL,
	Info_Update=isnull(Info_Update,'')+';8'	--Anulada info tecnologia y BW. Incoherencia Carriers vs PCC
where [5Mhz Bandwidth % SC real] is null  --La tabla de BW no contiene información
	and testid > @maxTestid_BR
	and round(isnull([% SC],0)+isnull([% CA],0)+isnull([% 3C],0),6)<>
		round(isnull([% LTE2600],0)+isnull([% LTE1800],0)+isnull([% LTE800],0)+isnull([% LTE2100],0),6)

update Lcc_Data_HTTPBrowser
set [% GSM]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% WCDMA]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, 
	[% LTE]=[% SC]+[% CA]+[% 3C],
	[% U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, 
	[% LTE2600]=null, [% LTE2100]=null, [% LTE1800]=null, [% LTE800]=null, 
	[DCS %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [GSM %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [EGSM %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% F1 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F2 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F3 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F1 U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F2 U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,	 
	[% LTE2600_SCC1]=null, [% LTE2100_SCC1]=null, [% LTE1800_SCC1]=null, [% LTE800_SCC1]=null,
	[% LTE2600_SCC2]=null, [% LTE2100_SCC2]=null, [% LTE1800_SCC2]=null, [% LTE800_SCC2]=null,
	[Roaming_VF]=NULL,[Roaming_MV]=NULL,[Roaming_OR]=NULL,[Roaming_YO]=NULL,
	[Roaming_U900]=NULL,[Roaming_U2100]=NULL,[Roaming_LTE800]=NULL,[Roaming_LTE1800]=NULL,[Roaming_LTE2100]=NULL,[Roaming_LTE2600]=NULL,
	[Duration_roaming_VF]=NULL,[Duration_roaming_MV]=NULL,[Duration_roaming_OR]=NULL,[Duration_roaming_YO]=NULL,
	[Duration_roaming_U900]=NULL,[Duration_roaming_U2100]=NULL,[Duration_roaming_LTE800]=NULL,[Duration_roaming_LTE1800]=NULL,[Duration_roaming_LTE2100]=NULL,[Duration_roaming_LTE2600]=NULL,
	[HSPA_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA+_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA_DC_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA+_DC_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[5Mhz Bandwidth % SC]=NULL,[10Mhz Bandwidth % SC]=NULL,[15Mhz Bandwidth % SC]=NULL,[20Mhz Bandwidth % SC]=NULL,
	[15Mhz Bandwidth % CA]=NULL,[20Mhz Bandwidth % CA]=NULL,[25Mhz Bandwidth % CA]=NULL,[30Mhz Bandwidth % CA]=NULL,[35Mhz Bandwidth % CA]=NULL,[40Mhz Bandwidth % CA]=NULL,		
	[25Mhz Bandwidth % 3C]=NULL,[30Mhz Bandwidth % 3C]=NULL,[35Mhz Bandwidth % 3C]=NULL,[40Mhz Bandwidth % 3C]=NULL,[45Mhz Bandwidth % 3C]=NULL,[50Mhz Bandwidth % 3C]=NULL,[55Mhz Bandwidth % 3C]=NULL,[60Mhz Bandwidth % 3C]=NULL,
	[5Mhz Bandwidth PCC %]=NULL,[10Mhz Bandwidth PCC %]=NULL,[15Mhz Bandwidth PCC %]=NULL,[20Mhz Bandwidth PCC %]=NULL,
	[5Mhz Bandwidth SCC1 %]=NULL,[10Mhz Bandwidth SCC1 %]=NULL,[15Mhz Bandwidth SCC1 %]=NULL,[20Mhz Bandwidth SCC1 %]=NULL,
	[5Mhz Bandwidth SCC2 %]=NULL,[10Mhz Bandwidth SCC2 %]=NULL,[15Mhz Bandwidth SCC2 %]=NULL,[20Mhz Bandwidth SCC2 %]=NULL,
	Info_Update=isnull(Info_Update,'')+';9'	--Anulada info tecnologia y BW. Incoherencia Carriers vs SCC1
where [5Mhz Bandwidth % SC real] is null  --La tabla de BW no contiene información
	and testid > @maxTestid_BR
	and round(+isnull([% CA],0)+isnull([% 3C],0),6)<>
		round(isnull([% LTE2600_SCC1],0)+isnull([% LTE1800_SCC1],0)+isnull([% LTE800_SCC1],0)+isnull([% LTE2100_SCC1],0),6)

update Lcc_Data_HTTPBrowser
set [% GSM]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, 
	[% WCDMA]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, 
	[% LTE]=[% SC]+[% CA]+[% 3C],
	[% U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, 
	[% LTE2600]=null, [% LTE2100]=null, [% LTE1800]=null, [% LTE800]=null, 
	[DCS %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [GSM %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [EGSM %]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[% F1 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F2 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F3 U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F1 U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end, [% F2 U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,	 
	[% LTE2600_SCC1]=null, [% LTE2100_SCC1]=null, [% LTE1800_SCC1]=null, [% LTE800_SCC1]=null,
	[% LTE2600_SCC2]=null, [% LTE2100_SCC2]=null, [% LTE1800_SCC2]=null, [% LTE800_SCC2]=null,
	[Roaming_VF]=NULL,[Roaming_MV]=NULL,[Roaming_OR]=NULL,[Roaming_YO]=NULL,
	[Roaming_U900]=NULL,[Roaming_U2100]=NULL,[Roaming_LTE800]=NULL,[Roaming_LTE1800]=NULL,[Roaming_LTE2100]=NULL,[Roaming_LTE2600]=NULL,
	[Duration_roaming_VF]=NULL,[Duration_roaming_MV]=NULL,[Duration_roaming_OR]=NULL,[Duration_roaming_YO]=NULL,
	[Duration_roaming_U900]=NULL,[Duration_roaming_U2100]=NULL,[Duration_roaming_LTE800]=NULL,[Duration_roaming_LTE1800]=NULL,[Duration_roaming_LTE2100]=NULL,[Duration_roaming_LTE2600]=NULL,
	[HSPA_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA+_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA_DC_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[HSPA+_DC_PCT]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier U2100]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,[% Dual Carrier U900]=case when round(([% SC]+[% CA]+[% 3C]),6)=1 then 0 end,
	[5Mhz Bandwidth % SC]=NULL,[10Mhz Bandwidth % SC]=NULL,[15Mhz Bandwidth % SC]=NULL,[20Mhz Bandwidth % SC]=NULL,
	[15Mhz Bandwidth % CA]=NULL,[20Mhz Bandwidth % CA]=NULL,[25Mhz Bandwidth % CA]=NULL,[30Mhz Bandwidth % CA]=NULL,[35Mhz Bandwidth % CA]=NULL,[40Mhz Bandwidth % CA]=NULL,		
	[25Mhz Bandwidth % 3C]=NULL,[30Mhz Bandwidth % 3C]=NULL,[35Mhz Bandwidth % 3C]=NULL,[40Mhz Bandwidth % 3C]=NULL,[45Mhz Bandwidth % 3C]=NULL,[50Mhz Bandwidth % 3C]=NULL,[55Mhz Bandwidth % 3C]=NULL,[60Mhz Bandwidth % 3C]=NULL,
	[5Mhz Bandwidth PCC %]=NULL,[10Mhz Bandwidth PCC %]=NULL,[15Mhz Bandwidth PCC %]=NULL,[20Mhz Bandwidth PCC %]=NULL,
	[5Mhz Bandwidth SCC1 %]=NULL,[10Mhz Bandwidth SCC1 %]=NULL,[15Mhz Bandwidth SCC1 %]=NULL,[20Mhz Bandwidth SCC1 %]=NULL,
	[5Mhz Bandwidth SCC2 %]=NULL,[10Mhz Bandwidth SCC2 %]=NULL,[15Mhz Bandwidth SCC2 %]=NULL,[20Mhz Bandwidth SCC2 %]=NULL,
	Info_Update=isnull(Info_Update,'')+';10' --Anulada info tecnologia y BW. Incoherencia Carriers vs SCC2
where [5Mhz Bandwidth % SC real] is null  --La tabla de BW no contiene información
	and testid > @maxTestid_BR
	and round(isnull([% 3C],0),6)<>
		round(isnull([% LTE2600_SCC2],0)+isnull([% LTE1800_SCC2],0)+isnull([% LTE800_SCC2],0)+isnull([% LTE2100_SCC2],0),6)

-------------------------------------------------------------------------------------------------------------------------------------
--DGP 16/03/2016
-- Se invalidan todos los tests en los que ningun KPIID tiene duración 
-------------------------------------------------------------------------------------------------------------------------------------
update testinfo
set valid=0, invalidReason = 'LCC Youtube Null Test'
from testinfo t, _ETSIYouTubeKPIs e
where t.testid=e.testid
		and	(e.Duration10620 is null 
			and e.Duration20620 is null
			and e.Duration10625 is null
			and e.Duration30621 is null
			and e.Duration20621 is null)
and t.valid=1
and t.testid > @maxTestid

-------------------------------------------------------------------------------------------------------------------------------------
-- Se anula la info de las carriers que no son detectadas 
--  (pueden detectarse en otras tablas de LTE y no desde donde se calcula SC/CA/3C)
-------------------------------------------------------------------------------------------------------------------------------------
update Lcc_Data_HTTPTransfer_DL
set 
	[DataTransferred_SCC1]=null,	[TransferTime_SCC1]=null,	[Throughput_SCC1]=null,	[Throughput_MAX_SCC1]=null,	
	[DataTransferred_SCC2]=null,	[TransferTime_SCC2]=null,	[Throughput_SCC2]=null,	[Throughput_MAX_SCC2]=null,
	[% QPSK 4G SCC1]=null,	[% 16QAM 4G SCC1]=null,	[% 64QAM 4G SCC1]=null,	
	[% QPSK 4G SCC2]=null,	[% 16QAM 4G SCC2]=null,	[% 64QAM 4G SCC2]=null,	
	[RBs SCC1]=null,[Max RBs SCC1]=null,[Min RBs SCC1]=null,[RBs When Allocated SCC1]=null, 
	[RBs SCC2]=null,[Max RBs SCC2]=null,[Min RBs SCC2]=null,[RBs When Allocated SCC2]=null, 
	[% TM Invalid SCC1]=null,	[% TM 1: Single Antenna Port 0 SCC1]=null,	[% TM 2: TD Rank 1 SCC1]=null,	[% TM 3: OL SM SCC1]=null,	[% TM 4: CL SM SCC1]=null,	[% TM 5: MU MIMO SCC1]=null,	[% TM 6: CL RANK1 PC SCC1]=null,	[% TM 7: Single Antenna Port 5 SCC1]=null,	[% TM Unknown SCC1]=null,	
	[% TM Invalid SCC2]=null,	[% TM 1: Single Antenna Port 0 SCC2]=null,	[% TM 2: TD Rank 1 SCC2]=null,	[% TM 3: OL SM SCC2]=null,	[% TM 4: CL SM SCC2]=null,	[% TM 5: MU MIMO SCC2]=null,	[% TM 6: CL RANK1 PC SCC2]=null,	[% TM 7: Single Antenna Port 5 SCC2]=null,	[% TM Unknown SCC2]=null,
	[CQI 4G SCC1]=null,	[CQI LTE2600 SCC1]=null,	[CQI LTE1800 SCC1]=null,	[CQI LTE800 SCC1]=null,	[CQI LTE2100 SCC1]=null,
	[CQI 4G SCC2]=null,	[CQI LTE2600 SCC2]=null,	[CQI LTE1800 SCC2]=null,	[CQI LTE800 SCC2]=null,	[CQI LTE2100 SCC2]=null,
	[% MIMO_SCC1]=null,	[% RI2_TM2_SCC1]=null,	[% RI2_TM3_SCC1]=null,	[% RI2_TM4_SCC1]=null,	[% RI1_SCC1]=null,	[% RI2_SCC1]=null,	
	[% MIMO_SCC2]=null,	[% RI2_TM2_SCC2]=null,	[% RI2_TM3_SCC2]=null,	[% RI2_TM4_SCC2]=null,	[% RI1_SCC2]=null,	[% RI2_SCC2]=null,
	Info_Update=isnull(Info_Update,'')+';11'	--Anulada info segunda y tercera carrier
where testid > @maxTestid_DL
	and isnull([% CA],0)=0 and isnull([% 3C],0)=0

update Lcc_Data_HTTPTransfer_DL
set 
	[DataTransferred_SCC2]=null,	[TransferTime_SCC2]=null,	[Throughput_SCC2]=null,	[Throughput_MAX_SCC2]=null,
	[% QPSK 4G SCC2]=null,	[% 16QAM 4G SCC2]=null,	[% 64QAM 4G SCC2]=null,	
	[RBs SCC2]=null,[Max RBs SCC2]=null,[Min RBs SCC2]=null,[RBs When Allocated SCC2]=null,
	[% TM Invalid SCC2]=null,	[% TM 1: Single Antenna Port 0 SCC2]=null,	[% TM 2: TD Rank 1 SCC2]=null,	[% TM 3: OL SM SCC2]=null,	[% TM 4: CL SM SCC2]=null,	[% TM 5: MU MIMO SCC2]=null,	[% TM 6: CL RANK1 PC SCC2]=null,	[% TM 7: Single Antenna Port 5 SCC2]=null,	[% TM Unknown SCC2]=null,
	[CQI 4G SCC2]=null,	[CQI LTE2600 SCC2]=null,	[CQI LTE1800 SCC2]=null,	[CQI LTE800 SCC2]=null,	[CQI LTE2100 SCC2]=null,
	[% MIMO_SCC2]=null,	[% RI2_TM2_SCC2]=null,	[% RI2_TM3_SCC2]=null,	[% RI2_TM4_SCC2]=null,	[% RI1_SCC2]=null,	[% RI2_SCC2]=null,
	Info_Update=isnull(Info_Update,'')+';12' --Anulada info tercera carrier
where testid > @maxTestid_DL
	and isnull([% 3C],0)=0 and isnull([% CA],0)>0

	
update Lcc_Data_HTTPBrowser
set 
	[DataTransferred_SCC1]=null,	[TransferTime_SCC1]=null,	[Throughput_SCC1]=null,	[Throughput_MAX_SCC1]=null,	
	[DataTransferred_SCC2]=null,	[TransferTime_SCC2]=null,	[Throughput_SCC2]=null,	[Throughput_MAX_SCC2]=null,
	[% QPSK 4G SCC1]=null,	[% 16QAM 4G SCC1]=null,	[% 64QAM 4G SCC1]=null,	
	[% QPSK 4G SCC2]=null,	[% 16QAM 4G SCC2]=null,	[% 64QAM 4G SCC2]=null,	
	[RBs SCC1]=null,[Max RBs SCC1]=null,[Min RBs SCC1]=null,[RBs When Allocated SCC1]=null, 
	[RBs SCC2]=null,[Max RBs SCC2]=null,[Min RBs SCC2]=null,[RBs When Allocated SCC2]=null, 
	[CQI 4G SCC1]=null,
	[CQI 4G SCC2]=null,	
	[% MIMO_SCC1]=null,	[% RI2_TM2_SCC1]=null,	[% RI2_TM3_SCC1]=null,	[% RI2_TM4_SCC1]=null,	[% RI1_SCC1]=null,	[% RI2_SCC1]=null,	
	[% MIMO_SCC2]=null,	[% RI2_TM2_SCC2]=null,	[% RI2_TM3_SCC2]=null,	[% RI2_TM4_SCC2]=null,	[% RI1_SCC2]=null,	[% RI2_SCC2]=null,
	Info_Update=isnull(Info_Update,'')+';11' --Anulada info segunda y tercera carrier
where testid > @maxTestid_BR
	and isnull([% CA],0)=0 and isnull([% 3C],0)=0

update Lcc_Data_HTTPBrowser
set 
	[DataTransferred_SCC2]=null,	[TransferTime_SCC2]=null,	[Throughput_SCC2]=null,	[Throughput_MAX_SCC2]=null,
	[% QPSK 4G SCC2]=null,	[% 16QAM 4G SCC2]=null,	[% 64QAM 4G SCC2]=null,	
	[RBs SCC2]=null,[Max RBs SCC2]=null,[Min RBs SCC2]=null,[RBs When Allocated SCC2]=null,
	[CQI 4G SCC2]=null,
	[% MIMO_SCC2]=null,	[% RI2_TM2_SCC2]=null,	[% RI2_TM3_SCC2]=null,	[% RI2_TM4_SCC2]=null,	[% RI1_SCC2]=null,	[% RI2_SCC2]=null,
	Info_Update=isnull(Info_Update,'')+';12'
where testid > @maxTestid_BR
	and isnull([% 3C],0)=0 and isnull([% CA],0)>0

--Anulamos la info de HSDPA si está a cero y hay 3G
update Lcc_Data_HTTPTransfer_DL
set [HSPA_PCT]=null, [HSPA+_PCT]=null, [HSPA_DC_PCT]=null, [HSPA+_DC_PCT]=null, [% Dual Carrier]=null,[% Dual Carrier U900]=null,[% Dual Carrier U2100]=null,
	Info_Update=isnull(Info_Update,'')+';13'	--Anulado desglose 3G
where testid > @maxTestid_DL
	and round(isnull([% WCDMA],0),6)<>
		round(isnull([HSPA_PCT],0)+isnull([HSPA+_PCT],0)+isnull([HSPA_DC_PCT],0)+isnull([HSPA+_DC_PCT],0),6)

update Lcc_Data_HTTPTransfer_UL
set [HSPA_PCT]=null, [HSPA+_PCT]=null, [HSPA_DC_PCT]=null, [HSPA+_DC_PCT]=null,
	Info_Update=isnull(Info_Update,'')+';13'	--Anulado desglose 3G
where testid > @maxTestid_UL
	and round(isnull([% WCDMA],0),6)<>
		round(isnull([HSPA_PCT],0)+isnull([HSPA+_PCT],0)+isnull([HSPA_DC_PCT],0)+isnull([HSPA+_DC_PCT],0),6)

update Lcc_Data_HTTPBrowser
set [HSPA_PCT]=null, [HSPA+_PCT]=null, [HSPA_DC_PCT]=null, [HSPA+_DC_PCT]=null, [% Dual Carrier]=null,[% Dual Carrier U900]=null,[% Dual Carrier U2100]=null,
	Info_Update=isnull(Info_Update,'')+';13'	--Anulado desglose 3G
where testid > @maxTestid_BR
	and round(isnull([% WCDMA],0),6)<>
		round(isnull([HSPA_PCT],0)+isnull([HSPA+_PCT],0)+isnull([HSPA_DC_PCT],0)+isnull([HSPA+_DC_PCT],0),6)

------------------------------------------------------------------------------------------------------------------------------------
-- Intentamos simular la tecnologia y desglose de banda de tests con SC+CA+3C = 1:
--  el cuadre con desgloses desde serving ha podido no cuadrar en % pero aqui lo adaptamos, sólo si las frecuencias de las carriers 
--  son iguales en el momento inicial/final que son detectadas
-------------------------------------------------------------------------------------------------------------------------------------
update Lcc_Data_HTTPTransfer_DL
set [% LTE2600]=case when c.band='LTE2600' then 1 else 0 end,
	[% LTE2100]=case when c.band='LTE2100' then 1 else 0 end,
	[% LTE1800]=case when c.band='LTE1800' then 1 else 0 end,
	[% LTE800]=case when c.band='LTE800' then 1 else 0 end, 
	[% LTE2600_SCC1]=case when c.band_SCC1='LTE2600' then isnull([% CA],0)+isnull([% 3C],0) else 0 end,
	[% LTE2100_SCC1]=case when c.band_SCC1='LTE2100' then isnull([% CA],0)+isnull([% 3C],0) else 0 end,
	[% LTE1800_SCC1]=case when c.band_SCC1='LTE1800' then isnull([% CA],0)+isnull([% 3C],0) else 0 end,
	[% LTE800_SCC1]=case when c.band_SCC1='LTE800' then isnull([% CA],0)+isnull([% 3C],0) else 0 end,

	[% LTE2600_SCC2]=case when c.band_SCC2='LTE2600' then isnull([% 3C],0) else 0 end,
	[% LTE2100_SCC2]=case when c.band_SCC2='LTE2100' then isnull([% 3C],0) else 0 end,
	[% LTE1800_SCC2]=case when c.band_SCC2='LTE1800' then isnull([% 3C],0) else 0 end,
	[% LTE800_SCC2]=case when c.band_SCC2='LTE800' then isnull([% 3C],0) else 0 end,

	[5Mhz Bandwidth % SC]=case when c.DLBandWidth=5 then isnull([% SC],0) else 0 end,
	[10Mhz Bandwidth % SC]=case when c.DLBandWidth=10 then isnull([% SC],0) else 0 end,
	[15Mhz Bandwidth % SC]=case when c.DLBandWidth=15 then isnull([% SC],0) else 0 end,
	[20Mhz Bandwidth % SC]=case when c.DLBandWidth=20 then isnull([% SC],0) else 0 end,

	[15Mhz Bandwidth % CA]=case when c.DLBandWidth+c.DLBandWidth_SCC1=15 then isnull([% CA],0) else 0 end,
	[20Mhz Bandwidth % CA]=case when c.DLBandWidth+c.DLBandWidth_SCC1=20 then isnull([% CA],0) else 0 end,
	[25Mhz Bandwidth % CA]=case when c.DLBandWidth+c.DLBandWidth_SCC1=25 then isnull([% CA],0) else 0 end,
	[30Mhz Bandwidth % CA]=case when c.DLBandWidth+c.DLBandWidth_SCC1=30 then isnull([% CA],0) else 0 end,
	[35Mhz Bandwidth % CA]=case when c.DLBandWidth+c.DLBandWidth_SCC1=35 then isnull([% CA],0) else 0 end,
	[40Mhz Bandwidth % CA]=case when c.DLBandWidth+c.DLBandWidth_SCC1=40 then isnull([% CA],0) else 0 end,		

	[25Mhz Bandwidth % 3C]=case when c.DLBandWidth+c.DLBandWidth_SCC1+c.DLBandWidth_SCC2=25 then isnull([% 3C],0) else 0 end,
	[30Mhz Bandwidth % 3C]=case when c.DLBandWidth+c.DLBandWidth_SCC1+c.DLBandWidth_SCC2=30 then isnull([% 3C],0) else 0 end,
	[35Mhz Bandwidth % 3C]=case when c.DLBandWidth+c.DLBandWidth_SCC1+c.DLBandWidth_SCC2=35 then isnull([% 3C],0) else 0 end,
	[40Mhz Bandwidth % 3C]=case when c.DLBandWidth+c.DLBandWidth_SCC1+c.DLBandWidth_SCC2=40 then isnull([% 3C],0) else 0 end,
	[45Mhz Bandwidth % 3C]=case when c.DLBandWidth+c.DLBandWidth_SCC1+c.DLBandWidth_SCC2=45 then isnull([% 3C],0) else 0 end,
	[50Mhz Bandwidth % 3C]=case when c.DLBandWidth+c.DLBandWidth_SCC1+c.DLBandWidth_SCC2=50 then isnull([% 3C],0) else 0 end,
	[55Mhz Bandwidth % 3C]=case when c.DLBandWidth+c.DLBandWidth_SCC1+c.DLBandWidth_SCC2=55 then isnull([% 3C],0) else 0 end,
	[60Mhz Bandwidth % 3C]=case when c.DLBandWidth+c.DLBandWidth_SCC1+c.DLBandWidth_SCC2=60 then isnull([% 3C],0) else 0 end,
	
	[5Mhz Bandwidth PCC %]=case when c.DLBandWidth=5 then 1 else 0 end,
	[10Mhz Bandwidth PCC %]=case when c.DLBandWidth=10 then 1 else 0 end,
	[15Mhz Bandwidth PCC %]=case when c.DLBandWidth=15 then 1 else 0 end,
	[20Mhz Bandwidth PCC %]=case when c.DLBandWidth=20 then 1 else 0 end,

	[5Mhz Bandwidth SCC1 %]=case when c.DLBandWidth_SCC1=5 then isnull([% CA],0)+isnull([% 3C],0) else 0 end,
	[10Mhz Bandwidth SCC1 %]=case when c.DLBandWidth_SCC1=10 then isnull([% CA],0)+isnull([% 3C],0) else 0 end,
	[15Mhz Bandwidth SCC1 %]=case when c.DLBandWidth_SCC1=15 then isnull([% CA],0)+isnull([% 3C],0) else 0 end,
	[20Mhz Bandwidth SCC1 %]=case when c.DLBandWidth_SCC1=20 then isnull([% CA],0)+isnull([% 3C],0) else 0 end,
	
	[5Mhz Bandwidth SCC2 %]=case when c.DLBandWidth_SCC2=5 then isnull([% 3C],0) else 0 end,
	[10Mhz Bandwidth SCC2 %]=case when c.DLBandWidth_SCC2=10 then isnull([% 3C],0) else 0 end,
	[15Mhz Bandwidth SCC2 %]=case when c.DLBandWidth_SCC2=15 then isnull([% 3C],0) else 0 end,
	[20Mhz Bandwidth SCC2 %]=case when c.DLBandWidth_SCC2=20 then isnull([% 3C],0) else 0 end,

	[Roaming_VF]=case when c.Roaming=1 and c.Ope_Roaming='Vodafone' then 1 else 0 end,
	[Roaming_MV]=case when c.Roaming=1 and c.Ope_Roaming='Movistar' then 1 else 0 end,
	[Roaming_OR]=case when c.Roaming=1 and c.Ope_Roaming='Orange' then 1 else 0 end,
	[Roaming_YO]=case when c.Roaming=1 and c.Ope_Roaming='Yoigo' then 1 else 0 end,
	[Roaming_U900]=0,
	[Roaming_U2100]=0,
	[Roaming_LTE800]=case when c.Roaming=1 and c.band='LTE800' then 1 else 0 end,
	[Roaming_LTE1800]=case when c.Roaming=1 and c.band='LTE1800' then 1 else 0 end,
	[Roaming_LTE2100]=case when c.Roaming=1 and c.band='LTE2100' then 1 else 0 end,
	[Roaming_LTE2600]=case when c.Roaming=1 and c.band='LTE2600' then 1 else 0 end,
	[Duration_roaming_VF]=case when c.Roaming=1 and c.Ope_Roaming='Vodafone' then (case when t.ErrorType='Accessibility' then c.durationAcc else c.duration end) else 0 end,
	[Duration_roaming_MV]=case when c.Roaming=1 and c.Ope_Roaming='Movistar' then (case when t.ErrorType='Accessibility' then c.durationAcc else c.duration end) else 0 end,
	[Duration_roaming_OR]=case when c.Roaming=1 and c.Ope_Roaming='Orange' then (case when t.ErrorType='Accessibility' then c.durationAcc else c.duration end) else 0 end,
	[Duration_roaming_YO]=case when c.Roaming=1 and c.Ope_Roaming='Yoigo' then (case when t.ErrorType='Accessibility' then c.durationAcc else c.duration end) else 0 end,
	[Duration_roaming_U900]=0,
	[Duration_roaming_U2100]=0,
	[Duration_roaming_LTE800]=case when c.Roaming=1 and c.band='LTE800' then (case when t.ErrorType='Accessibility' then c.durationAcc else c.duration end) else 0 end,
	[Duration_roaming_LTE1800]=case when c.Roaming=1 and c.band='LTE1800' then (case when t.ErrorType='Accessibility' then c.durationAcc else c.duration end) else 0 end,
	[Duration_roaming_LTE2100]=case when c.Roaming=1 and c.band='LTE2100' then (case when t.ErrorType='Accessibility' then c.durationAcc else c.duration end) else 0 end,
	[Duration_roaming_LTE2600]=case when c.Roaming=1 and c.band='LTE2600' then (case when t.ErrorType='Accessibility' then c.durationAcc else c.duration end) else 0 end,

	Info_Update=isnull(Info_Update,'')+';14'	--Desglose tecnologia 4G y BW simulados
from Lcc_Data_HTTPTransfer_DL t
	inner join _tech_Carriers c on t.testid=c.testid
where t.testid > @maxTestid_DL
	and round(isnull([% SC],0)+isnull([% CA],0)+isnull([% 3C],0),6)=1
	and	[5Mhz Bandwidth % SC] is null	--Información de BW (por tanto, tambien de tecnologia) vacia
	and c.band is not null				--Tecn de inicio/fin del PCC debe coincidir
	and (c.band_SCC1 is not null or (isnull([% CA],0)=0 and isnull([% 3C],0)=0))	--Tecn de inicio/fin del SCC1 debe coincidir si hay CA ó 3C
	and (c.band_SCC2 is not null or isnull([% 3C],0)=0)	--Tecn de inicio/fin del SCC2 debe coincidir si hay 3C

update Lcc_Data_HTTPBrowser
set 
	[% LTE2600]=case when c.band='LTE2600' then 1 else 0 end,
	[% LTE2100]=case when c.band='LTE2100' then 1 else 0 end,
	[% LTE1800]=case when c.band='LTE1800' then 1 else 0 end,
	[% LTE800]=case when c.band='LTE800' then 1 else 0 end, 
	[% LTE2600_SCC1]=case when c.band_SCC1='LTE2600' then isnull([% CA],0)+isnull([% 3C],0) else 0 end,
	[% LTE2100_SCC1]=case when c.band_SCC1='LTE2100' then isnull([% CA],0)+isnull([% 3C],0) else 0 end,
	[% LTE1800_SCC1]=case when c.band_SCC1='LTE1800' then isnull([% CA],0)+isnull([% 3C],0) else 0 end,
	[% LTE800_SCC1]=case when c.band_SCC1='LTE800' then isnull([% CA],0)+isnull([% 3C],0) else 0 end,
	[% LTE2600_SCC2]=case when c.band_SCC2='LTE2600' then isnull([% 3C],0) else 0 end,
	[% LTE2100_SCC2]=case when c.band_SCC2='LTE2100' then isnull([% 3C],0) else 0 end,
	[% LTE1800_SCC2]=case when c.band_SCC2='LTE1800' then isnull([% 3C],0) else 0 end,
	[% LTE800_SCC2]=case when c.band_SCC2='LTE800' then isnull([% 3C],0) else 0 end,

	[5Mhz Bandwidth % SC]=case when c.DLBandWidth=5 then isnull([% SC],0) else 0 end,
	[10Mhz Bandwidth % SC]=case when c.DLBandWidth=10 then isnull([% SC],0) else 0 end,
	[15Mhz Bandwidth % SC]=case when c.DLBandWidth=15 then isnull([% SC],0) else 0 end,
	[20Mhz Bandwidth % SC]=case when c.DLBandWidth=20 then isnull([% SC],0) else 0 end,
	[15Mhz Bandwidth % CA]=case when c.DLBandWidth+c.DLBandWidth_SCC1=15 then isnull([% CA],0) else 0 end,
	[20Mhz Bandwidth % CA]=case when c.DLBandWidth+c.DLBandWidth_SCC1=20 then isnull([% CA],0) else 0 end,
	[25Mhz Bandwidth % CA]=case when c.DLBandWidth+c.DLBandWidth_SCC1=25 then isnull([% CA],0) else 0 end,
	[30Mhz Bandwidth % CA]=case when c.DLBandWidth+c.DLBandWidth_SCC1=30 then isnull([% CA],0) else 0 end,
	[35Mhz Bandwidth % CA]=case when c.DLBandWidth+c.DLBandWidth_SCC1=35 then isnull([% CA],0) else 0 end,
	[40Mhz Bandwidth % CA]=case when c.DLBandWidth+c.DLBandWidth_SCC1=40 then isnull([% CA],0) else 0 end,
	[25Mhz Bandwidth % 3C]=case when c.DLBandWidth+c.DLBandWidth_SCC1+c.DLBandWidth_SCC2=25 then isnull([% 3C],0) else 0 end,
	[30Mhz Bandwidth % 3C]=case when c.DLBandWidth+c.DLBandWidth_SCC1+c.DLBandWidth_SCC2=30 then isnull([% 3C],0) else 0 end,
	[35Mhz Bandwidth % 3C]=case when c.DLBandWidth+c.DLBandWidth_SCC1+c.DLBandWidth_SCC2=35 then isnull([% 3C],0) else 0 end,
	[40Mhz Bandwidth % 3C]=case when c.DLBandWidth+c.DLBandWidth_SCC1+c.DLBandWidth_SCC2=40 then isnull([% 3C],0) else 0 end,
	[45Mhz Bandwidth % 3C]=case when c.DLBandWidth+c.DLBandWidth_SCC1+c.DLBandWidth_SCC2=45 then isnull([% 3C],0) else 0 end,
	[50Mhz Bandwidth % 3C]=case when c.DLBandWidth+c.DLBandWidth_SCC1+c.DLBandWidth_SCC2=50 then isnull([% 3C],0) else 0 end,
	[55Mhz Bandwidth % 3C]=case when c.DLBandWidth+c.DLBandWidth_SCC1+c.DLBandWidth_SCC2=55 then isnull([% 3C],0) else 0 end,
	[60Mhz Bandwidth % 3C]=case when c.DLBandWidth+c.DLBandWidth_SCC1+c.DLBandWidth_SCC2=60 then isnull([% 3C],0) else 0 end,
	
	[5Mhz Bandwidth PCC %]=case when c.DLBandWidth=5 then 1 else 0 end,
	[10Mhz Bandwidth PCC %]=case when c.DLBandWidth=10 then 1 else 0 end,
	[15Mhz Bandwidth PCC %]=case when c.DLBandWidth=15 then 1 else 0 end,
	[20Mhz Bandwidth PCC %]=case when c.DLBandWidth=20 then 1 else 0 end,
	[5Mhz Bandwidth SCC1 %]=case when c.DLBandWidth_SCC1=5 then isnull([% CA],0)+isnull([% 3C],0) else 0 end,
	[10Mhz Bandwidth SCC1 %]=case when c.DLBandWidth_SCC1=10 then isnull([% CA],0)+isnull([% 3C],0) else 0 end,
	[15Mhz Bandwidth SCC1 %]=case when c.DLBandWidth_SCC1=15 then isnull([% CA],0)+isnull([% 3C],0) else 0 end,
	[20Mhz Bandwidth SCC1 %]=case when c.DLBandWidth_SCC1=20 then isnull([% CA],0)+isnull([% 3C],0) else 0 end,	
	[5Mhz Bandwidth SCC2 %]=case when c.DLBandWidth_SCC2=5 then isnull([% 3C],0) else 0 end,
	[10Mhz Bandwidth SCC2 %]=case when c.DLBandWidth_SCC2=10 then isnull([% 3C],0) else 0 end,
	[15Mhz Bandwidth SCC2 %]=case when c.DLBandWidth_SCC2=15 then isnull([% 3C],0) else 0 end,
	[20Mhz Bandwidth SCC2 %]=case when c.DLBandWidth_SCC2=20 then isnull([% 3C],0) else 0 end,
	
	[Roaming_VF]=case when c.Roaming=1 and c.Ope_Roaming='Vodafone' then 1 else 0 end,
	[Roaming_MV]=case when c.Roaming=1 and c.Ope_Roaming='Movistar' then 1 else 0 end,
	[Roaming_OR]=case when c.Roaming=1 and c.Ope_Roaming='Orange' then 1 else 0 end,
	[Roaming_YO]=case when c.Roaming=1 and c.Ope_Roaming='Yoigo' then 1 else 0 end,
	[Roaming_U900]=0,
	[Roaming_U2100]=0,
	[Roaming_LTE800]=case when c.Roaming=1 and c.band='LTE800' then 1 else 0 end,
	[Roaming_LTE1800]=case when c.Roaming=1 and c.band='LTE1800' then 1 else 0 end,
	[Roaming_LTE2100]=case when c.Roaming=1 and c.band='LTE2100' then 1 else 0 end,
	[Roaming_LTE2600]=case when c.Roaming=1 and c.band='LTE2600' then 1 else 0 end,
	[Duration_roaming_VF]=case when c.Roaming=1 and c.Ope_Roaming='Vodafone' then (case when t.ErrorType='Accessibility' then c.durationAcc else c.duration end) else 0 end,
	[Duration_roaming_MV]=case when c.Roaming=1 and c.Ope_Roaming='Movistar' then (case when t.ErrorType='Accessibility' then c.durationAcc else c.duration end) else 0 end,
	[Duration_roaming_OR]=case when c.Roaming=1 and c.Ope_Roaming='Orange' then (case when t.ErrorType='Accessibility' then c.durationAcc else c.duration end) else 0 end,
	[Duration_roaming_YO]=case when c.Roaming=1 and c.Ope_Roaming='Yoigo' then (case when t.ErrorType='Accessibility' then c.durationAcc else c.duration end) else 0 end,
	[Duration_roaming_U900]=0,
	[Duration_roaming_U2100]=0,
	[Duration_roaming_LTE800]=case when c.Roaming=1 and c.band='LTE800' then (case when t.ErrorType='Accessibility' then c.durationAcc else c.duration end) else 0 end,
	[Duration_roaming_LTE1800]=case when c.Roaming=1 and c.band='LTE1800' then (case when t.ErrorType='Accessibility' then c.durationAcc else c.duration end) else 0 end,
	[Duration_roaming_LTE2100]=case when c.Roaming=1 and c.band='LTE2100' then (case when t.ErrorType='Accessibility' then c.durationAcc else c.duration end) else 0 end,
	[Duration_roaming_LTE2600]=case when c.Roaming=1 and c.band='LTE2600' then (case when t.ErrorType='Accessibility' then c.durationAcc else c.duration end) else 0 end,

	Info_Update=isnull(Info_Update,'')+';14'	--Desglose tecnologia 4G y BW simulados
from Lcc_Data_HTTPBrowser t
	inner join _tech_Carriers c on t.testid=c.testid
where t.testid > @maxTestid_BR
	and round(isnull([% SC],0)+isnull([% CA],0)+isnull([% 3C],0),6)=1
	and	[5Mhz Bandwidth % SC] is null	--Información de BW (por tanto, tambien de tecnologia) vacia
	and c.band is not null				--Tecn de inicio/fin del PCC debe coincidir
	and (c.band_SCC1 is not null or (isnull([% CA],0)=0 and isnull([% 3C],0)=0))	--Tecn de inicio/fin del SCC1 debe coincidir si hay CA ó 3C
	and (c.band_SCC2 is not null or isnull([% 3C],0)=0)	--Tecn de inicio/fin del SCC2 debe coincidir si hay 3C

------------------------------------------------------------------------------------------------------------------------------------
-- Se anulan los KPIs por tecnologia, si no es detectada
-------------------------------------------------------------------------------------------------------------------------------------
--Test sin 4G
update Lcc_Data_HTTPTransfer_DL
set [% QPSK 4G]=null,[% 16QAM 4G]=null,[% 64QAM 4G]=null, [% 256QAM 4G]=null,
	[% QPSK 4G PCC]=null,[% 16QAM 4G PCC]=null,[% 64QAM 4G PCC]=null,[% 256QAM 4G PCC]=null,
	[RBs]=null,[Max RBs]=null,[Min RBs]=null,[RBs When Allocated]=null,	[Shared channel use]=null,
	[RBs PCC]=null, [Max RBs PCC]=null, [Min RBs PCC]=null, [RBs When Allocated PCC]=null,	
	[% TM Invalid]=null,[% TM 1: Single Antenna Port 0 ]=null,[% TM 2: TD Rank 1]=null,	[% TM 3: OL SM]=null,[% TM 4: CL SM]=null,[% TM 5: MU MIMO]=null,[% TM 6: CL RANK1 PC]=null,[% TM 7: Single Antenna Port 5]=null,[% TM Unknown]=null,
	[% TM Invalid PCC]=null,[% TM 1: Single Antenna Port 0 PCC]=null,[% TM 2: TD Rank 1 PCC]=null,	[% TM 3: OL SM PCC]=null,[% TM 4: CL SM PCC]=null,[% TM 5: MU MIMO PCC]=null,	[% TM 6: CL RANK1 PC PCC]=null,[% TM 7: Single Antenna Port 5 PCC]=null,[% TM Unknown PCC]=null,  
	[% MIMO]=null,[% RI2_TM2]=null,[% RI2_TM3]=null,[% RI2_TM4]=null,
	[% MIMO_PCC]=null,[% RI2_TM2_PCC]=null,[% RI2_TM3_PCC]=null,[% RI2_TM4_PCC]=null,
	[% RI1]=null,[% RI2]=null,
	[% RI1_PCC]=null,[% RI2_PCC]=null,
	[CQI 4G]=null,[CQI LTE2600]=null,[CQI LTE1800]=null,[CQI LTE800]=null,[CQI LTE2100]=null,
	[CQI 4G PCC]=null,[CQI LTE2600 PCC]=null,[CQI LTE1800 PCC]=null,[CQI LTE800 PCC]=null,[CQI LTE2100 PCC]=null,
	EARFCN_N1=null,PCI_N1=null,	RSRP_N1=null,RSRQ_N1=null,
	num_HO_S1X2=null,duration_S1X2_avg=null,S1X2HO_SR=null,
	Info_Update=isnull(Info_Update,'')+';15'	--Anular KPIS tecnologia 4G
where [% LTE]=0
	and testid > @maxTestid_DL

update Lcc_Data_HTTPTransfer_UL
set [% BPSK 4G]=null, [% QPSK 4G]=null, [% 16QAM 4G]=null, [% 64QAM 4G]=null,
	[RBs]=null,[Max RBs]=null,[Min RBs]=null,[RBs When Allocated]=null,	[Shared channel use]=null,
	[CQI 4G]=null,[CQI LTE2600]=null,[CQI LTE1800]=null,[CQI LTE800]=null,[CQI LTE2100]=null,
	[% TM Invalid]=null,[% TM 1: Single Antenna Port 0 ]=null,[% TM 2: TD Rank 1]=null,	[% TM 3: OL SM]=null,[% TM 4: CL SM]=null,[% TM 5: MU MIMO]=null,[% TM 6: CL RANK1 PC]=null,[% TM 7: Single Antenna Port 5]=null,[% TM Unknown]=null,
	EARFCN_N1=null,PCI_N1=null,	RSRP_N1=null,RSRQ_N1=null,
	num_HO_S1X2=null,duration_S1X2_avg=null,S1X2HO_SR=null,
	[% MIMO]=null,[% RI2_TM2]=null,[% RI2_TM3]=null,[% RI2_TM4]=null,
	[% RI1]=null,[% RI2]=null,
	Info_Update=isnull(Info_Update,'')+';15'	--Anular KPIS tecnologia 4G
where [% LTE]=0
	and testid > @maxTestid_UL

update Lcc_Data_HTTPBrowser
set [% QPSK 4G]=null,[% 16QAM 4G]=null,[% 64QAM 4G]=null, [% 256QAM 4G]=null,
	[% QPSK 4G PCC]=null,[% 16QAM 4G PCC]=null,[% 64QAM 4G PCC]=null,[% 256QAM 4G PCC]=null,
	[RBs]=null,[Max RBs]=null,[Min RBs]=null,[RBs When Allocated]=null,	[Shared channel use]=null,
	[RBs PCC]=null, [Max RBs PCC]=null, [Min RBs PCC]=null, [RBs When Allocated PCC]=null,
	[% MIMO]=null,[% RI2_TM2]=null,[% RI2_TM3]=null,[% RI2_TM4]=null,
	[% MIMO_PCC]=null,[% RI2_TM2_PCC]=null,[% RI2_TM3_PCC]=null,[% RI2_TM4_PCC]=null,
	[% RI1]=null,[% RI2]=null,
	[% RI1_PCC]=null,[% RI2_PCC]=null,
	[CQI 4G]=null,
	[CQI 4G PCC]=null,[CQI LTE2600 PCC]=null,[CQI LTE1800 PCC]=null,[CQI LTE800 PCC]=null,[CQI LTE2100 PCC]=null,
	EARFCN_N1=null,PCI_N1=null,	RSRP_N1=null,RSRQ_N1=null,
	num_HO_S1X2=null,duration_S1X2_avg=null,S1X2HO_SR=null,
	Info_Update=isnull(Info_Update,'')+';15'	--Anular KPIS tecnologia 4G
where [% LTE]=0
	and testid > @maxTestid_BR


--Test sin 3G
update Lcc_Data_HTTPTransfer_DL
set RLC_MAX=null,	
	[% QPSK 3G]=null,[% 16QAM 3G]=null,[% 64QAM 3G]=null,		
	[Num Codes]=null,[Max Codes]=null,	
	[CQI 3G]=null,[CQI UMTS900]=null,[CQI UMTS2100]=null,
	[% SCCH]=null,[Procesos HARQ]=null,	
	[BLER DSCH]=null,[DTX DSCH]=null,[ACKs]=null,[% NACKs]=null,			
	[Retrx DSCH]=null,[RETRX MAC]=null,												
	[BLER RLC]=null,[RLC Thput]=null,
	UL_Interference=null,
	Info_Update=isnull(Info_Update,'')+';16'	--Anular KPIS tecnologia 3G
where [% WCDMA]=0
	and testid > @maxTestid_DL

update Lcc_Data_HTTPTransfer_UL
set RLC_MAX=null,
	[% SF22]=null,	[% SF22andSF42]=null,	[% SF4]=null,	[% SF42]=null,[% TTI 2ms]=null,
	[CQI 3G]=null,[CQI UMTS900]=null,[CQI UMTS2100]=null,
	[HappyRate]=null, 	[Happy Rate MAX]=null,[Serving Grant]=null, 	
	[DTX]=null,	[avg TBs size]=null,
	[% SHO]=null,	[ReTrx PDU]=null,
	UL_Interference=null,
	Info_Update=isnull(Info_Update,'')+';16'	--Anular KPIS tecnologia 3G
where [% WCDMA]=0
	and testid > @maxTestid_UL

update Lcc_Data_HTTPBrowser
set [% QPSK 3G]=null,[% 16QAM 3G]=null,[% 64QAM 3G]=null,		
	[Num Codes]=null,[Max Codes]=null,	
	[CQI 3G]=null,[CQI UMTS900]=null,[CQI UMTS2100]=null,
	[% SCCH]=null,[Procesos HARQ]=null,	
	[BLER DSCH]=null,[DTX DSCH]=null,[ACKs]=null,[% NACKs]=null,			
	[Retrx DSCH]=null,								
	[BLER RLC]=null,[RLC Thput]=null,
	Info_Update=isnull(Info_Update,'')+';16'	--Anular KPIS tecnologia 3G
where [% WCDMA]=0
	and testid > @maxTestid_BR
-------------------------------------------------------------------------------------------------------------------------------------
--DGP 07/09/2017
-- Invalidación para datos CE (DL/UL) en los que los KPIID no calculan bien el dataTransferred y el Thput de algunas medidas.
-------------------------------------------------------------------------------------------------------------------------------------
--DL
update testinfo
set valid=0, invalidReason='LCC Wrong Thput/DT Issue'
from Lcc_Data_HTTPTransfer_DL d, testinfo t
where t.testid=d.testid
and t.valid=1
and d.datatransferred<2900000
and d.testtype='DL_CE'
and d.testid > @maxTestid

--UL
update testinfo
set valid=0, invalidReason='LCC Wrong Thput/DT Issue'
from Lcc_Data_HTTPTransfer_UL u, testinfo t
where t.testid=u.testid
and t.valid=1
and u.datatransferred<900000
and u.testtype='UL_CE'
and u.testid > @maxTestid

--****************************************************************************************************


--****************************************************************************************************
-- ******************************		 BORRADO de Tablas intermedias	******************************
--****************************************************************************************************
------------------
---- Tablas antiguas:
drop table #maxTestID,
	_TECH_RADIO_AVG_Data, _TECH_RADIO_INI_Data, _TECH_RADIO_FIN_Data,
	_test_Operator,_intervalos,_intervalos_all,
	_lcc_Serving_Cell_Table_info,_lcc_Serving_Cell_Table_info_acotada_acc,_lcc_Serving_Cell_Table_info_acotada,
	_Serving_Info_acotado,_Serving_Info_acotado_acc,_Serving_Info,
	_lcc_BandWidth_Carriers,_lcc_BandWidth_Table_duration_Data,_BW_RADIO_DURATION_Data,_BW_RADIO_DURATION_Data_acotada_all,_BW_RADIO_DURATION_Data_acotada,
	_BW_acotado,_BW_acotado_acc,_BW,
	_MOD_3G_id,_MOD_3G_duration,_MOD_3G_duration_acotada,_MOD_3G_duration_acotada_acc,
	_MOD_3G_acotado,_MOD_3G_acotado_acc,_MOD_3G,
	_PCT_TECH_Data_acotado,_PCT_TECH_Data_acotado_acc,_PCT_TECH_Data,
	_RBs_carrier_DL,_RBs_DL,_RBs_UL,_MOD_4G,_Carrier,_TM_DL,
	_SCC_CQI,_PUCCHCQI_4G,_PUCCHCQI_4G_Duration,_PUCCHCQI_4G_Duration_acotada,_PUCCHCQI_4G_Duration_acotada_all,
	_CQI_4G_acotado,_CQI_4G_acotado_acc,
	_TM_UL_acotado,_TM_UL_acotado_acc,
	_CQI_3G_id,_CQI_3G_all,_CQI_3G_duration_acotada,_CQI_3G_duration_acotada_all,
	_CQI_3G_acotado,_CQI_3G_acotado_acc,
	_SCCH_USE_3G,_HARQ,_ULMAC,_tSF,_SF,_SHOs,_UL_Int,
	_tempStateRCC,_stateRCC,
	_THPUT_RLC,_THPUT,
	_lcc_gets,_lcc_200,_lcc_ip_service,
	_THPUT_Transf,_THPUT_Transf_NC,
	_ETSIYouTubeKPIs,_lcc_ResultsKPI,_lcc_ResultsKPI_DNSTime,
	_lcc_http_DL,_lcc_http_UL,_lcc_http_browser,_lcc_http_latencias,
	_Paging,_PDP,
	_NEIGH,_4GHO,_Window,_BUFFER,
	_Tech_Duration_Distribution_acotado_Serv,_Tech_Duration_Distribution_acotado_acc_Serv,_Tech_Duration_Distribution_acotado,_Tech_Duration_Distribution_acotado_acc,
	_Syn_HS,_Syn_Ack_HS,_TCP_3WAY_HANDSHAKE,
	_tech_INI_PCC,_tech_FIN_PCC,_tech_INI_SCC1,_tech_FIN_SCC1,_tech_INI_SCC2,_tech_FIN_SCC2,_tech_Carriers,
	_URAstate,_URA,_VALIDABLE_WEB

exec sp_lcc_dropifexists '_ResultsVq06TimeDom_ord'
exec sp_lcc_dropifexists '_ResultsVQ08ClipAvg'
exec sp_lcc_dropifexists '_ResultsVideoStreamAvg'
exec sp_lcc_dropifexists '_resolutionYTB' 
exec sp_lcc_dropifexists '_vResolutionInfo'



