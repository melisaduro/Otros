--select [database],date_reporting,week_reporting
--from [AGGRVoice3G].dbo.lcc_aggr_sp_MDD_Voice_Llamadas
--where entidad= 'algemesi'
--group by [database],date_reporting,week_reporting
--order by 1

use FY1617_Voice_Rest_3G_H1_6
-----------------------------
----- Testing Variables -----
-----------------------------

declare @simOperator as int = 1
declare @Date as varchar(256) = ''
declare @TechF as varchar(256) = ''
declare @type as varchar(256) = 'M2M'

declare @ciudad as varchar(256) = 'Algemesi'
declare @environ as varchar(256) = '%%'
declare @report as varchar(256) = 'MUN' --VDF (Reporte VDF), OSP (Reporte OSP), MUN (Municipal)


create table #All_Tests (
	[SessionId] bigint
)

-------------------------------------------------------------------------------
-- GLOBAL FILTER:
-------------------------------------------------------------------------------		  

If @Report='VDF'
begin
	
	insert into #All_Tests
	select v.sessionid

	from lcc_Calls_Detailed v, lcc_position_Entity_List_Vodafone c, lcc_position_Entity_List_Vodafone c2
	Where --v.collectionname like @Date + '%' + @ciudad + '%' + @TechF
		v.MNC = @simOperator	--MNC
		and v.MCC= 214						--MCC - Descartamos los valores erróneos	
		and v.calltype = @type
		and c.fileid=v.fileid
		and c.entity_name = @Ciudad
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

	group by v.sessionid

	OPTION (RECOMPILE)
end

If @Report='OSP'
begin
	
	insert into #All_Tests
	select v.sessionid

	from lcc_Calls_Detailed v, lcc_position_Entity_List_Orange c, lcc_position_Entity_List_Orange c2
	Where --v.collectionname like @Date + '%' + @ciudad + '%' + @TechF
		v.MNC = @simOperator	--MNC
		and v.MCC= 214						--MCC - Descartamos los valores erróneos	
		and v.calltype = @type
		and c.fileid=v.fileid
		and c.entity_name = @Ciudad
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

	group by v.sessionid
	OPTION (RECOMPILE)
end

If @Report='MUN'
begin
	
	insert into #All_Tests
	select v.sessionid

	from lcc_Calls_Detailed v, lcc_position_Entity_List_Municipio c, lcc_position_Entity_List_Municipio c2
	Where --v.collectionname like @Date + '%' + @ciudad + '%' + @TechF
		v.MNC = @simOperator	--MNC
		and v.MCC= 214						--MCC - Descartamos los valores erróneos	
		and v.calltype = @type
		and c.fileid=v.fileid
		and c.entity_name = @Ciudad
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

	group by v.sessionid
	OPTION (RECOMPILE)
end

select * from #All_Tests

------------------------- CST 95th Percentile---------------------------------

--------------------------- CST Main Table -----------------------------------

declare @CSTresult float

