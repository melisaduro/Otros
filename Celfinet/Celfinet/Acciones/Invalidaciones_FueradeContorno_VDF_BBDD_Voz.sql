-- Invalidaciones fuera de contorno VDF para BBDD VOZ---
use [FY1617_Voice_Rest_4G_H1_3]
update sessions
set valid = 0, InvalidReason = 'LCC OutOfBounds - ORA'
where valid = 1
and  sessionid in 
(
	select s.sessionid
	from filelist f, sessions s
	left outer join LCC_Celfinet_Sessions_List c on c.sessionid = s.sessionid
	where s.valid = 1 and c.sessionid is null
	and s.fileid = f.fileid
	--and f.collectionname like '%CHICLANA%'
	and s.sessiontype='call'
)