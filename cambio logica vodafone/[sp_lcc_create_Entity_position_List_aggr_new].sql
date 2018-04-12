USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_lcc_create_Entity_position_List_aggr]    Script Date: 04/01/2018 12:26:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[sp_lcc_create_Entity_position_List_aggr] @fromErase int=0
as


--**************************************************************************************************************

--declare @fromErase as int=0	-- procedimiento normal tras la importacion
--declare @fromErase as int=1	-- procedimiento puntual tras el erase --> tarda bastante mas, xq recalcula todo again
--								--		-> hay que dejar las entidades ya agregadas y revisar que sus fileids no tenga info de otras entidades 
--declare @fromErase as int=2	-- no se tiene en cuenta el listado de agregado

--drop table lcc_position_Entity_List_Municipio
--drop table lcc_position_Entity_List_Vodafone
--drop table lcc_position_Entity_List_Orange
--drop table lcc_CelfiNet_Sessions_List

---------------------------
-- Si no existen, se crean las las tablas necesarias:
if (select name from sys.all_objects where name='lcc_position_Entity_List_Municipio' and type='U') is null
begin
create table lcc_position_Entity_List_Municipio (
	[fileid] [bigint] NULL,
	lonid [bigint] NULL,
	latid [bigint] NULL,
	Collectionname [varchar] (256) NULL,
	MeasDate [varchar] (256) NULL,
	[Entity_name] [varchar] (256) NULL,
	[Type] [varchar] (256) NULL,
	[fileidB] [bigint] NULL
)
end


--if (select name from sys.all_objects where name='lcc_position_Entity_List_Vodafone' and type='U') is null
--begin
--create table lcc_position_Entity_List_Vodafone (
--	[fileid] [bigint] NULL,
--	lonid [bigint] NULL,
--	latid [bigint] NULL,
--	Collectionname [varchar] (256) NULL,
--	MeasDate [varchar] (256) NULL,
--	[Entity_name] [varchar] (256) NULL,
--	[Type] [varchar] (256) NULL,
--	[fileidB] [bigint] NULL,
--)
--end


if (select name from sys.all_objects where name='lcc_position_Entity_List_Orange' and type='U') is null
begin
create table lcc_position_Entity_List_Orange (
	[fileid] [bigint] NULL,
	lonid [bigint] NULL,
	latid [bigint] NULL,
	Collectionname [varchar] (256) NULL,
	MeasDate [varchar] (256) NULL,
	[Entity_name] [varchar] (256) NULL,
	[Type] [varchar] (256) NULL,
	[fileidB] [bigint] NULL

)
end


-----------------------------
---- Tablas para CelfiNet:
---- VOZ:
--if (select name from sys.all_objects where name='lcc_CelfiNet_Sessions_List' and type='U') is null and db_name() like '%Voice%'
--begin

--create table lcc_CelfiNet_Sessions_List (
--	[fileid] [bigint] NULL,
--	[sessionid] [bigint] NULL,
--	[Collectionname] [varchar] (256) NULL
--)
--end

---- DATOS:
--if (select name from sys.all_objects where name='lcc_CelfiNet_Tests_List' and type='U') is null and db_name() like '%Data%'
--begin

--create table lcc_CelfiNet_Tests_List (
--	[fileid] [bigint] NULL,
--	[sessionid] [bigint] NULL,
--	[testid] [bigint] NULL,
--	[Collectionname] [varchar] (256) NULL
--)
--end


--******************************************************************************************************
--************************ PARTE A - Actualizar las entidades por donde se pasa ************************
--******************************************************************************************************
--------------
-- 0) En funcion de la bbdd (VOZ/DATOS y 3G/4G) hay que crear la tabla con las entidades agregadas
--------------
declare @Meas_Round as varchar(256)= [master].dbo.fn_lcc_getElement(1, db_name(),'_') + '_' + [master].dbo.fn_lcc_getElement(5, db_name(),'_')
--print @Meas_Round

-- Entidades agregadas en este Meas_Round en funcion de la tecnologia 
exec sp_lcc_dropifexists '_aggr'
CREATE TABLE [dbo].[_aggr](
	[Database] [nvarchar](128) NULL,
	[Entidad] [varchar](256) NULL,
	[Report_Type] [varchar](256) NULL
) 