if @type = 'M2M' --Sólo las muestras con GPS
	begin

	create table #CST_perc ([value] float null)		
	create table #MO_CST_A ([CST_A_95] float null)
	create table #MO_CST_C ([CST_C_95] float null)
	create table #MT_CST_A ([CST_A_95] float null)
	create table #MT_CST_C ([CST_C_95] float null)
	create table #MOMT_CST_A ([CST_A_95] float null)
	create table #MOMT_CST_C ([CST_C_95] float null)
	create table #MT_CST_C_10_OSP ([CST_C_10] float null)
	create table #MO_CST_C_10_OSP ([CST_C_10] float null)
	create table #MOMT_CST_C_10_OSP ([CST_C_10] float null)
	create table #MT_CST_C_90_OSP ([CST_C_90] float null)
	create table #MO_CST_C_90_OSP ([CST_C_90] float null)
	create table #MOMT_CST_C_90_OSP ([CST_C_90] float null)

		select v.Sessionid, callDir ,cst_till_alerting, cst_till_connAck

		into #CST_MAIN
		from #All_Tests a,
			 lcc_Calls_Detailed v,
			 agrids.dbo.lcc_parcelas lp

		where a.Sessionid=v.Sessionid
		and callDir in ('MO', 'MT')
		and callstatus = 'Completed'
		and (cst_till_alerting is not null or cst_till_connAck is not null)
		and lp.Nombre= master.dbo.fn_lcc_getParcel(v.longitude_fin_A, v.latitude_fin_A)
		and lp.entorno like @Environ

		---- MO CST Percentile
		insert into #CST_perc
		select  cst_till_alerting/1000.0 as cst_till_alerting
				
				from #CST_Main
				where callDir= 'MO'
				and cst_till_alerting is not null

		exec sp_lcc_Percentil 95, 0.5, '#CST_perc', @CSTresult output

		insert into #MO_CST_A
		select @CSTresult

		set @CSTresult= null
		
		delete from #CST_perc


		insert into #CST_perc
		select  cst_till_connack/1000.0 as  cst_till_connAck
				from #CST_Main
				where callDir= 'MO'
				and cst_till_connack is not null

		exec sp_lcc_Percentil 95, 0.5, '#CST_perc', @CSTresult output

		insert into #MO_CST_C 
		select @CSTresult

		set @CSTresult= null

		delete from #CST_perc


		insert into #CST_perc
		select  cst_till_connack/1000.0 as  cst_till_connAck
				from #CST_Main
				where callDir= 'MO'
				and cst_till_connack is not null

		exec sp_lcc_Percentil 10, 0.5, '#CST_perc', @CSTresult output

		insert into #MO_CST_C_10_OSP 
		select @CSTresult

		set @CSTresult= null

		delete from #CST_perc

		insert into #CST_perc
		select  cst_till_connack/1000.0 as  cst_till_connAck
				from #CST_Main
				where callDir= 'MO'
				and cst_till_connack is not null

		exec sp_lcc_Percentil 90, 0.5, '#CST_perc', @CSTresult output

		insert into #MO_CST_C_90_OSP 
		select @CSTresult

		set @CSTresult= null

		delete from #CST_perc

		---- MT CST Percentile
		insert into #CST_perc
		select  cst_till_alerting/1000.0 as cst_till_alerting
				from #CST_Main
				where callDir= 'MT'
				and cst_till_alerting is not null
		
		exec sp_lcc_Percentil 95, 0.5, '#CST_perc', @CSTresult output

		insert into #MT_CST_A
		select @CSTresult

		set @CSTresult= null

		delete from #CST_perc

		insert into #CST_perc
		select  cst_till_connack/1000.0 as  cst_till_connAck
				from #CST_Main
				where callDir= 'MT'
				and cst_till_connack is not null

		exec sp_lcc_Percentil 95, 0.5, '#CST_perc', @CSTresult output
		
		insert into #MT_CST_C
		select @CSTresult

		set @CSTresult= null

		delete from #CST_perc

		insert into #CST_perc
		select  cst_till_connack/1000.0 as  cst_till_connAck
				from #CST_Main
				where callDir= 'MT'
				and cst_till_connack is not null

		exec sp_lcc_Percentil 10, 0.5, '#CST_perc', @CSTresult output
		
		insert into #MT_CST_C_10_OSP
		select @CSTresult

		set @CSTresult= null

		delete from #CST_perc

		insert into #CST_perc
		select  cst_till_connack/1000.0 as  cst_till_connAck
				from #CST_Main
				where callDir= 'MT'
				and cst_till_connack is not null

		exec sp_lcc_Percentil 90, 0.5, '#CST_perc', @CSTresult output
		
		insert into #MT_CST_C_90_OSP
		select @CSTresult

		set @CSTresult= null

		delete from #CST_perc

		---- MO+MT CST Percentile
		insert into #CST_perc
		select  cst_till_alerting/1000.0 as cst_till_alerting
				from #CST_Main
				where cst_till_alerting is not null
				
		exec sp_lcc_Percentil 95, 0.5, '#CST_perc', @CSTresult output

		insert into #MOMT_CST_A
		select @CSTresult

		set @CSTresult= null
		
		delete from #CST_perc
		
		insert into #CST_perc
		select  cst_till_connAck/1000.0 as  cst_till_connAck
				from #CST_Main
				where cst_till_connack is not null
		
		exec sp_lcc_Percentil 95, 0.5, '#CST_perc', @CSTresult output

		insert into #MOMT_CST_C
		select @CSTresult

		set @CSTresult= null

		delete from #CST_perc

		insert into #CST_perc
		select  cst_till_connAck/1000.0 as  cst_till_connAck
				from #CST_Main
				where cst_till_connack is not null
		
		exec sp_lcc_Percentil 10, 0.5, '#CST_perc', @CSTresult output

		insert into #MOMT_CST_C_10_OSP
		select @CSTresult

		set @CSTresult= null

		delete from #CST_perc

		insert into #CST_perc
		select  cst_till_connAck/1000.0 as  cst_till_connAck
				from #CST_Main
				where cst_till_connack is not null
		
		exec sp_lcc_Percentil 90, 0.5, '#CST_perc', @CSTresult output

		insert into #MOMT_CST_C_90_OSP
		select @CSTresult

		set @CSTresult= null

		delete from #CST_perc


	end



