-- Invalidaciones fuera de contorno VDF para BBDD DATOS--
use [FY1617_Data_Rest_4G_H1_3]
update TestInfo
set valid = 0, InvalidReason = 'LCC OutOfBounds - ORA'
where valid = 1
and  testid in 
(	select t.testid
	from filelist f, sessions s,testinfo t
	left outer join lcc_CelfiNet_Tests_List c on c.testid = t.testid
	where t.valid = 1 and c.testid is null
	and s.fileid = f.fileid
	--and f.collectionname like '%PTO%SANTA%MARIA%'
	and s.sessionid = t.sessionid
	and s.sessiontype='data'
)