--------------
-- Si el parametro es 2, no tendriamos en cuenta las agregadas, por lo que se incluirian tmb
if (@fromErase<>2)	
begin
	if db_name() like '%Voice%3G%'
	begin
		insert into _aggr
		select [Database], [Entidad], [Report_Type] 
		from [vlcc_AGGRVoice3G]
		where Meas_Round=@Meas_Round		
		group by [Database], [Entidad], [Report_Type] 
	end

	--Bases de datos de voz 4G FY1617. Consultamos las vistas de voz CSFB

	if (db_name() like '%Voice%4G%' or db_name() like '%Voice_AVE%' or 
		db_name() like '%Voice_Indoor%' or db_name() like '%Voice_%Road_%')	-- este ultimo termina en _A, para diferenciar de VOLTE
		and db_name() not like '%FY1718%'
	begin
		insert into _aggr
		select [Database], [Entidad], [Report_Type] 
		from [vlcc_AGGRVoice4G]
		where Meas_Round=@Meas_Round		
		group by [Database], [Entidad], [Report_Type] 
		order by [Database], [Entidad], [Report_Type] 
	end 

	--Bases de datos de voz 4G FY1718. Consultamos las vistas de voz CSFB, voz VOLTE y cobertura
	if (db_name() like '%Voice%4G%' or db_name() like '%Voice_AVE%' or 
		db_name() like '%Voice_Indoor%' or db_name() like '%Voice_%Road_%')	-- este ultimo termina en _A, para diferenciar de VOLTE
		and db_name() like '%FY1718%'
	begin
		--(el contorno estará cerrado cuando estén los 4 operadores agregados en CSFB y VOLTE y esté agregada la cobertura)
		insert into _aggr
		select calidad.[Database],calidad.entidad,calidad.report_type
		from
		(select [Database], [Entidad], [Report_Type]
				from(
					
					SELECT [Database], [Entidad], [Report_Type],count(distinct(tech)) as count_tech
					FROM (
						--Comprobamos que se agregan los cuatro operadores
						select * from
						(
							select [Database], [Entidad], [Report_Type],count(distinct(mnc)) as count_MNC,'4G' as tech
							from [vlcc_AGGRVoice4G]
							where Meas_Round=@Meas_Round	
							group by [Database], [Entidad], [Report_Type]
						)csfb
						where count_MNC=4
		 
						union all

						--Comprobamos que se agregan los cuatro operadores
						select * from 
						(
							select [Database], [Entidad], [Report_Type],count(distinct(mnc)) as count_MNC,'VOLTE' as tech
							from [vlcc_AGGRVolte]
							where Meas_Round=@Meas_Round
							group by [Database], [Entidad], [Report_Type]
						) volte
						where count_MNC=4 
					) aggr
		
					group by [Database], [Entidad], [Report_Type]
			) t
			where count_tech=case when db_name() like '%AVE%' then 1 --En AVEs solo nos aseguramos que este en una de las dos tecnologías
								  when db_name() like '%Road%' then 1 --En carreteras solo nos aseguramos que este en una de las dos tecnologías
								  when db_name() like '%Indoor%' then 1 --En POCs solo nos aseguramos que este en una de las dos tecnologías
								  else 2 end
		) calidad
		inner join
		(select [Database], [Entidad], [Report_Type]
			from(
					--Comprobamos que se agrega la cobertura
					select [Database], [Entidad], [Report_Type],count(distinct(tech)) as count_tech
					from
					(
						select [Database], [Entidad], [Report_Type],count(distinct(mnc)) as count_MNC, 'Cover' as tech
						from [vlcc_AGGRCoverage]
						where Meas_Round=@Meas_Round	
						group by [Database], [Entidad], [Report_Type]
					)cover
					group by [Database], [Entidad], [Report_Type]
				) t
		) cobertura
		on calidad.entidad=cobertura.entidad
		and calidad.report_type=cobertura.report_type
		group by  calidad.[Database],calidad.entidad,calidad.report_type
	end 

	--------------
	if db_name() like '%Data%3G%'
	begin
		insert into _aggr
		select [Database], [Entidad], [Report_Type] 
		from [vlcc_AGGRData3G]
		where Meas_Round=@Meas_Round		
		group by [Database], [Entidad], [Report_Type] 
	end 

	if db_name() like '%Data%4G%' or db_name() like '%Data_AVE%' or 
		db_name() like '%Data_Indoor%' or db_name() like '%Data_%Road_%' 

	--Nos aseguramos de que estén los cuatro operadores agregados, al igual que la voz para cerrar su contorno
	begin
		insert into _aggr
		select [Database], [Entidad], [Report_Type] 
		from (
			select * from 
				(
					select [Database], [Entidad], [Report_Type],count(distinct(mnc)) as count_MNC
					from [vlcc_AGGRData4G]
					where Meas_Round=@Meas_Round		
					group by [Database], [Entidad], [Report_Type]
				) data
			where count_MNC=4 ) aggr 
		order by [Database], [Entidad], [Report_Type] 
	end

	--------------
	if db_name() like '%VOLTE%' --Aqui tambien entrarán las BBDD del proyecto de Williams
	begin
		insert into _aggr
		select calidad.[Database], calidad.[Entidad], calidad.[Report_Type] 
		from 
			(select [Database], [Entidad], [Report_Type] 
			from [vlcc_AGGRVolte]
			where Meas_Round=@Meas_Round		
			group by [Database], [Entidad], [Report_Type] 
			) calidad
		inner join
			(select [Database], [Entidad], [Report_Type] 
			from [vlcc_AGGRCoverage]
			where Meas_Round=@Meas_Round		
			group by [Database], [Entidad], [Report_Type] 
			) cobertura
		on calidad.entidad=cobertura.entidad
		and calidad.report_type=cobertura.report_type
		group by  calidad.[Database],calidad.entidad,calidad.report_type
	end

	--------------
	--if db_name() like '%coverage%' 
	--begin
	--	insert into _aggr
	--	select [Database], [Entidad], [Report_Type] 
	--	from [vlcc_AGGRCoverage]
	--	where Meas_Round=@Meas_Round		
	--	group by [Database], [Entidad], [Report_Type] 
	--	order by [Database], [Entidad], [Report_Type] 
	--end
end

--select * from _aggr

---------------------------------------------------------
-- 1) Nos hacemos con los fileid que no estan actualizados en las tablas (ya nos da igual el orden):

---------------------------
--		1.a) Tenemos todo lo importado en filelist por fileid, que no este actualizado en las tablas
--------------	
exec sp_lcc_dropifexists '_newFileid'
select fileid into _newFileid from filelist 

--------------
--		1.b) Seleccionamos todos los fileid que se usaron en un primer momento -> columna fileidB (almacena fileid A y B) 

-- Cogemos todos los fileid (AyB) de las entidadas actualizadas en las tablas de Entity_List de la bbdd:
exec sp_lcc_dropifexists '_mun'
exec sp_lcc_dropifexists '_osp'
--exec sp_lcc_dropifexists '_vod'

select entity_name, fileidB into _mun from [dbo].[lcc_position_Entity_List_Municipio]
group by  entity_name, fileidB
order by  entity_name, fileidB

