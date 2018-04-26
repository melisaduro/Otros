USE [master]
GO
/****** Object:  StoredProcedure [dbo].[sp_lcc_core_Voice_ServingCell_Session_Table_Dial2Discon]    Script Date: 19/04/2018 11:05:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[sp_lcc_core_Voice_ServingCell_Session_Table_Dial2Discon]
as

-- DESCRIPTION ----------------------------------------------------------------------------------------------------------------------
--
--		* COLLATE Latin1_General_CI_AS	-> database_default
--
--		* Info para el lado A y B -> misma KEY_BST (en funcion del sessionid de A), es necesario filtrar por el side correspondiente:
--			select * from lcc_core_Voice_ServingCell_Session_Table_Dial2Discon where side='A'
--			select * from lcc_core_Voice_ServingCell_Session_Table_Dial2Discon where side='B'	
--
--		* Used:	NetworkInfo		
--				LTEMeasurementReport (4G) 
--				WCDMAActiveSet		 (3G)	where m.refCell=1	-- reference cell
--				MsgGsmReport		 (2G)
--
--		* VIP:		callStartTime_Dial / callSetupTime_ConACK / callEndTime_Disconnect
--
--		* En la tabla unificada de tecnologias, se coge la info de las llamadas entre:
--				callStartTime_Dial => callEndTime_Disconnect
--
--		* Info INI => callStartTime_Dial
--		* Info INI => callEndTime_Disconnect
--		* Info AVG => callStartTime_Dial => callEndTime_Disconnect
--
--		* SOLO las duraciones por tecnología, se filtran más aún, para quedarnos solo con la info entre:
--				callSetupTime_ConACK => callEndTime_Disconnect
--
-------------------------------------------------------------------------------------------------------------------------------------



---------------------------------------------------	select * from [_lcc_c0re_Voice_ServingCell_Session_Table_ALL]

--	Filtramos para quedarnos solo con la informacion:	
--				callStartTime_Dial => callEndTime_Disconnect			[lcc_core_Voice_Metrics_TimeStamp_Table]
--
--	Nos quedamos dichos margenes, para filtrar luego las duraciones de las tecnologias:
--		En CAIDAS Y COMPLETADAS => duracion:		callSetupTime_ConACK	=>	callEndTime_Disconnect
--		En BLOQUEOS				=> duracion:		callStartTime_Dial		=>	callEndTime_Disconnect (por definicion, la llamada no ha conectado)
exec sp_lcc_dropifexists '_lcc_c0re_Voice_ServingCell_Session_Table'
select 
	m.*, 
	mt.callStartTime_Dial, mt.callSetupTime_ConACK, mt.callEndTime_Disconnect,
	mt.callDuration_Dial2Disconnect, mt.callDuration_ConACK2Disconnect,
	row_number () over (partition by m.sessionid order by m.msgtime) as msgtime_id_asc,
	row_number () over (partition by m.sessionid order by m.msgtime desc) as msgtime_id_desc

into _lcc_c0re_Voice_ServingCell_Session_Table
from _lcc_c0re_Voice_ServingCell_Session_Table_ALL m
		LEFT OUTER JOIN lcc_core_Voice_Metrics_TimeStamp_Table mt	on mt.key_BST COLLATE Latin1_General_CI_AS=m.key_BST COLLATE Latin1_General_CI_AS
		
where	m.msgtime >= mt.callStartTime_Dial 
	and m.msgtime <= mt.callEndTime_Disconnect


---------------------------------------------------	select * from [_lcc_c0re_Voice_ServingCell_Session_Table]

----------------
-- Info by session:
exec sp_lcc_dropifexists 'lcc_core_Voice_ServingCell_Session_Table_Dial2Discon'
select distinct 
	sc.key_BST COLLATE Latin1_General_CI_AS as key_BST, sc.ddbb COLLATE Latin1_General_CI_AS as ddbb, 
	sc.side,
	sc.sessionid,

	-- Start Info			=> DIAL
	ini.[technology] as Initial_Technology,
	ini.[CId]		 as Initial_CId,		
	ini.[LAC]		 as Initial_LAC,
	case when ini.[technology] in ('%GSM%','%DCS%') then ini.[Freq]		end as Initial_BCCH,
	case when ini.[technology] in ('%GSM%','%DCS%') then ini.[Cell]		end as Initial_BSIC,
	case when ini.[technology] in ('%GSM%','%DCS%') then ini.[Signal]	end as Initial_RxLev,
	case when ini.[technology] in ('%GSM%','%DCS%') then ini.[Quality]	end as Initial_RxQual,

	case when ini.[technology] like ('%UMTS%') then ini.[Freq]		end as Initial_UARFCN,
	case when ini.[technology] like ('%UMTS%') then ini.[Cell]		end as Initial_PSC,
	case when ini.[technology] like ('%UMTS%') then ini.[Signal]	end as Initial_RSCP,
	case when ini.[technology] like ('%UMTS%') then ini.[Quality]	end as Initial_EcIo,

	case when ini.[technology] like ('%LTE%') then ini.[Freq]		end as Initial_EARFCN,
	case when ini.[technology] like ('%LTE%') then ini.[Cell]		end as Initial_PCI,
	case when ini.[technology] like ('%LTE%') then ini.[Signal]		end as Initial_RSRP,
	case when ini.[technology] like ('%LTE%') then ini.[Quality]	end as Initial_RSRQ,
	case when ini.[technology] like ('%LTE%') then ini.[RSSI]		end as Initial_RSSI,
	case when ini.[technology] like ('%LTE%') then (isnull(ini.[SINR0],0)+isnull(ini.[SINR1],0))/2.0 end as Initial_SINR,

	-- End Info			=> DISCONNECT
	fin.[technology] as Final_Technology,
	fin.[CId]		 as Final_CId,		
	fin.[LAC]		 as Final_LAC,
	case when fin.[technology] in ('%GSM%','%DCS%') then fin.[Freq]		end as Final_BCCH,
	case when fin.[technology] in ('%GSM%','%DCS%') then fin.[Cell]		end as Final_BSIC,
	case when fin.[technology] in ('%GSM%','%DCS%') then fin.[Signal]	end as Final_RxLev,
	case when fin.[technology] in ('%GSM%','%DCS%') then fin.[Quality]	end as Final_RxQual,

	case when fin.[technology] like ('%UMTS%') then fin.[Freq]		end as Final_UARFCN,
	case when fin.[technology] like ('%UMTS%') then fin.[Cell]		end as Final_PSC,
	case when fin.[technology] like ('%UMTS%') then fin.[Signal]	end as Final_RSCP,
	case when fin.[technology] like ('%UMTS%') then fin.[Quality]	end as Final_EcIo,

	case when fin.[technology] like ('%LTE%') then fin.[Freq]		end as Final_EARFCN,
	case when fin.[technology] like ('%LTE%') then fin.[Cell]		end as Final_PCI,
	case when fin.[technology] like ('%LTE%') then fin.[Signal]		end as Final_RSRP,
	case when fin.[technology] like ('%LTE%') then fin.[Quality]	end as Final_RSRQ,
	case when fin.[technology] like ('%LTE%') then fin.[RSSI]	end as Final_RSSI,
	case when fin.[technology] like ('%LTE%') then (isnull(fin.[SINR0],0)+isnull(fin.[SINR1],0))/2.0 end as Final_SINR,

	-- Avg Info			=> DIAL-> DISCONNECT
	avg.Hopping, 
	avg.avg_RxLev,	avg.avg_RxQual,					avg.min_RxLev,	avg.min_RxQual,
	avg.avg_RSCP,	avg.avg_EcI0,					avg.min_RSCP,	avg.min_EcI0,
	avg.avg_RSRP,	avg.avg_RSRQ,	avg.avg_SINR,	avg.min_RSRP,	avg.min_RSRQ,

	-- Tech Duration INFO	=> DIAL-> DISCONNECT
	durD.durationDial2Discon as durationDial2Discon,
	durD.durationDial2Discon_2G as durationDial2Discon_2G,		durD.durationDial2Discon_3G as durationDial2Discon_3G,			durD.durationDial2Discon_4G as durationDial2Discon_4G,
	
	durD.durationDial2Discon_G900 as durationDial2Discon_G900,	durD.durationDial2Discon_G1900 as durationDial2Discon_G1900,	durD.durationDial2Discon_G1800 as durationDial2Discon_G1800, 
	durD.durationDial2Discon_U900 as durationDial2Discon_U900,	durD.durationDial2Discon_U1700 as durationDial2Discon_U1700,	durD.durationDial2Discon_U2100 as durationDial2Discon_U2100,
	durD.durationDial2Discon_L1 as durationDial2Discon_L1,		durD.durationDial2Discon_L3 as durationDial2Discon_L3,			durD.durationDial2Discon_L5 as durationDial2Discon_L5,			durD.durationDial2Discon_L7 as durationDial2Discon_L7,
	durD.durationDial2Discon_L20 as durationDial2Discon_L20,	durD.durationDial2Discon_L28 as durationDial2Discon_L28,		durD.durationDial2Discon_L40 as durationDial2Discon_L40,		durD.durationDial2Discon_L41 as durationDial2Discon_L41,

	-- Tech Duration INFO	=> CONNECT-> DISCONNECT
	durC.durationCon2Discon as durationCon2Discon,
	durC.durationCon2Discon_2G as durationCon2Discon_2G,		durC.durationCon2Discon_3G as durationCon2Discon_3G,			durC.durationCon2Discon_4G as durationCon2Discon_4G,
	
	durC.durationCon2Discon_G900 as durationCon2Discon_G900,	durC.durationCon2Discon_G1900 as durationCon2Discon_G1900,		durC.durationCon2Discon_G1800 as durationCon2Discon_G1800, 
	durC.durationCon2Discon_U900 as durationCon2Discon_U900,	durC.durationCon2Discon_U1700 as durationCon2Discon_U1700,		durC.durationCon2Discon_U2100 as durationCon2Discon_U2100,
	durC.durationCon2Discon_L1 as durationCon2Discon_L1,		durC.durationCon2Discon_L3 as durationCon2Discon_L3,			durC.durationCon2Discon_L5 as durationCon2Discon_L5,			durC.durationCon2Discon_L7 as durationCon2Discon_L7,
	durC.durationCon2Discon_L20 as durationCon2Discon_L20,		durC.durationCon2Discon_L28 as durationCon2Discon_L28,			durC.durationCon2Discon_L40 as durationCon2Discon_L40,			durC.durationCon2Discon_L41 as durationCon2Discon_L41_A

into lcc_core_Voice_ServingCell_Session_Table_Dial2Discon
from _lcc_c0re_Voice_ServingCell_Session_Table sc

	----------------------------------------
	LEFT OUTER JOIN (		---- START info		=> DIAL:
			select	
				sc.key_BST COLLATE Latin1_General_CI_AS as key_BST, sc.sessionid,
				sc.[Freq],		sc.[Cell],	 
				sc.[Signal],	sc.[Quality],	sc.[RSSI],	sc.[SINR0],	sc.[SINR1],	
				sc.[CId],		sc.[LAC],		sc.[technology] 
			from _lcc_c0re_Voice_ServingCell_Session_Table sc
			where msgtime_id_asc=1
	) ini on ini.key_BST=sc.key_BST and ini.sessionid=sc.sessionid

	----------------------------------------
	LEFT OUTER JOIN (		---- END info		=> DISCONNECT
			select	
				sc.key_BST COLLATE Latin1_General_CI_AS as key_BST, sc.sessionid,
				sc.[Freq],		sc.[Cell],	 
				sc.[Signal],	sc.[Quality],	sc.[RSSI],	sc.[SINR0],	sc.[SINR1],	
				sc.[CId],		sc.[LAC],		sc.[technology] 
			from _lcc_c0re_Voice_ServingCell_Session_Table sc
			where msgtime_id_desc=1

	) fin on fin.key_BST=sc.key_BST and fin.sessionid=sc.sessionid

	----------------------------------------
	LEFT OUTER JOIN (		---- AVG info		=> DIAL-> DISCONNECT
			select 
				sc.key_BST COLLATE Latin1_General_CI_AS as key_BST, sessionid,

				max(case when sc.technology like '%GSM%' then cast(sc.hopping as integer) end) as Hopping,
				log10(avg(power(10.0E0,(case when sc.[technology] like '%GSM%' or sc.[technology] like '%DCS%' and sc.[Signal] is not null  then 1.0*sc.[Signal]  end)/10.0E0)))*10 as avg_RxLev,
				log10(avg(power(10.0E0,(case when sc.[technology] like '%GSM%' or sc.[technology] like '%DCS%' and sc.[Quality] is not null then 1.0*sc.[Quality] end)/10.0E0)))*10 as avg_RxQual, 

				log10(avg(power(10.0E0,(case when sc.[technology] like '%UMTS%' and sc.[Signal] is not null  then 1.0*sc.[Signal]  end)/10.0E0)))*10 as avg_RSCP,
				log10(avg(power(10.0E0,(case when sc.[technology] like '%UMTS%' and sc.[Quality] is not null then 1.0*sc.[Quality] end)/10.0E0)))*10 as avg_EcI0,

				log10(avg(power(10.0E0,(case when sc.[technology] like '%LTE%' and sc.[Signal] is not null  then 1.0*sc.[Signal]  end)/10.0E0)))*10 as avg_RSRP,
				log10(avg(power(10.0E0,(case when sc.[technology] like '%LTE%' and sc.[Quality] is not null then 1.0*sc.[Quality] end)/10.0E0)))*10 as avg_RSRQ,
				avg(case when (sc.[technology] like '%LTE%' and sc.[SINR0] is not null and sc.[SINR1] is not null) then 1.0*(sc.[SINR0]+sc.[SINR1])/2.0 end) as avg_SINR,

				min(case when sc.[technology] like '%GSM%' or sc.[technology] like '%DCS%' and sc.[Signal] is not null  then 1.0*sc.[Signal]  end) as min_RxLev,
				min(case when sc.[technology] like '%GSM%' or sc.[technology] like '%DCS%' and sc.[Quality] is not null then 1.0*sc.[Quality] end) as min_RxQual, 

				min(case when sc.[technology] like '%UMTS%' and sc.[Signal] is not null  then 1.0*sc.[Signal]  end) as min_RSCP,
				min(case when sc.[technology] like '%UMTS%' and sc.[Quality] is not null then 1.0*sc.[Quality] end) as min_EcI0, 

				min(case when sc.[technology] like '%LTE%' and sc.[Signal] is not null  then 1.0*sc.[Signal]  end) as min_RSRP,
				min(case when sc.[technology] like '%LTE%' and sc.[Quality] is not null then 1.0*sc.[Quality] end) as min_RSRQ
			--		select * 
			from _lcc_c0re_Voice_ServingCell_Session_Table sc
			group by sc.key_BST, sc.sessionid
	) avg on avg.key_BST=sc.key_BST and avg.sessionid=sc.sessionid

	-------------------------------------------------------------------------
	LEFT OUTER JOIN (		---- Tech Duration => DIAL-> DISCONNECT
			select 
				key_BST, sessionid,
				nullif(sum(isnull(durationDial2Discon,0)),0) as durationDial2Discon,
				nullif(sum(case when technology like '%GSM%' or technology like '%DCS%' then (isnull(durationDial2Discon,0)) end),0) as durationDial2Discon_2G,
				nullif(sum(case when technology like '%UMTS%' then (isnull(durationDial2Discon,0)) end),0) as durationDial2Discon_3G,
				nullif(sum(case when technology like '%LTE%'  then (isnull(durationDial2Discon,0)) end),0) as durationDial2Discon_4G,
				nullif(sum(case when technology like 'GSM 900' then (isnull(durationDial2Discon,0)) end),0) as durationDial2Discon_G900,
				nullif(sum(case when technology like 'GSM 1900' then (isnull(durationDial2Discon,0)) end),0) as durationDial2Discon_G1900,
				nullif(sum(case when technology like 'GSM 1800' then (isnull(durationDial2Discon,0)) end),0) as durationDial2Discon_G1800,
				nullif(sum(case when technology like 'UMTS 900' then (isnull(durationDial2Discon,0)) end),0) as durationDial2Discon_U900,
				nullif(sum(case when technology like 'UMTS 1700' then (isnull(durationDial2Discon,0)) end),0) as durationDial2Discon_U1700,
				nullif(sum(case when technology like 'UMTS 2100' then (isnull(durationDial2Discon,0)) end),0) as durationDial2Discon_U2100,
				nullif(sum(case when technology like 'LTE E-UTRA 1' then (isnull(durationDial2Discon,0)) end),0) as durationDial2Discon_L1,
				nullif(sum(case when technology like 'LTE E-UTRA 3' then (isnull(durationDial2Discon,0)) end),0) as durationDial2Discon_L3,
				nullif(sum(case when technology like 'LTE E-UTRA 5' then (isnull(durationDial2Discon,0)) end),0) as durationDial2Discon_L5,
				nullif(sum(case when technology like 'LTE E-UTRA 7' then (isnull(durationDial2Discon,0)) end),0) as durationDial2Discon_L7,
				nullif(sum(case when technology like 'LTE E-UTRA 20' then (isnull(durationDial2Discon,0)) end),0) as durationDial2Discon_L20,
				nullif(sum(case when technology like 'LTE E-UTRA 28' then (isnull(durationDial2Discon,0)) end),0) as durationDial2Discon_L28,
				nullif(sum(case when technology like 'LTE E-UTRA 40' then (isnull(durationDial2Discon,0)) end),0) as durationDial2Discon_L40,
				nullif(sum(case when technology like 'LTE E-UTRA 41' then (isnull(durationDial2Discon,0)) end),0) as durationDial2Discon_L41
			from (
				select 
					ini.*, 
					fin.msgtime as fin_msgtime, 
					datediff(ms, ini.msgtime, fin.msgtime) as durationDial2Discon

				from _lcc_c0re_Voice_ServingCell_Session_Table ini
						LEFT OUTER JOIN _lcc_c0re_Voice_ServingCell_Session_Table fin on ini.sessionid=fin.sessionid and ini.msgtime_id_asc=fin.msgtime_id_asc-1
			) side

			group by key_BST, sessionid
	) durD on durD.key_BST=sc.key_BST and durD.sessionid=sc.sessionid

	-------------------------------------------------------------------------
	LEFT OUTER JOIN (		---- Tech Duration	=> CONNECT-> DISCONNECT
			select 
				key_BST, sessionid,
				nullif(sum(isnull(durationCon2Discon,0)),0) as durationCon2Discon,
				nullif(sum(case when technology like '%GSM%' or technology like '%DCS%' then (isnull(durationCon2Discon,0)) end),0) as durationCon2Discon_2G,
				nullif(sum(case when technology like '%UMTS%' then (isnull(durationCon2Discon,0)) end),0) as durationCon2Discon_3G,
				nullif(sum(case when technology like '%LTE%'  then (isnull(durationCon2Discon,0)) end),0) as durationCon2Discon_4G,
				nullif(sum(case when technology like 'GSM 900' then (isnull(durationCon2Discon,0)) end),0) as durationCon2Discon_G900,
				nullif(sum(case when technology like 'GSM 1900' then (isnull(durationCon2Discon,0)) end),0) as durationCon2Discon_G1900,
				nullif(sum(case when technology like 'GSM 1800' then (isnull(durationCon2Discon,0)) end),0) as durationCon2Discon_G1800,
				nullif(sum(case when technology like 'UMTS 900' then (isnull(durationCon2Discon,0)) end),0) as durationCon2Discon_U900,
				nullif(sum(case when technology like 'UMTS 1700' then (isnull(durationCon2Discon,0)) end),0) as durationCon2Discon_U1700,
				nullif(sum(case when technology like 'UMTS 2100' then (isnull(durationCon2Discon,0)) end),0) as durationCon2Discon_U2100,
				nullif(sum(case when technology like 'LTE E-UTRA 1' then (isnull(durationCon2Discon,0)) end),0) as durationCon2Discon_L1,
				nullif(sum(case when technology like 'LTE E-UTRA 3' then (isnull(durationCon2Discon,0)) end),0) as durationCon2Discon_L3,
				nullif(sum(case when technology like 'LTE E-UTRA 5' then (isnull(durationCon2Discon,0)) end),0) as durationCon2Discon_L5,
				nullif(sum(case when technology like 'LTE E-UTRA 7' then (isnull(durationCon2Discon,0)) end),0) as durationCon2Discon_L7,
				nullif(sum(case when technology like 'LTE E-UTRA 20' then (isnull(durationCon2Discon,0)) end),0) as durationCon2Discon_L20,
				nullif(sum(case when technology like 'LTE E-UTRA 28' then (isnull(durationCon2Discon,0)) end),0) as durationCon2Discon_L28,
				nullif(sum(case when technology like 'LTE E-UTRA 40' then (isnull(durationCon2Discon,0)) end),0) as durationCon2Discon_L40,
				nullif(sum(case when technology like 'LTE E-UTRA 41' then (isnull(durationCon2Discon,0)) end),0) as durationCon2Discon_L41

			from (
				select 
					ini.*, 
					fin.msgtime as fin_msgtime, 
					case when ini.msgtime>= ini.callSetupTime_ConACK and fin.msgtime <= ini.callEndTime_Disconnect 
									then datediff(ms, ini.msgtime, fin.msgtime) 
					end as durationCon2Discon

				from _lcc_c0re_Voice_ServingCell_Session_Table ini
						LEFT OUTER JOIN _lcc_c0re_Voice_ServingCell_Session_Table fin on ini.sessionid=fin.sessionid and ini.msgtime_id_asc=fin.msgtime_id_asc-1
			) side

			group by key_BST, sessionid
	) durC on durC.key_BST=sc.key_BST and durC.sessionid=sc.sessionid



----------------
-- Drop table with ALL info:
exec sp_lcc_dropifexists '_lcc_c0re_Voice_ServingCell_Session_Table_ALL'
exec sp_lcc_dropifexists '_lcc_c0re_Voice_ServingCell_Session_Table'


---------------------------------------------------		select * from lcc_core_Voice_ServingCell_Session_Table_Dial2Discon where side='A'
---------------------------------------------------		select * from lcc_core_Voice_ServingCell_Session_Table_Dial2Discon where side='B'
