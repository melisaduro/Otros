--------------------------VOZ
---AGRRVoice4G
select concat('AGGRVoice4G.dbo.',name,'')
from AGGRVoice4G.sys.tables
where name like '%2016%' 
or name like '%_WCDMA%'
or name like '%public%'
or name like '%_grid%'
or name like '%backup%' 

---AGRRVoice3G
select concat('AGGRVoice3G.dbo.',name,'')
from AGGRVoice3G.sys.tables
where name like '%2016%' 
or name like '%_WCDMA%'
or name like '%public%'
or name like '%_grid%'
or name like '%backup%' 

---AGRRVoice4G_road
select concat('AGRRVoice4G_road.dbo.',name,'')
from AGGRVoice4G_road.sys.tables
where name like '%2016%' 
or name like '%_WCDMA%'
or name like '%public%'
or name like '%_grid%'
or name like '%backup%' 

---AGGRVOLTE
select concat('AGGRVOLTE.dbo.',name,'')
from AGGRVOLTE.sys.tables
where name like '%2016%' 
or name like '%_WCDMA%'
or name like '%public%'
or name like '%_grid%'
or name like '%backup%' 

--------------------------DATOS
---AGRRData4G
select concat('AGGRData4G.dbo.',name,'')
from AGGRData4G.sys.tables
where name like '%2016%'
or name like '%_WCDMA%'
or name like '%public%'
or name like '%_grid%'
or name like '%backup%' 

---AGRRData3G
select concat('AGGRData3G.dbo.',name,'')
from AGGRData3G.sys.tables
where name like '%2016%' 
or name like '%_WCDMA%'
or name like '%public%'
or name like '%_grid%'
or name like '%backup%' 

---AGRRData4G_road
select concat('select * from AGGRData4G_road.dbo.',name,'')
from AGGRData4G_road.sys.tables
where name like '%2016%' 
or name like '%_WCDMA%'
or name like '%public%'
or name like '%_grid%'
or name like '%backup%' 
