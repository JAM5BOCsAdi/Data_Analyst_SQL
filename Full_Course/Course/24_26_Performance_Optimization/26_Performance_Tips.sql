/*
            ----------------------------------------------------------------------------------------------
					CONNECTION: SalesDB

											 SQL PERFORMANCE TIPS
										      (21:43:10)
				
				    This section demonstrates best practices for fetching data, filtering,
				    joins, UNION, aggregations, subqueries/CTE, DDL, and indexing.
				    It covers techniques such as selecting only necessary columns,
				    proper filtering methods, explicit joins, avoiding redundant logic,
				    and efficient indexing strategies.
   
				    Table of Contents:
					  1. FETCHING DATA
					  2. FILTERING
					  3. JOINS
					  4. UNION
					  5. AGGREGATIONS
					  6. SUBQUERIES, CTE
					  7. CREATING TABLES (DDL)
					  8. INDEXING
			-----------------------------------------------------------------------------------------------
*/


USE SalesDB;
GO

--			********************************************************************************************
--													Pre-Things
--													(21:43:10)
--			********************************************************************************************
-- GOLDEN RULE:
-- The sql optimizer responses differently for different sizes of tables.
-- Always check te execution plan to confirm performance improvements when optimizing your query.
-- If there is no improvement, then just focus on readibility.



/*
            -----------------------------------------------------------------------------------------------
													FETCHING DATA
													(21:45:10)
			-----------------------------------------------------------------------------------------------
*/

-- ================================================================================
-- #1 Select only what you need (21:45:40)
-- ================================================================================
-- Bad practice:
SELECT *
FROM Sales.Customers;
GO

-- Good practice:
SELECT 
	sc.CustomerID,
	sc.FirstName,
	sc.LastName
FROM Sales.Customers AS sc;
GO

-- ================================================================================
-- #2 Avoid unnecessary DISTINCT & ORDER BY (21:46:05) 
-- ================================================================================
-- Bad practice:
SELECT DISTINCT
	sc.FirstName
FROM Sales.Customers AS sc
ORDER BY sc.FirstName;
GO

-- Good practice:
SELECT sc.FirstName
FROM Sales.Customers AS sc;
GO

-- ================================================================================
-- #3 For exploration purpose, limit rows (21:47:00) 
-- ================================================================================
-- When you have millions of rows, select only the top N
-- Bad practice:
SELECT 
	so.OrderID,
	so.Sales
FROM Sales.Orders AS so;
GO

-- Good practice:
SELECT TOP 10
	so.OrderID,
	so.Sales
FROM Sales.Orders AS so;
GO

/*
            -----------------------------------------------------------------------------------------------
													FILTERING DATA
													(21:48:00)
			-----------------------------------------------------------------------------------------------
*/
-- ================================================================================ 
-- #4 Create nonclustered index on frequently used coliumns in WHERE clause. (21:48:20) 
-- ================================================================================

SELECT *
FROM Sales.Orders AS so
WHERE so.OrderStatus = 'Delivered';
GO

CREATE NONCLUSTERED INDEX idx_Orders_OrderStatus ON Sales.Orders(OrderStatus);
GO

-- ================================================================================ 
-- #5 Avoid applying functions to columns in WHERE clause (21:48:40) 
-- ================================================================================
-- !!!!Functions on columns can block index usage!!!!!
-- Bad practice:
SELECT *
FROM Sales.Orders AS so
WHERE LOWER(so.OrderStatus) = 'delivered';
GO

-- Good practice:
SELECT *
FROM Sales.Orders AS so
WHERE so.OrderStatus = 'Delivered';
GO

-- Bad practice:
SELECT *
FROM Sales.Customers AS sc
WHERE SUBSTRING(sc.FirstName, 1, 1) = 'A';
GO

-- Good practice:
SELECT *
FROM Sales.Customers AS sc
WHERE sc.FirstName LIKE 'A%';
GO

-- Bad practice:
SELECT *
FROM Sales.Orders AS so
WHERE YEAR(so.OrderDate) = 2025;
GO

-- Good practice:
SELECT *
FROM Sales.Orders AS so
WHERE so.OrderDate BEtWEEn '2025-01-01' AND '2025-12-31';
GO