select entity_name, fileidB  into _osp from [dbo].[lcc_position_Entity_List_Orange]
group by  entity_name, fileidB
order by  entity_name, fileidB

--select entity_name, fileidB  into _vod from [dbo].[lcc_position_Entity_List_Vodafone]
--group by  entity_name, fileidB
--order by  entity_name, fileidB

-- Nos quedamos solo con los que esten en las 3 tablas (vamos acotando por lo menos, lo que ya esta en las 3, no hace falta recalcular)
-- Lo que sea correspondiente a una sola tabla (MUN por ejemplo) no se borrara y se volvera a calcular todo de nuevo, 
--		pero no se meteran duplicados en esa tabla ya q se revisara mas adelante esa condcion
exec sp_lcc_dropifexists '_entities'

select o.* 
into _entities
from _osp o	inner join 
	(
	 select m.* from _mun m 
		--inner join (select * from _vod) v on v.entity_name=m.entity_name and v.fileidB=m.fileidB
	 ) i on i.entity_name=o.entity_name and i.fileidB=o.fileidB
group by  o.entity_name, o.fileidB
order by  o.entity_name, o.fileidB


if (@fromErase in (0,2))
begin
	exec sp_lcc_dropifexists '_entFileid'		-- se quitan todos los fileids (AyB) que ya estuvieran en las tablas
	select fileidB as fileid into _entFileid from _entities

	--------------
	--		1.c) Se borran los fileid que ya estuvieran almacenados ->		
	--				¡OJO! se dejan los fileids de las ya agregadas, por si tuvieran info de otra entidad, 
	--					  mas adelante se indica que no se incluyan esos filed para las entidades agregadas
	delete _newFileid
	from _newFileid n, _entFileid e
	where n.fileid=e.fileid

end

--******************************************************************************
-- Esto ya no hace falta.
-- Al venir del erase, en cada tabla solo queda lo que esta agregado en ese report type
-- Los vamos a dejar para recalcular la info en esos fileid, por si tuvieran info de otras entidades.
-- Mas adelante se chequea que no metan duplicados

--if (@fromErase=1)
--begin
--	exec sp_lcc_dropifexists '_entFileid'		-- idem,  menos los fileid agregados por si tuvieran info de otra Entidad
--	select fileidB as fileid into _entFileid from lcc_position_Entity_List_Municipio
--	where entity_name not in (select entidad from _aggr where Report_Type='MUN') 
--	union 
--	select fileidB as fileid from lcc_position_Entity_List_Vodafone
--	where entity_name not in (select entidad from _aggr where Report_Type='VDF')
--	union  
--	select fileidB as fileid from lcc_position_Entity_List_Orange
--	where entity_name not in (select entidad from _aggr where Report_Type='OSP')
--end
--******************************************************************************



---------------------------------------------------------
-- 2) Se cogen todas las posiciones para los nuevos fileid a integrar:
---------------------------
exec sp_lcc_dropifexists '_position_LonLat'

if (select name from sys.all_objects where name='_position_LonLat' and type='U') is null
begin
	create table _position_LonLat (
		[fileid] [bigint] NULL,
		lonid [bigint] NULL,
		latid [bigint] NULL,
		Collectionname [varchar] (256) NULL,
		MeasDate [varchar] (256) NULL
	)
end
---------------------------
--	Se tiene en cuenta la tabla de Lcc_Entity_gps, por si ha habido alguna modificacion previa
if (select name from sys.all_objects where name='Lcc_Entity_gps' and type='U') is null
begin
	insert into _position_LonLat		
	select 
		p.fileid,
		master.dbo.fn_lcc_longitude2lonid (isnull(p.[Longitude],0), isnull(p.[Latitude],0)) as lonid,
		master.dbo.fn_lcc_latitude2latid (isnull(p.[Latitude],0)) as latid,
		f.collectionname,
		master.dbo.fn_lcc_GetElement (1,f.collectionname,'_') as MeasDate
	from position p, filelist f, _newFileid nf			-- asi es mas rapido
	where p.fileid=nf.fileid and p.fileid=f.fileid
	group by p.fileid, 
		master.dbo.fn_lcc_longitude2lonid (isnull(p.[Longitude],0), isnull(p.[Latitude],0)),
		master.dbo.fn_lcc_latitude2latid (isnull(p.[Latitude],0)), 
		f.collectionname

end

else
begin
	insert into _position_LonLat
	select 
		p.fileid,
		master.dbo.fn_lcc_longitude2lonid (isnull(p.[Longitude],0), isnull(p.[Latitude],0)) as lonid,
		master.dbo.fn_lcc_latitude2latid (isnull(p.[Latitude],0)) as latid,
		f.collectionname,
		master.dbo.fn_lcc_GetElement (1,f.collectionname,'_') as MeasDate
	from filelist f, 
		(
			select fileid, longitude, latitude
			from position
			where fileid in (select fileid from _newFileid)		-- asi es mas rapido

			union all

			select fileid, longitude, latitude
			from Lcc_Entity_gps
				--where fileid not in (select fileid from lcc_position_Entity_List_Vodafone group by fileid)
		) p
	where p.fileid=f.fileid
	group by p.fileid, 
		master.dbo.fn_lcc_longitude2lonid (isnull(p.[Longitude],0), isnull(p.[Latitude],0)),
		master.dbo.fn_lcc_latitude2latid (isnull(p.[Latitude],0)),
		f.collectionname

end

-- select * from _position_LonLat

---------------------------------------------------------
-- 3) Sacamos el Indice de valores ya incluidos para descartarlos en caso de duplicidades
---------------------------
-- Se cogen todos los fileids (A y B) para generar los indices, campo fileidB -> el el campo fileid se modificó para quedarnos solo con el del A
--		* Primero se introdcue la info ya almacenada, calculando la tupla correspondiente con fileidB (AyB) para evitar meter duplicados
--		* Segundo se mete la tupla nula de los nuevos valores, para que se pueda calcular la tupla de los fileids nuevos

