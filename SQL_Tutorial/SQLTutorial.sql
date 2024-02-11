-- Best written sources:
-- You can search on both sites
-- Official Documentation:
-- https://learn.microsoft.com/en-us/sql/sql-server/?view=sql-server-ver16
-- SQLShack: You can find Suggestions at the bottom of almost every page (and also can search)
-- https://www.sqlshack.com/learn-sql-dynamic-sql/

-- ***************************************************************
-- SQL Basics Tutorial For Beginners | Installing SQL Server Management Studio and CREATE TABLES 
-- ***************************************************************

-- 1. Step: Create tables
--CREATE TABLE EmployeeDemographics
--(
--EmployeeID int,
--FirstName varchar(50),
--LastName varchar(50),
--Age int,
--Gender varchar(50)
--);
--GO

--CREATE TABLE EmployeeSalary
--(
--EmployeeID int,
--JobTitle varchar(50),
--Salary int
--);
--GO

 --2. Step: Insert data into the tables
--INSERT INTO EmployeeDemographics VALUES 
--(1001, 'Jim', 'Halpert', 30, 'Male'),
--(1002, 'Pam', 'Beasley', 30, 'Female'),
--(1003, 'Dwight', 'Schrute', 29, 'Male'),
--(1004, 'Angela', 'Martin', 31, 'Female'),
--(1005, 'Toby', 'Flenderson', 32, 'Male'),
--(1006, 'Michael', 'Scott', 35, 'Male'),
--(1007, 'Meredith', 'Palmer', 32, 'Female'),
--(1008, 'Stanley', 'Hudson', 38, 'Male'),
--(1009, 'Kevin', 'Malone', 31, 'Male');
--GO

--INSERT INTO EmployeeSalary VALUES
--(1001, 'Salesman', 45000),
--(1002, 'Receptionist', 36000),
--(1003, 'Salesman', 63000),
--(1004, 'Accountant', 47000),
--(1005, 'HR', 50000),
--(1006, 'Regional Manager', 65000),
--(1007, 'Supplier Relations', 41000),
--(1008, 'Salesman', 48000),
--(1009, 'Accountant', 42000);
--GO

-- ***************************************************************
-- SQL Basics Tutorial For Beginners | SELECT + FROM Statements
-- ***************************************************************

-- 1. Step: SELECT + FROM
-- Select Everything from Database (*)
SELECT *
FROM EmployeeDemographics;

-- Select FirsName, LastName
SELECT FirstName, LastName
FROM EmployeeDemographics;

-- Select Top 5 from Database (*)
SELECT TOP 5 *
FROM EmployeeDemographics;

-- 2. Step: 
-- DISTINCT: We want unique values in a specific column
-- We want to know all the unique EmployeeID
SELECT DISTINCT(EmployeeID)
FROM EmployeeDemographics;

-- We want to know all the unique Gender 
-- -> Gives back only 2, because it has 2 main gender that are unique
-- It returns the very first unique value of Male and Female
SELECT DISTINCT(Gender)
FROM EmployeeDemographics;

-- 3. Step: 
-- COUNT: Gives back all the non-null values in a column
-- We want to know all the number of (count) LastName 
SELECT COUNT(LastName)
FROM EmployeeDemographics;

-- 4. Step: Previous + AS
-- AS: You can give a name for the newly created column(s)
SELECT COUNT(LastName) AS 'LastNameCount'
FROM EmployeeDemographics;

-- 5. Step: 
-- MAX: 
SELECT MAX(Salary) AS 'MaxSalary'
FROM EmployeeSalary;

-- 6. Step: 
-- MIN: 
SELECT MIN(Salary) AS 'MinSalary'
FROM EmployeeSalary;

-- 7. Step: 
-- AVG: 
SELECT AVG(Salary) AS 'AvgSalary'
FROM EmployeeSalary;

SELECT *
FROM EmployeeSalary;

-- 8. Step:
-- Change 'SQLTutorial' Available Database from Dropdown on the top left to 'master' 
-- You can see that there is no data (or there is an error) in tables
-- Solution:
-- We need to specify the Database and the table next to it (if you want)
SELECT *
FROM SQLTutorial.dbo.EmployeeSalary;
-- LESSONS LEARNED: If you do it this way, you do not need to change to that Available Database every time
-- It is more specific, more professional

-- SHORT FORM:
SELECT *
FROM SQLTutorial..EmployeeSalary;

-- 9. Step:
-- Just Change back to 'SQLTutorial'
SELECT *
FROM EmployeeSalary;

-- ***************************************************************
-- SQL Basics Tutorial For Beginners | WHERE Statement
-- ***************************************************************

