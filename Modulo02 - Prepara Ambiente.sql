/**********************************************
 Curso Query Tuning
 Autor: Landry D. Salles Filho
 Módulo 02
***********************************************/
USE master
go

create database AdventureWorksModulo2
go

USE AdventureWorksModulo2
go
create schema Sales
go
create schema Person
go
create schema Production
go
create schema HumanResources
go
 
select * into Sales.SalesOrderDetail
from AdventureWorks2014.Sales.SalesOrderDetail 

select * into Sales.SalesOrderHeader
from AdventureWorks2014.Sales.SalesOrderHeader 

select * into Sales.SpecialOffer
from AdventureWorks2014.Sales.SpecialOffer 

select * into Sales.SalesTaxRate
from AdventureWorks2014.Sales.SalesTaxRate 

select * into Sales.SalesPerson
from AdventureWorks2014.Sales.SalesPerson 


select * into Person.StateProvince
from AdventureWorks2014.Person.StateProvince 

select * into Production.Product
from AdventureWorks2014.Production.Product 

select * into HumanResources.Employee
from AdventureWorks2014.HumanResources.Employee 

