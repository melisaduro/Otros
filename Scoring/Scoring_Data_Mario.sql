/****** Script for SelectTopNRows command from SSMS  ******/
SELECT 
case when s.scope in ('MAIN CITIES','SMALLER CITIES') then 'CITIES AND TOWNS'
	 when s.scope in ('SUMMER','TOURISTIC AREA') then 'TOURISTIC AREA'
	 when s.scope = 'MAIN HIGHWAYS' then 'TRANSPORT'
	 else 'OTHER' end as Scope,
'4G' as Technology,
'Y' as Carrier,
s.Scope as Target_Scope,
v.entities_dashboard as Cities,
TRANSFER_DL_CE_QUALIFIED,
TRANSFER_DL_CE_SESSIONTIME,
TRANSFER_DL_CE_P10,
TRANSFER_DL_CE_P90,
TRANSFER_UL_CE_QUALIFIED,
TRANSFER_UL_CE_SESSIONTIME,
TRANSFER_UL_CE_P10,
TRANSFER_UL_CE_P90,
TRANSFER_DL_NC_QUALIFIED,
TRANSFER_DL_NC_DATARATE,
TRANSFER_DL_NC_P10,
TRANSFER_DL_NC_P90,
TRANSFER_UL_NC_QUALIFIED,
TRANSFER_UL_NC_DATARATE,
TRANSFER_UL_NC_P10,
TRANSFER_UL_NC_P90,
WEB_QUALIFIED,
WEB_SESSIONTIME,
WEB_HTTPS_QUALIFIED,
WEB_HTTPS_SESSIONTIME,
WEB_STATIC_QUALIFIED,
WEB_STATIC_SESSIONTIME,
WEB_LIVE_QUALIFIED,
WEB_LIVE_SESSIONTIME,
YOU_QUALIFIED_B3,
YOU_STARTTIME,
YOU_B2,
HDYOU_QUALIFIED_B3,
HDYOU_STARTTIME,
HDYOU_B2,
[HDYOU-B4],
HDYOU_B5,
Operator,
'' as MonthYear,
'Complete' as Type_Meas

  FROM [QLIK].[dbo].[lcc_Scoring_Data_BBDD] s, [AGRIDS].[dbo].[lcc_dashboard_info_scopes_NEW] v

  where s.entity = v.entities_bbdd
  and report = 'MUN'   -- dejar tal cual
  and ReportWeek='W1' -- cambiar
  and MonthYear='201801' --cambiar
  and id='OSP'

  order by case when s.scope in ('MAIN CITIES','SMALLER CITIES') then 1
				when s.scope in ('SUMMER','TOURISTIC AREA') then 3
				when s.scope = 'MAIN HIGHWAYS' then 2
				else 4 end,
				entity,
			case when operator='Vodafone' then 1
				 when operator='Movistar' then 2
				 when operator='Orange' then 3
				 else 4 end





--Maximos

SELECT 
case when s.scope in ('MAIN CITIES','SMALLER CITIES') then 'CITIES AND TOWNS'
	 when s.scope in ('SUMMER','TOURISTIC AREA') then 'TOURISTIC AREA'
	 when s.scope = 'MAIN HIGHWAYS' then 'TRANSPORT'
	 else 'OTHER' end as Scope,
'4G' as Technology,
'Y' as Carrier,
s.Scope as Target_Scope,
v.entities_dashboard as Cities,
TRANSFER_DL_CE_QUALIFIED_max,
TRANSFER_DL_CE_SESSIONTIME_max,
TRANSFER_DL_CE_P10_max,
TRANSFER_DL_CE_P90_max,
TRANSFER_UL_CE_QUALIFIED_max,
TRANSFER_UL_CE_SESSIONTIME_max,
TRANSFER_UL_CE_P10_max,
TRANSFER_UL_CE_P90_max,
TRANSFER_DL_NC_QUALIFIED_max,
TRANSFER_DL_NC_DATARATE_max,
TRANSFER_DL_NC_P10_max,
TRANSFER_DL_NC_P90_max,
TRANSFER_UL_NC_QUALIFIED_max,
TRANSFER_UL_NC_DATARATE_max,
TRANSFER_UL_NC_P10_max,
TRANSFER_UL_NC_P90_max,
WEB_QUALIFIED_max,
WEB_SESSIONTIME_max,
WEB_HTTPS_QUALIFIED_max,
WEB_HTTPS_SESSIONTIME_max,
WEB_STATIC_QUALIFIED_max,
WEB_STATIC_SESSIONTIME_max,
WEB_LIVE_QUALIFIED_max,
WEB_LIVE_SESSIONTIME_max,
YOU_QUALIFIED_B3_max,
YOU_STARTTIME_max,
YOU_B2_max,
HDYOU_QUALIFIED_B3_max,
HDYOU_STARTTIME_max,
HDYOU_B2_max,
[HDYOU-B4_max],
HDYOU_B5_max,
Operator,
'' as MonthYear,
'Complete' as Type_Meas

  FROM [QLIK].[dbo].[lcc_Scoring_Data_BBDD] s, [AGRIDS].[dbo].[lcc_dashboard_info_scopes_NEW] v

  where s.entity = v.entities_bbdd
  and report = 'MUN'   -- dejar tal cual
  and ReportWeek='W1'  -- cambiar
  and MonthYear='201801' -- cambiar
  and id='OSP'

  order by case when s.scope in ('MAIN CITIES','SMALLER CITIES') then 1
				when s.scope in ('SUMMER','TOURISTIC AREA') then 3
				when s.scope = 'MAIN HIGHWAYS' then 2
				else 4 end,
				entity,
			case when operator='Vodafone' then 1
				 when operator='Movistar' then 2
				 when operator='Orange' then 3
				 else 4 end