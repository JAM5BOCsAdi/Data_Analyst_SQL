/*
            ----------------------------------------------------------------------------------------------
					DOC: 11_SQL_Projects.pdf
					CONNECTION: DataWarehouse

											 DataWarehouse
										      (23:21:04)
			-----------------------------------------------------------------------------------------------
*/


USE master;
GO

-- You can use
-- Create Database 'DataWarehouse'
--IF NOT EXISTS(
--	SELECT 1
--	FROM sys.databases AS d
--	WHERE d.name = 'DataWarehouse'
--)
IF DB_ID('DataWarehouse') IS NULL 
	BEGIN
		BEGIN TRY
			CREATE DATABASE DataWarehouse;
			USE DataWarehouse;
			PRINT N'DataWarehouse database created successfully.';
		END TRY
		BEGIN CATCH
			PRINT N'Error Creating Database';
			PRINT N'-----------------------------------';
			PRINT N'Error Number: ' + ERROR_NUMBER();
			PRINT N'Error Severity: ' + ERROR_SEVERITY();
			PRINT N'Error State: ' + ERROR_STATE();
			PRINT N'Error Line: ' + ERROR_LINE();
			PRINT N'Error Message: ' + ERROR_MESSAGE();
		END CATCH
	END
ELSE
	BEGIN
		USE DataWarehouse;
		PRINT N'DataWarehouse database already exists.';
	END
GO

-- NEXT: Automate this part too:
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

-- NEXT: Make it a Stored Procedure to do all this