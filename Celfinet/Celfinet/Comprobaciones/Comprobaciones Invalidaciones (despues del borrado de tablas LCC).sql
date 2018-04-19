-- *******************************************
--	COMPROBACIONES INVALIDACIONES
-- *******************************************
-- *********************
--	VOZ
-- *********************
use FY1617_Voice_Rest_3G_H2_8
select sessionid,collectionname
from sessions s, filelist f
where valid=0
and s.fileid=f.fileid
and s.InvalidReason not like '% - ORA'
and s.InvalidReason like '%LCC%'
--and collectionname not like '%quartdepoblet%'
order by 1

-- *********************
--	DATOS
-- *********************
use FY1617_Data_Rest_4G_H2_8
select testid,collectionname,t.invalidReason
from testinfo t, sessions s, filelist f
where t.valid=0
and t.sessionid=s.sessionid
and s.fileid=f.fileid
and t.InvalidReason not like '% - ORA'
and t.InvalidReason like '%LCC%'
--and collectionname not like '%quartdepoblet%'
order by 1	


-- *******************************************
--	COMPROBACIONES CONTORNOS VODAFONE
-- *******************************************
-- *********************
--	VOZ
-- *********************
use FY1617_Voice_Rest_3G_H2_8
select sessionid,collectionname
from sessions s, filelist f
where valid=0
and s.fileid=f.fileid
and s.InvalidReason='LCC OutOfBounds - ORA'
order by 1

-- *********************
--	DATOS
-- *********************
use FY1617_Data_Rest_4G_H2_8
select testid,collectionname
from testinfo t, sessions s, filelist f
where t.valid=0
and t.sessionid=s.sessionid
and s.fileid=f.fileid
and t.InvalidReason='LCC OutOfBounds - ORA'
order by 1									