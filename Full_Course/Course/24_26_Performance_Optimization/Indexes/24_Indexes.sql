/*
            -----------------------------------------------------------------------------------------------
			        DOC: 09_Performance_Optimization.pdf
					CONNECTION: SalesBD

											 SQL INDEXES
										      (18:23:40)

					This script demonstrates various index types in SQL Server including clustered,
					non-clustered, columnstore, unique, and filtered indexes. It provides examples 
					of creating a heap table, applying different index types, and testing their 
					usage with sample queries.

					Table of Contents:
						Index Types:
							0. Create Index: Leftmost Prefix Rule Explanation
							1. Structure:
								- Clustered index
								- Non-Clustered index
							2. Storage:
								- Rowstore
								- Columnstore
							3. Functions:
								- Unique
								- Filtered
						Choose the right index

						Index Management & Monitoring:
							- Monitor Index Usage
							- Monitor Missing Indexes
							- Monitor Duplicate Indexes
							- Update Statistics
							- Fragmentations
				
			-----------------------------------------------------------------------------------------------
*/


USE SalesDB;
GO

--			********************************************************************************************
--													Pre-Things
--													(18:23:50)
--			********************************************************************************************
-- INDEX:
-- Data structure that provides quick access to data, optimizing the speed of your queries.

-- Some indexes are better for reading other for writing performance.
-- All about to choose the right index for the task.

/*
            ********************************************************************************************
													INDEX TYPES
													(18:25:15)
			********************************************************************************************
*/

/*
            -----------------------------------------------------------------------------------------------
													STRUCTURE
													(18:25:15)
			-----------------------------------------------------------------------------------------------
*/
-- PRE-THINGS:

-- PAGE:
-- The smallest unit of data storage in a database (8kb)
-- It stores anything (Data, Metadata, Indexes, etc...)
-- Types:
--		- Data Page
--		- Index Page: Faster to read (search init)

-- HEAP Structure:
-- HEAP = Table without clustered index
-- Fast read, slow write

-- Table full scan:
-- Scans the entire table page by page and row by row, searching for data.

/*
            ==============================
			Clustered vs Non-Clustered Index
					(18:33:00)
			==============================
*/
-- <<<<< Clustered Index (18:33:00) >>>>>
-- Sorts the data, and it is easier to search init. = Faster search
-- You can only create one clustered index on a table, because it sorts the data.


-- <<<<< Non-Clustered Index (18:39:10) >>>>>
-- Does not touches the data, or make any re-organizations. It stays the same.
-- You can create non-clustered index multiple times, because it does not affects the data.


-- <<<<< Clustered Index vs Non-Clustered Index (18:43:55) >>>>>
-- USE CASES AT (18:50:45)

-- Clustered index:
-- Like a book and there is a table of content at the front (Tartalomjegyzék), it can easily find the data.
-- You can only create one clustered index on a table, because it sorts the data.
-- Use-case: Unique column | Not frequently modified column | Imporve range query performance
--			For example: Primary Keys, use Clustered Index, because PK is rarely updated, only inserted (append) at the end
-- By default SQL Server going to create a clustered index automatically on every primary Key

-- Non-Clustered index:
-- Like the Index at the end of the book (Tárgymutató).
-- You can create non-clustered index multiple times, because it does not affects the data.
-- Use-case: Columns frequently used in search conditions and joins | Exact match queries
--			For example: Joining tables without using Primary Keys | Searching for exact values


/*
            ==============================
					CREATE INDEX
					(18:52:00)
			==============================
*/
--                       Default
-- CREATE [CLUSTERED | NONCLUSTERED] INDEX <index_name> ON <table_name>(column1, column2, ...)

-- CREATE CLUSTERED INDEX idx_CustomersID ON Customers(ID)

-- CREATE NONCLUSTERED INDEX idx_CustomersCity ON Customers(City)

-- CREATE INDEX idx_Customers_Name ON Cutomers(LastName ASC, FirstName DESC)

-- Find:
-- SalesDB -> Tables -> Sales.Customers -> Indexes

-- This is a CTAS:
SELECT *
INTO Sales.DBCustomers
FROM Sales.Customers;
GO

-- This did a "table full scan", because this table is "unorganized".
SELECT *
FROM Sales.DBCustomers AS sdbc
WHERE sdbc.CustomerID = 1;
GO

