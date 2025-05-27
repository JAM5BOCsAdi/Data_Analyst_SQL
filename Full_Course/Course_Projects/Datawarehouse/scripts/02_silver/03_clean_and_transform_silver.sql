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

-- <<<<< Clean & Transform Data (1:01:29:30) >>>>>
-- This cleans all the things that are in the 02_check_for_cleaning_silver.sql

SELECT 
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	cst_marital_status,
	CASE UPPER(TRIM(cst_gndr))
		WHEN 'F' THEN 'Female'
		WHEN 'M' THEN 'Male'
		ELSE 'n/a'
	END AS cst_gndr,
	cst_create_date
FROM(
	SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
	FROM bronze.crm_cust_info
	-- WHERE cst_id = 29466
) AS sub
WHERE sub.flag_last = 1; -- AND cst_id = 29466;
GO