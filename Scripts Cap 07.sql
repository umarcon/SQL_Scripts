/**********************************************************************
 Livro: Otimizando Consultas no Microsoft SQL Server
 Autor: Landry Duailibe Salles Filho

 Data: 11/08/2014

 Scripts Capitulo 07

 Descrição: Scripts utilizados no corpo do livro
***********************************************************************/
USE tempdb
go

/**************************
 AdventureWorks2008R2
***************************/
IF object_id('tempdb.dbo.Customer') is not null
   DROP TABLE tempdb.dbo.Customer

SELECT c.CustomerID as CustomerID,FirstName,MiddleName,Lastname,PersonType,
EmailPromotion,'RJ' as Region, dateadd(d,-BusinessEntityID,getdate()) DataCadastro 
INTO tempdb.dbo.Customer
FROM AdventureWorks2008R2.Sales.Customer c 
JOIN AdventureWorks2008R2.Person.Person p ON p.BusinessEntityID = c.PersonID

IF object_id('tempdb.dbo.SalesOrderHeader') is not null
   DROP TABLE tempdb.dbo.SalesOrderHeader

SELECT SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, 
SalesOrderNumber, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, 
SubTotal, TaxAmt, Freight, TotalDue, Comment, ModifiedDate
INTO tempdb.dbo.SalesOrderHeader
FROM AdventureWorks2008R2.Sales.SalesOrderHeader

IF object_id('tempdb.dbo.SalesOrderDetail') is not null
   DROP TABLE tempdb.dbo.SalesOrderDetail

SELECT SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty, ProductID, 
SpecialOfferID, UnitPrice, UnitPriceDiscount, LineTotal, rowguid, ModifiedDate
INTO tempdb.dbo.SalesOrderDetail
FROM AdventureWorks2008R2.Sales.SalesOrderDetail

/**************************
 AdventureWorks2012
***************************/
IF object_id('tempdb.dbo.Customer') is not null
   DROP TABLE tempdb.dbo.Customer

SELECT c.CustomerID as CustomerID,FirstName,MiddleName,Lastname,PersonType,
EmailPromotion,'RJ' as Region, dateadd(d,-BusinessEntityID,getdate()) DataCadastro 
INTO tempdb.dbo.Customer
FROM AdventureWorks2012.Sales.Customer c 
JOIN AdventureWorks2012.Person.Person p ON p.BusinessEntityID = c.PersonID

IF object_id('tempdb.dbo.SalesOrderHeader') is not null
   DROP TABLE tempdb.dbo.SalesOrderHeader

SELECT SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, 
SalesOrderNumber, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, 
SubTotal, TaxAmt, Freight, TotalDue, Comment, ModifiedDate
INTO tempdb.dbo.SalesOrderHeader
FROM AdventureWorks2012.Sales.SalesOrderHeader

IF object_id('tempdb.dbo.SalesOrderDetail') is not null
   DROP TABLE tempdb.dbo.SalesOrderDetail

SELECT SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty, ProductID, 
SpecialOfferID, UnitPrice, UnitPriceDiscount, LineTotal, rowguid, ModifiedDate
INTO tempdb.dbo.SalesOrderDetail
FROM AdventureWorks2012.Sales.SalesOrderDetail

/**************************
 AdventureWorks2014
***************************/
IF object_id('tempdb.dbo.Customer') is not null
   DROP TABLE tempdb.dbo.Customer

SELECT c.CustomerID as CustomerID,FirstName,MiddleName,Lastname,PersonType,
EmailPromotion,'RJ' as Region, dateadd(d,-BusinessEntityID,getdate()) DataCadastro 
INTO tempdb.dbo.Customer
FROM AdventureWorks2014.Sales.Customer c 
JOIN AdventureWorks2014.Person.Person p ON p.BusinessEntityID = c.PersonID

IF object_id('tempdb.dbo.SalesOrderHeader') is not null
   DROP TABLE tempdb.dbo.SalesOrderHeader

SELECT SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, 
SalesOrderNumber, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, 
SubTotal, TaxAmt, Freight, TotalDue, Comment, ModifiedDate
INTO tempdb.dbo.SalesOrderHeader
FROM AdventureWorks2014.Sales.SalesOrderHeader

IF object_id('tempdb.dbo.SalesOrderDetail') is not null
   DROP TABLE tempdb.dbo.SalesOrderDetail

SELECT SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty, ProductID, 
SpecialOfferID, UnitPrice, UnitPriceDiscount, LineTotal, rowguid, ModifiedDate
INTO tempdb.dbo.SalesOrderDetail
FROM AdventureWorks2014.Sales.SalesOrderDetail

SET STATISTICS IO ON

/***********************************************************
 Script 7.1
 - Indice não atende por completo a consulta
************************************************************/
CREATE INDEX IX_SalesOrderHeader_OrderDate 
ON tempdb.dbo.SalesOrderHeader (OrderDate)

