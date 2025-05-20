/*
            -----------------------------------------------------------------------------------------------
			        DOC: 08_Advanced_SQL_Techniques.pdf
					CONNECTION: SalesBD

										SQL STORED PROCEDURE
										      (17:27:00)

					This script shows how to work with stored procedures in SQL Server,
					starting from basic implementations and advancing to more sophisticated
					techniques.

					Table of Contents:
						1. Basics (Creation and Execution)
						2. Parameters
						3. Multiple Queries
						4. Variables
						5. Control Flow with IF/ELSE
						6. Error Handling with TRY/CATCH
				
			-----------------------------------------------------------------------------------------------
*/


USE SalesDB;
GO

--			********************************************************************************************
--													Pre-Things
--													(17:27:00)
--			********************************************************************************************

-- <<<<< Stored Procedure vs Query (17:31:00) >>>>>
-- <<<<< Stored Procedure vs Coding with Python (17:32:40) >>>>>


/*
            -----------------------------------------------------------------------------------------------
												   BASICS
												  (17:36:35)
			-----------------------------------------------------------------------------------------------
*/
-- CREATE OR ALTER PROCEDURE <name> 
--       @<variable1> <type>, 
--		 @<variable2> <type>,
--		 @<variable3> <type>,
--			...
-- AS
-- BEGIN
--	... [Use of <variables>, if needed]
-- END;
-- GO

-- EXEC <name> @<variable> = <value>;
-- GO

-- Write a query for US customers, to find the total number of customers and the average score
CREATE /* OR ALTER */ PROCEDURE sp_GetCustomerSummaryUSA As
BEGIN
	SELECT
		COUNT(*) AS TotalCustomers,
		AVG(sc.Score) AS AvgScore
	FROM Sales.Customers AS sc
	WHERE sc.Country = 'USA'
END;
GO

EXEC sp_GetCustomerSummaryUSA;
GO

/*
            -----------------------------------------------------------------------------------------------
												   PARAMETERS
												  (17:40:40)
			-----------------------------------------------------------------------------------------------
*/
-- Placeholders used to pass values as input from the caller to the procedure, allowing dynamic data to be processed.

-- For German customers find the total number of customers and the average score
CREATE /* OR ALTER */ PROCEDURE sp_GetCustomerSummary 
	@Country NVARCHAR(50)
AS
BEGIN
	SELECT
		COUNT(*) AS TotalCustomers,
		AVG(sc.Score) AS AvgScore
	FROM Sales.Customers AS sc
	WHERE sc.Country = @Country
END;
GO

EXEC sp_GetCustomerSummary @Country = 'Germany';
GO

EXEC sp_GetCustomerSummary @Country = 'USA';
GO

-- Default values:
CREATE /* OR ALTER */ PROCEDURE sp_GetCustomerSummary2 
	@Country2 NVARCHAR(50) = 'USA'
AS
BEGIN
	SELECT
		COUNT(*) AS TotalCustomers,
		AVG(sc.Score) AS AvgScore
	FROM Sales.Customers AS sc
	WHERE sc.Country = @Country2
END;
GO

EXEC sp_GetCustomerSummary2 @Country2 = 'Germany';
GO

EXEC sp_GetCustomerSummary2;
GO


-- Select dynamically the Country value
CREATE /* OR ALTER */ PROCEDURE sp_GetCustomerSummary3 
    @Country3 NVARCHAR(50) = NULL
AS
BEGIN
    -- If no country is provided, find the top 1 country by customer count
    IF @Country3 IS NULL
		BEGIN
			SELECT TOP 1 @Country3 = sc.Country
			FROM Sales.Customers AS sc
			GROUP BY sc.Country
			ORDER BY COUNT(*) DESC;
			PRINT N'Selected TOP 1 Country: ' + @Country3;
		END
	--SET a DEFAULT value in the ELSE clause, but also can be done in the Declaration, if te logic is correct that way
	--ELSE 
	--	BEGIN
	--		SET @Country3 = 'Germany';
	--		PRINT N'DEFAULT Country:' + @Country3;
	--	END

	-- Now use the resolved @Country3 to get summary data
	SELECT
		@Country3 AS SelectedCountry,
		COUNT(*) AS TotalCustomers,
		AVG(sc.Score) AS AvgScore
	FROM Sales.Customers AS sc
	WHERE sc.Country = @Country3;
	-- PRINT N'Selected Country: ' + @Country3;
