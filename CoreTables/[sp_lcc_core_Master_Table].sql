USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_lcc_core_Master_Table]    Script Date: 23/04/2018 13:34:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [dbo].[sp_lcc_core_Master_Table] as

-- DESCRIPTION ----------------------------------------------------------------------------------------------------------------------
--
--	In sessionType=SpeechClip - key_BST (ddbb_Sessionid_NA) only valid for Qlik -> detailed values no replicate avg/calls input in QLIK
--	Each key_BST (ddbb_sessionid_NA) has:
--			X - sessionType for SpeechClip
--			1 - sessionType for CALL
--
-------------------------------------------------------------------------------------------------------------------------------------
-- MODIFICATIONS --------------------------------------------------------------------------------------------------------------------
--
-- DGP 09/02/2018: Added Task name from Filelist
-------------------------
exec sp_lcc_dropifexists 'lcc_core_Master_Table'
select
	db_name()+'_'+convert(varchar(256),s.sessionid)+'_'+isnull(convert(varchar(256),t.testid),'NA') COLLATE Latin1_General_CI_AS key_BST, 	
	db_name() COLLATE Latin1_General_CI_AS as ddbb, 
	f.CollectionName,
	
	f.Zone as meas_equipment,
	f.TaskName,
	op.operator,

	case when ca.callType is not null then ca.callType else t.typeoftest	end typeoftest,
	case when ca.callDir  is not null then ca.callDir else  t.direction		end Direction,

	----------------------------------------
	-- SESSIONS INFO:
	--------------------
	s.valid as valid_session, s.invalidreason as invalidreason_sesssion,
	s.info session_Status 	
	--------------------
	-- A Side Information:
	,s.FileId,			s.SessionId,			s.sessionType		
	,s.startTime as session_start,				s.prevSessionId,					s.nextSessionId
	,s.duration,		s.SpeedAvg
	,f.ASideDevice,		f.ASideFileName
	,f.ProductVersion,	f.FirmwareV
	,f.IMEI,			f.IMSI
	,left(f.imsi,5)	as mccmnc,		left(f.imsi,3) as mcc,		right(left(f.imsi,5),2) as mnc
	--------------------
	-- B Side Information:
	,b.FileidB,			b.sessionidB,			b.sessiontypeB
	,b.session_startB,							b.prevSessionidB,					b.nextSessionidB
	,b.durationB,		b.SpeedAvgB
	,b.BSideDevice,		b.BSideFileName
	,b.ProductVersionB, b.firmwareVB 
	,b.IMEIB,			b.IMSIB
	,b.mccmnc_B,		b.mcc_B,			b.mnc_B 

	----------------------------------------
	-- TESTs INFO:
	--------------------
	,s.numOfTests
	,t.TestId
	,t.duration		as test_duration
	,t.SpeedAvg		as test_speed
	,t.startTime	as test_start
	,t.valid as valid_test, t.invalidreason invalidreason_test

	----------------------------------------
	-- GEOGRAPHICAL INFO:
	--------------------
	-- A Side - Ini:
	,ps.longitude_ini session_longitude_ini ,ps.latitude_ini session_latitude_ini 
	,geography::STPointFromText('POINT('+convert(varchar(256),ps.longitude_ini)+' '+convert(varchar(256),ps.latitude_ini)+')', 4326) GEOpointSession_ini
	,master.dbo.fn_lcc_binning_longitude2lonid (ps.longitude_ini, ps.latitude_ini,500) lonid_SessionIni_500
	,master.dbo.fn_lcc_binning_latitude2latid ( ps.latitude_ini,500) latid_SessioniIni_500
	--,master.dbo.fn_lcc_binning_longitude2lonid (ps.longitude_ini, ps.latitude_ini,50) lonid_SessionIni_50
	--,master.dbo.fn_lcc_binning_latitude2latid ( ps.latitude_ini,50) latid_SessioniIni_50
	,master.dbo.fn_lcc_longitude2lonid (ps.longitude_ini, ps.latitude_ini) lonid_SessionIni_50
	,master.dbo.fn_lcc_latitude2latid (ps.latitude_ini) latid_SessioniIni_50
	
	-- A Side - End:	
	,ps.longitude_end session_longitude_end , ps.latitude_end session_latitude_end 
	,geography::STPointFromText('POINT('+convert(varchar(256),ps.longitude_end)+' '+convert(varchar(256),ps.latitude_end)+')', 4326) GEOpointSession_end
	,master.dbo.fn_lcc_binning_longitude2lonid (ps.longitude_end, ps.latitude_end,500) lonid_SessionEnd_500
	,master.dbo.fn_lcc_binning_latitude2latid ( ps.latitude_end,500) latid_SessionEnd_500
	--,master.dbo.fn_lcc_binning_longitude2lonid (ps.longitude_end, ps.latitude_end,50) lonid_SessionEnd_50
	--,master.dbo.fn_lcc_binning_latitude2latid ( ps.latitude_end,50) latid_SessionEnd_50
	,master.dbo.fn_lcc_longitude2lonid (ps.longitude_end, ps.latitude_end) lonid_SessionEnd_50
	,master.dbo.fn_lcc_latitude2latid ( ps.latitude_end) latid_SessionEnd_50

	--------------------
	-- B Side - Ini:	
	,b.longitude_iniB, b.latitude_iniB, b.GeoPoint_iniB
	,master.dbo.fn_lcc_binning_longitude2lonid (b.longitude_iniB, b.latitude_iniB,500) lonid_iniB_500
	,master.dbo.fn_lcc_binning_latitude2latid ( b.latitude_iniB,500) latid_iniB_500
	--,master.dbo.fn_lcc_binning_longitude2lonid (b.longitude_iniB, b.latitude_iniB,50) lonid_iniB_50
	--,master.dbo.fn_lcc_binning_latitude2latid ( b.latitude_iniB,50) latid_iniB_50
	,master.dbo.fn_lcc_longitude2lonid (b.longitude_iniB, b.latitude_iniB) lonid_iniB_50
	,master.dbo.fn_lcc_latitude2latid ( b.latitude_iniB) latid_iniB_50

	-- B Side - end:	
	,b.longitude_endB, b.latitude_endB, b.GeoPoint_endB
	,master.dbo.fn_lcc_binning_longitude2lonid (b.longitude_endB, b.latitude_endB,500) lonid_endB_500
	,master.dbo.fn_lcc_binning_latitude2latid ( b.latitude_endB,500) latid_endB_500
	--,master.dbo.fn_lcc_binning_longitude2lonid (b.longitude_endB, b.latitude_endB,50) lonid_endB_50
	--,master.dbo.fn_lcc_binning_latitude2latid ( b.latitude_endB,50) latid_endB_50
	,master.dbo.fn_lcc_longitude2lonid (b.longitude_endB, b.latitude_endB) lonid_endB_50
	,master.dbo.fn_lcc_latitude2latid ( b.latitude_endB) latid_endB_50
		
	--------------------
	-- Test - Ini:	
	,t.longitude_ini test_longitude_ini , t.latitude_ini test_latitude_ini 
	,geography::STPointFromText('POINT('+convert(varchar(256),t.longitude_ini)+' '+convert(varchar(256),t.latitude_ini)+')', 4326) GEOpointTest_ini
	,master.dbo.fn_lcc_binning_longitude2lonid (t.longitude_ini, t.latitude_ini,500) lonid_TestIni_500
	,master.dbo.fn_lcc_binning_latitude2latid ( t.latitude_ini,500) latid_TestIni_500
	--,master.dbo.fn_lcc_binning_longitude2lonid (t.longitude_ini, t.latitude_ini,50) lonid_TestIni_50
	--,master.dbo.fn_lcc_binning_latitude2latid ( t.latitude_ini,50) latid_TestIni_50
	,master.dbo.fn_lcc_longitude2lonid (t.longitude_ini, t.latitude_ini) lonid_TestIni_50
	,master.dbo.fn_lcc_latitude2latid ( t.latitude_ini) latid_TestIni_50

	-- Test - end:	
	,t.longitude_end test_longitude_end , t.latitude_end test_latitude_end 
	,geography::STPointFromText('POINT('+convert(varchar(256),t.longitude_end)+' '+convert(varchar(256),t.latitude_end)+')', 4326) GEOpointTest_end
	,master.dbo.fn_lcc_binning_longitude2lonid (t.longitude_end, t.latitude_end,500) lonid_TestEnd_500
	,master.dbo.fn_lcc_binning_latitude2latid ( t.latitude_end,500) latid_TestEnd_500
	--,master.dbo.fn_lcc_binning_longitude2lonid (t.longitude_end, t.latitude_end,50) lonid_TestEnd_50
	--,master.dbo.fn_lcc_binning_latitude2latid ( t.latitude_end,50) latid_TestEnd_50
	,master.dbo.fn_lcc_longitude2lonid (t.longitude_end, t.latitude_end) lonid_TestEnd_50
	,master.dbo.fn_lcc_latitude2latid ( t.latitude_end) latid_TestEnd_50

