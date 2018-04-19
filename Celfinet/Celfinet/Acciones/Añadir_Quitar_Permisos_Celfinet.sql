---------------------------Añadir permisos a usuarios celfinet
use FY1617_Voice_AVE_MAD_SEV_H2_2

CREATE USER [SREPSQLBMVF\celfinet1]
alter user [SREPSQLBMVF\celfinet1] WITH DEFAULT_SCHEMA= dbo
exec sp_addrolemember 'db_datareader', 'SREPSQLBMVF\celfinet1'
exec sp_addrolemember 'db_datawriter', 'SREPSQLBMVF\celfinet1'

CREATE USER [SREPSQLBMVF\celfinet2]
alter user [SREPSQLBMVF\celfinet2] WITH DEFAULT_SCHEMA= dbo
exec sp_addrolemember 'db_datareader', 'SREPSQLBMVF\celfinet2'
exec sp_addrolemember 'db_datawriter', 'SREPSQLBMVF\celfinet2'

CREATE USER [SREPSQLBMVF\VFCEL]
alter user [SREPSQLBMVF\VFCEL] WITH DEFAULT_SCHEMA= dbo
exec sp_addrolemember 'db_datareader', 'SREPSQLBMVF\VFCEL'
exec sp_addrolemember 'db_datawriter', 'SREPSQLBMVF\VFCEL'

CREATE USER [SREPSQLBMVF\VFCEL2]
alter user [SREPSQLBMVF\VFCEL2] WITH DEFAULT_SCHEMA= dbo
exec sp_addrolemember 'db_datareader', 'SREPSQLBMVF\VFCEL2'
exec sp_addrolemember 'db_datawriter', 'SREPSQLBMVF\VFCEL2'

---------------------Quitar permisos a usuarios celfinet
use FY1617_Voice_AVE_MAD_SEV_H2_2

--DROP USER [SREPSQLBMVF\celfinet1]
--DROP USER [SREPSQLBMVF\celfinet2]
--DROP USER [SREPSQLBMVF\VFCEL]
--DROP USER [SREPSQLBMVF\VFCEL2]


