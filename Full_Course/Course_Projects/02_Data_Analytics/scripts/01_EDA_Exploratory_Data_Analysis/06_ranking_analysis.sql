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
--						  Ranking Analysis
--							(1:04:23:15)
-- ================================================================
-- Order the values of Dimensions by Measure.
-- Top N performers | Bottom N performers

-- Rank [Dimension] by <aggr.>[Measure]
-- Rank Countries by TotalSales
-- Top5 Products by Quantity
-- ...

-- Which 5 products generate the highest revenue?
SELECT TOP 5
	p.product_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
	ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;
GO

-- Solve with Window Function:
SELECT *
FROM(
	SELECT
		p.product_name,
		SUM(f.sales_amount) AS total_revenue,
		ROW_NUMBER() OVER(ORDER BY SUM(f.sales_amount) DESC) AS rank_products
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
		ON f.product_key = p.product_key
	GROUP BY p.product_name
) AS sub
WHERE rank_products <=5;
GO

-- Solve with CTE:
WITH cte_product_rank AS (
	SELECT
		p.product_name,
		SUM(f.sales_amount) AS total_revenue,
		ROW_NUMBER() OVER(ORDER BY SUM(f.sales_amount) DESC) AS rank_products
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
		ON f.product_key = p.product_key
	GROUP BY p.product_name
)
SELECT *
FROM cte_product_rank
WHERE rank_products <= 5;
GO


-- What are the 5 worst-performing products in terms of sales?
SELECT TOP 5
	p.product_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
	ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC;
GO

-- Which 5 subcategory generate the highest revenue?
SELECT TOP 5
	p.subcategory,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
	ON f.product_key = p.product_key
GROUP BY p.subcategory
ORDER BY total_revenue DESC;
GO

-- Find the TOP 10 customers who have generated the highest revenue
SELECT TOP 10
	c.customer_key,
	c.first_name,
	c.last_name,
	SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
	ON f.customer_key = c.customer_key
GROUP BY 
	c.customer_key,
	c.first_name,
	c.last_name
ORDER BY total_revenue DESC;
GO

-- The 3 customers with the fewest orders placed
SELECT TOP 3
	c.customer_key,
	c.first_name,
	c.last_name,
	COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
	ON f.customer_key = c.customer_key
GROUP BY 
	c.customer_key,
	c.first_name,
	c.last_name
ORDER BY total_orders ASC;
GO