/*
            -----------------------------------------------------------------------------------------------
			        DOC: 08_Advanced_SQL_Techniques.pdf
					CONNECTION: SalesBD

											 SQL TRIGGERS
										      (18:12:58)

					This script demonstrates the creation of a logging table, a trigger, and
					an insert operation into the Sales.Employees table that fires the trigger.
					The trigger logs details of newly added employees into the Sales.EmployeeLogs table.
				
			-----------------------------------------------------------------------------------------------
*/


USE SalesDB;
GO

--			********************************************************************************************
--													Pre-Things
--													(18:12:58)
--			********************************************************************************************
-- TRIGGERS: 
-- Special stored procedure (set of statements) that automatically runs in response
-- to a specific event on a table or view.
-- https://learn.microsoft.com/en-us/sql/t-sql/statements/create-trigger-transact-sql?view=sql-server-ver16
-- https://learn.microsoft.com/en-us/sql/relational-databases/triggers/logon-triggers?view=sql-server-ver16

-- Trigger types:
-- DML: (INSERT, UPDATE, DELETE)
--	  1. AFTER - Runs after the event
--    2. INSTEAD OF - Run during the event
-- DDL: (CREATE, ALTER, DROP, GRANT, DENY, REVOKE)
--    1. 
--    2. 
--    3. 
-- LOGON:

-- SQL Server TRIGGER Syntax  
-- Trigger on an INSERT, UPDATE, or DELETE statement to a table or view (DML Trigger)  
  
-- CREATE [ OR ALTER ] TRIGGER [ schema_name . ]trigger_name   
-- ON { table | view }   
-- [ WITH <dml_trigger_option> [ ,...n ] ]  
-- { FOR | AFTER | INSTEAD OF }   
-- { [ INSERT ] [ , ] [ UPDATE ] [ , ] [ DELETE ] }   
-- [ WITH APPEND ]  
-- [ NOT FOR REPLICATION ]   
-- AS 
-- BEGIN
--  { sql_statement  [ ; ] [ ,...n ] | EXTERNAL NAME <method specifier [ ; ] > }  
-- END 
 
-- <dml_trigger_option> ::=  
--     [ ENCRYPTION ]  
--     [ EXECUTE AS Clause ]  
  
-- <method_specifier> ::=  
--     assembly_name.class_name.method_name



-- TRIGGER syntax example:
-- CREATE TRIGGER <trigger_name> ON <table_name> AFTER INSERT
-- AS BEGIN
-- END


/*
            -----------------------------------------------------------------------------------------------
												   Logging - Trigger Use Case
												  (18:15:15)
			-----------------------------------------------------------------------------------------------
*/
-- To maintain audit logs.

CREATE TABLE Sales.EmployeeLogs(
	LogID INT IDENTITY(1,1) PRIMARY KEY, -- <-- id that start counting from 1
	EmployeeID INT, -- <-- Real data start from there
	LogMessage VARCHAR(255),
	LogDate DATE
);
GO

SELECT *
FROM Sales.EmployeeLogs;
GO

CREATE TRIGGER trg_AfterInsertEmployee ON Sales.Employees
AFTER INSERT
AS 
BEGIN
	INSERT INTO Sales.EmployeeLogs(EmployeeID, LogMessage, LogDate)
	SELECT
		EmployeeID,
		'New Employee Added = ' + CAST(EmployeeID AS VARCHAR),
		GETDATE()
		-- INSERTED: Virtual table that holds a copy of the rows that are being inserted into the target table
	FROM INSERTED
END;
GO

SELECT *
FROM Sales.Employees;
GO

INSERT INTO Sales.Employees
VALUES(7, 'Maria', 'Doe', 'HR', '1988-01-12',  'F', 80000, 3);
GO