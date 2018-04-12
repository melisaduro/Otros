--USE [master]
--GO
--/****** Object:  StoredProcedure [dbo].[sp_lcc_create_TableVoice_FY1617]    Script Date: 15/12/2017 9:39:48 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--CREATE procedure [dbo].[sp_lcc_create_TableVoice_FY1718] 
--as
exec dbo.sp_lcc_DropIfExists '_SQNS'
exec dbo.sp_lcc_DropIfExists '_SQNS_SD'
exec dbo.sp_lcc_DropIfExists '_SQNS_DD'
exec dbo.sp_lcc_DropIfExists '_tMOS'
exec dbo.sp_lcc_DropIfExists '_codec'
exec dbo.sp_lcc_DropIfExists '_MOS_ALL'
exec dbo.sp_lcc_DropIfExists '_MOS_DL'
exec dbo.sp_lcc_DropIfExists '_MOS_UL'
exec dbo.sp_lcc_DropIfExists '_TECH_INI_FIN'
exec dbo.sp_lcc_DropIfExists '_TECH_RADIO_AVG_A' 
exec dbo.sp_lcc_DropIfExists '_TECH_RADIO_ini_A' 
exec dbo.sp_lcc_DropIfExists '_TECH_RADIO_FIN_A'
exec dbo.sp_lcc_DropIfExists '_TECH_RADIO_AVG_B'
exec dbo.sp_lcc_DropIfExists '_TECH_RADIO_ini_B'
exec dbo.sp_lcc_DropIfExists '_TECH_RADIO_FIN_B'
exec dbo.sp_lcc_DropIfExists '_Disconnect' 
exec dbo.sp_lcc_DropIfExists '_Disconnect_EVENT'
exec dbo.sp_lcc_DropIfExists '_DURATION_MAIN'
exec dbo.sp_lcc_DropIfExists '_DURATION_MAIN_Technology'
exec dbo.sp_lcc_DropIfExists '_TECH_Technology_DURATION_A'
exec dbo.sp_lcc_DropIfExists '_TECH_Technology_DURATION_B'
exec dbo.sp_lcc_DropIfExists '_TECH_AVG_A'
exec dbo.sp_lcc_DropIfExists '_TECH_AVG_B' 
exec dbo.sp_lcc_DropIfExists '_HOs'
exec dbo.sp_lcc_DropIfExists '_HO'
exec dbo.sp_lcc_DropIfExists '_HO_B'
exec dbo.sp_lcc_DropIfExists '_GSM_NEIGHBOR'
exec dbo.sp_lcc_DropIfExists '_GSM_NEIGHBOR_B'
exec dbo.sp_lcc_DropIfExists '_GSM_N_TOP1'
exec dbo.sp_lcc_DropIfExists '_GSM_N_TOP1_B'
exec dbo.sp_lcc_DropIfExists '_WCDMA_NEIGHBOR'
exec dbo.sp_lcc_DropIfExists '_WCDMA_NEIGHBOR_B'
exec dbo.sp_lcc_DropIfExists '_WCDMA_N_TOP1'
exec dbo.sp_lcc_DropIfExists '_WCDMA_N_TOP1_B'
exec dbo.sp_lcc_DropIfExists '_TECH_GSM_DURATION_A'
exec dbo.sp_lcc_DropIfExists '_TECH_GSM_DURATION_B'
exec dbo.sp_lcc_DropIfExists '_TECH_UMTS_DURATION_A'
exec dbo.sp_lcc_DropIfExists '_TECH_UMTS_DURATION_B'
exec dbo.sp_lcc_DropIfExists '_position_alt' 
exec dbo.sp_lcc_DropIfExists '_position_end_A'
exec dbo.sp_lcc_DropIfExists '_position_end_B'
exec dbo.sp_lcc_DropIfExists '_position_ini_A'
exec dbo.sp_lcc_DropIfExists '_position_ini_B' 
exec dbo.sp_lcc_DropIfExists '_RRC_StartA'
exec dbo.sp_lcc_DropIfExists '_Alert_Connect_AB'
exec dbo.sp_lcc_DropIfExists '_CST_ALL'
exec dbo.sp_lcc_DropIfExists '_RRC_StartC' 
exec dbo.sp_lcc_DropIfExists '_RRC_StartC_10109'
exec dbo.sp_lcc_DropIfExists '_VOLTE_StartA' 
exec dbo.sp_lcc_DropIfExists '_VOLTE_StartC' 
exec dbo.sp_lcc_DropIfExists '_FAST_RETURN_MAIN'
exec dbo.sp_lcc_DropIfExists '_FAST_RETURN' 
exec dbo.sp_lcc_DropIfExists '_VOICE_EVENT_FREQ' 
exec dbo.sp_lcc_DropIfExists '_VOICE_EVENT_TIME' 
exec dbo.sp_lcc_DropIfExists '_TECH_LTE_DURATION_A'
exec dbo.sp_lcc_DropIfExists '_TECH_LTE_DURATION_B' 
exec dbo.sp_lcc_DropIfExists '_VOLTE_StartAB'
exec dbo.sp_lcc_DropIfExists '_VOLTE_StartCB'
exec dbo.sp_lcc_DropIfExists '_tCallRes' 
exec dbo.sp_lcc_DropIfExists '_RRC' 
exec dbo.sp_lcc_DropIfExists '_RRCB' 
exec dbo.sp_lcc_DropIfExists '_RRC_VOLTE' 
exec dbo.sp_lcc_DropIfExists '_RRCB_VOLTE' 

exec dbo.sp_lcc_DropIfExists '_RTP'
exec dbo.sp_lcc_DropIfExists '_RTP_B'
exec dbo.sp_lcc_DropIfExists '_Paging'
exec dbo.sp_lcc_DropIfExists '_Paging_B'
exec dbo.sp_lcc_DropIfExists '_PDP'
exec dbo.sp_lcc_DropIfExists '_PDP_B'
exec dbo.sp_lcc_DropIfExists '_LTE_NEIGHBOR'
exec dbo.sp_lcc_DropIfExists '_SRVCC'
exec dbo.sp_lcc_DropIfExists '_SRVCC_B'
exec dbo.sp_lcc_DropIfExists '_IRAT_HO'
exec dbo.sp_lcc_DropIfExists '_IRAT_HO_B'
exec dbo.sp_lcc_DropIfExists '_4GHO'
exec dbo.sp_lcc_DropIfExists '_4GHO_B'

exec dbo.sp_lcc_DropIfExists '_CSFB_StartA_B'
exec dbo.sp_lcc_DropIfExists '_CSFB_StartA_A'
exec dbo.sp_lcc_DropIfExists '_CSFB_StartU_B'
exec dbo.sp_lcc_DropIfExists '_CSFB_StartU_A'
exec dbo.sp_lcc_DropIfExists '_cRespons_Side'
exec dbo.sp_lcc_DropIfExists '_LTE_Return'

exec dbo.sp_lcc_DropIfExists '_call_info'
exec dbo.sp_lcc_DropIfExists '_info_calls'
exec dbo.sp_lcc_DropIfExists '_type_Calls'
exec dbo.sp_lcc_DropIfExists '_lcc_Serving_Cell_Table_info_interval'

exec dbo.sp_lcc_DropIfExists '_ROAMING_MAIN'
exec dbo.sp_lcc_DropIfExists '_ROAMING'


-- **********************************************************************************************************************************************	
--
--		Código que crea la tabla de Voz:
--				lcc_calls_detailed
--		Esta tabla contiene la info a nivel de Sessionid, es decir, agrupando todo a nivel de llamada.
--		Se tiene en cuenta el campo s.Valid de la tabla Sessions para INVALIDAR las llamadas a nivel de SESSIONID.
--
--		(1) MOS TEMPORARY TABLE:		-		_tMOS
--												_MOS_ALL	
--												_MOS_DL
--												_MOS_UL
--												_SQNS
--			Tablas involucradas:
--				dbo.ResultsLQ08Avg
--				TestInfo
--				NetworkInfo
--		Se saca la info de los niveles de MOS en NB y WB a nivel de Testid (_tMos) y después se calculan los agregados
--		a nivel de Sessionid para la llamadas, con agregados de nivel, por tecnología e histogramas de nivel.
--		Sacamos las muestras dependiendo del BandWidth (0 = NarrowBand, 1 = WideBand, 2 = Super WideBand).
--		También se saca el SQNS de cada llamada (=1 si hay), info mas detallada en el Bloque de SQNS.
--
--		(2) CODECS TEMPORARY TABLE:		-		_codec
--			Tabla involucrada:
--				VoiceCodecTest
--		Se saca la info de uso de codec a nivel de llamada, con agrupación por codec.
--
--		(3) TECHNOLOGY TEMPORARY TABLE:	-		_TECH_RADIO_AVG
--												_TECH_RADIO_INI
--												_TECH_RADIO_FIN
--												_DURATION_MAIN 
--												_TECH_AVG  
--												_DURATION_MAIN_Technology
--			
--			Tablas involucradas:
--				lcc_serving_cell_table <-- (plcc_create_Serving_cell_Table) Tabla que contiene la info de la serving Cell y algunos parametros mas por instante de tiempo.
--				NetworkInfo
--				NetworkIdRelation
--		Se saca la info Radio de las llamadas con niveles de señal y calidad por tecnología por llamada, así como
--		histogramas de los niveles de calidad. (_TECH_RADIO_AVG, _TECH_RADIO_INI, _TECH_RADIO_FIN).
--		Se saca el tiempo que se ha estado en cada tecnología por llamada para sacar los estadísticos. (_DURATION_MAIN, _TECH_AVG). 15/12/2017: Cambio en las duraciones de las llamadas
--		
--		Actualización FY1718_H2: Se modifica el criterio para calcular las siguientes tablas:
--				_TECH_RADIO_INI: Para obtener la tecnología de inicio nos quedamos con el instante anterior más cercano a los siguientes eventos:
--									Si la llamada es CSFB: antes de Extended SR
--									Si la llamada es VOLTE,SRVCC o VOLTE_HO: antes del Trying 
--									Si la llamada se produce en 3G/2G: antes del CMServiceRequest o el CallConfirmed(el otro lado de la llamada)
--									Si no tenemos ninguno de estos eventos, nos quedamos con la primera muestra de la Serving Cell Table. 
--				_TECH_RADIO_FIN: Para obtener la tecnología de fin nos quedamos con el tiempo anterior más cercano a los siguientes eventos:
--									Si la llamada es VOLTE: antes del Disconnect VOLTE de la llamada
--									Si la llamada no es VOLTE: antes del Disconnect de la llamada
--									Si no tenemos Disconnect, nos quedamos con la última muestra de la serving cell 
--				_TECH_RADIO_AVG: Cogemos los instantes entre el inicio de la _TECH_RADIO_INI y el fin de la _TECH_RADIO_FIN de la llamada
--
--		(4) HANDOVERS TEMPORARY TABLE:	-		_HOs
--			Tablas involucradas:
--				vresultskpi
--				Sessions
--		Se saca la info de cantidad de HOs por llamada, agrupados por tipo y media de tiempo de HO.
--
--		Actualización FY1718_H2: Acotamos los instantes donde se calcula los HANDOVERs, para diferenciarlos de reselecciones.
--									Instante posterior al Dial y anterior al Disconnect de cada llamada
--
--		(5) NEIGHBORS TEMPORARY TABLE:	-		_GSM_NEIGHBOR
--												_GSM_N_TOP1
--												_WCDMA_NEIGHBOR
--												_WCDMA_N_TOP1
--			Tablas involucradas:
--				MsgGSMLayer1
--				CallAnalysis
--				WcdmaMeasReport
--		Se saca la info del top 1 de las vecinas por tecnología en los últimos 5 segundos de la llamada
--		organizándolas por cercanía temporal al final de la llamada y nivel de señal.

--		Actualización FY1718_H2: Acotamos los instantes donde se calcula las vecinas.
--								 Instante posterior al Dial y anterior al Disconnect de cada llamada
--
--		(6) POSITION TEMPORARY TABLE:	-		_position_alt
--												_position_ini_A
--												_position_ini_B
--												_position_end_A
--												_position_end_B
--			Tablas involucradas:
--				Position
--				Sessions
--				SessionsB
--		Se saca la info inicial y final por sesion de cada llamada tanto del lado A como del B
--		en caso de llamadas M2M.
--
--		(7) CST TEMPORARY TABLE:		-		_CST_ALL
--												_Dial_RRC_DurationA
--												_RRC_Alerting_DurationA
--												_Dial_RRC_DurationB
--												_RRC_Alerting_DurationB
--												_Alert_Discon_DurationAB
--												_Connect_Discon_DurationAB
--			Tablas involucradas:
--				vResultsKPI
--				CallAnalysis
--		Se saca la duración de cada evento involucrado en el proceso de setup de la llamada
--		para poder calcular los distintos tiempos.
--		Actualización FY1718_H2: Calculamos los tiempos del CST en función de los Markers (no usamos el KPIID)
--								 Dependiento de si es M2M/M2F y el tipo de llamada CS/VOLTE. 
--
--
--		(8) FAST RETURN TEMPORARY TABLE:		-		_FAST_RETURN
--												
--			Tablas involucradas:
--				vlcc_layer3
--				WCDMARRCMessages
--				vResultsKPI
--		Se saca la duración de cada Fast Return tras la llamada. así como las sesiones en las que pasa de 3G a 4G.
--		También se saca la frecuencia a la que se pasa.
--
--		(9) ROAMING TEMPORARY TABLE:		   -        _ROAMING
--
--			Tablas involucradas:
--				lcc_serving_cell_table
--				CallAnalysis
--				vResultsKPI
--				sessions
--		Se saca la duración y el porcentaje de Roaming de la llamada a partir de las columnas Operator y Serving Operator de la tabla Serving_Cell_Info
--		Las duraciones se extraen igual que la tecnología, para que existan coherencia en los datos.
--		drop table [lcc_calls_detailed]
--
-- **********************************************************************************************************************************************	

-- Se inicializa el plugin para decodificar de capa 3
exec SQKeyValueInit 'C:\L3KeyValue'

if (select name from sys.all_objects where name='lcc_calls_detailed' and type='U') is null
BEGIN
	--------
	-- We create the table from the beginning
	--------
select 'Created lcc_calls_detailed from the Beginning' info
CREATE TABLE [dbo].[lcc_calls_detailed](	
	[MTU] [char](10) NULL,
	[Sessionid] [bigint] NOT NULL,
	[Fileid] [bigint] NOT NULL,
	[NetworkId] [bigint] NULL,
	[CollectionName] [varchar](100) NULL,
	[ASideFileName] [varchar](100) NULL,
	[BSideFileName] [varchar](100) NULL,
	[IMEI] [varchar](50) NULL,
	[IMSI] [varchar] (50) NULL,
	[MCC] [varchar](3) NULL,
	[MNC] [varchar](2) NULL,
	[calltype] [varchar](5) NULL,
	[callDir] [varchar](2) NOT NULL,
	[callStatus] [varchar](50) NULL,
	[codeDescription] [varchar](255) NULL,
	[disconcause] [varchar](100) NULL,
	[disconlocation] [varchar](100) NULL,
	[Silent_call] [int] NOT NULL,
	[CR_Affected_calls] [Int] NULL,
	
--  Tecnología y banda
	[Technology] [varchar](50) NULL,
	[StartTechnology] [varchar](50) NULL,
	[EndTechnology] [varchar](50) NULL,
	[Average_Technology] [varchar](4) NULL,
	[Technology_B] [varchar](50) NULL,
	[StartTechnology_B] [varchar](50) NULL,
	[EndTechnology_B] [varchar](50) NULL,
	[Average_Technology_B] [varchar](50) NULL,
	
	[Band] [varchar](50) NULL,
	
--  Tecnología y frecuencia a la que se conecta en cada uno de los eventos de llamada
	[CSFB_freq] [int] NULL,
	[CSFB_band] [varchar](max) NULL,
	[Trying_freq] [int] NULL,
	[Trying_band] [varchar](max) NULL,
	[CMService_freq] [int] NULL,
	[CMService_Band] [varchar](max) NULL,
	[Alerting_freq] [int] NULL,
	[Alerting_Band] [varchar](max) NULL,
	[Connect_freq] [int] NULL,
	[Connect_Band] [varchar](max) NULL,
	[Disconnect_freq] [int] NULL,
	[Disconnect_Band] [varchar](max) NULL,
	[CSFB_freq_B] [int] NULL,
	[CSFB_band_B] [varchar](max) NULL,
	[Trying_freq_B] [int] NULL,
	[Trying_band_B] [varchar](max) NULL,
	[CMService_freq_B] [int] NULL,
	[CMService_Band_B] [varchar](max) NULL,
	[Alerting_freq_B] [int] NULL,
	[Alerting_Band_B] [varchar](max) NULL,
	[Connect_freq_B] [int] NULL,
	[Connect_Band_B] [varchar](max) NULL,
	[Disconnect_freq_B] [int] NULL,
	[Disconnect_Band_B] [varchar](max) NULL,
	
--  Duraciones totales y por banda
	[callStartTimeStamp] [datetime] NULL,
	[callEndTimeStamp] [datetime] NULL,
	[callDuration] [numeric](17, 6) NULL,
	
	[GSM_duration] [numeric](26, 6) NULL,
	[UMTS_duration] [numeric](26, 6) NULL,
	[LTE_Duration] [numeric](26, 6) NULL,
	[LTE2600_Duration] [numeric](26, 6) NULL,
	[LTE2100_Duration] [numeric](26, 6) NULL,
	[LTE1800_Duration] [numeric](26, 6) NULL,
	[LTE800_Duration] [numeric](26, 6) NULL,
	[UMTS2100_Duration] [numeric](26, 6) NULL,
	[UMTS900_Duration] [numeric](26, 6) NULL,
	[GSMGSM_Duration] [numeric](26, 6) NULL,
	[GSMDCS_Duration] [numeric](26, 6) NULL,
	[GSM_duration_B] [numeric](26, 6) NULL,
	[UMTS_duration_B] [numeric](26, 6) NULL,
	[LTE_Duration_B] [numeric](26, 6) NULL,
	[UMTS2100_Duration_B] [numeric](26, 6) NULL,
	[UMTS900_Duration_B] [numeric](26, 6) NULL,
	[GSMGSM_Duration_B] [numeric](26, 6) NULL,
	[GSMDCS_Duration_B] [numeric](26, 6) NULL,
	[LTE2600_Duration_B] [numeric](26, 6) NULL,
	[LTE2100_Duration_B] [numeric](26, 6) NULL,
	[LTE1800_Duration_B] [numeric](26, 6) NULL,
	[LTE800_Duration_B] [numeric](26, 6) NULL,
	
--  Método
	[CallMethod] [varchar] (50) null,
	[is_CSFB] [int] NOT NULL,
	[is_SRVCC] [int] NOT NULL,
	[is_VOLTE] [int] NOT NULL,
	[is_VOLTE_HO] [int] NOT NULL,

	[CSFB_Device] [varchar](10) NULL,
	[SRVCC_Device] [varchar](10) NULL,
	[VOLTE_Device] [varchar](10) NULL,
	[VOLTE_HO_Device] [varchar](10) NOT NULL,
	
--  CST
	[cst_till_alerting] [int] NULL,
	[cst_till_connect] [int] NULL,
	[csfb_till_connRel] [int] NULL,
	[csfb_till_alerting] [int] NULL,
	
	[LTE_return] [int] NULL,
	
--	Posiciones
	[longitude_ini_A] [float] NULL,
	[latitude_ini_A] [float] NULL,
	[longitude_ini_B] [float] NULL,
	[latitude_ini_B] [float] NULL,
	[longitude_fin_A] [float] NULL,
	[latitude_fin_A] [float] NULL,
	[longitude_fin_B] [float] NULL,
	[latitude_fin_B] [float] NULL,
	
--	MOS total y por banda
	[MOS_NB] [float] NULL,
	[MOS_NB_DL] [float] NULL,
	[MOS_NB_UL] [float] NULL,
	[MOS_Samples_NB] [int] NULL,
	[MOS_1-1.5_NB] [int] NULL,
	[MOS_1.5-2_NB] [int] NULL,
	[MOS_2-2.1_NB] [int] NULL,
	[MOS_2.1-2.2_NB] [int] NULL,
	[MOS_2.2-2.3_NB] [int] NULL,
	[MOS_2.3-2.4_NB] [int] NULL,
	[MOS_2.4-2.5_NB] [int] NULL,
	[MOS_2.5-2.6_NB] [int] NULL,
	[MOS_2.6-2.7_NB] [int] NULL,
	[MOS_2.7-2.8_NB] [int] NULL,
	[MOS_2.8-2.9_NB] [int] NULL,
	[MOS_2.9-3_NB] [int] NULL,
	[MOS_3-3.1_NB] [int] NULL,
	[MOS_3.1-3.2_NB] [int] NULL,
	[MOS_3.2-3.3_NB] [int] NULL,
	[MOS_3.3-3.4_NB] [int] NULL,
	[MOS_3.4-3.5_NB] [int] NULL,
	[MOS_3.5-3.6_NB] [int] NULL,
	[MOS_3.6-3.7_NB] [int] NULL,
	[MOS_3.7-3.8_NB] [int] NULL,
	[MOS_3.8-3.9_NB] [int] NULL,
	[MOS_3.9-4_NB] [int] NULL,
	[MOS_4-4.5_NB] [int] NULL,
	[MOS_4.5-5_NB] [int] NULL,
	[MOS_WB] [float] NULL,
	[MOS_WB_DL] [float] NULL,
	[MOS_WB_UL] [float] NULL,
	[MOS_Samples_WB] [int] NULL,
	[MOS_1-1.5_WB] [int] NULL,
	[MOS_1.5-2_WB] [int] NULL,
	[MOS_2-2.1_WB] [int] NULL,
	[MOS_2.1-2.2_WB] [int] NULL,
	[MOS_2.2-2.3_WB] [int] NULL,
	[MOS_2.3-2.4_WB] [int] NULL,
	[MOS_2.4-2.5_WB] [int] NULL,
	[MOS_2.5-2.6_WB] [int] NULL,
	[MOS_2.6-2.7_WB] [int] NULL,
	[MOS_2.7-2.8_WB] [int] NULL,
	[MOS_2.8-2.9_WB] [int] NULL,
	[MOS_2.9-3_WB] [int] NULL,
	[MOS_3-3.1_WB] [int] NULL,
	[MOS_3.1-3.2_WB] [int] NULL,
	[MOS_3.2-3.3_WB] [int] NULL,
	[MOS_3.3-3.4_WB] [int] NULL,
	[MOS_3.4-3.5_WB] [int] NULL,
	[MOS_3.5-3.6_WB] [int] NULL,
	[MOS_3.6-3.7_WB] [int] NULL,
	[MOS_3.7-3.8_WB] [int] NULL,
	[MOS_3.8-3.9_WB] [int] NULL,
	[MOS_3.9-4_WB] [int] NULL,
	[MOS_4-4.5_WB] [int] NULL,
	[MOS_4.5-5_WB] [int] NULL,
	
	[MOS_GSM_Samples] [int] NULL,
	[MOS_DCS_Samples] [int] NULL,
	[MOS_UMTS_Samples] [int] NULL,
	[MOS_LTE_Samples] [int] NULL,
	[MOS_NB_GSM_AVG] [float] NULL,
	[MOS_NB_DCS_AVG] [float] NULL,
	[MOS_NB_UMTS_AVG] [float] NULL,
	[MOS_NB_LTE_AVG] [float] NULL,
	[MOS_NB_Samples_Under_2.5] [int] NULL,
	[MOS_WB_GSM_AVG] [float] NULL,
	[MOS_WB_DCS_AVG] [float] NULL,
	[MOS_WB_UMTS_AVG] [float] NULL,
	[MOS_WB_LTE_AVG] [float] NULL,
	[MOS_WB_Samples_Under_2.5] [int] NULL,
	
--  CAC 11/01/2017: Nuevos KPIs incorporados
	MOS_UMTS900_NB_AVG [float] NULL,
	MOS_UMTS900_WB_AVG [float] NULL,
	MOS_UMTS2100_NB_AVG [float] NULL,
	MOS_UMTS2100_WB_AVG [float] NULL,
	MOS_LTE800_NB_AVG [float] NULL,
	MOS_LTE800_WB_AVG [float] NULL,
	MOS_LTE1800_NB_AVG [float] NULL,
	MOS_LTE1800_WB_AVG [float] NULL,
	MOS_LTE2100_NB_AVG [float] NULL,
	MOS_LTE2100_WB_AVG [float] NULL,
	MOS_LTE2600_NB_AVG [float] NULL,
	MOS_LTE2600_WB_AVG [float] NULL,
	Samples_NB_GSM [int] NULL,
	Samples_WB_GSM [int] NULL,
	Samples_NB_DCS [int] NULL,
	Samples_WB_DCS [int] NULL,
	Samples_NB_UMTS900 [int] NULL,
	Samples_WB_UMTS900 [int] NULL,
	Samples_NB_UMTS2100 [int] NULL,
	Samples_WB_UMTS2100 [int] NULL,
	Samples_NB_LTE800 [int] NULL,
	Samples_WB_LTE800 [int] NULL,
	Samples_NB_LTE1800 [int] NULL,
	Samples_WB_LTE1800 [int] NULL,
	Samples_NB_LTE2100 [int] NULL,
	Samples_WB_LTE2100 [int] NULL,
	Samples_NB_LTE2600 [int] NULL,
	Samples_WB_LTE2600 [int] NULL,
	
--  SQNS
	[SNR] [float] NULL,
	[Speech_Delay] [float] NULL,
	[SQNS_NB] [int] NULL,
	[SQNS_WB] [int] NULL,
	[CodecName] [varchar](41) NULL,
	[Codec_Registers] [int] NULL,
	[HR_Count] [int] NULL,
	[FR_Count] [int] NULL,
	[EFR_Count] [int] NULL,
	[AMR_HR_Count] [int] NULL,
	[AMR_FR_Count] [int] NULL,
	[AMR_WB_Count] [int] NULL,
	[AMR_WB_HD_Count] [int] NULL,
	
--	HandOvers
	[Handovers] [int] NULL,
	[Handover_Failures] [int] NULL,
	[Handover_2G2G_Failures] [int] NULL,
	[Handover_2G3G_Failures] [int] NULL,
	[Handover_3G2G_Failures] [int] NULL,
	[Handover_3G3G_Failures] [int] NULL,
	[Handover_4G3G_Failures] [int] NULL,
	[Handover_4G4G_Failures] [int] NULL,
	[HOs_Duration_Avg] [int] NULL,
	
--	Parámetros Radio 2G
	[RxLev] [float] NULL,
	[RxQual] [float] NULL,
	[Hopping] [int] NULL,
	--[GSM_Samples] [int] NULL,
	--[DCS_Samples] [int] NULL,
	[RxQual_GSM] [float] NULL,
	[RxQual_DCS] [float] NULL,
	--[RxQual_samples] [int] NULL,
	[RxQual_0] [int] NULL,
	[RxQual_1] [int] NULL,
	[RxQual_2] [int] NULL,
	[RxQual_3] [int] NULL,
	[RxQual_4] [int] NULL,
	[RxQual_5] [int] NULL,
	[RxQual_6] [int] NULL,
	[RxQual_7] [int] NULL,
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
	[RxLev_B] [float] NULL,
	[RxQual_B] [float] NULL,
	[Hopping_B] [int] NULL,
	--[GSM_Samples_B] [int] NULL,
	--[DCS_Samples_B] [int] NULL,
	[RxQual_GSM_B] [float] NULL,
	[RxQual_DCS_B] [float] NULL,
	--[RxQual_samples_B] [int] NULL,
	[RxQual_0_B] [int] NULL,
	[RxQual_1_B] [int] NULL,
	[RxQual_2_B] [int] NULL,
	[RxQual_3_B] [int] NULL,
	[RxQual_4_B] [int] NULL,
	[RxQual_5_B] [int] NULL,
	[RxQual_6_B] [int] NULL,
	[RxQual_7_B] [int] NULL,
	[BCCH_Ini_B] [int] NULL,
	[BSIC_Ini_B] [int] NULL,
	[RxLev_Ini_B] [real] NULL,
	[RxQual_Ini_B] [real] NULL,
	[BCCH_Fin_B] [int] NULL,
	[BSIC_Fin_B] [int] NULL,
	[RxLev_Fin_B] [real] NULL,
	[RxQual_Fin_B] [real] NULL,
	[RxLev_min_B] [real] NULL,
	[RxQual_min_B] [real] NULL,

	[N1_BCCH] [smallint] NULL,
	[N1_RxLev] [smallint] NULL,
	[N1_BCCH_B] [smallint] NULL,
	[N1_RxLev_B] [smallint] NULL,
	
--	Parámetros Radio 3G
	[RSCP] [float] NULL,
	[EcIo] [float] NULL,
	--[UMTS2100_Samples] [int] NULL,
	--[UMTS900_Samples] [int] NULL,
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
	[EcIo_UMTS2100] [float] NULL,
	[EcIo_UMTS900] [float] NULL,
	--[EcIo_samples] [int] NULL,
	[EcIo [0, -2)] [int] NULL,
	[EcIo [-2, -4)] [int] NULL,
	[EcIo [-4, -6)] [int] NULL,
	[EcIo [-6, -8)] [int] NULL,
	[EcIo [-8, -10)] [int] NULL,
	[EcIo [-10, -12)] [int] NULL,
	[EcIo [-12, -14)] [int] NULL,
	[EcIo <= -14] [int] NULL,
	[RSCP_B] [float] NULL,
	[EcIo_B] [float] NULL,
	--[UMTS2100_Samples_B] [int] NULL,
	--[UMTS900_Samples_B] [int] NULL,
	[PSC_Ini_B] [int] NULL,
	[RSCP_Ini_B] [real] NULL,
	[EcIo_Ini_B] [real] NULL,
	[UARFCN_Ini_B] [int] NULL,
	[PSC_Fin_B] [int] NULL,
	[RSCP_Fin_B] [real] NULL,
	[EcIo_Fin_B] [real] NULL,
	[UARFCN_Fin_B] [int] NULL,
	[RSCP_min_B] [real] NULL,
	[EcIo_min_B] [real] NULL,
	[EcIo_UMTS2100_B] [float] NULL,
	[EcIo_UMTS900_B] [float] NULL,
	--[EcIo_samples_B] [int] NULL,
	[EcIo [0, -2)_B] [int] NULL,
	[EcIo [-2, -4)_B] [int] NULL,
	[EcIo [-4, -6)_B] [int] NULL,
	[EcIo [-6, -8)_B] [int] NULL,
	[EcIo [-8, -10)_B] [int] NULL,
	[EcIo [-10, -12)_B] [int] NULL,
	[EcIo [-12, -14)_B] [int] NULL,
	[EcIo <= -14_B] [int] NULL,
	
	[N1_PSC] [smallint] NULL,
	[N1_RSCP] [int] NULL,
	[N1_PSC_B] [smallint] NULL,
	[N1_RSCP_B] [int] NULL,
	
--	Parámetros Radio 4G
	[RSRP] [float] NULL,
	[RSRQ] [float] NULL,
	[SINR] [float] NULL,
	--[LTE800_Samples] [int] NULL,
	--[LTE1800_Samples] [int] NULL,
	--[LTE2600_Samples] [int] NULL,
	[PCI_Ini] [int] NULL,
	[RSRP_Ini] [real] NULL,
	[RSRQ_Ini] [real] NULL,
	[SINR_ini] [float] NULL,
	[EARFCN_Ini] [int] NULL,
	[PCI_Fin] [int] NULL,
	[RSRP_Fin] [real] NULL,
	[RSRQ_Fin] [real] NULL,
	[SINR_fin] [float] NULL,
	[EARFCN_Fin] [int] NULL,
	[CellId_Ini] [int] NULL,
	[LAC/TAC_Ini] [int] NULL,
	[RNC_Ini] [int] NULL,
	[CellId_Fin] [int] NULL,
	[LAC/TAC_Fin] [int] NULL,
	[RNC_Fin] [int] NULL,
	[RTP_Jitter_DL] [float] NULL,
	[RTP_Jitter_UL] [float] NULL,
	[RTP_Delay_DL] [float] NULL,
	[RTP_Delay_UL] [float] NULL,
	[Paging_Success_Ratio] [float] NULL,
	[PDP_Activate_Ratio] [float] NULL,
	[EARFCN_N1] [int] NULL,
	[PCI_N1] [int] NULL,
	[RSRP_N1] [real] NULL,
	[RSRQ_N1] [real] NULL,
	[SRVCC_SR] [float] NULL,
	[IRAT_HO2G3G_Ratio] [float] NULL,
	[num_HO_S1X2] [int] NULL,
	[duration_S1X2_avg] [float] NULL,
	[S1X2HO_SR] [float] NULL,
	[RSRP_B] [float] NULL,
	[RSRQ_B] [float] NULL,
	[SINR_B] [float] NULL,
	--[LTE800_Samples_B] [int] NULL,
	--[LTE1800_Samples_B] [int] NULL,
	--[LTE2600_Samples_B] [int] NULL,
	[PCI_Ini_B] [int] NULL,
	[RSRP_Ini_B] [real] NULL,
	[RSRQ_Ini_B] [real] NULL,
	[SINR_Ini_B] [float] NULL,
	[EARFCN_Ini_B] [int] NULL,
	[PCI_Fin_B] [int] NULL,
	[RSRP_Fin_B] [real] NULL,
	[RSRQ_Fin_B] [real] NULL,
	[SINR_Fin_B] [float] NULL,
	[EARFCN_Fin_B] [int] NULL,
	[CellId_Ini_B] [int] NULL,
	[LAC/TAC_Ini_B] [int] NULL,
	[RNC_Ini_B] [int] NULL,
	[CellId_Fin_B] [int] NULL,
	[LAC/TAC_Fin_B] [int] NULL,
	[RNC_Fin_B] [int] NULL,
	[RTP_Jitter_DL_B] [float] NULL,
	[RTP_Jitter_UL_B] [float] NULL,
	[RTP_Delay_DL_B] [float] NULL,
	[RTP_Delay_UL_B] [float] NULL,
	[Paging_Success_Ratio_B] [float] NULL,
	[PDP_Activate_Ratio_B] [float] NULL,
	[EARFCN_N1_B] [int] NULL,
	[PCI_N1_B] [int] NULL,
	[RSRP_N1_B] [real] NULL,
	[RSRQ_N1_B] [real] NULL,
	[SRVCC_SR_B] [float] NULL,
	[IRAT_HO2G3G_Ratio_B] [float] NULL,
	[num_HO_S1X2_B] [int] NULL,
	[duration_S1X2_avg_B] [float] NULL,
	[S1X2HO_SR_B] [float] NULL,
	
	[Fast_Return_Duration] [numeric](17, 6) NULL,
	[Fast_Return_Freq_Dest] [varchar](max) NULL,	
	
--	Información Roaming total y por banda
	[Roaming_VF] [float] NULL,
	[Roaming_MV] [float] NULL,
	[Roaming_OR] [float] NULL,
	[Roaming_YO] [float] NULL,
	[Roaming_GSM] [float] NULL,
	[Roaming_DCS] [float] NULL,
	[Roaming_U900] [float] NULL,
	[Roaming_U2100] [float] NULL,
	[Roaming_LTE800] [float] NULL,
	[Roaming_LTE1800] [float] NULL,
	[Roaming_LTE2100] [float] NULL,
	[Roaming_LTE2600] [float] NULL,
	[Duration_roaming_VF] [numeric](26, 6) NULL,
	[Duration_roaming_MV] [numeric](26, 6) NULL,
	[Duration_roaming_OR] [numeric](26, 6) NULL,
	[Duration_roaming_YO] [numeric](26, 6) NULL,
	[Duration_roaming_GSM] [numeric](26, 6) NULL,
	[Duration_roaming_DCS] [numeric](26, 6) NULL,
	[Duration_roaming_U900] [numeric](26, 6) NULL,
	[Duration_roaming_U2100] [numeric](26, 6) NULL,
	[Duration_roaming_LTE800] [numeric](26, 6) NULL,
	[Duration_roaming_LTE1800] [numeric](26, 6) NULL,
	[Duration_roaming_LTE2100] [numeric](26, 6) NULL,
	[Duration_roaming_LTE2600] [numeric](26, 6) NULL,
	[Roaming_VF_B] [float] NULL,
	[Roaming_MV_B] [float] NULL,
	[Roaming_OR_B] [float] NULL,
	[Roaming_YO_B] [float] NULL,
	[Roaming_GSM_B] [float] NULL,
	[Roaming_DCS_B] [float] NULL,
	[Roaming_U900_B] [float] NULL,
	[Roaming_U2100_B] [float] NULL,
	[Roaming_LTE800_B] [float] NULL,
	[Roaming_LTE1800_B] [float] NULL,
	[Roaming_LTE2100_B] [float] NULL,
	[Roaming_LTE2600_B] [float] NULL,
	[Duration_roaming_VF_B] [numeric](26, 6) NULL,
	[Duration_roaming_MV_B] [numeric](26, 6) NULL,
	[Duration_roaming_OR_B] [numeric](26, 6) NULL,
	[Duration_roaming_YO_B] [numeric](26, 6) NULL,
	[Duration_roaming_GSM_B] [numeric](26, 6) NULL,
	[Duration_roaming_DCS_B] [numeric](26, 6) NULL,
	[Duration_roaming_U900_B] [numeric](26, 6) NULL,
	[Duration_roaming_U2100_B] [numeric](26, 6) NULL,
	[Duration_roaming_LTE800_B] [numeric](26, 6) NULL,
	[Duration_roaming_LTE1800_B] [numeric](26, 6) NULL,
	[Duration_roaming_LTE2100_B] [numeric](26, 6) NULL,
	[Duration_roaming_LTE2600_B] [numeric](26, 6) NULL,
	
	[valid] [tinyint] NULL,
	[invalidReason] [varchar](255) NULL,
	
	[ASideDevice] [nvarchar](256) NULL,
	[BSideDevice] [nvarchar](256) NULL,
	[SWVersion] [nvarchar](256) NULL,
	
	[Respons_Side] [nvarchar](256) NULL

	
)
END

BEGIN 

--------
-- We insert new fields in the table
--------
declare @maxSession as int=(select isnull(MAX(sessionid),0) from lcc_calls_detailed)
select 'Updated lcc_calls_detailed from session='+CONVERT(varchar(256),@maxSession)+' to Session='+CONVERT(varchar(256),(select max(sessionid) from CallAnalysis)) info


-- Se añade nuevo campo a partir de la version 16.1 (en versiones anteriores, no existe esta columna):
exec dbo.sp_lcc_DropIfExists '_cRespons_Side'
if (SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'side' AND TABLE_NAME = 'CallAnalysis') is not null
begin
	exec('select fileid, sessionid, callstatus, null as Respons_Side--side as Respons_Side
		  into _cRespons_Side
		  from [dbo].[CallAnalysis]
		  where SessionId>'+@maxSession
		  )
end
else
begin
	exec('select fileid, sessionid, callstatus, null as Respons_Side
		  into _cRespons_Side
		  from [dbo].[CallAnalysis]
		  where SessionId>'+@maxSession
		  )
end

----------------------------------------------------------------------

--	CRITERIO 1: 

--		Calculamos el momento de la llamada desde el inicio al fin (ResultsKPI/CallAnalysis), 
--		acotandolo al momento del intervalo de la Serving Table.

--		Con este criterio calculamos:
--				Duraciones/Duraciones por tecnología/Duraciones por banda
--				Roaming
--				Avg Tech (tecnología con mayor duración en cada llamada)

--		Se modifica el momento del disconnect a la tabla de Markers en el caso que no esté en resultsKPI. 
--		Como última condición sacaremos el disconnect de callAnalysis.

--		11/02/2018 MDM : Se modifican los intervalos de duración de las llamadas
--		Tabla _call_info: extrae la duración de los tiempos de llamadas
--			Llamadas tipo Fail: desde callstarttimestamp hasta calldisconnecttimestamp (tiempo de la ventana)
--			Resto llamadas: desde callsetupendtimestamp hasta calldisconnecttimestamp

----------------------------------------------------------------------
------------------- DURACIONES GSM, WCDMA, LTE ----------------

-- CAC 11/01/2017: Se cambia la forma de calcular para homogeneizarlo con la duracion total de la llamada que va desde
-- el Setup al Disconnect.
-- En llamadas completadas el disconnect lo cogemos del KPIID=20101 en el caso de que este calculado
-- (el diconnect de callanalysis no coincide con el de red, en MO es anterior y en MT es posterior)
-- Se modifica el cálculo para tener en cuenta el idMax por side y corregir las duraciones en el inicio-fin 
-- En el calculo de la parte B se quita el cruce con sessionsB ya que no devuelve nada (en lcc_serving_cell_table la info de la parte A se recoge con sessionidA)
-- Se añade el calculo desglosado por tecnología


--CAC 11/09/2017:
-- Se modifica 21010 (endTime - Request BYE) por 31101 (endTime - BYE OK)  para las LLamadas VOLTE
-- y se modifica criterio para llamadas de VOLTE que no cursan todo en VOLTE

--MDM 11/02/2018
--Se modifica el momento del disconnect a la tabla de Markers en el caso que no esté en resultsKPI. 
--Si no tenemos markers de Disconnect, tomamos el Release.
--En el caso de que no tengamos ningún Marker de Disconnect ni Release, vemos el parámetro callDisconnect de CallAnalysis.
--		Si este es menor que el setup cogemos la ultima muestra de MOS, en el caso que la haya.	  
--Como última condición sacaremos el disconnect de callAnalysis.


exec sp_lcc_dropifexists '_Disconnect'
select c.sessionid
	,case when kpi1.sessionid is not null and ((kpi1.Num_Reg=1 and kpi1.Num_KPIs=1) or (kpi1.Num_Reg=2 and kpi1.Num_KPIs=2)) then kpi1.endtime 
		  when callDir='A->B' and isnull(t.disconnect_time_A,t.disconnectvolte_time_A)>c.calldisconnecttimestamp then
			case when c.calldisconnecttimestamp>isnull(max_time_Mos,convert(datetime,0))
				 then c.calldisconnecttimestamp 
					else isnull(t.disconnect_time_A,t.disconnectvolte_time_A) end
		  when callDir='A->B' and isnull(t.disconnect_time_A,t.disconnectvolte_time_A)<c.calldisconnecttimestamp then
			case when isnull(t.disconnect_time_A,t.disconnectvolte_time_A)>isnull(max_time_Mos,convert(datetime,0))
				 then isnull(t.disconnect_time_A,t.disconnectvolte_time_A)
					else c.calldisconnecttimestamp end
		  when callDir='B->A' and isnull(t.disconnect_time_B,t.disconnectvolte_time_B)>c.calldisconnecttimestamp then
			case when c.calldisconnecttimestamp>isnull(max_time_Mos,convert(datetime,0)) 
				 then c.calldisconnecttimestamp
					else isnull(t.disconnect_time_B,t.disconnectvolte_time_B) end
		  when callDir='B->A' and isnull(t.disconnect_time_B,t.disconnectvolte_time_B)<c.calldisconnecttimestamp then
			case when isnull(t.disconnect_time_B,t.disconnectvolte_time_B)>isnull(max_time_Mos,convert(datetime,0))
				 then isnull(t.disconnect_time_B,t.disconnectvolte_time_B)
					else c.calldisconnecttimestamp end
		  --Si no tenemos markers de Disconnect, tomamos el Release
		  when t.Release_time < c.calldisconnecttimestamp then t.Release_time 
		  --En el caso de que no tengamos ningún Marker de Disconnect ni Release, vemos el parámetro callDisconnect de CallAnalysis.
		  --Si este es menor que el setup cogemos la ultima muestra de MOS, en caso que la haya.
		  when c.calldisconnecttimestamp < max_time_Mos and c.CallSetupEndTimeStamp>CallDisconnectTimeStamp then max_time_Mos 
		  --En el caso de que no se cumplan ninguna de las condiciones anteriores, tomamos el calldisconnect de callAnalysis
		  else c.calldisconnecttimestamp
	end as 'callDisconnectTimeStamp'
	,case when callDir='A->B' and isnull(t.connectAck_time_A,t.connectAckVOLTE_time_A)>c.callsetupendtimestamp then
		case when isnull(t.connectAck_time_A,t.connectAckVOLTE_time_A)<isnull(min_time_Mos,convert(datetime,0))
				then isnull(t.connectAck_time_A,t.connectAckVOLTE_time_A)
					else c.callsetupendtimestamp end
		  when callDir='A->B' and isnull(t.connectAck_time_A,t.connectAckVOLTE_time_A)<c.callsetupendtimestamp then
			case when c.callsetupendtimestamp<isnull(min_time_Mos,convert(datetime,0))
				then c.callsetupendtimestamp
					else isnull(t.connectAck_time_A,t.connectAckVOLTE_time_A) end
		  when callDir='B->A' and isnull(t.connectAck_time_B,t.connectAckVOLTE_time_B)>c.callsetupendtimestamp then
			case when isnull(t.connectAck_time_B,t.connectAckVOLTE_time_B)<isnull(min_time_Mos,convert(datetime,0))
				then isnull(t.connectAck_time_B,t.connectAckVOLTE_time_B)
					else c.callsetupendtimestamp end
		  when callDir='B->A' and isnull(t.connectAck_time_B,t.connectAckVOLTE_time_B)<c.callsetupendtimestamp then
			case when c.callsetupendtimestamp<isnull(min_time_Mos,convert(datetime,0))
				then c.callsetupendtimestamp
					else isnull(t.connectAck_time_B,t.connectAckVOLTE_time_B) end
		  else c.callsetupendtimestamp 
	end as 'CallSetupEndTimeStamp'
into  _Disconnect
from callanalysis c
	left join lcc_markers_time t on c.sessionid=t.sessionid
	left join ( --Si por sessionid tenemos mas de un registro, nos quedamos con el máximo
		select sessionid, max(endtime) as endtime,count(1) as 'Num_Reg',count(distinct kpiid) as 'Num_KPIs'
		from resultskpi
		where kpiid  in (20101,31101) and ErrorCode=0
		group by sessionid) kpi1
	on c.sessionid=kpi1.sessionid and c.callStatus = 'Completed' --Para llamadas fallidas el KPI no se calcula correctamente	
where c.SessionId>@maxSession


--********************************************************************************************************************
--11/02/2018 MDM : Se modifican los intervalos de duración de las llamadas
--Tabla _call_info: extrae la duración de los tiempos de llamadas
--Llamadas tipo Fail: desde callstarttimestamp hasta calldisconnecttimestamp (tiempo de la ventana)
--Resto llamadas: desde callsetupendtimestamp hasta calldisconnecttimestamp

--OLD: intervalo de llamadas desde callsetupendtimestamp hasta calldisconnecttimestamp para cualquier tipo de llamada

--Tabla _lcc_Serving_Cell_Table_info_interval: extrae la duración de los intervalos (a partir del msgtime de lcc_serving_cell_table)
--********************************************************************************************************************
------------------------------------------------
--Inicio/Fin llamada:
------------------------------------------------

exec sp_lcc_dropifexists '_call_info'
select c.sessionid, c.callstatus,
	c.callStartTimeStamp,
	disc.callsetupendtimestamp,
	case 
		when c.callstatus= 'Failed' and c.callstarttimestamp > disc.calldisconnecttimestamp then c.callstarttimestamp
		else disc.calldisconnecttimestamp
	end as 'callEndTimeStamp',
	case 
		when c.callstatus= 'Failed' then c.callstarttimestamp
		else disc.callsetupendtimestamp
	end as 'callStartDuration',
	case 
		when c.callstatus= 'Failed' and DATEDIFF(ms,c.callstarttimestamp, disc.calldisconnecttimestamp)/1000.0 >= 0
			then DATEDIFF(ms,c.callstarttimestamp, disc.calldisconnecttimestamp)/1000.0
		when c.callstatus= 'Failed' and DATEDIFF(ms,c.callstarttimestamp, disc.calldisconnecttimestamp)/1000.0 < 0
			then 0.0
		--Para el resto de llamadas extraemos la duracion de la ventana desde el callsetup hasta el disconnect
		when DATEDIFF(ms,disc.callsetupendtimestamp, disc.calldisconnecttimestamp)/1000.0 >= 0
			then DATEDIFF(ms,disc.callsetupendtimestamp, disc.calldisconnecttimestamp)/1000.0
		else DATEDIFF(ms,c.callsetupendtimestamp, disc.calldisconnecttimestamp)/1000.0
	end as 'callDuration'
into _call_info
from CallAnalysis c
	left join _Disconnect disc
	on c.sessionid=disc.sessionid 



--Calculamos la duración de los intervalos
------------------------------------------------
--Intervalo lado A/B:
------------------------------------------------

exec sp_lcc_dropifexists '_lcc_Serving_Cell_Table_info_interval'
select ini.SessionId, ini.MsgTime as time_ini,
	isnull(fin.MsgTime,case when c.callstatus= 'Failed' and c.callEndTimeStamp>DATEADD(ms, s.duration ,s.startTime) then c.callEndTimeStamp else DATEADD(ms, s.duration ,s.startTime)end) as time_fin,

	DATEDIFF(ms, ini.MsgTime , isnull(fin.MsgTime,case when c.callstatus= 'Failed' and c.callEndTimeStamp>DATEADD(ms, s.duration ,s.startTime) then c.callEndTimeStamp else DATEADD(ms, s.duration ,s.startTime)end)) as duration,
	ini.Freq,ini.ServingOperator,ini.Operator, ini.Band, ini.technology, ini.id,ini.TestId,ini.side,ini.idSide
into  _lcc_Serving_Cell_Table_info_interval
from lcc_serving_cell_table ini 
	inner join sessions s
	on (ini.sessionid = s.sessionid)
	inner join _call_info c
	on (ini.sessionid = c.sessionid)
	left join lcc_serving_cell_table fin
	on (ini.sessionid = fin.sessionid
		and ini.idSide = fin.idSide -1
		and ini.side=fin.side)
where ini.sessionid > @maxsession
order by 1, 2

--OLD
--select sc.sessionid,
--		sc.msgtime,
--		sc.technology,
--		sc.mnc,
--		c.callsetupendtimestamp,
--		d.callDisconnectTimeStamp,
--		sc.side,
--		row_number () over (partition by sc.sessionid, sc.side order by sc.msgtime) as id

--into _TECH_MAIN_Net
--from lcc_serving_cell_table sc, callanalysis c, _Disconnect d

--where c.sessionid=sc.sessionid
--and c.sessionid=d.sessionid
----and sc.msgtime between c.callstarttimestamp and c.callDisconnectTimeStamp
--and sc.msgtime between c.callsetupendtimestamp and d.callDisconnectTimeStamp	
--and sc.SessionId>@maxSession


--Sacamos la duración acotada, teniendo en cuenta los tiempos de los intervalos y el tiempo de llamada
exec sp_lcc_dropifexists '_DURATION_MAIN' ---_DURATION_MAIN
select c.sessionid,
		left(t.technology, 4) as technology, 
		t.side,
		sum(case when idSide=1 and callStartDuration <= time_ini and callEndTimeStamp >= time_fin  then DATEDIFF(ms,callStartDuration,time_fin) --Si el primer registro es posterior al start cogemos desde el start
			when idSide=1 and callStartDuration <= time_ini and callEndTimeStamp <= time_fin then callDuration*1000.0 --Si el primer registro es posterior al start y el fin es posterior
			when callStartDuration <= time_ini and time_fin <= callEndTimeStamp then t.duration
			when time_ini <= callStartDuration and callEndTimeStamp <= time_fin then callDuration*1000.0
			when time_ini <= callStartDuration and time_fin <= callEndTimeStamp then DATEDIFF(ms,callStartDuration,time_fin)
			when callStartDuration <= time_ini and callEndTimeStamp <= time_fin then DATEDIFF(ms,time_ini,callEndTimeStamp)
		end) as duration 
into _DURATION_MAIN
from  _call_info c
	left join _lcc_Serving_Cell_Table_info_interval t
		on c.SessionId = t.SessionId 
			and callStartDuration < time_fin
			and callEndTimeStamp > time_ini
group by c.sessionid, left(t.technology, 4), t.side


--OLD
--select ini.sessionid,
--		left(ini.technology, 4) as technology, 
--		ini.side,

----		--sum(case 
----		--	when ini.id=mx.maxid then datediff (ms, ini.msgtime, ini.callDisconnectTimeStamp)
----		--	else datediff (ms, ini.msgtime, fin.msgtime)
----		--	end) as duration 
--		sum(case 	
--			when ini.id=1 then datediff (ms, ini.callsetupendtimestamp, fin.msgtime)	
--			when ini.side='A' and ini.id=mxA.maxid then datediff (ms, ini.msgtime, ini.callDisconnectTimeStamp)	
--			when ini.side='B' and ini.id=mxB.maxid then datediff (ms, ini.msgtime, ini.callDisconnectTimeStamp)
--			else datediff (ms, ini.msgtime, fin.msgtime)
--		end) as duration 
--into _DURATION_MAIN
--from  
--	_TECH_MAIN_Net ini 
--	LEFT JOIN  _TECH_MAIN_Net fin
--		ON ini.sessionid=fin.sessionid and ini.id=fin.id-1 and ini.side=fin.side
--	left join 
--		(select sessionid, max(id) as maxid from _TECH_MAIN_Net where side='B' group by sessionid) mxB	
--	on mxB.sessionid=ini.sessionid,
--	(select sessionid, max(id) as maxid from _TECH_MAIN_Net where side='A' group by sessionid) mxA
--where mxA.sessionid=ini.sessionid
--group by ini.sessionid,	left(ini.technology, 4), ini.side

--Calculamos las duraciones acotadas
exec sp_lcc_dropifexists '_DURATION_MAIN_Technology' ---_DURATION_MAIN_Technology
select c.sessionid,
		t.technology as technology, 	
		t.side,
		sum(case when idSide=1 and callStartDuration <= time_ini and time_fin <= callEndTimeStamp then DATEDIFF(ms,callStartDuration,time_fin) --Si el primer registro es posterior al start cogemos desde el start
			when idSide=1 and callStartDuration <= time_ini and callEndTimeStamp <= time_fin then callDuration*1000.0 --Si el primer registro es posterior al start y el fin es posterior
			when callStartDuration <= time_ini and time_fin <= callEndTimeStamp then t.duration
			when time_ini <= callStartDuration and callEndTimeStamp <= time_fin then callDuration*1000.0
			when time_ini <= callStartDuration and time_fin <= callEndTimeStamp then DATEDIFF(ms,callStartDuration,time_fin)
			when callStartDuration <= time_ini and callEndTimeStamp <= time_fin then DATEDIFF(ms,time_ini,callEndTimeStamp)
		end) as duration
into _DURATION_MAIN_Technology
from  _call_info c
	left join _lcc_Serving_Cell_Table_info_interval t
		on c.SessionId = t.SessionId 
			and callStartDuration < time_fin
			and callEndTimeStamp > time_ini	
group by c.sessionid,t.technology,t.side


--OLD
--select ini.sessionid,
--		ini.technology as technology, 	
--		ini.side,
--		sum(case 	
--			when ini.id=1 then datediff (ms, ini.callsetupendtimestamp, fin.msgtime)	
--			when ini.side='A' and ini.id=mxA.maxid then datediff (ms, ini.msgtime, ini.callDisconnectTimeStamp)	
--			when ini.side='B' and ini.id=mxB.maxid then datediff (ms, ini.msgtime, ini.callDisconnectTimeStamp)
--			else datediff (ms, ini.msgtime, fin.msgtime)
--		end) as duration 
--into _DURATION_MAIN_Technology
--from _TECH_MAIN_Net ini 
--	LEFT JOIN  _TECH_MAIN_Net fin
--		ON ini.sessionid=fin.sessionid and ini.id=fin.id-1 and ini.side=fin.side
--	left join 
--		(select sessionid, max(id) as maxid from _TECH_MAIN_Net where side='B' group by sessionid) mxB	
--	on mxB.sessionid=ini.sessionid,
--	(select sessionid, max(id) as maxid from _TECH_MAIN_Net where side='A' group by sessionid) mxA
--where mxA.sessionid=ini.sessionid	
--group by ini.sessionid,	ini.technology, ini.side


--Technology which is used majoritarily on every call
--A Side
exec sp_lcc_dropifexists '_TECH_AVG_A'
select  t.SessionId,
		t.technology,
		t.duration 
into _TECH_AVG_A
from _DURATION_MAIN t, 
	(Select SessionId, max(duration) as duration 
	 from _DURATION_MAIN
	 where side='A'
	 group by sessionid) r
where
t.SessionId=r.SessionId 
and t.duration=r.duration
and t.side='A'

--B Side
exec sp_lcc_dropifexists '_TECH_AVG_B'
select  --b.SessionIdA as Sessionid,
		t.SessionId,
		t.technology,
		t.duration 
into _TECH_AVG_B
from _DURATION_MAIN t, 
	(Select SessionId, max(duration) as duration 
	 from _DURATION_MAIN
	 where side='B'
	 group by sessionid) r--, sessionsB b
where
t.SessionId=r.SessionId 
and t.duration=r.duration
and t.side='B'

-- Durations per call and technology

--GSM A Side
exec sp_lcc_dropifexists '_TECH_GSM_DURATION_A'
select  t.SessionId,
		t.duration/1000.0 as GSM_Duration
into _TECH_GSM_DURATION_A
from _DURATION_MAIN t
where t.technology like '%GSM%'
and t.side='A'


--GSM B Side
exec sp_lcc_dropifexists '_TECH_GSM_DURATION_B'
select  --b.SessionIdA as Sessionid,
		t.SessionId,
		t.duration/1000.0 as GSM_Duration
into _TECH_GSM_DURATION_B
from _DURATION_MAIN t--, sessionsB b
where t.technology like '%GSM%'
--and b.sessionid=t.sessionid
and t.side='B'

-- UMTS A Side
exec sp_lcc_dropifexists '_TECH_UMTS_DURATION_A'
select  t.SessionId,
		t.duration/1000.0 as UMTS_Duration
into _TECH_UMTS_DURATION_A
from _DURATION_MAIN t
where t.technology like '%UMTS%'
and t.side='A'

-- UMTS B Side
exec sp_lcc_dropifexists '_TECH_UMTS_DURATION_B'
select  --b.SessionIdA as Sessionid,
		t.SessionId,
		t.duration/1000.0 as UMTS_Duration
into _TECH_UMTS_DURATION_B
from _DURATION_MAIN t--, sessionsB b
where t.technology like '%UMTS%'
--and b.sessionid=t.sessionid
and t.side='B'

-- LTE A Side
exec sp_lcc_dropifexists '_TECH_LTE_DURATION_A'
select  t.SessionId,
		t.duration/1000.0 as LTE_Duration
into _TECH_LTE_DURATION_A
from _DURATION_MAIN t
where t.technology like '%LTE%'
and t.side='A'

-- LTE
exec sp_lcc_dropifexists '_TECH_LTE_DURATION_B'
select  --b.SessionIdA as Sessionid,
		t.SessionId,
		t.duration/1000.0 as LTE_Duration
into _TECH_LTE_DURATION_B
from _DURATION_MAIN t--, sessionsB b
where t.technology like '%LTE%'
--and b.sessionid=t.sessionid
and t.side='B'


exec sp_lcc_dropifexists '_TECH_Technology_DURATION_A'
select  t.SessionId,
	sum (case when  t.technology = 'LTE 2600' then t.duration/1000.0 end) as LTE2600_Duration,
	sum (case when  t.technology = 'LTE 2100' then t.duration/1000.0 end) as LTE2100_Duration,
	sum (case when  t.technology = 'LTE 1800' then t.duration/1000.0 end) as LTE1800_Duration,
	sum (case when  t.technology = 'LTE 800' then t.duration/1000.0 end) as LTE800_Duration,
	sum (case when  t.technology = 'UMTS 2100' then t.duration/1000.0 end) as UMTS2100_Duration,
	sum (case when  t.technology = 'UMTS 900' then t.duration/1000.0 end) as UMTS900_Duration,
	sum (case when  t.technology = 'GSM 900' then t.duration/1000.0 end) as GSM_Duration,
	sum (case when  t.technology = 'GSM 1800' then t.duration/1000.0 end) as DCS_Duration
into _TECH_Technology_DURATION_A
from _DURATION_MAIN_Technology t
where t.side='A'
group by t.SessionId

exec sp_lcc_dropifexists '_TECH_Technology_DURATION_B'
select  t.SessionId,
	sum (case when  t.technology = 'LTE 2600' then t.duration/1000.0 end) as LTE2600_Duration,
	sum (case when  t.technology = 'LTE 2100' then t.duration/1000.0 end) as LTE2100_Duration,
	sum (case when  t.technology = 'LTE 1800' then t.duration/1000.0 end) as LTE1800_Duration,
	sum (case when  t.technology = 'LTE 800' then t.duration/1000.0 end) as LTE800_Duration,
	sum (case when  t.technology = 'UMTS 2100' then t.duration/1000.0 end) as UMTS2100_Duration,
	sum (case when  t.technology = 'UMTS 900' then t.duration/1000.0 end) as UMTS900_Duration,
	sum (case when  t.technology = 'GSM 900' then t.duration/1000.0 end) as GSM_Duration,
	sum (case when  t.technology = 'GSM 1800' then t.duration/1000.0 end) as DCS_Duration
into _TECH_Technology_DURATION_B
from _DURATION_MAIN_Technology t
where t.side='B'
group by t.SessionId


------------------ END Tech Tables ----------------------------

------------------- ROAMING --------------------------
-- 11/02/2018 MDM: se incopora la información de Roaming para VOZ
------------------------------------------------
--Tiempo total acotado lado A/B:
------------------------------------------------

exec sp_lcc_dropifexists '_ROAMING_MAIN'		
select c.sessionid,t.Operator,t.ServingOperator,t.Band,callStartDuration,time_ini,callEndTimeStamp,time_fin,callDuration,duration,
	case when idSide=1 and callStartDuration <= time_ini and time_fin <= callEndTimeStamp then DATEDIFF(ms,callStartDuration,time_fin) --Si el primer registro es posterior al start cogemos desde el start
		 when idSide=1 and callStartDuration <= time_ini and callEndTimeStamp <= time_fin then callDuration*1000.0 --Si el primer registro es posterior al start y el fin es posterior
		 when callStartDuration <= time_ini and time_fin <= callEndTimeStamp then t.duration -- DATEDIFF(ms,time_ini,time_fin)
		 when time_ini <= callStartDuration and callEndTimeStamp <= time_fin then callDuration*1000.0  ---DATEDIFF(ms,callStartDuration,callEndTimeStamp)
		 when time_ini <= callStartDuration and time_fin <= callEndTimeStamp then DATEDIFF(ms,callStartDuration,time_fin)
		 when callStartDuration <= time_ini and callEndTimeStamp <= time_fin then DATEDIFF(ms,time_ini,callEndTimeStamp)
	end/1000.0 as 'duration_acotada', t.Side
into _ROAMING_MAIN
from _call_info c
left join _lcc_Serving_Cell_Table_info_interval t
		on c.SessionId = t.SessionId
			and callStartDuration < time_fin -- callStartDuration <= time_fin
			and callEndTimeStamp > time_ini -- callEndTimeStamp >= time_ini

------------------------------------------------
--Info Roaming lado A/B:
------------------------------------------------

exec sp_lcc_dropifexists '_ROAMING'
select t.sessionid

	,convert(float,SUM(case when Side='A' then(case when t.operator <> 'Vodafone' and t.ServingOperator = 'Vodafone' then duration_acotada end) else 0 end))
		/SUM(case when Side='A' then(NULLIF(duration_acotada,0))end) as 'Roaming_VF'
	,convert(float,SUM(case when Side='A' then(case when t.operator <> 'Movistar' and t.ServingOperator = 'Movistar' then duration_acotada end) else 0 end))
		/SUM(case when Side='A' then(NULLIF(duration_acotada,0))end) as 'Roaming_MV'
	,convert(float,SUM(case when Side='A' then(case when t.operator <> 'Orange' and t.ServingOperator = 'Orange' then duration_acotada end) else 0 end))
		/SUM(case when Side='A' then(NULLIF(duration_acotada,0))end) as 'Roaming_OR'
	,convert(float,SUM(case when Side='A' then(case when t.operator <> 'Yoigo' and t.ServingOperator = 'Yoigo' then duration_acotada end) else 0 end))
		/SUM(case when Side='A' then(NULLIF(duration_acotada,0))end) as 'Roaming_YO'
	,convert(float,SUM(case when Side='A' then(case when t.Operator<>t.ServingOperator and t.Band like '%GSM%' then duration_acotada end) else 0 end))
		/SUM(case when Side='A' then(NULLIF(duration_acotada,0))end) as 'Roaming_GSM'
	,convert(float,SUM(case when Side='A' then(case when t.Operator<>t.ServingOperator and t.Band like '%DCS%' then duration_acotada end) else 0 end))
		/SUM(case when Side='A' then(NULLIF(duration_acotada,0))end) as 'Roaming_DCS'
	,convert(float,SUM(case when Side='A' then(case when t.Operator<>t.ServingOperator and t.Band = 'UMTS900' then duration_acotada end) else 0 end))
		/SUM(case when Side='A' then(NULLIF(duration_acotada,0))end) as 'Roaming_U900'
	,convert(float,SUM(case when Side='A' then(case when t.Operator<>t.ServingOperator and t.Band = 'UMTS2100' then duration_acotada end) else 0 end))
		/SUM(case when Side='A' then(NULLIF(duration_acotada,0))end) as 'Roaming_U2100'
	,convert(float,SUM(case when Side='A' then(case when t.Operator<>t.ServingOperator and t.Band = 'LTE800' then duration_acotada end) else 0 end))
		/SUM(case when Side='A' then(NULLIF(duration_acotada,0))end) as 'Roaming_LTE800'
	,convert(float,SUM(case when Side='A' then(case when t.Operator<>t.ServingOperator and t.Band = 'LTE1800' then duration_acotada end) else 0 end))
		/SUM(case when Side='A' then(NULLIF(duration_acotada,0))end) as 'Roaming_LTE1800'
	,convert(float,SUM(case when Side='A' then(case when t.Operator<>t.ServingOperator and t.Band = 'LTE2100' then duration_acotada end) else 0 end))
		/SUM(case when Side='A' then(NULLIF(duration_acotada,0))end) as 'Roaming_LTE2100'
	,convert(float,SUM(case when Side='A' then(case when t.Operator<>t.ServingOperator and t.Band = 'LTE2600' then duration_acotada end) else 0 end))
		/SUM(case when Side='A' then(NULLIF(duration_acotada,0))end) as 'Roaming_LTE2600'

	,SUM(case when Side='A' then(case when t.operator <> 'Vodafone' and t.ServingOperator = 'Vodafone' then duration_acotada end) else 0 end)
	as 'Duration_Roaming_VF'
	,SUM(case when Side='A' then(case when t.operator <> 'Movistar' and t.ServingOperator = 'Movistar' then duration_acotada end) else 0 end)
	as 'Duration_Roaming_MV'
	,SUM(case when Side='A' then(case when t.operator <> 'Orange' and t.ServingOperator = 'Orange' then duration_acotada end) else 0 end)
	as 'Duration_Roaming_OR'
	,SUM(case when Side='A' then(case when t.operator <> 'Yoigo' and t.ServingOperator = 'Yoigo' then duration_acotada end) else 0 end)
	as 'Duration_Roaming_YO'
	,SUM(case when Side='A' then(case when t.Operator<>t.ServingOperator and t.Band like '%GSM%' then duration_acotada end) else 0 end)
	as 'Duration_Roaming_GSM'
	,SUM(case when Side='A' then(case when t.Operator<>t.ServingOperator and t.Band like '%DCS%' then duration_acotada end) else 0 end)
	as 'Duration_Roaming_DCS'
	,SUM(case when Side='A' then(case when t.Operator<>t.ServingOperator and t.Band = 'UMTS900' then duration_acotada end) else 0 end)
	as 'Duration_Roaming_U900'
	,SUM(case when Side='A' then(case when t.Operator<>t.ServingOperator and t.Band = 'UMTS2100' then duration_acotada end) else 0 end)
	as 'Duration_Roaming_U2100'
	,SUM(case when Side='A' then(case when t.Operator<>t.ServingOperator and t.Band = 'LTE800' then duration_acotada end) else 0 end)
	as 'Duration_Roaming_LTE800'
	,SUM(case when Side='A' then(case when t.Operator<>t.ServingOperator and t.Band = 'LTE1800' then duration_acotada end) else 0 end)
	as 'Duration_Roaming_LTE1800'
	,SUM(case when Side='A' then(case when t.Operator<>t.ServingOperator and t.Band = 'LTE2100' then duration_acotada end) else 0 end)
	as 'Duration_Roaming_LTE2100'
	,SUM(case when Side='A' then(case when t.Operator<>t.ServingOperator and t.Band = 'LTE2600' then duration_acotada end) else 0 end)
	as 'Duration_Roaming_LTE2600'

	,convert(float,SUM(case when Side='B' then(case when t.operator <> 'Vodafone' and t.ServingOperator = 'Vodafone' then duration_acotada end) else 0 end)) 
		/SUM(case when Side='B' then(NULLIF(duration_acotada,0))end) as 'Roaming_VF_B'
	,convert(float,SUM(case when Side='B' then(case when t.operator <> 'Movistar' and t.ServingOperator = 'Movistar' then duration_acotada end) else 0 end))
		/SUM(case when Side='B' then(NULLIF(duration_acotada,0))end) as 'Roaming_MV_B'
	,convert(float,SUM(case when Side='B' then(case when t.operator <> 'Orange' and t.ServingOperator = 'Orange' then duration_acotada end) else 0 end))
		/SUM(case when Side='B' then(NULLIF(duration_acotada,0))end) as 'Roaming_OR_B'
	,convert(float,SUM(case when Side='B' then(case when t.operator <> 'Yoigo' and t.ServingOperator = 'Yoigo' then duration_acotada end) else 0 end))
		/SUM(case when Side='B' then(NULLIF(duration_acotada,0))end) as 'Roaming_YO_B'
	,convert(float,SUM(case when Side='B' then(case when t.Operator<>t.ServingOperator and t.Band like '%GSM%' then duration_acotada end) else 0 end))
		/SUM(case when Side='B' then(NULLIF(duration_acotada,0))end) as 'Roaming_GSM_B'
	,convert(float,SUM(case when Side='B' then(case when t.Operator<>t.ServingOperator and t.Band like '%DCS%' then duration_acotada end) else 0 end))
		/SUM(case when Side='B' then(NULLIF(duration_acotada,0))end) as 'Roaming_DCS_B'
	,convert(float,SUM(case when Side='B' then(case when t.Operator<>t.ServingOperator and t.Band = 'UMTS900' then duration_acotada end) else 0 end))
		/SUM(case when Side='B' then(NULLIF(duration_acotada,0))end) as 'Roaming_U900_B'
	,convert(float,SUM(case when Side='B' then(case when t.Operator<>t.ServingOperator and t.Band = 'UMTS2100' then duration_acotada end) else 0 end))
		/SUM(case when Side='B' then(NULLIF(duration_acotada,0))end) as 'Roaming_U2100_B'
	,convert(float,SUM(case when Side='B' then(case when t.Operator<>t.ServingOperator and t.Band = 'LTE800' then duration_acotada end) else 0 end))
		/SUM(case when Side='B' then(NULLIF(duration_acotada,0))end) as 'Roaming_LTE800_B'
	,convert(float,SUM(case when Side='B' then(case when t.Operator<>t.ServingOperator and t.Band = 'LTE1800' then duration_acotada end) else 0 end))
		/SUM(case when Side='B' then(NULLIF(duration_acotada,0))end) as 'Roaming_LTE1800_B'
	,convert(float,SUM(case when Side='B' then(case when t.Operator<>t.ServingOperator and t.Band = 'LTE2100' then duration_acotada end) else 0 end))
		/SUM(case when Side='B' then(NULLIF(duration_acotada,0))end) as 'Roaming_LTE2100_B'
	,convert(float,SUM(case when Side='B' then(case when t.Operator<>t.ServingOperator and t.Band = 'LTE2600' then duration_acotada end) else 0 end))
		/SUM(case when Side='B' then(NULLIF(duration_acotada,0))end) as 'Roaming_LTE2600_B'

	,SUM(case when Side='B' then(case when t.operator <> 'Vodafone' and t.ServingOperator = 'Vodafone' then duration_acotada end) else 0 end)
	as 'Duration_Roaming_VF_B'
	,SUM(case when Side='B' then(case when t.operator <> 'Movistar' and t.ServingOperator = 'Movistar' then duration_acotada end) else 0 end)
	as 'Duration_Roaming_MV_B'
	,SUM(case when Side='B' then(case when t.operator <> 'Orange' and t.ServingOperator = 'Orange' then duration_acotada end) else 0 end)
	as 'Duration_Roaming_OR_B'
	,SUM(case when Side='B' then(case when t.operator <> 'Yoigo' and t.ServingOperator = 'Yoigo' then duration_acotada end) else 0 end)
	as 'Duration_Roaming_YO_B'
	,SUM(case when Side='B' then(case when t.Operator<>t.ServingOperator and t.Band like '%GSM%' then duration_acotada end) else 0 end)
	as 'Duration_Roaming_GSM_B'
	,SUM(case when Side='B' then(case when t.Operator<>t.ServingOperator and t.Band like '%DCS%' then duration_acotada end) else 0 end)
	as 'Duration_Roaming_DCS_B'
	,SUM(case when Side='B' then(case when t.Operator<>t.ServingOperator and t.Band = 'UMTS900' then duration_acotada end) else 0 end)
	as 'Duration_Roaming_U900_B'
	,SUM(case when Side='B' then(case when t.Operator<>t.ServingOperator and t.Band = 'UMTS2100' then duration_acotada end) else 0 end)
	as 'Duration_Roaming_U2100_B'
	,SUM(case when Side='B' then(case when t.Operator<>t.ServingOperator and t.Band = 'LTE800' then duration_acotada end) else 0 end)
	as 'Duration_Roaming_LTE800_B'
	,SUM(case when Side='B' then(case when t.Operator<>t.ServingOperator and t.Band = 'LTE1800' then duration_acotada end) else 0 end)
	as 'Duration_Roaming_LTE1800_B'
	,SUM(case when Side='B' then(case when t.Operator<>t.ServingOperator and t.Band = 'LTE2100' then duration_acotada end) else 0 end)
	as 'Duration_Roaming_LTE2100_B'
	,SUM(case when Side='B' then(case when t.Operator<>t.ServingOperator and t.Band = 'LTE2600' then duration_acotada end) else 0 end)
	as 'Duration_Roaming_LTE2600_B'
	
into _ROAMING
from _ROAMING_MAIN t
where t.sessionid > @maxsession
group by t.sessionid
 
------------------- END ROAMING -----------------------------

------------------------------------- END CRITERIO 1 ------------------------------------------------------

------------------------------------------------------------------------------------------------------
--	CRITERIO 2: Calculamos los eventos más cercano a la primera y última muestra de MOS de la llamada-

--				Se calcula el momento del Disconnect de la llamada acotandolo al disconnect más cercano desde el último registro de MOS.
--				En el caso que no haya muestras de MOS, nos quedamos con el primer disconnect que se produzca
--				Como último caso, nos quedamos con el disconnect de CallAnalysis

--				La misma lógica se sigue para el ConnectACK. Tomamos el evento más cercano al primer registro de MOS.
--				En el caso de que no haya muestras de MOS, nos quedamos con el último ConnectACK que se produzca
--				Como último caso, nos quedamos con el callsetupendtimestamp de CallAnalysis

--	Con este criterio calculamos:
--				is_CSFB, is_VOLTE, is_SRVCC, is_CS
--				CMService_Band, CMService_Freq, Trying_Band, Trying_Freq,...
--				SRVCC: entre el Dial y el Disconnect
--				HOs: entre el Dial y el Disconnect, considerando que el CMServiceReques/Trying es anterior al Disconnect
--				Neighbours: entre el Dial y el Disconnect, considerando que el CMServiceReques/Trying es anterior al Disconnect
--				Tech_Radio_INI, Tech_Radio_FIN, Tech_Radio_AVG: dependiendo del tipo de llamada el comienzo será antes del Trying/CMServiceRequest/ExtendedSR y el final antes del Disconnect
--				CST


-----------------------------------------------------------------------------------------------------

---------------------- VOICE EVENT STAGE -------------------------------

--Se calcula el momento del Disconnect de la llamada acotandolo al disconnect más cercano desde el último registro de MOS.
--En el caso que no haya muestras de MOS, nos quedamos con el primer disconnect que se produzca
--Como último caso, nos quedamos con el disconnect de CallAnalysis

--La misma lógica se sigue para el ConnectACK. Tomamos el evento más cercano al primer registro de MOS.
--En el caso de que no haya muestras de MOS, nos quedamos con el último ConnectACK que se produzca
--Como último caso, nos quedamos con el callsetupendtimestamp de CallAnalysis

exec sp_lcc_dropifexists '_Disconnect_EVENT' --select * from _Disconnect_EVENT
--Determinados dial y disconnects de llamada:
select m.sessionid, c.callDir, c.callStatus, Dial_Time,
	case 
		-- Ambos disconnect se producen despues del ultimo registro de mos, nos quedamos con el primer disconnect.
		when m.max_Time_Mos<=m.DisconnectVOLTE_Time_A and m.max_Time_Mos<=m.Disconnect_Time_A then 
			(case when DisconnectVOLTE_Time_A<=Disconnect_Time_A then m.DisconnectVOLTE_Time_A else m.Disconnect_Time_A end)
		--Disconnect VOLTE despues del ultimo registro de MOS
		when m.max_Time_Mos<=m.DisconnectVOLTE_Time_A then m.DisconnectVOLTE_Time_A
		--Disconnect no VOLTE despues del ultimo registro de MOS
		when m.max_Time_Mos<=m.Disconnect_Time_A then m.Disconnect_Time_A 
		--No hay mos, nos quedamos con el primer disconnect que se produzca o con el disconnect de callAnalysis
		when m.max_Time_Mos is null then
			(case when DisconnectVOLTE_Time_A<=Disconnect_Time_A or (DisconnectVOLTE_Time_A is not null and Disconnect_Time_A is null) then DisconnectVOLTE_Time_A 
				when DisconnectVOLTE_Time_A>Disconnect_Time_A or (DisconnectVOLTE_Time_A is null and Disconnect_Time_A is not null) then Disconnect_Time_A
			else c.callDisconnectTimeStamp end)
		else c.callDisconnectTimeStamp
	end as Disconnect_A,
	case 
		--Ambos disconnect se producen despues del ultimo registro de mos, nos quedamos con el primer disconnect.
		when m.max_Time_Mos<=m.DisconnectVOLTE_Time_B and m.max_Time_Mos<=m.Disconnect_Time_B then 
			(case when DisconnectVOLTE_Time_B<=Disconnect_Time_B then m.DisconnectVOLTE_Time_B else m.Disconnect_Time_B end)
		--Disconnect VOLTE despues del ultimo registro de MOS
		when m.max_Time_Mos<=m.DisconnectVOLTE_Time_B then m.DisconnectVOLTE_Time_B
		--Disconnect no VOLTE despues del ultimo registro de MOS
		when m.max_Time_Mos<=m.Disconnect_Time_B then m.Disconnect_Time_B 
		--No hay mos, nos quedamos con el primer disconnect que se produzca o con el disconnect de callAnalysis
		when m.max_Time_Mos is null then
			(case when DisconnectVOLTE_Time_B<=Disconnect_Time_B or (DisconnectVOLTE_Time_B is not null and Disconnect_Time_B is null) then DisconnectVOLTE_Time_B 
				when DisconnectVOLTE_Time_B>Disconnect_Time_B or (DisconnectVOLTE_Time_B is null and Disconnect_Time_B is not null) then Disconnect_Time_B
			else cB.callDisconnectTimeStamp end)
		else cB.callDisconnectTimeStamp
	end as Disconnect_B,

	case 
		--Ambos ConnectAck se producen antes del primer registro de mos, nos quedamos con el último ConnectAck.
		when m.min_Time_Mos>=m.ConnectAckVOLTE_Time_A and m.min_Time_Mos>=m.ConnectAck_Time_A then 
			(case when ConnectAckVOLTE_Time_A>=ConnectAck_Time_A then m.ConnectAckVOLTE_Time_A else m.ConnectAck_Time_A end)
		--ConnectAck VOLTE antes del primer registro de MOS
		when m.min_Time_Mos>=m.ConnectAckVOLTE_Time_A then m.ConnectAckVOLTE_Time_A
		--ConnectAck no VOLTE antes del primer registro de MOS
		when m.min_Time_Mos>=m.ConnectAck_Time_A then m.ConnectAck_Time_A 
		--No hay mos, nos quedamos con el último ConnectAck que se produzca o con el Setup de callAnalysis
		when m.min_Time_Mos is null then
			(case when ConnectAckVOLTE_Time_A>=ConnectAck_Time_A or (ConnectAckVOLTE_Time_A is not null and ConnectAck_Time_A is null) then ConnectAckVOLTE_Time_A 
				when ConnectAckVOLTE_Time_A>ConnectAck_Time_A or (ConnectAckVOLTE_Time_A is null and ConnectAck_Time_A is not null) then ConnectAck_Time_A
			else c.callsetupendtimestamp end)
		else c.callsetupendtimestamp
	end as ConnectAck_A,
	case 
		--Ambos ConnectAck se producen antes del primer registro de mos, nos quedamos con el último ConnectAck.
		when m.min_Time_Mos>=m.ConnectAckVOLTE_Time_B and m.min_Time_Mos>=m.ConnectAck_Time_B then 
			(case when ConnectAckVOLTE_Time_B>=ConnectAck_Time_B then m.ConnectAckVOLTE_Time_B else m.ConnectAck_Time_B end)
		--ConnectAck VOLTE antes del primer registro de MOS
		when m.min_Time_Mos>=m.ConnectAckVOLTE_Time_B then m.ConnectAckVOLTE_Time_B
		--ConnectAck no VOLTE antes del primer registro de MOS
		when m.min_Time_Mos>=m.ConnectAck_Time_B then m.ConnectAck_Time_B 
		--No hay mos, nos quedamos con el último ConnectAck que se produzca o con el Setup de callAnalysis
		when m.min_Time_Mos is null then
			(case when ConnectAckVOLTE_Time_B>=ConnectAck_Time_B or (ConnectAckVOLTE_Time_B is not null and ConnectAck_Time_B is null) then ConnectAckVOLTE_Time_B 
				when ConnectAckVOLTE_Time_B>ConnectAck_Time_B or (ConnectAckVOLTE_Time_B is null and ConnectAck_Time_B is not null) then ConnectAck_Time_B
			else cB.callsetupendtimestamp end)
		else cB.callsetupendtimestamp
	end as ConnectAck_B
into _Disconnect_EVENT
from lcc_markers_time m  --Sesiones A
	left join callanalysis c  on c.sessionid=m.sessionid and c.side='A' --Llamadas A
	left join callanalysis cB on cB.sessionidA=m.sessionid and cB.side='B' --Llamadas B


exec sp_lcc_dropifexists '_SRVCC'
select r.sessionid,
	max(case when r.errorcode=0 then 1 else 0 end) as SRVCC_SR
into _SRVCC
from resultskpi r, _Disconnect_EVENT d, resultskpi kpi
where r.sessionid=d.sessionid
	and r.sessionid=kpi.sessionid
	and r.startTime > d.Dial_Time
	and r.endTime < d.Disconnect_A	
	and r.kpiid in (38040, 38050, 38060)
	--Activate Dedicated EPS bearer context
	and kpi.KPIId = 18015 and kpi.ErrorCode = 0
group by  r.sessionid

--SRVCC B
--select  a.sessionid,
--		max(case when (r.kpiid in (38040, 38050, 38060) and r.errorcode<>0) then 0 else 1 end) as SRVCC_SR_BSide

--into _SRVCC_B
--from resultskpi r, callanalysis a, sessionsB b
--where r.kpiid in (38040, 38050, 38060)
--and b.sessionid=r.sessionid
--and a.sessionid=b.sessionidA 
--and a.sessionid > @maxsession
--group by  a.sessionid


exec sp_lcc_dropifexists '_SRVCC_B'
select  d.sessionid,
	max(case when r.errorcode=0 then 1 else 0 end) as SRVCC_SR_B
into _SRVCC_B
from resultskpi r, sessionsB b, _Disconnect_EVENT d, resultskpi kpi
where b.sessionid=r.sessionid
	and d.sessionid=b.sessionidA 
	and r.sessionid=kpi.sessionid
	and r.startTime > d.Dial_Time
	and r.endTime < d.Disconnect_B	
	and r.kpiid in (38040, 38050, 38060)
	--Activate Dedicated EPS bearer context
	and kpi.KPIId = 18015 and kpi.ErrorCode = 0
group by  d.sessionid


--Identificamos intersystemHO 4G/3G exitosos desde el Trying al Disconnect
--HO
exec sp_lcc_dropifexists '_HO'
select r.sessionid,
	max(case when r.errorcode=0 then 1 else 0 end) as HO
into _HO
from resultskpi r, _Disconnect_EVENT d, lcc_markers_time m
where r.sessionid=d.sessionid
	and r.sessionid=m.sessionid
	and r.startTime > d.Dial_Time --Debe ser posterior al dial de la llamada (asi descartamos HO de intentos anteriores)
	and r.startTime > case when m.Trying_Time_A is not null then m.Trying_Time_A else d.Dial_Time end
	and (m.CMServiceRequest_Time_A is null or m.CMServiceRequest_Time_A >= m.Dial_Time or m.CMServiceRequest_Time_A <= d.Disconnect_A)
	and (m.CallConfirmed_Time_A is null or m.CallConfirmed_Time_A >= m.Dial_Time or m.CallConfirmed_Time_A <= d.Disconnect_A)
	and r.endTime < d.Disconnect_A	
	and r.kpiid =38020
group by  r.sessionid

--HO B
exec sp_lcc_dropifexists '_HO_B'
select  d.sessionid,
	max(case when r.errorcode=0 then 1 else 0 end) as HO_B
into _HO_B
from resultskpi r, sessionsB b, _Disconnect_EVENT d, lcc_markers_time m
where b.sessionid=r.sessionid
	and d.sessionid=b.sessionidA 
	and m.sessionid=b.sessionidA 
	and r.startTime > d.Dial_Time  --Debe ser posterior al dial de la llamada (asi descartamos HO de intentos anteriores)
	and r.startTime > case when m.Trying_Time_B is not null then m.Trying_Time_B else d.Dial_Time end
	and (m.CMServiceRequest_Time_B is null or m.CMServiceRequest_Time_B >= m.Dial_Time or m.CMServiceRequest_Time_B <= d.Disconnect_B)
	and (m.CallConfirmed_Time_B is null or m.CallConfirmed_Time_B >= m.Dial_Time or m.CallConfirmed_Time_B <= d.Disconnect_B)
	and r.endTime < d.Disconnect_B	
	and r.kpiid =38020
group by  d.sessionid

--Clasificamos llamadas de acuerdo a los eventos producidos entre dial-disconnect (lógica del disconnect hacia arriba):
--Si el disconnect se produce en VOLTE, la llamada es 100% VOLTE
--En caso contrario:
--		Si se produce un handover exitoso de 4G/XG entre Dial-Disconnect --> Llamada VOLTE con HO
--		Si se produce un SRVCC exitoso y unActivate Dedicated EPS bearer context --> Llamada VOLTE con SRVCC
--		Si no hay handover y se produce un ExtendedServiceRequest (exitoso o no) entre Dial-Disconnect --> Llamada CSFB
--		En cualquier otro caso --> llamada CS

exec sp_lcc_dropifexists '_type_Calls'
select d.*,
	case when d.Disconnect_A=m.DisconnectVOLTE_Time_A --Acaba en VOLTE
		--Iniciada en volte pero no info de disconnect, ni hecho CSFB, ni SRVCC, ni HO 4G/3G.
		or (m.DisconnectVOLTE_Time_A is null and m.Disconnect_Time_A is null --No hay info de disconnect
			and (s.SRVCC_SR=0 or s.SRVCC_SR is null) --No hay SRVCC
			and (m.ExtendedSR_Time_A is null or m.ExtendedSR_Time_A <= m.Dial_Time or m.ExtendedSR_Time_A >= d.Disconnect_A) --No hay CSFB
			and m.Trying_Time_A > m.Dial_Time and m.Trying_Time_A < d.Disconnect_A --Iniciada en VOLTE
			and (h.HO=0 or h.HO is null)) --No hay HO 4G/3G
	then 'VOLTE' end as is_VOLTE_A,	

	case when --Iniciada en volte, disconnect en CS, no hecho CSFB ni SRVCC pero si HO 4G/3G
		(d.Disconnect_A=m.Disconnect_Time_A --Acabada en no VOLTE
			and (s.SRVCC_SR=0 or s.SRVCC_SR is null) --No hay SRVCC
			and (m.ExtendedSR_Time_A is null or m.ExtendedSR_Time_A <= m.Dial_Time or m.ExtendedSR_Time_A >= d.Disconnect_A) --No hay CSFB
			and h.HO=1  --HO 4G/3G
			and m.Trying_Time_A > m.Dial_Time and m.Trying_Time_A < d.Disconnect_A) --Iniciada en VOLTE
		--Iniciada en volte pero no info de disconnect, ni hecho CSFB, ni SRVCC pero si HO 4G/3G.
		or (m.DisconnectVOLTE_Time_A is null and m.Disconnect_Time_A is null --No hay info de disconnect
			and (s.SRVCC_SR=0 or s.SRVCC_SR is null) --No hay SRVCC
			and (m.ExtendedSR_Time_A is null or m.ExtendedSR_Time_A <= m.Dial_Time or m.ExtendedSR_Time_A >= d.Disconnect_A) --No hay CSFB
			and m.Trying_Time_A > m.Dial_Time and m.Trying_Time_A < d.Disconnect_A --Iniciada en VOLTE
			and h.HO=1) --HO 4G/3G
	then 'VOLTE_HO' end as is_VOLTE_HO_A,

	case when (d.Disconnect_A<>m.DisconnectVOLTE_Time_A or m.DisconnectVOLTE_Time_A is null) --NO acabada en VOLTE
		and s.SRVCC_SR=1 --Hay SRVCC
	then 'SRVCC' end as is_SRVCC_A,

	case when (d.Disconnect_A<>m.DisconnectVOLTE_Time_A or m.DisconnectVOLTE_Time_A is null) --NO acabada en VOLTE
		and (s.SRVCC_SR=0 or s.SRVCC_SR is null) --NO hay SRVCC
		and m.ExtendedSR_Time_A > m.Dial_Time and m.ExtendedSR_Time_A < d.Disconnect_A --Hay CSFB
	then 'CSFB' end as is_CSFB_A,

	case when (d.Disconnect_A=m.Disconnect_Time_A --Acabada en no VOLTE
			and (s.SRVCC_SR=0 or s.SRVCC_SR is null) --NO hay SRVCC
			and (m.ExtendedSR_Time_A is null or m.ExtendedSR_Time_A <= m.Dial_Time or m.ExtendedSR_Time_A >= d.Disconnect_A)--No hay CSFB
			and ((h.HO=0 or h.HO is null) and m.Trying_Time_A > m.Dial_Time )) --No hay HO 4G/3G
		or (m.DisconnectVOLTE_Time_A is null and m.Disconnect_Time_A is null --No hay info de disconnect
			and (m.Trying_Time_A is null or m.Trying_Time_A <= m.Dial_Time or m.Trying_Time_A >= d.Disconnect_A) -- No esta iniciada en VOLTE
			and m.CMServiceRequest_Time_A > m.Dial_Time and m.CMServiceRequest_Time_A < d.Disconnect_A --CM Service
			and (m.ExtendedSR_Time_A is null or m.ExtendedSR_Time_A <= m.Dial_Time or m.ExtendedSR_Time_A >= d.Disconnect_A) --No hay CSFB
		)		
	then 'CS' end as is_CS_A,  ---Llamadas en 3G o en 2G
	-------------
	case when d.Disconnect_B=m.DisconnectVOLTE_Time_B --Acaba en VOLTE
		--Iniciada en volte pero no info de disconnect, ni hecho CSFB ni SRVCC.
		or (m.DisconnectVOLTE_Time_B is null and m.Disconnect_Time_B is null --No hay info de disconnect
			and (sB.SRVCC_SR_B=0 or sB.SRVCC_SR_B is null) --No hay SRVCC
			and (m.ExtendedSR_Time_B is null or m.ExtendedSR_Time_B <= m.Dial_Time or m.ExtendedSR_Time_B >= d.Disconnect_B) --No hay CSFB
			and m.Trying_Time_B > m.Dial_Time and m.Trying_Time_B < d.Disconnect_B --Iniciada en VOLTE
			and (hB.HO_B=0 or hB.HO_B is null)) --No hay HO 4G/3G
	then 'VOLTE' end as is_VOLTE_B,	

	case when --Iniciada en volte, disconnect en CS, no hecho CSFB ni SRVCC pero si HO 4G/3G
		(d.Disconnect_B=m.Disconnect_Time_B --Acabada en no VOLTE
			and (sB.SRVCC_SR_B=0 or sB.SRVCC_SR_B is null) --No hay SRVCC
			and (m.ExtendedSR_Time_B is null or m.ExtendedSR_Time_B <= m.Dial_Time or m.ExtendedSR_Time_B >= d.Disconnect_B) --No hay CSFB
			and hB.HO_B=1  --HO 4G/3G
			and m.Trying_Time_B > m.Dial_Time and m.Trying_Time_B < d.Disconnect_B) --Iniciada en VOLTE
		--Iniciada en volte pero no info de disconnect, ni hecho CSFB, ni SRVCC pero si HO 4G/3G.
		or (m.DisconnectVOLTE_Time_B is null and m.Disconnect_Time_B is null --No hay info de disconnect
			and (sB.SRVCC_SR_B=0 or sB.SRVCC_SR_B is null) --No hay SRVCC
			and (m.ExtendedSR_Time_B is null or m.ExtendedSR_Time_B <= m.Dial_Time or m.ExtendedSR_Time_B >= d.Disconnect_B) --No hay CSFB
			and m.Trying_Time_B > m.Dial_Time and m.Trying_Time_B < d.Disconnect_B --Iniciada en VOLTE
			and hB.HO_B=1) --HO 4G/3G
	then 'VOLTE_HO' end as is_VOLTE_HO_B,

	case when (d.Disconnect_B<>m.DisconnectVOLTE_Time_B or m.DisconnectVOLTE_Time_B is null) --NO acabada en VOLTE
		and sB.SRVCC_SR_B=1 --Hay SRVCC
	then 'SRVCC' end as is_SRVCC_B,

	case when (d.Disconnect_B<>m.DisconnectVOLTE_Time_B or m.DisconnectVOLTE_Time_B is null) --NO acabada en VOLTE
		and (sB.SRVCC_SR_B=0 or sB.SRVCC_SR_B is null) --NO hay SRVCC
		and m.ExtendedSR_Time_B > m.Dial_Time and m.ExtendedSR_Time_B < d.Disconnect_B --Hay CSFB
	then 'CSFB' end as is_CSFB_B,

	case when (d.Disconnect_B=m.Disconnect_Time_B --Acabada en no VOLTE
			and (sB.SRVCC_SR_B=0 or sB.SRVCC_SR_B is null) --NO hay SRVCC
			and (m.ExtendedSR_Time_B is null or m.ExtendedSR_Time_B <= m.Dial_Time or m.ExtendedSR_Time_B >= d.Disconnect_B)--No hay CSFB
		) 
		or (m.DisconnectVOLTE_Time_B is null and m.Disconnect_Time_B is null --No hay info de disconnect
			and (m.Trying_Time_B is null or m.Trying_Time_B <= m.Dial_Time or m.Trying_Time_B >= d.Disconnect_B) -- No esta iniciada en VOLTE
			and m.CMServiceRequest_Time_B > m.Dial_Time and m.CMServiceRequest_Time_B < d.Disconnect_B --CM Service
			and (m.ExtendedSR_Time_B is null or m.ExtendedSR_Time_B <= m.Dial_Time or m.ExtendedSR_Time_B >= d.Disconnect_B) --No hay CSFB
		)		
	then 'CS' end as is_CS_B
into _type_Calls
from _Disconnect_EVENT d inner join lcc_markers_time m on d.sessionid=m.sessionid
	left join _SRVCC s on d.sessionid=s.sessionid
	left join _SRVCC_B sB on d.sessionid=sB.sessionid
	left join _HO h on d.sessionid=h.sessionid
	left join _HO_B hB on d.sessionid=hB.sessionid


--------------------------------------------------------------------------------------------------------------------------------
-- Añadimos más información a las llamadas:
--	identifiacmos el disconnect del originante
--	identificamos los setups de cada terminal y el setup del terminante, dependiendo del tipo de llamada
--	AsideType, BsideType, CSFB_Device,is_CSFB, is_VOLTE y is_SRVCC
exec sp_lcc_dropifexists '_info_Calls'
select t.*
	,case when t.callDir = 'A->B' then t.Disconnect_A else t.Disconnect_B end as Disconnect_Originante
	,case when t.callDir = 'A->B' then ConnectAck_B else ConnectAck_A end as Setup_Terminante

	,case when t.is_VOLTE_A ='VOLTE' or t.is_SRVCC_A='SRVCC' or t.is_VOLTE_HO_A='VOLTE_HO' then 'VOLTE' 
		  else 'CS' end AsideType
	,case when t.is_VOLTE_B ='VOLTE' or t.is_SRVCC_B='SRVCC' or t.is_VOLTE_HO_B='VOLTE_HO' then 'VOLTE' 
		  else 'CS' end BsideType
	,case when t.is_CSFB_A='CSFB' and t.is_CSFB_B='CSFB' then 'AB'
		 when t.is_CSFB_A='CSFB' then 'A' 
		 when t.is_CSFB_B='CSFB' then 'B'
	else '' end as CSFB_Device
	,case when t.is_CSFB_A='CSFB' and t.is_CSFB_B='CSFB' then 2
		when t.is_CSFB_A='CSFB' or t.is_CSFB_B='CSFB' then 1 --Si existe el mensaje Extended SR es CSFB
	else 0 end as is_CSFB
	,case when (t.is_VOLTE_A ='VOLTE' or t.is_SRVCC_A='SRVCC' or t.is_VOLTE_HO_A='VOLTE_HO') and (t.is_VOLTE_B ='VOLTE' or t.is_SRVCC_B='SRVCC' or t.is_VOLTE_HO_B='VOLTE_HO') then 2
		 when (t.is_VOLTE_A ='VOLTE' or t.is_SRVCC_A='SRVCC' or t.is_VOLTE_HO_A='VOLTE_HO') or (t.is_VOLTE_B ='VOLTE' or t.is_SRVCC_B='SRVCC' or t.is_VOLTE_HO_B='VOLTE_HO') then 1
	else 0 end as is_VOLTE
	,case when t.is_SRVCC_A='SRVCC' and t.is_SRVCC_B='SRVCC' then 2
		 when t.is_SRVCC_A='SRVCC' or t.is_SRVCC_B='SRVCC' then 1
	else 0 end as is_SRVCC	
	,case when t.is_VOLTE_HO_A='SRVCC' and t.is_VOLTE_HO_B='SRVCC' then 2
		 when t.is_VOLTE_HO_A='SRVCC' or t.is_VOLTE_HO_B='SRVCC' then 1
	else 0 end as is_VOLTE_HO
into _info_Calls
from _type_Calls t inner join lcc_markers_time m on t.sessionid=m.sessionid

--
exec sp_lcc_dropifexists '_RRC'
select t.sessionid,t.bcch,t.msgtime,case when t.RFband like 'LTE E-UTRA%' then case when t.RFband like '%20%' then 'LTE800'
															when t.RFband like '%7%' then 'LTE2600'
															when t.RFband like '%3%' then 'LTE1800'
															when t.RFband like '%1%' then 'LTE2100' end
									 else replace(t.RFband,' ','') end as technology
	,row_number () over (partition by t.sessionid order by t.msgtime asc) as id
into _RRC
from vlcc_Layer3_comp t
	left join [AGRIDS].dbo.lcc_ref_servingOperator_Freq sof on t.BCCH=sof.Frequency, 
	sessionsB b,
	_Disconnect_EVENT td
Where b.sessionidA=t.sessionid
	and td.sessionid=b.sessionidA
	and t.msgtime > td.Disconnect_b

delete _RRC where id <> 1

exec sp_lcc_dropifexists '_RRCB'
select b.sessionidA, t.bcch,t.msgtime,case when t.RFband like 'LTE E-UTRA%' then case when t.RFband like '%20%' then 'LTE800'
															when t.RFband like '%7%' then 'LTE2600'
															when t.RFband like '%3%' then 'LTE1800'
															when t.RFband like '%1%' then 'LTE2100' end
										 else replace(t.RFband,' ','') end as technology
	,row_number () over (partition by t.sessionid order by t.msgtime asc) as id
into _RRCB				
from vlcc_Layer3_comp t
	left join [AGRIDS].dbo.lcc_ref_servingOperator_Freq sof on t.BCCH=sof.Frequency,
	sessionsB b,
	_Disconnect_EVENT td
Where b.sessionid=t.sessionid
	and td.sessionid=b.sessionidA
	and t.msgtime > td.Disconnect_A

delete _RRCB where id <> 1

exec sp_lcc_dropifexists '_RRC_VOLTE'
select t.sessionid,t.bcch,t.msgtime,case when t.RFband like 'LTE E-UTRA%' then case when t.RFband like '%20%' then 'LTE800'
															when t.RFband like '%7%' then 'LTE2600'
															when t.RFband like '%3%' then 'LTE1800'
															when t.RFband like '%1%' then 'LTE2100' end
									 else replace(t.RFband,' ','') end as technology
	,row_number () over (partition by t.sessionid order by t.msgtime asc) as id
into _RRC_VOLTE
from vlcc_IMSSIPMessage_comp t
	left join [AGRIDS].dbo.lcc_ref_servingOperator_Freq sof on t.BCCH=sof.Frequency,
	sessionsB b,
	_Disconnect_EVENT td
Where b.sessionidA=t.sessionid
	and td.sessionid=b.sessionidA
	and t.msgtime > td.Disconnect_b

delete _RRC_VOLTE where id <> 1

exec sp_lcc_dropifexists '_RRCB_VOLTE'
select b.sessionidA, t.bcch,t.msgtime,case when t.RFband like 'LTE E-UTRA%' then case when t.RFband like '%20%' then 'LTE800'
															when t.RFband like '%7%' then 'LTE2600'
															when t.RFband like '%3%' then 'LTE1800'
															when t.RFband like '%1%' then 'LTE2100' end
										 else replace(t.RFband,' ','') end as technology
	,row_number () over (partition by t.sessionid order by t.msgtime asc) as id
into _RRCB_VOLTE			
from vlcc_IMSSIPMessage_comp t
	left join [AGRIDS].dbo.lcc_ref_servingOperator_Freq sof on t.BCCH=sof.Frequency,
	sessionsB b,
	_Disconnect_EVENT td
Where b.sessionid=t.sessionid
	and td.sessionid=b.sessionidA
	and t.msgtime > td.Disconnect_A

delete _RRCB_VOLTE where id <> 1

exec sp_lcc_dropifexists '_VOICE_EVENT_FREQ'
select	t.sessionid,
	--Si la llamada es VOLTE o hace SRVCC, todos los eventos hasta el ConnectAck sabemos que se producen en 4g
	--Si la llamada hace CSFB o es CS, todos los eventos desde el CM Service Request sabemos que se producen en 3g/2g
	--Para el disconnect tomamos el evento de lcc_markers_time. Si no, cogemos el instante posterior al disconnect del otro lado de la llamada.
	case 
		when is_CSFB_A='CSFB' then ExtendedSR_tech_A
	end as CSFB_band,
	case 
		when is_CSFB_A='CSFB' then ExtendedSR_bcch_A
	end as CSFB_freq,

	case 
		when is_VOLTE_A ='VOLTE' or is_SRVCC_A='SRVCC' or t.is_VOLTE_HO_A='VOLTE_HO' then Trying_tech_A		
	end as Trying_band,
	case 
		when is_VOLTE_A ='VOLTE' or is_SRVCC_A='SRVCC' or t.is_VOLTE_HO_A='VOLTE_HO' then Trying_bcch_A
	end as Trying_freq,
	
	case 
		when is_CSFB_A='CSFB' or is_CS_A='CS' then 
			(case when CMServiceRequest_tech_A is not null then CMServiceRequest_tech_A else CallConfirmed_tech_A end)
	end as CMService_band,
	case 
		when is_CSFB_A='CSFB' or is_CS_A='CS' then 
			(case when CMServiceRequest_bcch_A is not null then CMServiceRequest_bcch_A else CallConfirmed_bcch_A end)
	end as CMService_freq,

	case 
		when is_VOLTE_A ='VOLTE' or is_SRVCC_A='SRVCC' or t.is_VOLTE_HO_A='VOLTE_HO' then Ringing_tech_A
		when is_CSFB_A='CSFB' or is_CS_A='CS' then Alerting_tech_A
	end as Alerting_band,
	case 
		when is_VOLTE_A ='VOLTE' or is_SRVCC_A='SRVCC' or t.is_VOLTE_HO_A='VOLTE_HO' then Ringing_bcch_A
		when is_CSFB_A='CSFB' or is_CS_A='CS' then Alerting_bcch_A
	end as Alerting_freq,

	case 
		when is_VOLTE_A ='VOLTE' then Accept_tech_A
		when is_SRVCC_A='SRVCC' or t.is_VOLTE_HO_A='VOLTE_HO' then --Identificamos el connect más cercano al primer registro de MOS (similar a la lógica del connectAck):
			--Ambos Connect se producen antes del primer registro de mos, nos quedamos con el último Connect
			case when m.min_Time_Mos>=m.Accept_time_A and m.min_Time_Mos>=m.Connect_Time_A then 
				(case when Accept_time_A>=Connect_Time_A then m.Accept_tech_A else m.Connect_tech_A end)
			--Connect VOLTE antes del primer registro de MOS
			when m.min_Time_Mos>=m.Accept_time_A then m.Accept_tech_A
			--Connect no VOLTE antes del primer registro de MOS
			when m.min_Time_Mos>=m.Connect_Time_A then m.Connect_tech_A 
			--No hay mos, nos quedamos con el último Connect que se produzca 
			when m.min_Time_Mos is null then
				(case when Accept_time_A>=Connect_Time_A or (Accept_time_A is not null and Connect_Time_A is null) then Accept_tech_A 
					when Accept_time_A>Connect_Time_A or (Accept_time_A is null and Connect_Time_A is not null) then Connect_tech_A
				end)
			end
		when is_CSFB_A='CSFB' or is_CS_A='CS' then Connect_tech_A
	end as Connect_band,
	case 
		when is_VOLTE_A ='VOLTE' then Accept_bcch_A
		when is_SRVCC_A='SRVCC' or t.is_VOLTE_HO_A='VOLTE_HO' then --Identificamos el connect más cercano al primer registro de MOS (similar a la lógica del connectAck):
			--Ambos Connect se producen antes del primer registro de mos, nos quedamos con el último Connect
			case when m.min_Time_Mos>=m.Accept_time_A and m.min_Time_Mos>=m.Connect_Time_A then 
				(case when Accept_time_A>=Connect_Time_A then m.Accept_bcch_A else m.Connect_bcch_A end)
			--Connect VOLTE antes del primer registro de MOS
			when m.min_Time_Mos>=m.Accept_time_A then m.Accept_bcch_A
			--Connect no VOLTE antes del primer registro de MOS
			when m.min_Time_Mos>=m.Connect_Time_A then m.Connect_bcch_A 
			--No hay mos, nos quedamos con el último Connect que se produzca 
			when m.min_Time_Mos is null then
				(case when Accept_time_A>=Connect_Time_A or (Accept_time_A is not null and Connect_Time_A is null) then Accept_bcch_A 
					when Accept_time_A>Connect_Time_A or (Accept_time_A is null and Connect_Time_A is not null) then Connect_bcch_A
				end)
			end
		when is_CSFB_A='CSFB' or is_CS_A='CS' then Connect_bcch_A
	end as Connect_freq,

	case 
		when Disconnect_A=m.DisconnectVOLTE_Time_A then DisconnectVOLTE_tech_A
		when Disconnect_A=m.Disconnect_Time_A then Disconnect_tech_A
		--el primer evento que se produzca despues del disconnect de B
		when (Disconnect_A<>m.DisconnectVOLTE_Time_A or DisconnectVOLTE_Time_A is null) and (Disconnect_A<>m.Disconnect_Time_A or Disconnect_Time_A is null) then
			(case when rrcVOLTE.msgtime<=rrc.msgtime or (rrcVOLTE.msgtime is not null and rrc.msgtime is null) then rrcVOLTE.technology collate SQL_Latin1_General_CP1_CI_AS
				when rrcVOLTE.msgtime>rrc.msgtime or (rrcVOLTE.msgtime is null and rrc.msgtime is not null) then rrc.technology collate SQL_Latin1_General_CP1_CI_AS
			end)
	end as Disconnect_band,
	
	case 
		when Disconnect_A=m.DisconnectVOLTE_Time_A then DisconnectVOLTE_bcch_A
		when Disconnect_A=m.Disconnect_Time_A then Disconnect_bcch_A
		--el primer evento que se produzca despues del disconnect de B
		when (Disconnect_A<>m.DisconnectVOLTE_Time_A or DisconnectVOLTE_Time_A is null) and (Disconnect_A<>m.Disconnect_Time_A or Disconnect_Time_A is null) then
			(case when rrcVOLTE.msgtime<=rrc.msgtime or (rrcVOLTE.msgtime is not null and rrc.msgtime is null) then rrcVOLTE.bcch
				when rrcVOLTE.msgtime>rrc.msgtime or (rrcVOLTE.msgtime is null and rrc.msgtime is not null) then rrc.bcch
			end)
	end as Disconnect_freq,

 --Para el inicio tomamos los eventos de lcc_markers_time, dependiendo del tipo de llamada:
--	CSFB: Extended Service Request
--	SRVCC/HO/VOLTE: Trying
--	CS: CM Service Request/Call Confirmed
--	Si alguno de estos eventos o en su defecto, tomaremos el Dial
	case when (is_CSFB_A is not null) then isnull(ExtendedSR_tech_A,Dial_tech)
		 when (is_SRVCC_A is not null or is_VOLTE_HO_A is not null or is_VOLTE_A is not null) then isnull(Trying_tech_A,Dial_tech)
		 when (is_CS_A is not null) then (case when CMServiceRequest_tech_A is not null then CMServiceRequest_tech_A else CallConfirmed_tech_A end)
	else (case when isnull(CMServiceRequest_tech_A,CallConfirmed_tech_A) is not null 
			   then isnull(CMServiceRequest_tech_A,CallConfirmed_tech_A) 
			   else Dial_tech end)
	end as Start_band,

	case when (is_CSFB_A is not null) then isnull(ExtendedSR_bcch_A,Dial_bcch)
		 when (is_SRVCC_A is not null or is_VOLTE_HO_A is not null or is_VOLTE_A is not null) then isnull(Trying_bcch_A,Dial_bcch)
		 when (is_CS_A is not null) then (case when CMServiceRequest_bcch_A is not null then CMServiceRequest_bcch_A else CallConfirmed_bcch_A end)
	else (case when isnull(CMServiceRequest_bcch_A,CallConfirmed_bcch_A) is not null 
		       then isnull(CMServiceRequest_bcch_A,CallConfirmed_bcch_A) 
			   else Dial_bcch end)
	end as Start_freq,

	-------------------------------------------
	case 
		when is_CSFB_B='CSFB' then ExtendedSR_tech_B
	end as CSFB_band_B,
	case 
		when is_CSFB_B='CSFB' then ExtendedSR_bcch_B
	end as CSFB_freq_B,

	case 
		when is_VOLTE_B ='VOLTE' or is_SRVCC_B='SRVCC' or t.is_VOLTE_HO_B='VOLTE_HO' then Trying_tech_B		
	end as Trying_band_B,
	case 
		when is_VOLTE_B ='VOLTE' or is_SRVCC_B='SRVCC' or t.is_VOLTE_HO_B='VOLTE_HO' then Trying_bcch_B
	end as Trying_freq_B,
	
	
	case 
		when is_CSFB_B='CSFB' or is_CS_B='CS' then 
			(case when CMServiceRequest_tech_B is not null then CMServiceRequest_tech_B else CallConfirmed_tech_B end)
	end as CMService_band_B,
	case 
		when is_CSFB_B='CSFB' or is_CS_B='CS' then 
			(case when CMServiceRequest_bcch_B is not null then CMServiceRequest_bcch_B else CallConfirmed_bcch_B end)
	end as CMService_freq_B,
	
	case 
		when is_VOLTE_B ='VOLTE' or is_SRVCC_B='SRVCC' or t.is_VOLTE_HO_B='VOLTE_HO' then Ringing_tech_B
		when is_CSFB_B='CSFB' or is_CS_B='CS' then Alerting_tech_B
	end as Alerting_band_B,
	case 
		when is_VOLTE_B ='VOLTE' or is_SRVCC_B='SRVCC' or t.is_VOLTE_HO_B='VOLTE_HO' then Ringing_bcch_B
		when is_CSFB_B='CSFB' or is_CS_B='CS' then Alerting_bcch_B
	end as Alerting_freq_B,

	case 
		when is_VOLTE_B ='VOLTE' then Accept_tech_B
		when is_SRVCC_B='SRVCC' or t.is_VOLTE_HO_B='VOLTE_HO' then --Identificamos el connect más cercano al primer registro de MOS (similar a la lógica del connectAck):
			--Ambos Connect se producen antes del primer registro de mos, nos quedamos con el último Connect
			case when m.min_Time_Mos>=m.Accept_time_B and m.min_Time_Mos>=m.Connect_Time_B then 
				(case when Accept_time_B>=Connect_Time_B then m.Accept_tech_B else m.Connect_tech_B end)
			--Connect VOLTE antes del primer registro de MOS
			when m.min_Time_Mos>=m.Accept_time_B then m.Accept_tech_B
			--Connect no VOLTE antes del primer registro de MOS
			when m.min_Time_Mos>=m.Connect_Time_B then m.Connect_tech_B 
			--No hay mos, nos quedamos con el último Connect que se produzca 
			when m.min_Time_Mos is null then
				(case when Accept_time_B>=Connect_Time_B or (Accept_time_B is not null and Connect_Time_B is null) then Accept_tech_B 
					when Accept_time_B>Connect_Time_B or (Accept_time_B is null and Connect_Time_B is not null) then Connect_tech_B
				end)
			end
		when is_CSFB_B='CSFB' or is_CS_B='CS' then Connect_tech_B
	end as Connect_band_B,
	case 
		when is_VOLTE_B ='VOLTE' then Accept_bcch_B
		when is_SRVCC_B='SRVCC' or t.is_VOLTE_HO_B='VOLTE_HO' then --Identificamos el connect más cercano al primer registro de MOS (similar a la lógica del connectAck):
			--Ambos Connect se producen antes del primer registro de mos, nos quedamos con el último Connect
			case when m.min_Time_Mos>=m.Accept_time_B and m.min_Time_Mos>=m.Connect_Time_B then 
				(case when Accept_time_B>=Connect_Time_B then m.Accept_bcch_B else m.Connect_bcch_B end)
			--Connect VOLTE antes del primer registro de MOS
			when m.min_Time_Mos>=m.Accept_time_B then m.Accept_bcch_B
			--Connect no VOLTE antes del primer registro de MOS
			when m.min_Time_Mos>=m.Connect_Time_B then m.Connect_bcch_B 
			--No hay mos, nos quedamos con el último Connect que se produzca 
			when m.min_Time_Mos is null then
				(case when Accept_time_B>=Connect_Time_B or (Accept_time_B is not null and Connect_Time_B is null) then Accept_bcch_B 
					when Accept_time_B>Connect_Time_B or (Accept_time_B is null and Connect_Time_B is not null) then Connect_bcch_B
				end)
			end
		when is_CSFB_B='CSFB' or is_CS_B='CS' then Connect_bcch_B
	end as Connect_freq_B,

	case 
		when Disconnect_B=m.DisconnectVOLTE_Time_B then DisconnectVOLTE_tech_B
		when Disconnect_B=m.Disconnect_Time_B then Disconnect_tech_B
		--el primer evento que se produzca despues del disconnect de B
		when (Disconnect_B<>m.DisconnectVOLTE_Time_B or DisconnectVOLTE_Time_B is null) and (Disconnect_B<>m.Disconnect_Time_B or Disconnect_Time_B is null) then
			(case when rrcBVOLTE.msgtime<=rrcB.msgtime or (rrcBVOLTE.msgtime is not null and rrcB.msgtime is null) then rrcBVOLTE.technology collate SQL_Latin1_General_CP1_CI_AS 
				when rrcBVOLTE.msgtime>rrcB.msgtime or (rrcBVOLTE.msgtime is null and rrcB.msgtime is not null) then rrcB.technology collate SQL_Latin1_General_CP1_CI_AS
			end)
	end as Disconnect_band_B,
	case 
		when Disconnect_B=m.DisconnectVOLTE_Time_B then DisconnectVOLTE_bcch_B
		when Disconnect_B=m.Disconnect_Time_B then Disconnect_bcch_B
		--el primer evento que se produzca despues del disconnect de B
		when (Disconnect_B<>m.DisconnectVOLTE_Time_B or DisconnectVOLTE_Time_B is null) and (Disconnect_B<>m.Disconnect_Time_B or Disconnect_Time_B is null) then
			(case when rrcBVOLTE.msgtime<=rrcB.msgtime or (rrcBVOLTE.msgtime is not null and rrcB.msgtime is null) then rrcBVOLTE.bcch 
				when rrcBVOLTE.msgtime>rrcB.msgtime or (rrcBVOLTE.msgtime is null and rrcB.msgtime is not null) then rrcB.bcch
			end)
	end as Disconnect_freq_B,
	
--	Dependiendo del tipo de llamada, el comienzo de la llamada será:
--	CSFB: Extended Service Request
--	SRVCC/HO/VOLTE: Trying
--	CS: CM Service Request/Call Confirmed
--	Si alguno de estos eventos o en su defecto, tomaremos el Dial
	case when (is_CSFB_B is not null) then isnull(ExtendedSR_tech_B,Dial_tech)
		 when (is_SRVCC_B is not null or is_VOLTE_HO_B is not null or is_VOLTE_B is not null) then isnull(Trying_tech_B,Dial_tech)
		 when (is_CS_B is not null) then (case when CMServiceRequest_tech_B is not null then CMServiceRequest_tech_B else CallConfirmed_tech_B end)
	else (case when isnull(CMServiceRequest_tech_B,CallConfirmed_tech_B) is not null 
			   then isnull(CMServiceRequest_tech_B,CallConfirmed_tech_B) 
			   else Dial_tech end)
	end as Start_band_B,

	case when (is_CSFB_B is not null) then isnull(ExtendedSR_bcch_B,Dial_bcch)
		 when (is_SRVCC_B is not null or is_VOLTE_HO_B is not null or is_VOLTE_B is not null) then isnull(Trying_bcch_B,Dial_bcch)
		 when (is_CS_B is not null) then (case when CMServiceRequest_bcch_B is not null then CMServiceRequest_bcch_B else CallConfirmed_bcch_B end)
	else (case when isnull(CMServiceRequest_bcch_B,CallConfirmed_bcch_B) is not null 
			   then isnull(CMServiceRequest_bcch_B,CallConfirmed_bcch_B) 
			   else Dial_bcch end)
	end as Start_freq_B

into _VOICE_EVENT_FREQ
from _info_Calls t inner join lcc_markers_time m on t.sessionid=m.sessionid
	left join _RRC rrc on t.sessionid=rrc.sessionid
	left join _RRCB rrcB on t.sessionid=rrcB.sessionidA
	left join _RRC_VOLTE rrcVOLTE on t.sessionid=rrcVOLTE.sessionid
	left join _RRCB_VOLTE rrcBVOLTE on t.sessionid=rrcBVOLTE.sessionidA

exec sp_lcc_dropifexists '_VOICE_EVENT_TIME'
select	t.sessionid,
	--Tomamos el inicio de la llamada dependiendo de como se clasifique el tipo de llamada.
	--Si la llamada es CSFB, tomamos el instante del ExtendedSR
	--Si la llamada es VOLTE/SRVCC/HO, tomamos el instante de Trying
	--Si la llamada es CS tomamos el CMServiceRequest o el CallConfirmed
	--En su defecto tomamos el instante del Dial

	--Para el fin de la llamada seguimos la misma lógica de disconnect que en la clasificación de llamadas
	
	case when (is_CSFB_A is not null) then isnull(ExtendedSR_time_A,m.Dial_time)
		 when (is_SRVCC_A is not null or is_VOLTE_HO_A is not null or is_VOLTE_A is not null) then isnull(Trying_time_A,m.Dial_time)
		 when (is_CS_A is not null) then (case when CMServiceRequest_time_A is not null then CMServiceRequest_time_A else CallConfirmed_time_A end)
	else m.Dial_time
	end as Start_time,

	case 
		when Disconnect_A=m.DisconnectVOLTE_Time_A then DisconnectVOLTE_Time_A
		when Disconnect_A=m.Disconnect_Time_A then Disconnect_Time_A
		--el primer evento que se produzca despues del disconnect de B
		when (Disconnect_A<>m.DisconnectVOLTE_Time_A or DisconnectVOLTE_Time_A is null) and (Disconnect_A<>m.Disconnect_Time_A or Disconnect_Time_A is null) then
			(case when rrcVOLTE.msgtime<=rrc.msgtime or (rrcVOLTE.msgtime is not null and rrc.msgtime is null) then rrcVOLTE.msgtime
				when rrcVOLTE.msgtime>rrc.msgtime or (rrcVOLTE.msgtime is null and rrc.msgtime is not null) then rrc.msgtime
			end)
	end as Disconnect_time,
	-------------------------------------------
	
	case when (is_CSFB_B is not null) then isnull(ExtendedSR_time_B,m.Dial_time)
		 when (is_SRVCC_B is not null or is_VOLTE_HO_B is not null or is_VOLTE_B is not null) then isnull(Trying_time_B,m.Dial_time)
		 when (is_CS_B is not null) then (case when CMServiceRequest_time_B is not null then CMServiceRequest_time_B else CallConfirmed_time_B end)
	else m.Dial_time
	end as Start_time_B,

	case 
		when Disconnect_B=m.DisconnectVOLTE_Time_B then DisconnectVOLTE_Time_B
		when Disconnect_B=m.Disconnect_Time_B then Disconnect_Time_B
		--el primer evento que se produzca despues del disconnect de A
		when (Disconnect_B<>m.DisconnectVOLTE_Time_B or DisconnectVOLTE_Time_B is null) and (Disconnect_B<>m.Disconnect_Time_B or Disconnect_Time_B is null) then
			(case when rrcBVOLTE.msgtime<=rrcB.msgtime or (rrcBVOLTE.msgtime is not null and rrcB.msgtime is null) then rrcBVOLTE.msgtime
				when rrcBVOLTE.msgtime>rrcB.msgtime or (rrcBVOLTE.msgtime is null and rrcB.msgtime is not null) then rrcB.msgtime
			end)
	end as Disconnect_time_B

into _VOICE_EVENT_TIME
from _info_Calls t inner join lcc_markers_time m on t.sessionid=m.sessionid
	left join _RRC rrc on t.sessionid=rrc.sessionid
	left join _RRCB rrcB on t.sessionid=rrcB.sessionidA
	left join _RRC_VOLTE rrcVOLTE on t.sessionid=rrcVOLTE.sessionid
	left join _RRCB_VOLTE rrcBVOLTE on t.sessionid=rrcBVOLTE.sessionidA


--**************************************************************************************
------------------ CALL SETUP TIME ----------------------------
--DGP 10/08/2015: Modificado el cálculo del CST:
--				Alerting: se elimina el tiempo desde el Dial hasta el RRC connect Request/Paging
--				Connect: nuevo cálculo Start = ,End = Connect A party – (Connect B party – Alerting B party)
--				En el caso de que el Alerting Time o el Connect Time para MTs sea negativo (Fake Alertings,
--				problemas de Herramienta, cogemos la info de vResultsKPI para la parte A)

--ERC 31/03/2016: Se modifica el cálculo del CST para el Connect de las llamadas M2M
--		- Se va a utilizar KPIID 10109 de SQ:	Dial2Connect(origen) - AnswTime(destino)
--		- Solo puede aplicarse a las BBDD NO VOLTE por ser versiones diferentes
--			*	En VOLTE, para las llamadas CS/CS, no se calcula este KPIID
--			*	En la parte del "Calculo definitivo CST" se va a diferenciar por nombre de la bbdd
--				Si contiene VOLTE, se realizara el calculo antiguo 
--				Para el resto de BBDD, se utilizara el KPIID:

--Start = Dial Command (Marker) y duración hasta el Connect, quitandole el AnsweringTime del llamado
--Hace los calculos en funcion de la dirección  de la llamada por lo que no hay que sacarlo para parte A y B por separado

--select SessionId, min(duration) as duration, min(StartTime) as RRC_StartA 
--into _RRC_StartC_10109
--from vResultsKPI
--where KPIId=10109
--	and ErrorCode=0
--	and SessionId>@maxSession -- We only get the sessionIds to import
--group by sessionid

----------------------------------------------------------------

----Start = StartTime del terminal en KPI 10100 y duracion hasta Alerting
--select SessionId, min(duration) as duration, min(StartTime) as RRC_StartA 
--into _RRC_StartA 
--from vResultsKPI
--where KPIId=10100
--	and ErrorCode=0
--	and SessionId>@maxSession -- We only get the sessionIds to import
--group by sessionid

----Start = StartTime del terminal en KPI 10101 y duración hasta el connect
--select SessionId, min(duration) as duration, min(StartTime) as RRC_StartC 
--into _RRC_StartC 
--from vResultsKPI
--where KPIId=10101
--	and ErrorCode=0
--	and SessionId>@maxSession -- We only get the sessionIds to import
--group by sessionid

------------Start = Alerting time del terminal A en KPI 20100 hasta el Disconnect
----------select SessionId, min(duration) as duration, min(StartTime) as Alerting_Time_A 
----------into _Alerting_StartA 
----------from vResultsKPI
----------where KPIId=20100
----------	and ErrorCode=0
----------	and SessionId>@maxSession -- We only get the sessionIds to import
----------group by sessionid

------------Start = Connect Time del terminal A en KPI 20101 hasta el Disconnect
----------select SessionId, min(duration) as duration, min(StartTime) as Connect_Time_A 
----------into _Connect_StartA
----------from vResultsKPI
----------where KPIId=20101
----------	and ErrorCode=0
----------	and SessionId>@maxSession -- We only get the sessionIds to import
----------group by sessionid

----Start = StartTime del terminal en KPI 11000 y duracion hasta Alerting
--select SessionId, min(duration) as duration, min(StartTime) as Alerting_Time_A 
--into _VOLTE_StartA 
--from vResultsKPI
--where KPIId=11000
--	and ErrorCode=0
--	and SessionId>@maxSession -- We only get the sessionIds to import
--group by sessionid

----Start = StartTime del terminal en KPI 11010 y duración hasta el connect
--select SessionId, min(duration) as duration, min(StartTime) as Connect_Time_A 
--into _VOLTE_StartC 
--from vResultsKPI
--where KPIId=11010
--	and ErrorCode=0
--	and SessionId>@maxSession -- We only get the sessionIds to import
--group by sessionid

----Start = StartTime del terminal en KPI 11000 y duracion hasta Alerting PARTE B
--select b.SessionIdA, min(v.duration) as duration, min(v.StartTime) as Alerting_Time_B 
--into _VOLTE_StartAB
--from vResultsKPI v, sessionsB b
--where KPIId=11000
--	and ErrorCode=0
--	and v.sessionid=b.sessionid
--	and b.SessionIdA>@maxSession -- We only get the sessionIds to import
--group by b.sessionidA

----Start = StartTime del terminal en KPI 11010 y duración hasta el connect PARTE B
--select b.SessionIdA, min(v.duration) as duration, min(v.StartTime) as Connect_Time_B
--into _VOLTE_StartCB 
--from vResultsKPI v, sessionsB b
--where KPIId=11010
--	and ErrorCode=0
--	and v.sessionid=b.sessionid
--	and b.SessionIdA>@maxSession -- We only get the sessionIds to import
--group by b.sessionidA

--DGP 21/10/2016
--End = UMTS Start time del terminal Originante
exec sp_lcc_dropifexists '_CSFB_StartU_A'
select SessionId, min(duration) as duration, min(StartTime) as CSFB_Time_UA
into _CSFB_StartU_A 
from vResultsKPI
where KPIId=10175
	and ErrorCode=0
	and SessionId>@maxSession -- We only get the sessionIds to import
group by sessionid

exec sp_lcc_dropifexists '_CSFB_StartU_B'
select b.SessionIdA, min(v.duration) as duration, min(v.StartTime) as CSFB_Time_UB
into _CSFB_StartU_B 
from vResultsKPI v, sessionsB b
where KPIId=10175
	and ErrorCode=0
	and v.sessionid=b.sessionid
	and b.SessionIdA>@maxSession -- We only get the sessionIds to import
group by b.sessionidA

exec sp_lcc_dropifexists '_CSFB_StartA_A'
--End = Alerting Start time del terminal Originante
select SessionId, min(duration) as duration, min(StartTime) as CSFB_Time_AA 
into _CSFB_StartA_A 
from vResultsKPI
where KPIId=10178
	and ErrorCode=0
	and SessionId>@maxSession -- We only get the sessionIds to import
group by sessionid

exec sp_lcc_dropifexists '_CSFB_StartA_B'
select b.SessionIdA, min(v.duration) as duration, min(v.StartTime) as CSFB_Time_AB
into _CSFB_StartA_B 
from vResultsKPI v, sessionsB b
where KPIId=10178
	and ErrorCode=0
	and v.sessionid=b.sessionid
	and b.SessionIdA>@maxSession -- We only get the sessionIds to import
group by b.sessionidA

----------------------------------------------------------------
--Resto de info necesaria
exec sp_lcc_dropifexists '_Alert_Connect_AB'
select 
	SessionId, Alerting_Time_A, Alerting_Time_B, Connect_Time_A,Connect_Time_B,
	Ringing_time_A, Ringing_time_B, Accept_time_A, Accept_time_B,
	isnull(isnull(RRCConnect_time_A,convert(varchar(25),ExtendedSR_time_A,121)),convert(varchar(25),Dial_Time,121)) as Start_time_CS_A,
	isnull(isnull(RRCConnect_time_B,convert(varchar(25),ExtendedSR_time_B,121)),convert(varchar(25),Dial_Time,121)) as Start_time_CS_B,
	isnull(Request_time_A,convert(varchar(25),Dial_Time,121)) as Start_time_VOLTE_A,
	isnull(Request_time_B,convert(varchar(25),Dial_Time,121)) as Start_time_VOLTE_B
into _Alert_Connect_AB
from lcc_markers_time
where SessionId>@maxSession -- We only get the sessionIds to import


--	Calculo definitivo para el CST
--	M2F: Tomamos la diferencia de tiempo entre los markers siempre. 
--			Alerting: Si la llamada es 'CS' (Inicio: RRCConnectionRequest. Si es nulo, Extended Service Request. Si es nulo, Dial.
--											 Final: Alerting)
--					  Si la llamada es 'VOLTE' (Inicio: SIP INVITE Request. Si es nulo, Dial.
--												Final: SIP INVITE Ringing)
--			Connect: Si la llamada es 'CS' (Inicio: RRCConnectionRequest. Si es nulo, Extended Service Request. Si es nulo, Dial.
--											 Final: Connect)
--					  Si la llamada es 'VOLTE' (Inicio: SIP INVITE Request. Si es nulo, Dial.
--												Final: SIP INVITE Accept 200 OK)

--	M2M: Tomamos la diferencia de tiempo entre los markers siempre.
--			Alerting: Si la llamada es 'CS' (Inicio: RRCConnectionRequest. Si es nulo, Extended Service Request. Si es nulo, Dial.
--											 Final: Alerting)
--					  Si la llamada es 'VOLTE' (Inicio: SIP INVITE Request. Si es nulo, Dial.
--												Final: SIP INVITE Ringing)
--			Connect: Si la llamada es 'CS' (Inicio: RRCConnectionRequest. Si es nulo, Extended Service Request. Si es nulo, Dial.
--											 Final: Connect) - Answering Time de la otra parte de la llamada
--					  Si la llamada es 'VOLTE' (Inicio: SIP INVITE Request. Si es nulo, Dial.
--												Final: SIP INVITE Accept 200 OK) - Answering Time de la otra parte de la llamada
exec sp_lcc_dropifexists '_CST_ALL'
select c.sessionid, 
	------------------------------
	--	Calculos para los ALERTING:
	case
		when (c.calltype like '%L%' or c.calltype like '%?%') then -- Si es M2F : INDOOR
			case 
				when ct.AsideType='CS'		then datediff(ms, restA.Start_time_CS_A, restA.Alerting_time_A) 
				when ct.AsideType='VOLTE'	then datediff(ms, restA.Start_time_VOLTE_A, restA.Ringing_time_A)
			end
		else -- Si es M2M
			case 
				when ct.AsideType='CS'		then datediff(ms, restA.Start_time_CS_A, restA.Alerting_time_A)
				when ct.AsideType='VOLTE'	then datediff(ms, restA.Start_time_VOLTE_A, restA.Ringing_time_A)
			end
	end as alertingMO,
	-----------------
	case
		when (c.calltype like '%L%' or c.calltype like '%?%') then -- Si es M2F  : INDOOR
			case 
				when ct.AsideType='CS'	then datediff(ms, restA.Start_time_CS_A, restA.Alerting_time_A)
				when ct.AsideType='VOLTE' then datediff(ms, restA.Start_time_VOLTE_A, restA.Ringing_time_A)
			end
		else -- Si es M2M
			case 
				when ct.BsideType='CS'		then datediff(ms, restA.Start_time_CS_B, restA.Alerting_time_B)
				when ct.BsideType='VOLTE'	then datediff(ms, restA.Start_time_VOLTE_B, restA.Ringing_time_B)
			end
	end as alertingMT, 

	------------------------------
	--	Calculos para los CONNECT:
	case
		when (c.calltype like '%L%' or c.calltype like '%?%') then -- Si es M2F : INDOOR
		case 
			when ct.AsideType='CS'		then datediff(ms, restA.Start_time_CS_A, restA.Connect_Time_A)
			when ct.AsideType='VOLTE'	then datediff(ms, restA.Start_time_VOLTE_A, restA.Accept_Time_A)
		end
	else -- Si es M2M
		case
			when ct.AsideType='CS'	  and ct.BsideType='CS'		then datediff(ms, restA.Start_time_CS_A, restA.Connect_Time_A) - datediff(ms, restA.Alerting_Time_B, restA.Connect_Time_B) -- Se le quita el Answering Time	
			when ct.AsideType='VOLTE' and ct.BsideType='VOLTE'  then datediff(ms, restA.Start_time_VOLTE_A, restA.Accept_Time_A)  - datediff(ms, restA.Ringing_Time_B,  restA.Accept_Time_B)   -- Se le quita el Answering Time		
			when ct.AsideType='VOLTE' and ct.BsideType='CS'		then datediff(ms, restA.Start_time_VOLTE_A, restA.Accept_Time_A)  - datediff(ms, restA.Alerting_Time_B, restA.Connect_Time_B) -- Se le quita el Answering Time	
			when ct.AsideType='CS'    and ct.BsideType='VOLTE'  then datediff(ms, restA.Start_time_CS_A, restA.Connect_Time_A) - datediff(ms, restA.Ringing_Time_B,  restA.Accept_Time_B)   -- Se le quita el Answering Time	

			--when ct.AsideType='CS'	and ct.BsideType='CS'		then rrcC10109.duration -- Nuevo KPIID desde Dial hasta el Connect en origen, descontando el Answ. Time del destino
			--when ct.AsideType='VOLTE' and ct.BsideType='VOLTE'  then datediff(ms, restA.Dial_time, restA.Accept_Time_A)  - datediff(ms, restA.Ringing_Time_B,  restA.Accept_Time_B)   -- Se le quita el Answering Time		
			--when ct.AsideType='VOLTE' and ct.BsideType='CS'		then datediff(ms, restA.Dial_time, restA.Accept_Time_A)  - datediff(ms, restA.Alerting_Time_B, restA.Connect_Time_B) -- Se le quita el Answering Time	
			--when ct.AsideType='CS'    and ct.BsideType='VOLTE'  then datediff(ms, restA.Dial_Time, restA.Connect_Time_A) - datediff(ms, restA.Ringing_Time_B,  restA.Accept_Time_B)   -- Se le quita el Answering Time	
		end
	end as connectMO,
	-----------------
	case
	when (c.calltype like '%L%' or c.calltype like '%?%') then -- Si es M2F
		case 
			when ct.AsideType='CS'		then datediff(ms, restA.Start_time_CS_A, restA.Connect_Time_A)
			when ct.AsideType='VOLTE'	then datediff(ms, restA.Start_time_VOLTE_A, restA.Accept_Time_A)
		end 
	else -- Si es M2M
		case
			when ct.AsideType='CS'	  and ct.BsideType='CS'		then datediff(ms, restA.Start_time_CS_B,restA.Connect_Time_B) - datediff(ms, restA.Alerting_Time_A, restA.Connect_Time_A) -- Se le quita el Answering Time	
			when ct.AsideType='VOLTE' and ct.BsideType='VOLTE'  then datediff(ms, restA.Start_time_VOLTE_B, restA.Accept_Time_B) - datediff(ms, restA.Ringing_Time_A,  restA.Accept_Time_A)   -- Se le quita el Answering Time		
			when ct.AsideType='VOLTE' and ct.BsideType='CS'		then datediff(ms, restA.Start_time_VOLTE_B,restA.Connect_Time_B) - datediff(ms, restA.Ringing_Time_A,  restA.Accept_Time_A)   -- Se le quita el Answering Time	
			when ct.AsideType='CS'    and ct.BsideType='VOLTE'	then datediff(ms, restA.Start_time_CS_B, restA.Accept_Time_B) - datediff(ms, restA.Alerting_Time_A, restA.Connect_Time_A) -- Se le quita el Answering Time	
			
			--when ct.AsideType='CS'	  and ct.BsideType='CS'		then rrcC10109.duration -- Nuevo KPIID desde Dial hasta el Connect en origen, descontando el Answ. Time del destino
			--when ct.AsideType='VOLTE' and ct.BsideType='VOLTE'  then datediff(ms, restA.Dial_time, restA.Accept_Time_B) - datediff(ms, restA.Ringing_Time_A,  restA.Accept_Time_A)   -- Se le quita el Answering Time		
			--when ct.AsideType='VOLTE' and ct.BsideType='CS'		then datediff(ms, restA.Dial_Time,restA.Connect_Time_B) - datediff(ms, restA.Ringing_Time_A,  restA.Accept_Time_A)   -- Se le quita el Answering Time	
			--when ct.AsideType='CS'    and ct.BsideType='VOLTE'	then datediff(ms, restA.Dial_time, restA.Accept_Time_B) - datediff(ms, restA.Alerting_Time_A, restA.Connect_Time_A) -- Se le quita el Answering Time	
		end
	end as connectMT,
	-----------------
	ct.AsideType, ct.BsideType,
	csUA.duration as CSFB_Time_UA, 
	csUB.duration as CSFB_Time_UB, 
	csAA.duration as CSFB_Time_AA,
	csAB.duration as CSFB_Time_AB

into  _CST_ALL
from CallAnalysis c

	left outer join _Alert_Connect_AB restA on restA.SessionId=c.SessionId

	left outer join _info_Calls ct		on ct.sessionid=c.sessionid

	left outer join _CSFB_StartU_A csUA on csUA.SessionId=c.SessionId

	left outer join _CSFB_StartU_B csUB on csUB.SessionIdA=c.SessionId

	left outer join _CSFB_StartA_A csAA on csAA.sessionid=c.sessionid

	left outer join _CSFB_StartA_B csAB on csAB.SessionIdA=c.sessionid

Where c.SessionId>@maxSession -- We only get the sessionIds to import


---------------------------------------------------------------- Fin del IF bbdd es VOLTE

--**************************************************************************************


-------------------- Tech Tables ------------------------------
-- Tables containing radio values for each call

---------------------- A side ------------------------------------------------------------------------------------

--GSM/WCDMA/LTE Tech Radio Initial/End

exec sp_lcc_dropifexists '_TECH_INI_FIN'
select vef.sessionid,
case when vef.Start_Band like '%DCS%' then replace(vef.Start_Band,'DCS','GSM1800')	
	 else vef.Start_Band
end as Start_Band,
case when vef.Start_Band like '%GSM%' or vef.Start_Band like '%DCS%'  then 'GSM'
	 when vef.Start_Band like '%UMTS%' then 'UMTS'
	 when vef.Start_Band like '%LTE%' then 'LTE' 
end as Start_tech,
case when vef.Disconnect_Band like '%DCS%' then replace(vef.Disconnect_Band,'DCS','GSM1800')		
	 else vef.Disconnect_Band
end as Disconnect_Band,
case when vef.Disconnect_Band like '%GSM%' or vef.Disconnect_Band like '%DCS%'  then 'GSM'
	 when vef.Disconnect_Band like '%UMTS%' then 'UMTS'
	 when vef.Disconnect_Band like '%LTE%' then 'LTE' 
end as Disconnect_Tech,
case when vef.Start_Band_B like '%DCS%' then replace(vef.Start_Band_B,'DCS','GSM1800')
	 else vef.Start_Band_B
end as Start_Band_B,
case when vef.Start_Band_B like '%GSM%' or vef.Start_Band_B like '%DCS%'  then 'GSM'
	 when vef.Start_Band_B like '%UMTS%' then 'UMTS'
	 when vef.Start_Band_B like '%LTE%' then 'LTE' 
end as Start_tech_B,
case when vef.Disconnect_Band_B like '%DCS%' then replace(vef.Disconnect_Band_B,'DCS','GSM1800')
	 else vef.Disconnect_Band_B
end as Disconnect_Band_B,
case when vef.Disconnect_Band_B like '%GSM%' or vef.Disconnect_Band_B like '%DCS%'  then 'GSM'
	 when vef.Disconnect_Band_B like '%UMTS%' then 'UMTS'
	 when vef.Disconnect_Band_B like '%LTE%' then 'LTE' 
end as Disconnect_Tech_B

into _TECH_INI_FIN
from _VOICE_EVENT_FREQ vef
where vef.SessionId>@maxSession -- We only get the sessionIds to import


--GSM/WCDMA/LTE  Radio Initial (Radio Values)
exec sp_lcc_dropifexists '_TECH_RADIO_INI_A'
select t.sessionid,
case when vef.Start_Band like '%GSM%' then t.Freq end as BCCH,
case when vef.Start_Band like '%GSM%' then t.signal end as RxLev,
case when vef.Start_Band like '%GSM%' then t.quality end as RxQual,
case when vef.Start_Band like '%GSM%' then t.cell end as BSIC,
case when vef.Start_Band like '%UMTS%' then t.Freq end as UARFCN,
case when vef.Start_Band like '%UMTS%' then t.signal end as RSCP,
case when vef.Start_Band like '%UMTS%' then t.quality end as EcIo,
case when vef.Start_Band like '%UMTS%' then t.cell end as PSC,
t.RNCID,
case when vef.Start_Band like '%LTE%' then t.Freq end as EARFCN,
case when vef.Start_Band like '%LTE%' then t.signal end as RSRP,
case when vef.Start_Band like '%LTE%' then t.quality end as RSRQ,
case when (vef.Start_Band like'%LTE%' and t.SINR0 is not null and t.SINR1 is not null) then 1.0 * (t.SINR0+t.SINR1)/2.0 end as SINR,
case when vef.Start_Band like '%LTE%' then t.cell end as PCI,
t.CId,
t.LAC

into _TECH_RADIO_INI_A
from _TECH_INI_FIN vef, lcc_serving_cell_table t
		left outer join 
-- **************************************************************************************************************	
						--Para obtener la tecnología de inicio nos quedamos con el tiempo anterior a los siguientes eventos:
						--Si la llamada es CSFB: antes de Extended SR
						--Si la llamada es VOLTE,SRVCC o VOLTE_HO: antes del Trying 
						--Si la llamada se produce en 3G/2G: antes del CMServiceRequest o el CallConfirmed(el otro lado de la llamada)
						
						--Si no tenemos ninguno de estos eventos, nos quedamos con la primera muestra de la serving cell 
-- **************************************************************************************************************
				(Select s.sessionid, case when max(idm.idm) is null then min(id) else max(idm.idm) end as id
					from lcc_serving_cell_table s
							left outer join (--Evento antes del CMService-CallConfirmed/Trying/ExtendedSR
												select t1.sessionid,max(id) as idm
												from lcc_serving_cell_table t1, _VOICE_EVENT_TIME t2
												where t1.sessionid=t2.sessionid
												and t1.msgtime<=Start_time
												and t1.side='A'
												group by t1.sessionid) idm on idm.sessionid=s.sessionid
					where s.side='A'
					
				 group by s.sessionid
				) mi on t.SessionId=mi.SessionId

-- **************************************************************************************************************
where t.id=mi.id
and vef.sessionid=t.sessionid
and t.side='A'
and t.SessionId>@maxSession -- We only get the sessionIds to import


--GSM/WCDMA/LTE Radio Final (Radio Values)
exec sp_lcc_dropifexists '_TECH_RADIO_FIN_A'
select t.sessionid,
case when vef.Disconnect_Band like '%GSM%' then t.Freq end as BCCH,
case when vef.Disconnect_Band like '%GSM%' then t.signal end as RxLev,
case when vef.Disconnect_Band like '%GSM%' then t.quality end as RxQual,
case when vef.Disconnect_Band like '%GSM%' then t.cell end as BSIC,
case when vef.Disconnect_Band like '%UMTS%' then t.Freq end as UARFCN,
case when vef.Disconnect_Band like '%UMTS%' then t.signal end as RSCP,
case when vef.Disconnect_Band like '%UMTS%' then t.quality end as EcIo,
case when vef.Disconnect_Band like '%UMTS%' then t.cell end as PSC,
t.RNCID,
case when vef.Disconnect_Band like '%LTE%' then t.Freq end as EARFCN,
case when vef.Disconnect_Band like '%LTE%' then t.signal end as RSRP,
case when vef.Disconnect_Band like '%LTE%' then t.quality end as RSRQ,
case when (vef.Disconnect_Band like '%LTE%' and t.SINR0 is not null and t.SINR1 is not null) then 1.0 * (t.SINR0+t.SINR1)/2.0 end as SINR,
case when vef.Disconnect_Band like '%LTE%' then t.cell end as PCI,
t.CId,
t.LAC

into _TECH_RADIO_FIN_A
from _TECH_INI_FIN vef,lcc_serving_cell_table t
		left outer join 
-- **************************************************************************************************************
						--Para obtener la tecnología de fin nos quedamos con el tiempo anterior al DISCONNECT de la llamada
						--Si no tenemos DISCONNECT, nos quedamos con la última muestra de la serving cell 
-- **************************************************************************************************************
				(Select s.sessionid, case when max(idm.idm) is null then max(id) else max(idm.idm) end as id
					from lcc_serving_cell_table s
							left outer join (--Evento antes del disconnect
												select t1.sessionid,max(id) as idm
												from lcc_serving_cell_table t1, _VOICE_EVENT_TIME t2
												where t1.sessionid=t2.sessionid
												and t1.msgtime<=Disconnect_time
												and t1.side='A'
												group by t1.sessionid) idm on idm.sessionid=s.sessionid
					where s.side='A'
				 group by s.sessionid) mi on t.SessionId=mi.SessionId
-- **************************************************************************************************************
where t.id=mi.id
and vef.sessionid=t.sessionid
and t.side='A'
and t.SessionId>@maxSession -- We only get the sessionIds to import


--GSM/WCDMA/LTE Radio AVG (Radio Values)
exec sp_lcc_dropifexists '_TECH_RADIO_AVG_A'
select  t.sessionid,
		MAX(case when t.technology like '%GSM%' then cast(t.hopping as integer) end) as Hopping,
		log10(avg(power(10.0E0,(case when t.band  like '%GSM%' and t.signal is not null then 1.0 * t.signal end)/10.0E0)))*10 as RxLev,
		log10(avg(power(10.0E0,(case when t.band  like '%GSM%' and t.quality is not null then 1.0 * t.quality end)/10.0E0)))*10 as RxQual,
		MIN(case when t.technology like '%GSM%' then t.signal end) as RxLev_min,
		MIN(case when t.technology like '%GSM%' then t.quality end) as RxQual_min,
		log10(avg(power(10.0E0,(case when t.band  like '%UMTS%' and t.signal is not null then 1.0 * t.signal end)/10.0E0)))*10 as RSCP,
		log10(avg(power(10.0E0,(case when t.band  like '%UMTS%' and t.quality is not null then 1.0 * t.quality end)/10.0E0)))*10 as EcIo,
		MIN(case when t.technology like '%UMTS%' then t.signal end) as RSCP_min,
		MIN(case when t.technology like '%UMTS%' then t.quality end) as EcIo_min,
		log10(avg(power(10.0E0,(case when t.band  like '%LTE%' and t.signal is not null then 1.0 * t.signal end)/10.0E0)))*10 as RSRP,
		log10(avg(power(10.0E0,(case when t.band  like '%LTE%' and t.quality is not null then 1.0 * t.quality end)/10.0E0)))*10 as RSRQ,
		MIN(case when t.technology like '%LTE%' then t.signal end) as RSRP_min,
		MIN(case when t.technology like '%LTE%' then t.quality end) as RSRQ_min,
		--SUM(case when t.band = 'GSM' then 1 else 0 end) as GSM_Samples,
		--SUM(case when t.band = 'DCS' then 1 else 0 end) as DCS_Samples,
		--SUM(case when t.band = 'UMTS2100' then 1 else 0 end) as UMTS2100_Samples,
		--SUM(case when t.band = 'UMTS900' then 1 else 0 end) as UMTS900_Samples,
		--SUM(case when t.band = 'LTE_800' then 1 else 0 end) as LTE800_Samples,
		--SUM(case when t.band = 'LTE_1800' then 1 else 0 end) as LTE1800_Samples,
		--SUM(case when t.band = 'LTE_2600' then 1 else 0 end) as LTE2600_Samples,
		--SUM(case when t.band in ('GSM', 'DCS') and t.quality is not null then 1 end) as RxQual_samples,
		SUM(case when t.band in ('GSM', 'DCS') and t.quality=0 then 1 end) as RxQual_0,
		SUM(case when t.band in ('GSM', 'DCS') and t.quality=1 then 1 end) as RxQual_1,
		SUM(case when t.band in ('GSM', 'DCS') and t.quality=2 then 1 end) as RxQual_2,
		SUM(case when t.band in ('GSM', 'DCS') and t.quality=3 then 1 end) as RxQual_3,
		SUM(case when t.band in ('GSM', 'DCS') and t.quality=4 then 1 end) as RxQual_4,
		SUM(case when t.band in ('GSM', 'DCS') and t.quality=5 then 1 end) as RxQual_5,
		SUM(case when t.band in ('GSM', 'DCS') and t.quality=6 then 1 end) as RxQual_6,
		SUM(case when t.band in ('GSM', 'DCS') and t.quality=7 then 1 end) as RxQual_7,
		log10(avg(power(10.0E0,(case when t.band = 'GSM' and t.quality is not null then 1.0 * t.quality end)/10.0E0)))*10 as RxQual_GSM,
		log10(avg(power(10.0E0,(case when t.band = 'DCS' and t.quality is not null then 1.0 * t.quality end)/10.0E0)))*10 as RxQual_DCS,
		--SUM(case when t.technology like '%UMTS%' and t.quality is not null then 1 end) as EcIo_samples,
		SUM(case when (t.technology like '%UMTS%' and t.quality > -2  and t.quality <= 0) then 1 end) as 'EcIo [0, -2)',
		SUM(case when (t.technology like '%UMTS%' and t.quality > -4  and t.quality <= -2) then 1 end) as 'EcIo [-2, -4)',
		SUM(case when (t.technology like '%UMTS%' and t.quality > -6  and t.quality <= -4) then 1 end) as 'EcIo [-4, -6)',
		SUM(case when (t.technology like '%UMTS%' and t.quality > -8  and t.quality <= -6) then 1 end) as 'EcIo [-6, -8)',
		SUM(case when (t.technology like '%UMTS%' and t.quality > -10  and t.quality <= -8) then 1 end) as 'EcIo [-8, -10)',
		SUM(case when (t.technology like '%UMTS%' and t.quality > -12  and t.quality <= -10) then 1 end) as 'EcIo [-10, -12)',
		SUM(case when (t.technology like '%UMTS%' and t.quality > -14  and t.quality <= -12) then 1 end) as 'EcIo [-12, -14)',
		SUM(case when (t.technology like '%UMTS%' and t.quality <= -14) then 1 end) as 'EcIo <= -14',
		log10(avg(power(10.0E0,(case when t.band = 'UMTS2100' and t.quality is not null then 1.0 * t.quality end)/10.0E0)))*10 as EcIo_UMTS2100,
		log10(avg(power(10.0E0,(case when t.band = 'UMTS900' and t.quality is not null then 1.0 * t.quality end)/10.0E0)))*10 as EcIo_UMTS900,
		avg(case when (t.technology like '%LTE%' and t.SINR0 is not null and t.SINR1 is not null) then 1.0 * (t.SINR0+t.SINR1)/2.0 end) as SINR

into _TECH_RADIO_AVG_A

from lcc_serving_cell_table t
left join
	(Select s.sessionid,case when max(idm.idm) is null then min(s.id) else max(idm.idm) end as id
	from lcc_serving_cell_table s
			left outer join (--Evento antes del CMService-CallConfirmed/Trying/ExtendedSR
								select t1.sessionid,max(id) as idm
								from lcc_serving_cell_table t1, _VOICE_EVENT_TIME t2
								where t1.sessionid=t2.sessionid
								and t1.msgtime<=Start_time
								and t1.side='A'
								group by t1.sessionid) idm on idm.sessionid=s.sessionid
	where s.side='A'
	group by s.sessionid
	)  id_ini on id_ini.sessionid=t.sessionid
left join
	(Select s.sessionid,case when max(idm.idm) is null then max(s.id) else max(idm.idm) end as id
	from lcc_serving_cell_table s
			left outer join (--Evento antes del Disconnect
								select t1.sessionid,max(id) as idm
								from lcc_serving_cell_table t1, _VOICE_EVENT_TIME t2
								where t1.sessionid=t2.sessionid
								and t1.msgtime<=Disconnect_time_B
								and t1.side='A'
								group by t1.sessionid) idm on idm.sessionid=s.sessionid
	where s.side='A'
	group by s.sessionid
	)  id_fin on id_fin.sessionid=t.sessionid
where t.side='A'
and t.id between id_ini.id and id_fin.id
and t.SessionId>@maxSession -- We only get the sessionIds to import
group by t.sessionid
order by t.SessionId

-----------------------------------------------------------------------------------------------------------------

---------------------- B side ------------------------------------------------------------------------------------

--GSM/WCDMA/LTE Radio Initial (Radio Values)
exec sp_lcc_dropifexists '_TECH_RADIO_INI_B'
select t.sessionid,
case when vef.Start_Band_B like '%GSM%' then t.Freq end as BCCH,
case when vef.Start_Band_B like '%GSM%' then t.signal end as RxLev,
case when vef.Start_Band_B like '%GSM%' then t.quality end as RxQual,
case when vef.Start_Band_B like '%GSM%' then t.cell end as BSIC,
case when vef.Start_Band_B like '%UMTS%' then t.Freq end as UARFCN,
case when vef.Start_Band_B like '%UMTS%' then t.signal end as RSCP,
case when vef.Start_Band_B like '%UMTS%' then t.quality end as EcIo,
case when vef.Start_Band_B like '%UMTS%' then t.cell end as PSC,
t.RNCID,
case when vef.Start_Band_B like '%LTE%' then t.Freq end as EARFCN,
case when vef.Start_Band_B like '%LTE%' then t.signal end as RSRP,
case when vef.Start_Band_B like '%LTE%' then t.quality end as RSRQ,
case when (vef.Start_Band_B like '%LTE%' and t.SINR0 is not null and t.SINR1 is not null) then 1.0 * (t.SINR0+t.SINR1)/2.0 end as SINR,
case when vef.Start_Band_B like '%LTE%' then t.cell end as PCI,
t.CId,
t.LAC

into _TECH_RADIO_INI_B
from _TECH_INI_FIN vef, lcc_serving_cell_table t
		left outer join 
-- **************************************************************************************************************	
						--Para obtener la tecnología de inicio nos quedamos con el tiempo anterior a los siguientes eventos:
						--Si la llamada es CSFB: antes de Extended SR
						--Si la llamada es VOLTE,SRVCC o VOLTE_HO: antes del Trying 
						--Si la llamada se produce en 3G/2G: antes del CMServiceRequest o el CallConfirmed(el otro lado de la llamada)
						
						--Si no tenemos ninguno de estos eventos, nos quedamos con la primera muestra de la serving cell 
-- **************************************************************************************************************
				(Select s.sessionid, case when max(idm.idm) is null then min(id) else max(idm.idm) end as id
					from lcc_serving_cell_table s
							left outer join (--Evento antes del CMService-CallConfirmed/Trying/ExtendedSR
												select t1.sessionid,max(id) as idm
												from lcc_serving_cell_table t1, _VOICE_EVENT_TIME t2
												where t1.sessionid=t2.sessionid
												and t1.msgtime<=Start_time
												and t1.side='B'
												group by t1.sessionid) idm on idm.sessionid=s.sessionid
					where s.side='B'
					
				 group by s.sessionid
				) mi on t.SessionId=mi.SessionId

-- **************************************************************************************************************
where t.id=mi.id
and vef.sessionid=t.sessionid
and t.side='B'
and t.SessionId>@maxSession -- We only get the sessionIds to import

--GSM/WCDMA/LTE Radio Final (Radio Values)
exec sp_lcc_dropifexists '_TECH_RADIO_FIN_B'
select t.sessionid,
case when vef.Disconnect_Band_B like '%GSM%' then t.Freq end as BCCH,
case when vef.Disconnect_Band_B like '%GSM%' then t.signal end as RxLev,
case when vef.Disconnect_Band_B like '%GSM%' then t.quality end as RxQual,
case when vef.Disconnect_Band_B like '%GSM%' then t.cell end as BSIC,
case when vef.Disconnect_Band_B like '%UMTS%' then t.Freq end as UARFCN,
case when vef.Disconnect_Band_B like '%UMTS%' then t.signal end as RSCP,
case when vef.Disconnect_Band_B like '%UMTS%' then t.quality end as EcIo,
case when vef.Disconnect_Band_B like '%UMTS%' then t.cell end as PSC,
t.RNCID,
case when vef.Disconnect_Band_B like '%LTE%' then t.Freq end as EARFCN,
case when vef.Disconnect_Band_B like '%LTE%' then t.signal end as RSRP,
case when vef.Disconnect_Band_B like '%LTE%' then t.quality end as RSRQ,
case when (vef.Disconnect_Band_B like '%LTE%' and t.SINR0 is not null and t.SINR1 is not null) then 1.0 * (t.SINR0+t.SINR1)/2.0 end as SINR,
case when vef.Disconnect_Band_B like '%LTE%' then t.cell end as PCI,
t.CId,
t.LAC

into _TECH_RADIO_FIN_B
from _TECH_INI_FIN vef,lcc_serving_cell_table t
		left outer join 
-- **************************************************************************************************************
						--Para obtener la tecnología de fin nos quedamos con el tiempo anterior al DISCONNECT de la llamada
						--Si no tenemos DISCONNECT, nos quedamos con la última muestra de la serving cell 
-- **************************************************************************************************************
				(Select s.sessionid, case when max(idm.idm) is null then max(id) else max(idm.idm) end as id
					from lcc_serving_cell_table s
							left outer join (--Evento antes del disconnect
												select t1.sessionid,max(id) as idm
												from lcc_serving_cell_table t1, _VOICE_EVENT_TIME t2
												where t1.sessionid=t2.sessionid
												and t1.msgtime<=Disconnect_time
												and t1.side='B'
												group by t1.sessionid) idm on idm.sessionid=s.sessionid
					where s.side='B'
				 group by s.sessionid) mi on t.SessionId=mi.SessionId
-- **************************************************************************************************************
where t.id=mi.id
and vef.sessionid=t.sessionid
and t.side='B'
and t.SessionId>@maxSession -- We only get the sessionIds to import

--GSM/WCDMA/LTE Radio AVG (Radio Values)
exec sp_lcc_dropifexists '_TECH_RADIO_AVG_B'
select  t.sessionid,
		MAX(case when t.technology like '%GSM%' then cast(t.hopping as integer) end) as Hopping,
		log10(avg(power(10.0E0,(case when t.band  like '%GSM%' and t.signal is not null then 1.0 * t.signal end)/10.0E0)))*10 as RxLev,
		log10(avg(power(10.0E0,(case when t.band  like '%GSM%' and t.quality is not null then 1.0 * t.quality end)/10.0E0)))*10 as RxQual,
		MIN(case when t.technology like '%GSM%' then t.signal end) as RxLev_min,
		MIN(case when t.technology like '%GSM%' then t.quality end) as RxQual_min,
		log10(avg(power(10.0E0,(case when t.band  like '%UMTS%' and t.signal is not null then 1.0 * t.signal end)/10.0E0)))*10 as RSCP,
		log10(avg(power(10.0E0,(case when t.band  like '%UMTS%' and t.quality is not null then 1.0 * t.quality end)/10.0E0)))*10 as EcIo,
		MIN(case when t.technology like '%UMTS%' then t.signal end) as RSCP_min,
		MIN(case when t.technology like '%UMTS%' then t.quality end) as EcIo_min,
		log10(avg(power(10.0E0,(case when t.band  like '%LTE%' and t.signal is not null then 1.0 * t.signal end)/10.0E0)))*10 as RSRP,
		log10(avg(power(10.0E0,(case when t.band  like '%LTE%' and t.quality is not null then 1.0 * t.quality end)/10.0E0)))*10 as RSRQ,
		MIN(case when t.technology like '%LTE%' then t.signal end) as RSRP_min,
		MIN(case when t.technology like '%LTE%' then t.quality end) as RSRQ_min,
		--SUM(case when t.band = 'GSM' then 1 else 0 end) as GSM_Samples,
		--SUM(case when t.band = 'DCS' then 1 else 0 end) as DCS_Samples,
		--SUM(case when t.band = 'UMTS2100' then 1 else 0 end) as UMTS2100_Samples,
		--SUM(case when t.band = 'UMTS900' then 1 else 0 end) as UMTS900_Samples,
		--SUM(case when t.band = 'LTE_800' then 1 else 0 end) as LTE800_Samples,
		--SUM(case when t.band = 'LTE_1800' then 1 else 0 end) as LTE1800_Samples,
		--SUM(case when t.band = 'LTE_2600' then 1 else 0 end) as LTE2600_Samples,
		--SUM(case when t.band in ('GSM', 'DCS') and t.quality is not null then 1 end) as RxQual_samples,
		SUM(case when t.band in ('GSM', 'DCS') and t.quality=0 then 1 end) as RxQual_0,
		SUM(case when t.band in ('GSM', 'DCS') and t.quality=1 then 1 end) as RxQual_1,
		SUM(case when t.band in ('GSM', 'DCS') and t.quality=2 then 1 end) as RxQual_2,
		SUM(case when t.band in ('GSM', 'DCS') and t.quality=3 then 1 end) as RxQual_3,
		SUM(case when t.band in ('GSM', 'DCS') and t.quality=4 then 1 end) as RxQual_4,
		SUM(case when t.band in ('GSM', 'DCS') and t.quality=5 then 1 end) as RxQual_5,
		SUM(case when t.band in ('GSM', 'DCS') and t.quality=6 then 1 end) as RxQual_6,
		SUM(case when t.band in ('GSM', 'DCS') and t.quality=7 then 1 end) as RxQual_7,
		log10(avg(power(10.0E0,(case when t.band = 'GSM' and t.quality is not null then 1.0 * t.quality end)/10.0E0)))*10 as RxQual_GSM,
		log10(avg(power(10.0E0,(case when t.band = 'DCS' and t.quality is not null then 1.0 * t.quality end)/10.0E0)))*10 as RxQual_DCS,
		--SUM(case when t.technology like '%UMTS%' and t.quality is not null then 1 end) as EcIo_samples,
		SUM(case when (t.technology like '%UMTS%' and t.quality > -2  and t.quality <= 0) then 1 end) as 'EcIo [0, -2)',
		SUM(case when (t.technology like '%UMTS%' and t.quality > -4  and t.quality <= -2) then 1 end) as 'EcIo [-2, -4)',
		SUM(case when (t.technology like '%UMTS%' and t.quality > -6  and t.quality <= -4) then 1 end) as 'EcIo [-4, -6)',
		SUM(case when (t.technology like '%UMTS%' and t.quality > -8  and t.quality <= -6) then 1 end) as 'EcIo [-6, -8)',
		SUM(case when (t.technology like '%UMTS%' and t.quality > -10  and t.quality <= -8) then 1 end) as 'EcIo [-8, -10)',
		SUM(case when (t.technology like '%UMTS%' and t.quality > -12  and t.quality <= -10) then 1 end) as 'EcIo [-10, -12)',
		SUM(case when (t.technology like '%UMTS%' and t.quality > -14  and t.quality <= -12) then 1 end) as 'EcIo [-12, -14)',
		SUM(case when (t.technology like '%UMTS%' and t.quality <= -14) then 1 end) as 'EcIo <= -14',
		log10(avg(power(10.0E0,(case when t.band = 'UMTS2100' and t.quality is not null then 1.0 * t.quality end)/10.0E0)))*10 as EcIo_UMTS2100,
		log10(avg(power(10.0E0,(case when t.band = 'UMTS900' and t.quality is not null then 1.0 * t.quality end)/10.0E0)))*10 as EcIo_UMTS900,
		avg(case when (t.technology like '%LTE%' and t.SINR0 is not null and t.SINR1 is not null) then 1.0 * (t.SINR0+t.SINR1)/2.0 end) as SINR

into _TECH_RADIO_AVG_B
from lcc_serving_cell_table t
left join
	(Select s.sessionid,case when max(idm.idm) is null then min(s.id) else max(idm.idm) end as id
	from lcc_serving_cell_table s
			left outer join (--Evento antes del CMService-CallConfirmed/Trying/ExtendedSR
								select t1.sessionid,max(id) as idm
								from lcc_serving_cell_table t1, _VOICE_EVENT_TIME t2
								where t1.sessionid=t2.sessionid
								and t1.msgtime<=Start_time
								and t1.side='B'
								group by t1.sessionid) idm on idm.sessionid=s.sessionid
	where s.side='B'
	group by s.sessionid
	)  id_ini on id_ini.sessionid=t.sessionid
left join
	(Select s.sessionid,case when max(idm.idm) is null then max(s.id) else max(idm.idm) end as id
	from lcc_serving_cell_table s
			left outer join (--Evento antes del Disconnect
								select t1.sessionid,max(id) as idm
								from lcc_serving_cell_table t1, _VOICE_EVENT_TIME t2
								where t1.sessionid=t2.sessionid
								and t1.msgtime<=Disconnect_time_B
								and t1.side='B'
								group by t1.sessionid) idm on idm.sessionid=s.sessionid
	where s.side='B'
	group by s.sessionid
	)  id_fin on id_fin.sessionid=t.sessionid
where t.side='B'
and t.id between id_ini.id and id_fin.id
and t.SessionId>@maxSession -- We only get the sessionIds to import
group by t.sessionid
order by t.SessionId


-----------------------------------------------------------------------------------------------------------------


--------------------- HANDOVERS -------------------------------
exec sp_lcc_dropifexists '_HOs'
select v.sessionid,
		COUNT(Kpistatus) as Handovers,
		SUM(case when v.KPIStatus = 'Failed' then 1 else 0 end) as Handover_Failures,
		SUM(case when v.KPIId in (34050,34060,34070) and v.KPIStatus = 'Failed' then 1 else 0 end) as Handover_2G2G_Failures,
		SUM(case when v.KPIId in (35060,35061) and v.KPIStatus = 'Failed' then 1 else 0 end) as Handover_2G3G_Failures,
		SUM(case when v.KPIId in (35020,35030,35040,35041,35070,35071) and v.KPIStatus = 'Failed' then 1 else 0 end) as Handover_3G2G_Failures,
		SUM(case when v.KPIId in (35100,35101,35105,35106,35110,35111) and v.KPIStatus = 'Failed' then 1 else 0 end) as Handover_3G3G_Failures,
		SUM(case when v.KPIId in (38020,38030) and v.KPIStatus = 'Failed' then 1 else 0 end) as Handover_4G3G_Failures,
		SUM(case when v.KPIId = 38100 and v.KPIStatus = 'Failed' then 1 else 0 end) as Handover_4G4G_Failures,
		AVG(v.Duration) as HOs_Duration_Avg

into _HOs		
from vresultskpi v,Sessions s,_Disconnect_EVENT d, lcc_markers_time m
where v.sessionid=d.sessionid
	and v.sessionid=m.sessionid
	and v.sessionid=s.sessionid

	--Acotamos los handovers al momento de la llamada para diferenciarlos de las reselecciones. 
	and v.startTime > d.Dial_Time --Debe ser posterior al dial de la llamada (asi descartamos HO de intentos anteriores)
	and v.startTime > case when m.Trying_Time_A is not null then m.Trying_Time_A else d.Dial_Time end
	and (m.CMServiceRequest_Time_A is null or m.CMServiceRequest_Time_A >= m.Dial_Time or m.CMServiceRequest_Time_A <= d.Disconnect_A)
	and (m.CallConfirmed_Time_A is null or m.CallConfirmed_Time_A >= m.Dial_Time or m.CallConfirmed_Time_A <= d.Disconnect_A)
	and v.endTime < d.Disconnect_A	

and v.kpiid in (34050,34060,34070, --2g
				35060,35061, --2G/3G
				35020,35030,35040,35041,35070,35071, --3G/2G
				35100,35101,35105,35106,35110,35111, --3G
				38020,38030, -- 4G/3G
				38100) -- 4G

and v.SessionId>@maxSession -- We only get the sessionIds to import

group by v.SessionId


--HO IRAT 2G/3G
exec sp_lcc_dropifexists '_IRAT_HO'
select  r.sessionid,
		1.0*sum(case when (r.kpiid in (35100,35101,35105,35106,35110,35111,35020,35030,35040,35041,35070,35071,35060,35061,34050,34060,34070) and r.errorcode<>0) then 0 else 1 end)/count(r.sessionid) as IRAT_HO2G3G_Ratio

into _IRAT_HO
from resultskpi r, _Disconnect_EVENT d, lcc_markers_time m
where r.sessionid=d.sessionid
	and r.sessionid=m.sessionid

	--Acotamos los handovers al momento de la llamada para diferenciarlos de las reselecciones. 
	and r.startTime > d.Dial_Time --Debe ser posterior al dial de la llamada (asi descartamos HO de intentos anteriores)
	and r.startTime > case when m.Trying_Time_A is not null then m.Trying_Time_A else d.Dial_Time end
	and (m.CMServiceRequest_Time_A is null or m.CMServiceRequest_Time_A >= m.Dial_Time or m.CMServiceRequest_Time_A <= d.Disconnect_A)
	and (m.CallConfirmed_Time_A is null or m.CallConfirmed_Time_A >= m.Dial_Time or m.CallConfirmed_Time_A <= d.Disconnect_A)
	and r.endTime < d.Disconnect_A	

	and r.kpiid in (35100,35101,35105,35106,35110,35111,
				  35020,35030,35040,35041,35070,35071,
				  35060,35061,
				  34050,34060,34070)
	and r.sessionid > @maxsession

group by  r.sessionid


--HO IRAT 2G/3G B
exec sp_lcc_dropifexists '_IRAT_HO_B'
select  a.sessionid,
		1.0*sum(case when (r.kpiid in (35100,35101,35105,35106,35110,35111,35020,35030,35040,35041,35070,35071,35060,35061,34050,34060,34070) and r.errorcode<>0) then 0 else 1 end)/count(r.sessionid) as IRAT_HO2G3G_Ratio_BSide

into _IRAT_HO_B
from resultskpi r,callAnalysis a, sessionsB s,_Disconnect_EVENT d, lcc_markers_time m
where s.sessionidA=d.sessionid
	and s.sessionidA=m.sessionid
	and s.sessionid=r.sessionid
	and a.sessionid=s.sessionidA

	--Acotamos los handovers al momento de la llamada para diferenciarlos de las reselecciones. 
	and r.startTime > d.Dial_Time --Debe ser posterior al dial de la llamada (asi descartamos HO de intentos anteriores)
	and r.startTime > case when m.Trying_Time_B is not null then m.Trying_Time_B else d.Dial_Time end
	and (m.CMServiceRequest_Time_B is null or m.CMServiceRequest_Time_B >= m.Dial_Time or m.CMServiceRequest_Time_B <= d.Disconnect_B)
	and (m.CallConfirmed_Time_B is null or m.CallConfirmed_Time_B >= m.Dial_Time or m.CallConfirmed_Time_B <= d.Disconnect_B)
	and r.endTime < d.Disconnect_B	

	and r.kpiid in (35100,35101,35105,35106,35110,35111,
				  35020,35030,35040,35041,35070,35071,
				  35060,35061,
				  34050,34060,34070)
	and a.sessionid > @maxsession
group by  a.sessionid


--HO 4G/4G
exec sp_lcc_dropifexists '_4GHO'
select  r.sessionid,
		count( r.sessionid ) as num_HO_S1X2,
		avg(r.duration) as duration_S1X2_avg,
		1.0*sum(case when (r.kpiid in (38100) and r.errorcode<>0) then 0 else 1 end)/count(r.sessionid) as S1X2HO_SR

into _4GHO
from resultskpi r,_Disconnect_EVENT d, lcc_markers_time m
where r.sessionid=d.sessionid
	and r.sessionid=m.sessionid

	--Acotamos los handovers al momento de la llamada para diferenciarlos de las reselecciones. 
	and r.startTime > d.Dial_Time --Debe ser posterior al dial de la llamada (asi descartamos HO de intentos anteriores)
	and r.startTime > case when m.Trying_Time_A is not null then m.Trying_Time_A else d.Dial_Time end
	and (m.CMServiceRequest_Time_A is null or m.CMServiceRequest_Time_A >= m.Dial_Time or m.CMServiceRequest_Time_A <= d.Disconnect_A)
	and (m.CallConfirmed_Time_A is null or m.CallConfirmed_Time_A >= m.Dial_Time or m.CallConfirmed_Time_A <= d.Disconnect_A)
	and r.endTime < d.Disconnect_A	

	and r.kpiid in (38100)
	and r.sessionid > @maxsession

group by  r.sessionid


--HO 4G/4G B
exec sp_lcc_dropifexists '_4GHO_B'
select  a.sessionid,
		count( r.sessionid ) as num_HO_S1X2_BSide,
		avg(r.duration) as duration_S1X2_avg_BSide,
		1.0*sum(case when (r.kpiid in (38100) and r.errorcode<>0) then 0 else 1 end)/count(r.sessionid) as S1X2HO_SR_BSide

into _4GHO_B
from resultskpi r,callAnalysis a, sessionsB s,_Disconnect_EVENT d, lcc_markers_time m
where s.sessionidA=d.sessionid
	and s.sessionidA=m.sessionid
	and s.sessionid=r.sessionid
	and a.sessionid=s.sessionidA

	--Acotamos los handovers al momento de la llamada para diferenciarlos de las reselecciones. 
	and r.startTime > d.Dial_Time --Debe ser posterior al dial de la llamada (asi descartamos HO de intentos anteriores)
	and r.startTime > case when m.Trying_Time_B is not null then m.Trying_Time_B else d.Dial_Time end
	and (m.CMServiceRequest_Time_B is null or m.CMServiceRequest_Time_B >= m.Dial_Time or m.CMServiceRequest_Time_B <= d.Disconnect_B)
	and (m.CallConfirmed_Time_B is null or m.CallConfirmed_Time_B >= m.Dial_Time or m.CallConfirmed_Time_B <= d.Disconnect_B)
	and r.endTime < d.Disconnect_B	

	and r.kpiid in (38100)
	and a.sessionid > @maxsession
group by  a.sessionid


-------------------- END HANDOVERS ----------------------------

--------------------- NEIGHBORS -------------------------------

----------------------------------------------------------------------------------------------------------------
--GSM Neighbors Info (Ordering BCCH by sessionid and RxLev of the last neighbor top 1 between start and end of the call) 
----------------------------------------------------------------------------------------------------------------
exec sp_lcc_dropifexists '_GSM_NEIGHBOR'
select  m.SessionId,
		m.N1_BCCH, 
		m.N1_RxLev,
		m.msgtime,
		ROW_NUMBER() over (partition by m.sessionid order by m.sessionid asc, m.msgtime desc, m.N1_rxlev asc) as id

into _GSM_NEIGHBOR
from MsgGSMLayer1 m, _Disconnect_EVENT d, lcc_markers_time r
where m.sessionid=d.sessionid
	and m.sessionid=r.sessionid
	--Acotamos al momento de la llamada
	and m.MsgTime between d.Dial_Time and d.Disconnect_A --Debe ser posterior al dial de la llamada
	and m.MsgTime > case when r.Trying_Time_A is not null then r.Trying_Time_A else d.Dial_Time end
	and (r.CMServiceRequest_Time_A is null or r.CMServiceRequest_Time_A >= r.Dial_Time or r.CMServiceRequest_Time_A <= d.Disconnect_A)
	and (r.CallConfirmed_Time_A is null or r.CallConfirmed_Time_A >= r.Dial_Time or r.CallConfirmed_Time_A <= d.Disconnect_A)
	and m.N1_BCCH is not null
	and m.SessionId>@maxSession -- We only get the sessionIds to import
	group by m.SessionId, m.MsgTime, m.N1_BCCH, m.N1_RxLev

--Parte B
exec sp_lcc_dropifexists '_GSM_NEIGHBOR_B'
select  m.sessionid,
		m.N1_BCCH, 
		m.N1_RxLev,
		m.msgtime,
		ROW_NUMBER() over (partition by m.sessionid order by m.sessionid asc, m.msgtime desc, m.N1_rxlev asc) as id

into  _GSM_NEIGHBOR_B
from MsgGSMLayer1 m, sessionsB s,_Disconnect_EVENT d, lcc_markers_time r
where s.sessionidA=d.sessionid
	and s.sessionidA=r.sessionid
	and s.sessionid=m.sessionid
	--Acotamos al momento de la llamada
	and m.MsgTime between d.Dial_Time and d.Disconnect_B --Debe ser posterior al dial de la llamada
	and m.MsgTime > case when r.Trying_Time_B is not null then r.Trying_Time_B else d.Dial_Time end
	and (r.CMServiceRequest_Time_B is null or r.CMServiceRequest_Time_B >= r.Dial_Time or r.CMServiceRequest_Time_B <= d.Disconnect_B)
	and (r.CallConfirmed_Time_B is null or r.CallConfirmed_Time_B >= r.Dial_Time or r.CallConfirmed_Time_B <= d.Disconnect_B)
	and m.N1_BCCH is not null
	and m.SessionId>@maxSession -- We only get the sessionIds to import
	group by m.SessionId, m.MsgTime, m.N1_BCCH, m.N1_RxLev
	
--GSM Neighbors TOP 1
exec sp_lcc_dropifexists '_GSM_N_TOP1'
select  SessionId,
		N1_BCCH,
		N1_RxLev
into _GSM_N_TOP1
from _GSM_NEIGHBOR 
where id=1

exec sp_lcc_dropifexists '_GSM_N_TOP1_B'
select  SessionId,
		N1_BCCH,
		N1_RxLev
into _GSM_N_TOP1_B
from _GSM_NEIGHBOR_B 
where id=1



----------------------------------------------------------------------------------------------------------------
--WCDMA Neighbors Info (Ordering PSC by sessionid and RSCP of the last neighbor top 1 between start and end of the call)
----------------------------------------------------------------------------------------------------------------
exec sp_lcc_dropifexists '_WCDMA_NEIGHBOR'
select  r2.SessionId,
		r2.PSC as N1_PSC,
		r2.RSCP as N1_RSCP,
		r2.msgtime,
		ROW_NUMBER() over (partition by r2.sessionid order by r2.sessionid asc, r2.msgtime desc, r2.RSCP asc) as id

into _WCDMA_NEIGHBOR
from 
(select r1.sessionid, r.PSC, r.RSCP, r1.MsgTime
	from _Disconnect_EVENT d, lcc_markers_time t, WCDMAMeasReportInfo r1
	left outer join
		(select * from WCDMAMeasReport )r  on r1.MeasReportId=r.MeasReportId
where SetValue in ('N', 'M') -- Monitored set 
	and r1.sessionid=d.sessionid
	and r1.sessionid=t.sessionid
	--Acotamos al momento de la llamada
	and r1.MsgTime between d.Dial_Time and d.Disconnect_A --Debe ser posterior al dial de la llamada
	and r1.MsgTime > case when t.Trying_Time_A is not null then t.Trying_Time_A else d.Dial_Time end
	and (t.CMServiceRequest_Time_A is null or t.CMServiceRequest_Time_A >= t.Dial_Time or t.CMServiceRequest_Time_A <= d.Disconnect_A)
	and (t.CallConfirmed_Time_A is null or t.CallConfirmed_Time_A >= t.Dial_Time or t.CallConfirmed_Time_A <= d.Disconnect_A)
	and r1.SessionId>@maxSession -- We only get the sessionIds to import
group by r1.SessionId, r1.MsgTime, r.PSC, r.RSCP) r2

--Parte B
exec sp_lcc_dropifexists '_WCDMA_NEIGHBOR_B'
select  r2.SessionId,
		r2.PSC as N1_PSC,
		r2.RSCP as N1_RSCP,
		r2.msgtime,
		ROW_NUMBER() over (partition by r2.sessionid order by r2.sessionid asc, r2.msgtime desc, r2.RSCP asc) as id

into _WCDMA_NEIGHBOR_B
from 
(select r1.sessionid, r.PSC, r.RSCP, r1.MsgTime
	from _Disconnect_EVENT d,sessionsB s,lcc_markers_time t, WCDMAMeasReportInfo r1
	left outer join
		(select * from WCDMAMeasReport )r  on r1.MeasReportId=r.MeasReportId
where SetValue in ('N', 'M') -- Monitored set
	and s.sessionidA=d.sessionid
	and s.sessionidA=t.sessionid
	and s.sessionid=r1.sessionid
	--Acotamos al momento de la llamada
	and r1.MsgTime between d.Dial_Time and d.Disconnect_B --Debe ser posterior al dial de la llamada
	and r1.MsgTime > case when t.Trying_Time_B is not null then t.Trying_Time_B else d.Dial_Time end
	and (t.CMServiceRequest_Time_B is null or t.CMServiceRequest_Time_B >= t.Dial_Time or t.CMServiceRequest_Time_B <= d.Disconnect_B)
	and (t.CallConfirmed_Time_B is null or t.CallConfirmed_Time_B >= t.Dial_Time or t.CallConfirmed_Time_B <= d.Disconnect_B)
	and r1.SessionId>@maxSession -- We only get the sessionIds to import
group by r1.SessionId, r1.MsgTime, r.PSC, r.RSCP) r2


--WCDMA Neighbors TOP 1 (We need the most accurate info of the Neighbor at the moment of finishing call)
exec sp_lcc_dropifexists '_WCDMA_N_TOP1'
select  SessionId,
		N1_PSC,
		N1_RSCP 
into _WCDMA_N_TOP1
from _WCDMA_NEIGHBOR
where id=1

exec sp_lcc_dropifexists '_WCDMA_N_TOP1_B'
select SessionId,
		N1_PSC,
		N1_RSCP 
into _WCDMA_N_TOP1_B
from _WCDMA_NEIGHBOR_B
where id=1


----------------------------------------------------------------------------------------------------------------
--LTE Neighbors Info (Ordering PCI by sessionid and RSRP of the last neighbor top 1 between start and end of the call)
----------------------------------------------------------------------------------------------------------------
exec sp_lcc_dropifexists '_LTE_NEIGHBOR'
select  l.sessionid,
		--l.testid,
		--l.EARFCN as EARFCN_PCC,
		--l.PhyCellId as PCI_PCC,
		--10*LOG10(AVG(POWER(CAST(10 AS float), (l.RSRP)/10.0))) as RSRP_PCC,
		--10*LOG10(AVG(POWER(CAST(10 AS float), (l.RSRQ)/10.0))) as RSRQ_PCC,
		ln.EARFCN_N1,
		ln.PCI_N1,
		10*LOG10(AVG(POWER(CAST(10 AS float), (ln.RSRP_N1)/10.0))) as RSRP_N1,
		10*LOG10(AVG(POWER(CAST(10 AS float), (ln.RSRQ_N1)/10.0))) as RSRQ_N1,
		lnb.EARFCN_N1_BSide,
		lnb.PCI_N1_BSide,
		10*LOG10(AVG(POWER(CAST(10 AS float), (lnb.RSRP_N1_BSide)/10.0))) as RSRP_N1_BSide,
		10*LOG10(AVG(POWER(CAST(10 AS float), (lnb.RSRQ_N1_BSide)/10.0))) as RSRQ_N1_BSide

into _LTE_NEIGHBOR
from LTEmeasurementReport l

left outer join 
			--PARTE A
			( select 
				l.sessionid,
				ln.ltemeasreportid,
				l.msgtime,
				ln.EARFCN as EARFCN_N1,
				ln.PhyCellId as PCI_N1,
				ln.RSRP as RSRP_N1,
				ln.RSRQ as RSRQ_N1,
				ln.carrierindex,
				row_number () over (partition by l.sessionid order by l.msgtime asc, ln.RSRP desc) as id
				
				from LTENeighbors ln, LTEmeasurementReport l,_Disconnect_EVENT d,lcc_markers_time t
				where carrierindex=0 --Solo para la PCC
				and l.ltemeasreportid=ln.ltemeasreportid
				and d.sessionid=l.sessionid
				and t.sessionid=l.sessionid
				--Acotamos al momento de la llamada 
				and l.MsgTime between d.Dial_Time and d.Disconnect_A --Debe ser posterior al dial de la llamada
				and l.MsgTime > case when t.Trying_Time_A is not null then t.Trying_Time_A else d.Dial_Time end
				and (t.CMServiceRequest_Time_A is null or t.CMServiceRequest_Time_A >= t.Dial_Time or t.CMServiceRequest_Time_A <= d.Disconnect_A)
				and (t.CallConfirmed_Time_A is null or t.CallConfirmed_Time_A >= t.Dial_Time or t.CallConfirmed_Time_A <= d.Disconnect_A)
				and l.sessionid > @maxsession

			) ln on l.sessionid=ln.sessionid and ln.id=1

left outer join 
			--PARTE B
			( select 
				b.sessionidA as sessionid,
				ln.ltemeasreportid,
				l.msgtime,
				ln.EARFCN as EARFCN_N1_BSide,
				ln.PhyCellId as PCI_N1_BSide,
				ln.RSRP as RSRP_N1_BSide,
				ln.RSRQ as RSRQ_N1_BSide,
				ln.carrierindex,
				row_number () over (partition by l.sessionid order by l.msgtime asc, ln.RSRP desc) as id
				
				from LTENeighbors ln, LTEmeasurementReport l,_Disconnect_EVENT d,lcc_markers_time t, sessionsB b
				where carrierindex=0 --Solo para la PCC
				and l.ltemeasreportid=ln.ltemeasreportid
				and d.sessionid=b.SessionIdA
				and t.sessionid=b.SessionIdA
				and b.sessionid=l.sessionid
				--Acotamos al momento de la llamada 
				and l.MsgTime between d.Dial_Time and d.Disconnect_B --Debe ser posterior al dial de la llamada
				and l.MsgTime > case when t.Trying_Time_B is not null then t.Trying_Time_A else d.Dial_Time end
				and (t.CMServiceRequest_Time_B is null or t.CMServiceRequest_Time_B >= t.Dial_Time or t.CMServiceRequest_Time_B <= d.Disconnect_B)
				and (t.CallConfirmed_Time_B is null or t.CallConfirmed_Time_B >= t.Dial_Time or t.CallConfirmed_Time_B <= d.Disconnect_B)
				and l.sessionid > @maxsession

			) lnb on lnb.sessionid=l.sessionid and lnb.id=1

where (ln.EARFCN_N1 is not null or lnb.EARFCN_N1_BSide is not null)

group by l.sessionid, ln.EARFCN_N1, ln.PCI_N1, lnb.EARFCN_N1_BSide, lnb.PCI_N1_BSide
order by l.sessionid


-------------------- END NEIGHBORS ----------------------------

------------------------------------- END CRITERIO 2 ------------------------------------------------------

-------------------------------------------------------------------------------------------

--	CRITERIO 3: Cálculos no acotados. No es necesario o el criterio utilizado ya lo acota.

--	Con este criterio calculamos:
--				MOS
--				SQNS
--				LTE_Return
--				PDP_Activate_Context
--				RTP
--				PAGING
--				Call_reestablishment
--				Fast return
--				Codecs
--				Posiciones

-------------------------------------------------------------------------------------------

--DGP 20/07/2016: Se cambia la forma de determinar el uso de MOS y Codecs para adaptarlo a NB --> BW=0, WB --> BW<>0
--CAC 09/08/2017: se cruza con lcc_ref_servingOperator_Freq para sacar la tecnologia por banda en LTE, sino rellena LTE E-UTRA X 
------------------ MOS Temporary Table -----------------------

---------------- MOS TYPE AND DIRECTION ----------------------
exec sp_lcc_dropifexists '_tMOS'
Select  m.sessionid, m.testid, 
		--n.technology,
		case when n.technology like 'LTE E-UTRA%' then case when n.technology like '%20%' then 'LTE800'
															when n.technology like '%7%' then 'LTE2600'
															when n.technology like '%3%' then 'LTE1800'
															when n.technology like '%1%' then 'LTE2100' end
		 else n.technology end as technology,
		case when m.OptionalNB is not null then m.OptionalNB
			 else m.OptionalWB end as MOS,
		m.StaticSNR as SNR,
		m.RcvDelay as Speech_Delay,
		m.bandwidth,
		m.[status],
		case t.direction
			 when 'A->B' then 'U'
			 when 'B->A' then 'D'
			 Else t.direction
		end as MOS_Test_Direction,
		Appl,
		ROW_NUMBER() over (partition by m.sessionid order by m.testid asc) as id
into _tMOS	
		from dbo.ResultsLQ08Avg m, TestInfo t
			, networkinfo n
			left join [AGRIDS].dbo.lcc_ref_servingOperator_Freq sof on n.BCCH=sof.Frequency
		where m.TestId=t.TestId
		and t.NetworkId=n.NetworkId
		and Appl in (10, 110, 1010, 20, 120, 12, 1012, 22) -- Application Codes for POLQA NB (10, 110, 1010, 20, 120) and WB (12, 1012, 22) Codecs -- Para nuevos Codecs habrá que tocar codigo
		and m.SessionId>@maxSession -- We only get the sessionIds to import

------------------- MOS AVG ALL --------------------------
-- MOS, SNR, Speech Delay, Samples and Histograms per call and Type

-- CAC 11/01/2017: se incopora el desglose por tecnología-banda
exec sp_lcc_dropifexists '_MOS_ALL' 
Select  sessionid, 
		AVG(case 
			when BandWidth=0 then MOS end) as MOS_NB,
		AVG(case 
			when BandWidth<>0 then MOS end) as MOS_WB,

		log10(avg(power(10.0E0,SNR/10.0E0)))*10 as SNR,
		AVG(Speech_Delay) as Speech_Delay,
		SUM(case when BandWidth=0 then 1 else 0 end) as Samples_NB,
		SUM(case when BandWidth<>0 then 1 else 0 end) as Samples_WB,
		SUM(case when bandwidth=0 and MOS<2.5 then 1 else 0 end) as 'Samples_Under_2.5_NB',
		SUM(case when bandwidth<>0 and MOS<2.5 then 1 else 0 end) as 'Samples_Under_2.5_WB',
		sum(case when [status]='Silence' then 1 else 0 end) as 'Silence_Samples',
		SUM(case when technology like '%GSM%900' then 1 else 0 end) as MOS_GSM_Samples,
		SUM(case when technology like '%GSM%1800' then 1 else 0 end) as MOS_DCS_Samples,
		SUM(case when technology like '%UMTS%' then 1 else 0 end) as MOS_UMTS_Samples,
		SUM(case when technology like '%LTE%' then 1 else 0 end) as MOS_LTE_Samples,
		avg(case when bandwidth=0 and technology like '%GSM%900' then MOS else null end) as MOS_NB_GSM_AVG,
		avg(case when bandwidth=0 and technology like '%GSM%1800' then MOS else null end) as MOS_NB_DCS_AVG,
		avg(case when bandwidth=0 and technology like '%UMTS%' then MOS else null end) as MOS_NB_UMTS_AVG,
		avg(case when bandwidth=0 and technology like '%LTE%' then MOS else null end) as MOS_NB_LTE_AVG,
		avg(case when bandwidth<>0 and technology like '%GSM%900' then MOS else null end) as MOS_WB_GSM_AVG,
		avg(case when bandwidth<>0 and technology like '%GSM%1800' then MOS else null end) as MOS_WB_DCS_AVG,
		avg(case when bandwidth<>0 and technology like '%UMTS%' then MOS else null end) as MOS_WB_UMTS_AVG,
		avg(case when bandwidth<>0 and technology like '%LTE%' then MOS else null end) as MOS_WB_LTE_AVG,

		--MOS_GSM900_NB_AVG  --> MOS_NB_GSM_AVG,	
		--MOS_GSM900_WB_AVG  --> MOS_WB_GSM_AVG,	
		--MOS_GSM1800_NB_AVG  --> MOS_NB_DCS_AVG,	
		--MOS_GSM1800_WB_AVG  --> MOS_WB_DCS_AVG,	

		AVG(case 		
			when technology like '%UMTS%900' and BandWidth=0 then MOS end) as MOS_UMTS900_NB_AVG,	
		AVG(case 		
			when technology like '%UMTS%900' and BandWidth<>0 then MOS end) as MOS_UMTS900_WB_AVG,
		AVG(case 		
			when technology like '%UMTS%2100' and BandWidth=0 then MOS end) as MOS_UMTS2100_NB_AVG,	
		AVG(case 		
			when technology like '%UMTS%2100' and BandWidth<>0 then MOS end) as MOS_UMTS2100_WB_AVG,		
		AVG(case 		
			when technology = 'LTE800' and BandWidth=0 then MOS end) as MOS_LTE800_NB_AVG,
		AVG(case 		
			when technology = 'LTE800' and BandWidth<>0 then MOS end) as MOS_LTE800_WB_AVG,
		AVG(case 		
			when technology = 'LTE1800' and BandWidth=0 then MOS end) as MOS_LTE1800_NB_AVG,
		AVG(case 		
			when technology = 'LTE1800' and BandWidth<>0 then MOS end) as MOS_LTE1800_WB_AVG,
		AVG(case 		
			when technology = 'LTE2100' and BandWidth=0 then MOS end) as MOS_LTE2100_NB_AVG,
		AVG(case 		
			when technology = 'LTE2100' and BandWidth<>0 then MOS end) as MOS_LTE2100_WB_AVG,
		AVG(case 		
			when technology = 'LTE2600' and BandWidth=0 then MOS end) as MOS_LTE2600_NB_AVG,
		AVG(case 		
			when technology = 'LTE2600' and BandWidth<>0 then MOS end) as MOS_LTE2600_WB_AVG,
				
		SUM(case when technology like '%GSM%900' and BandWidth=0 then 1 else 0 end) as Samples_NB_GSM,
		SUM(case when technology like '%GSM%900' and BandWidth<>0 then 1 else 0 end) as Samples_WB_GSM,
		SUM(case when technology like '%GSM%1800' and BandWidth=0 then 1 else 0 end) as Samples_NB_DCS,
		SUM(case when technology like '%GSM%1800' and BandWidth<>0 then 1 else 0 end) as Samples_WB_DCS,
		SUM(case when technology like '%UMTS%900' and BandWidth=0 then 1 else 0 end) as Samples_NB_UMTS900,
		SUM(case when technology like '%UMTS%900' and BandWidth<>0 then 1 else 0 end) as Samples_WB_UMTS900,
		SUM(case when technology like '%UMTS%2100' and BandWidth=0 then 1 else 0 end) as Samples_NB_UMTS2100,
		SUM(case when technology like '%UMTS%2100' and BandWidth<>0 then 1 else 0 end) as Samples_WB_UMTS2100,
		SUM(case when technology = 'LTE800' and BandWidth=0 then 1 else 0 end) as Samples_NB_LTE800,
		SUM(case when technology = 'LTE800' and BandWidth<>0 then 1 else 0 end) as Samples_WB_LTE800,
		SUM(case when technology = 'LTE1800' and BandWidth=0 then 1 else 0 end) as Samples_NB_LTE1800,
		SUM(case when technology = 'LTE1800' and BandWidth<>0 then 1 else 0 end) as Samples_WB_LTE1800,
		SUM(case when technology = 'LTE2100' and BandWidth=0 then 1 else 0 end) as Samples_NB_LTE2100,
		SUM(case when technology = 'LTE2100' and BandWidth<>0 then 1 else 0 end) as Samples_WB_LTE2100,
		SUM(case when technology = 'LTE2600' and BandWidth=0 then 1 else 0 end) as Samples_NB_LTE2600,
		SUM(case when technology = 'LTE2600' and BandWidth<>0 then 1 else 0 end) as Samples_WB_LTE2600,


		SUM(case when bandwidth=0 and MOS >= 1 and MOS < 1.5 then 1 else 0 end) as 'MOS_1-1.5_NB',
		SUM(case when bandwidth=0 and MOS >= 1.5 and MOS < 2 then 1 else 0 end) as 'MOS_1.5-2_NB',
		SUM(case when bandwidth=0 and MOS >= 2 and MOS < 2.1 then 1 else 0 end) as 'MOS_2-2.1_NB',
		SUM(case when bandwidth=0 and MOS >= 2.1 and MOS < 2.2 then 1 else 0 end) as 'MOS_2.1-2.2_NB',
		SUM(case when bandwidth=0 and MOS >= 2.2 and MOS < 2.3 then 1 else 0 end) as 'MOS_2.2-2.3_NB',
		SUM(case when bandwidth=0 and MOS >= 2.3 and MOS < 2.4 then 1 else 0 end) as 'MOS_2.3-2.4_NB',
		SUM(case when bandwidth=0 and MOS >= 2.4 and MOS < 2.5 then 1 else 0 end) as 'MOS_2.4-2.5_NB',
		SUM(case when bandwidth=0 and MOS >= 2.5 and MOS < 2.6 then 1 else 0 end) as 'MOS_2.5-2.6_NB',
		SUM(case when bandwidth=0 and MOS >= 2.6 and MOS < 2.7 then 1 else 0 end) as 'MOS_2.6-2.7_NB',
		SUM(case when bandwidth=0 and MOS >= 2.7 and MOS < 2.8 then 1 else 0 end) as 'MOS_2.7-2.8_NB',
		SUM(case when bandwidth=0 and MOS >= 2.8 and MOS < 2.9 then 1 else 0 end) as 'MOS_2.8-2.9_NB',
		SUM(case when bandwidth=0 and MOS >= 2.9 and MOS < 3 then 1 else 0 end) as 'MOS_2.9-3_NB',
		SUM(case when bandwidth=0 and MOS >= 3 and MOS < 3.1 then 1 else 0 end) as 'MOS_3-3.1_NB',
		SUM(case when bandwidth=0 and MOS >= 3.1 and MOS < 3.2 then 1 else 0 end) as 'MOS_3.1-3.2_NB',
		SUM(case when bandwidth=0 and MOS >= 3.2 and MOS < 3.3 then 1 else 0 end) as 'MOS_3.2-3.3_NB',
		SUM(case when bandwidth=0 and MOS >= 3.3 and MOS < 3.4 then 1 else 0 end) as 'MOS_3.3-3.4_NB',
		SUM(case when bandwidth=0 and MOS >= 3.4 and MOS < 3.5 then 1 else 0 end) as 'MOS_3.4-3.5_NB',
		SUM(case when bandwidth=0 and MOS >= 3.5 and MOS < 3.6 then 1 else 0 end) as 'MOS_3.5-3.6_NB',
		SUM(case when bandwidth=0 and MOS >= 3.6 and MOS < 3.7 then 1 else 0 end) as 'MOS_3.6-3.7_NB',
		SUM(case when bandwidth=0 and MOS >= 3.7 and MOS < 3.8 then 1 else 0 end) as 'MOS_3.7-3.8_NB',
		SUM(case when bandwidth=0 and MOS >= 3.8 and MOS < 3.9 then 1 else 0 end) as 'MOS_3.8-3.9_NB',
		SUM(case when bandwidth=0 and MOS >= 3.9 and MOS < 4 then 1 else 0 end) as 'MOS_3.9-4_NB',
		SUM(case when bandwidth=0 and MOS >= 4 and MOS < 4.5 then 1 else 0 end) as 'MOS_4-4.5_NB',
		SUM(case when bandwidth=0 and MOS >= 4.5 and MOS <= 5 then 1 else 0 end) as 'MOS_4.5-5_NB',
		SUM(case when bandwidth<>0 and MOS >= 1 and MOS < 1.5 then 1 else 0 end) as 'MOS_1-1.5_WB',
		SUM(case when bandwidth<>0 and MOS >= 1.5 and MOS < 2 then 1 else 0 end) as 'MOS_1.5-2_WB',
		SUM(case when bandwidth<>0 and MOS >= 2 and MOS < 2.1 then 1 else 0 end) as 'MOS_2-2.1_WB',
		SUM(case when bandwidth<>0 and MOS >= 2.1 and MOS < 2.2 then 1 else 0 end) as 'MOS_2.1-2.2_WB',
		SUM(case when bandwidth<>0 and MOS >= 2.2 and MOS < 2.3 then 1 else 0 end) as 'MOS_2.2-2.3_WB',
		SUM(case when bandwidth<>0 and MOS >= 2.3 and MOS < 2.4 then 1 else 0 end) as 'MOS_2.3-2.4_WB',
		SUM(case when bandwidth<>0 and MOS >= 2.4 and MOS < 2.5 then 1 else 0 end) as 'MOS_2.4-2.5_WB',
		SUM(case when bandwidth<>0 and MOS >= 2.5 and MOS < 2.6 then 1 else 0 end) as 'MOS_2.5-2.6_WB',
		SUM(case when bandwidth<>0 and MOS >= 2.6 and MOS < 2.7 then 1 else 0 end) as 'MOS_2.6-2.7_WB',
		SUM(case when bandwidth<>0 and MOS >= 2.7 and MOS < 2.8 then 1 else 0 end) as 'MOS_2.7-2.8_WB',
		SUM(case when bandwidth<>0 and MOS >= 2.8 and MOS < 2.9 then 1 else 0 end) as 'MOS_2.8-2.9_WB',
		SUM(case when bandwidth<>0 and MOS >= 2.9 and MOS < 3 then 1 else 0 end) as 'MOS_2.9-3_WB',
		SUM(case when bandwidth<>0 and MOS >= 3 and MOS < 3.1 then 1 else 0 end) as 'MOS_3-3.1_WB',
		SUM(case when bandwidth<>0 and MOS >= 3.1 and MOS < 3.2 then 1 else 0 end) as 'MOS_3.1-3.2_WB',
		SUM(case when bandwidth<>0 and MOS >= 3.2 and MOS < 3.3 then 1 else 0 end) as 'MOS_3.2-3.3_WB',
		SUM(case when bandwidth<>0 and MOS >= 3.3 and MOS < 3.4 then 1 else 0 end) as 'MOS_3.3-3.4_WB',
		SUM(case when bandwidth<>0 and MOS >= 3.4 and MOS < 3.5 then 1 else 0 end) as 'MOS_3.4-3.5_WB',
		SUM(case when bandwidth<>0 and MOS >= 3.5 and MOS < 3.6 then 1 else 0 end) as 'MOS_3.5-3.6_WB',
		SUM(case when bandwidth<>0 and MOS >= 3.6 and MOS < 3.7 then 1 else 0 end) as 'MOS_3.6-3.7_WB',
		SUM(case when bandwidth<>0 and MOS >= 3.7 and MOS < 3.8 then 1 else 0 end) as 'MOS_3.7-3.8_WB',
		SUM(case when bandwidth<>0 and MOS >= 3.8 and MOS < 3.9 then 1 else 0 end) as 'MOS_3.8-3.9_WB',
		SUM(case when bandwidth<>0 and MOS >= 3.9 and MOS < 4 then 1 else 0 end) as 'MOS_3.9-4_WB',
		SUM(case when bandwidth<>0 and MOS >= 4 and MOS < 4.5 then 1 else 0 end) as 'MOS_4-4.5_WB',
		SUM(case when bandwidth<>0 and MOS >= 4.5 and MOS <= 5 then 1 else 0 end) as 'MOS_4.5-5_WB'
into _MOS_ALL		
from _tMOS
group by SessionId


--select *
--from _tmos
------------------- MOS AVG DL --------------------------
------------------- MOS AVG DL --------------------------
exec sp_lcc_dropifexists '_MOS_DL' 
Select sessionid, AVG(case when bandwidth=0 then MOS end) as MOS_NB_DL, AVG(case when bandwidth<>0 then MOS end) as MOS_WB_DL
into _MOS_DL
from _tMOS
where MOS_Test_Direction='D'
group by SessionId

------------------- MOS AVG UL --------------------------
exec sp_lcc_dropifexists '_MOS_UL' 
Select sessionid, AVG(case when bandwidth=0 then MOS end) as MOS_NB_UL, AVG(case when bandwidth<>0 then MOS end) as MOS_WB_UL
into _MOS_UL
from _tMOS
where MOS_Test_Direction='U'
group by SessionId

-----------------------SQNS-------------------------------
-- A call has SQNS issue if there's two consecutive, regardless its direction, MOS samples under 2 for NB codecs 
-- or 1.6 for WB codecs or there's more than 2 event under limits in a call
-- DGP 01/03/2016:
-- or these events are in silence


-- Dos clip de voz en la misma dirección consecutivos con calidad < umbral
exec sp_lcc_dropifexists '_SQNS_SD' 
select  ini.sessionid,
		max(case 
			when ((ini.bandwidth=0 and (ini.MOS < 1.7 or ini.[status]='Silence'))
			and (fin.bandwidth=0 and (fin.MOS < 1.7 or fin.[status]='Silence'))) then 1 else 0 end) as SQNS_NB,
		--SUM(case when (ini.bandwidth=0 and ini.MOS < 1.7) then 1 else 0 end) as NB_Number_under_2,
		
		max(case 
			when ((ini.bandwidth<>0 and (ini.MOS < 1.3 or ini.[status]='Silence'))
			and (fin.bandwidth<>0 and (fin.MOS < 1.3 or fin.[status]='Silence'))) then 1 else 0 end) as SQNS_WB
		--SUM(case when (ini.bandwidth<>0 and ini.MOS < 1.3) then 1 else 0 end) as WB_Number_under_1_6

into _SQNS_SD
from  _tMOS ini 
	left outer join _tMOS fin 
	on ini.id=fin.id-2 and ini.sessionid=fin.sessionid and ini.MOS_Test_Direction=fin.MOS_Test_Direction
	--left outer join _tMOS fin_alt -- Se añade el filtro para misma direccion consecutiva
	--on ini.id=fin_alt.id-2 and ini.sessionid=fin_alt.sessionid
group by ini.sessionid

--Dos clip de voz consecutivos (distinta dirección) con calidad < umbral
exec sp_lcc_dropifexists '_SQNS_DD' 
select  ini.sessionid,
		max(case 
			when ((ini.bandwidth=0 and (ini.MOS < 1.7 or ini.[status]='Silence'))
			and (fin.bandwidth=0 and (fin.MOS < 1.7 or fin.[status]='Silence'))) then 1 else 0 end) as SQNS_NB,
		--SUM(case when (ini.bandwidth=0 and ini.MOS < 1.7) then 1 else 0 end) as NB_Number_under_2,
		
		max(case 
			when ((ini.bandwidth<>0 and (ini.MOS < 1.3 or ini.[status]='Silence'))
			and (fin.bandwidth<>0 and (fin.MOS < 1.3 or fin.[status]='Silence'))) then 1 else 0 end) as SQNS_WB
		--SUM(case when (ini.bandwidth<>0 and ini.MOS < 1.3) then 1 else 0 end) as WB_Number_under_1_6

into _SQNS_DD
from  _tMOS ini 
	left outer join _tMOS fin 
	on ini.id=fin.id-1 and ini.sessionid=fin.sessionid
	--left outer join _tMOS fin_alt -- Se añade el filtro para misma direccion consecutiva
	--on ini.id=fin_alt.id-2 and ini.sessionid=fin_alt.sessionid
group by ini.sessionid


-- Evaluamos ambos casos
exec sp_lcc_dropifexists '_SQNS' 
Select   Case when max(sd.SQNS_NB) = 0 then max(dd.SQNS_NB) else max(sd.SQNS_NB) end as SQNS_NB
		,Case when max(sd.SQNS_WB) = 0 then max(dd.SQNS_WB) else max(sd.SQNS_WB) end as SQNS_WB
		,dd.sessionid
INTO _SQNS
from _SQNS_SD sd,_SQNS_DD dd
where sd.sessionid = dd.sessionid
group by dd.sessionid

-- We update the info of SQNS for more than 2 events under limits per call
--update _SQNS
--set SQNS_NB=1
--where sessionid in (Select SessionId from _SQNS where NB_Number_under_2 > 2 and SQNS_NB=0)

--update _SQNS
--set SQNS_WB=1
--where sessionid in (Select SessionId from _SQNS where WB_Number_under_1_6 > 2 and SQNS_WB=0)


--------------------- MOS END --------------------------------

-------------- CODECS TEMPORARY TABLE ------------------------
-- Codec type assigned by total time used by each call, Codec type sample Count per Call
exec sp_lcc_dropifexists '_codec' 
select  c.sessionid,
		MAX(CodecName) as CodecName,
		MAX(Codec) as Codec,
		SUM(case when codec > 0 then 1 end) as Codec_Registers,
		SUM(case when codecName = 'EFR' then 1 end) as EFR_Count,
		SUM(case when codecName = 'AMR 12.2' OR codecName = 'AMR 4.75' then 1 end) as FR_Count,
		SUM(case when CodecName = 'AMR 5.9' OR CodecName = 'AMR 7.4' then 1 end) as HR_Count,
		SUM(case when CodecName like 'AMR HR%' then 1 else null end) as AMR_HR_Count,
		SUM(case when CodecName like 'AMR FR%' then 1 else null end) as AMR_FR_Count,
		SUM(case when CodecName like 'AMR WB%' then 1 else null end) as AMR_WB_Count,
		SUM(case when (CodecName like 'AMR WB%' and (CodecName not in ('AMR WB 6.6','AMR WB 8.85','AMR WB 12.2'))) then 1 else null end) as AMR_WB_HD_Count

into _codec		
from
		(select sessionid, Codec, direction,
		(dbo.GetCodec(Codec) + case when (Codec) in (5, 6, 7, 8, 10, 11) then ' ' + CONVERT(varchar,CodecRate)
									   else ''
									   end) as CodecName

		from VoiceCodecTest
		where SessionId>@maxSession -- We only get the sessionIds to import
		group by SessionId, Codec, CodecRate, direction) c

group by c.SessionId
order by sessionid
-------------------- END CODECS -------------------------------

---------------------- POSITION -------------------------------
exec sp_lcc_dropifexists '_position_alt' 
--Position alternative temporal table for getting initial position of every call

select  s.sessionid,
		p.longitude,
		p.latitude,
		ROW_NUMBER() over (partition by s.sessionid order by p.msgtime asc) as id,
		null as idB

into _position_alt
from Position p, Sessions s
where p.SessionId=s.SessionId
and p.SessionId>@maxSession -- We only get the sessionIds to import

union  

select  s.sessionidA as sessionid,
		p.longitude,
		p.latitude,
		null as id,
		ROW_NUMBER() over (partition by s.sessionidA order by p.msgtime asc) as idB
		
from Position p, SessionsB s
where p.SessionId=s.SessionId
and p.SessionId>@maxSession -- We only get the sessionIds to import



-- We get initial position for B device
exec sp_lcc_dropifexists '_position_ini_A' 
select	pA.SessionId, 
		pA.longitude as longitude_ini_A,
		pA.latitude as latitude_ini_A

into _position_ini_A
from _position_alt pA
where pA.id =1


-- We get initial position for B device
exec sp_lcc_dropifexists '_position_ini_B' 
select	pB.SessionId, 
		pB.longitude as longitude_ini_B,
		pB.latitude as latitude_ini_B

into _position_ini_B
from _position_alt pB
where pB.idB =1


-- We get final position for A device
exec sp_lcc_dropifexists '_position_end_A' 
Select	s.SessionId,
		p.longitude as longitude_fin_A,
		p.latitude as latitude_fin_A

into _position_end_A
from sessions s,
position p

where s.PosId=p.PosId
and s.SessionId=p.SessionId


-- We get final position for B device
exec sp_lcc_dropifexists '_position_end_B' 
Select	s.SessionIdA as Sessionid,
		p.longitude as longitude_fin_B,
		p.latitude as latitude_fin_B

into _position_end_B
from sessionsB s,
position p

where s.PosId=p.PosId
and s.SessionId=p.SessionId

---------------------- END POSITION -------------------------------

------------------ FAST RETURN ------------------------------------
exec sp_lcc_dropifexists '_FAST_RETURN_MAIN' 
select 
	-- Cada una de las sesiones de voz:
	s.sessionid, s.info,s.tech,

	-- Fin de llamada en 3G:
	r.sessionid as RRCConReleaseComplete_sessionid,  
	r.samples as RRCConReleaseComplete_samples,
	r.RRCConReleaseComplete_last_time as RRCConReleaseComplete_last_time,
		
	-- Primer mensaje 4G en la propia sesion - paso rapido
	--l.sessionid LTERRCMessage_sessionid,  	
	--l.samples as LTERRCMessage_sample,
	l.LTERRCMessage_first_time as LTERRCMessage_first_time,

	-- Calculo duraciones 2G-3G en la propia sesion:
	0.001*case when r.RRCConReleaseComplete_last_time < l.LTERRCMessage_first_time 
		 then datediff(ms,convert(datetime,r.RRCConReleaseComplete_last_time,109), convert(datetime,l.LTERRCMessage_first_time,109)) 
	end as Duration_rel_compl_to_4g,
	/*cast(c.dlEUTRACarrierFreq as varchar(max)) as*/ c.dlEUTRACarrierFreq

