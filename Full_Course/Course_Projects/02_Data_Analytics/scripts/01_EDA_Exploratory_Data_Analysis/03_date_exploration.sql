/*
            ----------------------------------------------------------------------------------------------
					DOC: Project_Notes_Sketches.pdf
					CONNECTION: DataWarehouse

											 Exploratory Data Analysis - EDA
										      (1:03:41:50)

					"Understand Data":
					- Basic Queries
					- Data Profiling
					- Simple Aggregations
					- Subquery
			-----------------------------------------------------------------------------------------------
*/


USE DataWarehouse;
GO

-- ================================================================
--						  Date Exploration
--							(1:03:58:15)
-- ================================================================

-- Identify the earliet and latest dates (boundaries).
-- Understand the scope of data and the timespan.

-- MIN/MAX [Date Dimension]
-- MIN order_date

-- Find the date of the first and last order
-- How many years of sales are available
SELECT
	MIN(order_date) AS first_order_date,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales;
GO

-- Find the youngest and the oldest customer
SELECT
	MIN(birthdate) AS oldest_birthdate,
	MAX(birthdate) AS youngest_birhtdate,
	DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age,
	DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers;
GO