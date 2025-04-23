/*
            -----------------------------------------------------------------------------------------------
			        DOC: 07_Row_Level_Functions.pdf
					CONNECTION: SalesBD

                                           SQL NULL Functions
										      (07:00:00)

					This script highlights essential SQL functions for managing NULL values.
					It demonstrates how to handle NULLs in data aggregation, mathematical operations,
					sorting, and comparisons. These techniques help maintain data integrity 
					and ensure accurate query results.

					Table of Contents:
						1. Handle NULL - Data Aggregation
						2. Handle NULL - Mathematical Operators
						3. Handle NULL before Sorting Data
						4. NULLIF - Division by Zero
						5. IS NULL - IS NOT NULL
						6. LEFT ANTI JOIN
						7. NULLs vs Empty String vs Blank Spaces
			-----------------------------------------------------------------------------------------------
*/

USE SalesDB;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                    ISNULL()
											  (07:01:55)
			-----------------------------------------------------------------------------------------------
*/
-- Replaces 'NULL' with a specified value.

/*
            -----------------------------------------------------------------------------------------------
			                                   COALESCE()
											  (07:06:21)
			-----------------------------------------------------------------------------------------------
*/
-- Returns the first non-null value of a list.

/*
            -----------------------------------------------------------------------------------------------
			                                   ISNULL() vs COALESCE()
													(07:11:53)
			-----------------------------------------------------------------------------------------------
*/

/*
            -----------------------------------------------------------------------------------------------
			                                   Handle NULL - Data Aggregation
													(07:13:20)
			-----------------------------------------------------------------------------------------------
*/

-- Find the average scores of the customers.
--- Uses COALESCE to replace NULL Score with 0.

SELECT
	sc.CustomerID,
	sc.Score,
	COALESCE(sc.Score, 0) AS Score2,
	AVG(sc.Score) OVER () AS AvgScores,
	AVG(COALESCE(sc.Score, 0)) OVER() AS AvgScores2
FROM Sales.Customers AS sc;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                   Handle NULL - Mathematical Operators
													(07:16:58)
			-----------------------------------------------------------------------------------------------
*/

-- Display the full name of customers in a single field by merging their
-- first and last names, and add 10 bonus points to each customer's score.

SELECT
	sc.CustomerID,
	sc.FirstName,
	sc.LastName,
	COALESCE(sc.LastName, '') AS LastNameCorr,
	sc.FirstName + ' ' + COALESCE(sc.LastName, '') AS FullName,
	sc.Score,
	COALESCE(sc.Score, 0) + 10 AS ScoreWithBonus
FROM Sales.Customers AS sc;
GO

/*
            -----------------------------------------------------------------------------------------------
													  HANDLE NULL before JOINS !!! IMPORTANT PART !!!
													(07:23:15 - 07:30:10)
			-----------------------------------------------------------------------------------------------
*/
-- Handle the NULL before JOINING tables (ISNULL | COALESCE USE CASE)
--SELECT
--	a.year, a.type, a.orders, b.sales
--FROM Table1 a
--JOIN Table2 b
--ON ABS.year = a.year = b.year 
--	AND ISNULL(a.type, '') = ISNULL (b.type, '');
--GO

/*
            -----------------------------------------------------------------------------------------------
												HANDLE NULL before SORTING DATA
													(07:30:15)
			-----------------------------------------------------------------------------------------------
*/

-- Sort the customers from lowest to highest scores, with NULL values appearing last.
SELECT
sc.CustomerID,
sc.Score
FROM Sales.Customers AS sc
ORDER BY sc.Score;
GO

-- <<<<< #1 Method >>>>>
-- Replace the NULLs with very big number.
SELECT
sc.CustomerID,
sc.Score,
COALESCE(sc.Score, 999999)
FROM Sales.Customers AS sc
ORDER BY COALESCE(sc.Score, 999999);
GO

-- <<<<< #2 Method >>>>>
-- Replace the NULLs with 1 and 0, then Order by.
SELECT
sc.CustomerID,
sc.Score
--CASE
--	WHEN sc.Score IS NULL THEN 1 ELSE 0 
--END AS Flag
FROM Sales.Customers AS sc
ORDER BY 
	CASE
		WHEN sc.Score IS NULL THEN 1 ELSE 0 
	END, 
	sc.Score;
GO

/*
            -----------------------------------------------------------------------------------------------
														NULLIF
													(07:35:50 - 07:39:35)
			-----------------------------------------------------------------------------------------------
*/
-- Compares 2 expressions returns:
-- - NULL, if they are equal
-- - First value, if they are not equal

/*
            -----------------------------------------------------------------------------------------------
													NULLIF - DIVISION BY ZERO
													(07:39:39)
			-----------------------------------------------------------------------------------------------
*/
-- Preventing the error of dividing by zero.

-- Find the sales price for each order by dividing sales by quantity.
-- Uses NULLIF to avoid division by zero.
SELECT
	so.OrderID,
	so.Sales,
	so.Quantity,
	so.Sales / NULLIF(so.Quantity, 0) AS Price
