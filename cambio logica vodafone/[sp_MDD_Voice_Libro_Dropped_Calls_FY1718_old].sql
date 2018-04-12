USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_MDD_Voice_Libro_Dropped_Calls_FY1718]    Script Date: 04/01/2018 12:30:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_MDD_Voice_Libro_Dropped_Calls_FY1718] (
	 --Variables de entrada
				@ciudad as varchar(256),
				@simOperator as int,
				@type as varchar (256),
				@Environ as varchar (256),
				@EntityList as varchar (256),
				@ReportType as varchar (256)
				)
AS

-------------------------------------------------------------------------------
--	Variables para pruebas:
-------------------------------------------------------------------------------
----	Antiguas Variables de entrada:
--				--@ciudad as varchar(256),
--				--@simOperator as int,
--				--@type as varchar(256),
--				--@Date as varchar (256),
--				--@TechF as varchar (256),
--				--@Environ as varchar (256),
--				--@EntityList as varchar (256)
--				--)

--USE FY1718_VOICE_JEREZ_4G_H1
----exec sp_MDD_Voice_Libro_Dropped_Calls_FY1718 'JEREZ', 1, 'M2M', '%%', 'VDF','4G'

----	Nuevas Variables de entrada:
--declare @ciudad as varchar(256) = 'JEREZ'
--declare @simOperator as int = 1
--declare @type as varchar(256) = 'M2M'
--declare @Environ as varchar(256) = '%%'
--declare @EntityList as varchar(256) = 'VDF' 
--declare @ReportType as varchar(256) = 'CSFB'


-------------------------------------------------------------------------------
--	Tipo de reporte:
-------------------------------------------------------------------------------
-- Establecemos el tipo de Reporte -  el 6ª elemento del collectionname debe coincidir con:
--		* Reporte '3G'		- antiguo 3G, deja de medirse VOZ 3G en FY1718	- collectionname acaba en _3G	
--		* Reporte '4G'		- antiguo 4G, se convierte en 'CSFB'			- collectionname acaba en _4G
--		* Reporte 'CSFB'	- nuevo en FY1718, igual al '4G'antiguo			- collectionname acaba en _4G		
--		* Reporte 'VOLTE'	- reportes antiguos acaban en _4G				- collectionname acaba en _4G	- bbdd de VOLTE
--							  reportes nuevos acaban en _VOLTE		

-- Para entidades antiguas, la diferencia será en la bbdd en la que se lance

if @ReportType='CSFB'  set @ReportType='4G'

-- En las bases de datos de VOLTE antiguas el collectionname no contiene la palabra "VOLTE" si no "4G"
-- 20170919: @MDM: quitamos de este filtro las bases de datos Williams
if db_name() like '%VOLTE%' and db_name() not like '%WILL%' set @ReportType='4G'

declare @Meas_Round as varchar(256)

if (charindex('AVE',db_name())>0 and charindex('Rest',db_name())=0)
	begin 
		set @Meas_Round= [master].dbo.fn_lcc_getElement(1, db_name(),'_') + '_' + [master].dbo.fn_lcc_getElement(6, db_name(),'_')
	end
else
	begin
		set @Meas_Round= [master].dbo.fn_lcc_getElement(1, db_name(),'_') + '_' + [master].dbo.fn_lcc_getElement(5, db_name(),'_')
	end

-------------------------------------------------------------------------------
--	Tabla con todas las sesiones:
-------------------------------------------------------------------------------
-- drop table #all_Tests
create table #All_Tests (
	[SessionId] bigint
)


-------------------------------------------------------------------------------
--	Seleccion de la Entity_List:
-------------------------------------------------------------------------------	
If @EntityList='VDF'
begin	
	insert into #All_Tests
	select v.sessionid
	from lcc_Calls_Detailed v, lcc_position_Entity_List_Vodafone c, lcc_position_Entity_List_Vodafone c2
	Where --v.collectionname like @Date + '%' + @ciudad + '%' + @TechF
		v.MNC = @simOperator	--MNC
		and v.MCC= 214						--MCC - Descartamos los valores erróneos	
		and v.calltype = @type
		and c.fileid=v.fileid
		and (
				(@type='M2M' and c.entity_name = @Ciudad and c2.entity_name = @Ciudad)

				or

				(@type='M2F' and c.entity_name = @Ciudad)

			)
		and c.fileid=c2.fileid
		and 
			(
				(@type='M2M' and (c.lonid=master.dbo.fn_lcc_longitude2lonid ([Longitude_Fin_A], [Latitude_Fin_A])
				and c.latid=master.dbo.fn_lcc_latitude2latid ([Latitude_Fin_A]))
						and
				(c2.lonid=master.dbo.fn_lcc_longitude2lonid ([Longitude_Fin_B], [Latitude_Fin_B])
				and c2.latid=master.dbo.fn_lcc_latitude2latid ([Latitude_Fin_B]))
				)
					or
				(@type='M2F' and c.lonid=master.dbo.fn_lcc_longitude2lonid ([Longitude_Fin_A], [Latitude_Fin_A])
				and c.latid=master.dbo.fn_lcc_latitude2latid ([Latitude_Fin_A])
				)
			)
		and v.collectionname like '%'+@ReportType+'%' 

	group by v.sessionid
	OPTION (RECOMPILE)
