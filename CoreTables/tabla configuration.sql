USE [FY1718_VOICE_BURGOS_4G_H1]
GO

/****** Object:  Table [dbo].[lcc_core_Data_Configuration_Table]    Script Date: 19/04/2018 11:28:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[lcc_core_Voice_Configuration_Table](
	[Config] [nvarchar](max) NULL,
	[Marker_ini_duration] [varchar(256)] NULL,  --Dial
	[Marker_end_duration] [varchar(256)] NULL,  --Disconnect
	[Marker_ini_tech] [varchar(256)] NULL,     --
	[Marker_end_tech] [varchar(256)] NULL,
	[Marker_ini_CST] [varchar(256)] NULL,     --Dial? CMServiceRequest
	[Marker_end_CST_Alerting] [varchar(256)] NULL,   --Alerting. Si VOLTE: Request
	[Marker_end_CST_Connect] [varchar(256)] NULL,    --Connect.
	[Disconnect_VOLTE] [bigint] NULL,  --31101
	[Disconnect_CSFB] [bigint] NULL    --20101

) ON [MainGroup] TEXTIMAGE_ON [MainGroup]

GO