else

	begin

	create table #CST_perc_Indoor ([value] float null)		
	create table #MO_CST_A_Indoor ([CST_A_95] float null)
	create table #MO_CST_C_Indoor ([CST_C_95] float null)
	create table #MT_CST_A_Indoor ([CST_A_95] float null)
	create table #MT_CST_C_Indoor ([CST_C_95] float null)
	create table #MOMT_CST_A_Indoor ([CST_A_95] float null)
	create table #MOMT_CST_C_Indoor ([CST_C_95] float null)
	create table #MT_CST_C_10_OSP_Indoor ([CST_C_10] float null)
	create table #MO_CST_C_10_OSP_Indoor ([CST_C_10] float null)
	create table #MOMT_CST_C_10_OSP_Indoor ([CST_C_10] float null)
	create table #MT_CST_C_90_OSP_Indoor ([CST_C_90] float null)
	create table #MO_CST_C_90_OSP_Indoor ([CST_C_90] float null)
	create table #MOMT_CST_C_90_OSP_Indoor ([CST_C_90] float null)

		select v.Sessionid, callDir ,cst_till_alerting, cst_till_connAck

		into #CST_MAIN_Indoor
		from #All_Tests a,
			 lcc_Calls_Detailed v

		where a.Sessionid=v.Sessionid
		and callDir in ('MO', 'MT')
		and callstatus = 'Completed'
		and (cst_till_alerting is not null or cst_till_connAck is not null)

		---- MO CST Percentile
		insert into #CST_perc_Indoor
		select  cst_till_alerting/1000.0 as cst_till_alerting
				
				from #CST_Main_Indoor
				where callDir= 'MO'
				and cst_till_alerting is not null

		exec sp_lcc_Percentil 95, 0.5, '#CST_perc_Indoor', @CSTresult output

		insert into #MO_CST_A_Indoor
		select @CSTresult

		set @CSTresult= null
		
		delete from #CST_perc_Indoor


		insert into #CST_perc_Indoor
		select  cst_till_connack/1000.0 as  cst_till_connAck
				from #CST_Main_Indoor
				where callDir= 'MO'
				and cst_till_connack is not null

		exec sp_lcc_Percentil 95, 0.5, '#CST_perc_Indoor', @CSTresult output

		insert into #MO_CST_C_Indoor
		select @CSTresult

		set @CSTresult= null

		insert into #CST_perc_Indoor
		select  cst_till_connack/1000.0 as  cst_till_connAck
				from #CST_Main_Indoor
				where callDir= 'MO'
				and cst_till_connack is not null

		exec sp_lcc_Percentil 10, 0.5, '#CST_perc_Indoor', @CSTresult output

		insert into #MO_CST_C_10_OSP_Indoor
		select @CSTresult

		set @CSTresult= null

		delete from #CST_perc_Indoor

		insert into #CST_perc_Indoor
		select  cst_till_connack/1000.0 as  cst_till_connAck
				from #CST_Main_Indoor
				where callDir= 'MO'
				and cst_till_connack is not null

		exec sp_lcc_Percentil 90, 0.5, '#CST_perc_Indoor', @CSTresult output

		insert into #MO_CST_C_90_OSP_Indoor
		select @CSTresult

		set @CSTresult= null

		delete from #CST_perc_Indoor

		---- MT CST Percentile
		insert into #CST_perc_Indoor
		select  cst_till_alerting/1000.0 as cst_till_alerting
				from #CST_Main_Indoor
				where callDir= 'MT'
				and cst_till_alerting is not null
		
		exec sp_lcc_Percentil 95, 0.5, '#CST_perc_Indoor', @CSTresult output

		insert into #MT_CST_A_Indoor
		select @CSTresult

		set @CSTresult= null

		delete from #CST_perc_Indoor

		insert into #CST_perc_Indoor
		select  cst_till_connack/1000.0 as  cst_till_connAck
				from #CST_Main_Indoor
				where callDir= 'MT'
				and cst_till_connack is not null

		exec sp_lcc_Percentil 95, 0.5, '#CST_perc_Indoor', @CSTresult output
		
		insert into #MT_CST_C_Indoor
		select @CSTresult

		set @CSTresult= null

		delete from #CST_perc_Indoor

		insert into #CST_perc_Indoor
		select  cst_till_connack/1000.0 as  cst_till_connAck
				from #CST_Main_Indoor
				where callDir= 'MT'
				and cst_till_connack is not null

		exec sp_lcc_Percentil 10, 0.5, '#CST_perc_Indoor', @CSTresult output
		
		insert into #MT_CST_C_10_OSP_Indoor
		select @CSTresult

		set @CSTresult= null

		delete from #CST_perc_Indoor

		insert into #CST_perc_Indoor
		select  cst_till_connack/1000.0 as  cst_till_connAck
				from #CST_Main_Indoor
				where callDir= 'MT'
				and cst_till_connack is not null

		exec sp_lcc_Percentil 90, 0.5, '#CST_perc_Indoor', @CSTresult output
		
		insert into #MT_CST_C_90_OSP_Indoor
		select @CSTresult

		set @CSTresult= null

		delete from #CST_perc_Indoor

		---- MO+MT CST Percentile
		insert into #CST_perc_Indoor
		select  cst_till_alerting/1000.0 as cst_till_alerting
				from #CST_Main_Indoor
				where cst_till_alerting is not null
				
		exec sp_lcc_Percentil 95, 0.5, '#CST_perc_Indoor', @CSTresult output

		insert into #MOMT_CST_A_Indoor
		select @CSTresult

		set @CSTresult= null
		
		delete from #CST_perc_Indoor
		
		insert into #CST_perc_Indoor
		select  cst_till_connAck/1000.0 as  cst_till_connAck
				from #CST_Main_Indoor
				where cst_till_connack is not null
		
		exec sp_lcc_Percentil 95, 0.5, '#CST_perc_Indoor', @CSTresult output

		insert into #MOMT_CST_C_Indoor
		select @CSTresult

		set @CSTresult= null

		delete from #CST_perc_Indoor

		insert into #CST_perc_Indoor
		select  cst_till_connAck/1000.0 as  cst_till_connAck
				from #CST_Main_Indoor
				where cst_till_connack is not null
		
		exec sp_lcc_Percentil 10, 0.5, '#CST_perc_Indoor', @CSTresult output

		insert into #MOMT_CST_C_10_OSP_Indoor
		select @CSTresult

		set @CSTresult= null

		delete from #CST_perc_Indoor

		insert into #CST_perc_Indoor
		select  cst_till_connAck/1000.0 as  cst_till_connAck
				from #CST_Main_Indoor
				where cst_till_connack is not null
		
		exec sp_lcc_Percentil 90, 0.5, '#CST_perc_Indoor', @CSTresult output

		insert into #MOMT_CST_C_90_OSP_Indoor
		select @CSTresult

		set @CSTresult= null

		delete from #CST_perc_Indoor

end

------------------------- CST 95th Percentile---------------------------------

--------------------------- MOS Percentile -----------------------------------

--------------------------- MOS Main Table -----------------------------------

declare @MOSresult float

