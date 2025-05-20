/*
            -----------------------------------------------------------------------------------------------
			        DOC: 04_Filtering_Data.pdf
					CONNECTION: MyDatabase

                                           SQL Filtering Data
										      (02:08:00)
					This document provides an overview of SQL filtering techniques using WHERE 
					and various operators for precise data retrieval.

					Table of Contents:
						1. Comparison Operators
							- =, <>, >, >=, <, <=
						2. Logical Operators
							- AND, OR, NOT
						3. Range Filtering
							- BETWEEN
						4. Set Filtering
							- IN
						5. Pattern Matching
							- LIKE
			-----------------------------------------------------------------------------------------------
*/

USE MyDatabase;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                         COMPARISON OPERATORS
			-----------------------------------------------------------------------------------------------
*/

-- Retrieve all customers from Germany.
SELECT *
FROM customers
WHERE country = 'Germany';
GO

-- Retrieve all customers who are not from Germany.
SELECT *
FROM customers
WHERE country <> 'Germany';
GO

-- Retrieve all customers with a score greater than 500.
SELECT *
FROM customers
WHERE score > 500;
GO

-- Retrieve all customers with a score of 500 or more.
SELECT *
FROM customers
WHERE score >= 500;
GO

-- Retrieve all customers with a score less than 500.
SELECT *
FROM customers
WHERE score < 500;
GO

-- Retrieve all customers with a score of 500 or less.
SELECT *
FROM customers
WHERE score <= 500;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                         LOGICAL OPERATORS
			-----------------------------------------------------------------------------------------------
*/

-- Combining conditions using AND, OR, and NOT [Logical opearator]

-- Retrieve all customers who are from the USA and have a score greater than 500.
SELECT *
FROM customers
WHERE country = 'USA' AND score > 500;
GO

-- Retrieve all customers who are either from the USA or have a score greater than 500.
SELECT *
FROM customers
WHERE country = 'USA' OR score > 500;
GO

-- Retrieve all customers with a score not less than 500.
SELECT *
FROM customers
WHERE NOT score < 500;
GO

/*
            -----------------------------------------------------------------------------------------------
			                            RANGE OPERATORS [RANGE FILTERING - BETWEEN]
			-----------------------------------------------------------------------------------------------
*/

-- Retrieve all customers whose score falls in the range between 100 and 500.
SELECT *
FROM customers
WHERE score BETWEEN 100 AND 500;
GO

-- Alternative method (Equivalent to BETWEEN)
SELECT *
FROM customers
WHERE score >= 100 AND score <= 500;
GO

/*
            -----------------------------------------------------------------------------------------------
			                            MEMBERSHIP OPERATORS [SET FILTERING - IN , NOT IN]
			-----------------------------------------------------------------------------------------------
*/

-- Use IN insted of OR for multiple values in the same column to simplify SQL

-- Retrieve all customers from either Germany or the USA.
SELECT *
FROM customers
WHERE country IN ('Germany', 'USA');
GO

-- Retrieve all customers not from Germany or the USA.
SELECT *
FROM customers
WHERE country NOT IN ('Germany', 'USA');
GO

/*
            -----------------------------------------------------------------------------------------------
			                            SEARCH OPERATORS [PATTERN MATCHING - LIKE]
			-----------------------------------------------------------------------------------------------
*/

-- Find all customers whose first name starts with 'M'.
SELECT *
FROM customers
WHERE first_name LIKE 'M%';
GO

-- Find all customers whose first name ends with 'n'.
SELECT *
FROM customers
WHERE first_name LIKE '%n';
GO

-- Find all customers whose first name contains 'r'.
SELECT *
FROM customers
WHERE first_name LIKE '%r%';
GO

-- Find all customers whose first name has 'r' in the third position.
SELECT *
FROM customers
WHERE first_name LIKE '__r%';
GO