/**********************************************
 Curso Query Tuning
 Autor: Landry D. Salles Filho
 Módulo 06 - Exercícios
***********************************************/
USE tempdb
go

/**************************
 Script 1
***************************/
IF object_id('tempdb.dbo.Customer') is not null
   DROP TABLE tempdb.dbo.Customer

SELECT c.CustomerID as CustomerID,FirstName,cast(MiddleName as char(4000)) as MiddleName,Lastname,PersonType,
EmailPromotion,'RJ' as Region, dateadd(d,-BusinessEntityID,getdate()) DataCadastro 
INTO tempdb.dbo.Customer
FROM AdventureWorks2014.Sales.Customer c 
JOIN AdventureWorks2014.Person.Person p ON p.BusinessEntityID = c.PersonID

IF object_id('tempdb.dbo.SalesOrderHeader') is not null
   DROP TABLE tempdb.dbo.SalesOrderHeader

SELECT SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, 
SalesOrderNumber, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, 
SubTotal, TaxAmt, Freight, TotalDue, Comment, ModifiedDate,cast('' as char(5000)) as Obs
INTO tempdb.dbo.SalesOrderHeader
FROM AdventureWorks2014.Sales.SalesOrderHeader

IF object_id('tempdb.dbo.SalesOrderDetail') is not null
   DROP TABLE tempdb.dbo.SalesOrderDetail

SELECT SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty, ProductID, 
SpecialOfferID, UnitPrice, UnitPriceDiscount, LineTotal, rowguid, ModifiedDate,cast('' as char(5000)) as Obs
INTO tempdb.dbo.SalesOrderDetail
FROM AdventureWorks2014.Sales.SalesOrderDetail

SET STATISTICS IO ON
/******************************************************/

/******************************************
 Exercício 1
*******************************************/
SELECT OrderDate,SalesOrderID,Status,SubTotal
FROM tempdb.dbo.SalesOrderHeader
WHERE OrderDate BETWEEN '20130401' AND '20130501'



/******************************************
 Exercício 2
*******************************************/
SELECT FirstName, LastName, CustomerID
FROM tempdb.dbo.Customer
WHERE LastName LIKE 'Z%'
ORDER BY FirstName


/******************************************
 Exercício 3
*******************************************/
SELECT SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty, ProductID, 
SpecialOfferID, UnitPrice, UnitPriceDiscount, LineTotal, rowguid, ModifiedDate,cast('' as char(5000)) as Obs
FROM tempdb.dbo.SalesOrderDetail
