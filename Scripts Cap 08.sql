/**********************************************************************
 Livro: Otimizando Consultas no Microsoft SQL Server
 Autor: Landry Duailibe Salles Filho

 Data: 02/09/2014

 Scripts Capitulo 08

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

SELECT SalesOrderID, RevisionNumber, OrderDate, DueDate, DATEADD(hh,1,ShipDate) as ShipDate, Status, OnlineOrderFlag, 
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
 Script 8.1
 - Uso de Função em coluna: LEFT, RIGHT
************************************************************/
CREATE INDEX IX_Customer_FirstName ON tempdb.dbo.Customer (FirstName)
INCLUDE (CustomerID, LastName)

-- Consulta 1
SELECT CustomerID, FirstName, LastName
FROM tempdb.dbo.Customer WHERE left(FirstName,1) = 'G'
-- Index Scan: Table 'Customer'. Scan count 1, logical reads 114

-- Consulta 2
SELECT CustomerID, FirstName, LastName
FROM tempdb.dbo.Customer WHERE FirstName like 'G%'
-- Index Seek: Table 'Customer'. Scan count 1, logical reads 7

USE tempdb
DROP INDEX dbo.Customer.IX_Customer_FirstName

/***********************************************************
 Script 8.2
 - Uso de Função em coluna: CONVERT
************************************************************/
CREATE INDEX IX_Customer_DataCadastro ON tempdb.dbo.Customer (DataCadastro)
INCLUDE (CustomerID, FirstName, LastName)

SELECT CustomerID, FirstName, LastName, DataCadastro
FROM tempdb.dbo.Customer WHERE convert(varchar(8),DataCadastro,112) = '19571229'
-- Index Scan: Table 'Customer'. Scan count 1, logical reads 133


CREATE INDEX IX_SalesOrderHeader_DataCadastro ON tempdb.dbo.SalesOrderHeader (ShipDate)
INCLUDE (SalesOrderID, CustomerID, TotalDue, OrderDate)

SELECT SalesOrderID, CustomerID, TotalDue, OrderDate, ShipDate
FROM tempdb.dbo.SalesOrderHeader
WHERE convert(varchar(8),ShipDate,112) = '20130714'
-- Table 'SalesOrderHeader'. Scan count 1, logical reads 181

/***********************************************************
 Script 8.3
 - Uso de Função em coluna: Eliminando o CONVERT
************************************************************/
SELECT CustomerID, FirstName, LastName, DataCadastro
FROM tempdb.dbo.Customer WHERE DataCadastro >= '19571229' AND DataCadastro < '19571230'
-- Index Seek: Table 'Customer'. Scan count 1, logical reads 2

USE tempdb
DROP INDEX dbo.Customer.IX_Customer_DataCadastro

/***********************************************************
 Script 8.4
 - Problema de desempenho com conversão implícita
************************************************************/
UPDATE tempdb.dbo.SalesOrderHeader set SalesOrderNumber = replace(SalesOrderNumber,'SO','')

CREATE INDEX IX_SalesOrderHeader_SalesOrderNumber
ON tempdb.dbo.SalesOrderHeader (SalesOrderNumber)
INCLUDE (SalesOrderID, OrderDate, Status)

SELECT SalesOrderID, OrderDate, Status
FROM tempdb.dbo.SalesOrderHeader
WHERE SalesOrderNumber = 53683
-- Table 'SalesOrderHeader'. Scan count 1, logical reads 162

/***********************************************************
 Script 8.5
 - Problema de desempenho com conversão implícita
************************************************************/
SELECT SalesOrderID, OrderDate, Status
FROM tempdb.dbo.SalesOrderHeader
WHERE SalesOrderNumber = '53683'
-- Table 'SalesOrderHeader'. Scan count 1, logical reads 2

USE tempdb
DROP INDEX dbo.SalesOrderHeader.IX_SalesOrderHeader_SalesOrderNumber


/***********************************************************
 Script 8.6
 - Operação Aritmética em Coluna
************************************************************/
CREATE INDEX IX_SalesOrderHeader_SalesOrderID
ON tempdb.dbo.SalesOrderHeader (SalesOrderID)
INCLUDE (SalesOrderNumber, OrderDate, Status)

-- Consulta 1
SELECT SalesOrderID, SalesOrderID * 2 as SalesOrderIDx2,SalesOrderNumber, 
OrderDate, Status
FROM tempdb.dbo.SalesOrderHeader
WHERE SalesOrderID * 2 >= 144480
-- Table 'SalesOrderHeader'. Scan count 1, logical reads 162

-- Consulta 2
SELECT SalesOrderID, SalesOrderID * 2 as SalesOrderIDx2,SalesOrderNumber, 
OrderDate, Status
FROM tempdb.dbo.SalesOrderHeader
WHERE SalesOrderID >= 144480 / 2
-- Table 'SalesOrderHeader'. Scan count 1, logical reads 17

USE tempdb
DROP INDEX dbo.SalesOrderHeader.IX_SalesOrderHeader_SalesOrderID


/***********************************************************
 Script 8.7
 - Consultas com parâmetro
************************************************************/
CREATE INDEX IX_SalesOrderHeader_OrderDate
ON tempdb.dbo.SalesOrderHeader (OrderDate)

-- Consulta 1
SELECT * FROM tempdb.dbo.SalesOrderHeader
WHERE OrderDate >= '20130201' AND OrderDate < '20130202'
-- Table 'SalesOrderHeader'. Scan count 1, logical reads 19

