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
--						  Build Product Report
--							(1:05:22:15)
-- ================================================================
/* 
	Purpose:
		- This report consolidate key product metrics and behaviors.

	Highlights:
		1. Gathers essential fields such as product name, category, subcategory and cost
		2. Segments products by revenue to identify High-Performers, Mid-Range pr Low-Performers
		3. Aggreagates product-level metrics:
			- total orders
			- total sales
			- total quantity sold
			- total customers (unique)
			- lifespan (in months)
		4. Calculates valueable KPIs:
			- recency (months since last order)
			- average order revenue (AOR)
			- average monthly revenue
*/
-- ---------------------------------------------------
-- 4. Create the VIEW to share with others
-- ---------------------------------------------------
-- OR use SELECT INTO OR CTAS like in (Line: 147)
-- 18_23_Adnvanced_SQL_Techniques ---> 21_CTAS_and_TEMP_Tables.sql
CREATE OR ALTER VIEW gold.report_products AS
	-- ---------------------------------------------------
	-- 1. Base Query: Retrieves core columns from tables
	-- ---------------------------------------------------
	WITH cte_base_query AS(
		SELECT 
			f.order_number,
			f.order_date,
			f.customer_key,
			f.sales_amount,
			f.quantity,
			p.product_key,
			p.product_name,
			p.category,
			p.subcategory,
			p.cost
		FROM gold.fact_sales AS f 
		LEFT JOIN gold.dim_products AS p
			ON f.product_key = p.product_key
		WHERE f.order_date IS NOT NULL
	), 
	-- ---------------------------------------------------
	-- 2. Product Aggregations: Summarizes key metrics at the product level
	-- ---------------------------------------------------
	cte_product_aggregation AS(
		SELECT 
			product_key,
			product_name,
			category,
			subcategory,
			cost,
			DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
			MAX(order_date) AS last_sale_date,
			COUNT(DISTINCT order_number) AS total_orders,
			COUNT(DISTINCT customer_key) AS total_customers,
			SUM(sales_amount) AS total_sales,
			SUM(quantity) AS total_quantity,
			ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
			
		FROM cte_base_query
		GROUP BY 
			product_key,
			product_name,
			category,
			subcategory,
			cost

	)
	-- ---------------------------------------------------
	-- 3. Final results
	-- ---------------------------------------------------
	SELECT
		product_key,
		product_name,
		category,
		subcategory,
		cost,
		last_sale_date,
		DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
		CASE
			WHEN total_sales > 50000 THEN 'High-Performer'
			WHEN total_sales >= 10000 THEN 'Mid-Performer'
			ELSE 'Low-Performer'
		END AS product_segment,
		lifespan,
		total_orders,
		total_sales,
		total_quantity,
		total_customers,
		avg_selling_price,

		-- Compute AVG order revenue (AOR)
		CASE 
			WHEN total_orders = 0 THEN 0
			ELSE ROUND(CAST(total_sales AS FLOAT) / total_orders, 2) 
		END AS avg_order_revenue,

		-- Compute AVG monthly spend
		CASE
			WHEN lifespan = 0 THEN total_sales
			ELSE ROUND(CAST(total_sales AS FLOAT) / lifespan, 2)
		END AS avg_monthly_revenue
	-- INTO gold.report_ctas_customer
	FROM cte_product_aggregation	
;
GO

-- If a user touches the view:
SELECT 
	product_name,
	SUM(total_sales) AS total_sales
FROM gold.report_products
GROUP BY product_name;
GO


-- -----------------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------
-- 4. BUT WITH SELECT INTO
-- ---------------------------------------------------
-- Purpose:
-- Refresh the table as you want (with Agent Job), not immediately like the VIEWS
WITH cte_base_query AS(
	SELECT 
		f.order_number,
		f.order_date,
		f.customer_key,
		f.sales_amount,
		f.quantity,
		p.product_key,
		p.product_name,
		p.category,
		p.subcategory,
		p.cost
	FROM gold.fact_sales AS f 
	LEFT JOIN gold.dim_products AS p
		ON f.product_key = p.product_key
	WHERE f.order_date IS NOT NULL
), 
-- ---------------------------------------------------
-- 2. Product Aggregations: Summarizes key metrics at the product level
-- ---------------------------------------------------
cte_product_aggregation AS(
	SELECT 
		product_key,
		product_name,
		category,
		subcategory,
		cost,
		DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
		MAX(order_date) AS last_sale_date,
		COUNT(DISTINCT order_number) AS total_orders,
		COUNT(DISTINCT customer_key) AS total_customers,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
			
	FROM cte_base_query
	GROUP BY 
		product_key,
		product_name,
		category,
		subcategory,
		cost

)
-- ---------------------------------------------------
-- 3. Final results
-- ---------------------------------------------------
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_date,
	DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Performer'
		ELSE 'Low-Performer'
	END AS product_segment,
	lifespan,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,

	-- Compute AVG order revenue (AOR)
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE ROUND(CAST(total_sales AS FLOAT) / total_orders, 2) 
	END AS avg_order_revenue,

	-- Compute AVG monthly spend
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE ROUND(CAST(total_sales AS FLOAT) / lifespan, 2)
	END AS avg_monthly_revenue
INTO gold.report_ctas_products
FROM cte_product_aggregation;
GO

-- If a user touches the view:
SELECT 
	product_name,
	SUM(total_sales) AS total_sales
FROM gold.report_ctas_products
GROUP BY product_name;
GO