FROM Sales.Orders AS so;
GO

/*
            -----------------------------------------------------------------------------------------------
												IS NULL | IS NOT NULL
													(07:41:44)
			-----------------------------------------------------------------------------------------------
*/
-- IS NULL: Returns TRUE if the value IS NULL, otherwise it returns FALSE.
-- IS NOT NULL: Returns TRUE if the value IS NOT NULL, otherwise it returns FALSE.

-- Identify the customers who have no scores.
SELECT *
FROM Sales.Customers AS sc
WHERE sc.Score IS NULL;
GO

-- Identify the customers who have scores
SELECT *
FROM Sales.Customers AS sc
WHERE sc.Score IS NOT NULL;
GO

/*
            -----------------------------------------------------------------------------------------------
											(LEFT | RIGHT) ANTI JOINs
													(07:45:30)
			-----------------------------------------------------------------------------------------------
*/
-- Finding the unmatched rows between two tables.
-- LEFT ANTI JOIN: All rows from the left table without matches in the right table.

-- List all details for customers who have NOT placed any orders.
SELECT 
	sc.*,
	so.OrderID
FROM Sales.Customers AS sc
LEFT JOIN Sales.Orders AS so
ON sc.CustomerID = so.CustomerID
WHERE so.OrderID IS NULL; -- Better to use the OrderID, than CustomerID. More clear to see which is the NULL
GO

/*
            -----------------------------------------------------------------------------------------------
											NULLs vs EMPTY STRING vs BLANK SPACES
													(07:51:26)
			-----------------------------------------------------------------------------------------------
*/
-- NULL: Means nothing, unknown. "I do not know the value."
-- EMPTY STRING: String value has zero characters. "I know the value, it is nothing."
-- BLANK SPACES: String values has 1 or more space characters. "How many spaces you have entered."

-- Demonstrate differences between NULL, empty strings, and blank spaces
WITH Orders AS (
	SELECT 1 AS ID, 'A' AS Category
		UNION
	SELECT 2, NULL
		UNION
	SELECT 3, ''
		UNION
	SELECT 4, '  '
)
SELECT 
	*,
	DATALENGTH(Category) AS CategoryLen
FROM Orders;
GO

/*
            -----------------------------------------------------------------------------------------------
													DATA POLICIES
													(07:57:30)
			-----------------------------------------------------------------------------------------------
*/
-- Set of rules that defines how data should be handled.

-- <<<<< #1 Data policy | TRIM >>>>>
-- Only use NULLS and EMPTY STRINGS, but avoid BLANK SPACES. 

-- Demonstrate differences between NULL, empty strings, and blank spaces
WITH Orders AS (
	SELECT 1 AS ID, 'A' AS Category
		UNION
	SELECT 2, NULL
		UNION
	SELECT 3, ''
		UNION
	SELECT 4, '  '
)
SELECT 
	*,
	DATALENGTH(Category) AS CategoryLen,
	TRIM(Category) AS Policy1,
	DATALENGTH(TRIM(Category)) AS CategoryLenTrim
FROM Orders;
GO

-- <<<<< #2 Data policy >>>>>
-- Only use NULLS and AVOID using EMPTY STRINGS and BLANK SPACES.
WITH Orders2 AS (
	SELECT 1 AS ID, 'A' AS Category
		UNION
	SELECT 2, NULL
		UNION
	SELECT 3, ''
		UNION
	SELECT 4, '  '
)
SELECT 
	*,
	DATALENGTH(Category) AS CategoryLen,
	TRIM(Category) AS Policy1,
	NULLIF(TRIM(Category), '') AS Policy2
FROM Orders2;
GO

-- <<<<< #3 Data policy >>>>>
-- Use the DEFAULT VALUE 'unkown' and AVOID using NULLS, EMPTY STRINGS and BLANK SPACES.
WITH Orders3 AS (
	SELECT 1 AS ID, 'A' AS Category
		UNION
	SELECT 2, NULL
		UNION
	SELECT 3, ''
		UNION
	SELECT 4, '  '
)
SELECT 
	*,
	DATALENGTH(Category) AS CategoryLen,
	TRIM(Category) AS Policy1,
	NULLIF(TRIM(Category), '') AS Policy2,
	COALESCE(NULLIF(TRIM(Category), ''), 'unkown') AS Policy3
FROM Orders3;
GO

-- <<<<< SUM of policies >>>>>
/*
	#1 Data Policy USE CASE: DO NOT USE!!! USELESS

	#2 Data Policy USE CASE: 
	Replacing empty strings and blanks with NULL during data preparation 
	BEFORE inserting into database to optimize storage and performace.

	#3 Data Policy USE CASE:
	Replacing empty strings, blanks, NULLS with default value during data
	preparation BEFORE using it in REPORTING to improve readability and
	reduce confusion.
*/