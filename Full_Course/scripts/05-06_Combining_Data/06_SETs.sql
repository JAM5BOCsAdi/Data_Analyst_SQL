/*
            -----------------------------------------------------------------------------------------------
			        DOC: 06_JOINS_and_SET.pdf
					CONNECTION: SalesDB

											  SQL SET OPERATORS
												(04:02:10)

					SQL set operations enable you to combine results from multiple queries
					into a single result set. This script demonstrates the rules and usage of
					set operations, including UNION, UNION ALL, EXCEPT, and INTERSECT.

					Table of Contents:
						1. SQL Operation Rules
						2. UNION
						3. UNION ALL
						4. EXCEPT
						5. INTERSECT
			-----------------------------------------------------------------------------------------------
*/

USE SalesDB;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                         SQL Operation Rules
														(04:02:10)
			-----------------------------------------------------------------------------------------------
*/

-- #1 Rule | CLAUSES (04:03:59)
-- SET Operator can be used almost in ALL CLAUSES [WHERE | JOIN | GROUP BY | HAVING]
-- ORDER BY is allowed only ONCE at the end of query.
SELECT 
	FirstName, 
	LastName
FROM Sales.Customers

UNION

SELECT 
	FirstName, 
	LastName
FROM Sales.Employees
ORDER BY FirstName ASC;
GO

-- #2 Rule | NUMBER OF COLUMNS (04:04:40)
-- The number of columns in each query must be the same.
SELECT 
	FirstName, 
	LastName
FROM Sales.Customers

UNION

SELECT 
	FirstName, 
	LastName
FROM Sales.Employees;
GO

-- #3 Rule | DATA TYPES (04:06:16)
-- Data types of columns in each query must be compatible.
-- GOOD:
SELECT 
	FirstName,		-- varchar(50) 
	LastName		-- varchar(50)
FROM Sales.Customers

UNION

SELECT 
	FirstName,		-- varchar(50)
	LastName		-- varchar(50)
FROM Sales.Employees;
GO

-- BAD:
--SELECT 
--	CustomerID,		-- PK, int not null 
--	LastName		-- varchar(50)
--FROM Sales.Customers

--UNION

--SELECT 
--	FirstName,		-- varchar(50)
--	LastName		-- varchar(50)
--FROM Sales.Employees;
--GO

-- #4 Rule | ORDER OF COLUMNS (04:08:10)
-- The order of columns in each query must be the same.
-- GOOD:
SELECT 
	FirstName, 
	LastName
FROM Sales.Customers

UNION

SELECT 
	FirstName, 
	LastName
FROM Sales.Employees;
GO

-- BAD: Order is not good, and also the columns are miss-matching.
--SELECT  
--	LastName,		-- varchar(50)
--	CustomerID		-- int
--FROM Sales.Customers

--UNION

--SELECT 
--	EmployeeID,		-- int
--	LastName		-- varchar(50)
--FROM Sales.Employees;
--GO

-- #5 Rule | COLUMN ALIEASES (04:09:52)
-- The column names in the result set are determined by the column names specified in the first query.
-- First query controls column names.
SELECT 
	CustomerID AS ID, 
	LastName AS Last_Name_Corr -- You see this, not the "Last_Name" in the 2nd query.
FROM Sales.Customers

UNION

SELECT 
	EmployeeID, 
	LastName AS Last_Name -- You will not see this.
FROM Sales.Employees;
GO


-- #6 Rule | CORRECT COLUMNS (04:12:04)
-- Even if all rules are met and SQL shows no errors, the result may be incorrect.
-- Incorrect columnt selection leads to inaccurate results.

-- Correct results:
SELECT 
	FirstName, 
	LastName
FROM Sales.Customers

UNION

SELECT 
	FirstName,	-- varchar BUT Not in the same order with 2nd query
	LastName	-- varchar BUT Not in the same order with 2nd query
FROM Sales.Employees;
GO

-- Incorrect results:
SELECT 
	FirstName, 
	LastName
FROM Sales.Customers

UNION

