USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_lcc_core_Voice_MOS_Table]    Script Date: 23/04/2018 13:57:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [dbo].[sp_lcc_core_Voice_MOS_Table] as

-- DESCRIPTION ----------------------------------------------------------------------------------------------------------------------
--
--	 Calculations made in 3 phases
--		-Phase1: obtain detailed results and codec use per testid
--		-Phase2: group all test in one value per sessionid (call)
--		-Phase3: traspose MOS individual values per sessionid to maintain full details	
--
--		* Base TABLE/VIEW:			[vResultsLQAvg] 		
--		
--		**** LEFT OUTER JOIN	
--				Subquery to (4 levels subqueries) VoiceCodecTest which determines the use rate
--					UL/DL codecs and the mostly used codec 
--
--	In PHASE 1 - key_BST (ddbb_Sessionid_NA) only valid for Qlik -> detailed values no replicate avg/calls input in QLIK
--
---------------------------------------------------------
----- Phase 1 Detailed results and codecuse by testid
----------------------------------------------------------
exec sp_lcc_dropifexists 'lcc_core_Voice_MOS_Table_Test'
select 
	--db_name()+'_'+convert(varchar(256),'NA')+'_'+isnull(convert(varchar(256),v.testid),'NA') COLLATE Latin1_General_CI_AS as key_BST, 
	db_name()+'_'+isnull(convert(varchar(256),v.sessionid),'NA')+'_'+convert(varchar(256),'NA') COLLATE Latin1_General_CI_AS as key_BST,
	db_name()+'_'+convert(varchar(256),v.testid)  COLLATE Latin1_General_CI_AS as key_BT,
	db_name()  COLLATE Latin1_General_CI_AS as ddbb, 
	
	v.testid, v.sessionid , v.LQFloat, v.WideBand, v.codedLevel, 
	v.noiseRcv, v.staticSNR, v.appl,
	Case (v.Appl / 10) % 10
			When 0 Then                             -- SQuad 08
				Case v.Appl % 10
				When 0 Then 'SQuad08-NB'            -- SQuad NB
				When 2 Then 'SQuad08-WB'            -- SQuad WB
				End
			When 1 Then                             -- POLQA v1.1
				Case v.Appl % 10
				When 0 Then 'P.863-NB'              -- POLQA NB
				When 2 Then 'P.863-SWB'             -- POLQA WB
				End
			When 2 Then                             -- POLQA v2.4
				Case v.Appl % 10
				When 0 Then 'P.863-NB'              -- POLQA NB
				When 2 Then 'P.863-SWB'             -- POLQA WB
				End
			end as Model,
	v.qualityCode, v.Bandwidth, v.ReceiveDelay speechDelay
	,c.codecDL, c.codecDL_use, c.codecDL_amounts,c.codecDL_avgRate
	,c.codecUL, c.codecUL_use, c.codecUL_amounts,c.codecUL_avgRate
	,case test.direction
		when 'A->B' then 'U'
		when 'B->A' then 'D'
	else test.direction end as MOS_Test_Direction,

	EFR_UseDL,	FR_UseDL,	HR_UseDL,	AMR_HR_UseDL,	AMR_FR_UseDL,	AMR_WB_UseDL,	AMR_WB_HD_UseDL,	noCodecName_UseDL,
	EFR_UseUL,	FR_UseUL,	HR_UseUL,	AMR_HR_UseUL,	AMR_FR_UseUL,	AMR_WB_UseUL,	AMR_WB_HD_UseUL,	noCodecName_UseUL,
	ROW_NUMBER() over (partition by v.sessionid order by v.testid asc) as id		-- testid is not valid - there are testid without info

