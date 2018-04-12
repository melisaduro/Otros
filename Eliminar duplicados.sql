use OSP1617_Data_Rest_3G_H1_2

--LCC_Data_HTTPTranfer_DL
select testid, count(1) as 'Num_test'
from [dbo].[Lcc_Data_HTTPTransfer_DL] 
group by collectionname,testid
having count(1)>1 

WITH myquery AS
(select ROW_NUMBER() OVER(partition by testid order by testid) as idx,*  from
[dbo].[Lcc_Data_HTTPTransfer_DL] ) --select * from myquery where idx>1 into myquery_backup from myquery --where idx>1
delete from myquery where idx > 1 

select *
from [dbo].[Lcc_Data_HTTPTransfer_DL] 
order by testid

--LCC_Data_HTTPTranfer_UL
select testid, collectionname, count(1) as 'Num_test'
from [dbo].[Lcc_Data_HTTPTransfer_UL] 
group by collectionname,testid
having count(1)>1 

WITH myquery AS
(select ROW_NUMBER() OVER(partition by testid order by testid) as idx,*  from
[dbo].[Lcc_Data_HTTPTransfer_UL] ) --select * from myquery where idx>1 into myquery_backup from myquery --where idx>1
delete from myquery where idx > 1 

select testid
from [dbo].[Lcc_Data_HTTPTransfer_UL] 
order by testid


--LCC_Data_HTTPBrowser
select testid, count(1) as 'Num_test'
from [dbo].[Lcc_Data_HTTPBrowser] 
group by collectionname,testid
having count(1)>1 

WITH myquery AS
(select ROW_NUMBER() OVER(partition by testid order by testid) as idx,*  from
[dbo].[Lcc_Data_HTTPBrowser]) --select * from myquery where idx>1 into myquery_temporal from myquery from myquery --select * into myquery_temporal from myquery  
delete from myquery where idx > 1 

select testid
from [dbo].[Lcc_Data_HTTPBrowser] 
order by testid

--Lcc_Data_Latencias
select testid, count(1) as 'Num_test'
from [dbo].[Lcc_Data_Latencias] 
group by collectionname,testid
having count(1)>1 

WITH myquery AS
(select ROW_NUMBER() OVER(partition by testid order by testid) as idx,*  from
[dbo].[Lcc_Data_Latencias] ) --select * from myquery where idx>1--select * into myquery_temporal from myquery  --select * from myquery
delete from myquery where idx > 1 

select testid
from [dbo].[Lcc_Data_Latencias] 
order by testid

--Lcc_Data_YOUTUBE
select testid, count(1) as 'Num_test'
from [dbo].[Lcc_Data_YOUTUBE] 
group by collectionname,testid
having count(1)>1 

WITH myquery AS
(select ROW_NUMBER() OVER(partition by testid order by testid) as idx,*  from
[dbo].[Lcc_Data_YOUTUBE] ) --select * from myquery where idx>1 --select * into myquery_temporal from myquery--select * from myquery  
delete from myquery where idx > 1 

select testid
from [dbo].[Lcc_Data_Latencias] 
order by testid