into lcc_core_Master_Table
from Sessions s 
		--------------------
		left outer join 
		    ( select t.*, pt.FileId, pt.longitude_ini, pt.latitude_ini, pt.longitude_end, pt.latitude_end
			  from testinfo t
			       left outer join 
				     (
					    select t.FileId, t.SessionId, t.TestId
							,i.longitude longitude_ini, i.latitude latitude_ini
							,f.longitude longitude_end, f.latitude latitude_end

						from 
							(
								select fileid, sessionid, testid,min(posid) as ini_posid, max(posid) as max_posid
								 from Position
								 group by fileid, sessionid, testid
							 ) t, position i, Position f
						where t.ini_posid=i.PosId and t.max_posid=f.PosId 
							and t.FileId=i.FileId and t.FileId=f.fileid
							and t.SessionId=i.SessionId and t.SessionId=f.SessionId
							and t.TestId=i.TestId and t.TestId=f.TestId
					 ) pt 
					 on pt.TestId=t.TestId and pt.SessionId=t.SessionId 
					 where t.TestId>0 and t.typeoftest not like '%speech%'
			
			) t 
			
			on t.SessionId=s.SessionId and t.fileid=s.fileid and s.sessionType='Data' and t.typeoftest not like '%speech%'

		-------------------- B side information
        left outer join 
		   (
		       select s.SessionIdA,s.SessionId sessionidB, s.sessionType sessiontypeB
					,s.FileId FileidB, sa.fileid as FileidA
					,s.duration durationB
					,s.prevSessionId prevSessionidB, s.nextSessionId nextSessionidB
					,s.SpeedAvg SpeedAvgB, s.startTime session_startB, convert(varchar(256),'B') Side_session
					,f.BSideDevice ,BSideFileName
					,f.IMEI IMEIB, f.IMSI IMSIB, left(f.imsi,5) mccmnc_B , left(f.imsi,3) as mcc_B,right(left(f.imsi,5),2) as mnc_B
					,f.ProductVersion ProductVersionB, f.firmwareV firmwareVB
					,ini.longitude as longitude_iniB, ini.latitude as latitude_iniB
					,geography::STPointFromText('POINT('+convert(varchar(256),ini.longitude)+' '+convert(varchar(256),ini.latitude)+')', 4326) GEOpoint_iniB
					,fin.longitude as longitude_endB, fin.latitude as latitude_endB
					,geography::STPointFromText('POINT('+convert(varchar(256),fin.longitude)+' '+convert(varchar(256),fin.latitude)+')', 4326) GEOpoint_endB
				from SessionsB s, sessions sA, filelist f,
				  (
						select fileid, sessionid ,min(posid) as ini_posid, max(posid) as max_posid
						from Position
						group by fileid, sessionid
					) t, position ini, Position fin
				
				where s.sessionidA=sA.sessionid and sA.FileId = f.FileId and s.SessionId=t.SessionId  and s.fileid=t.fileid
				    and t.ini_posid=ini.PosId and t.max_posid=fin.PosId
					and t.SessionId=ini.SessionId and t.SessionId=fin.SessionId
		   ) b on b.SessionIdA=s.SessionId and b.FileidA=s.FileId			
   
		-------------------- Call Analyisis information
		left outer join CallAnalysis ca on ca.SessionId=s.SessionId and ca.FileId=s.FileId
	
		-------------------- positioning per sessionid
        left outer join 
		   (
		      select t.fileid, t.SessionId
				,i.longitude longitude_ini, i.latitude latitude_ini
				,f.longitude longitude_end, f.latitude latitude_end

				from 
				    (
						select fileid, sessionid,min(posid) as ini_posid, max(posid) as max_posid
						from Position
						group by fileid, sessionid
					) t, position i, Position f
				where t.ini_posid=i.PosId and t.max_posid=f.PosId
					and t.SessionId=i.SessionId and t.SessionId=f.SessionId
					and t.FileId=i.FileId and t.FileId=f.FileId
		   ) ps on ps.SessionId=s.SessionId and ps.fileid=s.FileId
  
		--------------------
		,filelist f
  
		--------------------
		---- el operador en India no se identifica univocamente por el mccmnc.. hay mucha casuistica
		---     se toma el operador de la tabla networkinfo.. como el más veces identificado por fileid
		,(
			select fileid, homeOperator operator
			from
			(
				select *, row_number() over (partition by fileid order by duration desc) id
				from
				(
				select fileid, HomeOperator, sum(duration) duration
				from networkinfo group by fileid, homeoperator
				) t
			) t where id=1
		) op
  where f.FileId=s.FileId and f.fileid=op.fileid

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
UNION ALL		-- UNION WITH MOS Clip testid to have a sepparate count of calls test
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

