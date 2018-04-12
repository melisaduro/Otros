USE [master]

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[sp_lcc_cleaner]
as

-- Para hacer el procedimiento de sistema:
--exec sys.sp_MS_marksystemobject 'sp_lcc_cleaner'


if (SELECT @@SERVERNAME)='SREPSQLBMVF'
begin

-- **********************************************************************************************************
--	Comprobamos que haya BBDD sobre las que trabajar, es decir, BBDD con tablas de lcc%
-- **********************************************************************************************************

	select name, row_number()over( order by name) as id
	into #ddbb
	from sys.databases
	where name like 'FY1617%'


	create table #bbdd_eliminar
	(
	DDBB varchar(256),
	Limpiar varchar (30)
	)

	create table #bbdd_limpiar
	(
	DDBB varchar(256),
	Limpiar varchar (30),
	id int
	)


	declare @id as integer = 1
	declare @ddbb as varchar(256)

	while @id <= (select max(id) from #ddbb)
	begin

			set @ddbb = (select name from #ddbb where id=@id)

			--Recorremos dinámicamente todas las BBDD para saber en cuales hay tablas de lcc% y por lo tanto hay que limpiar.

			insert into #bbdd_eliminar
			exec ('select 
						''' + @DDBB + ''' as DDBB, 
						case
							when count (1) > 1 then ''Si''
							else ''No'' 
						end as ''Limpiar''

				  from ' + @DDBB + '.sys.tables
				  where name like ''%lcc%''

			')

			set @id = @id + 1

	end

	select * from #bbdd_eliminar where limpiar='Si' /* Este se puede quitar una vez se compruebe la funcionalidad del codigo*/

	insert into #bbdd_limpiar
	select *,row_number()over( order by DDBB) as id from #bbdd_eliminar where limpiar='Si'



-- **********************************************************************************************************
--	Una vez tenemos localizadas las BBDD sobre las que vamos a trabajar, se procede a la invalidacion
--	de las sesiones y test fuera de los contornos definidos por VDF. Para ello, deshabilitamos previamente los
--  permisos a los usuarios Celfinet en caso de que estén dados y los habilitamos de nuevo una vez hayamos 
--  realizado todas las invalidaciones
-- **********************************************************************************************************


if (select count(*) from #bbdd_limpiar)>=1

begin

		set @id = 1

		while @id <= (select max(id) from #bbdd_limpiar)
		begin

			set @ddbb = (select DDBB from #bbdd_limpiar where id=@id)

			-- *******************************************************************************************************************
			-- Quitamos permisos a los usuarios Celfinet
			-- *******************************************************************************************************************

			begin
				exec ('
					use '+@ddbb+'
					if (select name from sys.sysusers where name = ''[SREPSQLBMVF\celfinet1]'')
					begin
						DROP USER [SREPSQLBMVF\celfinet1]
					end
					if (select name from sys.sysusers where name = ''[SREPSQLBMVF\celfinet2]'')
					begin
						DROP USER [SREPSQLBMVF\celfinet2]
					end
					if (select name from sys.sysusers where name = ''SREPSQLBMVF\VFCEL'')
					begin
						DROP USER [SREPSQLBMVF\VFCEL]
					end
					if (select name from sys.sysusers where name = ''SREPSQLBMVF\VFCEL2'')
					begin
						DROP USER [SREPSQLBMVF\VFCEL2]
					end
					')
			end

			-- Invalidamos sessionid de VOZ fuera de contorno VDF

			if @ddbb like '%Voice%' or @ddbb like '%VOLTE%'
			begin
					exec ('	
							use '+@ddbb+'
							update sessions
							set valid = 0, InvalidReason = ''LCC OutOfBounds - ORA''
							where valid = 1
							and  sessionid in 
							(
								select s.sessionid
								from filelist f, sessions s
								left outer join LCC_Celfinet_Sessions_List c on c.sessionid = s.sessionid
								where s.valid = 1 and c.sessionid is null
								and s.fileid = f.fileid
								and s.sessiontype=''call''
							)

					')
			end


			-- Invalidamos testid de DATOS fuera de contorno VDF

			if @ddbb like '%DATA%'
			begin
					exec ('	
							use '+@ddbb+'
							update TestInfo
							set valid = 0, InvalidReason = ''LCC OutOfBounds - ORA''
							where valid = 1
							and  testid in 
							(	select t.testid
								from filelist f, sessions s,testinfo t
								left outer join lcc_CelfiNet_Tests_List c on c.testid = t.testid
								where t.valid = 1 and c.testid is null
								and s.fileid = f.fileid
								and s.sessionid = t.sessionid
								and s.sessiontype=''data''
							)

					')
			end

			-- *******************************************************************************************************************
			-- Realizamos la limpieza de tablas, procedimientos y vistas en la BBDD sobre la que hemos trabajado
			-- *******************************************************************************************************************

			exec ('
				exec ['+@ddbb+'].[dbo].[sp_lcc_delete_lccInfo_danger]
			')

			-- *******************************************************************************************************************
			-- Volvemos a dar permisos a los usuarios Celfinet
			-- *******************************************************************************************************************

			begin 
				exec('
					use '+@ddbb+'

					CREATE USER [SREPSQLBMVF\celfinet1]
					alter user [SREPSQLBMVF\celfinet1] WITH DEFAULT_SCHEMA= dbo
					exec sp_addrolemember ''db_datareader'', ''SREPSQLBMVF\celfinet1''
					exec sp_addrolemember ''db_datawriter'', ''SREPSQLBMVF\celfinet1''

					CREATE USER [SREPSQLBMVF\celfinet2]
					alter user [SREPSQLBMVF\celfinet2] WITH DEFAULT_SCHEMA= dbo
					exec sp_addrolemember ''db_datareader'', ''SREPSQLBMVF\celfinet2''
					exec sp_addrolemember ''db_datawriter'', ''SREPSQLBMVF\celfinet2''

					CREATE USER [SREPSQLBMVF\VFCEL]
					alter user [SREPSQLBMVF\VFCEL] WITH DEFAULT_SCHEMA= dbo
					exec sp_addrolemember ''db_datareader'', ''SREPSQLBMVF\VFCEL''
					exec sp_addrolemember ''db_datawriter'', ''SREPSQLBMVF\VFCEL''

					CREATE USER [SREPSQLBMVF\VFCEL2]
					alter user [SREPSQLBMVF\VFCEL2] WITH DEFAULT_SCHEMA= dbo
					exec sp_addrolemember ''db_datareader'', ''SREPSQLBMVF\VFCEL2''
					exec sp_addrolemember ''db_datawriter'', ''SREPSQLBMVF\VFCEL2''

				')
			end

			set @id = @id + 1

		end


end


drop table #ddbb, #bbdd_eliminar, #bbdd_limpiar

end
else 
select 'ALERT! You can not run this procedure on this server'