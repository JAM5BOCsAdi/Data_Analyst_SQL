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
--						  Performance Analysis
--							(1:04:47:20)
-- ================================================================
-- Comparing the current value to a target value.
-- Helps measure success and compare performance.

-- Current[Measure] - Target[Measure]
-- Current Sales - Average Sales
-- Current Year Sales - Prev. Year Sales [YoY]
-- Current Sales - Lowest Sales

-- WINDOW FUNCTIONS: 
--  Aggregate (SUM, AVG, MIN, ...)
--	Value Window func. (LEAD, LAG)


-- Analyze the yearly performance of products by comparing their sales to both the 
-- average sales performance of the product and the previous year's sales.
WITH cte_yearly_product_sales AS(
	SELECT
		YEAR(f.order_date) AS order_year,
		p.product_name,
		SUM(f.sales_amount) AS current_sales
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
		ON f.product_key = p.product_key
	WHERE f.order_date IS NOT NULL
	GROUP BY YEAR(f.order_date), p.product_name
)
SELECT
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales,
	current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diff_avg,
	CASE
		WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
		WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Belove Avg'
		ELSE 'Avg'
	END AS avg_change,
	-- Year-over-Year Analysis
	LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS py_sales,
	current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS diff_py,
	CASE
		WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
		WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
		ELSE 'No Change'
	END AS py_change
FROM cte_yearly_product_sales
ORDER BY product_name ASC, order_year ASC;
GO