select
	--db_name()+'_'+convert(varchar(256),s.sessionid)+'_'+isnull(convert(varchar(256),t.testid),'NA') COLLATE Latin1_General_CI_AS key_BST, 
	db_name()+'_'+isnull(convert(varchar(256),s.sessionid),'NA')+'_'+convert(varchar(256),'NA') COLLATE Latin1_General_CI_AS as key_BST,
	db_name() COLLATE Latin1_General_CI_AS as ddbb, 
	f.CollectionName,

	f.Zone as meas_equipment,
	f.TaskName,
	op.operator,
	 
	case when ca.callType is not null then ca.callType else t.typeoftest end typeoftest,
	case when ca.callDir  is not null then ca.callDir  else  t.direction end Direction,

	----------------------------------------
	-- SESSIONS INFO:
	s.valid valid_session, s.invalidreason invalidreason_sesssion,
	s.info session_Status
	--------------------
	-- A Side Information:			 	
	,s.FileId,			s.SessionId,			convert(varchar(256),'SpeechClip') as sessionType		
	,s.startTime as session_start,				s.prevSessionId,										s.nextSessionId 
	,s.duration,		s.SpeedAvg
	,f.ASideDevice,		f.ASideFileName
	,f.ProductVersion,	f.FirmwareV
	,f.IMEI,			f.IMSI
	,left(f.imsi,5) as mccmnc,					left(f.imsi,3) as mcc,				right(left(f.imsi,5),2) as mnc  
	--------------------
	-- B Side Information:
	,b.FileidB,			b.sessionidB,			b.sessiontypeB
	,b.session_startB,							b.prevSessionidB,										b.nextSessionidB			
	,b.durationB,		b.SpeedAvgB
	,b.BSideDevice,		b.BSideFileName
	,b.ProductVersionB, b.firmwareVB
	,b.IMEIB,			b.IMSIB
	,b.mccmnc_B,		b.mcc_B,				b.mnc_B
	
	----------------------------------------
	-- TESTs INFO:
	--------------------
	,s.numOfTests
	,t.TestId
	,t.duration		as test_duration
	,t.SpeedAvg		as test_speed
	,t.startTime	as test_start
	,t.valid valid_test, t.invalidreason as invalidreason_test

	----------------------------------------
	-- GEOGRAPHICAL INFO:
	--------------------
	-- A Side - Ini:	
	,ps.longitude_ini session_longitude_ini ,ps.latitude_ini session_latitude_ini 
	,geography::STPointFromText('POINT('+convert(varchar(256),ps.longitude_ini)+' '+convert(varchar(256),ps.latitude_ini)+')', 4326) GEOpointSession_ini
	,master.dbo.fn_lcc_binning_longitude2lonid (ps.longitude_ini, ps.latitude_ini,500) lonid_SessionIni_500
	,master.dbo.fn_lcc_binning_latitude2latid ( ps.latitude_ini,500) latid_SessioniIni_500
	--,master.dbo.fn_lcc_binning_longitude2lonid (ps.longitude_ini, ps.latitude_ini,50) lonid_SessionIni_50
	--,master.dbo.fn_lcc_binning_latitude2latid ( ps.latitude_ini,50) latid_SessioniIni_50
	,master.dbo.fn_lcc_longitude2lonid (ps.longitude_ini, ps.latitude_ini) lonid_SessionIni_50
	,master.dbo.fn_lcc_latitude2latid ( ps.latitude_ini) latid_SessioniIni_50
		
	-- A Side - End:				
	,ps.longitude_end session_longitude_end , ps.latitude_end session_latitude_end 
	,geography::STPointFromText('POINT('+convert(varchar(256),ps.longitude_end)+' '+convert(varchar(256),ps.latitude_end)+')', 4326) GEOpointSession_end
	,master.dbo.fn_lcc_binning_longitude2lonid (ps.longitude_end, ps.latitude_end,500) lonid_SessionEnd_500
	,master.dbo.fn_lcc_binning_latitude2latid ( ps.latitude_end,500) latid_SessionEnd_500
	--,master.dbo.fn_lcc_binning_longitude2lonid (ps.longitude_end, ps.latitude_end,50) lonid_SessionEnd_50
	--,master.dbo.fn_lcc_binning_latitude2latid ( ps.latitude_end,50) latid_SessionEnd_50
	,master.dbo.fn_lcc_longitude2lonid (ps.longitude_end, ps.latitude_end) lonid_SessionEnd_50
	,master.dbo.fn_lcc_latitude2latid ( ps.latitude_end) latid_SessionEnd_50

	--------------------
	-- B Side - Ini:	
	,b.longitude_iniB, b.latitude_iniB, b.GeoPoint_iniB
	,master.dbo.fn_lcc_binning_longitude2lonid (b.longitude_iniB, b.latitude_iniB,500) lonid_iniB_500
	,master.dbo.fn_lcc_binning_latitude2latid ( b.latitude_iniB,500) latid_iniB_500
	--,master.dbo.fn_lcc_binning_longitude2lonid (b.longitude_iniB, b.latitude_iniB,50) lonid_iniB_50
	--,master.dbo.fn_lcc_binning_latitude2latid ( b.latitude_iniB,50) latid_iniB_50
	,master.dbo.fn_lcc_longitude2lonid (b.longitude_iniB, b.latitude_iniB) lonid_iniB_50
	,master.dbo.fn_lcc_latitude2latid ( b.latitude_iniB) latid_iniB_50

	-- B Side - end:	
	,b.longitude_endB, b.latitude_endB, b.GeoPoint_endB
	,master.dbo.fn_lcc_binning_longitude2lonid (b.longitude_endB, b.latitude_endB,500) lonid_endB_500
	,master.dbo.fn_lcc_binning_latitude2latid ( b.latitude_endB,500) latid_endB_500
	--,master.dbo.fn_lcc_binning_longitude2lonid (b.longitude_endB, b.latitude_endB,50) lonid_endB_50
	--,master.dbo.fn_lcc_binning_latitude2latid ( b.latitude_endB,50) latid_endB_50
	,master.dbo.fn_lcc_longitude2lonid (b.longitude_endB, b.latitude_endB) lonid_endB_50
	,master.dbo.fn_lcc_latitude2latid ( b.latitude_endB) latid_endB_50
		
	----------------------
	---- Test - Ini:				
	--,t.longitude_ini test_longitude_ini , t.latitude_ini test_latitude_ini 
	--,geography::STPointFromText('POINT('+convert(varchar(256),t.longitude_ini)+' '+convert(varchar(256),t.latitude_ini)+')', 4326) GEOpointTest_ini
	--,master.dbo.fn_lcc_binning_longitude2lonid (t.longitude_ini, t.latitude_ini,500) lonid_TestIni_500
	--,master.dbo.fn_lcc_binning_latitude2latid ( t.latitude_ini,500) latid_TestIni_500
	--,master.dbo.fn_lcc_binning_longitude2lonid (t.longitude_ini, t.latitude_ini,50) lonid_TestIni_50
	--,master.dbo.fn_lcc_binning_latitude2latid ( t.latitude_ini,50) latid_TestIni_50
	
	---- Test - end:	
	--,t.longitude_end test_longitude_end , t.latitude_end test_latitude_end 
	--,geography::STPointFromText('POINT('+convert(varchar(256),t.longitude_end)+' '+convert(varchar(256),t.latitude_end)+')', 4326) GEOpointTest_end
	--,master.dbo.fn_lcc_binning_longitude2lonid (t.longitude_end, t.latitude_end,500) lonid_TestEnd_500
	--,master.dbo.fn_lcc_binning_latitude2latid ( t.latitude_end,500) latid_TestEnd_500
	--,master.dbo.fn_lcc_binning_longitude2lonid (t.longitude_end, t.latitude_end,50) lonid_TestEnd_50
	--,master.dbo.fn_lcc_binning_latitude2latid ( t.latitude_end,50) latid_TestEnd_50
	,t.longitude_ini as test_longitude_ini, t.latitude_ini as test_latitude_ini 
	,GEOpointTest_ini
	,lonid_TestIni_500
	,latid_TestIni_500
	,lonid_TestIni_50
	,latid_TestIni_50
	
	-- Test - end:	
	,t.longitude_end as test_longitude_end, t.latitude_end as test_latitude_end 
	,GEOpointTest_end
	,lonid_TestEnd_500
	,latid_TestEnd_500
	,lonid_TestEnd_50
	,latid_TestEnd_50

