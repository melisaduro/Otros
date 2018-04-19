use FY1718_VOICE_REST_4G_H1_46

select S.SESSIONID
from sessions s, filelist f
where f.fileid=s.FileId
and s.valid=1
and sessiontype='CALL'
and info in ('Completed','Failed','Dropped')
AND COLLECTIONNAME LIKE '%fuengirola%4G%'
GROUP BY S.SESSIONID

SELECT VALID,INVALIDREASON
FROM SESSIONS
WHERE SESSIONID IN ('38137','38139','38751','38753','39273','39517','41097','41099','41107','41115','41117','41119','41121','41123','41125','41127','41693','41695','41703','41711','41713','41715','41717','41719','41721','41723','42327','42331','42333','42335','42337','42339','42779','42783','42785','42787','42789','42791')

--WHERE SESSIONID IN ('38341','38343','38547','38549','39029','39761','41395','41397','41405','41413','41415','41417','41419','41421','41423','41425','41991','41993','42001','42009','42011','42013','42015','42017','42019','42021','42477','42481','42483','42485','42487','42489','42627','42631','42633','42635','42637','42639')

UPDATE SESSIONS
SET VALID=0,  InvalidReason='LCC OutOfBounds - ORA'
WHERE SESSIONID IN ('38137','38139','38751','38753','39273','39517','41097','41099','41107','41115','41117','41119','41121','41123','41125','41127','41693','41695','41703','41711','41713','41715','41717','41719','41721','41723','42327','42331','42333','42335','42337','42339','42779','42783','42785','42787','42789','42791')

--WHERE SESSIONID IN ('38341','38343','38547','38549','39029','39761','41395','41397','41405','41413','41415','41417','41419','41421','41423','41425','41991','41993','42001','42009','42011','42013','42015','42017','42019','42021','42477','42481','42483','42485','42487','42489','42627','42631','42633','42635','42637','42639')