into lcc_core_Voice_MOS_Table_Test
from [dbo].[vResultsLQAvg] v
		       left outer join 
			      (
			         -- codec per testid is the most used, nevertheless info about the use rate is mantained
						select sessionid, testid
							 ,max(case when Direction='D' and ord=1 then CodecName end )as codecDL
							 ,max(case when Direction='U' and ord=1  then CodecName end ) as codecUL
							 ,max(case when Direction='D' and ord=1  then codec_use end ) as codecDL_use
							 ,max(case when Direction='U' and ord=1  then codec_use end ) as codecUL_use
							 ,max(case when Direction='D' then ord end ) as codecDL_amounts
							 ,max(case when Direction='U' then ord end ) as codecUL_amounts
							 ,sum(case when Direction='D' then CodecRate_avg end ) as codecDL_avgRate
							 ,sum(case when Direction='U' then CodecRate_avg end ) as codecUL_avgRate

					 -- also we keep info about codecs use - by grouping codec name
							,sum(case when  Direction='D' and codecName = 'EFR' then codec_use end) as EFR_UseDL
							,sum(case when  Direction='D' and codecName = 'AMR 12.2' OR codecName = 'AMR 4.75' then codec_use end) as FR_UseDL
							,sum(case when  Direction='D' and CodecName = 'AMR 5.9' OR CodecName = 'AMR 7.4' then codec_use end) as HR_UseDL
							,sum(case when  Direction='D' and CodecName like 'AMR HR%' then codec_use else null end) as AMR_HR_UseDL
							,sum(case when  Direction='D' and CodecName like 'AMR FR%' then codec_use else null end) as AMR_FR_UseDL
							,sum(case when  Direction='D' and CodecName like 'AMR WB%' then codec_use else null end) as AMR_WB_UseDL
							,sum(case when  Direction='D' and (CodecName like 'AMR WB%' and (CodecName not in ('AMR WB 6.6','AMR WB 8.85','AMR WB 12.2'))) then codec_use else null end) as AMR_WB_HD_UseDL
							,sum(case when  Direction='D' and CodecName like '-'  then codec_use else null end) as noCodecName_UseDL

							,sum(case when  Direction='U' and codecName = 'EFR' then codec_use end) as EFR_UseUL
							,sum(case when  Direction='U' and codecName = 'AMR 12.2' OR codecName = 'AMR 4.75' then codec_use end) as FR_UseUL
							,sum(case when  Direction='U' and CodecName = 'AMR 5.9' OR CodecName = 'AMR 7.4' then codec_use end) as HR_UseUL
							,sum(case when  Direction='U' and CodecName like 'AMR HR%' then codec_use else null end) as AMR_HR_UseUL
							,sum(case when  Direction='U' and CodecName like 'AMR FR%' then codec_use else null end) as AMR_FR_UseUL
							,sum(case when  Direction='U' and CodecName like 'AMR WB%' then codec_use else null end) as AMR_WB_UseUL
							,sum(case when  Direction='U' and (CodecName like 'AMR WB%' and (CodecName not in ('AMR WB 6.6','AMR WB 8.85','AMR WB 12.2'))) then codec_use else null end) as AMR_WB_HD_UseUL
							,sum(case when  Direction='U' and CodecName like '-'  then codec_use else null end) as noCodecName_UseUL

						 from ( --- Since only one codec can be populated by testid, codecs are ordered by usage
						             --- (use rate is maintained for detailed analysis)
								 select SessionId,TestId, Direction, CodecName, CodecRateFloat*isnull(1.0*duration/nullif(test_duration,0),0) as CodecRate_avg,
										isnull(1.0*duration/nullif(test_duration,0),0) codec_use
									   , row_number() over (partition by sessionid, testid, direction order by isnull(1.0*duration/nullif(test_duration,0),0) desc) ord   
   								  from 
									( -- subquery to determine duration and codecs used in UL DL per each test
										select sessionid, testid, Direction,Codec,CodecName, CodecRateFloat, 
										sum(duration) duration, 
										avg(test_duration) test_duration 
										    -- test_duration is a nested sum by session, test and direction in below subquery. 
											--   Therefore group by result must be avg
	    
										 from 
										  ( -- Subquery to get the codec duration per test
											 Select vct.SessionId,
											 vct.TestId,
											 vct.Direction,
											 vct.Codec,
											 dbo.GetCodec(Codec)+isnull(' '+CONVERT(varchar,nullif(vct.CodecRate,0)),'')  CodecName ,
											 vct.Duration as Duration,
											sum(vct.Duration) over (partition by vct.sessionid,vct.testid,vct.direction)  test_duration,
											 vct.CodecRate as CodecRateFloat
										   From VoiceCodecTest vct 
										) vct
									  Group By sessionid, testid, Direction,Codec,CodecName, CodecRateFloat
									) t
	  
						  ) t
						  group by sessionid, testid


			      ) c 
			      on v.SessionId=c.SessionId and v.TestId= c.TestId
			, testinfo test
			where v.TestId=test.TestId

