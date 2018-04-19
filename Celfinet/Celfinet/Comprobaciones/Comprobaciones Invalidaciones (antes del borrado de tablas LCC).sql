----------Comprobaciones Invalidaciones

-- *********************
--	VOZ
-- *********************

use FY1617_Voice_AVE_MAD_SEV_H2_2

select s.sessionid, s.invalidReason
from sessions s
where 
------Fuera de contorno VDF
sessionid in 
(select s.sessionid
from sessions s,filelist f
left outer join lcc_CelfiNet_Sessions_List c on c.sessionid = s.sessionid
where s.valid = 1 and c.sessionid is null
and s.fileid = f.fileid
and s.sessiontype='call')
------Invalidaciones LCC
or (s.valid=0
and s.InvalidReason like '%LCC%')
order by 1


-- *********************
--	DATOS
-- *********************

use FY1617_Data_AVE_MAD_SEV_H2_2

select t.testid, t.invalidReason
from testinfo t
where 
------Fuera de contorno VDF
testid in 
(select t.testid
from filelist f, sessions s,testinfo t
left outer join lcc_CelfiNet_Tests_List c on c.testid = t.testid
where t.valid = 1 and c.testid is null
and s.fileid = f.fileid
and s.sessionid = t.sessionid
and s.sessiontype='data')
------Invalidaciones LCC
or (t.valid=0
and t.InvalidReason like '%LCC%')
order by 1
