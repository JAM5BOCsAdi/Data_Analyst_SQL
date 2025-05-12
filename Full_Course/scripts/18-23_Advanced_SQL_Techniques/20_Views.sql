/*
            -----------------------------------------------------------------------------------------------
			        DOC: 08_Advanced_SQL_Techniques.pdf
					CONNECTION: SalesBD

											  SQL VIEWS
										      (15:34:50)

					This script demonstrates various view use cases in SQL Server.
					It includes examples for creating, dropping, and modifying views, hiding
					query complexity, and implementing data security by controlling data access.

					Table of Contents:
						1. Create, Drop, Modify View
						2. VIEW USE CASES 
							- HIDE COMPLEXITY
							- DATA SECURITY
							- Flexibility & Dynamic
							- Multiple Languages
							- Virtual Data Marts in DWH <-- IMPORTANT PART
				
			-----------------------------------------------------------------------------------------------
*/


USE SalesDB;
GO

--			********************************************************************************************
--													Pre-Things
--													(15:35:15)
--			********************************************************************************************
-- Database Server: [DESKTOP-3FSNRUN - Local Server]
-- Stores, manages and provides access to databases for users or applications.

-- Database: [SalesDB]
-- Collection of information that is stored in a structured way.

-- Schema: [Salesdb -> Security -> Schemas -> Sales: Sales.Customers, Sales.Employees, ...]
-- Logical layer that groups related objects together.

-- Table: [SalesDB -> Tables: Sales.Customers, Sales.Employees, ...]
-- A place where data is stored and organized into rows and columns.

-- View: [SalesDB -> Views]
-- Virtual table that shows data without storing it physically.
-- Are persisted SQL queries in the database.

-- Database architecture: Divided into 3 levels
-- View: To create views for Business Analyst, Data Analyst, End Users
-- Logical: Structuring data, building data model, but do not care about where the data is stored
-- Physical: Lowest level, actual data is stored here

-- VIEWS vs TABLES (15:47:20):

-- VIEWS:
-- No Persistance (not stores data) | Easy to maintain | Slow response | Read

-- TABLES:
-- Persistance (stores data) | Hard to maintain | Fast response | Read/Write



-- VIEWS vs CTE (15:52:25):

-- VIEWS:
-- Reduce redundancy in MULTI-queries | Improve reusability in MULTI-queries | Persisted logic | Need to maintain - CREATE/DROP

-- CTE:
-- Reduce redundandy in 1 query | Improve reusability in 1 query | Temporary logic | No maintenance - auto cleanup

/*
            -----------------------------------------------------------------------------------------------
												  VIEW USE CASES
												  (15:48:55)
			-----------------------------------------------------------------------------------------------
*/
-- <<<<< #1 Central Complex Query Logic (15:48:55) >>>>>
-- Store central, complex query logic in the database for access by multiple queries, reducing project complexity.


/*
            -----------------------------------------------------------------------------------------------
												  CREATE, DROP, MODIFY VIEW
												  (15:54:00)
			-----------------------------------------------------------------------------------------------
*/

-- Find the running total of sales for each month

-- Use CTE first, than change to View
WITH cte_MonthlySummary AS (
	SELECT
		DATETRUNC(month, so.OrderDate) AS OrderMonth,
		SUM(so.Sales) AS TotalSales,
		COUNT(so.OrderID) AS TotalOrders,
		SUM(so.Quantity) AS TotalQuantity
	FROM Sales.Orders AS so
	GROUP BY DATETRUNC(month, so.OrderDate)
)
SELECT
	cte_ms.OrderMonth,
	cte_ms.TotalSales,
	SUM(cte_ms.TotalSales) OVER(ORDER BY cte_ms.OrderMonth) AS RunningTotal
FROM cte_MonthlySummary AS cte_ms;
GO

-- Change to view: 
CREATE OR ALTER VIEW vw_MonthlySummary AS (
	SELECT
		DATETRUNC(month, so.OrderDate) AS OrderMonth,
		SUM(so.Sales) AS TotalSales,
		COUNT(so.OrderID) AS TotalOrders,
		SUM(so.Quantity) AS TotalQuantity
	FROM Sales.Orders AS so
	GROUP BY DATETRUNC(month, so.OrderDate)
);
GO

-- to ADD to the SCHEMA write "Sales."
DROP VIEW IF EXISTS Sales.vw_MonthlySummary;
GO

-- 'V' part: 
-- 1. https://learn.microsoft.com/en-us/sql/t-sql/functions/object-id-transact-sql?view=sql-server-ver16
-- 2. https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-objects-transact-sql?view=sql-server-ver16

