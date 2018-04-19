use FY1718_DATA_BURGOS_4G_H1

select sum(1) from testinfo t,[ResultsHTTPBrowserTest] p,sessions s, filelist f
where typeoftest='HTTPBrowser'
and t.testid=p.testid
and t.valid=1
and s.sessionid=t.sessionid
and f.fileid=s.fileid
and right(left(imsi,5),2)=1
and p.url like '%http:%'
