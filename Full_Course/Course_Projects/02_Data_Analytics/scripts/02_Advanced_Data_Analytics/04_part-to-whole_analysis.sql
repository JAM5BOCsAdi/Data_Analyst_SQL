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
--						  Part-to-Whole Analysis
--							(1:04:59:40)
-- ================================================================
-- Analyze how an individual part is performing compared to the overall, allowing us to 
-- understand which category has the greatest impact on the business.

-- ( [Measure] / Total[Measure] ) * 100 by [Dimension]
-- ( Sales / Total Sales ) * 100 by Category
-- ( Quantity / Total Quantity ) * 100 by Country


-- Which categories contribute the most ot the overall sales?
-- To display aggregations at multiple levels in the results, use Window Functions
WITH cte_category_sales AS(
	SELECT 
		p.category,
		SUM(f.sales_amount) AS total_sales
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
		ON f.product_key = p.product_key
	GROUP BY p.category
)
SELECT 
	category, 
	total_sales,
	SUM(total_sales) OVER() AS overall_sales,
	CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER()) * 100, 2), '%') AS percentage_of_total
FROM cte_category_sales;
GO