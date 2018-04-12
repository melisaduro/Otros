SELECT
    DB_NAME(db.database_id) DatabaseName,
    (CAST(mfrows.RowSize AS FLOAT)*8)/(1024*1024) RowSizeGB,
    (CAST(mflog.LogSize AS FLOAT)*8)/(1024*1024) LogSizeGB
FROM sys.databases db
    LEFT JOIN (SELECT database_id, SUM(size) RowSize FROM sys.master_files
                   WHERE type = 0 GROUP BY database_id, type) mfrows ON mfrows.database_id = db.database_id
    LEFT JOIN (SELECT database_id, SUM(size) LogSize FROM sys.master_files
                   WHERE type = 1 GROUP BY database_id, type) mflog ON mflog.database_id = db.database_id
order by 1