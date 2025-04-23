/*
            -----------------------------------------------------------------------------------------------
			        DOC: 04_Data_Manipulation_DML.pdf
					CONNECTION: MyDatabase

                                           SQL Data Manipulation Language (DML)
														(01:43:44)

					This guide covers the essential DML commands used for inserting, updating, 
					and deleting data in database tables.

					Table of Contents:
					1. INSERT - Adding Data to Tables
					2. UPDATE - Modifying Existing Data
					3. DELETE - Removing Data from Tables
			-----------------------------------------------------------------------------------------------
*/

USE MyDatabase;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                         INSERT
			-----------------------------------------------------------------------------------------------
*/

-- <<<<< #1 Method: Manual INSERT using VALUES >>>>>

-- Insert new records into the customers table
INSERT INTO customers (id, first_name, country, score)
VALUES 
    (6, 'Anna', 'USA', NULL),
    (7, 'Sam', NULL, 100);
GO

SELECT *
FROM customers;
GO

-- Incorrect column order 
INSERT INTO customers (id, first_name, country, score)
VALUES 
    (8, 'Max', 'USA', NULL);
GO

-- Incorrect data type in values
INSERT INTO customers (id, first_name, country, score)
VALUES 
	('Max', 9, 'Max', NULL);
GO

-- Insert a new record without specifying column names (not recommended)
INSERT INTO customers 
VALUES 
    (9, 'Andreas', 'Germany', NULL);
GO

-- Insert a record with only id and first_name (other columns will be NULL or default values)
INSERT INTO customers (id, first_name)
VALUES 
    (10, 'Sahra');
GO

-- <<<<< #2 Method: INSERT DATA USING SELECT - Moving Data From One Table to Another >>>>>

-- Create again a new table called persons with columns: id, person_name, birth_date, and phone
CREATE TABLE persons(
	id INT NOT NULL,
	person_name VARCHAR(50) NOT NULL,
	birth_date DATE,
	phone VARCHAR(15) NOT NULL,
	CONSTRAINT pk_persons PRIMARY KEY (id)
);
GO

-- Copy data from the 'customers' table into 'persons'
INSERT INTO persons (id, person_name, birth_date, phone)
SELECT
    id,
    first_name,
    NULL,
    'Unknown'
FROM customers;
GO

SELECT *
FROM persons;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                         UPDATE
			-----------------------------------------------------------------------------------------------
*/

-- Change the score of customer with ID 6 to 0
UPDATE customers
SET score = 0
WHERE id = 6;
GO

SELECT *
FROM customers
WHERE id = 6;
GO

SELECT *
FROM customers;
GO

-- Change the score of customer with ID 10 to 0 and update the country to 'UK'
UPDATE customers
SET score = 0,
    country = 'UK'
WHERE id = 10;
GO

-- Update all customers with a NULL score by setting their score to 0
UPDATE customers
SET score = 0
WHERE score IS NULL;
GO

-- Verify the update
SELECT *
FROM customers
WHERE score IS NULL;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                         DELETE
			-----------------------------------------------------------------------------------------------
*/

-- Select customers with an ID greater than 5 before deleting
SELECT *
FROM customers
WHERE id > 5;
GO

-- Delete all customers with an ID greater than 5
DELETE FROM customers
WHERE id > 5;
GO

-- Delete all data from the persons table
DELETE FROM persons;

-- Faster method to delete all rows, especially useful for large tables.
-- Clears the whole table at once without checking or logging.
TRUNCATE TABLE persons;