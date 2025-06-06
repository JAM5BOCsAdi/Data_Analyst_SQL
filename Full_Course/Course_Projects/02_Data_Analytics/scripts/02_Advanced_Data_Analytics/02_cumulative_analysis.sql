/*
            ----------------------------------------------------------------------------------------------
					DOC: Project_Notes_Sketches.pdf
					CONNECTION: DataWarehouse

											 Advanced Data Analytics
										      (1:04:30:35)

					"Answer Business Questions"
					- Complex Queries
					- Window Functions
					- CTE
					- Subqueries
					- Reports
			-----------------------------------------------------------------------------------------------
*/


USE DataWarehouse;
GO

-- ================================================================
--						  Cumulative Analysis
--							(1:04:39:30)
-- ================================================================
-- Aggregate the data progressively over time.
-- Helps to understand whether our business is growing or declining.

-- <aggr.> [Cumulative Measure] by [Date Dimension]
-- Running Total Sales by Year
-- Moving Average of Sales by Month

-- Use: (Aggregate) WINDOW FUNCTIONS



-- Calculate the Total Sales per Month
-- and the Running Total of Sales over time.
-- DEFAULT Window Frame: https://learn.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql?view=sql-server-ver17
-- BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
SELECT
	sub.order_date,
	sub.total_sales,
	SUM(sub.total_sales) OVER(ORDER BY sub.order_date) AS running_total_sales
FROM(
	SELECT
		DATETRUNC(MONTH, order_date) AS order_date,
		SUM(sales_amount) AS total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH, order_date)
) AS sub;
GO

-- MOVING AVERAGE
SELECT
	sub.order_date,
	sub.total_sales,
	SUM(sub.total_sales) OVER(ORDER BY sub.order_date) AS running_total_sales,
	AVG(sub.avg_price) OVER(ORDER BY sub.order_date) AS moving_average_price
FROM(
	SELECT
		DATETRUNC(MONTH, order_date) AS order_date,
		SUM(sales_amount) AS total_sales,
		AVG(price) AS avg_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH, order_date)
) AS sub;
GO