-- ================================================================================ 
-- #6 Avoid LEADING wildcards (% | ?) as they PREVENT index usage (21:51:40) 
-- ================================================================================
-- Bad practice:
SELECT *
FROM Sales.Customers AS sc
WHERE sc.LastName LIKE '%Gold%'; -- <--
GO

-- Good practice:
SELECT *
FROM Sales.Customers AS sc
WHERE sc.LastName LIKE 'Gold%'; -- <--
GO

-- ================================================================================ 
-- #7 Use IN insted of multiple OR conditions (21:52:30) 
-- ================================================================================
-- Bad practice:
SELECT *
FROM Sales.Orders AS so
WHERE so.CustomerID = 1 OR so.CustomerID = 2 OR so.CustomerID = 3;
GO

-- Good practice:
SELECT *
FROM Sales.Orders AS so
WHERE so.CustomerID IN(1, 2, 3);
GO

/*
            -----------------------------------------------------------------------------------------------
													JOINING DATA
													(21:53:20)
			-----------------------------------------------------------------------------------------------
*/
-- ================================================================================ 
-- #8 Understand the speed of JOINS & use INNER JOIN when possible (21:53:20) 
-- ================================================================================
-- Best performance
SELECT sc.FirstName, so.OrderID 
FROM Sales.Customers AS sc 
	INNER JOIN Sales.Orders so ON sc.CustomerID = so.CustomerID;
GO

-- Slightly slower performance
SELECT sc.FirstName, so.OrderID 
FROM Sales.Customers AS sc 
RIGHT JOIN Sales.Orders AS so 
	ON sc.CustomerID = so.CustomerID;
GO


SELECT sc.FirstName, so.OrderID 
FROM Sales.Customers AS sc 
LEFT JOIN Sales.Orders AS so 
	ON sc.CustomerID = so.CustomerID;
GO

-- Worst performance
SELECT sc.FirstName,  so.OrderID
FROM Sales.Customers AS sc 
FULL OUTER JOIN Sales.Orders AS so 
	ON sc.CustomerID = so.CustomerID;
GO

-- ================================================================================ 
-- #9 Use Explicit Join (ANSI Join) Instead of Implicit Join (non-ANSI Join) (21:54:50) 
-- ================================================================================
-- Bad practice:
SELECT so.OrderID, sc.FirstName
FROM Sales.Customers AS sc, Sales.Orders AS so
WHERE sc.CustomerID = so.CustomerID;
GO
-- Good practice:
SELECT so.OrderID, sc.FirstName
FROM Sales.Customers AS sc
INNER JOIN Sales.Orders AS so
    ON sc.CustomerID = so.CustomerID;
GO

--For simple queries: There is no measurable performance difference if both ANSI and non-ANSI queries are correctly written.
--For complex queries: ANSI joins are usually easier to optimize and debug because their structure makes the intent of the query clearer.

-- ================================================================================ 
-- #10 Make sure to Index the columns used in the ON clause (21:55:30) 
-- ================================================================================
SELECT sc.FirstName, so.OrderID
FROM Sales.Orders AS so
INNER JOIN Sales.Customers AS sc
    ON sc.CustomerID = so.CustomerID; -- sc.CustumerID has and INDEX, but so.CustomerID does NOT have
GO									  -- So create and INDEX for so.CustomerID

CREATE NONCLUSTERED INDEX idx_Orders_CustomerID ON Sales.Orders(CustomerID);
GO

-- ================================================================================ 
-- #11 Filter Before Joining (Big Tables) (21:56:25) 
-- ================================================================================

-- Best Practice For Small-Medium Tables
-- Filter AFTER Join (WHERE)
SELECT sc.FirstName, so.OrderID
FROM Sales.Customers AS sc
INNER JOIN Sales.Orders AS so
    ON sc.CustomerID = so.CustomerID
WHERE so.OrderStatus = 'Delivered';
GO

-- Filter DURING Join (ON)
SELECT sc.FirstName, so.OrderID
FROM Sales.Customers AS sc
INNER JOIN Sales.Orders AS so
    ON sc.CustomerID = so.CustomerID
	AND so.OrderStatus = 'Delivered';
GO