into _FAST_RETURN_MAIN

from Filelist f, Sessions s
     left outer join 
		 (select sessionid, sum(1) as samples, min(msgtime) as RRCConReleaseComplete_last_time 
		 from WCDMARRCMessages
		 where msgtype like 'RRCConnectionReleaseComplete'
		 and SessionId>@maxSession
		 group by sessionid
		) r on r.sessionid=s.sessionid			-->=s.sessionid	and r.sessionid<=s.sessionid+1 		

	-- Para la vuelta a 4G 
      left outer join 
		(select vk.sessionid, sum(1) as samples, min(vk.EndTime) as LTERRCMessage_first_time
		from vresultskpi vk,
			(select sessionid, sum(1) as samples, min(msgtime) as RRCConReleaseComplete_time 
				 from WCDMARRCMessages
				 where msgtype like 'RRCConnectionReleaseComplete' --or  msgtype like 'RRCConnectionRelease') 
				 and SessionId>@maxSession
				 group by sessionid) r
		where vk.KPIId=38030 --and vk.sessionid>=s.sessionid and vk.sessionid<=s.sessionid+1 and vk.endtime>m.Release_time
			and vk.endtime>r.RRCConReleaseComplete_time
			and vk.sessionid>=r.sessionid and vk.sessionid<=r.sessionid+1
			and vk.SessionId>@maxSession

		 group by vk.sessionid
		) l on l.sessionid>=s.sessionid	and l.sessionid<=s.sessionid+1


	-- Indicacion de paso a 4G
	left outer join
		(select sessionid, sum(1) as samples, max(msgtime) RRCConnectionRelease_las_time, -- testid,channel,
		 cast(max(dbo.SQUMTSKeyValue(bin_message,logchantype,L3_Message,'dlEUTRACarrierFreq'))as varchar(max)) as dlEUTRACarrierFreq	 

		from vlcc_Layer3
		where l3_message like 'RRCConnectionRelease' and channel like 'DL_DCCH'
		and SessionId>@maxSession
		group by sessionid
		) c on c.sessionid=s.SessionId

