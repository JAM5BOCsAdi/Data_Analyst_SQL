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

-- <<<<< Quality Check for Silver (1:01:39:00) >>>>>

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