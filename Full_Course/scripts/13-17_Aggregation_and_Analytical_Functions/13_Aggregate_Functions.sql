/*
            -----------------------------------------------------------------------------------------------
			        DOC: 08_Aggregation_Analytical_Functions.pdf
					CONNECTION: MyDatabase

                                           SQL AGGREGATE FUNCTIONS
										      (08:43:34)

					This document provides an overview of SQL aggregate functions, which allow 
					performing calculations on multiple rows of data to generate summary results.

					Table of Contents:
					1. Basic Aggregate Functions
						- COUNT
						- SUM
						- AVG
						- MAX
						- MIN
					2. Grouped Aggregations
						- GROUP BY
			-----------------------------------------------------------------------------------------------
*/

USE MyDatabase;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                    BASIC AGGREGATE FUNCTIONS
												  (08:44:00)
			-----------------------------------------------------------------------------------------------
*/

-- COUNT:
-- Find the total number of customers
SELECT COUNT(*) AS TotalCustomers
FROM MyDatabase.dbo.customers AS mdc;
GO

-- SUM:
-- Find the total sales of all orders
SELECT SUM(mdo.sales) AS TotalSales
FROM MyDatabase.dbo.orders AS mdo;
GO

-- AVG:
-- Find the average sales of all orders
SELECT AVG(mdo.sales) AS AvgSales
FROM MyDatabase.dbo.orders AS mdo;
GO

-- MAX:
-- Find the highest score among customers
SELECT MAX(mdc.score) AS MaxScore
FROM MyDatabase.dbo.customers AS mdc;
GO

-- MIN:
-- Find the lowest score among customers
SELECT MIN(mdc.score) AS MinScore
FROM MyDatabase.dbo.customers AS mdc;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                    GROUPED AGGREGATIONS
												  (08:48:25)
			-----------------------------------------------------------------------------------------------
*/
-- GROUP BY:
-- Find the number of orders, total sales, average sales, highest sales, and lowest sales per customer
SELECT
    mdo.customer_id,
    COUNT(*) AS TotalOrders,
    SUM(mdo.sales) AS TotalSales,
    AVG(mdo.sales) AS AvgSales,
    MAX(mdo.sales) AS HighestSales,
    MIN(mdo.sales) AS LowestSales
FROM MyDatabase.dbo.orders AS mdo
GROUP BY mdo.customer_id;
GO