-- 1. Step:
-- WHERE: Only 'Jim' [FirstName] is displayed
SELECT *
FROM EmployeeDemographics
WHERE FirstName = 'Jim';

-- 2. Step:
-- EQUALS ( = ):

-- 3. Step:
-- DOES NOT EQUAL ( <> ): Everybody in there, except 'Jim' [FirstName]
SELECT *
FROM EmployeeDemographics
WHERE FirstName <> 'Jim';

-- 4. Step:
-- GREATER / LESS THAN ( > , < ):
-- Select everyone over the age of 30 (>30)
SELECT *
FROM EmployeeDemographics
WHERE Age > 30;

-- Select everyone below the age of 30 (<30)
SELECT *
FROM EmployeeDemographics
WHERE Age < 30;

-- Select everyone from the age of 30 that is over the number (>=30)
SELECT *
FROM EmployeeDemographics
WHERE Age >= 30;

-- Select everyone from the age of 30 that is below the number (<=30)
SELECT *
FROM EmployeeDemographics
WHERE Age <= 30;

-- 5. Step:
-- AND:
-- Select everyone from the age of 30 that is below the number (<=30) AND is Male
SELECT *
FROM EmployeeDemographics
WHERE Age <= 30 AND Gender = 'Male';

-- 6. Step:
-- OR:
-- Select everyone from the age of 30 that is below the number (<=30) OR is Male
-- One of the criteria is correct, than it displays the values, like the EmployeeID of 1002
-- It is a Female [Not good], but below and equals 30 (<=30) [Good] => [Good] 
SELECT *
FROM EmployeeDemographics
WHERE Age <= 30 OR Gender = 'Male';

-- 7. Step:
-- LIKE:
-- %: Every amount of letter, number, etc...
-- ?: That exact letter, number, etc...

-- S% -> Everything can be after letter 'S' (in LastName) OR we can say LastNames that are starting with 'S'
SELECT *
FROM EmployeeDemographics
WHERE LastName LIKE 'S%';

-- %S% -> Select every LastName that has an 'S' letter init
SELECT *
FROM EmployeeDemographics
WHERE LastName LIKE '%S%';

-- S%o% -> Select every LastName that starts with letter 'S' and there is an 'o' somewhere
SELECT *
FROM EmployeeDemographics
WHERE LastName LIKE 'S%o%';

-- S_o__ -> Select every LastName that starts with letter 'S' and there is 1 letter gap, 
-- than 'o', than ends with 2 letters
SELECT *
FROM EmployeeDemographics
WHERE LastName LIKE 'S_o__';

-- 8. Step:
-- NULL / NOT NULL:
SELECT *
FROM EmployeeDemographics
WHERE FirstName is NULL ;
-- Returns nothing, because there is no NULL value in FirstName 