from Sessions s 
	-------------------- Positioning by Testid
	left outer join 
		( 
			select t.*, pt.FileId, pt.longitude_ini, pt.latitude_ini, pt.longitude_end, pt.latitude_end
				-- Test - Ini:				
				,geography::STPointFromText('POINT('+convert(varchar(256), pt.longitude_ini)+' '+convert(varchar(256), pt.latitude_ini)+')', 4326) as GEOpointTest_ini
				,master.dbo.fn_lcc_binning_longitude2lonid(pt.longitude_ini, pt.latitude_ini,500)	as lonid_TestIni_500
				,master.dbo.fn_lcc_binning_latitude2latid (pt.latitude_ini,500)						as latid_TestIni_500
				--,master.dbo.fn_lcc_binning_longitude2lonid(pt.longitude_ini, pt.latitude_ini,50)	as lonid_TestIni_50
				--,master.dbo.fn_lcc_binning_latitude2latid (pt.latitude_ini,50)						as latid_TestIni_50
				,master.dbo.fn_lcc_longitude2lonid(pt.longitude_ini, pt.latitude_ini)	as lonid_TestIni_50
				,master.dbo.fn_lcc_latitude2latid (pt.latitude_ini)						as latid_TestIni_50
	
				-- Test - end:	
				,geography::STPointFromText('POINT('+convert(varchar(256), pt.longitude_end)+' '+convert(varchar(256), pt.latitude_end)+')', 4326) as GEOpointTest_end
				,master.dbo.fn_lcc_binning_longitude2lonid(pt.longitude_end, pt.latitude_end,500)	as lonid_TestEnd_500
				,master.dbo.fn_lcc_binning_latitude2latid (pt.latitude_end,500)						as latid_TestEnd_500
				--,master.dbo.fn_lcc_binning_longitude2lonid(pt.longitude_end, pt.latitude_end,50)	as lonid_TestEnd_50
				--,master.dbo.fn_lcc_binning_latitude2latid (pt.latitude_end,50)						as latid_TestEnd_50
				,master.dbo.fn_lcc_longitude2lonid(pt.longitude_end, pt.latitude_end)		as lonid_TestEnd_50
				,master.dbo.fn_lcc_latitude2latid (pt.latitude_end)						as latid_TestEnd_50

			from testinfo t
				left outer join 
					(
					select t.fileid, t.SessionId, t.TestId
						,i.longitude longitude_ini, i.latitude latitude_ini
						,f.longitude longitude_end, f.latitude latitude_end
					from 
						(
							select fileid, sessionid, testid,min(posid) as ini_posid, max(posid) as max_posid
							from Position
							group by fileid, sessionid, testid
						) t, position i, Position f
					where t.ini_posid=i.PosId and t.max_posid=f.PosId 
						and t.fileid=i.fileid and t.fileid=f.fileid
						and t.SessionId=i.SessionId and t.SessionId=f.SessionId
						and t.TestId=i.TestId and t.TestId=f.TestId
	
					)	pt on pt.TestId=t.TestId and pt.SessionId=t.SessionId 
			where t.TestId>0 and t.typeoftest like '%speech%'
			
		) t 
			
		on t.SessionId=s.SessionId /*and t.FileId=s.fileid*/ and s.sessionType='Call' and t.typeoftest like '%speech%'

	-------------------- B side information
	left outer join 
		(
			select 
				s.SessionIdA,s.SessionId sessionidB, s.sessionType sessiontypeB
				,s.FileId as FileidB, sa.fileid as FileidA
				,s.duration durationB
				,s.prevSessionId prevSessionidB, s.nextSessionId nextSessionidB
				,s.SpeedAvg SpeedAvgB, s.startTime session_startB, convert(varchar(256),'B') Side_session
				,f.BSideDevice ,BSideFileName
				,f.IMEI IMEIB, f.IMSI IMSIB, left(f.imsi,5) mccmnc_B , left(f.imsi,3) as mcc_B,right(left(f.imsi,5),2) as mnc_B
				,f.ProductVersion ProductVersionB, f.firmwareV firmwareVB
				,ini.longitude as longitude_iniB, ini.latitude as latitude_iniB
				,geography::STPointFromText('POINT('+convert(varchar(256),ini.longitude)+' '+convert(varchar(256),ini.latitude)+')', 4326) GEOpoint_iniB
				,fin.longitude as longitude_endB, fin.latitude as latitude_endB
				,geography::STPointFromText('POINT('+convert(varchar(256),fin.longitude)+' '+convert(varchar(256),fin.latitude)+')', 4326) GEOpoint_endB
			
			from SessionsB s, sessions sa, filelist f,
				(
					select fileid, sessionid,min(posid) as ini_posid, max(posid) as max_posid
					from Position
					group by fileid, sessionid
				) t, position ini, Position fin
				
			where s.sessionidA=sA.sessionid and sA.FileId = f.FileId and s.SessionId=t.SessionId and s.fileid=t.fileid
				and t.ini_posid=ini.PosId and t.max_posid=fin.PosId
				and t.fileid=ini.fileid and t.fileid=fin.fileid
				and t.SessionId=ini.SessionId and t.SessionId=fin.SessionId
		
		) b on b.SessionIdA=s.SessionId and b.FileidA=s.FileId							

	-------------------- Call Analyisis information
	left outer join CallAnalysis ca on ca.SessionId=s.SessionId and ca.fileid=s.fileid
	
	-------------------- Positioning per Sessionid
	left outer join 
			(
				select t.fileid, t.SessionId
				,i.longitude longitude_ini, i.latitude latitude_ini
				,f.longitude longitude_end, f.latitude latitude_end

				from 
					(
						select fileid, sessionid,min(posid) as ini_posid, max(posid) as max_posid
						from Position
						group by fileid, sessionid
					) t, position i, Position f

				where t.ini_posid=i.PosId and t.max_posid=f.PosId
					and t.SessionId=i.SessionId and t.SessionId=f.SessionId
					and t.fileid=i.fileid and t.fileid=f.fileid

			) ps on ps.SessionId=s.SessionId and ps.fileid=s.fileid

	--------------------
	, filelist f

	--------------------
	---- el operador en India no se identifica univocamente por el mccmnc.. hay mucha casuistica
	---     se toma el operador de la tabla networkinfo.. como el más veces identificado por fileid
	,(
		select fileid, homeOperator operator
		from
		(
			select *, row_number() over (partition by fileid order by duration desc) id
			from
			(
			select fileid, HomeOperator, sum(duration) duration
			from networkinfo group by fileid, homeoperator
			) t
		) t where id=1
	) op

