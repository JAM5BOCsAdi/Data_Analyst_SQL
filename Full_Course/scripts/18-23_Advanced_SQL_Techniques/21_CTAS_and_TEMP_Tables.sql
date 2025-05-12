/*
            -----------------------------------------------------------------------------------------------
			        DOC: 08_Advanced_SQL_Techniques.pdf
					CONNECTION: SalesBD

										SQL CTAS AND TEMPORARY TABLES
										      (16:36:35)

					This script provides a generic example of data migration using a temporary
					table.
				
			-----------------------------------------------------------------------------------------------
*/


USE SalesDB;
GO

--			********************************************************************************************
--													Pre-Things
--													(16:36:35)
--			********************************************************************************************
-- CTAS: CREATE TABLE AS SELECT, It is the same as SELECT INTO, but with extended features.
-- DB Table: A table is structured collection of data, similar to a spreadsheet or grid (Excel).

-- <<<<< Table types >>>>>
-- 1. Permanent table
--		1. CREATE/INSERT: 
--			Create -> Define the structure of table
--			Insert -> Insert data into the table
--		2. CTAS (CREATE TABLE AS SELECT):
--			Create a new table based on the result of an SQL query
-- 2. Temporary table
/*
            -----------------------------------------------------------------------------------------------
												  CTAS vs VIEWS - IMPORTANT PART
												  (16:42:55)
			-----------------------------------------------------------------------------------------------
*/
-- Querying VIEWS is SLOWER than querying CTAS tables.
-- BUT CTAS does not update automatically, like VIEWS.


/*
            -----------------------------------------------------------------------------------------------
												  Table Types
												  (16:48:15)
			-----------------------------------------------------------------------------------------------
*/
-- CREATE/INSERT syntax:
-- CREATE TABLE Table_name(
--		ID INT,
--		Name VARCHAR(50)
-- )

-- INSERT INTO Table_name
-- VALUES(1, 'Frank')




-- CTAS syntax [MySQL | Postgres | Oracle]:
-- CREATE TABLE Table_name AS (
--		SELECT ...
--		FROM ...
--		WHERE ...
-- )


-- CTAS syntax [SQL Server]:
-- SELECT ...
-- INTO New_Table
-- FROM ...
-- WHERE ...

/*
            -----------------------------------------------------------------------------------------------
												  Optimize Performance - IMPORTANT
												  (16:50:30)
			-----------------------------------------------------------------------------------------------
*/
-- Where does it make sens to use CTAS?
-- Where the VIEWS are really slow, in that case it would be better to use CTAS and run it during the night, 
-- to be ready for the morning.


/*
            -----------------------------------------------------------------------------------------------
												    CTAS
												  (16:52:40)
			-----------------------------------------------------------------------------------------------
*/
-- https://learn.microsoft.com/en-us/azure/synapse-analytics/sql-data-warehouse/sql-data-warehouse-develop-ctas

-- This is not working in T-SQL, as you see it above (Table types), because this is the syntax for MySQL | Postgres | Oracle.
-- Only the INTO works.

-- CREATE TABLE Test AS (
--	 SELECT
--		 DATENAME(month, OrderDate) AS OrderMonth,
--		 COUNT(so.OrderID) AS TotalOrders
--	 FROM Sales.Orders AS so
--	 GROUP BY DATENAME(month, so.OrderDate)
-- );
-- GO

-- CREATE a TABLE that show the total number of orders for each month
IF OBJECT_ID('Sales.MonthlyOrders', 'U') IS NOT NULL
	DROP TABLE Sales.MonthlyOrders;
GO

SELECT
	DATENAME(month, OrderDate) AS OrderMonth,
	COUNT(so.OrderID) AS TotalOrders
INTO Sales.MonthlyOrders
FROM Sales.Orders AS so
GROUP BY DATENAME(month, so.OrderDate);
GO

SELECT *
FROM Sales.MonthlyOrders;
GO

-- <<<<< Creating a Snapshot - CTAS USE CASE (16:58:10) >>>>> 
-- If we have a database (or table) that is continously updates, it is hard to find the problem.
-- Instead, create a snapshot of that table, and use that snapshot to find the problem and provide
-- solution, than you can do it for the always updating table too.
-- And in previously we learnt that, tha CTAS creates a "new table" from the data that is always updates, but 
-- the CTAS does not updates, so it can stay the same.

-- <<<<< Phísical Data Mart in DWH - CTAS USE CASE (16:59:35) >>>>> 
-- Persisting the Data Marts of a DWH, improves the speed of data retrieval compared to using views.

/*
            -----------------------------------------------------------------------------------------------
												 TEMPORARY TABLES
												  (17:02:10)
			-----------------------------------------------------------------------------------------------
*/
-- Stores intermediate results in temporary storage within the database during the session.
-- The database will drop all temporary tables once the session ends.

-- SESSION:
-- The time between connecting to and disconnection from the database.

-- Create Temporary table and insert data into it:
-- https://learn.microsoft.com/en-us/sql/t-sql/statements/create-table-transact-sql?view=sql-server-ver16#temporary-tables

-- CREATE TABLE #MyTempTable
-- (
--     col1 INT PRIMARY KEY
-- );

-- INSERT INTO #MyTempTable
-- VALUES (1);

-- Create Temporary table and from another table:
SELECT *
INTO #Orders
FROM Sales.Orders AS so;
GO

SELECT *
FROM #Orders;
GO

DELETE FROM #Orders
WHERE #Orders.OrderStatus = 'Delivered';
GO

SELECT *
FROM #Orders;
GO

-- Store data back to a table (not temptable) to store the results.
SELECT *
INTO Sales.OrdersTest
FROM #Orders;
GO

-- <<<<< Intermediate Results - TEMPTABLE USE CASE (17:12:20) >>>>>

-- <<<<< Temporary table opinion (17:15:10) >>>>>
-- I never use this in my projects.
-- If I need an intermediate result in 1 query, I can go and use the CTEs.
-- If my intermediate results are very important, than I put it in either VIEW or CTAS.
-- But TempTable is a nice technic to learn.