where s.fileid=f.fileid and
	s.valid=1 
	--and s.tech like '%LTE%' --or s.tech like '%GSM%' ) 
	and s.sessionType like 'CALL' -- solo me interesan las llamadas
	and s.info in ('Completed', 'Failed', 'Dropped')
	and s.SessionId>@maxSession

exec sp_lcc_dropifexists '_FAST_RETURN'
select sessionid, min(Duration_rel_compl_to_4g) as Duration_rel_compl_to_4g, cast(dlEUTRACarrierFreq as varchar(max)) as dlEUTRACarrierFreq
into _FAST_RETURN
from _FAST_RETURN_MAIN
group by sessionid,cast(dlEUTRACarrierFreq as varchar(max))

------------------ END FAST RETURN ------------------------------------

-- DGP 08/02/2016:
--Calculamos todas las llamadas con CallRestablishment tras un Radio Link Failure
------------------ CALL RESTABLISHMENT ---------------------------------
exec sp_lcc_dropifexists '_tCallRes'
select  c.sessionid,
		c.callStatus,
		datediff(s,cu.CU_Last_Time, c.[callEndTimeStamp]) as second_CU_endCall,
		datediff(s,cr.CR_Last_Time, c.[callEndTimeStamp]) as second_CR_endCall,
		datediff(s,cub.CU_Last_Time, c.[callEndTimeStamp]) as second_CU_endCall_Bside,
		datediff(s,crb.CR_Last_Time, c.[callEndTimeStamp]) as second_CR_endCall_Bside,
		-- CR parte A:
		cu.RadioFailureCU_attempt,
		cu.CU_Last_Time,
		cr.CR_attempt,
		cr.CR_Last_Time,

		-- CR parte B:
		cub.RadioFailureCU_attempt as RadioFailureCU_attempt_Bside,
		cub.CU_Last_Time as CU_Last_Time_Bside,
		crb.CR_attempt as CR_attempt_Bside,
		crb.CR_Last_Time as CR_Last_Time_Bside