SELECT *
FROM EmployeeDemographics
WHERE FirstName is NOT NULL;
-- Returns everything, because there is no NULL value in FirstName 
-- (So it's not empty, or we can say filled everything in)

-- 9. Step:
-- IN: If we want to search for multiple things (FirstNames) in a column
SELECT *
FROM EmployeeDemographics
WHERE FirstName IN ('Jim', 'Michael', 'Angela');

-- Also you can combine all these above

-- ***************************************************************
-- SQL Basics Tutorial For Beginners | GROUP BY + ORDER BY Statements
-- *************************************************************** 

-- 1. Step:
-- GROUPY BY:
-- It returns the very FIRST unique value of Male and Female
SELECT DISTINCT(Gender)
FROM EmployeeDemographics;

-- This returns ALL the unique values of Males and Females
SELECT Gender
FROM EmployeeDemographics
GROUP BY Gender;

-- Show the numbers
SELECT Gender, COUNT(Gender) AS 'NumbersOfGenders'
FROM EmployeeDemographics
GROUP BY Gender;

SELECT Gender, Age AS 'Age', COUNT(Gender) AS 'NumbersOfGendersInEachAge'
FROM EmployeeDemographics
GROUP BY Gender, Age;

-- ORDER BY: Oreders the data according to the column
-- DESC: Descending (from upper to lower | from more to less) 
-- ASC: Ascending (from lower to upper | from less to more)
SELECT Gender, COUNT(Gender) AS 'CountGender'
FROM EmployeeDemographics
WHERE Age > 31
GROUP BY Gender
ORDER BY Gender DESC;

-- By Default it is ASC
SELECT *
FROM EmployeeDemographics
ORDER BY Age;

-- DESC by Age
SELECT *
FROM EmployeeDemographics
ORDER BY Age DESC;

-- You can use multiple orders
SELECT *
FROM EmployeeDemographics
ORDER BY Age DESC, Gender DESC ;

-- You can use numbers instead of column names
SELECT *
FROM EmployeeDemographics
ORDER BY 4 DESC, 5 DESC;
-- It is the same as the previous one, because it counts from 1, not 0
-- 4 equals to 'Age' and 5 equals to 'Gender'

-- It orders by the column number 1, after it, number 2, and so on
-- By default, it is ASC
SELECT *
FROM EmployeeDemographics
ORDER BY 1,2,3,4,5;

-- **************************************************************
-- **************************************************************
-- **************************************************************

-- ***************************************************************
-- Intermediate SQL Tutorial | INNER / OUTER JOINS | Use Case
-- ***************************************************************
-- 1. Step: New Data
-- INSERT INTO EmployeeDemographics VALUES
-- (1011, 'Ryan', 'Howard', 26, 'Male'),
-- (NULL, 'Holly','Flax', NULL, NULL),
-- (1013, 'Darryl', 'Philbin', NULL, 'Male');

-- INSERT INTO EmployeeSalary VALUES
-- (1010, NULL, 47000),
-- (NULL, 'Salesman', 43000);

SELECT *
FROM SQLTutorial.dbo.EmployeeDemographics;

SELECT *
FROM SQLTutorial.dbo.EmployeeSalary;

-- 2.Step: 
-- INNER JOIN: Intersection of two sets
-- Both tables are combined based on the EmployeeIDs, and that is
-- why we can not see the other EmployeeIDs (like 1011, 1012, 1013)
SELECT *
FROM SQLTutorial.dbo.EmployeeDemographics
INNER JOIN SQLTutorial.dbo.EmployeeSalary
    ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID;

-- 3. Step: 
-- LEFT JOIN / LEFT OUTER JOIN (Both are the same):
-- The LEFT JOIN keyword returns all records from the left table (A)
SELECT *
FROM SQLTutorial.dbo.EmployeeDemographics
LEFT JOIN SQLTutorial.dbo.EmployeeSalary
    ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID;

SELECT *
FROM SQLTutorial.dbo.EmployeeDemographics
LEFT OUTER JOIN SQLTutorial.dbo.EmployeeSalary
    ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID;

-- 4. Step:
-- RIGHT JOIN / RIGHT OUTER JOIN (Both are the same): 
-- The RIGHT JOIN keyword returns all records from the right table (B)
SELECT *
FROM SQLTutorial.dbo.EmployeeDemographics
RIGHT JOIN SQLTutorial.dbo.EmployeeSalary
    ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID;

SELECT *
FROM SQLTutorial.dbo.EmployeeDemographics
RIGHT OUTER JOIN SQLTutorial.dbo.EmployeeSalary
    ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID;

-- 7. Step:
-- FULL JOIN / FULL OUTER JOIN (Both are the same):
-- The FULL OUTER JOIN keyword returns all records when there is a match in left (A) or right (B) table records.
-- Tip: FULL OUTER JOIN and FULL JOIN are the same. 
SELECT *
FROM SQLTutorial.dbo.EmployeeDemographics
FULL JOIN SQLTutorial.dbo.EmployeeSalary
    ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID;

SELECT *
FROM SQLTutorial.dbo.EmployeeDemographics
FULL OUTER JOIN SQLTutorial.dbo.EmployeeSalary
    ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID;

-- This is not going to work, because we need to specify which EmployeeID we want (from which table)

-- SELECT EmployeeID, FirstName, LastName, JobTitle, Salary
-- FROM SQLTutorial.dbo.EmployeeDemographics
-- INNER JOIN SQLTutorial.dbo.EmployeeSalary
--     ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID;

-- 8. Step:
-- Examples for RIGHT, LEF JOINs
SELECT EmployeeDemographics.EmployeeID, FirstName, LastName, JobTitle, Salary
FROM SQLTutorial.dbo.EmployeeDemographics
RIGHT OUTER JOIN SQLTutorial.dbo.EmployeeSalary
    ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID;

SELECT EmployeeSalary.EmployeeID, FirstName, LastName, JobTitle, Salary
FROM SQLTutorial.dbo.EmployeeDemographics
RIGHT OUTER JOIN SQLTutorial.dbo.EmployeeSalary
    ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID;

SELECT EmployeeDemographics.EmployeeID, FirstName, LastName, JobTitle, Salary
FROM SQLTutorial.dbo.EmployeeDemographics
LEFT OUTER JOIN SQLTutorial.dbo.EmployeeSalary
    ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID

SELECT EmployeeSalary.EmployeeID, FirstName, LastName, JobTitle, Salary
FROM SQLTutorial.dbo.EmployeeDemographics
LEFT OUTER JOIN SQLTutorial.dbo.EmployeeSalary
    ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID;

SELECT EmployeeDemographics.EmployeeID, FirstName, LastName, JobTitle, Salary
FROM SQLTutorial.dbo.EmployeeDemographics
INNER JOIN SQLTutorial.dbo.EmployeeSalary
    ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
WHERE FirstName <> 'Michael'
ORDER BY Salary DESC;

SELECT JobTitle, AVG(Salary) AS 'SalesmanAvgSalary'
FROM SQLTutorial.dbo.EmployeeDemographics
INNER JOIN SQLTutorial.dbo.EmployeeSalary
    ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
WHERE JobTitle = 'Salesman'
GROUP BY JobTitle;

-- ***************************************************************
-- Intermediate SQL Tutorial | Unions | Union Operator
-- ***************************************************************

-- 1. Step: New Data and Table
--INSERT INTO EmployeeDemographics VALUES
--(1011, 'Ryan', 'Howard', 26, 'Male'),
--(NULL, 'Holly', 'Flax', NULL, NULL),
--(1013, 'Darryl', 'Philbin', NULL, 'Male');

--CREATE TABLE WareHouseEmployeeDemographics 
--(
--EmployeeID int, 
--FirstName varchar(50), 
--LastName varchar(50), 
--Age int, 
--Gender varchar(50)
--);

--INSERT INTO WareHouseEmployeeDemographics VALUES
--(1013, 'Darryl', 'Philbin', NULL, 'Male'),
--(1050, 'Roy', 'Anderson', 31, 'Male'),
--(1051, 'Hidetoshi', 'Hasagawa', 40, 'Male'),
--(1052, 'Val', 'Johnson', 31, 'Female');

SELECT *
FROM SQLTutorial.dbo.EmployeeDemographics;

SELECT *
FROM SQLTutorial.dbo.WareHouseEmployeeDemographics;

SELECT *
FROM SQLTutorial.dbo.EmployeeDemographics
FULL OUTER JOIN SQLTutorial.dbo.WareHouseEmployeeDemographics
	ON EmployeeDemographics.EmployeeID = WareHouseEmployeeDemographics.EmployeeID;

-- 2. Step:
-- UNION: It combines the 2 tables [EmployeeDemographics] and [WareHouseEmployeeDemographics]
-- It added the last 3 (1050, 1051, 1052) at the end of the columns.
-- UNION is taking out and removing the duplicates, like DISCTINCT
SELECT *
FROM SQLTutorial.dbo.EmployeeDemographics
UNION
SELECT *
FROM SQLTutorial.dbo.WareHouseEmployeeDemographics;

-- 3. Step:
-- UNION ALL: It combines the 2 tables [EmployeeDemographics] and [WareHouseEmployeeDemographics]
-- , also keeps everything (Duplicates, NULLs, etc...) -> You can see there are multiple "Darryl (1013)"s
SELECT *
FROM SQLTutorial.dbo.EmployeeDemographics
UNION ALL
SELECT *
FROM SQLTutorial.dbo.WareHouseEmployeeDemographics
ORDER BY EmployeeID;

-- UNION WORKS WELL, WHEN THE 2 TABLES ARE THE SAME (COLUMNS)
-- But let's see when we have another table
SELECT *
FROM SQLTutorial.dbo.EmployeeDemographics
ORDER BY EmployeeID;

SELECT *
FROM SQLTutorial.dbo.EmployeeSalary
ORDER BY EmployeeID;
-- ---------------------------------------------
-- 4. Step:
-- If you watch this query, you can see it shows the [EmployeeID, FirstName, Age] based on
-- the first SELECT as the headers of columns.
-- But as you see, in each column there are the second SELECT's results too [EmployeeID, JobTitle, Salary]
-- So every second row is the second SELECT based on the first SELECT
SELECT EmployeeID, FirstName, Age
FROM SQLTutorial.dbo.EmployeeDemographics
UNION
SELECT EmployeeID, JobTitle, Salary
FROM SQLTutorial.dbo.EmployeeSalary
ORDER BY EmployeeID;

-- ***************************************************************
-- Intermediate SQL Tutorial | Case Statement | Use Cases
-- ***************************************************************
-- Just to clear up data:
SELECT *
FROM SQLTutorial.dbo.EmployeeDemographics
ORDER BY EmployeeID;

--DELETE FROM SQLTutorial.dbo.EmployeeDemographics
--WHERE FirstName = 'Ryan' OR FirstName = 'Holly'

--INSERT INTO SQLTutorial.dbo.EmployeeDemographics VALUES
--(1011, 'Ryan', 'Howard', 26, 'Male'),
--(NULL, 'Holly', 'Flax', NULL, NULL)

-- 1. Step:
-- CASE Statement: Like in Programming, if it finds the first match, it stops there and does not search toward
-- !!!!WARNING!!!! DO NOT FORGET THE COMME AFTER SELECT's LINE ( , )
SELECT FirstName, LastName, Age, 
CASE
-- The ORDER is a key feature in the CASE statement, 
-- because now it says 'Old' at Stanley and not 'Stanley'
-- It Stops at the first case, when it found a match
-- If you switch the first 2 WHERE lines, than it will be okay, but be attentive about that
	WHEN Age > 30 THEN 'Old'
	WHEN Age = 38 THEN 'Stanley'
	WHEN Age BETWEEN 27 AND 30 THEN 'Young'
	ELSE 'Baby'
END AS 'NickNames'
FROM SQLTutorial.dbo.EmployeeDemographics
WHERE Age is NOT NULL
ORDER BY Age;

SELECT FirstName, LastName, JobTitle, Salary,
FORMAT(
	CASE
		WHEN JobTitle = 'Salesman' THEN Salary + (Salary * 0.10)
		WHEN JobTitle = 'Accountant' THEN Salary + (Salary * 0.05)
		WHEN JobTitle = 'HR' THEN Salary + (Salary * 0.005)
		ELSE Salary + (Salary * 0.03)
	END,
	-- FORMAT() function tells the system to display the number with no decimal places. 
	-- The N indicates a number, and 0 specifies the number of decimal places (which is zero in this case).
	'N2' 
	-- Only writing '0' is like the Salary column
) AS 'SalaryAfterRaise'
FROM SQLTutorial.dbo.EmployeeDemographics
JOIN SQLTutorial.dbo.EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID;

-- ***************************************************************
-- Intermediate SQL Tutorial | HAVING Clause
-- ***************************************************************

-- 1. Step:
-- We can not use this aggregate function (COUNT) in a WHERE Statement
SELECT JobTitle, COUNT(JobTitle) AS 'NumOfEmployee'
FROM SQLTutorial.dbo.EmployeeDemographics
JOIN SQLTutorial.dbo.EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
WHERE COUNT(JobTitle) > 1
GROUP BY JobTitle;

-- 2. Step: 
-- HAVING must be after GROUP BY (it is also needed)
-- HAVING: The HAVING clause is applied to the result set after the GROUP BY clause. 
-- It filters the grouped data based on a specified condition. 
-- It is similar to the WHERE clause, but while the WHERE clause filters individual rows before they are grouped, 
-- the HAVING clause filters groups of rows after they have been formed by the GROUP BY clause 
SELECT JobTitle, COUNT(JobTitle) AS 'NumOfEmployee'
FROM SQLTutorial.dbo.EmployeeDemographics
JOIN SQLTutorial.dbo.EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
GROUP BY JobTitle
HAVING COUNT(JobTitle) > 1;

SELECT JobTitle, AVG(Salary) AS 'AvgSalary'
FROM SQLTutorial.dbo.EmployeeDemographics
JOIN SQLTutorial.dbo.EmployeeSalary
	ON EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
GROUP BY JobTitle
HAVING AVG(Salary) > 45000
ORDER BY AVG(Salary);

-- ***************************************************************
-- Intermediate SQL Tutorial | UPDATING / DELETING Data
-- ***************************************************************

SELECT *
FROM SQLTutorial.dbo.EmployeeDemographics;

UPDATE SQLTutorial.dbo.EmployeeDemographics
SET EmployeeID = 1012
WHERE FirstName = 'Holly' AND LastName = 'Flax';

UPDATE SQLTutorial.dbo.EmployeeDemographics
SET Age = 31, Gender = 'Female'
WHERE FirstName = 'Holly' AND LastName = 'Flax';

DELETE FROM SQLTutorial.dbo.EmployeeDemographics
WHERE EmployeeID = 1005;

-- Trick to see what you are deleting is that to make a SELECT before
SELECT *
FROM SQLTutorial.dbo.EmployeeDemographics
WHERE EmployeeID = 1004;

--DELETE
--FROM SQLTutorial.dbo.EmployeeDemographics
--WHERE EmployeeID = 1004;
SELECT *
FROM SQLTutorial.dbo.EmployeeDemographics
WHERE EmployeeID = 1013;

DELETE
FROM SQLTutorial.dbo.EmployeeDemographics
WHERE EmployeeID = 1013;

-- 1013	Darryl	Philbin	NULL	Male
--INSERT INTO SQLTutorial.dbo.EmployeeDemographics VALUES
--(1013, 'Darryl', 'Philbin', NULL, 'Male');

SELECT *
FROM SQLTutorial.dbo.EmployeeDemographics;

-- ***************************************************************
-- Intermediate SQL Tutorial | ALIASING 
-- ***************************************************************

-- 1. Step: COLUMN Names
-- ALIASING: Temporarly changing the colum or tail name(s) in you script
-- and not going to impact your output
-- It is used for readability of your script
SELECT FirstName AS Fname
FROM SQLTutorial.dbo.EmployeeDemographics;

-- Works like this too
SELECT FirstName Fname
FROM SQLTutorial.dbo.EmployeeDemographics;

SELECT FirstName + ' ' + LastName AS FullName
FROM SQLTutorial.dbo.EmployeeDemographics;

SELECT AVG(Age) AS AvgAge
FROM SQLTutorial.dbo.EmployeeDemographics;

-- 2. Step: TABLE Names
-- Firstly you set the temp name AS Demo on the FROM's line, than use it in SELECT
SELECT Demo.EmployeeID
FROM SQLTutorial.dbo.EmployeeDemographics AS Demo;

SELECT Demo.EmployeeID, Sal.Salary
FROM SQLTutorial.dbo.EmployeeDemographics AS Demo
JOIN SQLTutorial.dbo.EmployeeSalary AS Sal
	ON Demo.EmployeeID = Sal.EmployeeID;

-- !!!!WRONG!!!! Example: It does not give any context to what the table that you are referencing is
SELECT a.EmployeeID, a.FirstName, b.JobTitle, c.Age
FROM SQLTutorial.dbo.EmployeeDemographics AS a
LEFT JOIN SQLTutorial.dbo.EmployeeSalary AS b
	ON a.EmployeeID = b.EmployeeID
LEFT JOIN SQLTutorial.dbo.WareHouseEmployeeDemographics AS c
	ON a.EmployeeID = c.EmployeeID;

-- GOOD (Better) Example:
SELECT Demo.EmployeeID, Demo.FirstName, Sal.JobTitle, Ware.Age
FROM SQLTutorial.dbo.EmployeeDemographics AS Demo
LEFT JOIN SQLTutorial.dbo.EmployeeSalary AS Sal
	ON Demo.EmployeeID = Sal.EmployeeID
LEFT JOIN SQLTutorial.dbo.WareHouseEmployeeDemographics AS Ware
	ON Demo.EmployeeID = Ware.EmployeeID;

-- ***************************************************************
-- Intermediate SQL Tutorial | PARTITION BY 
-- ***************************************************************

-- 1. Step:
-- 

SELECT *
FROM SQLTutorial..EmployeeDemographics;

SELECT * 
FROM SQLTutorial..EmployeeSalary;

---------------- RUN THIS 2 AT ONCE [START] ----------------
-- The PARTITION BY doing the same query as in the below one SELECT Statement, just in 1 line and
-- sticks it to the end as 'TotalGender' to the columns
SELECT FirstName, LastName, Gender, Salary, COUNT(Gender) OVER(PARTITION BY Gender) AS 'TotalGender'
FROM SQLTutorial..EmployeeDemographics Dem
JOIN SQLTutorial..EmployeeSalary Sal
	ON Dem.EmployeeID = Sal.EmployeeID;

-- This query is doing the same as in the above one that 1 line of PARTITION BY
SELECT  Gender, COUNT(Gender) AS 'GenderCount'
FROM SQLTutorial..EmployeeDemographics Dem
JOIN SQLTutorial..EmployeeSalary Sal
	ON Dem.EmployeeID = Sal.EmployeeID
GROUP BY Gender;
---------------- RUN THIS 2 AT ONCE [END] ----------------

-- ***************************************************************
-- Advanced SQL Tutorial | CTE (Common Table Expression)
-- ***************************************************************

-- 1. Step:
-- RUN the whole thing from 'WITH' to 'FROM CTE_Employee' at the bottom 
-- Why is it GOOD for us? https://learnsql.com/blog/what-is-common-table-expression/
WITH CTE_Employee AS (
	SELECT 
		FirstName, 
		LastName, 
		Gender, 
		Salary, 
		COUNT(Gender) OVER(PARTITION BY Gender) AS TotalGender,
		AVG(Salary) OVER(PARTITION BY Gender) AS AvgSalary
	FROM SQLTutorial..EmployeeDemographics AS Dem
	JOIN SQLTutorial..EmployeeSalary AS Sal
		ON Dem.EmployeeID = Sal.EmployeeID
	WHERE Salary > '45000'
)
SELECT FirstName, AvgSalary
FROM CTE_Employee;
-- The CTE is not stored in a temp database, so it won't work if you just run
-- SELECT FirstName, AvgSalary 
-- FROM CTE_Employee
-- You need to select and run the Whole thing from 'WITH'
-- Also you need to write the SELECT statement right after the ')' ends, because if you leave
-- a line it won't do the SELECT

-- ***************************************************************
-- Advanced SQL Tutorial | TEMP(ORARY) TABLES
-- ***************************************************************

-- 1. Step:
-- TEMP TABLE(S): It stores the values, but it does not create a new table as you can
-- see it on the left panel (Object Explorer). So it is good for temporary things to store.
-- A Lot of time these temp tables are used in 'Stored Procedures' you can see it at
-- (Advanced SQL Tutorial | Stored Procedures + Use Cases) part from the line: 

CREATE TABLE #temp_Employee(
	EmployeeID int,
	JobTitle varchar(100),
	Salary int
);

