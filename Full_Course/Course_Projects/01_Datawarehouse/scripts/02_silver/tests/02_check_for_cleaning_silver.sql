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

-- <<<<< Clean & Load (1:01:26:30) >>>>>

-- -------------------------------
--				CRM 
--          (1:01:26:30)
-- -------------------------------
-- ***** crm_cust_info table *****
SELECT *
FROM bronze.crm_cust_info;
GO
-- 1. Check for NULLS or DUPLICATES in Primary Key [cst_id]
--		Expectation: No result
SELECT 
	cst_id,
	COUNT(*) AS duplicates_nr
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;
GO

-- 2. Check for unwanted spaces in text columns [cst_firstname, cst_lastname]
--		Expectation: No result
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);
GO

SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);
GO

--SELECT cst_firstname, cst_lastname
--FROM bronze.crm_cust_info
--WHERE 
--	cst_firstname != TRIM(cst_firstname)
--	OR cst_lastname != TRIM(cst_lastname);
--GO

-- Good quality = No result
SELECT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);
GO

-- 3. Data Standardization & Consistency
-- Change gender F -> Female | M -> Male | NULL -> n/a [cst_gndr]
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;
GO

-- Change marital status S -> Single | M -> Married | NULL -> n/a [cst_marital_status]
SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info;
GO




-- ***** crm_prd_info table *****
SELECT *
FROM bronze.crm_prd_info;
GO
-- 1. Check for NULLS or DUPLICATES in Primary Key [prd_id]
--		Expectation: No result
SELECT 
	prd_id,
	COUNT(*) AS duplicates_nr
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;
GO

-- 2. cat_id is selected but there are "-" instead of "_"
SELECT DISTINCT id
FROM bronze.erp_px_cat_g1v2;
GO

-- 3. Check for unwanted spaces in text column(s) [prd_nm]
--		Expectation: No result
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);
GO

-- 4. Check for NULLS or Negative Numbers in [prd_cost]
--		Replace NULLS with 0s
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;
GO

-- 5. Data Standardization & Consistency [prd_line]
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info;
GO

-- 6. Check for Invalid Date Orders [prd_end_dt, prd_start_dt]
-- End date is smaller then start date?
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;
GO

-- 7. Change the column types in silver.crm_prd_info -> 01_ddl_silver.sql or ALTER TABLE
-- DATETIME to DATE [prd_start_dt, prd_end_dt]
SELECT *
FROM silver.crm_prd_info;
GO



-- ***** crm_sales_details table *****
-- 1. Check for unwanted spaces in text column(s) [prd_nm]
--		Expectation: No result
SELECT *
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);
GO

-- 2. Check for Invalid Dates [sls_order_dt, sls_ship_dt, sls_due_dt]
SELECT 
	NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE	sls_order_dt <= 0 
		OR LEN(sls_order_dt) != 8
		OR sls_order_dt > 20500101 -- 2050.01.01.
		OR sls_order_dt < 19000101;-- 1900.01.01.
GO

SELECT 
	NULLIF(sls_ship_dt, 0) AS sls_ship_dt
FROM bronze.crm_sales_details
WHERE	sls_ship_dt <= 0 
		OR LEN(sls_ship_dt) != 8
		OR sls_ship_dt > 20500101 -- 2050.01.01.
		OR sls_ship_dt < 19000101;-- 1900.01.01.
GO

SELECT 
	NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE	sls_due_dt <= 0 
		OR LEN(sls_due_dt) != 8
		OR sls_due_dt > 20500101 -- 2050.01.01.
		OR sls_due_dt < 19000101;-- 1900.01.01.
GO

-- 3. Check for Invalid Dates
-- sls_order_dt must always be earlier than the sls_ship_dt or sls_due_dt
-- Now it is checking for the opposite, if there are sls_ship_dt or sls_due_dt that earlier than sls_order_dt, it shows.
--		Expectation: No result
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;
GO

