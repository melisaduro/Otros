use FY1718_VOICE_BURGOS_4G_H1
alter table lcc_core_Voice_Configuration_Table
add HO_2G2G varchar(256),HO_2G3G varchar(256),HO_3G2G varchar(256),HO_3G3G varchar(256)

select * from lcc_core_Voice_Configuration_Table
PDP_context varchar(256),SRVCC varchar(256) ,HO_IRAT_2G3G varchar(256),HO_4G3G varchar(256),HO_4G4G varchar(256)

update lcc_core_Voice_Configuration_Table
set PDP_context='15200',
SRVCC='38040, 38050, 38060',
HO_2G2G='34050,34060,34070',
HO_2G3G='35060,35061',
HO_3G2G='35020,35030,35040,35041,35070,35071',
HO_3G3G='35100,35101,35105,35106,35110,35111',
HO_4G3G='38020,38030',
HO_4G4G='38100'

HO_3G3G