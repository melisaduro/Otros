select cst_till_alerting,cst_till_connect
from lcc_calls_detailed
where sessionid=78

--Call Setup Time Voice MtoM (10108)
--[from Dial to connect]
select [kpi10100_Duration]
from lcc_core_Voice_CST_KPIs_Table_SQ
where sessionid=78