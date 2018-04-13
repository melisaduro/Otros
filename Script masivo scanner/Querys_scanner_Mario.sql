use [FY1718_SCANNER_GSM_LTE_WCDMA]
select li.channel, li.rssi, p.latitude, p.longitude, l.msgtime  
from FY1718_VOICE_REST_4G_H1_52.[dbo].[MsgScannerBCCHInfo] l, FY1718_VOICE_REST_4G_H1_52.[dbo].[MsgScannerBCCH] li, FY1718_VOICE_REST_4G_H1_52.dbo.position p
where l.bcchscanid=li.bcchscanid
and l.posid=p.posid

use [FY1718_VOICE_SMALLCELLS_4G]
select li.channel, l.phcid, l.rsrp, l.rsrq, l.cinr, p.latitude, p.longitude,li.msgtime 
--into _Scanner_LTE
from FY1718_VOICE_REST_4G_H1_52.dbo.MsgLTEScannerTopNInfo li, FY1718_VOICE_REST_4G_H1_52.dbo.MsgLTEScannerTopN l, FY1718_VOICE_REST_4G_H1_52.dbo.position p
where l.LTETopNId=li.LTETopNId
and li.posid=p.posid
group by latitude, longitude


use [FY1718_SCANNER_GSM_LTE_WCDMA]
select (rxlev+cpich) as RSCP, channel, sc, cpich as EcIo, latitude, longitude, w.msgtime 
into _Scanner_WCDMA
from FY1718_VOICE_REST_4G_H1_52.dbo.LCC_scannerWcdma w, FY1718_VOICE_REST_4G_H1_52.dbo.position p
where p.posid=w.posid