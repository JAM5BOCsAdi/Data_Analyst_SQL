/*
            -----------------------------------------------------------------------------------------------
			        DOC: 05_JOINS_and_SET.pdf
					CONNECTION: MyDatabase, SalesDB

											  SQL JOINs
										      (02:47:57)

					This document provides an overview of SQL joins, which allow combining data
					from multiple tables to retrieve meaningful insights.

					Table of Contents:
					1. Basic Joins
						- INNER JOIN
						- LEFT JOIN
						- RIGHT JOIN
						- FULL JOIN
					2. Advanced Joins
						- LEFT ANTI JOIN
						- RIGHT ANTI JOIN
						- ALTERNATIVE INNER JOIN
						- FULL ANTI JOIN
						- CROSS JOIN
					3. Multiple Table Joins (4 Tables)
			-----------------------------------------------------------------------------------------------
*/

USE MyDatabase;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                         BASIC JOINS
			-----------------------------------------------------------------------------------------------
*/

-- <<<<< NO JOIN >>>>>
-- Retrieve all data from customers and orders as separate results.
SELECT *
FROM customers;

SELECT *
FROM orders;
GO

SELECT *
FROM persons;
GO

-- <<<<< INNER JOIN >>>>>
-- Returns Only Matching Rows from Both tables

-- Get all customers along with their orders, but only for customers who have placed an order.
-- with AS
SELECT c.id, c.first_name, o.order_id, o.sales
FROM customers AS c
INNER JOIN orders AS o ON c.id = o.customer_id;
GO

-- without AS
SELECT c.id, c.first_name, o.order_id, o.sales
FROM customers c
INNER JOIN orders o ON c.id = o.customer_id;
GO

-- <<<<< LEFT JOIN >>>>>
-- Returns All Rows from Left and Only Matching from Right

-- Get all customers along with their orders, including those without orders
SELECT c.id, c.first_name, o.order_id, o.sales
FROM customers AS c
LEFT JOIN orders AS o ON c.id = o.customer_id;
GO

-- <<<<< RIGHT JOIN >>>>>
-- Returns All Rows from Right and Only Matching from Left

-- Get all customers along with their orders, including orders without matching customers
SELECT c.id, c.first_name, o.order_id, o.sales
FROM customers AS c
RIGHT JOIN orders AS o ON c.id = o.customer_id;
GO

-- Alternative to RIGHT JOIN using LEFT JOIN
-- Get all customers along with their orders, including orders without matching customers
SELECT c.id, c.first_name, o.order_id, o.sales
FROM orders AS o
LEFT JOIN customers AS c ON c.id = o.customer_id;
GO

-- <<<<< FULL JOIN >>>>>
-- Returns All Rows from Both tables

-- Get all customers and all orders, even if there’s no match
SELECT c.id, c.first_name, o.order_id, o.sales
FROM customers AS c
FULL JOIN orders AS o ON c.id = o.customer_id;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                         ADVANCED JOINS
			-----------------------------------------------------------------------------------------------
*/

-- <<<<< LEFT ANTI JOIN >>>>>
-- Returns Row from Left that has NO Match in Right

-- Get all customers who haven't placed any order
SELECT *
FROM customers AS c
LEFT JOIN orders AS o
ON c.id = o.customer_id
WHERE o.customer_id IS NULL;
GO

-- <<<<< RIGHT ANTI JOIN >>>>>
-- Returns Row from Right that has NO Match in Left

-- Get all orders without matching customers [0 Result]
SELECT *
FROM customers AS c
RIGHT JOIN orders AS o
ON c.id = o.customer_id
WHERE c.id IS NULL;
GO

-- Alternative to RIGHT ANTI JOIN using LEFT JOIN
-- Get all orders without matching customers [0 Result]
SELECT *
FROM orders AS o
LEFT JOIN customers AS c
ON c.id = o.customer_id
WHERE c.id IS NULL;
GO

-- <<<<< FULL ANTI JOIN >>>>>
-- Return Only Rows that DO NOT Match in either tables

-- Find customers without orders and orders without customers
SELECT *
FROM orders AS o
FULL JOIN customers AS c
ON c.id = o.customer_id
WHERE c.id IS NULL OR o.customer_id IS NULL;
GO

-- Get all customers along with their orders, but only for customers who have placed an order.
-- Without using INNER JOIN!!!
SELECT *
FROM customers AS c
LEFT JOIN orders AS o
ON c.id = o.customer_id
WHERE o.customer_id IS NOT NULL;
GO

-- <<<<< CROSS JOIN >>>>>
-- Combines Every Row from Left with Every Row from Right
-- All possible conbinations - Cartersian Join -

-- Generate all possible combinations of customers and orders
SELECT *
FROM customers
CROSS JOIN orders;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                         DECISION TREE
											How to choose which join to use
													  (03:47:10)
			-----------------------------------------------------------------------------------------------
*/

/*
            -----------------------------------------------------------------------------------------------
			                                         MULTI-TABLE JOIN
													  (03:48:48)
			-----------------------------------------------------------------------------------------------
*/

--Task: Using SalesDB, Retrieve a list of all orders, along with the related customer, product, 
--   and employee details. For each order, display:
--   - Order ID
--   - Customer's name
--   - Product name
--   - Sales amount
--   - Product price
--   - Salesperson's name

USE SalesDB;
GO

-- SalesDB:
-- so = Sales.Orders
-- sc = Sales.Customers
-- sp = Sales.Products
SELECT 
	so.OrderID,
	so.Sales,
	sc.FirstName AS CustomerFirstName,
	sc.LastName AS CustomerLastName,
	sp.Product AS ProductName,
	sp.Price,
	se.FirstName AS EmployeeFirstName,
	se.LastName AS EmployeeLastName
FROM Sales.Orders AS so
LEFT JOIN Sales.Customers AS sc
	ON so.CustomerID = sc.CustomerID
LEFT JOIN Sales.Products AS sp
	ON so.ProductID = sp.ProductID
LEFT JOIN Sales.Employees AS se
	ON so.SalesPersonID = se.EmployeeID;
GO

-- Exploring tables:
SELECT * FROM Sales.Customers;
SELECT * FROM Sales.Employees;
SELECT * FROM Sales.Orders;
SELECT * FROM Sales.OrdersArchive;
SELECT * FROM Sales.Products;