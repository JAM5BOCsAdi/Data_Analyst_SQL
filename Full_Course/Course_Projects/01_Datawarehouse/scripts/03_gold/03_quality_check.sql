/*
            ----------------------------------------------------------------------------------------------
					DOC: 11_SQL_Projects.pdf
					CONNECTION: DataWarehouse

											 DataWarehouse
										      (23:21:04)

					"Organize, Structure, Prepare":
					- ETL/ELT Processing
					- Data Architecture
					- Data Integration
					- Data Cleansing
					- Data Load
					- Data Modeling
			-----------------------------------------------------------------------------------------------
*/

USE DataWarehouse;
GO

-- <<<<< Quality Check dim_customers VIEW (1:03:14:40) >>>>>
SELECT DISTINCT 
	gender
FROM gold.dim_customers;
GO

-- <<<<< Quality Check dim_products VIEW (1:03:2:10) >>>>>
SELECT *
FROM gold.dim_products;
GO

-- <<<<< Quality Check fact_sales VIEW (1:03:27:00) >>>>>
SELECT *
FROM gold.fact_sales;
GO

-- <<<<< Foreign Key integrity [Dimensions] (1:03:27:10) >>>>>
-- Check if all Dimension tables can successfully join to the fact table.
--		Expectation: No result
--		That means: Everything matching
SELECT *
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
	ON f.customer_key = c.customer_key
LEFT JOIN gold.dim_products AS p
	ON f.product_key = p.product_key
WHERE c.customer_key IS NULL OR p.product_key IS NULL;
GO