where f.FileId=s.FileId and f.fileid=op.fileid and s.sessiontype='Call' and t.TestId is not null


update [lcc_core_Master_Table]
set operator=upper(operator)


---------------		select * from lcc_core_Master_Table



----++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
---- TOMaDO de los CUs:
----	Se actualizan los campos sin GPS, con la posición válida más cercana en el tiempo.
----	Se tiene en cuanta hacia adelante y hacia atrás en el tiempo
----	Se coge la ordenación para coger la más cercana en el tiempo:	order by (timelink asc/desc)
----
---- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

----	******************************************************************************************************
----	UPDATE LONG/LAT - SESSIONS:
----	******************************************************************************************************
----	First position after lose GPS (A):
-----------------------------------------------------------------------------
----	Update INITIAL position - SIDE A
--update lcc_core_Master_Table
--	set session_longitude_ini=(select top 1 longitude from lcc_timelink_position
--						where timelink>=master.dbo.fn_lcc_gettimelink(lc.session_start)
--						and collectionname=lc.collectionname collate Latin1_General_CI_AS
--						and side='A'
--						order by timelink asc),
--	session_latitude_ini=(select top 1 latitude from lcc_timelink_position
--						where timelink>=master.dbo.fn_lcc_gettimelink(lc.session_start)
--						and collectionname=lc.collectionname collate Latin1_General_CI_AS
--						and side='A'
--						order by timelink asc)
--from lcc_core_Master_Table lc
--where
--	(lc.session_longitude_ini is null or lc.session_longitude_ini=0)
	
