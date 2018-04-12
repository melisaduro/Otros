USE [AGRIDS]
GO

/****** Object:  Table [dbo].[lcc_procedures_step1]    Script Date: 14/09/2015 9:46:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[lcc_tablas_de_lcc_minScannerValue_table](
	[Name_Table] [varchar](128) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO




insert into lcc_tablas_de_lcc_minScannerValue_table
select 'lcc_minScannerValue_table'




--select * from  lcc_tablas_de_lcc_minScannerValue_table