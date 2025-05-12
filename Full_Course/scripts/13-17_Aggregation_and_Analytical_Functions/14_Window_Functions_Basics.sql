/*
            -----------------------------------------------------------------------------------------------
			        DOC: 07_Aggregation_Analytical_Functions.pdf
					CONNECTION: SalesBD

                                           SQL WINDOW FUNCTIONS BASICS
										      (08:49:50)

					SQL window functions enable advanced calculations across sets of rows 
					related to the current row without resorting to complex subqueries or joins.
					This script demonstrates the fundamentals and key clauses of window functions,
					including the OVER, PARTITION, ORDER, and FRAME clauses, as well as common rules 
					and a GROUP BY use case.

					Description: Perform calculations (e.g. aggregation) on a specific subset of data,
					without losing the level of details of rows.

					Table of Contents:
					1. SQL Window Basics
					2. SQL Window OVER Clause
					3. SQL Window PARTITION Clause
					4. SQL Window ORDER Clause
					5. SQL Window FRAME Clause
					6. SQL Window Rules
					7. SQL Window with GROUP BY
					8. SQL Window Syntax Explanation
			-----------------------------------------------------------------------------------------------
*/


USE SalesDB;
GO


/*
            -----------------------------------------------------------------------------------------------
													BASICS
												  (08:52:00)
			-----------------------------------------------------------------------------------------------
*/

-- Calculate the Total Sales Across All Orders
SELECT
	SUM(so.Sales) AS TotalSales
FROM Sales.Orders AS so;
GO

-- Calculate the Total Sales for Each Product 

-- Result granularity: The number of rows in the output is defined by the dimension
SELECT
	so.ProductID,
	SUM(so.Sales) AS TotalSales
FROM Sales.Orders AS so
GROUP BY so.ProductID;
GO

/*
            -----------------------------------------------------------------------------------------------
												  OVER Clause
												  (08:58:00)
			-----------------------------------------------------------------------------------------------
*/
-- Tells SQL that the function used is a window function
-- It defines a window or subset of data

-- Find the total sales across all orders,
-- additionally providing details such as OrderID and OrderDate 

-- ALL columns in SELECT must be included in GROUP BY
-- Can not do aggregations and provide details at the same time

-- BAD:
SELECT
	so.OrderID,
	so.OrderDate,
	so.ProductID,
	SUM(so.Sales) AS TotalSales
FROM Sales.Orders AS so
GROUP BY 
	so.OrderID,
	so.OrderDate,
	so.ProductID;
GO

-- GOOD:
-- Window functions returns a result for each row
SELECT
	so.OrderID,
    so.OrderDate,
    so.ProductID,
    so.Sales,
	SUM(so.Sales) OVER() AS TotalSales
FROM Sales.Orders AS so;
GO

/*
            -----------------------------------------------------------------------------------------------
												  PARTITION (BY) Clause
												  (09:00:50) & (09:08:08)
			-----------------------------------------------------------------------------------------------
*/
-- Divides the result set into partitions (Windows).

-- Same task as in OVER Clause (Above)
-- Find the total sales across all orders,
-- additionally providing details such as OrderID and OrderDate
SELECT
	so.OrderID,
    so.OrderDate,
    so.ProductID,
    so.Sales,
	SUM(so.Sales) OVER() AS TotalSales,
	SUM(so.Sales) OVER(PARTITION BY so.ProductID) AS TotalSalesByProducts
FROM Sales.Orders AS so;
GO

-- Find the total sales across all orders, for each product,
-- and for each combination of product and order status,
-- additionally providing details such as OrderID and OrderDate
SELECT
	so.OrderID,
    so.OrderDate,
    so.ProductID,
	so.OrderStatus,
    so.Sales,
	SUM(so.Sales) OVER() AS TotalSales,
	SUM(so.Sales) OVER(PARTITION BY so.ProductID) AS TotalSalesByProducts,
	SUM(so.Sales) OVER(PARTITION BY so.ProductID, so.OrderStatus) AS SalesByProductAndStatus
FROM Sales.Orders AS so;
GO

/*
            -----------------------------------------------------------------------------------------------
												  ORDER (BY) Clause
												  (09:18:25)
			-----------------------------------------------------------------------------------------------
*/
-- Sort the data within a window.

-- Rank each order by Sales from highest to lowest
SELECT
	so.OrderID,
	so.OrderDate,
	so.Sales,
	RANK() OVER(ORDER BY so.Sales DESC) AS RankSales
FROM Sales.Orders AS so;
GO

/*
            -----------------------------------------------------------------------------------------------
												  FRAME Clause
												  (09:22:30)
			-----------------------------------------------------------------------------------------------
*/
-- Defines a subset of rows within each window that is relevant for the calculation

-- [Window Func] OVER([Partition] [Order] [Frame])

-- Example:
-- AVG(Sales) OVER(PARTITION BY Category ORDER BY OrderDate ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)

-- FRAME: ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING

-- RULES: Frame clause can only be used together with order by clause.
--		  Lower value must be BEFORE the Higher value.

-- VISUAL EXPLANATION: 09:26:05

