--1322
select * from lcc_serving_cell_table
where sessionid=2
-101
use FY1718_VOICE_MROAD_A1_H1
select * from lcc_serving_cell_table
where sessionid=2

--VOZ
use FY1718_VOICE_MROAD_A1_H1
--478222
select ini.SessionId,ini.testid, ini.MsgTime as time_ini,
	isnull(fin.MsgTime,case when s.info= 'Failed' then DATEADD(ms, s.duration ,s.startTime)end) as time_fin,
	DATEDIFF(ms, ini.MsgTime , isnull(fin.MsgTime,case when s.info= 'Failed' then DATEADD(ms, s.duration ,s.startTime)end)) as duration,
	ini.Freq,ini.Operator, ini.Band, ini.technology,ini.collectionname,ini.Cell
into [DASHBOARD].dbo.estudio_celdas_top12_Serving
from lcc_serving_cell_table ini 
	inner join sessions s
	on (ini.sessionid = s.sessionid)
	left join lcc_serving_cell_table fin
	on (ini.sessionid = fin.sessionid
		and ini.idSide = fin.idSide -1
		and ini.side=fin.side)
where ini.collectionname like '%r6%'
order by 1, 2

--DATOS
use FY1718_DATA_MROAD_A1_H1
--158140
insert into [DASHBOARD].dbo.estudio_celdas_top12_Serving
select ini.SessionId, ini.testid,ini.MsgTime as time_ini,
	isnull(fin.MsgTime,DATEADD(ms, s.duration ,s.startTime)) as time_fin,
	DATEDIFF(ms, ini.MsgTime , isnull(fin.MsgTime,DATEADD(ms, s.duration ,s.startTime))) as duration,
	ini.Freq,ini.Operator, ini.Band, ini.technology,ini.collectionname,ini.Cell

from lcc_serving_cell_table ini 
	inner join testinfo s
	on (ini.sessionid = s.sessionid and ini.testid=s.testid)
	left join lcc_serving_cell_table fin
	on (ini.sessionid = fin.sessionid and ini.testid=fin.testid
		and ini.idSide = fin.idSide -1
		and ini.side=fin.side)
where ini.collectionname like '%r6%'
order by 1, 2