----		3.a) VODAFONE:
--exec sp_lcc_dropifexists '_position_Vodafone'

--select  fileidB as fileid, cast(fileidB as Varchar) + ', ' + cast(lonid as Varchar) + ', ' + cast(latid as varchar) as tupla
--into _position_Vodafone
--from lcc_position_Entity_List_Vodafone 
--group by  fileidB, cast(fileidB as Varchar) + ', ' + cast(lonid as Varchar) + ', ' + cast(latid as varchar)

---- Hacen faltan los fileid (AyB) para poder comparar las tuplas nuevas
--	insert into _position_Vodafone
	
--	select p.fileid, cast(p.fileid as Varchar) + ', 0, 0'
--	from _position_LonLat p
	
--	group by p.fileid
--	order by p.fileid

---------------------------
--		3.b) ORANGE:
exec sp_lcc_dropifexists '_position_Orange'

select  fileidB as fileid, cast(fileidB as Varchar) + ', ' + cast(lonid as Varchar) + ', ' + cast(latid as varchar) as tupla
into _position_Orange
from lcc_position_Entity_List_Orange
group by  fileidB, cast(fileidB as Varchar) + ', ' + cast(lonid as Varchar) + ', ' + cast(latid as varchar)

-- Hacen faltan los fileid (AyB) para poder comparar las tuplas nuevas
	insert into _position_Orange

	select p.fileid, cast(p.fileid as Varchar) + ', 0, 0'
	from _position_LonLat p

	group by p.fileid
	order by p.fileid

---------------------------
--		3.c) MUNICIPIO:
exec sp_lcc_dropifexists '_position_Municipio'

-- Tenemos todo lo antiguo para comparar y no meter duplicados
select fileidB as fileid, cast(fileidB as Varchar) + ', ' + cast(lonid as Varchar) + ', ' + cast(latid as varchar) as tupla
into _position_Municipio
from lcc_position_Entity_List_Municipio
group by  fileidB, cast(fileidB as Varchar) + ', ' + cast(lonid as Varchar) + ', ' + cast(latid as varchar)

-- Hacen faltan los fileid (AyB) para poder comparar las tuplas nuevas
	insert into _position_Municipio

	select p.fileid, cast(p.fileid as Varchar) + ', 0, 0'
	from _position_LonLat p

	group by p.fileid
	order by p.fileid

 ---------------------------------------------------------
-- 4) Se rellenan las Entity_List correspondientes en funcion de las bbdd.
--	  Se asigna la ENTIDAD en funcion de los lonid/latid asi como el TIPO correspondiente
--		Las entidades ya agregadas no serán tenidas en cuenta:
--			- no se incluirá info nueva en entidades ya agregadas
---------------------------
--		4.a) INDOOR - POCs
--				Para INDOOR interesean las tablas de VOD y OSP	-> Type='Indoor'
--				No se tienen en cuenta ninguna GRID en especial
--				Se asigna la ENTIDAD segun el collectionname (POCs)
if db_name() like '%INDOOR%'								
begin
		---------
		---- VODAFONE:
		----insert into lcc_position_Entity_List_Vodafone
		--exec sp_lcc_dropifexists '_temp1'

		--Select e.*			-- a) se calculan las nuevas tuplas
		--into _temp1
		--from
		--(select p.*, master.dbo.fn_lcc_GetElement (4,p.collectionname,'_') as 'Entity_name', 'Indoor' as [Type],
		--		cast(p.fileid as Varchar) + ', ' + cast(p.lonid as Varchar) + ', ' + cast(p.latid as varchar) as tupla
		--from _position_LonLat p) e
		
		--delete _temp1		-- b) se eliminan las que ya tuvieramos guardadas
		--where tupla in (select distinct tupla from _position_Vodafone)

		-----------
		--exec sp_lcc_dropifexists '_temp'

		--Select e.fileid, e.lonid, e.latid, e.collectionname, e.MeasDate, e.Entity_name, e.[Type], e.fileid as fileidB
		--into _temp			-- c) se da forma a la tabla
		--from _temp1 e
		--group by e.fileid, e.lonid, e.latid, e.Entity_name, e.[Type], e.collectionname, e.MeasDate

		--delete _temp		-- d) se eliminan las que estuvieran agregadas
		--where Entity_name in (select entidad from _aggr where [Report_Type]='VDF')

		--insert into lcc_position_Entity_List_Vodafone		-- e) se guarda la nueva info calculada
		--select * from _temp

		---------
		-- ORANGE:
		--insert into lcc_position_Entity_List_Orange
		exec sp_lcc_dropifexists '_temp1'

		Select e.*	
		into _temp1
		from
		(select p.*, master.dbo.fn_lcc_GetElement (4,p.collectionname,'_') as 'Entity_name', 'Indoor' as [Type],
				cast(p.fileid as Varchar) + ', ' + cast(p.lonid as Varchar) + ', ' + cast(p.latid as varchar) as tupla
		from _position_LonLat p) e
		
		delete _temp1
		where tupla in (select distinct tupla from _position_Orange)

		---------
		exec sp_lcc_dropifexists '_temp'

		Select e.fileid, e.lonid, e.latid, e.collectionname, e.MeasDate, e.Entity_name, e.[Type], e.fileid as fileidB
		into _temp
		from _temp1 e
		group by e.fileid, e.lonid, e.latid, e.Entity_name, e.[Type], e.collectionname, e.MeasDate

		delete _temp
		where Entity_name in (select entidad from _aggr where [Report_Type]='OSP')

		insert into lcc_position_Entity_List_Orange
		select * from _temp

end