-----------------------------------------------------------------------------
----	Update FINAL position - SIDE A
--update lcc_core_Master_Table
--	set session_longitude_end=(select top 1 longitude from lcc_timelink_position
--						where timelink>=master.dbo.fn_lcc_gettimelink(dateadd(ms,lc.duration, lc.session_start))		-- el ENDTIME de la session, a partir del duration de sessions
--						and collectionname=lc.collectionname collate Latin1_General_CI_AS
--						and side='A'
--						order by timelink asc),
--	session_latitude_end=(select top 1 latitude from lcc_timelink_position
--						where timelink>=master.dbo.fn_lcc_gettimelink(dateadd(ms,lc.duration, lc.session_start))
--						and collectionname=lc.collectionname collate Latin1_General_CI_AS
--						and side='A'
--						order by timelink asc)
--from lcc_core_Master_Table lc
--where
--	(lc.session_longitude_end is null or lc.session_longitude_end=0)


----	******************************************************************************************************
----	Last position before lose GPS (A):
---------------------------------------------------------------------------
----	Update INITIAL position - SIDE A
--update lcc_core_Master_Table
--	set session_longitude_ini=(select top 1 longitude from lcc_timelink_position
--						where timelink<=master.dbo.fn_lcc_gettimelink(lc.session_start)
--						and collectionname=lc.collectionname collate Latin1_General_CI_AS
--						and side='A'
--						order by timelink desc),
--	session_latitude_ini=(select top 1 latitude from lcc_timelink_position
--						where timelink<=master.dbo.fn_lcc_gettimelink(lc.session_start)
--						and collectionname=lc.collectionname collate Latin1_General_CI_AS
--						and side='A'
--						order by timelink desc)
--from lcc_core_Master_Table lc
--where
--	(lc.session_longitude_ini is null or lc.session_longitude_ini=0)

