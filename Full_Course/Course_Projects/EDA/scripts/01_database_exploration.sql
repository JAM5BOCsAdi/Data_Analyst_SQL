/*
            ----------------------------------------------------------------------------------------------
					DOC: Project_Notes_Sketches.pdf
					CONNECTION: DataWarehouse

											 Exploratory Data Analysis - EDA
										      (1:03:41:50)
			-----------------------------------------------------------------------------------------------
*/


USE DataWarehouse;
GO

-- ================================================================
--						Dimension vs Measure
--							(1:03:47:40)
-- ================================================================

--								1. Is data type = number?
--							/                              \
--                    YES                                      NO

--			2. Does it make sense							[Dimension]	
--              to aggregate?
--            /              \
--			YES               NO
--        [Measure]			[Dimension]

-- Dimension
SELECT DISTINCT
	category
FROM gold.dim_products;
GO

-- Measure
SELECT DISTINCT
	sales_amount
FROM gold.fact_sales;
GO

-- Dimension
SELECT DISTINCT
	product_name
FROM gold.dim_products;
GO

-- Measure
SELECT DISTINCT
	quantity
FROM gold.fact_sales;
GO

-- Dimension
SELECT DISTINCT
	birthdate
FROM gold.dim_customers;
GO

-- Measure
SELECT DISTINCT
	AVG(DATEDIFF(year, birthdate, GETDATE())) AS avg_age
FROM gold.dim_customers;
GO

-- Dimension
SELECT DISTINCT
	customer_id
FROM gold.dim_customers;
GO

-- ================================================================
--						Database Exploration
--							(1:03:51:15)
-- ================================================================

-- Explore All Objects in the database
SELECT *
FROM INFORMATION_SCHEMA.TABLES;
GO

-- Explore All Columns in the database
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS;
GO

-- Explore 1 Column in the database
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';
GO