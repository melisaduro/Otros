DECLARE @BatchSize INT, @Criteria varchar(256);

SELECT @BatchSize = 1000, @Criteria = 'FY1718_VOICE_REST_4G_H1_46';

WHILE @@rowcount > 0

BEGIN 

BEGIN TRAN
DELETE TOP (@BatchSize)

FROM Scanner_2G_08

WHERE [DATABASE] = @Criteria;

COMMIT TRAN
END