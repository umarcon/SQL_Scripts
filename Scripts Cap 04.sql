/**********************************************************************
 Livro: Otimizando Consultas no Microsoft SQL Server
 Autor: Landry Duailibe Salles Filho

 Data: 19/07/2014

 Scripts Capitulo 04

 Descrição: Scripts utilizados no corpo do livro
***********************************************************************/

/*******************
 Plano de Execução
********************/
-- Texto
SET STATISTICS IO ON
SET STATISTICS IO OFF

SET STATISTICS TIME ON
SET STATISTICS TIME OFF

SET STATISTICS PROFILE ON
SET STATISTICS PROFILE OFF

-- XML
SET STATISTICS XML ON
SET STATISTICS XML OFF

/*******************
 Plano Estimado
********************/
-- Texto
SET SHOWPLAN_ALL ON 
SET SHOWPLAN_ALL OFF

-- XML
SET SHOWPLAN_XML ON
SET SHOWPLAN_XML ON


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

/**************************
 AdventureWorks 2008 R2
***************************/
SELECT h.SalesOrderID, h.OrderDate, h.[Status], 
h.CustomerID, p.FirstName, p.LastName
FROM AdventureWorks2008R2.Sales.Customer c
JOIN AdventureWorks2008R2.Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID
JOIN AdventureWorks2008R2.Person.Person p ON p.BusinessEntityID = c.PersonID
WHERE h.OrderDate = '20070415'

/**************************
 AdventureWorks 2012
***************************/
SELECT h.SalesOrderID, h.OrderDate, h.[Status], 
h.CustomerID, p.FirstName, p.LastName
FROM AdventureWorks2012.Sales.Customer c
JOIN AdventureWorks2012.Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID
JOIN AdventureWorks2012.Person.Person p ON p.BusinessEntityID = c.PersonID
WHERE h.OrderDate = '20070415'

/**************************
 AdventureWorks 2014
***************************/
SELECT h.SalesOrderID, h.OrderDate, h.[Status], 
h.CustomerID, p.FirstName, p.LastName
FROM AdventureWorks2014.Sales.Customer c
JOIN AdventureWorks2014.Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID
JOIN AdventureWorks2014.Person.Person p ON p.BusinessEntityID = c.PersonID
WHERE h.OrderDate = '20110604'


/***********************************************************
 Script 4.1
 - SET STATISTICS PROFILE
************************************************************/

SET STATISTICS PROFILE ON
SET STATISTICS PROFILE OFF

SELECT h.SalesOrderID, h.OrderDate, h.[Status], 
h.CustomerID, p.FirstName, p.LastName
FROM AdventureWorks2014.Sales.Customer c
JOIN AdventureWorks2014.Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID
JOIN AdventureWorks2014.Person.Person p ON p.BusinessEntityID = c.PersonID
WHERE h.OrderDate = '20110604'

/***********************************************************
 Script 4.2
 - SET STATISTICS IO 
************************************************************/

SET STATISTICS IO ON
SET STATISTICS IO OFF

SELECT h.SalesOrderID, h.OrderDate, h.[Status], 
h.CustomerID, p.FirstName, p.LastName
FROM AdventureWorks2014.Sales.Customer c
JOIN AdventureWorks2014.Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID
JOIN AdventureWorks2014.Person.Person p ON p.BusinessEntityID = c.PersonID
WHERE h.OrderDate = '20110604'
-- Table 'Person'. Scan count 0, logical reads 15
-- Table 'Customer'. Scan count 0, logical reads 10
-- Table 'SalesOrderHeader'. Scan count 1, logical reads 689


/***********************************************************
 Script 4.3
 - SET STATISTICS TIME
************************************************************/

SET STATISTICS TIME ON
SET STATISTICS TIME OFF

SELECT h.SalesOrderID, h.OrderDate, h.[Status], 
h.CustomerID, p.FirstName, p.LastName
FROM AdventureWorks2014.Sales.Customer c
JOIN AdventureWorks2014.Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID
JOIN AdventureWorks2014.Person.Person p ON p.BusinessEntityID = c.PersonID
WHERE h.OrderDate = '20110604'
/*
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 0 ms.

(5 row(s) affected)

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 1 ms
*/


/***********************************************************
 Script 4.4
 - SET STATISTICS XML
************************************************************/

SET STATISTICS XML ON
SET STATISTICS XML OFF

SELECT h.SalesOrderID, h.OrderDate, h.[Status], 
h.CustomerID, p.FirstName, p.LastName
FROM AdventureWorks2014.Sales.Customer c
JOIN AdventureWorks2014.Sales.SalesOrderHeader h ON c.CustomerID = h.CustomerID
JOIN AdventureWorks2014.Person.Person p ON p.BusinessEntityID = c.PersonID
WHERE h.OrderDate = '20110604'



