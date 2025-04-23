/*
            -----------------------------------------------------------------------------------------------
							DOC: 02_Query_Data_SELECT.pdf
							CONNECTION: MyDatabase

													SQL SELECT Query
														(34:01)

							This guide covers various SELECT query techniques used for retrieving, 
							filtering, sorting, and aggregating data efficiently.

							Table of Contents:
								1. SELECT ALL COLUMNS
								2. SELECT SPECIFIC COLUMNS
								3. WHERE CLAUSE
								4. ORDER BY
								5. GROUP BY
								6. HAVING
								7. DISTINCT
								8. TOP
								9. COOL STUFF - Additional SQL Features
								10. Combining Queries
			-----------------------------------------------------------------------------------------------
*/

-- 1 line comment

/* 
	Multi-line comment
*/

USE MyDatabase;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                         SELECT
			-----------------------------------------------------------------------------------------------
*/

-- Retrieve All Customer Data
SELECT *
FROM customers;
GO

-- Retrieve All Order Data
SELECT *
FROM orders;
GO

-- Retrieve each customer's name, country, and score
SELECT
	first_name,
	country,
	score
FROM customers;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                         WHERE
			-----------------------------------------------------------------------------------------------
*/

-- Retrieve customers with a score not equal to 0
SELECT *
FROM customers
WHERE score != 0;
GO

-- Retrieve customers from Germany
SELECT 
	first_name,
	country
FROM customers
WHERE country = 'Germany';
GO

/*
            -----------------------------------------------------------------------------------------------
			                                         ORDER BY
			-----------------------------------------------------------------------------------------------
*/

-- Retrieve all customers and sort the results by the highest score first
SELECT *
FROM customers
ORDER BY score DESC;
GO

-- Retrieve all customers and sort the results by the lowest score first
SELECT *
FROM customers
ORDER BY score ASC;
GO

-- Retrieve all customers and sort the results by the country and then by the highest score.
SELECT *
FROM customers
ORDER BY 
	country ASC,
	score DESC;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                         GROUP BY
			-----------------------------------------------------------------------------------------------
*/

-- Find the total score for each country
SELECT
	country,
	SUM(score) AS total_score
FROM customers
GROUP BY country;
GO

-- This will not work because 'first_name' is neither part of the GROUP BY 
-- nor wrapped in an aggregate function. SQL doesn't know how to handle this column.

-- WRONG:
SELECT 
    country,
    first_name,
    SUM(score) AS total_score
FROM customers
GROUP BY country;
GO

-- GOOD:
SELECT 
    country,
    first_name,
    SUM(score) AS total_score
FROM customers
GROUP BY country, first_name;
GO

-- Find the total score and total number of customers for each country
SELECT
	country,
	SUM(score) AS total_score,
	COUNT(id) AS total_customers
FROM customers
GROUP BY country;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                         HAVING
			-----------------------------------------------------------------------------------------------
*/

-- Find the average score for each country
-- considering only customers with a score not equal to 0
-- and return only those countries with an average score greater than 430

SELECT
	country,
	AVG(score) AS avg_acore
FROM customers
WHERE score != 0
GROUP BY country
HAVING AVG(score) > 430;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                         DISTINCT
			-----------------------------------------------------------------------------------------------
*/

-- Return Unique list of all countries
SELECT DISTINCT country
FROM customers;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                         TOP
			-----------------------------------------------------------------------------------------------
*/

-- Retrieve only 3 Customers
SELECT TOP 3 *
FROM customers;
GO

-- Retrieve the Top 3 Customers with the Highest Scores
SELECT TOP 3 *
FROM customers
ORDER BY score DESC;
GO

-- Retrieve the Lowest 2 Customers based on the score
SELECT TOP 2 *
FROM customers
ORDER BY score ASC;
GO

-- Get the Two Most Recent Orders
SELECT TOP 2 *
FROM orders
ORDER BY order_date DESC;
GO



/*
            -----------------------------------------------------------------------------------------------
			                               COOL STUFF - Additional SQL Features
			-----------------------------------------------------------------------------------------------
*/

-- Execute multiple queries at once
SELECT * 
FROM customers;
GO

SELECT * 
FROM orders;
GO

-- Selecting Static Data: Select a static or constant value without accessing any table
SELECT 123 AS static_number;
GO

SELECT 'Hello' AS static_string;
GO

-- Assign a constant value to a column in a query
SELECT
    id,
    first_name,
    'New Customer' AS customer_type
FROM customers;
GO

-- Higlight and Execute
SELECT *
FROM customers
WHERE country = 'Germany';
GO

/*
            -----------------------------------------------------------------------------------------------
			                                         COMBINE ALL TOGETHER
			-----------------------------------------------------------------------------------------------
*/

-- Calculate the average score for each country 
-- considering only customers with a score not equal to 0
-- and return only those countries with an average score greater than 430
-- and sort the results by the highest average score first.

SELECT
    country,
    AVG(score) AS avg_score
FROM customers
WHERE score != 0
GROUP BY country
HAVING AVG(score) > 430
ORDER BY AVG(score) DESC