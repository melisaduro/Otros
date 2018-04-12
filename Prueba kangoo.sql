
use FY1617_DATA_PRUEBA
select * from lcc_Serving_Cell_Table
where collectionname like '%kangoo%'

use FY1617_DATA_PRUEBA
select * from filelist

GROUP BY FREQ, SIGNAL, QUALITY, OPERATOR, MNC, COLLECTIONNAME , BAND

use FY1617_DATA_PRUEBA
select *
from WCDMAMeasReportInfo t , WCDMAMeasReport c, filelist f, sessions s
where f.fileid=s.fileid and s.sessionid=t.sessionid and t.MeasReportId=c.MeasReportId
and collectionname like '%kangoo%'
GROUP BY  CollectionName
ORDER BY 4

use FY1617_DATA_PRUEBA_2
select * from WCDMAMeasReportInfo t , WCDMAMeasReport c, filelist f, sessions s
where f.fileid=s.fileid and s.sessionid=t.sessionid and t.MeasReportId=c.MeasReportId
and collectionname like '%kangoo%'
GROUP BY PSC , CollectionName 
ORDER BY 5

select longitude, latitude, collectionname 
from filelist f, sessions s, lcc_position c 
where collectionname like '%kangoo%'
and f.fileid=s.fileid and s.posid=c.posid
group by  longitude, latitude, collectionname

select freqDL,PrimSccode, (log10(avg(power(10.0E0,(1.0 * AggrEcio)/10.0E0)))*10) as Avg_EcIo,
(log10(avg(power(10.0E0,(1.0 * AggrRSCP)/10.0E0)))*10) as Avg_RSCP, collectionname, asidefilename,count (1) as num_muestras
from WCDMAActiveSet w, filelist f, sessions s
where f.fileid=s.fileid and w.sessionid=s.sessionid
and collectionname like '%kangoo%'
group by freqDL,PrimSccode, collectionname, asidefilename
order by 5

log10(avg(power(10.0E0,(1.0 * AggrEcio)/10.0E0)))*10 as 'EcI0 Avg'

select * from sessions