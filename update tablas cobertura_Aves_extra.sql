-------------------Modificación en las tablas de cobertura de la bbdd de origen

use FY1617_Voice_AVE_Rest_H2

declare @entidad_old as varchar(256)='VALLA-LEO-R5'
declare @entidad_new as varchar(256)='AVE-Valladolid-Leon-R5'

begin transaction
update lcc_GSMScanner_allFreqs_allBCCH_50x50_probCobIndoor
set Entidad_medida=@entidad_new
where Entidad_Medida=@entidad_old

update lcc_GSMScanner_allFreqs_allBCCH_50x50_probCobIndoor_ord
set Entidad_medida=@entidad_new
where Entidad_Medida=@entidad_old

update lcc_LTEScanner_allFreqs_allPCIS_50x50_probCobIndoor
set Entidad_medida=@entidad_new
where Entidad_Medida=@entidad_old

update lcc_LTEScanner_allFreqs_allPCIS_50x50_probCobIndoor_ord
set Entidad_medida=@entidad_new
where Entidad_Medida=@entidad_old

update lcc_UMTSScanner_allFreqs_allSC_50x50_probCobIndoor
set Entidad_medida=@entidad_new
where Entidad_Medida=@entidad_old

update lcc_UMTSScanner_allFreqs_allSC_50x50_probCobIndoor_ord
set Entidad_medida=@entidad_new
where Entidad_Medida=@entidad_old

-------------------Modificación en las tablas de cobertura de la coverage_union
use FY1617_Coverage_Union_AVE_H2

declare @entidad_old as varchar(256)='VALLA-LEO-R5'
declare @entidad_new as varchar(256)='AVE-Valladolid-Leon-R5'
commit
begin transaction
update lcc_GSMScanner_50x50_ProbCobIndoor
set Entidad_medida=@entidad_new
where Entidad_Medida=@entidad_old

update lcc_GSMScanner_allFreqs_allBCCH_50x50_probCobIndoor_ord
set Entidad_medida=@entidad_new
where Entidad_Medida=@entidad_old

update lcc_LTEScanner_allFreqs_allPCIS_50x50_probCobIndoor_ord
set Entidad_medida=@entidad_new
where Entidad_Medida=@entidad_old

update lcc_UMTSScanner_50x50_ProbCobIndoor
set Entidad_medida=@entidad_new
where Entidad_Medida=@entidad_old

update lcc_UMTSScanner_allFreqs_allSC_50x50_probCobIndoor_ord
set Entidad_medida=@entidad_new
where Entidad_Medida=@entidad_old