if @type = 'M2M' --Sólo las muestras con GPS
	begin
		
	create table #MOS_perc ([value] float null)		
	create table #MOS_NB_5TH ([MOS_5] float null)
	create table #MOS_WB_MED ([MOS_MED] float null)
	create table #MOS_ALL_5TH ([MOS_5] float null)
	create table #MOS_ALL_STDEV ([MOS] float null)

		-- MOS disaggregated Main Table

		Select  m.sessionid, m.testid,
		(case when m.OptionalWB is not null then m.OptionalWB else m.OptionalNB end) as MOS,
		(case when m.BandWidth=0 then 'NB' else 'WB' end) as MOS_Type,
		case t.direction
			 when 'A->B' then 'U'
			 when 'B->A' then 'D'
			 Else t.direction
		end as MOS_Test_Direction

		into #MOS_MAIN

		from dbo.ResultsLQ08Avg m, TestInfo t, #All_Tests a, lcc_calls_detailed v,
			 agrids.dbo.lcc_parcelas lp
		
		where m.TestId=t.TestId
		and a.Sessionid=m.SessionId and t.SessionId=a.Sessionid
		and a.sessionid=v.sessionid
		and (m.OptionalNB is not null or m.OptionalWB is not null)
		and Appl in (10, 110, 1010, 20, 120, 12, 1012, 22) -- Application Codes for POLQA NB and WB Codecs
		and v.callStatus = 'Completed'
		and lp.Nombre= master.dbo.fn_lcc_getParcel(v.longitude_fin_A, v.latitude_fin_A)
		and lp.entorno like @Environ

		-- MOS NB 5th Percentile
		insert into #MOS_perc
		select  MOS as  MOS_5
				from #MOS_MAIN
				where MOS_Type='NB'
				and MOS is not null
				
		exec sp_lcc_Percentil 5, 0.5, '#MOS_perc', @MOSresult output

		insert into #MOS_NB_5TH
		select @MOSresult

		set @MOSresult= null
		
		delete from #MOS_perc

		---- MOS WB Median

		insert into #MOS_perc
		select  MOS as  MOS_MED
				from #MOS_MAIN
				where MOS_Type='WB'
				and MOS is not null

		exec sp_lcc_Percentil 50, 0.5, '#MOS_perc', @MOSresult output
		
		insert into #MOS_WB_MED
		select @MOSresult
		
		set @MOSresult= null

		delete from #MOS_perc

		-- MOS ALL 5th Percentile

		insert into #MOS_perc
		select  MOS as  MOS_5
				from #MOS_MAIN
				where MOS is not null
				
		exec sp_lcc_Percentil 5, 0.5, '#MOS_perc', @MOSresult output

		insert into #MOS_ALL_5TH
		select @MOSresult
		
		set @MOSresult= null

		delete from #MOS_perc

		-- MOS ALL STDEVP

		insert into #MOS_perc
		select  MOS
				from #MOS_MAIN
				where MOS is not null
				
		exec sp_lcc_STDEVP 0.5, '#MOS_perc', @MOSresult output

		insert into #MOS_ALL_STDEV
		select @MOSresult
		
		set @MOSresult= null

		delete from #MOS_perc

	end
else

begin
		
	create table #MOS_perc_Indoor ([value] float null)		
	create table #MOS_NB_5TH_Indoor ([MOS_5] float null)
	create table #MOS_WB_MED_Indoor ([MOS_MED] float null)
	create table #MOS_ALL_5TH_Indoor ([MOS_5] float null)
	create table #MOS_NB_STDEV_Indoor ([MOS] float null)

		-- MOS disaggregated Main Table

		Select  m.sessionid, m.testid,
		(case when m.OptionalWB is not null then m.OptionalWB else m.OptionalNB end) as MOS,
		(case when m.BandWidth=0 then 'NB' else 'WB' end) as MOS_Type,
		case t.direction
			 when 'A->B' then 'U'
			 when 'B->A' then 'D'
			 Else t.direction
		end as MOS_Test_Direction

		into #MOS_MAIN_Indoor

		from dbo.ResultsLQ08Avg m, TestInfo t, #All_Tests a, lcc_calls_detailed v
		where m.TestId=t.TestId
		and a.Sessionid=m.SessionId and t.SessionId=a.Sessionid
		and a.sessionid=v.sessionid
		and (m.OptionalNB is not null or m.OptionalWB is not null)
		and Appl in (10, 110, 1010, 20, 120, 12, 1012, 22) -- Application Codes for POLQA NB and WB Codecs
		and v.callStatus = 'Completed'

		-- MOS NB 5th Percentile
		insert into #MOS_perc_Indoor
		select  MOS as  MOS_5
				from #MOS_MAIN_Indoor
				where MOS_Type='NB'
				and MOS is not null
				
		exec sp_lcc_Percentil 5, 0.5, '#MOS_perc_Indoor', @MOSresult output

		insert into #MOS_NB_5TH_Indoor
		select @MOSresult

		set @MOSresult= null
		
		delete from #MOS_perc_Indoor

		---- MOS WB Median

		insert into #MOS_perc_Indoor
		select  MOS as  MOS_MED
				from #MOS_MAIN_Indoor
				where MOS_Type='WB'
				and MOS is not null

		exec sp_lcc_Percentil 50, 0.5, '#MOS_perc_Indoor', @MOSresult output
		
		insert into #MOS_WB_MED_Indoor
		select @MOSresult
		
		set @MOSresult= null

		delete from #MOS_perc_Indoor

		-- MOS ALL 5th Percentile

		insert into #MOS_perc_Indoor
		select  MOS as  MOS_5
				from #MOS_MAIN_Indoor
				where MOS is not null
				
		exec sp_lcc_Percentil 5, 0.5, '#MOS_perc_Indoor', @MOSresult output

		insert into #MOS_ALL_5TH_Indoor
		select @MOSresult
		
		set @MOSresult= null

		delete from #MOS_perc_Indoor

		-- MOS NB STDEV

		insert into #MOS_perc_Indoor
		select  MOS
				from #MOS_MAIN_Indoor
				where MOS_Type='NB'
				and MOS is not null
				
		exec sp_lcc_STDEVP 0.5, '#MOS_perc_Indoor', @MOSresult output

		insert into #MOS_NB_STDEV_Indoor
		select @MOSresult
		
		set @MOSresult= null

		delete from #MOS_perc_Indoor

end

--------------------------- MOS Percentile -----------------------------------

------------------------------------------------------------------------------------
------------------------------- GENERAL SELECT
---------------- All Sheet for KPI Voice Aggregated Info Book
------------------------------------------------------------------------------------

if @type = 'M2M' --Sólo las muestras con GPS
begin

select 
SUM (case when v.callDir in ('MO','MT') then 1 else 0 end) as Call_Attemps,
SUM (case when v.callDir in ('MO','MT') and v.callStatus='Failed' then 1 else 0 end) as Access_Failures,