into _tCallRes

from 
	CallAnalysis c

	left outer join 
		(select sessionid, sum(1) as RadioFailureCU_attempt, max(msgtime) as CU_Last_Time 
		from WCDMARRCMessages where msgType like 'cellUpdate'
			and dbo.SQUMTSKeyValue(msg,LogChanType,msgType,
				'UL_CCCH_Message;message;cellUpdate;cellUpdateCause') in ('radiolinkFailure','rlc_unrecoverableError')
				--and sessionid=41046
		group by sessionid
		) cu on cu.sessionid=c.sessionid

	left outer join 
		(select sessionid, sum(1) as CR_attempt, max(msgtime) as CR_Last_Time 
		from [dbo].[vGSMmm] 
		where msg='CM Re-Establishment Request'
		group by sessionid
		) cr on cr.sessionid=c.sessionid

	, sessions s
	-- Sesiones parte B:
	,sessionsb sb

	left outer join 
		(select sessionid, sum(1) as RadioFailureCU_attempt, max(msgtime) as CU_Last_Time 
		from WCDMARRCMessages where msgType like 'cellUpdate'
			and dbo.SQUMTSKeyValue(msg,LogChanType,msgType,
			'UL_CCCH_Message;message;cellUpdate;cellUpdateCause') in ('radiolinkFailure','rlc_unrecoverableError')
		group by sessionid) cub on cub.sessionid=sb.sessionid
	 
	left outer join 
		(select sessionid, sum(1) as CR_attempt, max(msgtime) as CR_Last_Time 
		from [dbo].[vGSMmm] 
		where msg='CM Re-Establishment Request'
		group by sessionid) crb on crb.sessionid=sb.sessionid

