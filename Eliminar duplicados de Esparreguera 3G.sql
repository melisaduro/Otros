use OSP1617_Data_Rest_3G_H1_2

--LCC_Data_HTTPTranfer_DL
select testid, count(1) as 'Num_test'
from [dbo].[Lcc_Data_HTTPTransfer_DL] 
where collectionname like '%esparreguera%'
group by collectionname,testid
having count(1)>1 

WITH myquery AS
(select ROW_NUMBER() OVER(partition by testid order by testid) as idx,*  from
[dbo].[Lcc_Data_HTTPTransfer_DL] 
where collectionname like '%esparreguera%')
--delete from myquery where idx > 1 

select testid,*
from [dbo].[Lcc_Data_HTTPTransfer_DL] 
where collectionname like '%esparreguera%'
order by testid

--LCC_Data_HTTPTranfer_UL
select testid, count(1) as 'Num_test'
from [dbo].[Lcc_Data_HTTPTransfer_UL] 
where collectionname like '%esparreguera%'
group by collectionname,testid
having count(1)>1 

WITH myquery AS
(select ROW_NUMBER() OVER(partition by testid order by testid) as idx,*  from
[dbo].[Lcc_Data_HTTPTransfer_UL] 
where collectionname like '%esparreguera%') --select * into myquery_temporal from myquery  
--delete from myquery where idx > 1 

select testid
from [dbo].[Lcc_Data_HTTPTransfer_UL] 
where collectionname like '%esparreguera%'
order by testid


--LCC_Data_HTTPBrowser
select testid, count(1) as 'Num_test'
from [dbo].[Lcc_Data_HTTPBrowser] 
where collectionname like '%esparreguera%'
group by collectionname,testid
having count(1)>1 

WITH myquery AS
(select ROW_NUMBER() OVER(partition by testid order by testid) as idx,*  from
[dbo].[Lcc_Data_HTTPBrowser] 
where collectionname like '%esparreguera%') --select * from myquery --select * into myquery_temporal from myquery  
--delete from myquery where idx > 1 

select testid
from [dbo].[Lcc_Data_HTTPBrowser] 
where collectionname like '%esparreguera%'
order by testid

--Lcc_Data_Latencias
select testid, count(1) as 'Num_test'
from [dbo].[Lcc_Data_Latencias] 
where collectionname like '%esparreguera%'
group by collectionname,testid
having count(1)>1 

WITH myquery AS
(select ROW_NUMBER() OVER(partition by testid order by testid) as idx,*  from
[dbo].[Lcc_Data_Latencias] 
where collectionname like '%esparreguera%') --select * from myquery--select * into myquery_temporal from myquery  
--delete from myquery where idx > 1 

select testid
from [dbo].[Lcc_Data_Latencias] 
where collectionname like '%esparreguera%'
order by testid

--Lcc_Data_YOUTUBE
select testid, count(1) as 'Num_test'
from [dbo].[Lcc_Data_YOUTUBE] 
where collectionname like '%esparreguera%'
group by collectionname,testid
having count(1)>1 

WITH myquery AS
(select ROW_NUMBER() OVER(partition by testid order by testid) as idx,*  from
[dbo].[Lcc_Data_YOUTUBE] 
where collectionname like '%esparreguera%') --select * from myquery--select * into myquery_temporal from myquery  
--delete from myquery where idx > 1 

select testid
from [dbo].[Lcc_Data_Latencias] 
where collectionname like '%esparreguera%'
order by testid



