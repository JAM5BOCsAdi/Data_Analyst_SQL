/*
            ----------------------------------------------------------------------------------------------
					DOC: 09_Performance_Optimization.pdf
					CONNECTION: SalesDB

											 SQL PARTITIONS
										      (21:11:05)
				
					This script demonstrates SQL Server partitioning features. It covers the
					creation of partition functions, filegroups, data files, partition schemes,
					partitioned tables, and verification queries. It also shows how to compare
					execution plans between partitioned and non-partitioned tables.

					Table of Contents:
						1. Create a Partition Function
						2. Create Filegroups
						3. Create Data Files
						4. Create Partition Scheme
						5. Create the Partitioned Table
						6. Insert Data Into the Partitioned Table
						7. How everything is connected
						8. Performance [Verify Partitioning and Compare Execution Plans]
			-----------------------------------------------------------------------------------------------
*/


USE SalesDB;
GO

--			********************************************************************************************
--													Pre-Things
--													(21:11:05)
--			********************************************************************************************
-- SQL PARTITIONING:
-- Divides Big Table into Smaller partitions, WHILE still being treated as a single logical table.


/*
            -----------------------------------------------------------------------------------------------
												Create Partition Function
													(21:16:00)
			-----------------------------------------------------------------------------------------------
*/

-- Partition Function:
-- Define the Logic on how to divide your data into partitions!
-- Based on Partition Key Like Column, Region, ... (Mainly DATE columns)
-- https://learn.microsoft.com/en-us/sql/t-sql/statements/create-partition-function-transact-sql?view=sql-server-ver17

-- Partition #		Value Range									Filegroup
-- 1				OrderDate <= '2023-12-31'					FG_2023
-- 2				'2023-12-31' < OrderDate <= '2024-12-31'	FG_2024
-- 3				'2024-12-31' < OrderDate <= '2025-12-31'	FG_2025
-- 4				'2025-12-31' < OrderDate					FG_2026

CREATE PARTITION FUNCTION PartitionByYear (DATE)
AS RANGE LEFT FOR VALUES ('2023-12-31', '2024-12-31', '2025-12-31');
GO

-- Query lists all existing Partition Function
SELECT
	spf.name,
	spf.function_id,
	spf.type,
	spf.type_desc,
	spf.boundary_value_on_right
FROM sys.partition_functions AS spf;
GO

/*
            -----------------------------------------------------------------------------------------------
												Create Filegroups
													(21:20:55)
			-----------------------------------------------------------------------------------------------
*/
-- Filegroups:
-- Logical container of one or more data files to help organize partitions. (= like folders)
-- https://learn.microsoft.com/en-us/sql/t-sql/statements/alter-database-transact-sql-file-and-filegroup-options?view=sql-server-ver17

-- PRIMARY (Filegroup): Default filegroup where all objects of database is stored.

-- Create filegroups
ALTER DATABASE SalesDB ADD FILEGROUP FG_2023;
ALTER DATABASE SalesDB ADD FILEGROUP FG_2024;
ALTER DATABASE SalesDB ADD FILEGROUP FG_2025;
ALTER DATABASE SalesDB ADD FILEGROUP FG_2026;

-- ALTER DATABASE SalesDB REMOVE FILEGROUP FG_2023;

-- Query lists all existing Filegroups
SELECT *
FROM sys.filegroups AS sf
WHERE sf.type = 'FG';
GO

/*
            -----------------------------------------------------------------------------------------------
												Create Data Files
													(21:23:38)
			-----------------------------------------------------------------------------------------------
*/

-- https://learn.microsoft.com/en-us/sql/relational-databases/databases/add-data-or-log-files-to-a-database?view=sql-server-ver17

-- Add .ndf files to each filegroup
ALTER DATABASE SalesDB ADD FILE(
	NAME = P_2023,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\P_2023.ndf'
    -- SIZE = 5MB,
    -- MAXSIZE = 100MB,
    -- FILEGROWTH = 5MB
)
TO FILEGROUP FG_2023;
GO

-- FILENAME: Path where the data going to be stored.
--		Example: C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA

ALTER DATABASE SalesDB ADD FILE(
	NAME = P_2024,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\P_2024.ndf'
)
TO FILEGROUP FG_2024;
GO

ALTER DATABASE SalesDB ADD FILE(
	NAME = P_2025,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\P_2025.ndf'
)
TO FILEGROUP FG_2025;
GO

ALTER DATABASE SalesDB ADD FILE(
	NAME = P_2026,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\P_2026.ndf'
)
TO FILEGROUP FG_2026;
GO

-- Check if files are in their corresponding Filegroups:
SELECT
	fg.name AS FilegroupName,
	mf.name AS LogicalFileName,
	mf.physical_name AS PhysicalFilePath,
	mf.size / 128 AS SizeInMB