where 
	c.callstatus not in ('System Release', 'Not Set')
	--and (cu.RadioFailureCU__attempt is not null or cr.CR_attempt is not null)
	and c.Sessionid=s.SessionId and s.valid=1
	and s.SessionId=sb.SessionIdA
	and c.sessionid > @maxSession


-- DGP 10/06/2016:
--Calculamos todas las llamadas con KPI EXTRAS de CEM

------------------ END CALL RESTABLISHMENT ----------------------------

-- RTP
exec sp_lcc_dropifexists '_RTP'
select  r.sessionid, 
		avg(case when rs.Mode = 0 then 1.0*rs.AVGjitter end) as RTP_Jitter_DL,
		avg(case when rs.Mode = 1 then 1.0*rs.AVGjitter end) as RTP_Jitter_UL,
		avg(case when rs.Mode = 0 then 1.0*rs.AVGPDV end) as RTP_Delay_DL,
		avg(case when rs.Mode = 1 then 1.0*rs.AVGPDV end) as RTP_Delay_UL

into _RTP
from  RTPStatistics rs, RTPStatisticsInfo r

where r.sessionid > @maxsession
and r.RTPStatID=rs.RTPStatID

group by r.sessionid


-- RTP B
exec sp_lcc_dropifexists '_RTP_B'
select  a.sessionid, 
		avg(case when rs.Mode = 0 then 1.0*rs.AVGjitter end) as RTP_Jitter_DL_BSide,
		avg(case when rs.Mode = 1 then 1.0*rs.AVGjitter end) as RTP_Jitter_UL_BSide,
		avg(case when rs.Mode = 0 then 1.0*rs.AVGPDV end) as RTP_Delay_DL_BSide,
		avg(case when rs.Mode = 1 then 1.0*rs.AVGPDV end) as RTP_Delay_UL_BSide