/*sum (case when v.callDir='MO' then 1 else 0 end)*/ null as MO_Attempts,
/*SUM (case when (v.callDir='MO' and v.callStatus='Failed') then 1 else 0 end)*/ null as MO_Fails,
/*sum (case when v.callDir='MT' then 1 else 0 end)*/ null as MT_Attempts,
/*SUM (case when (v.callDir='MT' and v.callStatus='Failed') then 1 else 0 end)*/ null as MT_Fails,
SUM (case when (v.callStatus='Dropped') then 1 else 0 end) as Drops,

/*sum(v.SQNS_NB)*/ null as SQNS_NB,
sum(case when v.callstatus = 'Completed' then v.SQNS_WB end) as SQNS_WB,

/*AVG(case when v.callDir='MO' then v.cst_till_alerting end)/1000.0*/ null as CST_MO_Alerting_AVG,
/*AVG(case when v.callDir='MT' then v.cst_till_alerting end)/1000.0*/ null as CST_MT_Alerting_AVG,
AVG(CAST(case when v.callDir in ('MO','MT') and v.callstatus = 'Completed' then 1.0*v.cst_till_alerting end as Float))/1000.0 as CST_MOMT_Alerting_AVG,
/*(select CST_A_95 from #MO_CST_A)*/ null as CST_MO_Alerting_95th,
/*(select CST_A_95 from #MT_CST_A)*/ null as CST_MT_Alerting_95th,
(select CST_A_95 from #MOMT_CST_A) as CST_MOMT_Alerting_95th,
/*AVG(case when v.callDir='MO' then v.cst_till_connAck end)/1000.0*/ null as CST_MO_Connect_AVG,
/*AVG(case when v.callDir='MT' then v.cst_till_connAck end)/1000.0*/ null as CST_MT_Connect_AVG,
AVG(CAST(case when v.callDir in ('MO','MT') and v.callstatus = 'Completed' then 1.0*v.cst_till_connAck end as Float))/1000.0 as CST_MOMT_Connect_AVG,
/*(select CST_C_95 from #MO_CST_C)*/ null as CST_MO_Connect_95th,
/*(select CST_C_95 from #MT_CST_C)*/ null as CST_MT_Connect_95th,
(select CST_C_95 from #MOMT_CST_C) as CST_MOMT_Connect_95th,

/*AVG(v.MOS_NB)*/ null as MOS_NB_DLUL_AVG,
/*SUM(v.MOS_Samples_NB)*/ null as MOS_NB_Samples,
/*STDEV(v.MOS_NB)*/ null as MOS_NB_DLUL_STDEV,
/*SUM(v.[MOS_NB_Samples_Under_2.5])*/ null as 'MOS_NB_Samples_Under_2.5',
/*(select MOS_5 from #MOS_NB_5TH)*/ null as MOS_NB_5th,

AVG(case when v.callstatus = 'Completed' then CAST(case when (v.MOS_WB is not null) then v.MOS_WB else v.MOS_NB end as Float) end) as  MOS_ALL_DLUL_AVG,
SUM(case when v.callstatus = 'Completed' then(v.MOS_Samples_NB + v.MOS_Samples_WB) end) as MOS_ALL_Samples,
(select MOS from #MOS_ALL_STDEV) as MOS_ALL_DLUL_STDEV,
SUM(case when v.callstatus = 'Completed' then (v.[MOS_NB_Samples_Under_2.5] + v.[MOS_WB_Samples_Under_2.5])end) as 'MOS_ALL_Samples_Under_2.5',
(select MOS_5 from #MOS_ALL_5TH) as MOS_ALL_5th,
avg(v.Speech_Delay) as VOLTE_Speech_Delay,

SUM(case when v.callstatus = 'Completed' then (case when v.MOS_Samples_NB = 0 and v.MOS_Samples_WB > 0 then 1 else 0 end)end) as Calls_WB_Only,
AVG(case when v.callstatus = 'Completed' then (CAST(case when v.MOS_Samples_NB = 0 and v.MOS_Samples_WB > 0 then v.MOS_WB end as Float)) end) as MOS_WB_Avg,
case when SUM(case when v.callstatus = 'Completed' then (case when v.MOS_Samples_NB = 0 and v.MOS_Samples_WB > 0 then 1 else 0 end)end)=0 then null else (select MOS_MED from #MOS_WB_MED) end as MOS_WB_Median,

/* DGP 11/02/2015: Se actualiza la forma de contar las llamadas para tener en cuenta los 2 moviles para M2M*/

SUM(case 
		when ((left(v.cmservice_band,4) = 'UMTS' and left(v.disconnect_band,4) = 'UMTS' and v.CSFB_Device = '') and (left(v.cmservice_band_B,4) = 'UMTS' and left(v.disconnect_band_B,4) = 'UMTS' and v.CSFB_Device = '') and v.is_csfb=0 and v.callstatus in ('Completed','Dropped')) then 2
		when (((left(v.cmservice_band,4) = 'UMTS' and left(v.disconnect_band,4) = 'UMTS' and v.CSFB_Device <> 'A') or (left(v.cmservice_band_B,4) = 'UMTS' and left(v.disconnect_band_B,4) = 'UMTS' and v.CSFB_Device <> 'B')) and v.is_csfb<2 and v.callstatus in ('Completed','Dropped')) then 1 
		else 0 
		end) As Started_Ended_3G,
SUM(case 
		when ((left(v.cmservice_band,3) = 'GSM' and left(v.disconnect_band,3) = 'GSM' and v.CSFB_Device = '') and (left(v.cmservice_band_B,3) = 'GSM' and left(v.disconnect_band_B,3) = 'GSM' and v.CSFB_Device = '') and v.is_csfb=0 and v.callstatus in ('Completed','Dropped')) then 2
		when (((left(v.cmservice_band,3) = 'GSM' and left(v.disconnect_band,3) = 'GSM' and v.CSFB_Device <> 'A') or (left(v.cmservice_band_B,3) = 'GSM' and left(v.disconnect_band_B,3) = 'GSM' and v.CSFB_Device <> 'B')) and v.is_csfb<2 and v.callstatus in ('Completed','Dropped')) then 1 
		else 0 
		end) As Started_Ended_2G,
SUM(case 
		when (((left(v.cmservice_band,3) <> left(v.disconnect_band,3) and v.CSFB_Device = '') and (left(v.cmservice_band_B,3) <> left(v.disconnect_band_B,3) and v.CSFB_Device = '')) and v.is_csfb=0 and v.callstatus in ('Completed','Dropped')) then 2
		when (((left(v.cmservice_band,3) <> left(v.disconnect_band,3) and v.CSFB_Device <> 'A') or (left(v.cmservice_band_B,3) <> left(v.disconnect_band_B,3) and v.CSFB_Device <> 'B')) and v.is_csfb<2 and v.callstatus in ('Completed','Dropped')) then 1 
		else 0 
		end) As Calls_Mixed,
SUM(case when (v.Technology = 'LTE' or v.Technology_Bside = 'LTE' or v.is_csfb>0 or v.is_VoLTE>0) and v.callstatus in ('Completed','Dropped') then v.is_csfb+v.is_VoLTE else 0 end) As Started_4G,
sum(case when (v.callstatus in ('Completed','Dropped') and (v.is_VoLTE-v.is_SRVCC) >=0) then v.is_VoLTE-v.is_SRVCC else 0 end) as Started_VoLTE,
isnull(SUM(v.UMTS_Duration),0) as Duration_3G,
isnull(SUM(v.GSM_Duration),0) as Duration_2G,
SUM(case 
		when (((v.cmService_band like 'GSM%' and v.CSFB_device like '%A%') and (v.cmService_band_B like 'GSM%' and v.CSFB_device like '%B%')) and v.is_csfb=2 and v.callstatus in ('Completed','Dropped')) then 2 
		when (((v.cmService_band like 'GSM%' and v.CSFB_device = 'A') or (v.cmService_band_B like 'GSM%' and v.CSFB_device = 'B')) and v.is_csfb>0 and v.callstatus in ('Completed','Dropped')) then 1 
		else 0 
		end) as GSM_calls_After_CSFB,
SUM(case 
		when (((v.cmService_band like 'UMTS%' and v.CSFB_device like '%A%') and (v.cmService_band_B like 'UMTS%' and v.CSFB_device like '%B%')) and v.is_csfb=2 and v.callstatus in ('Completed','Dropped')) then 2 
		when (((v.cmService_band like 'UMTS%' and v.CSFB_device = 'A') or (v.cmService_band_B like 'UMTS%' and v.CSFB_device = 'B')) and v.is_csfb>0 and v.callstatus in ('Completed','Dropped')) then 1 
		else 0 
		end) as UMTS_calls_After_CSFB,
sum(case when v.callstatus in ('Completed','Dropped') then v.is_SRVCC end) as SRVCC,
1.0*sum(case when v.callstatus in ('Completed','Dropped') then v.is_SRVCC end)/nullif(sum(case when v.callstatus in ('Completed','Dropped') then v.is_VoLTE end),0) as SRVCC_pct,
--OSP:
(select CST_C_10 from #MO_CST_C_10_OSP) as CST_MO_Connect_10th,
(select CST_C_10 from #MT_CST_C_10_OSP) as CST_MT_Connect_10th,
(select CST_C_10 from #MOMT_CST_C_10_OSP) as CST_MOMT_Connect_10th,
(select CST_C_90 from #MO_CST_C_90_OSP) as CST_MO_Connect_90th,
(select CST_C_90 from #MT_CST_C_90_OSP) as CST_MT_Connect_90th,
(select CST_C_90 from #MOMT_CST_C_90_OSP) as CST_MOMT_Connect_90th,
1.0*isnull(sum(v.HR_Count),0)/nullif(sum(v.Codec_Registers),0) as [% HR],
1.0*isnull(sum(v.FR_Count),0)/nullif(sum(v.Codec_Registers),0) as [% FR],
1.0*isnull(sum(v.EFR_Count),0)/nullif(sum(v.Codec_Registers),0) as [% EFR],
1.0*isnull(sum(v.AMR_HR_Count),0)/nullif(sum(v.Codec_Registers),0) as [% AMR HR],
1.0*isnull(sum(v.AMR_FR_Count),0)/nullif(sum(v.Codec_Registers),0) as [% AMR FR],
1.0*isnull(sum(v.AMR_WB_Count),0)/nullif(sum(v.Codec_Registers),0) as [% AMR WB],
1.0*isnull(sum(v.AMR_WB_HD_Count),0)/nullif(sum(v.Codec_Registers),0) as [% AMR WB HD]


from 
	#All_Tests a,
	lcc_Calls_Detailed v,
	Sessions s,
	Agrids.dbo.lcc_parcelas lp

where
	a.sessionid=v.Sessionid
	and s.SessionId=v.Sessionid
	and v.callDir <> 'SO'
	and v.callStatus in ('Completed','Failed','Dropped')
	and s.valid=1
	and lp.Nombre= master.dbo.fn_lcc_getParcel(v.longitude_fin_A, v.latitude_fin_A)
	and lp.entorno like @Environ

	OPTION (OPTIMIZE FOR UNKNOWN)
end


else -- Type: M2F (Todos los tests Con GPS o no)
begin

select 
SUM (case when v.callDir in ('MO','MT') then 1 else 0 end) as Call_Attemps,
SUM (case when v.callDir in ('MO','MT') and v.callStatus='Failed' then 1 else 0 end) as Access_Failures,

sum (case when v.callDir='MO' then 1 else 0 end) as MO_Attempts,
SUM (case when (v.callDir='MO' and v.callStatus='Failed') then 1 else 0 end) as MO_Fails,
sum (case when v.callDir='MT' then 1 else 0 end) as MT_Attempts,
SUM (case when (v.callDir='MT' and v.callStatus='Failed') then 1 else 0 end) as MT_Fails,
SUM (case when (v.callStatus='Dropped') then 1 else 0 end) as Drops,

sum(case when v.callstatus = 'Completed' then v.SQNS_NB end) as SQNS_NB,
/*sum(v.SQNS_WB)*/ null as SQNS_WB,

AVG(case when v.callDir='MO' and v.callstatus = 'Completed' then 1.0*v.cst_till_alerting end)/1000.0 as CST_MO_Alerting_AVG,
AVG(case when v.callDir='MT' and v.callstatus = 'Completed' then 1.0*v.cst_till_alerting end)/1000.0 as CST_MT_Alerting_AVG,
AVG(case when v.callDir in ('MO','MT') and v.callstatus = 'Completed' then 1.0*v.cst_till_alerting end)/1000.0 as CST_MOMT_Alerting_AVG,
(select CST_A_95 from #MO_CST_A_Indoor) as CST_MO_Alerting_95th,
(select CST_A_95 from #MT_CST_A_Indoor) as CST_MT_Alerting_95th,
(select CST_A_95 from #MOMT_CST_A_Indoor) as CST_MOMT_Alerting_95th,
AVG(case when v.callDir='MO' and v.callstatus = 'Completed' then 1.0*v.cst_till_connAck end)/1000.0 as CST_MO_Connect_AVG,
AVG(case when v.callDir='MT' and v.callstatus = 'Completed' then 1.0*v.cst_till_connAck end)/1000.0 as CST_MT_Connect_AVG,
AVG(case when v.callDir in ('MO','MT') and v.callstatus = 'Completed' then 1.0*v.cst_till_connAck end)/1000.0 as CST_MOMT_Connect_AVG,
(select CST_C_95 from #MO_CST_C_Indoor) as CST_MO_Connect_95th,
(select CST_C_95 from #MT_CST_C_Indoor) as CST_MT_Connect_95th,
(select CST_C_95 from #MOMT_CST_C_Indoor) as CST_MOMT_Connect_95th,

AVG(case when v.callstatus = 'Completed' then v.MOS_NB end) as MOS_NB_DLUL_AVG,
SUM(case when v.callstatus = 'Completed' then v.MOS_Samples_NB end) as MOS_NB_Samples,
(select MOS from #MOS_NB_STDEV_Indoor) as MOS_NB_DLUL_STDEV,
SUM(case when v.callstatus = 'Completed' then v.[MOS_NB_Samples_Under_2.5] end) as 'MOS_NB_Samples_Under_2.5',
(select MOS_5 from #MOS_NB_5TH_Indoor) as MOS_NB_5th,

/*(AVG(v.MOS_NB)+AVG(v.MOS_WB))/2*/ null as MOS_ALL_DLUL_AVG,
/*SUM(v.MOS_Samples_NB + v.MOS_Samples_WB)*/ null as MOS_ALL_Samples,
/*STDEV(v.MOS_NB)*/ null as MOS_ALL_DLUL_STDEV,
/*SUM(v.[MOS_NB_Samples_Under_2.5] + v.[MOS_WB_Samples_Under_2.5])*/ null as 'MOS_ALL_Samples_Under_2.5',
/*(select MOS_5 from #MOS_ALL_5TH)*/ null as MOS_ALL_5th,

/*SUM(case when v.MOS_Samples_NB is null and v.MOS_Samples_WB is not null then 1 else 0 end)*/ null as Calls_WB_Only,
/*AVG(v.MOS_WB)*/ null as MOS_WB_Avg,
/*(select MOS_MED from #MOS_WB_MED)*/ null as MOS_WB_Median,


-- DGP 11/02/2015: Se actualiza la forma de contar las llamadas para tener en cuenta los 2 moviles para M2F
--***************************************************************************************************************************

SUM(case 
		when ((left(v.cmservice_band,4) = 'UMTS' and left(v.disconnect_band,4) = 'UMTS' and v.CSFB_Device = '') and (left(v.cmservice_band_B,4) = 'UMTS' and left(v.disconnect_band_B,4) = 'UMTS' and v.CSFB_Device = '') and v.is_csfb=0 and v.callstatus in ('Completed','Dropped')) then 2
		when (((left(v.cmservice_band,4) = 'UMTS' and left(v.disconnect_band,4) = 'UMTS' and v.CSFB_Device <> 'A') or (left(v.cmservice_band_B,4) = 'UMTS' and left(v.disconnect_band_B,4) = 'UMTS' and v.CSFB_Device <> 'B')) and v.is_csfb<2 and v.callstatus in ('Completed','Dropped')) then 1 
		else 0 
		end) As Started_Ended_3G,
SUM(case 
		when ((left(v.cmservice_band,3) = 'GSM' and left(v.disconnect_band,3) = 'GSM' and v.CSFB_Device = '') and (left(v.cmservice_band_B,3) = 'GSM' and left(v.disconnect_band_B,3) = 'GSM' and v.CSFB_Device = '') and v.is_csfb=0 and v.callstatus in ('Completed','Dropped')) then 2
		when (((left(v.cmservice_band,3) = 'GSM' and left(v.disconnect_band,3) = 'GSM' and v.CSFB_Device <> 'A') or (left(v.cmservice_band_B,3) = 'GSM' and left(v.disconnect_band_B,3) = 'GSM' and v.CSFB_Device <> 'B')) and v.is_csfb<2 and v.callstatus in ('Completed','Dropped')) then 1 
		else 0 
		end) As Started_Ended_2G,
SUM(case 
		when (((left(v.cmservice_band,3) <> left(v.disconnect_band,3) and v.CSFB_Device = '') and (left(v.cmservice_band_B,3) <> left(v.disconnect_band_B,3) and v.CSFB_Device = '')) and v.is_csfb=0 and v.callstatus in ('Completed','Dropped')) then 2
		when (((left(v.cmservice_band,3) <> left(v.disconnect_band,3) and v.CSFB_Device <> 'A') or (left(v.cmservice_band_B,3) <> left(v.disconnect_band_B,3) and v.CSFB_Device <> 'B')) and v.is_csfb<2 and v.callstatus in ('Completed','Dropped')) then 1 
		else 0 
		end) As Calls_Mixed,
SUM(case when (v.Technology = 'LTE' or v.Technology_Bside = 'LTE' or v.is_csfb>0 or v.is_VoLTE>0) and v.callstatus in ('Completed','Dropped') then v.is_csfb+v.is_VOLTE else 0 end) As Started_4G,
isnull(SUM(v.UMTS_Duration),0) as Duration_3G,
isnull(SUM(v.GSM_Duration),0) as Duration_2G,
SUM(case 
		when (((v.cmService_band like 'GSM%' and v.CSFB_device like '%A%') and (v.cmService_band_B like 'GSM%' and v.CSFB_device like '%B%')) and v.is_csfb=2 and v.callstatus in ('Completed','Dropped')) then 2 
		when (((v.cmService_band like 'GSM%' and v.CSFB_device = 'A') or (v.cmService_band_B like 'GSM%' and v.CSFB_device = 'B')) and v.is_csfb>0 and v.callstatus in ('Completed','Dropped')) then 1 
		else 0 
		end) as GSM_calls_After_CSFB,
SUM(case 
		when (((v.cmService_band like 'UMTS%' and v.CSFB_device like '%A%') and (v.cmService_band_B like 'UMTS%' and v.CSFB_device like '%B%')) and v.is_csfb=2 and v.callstatus in ('Completed','Dropped')) then 2 
		when (((v.cmService_band like 'UMTS%' and v.CSFB_device = 'A') or (v.cmService_band_B like 'UMTS%' and v.CSFB_device = 'B')) and v.is_csfb>0 and v.callstatus in ('Completed','Dropped')) then 1 
		else 0 
		end) as UMTS_calls_After_CSFB,

--OSP:
(select CST_C_10 from #MO_CST_C_10_OSP_INDOOR) as CST_MO_Connect_10th,
(select CST_C_10 from #MT_CST_C_10_OSP_INDOOR) as CST_MT_Connect_10th,
(select CST_C_10 from #MOMT_CST_C_10_OSP_INDOOR) as CST_MOMT_Connect_10th,
(select CST_C_90 from #MO_CST_C_90_OSP_INDOOR) as CST_MO_Connect_90th,
(select CST_C_90 from #MT_CST_C_90_OSP_INDOOR) as CST_MT_Connect_90th,
(select CST_C_90 from #MOMT_CST_C_90_OSP_INDOOR) as CST_MOMT_Connect_90th,
1.0*isnull(sum(v.HR_Count),0)/nullif(sum(v.Codec_Registers),0) as [% HR],
1.0*isnull(sum(v.FR_Count),0)/nullif(sum(v.Codec_Registers),0) as [% FR],
1.0*isnull(sum(v.EFR_Count),0)/nullif(sum(v.Codec_Registers),0) as [% EFR],
1.0*isnull(sum(v.AMR_HR_Count),0)/nullif(sum(v.Codec_Registers),0) as [% AMR HR],
1.0*isnull(sum(v.AMR_FR_Count),0)/nullif(sum(v.Codec_Registers),0) as [% AMR FR],
1.0*isnull(sum(v.AMR_WB_Count),0)/nullif(sum(v.Codec_Registers),0) as [% AMR WB],
1.0*isnull(sum(v.AMR_WB_HD_Count),0)/nullif(sum(v.Codec_Registers),0) as [% AMR WB HD]


from 
	#All_Tests a,
	lcc_Calls_Detailed v,
	Sessions s

where
	a.sessionid=v.Sessionid
	and s.SessionId=v.Sessionid
	and v.callDir <> 'SO'
	and v.callStatus in ('Completed','Failed','Dropped')
	and s.valid=1

	OPTION (OPTIMIZE FOR UNKNOWN)
end


if @type = 'M2M' --Sólo las muestras con GPS
begin
drop table #all_Tests, #CST_MAIN,#MO_CST_A, #MT_CST_A, #MOMT_CST_A, #MO_CST_C, #MT_CST_C, #MOMT_CST_C, #MOS_MAIN,#MOS_ALL_5TH,#MOS_NB_5TH,#MOS_WB_MED, #CST_perc, #MOS_perc, #MOS_ALL_STDEV,#MO_CST_C_10_OSP,#MO_CST_C_90_OSP, #MT_CST_C_10_OSP, #MT_CST_C_90_OSP, #MOMT_CST_C_10_OSP, #MOMT_CST_C_90_OSP
end

else

begin
drop table #all_Tests, #CST_MAIN_Indoor,#MO_CST_A_Indoor, #MT_CST_A_Indoor, #MOMT_CST_A_Indoor, #MO_CST_C_Indoor, #MT_CST_C_Indoor, #MOMT_CST_C_Indoor, #MOS_MAIN_Indoor,#MOS_ALL_5TH_Indoor,#MOS_NB_5TH_Indoor,#MOS_WB_MED_Indoor, #CST_perc_Indoor, #MOS_perc_Indoor, #MOS_NB_STDEV_Indoor,#MO_CST_C_10_OSP_INDOOR,#MO_CST_C_90_OSP_INDOOR, #MT_CST_C_10_OSP_INDOOR, #MT_CST_C_90_OSP_INDOOR, #MOMT_CST_C_10_OSP_INDOOR, #MOMT_CST_C_90_OSP_INDOOR
end
