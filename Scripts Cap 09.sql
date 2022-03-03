/**********************************************************************
 Livro: Otimizando Consultas no Microsoft SQL Server
 Autor: Landry Duailibe Salles Filho

 Data: 10/10/2014

 Scripts Capitulo 09

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
 Script 9.1
 - Hints para Joins
************************************************************/
-- Consulta 1
SELECT h.SalesOrderID, h.OrderDate, h.[Status], 
h.CustomerID, c.FirstName, c.LastName
FROM tempdb.dbo.SalesOrderHeader h 
JOIN tempdb.dbo.Customer c ON h.CustomerID = c.CustomerID
-- Customer -> SalesOrderHeader

-- Consulta 2
SELECT h.SalesOrderID, h.OrderDate, h.[Status], 
h.CustomerID, c.FirstName,c.LastName
FROM tempdb.dbo.SalesOrderHeader h 
INNER HASH JOIN tempdb.dbo.Customer c ON h.CustomerID = c.CustomerID
-- SalesOrderHeader -> Customer 


/***********************************************************
 Script 9.2
 - Hints para Joins (FORCE ORDER)
************************************************************/
SELECT h.SalesOrderID, h.OrderDate, h.[Status], h.CustomerID, c.FirstName,c.LastName
FROM tempdb.dbo.SalesOrderHeader h JOIN tempdb.dbo.Customer c ON h.CustomerID = c.CustomerID
OPTION (FORCE ORDER)
-- Customer -> SalesOrderHeader


/***********************************************************
 Script 9.3
 - Hints de Tabela
************************************************************/
CREATE INDEX IX_Customer_Lastname ON tempdb.dbo.Customer(Lastname)

-- Obriga o uso do índice IX_Customer_Lastname
SELECT * 
FROM tempdb.dbo.Customer WITH(INDEX(IX_Customer_Lastname))
WHERE Lastname = N'Adams'
-- Table 'Customer'. Scan count 1, logical reads 87

-- Obriga o uso de Table Scan
SELECT * 
FROM tempdb.dbo.Customer WITH(INDEX(0))
WHERE Lastname = N'Adams'
-- Table 'Customer'. Scan count 1, logical reads 155

use tempdb
DROP INDEX dbo.Customer.IX_Customer_Lastname

/***********************************************************
 Script 9.4
 - Hints de consulta
************************************************************/
SELECT * FROM tempdb.dbo.SalesOrderDetail 
ORDER BY ProductID

SELECT * FROM tempdb.dbo.SalesOrderDetail 
ORDER BY ProductID
OPTION(MAXDOP 1)

/***********************************************************
 Script 9.5
 - Hints de consulta
************************************************************/
SELECT * FROM tempdb.dbo.SalesOrderDetail ORDER BY ProductID
OPTION(MAXDOP 1)
 

/***********************************************************
 Script 9.6
 - Hints de consulta
************************************************************/
EXEC sp_create_plan_guide 
@name = N'Teste Serial', 
@stmt = N'SELECT * FROM tempdb.dbo.SalesOrderDetail ORDER BY ProductID', 
@type = N'SQL',
@module_or_batch = NULL, 
@params = NULL, 
@hints = N'OPTION(MAXDOP 1)'

SELECT * FROM sys.plan_guides

SELECT * FROM tempdb.dbo.SalesOrderDetail ORDER BY ProductID

-- Desabilita Plan Guide
EXEC sp_control_plan_guide N'DISABLE', N'Teste Serial'

-- Habilita Plan Guide
EXEC sp_control_plan_guide N'ENABLE', N'Teste Serial'

-- Exclui Plan Guide
EXEC sp_control_plan_guide N'DROP', N'Teste Serial'