end


If @EntityList='OSP'
begin	
	insert into #All_Tests
	select v.sessionid
	from lcc_Calls_Detailed v, lcc_position_Entity_List_Orange c, lcc_position_Entity_List_Orange c2
	Where --v.collectionname like @Date + '%' + @ciudad + '%' + @TechF
		v.MNC = @simOperator	--MNC
		and v.MCC= 214						--MCC - Descartamos los valores erróneos	
		and v.calltype = @type
		and c.fileid=v.fileid
		and (
				(@type='M2M' and c.entity_name = @Ciudad and c2.entity_name = @Ciudad)

				or

				(@type='M2F' and c.entity_name = @Ciudad)

			)
		and c.fileid=c2.fileid
		and 
			(
				(@type='M2M' and (c.lonid=master.dbo.fn_lcc_longitude2lonid ([Longitude_Fin_A], [Latitude_Fin_A])
				and c.latid=master.dbo.fn_lcc_latitude2latid ([Latitude_Fin_A]))
						and
				(c2.lonid=master.dbo.fn_lcc_longitude2lonid ([Longitude_Fin_B], [Latitude_Fin_B])
				and c2.latid=master.dbo.fn_lcc_latitude2latid ([Latitude_Fin_B]))
				)
					or
				(@type='M2F' and c.lonid=master.dbo.fn_lcc_longitude2lonid ([Longitude_Fin_A], [Latitude_Fin_A])
				and c.latid=master.dbo.fn_lcc_latitude2latid ([Latitude_Fin_A])
				)
			)
		and v.collectionname like '%'+@ReportType+'%'  

	group by v.sessionid
	OPTION (RECOMPILE)
end


If @EntityList='MUN'
begin	
	insert into #All_Tests
	select v.sessionid
	from lcc_Calls_Detailed v, lcc_position_Entity_List_Municipio c, lcc_position_Entity_List_Municipio c2
	Where --v.collectionname like @Date + '%' + @ciudad + '%' + @TechF
		v.MNC = @simOperator	--MNC
		and v.MCC= 214						--MCC - Descartamos los valores erróneos	
		and v.calltype = @type
		and c.fileid=v.fileid
		and (
				(@type='M2M' and c.entity_name = @Ciudad and c2.entity_name = @Ciudad)

				or

				(@type='M2F' and c.entity_name = @Ciudad)

			)

		and c.fileid=c2.fileid
		and 
			(
				(@type='M2M' and (c.lonid=master.dbo.fn_lcc_longitude2lonid ([Longitude_Fin_A], [Latitude_Fin_A])
				and c.latid=master.dbo.fn_lcc_latitude2latid ([Latitude_Fin_A]))
						and
				(c2.lonid=master.dbo.fn_lcc_longitude2lonid ([Longitude_Fin_B], [Latitude_Fin_B])
				and c2.latid=master.dbo.fn_lcc_latitude2latid ([Latitude_Fin_B]))
				)
					or
				(@type='M2F' and c.lonid=master.dbo.fn_lcc_longitude2lonid ([Longitude_Fin_A], [Latitude_Fin_A])
				and c.latid=master.dbo.fn_lcc_latitude2latid ([Latitude_Fin_A])
				)
			)
		and v.collectionname like '%'+@ReportType+'%'  

	group by v.sessionid
	OPTION (RECOMPILE)
end


