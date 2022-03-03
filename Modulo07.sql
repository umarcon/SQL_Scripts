/**********************************************
 Curso Query Tuning
 Autor: Landry D. Salles Filho
 Módulo 07 - Exercícios
***********************************************/
USE tempdb
go

/**************************
 Prepara Ambiente
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
SubTotal, TaxAmt, Freight, TotalDue, Comment, ModifiedDate
INTO tempdb.dbo.SalesOrderHeader
FROM AdventureWorks2014.Sales.SalesOrderHeader

SET STATISTICS IO ON
/******************************************************/

/******************************************
 Exercício 1
*******************************************/
SELECT FirstName, LastName, CustomerID
FROM tempdb.dbo.Customer 
WHERE PersonType = 'SC' AND EmailPromotion = 2
ORDER BY FirstName


/******************************************
 Exercício 2
*******************************************/
SELECT FirstName, LastName, CustomerID
FROM tempdb.dbo.Customer 
WHERE PersonType = 'SC' OR EmailPromotion = 2
ORDER BY FirstName


/******************************************
 Exercício 3
*******************************************/
SELECT h.SalesOrderID, h.OrderDate, h.[Status], h.CustomerID, c.FirstName,c.LastName
FROM tempdb.dbo.SalesOrderHeader h JOIN tempdb.dbo.Customer c ON h.CustomerID = c.CustomerID
WHERE h.OrderDate >= '20120101' and  h.OrderDate < '20120102'

