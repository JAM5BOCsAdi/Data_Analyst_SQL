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


-- <<<<< Develop SQL Load Scripts (1:00:44:00) >>>>>
-- Full Load: Truncate -> Insert
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	
	DECLARE @start_time DATETIME,
			@end_time DATETIME,
			@batch_start_time DATETIME,
			@batch_end_time DATETIME;
	BEGIN TRY

		PRINT '=========================';
		PRINT '   Loading Bronz Layer   ';
		PRINT '=========================';

		PRINT '-------------------------';
		PRINT '   Loading CRM Tables   ';
		PRINT '-------------------------';

		SET @batch_start_time = GETDATE();

		-- ***** crm_cust_info table *****
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> Inserting Data Into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\orada\Documents\Data_Analyst\Data_Analyst_SQL\Full_Course\Course_Projects\Datawarehouse\datasets\source_crm\cust_info.csv'
		-- If you use N'', somehow it does not loads the last row data, and it is missing.
		-- FROM N'C:\Users\orada\Documents\Data_Analyst\Data_Analyst_SQL\Full_Course\Course_Projects\Datawarehouse\datasets\source_crm\cust_info.csv'
		WITH (
			FIELDTERMINATOR = ',',
			FORMAT = 'CSV',
			FIRSTROW = 2,
			TABLOCK 
		)
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(millisecond, @start_time, @end_time) AS NVARCHAR) + ' millisecond(s)';
		PRINT '______________';



		-- ***** crm_prd_info table *****
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> Inserting Data Into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\orada\Documents\Data_Analyst\Data_Analyst_SQL\Full_Course\Course_Projects\Datawarehouse\datasets\source_crm\prd_info.csv'
		WITH (
			FIELDTERMINATOR = ',',
			FORMAT = 'CSV',
			FIRSTROW = 2,
			TABLOCK 
		)
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(millisecond, @start_time, @end_time) AS NVARCHAR) + ' millisecond(s)';
		PRINT '______________';



		-- ***** crm_sales_details table *****
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>> Inserting Data Into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\orada\Documents\Data_Analyst\Data_Analyst_SQL\Full_Course\Course_Projects\Datawarehouse\datasets\source_crm\sales_details.csv'
		WITH (
			FIELDTERMINATOR = ',',
			FORMAT = 'CSV',
			FIRSTROW = 2,
			TABLOCK 
		)
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(millisecond, @start_time, @end_time) AS NVARCHAR) + ' millisecond(s)';



		-- -------------------------------------------------------------------------
		-- Last row Does not loads properly, because you need a delimiter at the end (in excel or notepad)
		-- Shortest way for doing this: Open CUST_AZ12.csv in Excel, rolldown to the last row, click in it (or after the end), then push ENTER to make a '\n'
		PRINT '-------------------------';
		PRINT '   Loading ERP Tables   ';
		PRINT '-------------------------';

		-- ***** erp_cust_az12 table *****
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\orada\Documents\Data_Analyst\Data_Analyst_SQL\Full_Course\Course_Projects\Datawarehouse\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIELDTERMINATOR = ',',
			FORMAT = 'CSV',
			FIRSTROW = 2,
			TABLOCK 
		)
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(millisecond, @start_time, @end_time) AS NVARCHAR) + ' millisecond(s)';
		PRINT '______________';



		-- ***** erp_loc_a101 table *****
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\orada\Documents\Data_Analyst\Data_Analyst_SQL\Full_Course\Course_Projects\Datawarehouse\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIELDTERMINATOR = ',',
			FORMAT = 'CSV',
			FIRSTROW = 2,
			TABLOCK 
		)
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(millisecond, @start_time, @end_time) AS NVARCHAR) + ' millisecond(s)';
		PRINT '______________';



		-- ***** erp_px_cat_g1v2 table *****
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\orada\Documents\Data_Analyst\Data_Analyst_SQL\Full_Course\Course_Projects\Datawarehouse\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIELDTERMINATOR = ',',
			FORMAT = 'CSV',
			FIRSTROW = 2,
			TABLOCK 
		)
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(millisecond, @start_time, @end_time) AS NVARCHAR) + ' millisecond(s)';


		SET @batch_end_time = GETDATE();
		PRINT '=========================';
		PRINT 'Loading Bronze Layer COMPLETED';
		PRINT '>> Total Load Duration: ' + CAST(DATEDIFF(millisecond, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' millisecond(s)';
		PRINT '=========================';

	END TRY
	BEGIN CATCH
		PRINT '=========================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZ LAYER';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Number' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================';
	END CATCH
						
END;
GO

-- <<<<< Create Stored Procedure (1:00:51:55) >>>>>
-- TIP: Save frequently used SQL code in Stored Procedures in database
EXEC bronze.load_bronze;
GO