-- Best Practice For BIG Tables
-- Filter BEFORE Join (SUBQUERY)
SELECT sc.FirstName, sub.OrderID
FROM Sales.Customers AS sc
INNER JOIN (
    SELECT so.OrderID, so.CustomerID
    FROM Sales.Orders AS so
    WHERE so.OrderStatus = 'Delivered'
) AS sub
    ON sc.CustomerID = sub.CustomerID;
GO

-- Or use CTEs to prepare data before JOIN.
-- Try to isolate the preparation step in a CTE or subquery.
WITH cte_delivered AS (
	SELECT 
		so.OrderID, 
		so.CustomerID,
		so.OrderStatus
    FROM Sales.Orders AS so
    WHERE so.OrderStatus = 'Delivered'
)
SELECT
	sc.FirstName,
	d.OrderID,
	d.CustomerID,
	d.OrderStatus
FROM Sales.Customers AS sc
INNER JOIN cte_delivered AS d
	ON sc.CustomerID = d.CustomerID;
GO


-- ================================================================================ 
-- #12 Aggregate Before Joining (Big Tables) (21:59:20) 
-- ================================================================================

-- Best Practice For Small-Medium Tables
-- Grouping and Joining
SELECT sc.CustomerID, sc.FirstName, COUNT(so.OrderID) AS OrderCount
FROM Sales.Customers AS sc
INNER JOIN Sales.Orders AS so
    ON sc.CustomerID = so.CustomerID
GROUP BY sc.CustomerID, sc.FirstName;
GO

-- Best Practice For Big Tables
-- Pre-aggregated Subquery
SELECT sc.CustomerID, sc.FirstName, sub.OrderCount
FROM Sales.Customers AS sc
INNER JOIN (
	-- Prepare data here, then (inner) join the result
    SELECT so.CustomerID, COUNT(so.OrderID) AS OrderCount
    FROM Sales.Orders AS so
    GROUP BY so.CustomerID
) AS sub
    ON sc.CustomerID = sub.CustomerID;
GO

-- Or use CTE
WITH cte_prep AS(
	-- Prepare data here, then (inner) join the result
	SELECT 
		so.CustomerID, 
		COUNT(so.OrderID) AS OrderCount
    FROM Sales.Orders AS so
    GROUP BY so.CustomerID
)
SELECT 
	sc.CustomerID, 
	sc.FirstName, 
	p.OrderCount
FROM Sales.Customers AS sc
INNER JOIN cte_prep	AS p
	ON p.CustomerID = sc.CustomerID;
GO

-- Bad Practice [WORST]
-- Correlated Subquery: Inefficient because SQL execute aggregations for every row
SELECT 
    sc.CustomerID, 
    sc.FirstName,
    (
	 SELECT COUNT(so.OrderID)
     FROM Sales.Orders AS so
     WHERE so.CustomerID = sc.CustomerID
	) AS OrderCount
FROM Sales.Customers AS sc;
GO


-- ================================================================================ 
-- #13 Use UNION instead of OR in joins (22:01:54) 
-- ================================================================================
-- Bad Practice:
SELECT so.OrderID, sc.FirstName
FROM Sales.Customers AS sc
INNER JOIN Sales.Orders AS so
    ON sc.CustomerID = so.CustomerID
    OR sc.CustomerID = so.SalesPersonID;

-- Best Practice: !!!! Pay attention for the same amount of columns and same order !!!!
SELECT so.OrderID, sc.FirstName
FROM Sales.Customers AS sc
INNER JOIN Sales.Orders AS so
    ON sc.CustomerID = so.CustomerID

UNION

SELECT so.OrderID, sc.FirstName
FROM Sales.Customers AS sc
INNER JOIN Sales.Orders AS so
    ON sc.CustomerID = so.SalesPersonID;

-- ================================================================================ 
-- #14 Check for Nested Loops and Use SQL HINTS (22:03:10) 
-- ================================================================================
-- Execution plan:

-- JOIN Algorithms: https://learn.microsoft.com/en-us/sql/t-sql/queries/hints-transact-sql-join?view=sql-server-ver16
-- Nested Loops: Compares tables row by row. [Best for SMALL tables]
-- Hash Match: Matcches rows using a hash table. [Best for LARGE tables]
-- Merge join: Merge two sorted table. [Efficient when BOTH are sorted]
SELECT so.OrderID, sc.FirstName
FROM Sales.Customers sc
INNER JOIN Sales.Orders so 
ON sc.CustomerID = so.CustomerID;
GO

