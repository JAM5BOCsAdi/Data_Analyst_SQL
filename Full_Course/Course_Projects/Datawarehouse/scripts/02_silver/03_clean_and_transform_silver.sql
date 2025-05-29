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
-- https://learn.microsoft.com/en-us/sql/t-sql/statements/insert-transact-sql?view=sql-server-ver17


-- ***** crm_cust_info table *****
TRUNCATE TABLE silver.crm_cust_info;
GO
INSERT INTO silver.crm_cust_info(
	-- Columns:
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
)
SELECT 
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	CASE UPPER(TRIM(cst_marital_status))
		WHEN 'S' THEN 'Single'
		WHEN 'M' THEN 'Married'
		ELSE 'n/a'
	END AS cst_marital_status,
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
	WHERE cst_id IS NOT NULL
	-- WHERE cst_id = 29466
) AS sub
WHERE	sub.flag_last = 1;
GO




-- ***** crm_prd_info table *****
TRUNCATE TABLE silver.crm_prd_info;
GO
INSERT INTO silver.crm_prd_info(
	prd_id,
	prd_cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
)
SELECT
	prd_id,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS prd_cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
	prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost, -- COALESCE also good, might be better
	CASE UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'n/a'
	END AS prd_line,
	CAST(prd_start_dt AS DATE) AS prd_start_dt,
	CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt ASC) -1 AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info
-- WHERE prd_key IN('AC-HE-HL-U509-R', 'AC-HE-HL-U509')
-- WHERE SUBSTRING(prd_key, 7, LEN(prd_key)) NOT IN (SELECT sls_prd_key FROM bronze.crm_sales_details);
-- WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') NOT IN (SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2);
GO




-- ***** crm_sales_details table *****
-- CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
-- Here you can not cast an INT to DATE, first you need to cast to VARCHAR then to DATE. [in SQL Server]
SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE
		WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	END AS sls_order_dt,
	CASE
		WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
	END AS sls_ship_dt,
	CASE
		WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END AS sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
FROM bronze.crm_sales_details;
-- WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)
-- WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);
GO


--- ========================================= Extra BEGIN =========================================
-- UDF (User-Defined Function): https://learn.microsoft.com/en-us/sql/t-sql/statements/create-function-transact-sql?view=sql-server-ver17
-- It stores the logic of the CASE-END statements, and you can re-use it, like a Stored Procedure.
-- Find it: DatawareHouse -> Programmability -> Functions -> Table- or Scalar-valued Functions
CREATE FUNCTION silver.CleanDate (@date INT)
RETURNS DATE
AS
BEGIN
    DECLARE @result DATE;

    SET @result = 
        CASE 
            WHEN @date = 0 OR LEN(@date) != 8 THEN NULL
            ELSE CAST(CAST(@date AS VARCHAR(8)) AS DATE)
        END;

    RETURN @result;
END;
GO

-- Same Select, but with UDF:
SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	silver.CleanDate(sls_order_dt) AS sls_order_dt, -- <-- UDF used here
	silver.CleanDate(sls_ship_dt) AS sls_ship_dt,
	silver.CleanDate(sls_due_dt) AS sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
FROM bronze.crm_sales_details;
-- WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)
-- WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);
GO

--- ========================================= Extra END =========================================