/**********************************************************************
 Livro: Otimizando Consultas no Microsoft SQL Server
 Autor: Landry Duailibe Salles Filho

 Data: 11/08/2014

 Scripts Capitulo 06

 Descrição: Scripts utilizados no corpo do livro
***********************************************************************/
USE tempdb
go

/**************************
 AdventureWorks2008R2
***************************/
IF object_id('tempdb.dbo.Customer') is not null
   DROP TABLE tempdb.dbo.Customer

SELECT BusinessEntityID as CustomerID,FirstName,MiddleName,Lastname,PhoneNumber,
EmailAddress,AddressLine1 as Address,'RJ' as Region, dateadd(d,-BusinessEntityID,getdate()) DataCadastro 
INTO tempdb.dbo.Customer
FROM AdventureWorks2008R2.Sales.vIndividualCustomer

IF object_id('tempdb.dbo.SalesOrderHeader') is not null
   DROP TABLE tempdb.dbo.SalesOrderHeader

SELECT SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, 
SalesOrderNumber, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, 
SubTotal, TaxAmt, Freight, TotalDue, Comment, ModifiedDate
INTO tempdb.dbo.SalesOrderHeader
FROM AdventureWorks2008R2.Sales.SalesOrderHeader

/**************************
 AdventureWorks2012
***************************/
IF object_id('tempdb.dbo.Customer') is not null
   DROP TABLE tempdb.dbo.Customer

SELECT BusinessEntityID as CustomerID,FirstName,MiddleName,Lastname,PhoneNumber,
EmailAddress,AddressLine1 as Address,'RJ' as Region, dateadd(d,-BusinessEntityID,getdate()) DataCadastro 
INTO tempdb.dbo.Customer
FROM AdventureWorks2012.Sales.vIndividualCustomer

IF object_id('tempdb.dbo.SalesOrderHeader') is not null
   DROP TABLE tempdb.dbo.SalesOrderHeader

SELECT SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, 
SalesOrderNumber, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, 
SubTotal, TaxAmt, Freight, TotalDue, Comment, ModifiedDate
INTO tempdb.dbo.SalesOrderHeader
FROM AdventureWorks2012.Sales.SalesOrderHeader

/**************************
 AdventureWorks2014
***************************/
IF object_id('tempdb.dbo.Customer') is not null
   DROP TABLE tempdb.dbo.Customer

SELECT BusinessEntityID as CustomerID,FirstName,MiddleName,Lastname,PhoneNumber,
EmailAddress,AddressLine1 as Address,'RJ' as Region, dateadd(d,-BusinessEntityID,getdate()) DataCadastro 
INTO tempdb.dbo.Customer
FROM AdventureWorks2014.Sales.vIndividualCustomer

IF object_id('tempdb.dbo.SalesOrderHeader') is not null
   DROP TABLE tempdb.dbo.SalesOrderHeader

SELECT SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, 
SalesOrderNumber, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, 
SubTotal, TaxAmt, Freight, TotalDue, Comment, ModifiedDate
INTO tempdb.dbo.SalesOrderHeader
FROM AdventureWorks2014.Sales.SalesOrderHeader



/***********************************************************
 Script 6.1
 - Preparando ambiente 
************************************************************/
IF object_id('tempdb.dbo.Customer') is not null
   DROP TABLE tempdb.dbo.Customer

SELECT BusinessEntityID as CustomerID,FirstName,MiddleName,Lastname,PhoneNumber,
EmailAddress,AddressLine1 as Address,'RJ' as Region, dateadd(d,-BusinessEntityID,getdate()) DataCadastro 
INTO tempdb.dbo.Customer
FROM AdventureWorks2014.Sales.vIndividualCustomer

IF object_id('tempdb.dbo.SalesOrderHeader') is not null
   DROP TABLE tempdb.dbo.SalesOrderHeader

SELECT SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, 
SalesOrderNumber, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, 
SubTotal, TaxAmt, Freight, TotalDue, Comment, ModifiedDate
INTO tempdb.dbo.SalesOrderHeader
FROM AdventureWorks2014.Sales.SalesOrderHeader

SET STATISTICS IO ON

/***********************************************************
 Script 6.2
 - Index Seek
************************************************************/
CREATE INDEX IX_Customer_Lastname ON tempdb.dbo.Customer(Lastname,FirstName,PhoneNumber)

SELECT Lastname,FirstName,PhoneNumber 
FROM tempdb.dbo.Customer WHERE Lastname = N'Adams'

USE tempdb
DROP INDEX dbo.Customer.IX_Customer_Lastname 

/***********************************************************
 Script 6.3
 - Index Seek, comparando Clustered e NonClustered
************************************************************/
CREATE INDEX IX_SalesOrderHeader_OrderDate 
ON tempdb.dbo.SalesOrderHeader (OrderDate,SalesOrderID)

SELECT OrderDate,SalesOrderID
FROM tempdb.dbo.SalesOrderHeader WHERE OrderDate BETWEEN '20130401' AND '20130430'
-- Index Seek (NonClustered): Table 'SalesOrderHeader'. Scan count 1, logical reads 4

CREATE CLUSTERED INDEX IX_SalesOrderHeader_OrderDate 
ON tempdb.dbo.SalesOrderHeader (OrderDate,SalesOrderID)
WITH DROP_EXISTING

SELECT OrderDate,SalesOrderID
FROM tempdb.dbo.SalesOrderHeader WHERE OrderDate BETWEEN '20130401' AND '20130430'
-- Cluster Index Seek: Table 'SalesOrderHeader'. Scan count 1, logical reads 12

USE tempdb
DROP INDEX dbo.SalesOrderHeader.IX_SalesOrderHeader_OrderDate 

/***********************************************************
 Script 6.4
 - Index Scan
************************************************************/
CREATE INDEX IXCustomer_Lastname ON tempdb.dbo.Customer (Lastname,FirstName,PhoneNumber)

-- Consulta 1
SELECT Lastname,FirstName,PhoneNumber 
FROM tempdb.dbo.Customer

-- Consulta 2
SELECT Lastname,FirstName,PhoneNumber 
FROM tempdb.dbo.Customer WHERE FirstName = N'Adam'


/***********************************************************
 Script 6.5
 - Table Scan no Heap
************************************************************/
SELECT OrderDate,SalesOrderID
FROM tempdb.dbo.SalesOrderHeader 
WHERE OrderDate BETWEEN '20130401' AND '20130430'
-- Table Scan: Table 'SalesOrderHeader'. Scan count 1, logical reads 566

/***********************************************************
 Script 6.6
 - Clustered Index Scan
************************************************************/
CREATE CLUSTERED INDEX IX_SalesOrderHeader_SalesOrderID 
ON tempdb.dbo.SalesOrderHeader (SalesOrderID)

SELECT OrderDate,SalesOrderID
FROM tempdb.dbo.SalesOrderHeader WHERE OrderDate BETWEEN '20130401' AND '20130430'
-- Table 'SalesOrderHeader'. Scan count 1, logical reads 568



