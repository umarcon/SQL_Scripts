/********************************************************************************
Author: Brent Ozar Unlimited® 
Purpose: Demo some of the peculiarities of heaps in SQL Server. 

This script is for use on TEST servers (not production). It creates 
and drops a database and uses undocumented stored procedures. 

References: We run this script in our video demo on heaps. Check out the 
video for intepretation of the script results and more. 

Usage notes: This demo uses both undocumented and documented procedures in SQL Server. 

This demo also uses sys.dm_db_database_page_allocations, which is a new undocumented 
DMV in  SQL Server 2012. If you're testing these scripts against an earlier version of 

SQL Server, you can use DBCC IND (also undocumented) to see the same information. 
We include an example of DBCC IND with the syntax in the demo. 
**********************************************************************************/

SET STATISTICS IO OFF; 
SET STATISTICS TIME OFF; 
GO 


IF DB_ID('HeapsOfHeaps') IS NOT NULL 
BEGIN 
        USE master; 
        ALTER DATABASE HeapsOfHeaps SET SINGLE_USER WITH ROLLBACK IMMEDIATE; 
        DROP DATABASE HeapsOfHeaps; 
END 
GO 

--Create and use the database. 
--This creates it in the default location with default sizes-- change if you wish. 

CREATE DATABASE HeapsOfHeaps; 
GO 

USE HeapsOfHeaps; 
SET NOCOUNT ON; 
SET STATISTICS IO OFF; 
SET STATISTICS TIME OFF; 
GO 

--Let's create a heap! 
CREATE TABLE dbo.DataPile ( 
datapileid BIGINT IDENTITY  NOT NULL, 
col1 VARCHAR(1024) NOT NULL); 
GO 

--Insert 1000 rows. 
DECLARE @i INT = 1; 
WHILE @i <= 1000 
BEGIN 
        INSERT  dbo.dataPile (col1) 
        SELECT  REPLICATE('A',200) ; 
        SELECT  @i = @i + 1; 
END 
GO 

--Here's a query that will show if you have heaps. 
--You want to look for Index_Id = 0. 
SELECT  sc.name AS [Schema Name], so.name AS [Table_Name]
FROM sys.indexes si 
JOIN sys.objects so ON si.object_id = so.object_id 
JOIN sys.schemas sc ON so.schema_id = sc.schema_id 
WHERE so.is_ms_shipped = 0  /* Not shipped by Microsoft */ 
AND si.index_id = 0 /* Index Id 0 = A Heap */ 
AND so.type = 'U'; /* User table */ 
GO 

--You can also look at the table and TRY to find indexes 
exec sp_helpindex 'DataPile'; 
GO 

--Let's look at the structure of our heap with DBCC IND. 
--This is a special system command (undocumented!). 
--PageType 10= an IAM page (Index Allocation Map). 
--Parameters: DatabaseName, TableName, IndexID 
DBCC IND('HeapsOfHeaps', 'DataPile',0) 
GO 

--In SQL 2012 we can also query a new DMV to see allocations! 
--This DMV is also undocumented. 
--Parameters: DatabaseId, ObjectId, IndexId, PartitionId, mode 
select * 
from sys.dm_db_database_page_allocations(db_id(),object_id('DataPile'),0,null,'DETAILED'); 
GO 

--We can also get information about the table's fragmentation. 
--This is a documented procedure, but I'm running it in detailed mode so it's going to look 
--at all the pages in the active table. Be very careful if you run this in detailed mode 
--against a production database. 
SELECT alloc_unit_type_desc, 
index_depth, page_count, avg_page_space_used_in_percent, 
record_count, forwarded_record_count 
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('DataPile'), 0, NULL,'detailed'); 
GO 

--sys.dm_db_partition_stats looks at the metadata. 
select used_page_count, in_row_used_page_count, reserved_page_count, row_count 
from sys.dm_db_partition_stats 
where object_name(object_id) = 'DataPile'; 

--Let's count how many reads we have to do to scan the table. 
--Run the select, then go to the Messages tab. 
--Look at the number of "logical reads" we did. 
SET STATISTICS IO ON; 
SET STATISTICS TIME ON; 

SELECT * FROM dbo.dataPile; 
-- Table 'DataPile'. Scan count 1, logical reads 29
GO 

--Let's make half of the rows have larger values in them. 
UPDATE dbo.DataPile 
SET col1=REPLICATE('B',1000) 
WHERE dataPileid % 2 = 0; 
GO 

