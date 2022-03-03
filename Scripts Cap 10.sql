/**********************************************************************
 Livro: Otimizando Consultas no Microsoft SQL Server
 Autor: Landry Duailibe Salles Filho

 Data: 20/03/2015

 Scripts Capitulo 10

 Descrição: Scripts utilizados no corpo do livro
***********************************************************************/
USE tempdb
go
/**************************
 AdventureWorks2008R2
***************************/
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
go

CREATE INDEX ix_SalesOrderDetail_SalesOrderID ON dbo.SalesOrderDetail(SalesOrderID) INCLUDE (ProductID,OrderQty,LineTotal)
CREATE INDEX ix_SalesOrderHeader_SalesOrderID ON dbo.SalesOrderHeader(SalesOrderID) INCLUDE (CustomerID)
go

SET STATISTICS IO ON

SELECT H.CustomerID, D.ProductID, 
SUM(D.OrderQty) as SumOrderQty,
AVG(D.LineTotal) as  AvgLineTotal,
COUNT(*) as NumRows
FROM dbo.SalesOrderDetail AS D
JOIN dbo.SalesOrderHeader AS H ON H.SalesOrderID = D.SalesOrderID
GROUP BY H.CustomerID, D.ProductID
/*
Table 'SalesOrderHeader'. Scan count 9, logical reads 259
Table 'SalesOrderDetail'. Scan count 9, logical reads 689

Custo 2,89619
*/

IF object_id('dbo.CustomerOrders') is not null
   DROP VIEW dbo.CustomerOrders

go
CREATE VIEW dbo.CustomerOrders
WITH SCHEMABINDING AS
SELECT H.CustomerID, D.ProductID, 
SUM(D.OrderQty) as SumOrderQty,
SUM(D.LineTotal) as  SumLineTotal,
COUNT_BIG(D.LineTotal) as CountLineTotal,
COUNT_BIG(*) as NumRows
FROM dbo.SalesOrderDetail AS D
JOIN dbo.SalesOrderHeader AS H ON H.SalesOrderID = D.SalesOrderID
GROUP BY H.CustomerID, D.ProductID
go

CREATE UNIQUE CLUSTERED INDEX cuq ON dbo.CustomerOrders (ProductID,CustomerID)
go


SELECT H.CustomerID, D.ProductID, 
SUM(D.OrderQty) as SumOrderQty,
AVG(D.LineTotal) as  AvgLineTotal,
COUNT(*) as NumRows
FROM dbo.SalesOrderDetail AS D
JOIN dbo.SalesOrderHeader AS H ON H.SalesOrderID = D.SalesOrderID
WHERE D.ProductID BETWEEN 711 AND 718
GROUP BY H.CustomerID, D.ProductID
/*
Table 'CustomerOrders'. Scan count 1, logical reads 538

Custo 0,493416
*/


SELECT C.CustomerID, SUM(C.SumOrderQty)
FROM dbo.CustomerOrders AS C WITH (NOEXPAND)
WHERE C.ProductID BETWEEN 711 AND 718
GROUP BY C.CustomerID