SELECT 
	LastName,	-- varchar BUT It should be FirstName (as in 1st query)
	FirstName	-- varchar BUT It should be LastName (as in 1st query)
FROM Sales.Employees;
GO

/*
            -----------------------------------------------------------------------------------------------
														  UNION
														(04:14:45)
			-----------------------------------------------------------------------------------------------
*/
-- Returns all distinct rows from both queries.
-- Removes duplicate rows from the result.

-- Combine the data from Employees and Customers into one table using UNION 
SELECT 
	FirstName,
	LastName
FROM Sales.Customers

UNION

SELECT 
	FirstName,
	LastName
FROM Sales.Employees;
GO

/*
            -----------------------------------------------------------------------------------------------
														 UNION ALL
														(04:20:40)
			-----------------------------------------------------------------------------------------------
*/

-- Returns All Rows, including duplicates.
-- UNION ALL does not search throught for duplicates, and that is why it is faster than UNION.
-- Find duplicates after combining the data, that is why usefule UNION ALL.

-- Combine the data from Employees and Customers into one table, including duplicates (using UNION ALL)
SELECT 
	FirstName,
	LastName
FROM Sales.Customers

UNION ALL

SELECT 
	FirstName,
	LastName
FROM Sales.Employees;
GO

/*
            -----------------------------------------------------------------------------------------------
														  EXCEPT [Like LEFT ANTI JOIN]
														(04:24:08)
			-----------------------------------------------------------------------------------------------
*/

-- Returns all distinct/unique rows from the 1st query that are NOT FOUND in the 2nd query. [Similar to LEFT ANTI JOIN]
-- It is the only one where the order of queries affects the final result.

-- Find employees who are NOT customers at the same time (using EXCEPT)
SELECT 
	FirstName,
	LastName
FROM Sales.Employees

EXCEPT

SELECT 
	FirstName,
	LastName
FROM Sales.Customers;
GO

/*
            -----------------------------------------------------------------------------------------------
														 INTERSECT [Like INNER JOIN]
														(04:29:34)
			-----------------------------------------------------------------------------------------------
*/

-- Returns only the rows that are common in both queries. [Similar to INNER JOIN]

-- Find employees who are also customers (using INTERSECT) 
SELECT 
	FirstName,
	LastName
FROM Sales.Customers

INTERSECT

SELECT 
	FirstName,
	LastName
FROM Sales.Employees;
GO

/*
            -----------------------------------------------------------------------------------------------
												HOW TO USE SET OPERATORS [USE CASES]
													 (04:32:05)
			-----------------------------------------------------------------------------------------------
*/

-- <<<<< UNION, UNION ALL - COMBINE INFORMATION (04:32:05) >>>>>
-- Combine similar information before analyzing the data.

-- Orders are stored in separate tables (Orders and OrdersArchive).
-- Combine order data from Orders and OrdersArchive into one report without duplicates.
SELECT
	'Orders' AS SourceTable, -- These are for easier understand where the data from.
	OrderID,
	ProductID,
	CustomerID,
	SalesPersonID,
	OrderDate,
	ShipDate,
	OrderStatus,
	BillAddress,
	Quantity,
	Sales,
	CreationTime
FROM Sales.Orders

UNION

SELECT
	'OrdersArchive' AS SourceTable, -- These are for easier understand where the data from.
	OrderID,
	ProductID,
	CustomerID,
	SalesPersonID,
	OrderDate,
	ShipDate,
	OrderStatus,
	BillAddress,
	Quantity,
	Sales,
	CreationTime
FROM Sales.OrdersArchive
ORDER BY OrderID;
GO

-- Now this is "dirty" and the BEST PRACTICE is to NEVER use an asterisk (*) to combine tables. List the needed columns.

-- <<<<< EXCEPT - DELTA DETECTION (04:41:50) >>>>>
-- Identifying the differences or changes (delta) between two batches of data.

-- <<<<< EXCEPT - DATA COMPLETENESS CHECK (04:44:00) >>>>>
-- EXCEPT operator can be used to compare tables to detect discrepancies between databases.