-------------------------------------------------------------------------------
-- Condiciones de Reporte:
--		VDF - VOLTE - No reporta ni MOV ni YOI
--		VDF - CSFB  - Para MOV y YOI incluye 4G
-------------------------------------------------------------------------------
-- Para VDF - si es reporte VOLTE - No reporta ni MOV ni YOI - Los borramos
if @EntityList in (select report_type from [AGRIDs].dbo.lcc_operators_report_VOLTE where meas_round=@meas_round group by report_type) 
	and @meas_round in (select meas_round from [AGRIDs].dbo.lcc_operators_report_VOLTE group by meas_round)
	and @simOperator in (select mnc from [AGRIDs].dbo.lcc_operators_report_VOLTE where is_report_VOLTE='N' and meas_round=@meas_round and report_type=@EntityList)
	and @ReportType='VOLTE' 				
begin
	delete #All_Tests
end

-- Para VDF - si es reporte CSFB  - Se tienen en cuenta las medidas de VOLTE tmb para MOV y YOI 
--		Se añaden dichos tests de MOV y YOI de VOLTE a #All_Tests
if @EntityList in (select report_type from [AGRIDs].dbo.lcc_operators_report_VOLTE where meas_round=@meas_round group by report_type) 
	and @meas_round in (select meas_round from [AGRIDs].dbo.lcc_operators_report_VOLTE group by meas_round)
	and @simOperator in (select mnc from [AGRIDs].dbo.lcc_operators_report_VOLTE where is_report_VOLTE='N' and meas_round=@meas_round and report_type=@EntityList)
	and @ReportType='4G' 				
begin
	insert into #All_Tests
	select v.sessionid
	from lcc_Calls_Detailed v, lcc_position_Entity_List_Vodafone c, lcc_position_Entity_List_Vodafone c2
	Where --v.collectionname like @Date + '%' + @ciudad + '%' + @TechF
		v.MNC = @simOperator	--MNC
		and v.MCC= 214						--MCC - Descartamos los valores erróneos	
		and v.calltype = @type
		and c.fileid=v.fileid
		and (
				(@type='M2M' and c.entity_name = @Ciudad and c2.entity_name = @Ciudad)

				or

				(@type='M2F' and c.entity_name = @Ciudad)

			)
		and c.fileid=c2.fileid
		and 
			(
				(@type='M2M' and (c.lonid=master.dbo.fn_lcc_longitude2lonid ([Longitude_Fin_A], [Latitude_Fin_A])
				and c.latid=master.dbo.fn_lcc_latitude2latid ([Latitude_Fin_A]))
						and
				(c2.lonid=master.dbo.fn_lcc_longitude2lonid ([Longitude_Fin_B], [Latitude_Fin_B])
				and c2.latid=master.dbo.fn_lcc_latitude2latid ([Latitude_Fin_B]))
				)
					or
				(@type='M2F' and c.lonid=master.dbo.fn_lcc_longitude2lonid ([Longitude_Fin_A], [Latitude_Fin_A])
				and c.latid=master.dbo.fn_lcc_latitude2latid ([Latitude_Fin_A])
				)
			)
		and v.collectionname like '%VOLTE%' 

	group by v.sessionid
	OPTION (RECOMPILE)