SELECT *
FROM #temp_Employee;

--INSERT INTO #temp_Employee VALUES
--(1001, 'HR', 45000);

-- FAST WAY TO TAKE ALL THE DATA FROM 'EmployeeSalary' to '#temp_Employee'
INSERT INTO #temp_Employee
SELECT *
FROM SQLTutorial..EmployeeSalary;

------------------- USEFUL SECTION START --------------------
-- 2. Step:  Use Case(s)
-- How to actually use TEMP TABLE(S)
-- Trick to use temp table(s) and create it (run it) again and again:
-- If it exists it deletes, and you select and run it from here (DROP TABLE...) to 
-- 'FROM #temp_Employee2' at the end of Useful section
DROP TABLE IF EXISTS #temp_Employee2
CREATE TABLE #temp_Employee2(
	JobTitle varchar(50),
	EmployeesPerJob int,
	AvgAge int,
	AvgSalary int
);

-- FAST WAY TO TAKE ALL THE DATA FROM 'EmployeeDemographics and EmployeeSalary' 
-- to '#temp_Employee2'
-- GOOD for: 
-- You do not need to re-create every time this connection among tables (JOIN)
-- You did it once, and you can use the '#temp_Employee2' table to make queries further queries
INSERT INTO #temp_Employee2
SELECT JobTitle, COUNT(JobTitle), AVG(Age), AVG(Salary)
FROM SQLTutorial..EmployeeDemographics Dem
JOIN SQLTutorial..EmployeeSalary Sal
	ON Dem.EmployeeID = Sal.EmployeeID