-- Consulta 1
SELECT OrderDate,SalesOrderID,Status,SubTotal
FROM tempdb.dbo.SalesOrderHeader
WHERE OrderDate BETWEEN '20130401' AND '20130531'
--WHERE OrderDate BETWEEN '20080401' AND '20080531'
-- Table 'SalesOrderHeader'. Scan count 1, logical reads 567

-- Consulta 2
SELECT OrderDate,SalesOrderID,Status,SubTotal
FROM tempdb.dbo.SalesOrderHeader WITH(INDEX(IX_SalesOrderHeader_OrderDate))
WHERE OrderDate BETWEEN '20130401' AND '20130531'
--WHERE OrderDate BETWEEN '20080401' AND '20080531'
-- Table 'SalesOrderHeader'. Scan count 1, logical reads 861

/***********************************************************
 Script 7.2
 - Covered a Query
************************************************************/
CREATE INDEX IX_SalesOrderHeader_OrderDate 
ON tempdb.dbo.SalesOrderHeader (OrderDate)
INCLUDE (SalesOrderID,Status,SubTotal)
WITH DROP_EXISTING

-- Consulta 1
SELECT OrderDate,SalesOrderID,Status,SubTotal
FROM tempdb.dbo.SalesOrderHeader
WHERE OrderDate BETWEEN '20130401' AND '20130531'
--WHERE OrderDate BETWEEN '20080401' AND '20080531'
-- Table 'SalesOrderHeader'. Scan count 1, logical reads 7

USE tempdb
DROP INDEX dbo.SalesOrderHeader.IX_SalesOrderHeader_OrderDate 

/***********************************************************
 Script 7.3
 - AND
************************************************************/
CREATE INDEX IX_SalesOrderHeader_OnlineOrderFlag
ON tempdb.dbo.SalesOrderHeader (OnlineOrderFlag)
INCLUDE (CustomerID,OrderDate,SalesOrderID,SubTotal)

CREATE INDEX IX_SalesOrderHeader_CustomerID
ON tempdb.dbo.SalesOrderHeader (CustomerID)
INCLUDE (OnlineOrderFlag,OrderDate,SalesOrderID,SubTotal)

SELECT OrderDate,SalesOrderID,OnlineOrderFlag,SubTotal
FROM tempdb.dbo.SalesOrderHeader
WHERE OnlineOrderFlag = 0 AND CustomerID = 29510
-- INDEX SEEK: Table 'SalesOrderHeader'. Scan count 1, logical reads 2

SELECT OrderDate,SalesOrderID,OnlineOrderFlag,SubTotal
FROM tempdb.dbo.SalesOrderHeader WITH(INDEX(IX_SalesOrderHeader_OnlineOrderFlag))
WHERE OnlineOrderFlag = 0 AND CustomerID = 29510
-- INDEX SEEK: Table 'SalesOrderHeader'. Scan count 1, logical reads 21

/***********************************************************
 Script 7.4
 - AND
************************************************************/
SELECT OrderDate,SalesOrderID,OnlineOrderFlag,SubTotal
FROM tempdb.dbo.SalesOrderHeader
WHERE OnlineOrderFlag = 0
-- 3.806 linhas
-- Table 'SalesOrderHeader'. Scan count 1, logical reads 21

SELECT OrderDate,SalesOrderID,OnlineOrderFlag,SubTotal
FROM tempdb.dbo.SalesOrderHeader
WHERE CustomerID = 29510
-- 4 linhas
-- Table 'SalesOrderHeader'. Scan count 1, logical reads 2

USE tempdb
DROP INDEX dbo.SalesOrderHeader.IX_SalesOrderHeader_OnlineOrderFlag 
DROP INDEX dbo.SalesOrderHeader.IX_SalesOrderHeader_CustomerID 


/***********************************************************
 Script 7.5
 - OR
************************************************************/
CREATE INDEX IX_SalesOrderHeader_OnlineOrderFlag
ON tempdb.dbo.SalesOrderHeader (OnlineOrderFlag)
INCLUDE (CustomerID,OrderDate,SalesOrderID,SubTotal)

SELECT OrderDate,SalesOrderID,OnlineOrderFlag,SubTotal
FROM tempdb.dbo.SalesOrderHeader
WHERE OnlineOrderFlag = 0 OR CustomerID = 29510
-- INDEX SCAN: Table 'SalesOrderHeader'. Scan count 1, logical reads 155


/***********************************************************
 Script 7.6
 - OR
************************************************************/
CREATE INDEX IX_SalesOrderHeader_CustomerID
ON tempdb.dbo.SalesOrderHeader (CustomerID)
INCLUDE (OnlineOrderFlag,OrderDate,SalesOrderID,SubTotal)

