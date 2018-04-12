declare @cmd nvarchar(4000)				
DECLARE @nameTabla varchar(256)			
DECLARE @entidad varchar(256) = 'MERIDA'						
DECLARE @pattern varchar(256) = '%AGGRVoice%4G'		
				
				
DECLARE @nameBD varchar(256)				
declare @it2 bigint				
declare @MaxBBDD bigint				
declare @it1 bigint				
declare @MaxTab bigint				
				
set @it1 = 1				
set @it2 = 1				
				
exec sp_lcc_dropifexists '_tmp_BBDD'				
				
select IDENTITY(int,1,1) id,name				
into _tmp_BBDD				
from sys.databases				
where name like  @pattern	
	and name not like '%_old'
	
	
		
				
select @MaxBBDD = MAX(id) 				
from _tmp_BBDD				
				
while @it2 <= @MaxBBDD 				
begin				
				
	select @nameBD = name			
	from _tmp_BBDD			
	where id =@it2			
	print 'Nombre de la bbdd:  ' + @nameBD			
				
	exec sp_lcc_dropifexists '_tmp_Tablas'			
	--declare @pattern as varchar (256) = 'ogrove'			
	set @cmd = 'select IDENTITY(int,1,1) id,name			
	into _tmp_Tablas			
	from ['+@nameBD +'].sys.tables			
	where name like ''%lcc_aggr%''
	and name not like ''lcc_aggr_%backup%''	 
	and name not like ''lcc_aggr_%old%''
	and name not like ''lcc_aggr_%2017%''
	and name not like ''lcc_aggr_%2016%''
	and name not like ''%_3G''
	and name not like ''%_4G''
	and type=''U'''		
	print @cmd			
	exec (@cmd)	
	
	select * from _tmp_Tablas	
				
	select @MaxTab = MAX(id) 			
	from _tmp_Tablas			
				
	set @it1 = 1			
				
	while @it1 <= @MaxTab			
	begin			
				
		select @nameTabla = name		
		from _tmp_Tablas		
		where id =@it1		
		print 'Nombre de la tabla:  ' + @nameTabla		

		--set @cmd = 'select c.[Region_VF] from '+@nameBD +'.dbo.'+ @nameTabla +' c, Agrids.dbo.lcc_parcelas p where p.Nombre=c.parcel and (c.Region_VF is null or c.Region_OSP is null) and (c.[database] not like ''%Indoor%'' and c.[database] not like ''%AVE%'')'	
			
				
		set @cmd = 'select entidad,meas_Date,meas_week,date_reporting,week_reporting,report_type,meas_round,count(distinct(mnc)) as MNC
				from '+@nameBD +'.dbo.'+ @nameTabla +'
				where entidad= '''+@entidad+'''
				and meas_round like ''%1718%''
				group by entidad,meas_Date,meas_week,date_reporting,week_reporting,report_type,meas_round
				order by 2
			'
		
		--set @cmd='select * into '+@nameBD +'.dbo.'+ @nameTabla +'_backup_ALL from '+@nameBD +'.dbo.'+ @nameTabla
				
		print @cmd		
		exec (@cmd)
				
		set @it1 = @it1 +1		
	end			
				
	set @it2 = @it2 +1			
end				
				
				
exec sp_lcc_dropifexists '_tmp_BBDD'				
exec sp_lcc_dropifexists '_tmp_Tablas'



declare @entidad as varchar (256)='CALAHORRA'


select entidad,meas_Date,meas_week,date_reporting,week_reporting,report_type,meas_round,count(distinct(mnc)) as MNC
from [AGGRVoice4G].dbo.lcc_aggr_sp_MDD_Voice_Llamadas
where entidad = @entidad
and meas_round like '%1718%'
group by entidad,meas_Date,meas_week,date_reporting,week_reporting,report_type,meas_round
order by 2

select entidad,meas_Date,meas_week,date_reporting,week_reporting,report_type,meas_round,count(distinct(mnc)) as MNC
from [AGGRVOLTE].dbo.lcc_aggr_sp_MDD_Voice_Llamadas
where entidad= @entidad
and meas_round like '%1718%'
group by entidad,meas_Date,meas_week,date_reporting,week_reporting,report_type,meas_round
order by 2

select entidad,meas_Date,meas_week,date_reporting,week_reporting,report_type,meas_round,count(distinct(mnc)) as MNC
from [AGGRData3G].dbo.lcc_aggr_sp_MDD_Data_DL_Thput_CE
where entidad= @entidad
and meas_round like '%1718%'
group by entidad,meas_Date,meas_week,date_reporting,week_reporting,report_type,meas_round
order by 2

select entidad,meas_Date,meas_week,date_reporting,week_reporting,report_type,meas_round,count(distinct(mnc)) as MNC
from [AGGRData4G].dbo.lcc_aggr_sp_MDD_Data_Youtube_HD
where entidad= @entidad
and meas_round like '%1718%'
group by entidad,meas_Date,meas_week,date_reporting,week_reporting,report_type,meas_round
order by 2

select entidad,meas_Date,meas_week,date_reporting,week_reporting,report_type,meas_round,count(distinct(mnc)) as MNC
from [AGGRCoverage].DBO.lcc_aggr_sp_MDD_Coverage_All_Indoor a
where a.entidad=@entidad
and meas_round like '%1718%'
group by entidad,meas_Date,meas_week,date_reporting,week_reporting,report_type,meas_round
order by 2				