END;
GO

-- Dynamically selects top 1 country by customer count
EXEC sp_GetCustomerSummary3;
GO

-- Uses provided country
EXEC sp_GetCustomerSummary3 @Country3 = 'Germany';
GO

/*
            -----------------------------------------------------------------------------------------------
											MULTIPLE STATEMENTS
												  (17:47:30)
			-----------------------------------------------------------------------------------------------
*/

-- Find the total nr. of orders and total sales [2nd query in the procedure]
CREATE /* OR ALTER */ PROCEDURE sp_GetCustomerSummary4 
	@Country4 NVARCHAR(50) = 'USA'
AS
BEGIN
	SELECT
		@Country4 AS SelectedCountry,
		COUNT(*) AS TotalCustomers,
		AVG(sc.Score) AS AvgScore
	FROM Sales.Customers AS sc
	WHERE sc.Country = @Country4;
	

	SELECT
		@Country4 AS SelectedCountry,
		COUNT(so.OrderID) AS TotalOrders,
		SUM(so.Sales) AS TotalSales
	FROM Sales.Orders AS so
	JOIN Sales.Customers AS sc -- It is INNER JOIN 
		ON so.CustomerID = sc.CustomerID
	WHERE sc.Country = @Country4;
END;
GO

EXEC sp_GetCustomerSummary4;
GO

EXEC sp_GetCustomerSummary4 @Country4 = 'Germany';
GO

/*
            -----------------------------------------------------------------------------------------------
												   VARIABLES
												  (17:50:35)
			-----------------------------------------------------------------------------------------------
*/
-- Placeholders used to store values to be used later in the procedure.

CREATE /* OR ALTER */ PROCEDURE sp_GetCustomerSummary5 
	@Country5 NVARCHAR(50) = 'USA'
AS
BEGIN
	DECLARE @TotalCustomers		INT,
			@AvgScore			FLOAT;

	SELECT
		@TotalCustomers = COUNT(*),
		@AvgScore = AVG(sc.Score)
	FROM Sales.Customers AS sc
	WHERE sc.Country = @Country5;

	PRINT N'Total customers from ' + @Country5 + ': ' + CAST(@TotalCustomers AS NVARCHAR);
	PRINT N'Average score from ' + @Country5 + ': ' + CAST(@AvgScore AS NVARCHAR);
	

	SELECT
		@Country5 AS SelectedCountry,
		COUNT(so.OrderID) AS TotalOrders,
		SUM(so.Sales) AS TotalSales
	FROM Sales.Orders AS so
	JOIN Sales.Customers AS sc -- It is INNER JOIN 
		ON so.CustomerID = sc.CustomerID
	WHERE sc.Country = @Country5;
END;
GO

EXEC sp_GetCustomerSummary5;
GO

EXEC sp_GetCustomerSummary5 @Country5 = 'Germany';
GO

/*
            -----------------------------------------------------------------------------------------------
											Control Flow with IF/ELSE
												  (17:58:15)
			-----------------------------------------------------------------------------------------------
*/

CREATE /* OR ALTER */ PROCEDURE sp_GetCustomerSummary6 
	@Country6 NVARCHAR(50) = 'USA'
