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
--							Silver Layer
--							(1:01:10:20)
-- ================================================================

-- <<<<< Quality Check for Silver (1:01:39:00) >>>>>


-- -------------------------------
--				CRM
--          (1:01:26:30)
-- -------------------------------
-- ***** crm_cust_info table *****
SELECT * 
FROM silver.crm_cust_info;
GO

-- 1. Check for NULLS or DUPLICATES in Primary Key
--		Expectation: No result
SELECT 
	cst_id,
	COUNT(*) AS duplicates_nr
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;
GO

-- 2. Check for unwanted spaces in text columns
--		Expectation: No result
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);
GO

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);
GO

--SELECT cst_firstname, cst_lastname
--FROM silver.crm_cust_info
--WHERE 
--	cst_firstname != TRIM(cst_firstname)
--	OR cst_lastname != TRIM(cst_lastname);
--GO

-- Good quality = No result
SELECT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);
GO

-- 3. Data Standardization & Consistency
-- Change gender F -> Female | M -> Male | NULL -> n/a
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;
GO

-- Change marital status S -> Single | M -> Married | NULL -> n/a
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;
GO





-- ***** crm_prd_info table *****
SELECT * 
FROM silver.crm_prd_info;
GO

-- 1. Check for NULLS or DUPLICATES in Primary Key
--		Expectation: No result
SELECT 
	prd_id,
	COUNT(*) AS duplicates_nr
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;
GO

-- 2. Check for unwanted spaces in text columns
--		Expectation: No result
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);
GO

-- 3. Check for NULLS or Negative Numbers in [prd_cost]
--		Replace NULLS with 0s
--		Expectation: No result
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;
GO

-- 4. Check for Invalid Date Orders [prd_end_dt, prd_start_dt]
-- End date is smaller then start date?
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;
GO




-- ***** crm_sales_details table *****
SELECT * 
FROM silver.crm_sales_details;
GO

-- 1. Check for Invalid Dates
-- sls_order_dt must always be earlier than the sls_ship_dt or sls_due_dt
--		Expectation: No result
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;
GO

-- 2. Check Data Consistency between Sales, Quantity and Price
-- >> Sales = Quantity * Price
-- >> Values must NOT be NULL, ZERO or NEGATIVE
-- Solution: Not the best, but good for now.
--		1. If Sales is negative, zero or null, use the calculation [Sales = Quantity * Price].
--		2. If Price is zero or null, use the calculation [Price= Sales / Quantity].
--		3. If Price is negative, convert to a positive value.
--		Expectation: No result
SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE	sls_sales != sls_quantity * sls_price
		OR sls_sales IS NULL
		OR sls_quantity IS NULL
		OR sls_price IS NULL
		OR sls_sales <= 0
		OR sls_quantity <= 0
		OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;
GO




-- -------------------------------
--				ERP
--          (1:02:19:20)
-- -------------------------------
-- ***** erp_cust_az12 table *****
SELECT *
FROM silver.erp_cust_az12;
GO

-- 1. Identify Out-of-Range Dates
-- Birthdate is strange if it is low or in the future
-- Now we do not see the future bdate
--		Expectation: No result
SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE bdate < '1900-01-01' OR bdate > GETDATE();
GO



-- ***** erp_loc_a101 table *****
SELECT
	cid,
	cntry,
	dwh_create_date
FROM silver.erp_loc_a101;
GO
-- 1. Check the distinct values in cntry
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry;
GO



-- ***** erp_px_cat_g1v2 table *****
SELECT *
FROM silver.erp_px_cat_g1v2;
GO