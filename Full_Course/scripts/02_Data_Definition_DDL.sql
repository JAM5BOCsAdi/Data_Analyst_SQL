/*
            -----------------------------------------------------------------------------------------------
						DOC: 03_Data_Definition_DDL.pdf
						CONNECTION: MyDatabase

										SQL Data Definition Language (DDL)
													(01:32:31)

						This guide covers the essential DDL commands used for defining and managing
						database structures, including creating, modifying, and deleting tables.

						Table of Contents:
							1. CREATE - Creating Tables
							2. ALTER - Modifying Table Structure
							3. DROP - Removing Tables
			-----------------------------------------------------------------------------------------------
*/

USE MyDatabase;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                         CREATE
			-----------------------------------------------------------------------------------------------
*/

-- Create a new table called persons with columns: id, person_name, birth_date, and phone
CREATE TABLE persons(
	id INT NOT NULL,
	person_name VARCHAR(50) NOT NULL,
	birth_date DATE,
	phone VARCHAR(15) NOT NULL,
	CONSTRAINT pk_persons PRIMARY KEY (id)
);
GO

SELECT *
FROM persons;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                         ALTER
			-----------------------------------------------------------------------------------------------
*/

-- Add a new column called email to the persons table
ALTER TABLE persons
ADD email VARCHAR(50) NOT NULL;
GO

SELECT *
FROM persons;
GO

-- Remove the column phone from the persons table
ALTER TABLE persons
DROP COLUMN phone;
GO

SELECT *
FROM persons;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                         DROP
			-----------------------------------------------------------------------------------------------
*/

-- Delete the table persons from the database
DROP TABLE persons;
GO