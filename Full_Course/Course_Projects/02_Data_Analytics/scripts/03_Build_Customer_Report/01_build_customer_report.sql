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
--						  Build Customer Report
--							(1:05:22:55)
-- ================================================================
/* 
	Purpose:
		- This report consolidate key customer metrics and behaviors.

	Highlights:
		1. Gathers essential fields such as names, ages, and transaction details
		2. Segments customers into categories (VIP, Regular, New) and age groups
		3. Aggreagates customer-level metrics:
			- total orders
			- total sales
			- total quantity purchased
			- total products
			- lifespan (in months)
		4. Calculates valueable KPIs:
			- recency (months since last order)
			- average order value (AOV)
			- average monthly spend
*/
-- ---------------------------------------------------
-- 4. Create the VIEW to share with others
-- ---------------------------------------------------
-- OR use SELECT INTO OR CTAS like in (Line: 147)
-- 18_23_Adnvanced_SQL_Techniques ---> 21_CTAS_and_TEMP_Tables.sql
CREATE OR ALTER VIEW gold.report_customers AS
	-- ---------------------------------------------------
	-- 1. Base Query: Retrieves core columns from tables
	-- ---------------------------------------------------
	WITH cte_base_query AS(
		SELECT 
			f.order_number,
			f.product_key,
			f.order_date,
			f.sales_amount,
			f.quantity,
			c.customer_key,
			c.customer_number,
			CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
			DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age
		FROM gold.fact_sales AS f 
		LEFT JOIN gold.dim_customers AS c
			ON f.customer_key = c.customer_key
		WHERE f.order_date IS NOT NULL
	), 
	-- ---------------------------------------------------
	-- 2. Customer Aggregations: Summarizes key metrics at the customer level
	-- ---------------------------------------------------
	cte_customer_aggregation AS(
		SELECT 
			customer_key,
			customer_number,
			customer_name,
			age,
			COUNT(DISTINCT order_number) AS total_orders,
			SUM(sales_amount) AS total_sales,
			SUM(quantity) AS total_quantity,
			COUNT(DISTINCT product_key) AS total_products,
			MAX(order_date) AS last_order_date,
			DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
		FROM cte_base_query
		GROUP BY 
			customer_key,
			customer_number,
			customer_name,
			age
	)
	-- ---------------------------------------------------
	-- 3. Final results
	-- ---------------------------------------------------
	SELECT
		customer_key,
		customer_number,
		customer_name,
		age,
		CASE
			WHEN age < 20 THEN 'Under 20'
			WHEN age BETWEEN 20 AND 29 THEN '20-29'
			WHEN age BETWEEN 30 AND 39 THEN '30-39'
			WHEN age BETWEEN 40 AND 49 THEN '40-49'
			ELSE '50 and above'
		END AS age_group,
		CASE 
			WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
			WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
			ELSE 'New'
		END AS customer_segment,
		last_order_date,
		DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,
		total_orders,
		total_sales,
		total_quantity,
		total_products,
		lifespan,

		-- Compute AVG order value (AOV)
		CASE 
			WHEN total_orders = 0 THEN 0
			ELSE ROUND(CAST(total_sales AS FLOAT) / total_orders, 2) 
		END AS avg_order_value,

		-- Compute AVG monthly spend
		CASE
			WHEN lifespan = 0 THEN total_sales
			ELSE ROUND(CAST(total_sales AS FLOAT) / lifespan, 2)
		END AS avg_monthly_spend
	-- INTO gold.report_ctas_customer
	FROM cte_customer_aggregation	
;
GO

-- If a user touches the view:
SELECT 
	age_group,
	COUNT(customer_number) AS total_customers,
	SUM(total_sales) AS total_sales
FROM gold.report_customers
GROUP BY age_group;
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
		f.product_key,
		f.order_date,
		f.sales_amount,
		f.quantity,
		c.customer_key,
		c.customer_number,
		CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
		DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age
	FROM gold.fact_sales AS f 
	LEFT JOIN gold.dim_customers AS c
		ON f.customer_key = c.customer_key
	WHERE f.order_date IS NOT NULL
), 
-- ---------------------------------------------------
-- 2. Customer Aggregations: Summarizes key metrics at the customer level
-- ---------------------------------------------------
cte_customer_aggregation AS(
	SELECT 
		customer_key,
		customer_number,
		customer_name,
		age,
		COUNT(DISTINCT order_number) AS total_orders,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
		COUNT(DISTINCT product_key) AS total_products,
		MAX(order_date) AS last_order_date,
		DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
	FROM cte_base_query
	GROUP BY 
		customer_key,
		customer_number,
		customer_name,
		age
)
-- ---------------------------------------------------
-- 3. Final results
-- ---------------------------------------------------
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE
		WHEN age < 20 THEN 'Under 20'
		WHEN age BETWEEN 20 AND 29 THEN '20-29'
		WHEN age BETWEEN 30 AND 39 THEN '30-39'
		WHEN age BETWEEN 40 AND 49 THEN '40-49'
		ELSE '50 and above'
	END AS age_group,
	CASE 
		WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
	END AS customer_segment,
	last_order_date,
	DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,
	total_orders,
	total_sales,
	total_quantity,
	total_products,
	lifespan,

	-- Compute AVG order value (AOV)
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE ROUND(CAST(total_sales AS FLOAT) / total_orders, 2) 
	END AS avg_order_value,

	-- Compute AVG monthly spend
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE ROUND(CAST(total_sales AS FLOAT) / lifespan, 2)
	END AS avg_monthly_spend
INTO gold.report_ctas_customers -- <<<<----- HERE IS THE CTAS in T-SQL
FROM cte_customer_aggregation;
GO

-- If a user touches the view:
SELECT 
	age_group,
	COUNT(customer_number) AS total_customers,
	SUM(total_sales) AS total_sales
FROM gold.report_ctas_customers
GROUP BY age_group;
GO