---------------------------
--		4.b) AVEs y CARRETERAS
--				Para AVES y CARRETERAS interesan VOD y OSP		-> Type='RW-Road'
--				AGRIDS_v2:	lcc_AGRIDS_Autovias_VF y lcc_AGRIDS_AVE_OSP
else if (db_name() like '%AVE%' or db_name() like '%Road%')		
begin
		-----------
		---- VODAFONE:
		----insert into lcc_position_Entity_List_Vodafone
		--exec sp_lcc_dropifexists '_temp1'

		--Select e.*			-- a) se calculan las nuevas tuplas
		--into _temp1
		--from
		--(select p.*, master.dbo.fn_lcc_GetElement (4,p.collectionname,'_') as 'Entity_name', 'RW-Road' as [Type],
		--	cast(p.fileid as Varchar) + ', ' + cast(p.lonid as Varchar) + ', ' + cast(p.latid as varchar) as tupla
		--from _position_LonLat p
		
		--union all 

		--select p.*, v.road_VF as 'Entity_name', 'Road' as [Type],
		--	cast(p.fileid as Varchar) + ', ' + cast(p.lonid as Varchar) + ', ' + cast(p.latid as varchar) as tupla
		--from AGRIDS_V2.dbo.lcc_AGRIDS_Autovias_VF v, _position_LonLat p
		--where
		--p.lonid=v.lonid and p.latid=v.latid
		
		--union all
		
		--select p.*, v.nombre as 'Entity_name', 'RW' as [Type],
		--cast(p.fileid as Varchar) + ', ' + cast(p.lonid as Varchar) + ', ' + cast(p.latid as varchar) as tupla
		--from AGRIDS_V2.dbo.lcc_AGRIDS_AVE_OSP v, _position_LonLat p
		--where
		--p.lonid=v.lonid and p.latid=v.latid
		--and v.nombre is not null
		
		--union all
		
		--select p.*, v.nombre + '-' + right(master.dbo.fn_lcc_GetElement (4,p.collectionname,'_'),2) as 'Entity_name', 'RW' as [Type],
		--cast(p.fileid as Varchar) + ', ' + cast(p.lonid as Varchar) + ', ' + cast(p.latid as varchar) as tupla
		--from AGRIDS_V2.dbo.lcc_AGRIDS_AVE_OSP v, _position_LonLat p, filelist f
		--where
		--	p.lonid=v.lonid and p.latid=v.latid
		--	and v.nombre is not null
		--	and f.fileid=p.fileid
		--) e

		--delete _temp1	-- b) se eliminan las que ya tuvieramos guardadas
		--where tupla in (select distinct tupla from _position_Vodafone)

		-----------
		--exec sp_lcc_dropifexists '_temp'

		--Select e.fileid, e.lonid, e.latid, e.collectionname, e.MeasDate, e.Entity_name, e.[Type], e.fileid as fileidB
		--into _temp		-- c) se da forma a la tabla
		--from _temp1 e
		--group by e.fileid, e.lonid, e.latid, e.Entity_name, e.[Type], e.collectionname, e.MeasDate
		

		--delete _temp	-- d) se eliminan las que estuvieran agregadas
		--where Entity_name in (select entidad from _aggr where [Report_Type]='VDF')

		--insert into lcc_position_Entity_List_Vodafone	-- e) se guarda la nueva info calculada
		--select * from _temp

		---------		
		-- ORANGE:
		--insert into lcc_position_Entity_List_Orange
		exec sp_lcc_dropifexists '_temp1'

		Select e.*		-- a) se calculan las nuevas tuplas
		into _temp1
		from	(
			select p.*, master.dbo.fn_lcc_GetElement (4,p.collectionname,'_')  as 'Entity_name', 'RW-Road' as [Type],
				cast(p.fileid as Varchar) + ', ' + cast(p.lonid as Varchar) + ', ' + cast(p.latid as varchar) as tupla
			from _position_LonLat p
		
			union all
		
			select p.*, v.road as 'Entity_name', 'Road' as [Type],
				cast(p.fileid as Varchar) + ', ' + cast(p.lonid as Varchar) + ', ' + cast(p.latid as varchar) as tupla
			from AGRIDS_V2.dbo.lcc_G2K5Absolute_INDEX_new v, _position_LonLat p
			where
				p.lonid=v.lonid and p.latid=v.latid
				and v.road is not null

			union all
		
			select p.*, v.nombre as 'Entity_name', 'RW' as [Type],
				cast(p.fileid as Varchar) + ', ' + cast(p.lonid as Varchar) + ', ' + cast(p.latid as varchar) as tupla
			from AGRIDS_V2.dbo.lcc_AGRIDS_AVE_OSP v, _position_LonLat p
			where
				p.lonid=v.lonid and p.latid=v.latid
				and v.nombre is not null
		
			union all
		
			select p.*, v.nombre + '-' + right(master.dbo.fn_lcc_GetElement (4,p.collectionname,'_'),2) as 'Entity_name', 'RW' as [Type],
				cast(p.fileid as Varchar) + ', ' + cast(p.lonid as Varchar) + ', ' + cast(p.latid as varchar) as tupla
			from AGRIDS_V2.dbo.lcc_AGRIDS_AVE_OSP v, _position_LonLat p, filelist f
			where
				p.lonid=v.lonid and p.latid=v.latid
				and v.nombre is not null
				and f.fileid=p.fileid
		) e

		delete _temp1	-- b) se eliminan las que ya tuvieramos guardadas
		where tupla in (select distinct tupla from _position_Orange)

		---------
		exec sp_lcc_dropifexists '_temp'

		Select e.fileid, e.lonid, e.latid, e.collectionname, e.MeasDate, e.Entity_name, e.[Type], e.fileid as fileidB
		into _temp		-- c) se da forma a la tabla
		from _temp1 e
		group by e.fileid, e.lonid, e.latid, e.Entity_name, e.[Type], e.collectionname, e.MeasDate
		
		delete _temp	-- d) se eliminan las que estuvieran agregadas
		where Entity_name in (select entidad from _aggr where [Report_Type]='OSP')

		insert into lcc_position_Entity_List_Orange	-- e) se guarda la nueva info calculada
		select * from _temp

