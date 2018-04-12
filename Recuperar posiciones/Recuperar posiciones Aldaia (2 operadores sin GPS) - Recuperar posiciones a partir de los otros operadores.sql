--Vemos los fileids que nos afectan para recuperar las posiciones (en nuestro caso los fileids sin posiciones son los 144 y 145)
--Recuperaremos las posiciones de los fileids 143 y 146 respectivamente
use FY1617_Data_Rest_3G_H2_6
select fileid, collectionname,* from filelist
where collectionname like '%aldaia%'
order by 1

--- Hacemos una copia temporal de las tablas de lcc_position
select * 
into lcc_position_entity_list_vodafone_20170509
from lcc_position_entity_list_vodafone

select * 
into lcc_position_entity_list_municipio_20170509
from lcc_position_entity_list_municipio

--Vemos las filas afectadas que queremos eliminar
select *
from lcc_position_entity_list_vodafone
where fileid in (144,145)

--Borramos los fileid
delete 
from lcc_position_entity_list_vodafone
where fileid in (144,145)


--Insertamos a partir de las posiciones del fileid 143 y asignamos el fileid 144
insert into 
lcc_position_entity_list_vodafone
select 
'144',lonid,latid,collectionname, measdate,entity_name,type, '144'
from lcc_position_entity_list_vodafone
where fileid = (143)

--Insertamos a partir de las posiciones del fileid 146 y asignamos el fileid 145
insert into 
lcc_position_entity_list_vodafone
select 
'145',lonid,latid,collectionname, measdate,entity_name,type, '145'
from lcc_position_entity_list_vodafone
where fileid = (146)

--Mismo procedimiento con la tabla de municipio
select *
from lcc_position_entity_list_municipio
where fileid in (144,145)

begin transaction
delete 
from lcc_position_entity_list_municipio
where fileid in (144,145)
commit

insert into 
lcc_position_entity_list_municipio
select 
'144',lonid,latid,collectionname, measdate,entity_name,type, '144'
from lcc_position_entity_list_municipio
where fileid = (143)

insert into 
lcc_position_entity_list_municipio
select 
'145',lonid,latid,collectionname, measdate,entity_name,type, '145'
from lcc_position_entity_list_municipio
where fileid = (146)


--Comprobamos que las posiciones asignadas para cada fileid corresponden
select fileid, collectionname, count(1)
from lcc_position_entity_list_municipio
where entity_name ='aldaia'
group by fileid, collectionname
order by 1