-----------------------------------------------------------------------------
----	Update FINAL position - SIDE A
--update lcc_core_Master_Table
--	set session_longitude_end=(select top 1 longitude from lcc_timelink_position
--						where timelink<=master.dbo.fn_lcc_gettimelink(dateadd(ms,lc.duration, lc.session_start))
--						and collectionname=lc.collectionname collate Latin1_General_CI_AS
--						and side='A'
--						order by timelink desc),
--	session_latitude_end=(select top 1 latitude from lcc_timelink_position
--						where timelink<=master.dbo.fn_lcc_gettimelink(dateadd(ms,lc.duration, lc.session_start))
--						and collectionname=lc.collectionname collate Latin1_General_CI_AS
--						and side='A'
--						order by timelink desc)
--from lcc_core_Master_Table lc
--where
--	(lc.session_longitude_end is null or lc.session_longitude_end=0)


----	******************************************************************************************************
----	First position after lose GPS (B):
---------------------------------------------------------------------------
----	Update INITIAL position - SIDE B:
--update lcc_core_Master_Table
--	set longitude_iniB=(select top 1 longitude from lcc_timelink_position
--						where timelink>=master.dbo.fn_lcc_gettimelink(lc.session_startB)
--						and collectionname=lc.collectionname collate Latin1_General_CI_AS
--						and side='B'
--						order by timelink asc),
--	latitude_iniB=(select top 1 latitude from lcc_timelink_position
--						where timelink>=master.dbo.fn_lcc_gettimelink(lc.session_startB)
--						and collectionname=lc.collectionname collate Latin1_General_CI_AS
--						and side='B'
--						order by timelink asc)
--from lcc_core_Master_Table lc
--where
--	(lc.longitude_iniB is null or lc.longitude_iniB=0)

---------------------------------------------------------------------------
----	Update FINAL session position - SIDE B:
--update lcc_core_Master_Table
--	set longitude_endB=(select top 1 longitude from lcc_timelink_position
--						where timelink>=master.dbo.fn_lcc_gettimelink(dateadd(ms,lc.durationB, lc.session_startB))
--						and collectionname=lc.collectionname collate Latin1_General_CI_AS
--						and side='B'
--						order by timelink asc),
--	latitude_endB=(select top 1 latitude from lcc_timelink_position
--						where timelink>=master.dbo.fn_lcc_gettimelink(dateadd(ms,lc.durationB, lc.session_startB))
--						and collectionname=lc.collectionname collate Latin1_General_CI_AS
--						and side='B'
--						order by timelink asc)
--from lcc_core_Master_Table lc
--where
--	(lc.longitude_endB is null or lc.longitude_endB=0)


