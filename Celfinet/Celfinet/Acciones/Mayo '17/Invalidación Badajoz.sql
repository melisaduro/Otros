-------VOZ
USE FY1617_Voice_Badajoz_3G_H2
select FILEID,CollectionName from filelist
order by 2

select * from filelist f, sessions s
where f.fileid=s.fileid
and collectionname not like '%badajoz%'
and s.valid=0
and s.InvalidReason='LCC Not Reported'

begin transaction
update sessions
set valid=0, InvalidReason='Lcc Not Reported'
from filelist f, sessions s
where f.fileid=s.fileid
and collectionname not like '%badajoz%'
and s.valid=1
commit


------DATOS-------
USE FY1617_Data_Badajoz_3G_H2
select FILEID,CollectionName from filelist
order by 2

select * from filelist f, sessions s, testinfo t
where f.fileid=s.fileid
and s.SessionId=t.SessionId
and t.InvalidReason='LCC Not Reported'

begin transaction
update testinfo
set valid=0, InvalidReason='Lcc Not Reported'
from filelist f, sessions s, testinfo t
where collectionname not like '%badajoz%'
and f.fileid=s.fileid
and s.SessionId=t.SessionId
and t.valid=1
commit


select FILEID,CollectionName from filelist
where fileid between 153 AND 174

BEGIN TRANSACTION
UPDATE FILELIST 
SET COLLECTIONNAME='20170411_SC_BA_BADAJOZ_1_3G'
where fileid between 153 AND 174

COMMIT