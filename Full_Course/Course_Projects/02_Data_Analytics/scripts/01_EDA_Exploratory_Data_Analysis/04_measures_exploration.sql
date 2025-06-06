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
--						  Measure Exploration
--							(1:04:03:30)
-- ================================================================

-- Calculate the key metric of the business (Big Numbers)

-- Highest Level of Aggregation | Lowest level of Details

-- <aggregation> <measure>
-- SUM(Sales)
-- AVG(Price)

-- Find the Total Sales
SELECT
	SUM(sales_amount) AS total_sales
FROM gold.fact_sales;
GO

-- Find how many items are sold
SELECT
	SUM(quantity) AS total_quantity
FROM gold.fact_sales;
GO

-- Find the average selling price
SELECT
	AVG(price) AS avg_price
FROM gold.fact_sales;
GO

-- Find the Total Number of Orders
SELECT
	COUNT(order_number) AS total_orders
FROM gold.fact_sales;
GO

SELECT 
	COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales;
GO
-- Fint the Total Number of Products
SELECT
	COUNT(product_key) AS total_products
FROM gold.dim_products;
GO

SELECT
	COUNT(product_key) AS total_products
FROM gold.dim_products;
GO

-- Fint the Total Number of Customers
SELECT
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers;
GO

-- Fint the Total Number of Customers that has okaced an order
SELECT
	COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales;
GO



-- ============================================================
-- Generate Report that shows all key metrics of the business
-- ============================================================
-- You can Create Table with CTAS:

-- CREATE TABLE gold.summary_metrics AS
SELECT
	'Total Sales' AS measure_name,
	SUM(sales_amount) AS measure_value
FROM gold.fact_sales

UNION ALL

SELECT
	'Total Quantity' AS measure_name,
	SUM(quantity) AS measure_value
FROM gold.fact_sales

UNION ALL

SELECT
	'Average Price' AS measure_name,
	AVG(price) AS measure_value
FROM gold.fact_sales

UNION ALL

SELECT
	'Total Nr. Orders' AS measure_name,
	COUNT(DISTINCT order_number) AS measure_value
FROM gold.fact_sales

UNION ALL

SELECT
	'Total Nr. Products' AS measure_name,
	COUNT(product_key) AS measure_value
FROM gold.dim_products

UNION ALL

SELECT
	'Total Nr. Customers' AS measure_name,
	COUNT(customer_key) AS measure_value
FROM gold.dim_customers;
GO