into _RTP_B
from  RTPStatistics rs, RTPStatisticsInfo r, sessionsB b, callanalysis a

where r.sessionid=b.sessionid
and a.sessionid=b.sessionidA
and r.RTPStatID=rs.RTPStatID
and a.sessionid > @maxsession

group by a.sessionid


--Paging
exec sp_lcc_dropifexists '_Paging'
select r.sessionid,
	   1.0*sum(case when r.errorcode = 0 then 1 else 0 end)/count(r.errorcode) as Paging_Success_Ratio

into _Paging	   
from resultskpi r
where (r.value3 like '%paging%' or r.value4 like '%paging%')
and r.sessionid > @maxsession


group by r.sessionid

--Paging B
exec sp_lcc_dropifexists '_Paging_B'
select a.sessionid,
	   1.0*sum(case when r.errorcode = 0 then 1 else 0 end)/count(r.errorcode) as Paging_Success_Ratio_BSide

into _Paging_B	   
from resultskpi r, callanalysis a, sessionsB b
where (r.value3 like '%paging%' or r.value4 like '%paging%')
and b.sessionid=r.sessionid
and a.sessionid=b.sessionidA 
and a.sessionid > @maxsession

group by a.sessionid


--Activate PDP Context
--PDP
exec sp_lcc_dropifexists '_PDP'
select r.sessionid,
	   1.0*sum(case when r.errorcode = 0 then 1 else 0 end)/count(r.errorcode) as PDP_Activate_Ratio

