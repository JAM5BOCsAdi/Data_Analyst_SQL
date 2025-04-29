/*
            -----------------------------------------------------------------------------------------------
			        DOC: 08_Aggregation_Analytical_Functions.pdf
					CONNECTION: SalesBD

                                           SQL WINDOW VALUE FUNCTIONS
										      (11:56:08)

					These functions let you reference and compare values from other rows 
					in a result set without complex joins or subqueries, enabling advanced 
					analysis on ordered data.

					Table of Contents:
						1. LEAD
						2. LAG
						3. FIRST_VALUE
						4. LAST_VALUE
			-----------------------------------------------------------------------------------------------
*/


USE SalesDB;
GO

/*
            -----------------------------------------------------------------------------------------------
												  LEAD | LAG [Similar to each other]
												  (11:59:45)
			-----------------------------------------------------------------------------------------------
*/
-- LEAD:
-- Access a value from the NEXT ROW within a window.

-- LAG:
-- Access a value from the PREVIOUS ROW within a window.

-- <<<<< MoM - Month-Over-Month Analysis (12:09:45) >>>>>
-- Analyze the MoM performance by finding the precentage change in sales between the current and previous month

SELECT
	*,
	sub.CurrentMonthSales - sub.PrevMonthSale AS MoMChange,
	ROUND(CAST(sub.CurrentMonthSales - sub.PrevMonthSale AS FLOAT) / sub.PrevMonthSale * 100, 1) AS MoMPerc
FROM(
	SELECT
		MONTH(so.OrderDate) AS OrderMonth,
		SUM(so.Sales) AS CurrentMonthSales,
		LAG(SUM(so.Sales)) OVER(ORDER BY MONTH(so.OrderDate)) AS PrevMonthSale
	FROM 
		Sales.Orders AS so
	GROUP BY 
		MONTH(so.OrderDate)
)AS sub;
GO

-- <<<<< Customer Retention Analysis (12:16:50) >>>>>
-- Analyze customer loyalty by ranking customers based on the average number of days between orders
SELECT
	sub.CustomerID,
	AVG(sub.DaysUntilNextOrder) AS AvgDays,
	RANK() OVER(ORDER BY AVG(sub.DaysUntilNextOrder) ASC) AS RankAvg
FROM(
	SELECT
		so.OrderID,
		so.CustomerID,
		so.OrderDate AS CurrentOrder,
		LEAD(so.OrderDate) OVER(PARTITION BY so.CustomerID ORDER BY so.OrderDate) AS NextOrder,
		DATEDIFF(day, so.OrderDate, LEAD(so.OrderDate) OVER(PARTITION BY so.CustomerID ORDER BY so.OrderDate)) AS DaysUntilNextOrder
	FROM Sales.Orders AS so
) AS sub
GROUP BY sub.CustomerID
HAVING AVG(sub.DaysUntilNextOrder) IS NOT NULL;
GO

/*
            -----------------------------------------------------------------------------------------------
												  FIRST_VALUE | LAST_VALUE [Similar to each other]
												  (12:25:08)
			-----------------------------------------------------------------------------------------------
*/
-- FIRST_VALUE:
-- Access a value from the FIRST row within a window.

-- LAST_VALUE:
-- Access a value from the LAST row within a window.

-- Find the lowest and highest sales or each product
SELECT
	so.OrderID,
	so.ProductID,
	so.Sales,
	FIRST_VALUE(so.Sales) OVER(PARTITION BY so.ProductID ORDER BY so.Sales ASC) AS LowestSales_01,
	LAST_VALUE(so.Sales) OVER(
							PARTITION BY so.ProductID ORDER BY so.Sales ASC 
							ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
						 ) AS HighestSales_01,
	FIRST_VALUE(so.Sales) OVER(PARTITION BY so.ProductID ORDER BY so.Sales DESC) AS HighestSales_02,
	MIN(so.Sales) OVER(PARTITION BY so.ProductID) AS LowestSales_02,
	MAX(so.Sales) OVER(PARTITION BY so.ProductID) AS HighestSales_03
FROM Sales.Orders AS so;
GO

-- Find the lowest and highest sales or each product
-- Find the difference in sales between the current and the lowest sales
SELECT
	so.OrderID,
	so.ProductID,
	so.Sales,
	FIRST_VALUE(so.Sales) OVER(PARTITION BY so.ProductID ORDER BY so.Sales ASC) AS LowestSales,
	FIRST_VALUE(so.Sales) OVER(PARTITION BY so.ProductID ORDER BY so.Sales DESC) AS HighestSales,
	so.Sales - FIRST_VALUE(so.Sales) OVER(PARTITION BY so.ProductID ORDER BY so.Sales ASC) AS SalesDiff
FROM Sales.Orders AS so;
GO