-- To not scan all the data in the table, we create a Clustered index on Primary Key
CREATE CLUSTERED INDEX idx_DBCustomers_CustomerID
ON Sales.DBCustomers(CustomerID);
GO

-- To see we can not create multiple CLUSTERED INDEX on 1 table:
-- CREATE CLUSTERED INDEX idx_DBCustomers_FirstName
-- ON Sales.DBCustomers(FirstName);
-- GO

-- You want to change the column to make and index on:
DROP INDEX idx_DBCustomers_CustomerID ON Sales.DBCustomers;
GO

-- Searching for LastName:
SELECT *
FROM Sales.DBCustomers AS sdbc
WHERE sdbc.LastName = 'Brown';
GO

CREATE NONCLUSTERED INDEX idx_DBCustomers_LastName
ON Sales.DBCustomers(LastName);
GO

-- Searching for FirstName:
SELECT *
FROM Sales.DBCustomers AS sdbc
WHERE sdbc.FirstName = 'Anna';
GO

CREATE NONCLUSTERED INDEX idx_DBCustomers_FirstName
ON Sales.DBCustomers(FirstName);
GO

/*
            ==============================
					COMPOSITE INDEX
					(19:00:40)
			==============================
*/
-- Index that has multiple columns inside same index.

-- Searching for Country AND Score (so these 2 columns):
SELECT *
FROM Sales.DBCustomers AS sdbc
WHERE sdbc.Country = 'USA' AND sdbc.Score > 500;
GO

-- Important to keep the same order in INDEX as in the WHERE clause (query)
CREATE NONCLUSTERED INDEX idx_DBCustomers_CountryScore
ON Sales.DBCustomers(Country, Score); -- sdbc.Country = 'USA' AND sdbc.Score > 500
GO

-- If you change the order, the query does not use the INDEX, and it is just there for nothing
SELECT *
FROM Sales.DBCustomers AS sdbc
WHERE sdbc.Score > 500 AND sdbc.Country = 'USA'; -- <-- Changed the order
GO

-- <<<< Leftmost Prefix Rule >>>>>
-- If you only use 1 filter in the WHERE clause, the INDEX will work, if the order is the same but with
-- less filter values.
-- So here the "AND sdbc.Score > 500" is missing, but based on the leftmost prefix rule, it start from the left
-- and uses the Country to scan.
SELECT *
FROM Sales.DBCustomers AS sdbc
WHERE sdbc.Country = 'USA';
GO

-- It will not use the idx_DBCustomers_CountryScore
SELECT *
FROM Sales.DBCustomers AS sdbc
WHERE sdbc.Score > 500;
GO

/*
            -----------------------------------------------------------------------------------------------
													STORAGE
													(19:05:30)
			-----------------------------------------------------------------------------------------------
*/
-- ROWSTORE INDEX (19:06:00):
--	Stores the data row by row
--	Decent speed in reading and writing too
--	Less efficient in storage
--	Best for OLTP (Transactional) systems [commerce, banking, financial, order processing]
--	USE-CASE: High-frequency transaction applications | Quick access to complete records

-- COLUMNSTORE INDEX (19:06:15):
--	Stores the data column by column
--	Faster reading, but slower writing performance
--	Highly efficient with compression
--	Best for: OLAP (Analytical) [Data Warehouse, Business Intelligence, Reporting, Analytics]
--	USE-CASE: Big Data Analytics | Scanning of large datasets | Fast aggregation



-- ROW STORE INDEX vs COLUMN STORE INDEX (19:13:30 | 19:17:50 - Summary)

/*
            ==============================
					COLUMNSTORE INDEX
					(19:20:20)
			==============================
*/
-- No need to specify the column1, column2, ... [names], because every column is included automatially,
-- BUT If you already have a CLUSTERED INDEX (PK), you have to insert the column(s).
-- CREATE [CLUSTERED | NONCLUSTERED] COLUMNSTORE INDEX <index_name> ON <table_name>  [(column1, column2, ...)]

DROP INDEX IF EXISTS idx_DBCustomers_CustomerID ON Sales.DBCUstomers;
GO

CREATE CLUSTERED COLUMNSTORE INDEX idx_DBCustomers_CS ON Sales.DBCustomers;
GO