into _PDP	   
from resultskpi r
where r.kpiid=15200
and r.sessionid > @maxsession

group by r.sessionid

--PDP B
exec sp_lcc_dropifexists '_PDP_B'
select a.sessionid,
	   1.0*sum(case when r.errorcode = 0 then 1 else 0 end)/count(r.errorcode) as PDP_Activate_Ratio_BSide

into _PDP_B	   
from resultskpi r, callanalysis a, sessionsB b
where r.kpiid=15200
and b.sessionid=r.sessionid
and a.sessionid=b.sessionidA 
and a.sessionid > @maxsession

group by a.sessionid


-- LTE Return
exec sp_lcc_dropifexists '_LTE_Return'
select *
into _LTE_Return
from (
		select c.sessionid,vk.EndTime, row_number() over (partition by c.sessionid order by c.sessionid, vk.endtime) as id
		from resultskpi vk, lcc_markers_time ma, callanalysis c	
		where vk.KPIId=38030 
		and vk.sessionid>=c.sessionid 
		and vk.sessionid<=c.sessionid+1 
		and vk.endtime>ma.release_time
		and vk.sessionid > @maxsession
		group by c.SessionId, vk.EndTime
) f

where f.id=1

------------------------------------- END CRITERIO 3 ------------------------------------------------------


------------------- Select General ----------------------------
insert into lcc_calls_detailed
select  f.CallingModule as MTU,
		c.Sessionid, 
		c.Fileid,
		c.NetworkId,
		f.CollectionName,
		f.ASideFileName,
		f.BSideFileName, 
		f.IMEI,
		f.IMSI,
		LEFT(f.IMSI,3) as MCC,
		RIGHT(LEFT(f.IMSI,5),2) as MNC,
		case when (c.calltype like '%L%' or c.calltype like '%?%') then 'M2F'
		when c.calltype = 'M->M' then 'M2M' end as calltype,
		case when c.callDir = 'A->B' and c.callCause='Config Call' then 'SO' 
		when c.callDir = 'A->B' and c.callCause<>'Config Call' then 'MO' 
		else 'MT' end as callDir,
		c.callStatus,
		c.codeDescription,
		c.disconcause,
		c.disconlocation,
		case when c.callCause='Silence' then 1 else 0 end as Silent_call,
		case 
			when ((cr.RadioFailureCU_attempt > 0 or cr.CR_attempt > 0)
					and (cr.second_CU_endCall >= 0 or cr.second_CR_endCall >= 0)
					and c.callstatus='completed') then 1
			else 0
		end as CR_Affected_calls,
		
		-- ***********TECNOLOGIA**************

		case 
			when tif.Start_tech <> tif.Disconnect_tech then
				 tif.Start_tech+'/'+tif.Disconnect_tech
			else
				tif.Start_tech
			end as Technology,
		
		tif.Start_Band as StartTechnology,
		tif.Disconnect_Band as EndTechnology,
		ta.technology as Average_Technology,
		
		case 
			when tif.Start_tech_B <> tif.Disconnect_tech_B then
				 tif.Start_tech_B+'/'+tif.Disconnect_tech_B
			else
				tif.Start_tech_B
			end as Technology_B,
		
		tif.Start_Band_B as StartTechnology_B,
		tif.Disconnect_Band_B as EndTechnology_B,
		tb.technology as Average_Technology_B,
		
		
		case when c.band like '%RAT%' then tif.Disconnect_Band else c.band collate SQL_Latin1_General_CP1_CI_AS end as Band,  --se rellena a partir del callanalysis
		
		-- ***********ALERTING/CONNECT/DISCONNECT/CMSERVICE/TRYING/CSFB**************
		
		vef.CSFB_freq,
		vef.CSFB_Band,
		vef.Trying_freq,
		vef.Trying_Band,
		vef.CMService_freq,
		vef.CMService_Band,
		vef.Alerting_freq,
		vef.Alerting_Band,
		vef.Connect_freq,
		vef.Connect_Band,
		vef.Disconnect_freq,
		vef.Disconnect_Band,
		vef.CSFB_freq_B,
		vef.CSFB_Band_B,
		vef.Trying_freq_B,
		vef.Trying_Band_B,
		vef.CMService_freq_B,
		vef.CMService_Band_B,
		vef.Alerting_freq_B,
		vef.Alerting_Band_B,
		vef.Connect_freq_B,
		vef.Connect_Band_B,
		vef.Disconnect_freq_B,
		vef.Disconnect_Band_B,

		-- ***********DURACIONES**************

		cif.callStartDuration as CallStartTimeStamp,
		cif.callEndTimeStamp,
		cif.callDuration,

		isnull(tg.GSM_duration,0) as GSM_duration,
		isnull(tu.UMTS_duration,0) as UMTS_duration,
		isnull(tl.LTE_Duration,0) as LTE_Duration,
		isnull(tall.LTE2600_Duration,0) as LTE2600_Duration,
		isnull(tall.LTE2100_Duration,0) as LTE2100_Duration,
		isnull(tall.LTE1800_Duration,0) as LTE1800_Duration,
		isnull(tall.LTE800_Duration,0) as LTE800_Duration,
		isnull(tall.UMTS2100_Duration,0) as UMTS2100_Duration,
		isnull(tall.UMTS900_Duration,0) as UMTS900_Duration,
		isnull(tall.GSM_Duration,0) as GSMGSM_Duration,
		isnull(tall.DCS_Duration,0) as GSMDCS_Duration,
			
		isnull(tgb.GSM_duration,0) as GSM_duration_B,
		isnull(tub.UMTS_duration,0) as UMTS_duration_B,
		isnull(tlb.LTE_Duration,0) as LTE_Duration_B,
		isnull(tallb.UMTS2100_Duration,0) as UMTS2100_Duration_B,
		isnull(tallb.UMTS900_Duration,0) as UMTS900_Duration_B,
		isnull(tallb.GSM_Duration,0) as GSMGSM_Duration_B,
		isnull(tallb.DCS_Duration,0) as GSMDCS_Duration_B,
		isnull(tallb.LTE2600_Duration,0) as LTE2600_Duration_B,
		isnull(tallb.LTE2100_Duration,0) as LTE2100_Duration_B,
		isnull(tallb.LTE1800_Duration,0) as LTE1800_Duration_B,
		isnull(tallb.LTE800_Duration,0) as LTE800_Duration_B,
		
		-- ***********METODO**************
		ifc.AsideType + '/' + ifc.BsideType as CallMethod,
		
		case when (ifc.is_CSFB_A is not null and ifc.is_CSFB_B is not null) then 2
		     when (ifc.is_CSFB_A is not null or ifc.is_CSFB_B is not null) then 1
			 else 0
		end as is_CSFB,
		
		case when (ifc.is_SRVCC_A is not null and ifc.is_SRVCC_B is not null) then 2
		     when (ifc.is_SRVCC_A is not null or ifc.is_SRVCC_B is not null) then 1
			 else 0
		end as is_SRVCC,

		case when (ifc.is_VOLTE_A is not null and ifc.is_VOLTE_B is not null) then 2
		     when (ifc.is_VOLTE_A is not null or ifc.is_VOLTE_B is not null) then 1
			 else 0
		end as is_VOLTE,

		case when (ifc.is_VOLTE_HO_A is not null and ifc.is_VOLTE_HO_B is not null) then 2
		     when (ifc.is_VOLTE_HO_A is not null or ifc.is_VOLTE_HO_B is not null) then 1
			 else 0
		end as is_VOLTE_HO,

		case when (ifc.is_CSFB_A is not null and ifc.is_CSFB_B is not null) then 'AB'
		     when (ifc.is_CSFB_A is not null) then 'A'
			 when (ifc.is_CSFB_B is not null) then 'B'
			 else ''
		end as CSFB_Device,

		case when (ifc.is_SRVCC_A is not null and ifc.is_SRVCC_B is not null) then 'AB'
		     when (ifc.is_SRVCC_A is not null) then 'A'
			 when (ifc.is_SRVCC_B is not null) then 'B'
			 else ''
		end as SRVCC_Device,

		case when (ifc.is_VOLTE_A is not null and ifc.is_VOLTE_B is not null) then 'AB'
		     when (ifc.is_VOLTE_A is not null) then 'A'
			 when (ifc.is_VOLTE_B is not null) then 'B'
			 else ''
		end as VOLTE_Device,

		case when (ifc.is_VOLTE_HO_A is not null and ifc.is_VOLTE_HO_B is not null) then 'AB'
		     when (ifc.is_VOLTE_HO_A is not null) then 'A'
			 when (ifc.is_VOLTE_HO_B is not null) then 'B'
			 else ''
		end as VOLTE_HO_Device,
		
		-- ***********CST**************
		case when c.callDir = 'B->A' then alertingMT
			 when c.callDir = 'A->B' then alertingMO
			 End
			 as cst_till_alerting, 
			 
		case when c.callDir = 'B->A' then connectMT
			 when c.callDir = 'A->B' then connectMO
			 End
			 as cst_till_connect,  --ca: DEJO cst_till_connAck pero en realidad sería cst_till_conn
     
   
		case when c.callDir = 'B->A' and c.calltype = 'M->M' then    
			 case when cst.CSFB_Time_UB is not null then cst.CSFB_Time_UB  
			 else cst.CSFB_Time_UA end  
		else    
			 case when cst.CSFB_Time_UA is not null then cst.CSFB_Time_UA  
			 else cst.CSFB_Time_UB end  
		end as csfb_till_connRel,
 
		case when c.callDir = 'B->A' and c.calltype = 'M->M' then    
			 case when cst.CSFB_Time_AB is not null then cst.CSFB_Time_AB  
			 else cst.CSFB_Time_AA end  
		else    
			 case when cst.CSFB_Time_AA is not null then cst.CSFB_Time_AA  
			 else cst.CSFB_Time_AB end  
		end as csfb_till_alerting,
        
        datediff(ms,ma.Release_time, lr.endtime) as LTE_return,

		-- ***********POSICION**************
		piA.longitude_ini_A,
		piA.latitude_ini_A,
		piB.longitude_ini_B,
		piB.latitude_ini_B,
		peA.longitude_fin_A,
		peA.latitude_fin_A,
		peB.longitude_fin_B,
		peB.latitude_fin_B,

		-- ***********MOS**************
		m.MOS_NB,
		md.MOS_NB_DL,
		mu.MOS_NB_UL,
		m.Samples_NB as 'MOS_Samples_NB',
		m.[MOS_1-1.5_NB],
		m.[MOS_1.5-2_NB],
		m.[MOS_2-2.1_NB],
		m.[MOS_2.1-2.2_NB],
		m.[MOS_2.2-2.3_NB],
		m.[MOS_2.3-2.4_NB],
		m.[MOS_2.4-2.5_NB],
		m.[MOS_2.5-2.6_NB],
		m.[MOS_2.6-2.7_NB],
		m.[MOS_2.7-2.8_NB],
		m.[MOS_2.8-2.9_NB],
		m.[MOS_2.9-3_NB],
		m.[MOS_3-3.1_NB],
		m.[MOS_3.1-3.2_NB],
		m.[MOS_3.2-3.3_NB],
		m.[MOS_3.3-3.4_NB],
		m.[MOS_3.4-3.5_NB],
		m.[MOS_3.5-3.6_NB],
		m.[MOS_3.6-3.7_NB],
		m.[MOS_3.7-3.8_NB],
		m.[MOS_3.8-3.9_NB],
		m.[MOS_3.9-4_NB],
		m.[MOS_4-4.5_NB],
		m.[MOS_4.5-5_NB],
		m.MOS_WB,
		md.MOS_WB_DL,
		mu.MOS_WB_UL,
		m.Samples_WB as 'MOS_Samples_WB',
		m.[MOS_1-1.5_WB],
		m.[MOS_1.5-2_WB],
		m.[MOS_2-2.1_WB],
		m.[MOS_2.1-2.2_WB],
		m.[MOS_2.2-2.3_WB],
		m.[MOS_2.3-2.4_WB],
		m.[MOS_2.4-2.5_WB],
		m.[MOS_2.5-2.6_WB],
		m.[MOS_2.6-2.7_WB],
		m.[MOS_2.7-2.8_WB],
		m.[MOS_2.8-2.9_WB],
		m.[MOS_2.9-3_WB],
		m.[MOS_3-3.1_WB],
		m.[MOS_3.1-3.2_WB],
		m.[MOS_3.2-3.3_WB],
		m.[MOS_3.3-3.4_WB],
		m.[MOS_3.4-3.5_WB],
		m.[MOS_3.5-3.6_WB],
		m.[MOS_3.6-3.7_WB],
		m.[MOS_3.7-3.8_WB],
		m.[MOS_3.8-3.9_WB],
		m.[MOS_3.9-4_WB],
		m.[MOS_4-4.5_WB],
		m.[MOS_4.5-5_WB],

		m.MOS_GSM_Samples,
		m.MOS_DCS_Samples,
		m.MOS_UMTS_Samples,
		m.MOS_LTE_Samples,
		m.MOS_NB_GSM_AVG,
		m.MOS_NB_DCS_AVG,
		m.MOS_NB_UMTS_AVG,
		m.MOS_NB_LTE_AVG,
		m.[Samples_Under_2.5_NB] as 'MOS_NB_Samples_Under_2.5',
		m.MOS_WB_GSM_AVG,
		m.MOS_WB_DCS_AVG,
		m.MOS_WB_UMTS_AVG,
		m.MOS_WB_LTE_AVG,
		m.[Samples_Under_2.5_WB] as 'MOS_WB_Samples_Under_2.5',

		--CAC 11/01/2017: Nuevos KPIs incorporados
		m.MOS_UMTS900_NB_AVG,	
		m.MOS_UMTS900_WB_AVG,
		m.MOS_UMTS2100_NB_AVG,	
		m.MOS_UMTS2100_WB_AVG,		
		m.MOS_LTE800_NB_AVG,	
		m.MOS_LTE800_WB_AVG,
		m.MOS_LTE1800_NB_AVG,	
		m.MOS_LTE1800_WB_AVG,
		m.MOS_LTE2100_NB_AVG,	
		m.MOS_LTE2100_WB_AVG,
		m.MOS_LTE2600_NB_AVG,	
		m.MOS_LTE2600_WB_AVG,
		m.Samples_NB_GSM,
		m.Samples_WB_GSM,
		m.Samples_NB_DCS,
		m.Samples_WB_DCS,
		m.Samples_NB_UMTS900,
		m.Samples_WB_UMTS900,
		m.Samples_NB_UMTS2100,
		m.Samples_WB_UMTS2100,
		m.Samples_NB_LTE800,
		m.Samples_WB_LTE800,
		m.Samples_NB_LTE1800,
		m.Samples_WB_LTE1800,
		m.Samples_NB_LTE2100,
		m.Samples_WB_LTE2100,
		m.Samples_NB_LTE2600,
		m.Samples_WB_LTE2600,

		-- ***********SQNS**************
		m.SNR,
		m.Speech_Delay,
		sq.SQNS_NB,
		sq.SQNS_WB,
		co.CodecName,
		co.Codec_Registers,
		co.HR_Count,
		co.FR_Count,
		co.EFR_Count,
		co.AMR_HR_Count,
		co.AMR_FR_Count,
		co.AMR_WB_Count,
		co.AMR_WB_HD_Count,
		-- ***********HANDOVERS**************
		ho.Handovers,
		ho.Handover_Failures,
		ho.Handover_2G2G_Failures,
		ho.Handover_2G3G_Failures,
		ho.Handover_3G2G_Failures,
		ho.Handover_3G3G_Failures,
		ho.Handover_4G3G_Failures,
		ho.Handover_4G4G_Failures,
		ho.HOs_Duration_Avg,

		-- ***********RADIO 2G*************
		tra.RxLev,
		tra.RxQual,
		tra.Hopping,
		--tra.GSM_Samples,
		--tra.DCS_Samples,
		tra.RxQual_GSM,
		tra.RxQual_DCS,
		--tra.RxQual_samples,
		tra.RxQual_0,
		tra.RxQual_1,
		tra.RxQual_2,
		tra.RxQual_3,
		tra.RxQual_4,
		tra.RxQual_5,
		tra.RxQual_6,
		tra.RxQual_7,
		tri.BCCH as BCCH_Ini,
		tri.BSIC as BSIC_Ini,
		tri.RxLev as RxLev_Ini,
		tri.RxQual as RxQual_Ini,
		trf.BCCH as BCCH_Fin,
		trf.BSIC as BSIC_Fin,
		trf.RxLev as RxLev_Fin,
		trf.RxQual as RxQual_Fin,
		tra.RxLev_min,
		tra.RxQual_min,
		
		trab.RxLev as RxLev_B,
		trab.RxQual as RxQual_B,
		trab.Hopping as Hopping_B,
		--trab.GSM_Samples as GSM_Samples_B,
		--trab.DCS_Samples as DCS_Samples_B,
		trab.RxQual_GSM as RxQual_GSM_B,
		trab.RxQual_DCS as RxQual_DCS_B,
		--trab.RxQual_samples as RxQual_samples_B,
		trab.RxQual_0 as RxQual_0_B,
		trab.RxQual_1 as RxQual_1_B,
		trab.RxQual_2 as RxQual_2_B,
		trab.RxQual_3 as RxQual_3_B,
		trab.RxQual_4 as RxQual_4_B,
		trab.RxQual_5 as RxQual_5_B,
		trab.RxQual_6 as RxQual_6_B,
		trab.RxQual_7 as RxQual_7_B,
		trib.BCCH as BCCH_Ini_B,
		trib.BSIC as BSIC_Ini_B,
		trib.RxLev as RxLev_Ini_B,
		trib.RxQual as RxQual_Ini_B,
		trfb.BCCH as BCCH_Fin_B,
		trfb.BSIC as BSIC_Fin_B,
		trfb.RxLev as RxLev_Fin_B,
		trfb.RxQual as RxQual_Fin_B,
		trab.RxLev_min as RxLev_min_B,
		trab.RxQual_min as RxQual_min_B,

		gt1.N1_BCCH,
		gt1.N1_RxLev,
		gt1b.N1_BCCH as 'N1_BCCH_B',
		gt1b.N1_RxLev as 'N1_RxLev_B',

		-- ***********RADIO 3G**************
		tra.RSCP,
		tra.EcIo,
		--tra.UMTS2100_Samples,
		--tra.UMTS900_Samples,
		tri.PSC as PSC_Ini,
		tri.RSCP as RSCP_Ini,
		tri.EcIo as EcIo_Ini,
		tri.UARFCN as UARFCN_Ini,
		trf.PSC as PSC_Fin,
		trf.RSCP as RSCP_Fin,
		trf.EcIo as EcIo_Fin,
		trf.UARFCN as UARFCN_Fin,
		tra.RSCP_min,
		tra.EcIo_min,
		tra.EcIo_UMTS2100,
		tra.EcIo_UMTS900,
		--tra.EcIo_samples,
		tra.[EcIo [0, -2)],
		tra.[EcIo [-2, -4)],
		tra.[EcIo [-4, -6)],
		tra.[EcIo [-6, -8)],
		tra.[EcIo [-8, -10)],
		tra.[EcIo [-10, -12)],
		tra.[EcIo [-12, -14)],
		tra.[EcIo <= -14],

		trab.RSCP as RSCP_B,
		trab.EcIo as EcIo_B,
		--trab.UMTS2100_Samples as UMTS2100_Samples_B,
		--trab.UMTS900_Samples as UMTS900_Samples_B,
		trib.PSC as PSC_Ini_B,
		trib.RSCP as RSCP_Ini_B,
		trib.EcIo as EcIo_Ini_B,
		trib.UARFCN as UARFCN_Ini_B,
		trfb.PSC as PSC_Fin_B,
		trfb.RSCP as RSCP_Fin_B,
		trfb.EcIo as EcIo_Fin_B,
		trfb.UARFCN as UARFCN_Fin_B,
		trab.RSCP_min as RSCP_min_B,
		trab.EcIo_min as EcIo_min_B,
		trab.EcIo_UMTS2100 as EcIo_UMTS2100_B,
		trab.EcIo_UMTS900 as EcIo_UMTS900_B,
		--trab.EcIo_samples as EcIo_samples_B,
		trab.[EcIo [0, -2)] as [EcIo [0, -2)_B],
		trab.[EcIo [-2, -4)] as [EcIo [-2, -4)_B],
		trab.[EcIo [-4, -6)] as [EcIo [-4, -6)_B],
		trab.[EcIo [-6, -8)] as [EcIo [-6, -8)_B],
		trab.[EcIo [-8, -10)] as [EcIo [-8, -10)_B],
		trab.[EcIo [-10, -12)] as [EcIo [-10, -12)_B],
		trab.[EcIo [-12, -14)] as [EcIo [-12, -14)_B],
		trab.[EcIo <= -14] as [EcIo <= -14_B],

		wt1.N1_PSC,
		wt1.N1_RSCP,
		wt1b.N1_PSC as 'N1_PSC_B',
		wt1b.N1_RSCP as 'N1_RSCP_B',

		-- ***********RADIO 4G**************
		tra.RSRP,
		tra.RSRQ,
		tra.SINR,
		--tra.LTE800_Samples,
		--tra.LTE1800_Samples,
		--tra.LTE2600_Samples,
		tri.PCI as PCI_Ini,
		tri.RSRP as RSRP_Ini,
		tri.RSRQ as RSRQ_Ini,
		tri.SINR as SINR_ini,
		tri.EARFCN as EARFCN_Ini,
		trf.PCI as PCI_Fin,
		trf.RSRP as RSRP_Fin,
		trf.RSRQ as RSRQ_Fin,
		trf.SINR as SINR_fin,
		trf.EARFCN as EARFCN_Fin,
		tri.CId as CellId_Ini,
		tri.LAC as 'LAC/TAC_Ini',
		tri.RNCID as RNC_Ini,
		trf.CId as CellId_Fin,
		trf.LAC as 'LAC/TAC_Fin',
		trf.RNCID as RNC_Fin,
		rtp.RTP_Jitter_DL,
		rtp.RTP_Jitter_UL,
		rtp.RTP_Delay_DL,
		rtp.RTP_Delay_UL,
		pag.Paging_Success_Ratio,
		pdp.PDP_Activate_Ratio,
		neigh.EARFCN_N1,
		neigh.PCI_N1,
		neigh.RSRP_N1,
		neigh.RSRQ_N1,
		sr.SRVCC_SR,
		i.IRAT_HO2G3G_Ratio,
		ho4G.num_HO_S1X2,
		ho4G.duration_S1X2_avg,
		ho4G.S1X2HO_SR,
		
		trab.RSRP as RSRP_B,
		trab.RSRQ as RSRQ_B,
		trab.SINR as SINR_B,
		--trab.LTE800_Samples as LTE800_Samples_B,
		--trab.LTE1800_Samples as LTE1800_Samples_B,
		--trab.LTE2600_Samples as LTE2600_Samples_B,
		trib.PCI as PCI_Ini_B,
		trib.RSRP as RSRP_Ini_B,
		trib.RSRQ as RSRQ_Ini_B,
		trib.SINR as SINR_ini_B,
		trib.EARFCN as EARFCN_Ini_B,
		trfb.PCI as PCI_Fin_B,
		trfb.RSRP as RSRP_Fin_B,
		trfb.RSRQ as RSRQ_Fin_B,
		trfb.SINR as SINR_Fin_B,
		trfb.EARFCN as EARFCN_Fin_B,
		trib.CId as CellId_Ini_B,
		trib.LAC as 'LAC/TAC_Ini_B',
		trib.RNCID as RNC_Ini_B,
		trfb.CId as CellId_Fin_B,
		trfb.LAC as 'LAC/TAC_Fin_B',
		trfb.RNCID as RNC_Fin_B,
		rtpb.RTP_Jitter_DL_BSide as 'RTP_Jitter_DL_B',
		rtpb.RTP_Jitter_UL_BSide as 'RTP_Jitter_UL_B',
		rtpb.RTP_Delay_DL_BSide as 'RTP_Delay_DL_B',
		rtpb.RTP_Delay_UL_BSide as 'RTP_Delay_UL_B',
		pagb.Paging_Success_Ratio_BSide as 'Paging_Success_Ratio_B',
		pdpb.PDP_Activate_Ratio_BSide as 'PDP_Activate_Ratio_B',
		neigh.EARFCN_N1_BSide as 'EARFCN_N1_B',
		neigh.PCI_N1_BSide as 'PCI_N1_B',
		neigh.RSRP_N1_BSide as 'RSRP_N1_B',
		neigh.RSRQ_N1_BSide as 'RSRQ_N1_B',
		srb.SRVCC_SR_B,
		ib.IRAT_HO2G3G_Ratio_BSide as 'IRAT_HO2G3G_Ratio_B',
		ho4Gb.num_HO_S1X2_BSide as 'num_HO_S1X2_B',
		ho4Gb.duration_S1X2_avg_BSide as 'duration_S1X2_avg_B',
		ho4Gb.S1X2HO_SR_BSide as 'S1X2HO_SR_B',
	
		fr.Duration_rel_compl_to_4g as Fast_Return_Duration,
		fr.dlEUTRACarrierFreq as Fast_Return_Freq_Dest,

		-- ***********ROAMING**************
		--11/02/2018 MDM: Incorporamos KPIs de Roaming de Voz
		roa.Roaming_VF,
		roa.Roaming_MV,
		roa.Roaming_OR,
		roa.Roaming_YO,
		roa.Roaming_GSM,
		roa.Roaming_DCS,
		roa.Roaming_U900,
		roa.Roaming_U2100,
		roa.Roaming_LTE800,
		roa.Roaming_LTE1800,
		roa.Roaming_LTE2100,
		roa.Roaming_LTE2600,
		roa.Duration_Roaming_VF,
		roa.Duration_Roaming_MV,
		roa.Duration_Roaming_OR,
		roa.Duration_Roaming_YO,
		roa.Duration_Roaming_GSM,
		roa.Duration_Roaming_DCS,
		roa.Duration_Roaming_U900,
		roa.Duration_Roaming_U2100,
		roa.Duration_Roaming_LTE800,
		roa.Duration_Roaming_LTE1800,
		roa.Duration_Roaming_LTE2100,
		roa.Duration_Roaming_LTE2600,
		roa.Roaming_VF_B,
		roa.Roaming_MV_B,
		roa.Roaming_OR_B,
		roa.Roaming_YO_B,
		roa.Roaming_GSM_B,
		roa.Roaming_DCS_B,
		roa.Roaming_U900_B,
		roa.Roaming_U2100_B,
		roa.Roaming_LTE800_B,
		roa.Roaming_LTE1800_B,
		roa.Roaming_LTE2100_B,
		roa.Roaming_LTE2600_B,
		roa.Duration_Roaming_VF_B,
		roa.Duration_Roaming_MV_B,
		roa.Duration_Roaming_OR_B,
		roa.Duration_Roaming_YO_B,
		roa.Duration_Roaming_GSM_B,
		roa.Duration_Roaming_DCS_B,
		roa.Duration_Roaming_U900_B,
		roa.Duration_Roaming_U2100_B,
		roa.Duration_Roaming_LTE800_B,
		roa.Duration_Roaming_LTE1800_B,
		roa.Duration_Roaming_LTE2100_B,
		roa.Duration_Roaming_LTE2600_B,

		s.valid as valid,
		s.InvalidReason as invalidReason,
		f.ASideDevice, 
		f.BSideDevice, 
		f.SWVersion, 
		cRS.Respons_Side