IF OBJECT_ID('Sales.vw_MonthlySummary', 'V') IS NOT NULL 
DROP VIEW Sales.vw_MonthlySummary;
GO

CREATE OR ALTER VIEW Sales.vw_MonthlySummary AS (
	SELECT
		DATETRUNC(month, so.OrderDate) AS OrderMonth,
		SUM(so.Sales) AS TotalSales,
		COUNT(so.OrderID) AS TotalOrders,
		SUM(so.Quantity) AS TotalQuantity
	FROM Sales.Orders AS so
	GROUP BY DATETRUNC(month, so.OrderDate)
);
GO

-- Check if it is good
SELECT *
FROM Sales.vw_MonthlySummary;
GO

-- Query the View
SELECT
	vw_ms.OrderMonth,
	vw_ms.TotalSales,
	SUM(vw_ms.TotalSales) OVER(ORDER BY vw_ms.OrderMonth) AS RunningTotal
FROM Sales.vw_MonthlySummary AS vw_ms;
GO

-- Drop unneccessary VIEW
DROP VIEW dbo.vw_MonthlySummary;
GO

/*
            -----------------------------------------------------------------------------------------------
												  Hide complexity
												  (16:09:16)
			-----------------------------------------------------------------------------------------------
*/
-- Views can be use to hide the complexity of database tables and offers users more
-- friendly and easy-to-consume objects.

-- Provide a view that combines details from orders, products, customers and employees.
CREATE OR ALTER VIEW Sales.vw_OrderDetails AS (
	SELECT 
		so.OrderID,
		so.OrderDate,
		sp.Product,
		sp.Category,
		TRIM(COALESCE(sc.FirstName, '')) + ' ' + TRIM(COALESCE(sc.LastName, '')) AS CustomerName,
		TRIM(COALESCE(se.FirstName, '')) + ' ' + TRIM(COALESCE(se.LastName, '')) AS EmployeeName,
		se.Department,
		sc.Country AS CustomerCountry,
		so.Sales,
		so.Quantity
	FROM Sales.Orders AS so
	LEFT JOIN Sales.Products AS sp
		ON so.ProductID = sp.ProductID
	LEFT JOIN Sales.Customers AS sc
		ON so.CustomerID = sc.CustomerID
	LEFT JOIN Sales.Employees AS se
		ON so.SalesPersonID = se.EmployeeID
);
GO

SELECT *
FROM Sales.vw_OrderDetails;
GO

/*
            -----------------------------------------------------------------------------------------------
												 Data Security
												  (16:19:50)
			-----------------------------------------------------------------------------------------------
*/
-- Use VIEWS to enforce security and protect sensitive data, by hiding columns and/or rows from tables.

-- Provide a VIEW for EU Sales Team, that combines details from All tables
-- but EXCLUDES data related to the USA
CREATE OR ALTER VIEW Sales.vw_OrderDetailsEU AS (
	SELECT 
			so.OrderID,
			so.OrderDate,
			sp.Product,
			sp.Category,
			TRIM(COALESCE(sc.FirstName, '')) + ' ' + TRIM(COALESCE(sc.LastName, '')) AS CustomerName,
			TRIM(COALESCE(se.FirstName, '')) + ' ' + TRIM(COALESCE(se.LastName, '')) AS EmployeeName,
			se.Department,
			sc.Country AS CustomerCountry,
			so.Sales,
			so.Quantity
	FROM Sales.Orders AS so
	LEFT JOIN Sales.Products AS sp
		ON so.ProductID = sp.ProductID
	LEFT JOIN Sales.Customers AS sc
		ON so.CustomerID = sc.CustomerID
	LEFT JOIN Sales.Employees AS se
		ON so.SalesPersonID = se.EmployeeID
	WHERE sc.Country != 'USA' -- != and <> can be used, it is the SAME and both works
); 
GO

SELECT *
FROM Sales.vw_OrderDetailsEU;
GO

/*
            -----------------------------------------------------------------------------------------------
												  Flexibility & Dynamic
												  (16:26:27)
			-----------------------------------------------------------------------------------------------
*/
/*
            -----------------------------------------------------------------------------------------------
												  Multiple Languages
												  (16:28:40)
			-----------------------------------------------------------------------------------------------
*/
/*
            -----------------------------------------------------------------------------------------------
												  Virtual Data Marts in DWH - IMPORTANT PART 
												  (16:30:45)
			-----------------------------------------------------------------------------------------------
*/
-- VIEWS can be used as Data Marts in Data Warehouse System, because they provide a flexible and
-- efficient way to present data.

-- Data Mart: Is always specific for a use case that focus on 1 topic.
--	Sales Mart = Collects data about the Sales
--	Finance Mart = Collects data about the Finance