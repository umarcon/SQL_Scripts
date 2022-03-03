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