/**********************************************
 Script 4.5
 - Etapas de um Plano de Execução
***********************************************/

SELECT CustomerID,FirstName,MiddleName,Lastname,PersonType,EmailPromotion,Region,DataCadastro
FROM tempdb.dbo.Customer
-- Table Scan

CREATE UNIQUE CLUSTERED INDEX IX_Customer_CustomerID ON tempdb.dbo.Customer(CustomerID)

SELECT CustomerID,FirstName,MiddleName,Lastname,PersonType,EmailPromotion,Region,DataCadastro
FROM tempdb.dbo.Customer
-- Clustered Index Scan


SELECT CustomerID,FirstName,MiddleName,Lastname,PersonType,EmailPromotion,Region,DataCadastro
FROM tempdb.dbo.Customer
WHERE CustomerID = 11000
-- Clustered Index Seek

CREATE INDEX IX_Customer_FirstName ON tempdb.dbo.Customer(FirstName)

SELECT CustomerID,FirstName,MiddleName,Lastname,PersonType,EmailPromotion,Region,DataCadastro
FROM tempdb.dbo.Customer
WHERE FirstName = 'John'
-- Index Seek (NonClustered)

USE tempdb
go
DROP INDEX dbo.Customer.IX_Customer_FirstName
DROP INDEX dbo.Customer.IX_Customer_CustomerID

/**********************************************
 Script 4.6
 - Etapas de um Plano de Execução: Bookmark
***********************************************/

CREATE INDEX IX_Customer_FirstName ON tempdb.dbo.Customer(FirstName)

SELECT CustomerID,FirstName,MiddleName,Lastname,PersonType,EmailPromotion,Region,DataCadastro
FROM tempdb.dbo.Customer
WHERE FirstName = 'John'
-- RID Lookup

CREATE UNIQUE CLUSTERED INDEX IX_Customer_CustomerID ON tempdb.dbo.Customer(CustomerID)
-- Key Lookup

USE tempdb
go
DROP INDEX dbo.Customer.IX_Customer_FirstName
DROP INDEX dbo.Customer.IX_Customer_CustomerID

/**********************************************
 Script 4.7
 - Etapas de um Plano de Execução: JOIN
***********************************************/

SELECT c.CustomerID,c.FirstName,c.MiddleName,c.Lastname
FROM tempdb.dbo.Customer c
INNER LOOP JOIN tempdb.dbo.SalesOrderHeader h ON c.CustomerID = h.CustomerID
WHERE FirstName = 'John'
OPTION (MAXDOP 1)

SELECT c.CustomerID,c.FirstName,c.MiddleName,c.Lastname
FROM tempdb.dbo.Customer c
INNER MERGE JOIN tempdb.dbo.SalesOrderHeader h ON c.CustomerID = h.CustomerID
WHERE FirstName = 'John'
OPTION (MAXDOP 1)

SELECT c.CustomerID,c.FirstName,c.MiddleName,c.Lastname
FROM tempdb.dbo.Customer c
INNER HASH JOIN tempdb.dbo.SalesOrderHeader h ON c.CustomerID = h.CustomerID
WHERE FirstName = 'John'
OPTION (MAXDOP 1)



/**********************************************
 Script 4.8
 - Etapas de um Plano de Execução: GROUP BY
***********************************************/
CREATE INDEX IX_Customer_Lastname ON tempdb.dbo.Customer(Lastname,FirstName)
CREATE INDEX IX_Customer_FirstName ON tempdb.dbo.Customer(FirstName)

SELECT FirstName, count(*)
FROM tempdb.dbo.Customer
GROUP BY FirstName

USE tempdb
go
DROP INDEX dbo.Customer.IX_Customer_FirstName
DROP INDEX dbo.Customer.IX_Customer_Lastname


/**********************************************
 Script 4.9
 - Etapas de um Plano de Execução: ORDER BY
***********************************************/
CREATE INDEX IX_Customer_Lastname ON tempdb.dbo.Customer(Lastname,FirstName) INCLUDE (CustomerID)
CREATE INDEX IX_Customer_FirstName ON tempdb.dbo.Customer(FirstName,Lastname) INCLUDE (CustomerID)

SELECT FirstName,Lastname,CustomerID
FROM tempdb.dbo.Customer
ORDER BY FirstName,Lastname

USE tempdb
go
DROP INDEX dbo.Customer.IX_Customer_FirstName
DROP INDEX dbo.Customer.IX_Customer_Lastname