-- Example starts at 09:32:06
SELECT
	so.OrderID,
	so.OrderDate,
	so.OrderStatus,
	so.Sales,
	SUM(so.Sales) OVER(
						PARTITION BY so.OrderStatus 
						ORDER BY so.OrderDate
						ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING
				  ) AS TotalSales
FROM Sales.Orders AS so;
GO

-- COMPACT form of FRAME (09:34:10)
-- For only PRECEDING, the CURRENT ROW can be skipped
SELECT
	so.OrderID,
	so.OrderDate,
	so.OrderStatus,
	so.Sales,
	SUM(so.Sales) OVER(
						PARTITION BY so.OrderStatus 
						ORDER BY so.OrderDate
					 -- ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
						ROWS 2 PRECEDING -- Compact form for the commented out above
				  ) AS TotalSales
FROM Sales.Orders AS so;
GO

-- DEFAULT FRAME (09:35:16)
-- SQL uses default frame, if ORDER BY is used without FRAME
-- DEFAULT FRAME is : ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
SELECT
	so.OrderID,
	so.OrderDate,
	so.OrderStatus,
	so.Sales,
	SUM(so.Sales) OVER(
						PARTITION BY so.OrderStatus 
						ORDER BY so.OrderDate
						ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW -- This is the DEFAULT, you can leave this
				  ) AS TotalSales
FROM Sales.Orders AS so;
GO

/*
            -----------------------------------------------------------------------------------------------
												  WINDOW Syntax Explanation
												  (09:03:05)
			-----------------------------------------------------------------------------------------------
*/
-- [Window Func] OVER([Partition] [Order] [Frame])

-- Example:
-- AVG(Sales) OVER(PARTITION BY Category ORDER BY OrderDate ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)

-- [Window Func]: Perform calculations within a window
--					- Aggregate Functions (COUNT, SUM, AVG, MAX, MIN, ...)
--					- Rank Functions (ROW_NUMBER, RANK, DENSE_RANK, CUME_DIST, PERCENT_RANK, NTILE, ...)
--					- Value/Analytics Functions (LEAD, LAG, FIRST_VALUE, LAST_VALUE, ...)

-- Sales: Function Expression -> Arguments you pass to a function
-- Description: 09:06:04 or Window_Expression.png

-- OVER: Tells SQL that the function used is a window function
--		 It defines a window or subset of data

/*
            -----------------------------------------------------------------------------------------------
												  RULES
												  (09:37:10)
			-----------------------------------------------------------------------------------------------
*/

-- <<<<< #1 Rule >>>>>
-- Window functions can only be used in SELECT or ORDER BY clauses
-- BAD:
SELECT
    so.OrderID,
    so.OrderDate,
    so.ProductID,
    so.OrderStatus,
    so.Sales,
    SUM(so.Sales) OVER (PARTITION BY so.OrderStatus) AS TotalSales
FROM Sales.Orders AS so
WHERE SUM(so.Sales) OVER (PARTITION BY so.OrderStatus) > 100;  -- Invalid: window function in WHERE clause
GO

-- GOOD:
SELECT
    so.OrderID,
    so.OrderDate,
    so.ProductID,
    so.OrderStatus,
    so.Sales,
    SUM(so.Sales) OVER (PARTITION BY so.OrderStatus) AS TotalSales
FROM Sales.Orders AS so
ORDER BY SUM(so.Sales) OVER (PARTITION BY so.OrderStatus) DESC;  -- ORDER BY so.OrderStatus DESC   <- This does the same
GO

-- <<<<< #2 Rule >>>>>
-- Window functions cannot be nested 
SELECT
    so.OrderID,
    so.OrderDate,
    so.ProductID,
    so.OrderStatus,
    so.Sales,
    SUM(SUM(so.Sales) OVER (PARTITION BY so.OrderStatus)) OVER (PARTITION BY so.OrderStatus) AS TotalSales  -- Invalid nesting
FROM Sales.Orders AS so;
GO

-- <<<<< #3 Rule >>>>>
-- SQL execute WINDOW Functions AFTER WHERE Clause (after filtering data)

-- Find the total sales for each order status, only for two products 101 and 102
SELECT
    so.OrderID,
    so.OrderDate,
    so.ProductID,
    so.OrderStatus,
    so.Sales,
    SUM(so.Sales) OVER (PARTITION BY so.OrderStatus) AS TotalSales
FROM Sales.Orders AS so
WHERE so.ProductID IN (101, 102);
GO

/*
            -----------------------------------------------------------------------------------------------
													GROUP BY
												  (09:40:25)
			-----------------------------------------------------------------------------------------------
*/
-- <<<<< #4 Rule >>>>>
-- Window Function can be used together with GROUP BY in the same query,
-- ONLY if the same columns are used

-- Rank customers by their total sales
SELECT
	so.CustomerID,
    SUM(so.Sales) AS TotalSales,
	RANK() OVER(ORDER BY SUM(so.Sales) DESC) AS RankCustomers
FROM Sales.Orders AS so
GROUP BY so.CustomerID;
GO