/*
            -----------------------------------------------------------------------------------------------
			        DOC: 08_Advanced_SQL_Techniques.pdf
					CONNECTION: SalesBD

										SQL SUBQUERY FUNCTIONS
										      (12:40:34)

					This script demonstrates various subquery techniques in SQL.
					It covers result types, subqueries in the FROM clause, in SELECT, in JOIN clauses,
					with comparison operators, IN, ANY, correlated subqueries, and EXISTS.
   
					Table of Contents:
					1. RESULT TYPES
					2. LOCATION | CLAUSES
						1. FROM 
						2. SELECT
						3. JOIN
						4. WHERE
							1. COMPARISON OPERATORS ( <, >, =, !=, >=, <=)
							2. LOGICAL OPERATORS
								1. IN
								2. ANY | ALL
								3. EXISTS
					3. DEPENDANCY
						1. Non-Correlated subquery
						2. Correlated subquery
				
			-----------------------------------------------------------------------------------------------
*/


USE SalesDB;
GO

--			********************************************************************************************
--													Pre-Things
--													(12:40:34)
--			********************************************************************************************
/*
            -----------------------------------------------------------------------------------------------
												  USER DATA STORAGE
												  (12:50:10)
			-----------------------------------------------------------------------------------------------
*/
-- It is the main content of the database.
-- This is where the actual data that users care about is stored.
-- Database -> SalesDB -> Tables -> Sales.Customers, Sales.Employees, ... [These are the User Data Storage]
SELECT
	*
FROM Sales.Orders;
GO

/*
            -----------------------------------------------------------------------------------------------
												  SYSTEM CATALOG
												  (12:51:08)
			-----------------------------------------------------------------------------------------------
*/
-- Database's internal storage for it's own information. (= MetaData)
-- A blueprint that kees track of everything about the database itself, not the user data.

-- METADATA: Data about data.

-- INFORMATION SCHEMA: A system-defined schema with built-in views that provide info
-- about the database, like tables and columns.

SELECT 
	*
FROM INFORMATION_SCHEMA.COLUMNS;
GO

SELECT 
	DISTINCT TABLE_NAME
FROM INFORMATION_SCHEMA.COLUMNS;
GO

/*
            -----------------------------------------------------------------------------------------------
												TEMPORARY (DATA) STORAGE
												  (12:55:42)
			-----------------------------------------------------------------------------------------------
*/
-- Temporary space used by the database for short-term tasks, like processing queries or sorting data.
-- Once these tasks are done, the storage is cleared.
-- Databases -> System Databases -> tempdb -> Temporary Tables




--			********************************************************************************************
--												SUBQUERIES
--												(12:58:10)
--			********************************************************************************************
-- A query inside another query.
-- How database execute Suqueries? (13:18:35)

/*
            -----------------------------------------------------------------------------------------------
												  Categories
												  (13:03:02)
			-----------------------------------------------------------------------------------------------
*/
-- Overview for all the Subqueries from 1 to 9



-- <<<<< Result Types (13:05:20) >>>>>

-- SCALAR (sub)query: Returns a single value
SELECT
	AVG(so.Sales) AS ScalarQuery
FROM Sales.Orders AS so;
GO

-- ROW (sub)query: Returns multiple rows and/in a single column
SELECT
	so.CustomerID AS RowQuery
FROM Sales.Orders AS so;
GO

-- TABLE (sub)query: Returns multiple rows and multiple columns
SELECT
	so.OrderID,
	so.OrderDate
FROM Sales.Orders AS so;
GO


-- <<<<< LOCATION | CLAUSES (13:07:35) >>>>>

-- FROM Clause (13:07:35)
-- Used as a temporary table for the main query

-- Find the products that have a price higher than the average price of all products
SELECT
	*
FROM(
	SELECT
		sp.ProductID,
		sp.Price,
		AVG(sp.Price) OVER() AS AvgPrice
	FROM Sales.Products AS sp
) AS sub
WHERE sub.Price > sub.AvgPrice;
GO

-- Rank Customers based on their total amount of sales
SELECT
	*,
	RANK() OVER(ORDER BY sub.TotalSales DESC) AS CustomerRank
FROM(
	SELECT
		so.CustomerID,
		SUM(so.Sales) AS TotalSales
	FROM Sales.Orders AS so
	GROUP BY so.CustomerID
) AS sub;
GO


-- SELECT Clause (13:20:08)
-- Used to aggregate data side-by-side with the main query's data, allowing for direct comparison

-- Show the product IDs, product names, prices, and the total number of orders
SELECT
	sp.ProductID,
	sp.Product,
	sp.Price,
	(SELECT COUNT(*) FROM Sales.Orders) AS TotalOrders
FROM Sales.Products AS sp;
GO