end
-------------------------------------------------------------------------------
--	SELECT FINAL:
-------------------------------------------------------------------------------  
select  
	v.Sessionid,
	v.ASideFileName as LogFile,
	v.imei,
	v.callDir as CallDirection,
	v.calltype,
	v.MCC as Country,
	v.MNC as Operator,
	v.callStartTimeStamp as LogDate,
	v.callStartTimeStamp as StartDate,
	v.callEndTimeStamp as DropDate,
	v.callDuration as Duration,
	v.codeDescription as Cause,
	v.is_CSFB as Is_CSFB_Call,
	v.CMService_UARFCN,
	v.CMService_Band,
	v.Alerting_UARFCN,
	v.Alerting_Band,
	v.Connect_UARFCN,
	v.Connect_Band,
	v.Disconnect_UARFCN,
	v.Disconnect_Band,
	v.technology as Technology,
	v.Hopping,
	v.StartTechnology,
	v.[LAC/TAC_Ini] as Initial_LAC,
	v.CellId_Ini as Initial_CellId,
	case when v.StartTechnology like '%GSM%' then v.BSIC_Ini
			when v.StartTechnology like '%UMTS%' then v.PSC_Ini
			when v.StartTechnology like '%LTE%' then v.PCI_Ini
			end as Initial_BSIC_PSC_PCI,
	case when v.StartTechnology like '%GSM%' then v.BCCH_Ini
			when v.StartTechnology like '%UMTS%' then v.UARFCN_Ini
			when v.StartTechnology like '%LTE%' then v.EARFCN_Ini
			end as Initial_BCCH_UARFCN_EARFCN,
	--v.UARFCN_Ini as Initial_UARFCN,
	v.RNC_Ini as Initial_RNC,
	case when v.StartTechnology like '%GSM%' then v.RxLev_Ini
			when v.StartTechnology like '%UMTS%' then v.RSCP_Ini
			when v.StartTechnology like '%LTE%' then v.RSRP_Ini
			end as Initial_SS,
	case when v.StartTechnology like '%GSM%' then v.RxQual_Ini
			when v.StartTechnology like '%UMTS%' then v.EcIo_Ini
			when v.StartTechnology like '%LTE%' then v.RSRQ_Ini
			end as Initial_SQ,
	case when v.StartTechnology like '%LTE%' then v.SINR_Aside_ini end as SINR_Ini,
	v.EndTechnology,
	v.[LAC/TAC_Fin] as Final_LAC,
	v.CellId_Fin as Final_CellId,
	case when v.EndTechnology like '%GSM%' then v.BSIC_Fin
			when v.EndTechnology like '%UMTS%' then v.PSC_Fin
			when v.EndTechnology like '%LTE%' then v.PCI_Fin
			end as Final_BSIC_PSC_PCI,
	case when v.EndTechnology like '%GSM%' then v.BCCH_Ini
			when v.EndTechnology like '%UMTS%' then v.UARFCN_Ini
			when v.EndTechnology like '%LTE%' then v.EARFCN_Ini
			end as Final_BCCH_UARFCN_EARFCN,
	--v.UARFCN_Fin as Final_UARFCN,
	v.RNC_Fin as Final_RNC,
	case when v.EndTechnology like '%GSM%' then v.RxLev_Fin
			when v.EndTechnology like '%UMTS%' then v.RSCP_Fin
			when v.StartTechnology like '%LTE%' then v.RSRP_Fin
			end as Final_SS,
	case when v.EndTechnology like '%GSM%' then v.RxQual_Fin
			when v.EndTechnology like '%UMTS%' then v.EcIo_Fin
			when v.EndTechnology like '%LTE%' then v.RSRQ_Fin
			end as Final_SQ,
	case when v.EndTechnology like '%LTE%' then v.SINR_Aside_fin end as SINR_Fin,
	v.average_technology as Average_Technology,
	case when v.average_technology like '%GSM%' then v.RxLev
			when v.average_technology like '%UMTS%' then v.RSCP
			when v.average_technology like '%LTE%' then v.RSRP
			end as Average_SS,
	case when v.average_technology like '%GSM%' then v.RxQual
			when v.average_technology like '%UMTS%' then v.EcIo
			when v.average_technology like '%LTE%' then v.RSRQ
			end as Average_SQ,
	case when v.average_technology like '%LTE%' then v.SINR_Aside end as Average_SINR,
	case when v.average_technology like '%GSM%' then v.N1_RxLev
			when v.average_technology like '%UMTS%' then v.N1_RSCP
		-- when v.average_technology like '%LTE%' then v.N1_RSRP
			end as Neighbor1_SS,
	case when v.average_technology like '%GSM%' then v.RxLev_min
			when v.average_technology like '%UMTS%' then v.RSCP_Min
		-- when v.average_technology like '%LTE%' then v.RSRP_Min
			end as Min_SS,
	case when v.average_technology like '%GSM%' then v.RxQual_min
			when v.average_technology like '%UMTS%' then v.EcIo_min
		-- when v.average_technology like '%LTE%' then v.RSRQ_Min
			end as Worst_SQ,
	v.Fast_Return_Duration,
	v.Fast_Return_Freq_Dest,
	v.longitude_Ini_A as Initial_Longitude_A,
	v.latitude_Ini_A as Initial_Latitude_A,
	v.longitude_Ini_B as Initial_Longitude_B,
	v.latitude_Ini_B as Initial_Latitude_B,
	v.longitude_Fin_A as Final_Longitude_A,
	v.latitude_Fin_A as Final_Latitude_A,
	v.longitude_Fin_B as Final_Longitude_B,
	v.latitude_Fin_B as Final_Latitude_B,
	DB_name() as DDBB,
	v.is_VoLTE as Volte,
	v.Speech_Delay as [Volte Speech Delay],
	v.is_SRVCC as SRVCC,
	v.technology_BSide,
	v.CMService_UARFCN_B,
	v.CMService_Band_B,
	v.Alerting_UARFCN_B,
	v.Alerting_Band_B,
	v.Connect_UARFCN_B,
	v.Connect_Band_B,
	v.Disconnect_UARFCN_B,
	v.Disconnect_Band_B,
	v.Hopping_BSide,
	v.StartTechnology_BSide,
	v.[LAC/TAC_Ini_BSide] as Initial_LAC_BSide,
	v.CellId_Ini_BSide as Initial_CellId_BSide,
	case when v.StartTechnology_BSide like '%GSM%' then v.BSIC_Ini_BSide
			when v.StartTechnology_BSide like '%UMTS%' then v.PSC_Ini_BSide
			when v.StartTechnology_BSide like '%LTE%' then v.PCI_Ini_BSide
			end as Initial_BSIC_PSC_PCI_BSide,
	case when v.StartTechnology_BSide like '%GSM%' then v.BCCH_Ini_BSide
			when v.StartTechnology_BSide like '%UMTS%' then v.UARFCN_Ini_BSide
			when v.StartTechnology_BSide like '%LTE%' then v.EARFCN_Ini_BSide
			end as Initial_BCCH_UARFCN_EARFCN_BSide,
	--v.UARFCN_Ini as Initial_UARFCN,
	v.RNC_Ini_BSide as Initial_RNC_BSide,
	case when v.StartTechnology_BSide like '%GSM%' then v.RxLev_Ini_BSide
			when v.StartTechnology_BSide like '%UMTS%' then v.RSCP_Ini_BSide
			when v.StartTechnology_BSide like '%LTE%' then v.RSRP_Ini_BSide
			end as Initial_SS_BSide,
	case when v.StartTechnology_BSide like '%GSM%' then v.RxQual_Ini_BSide
			when v.StartTechnology_BSide like '%UMTS%' then v.EcIo_Ini_BSide
			when v.StartTechnology_BSide like '%LTE%' then v.RSRQ_Ini_BSide
			end as Initial_SQ_BSide,
	case when v.StartTechnology_BSide like '%LTE%' then v.SINR_Bside_ini end as SINR_Ini_BSide,
	v.EndTechnology_BSide,
	v.[LAC/TAC_Fin_BSide] as Final_LAC_BSide,
	v.CellId_Fin_BSide as Final_CellId_BSide,
	case when v.EndTechnology_BSide like '%GSM%' then v.BSIC_Fin_BSide
			when v.EndTechnology_BSide like '%UMTS%' then v.PSC_Fin_BSide
			when v.EndTechnology_BSide like '%LTE%' then v.PCI_Fin_BSide
			end as Final_BSIC_PSC_PCI_BSide,
	case when v.EndTechnology_BSide like '%GSM%' then v.BCCH_Ini_BSide
			when v.EndTechnology_BSide like '%UMTS%' then v.UARFCN_Ini_BSide
			when v.EndTechnology_BSide like '%LTE%' then v.EARFCN_Ini_BSide
			end as Final_BCCH_UARFCN_EARFCN_BSide,
	--v.UARFCN_Fin as Final_UARFCN,
	v.RNC_Fin as Final_RNC_BSide,
	case when v.EndTechnology_BSide like '%GSM%' then v.RxLev_Fin_BSide
			when v.EndTechnology_BSide like '%UMTS%' then v.RSCP_Fin_BSide
			when v.StartTechnology_BSide like '%LTE%' then v.RSRP_Fin_BSide
			end as Final_SS_BSide,
	case when v.EndTechnology_BSide like '%GSM%' then v.RxQual_Fin_BSide
			when v.EndTechnology_BSide like '%UMTS%' then v.EcIo_Fin_BSide
			when v.EndTechnology_BSide like '%LTE%' then v.RSRQ_Fin_BSide
			end as Final_SQ_BSide,
	case when v.EndTechnology_BSide like '%LTE%' then v.SINR_Bside_fin end as SINR_Fin_BSide,
	v.average_technology_B as Average_Technology_B,
	case when v.average_technology_B like '%GSM%' then v.RxLev_BSide
			when v.average_technology_B like '%UMTS%' then v.RSCP_BSide
			when v.average_technology_B like '%LTE%' then v.RSRP_BSide
			end as Average_SS_BSide,
	case when v.average_technology_B like '%GSM%' then v.RxQual_BSide
			when v.average_technology_B like '%UMTS%' then v.EcIo_BSide
			when v.average_technology_B like '%LTE%' then v.RSRQ_BSide
			end as Average_SQ_BSide,
	case when v.average_technology_B like '%LTE%' then v.SINR_Bside end as Average_SINR_BSide,
	v.CSFB_Device,
	v.RTP_Jitter_DL,
	v.RTP_Jitter_UL,
	v.RTP_Delay_DL,
	v.RTP_Delay_UL,
	v.RTP_Jitter_DL_BSide,
	v.RTP_Jitter_UL_BSide,
	v.RTP_Delay_DL_BSide,
	v.RTP_Delay_UL_BSide,
	v.Paging_Success_Ratio,
	v.Paging_Success_Ratio_BSide,
	v.PDP_Activate_Ratio,
	v.PDP_Activate_Ratio_BSide,
	v.EARFCN_N1,
	v.PCI_N1,
	v.RSRP_N1,
	v.RSRQ_N1,
	v.EARFCN_N1_BSide,
	v.PCI_N1_BSide,
	v.RSRP_N1_BSide,
	v.RSRQ_N1_BSide,
	v.SRVCC_SR,
	v.SRVCC_SR_BSide,
	v.IRAT_HO2G3G_Ratio,
	v.IRAT_HO2G3G_Ratio_BSide,
	v.num_HO_S1X2,
	v.duration_S1X2_avg,
	v.S1X2HO_SR,
	v.num_HO_S1X2_BSide,
	v.duration_S1X2_avg_BSide,
	v.S1X2HO_SR_BSide,
	v.IMSI	

