/*
            -----------------------------------------------------------------------------------------------
			        DOC: 08_Aggregation_Analytical_Functions.pdf
					CONNECTION: SalesBD

                                           SQL WINDOW RANKING FUNCTIONS
										      (10:53:08)

					These functions allow you to rank and order rows within a result set 
					without the need for complex joins or subqueries. They enable you to assign 
					unique or non-unique rankings, group rows into buckets, and analyze data 
					distributions on ordered data.

					Table of Contents:
					1. INTEGER-based Ranking (TOP/BOTTOM N Analysis - Find the Top 3 Products)
						1. ROW_NUMBER
						2. RANK
						3. DENSE_RANK
						4. NTILE
					2. PERCENTAGE-based Ranking (Distribution Analysis - Find Top 20% Products)
						1. CUME_DIST
						2. PERcENT_RANK
			-----------------------------------------------------------------------------------------------
*/


USE SalesDB;
GO

/*
	***************************************************************************************************************
												INTEGER-based Ranking
	***************************************************************************************************************
*/

/*
            -----------------------------------------------------------------------------------------------
												  ROW_NUMBER
												  (10:58:05)
			-----------------------------------------------------------------------------------------------
*/
-- Assign a unique number to each row.
-- It DOES NOT handle ties. (So same number will not share the same value)

-- For example:
-- Sales    |   Rank
-- 100			 1
-- 80			 2
-- 80			 3
-- 50			 4
-- 20			 5

-- Rank the orders based on their sales from highest to lowest
SELECT
	so.OrderID,
	so.ProductID,
	so.Sales,
	ROW_NUMBER() OVER(ORDER BY so.Sales DESC) AS SalesRank_Row
FROM Sales.Orders AS so;
GO

/*
            -----------------------------------------------------------------------------------------------
													 RANK
												  (11:02:30)
			-----------------------------------------------------------------------------------------------
*/
-- Assign a rank to each row.
-- It HANDLES ties.
-- It leaves GAPS in the ranking.

-- For example:
-- Sales    |   Rank
-- 100			 1
-- 80			 2
-- 80			 2  <-- Same as before
-- 50			 4  <-- It is in Position 4 (count from up to down) and will leave a GAP (3) after the previous value
-- 20			 5

-- Rank the orders based on their sales from highest to lowest
SELECT
	so.OrderID,
	so.ProductID,
	so.Sales,
	ROW_NUMBER() OVER(ORDER BY so.Sales DESC) AS SalesRank_Row,
	RANK() OVER(ORDER BY so.Sales DESC) AS SalesRank_Rank
FROM Sales.Orders AS so;
GO

/*
            -----------------------------------------------------------------------------------------------
												  DENSE_RANK
												  (11:06:35)
			-----------------------------------------------------------------------------------------------
*/
-- Assign a rank to each row.
-- It handles ties.
-- It DOES NOT leave anys gaps in ranking.

-- For example:
-- Sales    |   Rank
-- 100			 1
-- 80			 2
-- 80			 2
-- 50			 3 <-- No Gap(s)
-- 20			 4


SELECT
	so.OrderID,
	so.ProductID,
	so.Sales,
	ROW_NUMBER() OVER(ORDER BY so.Sales DESC) AS SalesRank_Row,
	RANK() OVER(ORDER BY so.Sales DESC) AS SalesRank_Rank,
	DENSE_RANK() OVER(ORDER BY so.Sales DESC) AS SalesRank_Dense
FROM Sales.Orders AS so;
GO

/*
            -----------------------------------------------------------------------------------------------
												EXAMPLE USE CASES [ROW_NUMBER]
												  (11:12:30)
			-----------------------------------------------------------------------------------------------
*/

-- <<<<< TOP/BOTTOM N Analysis (11:12:30) >>>>>
-- Find the TOP 1 highest sales for each product
SELECT
	*
FROM(
	SELECT
		so.OrderID,
		so.ProductID,
		so.Sales,
		ROW_NUMBER() OVER(PARTITION BY so.ProductID ORDER BY so.Sales DESC) AS RankByProduct
	FROM Sales.Orders AS so
) AS sub
WHERE RankByProduct = 1;
GO

-- Find the lowest 2 Customers based on their total sales
SELECT
	*
FROM(
	SELECT
		so.CustomerID,
		SUM(so.Sales) AS TotalSales,
		ROW_NUMBER() OVER(ORDER BY SUM(so.Sales) ASC) AS RankCustomers
	FROM Sales.Orders AS so
	GROUP BY so.CustomerID
) sub
WHERE sub.RankCustomers <= 2;
GO

-- <<<<< Generate unique IDs (11:19:40) >>>>>
-- Assign unique IDs to the rows of the 'Orders Archive' table [= Make Primary Key if we do not have]
SELECT
	ROW_NUMBER() OVER(ORDER BY soa.OrderID, soa.OrderDate) AS UniqueID,
	*
FROM Sales.OrdersArchive AS soa;
GO

-- <<<<< Identify duplicates (11:22:06) >>>>>
--Identify DUPLICATE rows in the table 'Orders Archive' and return a clean result without any duplicates
SELECT
	*