-- Per Product Order Totals [NOT subquery in SELECT]
SELECT 
    sp.ProductID,
    sp.Product,
    sp.Price,
    COUNT(o.OrderID) AS TotalOrders
FROM Sales.Products AS sp
LEFT JOIN Sales.Orders AS o
    ON sp.ProductID = o.ProductID
GROUP BY 
    sp.ProductID, sp.Product, sp.Price;
GO


-- JOIN Clause (13:27:10)
-- Used to prepare the data (filtering or aggregation) before joining it with other tables

-- Show customer details and find the total orders of each customer
SELECT
	sc.*,
	sub.TotalOrders
FROM Sales.Customers AS sc
LEFT JOIN (
	SELECT
		so.CustomerID,
		COUNT(*) AS TotalOrders
	FROM Sales.Orders AS so
	GROUP BY so.CustomerID
) AS sub
ON sc.CustomerID = sub.CustomerID;
GO

SELECT
	so.CustomerID,
	COUNT(*) AS TotalOrders
FROM Sales.Orders AS so
GROUP BY so.CustomerID;
GO


-- WHERE Clause (13:32:30)
-- Used for complex filtering logic and makes query more flexible and dynamic

-- -- Comparison Operators:
-- -- Find the products that have a price higher than the average price of all products
SELECT
	sp.ProductID,
	sp.Price,
	(SELECT AVG(sp2.Price) FROM Sales.Products AS sp2) AS AvgPrice
FROM Sales.Products AS sp
WHERE sp.Price > (
	SELECT AVG(sp2.Price)
	FROM Sales.Products AS sp2
);
GO

-- -- Logical Operators:

-- -- IN:
-- -- Show the details of orders made by customers in Germany
SELECT
	*
FROM Sales.Orders AS so
WHERE so.CustomerID IN (
	SELECT sc.CustomerID
	FROM Sales.Customers AS sc
	WHERE sc.Country = 'Germany'
);
GO

SELECT
	sc.CustomerID
FROM Sales.Customers AS sc
WHERE sc.Country = 'Germany';
GO

-- -- Show the details of orders made by customers NOT in Germany
SELECT
	*
FROM Sales.Orders AS so
WHERE so.CustomerID NOT IN (
	SELECT sc.CustomerID
	FROM Sales.Customers AS sc
	WHERE sc.Country = 'Germany'
);
GO

-- -- ANY | ALL:
-- -- Check if a value matches ANY value within a list.
-- -- Used to check if a value is true for AT LEAST one of the values in a list.

-- -- Find female employees whose salaries are greater than the salaries of ANY male employees
SELECT
	se.EmployeeID,
	se.FirstName,
	se.Gender,
	se.Salary
FROM Sales.Employees AS se
WHERE se.Gender = 'F' AND 
	  se.Salary > ANY (SELECT se2.Salary FROM Sales.Employees AS se2 WHERE se2.Gender = 'M');
GO

SELECT
	se.FirstName,
	se.Salary
FROM Sales.Employees AS se
WHERE se.Gender = 'M';
GO

-- -- Find female employees whose salaries are greater than the salaries of ALL male employees
SELECT
	se.EmployeeID,
	se.FirstName,
	se.Gender,
	se.Salary
FROM Sales.Employees AS se
WHERE se.Gender = 'F' AND 
	  se.Salary > ALL (SELECT se2.Salary FROM Sales.Employees AS se2 WHERE se2.Gender = 'M');
GO

-- -- EXISTS (14:04:22):
-- -- CHeck if a subquery returns any results/rows.
-- -- Show the details of orders made by customers in Germany
SELECT
*
FROM Sales.Orders AS so
WHERE EXISTS (
	SELECT 1
	FROM Sales.Customers AS sc
	WHERE sc.Country = 'Germany'  AND sc.CustomerID = so.CustomerID
);
GO

SELECT
*
FROM Sales.Customers AS sc
WHERE sc.Country = 'Germany';
GO

-- -- Show the details of orders made by customers not in Germany
SELECT
*
FROM Sales.Orders AS so
WHERE NOT EXISTS (
	SELECT 1
	FROM Sales.Customers AS sc
	WHERE sc.Country = 'Germany'  AND sc.CustomerID = so.CustomerID
);
GO


-- <<<<< DEPENDANCY (13:53:35) >>>>>

-- Non-Correlated subquery
-- A subquery that can run independently from the main query. 

-- Correlated subquery
-- A subquery that relays on values from the main query (for each row it processes).

-- Show all customer details and the total orders for each customer using a correlated subquery
SELECT
sc.*,
	(SELECT COUNT(*) FROM Sales.Orders AS so WHERE so.CustomerID = sc.CustomerID) AS TotalSales
FROM Sales.Customers AS sc;
GO

SELECT COUNT(*) FROM Sales.Orders