-- Consulta 2
DECLARE @DataINI varchar(8), @DataFIM varchar(8)
SET @DataINI = '20130201'
SET @DataFIM = '20130202'

SELECT * FROM tempdb.dbo.SalesOrderHeader
WHERE OrderDate >= @DataINI AND OrderDate < @DataFIM
-- Table 'SalesOrderHeader'. Scan count 1, logical reads 568
go


/***********************************************************
 Script 8.8
 - OPTIMIZE FOR
************************************************************/
DECLARE @DataINI varchar(8), @DataFIM varchar(8)
SET @DataINI = '20130201'
SET @DataFIM = '20130202'

SELECT * FROM tempdb.dbo.SalesOrderHeader
WHERE OrderDate >= @DataINI AND OrderDate < @DataFIM
OPTION (OPTIMIZE FOR (@DataINI = '20130201', @DataFIM = '20130202'))
-- Table 'SalesOrderHeader'. Scan count 1, logical reads 19
go


/***********************************************************
 Script 8.9
 - sp_executesql
************************************************************/
DECLARE @DataINI varchar(8), @DataFIM varchar(8), @Query nvarchar(2000)
SET @DataINI = '20130201'
SET @DataFIM = '20130202'

SET @Query = N'
SELECT * FROM tempdb.dbo.SalesOrderHeader
WHERE OrderDate >= @ParamDataINI AND OrderDate < @ParamDataFIM'

EXEC SP_EXECUTESQL @Query,N'@ParamDataINI varchar(8),@ParamDataFIM varchar(8)',
@ParamDataINI = @DataINI, @ParamDataFIM = @DataFIM
-- Table 'SalesOrderHeader'. Scan count 1, logical reads 19
go

USE tempdb
DROP INDEX dbo.SalesOrderHeader.IX_SalesOrderHeader_OrderDate


/***********************************************************
 Script 8.10
 - Parameter Sniffing
************************************************************/
-- Atualiza uma linha da tabela Customer para 'SP' o restante ficou com 'RJ'
UPDATE TOP(1) tempdb.dbo.Customer SET Region = 'SP'

CREATE INDEX IX_Customer_Region ON tempdb.dbo.Customer (Region)
-- Total de linhas na tabela Customer: 19.119 

-- Consulta 1
SELECT * FROM tempdb.dbo.Customer WHERE Region = 'RJ'
-- 19.118 linhas com valor 'RJ'
-- Table Scan: Table 'Customer'. Scan count 1, logical reads 155

-- Consulta 2
SELECT * FROM tempdb.dbo.Customer WHERE Region = 'SP'
-- 1 linha com valor 'SP'
-- Index Seek + Bookmark Lookup: Table 'Customer'. Scan count 1, logical reads 3


/***********************************************************
 Script 8.11
 - Parameter Sniffing: Stored Procedure
************************************************************/
go
CREATE PROCEDURE spu_CustomerRegion
@Region varchar(2)
as  
SELECT * FROM tempdb.dbo.Customer WHERE Region = @Region
go


/***********************************************************
 Script 8.12
 - Parameter Sniffing: Stored Procedure
************************************************************/
EXEC spu_CustomerRegion 'SP'
-- 1 linha com valor 'SP'
-- Index Seek + Bookmark Lookup: Table 'Customer'. Scan count 1, logical reads 3

/***********************************************************
 Script 8.13
 - Parameter Sniffing: Stored Procedure
************************************************************/
EXEC spu_CustomerRegion 'RJ'
-- 19.118 linhas com valor 'RJ'
-- Index Seek + Bookmark Lookup: Table 'Customer'. Scan count 1, logical reads 19168


/***********************************************************
 Script 8.14
 - Parameter Sniffing: Stored Procedure
************************************************************/
go
ALTER PROCEDURE spu_CustomerRegion
@Region varchar(2)
WITH RECOMPILE
as  
SELECT * FROM tempdb.dbo.Customer WHERE Region = @Region
go

/***********************************************************
 Script 8.12
 - Parameter Sniffing: Stored Procedure
************************************************************/
EXEC spu_CustomerRegion 'SP'
-- 1 linha com valor 'SP'
-- Index Seek + Bookmark Lookup: Table 'Customer'. Scan count 1, logical reads 3

EXEC spu_CustomerRegion 'RJ'
-- 19.118 linhas com valor 'RJ'
-- Table Scan: Table 'Customer'. Scan count 1, logical reads 155

USE tempdb
DROP INDEX dbo.Customer.IX_Customer_Region

/**************************************
 BETWEEN x IN
***************************************/
CREATE INDEX IX_Customer_CustomerID ON tempdb.dbo.Customer(CustomerID)
INCLUDE (FirstName,Lastname,DataCadastro)

-- Consulta 1 (IN)
SELECT CustomerID,FirstName,Lastname,DataCadastro 
FROM tempdb.dbo.Customer
WHERE CustomerID IN (11000,11001,11002,11003,11004,11005)
-- 6 linhas
-- Index Seek -> Table 'Customer'. Scan count 6, logical reads 12

-- Consulta 2 (BETWEEN)
SELECT CustomerID,FirstName,Lastname,DataCadastro 
FROM tempdb.dbo.Customer 
WHERE CustomerID BETWEEN 11000 and 11005
-- 6 linhas
-- Index Seek -> Table 'Customer'. Scan count 1, logical reads 2

USE tempdb
DROP INDEX dbo.Customer.IX_Customer_CustomerID

