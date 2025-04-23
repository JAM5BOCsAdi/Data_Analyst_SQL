/*
            -----------------------------------------------------------------------------------------------
			        DOC: 07_Row_Level_Functions.pdf
					CONNECTION: SalesBD

                                           SQL String Functions
										      (04:47:40)

					This document provides an overview of SQL string functions, which allow 
					manipulation, transformation, and extraction of text data efficiently.

					Table of Contents:
					1. Manipulations
						- CONCAT
						- LOWER
						- UPPER
						- TRIM
						- REPLACE
					2. Calculation
						- LEN
					3. Substring Extraction
						- LEFT
						- RIGHT
						- SUBSTRING
			-----------------------------------------------------------------------------------------------
*/

USE SalesDB;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                   CONCAT() - String Concatenation
											  (04:53:00)
			-----------------------------------------------------------------------------------------------
*/

-- Concatenate first name and country into one column
SELECT 
	sc.FirstName,
	sc.Country,
	CONCAT(sc.FirstName, ' - ', sc.Country) AS FullInfo
FROM Sales.Customers AS sc;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                   LOWER() & UPPER() - Case Transformation
											       (04:57:30)
			-----------------------------------------------------------------------------------------------
*/

-- Convert the first name to lowercase
SELECT 
	LOWER(sc.FirstName) AS lower_first_name
FROM Sales.Customers AS sc;
GO

-- Convert the first name to uppercase
SELECT 
	UPPER(sc.FirstName) AS UPPER_FIRST_NAME
FROM Sales.Customers AS sc;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                   TRIM() - Remove White Spaces
											       (04:58:40)
			-----------------------------------------------------------------------------------------------
*/

-- Put a White Space in 'Kevin' for the TRIM() example
UPDATE Sales.Customers
SET FirstName = ' Kevin'
WHERE FirstName = 'Kevin';
GO

SELECT *
FROM Sales.Customers;
GO

-- Find customers whose first name contains leading or trailing spaces.

-- Check to see if there are differences:
SELECT 
	sc.FirstName,
	LEN(sc.FirstName) AS LenOfFirstName,
	LEN(TRIM(sc.FirstName)) AS TrimmedLenOfFirstName,
	LEN(sc.FirstName) - LEN(TRIM(sc.FirstName)) AS Flag
FROM Sales.Customers AS sc
-- WHERE FirstName != TRIM(FirstName);
GO

-- Solution: [There are no white spaces]
SELECT 
	sc.FirstName,
	LEN(sc.FirstName) AS LenOfFirstName,
	LEN(TRIM(sc.FirstName)) AS TrimmedLenOfFirstName,
	LEN(sc.FirstName) - LEN(TRIM(sc.FirstName)) AS Flag
FROM Sales.Customers AS sc
WHERE FirstName != TRIM(FirstName);
GO

/*
            -----------------------------------------------------------------------------------------------
			                                   REPLACE() - Replace or Remove old value with new one
											       (05:04:08)
			-----------------------------------------------------------------------------------------------
*/

-- Remove dashes (-) from a phone number.
SELECT
'123-456-7890' AS phone,
REPLACE('123-456-7890', '-', '/') AS clean_phone;
GO

-- Replace File Extence from txt to csv
SELECT
'report.txt' AS old_filename,
REPLACE('report.txt', '.txt', '.csv') AS new_filename;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                   LEN() - String Length & Trimming
											       (05:07:39)
			-----------------------------------------------------------------------------------------------
*/

-- Calculate the length of each customer's first name.
SELECT 
	sc.FirstName,
	LEN(sc.FirstName) AS LenOfFirstName
FROM Sales.Customers AS sc;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                   LEFT() & RIGHT() - Substring Extraction
											       (05:09:29)
			-----------------------------------------------------------------------------------------------
*/

-- Retrieve the first two characters of each first name.
SELECT 
	sc.FirstName,
	LEFT(TRIM(sc.FirstName), 2) AS first_2_chars
FROM Sales.Customers AS sc;
GO

-- Retrieve the last two characters of each first name.
SELECT 
	sc.FirstName,
	RIGHT(TRIM(sc.FirstName), 2) AS first_2_chars
FROM Sales.Customers AS sc;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                   SUBSTRING() - Extracting Substrings
											       (05:12:40)
			-----------------------------------------------------------------------------------------------
*/

-- Retrieve a list of customers' first names after removing the first character.
SELECT 
	sc.FirstName,
	SUBSTRING(TRIM(sc.FirstName), 2, LEN(sc.FirstName)) AS trimmed_name
FROM Sales.Customers AS sc;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                   NESTING FUNCTIONS
			-----------------------------------------------------------------------------------------------
*/

-- Nesting
SELECT
	sc.FirstName, 
	UPPER(LOWER(sc.FirstName)) AS nesting
FROM Sales.Customers AS sc;
GO