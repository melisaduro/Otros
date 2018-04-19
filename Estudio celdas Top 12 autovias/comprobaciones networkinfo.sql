use FY1718_DATA_MROAD_A1_H1
select * from networkinfo
where fileid=1
use FY1718_voice_MROAD_A1_H1
select * from networkinfo
where fileid=1


SELECT * FROM TESTINFO
WHERE networkid=194
order by STARTTIME,NETWORKID
use FY1718_DATA_MROAD_A1_H1
select sum(duration),sessionid,fileid
from sessions
group by sessionid,fileid
use FY1718_voice_MROAD_A1_H1
select sum(duration),sessionid,fileid
from sessions
group by sessionid,fileid

SELECT * FROM [LTEServingCellInfo]
WHERE NetworkId=194
order by msgtime,NETWORKID


