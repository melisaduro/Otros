SELECT DISTINCT ENTIDAD FROM [dbo].[TablaSTDVVoz_WILLIAMS]
SELECT DISTINCT ENTITIES_BBDD FROM AGRIDS.[dbo].[vlcc_dashboard_info_scopes_NEW] WHERE SCOPE LIKE '%WILL%'

SELECT *
FROM AGRIDS.[dbo].[vlcc_dashboard_info_scopes_NEW] T1
LEFT JOIN [dbo].[TablaPercentilVoz] T2
ON ENTITIES_BBDD=ENTIDAD
WHERE SCOPE LIKE '%WILL%'
AND T2.ENTIDAD IS NULL

select * from [dbo].[TablaPercentilDatos_Williams] where entidad='aarnoia'

---Desviaciones
insert into [dbo].[TablaSTDDatos_Williams]
select t3.entities_bbdd,base.*
from 
(SELECT MNC as mnc,
		NULL as Date_Reporting,
		'MUN' as Report_QLik,
		TEST_TYPE as Test_Type,
		MEAS_TECH as Meas_Tech,
		NULL as Resultado_desviacion
FROM AGRIDS.[dbo].[vlcc_dashboard_info_scopes_NEW] T1
INNER JOIN [dbo].[TablaSTDDatos_Williams] T2
ON T1.ENTITIES_BBDD=ENTIDAD
WHERE T1.SCOPE LIKE '%WILL%'
AND t2.ENTIDAD='AARNOIA')base
inner join
(SELECT t1.entities_bbdd,t1.report
FROM AGRIDS.[dbo].[vlcc_dashboard_info_scopes_NEW] T1
LEFT JOIN [TablaSTDDatos] T2
ON ENTITIES_BBDD=ENTIDAD
WHERE SCOPE LIKE '%WILL%'
AND T2.ENTIDAD IS NULL) t3
on base.report_qlik=t3.report

SELECT * FROM QLIK.DBO._RI_VOICE_COMPLETED_QLIK
WHERE ENTITY LIKE '%TORREDECLARAMUNT%'
----Percentiles
insert into [dbo].[TablaPercentilDatos_Williams]
select t3.entities_bbdd,base.*
from 
(SELECT MNC as mnc,
		NULL as Date_Reporting,
		'MUN' as Report_QLik,
		TEST_TYPE as Test_Type,
		MEAS_TECH as Meas_Tech,
		NULL as Percentil,
		NULL as Resultado_Percentil
FROM AGRIDS.[dbo].[vlcc_dashboard_info_scopes_NEW] T1
INNER JOIN [dbo].[TablaPercentilDatos_Williams] T2
ON T1.ENTITIES_BBDD=ENTIDAD
WHERE T1.SCOPE LIKE '%WILL%'
AND t2.ENTIDAD='AARNOIA')base
inner join
(SELECT t1.entities_bbdd,t1.report
FROM AGRIDS.[dbo].[vlcc_dashboard_info_scopes_NEW] T1
LEFT JOIN [TablaPercentilDatos_Williams] T2
ON ENTITIES_BBDD=ENTIDAD
WHERE SCOPE LIKE '%WILL%'
AND T2.ENTIDAD IS NULL) t3
on base.report_qlik=t3.report