GROUP BY JobTitle;

SELECT *
FROM #temp_Employee2;
-- Further queries
---------------- USEFUL SECTION END --------------------

-- ***************************************************************
-- Advanced SQL Tutorial | String Functions + Use Cases
-- ***************************************************************

--Drop Table EmployeeErrors;

--CREATE TABLE EmployeeErrors (
--	EmployeeID varchar(50),
--	FirstName varchar(50),
--	LastName varchar(50)
--);

--INSERT INTO SQLTutorial..EmployeeErrors VALUES
--('1001  ', 'Jimbo', 'Halbert'),
--('  1002', 'Pamela', 'Beasely'),
--('1005', 'TOby', 'Flenderson - Fired');

--INSERT INTO SQLTutorial..EmployeeDemographics VALUES
--('1014', 'Toby', 'Bee', '35', 'Male');

SELECT *
FROM SQLTutorial..EmployeeErrors;

SELECT *
FROM SQLTutorial..EmployeeDemographics;

-- 1. Step:
-- TRIM, LTRIM, RTRIM: 
SELECT EmployeeID, TRIM(EmployeeID) AS IDTRIM
FROM SQLTutorial..EmployeeErrors;

SELECT EmployeeID, LTRIM(EmployeeID) AS IDTRIM
FROM SQLTutorial..EmployeeErrors;

