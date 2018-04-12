select distinct nombre
from agrids_v2.dbo.lcc_AGRIDS_AVE_OSP

select *
from AGRIDS.dbo.lcc_AVE_ROAD_names


create table AGRIDS.dbo.lcc_AVE_ROAD_names (
[entity_collectionname] varchar(256),
[entity_procesado] varchar(256)
)

begin transaction
insert into AGRIDS.dbo.lcc_AVE_ROAD_names (entity_collectionname,entity_procesado)
values('ALB-ALI','AVE-Albacete-Alicante')

insert into AGRIDS.dbo.lcc_AVE_ROAD_names (entity_collectionname,entity_procesado)
values('BCN-FIG','AVE-Barcelona-Figueres')

insert into AGRIDS.dbo.lcc_AVE_ROAD_names (entity_collectionname,entity_procesado)
values('COR-MAL','AVE-Cordoba-Malaga')

insert into AGRIDS.dbo.lcc_AVE_ROAD_names (entity_collectionname,entity_procesado)
values('MAD-BCN','MAD-BCN')

insert into AGRIDS.dbo.lcc_AVE_ROAD_names (entity_collectionname,entity_procesado)
values('MAD-MOT','AVE-Madrid-Motilla')

insert into AGRIDS.dbo.lcc_AVE_ROAD_names (entity_collectionname,entity_procesado)
values('MAD-SEV','MAD-SEV')

insert into AGRIDS.dbo.lcc_AVE_ROAD_names (entity_collectionname,entity_procesado)
values('MAD-VLC','MAD-VLC')

insert into AGRIDS.dbo.lcc_AVE_ROAD_names (entity_collectionname,entity_procesado)
values('MAD-VALLA','AVE-Madrid-Valladolid')

insert into AGRIDS.dbo.lcc_AVE_ROAD_names (entity_collectionname,entity_procesado)
values('MOT-ALB','AVE-Motilla-Albacete')

insert into AGRIDS.dbo.lcc_AVE_ROAD_names (entity_collectionname,entity_procesado)
values('MOT-VLC','AVE-Motilla-Valencia')

insert into AGRIDS.dbo.lcc_AVE_ROAD_names (entity_collectionname,entity_procesado)
values('OLM-ZAM','AVE-Olmedo-Zamora')

insert into AGRIDS.dbo.lcc_AVE_ROAD_names (entity_collectionname,entity_procesado)
values('SGO-OUR','AVE-Santiago-Orense')

insert into AGRIDS.dbo.lcc_AVE_ROAD_names (entity_collectionname,entity_procesado)
values('VALLA-LEO','AVE-Valladolid-Leon')

insert into AGRIDS.dbo.lcc_AVE_ROAD_names (entity_collectionname,entity_procesado)
values('A1-IRUN','A1-IRUN')

insert into AGRIDS.dbo.lcc_AVE_ROAD_names (entity_collectionname,entity_procesado)
values('A2-BCN','A2-BCN')

insert into AGRIDS.dbo.lcc_AVE_ROAD_names (entity_collectionname,entity_procesado)
values('A3-VLC','A3-VLC')

insert into AGRIDS.dbo.lcc_AVE_ROAD_names (entity_collectionname,entity_procesado)
values('A4-CAD','A4-CAD')

insert into AGRIDS.dbo.lcc_AVE_ROAD_names (entity_collectionname,entity_procesado)
values('A5-BAD','A5-BAD')

insert into AGRIDS.dbo.lcc_AVE_ROAD_names (entity_collectionname,entity_procesado)
values('A6-COR','A6-COR')

insert into AGRIDS.dbo.lcc_AVE_ROAD_names (entity_collectionname,entity_procesado)
values('A7-ALG','A7-ALG')

commit


use FY1617_Data_AVE_Rest_H1
select distinct collectionname 
from filelist
where collectionname like 'MAd'

exec sp_lcc_dropifexists 'temporal_log' 
select FileId,concat(t.entity_procesado,'-',Substring([master].dbo.fn_lcc_getElement(4, CollectionName,'_'),len([master].dbo.fn_lcc_getElement(4, CollectionName,'_'))-charindex('-',reverse([master].dbo.fn_lcc_getElement(4, CollectionName,'_')))+2,3)) as 'Entidad_Medida'
into temporal_log
from FileList f, AGRIDS.dbo.lcc_AVE_ROAD_names t
where FileId>@max_fileid
and reverse(Substring(reverse([master].dbo.fn_lcc_getElement(4, f.CollectionName,'_')),charindex('-',reverse([master].dbo.fn_lcc_getElement(4, f.CollectionName,'_')))+1,len(reverse([master].dbo.fn_lcc_getElement(4, f.CollectionName,'_')))))= t.entity_collectionname
group by FileId,entity_procesado,collectionname



select FileId,[master].dbo.fn_lcc_getElement(4, CollectionName,'_') as 'Entidad_Medida'

from FileList

group by FileId,CollectionName