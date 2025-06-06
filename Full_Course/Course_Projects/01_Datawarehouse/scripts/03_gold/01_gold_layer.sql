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

-- ================================================================
--							Gold Layer
--							(1:02:48:00)
-- ================================================================

-- <<<<< What is Data Modeling? (1:02:49:15) >>>>>

-- <<<<< Star Schema vs Snowflake Schema (1:02:51:55) >>>>>

-- 1. Fact tables: Contains transactions, events
-- 2. Dimension tables: Contains descriptive informations

-- Star Schema: [Using this now]
-- Simple & Easy (to query)
-- Good for analysis
-- BAD: Big dimensions

-- Snowflake Schema:
-- More complex
-- Large dataset

-- <<<<< Dimensions vs Facts (1:02:53:40) >>>>>
-- Dimensions:
-- Descriptive information that give context to your data
-- Q: Who? | What? | Where?

-- Facts:
-- Quantitative information that represents events
-- Q: How much? | How many?


-- <<<<< Explore the Business Objects (1:02:54:45) >>>>>

-- -------------------------------
--	  Create dimension customers
--          (1:02:58:40)
-- -------------------------------
-- Rename columns to friendly, meaningful names (1:03:10:00)
-- Dimension or Fact? <-- Dimension: Describes information about customers

-- You always need a PK for a dimension!!!
-- Surrogate Key: System-generated unique identifier assigned to each record in a table. [customer_key]
--					Only use is to connect data model.
CREATE OR ALTER VIEW gold.dim_customers AS
	SELECT 
		ROW_NUMBER() OVER(ORDER BY ci.cst_id ASC) AS customer_key,
		ci.cst_id				AS customer_id,
		ci.cst_key				AS customer_number,
		ci.cst_firstname		AS first_name,
		ci.cst_lastname			AS last_name,
		la.cntry				AS country,
		ci.cst_marital_status	AS marital_status,
		-- 02_data_integration.sql
		CASE
			WHEN ci.cst_gndr != 'n/a' 
				THEN ci.cst_gndr -- CRM is the master for gender info
			ELSE COALESCE(ca.gen, 'n/a')
		END						AS gender,
		ca.bdate				AS birthdate,
		ci.cst_create_date		AS create_date
	FROM silver.crm_cust_info AS ci
	LEFT JOIN silver.erp_cust_az12 AS ca
		ON ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 la
		ON ci.cst_key = la.cid
;
GO


-- TIP: After joining table, check if any duplicates were introduced by the join logic
SELECT 
	sub.cst_id,
	COUNT(*) AS duplicates_nr
FROM (
	SELECT 
		ci.cst_id,
		ci.cst_key,
		ci.cst_firstname,
		ci.cst_lastname,
		ci.cst_marital_status,
		ci.cst_gndr,
		ci.cst_create_date,
		ca.bdate,
		ca.gen,
		la.cntry
	FROM silver.crm_cust_info AS ci
	LEFT JOIN silver.erp_cust_az12 AS ca
		ON ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 la
		ON ci.cst_key = la.cid
) AS sub
GROUP BY sub.cst_id
HAVING COUNT(*) > 1;
GO



-- -------------------------------
--	  Create dimension products
--          (1:03:15:10)
-- -------------------------------

-- Rename columns to friendly, meaningful names (1:03:19:50)
-- Dimension or Fact? <-- Dimension: Describes information about products

-- You always need a PK for a dimension!!!
-- Surrogate Key: System-generated unique identifier assigned to each record in a table. [product_key]
--					Only use is to connect data model.
CREATE OR ALTER VIEW gold.dim_products AS
	SELECT 
		ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt ASC, pn.prd_key ASC) AS product_key,
		pn.prd_id			AS product_id,
		pn.prd_key			AS product_number,
		pn.prd_nm			AS product_name,
		pn.prd_cat_id		AS category_id,
		pc.cat				AS category,
		pc.subcat			AS subcategory,
		pc.maintenance,
		pn.prd_cost			AS cost,
		pn.prd_line			AS product_line,
		pn.prd_start_dt		AS start_date
		-- pn.prd_end_dt
	FROM silver.crm_prd_info AS pn
	LEFT JOIN silver.erp_px_cat_g1v2 AS pc
		ON pn.prd_cat_id = pc.id
	WHERE pn.prd_end_dt IS NULL -- Filter out all historical data
; 
GO

-- TIP: After joining table, check if any duplicates were introduced by the join logic
SELECT
	sub.prd_key,
	COUNT(*) AS duplicates_nr
FROM (
	SELECT 
		pn.prd_id,
		pn.prd_cat_id,
		pn.prd_key,
		pn.prd_nm,
		pn.prd_cost,
		pn.prd_line,
		pn.prd_start_dt,
		pn.prd_end_dt,
		pc.cat,
		pc.subcat,
		pc.maintenance
	FROM silver.crm_prd_info AS pn
	LEFT JOIN silver.erp_px_cat_g1v2 AS pc
		ON pn.prd_cat_id = pc.id
	WHERE pn.prd_end_dt IS NULL -- Filter out all historical data
) AS sub
GROUP BY sub.prd_key
HAVING COUNT(*) > 1; 
GO



-- -------------------------------
--	  Create fact sales
--          (1:03:22:20)
-- -------------------------------
-- Dimension or Fact? <-- Fact: Lot of keys, dates, measures
-- We HAVE TO present a Surrogate Keys that are coming from the Dimensions!!!!!!!!
-- BUILDING FACT: Use the dimension's surrogate key instead of IDs to easily connect facts with dimensions.
--					[sls_prd_key, sls_cust_id] -> [pr.product_key, cu.customer_key]

-- Rename columns to friendly, meaningful names (1:03:25:35)

-- Best Schema for FACT tables is this:
-- Sort the columns into logical groups to improve readablity.
-- Dimension keys		-------------------->		Dates		-------------------->		Measures
-- [order_number, product_key, customer_key]		[order_date, shipping_date, due_date]	[sales_amount, quantity, price]
CREATE OR ALTER VIEW gold.fact_sales AS
	SELECT 
		sd.sls_ord_num		AS order_number,
		pr.product_key,
		-- sd.sls_prd_key,
		cu.customer_key,
		-- sd.sls_cust_id,
		sd.sls_order_dt		AS order_date,
		sd.sls_ship_dt		AS shipping_date,
		sd.sls_due_dt		AS due_date,
		sd.sls_sales		AS sales_amount,
		sd.sls_quantity		AS quantity,
		sd.sls_price		AS price
	FROM silver.crm_sales_details AS sd
	LEFT JOIN gold.dim_products AS pr
		ON sd.sls_prd_key = pr.product_number
	LEFT JOIN gold.dim_customers AS cu
		ON sd.sls_cust_id = cu.customer_id
;
GO

SELECT *
FROM silver.crm_sales_details;
GO

SELECT *
FROM gold.dim_products;
GO

SELECT *
FROM gold.dim_customers;
GO