----	******************************************************************************************************
----	Last position before lose GPS (B):
---------------------------------------------------------------------------
----	Update INITIAL position - SIDE B:
--update lcc_core_Master_Table
--	set longitude_iniB=(select top 1 longitude from lcc_timelink_position
--						where timelink<=master.dbo.fn_lcc_gettimelink(lc.session_startB)
--						and collectionname=lc.collectionname collate Latin1_General_CI_AS
--						and side='B'
--						order by timelink desc),
--	latitude_iniB=(select top 1 latitude from lcc_timelink_position
--						where timelink<=master.dbo.fn_lcc_gettimelink(lc.session_startB)
--						and collectionname=lc.collectionname collate Latin1_General_CI_AS
--						and side='B'
--						order by timelink desc)
--from lcc_core_Master_Table lc
--where
--	(lc.longitude_iniB is null or lc.longitude_iniB=0)

---------------------------------------------------------------------------
----	Update FINAL position - SIDE B:
--update lcc_core_Master_Table
--	set longitude_endB=(select top 1 longitude from lcc_timelink_position
--						where timelink<=master.dbo.fn_lcc_gettimelink(dateadd(ms,lc.durationB, lc.session_startB))
--						and collectionname=lc.collectionname collate Latin1_General_CI_AS
--						and side='B'
--						order by timelink desc),
--	latitude_endB=(select top 1 latitude from lcc_timelink_position
--						where timelink<=master.dbo.fn_lcc_gettimelink(dateadd(ms,lc.durationB, lc.session_startB))
--						and collectionname=lc.collectionname collate Latin1_General_CI_AS
--						and side='B'
--						order by timelink desc)
--from lcc_core_Master_Table lc
--where
--	(lc.longitude_endB is null or lc.longitude_endB=0)



----	******************************************************************************************************
----	UPDATE LONG/LAT - TESTS:
----	******************************************************************************************************
----	First position after lose GPS:
---------------------------------------------------------------------------
---- Update INITIAL position
--update lcc_core_Master_Table
--set test_longitude_ini=(select top 1 longitude from lcc_timelink_position 
--						where timelink>=master.dbo.fn_lcc_gettimelink(lc.test_start)
--						and collectionname=lc.collectionname collate Latin1_General_CI_AS
--						and side='A'
--						order by timelink asc),
--	test_latitude_ini=(select top 1 latitude from lcc_timelink_position 
--						where timelink>=master.dbo.fn_lcc_gettimelink(lc.test_start)
--						and collectionname=lc.collectionname collate Latin1_General_CI_AS
--						and side='A'
--						order by timelink asc)
--from lcc_core_Master_Table lc
--where
--(lc.test_longitude_ini is null or lc.test_longitude_ini=0)

---------------------------------------------------------------------------
---- Update FINAL position 
--update lcc_core_Master_Table
--set test_longitude_end=(select top 1 longitude from lcc_timelink_position 
--						where timelink>=master.dbo.fn_lcc_gettimelink(dateadd(ms,lc.test_duration, lc.test_start))
--						and collectionname=lc.collectionname collate Latin1_General_CI_AS
--						and side='A'
--						order by timelink asc),
--	test_latitude_end=(select top 1 latitude from lcc_timelink_position 
--						where timelink>=master.dbo.fn_lcc_gettimelink(dateadd(ms,lc.test_duration, lc.test_start))
--						and collectionname=lc.collectionname collate Latin1_General_CI_AS
--						and side='A'
--						order by timelink asc)
--from lcc_core_Master_Table lc
--where
--	(lc.test_longitude_end is null or lc.test_longitude_end=0)


----	******************************************************************************************************
----	Last position before lose GPS:
---------------------------------------------------------------------------
---- Update INITIAL position
--update lcc_core_Master_Table
--set test_longitude_ini=(select top 1 longitude from lcc_timelink_position 
--						where timelink<=master.dbo.fn_lcc_gettimelink(lc.test_start)
--						and collectionname=lc.collectionname collate Latin1_General_CI_AS
--						and side='A'
--						order by timelink desc),
--	test_latitude_ini=(select top 1 latitude from lcc_timelink_position 
--						where timelink<=master.dbo.fn_lcc_gettimelink(lc.test_start)
--						and collectionname=lc.collectionname collate Latin1_General_CI_AS
--						and side='A'
--						order by timelink desc)
--from lcc_core_Master_Table lc
--where
--	(lc.test_longitude_ini is null or lc.test_longitude_ini=0)

---------------------------------------------------------------------------
----	Update FINAL position
--update lcc_core_Master_Table
--set test_longitude_end=(select top 1 longitude from lcc_timelink_position 
--						where timelink<=master.dbo.fn_lcc_gettimelink(dateadd(ms,lc.test_duration, lc.test_start))
--						and collectionname=lc.collectionname collate Latin1_General_CI_AS
--						and side='A'
--						order by timelink desc),
--	test_latitude_end=(select top 1 latitude from lcc_timelink_position 
--						where timelink<=master.dbo.fn_lcc_gettimelink(dateadd(ms,lc.test_duration, lc.test_start))
--						and collectionname=lc.collectionname collate Latin1_General_CI_AS
--						and side='A'
--						order by timelink desc)
--from lcc_core_Master_Table lc
--where
--	(lc.test_longitude_end is null or lc.test_longitude_end=0)
