USE FY1718_VOICE_REST_4G_H1_44
--exec sp_MDD_Voice_Libro_Voz_TLT_All_FY1617_GRID		'JEREZ',	1,			'M2M',	'', '4G',	'%%','0',	'VDF'

----	Nuevas Variables de entrada:
declare @ciudad as varchar(256) = 'ROQUETAS'
declare @type as varchar(256) = 'M2M'
declare @Environ as varchar(256) = '%%'
declare @EntityList as varchar(256) = 'VDF' 
declare @ReportType as varchar(256) = 'CSFB'


-------------------------------------------------------------------------------
--	Tipo de reporte:
-------------------------------------------------------------------------------
-- Establecemos el tipo de Reporte -  el 6ª elemento del collectionname debe coincidir con:
--		* Reporte '3G'		- antiguo 3G, deja de medirse VOZ 3G en FY1718	- collectionname acaba en _3G	
--		* Reporte '4G'		- antiguo 4G, se convierte en 'CSFB'			- collectionname acaba en _4G
--		* Reporte 'CSFB'	- nuevo en FY1718, igual al '4G'antiguo			- collectionname acaba en _4G		
--		* Reporte 'VOLTE'	- reportes antiguos acaban en _4G				- collectionname acaba en _4G	- bbdd de VOLTE
--							  reportes nuevos acaban en _VOLTE		

-- Para entidades antiguas, la diferencia será en la bbdd en la que se lance
if @ReportType='CSFB'  set @ReportType='4G'
-- En las bases de datos de VOLTE antiguas el collectionname no contiene la palabra "VOLTE" si no "4G"
-- 20170919: @MDM: quitamos de este filtro las bases de datos Williams
if db_name() like '%VOLTE%' and db_name() not like '%WILL%' set @ReportType='4G'


declare @Meas_Round as varchar(256)

if (charindex('AVE',db_name())>0 and charindex('Rest',db_name())=0)
	begin 
		set @Meas_Round= [master].dbo.fn_lcc_getElement(1, db_name(),'_') + '_' + [master].dbo.fn_lcc_getElement(6, db_name(),'_')
	end

else

	begin
		set @Meas_Round= [master].dbo.fn_lcc_getElement(1, db_name(),'_') + '_' + [master].dbo.fn_lcc_getElement(5, db_name(),'_')
	end

-------------------------------------------------------------------------------
--	Tabla con todas las sesiones:
-------------------------------------------------------------------------------
-- drop table #all_Tests
create table #All_Tests (
	[SessionId] bigint
)

-------------------------------------------------------------------------------
--	Seleccion de la Entity_List:
-------------------------------------------------------------------------------		  
If @EntityList='VDF'
begin
insert into #All_Tests
select v.sessionid
from lcc_Calls_Detailed v, Sessions s, lcc_position_Entity_List_Vodafone c, lcc_position_Entity_List_Vodafone c2
Where --v.collectionname like @Date + '%' + @ciudad + '%' + @TechF
	v.sessionid=s.sessionid
	and s.valid=1
	and v.MCC= 214						--MCC - Descartamos los valores erróneos	
	and v.calltype = @type
	and c.fileid=v.fileid
	and (
			(@type='M2M' and c.entity_name = @Ciudad and c2.entity_name = @Ciudad)

			or

			(@type='M2F' and c.entity_name = @Ciudad)

		)
	and c.fileid=c2.fileid
	and 
	(
		(@type='M2M' and (c.lonid=master.dbo.fn_lcc_longitude2lonid ([Longitude_Fin_A], [Latitude_Fin_A])
		and c.latid=master.dbo.fn_lcc_latitude2latid ([Latitude_Fin_A]))
				and
		(c2.lonid=master.dbo.fn_lcc_longitude2lonid ([Longitude_Fin_B], [Latitude_Fin_B])
		and c2.latid=master.dbo.fn_lcc_latitude2latid ([Latitude_Fin_B]))
		)
			or
		(@type='M2F' and c.lonid=master.dbo.fn_lcc_longitude2lonid ([Longitude_Fin_A], [Latitude_Fin_A])
		and c.latid=master.dbo.fn_lcc_latitude2latid ([Latitude_Fin_A])
		)
	)
	and v.collectionname like '%'+@ReportType+'%' 

group by v.sessionid
END

SELECT * FROM #All_Tests