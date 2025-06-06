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

-- <<<<< Clean & Transform Data (1:01:29:30) >>>>>
-- This cleans all the things that are in the 02_check_for_cleaning_silver.sql
-- https://learn.microsoft.com/en-us/sql/t-sql/statements/insert-transact-sql?view=sql-server-ver17

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN

	DECLARE @start_time DATETIME,
			@end_time DATETIME,
			@batch_start_time DATETIME,
			@batch_end_time DATETIME;
	BEGIN TRY

		PRINT '=========================';
		PRINT '   Loading Silver Layer   ';
		PRINT '=========================';


		SET @batch_start_time = GETDATE();


		-- -------------------------------
		--				CRM
		--          (1:01:26:30)
		-- -------------------------------
		PRINT '-------------------------';
		PRINT '   Loading CRM Tables   ';
		PRINT '-------------------------';

		-- ***** crm_cust_info table *****
		SET @start_time = GETDATE();
		PRINT N'>> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
	
		PRINT N'>> Inserting Data Into: silver.crm_cust_info';
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
		WHERE sub.flag_last = 1;
		
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(millisecond, @start_time, @end_time) AS NVARCHAR) + ' millisecond(s)';
		PRINT '______________';




		-- ***** crm_prd_info table *****
		SET @start_time = GETDATE();
		PRINT N'>> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
	
		PRINT N'>> Inserting Data Into: silver.crm_prd_info';
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
		FROM bronze.crm_prd_info;
		-- WHERE prd_key IN('AC-HE-HL-U509-R', 'AC-HE-HL-U509')
		-- WHERE SUBSTRING(prd_key, 7, LEN(prd_key)) NOT IN (SELECT sls_prd_key FROM bronze.crm_sales_details);
		-- WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') NOT IN (SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2);
		
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(millisecond, @start_time, @end_time) AS NVARCHAR) + ' millisecond(s)';
		PRINT '______________';




		-- ***** crm_sales_details table *****
		SET @start_time = GETDATE();
		-- CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
		-- Here you can not cast an INT to DATE, first you need to cast to VARCHAR then to DATE. [in SQL Server]
		PRINT N'>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
	
		PRINT N'>> Inserting Data Into: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE
				WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 
					THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,

			CASE
				WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 
					THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,

			CASE
				WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 
					THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,

			CASE
				WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
					THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
			END AS sls_sales,

			sls_quantity,

			CASE
				WHEN sls_price IS NULL OR sls_price <= 0
					THEN sls_sales / NULLIF(sls_quantity, 0)
				ELSE sls_price
			END AS sls_price
		FROM bronze.crm_sales_details;
		-- WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)
		-- WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(millisecond, @start_time, @end_time) AS NVARCHAR) + ' millisecond(s)';








		-- -------------------------------
		--				ERP 
		--          (1:02:19:20)
		-- -------------------------------
		PRINT '-------------------------';
		PRINT '   Loading ERP Tables   ';
		PRINT '-------------------------';

		-- ***** erp_cust_az12 table *****
		SET @start_time = GETDATE();
		PRINT N'>> Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
	
		PRINT N'>> Inserting Data Into: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12(
			cid,
			bdate,
			gen
		)
		SELECT 
			CASE 
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
				ELSE cid
			END AS cid,
			CASE
				WHEN bdate < '1900-01-01' OR bdate > GETDATE() THEN NULL
				ELSE bdate
			END bdate,
			CASE
				WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				ELSE 'n/a'
			END AS gen
		FROM bronze.erp_cust_az12;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(millisecond, @start_time, @end_time) AS NVARCHAR) + ' millisecond(s)';
		PRINT '______________';




		-- ***** erp_loc_a101 table *****
		SET @start_time = GETDATE();
		PRINT N'>> Truncating Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
	
		PRINT N'>> Inserting Data Into: silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101(
			cid, 
			cntry
		)
		SELECT
			REPLACE(cid, '-', '') AS cid,
			CASE
				WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				WHEN TRIM(cntry) IN('US', 'USA') THEN 'United States'
				WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
				ELSE TRIM(cntry)
			END AS cntry
		FROM bronze.erp_loc_a101;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(millisecond, @start_time, @end_time) AS NVARCHAR) + ' millisecond(s)';
		PRINT '______________';




		-- ***** erp_px_cat_g1v2 table *****
		SET @start_time = GETDATE();
		-- There is nothing wrong here, so just insert it
		PRINT N'>> Truncating Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
	
		PRINT N'>> Inserting Data Into: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2(
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT 
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(millisecond, @start_time, @end_time) AS NVARCHAR) + ' millisecond(s)';




		SET @batch_end_time = GETDATE();
		PRINT '=========================';
		PRINT 'Loading Silver Layer COMPLETED';
		PRINT '>> Total Load Duration: ' + CAST(DATEDIFF(millisecond, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' millisecond(s)';
		PRINT '=========================';

	END TRY
	BEGIN CATCH
		PRINT '=========================================';
		PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Number' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================';
	END CATCH
END;
GO

EXEC silver.load_silver;
GO

--- ========================================= Extra BEGIN =========================================
-- UDF (User-Defined Function): https://learn.microsoft.com/en-us/sql/t-sql/statements/create-function-transact-sql?view=sql-server-ver17
-- It stores the logic of the CASE-END statements, and you can re-use it, like a Stored Procedure.
-- https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-objects-transact-sql?view=sql-server-ver16
-- Find it: DatawareHouse -> Programmability -> Functions -> Table- or Scalar-valued Functions
IF OBJECT_ID('silver.CleanDate', 'FN') IS NOT NULL -- <-- FN : SQL scalar function
	DROP FUNCTION silver.CleanDate;
GO
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


--- ========================================= Extra END =========================================