end

---------------------------
--		4.c) Resto de BBDD:
--				Para el resto de bbdd interesan VOD y MUN		-> Type='Urban'
--				AGRIDS_v2:	lcc_G2K5Absolute_INDEX_new (MUN), lcc_AGRIDS_contornos_VF (VDF), lcc_AGRIDS_contornos_OSP (OSP)
else		
begin
		---------
		-- MUNICIPIO:
		--insert into lcc_position_Entity_List_Municipio
		exec sp_lcc_dropifexists '_temp1'
		
		Select e.*
		into _temp1
		from (
			 select p.*, v.municipio as 'Entity_name', 'Urban' as [Type],
						cast(p.fileid as Varchar) + ', ' + cast(p.lonid as Varchar) + ', ' + cast(p.latid as varchar) as tupla
			 from AGRIDS_V2.dbo.lcc_G2K5Absolute_INDEX_new v, _position_LonLat p
			 where p.lonid=v.lonid and p.latid=v.latid and v.municipio is not null
			 ) e
		
		delete _temp1
		where tupla in (select distinct tupla from _position_Municipio)

		---------
		exec sp_lcc_dropifexists '_temp'
		
		Select e.fileid, e.lonid, e.latid, e.collectionname, e.MeasDate, e.Entity_name, e.[Type], e.fileid as fileidB
		into _temp 
		from  _temp1 e
		group by e.fileid, e.lonid, e.latid, e.Entity_name, e.[Type], e.collectionname, e.MeasDate	

		delete _temp
		where Entity_name in (select entidad from _aggr where [Report_Type]='MUN')

		insert into lcc_position_Entity_List_Municipio
		select * from _temp

		-----------
		---- VODAFONE:
		----insert into lcc_position_Entity_List_Vodafone
		--exec sp_lcc_dropifexists '_temp1'

		--Select e.*		-- a) se calculan las nuevas tuplas
		--into _temp1
		--from (
		--	 select p.*, v.entity_name as 'Entity_name', 'Urban' as [Type],
		--			cast(p.fileid as Varchar) + ', ' + cast(p.lonid as Varchar) + ', ' + cast(p.latid as varchar) as tupla

		--	 from AGRIDS_V2.dbo.lcc_AGRIDS_contornos_VF v, _position_LonLat p

		--	 where p.lonid=v.lonid and p.latid=v.latid and v.entity_name is not null
		--	 ) e
	
		--delete _temp1	-- b) se eliminan las que ya tuvieramos guardadas
		--where tupla in (select distinct tupla from _position_Vodafone)

		-----------
		--exec sp_lcc_dropifexists '_temp'

		--Select e.fileid, e.lonid, e.latid, e.collectionname, e.MeasDate, e.Entity_name, e.[Type], e.fileid as fileidB
		--into _temp		-- c) se da forma a la tabla
		--from _temp1 e			
		--group by e.fileid, e.lonid, e.latid, e.Entity_name, e.[Type], e.collectionname, e.MeasDate	
		
		--delete _temp	-- d) se eliminan las que estuvieran agregadas
		--where Entity_name in (select entidad from _aggr where [Report_Type]='VDF')

		--insert into lcc_position_Entity_List_Vodafone	-- e) se guarda la nueva info calculada
		--select * from _temp

		---------
		-- ORANGE
		--insert into lcc_position_Entity_List_Orange
		exec sp_lcc_dropifexists '_temp1'

		Select e.*
		into _temp1
		from
		(select p.*, v.entity_name as 'Entity_name', 'Urban' as [Type],
				cast(p.fileid as Varchar) + ', ' + cast(p.lonid as Varchar) + ', ' + cast(p.latid as varchar) as tupla

		from AGRIDS_V2.dbo.lcc_AGRIDS_contornos_OSP v, _position_LonLat p

		where p.lonid=v.lonid and p.latid=v.latid and v.entity_name is not null
		) e

		delete _temp1
		where tupla in (select distinct tupla from _position_Orange)

		---------
		exec sp_lcc_dropifexists '_temp'

		Select e.fileid, e.lonid, e.latid, e.collectionname, e.MeasDate, e.Entity_name, e.[Type], e.fileid as fileidB
		into _temp
		from _temp1 e			
		group by e.fileid, e.lonid, e.latid, e.Entity_name, e.[Type], e.collectionname, e.MeasDate	
		
		delete _temp
		where Entity_name in (select entidad from _aggr where [Report_Type]='OSP')

		insert into lcc_position_Entity_List_Orange
		select * from _temp	
end

--select distinct fileid  from lcc_position_Entity_List_Municipio
--select * from lcc_position_Entity_List_Municipio
--select * from lcc_position_Entity_List_Vodafone
--select * from lcc_position_Entity_List_Orange

--*************************************		FIN PARTE A		********************************************
--******************************************************************************************************


--******************************************************************************************************
--****************** PARTE B para sacar el listado de las entidades para SETA **************************
--******************************************************************************************************
--	1) lcc_Coverage_City_List:
exec sp_lcc_dropifexists 'lcc_Coverage_City_List'
select c.[Entity_name] as [City_Name]
into lcc_Coverage_City_List
from (
		select entity_name, [type]
		from lcc_position_Entity_List_Municipio
		union all
		--select entity_name, [type]
		--from lcc_position_Entity_List_Vodafone
		--union all
		select entity_name, [type]
		from lcc_position_Entity_List_Orange
	) c
