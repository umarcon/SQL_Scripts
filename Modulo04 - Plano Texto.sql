/**********************************************
 Curso Query Tuning
 Autor: Landry D. Salles Filho
 Módulo 04 - Exercício 1
***********************************************/
USE tempdb
go

/******************************************
 Script 1
*******************************************/
IF object_id('tempdb.dbo.SalesOrderHeader') is not null
   DROP TABLE tempdb.dbo.SalesOrderHeader

SELECT SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, 
SalesOrderNumber, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, 
SubTotal, TaxAmt, Freight, TotalDue, Comment, ModifiedDate
INTO tempdb.dbo.SalesOrderHeader
FROM AdventureWorks2014.Sales.SalesOrderHeader
/*****************************************/


/******************************************
 Script 2
*******************************************/
CREATE INDEX IX_SalesOrderHeader_OrderDate 
ON tempdb.dbo.SalesOrderHeader (OrderDate)
WITH (STATISTICS_NORECOMPUTE = ON)
/*****************************************/

UPDATE TOP(400) tempdb.dbo.SalesOrderHeader SET OrderDate = '20130401'
WHERE OrderDate < '20130401'

SET STATISTICS PROFILE ON

SET STATISTICS PROFILE OFF

SELECT OrderDate,SalesOrderID,Status,SubTotal
FROM tempdb.dbo.SalesOrderHeader
WHERE OrderDate BETWEEN '20130401' AND '20130401'


CREATE INDEX IX_SalesOrderHeader_OrderDate 
ON tempdb.dbo.SalesOrderHeader (OrderDate)
WITH DROP_EXISTING
