USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_lcc_core_Data_LTE_Tech]    Script Date: 27/03/2018 10:29:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[sp_lcc_core_Data_LTE_Tech]
as
exec sp_lcc_dropifexists 'lcc_core_Data_LTE_Tech'

select
	db_name()+'_'+convert(varchar(256),l.sessionid)+'_'+isnull(convert(varchar(256),l.testid),'NA') COLLATE Latin1_General_CI_AS key_BST, 	
	db_name()  ddbb, 
	l.sessionid, l.testid,  

	sum(1.0*l.numrecords* 
		case when l.numrecords>500 then 1-convert(float,l.NumRecords)/(nullif(l.numrecords,0)) 
			else 1-convert(float,l.NumRecords)/(500.0) 
		end  
		)/
	nullif(sum(1.0*l.numrecords),0)
	as PDSCH_DTX_LTE, 
	sum(l. numRecords) NumRecords, 
	sum(1.0*l.numRank2)/nullif(sum(l.numRecords),0) Rank2Use,
	0.000008*sum(1.0*l.netPDSCHThroughput*l.numrecords)/nullif(sum(l.numrecords),0) NetPdschThput_Mbps,
	sum(l.numTBs) numTBs,
	sum(1.0*l.numRBs)/nullif(sum(l.numTBs),0) RBs,
	sum(1.0*l.[BytesTransferred])/(1024*1024) MBytes_transferred,
	sum(1.0*l.numTBs*l.avgMCS)/nullif(sum(l.numTBs),0) avgMCs, 
	sum(1.0*l.NumRetrans1)/nullif(sum(l.numRBs),0) Retx1_rate,
	sum(1.0*l.NumRetrans2)/nullif(sum(l.numRBs),0) Retx2_rate,
	sum(1.0*l.numRetrans3orMore)/nullif(sum(l.numRBs),0) Retx3_rate,
	sum(1.0*l.NumQPSK)/nullif(sum(l.numTBs),0) QPSK_rate,
	sum(1.0*l.Num16QAM)/nullif(sum(l.numTBs),0) QAM16_rate,
	sum(1.0*l.Num64QAM)/nullif(sum(l.numTBs),0) QAM64_rate,
	sum(1.0*l.Num256QAM)/nullif(sum(l.numTBs),0) QAM256_rate,
	1-(sum(1.0*l.numcrcpass)/nullif(sum(l.numTBs),0)) BLER,
	sum(1.0*l.numCarriers*l.numrecords)/nullif(sum(l.numRecords),0) avg_NumCarriers

--into lcc_core_Data_LTE_Tech

from LTEPDSCHStatisticsInfo l
group by 
	db_name()+'_'+convert(varchar(256),l.sessionid)+'_'+isnull(convert(varchar(256),l.testid),'NA') COLLATE Latin1_General_CI_AS , 	
	--	db_name(), 
	l.sessionid, l.testid

 