AS
BEGIN
	DECLARE @TotalCustomers		INT,
			@AvgScore			FLOAT;
	
	
	-- <<<<< Prepare & Clean up >>>>>
	
	-- Check if there is NULL in Country, write 1. Else 0.
	-- SELECT 1 FROM Sales.Customers AS sc WHERE sc.Score IS NULL AND sc.Country = @Country6

	IF EXISTS (SELECT 1 FROM Sales.Customers AS sc WHERE sc.Score IS NULL AND sc.Country = @Country6)
		BEGIN
			PRINT N'Updating NULL Scores to 0 ...'
			UPDATE Sales.Customers
			SET Score = 0
			WHERE Score IS NULL AND Country = @Country6;
		END;

	ELSE
		BEGIN
			PRINT N'No NULL Scores found.';
		END;


	-- <<<<< Generating Reports >>>>>
	SELECT
		@TotalCustomers = COUNT(*),
		@AvgScore = AVG(sc.Score)
	FROM Sales.Customers AS sc
	WHERE sc.Country = @Country6;

	PRINT N'Total customers from ' + @Country6 + ': ' + CAST(@TotalCustomers AS NVARCHAR);
	PRINT N'Average score from ' + @Country6 + ': ' + CAST(@AvgScore AS NVARCHAR);
	

	SELECT
		@Country6 AS SelectedCountry,
		COUNT(so.OrderID) AS TotalOrders,
		SUM(so.Sales) AS TotalSales
	FROM Sales.Orders AS so
	JOIN Sales.Customers AS sc -- It is INNER JOIN 
		ON so.CustomerID = sc.CustomerID
	WHERE sc.Country = @Country6;
END;
GO

EXEC sp_GetCustomerSummary6;
GO

EXEC sp_GetCustomerSummary6 @Country6 = 'Germany';
GO

SELECT *
FROM Sales.Customers;
GO

/*
            -----------------------------------------------------------------------------------------------
											Error Handling with TRY/CATCH
												  (18:04:50)
			-----------------------------------------------------------------------------------------------
*/

-- https://learn.microsoft.com/en-us/sql/t-sql/language-elements/try-catch-transact-sql?view=sql-server-ver16#retrieve-error-information

-- BEGIN TRY
--		...
-- END TRY
-- BEGIN CATCH
--		...
-- END CATCH

CREATE /* OR ALTER */ PROCEDURE sp_GetCustomerSummary7 
	@Country7 NVARCHAR(50) = 'USA'
AS
BEGIN
	BEGIN TRY
		DECLARE @TotalCustomers		INT,
				@AvgScore			FLOAT;
	
		-- ===================
		--  Prepare & Clean up 
		-- ===================

		-- Check if there is NULL in Country, write 1. Else 0.
		-- SELECT 1 FROM Sales.Customers AS sc WHERE sc.Score IS NULL AND sc.Country = @Country6

		IF EXISTS (SELECT 1 FROM Sales.Customers AS sc WHERE sc.Score IS NULL AND sc.Country = @Country7)
			BEGIN
				PRINT N'Updating NULL Scores to 0 ...'
				UPDATE Sales.Customers
				SET Score = 0
				WHERE Score IS NULL AND Country = @Country7;
			END;

		ELSE
			BEGIN
				PRINT N'No NULL Scores found.';
			END;


		-- ===================
		--  Gemerate Reports 
		-- ===================
		-- Calculate total customers and average score for specific country

		SELECT
			@TotalCustomers = COUNT(*),
			@AvgScore = AVG(sc.Score)
		FROM Sales.Customers AS sc
		WHERE sc.Country = @Country7;

		PRINT N'Total customers from ' + @Country7 + ': ' + CAST(@TotalCustomers AS NVARCHAR);
		PRINT N'Average score from ' + @Country7 + ': ' + CAST(@AvgScore AS NVARCHAR);
	
		-- Calculate total number of orders and total sales for specify country
		SELECT
			@Country7 AS SelectedCountry,
			COUNT(so.OrderID) AS TotalOrders,
			SUM(so.Sales) AS TotalSales
			-- 1/0 <-- This can give the error (Dividing by zero)
		FROM Sales.Orders AS so
		JOIN Sales.Customers AS sc -- It is INNER JOIN 
			ON so.CustomerID = sc.CustomerID
		WHERE sc.Country = @Country7;
	END TRY
	
	BEGIN CATCH
		PRINT N'An error occured.';
		PRINT N'Error Message: '+ ERROR_MESSAGE();
		PRINT N'Error Number: '+ CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT N'Error Line: '+ CAST(ERROR_LINE() AS NVARCHAR);
		PRINT N'Error Procedure: ' + ERROR_PROCEDURE();
	END CATCH
END;
GO

EXEC sp_GetCustomerSummary7;
GO

EXEC sp_GetCustomerSummary7 @Country7 = 'Germany';
GO

SELECT *
FROM Sales.Customers;
GO