USE AdventureWorksModulo2
go

DECLARE @i int
SET @i = 1

WHILE @i <= 100 BEGIN

	SELECT d.SalesOrderID
		   , d.OrderQty
		   , h.OrderDate
		   , o.Description
		   , o.StartDate
		   , o.EndDate
	FROM Sales.SalesOrderDetail d
	INNER JOIN Sales.SalesOrderHeader h ON d.SalesOrderID = h.SalesOrderID
	INNER JOIN Sales.SpecialOffer o ON d.SpecialOfferID = o.SpecialOfferID
	WHERE d.SpecialOfferID <> 1

	SELECT TOP 5
			 sp.Name
		   , st.TaxRate
	FROM Sales.SalesTaxRate st
	JOIN Person.StateProvince sp 
	ON st.StateProvinceID = sp.StateProvinceID
	WHERE sp.CountryRegionCode = 'US'
	ORDER BY st.TaxRate desc
  
	--EXECUTE dbo.uspGetEmployeeManagers 1

	SELECT h.SalesOrderID
		   , h.OrderDate
		   , h.SubTotal
		   , p.SalesQuota
	FROM Sales.SalesPerson p
	INNER JOIN Sales.SalesOrderHeader h 
	ON p.BusinessEntityID = h.SalesPersonID ;

	SELECT Name
		   , ProductNumber
		   , ListPrice AS Price
	FROM Production.Product
	WHERE ProductLine = 'R' AND DaysToManufacture < 4
	ORDER BY Name ASC ;

	WITH HiringTrendCTE(TheYear, TotalHired)
	AS (
	SELECT YEAR(e.HireDate), COUNT(e.BusinessEntityID) 
	FROM HumanResources.Employee AS e
	GROUP BY YEAR(e.HireDate))

	SELECT thisYear.*, prevYear.TotalHired AS HiredPrevYear, 
		(thisYear.TotalHired - prevYear.TotalHired) AS Diff,
		((thisYear.TotalHired - prevYear.TotalHired) * 100) / 
					 prevYear.TotalHired AS DiffPerc
	FROM HiringTrendCTE AS thisYear 
	LEFT OUTER JOIN HiringTrendCTE AS prevYear
	ON thisYear.TheYear =  prevYear.TheYear + 1;

END
go