SELECT OrderDate,SalesOrderID,OnlineOrderFlag,SubTotal
FROM tempdb.dbo.SalesOrderHeader
WHERE OnlineOrderFlag = 0 OR CustomerID = 29510
-- Table 'SalesOrderHeader'. Scan count 2, logical reads 23

USE tempdb
DROP INDEX dbo.SalesOrderHeader.IX_SalesOrderHeader_OnlineOrderFlag 
DROP INDEX dbo.SalesOrderHeader.IX_SalesOrderHeader_CustomerID

/***********************************************************
 Script 7.7
 - Hash JOIN
************************************************************/

SELECT h.SalesOrderID, h.OrderDate, h.[Status], h.CustomerID, c.FirstName,c.LastName
FROM tempdb.dbo.SalesOrderHeader h JOIN tempdb.dbo.Customer c ON h.CustomerID = c.CustomerID
WHERE h.OrderDate >= '20120101' and  h.OrderDate < '20130101'
-- WHERE h.OrderDate >= '20060101' and  h.OrderDate < '20070101'
-- Table 'Workfile'. Scan count 0, logical reads 0
-- Table 'Worktable'. Scan count 0, logical reads 0
-- Table 'Customer'. Scan count 1, logical reads 155
-- Table 'SalesOrderHeader'. Scan count 1, logical reads 567


/***********************************************************
 Script 7.8
 - Nested Loop JOIN
************************************************************/
CREATE INDEX IX_Customer_CustomerID
ON tempdb.dbo.Customer (CustomerID)
INCLUDE (FirstName,LastName)

CREATE INDEX IX_SalesOrderHeader_OrderDate
ON tempdb.dbo.SalesOrderHeader (OrderDate)
INCLUDE (CustomerID,SalesOrderID,[Status],SubTotal)

SELECT h.SalesOrderID, h.OrderDate, h.[Status], h.CustomerID, c.FirstName,c.LastName
FROM tempdb.dbo.SalesOrderHeader h JOIN tempdb.dbo.Customer c ON h.CustomerID = c.CustomerID
WHERE h.OrderDate >= '20120102' and  h.OrderDate < '20120103'
--WHERE h.OrderDate >= '20060101' and  h.OrderDate < '20060102'
-- Table 'Customer'. Scan count 6, logical reads 12
-- Table 'SalesOrderHeader'. Scan count 1, logical reads 2

USE tempdb
DROP INDEX dbo.Customer.IX_Customer_CustomerID 
DROP INDEX dbo.SalesOrderHeader.IX_SalesOrderHeader_OrderDate

/***********************************************************
 Figura 7.6
 - Nested Loop JOIN
************************************************************/
CREATE INDEX IX_Customer_CustomerID
ON tempdb.dbo.Customer (CustomerID)
INCLUDE (FirstName,LastName)

CREATE INDEX IX_SalesOrderHeader_OrderDate
ON tempdb.dbo.SalesOrderHeader (OrderDate)
INCLUDE (CustomerID,SalesOrderID,[Status],SubTotal)

SELECT h.SalesOrderID, h.OrderDate, h.[Status], h.CustomerID, c.FirstName,c.LastName
FROM tempdb.dbo.SalesOrderHeader h JOIN tempdb.dbo.Customer c ON h.CustomerID = c.CustomerID
WHERE h.OrderDate >= '20120101' and  h.OrderDate < '20120102'
--WHERE h.OrderDate >= '20060101' and  h.OrderDate < '20060102'
-- Table 'Customer'. Scan count 6, logical reads 12
-- Table 'SalesOrderHeader'. Scan count 1, logical reads 2

USE tempdb
DROP INDEX dbo.Customer.IX_Customer_CustomerID 
DROP INDEX dbo.SalesOrderHeader.IX_SalesOrderHeader_OrderDate

/***********************************************************
 Script 7.9
 - Merge JOIN
************************************************************/
CREATE UNIQUE INDEX IX_Customer_CustomerID
ON tempdb.dbo.Customer (CustomerID)
INCLUDE (FirstName,LastName)

CREATE INDEX IX_SalesOrderHeader_CustomerID
ON tempdb.dbo.SalesOrderHeader (CustomerID)
INCLUDE (SalesOrderID,OrderDate,[Status],SubTotal)

SELECT h.SalesOrderID, h.OrderDate, h.[Status], h.CustomerID, c.FirstName,c.LastName
FROM tempdb.dbo.SalesOrderHeader h JOIN tempdb.dbo.Customer c ON h.CustomerID = c.CustomerID
WHERE h.OrderDate >= '20120101' and  h.OrderDate < '20130101'
--WHERE h.OrderDate >= '20060101' and  h.OrderDate < '20070101'
-- Table 'SalesOrderHeader'. Scan count 1, logical reads 155
-- Table 'Customer'. Scan count 1, logical reads 114

USE tempdb
DROP INDEX dbo.Customer.IX_Customer_CustomerID 
DROP INDEX dbo.SalesOrderHeader.IX_SalesOrderHeader_CustomerID
