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
order by ProductTotal
OPTION (FORCE ORDER)'

EXEC SP_EXECUTESQL @Query,N'@ParamCustomerID int',
@ParamCustomerID = @CustomerID

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