where c.[type] in ('Urban','Indoor')
group by c.[Entity_name]


-- 2) lcc_Coverage_Road_List
exec sp_lcc_dropifexists 'lcc_Coverage_Road_List'
select c.[Entity_name] as [Road]
into lcc_Coverage_Road_List
from (
		select entity_name, [type]
		from lcc_position_Entity_List_Municipio
		union all
		--select entity_name, [type]
		--from lcc_position_Entity_List_Vodafone
		--union all
		select entity_name, [type]
		from lcc_position_Entity_List_Orange
	) c
where c.[type] in ('Road', 'RW', 'RW-Road')
group by [Entity_name]


--*************************************		FIN PARTE B		********************************************
--******************************************************************************************************


--******************************************************************************************************
--*********** PARTE C - Actualizar el listado de sesiones del lado B (Issue Filelist) ******************
--******************************************************************************************************
if db_name() like '%Voice%'
begin
	---------------------------
	exec sp_lcc_dropifexists '_temp_file'
	--CAC 27/03/2017
	--select case when f.fileid in (select fileid from callanalysis group by fileid) then 1 else 2 end as id, *
	select case when f.Bfileid is not null then 1 else 2 end as id, --Parte A fileid id=1, Parte B fileid id=2
		*
	into _temp_file
	from filelist f

	where f.BsideFilename <> '-' and f.Bsidefilename is not null
		and f.fileid in (select fileid from _newFileid group by fileid)
	
	---------------------------
	exec sp_lcc_dropifexists '_Filelist_final'
	select t2.Fileid as FileidB, t1.* 

	into _Filelist_final
	from _temp_file t1, _temp_file t2

	where t1.id=t2.id-1
	and t1.Asidefilename=t2.Asidefilename
	and t1.Bsidefilename=t2.Bsidefilename

	--VDF
	--update lcc_position_Entity_List_Vodafone

	--set fileid= f.fileid, fileidb=f.fileidB

	--from lcc_position_Entity_List_Vodafone v, _Filelist_final f

	--where v.fileid=f.fileidB


	--OSP
	update lcc_position_Entity_List_Orange

	set fileid= f.fileid, fileidb=f.fileidB

	from lcc_position_Entity_List_Orange v, _Filelist_final f

	where v.fileid=f.fileidB

	--MUN
	update lcc_position_Entity_List_Municipio

	set fileid= f.fileid, fileidb=f.fileidB

	from lcc_position_Entity_List_Municipio v, _Filelist_final f

	where v.fileid=f.fileidB

	exec sp_lcc_dropifexists _temp_file
	exec sp_lcc_dropifexists _Filelist_final

end

--select distinct fileid  from lcc_position_Entity_List_Municipio
--select * from lcc_position_Entity_List_Municipio order by fileid
--select * from lcc_position_Entity_List_Vodafone order by fileid
--select * from lcc_position_Entity_List_Orange order by fileid


--*************************************		FIN PARTE C		********************************************
--******************************************************************************************************


----******************************************************************************************************
----****************** PARTE D - sacar el listado de sesiones/tests para CelfiNet ************************
----******************************************************************************************************
-----------------------------
---- Venimos del ERASE, por lo que se ha borrado la tabla entera.
---- Se vuelve a regenerar toda entera a partir de lo que tengamos en lcc_position_Entity_List_Vodafone;
--if (@fromErase=1)	
--begin
--	if db_name() like '%Voice%' and db_name() not like '%voice%indoor%' and db_name() not like '%voice%ave%'
--	begin
--		insert into lcc_CelfiNet_Sessions_List

--		select s.* from 
--		(select  lc.fileid,
--			lc.sessionid,
--			lc.collectionname

--			from lcc_calls_detailed lc, lcc_position_Entity_List_Vodafone p, lcc_position_Entity_List_Vodafone p2

--			where lc.fileid in (select fileid from lcc_position_Entity_List_Vodafone) and 

--				-- Forzamos a que ambos terminales se encuentren dentro del contorno para dar por valida la llamada:
--				(p.lonid = master.dbo.fn_lcc_longitude2lonid (lc.longitude_fin_A, lc.latitude_fin_A) 
--				and p.latid = master.dbo.fn_lcc_latitude2latid (lc.latitude_fin_A))
		
--				and 

--				(p2.lonid = master.dbo.fn_lcc_longitude2lonid (lc.longitude_fin_B, lc.latitude_fin_B) 
--				and p2.latid = master.dbo.fn_lcc_latitude2latid (lc.latitude_fin_B))
--		) s

--		group by s.fileid,s.sessionid, s.collectionname
--	end

--	---------------------------
--	if db_name() like '%voice%indoor%' or db_name() like '%voice%ave%'
--	begin
--		insert into lcc_CelfiNet_Sessions_List

--		select s.* from 
--		(select  lc.fileid,
--			lc.sessionid,
--			lc.collectionname

--			from lcc_calls_detailed lc, lcc_position_Entity_List_Vodafone p, lcc_position_Entity_List_Vodafone p2

--			where lc.fileid in (select fileid from lcc_position_Entity_List_Vodafone) 
--			and 

--				-- En INDOOR vale con que este uno de los terminales
--				(p.lonid = master.dbo.fn_lcc_longitude2lonid (lc.longitude_fin_A, lc.latitude_fin_A) 
--				and p.latid = master.dbo.fn_lcc_latitude2latid (lc.latitude_fin_A))
--		) s

--		group by s.fileid,s.sessionid, s.collectionname
--	end

--	---------------------------
--	if db_name() like '%Data%'
--	begin
--		insert into lcc_CelfiNet_Tests_List

--		select  d.fileid,
--				d.sessionid,
--				d.testid,
--				d.collectionname

