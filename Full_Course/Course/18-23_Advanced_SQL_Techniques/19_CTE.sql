/*
            -----------------------------------------------------------------------------------------------
			        DOC: 08_Advanced_SQL_Techniques.pdf
					CONNECTION: SalesBD

										SQL COMMON TABLE EXPRESSIONS (CTEs)
										      (14:18:00)

					This script demonstrates the use of Common Table Expressions (CTEs) in SQL Server.
					It includes examples of non-recursive CTEs for data aggregation and segmentation,
					as well as recursive CTEs for generating sequences and building hierarchical data.

					Table of Contents:
					CTE Types:
						1. NON-RECURSIVE
							- Standalone
							- Nested
						2. RECURSIVE
							- GENERATE SEQUENCE
							- BUILD HIERARCHY
				
			-----------------------------------------------------------------------------------------------
*/


USE SalesDB;
GO

--			********************************************************************************************
--													Pre-Things
--													(14:18:18)
--			********************************************************************************************
-- CTE (Common Table Expression): 
-- Temporary, named result set (virtual table), that can be used multipe times 
-- within your query to simplify and organize complex query.
-- !!!!!You can NOT use ORDER BY directly within the CTE!!!!!! (Neather in: views, subqueries, ...)

-- Why CTE? (When to use) (14:24:20)
-- Execute CTE (14:29:15)
-- CTE Types (14:31:32)


--			********************************************************************************************
--												  NON-RECURSIVE
--													(14:18:18)
--			********************************************************************************************
-- Executed only once without any repetition
/*
            -----------------------------------------------------------------------------------------------
												  Standalone CTE [Non-recursive]
												  (14:32:06)
			-----------------------------------------------------------------------------------------------
*/
-- Defined and used INDEPENDENTLY.
-- Runs independently as it's selft-contained and does not rely on other CTEs or queries.

-- <<<<< Simple standalone CTE (14:35:10) >>>>>
-- Find the total sales per customer (use CTE for later steps)
WITH cte_TotalSales1 AS(
	SELECT 
		so.CustomerID,
		SUM(so.Sales) AS TotalSales
	FROM Sales.Orders AS so
	GROUP BY so.CustomerID
	-- ORDER BY so.CustomerID  <-- You can NOT USE ORDER BY in CTE (And many other: views, subqueries, ...)
)
SELECT 
	sc.CustomerID,
	sc.FirstName,
	sc.LastName,
	cte_ts1.TotalSales
FROM Sales.Customers AS sc
LEFT JOIN cte_TotalSales1 AS cte_ts1
	ON cte_ts1.CustomerID = sc.CustomerID
ORDER BY sc.CustomerID ASC; -- You can use here, in the MAIN query the ORDER BY
GO



-- <<<<< Multiple standalone CTE (14:40:50) >>>>>
-- Find the last order date per customer [Re-using previous]
-- Added: cte_LastOrder1
WITH cte_TotalSales2 AS( -- [Standalone CTE]
	SELECT 
		so.CustomerID,
		SUM(so.Sales) AS TotalSales
	FROM Sales.Orders AS so
	GROUP BY so.CustomerID
	-- ORDER BY so.CustomerID  <-- You can NOT USE ORDER BY in CTE (And many other: views, subqueries, ...)
),
cte_LastOrder1 AS( -- [Standalone CTE]
	SELECT
		so.CustomerID,
		MAX(so.OrderDate) AS LastOrder
	FROM Sales.Orders AS so
	GROUP BY so.CustomerID
)
SELECT 
	sc.CustomerID,
	sc.FirstName,
	sc.LastName,
	cte_ts2.TotalSales,
	cte_lo1.LastOrder
FROM Sales.Customers AS sc
LEFT JOIN cte_TotalSales2 AS cte_ts2
	ON cte_ts2.CustomerID = sc.CustomerID
LEFT JOIN cte_LastOrder1 AS cte_lo1
	ON cte_lo1.CustomerID = sc.CustomerID
ORDER BY sc.CustomerID ASC; -- You can use here, in the MAIN query the ORDER BY
GO

/*
            -----------------------------------------------------------------------------------------------
												  Nested CTE [Non-recursive]
												  (14:48:54)
			-----------------------------------------------------------------------------------------------
*/
-- CTE insode another CTE
-- A nested CTE uses the result of another CTE, so it can not run independently.

-- Ranks the customers based on total sales per customer. [Re-using previous]
-- Added: cte_CustomerRank1
WITH cte_TotalSales3 AS( -- [Standalone CTE]
	SELECT 
		so.CustomerID,
		SUM(so.Sales) AS TotalSales
	FROM Sales.Orders AS so
	GROUP BY so.CustomerID
	-- ORDER BY so.CustomerID  <-- You can NOT USE ORDER BY in CTE (And many other: views, subqueries, ...)
),
cte_LastOrder2 AS( -- [Standalone CTE]
	SELECT
		so.CustomerID,
		MAX(so.OrderDate) AS LastOrder
	FROM Sales.Orders AS so
	GROUP BY so.CustomerID
),
cte_CustomerRank1 AS( -- [Nested CTE] Because in the FROM clause, you connect the cte_TotalSales3 to cte_CustomerRank1
	SELECT
		cte_ts3.CustomerID,
		cte_ts3.TotalSales,
		RANK() OVER(ORDER BY cte_ts3.TotalSales DESC) AS CustomerRank
	FROM cte_TotalSales3 AS cte_ts3
)
SELECT 
	sc.CustomerID,
	sc.FirstName,
	sc.LastName,
	cte_ts3.TotalSales,
	cte_lo2.LastOrder,
	cte_cr1.CustomerRank
