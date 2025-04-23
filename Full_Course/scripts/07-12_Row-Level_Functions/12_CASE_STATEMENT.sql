/*
            -----------------------------------------------------------------------------------------------
			        DOC: 07_Row_Level_Functions.pdf
					CONNECTION: SalesBD

                                           SQL CASE STATEMENT
										      (08:07:55)

					This script demonstrates various use cases of the SQL CASE statement, including
					data categorization, mapping, quick form syntax, handling nulls, and conditional 
					aggregation.
   
					Table of Contents:
						1. Categorize Data
						2. Mapping
						3. Quick Form of Case Statement
						4. Handling Nulls
						5. Conditional Aggregation
			-----------------------------------------------------------------------------------------------
*/

USE SalesDB;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                    CATEGORIZE DATA
												  (08:18:25)
			-----------------------------------------------------------------------------------------------
*/
-- Group the data into different categories based on certain conditions.

/*  
   Create a report showing total sales for each category:
	   - High: Sales over 50
	   - Medium: Sales between 20 and 50
	   - Low: Sales 20 or less
   The results are sorted from highest to lowest total sales.
*/

-- <<<<< Rule >>>>>
-- !!!!!!The data type of the resutls must be matching!!!!!

SELECT
	sub.Category,
	SUM(sub.Sales) AS TotalSales
	FROM(
		SELECT
			so.OrderID,
			so.Sales,
			CASE
				WHEN so.Sales > 50 THEN 'High'
				WHEN so.Sales > 20 THEN 'Medium'
				ELSE 'Low'
			END AS Category
		FROM Sales.Orders AS so
	) AS sub -- sub = SubQuery
GROUP BY sub.Category
ORDER BY TotalSales DESC;
GO

/*
            -----------------------------------------------------------------------------------------------
												   MAPPING
												  (08:24:34)
			-----------------------------------------------------------------------------------------------
*/

-- Retrieve employee details with gender displayed as full text.
SELECT
	se.EmployeeID,
	se.FirstName,
	se.LastName,
	se.Gender,
	CASE
		WHEN se.Gender = 'F' THEN 'Female'
		WHEN se.Gender = 'M' THEN 'Male'
		ELSE 'Not Available'
	END AS GenderFullText
FROM Sales.Employees AS se;
GO

-- Retrieve customer details with abbreviated country codes using quick form.
SELECT
	sc.CustomerID,
	sc.FirstName,
	sc.LastName,
	sc.Country,
	CASE
		WHEN sc.Country = 'Germany' THEN 'DE'
		WHEN sc.Country = 'USA' THEN 'US'
		ELSE 'N/A'
	END AS CountryAbbr
FROM Sales.Customers AS sc;
GO

-- QUICK FORM: Only for EXACT MATCHES (Not ofr >, <, >=, <=, ...)
SELECT
	sc.CustomerID,
	sc.FirstName,
	sc.LastName,
	sc.Country,
	CASE sc.Country
		WHEN 'Germany' THEN 'DE'
		WHEN 'USA' THEN 'US'
		ELSE 'N/A'
	END AS CountryAbbr
FROM Sales.Customers AS sc;
GO

SELECT DISTINCT sc.Country
FROM Sales.Customers AS sc;
GO

/*
            -----------------------------------------------------------------------------------------------
												 HADNLING NULLS
												  (08:33:30)
			-----------------------------------------------------------------------------------------------
*/
-- Replace NULLS with a specific value. 
-- NULLS can lead to inaccurate results, which can lead to wrong decision-making.

-- Calculate the average score of customers, treating NULL as 0,
-- and provide CustomerID and LastName details.
SELECT
	sc.CustomerID,
	sc.LastName,
	sc.Score,
	CASE
		WHEN sc.Score IS NULL THEN 0
		ELSE sc.Score
	END AS ScoreClean,
	AVG(
		CASE
			WHEN sc.Score IS NULL THEN 0
			ELSE sc.Score
		END
	) OVER () AS AvgCustomerScoreClean,
	AVG(sc.Score) OVER() AS AvgCustomerScore
FROM Sales.Customers AS sc;
GO

-- Only 1 value to show with an added dynamic column that is counting
SELECT
	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Result,
	AVG(
		CASE
			WHEN sc.Score IS NULL THEN 0
			ELSE sc.Score
		END
	) AS AvgCustomerScore
FROM Sales.Customers AS sc;
GO

/*
            -----------------------------------------------------------------------------------------------
											CONDITIONAL AGGREGATION
												  (08:37:08)
			-----------------------------------------------------------------------------------------------
*/
-- Apply aggregate functions only on subsets of data that fulfill certain conditions.

-- Count how many orders each customer made with sales greater than 30
-- FLAG: Binary indicator (1, 0) to be summarized to show how many times the condition is true.
-- 1. step: Add a helper column with 1 and 0s
SELECT
	so.OrderID,
	so.CustomerID,
	so.Sales,
	CASE
		WHEN so.Sales > 30 THEN 1
		ELSE 0
	END AS SalesFlag
FROM Sales.Orders AS so
ORDER by so.CustomerID;
GO

-- 2. step
SELECT
	so.CustomerID,
	COUNT(*) AS TotalOrders,
	SUM(
		CASE
			WHEN so.Sales > 30 THEN 1
			ELSE 0
		END
	) AS TotalOrdersHigher30
FROM Sales.Orders AS so
GROUP BY so.CustomerID
ORDER BY so.CustomerID ASC;
GO