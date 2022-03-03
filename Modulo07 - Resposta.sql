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

SELECT count(*) FROM tempdb.dbo.Customer
WHERE PersonType = 'SC'
-- 635 linhas

SELECT count(*) FROM tempdb.dbo.Customer
WHERE EmailPromotion = 2
-- 3609 linhas

SELECT PersonType,count(*)
FROM tempdb.dbo.Customer
GROUP BY PersonType

-- Missing Index
CREATE NONCLUSTERED INDEX MI_Customer_PersonType_EmailPromotion
ON dbo.Customer (PersonType,EmailPromotion)
INCLUDE (CustomerID,FirstName,Lastname)

-- Sugestão do DTA
CREATE NONCLUSTERED INDEX DTA_Customer_EmailPromotion_PersonType
ON dbo.Customer (EmailPromotion,PersonType,FirstName)
INCLUDE (CustomerID,Lastname)

-- Índice ideal
CREATE INDEX IX_Customer_PersonType_EmailPromotion
ON dbo.Customer (PersonType,EmailPromotion,FirstName)
INCLUDE (CustomerID,Lastname)
-- Table 'Customer'. Scan count 1, logical reads 4

DROP INDEX dbo.Customer.MI_Customer_PersonType_EmailPromotion
DROP INDEX dbo.Customer.DTA_Customer_EmailPromotion_PersonType
DROP INDEX dbo.Customer.IX_Customer_PersonType_EmailPromotion

/******************************************
 Exercício 2
*******************************************/
SELECT FirstName, LastName, CustomerID
FROM tempdb.dbo.Customer 
WHERE PersonType = 'SC' OR EmailPromotion = 2
ORDER BY FirstName

-- Sem Missing Index


-- Sugestão do DTA
CREATE NONCLUSTERED INDEX DTA_Customer_FirstName_PersonType
ON dbo.Customer (FirstName,PersonType,EmailPromotion)
INCLUDE (CustomerID,Lastname)
-- Table 'Customer'. Scan count 1, logical reads 133

-- Índice ideal ???
CREATE NONCLUSTERED INDEX IX_Customer_PersonType_EmailPromotion
ON dbo.Customer (PersonType,EmailPromotion,FirstName)
INCLUDE (CustomerID,Lastname)

CREATE NONCLUSTERED INDEX IX_Customer_EmailPromotion_PersonType
ON dbo.Customer (EmailPromotion,PersonType,FirstName)
INCLUDE (CustomerID,Lastname)
-- Table 'Customer'. Scan count 2, logical reads 36

DROP INDEX dbo.Customer.DTA_Customer_FirstName_PersonType
DROP INDEX dbo.Customer.IX_Customer_PersonType_EmailPromotion
DROP INDEX dbo.Customer.IX_Customer_EmailPromotion_PersonType

-- Alternativo um indice Cover
CREATE NONCLUSTERED INDEX IX_Customer_FirstName
ON dbo.Customer (FirstName)
INCLUDE (CustomerID,Lastname,EmailPromotion,PersonType)
-- Table 'Customer'. Scan count 1, logical reads 133

DROP INDEX dbo.Customer.IX_Customer_FirstName

/******************************************
 Exercício 3
*******************************************/
SELECT h.SalesOrderID, h.OrderDate, h.[Status], h.CustomerID, c.FirstName,c.LastName
FROM tempdb.dbo.SalesOrderHeader h JOIN tempdb.dbo.Customer c ON h.CustomerID = c.CustomerID
WHERE h.OrderDate >= '20120101' and  h.OrderDate < '20120102'
-- Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Customer'. Scan count 1, logical reads 19119, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'SalesOrderHeader'. Scan count 1, logical reads 564, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

-- Missing Index 1
CREATE NONCLUSTERED INDEX MI_Customer_CustomerID
ON dbo.Customer (CustomerID)
INCLUDE (FirstName,Lastname)

-- Missing Index 2
CREATE NONCLUSTERED INDEX MI_SalesOrderHeader_OrderDate
ON dbo.SalesOrderHeader (OrderDate)
INCLUDE (SalesOrderID,Status,CustomerID)
-- Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Customer'. Scan count 1, logical reads 114, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'SalesOrderHeader'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

DROP INDEX dbo.Customer.MI_Customer_CustomerID
DROP INDEX dbo.SalesOrderHeader.MI_SalesOrderHeader_OrderDate


-- Sugestão do DTA
CREATE NONCLUSTERED INDEX DTA_Customer_CustomerID
ON dbo.Customer (CustomerID)
INCLUDE (FirstName,Lastname)

CREATE NONCLUSTERED INDEX DTA_SalesOrderHeader_OrderDate
ON dbo.SalesOrderHeader (OrderDate,CustomerID)
INCLUDE (SalesOrderID,Status)
-- Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'Customer'. Scan count 1, logical reads 114, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
-- Table 'SalesOrderHeader'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

DROP INDEX dbo.Customer.DTA_Customer_CustomerID
DROP INDEX dbo.SalesOrderHeader.DTA_SalesOrderHeader_OrderDate

-- Índice ideal para Merge Join
CREATE UNIQUE NONCLUSTERED INDEX IX_Customer_CustomerID
ON dbo.Customer (CustomerID)
INCLUDE (FirstName,Lastname)

CREATE INDEX IX_SalesOrderHeader_CustomerID
ON tempdb.dbo.SalesOrderHeader (CustomerID)
INCLUDE (SalesOrderID,OrderDate,[Status],SubTotal)
-- Table 'SalesOrderHeader'. Scan count 1, logical reads 155
-- Table 'Customer'. Scan count 1, logical reads 114
