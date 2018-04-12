use FY1718_voice_REST_4G_H1_48


		select  lc.fileid,
			lc.sessionid,
			lc.collectionname,
			p.entity_name

			from lcc_calls_detailed lc, lcc_position_Entity_List_Vodafone p, lcc_position_Entity_List_Vodafone p2

			where lc.fileid in (select fileid from lcc_position_Entity_List_Vodafone) and 

				-- Forzamos a que ambos terminales se encuentren dentro del contorno para dar por valida la llamada:
				(p.lonid = master.dbo.fn_lcc_longitude2lonid (lc.longitude_fin_A, lc.latitude_fin_A) 
				and p.latid = master.dbo.fn_lcc_latitude2latid (lc.latitude_fin_A))
		
				and 

				(p2.lonid = master.dbo.fn_lcc_longitude2lonid (lc.longitude_fin_B, lc.latitude_fin_B) 
				and p2.latid = master.dbo.fn_lcc_latitude2latid (lc.latitude_fin_B))
			and p.collectionname like '%mogan%'
			and p.entity_name not like '%mogan%'
		group by lc.fileid,
			lc.sessionid,
			lc.collectionname,
			p.entity_name
		

		