from FileList f, Sessions s, CallAnalysis c

	left outer join _MOS_ALL m on m.SessionId=c.sessionId
	
	left outer join _MOS_DL md on md.SessionId=c.sessionId
	
	left outer join _MOS_UL mu on mu.SessionId=c.sessionId

	left outer join _SQNS sq on sq.SessionId=c.SessionId
	
	left outer join _codec co on co.SessionId=c.SessionId
	
	left outer join _TECH_RADIO_AVG_A tra on tra.SessionId=c.SessionId
	
	left outer join _TECH_RADIO_ini_A tri on tri.SessionId=c.SessionId
	
	left outer join _TECH_RADIO_FIN_A trf on trf.SessionId=c.SessionId

	left outer join _TECH_RADIO_AVG_B trab on trab.SessionId=c.SessionId
	
	left outer join _TECH_RADIO_ini_B trib on trib.SessionId=c.SessionId
	
	left outer join _TECH_RADIO_FIN_B trfb on trfb.SessionId=c.SessionId
	
	left outer join _TECH_GSM_DURATION_A tg on tg.SessionId=c.SessionId
	
	left outer join _TECH_UMTS_DURATION_A tu on tu.SessionId=c.SessionId

	left outer join _TECH_LTE_DURATION_A tl on tl.SessionId=c.SessionId

	left outer join _TECH_GSM_DURATION_B tgb on tgb.SessionId=c.SessionId
	
	left outer join _TECH_UMTS_DURATION_B tub on tub.SessionId=c.SessionId

	left outer join _TECH_LTE_DURATION_B tlb on tlb.SessionId=c.SessionId
	
	left outer join _TECH_Technology_DURATION_A tall on tall.SessionId=c.SessionId
	
	left outer join _TECH_Technology_DURATION_B tallb on tallb.SessionId=c.SessionId

	left outer join _TECH_AVG_A ta on ta.SessionId=c.SessionId

	left outer join _TECH_AVG_B tb on tb.SessionId=c.SessionId
	
	left outer join _HOs ho on ho.SessionId=c.SessionId
	
	left outer join _GSM_N_TOP1 gt1 on gt1.SessionId=c.SessionId

	left outer join _GSM_N_TOP1_B gt1b on gt1b.SessionId=c.SessionId
	
	left outer join _WCDMA_N_TOP1 wt1 on wt1.SessionId=c.SessionId

	left outer join _WCDMA_N_TOP1_B wt1b on wt1b.SessionId=c.SessionId
	
	left outer join lcc_markers_time ma on ma.sessionid=c.SessionId
	
	left outer join _position_ini_A piA on piA.SessionId=c.SessionId
	
	left outer join _position_ini_B piB on piB.SessionId=c.SessionId
	
	left outer join _position_end_A peA on peA.SessionId=c.SessionId
	
	left outer join _position_end_B peB on peB.SessionId=c.SessionId

	left outer join _CST_ALL cst on cst.sessionid=c.sessionid

	left outer join _FAST_RETURN fr on fr.sessionid=c.sessionid

	left outer join _LTE_Return lr on lr.sessionid=c.sessionid 
	
	left outer join _VOICE_EVENT_FREQ vef on vef.sessionid=c.sessionid
	
	left outer join _tCallRes cr on cr.sessionid=c.sessionid

	left outer join _call_info cif on cif.sessionid=c.sessionid

	left outer join _RTP rtp on rtp.sessionid=c.sessionid

	left outer join _RTP_B rtpb on rtpb.sessionid=c.sessionid

	left outer join _Paging pag on pag.sessionid=c.sessionid

	left outer join _Paging_B pagb on pagb.sessionid=c.sessionid

	left outer join _PDP pdp on pdp.sessionid=c.sessionid

	left outer join _PDP_B pdpb on pdpb.sessionid=c.sessionid

	left outer join _LTE_NEIGHBOR neigh on neigh.sessionid=c.sessionid

	left outer join _SRVCC sr on sr.sessionid=c.sessionid

	left outer join _SRVCC_B srb on srb.sessionid=c.sessionid

	left outer join _IRAT_HO i on i.sessionid=c.sessionid

	left outer join _IRAT_HO_B ib on ib.sessionid=c.sessionid

	left outer join _4GHO ho4G on ho4G.sessionid=c.sessionid

	left outer join _4GHO_B ho4Gb on ho4Gb.sessionid=c.sessionid

	left outer join _cRespons_Side cRS on cRS.sessionid=c.sessionid
	
	left outer join _ROAMING roa on roa.sessionid=c.sessionid 

	left outer join _info_Calls ifc on ifc.sessionid=c.sessionid

	left outer join _TECH_INI_FIN tif on tif.sessionid=c.sessionid


where f.FileId=c.FileId
--and c.PosId=p.PosId
and s.fileid=c.fileid
and s.SessionId=c.SessionId
and s.valid=1
--and (c.callcause <> 'Call Setup Timeout')
--and (c.callStatus <> 'failed' or (c.callStatus='failed' and not (c.codeDescription like '%voicebox%' or c.codeDescription like '%busy%' or c.disconcause like '%voicebox%' or c.disconcause like '%busy%' or c.callcause like '%voicebox%' or c.callcause like '%busy%')))-- Quitamos los fallos descartados por VDF Global

and c.SessionId>@maxSession -- We only get the sessionIds to import
order by c.sessionid

END

-------------------------------------------------------------------------------------------------
------------------------------------- UPDATING SECTION ------------------------------------------
-------------------------------------------------------------------------------------------------


update lcc_calls_detailed
set valid=0,invalidReason='lcc_voiceBox'
where  callstatus='failed' and
    ( codedescription like '%voicebox%' or  disconcause like '%voicebox%')

update lcc_calls_detailed
set valid=0,invalidReason='lcc_busy'
where  callstatus='failed' and
    ( codedescription like '%busy%' or  disconcause like '%busy%')

--Invalidaciones por duración
update lcc_calls_detailed
set valid=0,invalidReason='lcc_timeout'
where  callDuration>115
and callstatus in ('Completed','Failed','Dropped')


--Marcamos como fallidas las llamadas que en el CU de Vodafone marca como fallo 
--KPIID: 75001->Voice CS
--KPIID: 75101->Voice VOLTE Real
--KPIID: 75201->Voice VOLTE Capable

update lcc_calls_detailed
set callstatus='Failed', codeDescription = 'LCC CST timeout, original status: ' + callstatus,disconcause = 'LCC CST timeout'
from vresultskpi k, lcc_calls_detailed t
where k.sessionid=t.sessionid
and k.sessionid in (select sessionid 
					  from lcc_calls_detailed
					  where cst_till_connect > 15000
					  and (callstatus='dropped' or callstatus='completed')
					  and calltype = 'M2M') 
and kpiid in (75001,75101,75201) --KPIID que identifica que la llamada tiene más de 15 segundos
and errorcode <>0  --El cu de Vodafone lo marca como llamada Failed

--Las que no se han marcado como fallidas en resultsKPI, las invalidamos
update lcc_calls_detailed
set valid=0,invalidReason='LCC_CST_timeout'
where  sessionid in (select sessionid 
					 from lcc_calls_detailed
					 where cst_till_connect > 15000
					 and (callstatus='dropped' or callstatus='completed')
					 and calltype = 'M2M')

--Para las llamadas M2F invalidamos los CST mayores a 15 segundos y mayores que la duración total de la llamada
update lcc_calls_detailed
set valid=0,invalidReason='LCC_CST_timeout'
where  sessionid in (select sessionid
					 from lcc_calls_detailed
					 where cst_till_connect > 15000
					 and cst_till_connect/1000.0 >= callDuration
					 and callstatus in ('Dropped','Completed','Failed')
					 and calltype = 'M2F')

--Para las llamadas M2F marcamos como Fail los CST mayores a 15 segundos y menores que la duración total de la llamada
update lcc_calls_detailed
set callstatus='Failed', codeDescription = 'LCC CST timeout, original status: ' + callstatus,disconcause = 'LCC CST timeout'
where  sessionid in (select sessionid 
					 from lcc_calls_detailed
					 where cst_till_connect > 15000
					 and cst_till_connect/1000.0 < callDuration
					 and (callstatus='dropped' or callstatus='completed')
					 and calltype = 'M2F')

--Si alguno de los CST es negativo, lo igualamos al otro CST
update lcc_calls_detailed
set cst_till_connect=cst_till_alerting
where  sessionid in (select sessionid 
					 from lcc_calls_detailed
					 where cst_till_connect <0
					 )

update lcc_calls_detailed
set cst_till_alerting=cst_till_connect
where  sessionid in (select sessionid 
					 from lcc_calls_detailed
					 where cst_till_alerting <0
					 )

update sessions
set valid=0,invalidreason=c.invalidReason
from sessions s, lcc_calls_detailed c
where s.sessionid=c.Sessionid
	and c.valid=0 and s.valid=1	  

--************************************************************************************************************************
--MDM 13/02/2017: Anulamos la información de tecnología de inicio del lado B para llamadas M2F (se rellenará por el Dial)
--************************************************************************************************************************

update lcc_calls_detailed
set		Technology_B=null,
		StartTechnology_B=null
where calltype='M2F'
and sessionid> @maxSession

--********************************************************************************************************************
--CAC 20/12/2017: Si la suma de duraciones de tecnologia es ceros, se anulan las duraciones de tecnologia y la 
-- informacion de roaming
--********************************************************************************************************************

update lcc_calls_detailed
set		Average_Technology=null,		
		GSM_duration=null,
		UMTS_duration=null,		
		LTE_Duration=null,				
		LTE2600_Duration=null,LTE2100_Duration=null,LTE1800_Duration=null,LTE800_Duration=null,
		UMTS2100_Duration=null,UMTS900_Duration=null,
		GSMGSM_Duration=null,GSMDCS_Duration=null,		
		[Roaming_VF]=null,[Roaming_MV]=null,[Roaming_OR]=null,[Roaming_YO]=null,
		[Roaming_U900] =null,[Roaming_U2100]=null,
		[Roaming_LTE800] =null,[Roaming_LTE1800]=null,[Roaming_LTE2100]=null,[Roaming_LTE2600]=null,
		[Duration_roaming_VF]=null,[Duration_roaming_MV]=null,[Duration_roaming_OR]=null,[Duration_roaming_YO]=null,
		[Duration_roaming_U900]=null,[Duration_roaming_U2100]=null,
		[Duration_roaming_LTE800]=null,[Duration_roaming_LTE1800]=null,[Duration_roaming_LTE2100]=null,[Duration_roaming_LTE2600]=null
where isnull(GSM_Duration,0)+isnull(UMTS_Duration,0)+isnull(LTE_Duration,0)=0
and sessionid> @maxSession

update lcc_calls_detailed
set		Average_Technology_B=null,		
		GSM_duration_B=null,
		UMTS_duration_B=null,		
		LTE_Duration_B=null,				
		LTE2600_Duration_B=null,LTE2100_Duration_B=null,LTE1800_Duration_B=null,LTE800_Duration_B=null,
		UMTS2100_Duration_B=null,UMTS900_Duration_B=null,
		GSMGSM_Duration_B=null,GSMDCS_Duration_B=null,		
		[Roaming_VF_B]=null,[Roaming_MV_B]=null,[Roaming_OR_B]=null,[Roaming_YO_B]=null,
		[Roaming_U900_B] =null,[Roaming_U2100_B]=null,
		[Roaming_LTE800_B] =null,[Roaming_LTE1800_B]=null,[Roaming_LTE2100_B]=null,[Roaming_LTE2600_B]=null,
		[Duration_roaming_VF_B]=null,[Duration_roaming_MV_B]=null,[Duration_roaming_OR_B]=null,[Duration_roaming_YO_B]=null,
		[Duration_roaming_U900_B]=null,[Duration_roaming_U2100_B]=null,
		[Duration_roaming_LTE800_B]=null,[Duration_roaming_LTE1800_B]=null,[Duration_roaming_LTE2100_B]=null,[Duration_roaming_LTE2600_B]=null
where isnull(GSM_Duration_B,0)+isnull(UMTS_Duration_B,0)+isnull(LTE_Duration_B,0)=0
and sessionid> @maxSession


-- ******************************************************************************************************
--DGP 27/11/2015: Se actualizan los campos sin GPS, con la posición válida más cercana en el tiempo.
--DGP 07/03/2016: Se hacía hacia adelante en el tiempo, se añade ahora hacia atrás por si se da al final
--CAC 06/02/2017: Se almacenan las nuevas posiciones en la tabla Lcc_Entity_gps para tenerlas en cuenta
-- en las tablas de contorno. Además se corrige la ordenación para coger la más cercana en el tiempo
-- antes: order by (callstarttimeStamp/callendtimeStamp asc/desc), ahora: order by (timelink asc/desc)
-- ******************************************************************************************************

if (select name from sys.all_objects where name='Lcc_Entity_gps' and type='U') is null
begin
	CREATE TABLE [dbo].[Lcc_Entity_gps](
		[fileid] [bigint] NULL,
		[Longitude] [float] NULL,
		[Latitude] [float] NULL
	)
end
-------------------------------------------------------------------------
--Hacia Adelante en el tiempo (A)
-------------------------------------------------------------------------
--Insertamos en la tabla de gps las posiciones que vamos a simular para que se tengan en cuenta en la tabla de contornos

--insert into Lcc_Entity_gps
--select Fileid,(select top 1 longitude from lcc_timelink_position
--						where timelink>=master.dbo.fn_lcc_gettimelink(lc.callstarttimeStamp)
--						and collectionname=lc.collectionname
--						and side='A'
--						order by timelink asc) as longitude,
--	(select top 1 latitude from lcc_timelink_position
--						where timelink>=master.dbo.fn_lcc_gettimelink(lc.callstarttimeStamp)
--						and collectionname=lc.collectionname
--						and side='A'
--						order by timelink asc) as latitude
--from lcc_calls_detailed lc
--where
--	(lc.longitude_ini_A is null or lc.longitude_ini_A=0)
--	and sessionid> @maxSession

--insert into Lcc_Entity_gps
--select Fileid,(select top 1 longitude from lcc_timelink_position
--						where timelink>=master.dbo.fn_lcc_gettimelink(lc.callendtimeStamp)
--						and collectionname=lc.collectionname
--						and side='A'
--						order by timelink asc) as longitude,
--	(select top 1 latitude from lcc_timelink_position
--						where timelink>=master.dbo.fn_lcc_gettimelink(lc.callendtimeStamp)
--						and collectionname=lc.collectionname
--						and side='A'
--						order by timelink asc) as latitude
--from lcc_calls_detailed lc
--where
--	(lc.longitude_fin_A is null or lc.longitude_fin_A=0)
--	and sessionid> @maxSession

----Insertamos las posiciones simuladas
--update lcc_calls_detailed
--	set longitude_ini_A=(select top 1 longitude from lcc_timelink_position
--						where timelink>=master.dbo.fn_lcc_gettimelink(lc.callstarttimeStamp)
--						and collectionname=lc.collectionname
--						and side='A'
--						order by timelink asc),
--	latitude_ini_A=(select top 1 latitude from lcc_timelink_position
--						where timelink>=master.dbo.fn_lcc_gettimelink(lc.callstarttimeStamp)
--						and collectionname=lc.collectionname
--						and side='A'
--						order by timelink asc)
--from lcc_calls_detailed lc
--where
--	(lc.longitude_ini_A is null or lc.longitude_ini_A=0)
--	and sessionid> @maxSession

--update lcc_calls_detailed
--	set longitude_fin_A=(select top 1 longitude from lcc_timelink_position
--						where timelink>=master.dbo.fn_lcc_gettimelink(lc.callendtimeStamp)
--						and collectionname=lc.collectionname
--						and side='A'
--						order by timelink asc),
--	latitude_fin_A=(select top 1 latitude from lcc_timelink_position
--						where timelink>=master.dbo.fn_lcc_gettimelink(lc.callendtimeStamp)
--						and collectionname=lc.collectionname
--						and side='A'
--						order by timelink asc)
--from lcc_calls_detailed lc
--where
--	(lc.longitude_fin_A is null or lc.longitude_fin_A=0)
--	and sessionid> @maxSession

---------------------------------------------------------------------------
----Hacia Atras en el tiempo (A)
---------------------------------------------------------------------------
----Insertamos en la tabla de gps las posiciones que vamos a simular para que se tengan en cuenta en la tabla de contornos
--insert into Lcc_Entity_gps
--select Fileid,(select top 1 longitude from lcc_timelink_position
--						where timelink<=master.dbo.fn_lcc_gettimelink(lc.callstarttimeStamp)
--						and collectionname=lc.collectionname
--						and side='A'
--						order by timelink desc) as longitude,
--	(select top 1 latitude from lcc_timelink_position
--						where timelink<=master.dbo.fn_lcc_gettimelink(lc.callstarttimeStamp)
--						and collectionname=lc.collectionname
--						and side='A'
--						order by timelink desc) as latitude
--from lcc_calls_detailed lc
--where
--	(lc.longitude_ini_A is null or lc.longitude_ini_A=0)
--	and sessionid> @maxSession

--insert into Lcc_Entity_gps
--select Fileid,(select top 1 longitude from lcc_timelink_position
--						where timelink<=master.dbo.fn_lcc_gettimelink(lc.callendtimeStamp)
--						and collectionname=lc.collectionname
--						and side='A'
--						order by timelink desc) as longitude,
--	(select top 1 latitude from lcc_timelink_position
--						where timelink<=master.dbo.fn_lcc_gettimelink(lc.callendtimeStamp)
--						and collectionname=lc.collectionname
--						and side='A'
--						order by timelink desc) as latitude
--from lcc_calls_detailed lc
--where
--	(lc.longitude_fin_A is null or lc.longitude_fin_A=0)
--	and sessionid> @maxSession

----Insertamos las posiciones simuladas
--update lcc_calls_detailed
--	set longitude_ini_A=(select top 1 longitude from lcc_timelink_position
--						where timelink<=master.dbo.fn_lcc_gettimelink(lc.callstarttimeStamp)
--						and collectionname=lc.collectionname
--						and side='A'
--						order by timelink desc),
--	latitude_ini_A=(select top 1 latitude from lcc_timelink_position
--						where timelink<=master.dbo.fn_lcc_gettimelink(lc.callstarttimeStamp)
--						and collectionname=lc.collectionname
--						and side='A'
--						order by timelink desc)
--from lcc_calls_detailed lc
--where
--	(lc.longitude_ini_A is null or lc.longitude_ini_A=0)
--	and sessionid> @maxSession

--update lcc_calls_detailed
--	set longitude_fin_A=(select top 1 longitude from lcc_timelink_position
--						where timelink<=master.dbo.fn_lcc_gettimelink(lc.callendtimeStamp)
--						and collectionname=lc.collectionname
--						and side='A'
--						order by timelink desc),
--	latitude_fin_A=(select top 1 latitude from lcc_timelink_position
--						where timelink<=master.dbo.fn_lcc_gettimelink(lc.callendtimeStamp)
--						and collectionname=lc.collectionname
--						and side='A'
--						order by timelink desc)
--from lcc_calls_detailed lc
--where
--	(lc.longitude_fin_A is null or lc.longitude_fin_A=0)
--	and sessionid> @maxSession


---------------------------------------------------------------------------
----Hacia Adelante en el tiempo (B)
---------------------------------------------------------------------------
----Insertamos en la tabla de gps las posiciones que vamos a simular para que se tengan en cuenta en la tabla de contornos
--insert into Lcc_Entity_gps
--select Fileid,(select top 1 longitude from lcc_timelink_position
--						where timelink>=master.dbo.fn_lcc_gettimelink(lc.callstarttimeStamp)
--						and collectionname=lc.collectionname
--						and side='B'
--						order by timelink asc) as longitude,
--	(select top 1 latitude from lcc_timelink_position
--						where timelink>=master.dbo.fn_lcc_gettimelink(lc.callstarttimeStamp)
--						and collectionname=lc.collectionname
--						and side='B'
--						order by timelink asc) as latitude
--from lcc_calls_detailed lc
--where
--	(lc.longitude_ini_B is null or lc.longitude_ini_B=0)
--	and sessionid> @maxSession

--insert into Lcc_Entity_gps
--select Fileid,(select top 1 longitude from lcc_timelink_position
--						where timelink>=master.dbo.fn_lcc_gettimelink(lc.callendtimeStamp)
--						and collectionname=lc.collectionname
--						and side='B'
--						order by timelink asc) as longitude,
--	(select top 1 latitude from lcc_timelink_position
--						where timelink>=master.dbo.fn_lcc_gettimelink(lc.callendtimeStamp)
--						and collectionname=lc.collectionname
--						and side='B'
--						order by timelink asc) as latitude
--from lcc_calls_detailed lc
--where
--	(lc.longitude_fin_B is null or lc.longitude_fin_B=0)
--	and sessionid> @maxSession

----Insertamos las posiciones simuladas
--update lcc_calls_detailed
--	set longitude_ini_B=(select top 1 longitude from lcc_timelink_position
--						where timelink>=master.dbo.fn_lcc_gettimelink(lc.callstarttimeStamp)
--						and collectionname=lc.collectionname
--						and side='B'
--						order by timelink asc),
--	latitude_ini_B=(select top 1 latitude from lcc_timelink_position
--						where timelink>=master.dbo.fn_lcc_gettimelink(lc.callstarttimeStamp)
--						and collectionname=lc.collectionname
--						and side='B'
--						order by timelink asc)
--from lcc_calls_detailed lc
--where
--	(lc.longitude_ini_B is null or lc.longitude_ini_B=0)
--	and sessionid> @maxSession

--update lcc_calls_detailed
--	set longitude_fin_B=(select top 1 longitude from lcc_timelink_position
--						where timelink>=master.dbo.fn_lcc_gettimelink(lc.callendtimeStamp)
--						and collectionname=lc.collectionname
--						and side='B'
--						order by timelink asc),
--	latitude_fin_B=(select top 1 latitude from lcc_timelink_position
--						where timelink>=master.dbo.fn_lcc_gettimelink(lc.callendtimeStamp)
--						and collectionname=lc.collectionname
--						and side='B'
--						order by timelink asc)
--from lcc_calls_detailed lc
--where
--	(lc.longitude_fin_B is null or lc.longitude_fin_B=0)
--	and sessionid> @maxSession

---------------------------------------------------------------------------
----Hacia Atras en el tiempo (B)
---------------------------------------------------------------------------
----Insertamos en la tabla de gps las posiciones que vamos a simular para que se tengan en cuenta en la tabla de contornos
--insert into Lcc_Entity_gps
--select Fileid,(select top 1 longitude from lcc_timelink_position
--						where timelink<=master.dbo.fn_lcc_gettimelink(lc.callstarttimeStamp)
--						and collectionname=lc.collectionname
--						and side='B'
--						order by timelink desc) as longitude,
--	(select top 1 latitude from lcc_timelink_position
--						where timelink<=master.dbo.fn_lcc_gettimelink(lc.callstarttimeStamp)
--						and collectionname=lc.collectionname
--						and side='B'
--						order by timelink desc) as latitude
--from lcc_calls_detailed lc
--where
--	(lc.longitude_ini_B is null or lc.longitude_ini_B=0)
--	and sessionid> @maxSession

--insert into Lcc_Entity_gps
--select Fileid,(select top 1 longitude from lcc_timelink_position
--						where timelink<=master.dbo.fn_lcc_gettimelink(lc.callendtimeStamp)
--						and collectionname=lc.collectionname
--						and side='B'
--						order by timelink desc) as longitude,
--	(select top 1 latitude from lcc_timelink_position
--						where timelink<=master.dbo.fn_lcc_gettimelink(lc.callendtimeStamp)
--						and collectionname=lc.collectionname
--						and side='B'
--						order by timelink desc) as latitude
--from lcc_calls_detailed lc
--where
--	(lc.longitude_fin_B is null or lc.longitude_fin_B=0)
--	and sessionid> @maxSession

----Insertamos las posiciones simuladas
--update lcc_calls_detailed
--	set longitude_ini_B=(select top 1 longitude from lcc_timelink_position
--						where timelink<=master.dbo.fn_lcc_gettimelink(lc.callstarttimeStamp)
--						and collectionname=lc.collectionname
--						and side='B'
--						order by timelink desc),
--	latitude_ini_B=(select top 1 latitude from lcc_timelink_position
--						where timelink<=master.dbo.fn_lcc_gettimelink(lc.callstarttimeStamp)
--						and collectionname=lc.collectionname
--						and side='B'
--						order by timelink desc)
--from lcc_calls_detailed lc
--where
--	(lc.longitude_ini_B is null or lc.longitude_ini_B=0)
--	and sessionid> @maxSession

--update lcc_calls_detailed
--	set longitude_fin_B=(select top 1 longitude from lcc_timelink_position
--						where timelink<=master.dbo.fn_lcc_gettimelink(lc.callendtimeStamp)
--						and collectionname=lc.collectionname
--						and side='B'
--						order by timelink desc),
--	latitude_fin_B=(select top 1 latitude from lcc_timelink_position
--						where timelink<=master.dbo.fn_lcc_gettimelink(lc.callendtimeStamp)
--						and collectionname=lc.collectionname
--						and side='B'
--						order by timelink desc)
--from lcc_calls_detailed lc
--where
--	(lc.longitude_fin_B is null or lc.longitude_fin_B=0)
--	and sessionid> @maxSession



----Para quitar las parte B no informadas en M2F o quitar simulaciones no encontradas
--delete Lcc_Entity_gps
--where latitude is null and longitude is null


---- ***************************************************************************************************

----DGP 10/12/2015: Se actualizan los campos con SQNS, anulando el MOS para que no cuente para la media
---- ***************************************************************************************************

----update lcc_calls_detailed
----set MOS_NB=null,
----	--CAC 11/01/2017: Se anulan el resto de campos de mos para que tampoco cuenten
----	MOS_NB_GSM_AVG=null,
----	MOS_NB_DCS_AVG=null,
----	MOS_NB_UMTS_AVG=null,
----	MOS_NB_LTE_AVG=null,
----	MOS_UMTS900_NB_AVG=null,
----	MOS_UMTS2100_NB_AVG=null,
----	MOS_LTE800_NB_AVG=null,
----	MOS_LTE1800_NB_AVG=null,
----	MOS_LTE2100_NB_AVG=null,
----	MOS_LTE2600_NB_AVG=null,
----	MOS_Samples_NB=0,
----	[MOS_NB_Samples_Under_2.5]=0,
----	Samples_NB_GSM900=0,
----	Samples_NB_GSM1800=0,
----	Samples_NB_UMTS900=0,
----	Samples_NB_UMTS2100=0,
----	Samples_NB_LTE800=0,
----	Samples_NB_LTE1800=0,
----	Samples_NB_LTE2100=0,
----	Samples_NB_LTE2600=0
----where SQNS_NB=1
----and sessionid> @maxSession

----update lcc_calls_detailed
----set MOS_WB=null,
----	--CAC 11/01/2017: Se anulan el resto de campos de mos para que tampoco cuenten
----	MOS_WB_GSM_AVG=null,
----	MOS_WB_DCS_AVG=null,
----	MOS_WB_UMTS_AVG=null,
----	MOS_WB_LTE_AVG=null,
----	MOS_UMTS900_WB_AVG=null,
----	MOS_UMTS2100_WB_AVG=null,
----	MOS_LTE800_WB_AVG=null,
----	MOS_LTE1800_WB_AVG=null,
----	MOS_LTE2100_WB_AVG=null,
----	MOS_LTE2600_WB_AVG=null,
----	MOS_Samples_WB=0,
----	[MOS_WB_Samples_Under_2.5]=0,
----	Samples_WB_GSM900=0,
----	Samples_WB_GSM1800=0,
----	Samples_WB_UMTS900=0,
----	Samples_WB_UMTS2100=0,
----	Samples_WB_LTE800=0,
----	Samples_WB_LTE1800=0,
----	Samples_WB_LTE2100=0,
----	Samples_WB_LTE2600=0
----where SQNS_WB=1
----and sessionid> @maxSession
---- ***************************************************************************************************



----********************************************************************************************************************
----CAC 16/01/2017: Se anulan las duraciones por tecnologia en los bloqueos (informacion de setup al disconnect)
----********************************************************************************************************************

----********************************************************************************************************************
----MDM 15/12/2017: Se comenta esta parte porque se cambia el criterio de duraciones en los bloqueos (Antes la duración se 
----calculaba del setup al disconnect y ahora se calcula desde el start al disconnect (tamaño de la ventana))
----********************************************************************************************************************
----update lcc_calls_detailed
----set		Average_Technology=null,		
----		GSM_duration=null,
----		UMTS_duration=null,		
----		Average_Technology_B=null,
----		LTE_Duration=null,
----		GSM_duration_B=null,
----		UMTS_duration_B=null,
----		LTE_Duration_B=null,		
----		LTE2600_Duration=null,
----		LTE2100_Duration=null,
----		LTE1800_Duration=null,
----		LTE800_Duration=null,
----		UMTS2100_Duration=null,
----		UMTS900_Duration=null,
----		GSM900_Duration=null,
----		GSM1800_Duration=null,
----		UMTS2100_Duration_B=null,
----		UMTS900_Duration_B=null,
----		GSM900_Duration_B=null,
----		GSM1800_Duration_B=null,
----		LTE2600_Duration_B=null,
----		LTE2100_Duration_B=null,
----		LTE1800_Duration_B=null,
----		LTE800_Duration_B=null
----where callstatus='failed'
----and sessionid> @maxSession

----********************************************************************************************************************

---- DGP 31/08/2016: Ya no es necesario
----------DGP 20/01/2016:
---- *********************** Invalidamos las sesiones de Main o Smaller fuera de contorno **************************

----if (db_name() like '%main%' or db_name() like '%smaller%')
----begin

----update sessions
----set valid=0, invalidReason='LCC OutOfBounds'
----where sessionid in (
----	select d.sessionid from lcc_calls_detailed d, agrids.dbo.lcc_parcelas lp
----	where 
----	(lp.nombre=master.dbo.fn_lcc_getParcel(d.[Longitude_Fin_A], d.[Latitude_Fin_A])
----	or lp.nombre=master.dbo.fn_lcc_getParcel(d.[Longitude_Fin_B], d.[Latitude_Fin_B]))
----	and (lp.entorno not like '[0-9]%' and lp.entorno not like 'LA [0-9]%')
----	and d.sessionid > @maxSession)
----and valid=1

----end

------DGP 03/02/2016:
------ ********* Invalidamos las sesiones de Main o Smaller con alguno de los coches en entorno distinto *********

----if (db_name() like '%main%' or db_name() like '%smaller%')
----begin

----update sessions
----set valid=0, invalidReason='LCC WrongEnvironment'
----where sessionid in (
----	select vA.sessionid from 

----		(select lp.entorno, d.* from lcc_calls_detailed d, agrids.dbo.lcc_parcelas lp
----			where 
----			lp.nombre=master.dbo.fn_lcc_getParcel(d.[Longitude_Fin_A], d.[Latitude_Fin_A])
----			and (lp.entorno like '[0-9]%' or lp.entorno like 'LA [0-9]%')
----			and d.sessionid > @maxSession) vA,


----		(select lp.entorno, d.* from lcc_calls_detailed d, agrids.dbo.lcc_parcelas lp
----			where 
----			lp.nombre=master.dbo.fn_lcc_getParcel(d.[Longitude_Fin_B], d.[Latitude_Fin_B])
----			and (lp.entorno like '[0-9]%' or lp.entorno like 'LA [0-9]%')
----			and d.sessionid > @maxSession) vB

----		where vA.sessionid=vB.sessionid
----		and vA.entorno<>vB.entorno
----	)
----and valid=1
----end


--drop table _SQNS,_SQNS_SD,_SQNS_DD,_tMOS,_codec,_MOS_ALL,_MOS_DL,_MOS_UL, _TECH_RADIO_AVG_A, _TECH_RADIO_ini_A, _TECH_RADIO_FIN_A,
--_TECH_RADIO_AVG_B, _TECH_RADIO_ini_B, _TECH_RADIO_FIN_B,_DURATION_MAIN,_TECH_AVG_A,_TECH_AVG_B, _HOs,_GSM_NEIGHBOR,_GSM_NEIGHBOR_B,_GSM_N_TOP1,_GSM_N_TOP1_B,
--_WCDMA_NEIGHBOR,_WCDMA_NEIGHBOR_B,_WCDMA_N_TOP1,_WCDMA_N_TOP1_B,_TECH_GSM_DURATION_A,_TECH_GSM_DURATION_B,_TECH_UMTS_DURATION_A, _TECH_UMTS_DURATION_B, _position_alt, _position_end_A, _position_end_B,
--_position_ini_A, _position_ini_B,_Alert_Connect_AB,_CST_ALL, _FAST_RETURN, _VOICE_EVENT_FREQ, _VOICE_EVENT_TIME, 
--_TECH_LTE_DURATION_A, _TECH_LTE_DURATION_B,_tCallRes, _RRC, _RRCB, _Disconnect,_cRespons_Side,
--_DURATION_MAIN_Technology,_TECH_Technology_DURATION_A,_TECH_Technology_DURATION_B,
--_RTP, _RTP_B, _Paging, _Paging_B, _PDP, _PDP_B, _LTE_NEIGHBOR, _SRVCC, _SRVCC_B, _IRAT_HO, _IRAT_HO_B, _4GHO, _4GHO_B,
--_CSFB_StartA_B, _CSFB_StartA_A, _CSFB_StartU_B, _CSFB_StartU_A,  _LTE_Return, _ROAMING,_ROAMING_MAIN,_lcc_Serving_Cell_Table_info_interval,_call_info, _Disconnect_EVENT,_HO,_HO_B,_info_Calls,
--_RRCB_VOLTE,_RRC_VOLTE,_type_Calls,_TECH_INI_FIN,_FAST_RETURN_MAIN


--_RRC_StartC_10109,_RRC_StartA,_RRC_StartC,_VOLTE_StartA, _VOLTE_StartC,_VOLTE_StartCB,_VOLTE_StartAB