FROM Sales.Customers AS sc
LEFT JOIN cte_TotalSales3 AS cte_ts3
	ON cte_ts3.CustomerID = sc.CustomerID
LEFT JOIN cte_LastOrder2 AS cte_lo2
	ON cte_lo2.CustomerID = sc.CustomerID
LEFT JOIN cte_CustomerRank1 AS cte_cr1
	ON cte_cr1.CustomerID = sc.CustomerID
-- WHERE cte_cr.CustomerRank1 IS NOT NULL -- <-- If you want to leave the NULL value(s) from CustomerRank1
ORDER BY cte_cr1.CustomerRank ASC; -- You can use here, in the MAIN query the ORDER BY
GO



-- Segment customers based on their total sales [Re-using previous]
-- Added: cte_CustomerSegments1
WITH cte_TotalSales4 AS( -- [Standalone CTE]
	SELECT 
		so.CustomerID,
		SUM(so.Sales) AS TotalSales
	FROM Sales.Orders AS so
	GROUP BY so.CustomerID
	-- ORDER BY so.CustomerID  <-- You can NOT USE ORDER BY in CTE (And many other: views, subqueries, ...)
),
cte_LastOrder3 AS( -- [Standalone CTE]
	SELECT
		so.CustomerID,
		MAX(so.OrderDate) AS LastOrder
	FROM Sales.Orders AS so
	GROUP BY so.CustomerID
),
cte_CustomerRank2 AS( -- [Nested CTE] Because in the FROM clause, you connect the cte_TotalSales4 to cte_CustomerRank2
	SELECT
		cte_ts4.CustomerID,
		cte_ts4.TotalSales,
		RANK() OVER(ORDER BY cte_ts4.TotalSales DESC) AS CustomerRank
	FROM cte_TotalSales4 AS cte_ts4
),
cte_CustomerSegments1 AS( -- [Nested CTE] Because in the FROM clause, you connect the cte_TotalSales4 to cte_CustomerSegments1
	SELECT
		cte_ts4.CustomerID,
		cte_ts4.TotalSales,
		CASE 
			WHEN cte_ts4.TotalSales > 100 THEN 'High'
			WHEN cte_ts4.TotalSales > 80 THEN 'Medium'
			ELSE 'Low'
		END AS CustomerSegments
	FROM cte_TotalSales4 AS cte_ts4
)
SELECT 
	sc.CustomerID,
	sc.FirstName,
	sc.LastName,
	cte_ts4.TotalSales,
	cte_lo3.LastOrder,
	cte_cr2.CustomerRank,
	cte_cs1.CustomerSegments
FROM Sales.Customers AS sc
LEFT JOIN cte_TotalSales4 AS cte_ts4
	ON cte_ts4.CustomerID = sc.CustomerID
LEFT JOIN cte_LastOrder3 AS cte_lo3
	ON cte_lo3.CustomerID = sc.CustomerID
LEFT JOIN cte_CustomerRank2 AS cte_cr2
	ON cte_cr2.CustomerID = sc.CustomerID
LEFT JOIN cte_CustomerSegments1 AS cte_cs1
	ON cte_cs1.CustomerID = sc.CustomerID
-- WHERE cte_cr2.CustomerRank2 IS NOT NULL -- <-- If you want to leave the NULL value(s) from CustomerRank2
ORDER BY cte_cr2.CustomerRank ASC; -- You can use here, in the MAIN query the ORDER BY
GO



-- <<<<< Best Practices (15:02:30) >>>>>
-- Rethink and refactor your CTEs before starting a new one.
-- DO NOT use more than 5 CTEs in one query (but that is also a lot), otherwise
-- your code will be hard to understand and maintain.



--			********************************************************************************************
--													 RECURSIVE
--													(15:05:18)
--			********************************************************************************************
--  Self-referencing query, that repeatedly processes data until a specific condition is met

/*
            -----------------------------------------------------------------------------------------------
												  GENERATE SEQUENCE [Recursive]
												  (15:05:18)
			-----------------------------------------------------------------------------------------------
*/

-- Generate a sequence of numbers from 1 to 20
WITH cte_Series AS(

	-- Anchor query
	SELECT 1 AS MyNumber

	UNION ALL

	-- Recursive query
	SELECT MyNumber + 1
	FROM cte_Series
	WHERE MyNumber < 20
)
-- Main query
SELECT *
FROM cte_Series
-- OPTION(MAXRECURSION 10); -- Stops at maximum 10 recursion, you can set it to 1000 or any number
GO

-- Show the employee hierarchy by displaying each employee's level within the organization

WITH cte_EmpHierarchy AS(

	-- Anchor query
	SELECT 
		se1.EmployeeID,
		se1.FirstName,
		se1.ManagerID,
		1 AS Level
	FROM Sales.Employees AS se1
	WHERE se1.ManagerID IS NULL

	UNION ALL

	-- Recursive query
	SELECT
		se2.EmployeeID,
		se2.FirstName,
		se2.ManagerID,
		Level + 1
	FROM Sales.Employees AS se2
	INNER JOIN cte_EmpHierarchy AS cte_eh
		ON se2.ManagerID = cte_eh.EmployeeID
)

-- Main query
SELECT *
FROM cte_EmpHierarchy;
GO