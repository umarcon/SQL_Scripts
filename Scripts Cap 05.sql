/**********************************************************************
 Livro: Otimizando Consultas no Microsoft SQL Server
 Autor: Landry Duailibe Salles Filho

 Data: 19/07/2014

 Scripts Capitulo 05

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

-- Atualiza tabela para ter uma linhas com 'SP' em Region e o restante 'RJ'
UPDATE tempdb.dbo.Customer SET Region = 'SP' WHERE CustomerID = 11000
CREATE INDEX IXCustomer_Region ON tempdb.dbo.Customer(Region)

/***********************************************************
 Script 5.1
 - Trivial Plan
************************************************************/
SELECT * FROM sys.dm_exec_query_optimizer_info WHERE counter='trivial plan'
-- 440 consultas executadas com Trivial Plan

select * from AdventureWorks2014.Person.Person
-- 441 consultas executadas com Trivial Plan



/***********************************************************
 Script 5.2
 - Trivial Plan com filtro
************************************************************/
SELECT TOP(10) BusinessEntityID as CustomerID,FirstName,MiddleName,Lastname,PhoneNumber,
EmailAddress,AddressLine1 as Address,'RJ' as Region, dateadd(d,-BusinessEntityID,getdate()) DataCadastro 
INTO tempdb.dbo.CustomerTrivial
FROM AdventureWorks2014.Sales.vIndividualCustomer

UPDATE TOP(1) tempdb.dbo.CustomerTrivial SET Region = 'SP'
-- 1 linha com SP e 9 linhas com RJ

CREATE INDEX IX_CustomerTrivial_Region ON tempdb.dbo.CustomerTrivial(Region)

SET STATISTICS IO ON

SELECT * FROM tempdb.dbo.CustomerTrivial WHERE Region = 'SP'
SELECT * FROM tempdb.dbo.CustomerTrivial WHERE Region = 'RJ'
-- Trivial Plan


/***********************************************************
 Script 5.3
 - Sem Trivial Plan
************************************************************/
SELECT BusinessEntityID as CustomerID,FirstName,MiddleName,Lastname,PhoneNumber,
EmailAddress,AddressLine1 as Address,'RJ' as Region, dateadd(d,-BusinessEntityID,getdate()) DataCadastro 
INTO tempdb.dbo.Customer
FROM AdventureWorks2014.Sales.vIndividualCustomer

UPDATE TOP(1) tempdb.dbo.Customer SET Region = 'SP'
-- 1 linha com SP e 18.507 linhas com RJ

CREATE INDEX IX_Customer_Region ON tempdb.dbo.Customer(Region)

SET STATISTICS IO ON

SELECT * FROM tempdb.dbo.Customer WHERE Region = 'SP'
-- Index Seek: Table 'Customer'. Scan count 1, logical reads 3

SELECT * FROM tempdb.dbo.Customer WHERE Region = 'RJ'
-- Table Scan: Table 'Customer'. Scan count 1, logical reads 429

SET STATISTICS IO OFF



/***********************************************************
 Script 5.4
 - Estatísticas de Banco de Dados
************************************************************/
IF object_id('tempdb.dbo.Customer') is not null
   DROP TABLE tempdb.dbo.Customer

SELECT BusinessEntityID as CustomerID,FirstName,MiddleName,Lastname,PhoneNumber,
EmailAddress,AddressLine1 as Address,'RJ' as Region, dateadd(d,-BusinessEntityID,getdate()) DataCadastro 
INTO tempdb.dbo.Customer
FROM AdventureWorks2014.Sales.vIndividualCustomer

create index IX_Customer_CustomerID on tempdb.dbo.Customer(CustomerID)

DBCC SHOW_STATISTICS ("tempdb.dbo.Customer", IX_Customer_CustomerID)

-- Simulando cálculo da Densidade
WITH Estatistica AS (
SELECT 
count(*) as TotalLinhas, 
count(distinct CustomerID) as ValoresDistintos, -- count(distinct <col>)
1.0/count(distinct CustomerID) as Densidade -- 1.0 / count(distinct <col>) = Densidade
FROM tempdb.dbo.Customer)

SELECT 
TotalLinhas, ValoresDistintos, Densidade,
1.0/Densidade as ValoresDistintos, -- 1.0 / Densidade = Total de Valores Únicos
Densidade * TotalLinhas as MediaValDuplicados -- Densidade * Total de Linhas
FROM Estatistica



/***********************************************************
 Script 5.5
 - Uso Estatísticas de Banco de Dados
************************************************************/
IF object_id('tempdb.dbo.Customer') is not null
   DROP TABLE tempdb.dbo.Customer

SELECT BusinessEntityID as CustomerID,FirstName,MiddleName,Lastname,PhoneNumber,
EmailAddress,AddressLine1 as Address,'RJ' as Region, dateadd(d,-BusinessEntityID,getdate()) DataCadastro 
INTO tempdb.dbo.Customer
FROM AdventureWorks2014.Sales.vIndividualCustomer

UPDATE tempdb.dbo.Customer SET Region = 'SP' WHERE CustomerID = 11000

CREATE INDEX IX_Customer_Region ON tempdb.dbo.Customer(Region)

SET STATISTICS IO ON

-- Plano 1) Table Scan
SELECT * FROM tempdb.dbo.Customer WHERE Region = 'RJ'
-- Table 'Customer'. Scan count 1, logical reads 429

USE TEMPDB
go
SELECT rows as QtdLinhas, data_pages Paginas8k 
FROM sys.partitions p join sys.allocation_units a ON p.hobt_id = a.container_id
WHERE p.[object_id] = object_id('tempdb.dbo.Customer') and index_id < 2
-- QtdLinhas	Paginas8k
-- 18508		429

-- Plano 2) Index Seek + Booknark Lookup
SELECT * FROM tempdb.dbo.Customer WITH (INDEX(IX_Customer_Region)) WHERE Region = 'RJ'
-- Table 'Customer'. Scan count 1, logical reads 18555

DBCC SHOW_STATISTICS ("tempdb.dbo.Customer", IX_Customer_Region)


-- Atualiza todas as estatísticas da tabela Customer
UPDATE STATISTICS dbo.Customer

-- Atualiza a estatística do índice IX_Customer_Region na tabela Customer com SAMPLE
UPDATE STATISTICS dbo.Customer(IX_Customer_Region) WITH SAMPLE 50 PERCENT

-- Atualiza a estatística do índice IX_Customer_Region na tabela Customer com FULLSCAN
UPDATE STATISTICS dbo.Customer(IX_Customer_Region) WITH FULLSCAN


CREATE STATISTICS ST_Customer_FirstName ON tempdb.dbo.Customer(FirstName)
CREATE STATISTICS ST_Customer_FirstName2 ON tempdb.dbo.Customer(FirstName)

CREATE INDEX IX_Customer_Region ON tempdb.dbo.Customer(Region)
CREATE INDEX IX_Customer_Region2 ON tempdb.dbo.Customer(Region)

select * from sys.indexes where object_id = object_id('dbo.Customer')

select s.*, sc.column_id from sys.stats s 
join sys.stats_columns sc on s.stats_id = sc.stats_id and s.[object_id] = sc.[object_id]
where s.object_id = object_id('dbo.Customer')



