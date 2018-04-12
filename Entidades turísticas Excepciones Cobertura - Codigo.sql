select *
 from lcc_entities_completed_Report e
  inner join (
   select a.[entity_name],a.[Meas_round]
	, case when a.[3G_Voice_VDF]='N' and a.[3G_Data_VDF]='N' and a.[4G_Voice_VDF]='N' and a.[4G_Data_VDF]='N' and a.[4GDevice_Data_VDF]='N' and a.[3G_Voice_OSP]='N' and a.[3G_Data_OSP]='N' and a.[4G_Voice_OSP]='N' and a.[4G_Data_OSP]='N' and a.[4GDevice_Data_OSP]='N' and a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N'
      and e.[3G_Voice_VDF] is not null then e.[3G_Voice_VDF]
     else a.[3G_Voice_VDF] end as '3G_Voice_VDF'
    , case when a.[3G_Voice_VDF]='N' and a.[3G_Data_VDF]='N' and a.[4G_Voice_VDF]='N' and a.[4G_Data_VDF]='N' and a.[4GDevice_Data_VDF]='N' and a.[3G_Voice_OSP]='N' and a.[3G_Data_OSP]='N' and a.[4G_Voice_OSP]='N' and a.[4G_Data_OSP]='N' and a.[4GDevice_Data_OSP]='N' and a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N'
      and e.[3G_Data_VDF] is not null then e.[3G_Data_VDF]
     else a.[3G_Data_VDF] end as '3G_Data_VDF'
    , case when a.[3G_Voice_VDF]='N' and a.[3G_Data_VDF]='N' and a.[4G_Voice_VDF]='N' and a.[4G_Data_VDF]='N' and a.[4GDevice_Data_VDF]='N' and a.[3G_Voice_OSP]='N' and a.[3G_Data_OSP]='N' and a.[4G_Voice_OSP]='N' and a.[4G_Data_OSP]='N' and a.[4GDevice_Data_OSP]='N' and a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N'
      and e.[4G_Voice_VDF] is not null then e.[4G_Voice_VDF]
     else a.[4G_Voice_VDF] end as '4G_Voice_VDF'
    , case when a.[3G_Voice_VDF]='N' and a.[3G_Data_VDF]='N' and a.[4G_Voice_VDF]='N' and a.[4G_Data_VDF]='N' and a.[4GDevice_Data_VDF]='N' and a.[3G_Voice_OSP]='N' and a.[3G_Data_OSP]='N' and a.[4G_Voice_OSP]='N' and a.[4G_Data_OSP]='N' and a.[4GDevice_Data_OSP]='N' and a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N'
      and e.[4G_Data_VDF] is not null then e.[4G_Data_VDF]
     else a.[4G_Data_VDF] end as '4G_Data_VDF'
    , case when a.[3G_Voice_VDF]='N' and a.[3G_Data_VDF]='N' and a.[4G_Voice_VDF]='N' and a.[4G_Data_VDF]='N' and a.[4GDevice_Data_VDF]='N' and a.[3G_Voice_OSP]='N' and a.[3G_Data_OSP]='N' and a.[4G_Voice_OSP]='N' and a.[4G_Data_OSP]='N' and a.[4GDevice_Data_OSP]='N' and a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N'
      and e.[4GDevice_Data_VDF] is not null then e.[4GDevice_Data_VDF]
     else a.[4GDevice_Data_VDF] end as '4GDevice_Data_VDF'
    , case when a.[3G_Voice_OSP]='N' and a.[3G_Data_OSP]='N' and a.[4G_Voice_OSP]='N' and a.[4G_Data_OSP]='N' and a.[4GDevice_Data_OSP]='N' and a.[3G_Voice_OSP]='N' and a.[3G_Data_OSP]='N' and a.[4G_Voice_OSP]='N' and a.[4G_Data_OSP]='N' and a.[4GDevice_Data_OSP]='N' and a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N'
      and e.[3G_Voice_OSP] is not null then e.[3G_Voice_OSP]
     else a.[3G_Voice_OSP] end as '3G_Voice_OSP'
	, case when a.[3G_Voice_OSP]='N' and a.[3G_Data_OSP]='N' and a.[4G_Voice_OSP]='N' and a.[4G_Data_OSP]='N' and a.[4GDevice_Data_OSP]='N' and a.[3G_Voice_OSP]='N' and a.[3G_Data_OSP]='N' and a.[4G_Voice_OSP]='N' and a.[4G_Data_OSP]='N' and a.[4GDevice_Data_OSP]='N' and a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N'
      and e.[3G_Data_OSP] is not null then e.[3G_Data_OSP]
     else a.[3G_Data_OSP] end as '3G_Data_OSP'
    , case when a.[3G_Voice_OSP]='N' and a.[3G_Data_OSP]='N' and a.[4G_Voice_OSP]='N' and a.[4G_Data_OSP]='N' and a.[4GDevice_Data_OSP]='N' and a.[3G_Voice_OSP]='N' and a.[3G_Data_OSP]='N' and a.[4G_Voice_OSP]='N' and a.[4G_Data_OSP]='N' and a.[4GDevice_Data_OSP]='N' and a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N'
      and e.[4G_Voice_OSP] is not null then e.[4G_Voice_OSP]
     else a.[4G_Voice_OSP] end as '4G_Voice_OSP'
    , case when a.[3G_Voice_OSP]='N' and a.[3G_Data_OSP]='N' and a.[4G_Voice_OSP]='N' and a.[4G_Data_OSP]='N' and a.[4GDevice_Data_OSP]='N' and a.[3G_Voice_OSP]='N' and a.[3G_Data_OSP]='N' and a.[4G_Voice_OSP]='N' and a.[4G_Data_OSP]='N' and a.[4GDevice_Data_OSP]='N' and a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N'
      and e.[4G_Data_OSP] is not null then e.[4G_Data_OSP]
     else a.[4G_Data_OSP] end as '4G_Data_OSP'
    , case when a.[3G_Voice_OSP]='N' and a.[3G_Data_OSP]='N' and a.[4G_Voice_OSP]='N' and a.[4G_Data_OSP]='N' and a.[4GDevice_Data_OSP]='N' and a.[3G_Voice_OSP]='N' and a.[3G_Data_OSP]='N' and a.[4G_Voice_OSP]='N' and a.[4G_Data_OSP]='N' and a.[4GDevice_Data_OSP]='N' and a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N'
      and e.[4GDevice_Data_OSP] is not null then e.[4GDevice_Data_OSP]
     else a.[4GDevice_Data_OSP] end as '4GDevice_Data_OSP'
    , case when a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N' and a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N' and a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N'
      and e.[3G_Voice_MUN] is not null then e.[3G_Voice_MUN]
     else a.[3G_Voice_MUN] end as '3G_Voice_MUN'
	, case when a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N' and a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N' and a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N'
      and e.[3G_Data_MUN] is not null then e.[3G_Data_MUN]
     else a.[3G_Data_MUN] end as '3G_Data_MUN'
    , case when a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N' and a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N' and a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N'
      and e.[4G_Voice_MUN] is not null then e.[4G_Voice_MUN]
     else a.[4G_Voice_MUN] end as '4G_Voice_MUN'
    , case when a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N' and a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N' and a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N'
      and e.[4G_Data_MUN] is not null then e.[4G_Data_MUN]
     else a.[4G_Data_MUN] end as '4G_Data_MUN'
    , case when a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N' and a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N' and a.[3G_Voice_MUN]='N' and a.[3G_Data_MUN]='N' and a.[4G_Voice_MUN]='N' and a.[4G_Data_MUN]='N' and a.[4GDevice_Data_MUN]='N'
      and e.[4GDevice_Data_MUN] is not null then e.[4GDevice_Data_MUN]
     else a.[4GDevice_Data_MUN] end as '4GDevice_Data_MUN'
    ,a.[is_Road]
    , a.Coverage_VDF
    , a.Coverage_OSP
    , a.Coverage_MUN
   from  lcc_entities_aggregated a
    left join lcc_entities_aggregated e
     on (a.entity_name=e.entity_name 
      --Mismo año fiscal
      and left(a.meas_round,len(a.meas_round)-2)=left(e.meas_round,len(e.meas_round)-2) 
      --Ronda igual o posterior
      and right(a.meas_round,1)>=right(e.meas_round,1) 
     )
  ) a
   on (e.entity_name=a.entity_name 
    and e.meas_round=a.meas_round)
  left join [AGRIDS_v2].[dbo].[lcc_ciudades_tipo_Project_V9] s
   on e.entity_name=s.entity_name
 where s.scope = 'TOURISTIC AREA' 
  and a.meas_round not like 'FY1516%'
  and ([3G_Voice_VDF] = 'Y' or [3G_Voice_OSP] = 'Y' or [3G_Voice_MUN] = 'Y')
  and ([3G_Data_VDF] = 'Y'  or [3G_Data_OSP] = 'Y'  or [3G_Data_MUN] = 'Y')
  and ([4G_Voice_VDF] = 'Y' or [4G_Voice_OSP] = 'Y' or [4G_Voice_MUN] = 'Y')
  and ([4G_Data_VDF] = 'Y'  or [4G_Data_OSP] = 'Y'  or [4G_Data_MUN] = 'Y')
  and (Coverage_VDF = 'Y' or Coverage_OSP = 'Y' or Coverage_MUN = 'Y')
order by 1