-- Good Practice for Having Big Table & Small Table
SELECT so.OrderID, sc.FirstName
FROM Sales.Customers AS sc
INNER JOIN Sales.Orders AS so
    ON sc.CustomerID = so.CustomerID
OPTION (HASH JOIN);
GO


/*
            -----------------------------------------------------------------------------------------------
													  UNION
													(22:04:30)
			-----------------------------------------------------------------------------------------------
*/
-- ================================================================================ 
-- #15 Use UNION ALL instead of using UNION | duplicates are acceptable (22:04:30) 
-- ================================================================================
-- Use UNION ALL instead of UNION if duplicates are acceptable
SELECT CustomerID FROM Sales.Orders
UNION
SELECT CustomerID FROM Sales.OrdersArchive;
GO

-- Best Practice
SELECT CustomerID FROM Sales.Orders
UNION ALL
SELECT CustomerID FROM Sales.OrdersArchive;
GO

-- ================================================================================ 
-- #16 Use UNION ALL + Distinct instead of using UNION | duplicates are not acceptable (22:05:05) 
-- ================================================================================
-- Bad Practice
SELECT CustomerID FROM Sales.Orders
UNION
SELECT CustomerID FROM Sales.OrdersArchive;
GO

-- Best Practice
-- Use UNION ALL then select the DISTINCT values
SELECT DISTINCT CombinedData.CustomerID
FROM (
    SELECT CustomerID FROM Sales.Orders
    UNION ALL
    SELECT CustomerID FROM Sales.OrdersArchive
) AS CombinedData;
GO

/*
            -----------------------------------------------------------------------------------------------
													AGGREGATIONS
													(22:06:10)
			-----------------------------------------------------------------------------------------------
*/
-- ================================================================================ 
-- #17 Use Columnstore Index for Aggregations on LARGE Table (22:06:10) 
-- ================================================================================
SELECT 
	CustomerID, 
	COUNT(OrderID) AS OrderCount
FROM Sales.Orders 
GROUP BY CustomerID;
GO

--SELECT *
--INTO Sales.OrdersTest2
--FROM Sales.Orders;
--GO

SELECT 
	CustomerID, 
	COUNT(OrderID) AS OrderCount
FROM Sales.OrdersTest2 
GROUP BY CustomerID;
GO

CREATE CLUSTERED COLUMNSTORE INDEX idx_Orders_Columnstore ON Sales.OrdersTest2;
GO

-- ================================================================================ 
-- #18 Pre-Aggregate Data and store it in new Table for Reporting (22:07:00) 
-- ================================================================================
SELECT MONTH(OrderDate) OrderYear, SUM(Sales) AS TotalSales
INTO Sales.SalesSummary
FROM Sales.Orders
GROUP BY MONTH(OrderDate);
GO

SELECT OrderYear, TotalSales 
FROM Sales.SalesSummary;
GO

/*
            -----------------------------------------------------------------------------------------------
													SUBQUERIES, CTEs
													(22:08:25)
			-----------------------------------------------------------------------------------------------
*/
-- ================================================================================ 
-- #19 JOIN vs EXISTS vs IN (Avoid using IN) (22:08:25) 
-- ================================================================================
-- JOIN (Best Practice: If the Performance equals to EXISTS)
SELECT so.OrderID, so.Sales
FROM Sales.Orders AS so
INNER JOIN Sales.Customers AS sc
    ON so.CustomerID = sc.CustomerID
WHERE sc.Country = 'USA';

-- EXISTS (Best Practice: Use it for Large Tables)
-- Better than JOIN because, it stops at first match and avoid data duplication
SELECT so.OrderID, so.Sales
FROM Sales.Orders AS so
WHERE EXISTS (
    SELECT 1
    FROM Sales.Customers AS sc
    WHERE sc.CustomerID = so.CustomerID
      AND sc.Country = 'USA'
);

-- IN (Bad Practice)
-- The IN operator processes and evaliates all rows.
-- It lacks an early exit mechanism.
SELECT so.OrderID, so.Sales
FROM Sales.Orders AS so
WHERE so.CustomerID IN (
    SELECT sc.CustomerID
    FROM Sales.Customers AS sc
    WHERE sc.Country = 'USA'
);