FROM(
	SELECT
		ROW_NUMBER() OVER(PARTITION BY soa.OrderID ORDER BY soa.CreationTime DESC) AS rn,
		*
	FROM Sales.OrdersArchive AS soa
)AS sub
WHERE sub.rn = 1;
GO

/*
            -----------------------------------------------------------------------------------------------
													NTILE
												  (11:27:45)
			-----------------------------------------------------------------------------------------------
*/
-- Divides the rows into a specified number of approximately equal groups (Buckets).

-- NTILE(2) OVER(ORDER bY Sales DESC)

-- Bucket Size = Nr. of Rows / Nr. of Buckets
-- 2.5 = 5 / 2
-- Rule: Larger groups come first.

-- For example:
-- Sales     |     NTILE
-- 100              1
-- 80               1
-- 80               1 <-- This is connected to the first Bucket, so it is the larger with 3 items
-- 50               2
-- 30               2

SELECT
	so.OrderID,
	so.Sales,
	NTILE(1) OVER(ORDER BY so.Sales DESC) AS OneBucket,
	NTILE(2) OVER(ORDER BY so.Sales DESC) AS TwoBuckets,
	NTILE(3) OVER(ORDER BY so.Sales DESC) AS ThreeBuckets,
	NTILE(4) OVER(ORDER BY so.Sales DESC) AS FourBuckets
FROM Sales.Orders AS so;
GO

/*
            -----------------------------------------------------------------------------------------------
												EXAMPLE USE CASES [NTILE]
												  (11:33:55)
			-----------------------------------------------------------------------------------------------
*/

-- <<<<< Data Segmentation (11:34:20) >>>>>
-- Divides a dataset into distinct subsets based on certain criteria.

-- Segment all orders into 3 categories: high, medium and low sales
SELECT
	*,
	CASE sub.Buckets
		WHEN 1 THEN 'High'
		WHEN 2 THEN 'Medium'
		WHEN 3 THEN 'Low'
	END AS Segmentations
FROM(
	SELECT
		so.OrderID,
		so.Sales,
		NTILE(3) OVER(ORDER BY so.Sales DESC) AS Buckets
	FROM Sales.Orders AS so
)AS sub;
GO

-- <<<<< Equalizing load (11:37:53) >>>>>
-- In order to export the data, divide the orders into 2 groups
SELECT
	NTILE(2) OVER(ORDER BY so.OrderID) AS Buckets,
	*
FROM Sales.Orders AS so;
GO

/*
	***************************************************************************************************************
												PERCENTAGE-based Ranking
	***************************************************************************************************************
*/

/*
            -----------------------------------------------------------------------------------------------
												  CUME_DIST
												  (11:42:27)
			-----------------------------------------------------------------------------------------------
*/
-- Cumulative Distribution calculates the distribution of data points within a window.

-- CUME_DIST() OVER(ORDER BY Sales DESC)

-- CUME_DIST = Position Nr. / Nr. of Rows
-- CUME_DIST = 1 / 5 (0,2)
-- CUME_DIST = 3 / 5 (0,6)
-- CUME_DIST = 4 / 5 (0,8)
-- CUME_DIST = 5 / 5 (1,0)

-- For example:
-- Sales     |     DIST
-- 100              0,2
-- 80               0,6	   <-- TIE
-- 80               0,6    <-- Duplicate value. RULE: The position of the LAST occurrence of the same value will be 'Position Nr.'.
-- 50               0,8
-- 30               1,0

-- Find Products that Fall Within the Highest 40% of the Prices
SELECT
	*,
	CONCAT(sub.DistRank * 100, '%') AS DistRankPerc
FROM(
	SELECT
		sp.Product,
		sp.Price,
		CUME_DIST() OVER(ORDER BY sp.Price DESC) AS DistRank
	FROM Sales.Products AS sp
) AS sub
WHERE sub.DistRank <= 0.4;
GO


/*
            -----------------------------------------------------------------------------------------------
												  PERCENT_RANK
												  (11:46:10)
			-----------------------------------------------------------------------------------------------
*/
-- Calculates the relative position of each row.

-- PERCENT_RANK() OVER(ORDER BY Sales DESC)

-- PERCENT_RANK = Position Nr. -1 / Nr. of Rows -1

-- PERCENT_RANK = 1-1 / 5-1 (0)
-- PERCENT_RANK = 2-1 / 5-1 (0,25)
-- PERCENT_RANK = 2-1 / 5-1 (0,25)
-- PERCENT_RANK = 4-1 / 5-1 (0,75)
-- PERCENT_RANK = 5-1 / 5-1 (1)

-- For example:
-- Sales     |     DIST
-- 100              0
-- 80               0,25  <-- TIE 
-- 80               0,25  <-- Duplicate value. RULE: The position of the FIRST occurrence of the same value will be 'Position Nr.'.
-- 50               0,75
-- 30               1,0

-- Find Products that Fall Within the Highest 40% of the Prices
SELECT
	*,
	CONCAT(sub.PercentRank * 100, '%') AS PercentRankPerc
FROM(
	SELECT
		sp.Product,
		sp.Price,
		PERCENT_RANK() OVER(ORDER BY sp.Price DESC) AS PercentRank
	FROM Sales.Products AS sp
) AS sub
WHERE sub.PercentRank <= 0.4;
GO