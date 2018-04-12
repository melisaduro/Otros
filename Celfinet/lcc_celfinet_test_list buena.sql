use FY1718_DATA_REST_4G_H1_12

		select  d.fileid,
				d.sessionid,
				d.testid,
				d.collectionname,
				p.entity_name,
				d.starttime

				from  lcc_position_Entity_List_Vodafone p,

					(select fileid, sessionid, testid, collectionname, [longitud Final], [Latitud Final],starttime
							from lcc_data_httpTransfer_DL
					union all
				
					select fileid, sessionid, testid, collectionname, [longitud Final], [Latitud Final],starttime
							from lcc_data_httpTransfer_UL

					union all
				
					select fileid, sessionid, testid, collectionname, [longitud Final], [Latitud Final],starttime
							from lcc_data_httpBrowser

					union all
				
					select fileid, sessionid, testid, collectionname, [longitud Final], [Latitud Final],starttime
							from lcc_data_Youtube

					union all
				
					select fileid, sessionid, testid, collectionname, [longitud Final], [Latitud Final],starttime
							from lcc_data_Latencias
					) d

				where d.fileid=p.fileid
				--and d.testid='35918'
				AND D.COLLECTIONNAME LIKE '%TOLEDO%'
				and p.entity_name <> 'TOLEDO'
				and p.lonid = [master].dbo.fn_lcc_longitude2lonid (d.[longitud Final], d.[Latitud Final]) 
				and p.latid = [master].dbo.fn_lcc_latitude2latid (d.[Latitud Final]) 