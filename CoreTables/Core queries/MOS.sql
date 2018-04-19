select key_bst,count(1)
 from [dbo].[lcc_core_Master_Table]

 group by key_bst

 select key_bst,sessiontype,count(1)
 from [dbo].[lcc_core_Master_Table]
 group by key_bst,sessiontype
 having count(1)>1
 use bm_analytics
 select * from [dbo].[lcc_core_Config_Values_Table]

 select * from [vlcc_core_Voice_MOS] where opertat

 select sessionid,mos_nb,mos_nb_dl,mos_nb_ul
  from lcc_calls_detailed
 where mnc='05'
 and callstatus='completed'
