select *
from FY1617_DATA_Rest_4G_H2_3.dbo.filelist f, FY1617_DATA_Rest_4G_H2_3.dbo.sessions s
where collectionname not in ((select collectionname COLLATE SQL_Latin1_General_CP1_CI_AS from collectionnames_abril)  )
and f.fileid=s.fileid

use FY1617_Voice_Rest_3G_H2_3
SELECT
    col.name, col.collation_name
FROM 
    sys.columns col
WHERE
    object_id = OBJECT_ID('filelist')


select OBJECT_ID('filelist') from sys.tables
use FY1617_TEST_CECI
SELECT
    col.name, col.collation_name
FROM 
    sys.columns col
WHERE
    object_id = OBJECT_ID('collectionnames_abril')

