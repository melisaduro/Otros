--Query 2G
	Select 
		l.Channel,
		l.RSSI,
		longitude,
		latitude,
		msgtime
	into _prueba_scanner_2G
	from MsgScannerBCCHInfo li,
		MsgScannerBCCH l,
		(select p.latitude, 
			p.longitude,
			p.posid,
			p.fileid
		   from Position p
		 )p
	where li.BCCHScanId=l.BCCHScanId
		and li.PosId=p.PosId
	group by l.Channel,
		l.RSSI,
		longitude,
		latitude,
		msgtime
	

--Query 3G

	select 
		rxlev,
		channel,
		sc,
		p.longitude,
		p.latitude,
		p.msgtime
	into _prueba_scanner_3G
	from dbo.lcc_scannerWcdma l,
	Position p 
	--,Sessions s
where  l.PosId=p.PosId
group by rxlev,
		channel,
		sc,
		p.longitude,
		p.latitude,
		p.msgtime


--Query 4G

