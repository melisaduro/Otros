--USE [master]
--GO
--/****** Object:  StoredProcedure [dbo].[sp_lcc_create_Entity_position_List_aggr]    Script Date: 04/01/2018 12:26:55 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

--ALTER procedure [dbo].[sp_lcc_create_Entity_position_List_aggr] @fromErase int=0, @client int=3
--as


--**************************************************************************************************************

--declare @fromErase as int=0	-- procedimiento normal tras la importacion
--declare @fromErase as int=1	-- procedimiento puntual tras el erase --> tarda bastante mas, xq recalcula todo again
								--		-> hay que dejar las entidades ya agregadas y revisar que sus fileids no tenga info de otras entidades 
--declare @fromErase as int=2	-- no se tiene en cuenta el listado de agregado

declare @client as int = 1 --Tipo de cliente (Vodafone=1,Orange=3)
declare @tabla_grid as varchar(256)= 'AGRIDS_V2.dbo.[lcc_Athens_grid_50]'  --Tabla grid

--drop table lcc_position_Entity_List_Municipio
--drop table lcc_position_Entity_List_Vodafone
--drop table lcc_position_Entity_List_Orange
--drop table lcc_CelfiNet_Sessions_List

declare @table as varchar(256)
declare @cmd as nvarchar(500)


if @client=1
begin
	set @table='lcc_position_Entity_List'
end

 print @table
---------------------------
-- Si no existen, se crean las las tablas necesarias:

set @cmd='if (select name from sys.all_objects where name='''+@table+''' and type=''U'') is null
begin
create table '+@table+'(
	[fileid] [bigint] NULL,
	lonid [bigint] NULL,
	latid [bigint] NULL,
	Collectionname [varchar] (256) NULL,
	MeasDate [varchar] (256) NULL,
	[Entity_name] [varchar] (256) NULL,
	[Type] [varchar] (256) NULL,
	[fileidB] [bigint] NULL
)
end'

exec (@cmd)

---------------------------------------------------------
-- 1) Nos hacemos con los fileid que no estan actualizados en las tablas (ya nos da igual el orden):

---------------------------
--		1.a) Tenemos todo lo importado en filelist por fileid, que no este actualizado en las tablas
--------------	
exec sp_lcc_dropifexists '_newFileid'
select fileid into _newFileid from filelist 

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


exec sp_lcc_dropifexists '_position_tabla'

-- Tenemos todo lo antiguo para comparar y no meter duplicados

set @cmd=('
	select fileidB as fileid, cast(fileidB as Varchar) + '','' + cast(lonid as Varchar) + '','' + cast(latid as varchar) as tupla
	into _position_tabla
	from '+@table+'
	group by  fileidB, cast(fileidB as Varchar) + '','' + cast(lonid as Varchar) + '','' + cast(latid as varchar)')

	exec (@cmd)

-- Hacen faltan los fileid (AyB) para poder comparar las tuplas nuevas
	
	insert into _position_tabla

	select p.fileid, cast(p.fileid as Varchar) + ', 0, 0'
	from _position_LonLat p

	group by p.fileid
	order by p.fileid

 		
begin
		---------
		--insert into lcc_position_Entity_List
		exec sp_lcc_dropifexists '_temp1'
		
		set @cmd=('Select e.*
			into _temp1
			from (
				 select p.*, v.entity as ''Entity_name'', ''Urban'' as [Type],
							cast(p.fileid as Varchar) + '', '' + cast(p.lonid as Varchar) + '', '' + cast(p.latid as varchar) as tupla
				 from '+@tabla_grid+' v, _position_LonLat p
				 where p.lonid=v.lonid and p.latid=v.latid and v.entity is not null
				 ) e
		

		')
		exec(@cmd)

		delete _temp1
		where tupla in (select distinct tupla from _position_tabla)
			---------
		exec sp_lcc_dropifexists '_temp'
		
		Select e.fileid, e.lonid, e.latid, e.collectionname, e.MeasDate, e.Entity_name, e.[Type], e.fileid as fileidB
		into _temp 
		from  _temp1 e
		group by e.fileid, e.lonid, e.latid, e.Entity_name, e.[Type], e.collectionname, e.MeasDate	


		set @cmd=('
			insert into '+@table+'
			select * from _temp')

		exec (@cmd)

end


--*************************************		FIN PARTE A		********************************************
--******************************************************************************************************


--******************************************************************************************************
--****************** PARTE B para sacar el listado de las entidades para SETA **************************
--******************************************************************************************************
--	1) lcc_Coverage_City_List:
exec sp_lcc_dropifexists 'lcc_Coverage_City_List'
set @cmd=('
	select c.[Entity_name] as [City_Name]
	into lcc_Coverage_City_List
	from (
			select entity_name, [type]
			from '+@table+'
		) c
	where c.[type] in (''Urban'',''Indoor'')
	group by c.[Entity_name]')

exec (@cmd)

-- 2) lcc_Coverage_Road_List
exec sp_lcc_dropifexists 'lcc_Coverage_Road_List'
set @cmd=('
	select c.[Entity_name] as [Road]
	into lcc_Coverage_Road_List
	from (
			select entity_name, [type]
			from '+@table+'
		) c
	where c.[type] in (''Road'', ''RW'', ''RW-Road'')
	group by [Entity_name]')

exec (@cmd)


--*************************************		FIN PARTE B		********************************************
--******************************************************************************************************


--******************************************************************************************************
--*********** PARTE C - Actualizar el listado de sesiones del lado B (Issue Filelist) ******************
--******************************************************************************************************

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

	--UPDATE

	set @cmd=('
	update '+@table+'

	set fileid= f.fileid, fileidb=f.fileidB

	from '+@table+' v, _Filelist_final f

	where v.fileid=f.fileidB')

	exec (@cmd)



	exec sp_lcc_dropifexists _temp_file
	exec sp_lcc_dropifexists _Filelist_final

end


--******************************************************************************************************
--************************ PARTE E - Final - borrado de tablas intermedias *****************************
--******************************************************************************************************

------Eliminamos las tablas temporales
--exec sp_lcc_dropifexists _newFileid 
--exec sp_lcc_dropifexists _entFileid
--exec sp_lcc_dropifexists _position_LonLat
--exec sp_lcc_dropifexists _position_tabla 
----exec sp_lcc_dropifexists _position_Vodafone 
----exec sp_lcc_dropifexists _position_Orange 
----exec sp_lcc_dropifexists _position_Municipio 
--exec sp_lcc_dropifexists _temp1
--exec sp_lcc_dropifexists _temp
--exec sp_lcc_dropifexists _temp_file
--exec sp_lcc_dropifexists  _Filelist_final
--exec sp_lcc_dropifexists  _aggr
--exec sp_lcc_dropifexists  _entities
--exec sp_lcc_dropifexists _entities_fileid
----exec sp_lcc_dropifexists  _mun
----exec sp_lcc_dropifexists  _osp
----exec sp_lcc_dropifexists  _vod

