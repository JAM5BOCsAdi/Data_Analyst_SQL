/*
            -----------------------------------------------------------------------------------------------
			        DOC: 07_Aggregation_Analytical_Functions.pdf
					CONNECTION: SalesBD

                                           SQL WINDOW AGGREGATE FUNCTIONS
										      (09:46:50)

					These functions allow you to perform aggregate calculations over a set 
					of rows without the need for complex subqueries. They enable you to compute 
					counts, sums, averages, minimums, and maximums while still retaining access 
					to individual row details.

					Table of Contents:
						1. COUNT
						2. SUM
						3. AVG
						4. MAX / MIN
						5. ROLLING SUM & AVERAGE Use Case
			-----------------------------------------------------------------------------------------------
*/


USE SalesDB;
GO


/*
            -----------------------------------------------------------------------------------------------
													COUNT
												  (09:49:10)
			-----------------------------------------------------------------------------------------------
*/
-- Returns the number of rows within a window.

-- Find the total number of Orders, additionally provide details such as order id and order

SELECT
	so.OrderID,
	so.OrderDate,
	COUNT(*) OVER() AS TotalOrders
FROM Sales.Orders AS so;
GO

-- Find the Total Number of Orders and the Total Number of Orders for Each Customer
SELECT
	so.OrderID,
	so.OrderDate,
	CustomerID,
	COUNT(*) OVER() AS TotalOrders,
	COUNT(*) OVER(PARTITION BY so.CustomerID) AS OrdersByCustomers
FROM Sales.Orders AS so;
GO

-- Find the total number of customers, additionally provide all customer's details
SELECT 
	*,
	COUNT(*) OVER() AS TotalCustomers
FROM Sales.Customers AS sc;
GO

-- Find the total number of scores for the customers
SELECT 
	*,
	COUNT(*) OVER() AS TotalCustomersStar,
	COUNT(1) OVER() AS TotalCustomersOne,
	COUNT(sc.Score) OVER() AS ScoreNumber,
	COUNT(sc.Country) OVER() AS ScoreCountries
FROM Sales.Customers AS sc;
GO

-- Check wether the table 'Orders' contains any duplicate rows
SELECT
	so.OrderID,
	COUNT(*) OVER(PARTITION BY so.OrderID) AS CheckPK
FROM Sales.Orders AS so;
GO

SELECT
*
FROM(
	SELECT
		soa.OrderID,
		COUNT(*) OVER(PARTITION BY soa.OrderID) AS CheckPK
	FROM Sales.OrdersArchive AS soa
) AS sub
WHERE sub.CheckPK > 1;
GO

/*
            -----------------------------------------------------------------------------------------------
													SUM
												  (10:05:48)
			-----------------------------------------------------------------------------------------------
*/
-- Returns the sum of values within a window.

-- Find the total sales across all orders and
-- the total sales for each product
-- Additionally, provide details such as orderID and OrderDate
SELECT
	so.OrderID,
	so.OrderDate,
	so.Sales,
	SUM(so.Sales) OVER() AS TotalSales,
	SUM(so.Sales) OVER(PARTITION BY so.ProductID) AS SalesByProducts
FROM Sales.Orders AS so;
GO

-- <<<<< Comparison Use Cases (10:10:05) - PART-TO-WHOLE >>>>>
-- Compare the current value and aggregated value of window functions.

-- Find the Percentage Contribution of Each Product's Sales to the Total Sales
SELECT
	so.OrderID,
	so.ProductID,
	so.Sales,
	SUM(so.Sales) OVER() AS TotalSales,
	ROUND(CAST(so.Sales AS FLOAT) / SUM(so.Sales) OVER() * 100, 2) AS PercentOfTotal
FROM Sales.Orders AS so;
GO

/*
            -----------------------------------------------------------------------------------------------
													AVG
												  (10:13:14)
			-----------------------------------------------------------------------------------------------
*/
-- Returns the average of values within a window.

-- Find the average sales across all orders
-- and find the average sales for each product
-- Additionally provide details such OrderID, OrderDate
SELECT
	so.OrderID,
	so.OrderDate,
	so.Sales,
	so.ProductID,
	AVG(so.Sales) OVER() AS AvgSales, -- Overall analysis
	AVG(so.Sales) OVER(PARTITION BY so.ProductID) AS AvgSalesByProducts
FROM Sales.Orders AS so;
GO

-- Find the Average Scores of Customers
-- Additionally provide details such as CustomerID and LastName
SELECT
	sc.CustomerID,
	sc.LastName,
	sc.Score,
	COALESCE(sc.Score, 0) AS CustomerScore,
	AVG(COALESCE(sc.Score, 0)) OVER() AS AvgScore
FROM Sales.Customers AS sc;
GO

-- Find all orders where sales are higher than the average sales across all orders
-- WINDOW Functions CAN NOT be used in the WHERE clause
SELECT
	*
