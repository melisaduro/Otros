SELECT 
case when S.scope in ('MAIN CITIES','SMALLER CITIES') then 'CITIES AND TOWNS'
	 when S.scope in ('SUMMER','TOURISTIC AREA') then 'TOURISTIC AREA'
	 when S.scope = 'MAIN HIGHWAYS' then 'TRANSPORT'
	 else 'OTHER' end as Scope,
'4G' as Technology,
'Y' as Carrier,
S.Scope as Target_Scope,
v.entities_dashboard as Cities,
Operator,
Qvoice_score,
CST_score,
MOS_Score,
'' as MonthYear,
'Complete' as Type_Meas

  FROM [QLIK].[dbo].[lcc_Scoring_Voice_BBDD] s, [AGRIDS].[dbo].[lcc_dashboard_info_scopes_NEW] v

   where 
   s.entity = v.entities_bbdd
   and report = 'MUN'      --dejarlo tal cual
   AND ReportWeek='W1'    --cambiar
   and MonthYear='201801'  --cambiar
   and id='OSP'


  order by case when S.scope in ('MAIN CITIES','SMALLER CITIES') then 1
				when S.scope in ('SUMMER','TOURISTIC AREA') then 3
				when S.scope = 'MAIN HIGHWAYS' then 2
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
Operator,
Qvoice_score_Max,
CST_score_Max,
MOS_Score_Max,
'' as MonthYear,
'Complete' as Type_Meas

  FROM [QLIK].[dbo].[lcc_Scoring_Voice_BBDD] s, [AGRIDS].[dbo].[lcc_dashboard_info_scopes_NEW] v

   where s.entity = v.entities_bbdd
   and report = 'MUN'    -- dejarlo tal cual
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