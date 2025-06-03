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
--						Dimensions Exploration
--							(1:03:54:30)
-- ================================================================
-- Identifying the unique values (or categories) in each dimension.
-- Recognizeing how data might be grouped or segmented, which is useful for later analysis.

-- Use: DISTINCT [Dimension]
-- DISTINCT Country
-- DISTINCT Category
-- ...

-- Explore All countries our customers came from
SELECT DISTINCT 
	country
FROM gold.dim_customers;
GO

-- Explore All categories "The major Divisions"
SELECT DISTINCT 
	category,
	subcategory,
	product_name
FROM gold.dim_products
ORDER BY 1, 2, 3;
GO
