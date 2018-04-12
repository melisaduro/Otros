-----Primera pregunta Entity_Name (V9)=Entities_BBDD (tabla dashboard)

select *
from AGRIDs_v2.dbo.lcc_ciudades_tipo_Project_V9 v
left join AGRIDs.dbo.lcc_dashboard_info_scopes_NEW d
on v.entity_name=d.entities_bbdd
where d.entities_bbdd is null
and v.scope <> 'ADD-ON CITIES COVERAGE'

----En la V9 no está el scope de RW y ROADs
select *
from AGRIDs.dbo.lcc_dashboard_info_scopes_NEW d
left join AGRIDs_v2.dbo.lcc_ciudades_tipo_Project_V9 v
on v.entity_name=d.entities_bbdd
where v.entity_name is null


----En la V9 está tanto calidad como cobertura. Cobertura no está en la info_scopes_NEW.


---Creamos backup para crear la tabla V9 de bakcup 

select * from [AGRIDs_v2].[dbo].lcc_ciudades_tipo_Project_V9_backup_20170301
where scope <> 'ADD-ON CITIES COVERAGE'

select * into [AGRIDs_v2].[dbo].lcc_ciudades_tipo_Project_V9_backup_20170301
from [AGRIDs_v2].[dbo].lcc_ciudades_tipo_Project_V9

---Añadimos columnas nuevas

alter table [AGRIDs_v2].[dbo].lcc_ciudades_tipo_Project_V9_backup_20170301 
ADD Entities_Dashboard varchar (256) NULL

alter table [AGRIDs_v2].[dbo].lcc_ciudades_tipo_Project_V9_backup_20170301 
ADD Provincia_Dashboard  varchar (256) NULL

alter table [AGRIDs_v2].[dbo].lcc_ciudades_tipo_Project_V9_backup_20170301 
ADD CCAA_Dashboard  varchar (256) NULL

---Rellenamos columnas con la nueva información

--Entities_dashboard
select * from [AGRIDs_v2].[dbo].lcc_ciudades_tipo_Project_V9_backup_20170301 

begin transaction
update [AGRIDs_v2].[dbo].lcc_ciudades_tipo_Project_V9_backup_20170301 
set Entities_Dashboard=v.Entities_Dashboard
from AGRIDs.dbo.lcc_dashboard_info_scopes_NEW v
inner join [AGRIDs_v2].[dbo].lcc_ciudades_tipo_Project_V9_backup_20170301  d
on d.entity_name=v.entities_bbdd
commit

--Provincia_dashboard

begin transaction
update [AGRIDs_v2].[dbo].lcc_ciudades_tipo_Project_V9_backup_20170301 
set Provincia_Dashboard=v.Provincia
from [AGRIDs_v2].[dbo].lcc_ciudades_tipo_Project_V9_backup_20170224 v
inner join [AGRIDs_v2].[dbo].lcc_ciudades_tipo_Project_V9_backup_20170301  d
on d.entity_name=v.entity_name
commit

--CCAA_dashboard

begin transaction
update [AGRIDs_v2].[dbo].lcc_ciudades_tipo_Project_V9_backup_20170301 
set CCAA_Dashboard=v.CCAA
from [AGRIDs_v2].[dbo].lcc_ciudades_tipo_Project_V9_backup_20170224 v
inner join [AGRIDs_v2].[dbo].lcc_ciudades_tipo_Project_V9_backup_20170301  d
on d.entity_name=v.entity_name
commit