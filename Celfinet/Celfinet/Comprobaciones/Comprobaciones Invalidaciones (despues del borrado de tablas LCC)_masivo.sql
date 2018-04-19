--select 
--	case
--		when count (1) > 1 then 'Si'
--		else 'No' end as 'Limpiar',
--	case 
--		when count (1) > 1 then count (1)
--		else '' end as contador
--from FY1617_Data_Rest_3G_H2_4.sys.tables
--where name like '%lcc%'


select name, row_number()over( order by name) as id
into _ddbb
from sys.databases
where name in ('FY1718_Data_ALBACETE_4G_H1','FY1718_DATA_ALICANTE_4G_H1','FY1718_DATA_AVE_MAD_SEV_H1','FY1718_DATA_AVE_MAD_VLC_H1','FY1718_DATA_CARTAGENA_4G_H1','FY1718_DATA_CASTELLON_4G_H1','FY1718_DATA_ELCHE_4G_H1','FY1718_DATA_GRANADA_4G_H1','FY1718_DATA_LOGRONO_4G_H1','FY1718_Data_MRoad_A1_H1','FY1718_Data_MRoad_A6_H1','FY1718_DATA_MURCIA_4G_H1','FY1718_DATA_PAMPLONA_4G_H1','FY1718_DATA_REST_4G_H1_12','FY1718_DATA_REST_4G_H1_13','FY1718_DATA_REST_4G_H1_14','FY1718_DATA_REST_4G_H1_15','FY1718_DATA_REST_4G_H1_22','FY1718_DATA_REST_4G_H1_23','FY1718_DATA_REST_4G_H1_27','FY1718_DATA_REST_4G_H1_29','FY1718_DATA_REST_4G_H1_31','FY1718_DATA_REST_4G_H1_34','FY1718_DATA_REST_4G_H1_36','FY1718_DATA_REST_4G_H1_38','FY1718_DATA_REST_4G_H1_39','FY1718_DATA_REST_4G_H1_44','FY1718_DATA_REST_4G_H1_52','FY1718_DATA_REST_4G_H1_53','FY1718_DATA_REST_4G_H1_55','FY1718_Voice_ALBACETE_4G_H1','FY1718_VOICE_ALICANTE_4G_H1','FY1718_VOICE_AVE_MAD_SEV_H1','FY1718_VOICE_AVE_MAD_VLC_H1','FY1718_VOICE_BURGOS_4G_H1','FY1718_VOICE_CARTAGENA_4G_H1','FY1718_Voice_CASTELLON_4G_H1','FY1718_VOICE_ELCHE_4G_H1','FY1718_VOICE_GRANADA_4G_H1','FY1718_VOICE_LOGRONO_4G_H1','FY1718_Voice_MRoad_A1_H1','FY1718_VOICE_MROAD_A6_H1','FY1718_VOICE_MURCIA_4G_H1','FY1718_VOICE_PAMPLONA_4G_H1','FY1718_VOICE_REST_4G_H1_22','FY1718_VOICE_REST_4G_H1_27','FY1718_VOICE_REST_4G_H1_38','FY1718_VOICE_REST_4G_H1_39','FY1718_VOICE_REST_4G_H1_53')


create table #bbddfileid
(
DDBB varchar(256),
Contador int
)




declare @id as integer = 1
declare @ddbb as varchar(256)

while @id <= (select max(id) from _ddbb)
begin

set @ddbb = (select name from _ddbb where id=@id)

if @ddbb like '%Voice%'
begin
insert into #bbddfileid
exec ('use ' + @DDBB + '
		select ''' + @DDBB + ''',count(1)
		from sessions s, filelist f
		where valid=0
		and s.fileid=f.fileid
		
		and s.InvalidReason like ''%LCC%''
		
		order by 1


')
end 

if @ddbb like '%Data%'
begin
insert into #bbddfileid

exec ('
	use ' + @DDBB + '
	select ''' + @DDBB + ''',count(1)
	from testinfo t, sessions s, filelist f
	where t.valid=0
	and t.sessionid=s.sessionid
	and s.fileid=f.fileid

	and t.InvalidReason like ''%LCC%''

	order by 1	
	 
')
end 

set @id = @id + 1

end


select * from #bbddfileid

drop table _ddbb,#bbddfileid

