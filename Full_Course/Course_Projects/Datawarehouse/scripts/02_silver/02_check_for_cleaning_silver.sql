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

-- 1. Check for NULLS or DUPLICATES in Primary Key
--		Expectation: No result
SELECT 
	cst_id,
	COUNT(*) AS duplicates_nr
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;
GO

-- 2. Check for unwanted spaces in text columns
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
-- Change F -> Female | M -> Male | NULL -> n/a
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;
GO