SELECT EmployeeID, RTRIM(EmployeeID) AS IDTRIM
FROM SQLTutorial..EmployeeErrors;

-- 2. Step:
-- REPLACE:
SELECT LastName, REPLACE(LastName, '- Fired', '') AS LastNameFixed
FROM SQLTutorial..EmployeeErrors;

-- 3. Step:
-- SubString:
SELECT SUBSTRING(FirstName, 1, 3)
FROM SQLTutorial..EmployeeErrors;

-- Fuzzy matching:
-- Table1: ALEX
-- Table2: ALEXANDER
SELECT 
	err.FirstName, 
	SUBSTRING(err.FirstName, 1, 3), 
	dem.FirstName, 
	SUBSTRING(dem.FirstName, 1, 3)
FROM SQLTutorial..EmployeeErrors err
JOIN SQLTutorial..EmployeeDemographics dem
	ON SUBSTRING(err.FirstName, 1, 3) = SUBSTRING(dem.FirstName, 1, 3);
-- Would do this Fuzzy Matching on multiple things, like:
-- Gender, LastName, Age, Date of Birth
-- to find and correct the same person

-- 4. Step:
-- UPPER / LOWER:
SELECT FirstName, LOWER(FirstName) AS FirstNameLower 
FROM SQLTutorial..EmployeeErrors;