DROP INDEX idx_DBCustomers_CustomerID ON Sales.DBCUstomers;
GO


-- Only allowed 1 CLOUMNSTORE INDEX on 1 table
-- This will throw error:
CREATE NONCLUSTERED COLUMNSTORE INDEX idx_DBCustomers_CS_FirstName ON Sales.DBCustomers(FirstName);
GO

-- Lets drop "idx_DBCustomers_CS" to see the previous one.
DROP INDEX idx_DBCustomers_CS ON Sales.DBCUstomers;
GO

-- Starts from 19:22:00
USE AdventureWorksDW2022;
GO

-- HEAP
SELECT *
INTO FactInternetSales_HP
FROM AdventureWorksDW2022.dbo.FactInternetSales;
GO

-- ROWSTORE INDEX
SELECT *
INTO FactInternetSales_RS
FROM AdventureWorksDW2022.dbo.FactInternetSales;
GO

CREATE CLUSTERED INDEX idx_FactInternetSales_RS_PK
ON FactInternetSales_RS(SalesOrderNumber, SalesOrderLineNumber);
GO

-- COLUMNSTORE INDEX
SELECT *
INTO FactInternetSales_CS
FROM AdventureWorksDW2022.dbo.FactInternetSales;
GO

CREATE CLUSTERED COLUMNSTORE INDEX idx_FactInternetSales_CS_PK
ON FactInternetSales_CS;
GO

-- <<<<< Storage Efficiency >>>>>
--   1. Columnstore index
--   2. Heap table
--   3. Rowstore clustered index

/*
            ==============================
					ROWSTORE INDEX
					(19:20:20)
			==============================
*/
-- There is no keyword for Rowstore index, so just leave it empty. And this is the DEFAULT
-- CREATE [CLUSTERED | NONCLUSTERED] [empty] INDEX <index_name> ON <table_name>(column1, column2, ...)


/*
            -----------------------------------------------------------------------------------------------
													FUNCTIONS
													(19:31:10)
			-----------------------------------------------------------------------------------------------
*/

/*
            ==============================
					UNIQUE INDEX
					(19:31:10)
			==============================
*/
-- Ensures no duplicate values exist in specific column.
-- Benefits:
--		1. Enforce uniqueness
--		2. Slightly increase query performance
--		3. Duplicates in the column(s) will prevent creating a unique index (It is good to check if there are duplicates)

-- But:
-- Writing to a unique index is slower than non-unique.
-- Reading from a unique index is faster than non-unique.
-- Bc we are adding one more task to the clustered index (table), and is slows down writing, but fasten reading.

-- CREATE [UNIQUE] [CLUSTERED | NONCLUSTERED] [COLUMNSTORE] INDEX <index_name> ON <table_name>(column1, column2, ...)
-- Example:
-- Duplicates: CREATE INDEX idx_Customers_Email ON Customers(Email)
-- NO Duplicates: CREATE UNIQUE INDEX idx_Customers_Email ON Customers(Email)

USE SalesDB;
GO

SELECT *
FROM Sales.Products;
GO

-- Duplicates in the column(s) will prevent creating a unique index (It is good to check if there are duplicates)
CREATE UNIQUE NONCLUSTERED INDEX idx_Products_Category
ON Sales.Products(Category);
GO

-- We can do it for the Category column, bc there are no duplicates init.
CREATE UNIQUE NONCLUSTERED INDEX idx_Products_Product
ON Sales.Products(Product);
GO

-- CHECK if we insert a same value that is already in.
-- Throws error: "Cannot insert duplicate key row in object 'Sales.Products' with unique index 'idx_Products_Product'. The duplicate key value is (Caps)."
INSERT INTO Sales.Products(ProductID, Product)
VALUES (106, 'Caps');
GO

/*
            ==============================
					FILTERED INDEX
					(19:36:45)
			==============================
*/
-- An index that includes only rows meeting the specified conditions.
-- Benefit:
--	1. Targeted optimization
--	2. Reduce storage: Less data in the index

-- Rules:
--	1. You can NOT create a filtered index on a CLUSTERED INDEX
--	2. You can NOT create a filtered index on a COLUMNSTORE INDEX

--								   empty = ROWSTORE -> line: 313
-- CREATE [UNIQUE] [NONCLUSTERED] [empty] INDEX <index_name> ON <table_name>(column1, column2, ...)
-- WHERE [Condition]

