use DASHBOARD
DECLARE @pattern varchar(256) = 'FY1718%DATA%MADRID%4G%'
declare @db as varchar(256)
declare @id2 as int=1
declare @id1 as int=1




declare @ruta_entidades as varchar (4000)='F:\VDF_Invalidate\columnas.xlsx'

-- Importamos el excel que contiene el nombre de todas las ciudades a agregar

exec sp_lcc_dropifexists '_columnas_agregar'
exec sp_lcc_dropifexists '_columnas_quitar'

-- Cogemos la informacion de la entidad del Excel en red
exec  [dbo].[sp_importExcelFileAsText] @ruta_entidades, 'Anadir_DL','_columnas_agregar'
exec  [dbo].[sp_importExcelFileAsText] @ruta_entidades, 'Quitar_DL','_columnas_quitar'

exec sp_lcc_dropifexists '#it1'
select identity(int,1,1) id,*
into #it1
from [dbo]._columnas_quitar

exec sp_lcc_dropifexists '#it2'
select identity(int,1,1) id,*
into #it2
from [dbo]._columnas_agregar
----

exec sp_lcc_dropifexists '#bbdd'
select identity(int,1,1) id, name 
into #bbdd 
from sys.databases  
where name like  @pattern
select * from #bbdd

while @id1<=(select max(id) from #bbdd)
begin
	set @db=(select name from #bbdd where id=@id1)
	print @db


	--Anadir columnas
	while @id2<=(select max(id) from #it1)
	begin
		
		declare @campo as varchar (256) = (select [Campo] from #it1 where id=@id2)
		declare @tipo as varchar (256)= (select [Tipo] from #it1 where id=@id2)
		declare @tamano as varchar (256)= (select [Tamano] from #it1 where id=@id2)
		declare @NULL as varchar (256)= (select [NOT] from #it1 where id=@id2)
		


		print('alter table ' + @db +'.dbo.Lcc_Data_HTTPTransfer_DL ADD ' + @campo +' ' + @tipo +' ' + @tamano +' ' + @NULL +'')
	

	set @id2=@id2+1
	end 

	set @id2=1
	while @id2<=(select max(id) from #it2)
	begin
		
		declare @campoquitar as varchar (256) = (select [Campo] from #it2 where id=@id2)
		


		print('alter table ' + @db +'.dbo.Lcc_Data_HTTPTransfer_DL DROP COLUMN ' + @campo +'')
	

	set @id2=@id2+1
	end 

	set @id1=@id1+1

end