--				from  lcc_position_Entity_List_Vodafone p,

--					(select fileid, sessionid, testid, collectionname, [longitud Final], [Latitud Final]
--							from lcc_data_httpTransfer_DL
--					union all
				
--					select fileid, sessionid, testid, collectionname, [longitud Final], [Latitud Final]
--							from lcc_data_httpTransfer_UL

--					union all
				
--					select fileid, sessionid, testid, collectionname, [longitud Final], [Latitud Final]
--							from lcc_data_httpBrowser

--					union all
				
--					select fileid, sessionid, testid, collectionname, [longitud Final], [Latitud Final]
--							from lcc_data_Youtube

--					union all
				
--					select fileid, sessionid, testid, collectionname, [longitud Final], [Latitud Final]
--							from lcc_data_Latencias
--					) d

--				where d.fileid  in (select fileid from lcc_position_Entity_List_Vodafone)
--				and p.lonid = [master].dbo.fn_lcc_longitude2lonid (d.[longitud Final], d.[Latitud Final]) 
--				and p.latid = [master].dbo.fn_lcc_latitude2latid (d.[Latitud Final]) 
--	end

--end

---------------------------
-- Venimos de la importacion normal o de la restauracion completa
-- Se añade la nueva info de fileids
--if (@fromErase<>1)	
--begin
--	if db_name() like '%Voice%' and db_name() not like '%voice%indoor%' and db_name() not like '%voice%ave%'
--	begin
--		insert into lcc_CelfiNet_Sessions_List

--		select s.* from 
--		(select  lc.fileid,
--			lc.sessionid,
--			lc.collectionname

--			from lcc_calls_detailed lc, lcc_position_Entity_List_Vodafone p, lcc_position_Entity_List_Vodafone p2

--			where lc.fileid in (select fileid from _newFileid) and 

--				-- Forzamos a que ambos terminales se encuentren dentro del contorno para dar por valida la llamada:
--				(p.lonid = master.dbo.fn_lcc_longitude2lonid (lc.longitude_fin_A, lc.latitude_fin_A) 
--				and p.latid = master.dbo.fn_lcc_latitude2latid (lc.latitude_fin_A))
		
--				and 

--				(p2.lonid = master.dbo.fn_lcc_longitude2lonid (lc.longitude_fin_B, lc.latitude_fin_B) 
--				and p2.latid = master.dbo.fn_lcc_latitude2latid (lc.latitude_fin_B))
--		) s

--		group by s.fileid,s.sessionid, s.collectionname
--	end

--	---------------------------
--	if db_name() like '%voice%indoor%' or db_name() like '%voice%ave%'
--	begin
--		insert into lcc_CelfiNet_Sessions_List

--		select s.* from 
--		(select  lc.fileid,
--			lc.sessionid,
--			lc.collectionname

--			from lcc_calls_detailed lc, lcc_position_Entity_List_Vodafone p, lcc_position_Entity_List_Vodafone p2

--			where lc.fileid in (select fileid from _newFileid) 
--			and 

--				-- Solo hay 1 terminal
--				(p.lonid = master.dbo.fn_lcc_longitude2lonid (lc.longitude_fin_A, lc.latitude_fin_A) 
--				and p.latid = master.dbo.fn_lcc_latitude2latid (lc.latitude_fin_A))
--		) s

--		group by s.fileid,s.sessionid, s.collectionname
--	end

--	---------------------------
--	if db_name() like '%Data%'
--	begin
--		insert into lcc_CelfiNet_Tests_List

--		select  d.fileid,
--				d.sessionid,
--				d.testid,
--				d.collectionname

--				from  lcc_position_Entity_List_Vodafone p,

--					(select fileid, sessionid, testid, collectionname, [longitud Final], [Latitud Final]
--							from lcc_data_httpTransfer_DL
--					union all
				
--					select fileid, sessionid, testid, collectionname, [longitud Final], [Latitud Final]
--							from lcc_data_httpTransfer_UL

--					union all
				
--					select fileid, sessionid, testid, collectionname, [longitud Final], [Latitud Final]
--							from lcc_data_httpBrowser

--					union all
				
--					select fileid, sessionid, testid, collectionname, [longitud Final], [Latitud Final]
--							from lcc_data_Youtube

--					union all
				
--					select fileid, sessionid, testid, collectionname, [longitud Final], [Latitud Final]
--							from lcc_data_Latencias
--					) d

--				where d.fileid  in (select fileid from _newFileid)
--				and p.lonid = [master].dbo.fn_lcc_longitude2lonid (d.[longitud Final], d.[Latitud Final]) 
--				and p.latid = [master].dbo.fn_lcc_latitude2latid (d.[Latitud Final]) 
--	end

--end

--*************************************		FIN PARTE D		********************************************
--******************************************************************************************************


--******************************************************************************************************
--************************ PARTE E - Final - borrado de tablas intermedias *****************************
--******************************************************************************************************

--Eliminamos las tablas temporales
exec sp_lcc_dropifexists _newFileid 
exec sp_lcc_dropifexists _entFileid
exec sp_lcc_dropifexists _position_LonLat
--exec sp_lcc_dropifexists _position_Vodafone 
exec sp_lcc_dropifexists _position_Orange 
exec sp_lcc_dropifexists _position_Municipio 
exec sp_lcc_dropifexists _temp1
exec sp_lcc_dropifexists _temp
exec sp_lcc_dropifexists _temp_file
exec sp_lcc_dropifexists  _Filelist_final
exec sp_lcc_dropifexists  _aggr
exec sp_lcc_dropifexists  _entities
exec sp_lcc_dropifexists  _mun
exec sp_lcc_dropifexists  _osp
--exec sp_lcc_dropifexists  _vod