SELECT *
FROM Sales.Customers AS sc
WHERE sc.Country = 'USA';
GO

-- TO fasten the search condition 'USA' for this Customers (Country) table, if we need to search only for 'USA'
-- each time. So this Index is targeting only a subset of data (USA).
CREATE NONCLUSTERED INDEX idx_Customers_Country
ON Sales.Customers (Country)
WHERE Country = 'USA';
GO

-- So here the INDEX is going to be used, and fasten the search:
SELECT *
FROM Sales.Customers AS sc
WHERE sc.Country = 'USA';
GO

-- But here it does NOTHING, so it is slower:
SELECT *
FROM Sales.Customers AS sc
WHERE sc.Country = 'Germany';
GO

/*
            -----------------------------------------------------------------------------------------------
													Choose the right index
													(19:42:25)
			-----------------------------------------------------------------------------------------------
*/

-- HEAP: Table without any index
--	1. Fast INSERTS (For staging tables = Insert data fast, then get rid of it later)

-- CLUSTERED (ROWSTORE) INDEX: OLTP systems
--	1. For PRIMARY KEYS (If not, then for DATE columns)
--	2. If you create PK, then SQL Server will automatically create CLUSTERED INDEX for the column

-- NONCLUSTERED INDEX:
--	1. For non-PK columns (Foreign keys, joins, filters)

-- COLUMNSTORE INDEX: OLAP systems
--	1. For ANALYTICAL queries
--  2. Reduce size of large table

-- FILTERED INDEX:
--	1. Target SUBSET of data
--	2. Reduce size of index

-- UNIQUE INDEX:
--	1. Enforce UNIQUENESS
--	2. Improve query speed


/*
            -----------------------------------------------------------------------------------------------
											Index Management & Monitoring
													(19:45:55)
			-----------------------------------------------------------------------------------------------
*/

-- <<<<< #1 Monitor Index Usage (19:45:55) >>>>>
-- Over the time, are we really using the indexes that we have created?
-- Are they really helping to improve the speed of queires?
-- Was it just a good idea at the begining but lost the importance at the end?

-- PRO TIP: 90% of indexes are totally untouched, so the first thing in a database is to check them.
--			If the team finds it useless, just drop it.
--			1. Saves storage
--			2. Optimize performance

-- List all indexes on a specific table
sp_helpindex 'Sales.DBCustomers';
GO

-- How to monitor index usage?
SELECT 
	tbl.name			AS TableName,
	idx.object_id		AS ObjectID,
	idx.name			AS IndexName,
	idx.type_desc		AS IndexType,
	idx.is_primary_key	AS IsPrimaryKey,
	idx.is_unique		AS IsUnique,
	idx.is_disabled		AS IsDisabled,
	ius.user_seeks		AS UserSeeks,
	ius.user_scans		AS UserScans,
	ius.user_lookups	AS UserLookups,
	ius.user_updates	AS UserUpdates,
	COALESCE(ius.last_user_seek, ius.last_user_scan) AS LastUpdate -- Combined: 2 columns to give back the first non null value
FROM sys.indexes AS idx
JOIN sys.tables AS tbl
	ON idx.object_id = tbl.object_id
LEFT JOIN sys.dm_db_index_usage_stats AS ius
	ON idx.object_id = ius.object_id
ORDER BY tbl.name, idx.name;
GO

SELECT *
FROM sys.tables;
GO

-- To monitor usage, use DMV (Dynamic Management View):
SELECT *
FROM sys.dm_db_index_usage_stats;
GO

SELECT *
FROM Sales.Employees;
GO


-- <<<<< #2 Monitor Missing Index (19:59:40) >>>>>
-- You can get recommendations by the database of missing indexes.
USE AdventureWorksDW2022;
GO

SELECT
	fs.SalesOrderNumber,
	dp.EnglishProductName,
	dp.Color
FROM AdventureWorksDW2022.dbo.FactInternetSales AS fs
INNER JOIN AdventureWorksDW2022.dbo.DimProduct AS dp
	ON fs.ProductKey = dp.ProductKey
WHERE	dp.Color = 'Black' AND
		fs.OrderDateKey BEtWEEN 20101229 AND 20101231;
GO