SELECT FirstName, UPPER(FirstName) AS FirstNameLower 
FROM SQLTutorial..EmployeeErrors;

-- ***************************************************************
-- Advanced SQL Tutorial | Stored PROCEDURES + Use Cases
-- ***************************************************************
-- !!!!WARNING!!!!: You need to put GO; before CREATE PROCEDURE (and suggested to put after it too)
-- https://stackoverflow.com/questions/41022645/create-procedure-must-be-the-only-statement-in-the-batch-erro
GO;
CREATE PROCEDURE test
AS
SELECT *
FROM SQLTutorial..EmployeeDemographics; 

EXEC test;

-- Better to put AS BEGIN - END Pair to see the end of the PROCEDURE
DROP PROCEDURE IF EXISTS test2;
GO;
CREATE PROCEDURE test2
AS BEGIN
	SELECT *
	FROM SQLTutorial..EmployeeDemographics
END;

EXEC test2;




DROP PROCEDURE IF EXISTS Temp_Employee;
GO;
CREATE PROCEDURE Temp_Employee @JobTitle NVARCHAR(100)
AS BEGIN

	CREATE TABLE #temp_Employee3(
		JobTitle VARCHAR(100),
		EmployeesPerJob INT,
		AvgAge INT,
		AvgSalary INT
	)

	INSERT INTO #temp_Employee3
	SELECT JobTitle, COUNT(JobTitle), AVG(Age), AVG(Salary)
	FROM SQLTutorial..EmployeeDemographics Dem
	JOIN SQLTutorial..EmployeeSalary Sal
		ON Dem.EmployeeID = Sal.EmployeeID
	WHERE JobTitle = @JobTitle
	GROUP BY JobTitle;

	SELECT *
	FROM #temp_Employee3;