-- 4. Check Data Consistency between Sales, Quantity and Price
-- >> Sales = Quantity * Price
-- >> Values must NOT be NULL, ZERO or NEGATIVE
-- Checking for the opposite, if the Sales is NOT equal to Quantity * Price, and so on...
-- Solution: Not the best, but good for now.
--		1. If Sales is negative, zero or null, use the calculation [Sales = Quantity * Price].
--		2. If Price is zero or null, use the calculation [Price= Sales / Quantity].
--		3. If Price is negative, convert to a positive value.
SELECT DISTINCT
	sls_sales AS old_sls_sales,
	sls_quantity,
	sls_price AS old_sls_price,
	CASE
		WHEN	sls_sales IS NULL
				OR sls_sales <= 0
				OR sls_sales != sls_quantity * ABS(sls_price)
			THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales,

	CASE
		WHEN	sls_price IS NULL
				OR sls_price <= 0
			THEN sls_sales / NULLIF(sls_quantity, 0)
		ELSE sls_price
	END AS sls_price
FROM bronze.crm_sales_details
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
-- 1. Clean up NAS from the begining of the cid
SELECT *
FROM bronze.erp_cust_az12
WHERE cid LIKE '%AW00011000%';
GO

SELECT *
FROM silver.crm_cust_info;
GO

-- Corrects the cid column, and checks in the WHERE clause if there are miss matches in the 
-- crm_cust_info 's cst_key and erp_cust_az12 's cid.
-- Short: If cst_key != cid, show it in results.
-- Expectation: No result
SELECT 
	cid,
	CASE 
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
		ELSE cid
	END AS cid_corr,
	bdate,
	gen
FROM bronze.erp_cust_az12
WHERE 
	CASE 
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
		ELSE cid
	END NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info);
GO

-- 2. Identify Out-of-Range Dates
-- Birthdate is strange if it is low or in the future
SELECT DISTINCT bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1900-01-01' OR bdate > GETDATE();
GO

-- 3. Data Standardization & Consistency
-- Only values we need: Male | Female | n/a
SELECT DISTINCT 
	gen,
	CASE
		WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
		WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
		ELSE 'n/a'
	END AS gen
FROM bronze.erp_cust_az12;
GO

-- ***** erp_loc_a101 table *****
-- 1. Need to remove the "-" from cid to match cst_key
SELECT
	cid,
	cntry
FROM bronze.erp_loc_a101;
GO

SELECT cst_key
FROM silver.crm_cust_info;
GO

SELECT
	REPLACE(cid, '-', '') AS cid,
	cntry
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '')  NOT IN (SELECT cst_key FROM silver.crm_cust_info);
GO

-- 2. Data Standardization & Consistency [cntry]
SELECT DISTINCT cntry
FROM bronze.erp_loc_a101
ORDER BY cntry;
GO

SELECT DISTINCT 
	cntry AS old_cntry,
	CASE
		WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		WHEN TRIM(cntry) IN('US', 'USA') THEN 'United States'
		WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
		ELSE TRIM(cntry)
	END AS cntry
FROM bronze.erp_loc_a101
ORDER BY cntry;
GO


-- ***** erp_px_cat_g1v2 table *****
SELECT 
	id,
	cat,
	subcat,
	maintenance
FROM bronze.erp_px_cat_g1v2;
GO

-- 1. Check for unwanted spaces
--		Expectation: No result
SELECT 
	id,
	cat,
	subcat,
	maintenance
FROM bronze.erp_px_cat_g1v2
WHERE 
	cat != TRIM(cat) 
	OR subcat != TRIM(subcat) 
	OR maintenance != TRIM(maintenance);
GO

-- 2. Data Standardization & Consistency
SELECT DISTINCT
	cat
FROM bronze.erp_px_cat_g1v2;
GO

SELECT DISTINCT
	subcat
FROM bronze.erp_px_cat_g1v2;
GO

SELECT DISTINCT
	maintenance
FROM bronze.erp_px_cat_g1v2;
GO