--How many reads does it take to scan the table now? 
--Run the select, then go to the Messages tab. 
--Look at the number of "logical reads" we did. 
SELECT * FROM dbo.dataPile; 
-- Table 'DataPile'. Scan count 1, logical reads 486
GO 

--Why did we do so many more logical reads???? 
--Let's find some information by looking at the table's fragmentation now. 
--Note: look at the record_count column-- we didn't insert any records! 
--It's counting wrong by the number of forwarded records. 
--(That's documented in Books Online, by the way.) 
SELECT alloc_unit_type_desc, 
index_depth, page_count, avg_page_space_used_in_percent, 
record_count, forwarded_record_count 
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('DataPile'), 0, NULL,'detailed'); 
GO 

--We can see something special happened reading, as well. 
--Check out forwarded_fetch_count. 
select leaf_insert_count, leaf_update_count, forwarded_fetch_count 
from sys.dm_db_index_operational_stats(db_id(),object_id('DataPile'),0,null); 
GO 

--What about deletes? 
--Let's delete all of the rows from the table, except for five. 
DELETE FROM dbo.datapile 
where datapileid > 5; 
GO 

--OK, we only have FIVE rows in this table now. We started with 1000. 
--How many reads does it take to read now? 
--Run the select, go to the messages tab, and look at logical reads. 

SELECT * FROM dbo.dataPile; 
-- Table 'DataPile'. Scan count 1, logical reads 88
GO 

--What changed? 
--We got rid of MOST of the forwarded record pointers. 
--But we still have 80+ pages allocated! For only five rows! 

SELECT alloc_unit_type_desc, 
index_depth, page_count, avg_page_space_used_in_percent, 
record_count, forwarded_record_count 
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('DataPile'), 0, NULL,'detailed'); 
GO 

--sys.dm_db_partition_stats agrees that we still have LOTS of pages. 
--It gets the row count right, by the way. 
select used_page_count, in_row_used_page_count, reserved_page_count, row_count 
from sys.dm_db_partition_stats 
where object_name(object_id) = 'DataPile'; 
GO 

--Let's create a nonclustered index on our heap. 
CREATE UNIQUE NONCLUSTERED INDEX ix_datapile_nc_datapileid ON dbo.DataPile (datapileid); 
GO 

--Let's look at what pages are being used for the nonclustered index. 
--We're using the undocumented new DMV again. 
--We have an INDEX page type instead of a DATA page type. */ 
select * 
from sys.dm_db_database_page_allocations(db_id(),object_id('DataPile'),3,null,'DETAILED'); 
GO 

--Now, let's take the index page ID: 
--This is the allocated_page_page_id for the row where page_type_desc=INDEX_PAGE 
--We'll plug it into DBCC PAGE. 
--This is another undocumented procedure that lets us look at page data. 
--Check out the values in the HEAP RID Column and record them. 
DBCC TRACEON (3604); 
DBCC PAGE (HeapsOfHeaps, 1, 284,3) 
GO 

--Now let's rebuild the heap. 
--We can do that-- we can rebuild a heap! (On SQL Server 2008 and above.) 
--Prior to SQL Server 2008, the most popular way to de-fragment a heap is to 
--add and remove a clustered index--- but it has the same impact we'll see here. 
ALTER TABLE dbo.DataPile REBUILD; 
GO 

--Let's check out our nonclustered index... 
select allocated_page_page_id, page_type_desc 
from sys.dm_db_database_page_allocations(db_id(),object_id('DataPile'),3,null,'DETAILED'); 
GO 

--Hey, wait a second, the PAGE IDs are different for the Non-Clustered index. 
--And we didn't rebuild the non-clustered index--- we just asked for a rebuild of the heap! 
--But yet our non-clustered index shows us that it is on totally new pages now. 
--What's up with that???? 

DBCC TRACEON (3604); 
DBCC PAGE (HeapsOfHeaps, 1, 370,3) 
GO 

-- Compare those HEAP RIDS to what you recorded before. 
--We explain why this is and what this means in the video. 
--Wow, rebuilding a big heap with nonclustered indexes could 
--cause LOTS and LOTS of unexpected IO. 
--Really, the times when we want to have a heap in SQL Server are the exception rather than the rule. 
--We like to default to clustered indexes in SQL Server--- 
--unless we have performance tests showing that heaps are better for that use case! 

SELECT * FROM dbo.dataPile; 
-- Table 'DataPile'. Scan count 1, logical reads 2
GO