END;
-- Recompile the stored procedure
--EXEC sp_recompile 'Temp_Employee';

-- SQLTutorial -> Programmability -> StoredProcedures -> Right click on sbo.Temp_Employee ->
-- -> Modify -> Add parameters: @JobTitle NVARCHAR(100) -> Add WHERE: WHERE JobTitle = @JobTitle ->
-- Save it (Temp_Employee_Procedure_Modified) -> !!!!!!EXECUTE the Modified file!!!!!
-- Than You can add this " @Jobtitle = 'Salesman' " to it as parameter

-- EXEC Temp_Employee; This time it says error, it needs a parameter
EXEC Temp_Employee @JobTitle = 'Salesman';
GO;

-- ***************************************************************
-- Advanced SQL Tutorial | Subqueries (In the SELECT, FROM and WHERE Statement)
-- ***************************************************************
-- Subqueris are slower than Temp_Tables and CTEs, and if you use Temp_Tables, you can re-use it.
-- So Temp_Tables are the BEST

SELECT *
FROM SQLTutorial..EmployeeSalary;

-- 1. Step:
-- Subquery in SELECT
SELECT EmployeeID, Salary, (SELECT AVG(Salary) FROM SQLTutorial..EmployeeSalary) AS AllAvgSalary
FROM SQLTutorial..EmployeeSalary;

-- 2. Step:
-- How to do it with PARTITION BY
SELECT EmployeeID, Salary,  AVG(Salary) OVER() AS AllAvgSalary
FROM SQLTutorial..EmployeeSalary;

-- 3. Step:
-- Why GROUP BY does not work
SELECT EmployeeID, Salary,  AVG(Salary) AS AllAvgSalary
FROM SQLTutorial..EmployeeSalary
GROUP BY EmployeeID, Salary
ORDER BY 1, 2;

-- 4. Step:
-- Subquery in FROM
-- Not suggested to use it like this, it uses more memory/power/calculating time
SELECT a.EmployeeID, AllAvgSalary
FROM (	SELECT EmployeeID, Salary,  AVG(Salary) OVER() AS AllAvgSalary
		FROM SQLTutorial..EmployeeSalary ) AS a;

-- 5. Step:
-- Subquery in WHERE
SELECT EmployeeID, JobTitle, Salary
FROM SQLTutorial..EmployeeSalary
WHERE EmployeeID IN (
	SELECT EmployeeID
	FROM SQLTutorial..EmployeeDemographics
	WHERE Age > 30
);


-- ***************************************************************
-- Legendary SQL Tutorial | 
-- ***************************************************************

--DECLARE @i INT;
--SET @i = 1;
 
--WHILE @i <= 10
--BEGIN
--   PRINT CONCAT('Pass...', @i);
--   SET @i = @i + 1;
--END;

--DECLARE @ColumnName NVARCHAR(50) = 'FirstName';
--DECLARE @Query NVARCHAR(MAX);

--SET @Query = 'SELECT ' + @ColumnName + ' FROM SQLTutorial.dbo.EmployeeDemographics';
--EXEC (@Query);