-- ================================================================================ 
-- #20 Avoid Redundant Logic in Your Query (22:11:25) 
-- ================================================================================
-- Bad Practice
SELECT se1.EmployeeID, se1.FirstName, 'Above Average' AS Status
FROM Sales.Employees AS se1
WHERE se1.Salary > (SELECT AVG(se2.Salary) FROM Sales.Employees AS se2)

UNION ALL

SELECT se1.EmployeeID, se1.FirstName, 'Below Average' AS Status
FROM Sales.Employees AS se1
WHERE se1.Salary < (SELECT AVG(se2.Salary) FROM Sales.Employees AS se2);

-- Good Practice
SELECT 
    se.EmployeeID, 
    se.FirstName, 
    CASE 
        WHEN se.Salary > AVG(se.Salary) OVER () THEN 'Above Average'
        WHEN se.Salary < AVG(se.Salary) OVER () THEN 'Below Average'
        ELSE 'Average'
    END AS Status
FROM Sales.Employees AS se;

/*
            -----------------------------------------------------------------------------------------------
												CREATING TABLES (DDL)
													(22:13:35)
			-----------------------------------------------------------------------------------------------
*/
-- ================================================================================ 
-- #21 Avoid TEXT Data Type If Possible (22:13:35) 
-- ================================================================================
-- ================================================================================ 
-- #22 Avoid Using MAX or Overly Large Lengths (22:16:20) 
-- ================================================================================
-- ================================================================================ 
-- #23 Use NOT NULL If possible (22:17:50) 
-- ================================================================================
-- ================================================================================ 
-- #24 Make sure all tables have a CLUSTERED PRIMARY KEY (22:19:20) 
-- ================================================================================
-- ================================================================================ 
-- #25 Create Nonclustered Index on Foreign Key if they are frequently used (22:20:25) 
-- ================================================================================
-- Bad Practice 
CREATE TABLE CustomersInfo (
    CustomerID INT,
    FirstName VARCHAR(MAX),
    LastName TEXT,
    Country VARCHAR(255),
    TotalPurchases FLOAT, 
    Score VARCHAR(255),
    BirthDate VARCHAR(255),
    EmployeeID INT,
    CONSTRAINT FK_Bad_Customers_EmployeeID FOREIGN KEY (EmployeeID)
        REFERENCES Sales.Employees(EmployeeID)
);
GO

-- Good Practice Practice 
CREATE TABLE CustomersInfo2 (
    CustomerID INT PRIMARY KEY CLUSTERED,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Country VARCHAR(50) NOT NULL,
    TotalPurchases FLOAT,
    Score INT,
    BirthDate DATE,
    EmployeeID INT,
    CONSTRAINT FK_CustomersInfo_EmployeeID FOREIGN KEY (EmployeeID)
        REFERENCES Sales.Employees(EmployeeID)
);
GO

CREATE NONCLUSTERED INDEX idx_CustomersInfo2_EmployeeID
ON CustomersInfo2(EmployeeID);
GO

/*
            -----------------------------------------------------------------------------------------------
													INDEXING
													(22:21:15)
			-----------------------------------------------------------------------------------------------
*/
-- ================================================================================ 
-- #26 Avoid Over Indexing, as it can slow down insert, update, and delete operations (22:21:15) 
-- ================================================================================
-- ================================================================================ 
-- #27 Regularly review and drop unused indexes to save space and improve write performance (22:21:33) 
-- ================================================================================
-- ================================================================================ 
-- #28 Update table statistics weekly to ensure the query optimizer has the most up-to-date information (22:21:51) 
-- ================================================================================
-- ================================================================================ 
-- #29 Reorganize and rebuild fragmented indexes weekly to maintain query performance (22:22:19) 
-- ================================================================================
-- ================================================================================ 
-- #30 For large tables (e.g., fact tables), partition the data and then apply a 
--		columnstore index for best performance results (22:22:47) 
-- ================================================================================

/*
            -----------------------------------------------------------------------------------------------
													Final Thoughts
													(22:23:20)
			-----------------------------------------------------------------------------------------------
*/