SELECT *
FROM sys.dm_db_missing_index_details;
GO


-- <<<<< #2 Monitor Duplicate Indexes (20:02:55) >>>>>
SELECT	
	tbl.name		AS TableName,
	col.name		AS IndexColumn,
	idx.name		AS IndexName,
	idx.type_desc	AS IndexType,
	COUNT(*) OVER (PARTITION BY tbl.name, col.name) AS ColumnCount
FROM sys.indexes AS idx
INNER JOIN sys.tables AS tbl
	ON idx.object_id = tbl.object_id
INNER JOIN sys.index_columns AS ic
	ON idx.object_id = ic.object_id 
	AND idx.index_id = ic.index_id
INNER JOIN sys.columns	AS col
	ON ic.object_id = col.object_id 
	AND ic.column_id = col.column_id
ORDER BY ColumnCount DESC;
GO


-- <<<<< #3 Update statistics (20:06:05) >>>>>
-- The DB engine usually uses statistics, in order to understand which index should be used for our query.

-- Find if the statistics are up-to-date or outdated.
USE SalesDB;
GO

SELECT
	SCHEMA_NAME(t.schema_id) AS SchemaName,
	t.name AS TableName,
	s.name AS StatisticsName,
	sp.last_updated AS LastUpdate,
	DATEDIFF(day, sp.last_updated, GETDATE()) AS LastUpdateDay,
	sp.rows AS 'Rows',
	sp.modification_counter AS ModificationsScinceLastUpdate
FROM sys.stats AS s
INNER JOIN sys.tables AS t
	ON s.object_id = t.object_id
CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) AS sp
ORDER BY sp.modification_counter DESC;
GO
--									<StatisticsName>
UPDATE STATISTICS Sales.DBCustomers _WA_Sys_00000001_05D8E0BE;
GO

-- Update all statistics, that belongs to this table (DBCustomers)
UPDATE STATISTICS Sales.DBCustomers;
GO

-- Update statistics of the whole DB (It can take a while)
-- EXEC sp_updatestats;
-- GO

-- USE CASES:
-- 1. Weekly job to update statistics on weekends
-- 2. After migrating data


-- <<<<< #4 Monitoring fragmentations (20:14:25) >>>>>
-- Fragmentation:
-- There are unused spaces in you DB and it does not using that, so you need to clean up, to use them again.
-- Unused data in data pages.
-- Data pages are out of order.

-- Fragmentation Methods:
--	1. Reorganize:	Defragments lead nodes to keep them sorted
--					'Light' operation
--	2. Rebuild:		Recreates index from scratch
--					'Heavy' operation


-- Important: avg_fragmentation_in_percent

-- avg_fragmentation_in_percent:
--	Indicate how out-of-order pages are within the index
--	0% means NO fragmentation (= perfect)
--	100% means index is completely fragmented (= out of order)
SELECT 
*
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED');
GO

SELECT
	tbl.name AS TableName,
	idx.name AS IndexName,
	s.avg_fragmentation_in_percent,
	s.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') AS s
INNER JOIN sys.tables AS tbl
	ON s.object_id = tbl.object_id
INNER JOIN sys.indexes AS idx
	ON idx.object_id = s.object_id
	AND idx.index_id = s.index_id
ORDER BY s.avg_fragmentation_in_percent DESC;
GO

-- USE-CASE: https://www.beyondtrust.com/docs/privileged-identity/faqs/reorganize-and-rebuild-indexes-in-database.htm
			 https://learn.microsoft.com/en-us/sql/relational-databases/indexes/reorganize-and-rebuild-indexes?view=sql-server-ver16
-- When to defragment?
--		<10% No action needed
--		10-30% Reorganize
--		>30% Rebuild

-- Reorganize INDEX: 
ALTER INDEX idx_DBCustomers_CS_FirstName ON Sales.DBCustomers REORGANIZE;
GO

-- Rebuild INDEX:
ALTER INDEX idx_DBCustomers_CountryScore ON Sales.DBCustomers REBUILD;
GO

-- Just some searching:
SELECT *
FROM sys.key_constraints;
GO

SELECT *
FROM sys.tables as st
INNER JOIN sys.key_constraints AS skc
	ON st.object_id = skc.parent_object_id
WHERE skc.name = 'PK_orders';
GO