------------------------------------------------ select * from lcc_core_Voice_MOS_Table_Test

-------------------------------------------------------------
--- Phase 2 group by sessionid, for call based results
-------------------------------------------------------------
exec sp_lcc_dropifexists 'lcc_core_Voice_MOS_Table'
select 	  
	db_name()+'_'+isnull(convert(varchar(256),v.sessionid),'NA')+'_'+convert(varchar(256),'NA') COLLATE Latin1_General_CI_AS as key_BST, 
	ddbb,  sessionid,
	max(model) as model_session_Call,
	avg(LQFloat) as LQFloat_avg_Call,
	sum(WideBand*1.0)/count(WideBand) as WideBand_meas_Call,
	avg(CodedLevel) as CodedLevel_avg_Call,
	avg(noiseRcv) as NoiseRcv_avg_Call,
	avg(StaticSNR) as StaticSNR_avg_Call,
	avg(speechDelay) as speechDelay_avg_Call,
	count(distinct codecDL) as CodecDL_quatity_Call,
	avg(codecDL_avgRate) as CodecDL_avgRate_session_Call,
	max( codecDL) as CodecDL_session_Call,
	count(distinct codecuL) as CodecUL_quatity_Call,
	avg(codecUL_avgRate) as CodecUL_avgRate_session_Call,
	max( codecUL) as CodecUL_session_Call,
	sum(case when mos_test_direction='U' then 1 else 0 end ) Num_UL_MOS_Clips_Call,
	sum(case when mos_test_direction='D' then 1 else 0 end ) Num_DL_MOS_Clips_Call,
	
	-- DL Codc Use:
	sum(EFR_UseDL)/max(id) as [EFR_UseDL],
	sum(FR_UseDL)/max(id) as [FR_UseDL],
	sum(HR_UseDL)/max(id) as [HR_UseDL],
	sum(AMR_HR_UseDL)/max(id) as [AMR_HR_UseDL],
	sum(AMR_FR_UseDL)/max(id) as [AMR_FR_UseDL],
	sum(AMR_WB_UseDL)/max(id) as [AMR_WB_UseDL],
	sum(AMR_WB_HD_UseDL)/max(id) as [AMR_WB_HD_UseDL],
	sum(noCodecName_UseDL)/max(id) as [noCodecName_UseDL],

	-- UL Codec Use:
	sum(EFR_UseUL)/max(id) as [EFR_UseUL],
	sum(FR_UseUL)/max(id) as [FR_UseUL],
	sum(HR_UseUL)/max(id) as [HR_UseUL],
	sum(AMR_HR_UseUL)/max(id) as [AMR_HR_UseUL],
	sum(AMR_FR_UseUL)/max(id) as [AMR_FR_UseUL],
	sum(AMR_WB_UseUL)/max(id) as [AMR_WB_UseUL],
	sum(AMR_WB_HD_UseUL)/max(id) as [AMR_WB_HD_UseUL],
	sum(noCodecName_UseUL)/max(id) as [noCodecName_UseUL]

into lcc_core_Voice_MOS_Table
from lcc_core_Voice_MOS_Table_Test v
group by 
	db_name()+'_'+isnull(convert(varchar(256),v.sessionid),'NA')+'_'+convert(varchar(256),'NA'), 
	ddbb,  sessionid

--------
-- update to delete codecName in those cases where several codecs are used

update lcc_core_Voice_MOS_Table
set codecDL_session_Call=case when CodecDL_quatity_Call<>1 
							then convert(varchar(256),'Various Codecs') 
							else CodecDL_session_Call end
	,codecUL_session_Call=case when CodecUL_quatity_Call<>1 
							then convert(varchar(256),'Various Codecs') 
							else CodecUL_session_Call end
	
from lcc_core_Voice_MOS_Table

------------------------------------------------ select * from lcc_core_Voice_MOS_Table

