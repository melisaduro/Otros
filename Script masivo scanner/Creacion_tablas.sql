use [FY1718_SCANNER_GSM_LTE_WCDMA]

create table Scanner_2G_01(
[channel] [int] NULL,
	[rssi] [real] NULL,
	[latitude] [float] NULL,
	[longitude] [float] NULL,
	[msgtime] [datetime2](3) NULL )

create table tabla_control(
[database] varchar(256) NULL,
[Count_Reg] [float] NULL,
	[Count_Reg_insertados] [float] NULL )

select * from tabla_control

truncate table tabla_control

select convert(varchar(4), month(p.msgtime))
		from FY1718_VOICE_ROAD_REST_H1.[dbo].[MsgScannerBCCHInfo] l, 
			 FY1718_VOICE_ROAD_REST_H1.[dbo].[MsgScannerBCCH] li, 
			 FY1718_VOICE_ROAD_REST_H1.[dbo].position p
	   where l.bcchscanid=li.bcchscanid
		and l.posid=p.posid
		and month(p.msgtime)= 1