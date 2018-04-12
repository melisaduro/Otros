use [FY1617_DATA_PRUEBA_2]

select l.TestId, count(1) as 'Count_Info',
 max(case when l.msgtime < k.starttime then msgTime end) as 'MsgTimeAnterior',
 sum(case when l.msgtime < k.starttime then 1 else 0 end) as 'InfoAnterior',
 sum(case when l.msgtime between k.starttime and k.endtime then 1 else 0 end) as 'InfoTramo',
 sum(case when l.msgtime > k.endtime then 1 else 0 end) as 'InfoPosterior'
from TestInfo test, LTEPDSCHStatisticsInfo l, 
 ResultsKpi k  
where l.sessionid=k.sessionid and l.testid=k.testid and (k.kpiid=20415 or k.kpiid=20405 or k.kpiid=20417 or k.kpiid=20461)
 --and l.msgtime between k.starttime and k.endtime
 and test.testid=l.testid
 and l.TestId in (31377,37533,31297,31337,31617,31719,31937,37453,34169,31799,34369,31479,31737,31759,31897,34409,33729,34231,33809,34431,34525,35063,34445,34663,34765,34463,34783,37431,37493,35023,35125,36763,31817,31977,31999,34943,35045,37671,37773,37991,38093,40102,34983,35085,39760,40062,37751,38071,37711,37813,37973,38031,38133,39720,40142,34485,34703,34805,40040,40360,40382,40080,37471,37733,37791,37911,31399,31657,31359,31679,37853,31417,34845,32017,31439,34743,31697,34903,31319,31959,34823,38111,31457,34885,34565,35103,37893,37573,34503,34209,38173,36843,33889,31239,37511,31777,37831,31519,31839,39902,35165,34071,37413,31639,35005,40302,40240,34329,37263,37631,36683,33791,31577,31857,34623,34685,31257,38013,37951,34391,37201,37693,37082,39920,37591,37653,39880,34965,40200,34645,33751,34863,35183,36705,40262,37104,31919,33649,34031,34583,31279,31599,31537,31497,37002,37551,34925,37613,34543,34311,37871,40222,31559,33711,34605,35143,37933,31879,36665,38151)

group by l.TestId
order by 2

------DL 4G
--select l.TestId, count(1) as 'Count_Info',
-- max(case when l.msgtime < k.starttime then msgTime end) as 'MsgTimeAnterior',
-- sum(case when l.msgtime < k.starttime then 1 else 0 end) as 'InfoAnterior',
-- sum(case when l.msgtime between k.starttime and k.endtime then 1 else 0 end) as 'InfoTramo',
-- sum(case when l.msgtime > k.endtime then 1 else 0 end) as 'InfoPosterior'
--from TestInfo test, LTEPDSCHStatisticsInfo l, 
-- ResultsKpi k  
--where l.sessionid=k.sessionid and l.testid=k.testid and (k.kpiid=20415 or k.kpiid=20405 or k.kpiid=20417 or k.kpiid=20461)
-- and l.msgtime between k.starttime and k.endtime
-- and test.testid=l.testid
-- and l.TestId in (37533,36984,37871,39791)
--group by l.TestId

------UL 4G
--select l.TestId, count(1) as 'Count_Info',
-- max(case when l.msgtime < k.starttime then msgTime end) as 'MsgTimeAnterior',
-- sum(case when l.msgtime < k.starttime then 1 else 0 end) as 'InfoAnterior',
-- sum(case when l.msgtime between k.starttime and k.endtime then 1 else 0 end) as 'InfoTramo',
-- sum(case when l.msgtime > k.endtime then 1 else 0 end) as 'InfoPosterior'
--from TestInfo test, LTEPUSCHStatisticsInfo l, 
-- ResultsKpi k  
--where l.sessionid=k.sessionid and l.testid=k.testid and (k.kpiid = 20416 or k.kpiid=20412 or k.kpiid=20462)
-- and l.msgtime between k.starttime and k.endtime
-- and test.testid=l.testid
-- and l.TestId in (34293,33036,33263)
--group by l.TestId
------UL 3G
--select l.TestId, count(1) as 'Count_Info',
-- max(case when l.msgtime < k.starttime then msgTime end) as 'MsgTimeAnterior',
-- sum(case when l.msgtime < k.starttime then 1 else 0 end) as 'InfoAnterior',
-- sum(case when l.msgtime between k.starttime and k.endtime then 1 else 0 end) as 'InfoTramo',
-- sum(case when l.msgtime > k.endtime then 1 else 0 end) as 'InfoPosterior'
--from TestInfo test, HSUPAMACStatistics l, 
-- ResultsKpi k  
--where l.sessionid=k.sessionid and l.testid=k.testid and (k.kpiid = 20416 or k.kpiid=20412 or k.kpiid=20462)
-- and l.msgtime between k.starttime and k.endtime
-- and test.testid=l.testid
-- and l.TestId in (38271,38280)
--group by l.TestId

------DL 3G
--select l.TestId, count(1) as 'Count_Info',
-- max(case when l.msgtime < k.starttime then msgTime end) as 'MsgTimeAnterior',
-- sum(case when l.msgtime < k.starttime then 1 else 0 end) as 'InfoAnterior',
-- sum(case when l.msgtime between k.starttime and k.endtime then 1 else 0 end) as 'InfoTramo',
-- sum(case when l.msgtime > k.endtime then 1 else 0 end) as 'InfoPosterior'
--from TestInfo test, HSDPAThroughput l, 
-- ResultsKpi k  
--where l.sessionid=k.sessionid and l.testid=k.testid and (k.kpiid=20415 or k.kpiid=20405 or k.kpiid=20417 or k.kpiid=20461)
-- and l.msgtime between k.starttime and k.endtime
-- and test.testid=l.testid
-- and l.TestId in (38267,38276)
--group by l.TestId