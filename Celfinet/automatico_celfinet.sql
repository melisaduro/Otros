


-- **********************************************************************************************************
--	Comprobamos que haya BBDD sobre las que trabajar, es decir, BBDD con tablas de lcc%
-- **********************************************************************************************************

	select name, row_number()over( order by name) as id
	into _ddbb
	from sys.databases
	where name like '[FY1617_Voice_Smaller_VOLTE_H2_2]%'


	create table _bbdd_eliminar
	(
	DDBB varchar(256),
	Limpiar varchar (30)
	)


	declare @id as integer = 1
	declare @ddbb as varchar(256)

	while @id < (select max(id) from _ddbb)
	begin

			set @ddbb = (select name from _ddbb where id=@id)

			--Recorremos dinámicamente todas las BBDD para saber en cuales hay tablas de lcc% y por lo tanto hay que limpiar.

			insert into _bbdd_eliminar
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

	select * from _bbdd_eliminar where limpiar='Si' /* Este se puede quitar una vez se compruebe la funcionalidad del codigo*/

	insert into _bbdd_limpiar
	select * from _bbdd_eliminar where limpiar='Si'



-- **********************************************************************************************************
--	Una vez tenemos localizadas las BBDD sobre las que vamos a trabajar, se procede a la invalidacion
--	de las sesiones y test fuera de los contornos definidos por VDF.
-- **********************************************************************************************************


if (select count(*) from _bbdd_limpiar)>=1

begin

		declare @id as integer = 1
		declare @ddbb as varchar(256)

		while @id < (select max(id) from _ddbb)
		begin

			set @ddbb = (select name from _ddbb where id=@id)

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
			--	En ultimo lugar, realizamos la limpieza de tablas, procedimientos y vistas en la BBDD sobre la que hemos trabajado
			-- *******************************************************************************************************************

			exec ('
				exec ['+@ddbb+'].[dbo].[sp_lcc_delete_lccInfo_danger]
			')



			set @id = @id + 1

		end


end


drop table _ddbb, _bbdd_eliminar, _bbdd_limpiar