into #final
from 
	#All_Tests a,
	lcc_Calls_Detailed v,
	Sessions s

where
	a.Sessionid=v.Sessionid
	and s.SessionId=v.Sessionid
	and v.callDir <> 'SO'
	and v.callStatus='Dropped'
	and s.valid=1

order by v.callEndTimeStamp

OPTION (OPTIMIZE FOR UNKNOWN)


-------------------------------------------------------------------------------
-- DGP 20/11/2015:
-- Separamos los resultados por tipo de scope:
-- BenchMarkers: Sólo se muestran los tests con GPS
-- FreeRiders: Se muestran todos los tests, y se añade la info de GPS a los que tengan
-------------------------------------------------------------------------------
if (db_name() like '%Indoor%' or db_name() like '%AVE%')		-- FreeRiders:		Todas las muestras
begin
	select  f.*,
			lp.nombre as Parcela,
			lp.Region_VF,
			lp.Region_OSP,
			lp.provincia as Provincia,
			lp.entorno as Entorno,
			lp.entorno_TLT as Entorno_TLT,
			lp.ciudad as Ciudad,
			lp.condado as Condado
		into #DI	
		from #final f
			LEFT OUTER JOIN	Agrids.dbo.lcc_parcelas lp on (lp.Nombre=master.dbo.fn_lcc_getParcel(f.Final_Longitude_A, f.Final_Latitude_A))

	-----------------
	-- En funcion del tipo de reporte, se muestra una region u otra:
	if  @EntityList = 'VDF'
	begin 
		alter table #DI drop column Region_OSP
	end
	else
	begin
		alter table #DI drop column Region_VF
	end
	-----------------
	select * from #DI 
	order by DropDate
	-----------------
	drop table #All_Tests,#final,#DI
end

else															-- BenchMarkers:	Sólo las muestras con GPS
begin
	select  f.*,
			lp.nombre as Parcela,
			lp.Region_VF,
			lp.Region_OSP,
			lp.provincia as Provincia,
			lp.entorno as Entorno,
			lp.entorno_TLT as Entorno_TLT,
			lp.ciudad as Ciudad,
			lp.condado as Condado
		into #D	
		from #final f, Agrids.dbo.lcc_parcelas lp 
		where lp.Nombre=master.dbo.fn_lcc_getParcel(f.Final_Longitude_A, f.Final_Latitude_A)
		and lp.entorno like @Environ

	-----------------
	-- En funcion del tipo de reporte, se muestra una region u otra:
	if  @EntityList = 'VDF'
	begin 
		alter table #D drop column Region_OSP
	end
	else
	begin
		alter table #D drop column Region_VF
	end
	-----------------
	select * from #D 
	order by DropDate
	-----------------
	drop table #All_Tests,#final,#D
end