FROM sys.filegroups AS fg
INNER JOIN sys.master_files AS mf
	ON fg.data_space_id = mf.data_space_id
WHERE mf.database_id = DB_ID('SalesDB');
GO


/*
            -----------------------------------------------------------------------------------------------
												Create Partition Scheme
													(21:28:40)
			-----------------------------------------------------------------------------------------------
*/
-- Partition Scheme:
-- Connects Partitions to filegroups. 
-- Like '2023-12-31', '2024-12-31', '2025-12-31' partitions to FG_2023, FG_2024, FG_2025, FG_2026
-- https://learn.microsoft.com/en-us/sql/t-sql/statements/create-partition-scheme-transact-sql?view=sql-server-ver17
-- https://learn.microsoft.com/en-us/sql/t-sql/statements/alter-partition-scheme-transact-sql?view=sql-server-ver17
-- https://learn.microsoft.com/en-us/sql/t-sql/statements/drop-partition-scheme-transact-sql?view=sql-server-ver17

-- Create Partition Scheme
CREATE PARTITION SCHEME SchemePartitionByYear
AS PARTITION PartitionByYear -- Line: 48
-- Sort the filegroups according to the result of the function's partitions.
-- 3 boundaries = 4 partitions = 4 filegroups (Line: 49)
TO(FG_2023, FG_2024, FG_2025, FG_2026); -- Same order as on line 49
GO

-- Query lists all Partition Scheme
SELECT
	ps.name AS PartitionSchemeName,
	pf.name AS PartitionFunctionName,
	dds.destination_id AS PartitionNumber,
	fg.name AS FilegroupName
FROM sys.partition_schemes ps
INNER JOIN sys.partition_functions AS pf
	ON ps.function_id = pf.function_id
INNER JOIN sys.destination_data_spaces AS dds
	ON ps.data_space_id = dds.partition_scheme_id
INNER JOIN sys.filegroups AS fg
	ON dds.data_space_id = fg.data_space_id;
GO

/*
            -----------------------------------------------------------------------------------------------
												Create Partitioned Table
													(21:33:20)
			-----------------------------------------------------------------------------------------------
*/
-- https://learn.microsoft.com/en-us/sql/relational-databases/partitions/create-partitioned-tables-and-indexes?view=sql-server-ver16

-- Create Partitioned Table
CREATE TABLE Sales.Orders_Partitioned(
	OrderID INT,
	OrderDate DATE,
	Sales INT
) ON SchemePartitionByYear(OrderDate);
GO

-- Insert data into the partitioned table
INSERT INTO Sales.Orders_Partitioned
VALUES(1, '2023-05-15', 100);
GO

SELECT *
FROM Sales.Orders_Partitioned;
GO

SELECT
	p.partition_number AS PartitionNumber,
	fg.name AS PartitionFilegroup,
	p.rows AS NumberOrRows
FROM sys.partitions AS p
INNER JOIN sys.destination_data_spaces AS dds 
	ON p.partition_number = dds.destination_id
INNER JOIN sys.filegroups AS fg
	ON dds.data_space_id = fg.data_space_id
	WHERE OBJECT_NAME(p.object_id) = 'Orders_Partitioned';
GO

INSERT INTO Sales.Orders_Partitioned
VALUES(2, '2024-07-20', 50);
GO

INSERT INTO Sales.Orders_Partitioned
VALUES(3, '2025-12-31', 20); -- AS RANGE LEFT FOR VALUES ('2023-12-31', '2024-12-31', '2025-12-31');
GO

INSERT INTO Sales.Orders_Partitioned
VALUES(4, '2026-01-01', 100);
GO

SELECT *
FROM Sales.Orders_Partitioned;
GO

/*
            -----------------------------------------------------------------------------------------------
												How everything is connected
													(21:39:00)
			-----------------------------------------------------------------------------------------------
*/

/*
            -----------------------------------------------------------------------------------------------
												Performance [Verify Partitioning and Compare Execution Plans]
													(21:40:05)
			-----------------------------------------------------------------------------------------------
*/

SELECT *
INTO Sales.Orders_NoPartitioned
FROM Sales.Orders_Partitioned;
GO

-- Check for query performance optimazitions
-- No Partitioned
SELECT *
FROM Sales.Orders_NoPartitioned AS sonp1
WHERE sonp1.OrderDate = '2026-01-01';
GO
-- Partitioned
SELECT *
FROM Sales.Orders_Partitioned AS sop1
WHERE sop1.OrderDate = '2026-01-01';
GO


-- No Partitioned
SELECT *
FROM Sales.Orders_NoPartitioned AS sonp2
WHERE sonp2.OrderDate IN('2026-01-01', '2025-12-31');
GO
-- Partitioned
SELECT *
FROM Sales.Orders_Partitioned AS sop2
WHERE sop2.OrderDate IN('2026-01-01', '2025-12-31');
GO

