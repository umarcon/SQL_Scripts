/**********************************************
 Curso Query Tuning
 Autor: Landry D. Salles Filho
 Módulo 08 - Exercícios
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

IF object_id('tempdb.dbo.SalesOrderDetail') is not null
   DROP TABLE tempdb.dbo.SalesOrderDetail

SELECT SalesOrderID, SalesOrderDetailID, CarrierTrackingNumber, OrderQty, ProductID, 
SpecialOfferID, UnitPrice, UnitPriceDiscount, LineTotal, rowguid, ModifiedDate
INTO tempdb.dbo.SalesOrderDetail
FROM AdventureWorks2014.Sales.SalesOrderDetail

SET STATISTICS IO ON
/******************************************************/

/******************************************
 Exercício 1
*******************************************/
SELECT s.SalesOrderID, c.CustomerID, c.FirstName, s.TotalDue, s.OrderDate, s.ShipDate
FROM tempdb.dbo.Customer c join tempdb.dbo.SalesOrderHeader s
ON c.CustomerID = s.CustomerID
WHERE convert(varchar(8),s.ShipDate,112) = '20130714'
AND left(c.FirstName,1) = 'G'
/*
Table 'Workfile'. Scan count 0, logical reads 0
Table 'Worktable'. Scan count 0, logical reads 0
Table 'Customer'. Scan count 1, logical reads 19119
Table 'SalesOrderHeader'. Scan count 1, logical reads 565

Plano: Table Scan + Hash
*/

create index ix_SalesOrderHeader_ShipDate on SalesOrderHeader (ShipDate,CustomerID) include (SalesOrderID,TotalDue,OrderDate)
create index ix_SalesOrderHeader_CustomerID on SalesOrderHeader (CustomerID,ShipDate) include (SalesOrderID,TotalDue,OrderDate)
create index ix_Customer_FirstName on Customer (FirstName,CustomerID)
create index ix_Customer_CustomerID on Customer (CustomerID,FirstName)
/*
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Customer'. Scan count 1, logical reads 83, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'SalesOrderHeader'. Scan count 1, logical reads 181, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

Plano: Index Scan NonClustered + Hash

Table 'Customer'. Scan count 67, logical reads 161, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'SalesOrderHeader'. Scan count 1, logical reads 181, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

Plano: Index Scan SalesOrderHeader + Index Seek Customer + NEsted Loops
*/
drop index SalesOrderHeader.ix_SalesOrderHeader_ShipDate
drop index SalesOrderHeader.ix_SalesOrderHeader_CustomerID
drop index Customer.ix_Customer_FirstName
drop index Customer.ix_Customer_CustomerID

SELECT s.SalesOrderID, c.CustomerID, c.FirstName, s.TotalDue, s.OrderDate, s.ShipDate
FROM tempdb.dbo.Customer c join tempdb.dbo.SalesOrderHeader s
ON c.CustomerID = s.CustomerID
WHERE s.ShipDate >= '20130714' AND s.ShipDate < '20130715' 
AND FirstName like 'G%'

create index ix_SalesOrderHeader_ShipDate on SalesOrderHeader (ShipDate,CustomerID) include (SalesOrderID,TotalDue,OrderDate)
create index ix_Customer_FirstName on Customer (FirstName,CustomerID)
/*
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Customer'. Scan count 1, logical reads 6, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'SalesOrderHeader'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

Plano: Index Seek + Hash
*/


/******************************************
 Exercício 2
*******************************************/
declare @CustomerID int
declare @Query nvarchar(2000)

set @CustomerID = 29641

SET @Query = N'
SELECT top(4) d.ProductID, sum(d.LineTotal) as ProductTotal
FROM tempdb.dbo.Customer c 
join tempdb.dbo.SalesOrderHeader s ON c.CustomerID = s.CustomerID
join tempdb.dbo.SalesOrderDetail d on d.SalesOrderID = s.SalesOrderID
where c.CustomerID = @ParamCustomerID
group by c.CustomerID, d.ProductID
order by ProductTotal'

EXEC SP_EXECUTESQL @Query,N'@ParamCustomerID int',
@ParamCustomerID = @CustomerID
/*
Table 'SalesOrderHeader'. Scan count 1, logical reads 565, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Customer'. Scan count 2, logical reads 38238, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'SalesOrderDetail'. Scan count 3, logical reads 1496, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/


create index ix_Customer_CustomerID on Customer (CustomerID)
create index ix_SalesOrderHeader_CustomerID on SalesOrderHeader (CustomerID,SalesOrderID)
create index ix_SalesOrderDetail_SalesOrderID on SalesOrderDetail (SalesOrderID,ProductID) include (LineTotal)
/*
Table 'Customer'. Scan count 203, logical reads 406, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'SalesOrderDetail'. Scan count 4, logical reads 14, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'SalesOrderHeader'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/

drop index Customer.ix_Customer_CustomerID
drop index SalesOrderHeader.ix_SalesOrderHeader_CustomerID
drop index SalesOrderDetail.ix_SalesOrderDetail_SalesOrderID









