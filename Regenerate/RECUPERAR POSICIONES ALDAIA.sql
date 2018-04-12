select *
from filelist

use FY1617_Data_Rest_3G_H2_6
select f.fileid, sessionid, count(1), posid
from position p, filelist f
where p.fileid=f.fileid
and collectionname like '%aldaia%'
group by f.fileid,sessionid,posid
order by f.fileid,sessionid

select f.fileid, sessionid,collectionname
from filelist f, sessions s
where f.fileid=s.fileid
and collectionname like '%aldaia%'
group by f.fileid, sessionid
order by f.fileid,sessionid


select msgtime
into lcc_serving_cell_table_vodafone_temporal
from lcc_serving_cell_table
where collectionname like '%aldaia%'
and mnc=1
order by msgtime

select msgtime
into lcc_serving_cell_table_movistar_temporal
from lcc_serving_cell_table
where collectionname like '%aldaia%'
and mnc=7
order by msgtime

select *,[master].[dbo].fn_lcc_getTimelink(CONVERT(time, DATEADD(s, 2.346 ,vdf.msgtime), 108)),[master].[dbo].fn_lcc_getTimelink(CONVERT(time, OSP.msgtime, 108)),[master].[dbo].fn_lcc_getTimelink(CONVERT(time, DATEADD(s, 2.346 ,vdf.msgtime), 108))-[master].[dbo].fn_lcc_getTimelink(CONVERT(time, osp.msgtime, 108)) as dif
from lcc_serving_cell_table_vodafone_temporal vdf, lcc_serving_cell_table_movistar_temporal osp
where [master].[dbo].fn_lcc_getTimelink(CONVERT(time, DATEADD(s, 2.346 ,vdf.msgtime), 108))=[master].[dbo].fn_lcc_getTimelink(CONVERT(time, osp.msgtime, 108))
order by vdf.msgtime