FROM(
	SELECT	
		so.OrderID,
		so.ProductID,
		so.Sales,
		AVG(so.Sales) OVER() AS AvgSales
	FROM Sales.Orders AS so
) AS sub
WHERE sub.Sales > sub.AvgSales;
GO

/*
            -----------------------------------------------------------------------------------------------
												   MIN / MAX
												  (10:22:19)
			-----------------------------------------------------------------------------------------------
*/
-- Returns the lowest / highest alue within a window.

-- Find the Highest and Lowest Sales across all orders
SELECT
	MIN(so.Sales) AS MinSales,
	MAX(so.Sales) AS MaxSales
FROM Sales.Orders AS so;
GO

-- Find the Lowest Sales across all orders and by Product
SELECT
	so.OrderID,
	so.OrderDate,
	so.ProductID,
	so.Sales,
	MIN(so.Sales) OVER() AS MinSales,
	MIN(so.Sales) OVER(PARTITION BY so.ProductID) AS MinSalesByProduct
FROM Sales.Orders AS so;
GO

-- Show the employees who have the highest salaries
SELECT
	*
FROM(
	SELECT
		*,
		MAX(se.Salary) OVER() AS HighestSalary
	FROM Sales.Employees AS se
) AS sub
WHERE sub.Salary = sub.HighestSalary;
GO

-- <<<<< Comparison Use Cases (10:29:38) >>>>>
-- Find the deviation of each Sales from the MIN and MAX Sales
SELECT
	so.OrderID,
	so.OrderDate,
	so.ProductID,
	so.Sales,
	MIN(so.Sales) OVER() AS MinSales,
	MAX(so.Sales) OVER() AS MaxSales,
	so.Sales - MIN(so.Sales) OVER() AS DeviationFromMin,
	MAX(so.Sales) OVER() - so.Sales AS DeviationFromMax
FROM Sales.Orders AS so;
GO

/*
            -----------------------------------------------------------------------------------------------
										RUNNING & ROLLING TOTAL (SUM & AVG)
												  (10:31:56)
			-----------------------------------------------------------------------------------------------
*/
-- RUNNING TOTAL: 
-- Aggregate all values from the beginning up to the curremt point without dropping off older data.

-- ROLLING TOTAL: 
-- Aggregate all values within a fixed time window (e.g. 30 days). As new data is added, the oldest data point will be dropped.

-- Calculate the Running sum of Sales for each Product over time
SELECT
	so.OrderID,
	so.OrderDate,
	so.ProductID,
	so.Sales,
	SUM(so.Sales) OVER(PARTITION BY so.ProductID) AS SumByProduct,
	SUM(so.Sales) OVER(PARTITION BY so.ProductID ORDER BY so.OrderDate ASC) AS RunningSum
FROM Sales.Orders AS so;
GO

-- Calculate the  Running sum of Sales for each Product over time, including only the next Order
SELECT
	so.OrderID,
	so.OrderDate,
	so.ProductID,
	so.Sales,
	SUM(so.Sales) OVER(PARTITION BY so.ProductID) AS SumByProduct,
	SUM(so.Sales) OVER(PARTITION BY so.ProductID ORDER BY so.OrderDate ASC) AS RunningSum,
	SUM(so.Sales) OVER(PARTITION BY so.ProductID ORDER BY so.OrderDate ASC ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) AS RollingSum
FROM Sales.Orders AS so;
GO

-- Calculate the moving average (= Running average) of Sales for each Product over time
SELECT
	so.OrderID,
	so.OrderDate,
	so.ProductID,
	so.Sales,
	AVG(so.Sales) OVER(PARTITION BY so.ProductID) AS AvgByProduct,
	AVG(so.Sales) OVER(PARTITION BY so.ProductID ORDER BY so.OrderDate ASC) AS MovingAvg
FROM Sales.Orders AS so;
GO

-- Calculate the moving average (= Running average) of Sales for each Product over time, including only the next Order
SELECT
	so.OrderID,
	so.OrderDate,
	so.ProductID,
	so.Sales,
	AVG(so.Sales) OVER(PARTITION BY so.ProductID) AS AvgByProduct,
	AVG(so.Sales) OVER(PARTITION BY so.ProductID ORDER BY so.OrderDate ASC) AS MovingAvg,
	AVG(so.Sales) OVER(PARTITION BY so.ProductID ORDER BY so.OrderDate ASC ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) AS RollingAvg
FROM Sales.Orders AS so;
GO

/*
            -----------------------------------------------------------------------------------------------
												  OVERVIEW
												  (10:48:45)
			-----------------------------------------------------------------------------------------------
*/
/*
	Overall Total:
	SUM(Sales) OVER()

	- Overview of entire data

	**********************************

	Total Per Groups:
	SUM(Sales) OVER(PARTITION BY Product)

	- Compare cetegories

	**********************************

	Running Total:
	SUM(Sales) OVER(ORDER BY Month)

	- Progress over time

	**********************************

	Rolling Total:
	SUM(Sales) OVER(ORDER BY Month ROWS 2 PRECEDING)

	- Progress over time in specific fixed window
*/