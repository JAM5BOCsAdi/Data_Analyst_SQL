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
--						  Data Segmentation Analysis
--							(1:05:07:05)
-- ================================================================
-- Group the data based on a specific range.
-- Helps understand the correlation between two measures.

-- [Measure]by [Measure]
-- Total Products by Sales Range
-- Total Customers by Age

-- Use: CASE WHEN STATEMENT


-- Segment products into cost ranges and count how many products fall into each segment
WITH cte_product_segment AS (
	SELECT 
		product_key,
		product_name,
		cost,
		CASE
			WHEN cost < 100 THEN 'Below 100'
			WHEN cost BETWEEN 100 AND 500 THEN '100-500'
			WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
			ELSE 'Above 1000'
		END AS cost_range
	FROM gold.dim_products
)
SELECT 
	cost_range,
	COUNT(product_key) AS total_products,
	SUM(COUNT(product_key)) OVER() AS overall_products,
	CONCAT(ROUND((CAST(COUNT(product_key) AS FLOAT) / SUM(COUNT(product_key)) OVER()) * 100, 2), '%') AS percent_of_total
FROM cte_product_segment
GROUP BY cost_range
ORDER BY total_products DESC;
GO


-- Goup customers into three segments based on their spending behavior:
--  - VIP: Customers with at least 12 months of history and spending more than 5000
--  - Regular: Customers with at least 12 months of history, but speding 5000 or less
--  - New: Customer with a lifespan less than 12 months
-- And find the total number of customers by each group
WITH cte_customer_spending AS(
	SELECT
		c.customer_key,
		SUM(f.sales_amount) AS total_spending,
		MIN(f.order_date) AS first_order,
		MAX(f.order_date) AS last_order,
		DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_customers AS c
		ON f.customer_key = c.customer_key
	GROUP BY c.customer_key
), cte_customer_segment AS (  -- <-- NESTED CTE
	SELECT
		customer_key,
		--total_spending,
		--lifespan,
		CASE 
			WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
			WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
			ELSE 'New'
		END AS customer_segment
	FROM cte_customer_spending
)
SELECT
	customer_segment,
	COUNT(customer_key) AS total_customers
FROM cte_customer_segment
GROUP BY customer_segment
ORDER BY total_customers DESC;
GO
