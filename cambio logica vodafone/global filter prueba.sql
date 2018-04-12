USE [FY1718_VOICE_LOGRONO_4G_H1]
--exec sp_MDD_Voice_Libro_Voz_TLT_All_FY1617_GRID		'JEREZ',	1,			'M2M',	'', '4G',	'%%','0',	'VDF'

----	Nuevas Variables de entrada:
declare @ciudad as varchar(256) = 'LOGRONO'
declare @simOperator as int = 7
declare @type as varchar(256) = 'M2M'
declare @Environ as varchar(256) = '%%'
declare @EntityList as varchar(256) = 'VDF' 
declare @ReportType as varchar(256) = 'VOLTE'

-------------------------------------------------------------------------------
--	Cliente: declaramos el tipo de cliente para hacer el filtro modulable
-------------------------------------------------------------------------------

declare @client as int
set @client= case when (@EntityList='MUN' or @EntityList='OSP') then 3
					when @EntityList='VDF' then 1
			end

declare @Indoor as int
set @Indoor= case when @type='M2M' then 0
				  when @type='M2F' and db_name() like '%indoor%' then 1
				  when @type='M2F' and db_name() like '%ave%' then 2
			end



EXEC [DBO].sp_MDD_Voice_GLOBAL_FILTER_PRUEBA @ciudad, @simOperator,'%%',@Indoor,@EntityList,@ReportType
EXEC [DBO].sp_MDD_Voice_GLOBAL_FILTER_PRUEBA_2 @ciudad, @simOperator,'%%',@Indoor,@EntityList,@ReportType


