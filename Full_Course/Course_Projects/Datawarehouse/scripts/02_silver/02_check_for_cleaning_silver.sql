/*
            ----------------------------------------------------------------------------------------------
					DOC: 11_SQL_Projects.pdf
					CONNECTION: DataWarehouse

											 DataWarehouse
										      (23:21:04)
			-----------------------------------------------------------------------------------------------
*/

USE DataWarehouse;
GO

-- ================================================================
--							Silver Layer
--							(1:01:10:20)
-- ================================================================

-- <<<<< Clean & Load (1:01:26:30) >>>>>

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