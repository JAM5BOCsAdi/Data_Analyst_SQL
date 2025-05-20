/*
            -----------------------------------------------------------------------------------------------
			        DOC: 06_Row_Level_Functions.pdf
					CONNECTION: SalesBD

                                           SQL Date and Time Functions
										      (05:22:43)

					This script demonstrates various date and time functions in SQL.
					It covers functions such as GETDATE, DATETRUNC, DATENAME, DATEPART,
					YEAR, MONTH, DAY, EOMONTH, FORMAT, CONVERT, CAST, DATEADD, DATEDIFF,
					and ISDATE.
   
					Table of Contents:
						1. GETDATE | Date Values
						2. Date Part Extractions (DATETRUNC, DATENAME, DATEPART, YEAR, MONTH, DAY)
						3. EOMONTH
						4. Date Parts
						5. FORMAT & CONVERT
						6. CAST
						7. DATEADD & DATEDIFF
						8. ISDATE
			-----------------------------------------------------------------------------------------------
*/

USE SalesDB;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                   GETDATE() | DATE VALUES
											  (05:27:57)
			-----------------------------------------------------------------------------------------------
*/
-- Returns the current date and time at the moment when the query is executed.

-- Display OrderID, CreationTime, a hard-coded date, and the current system date.
SELECT
    so.OrderID,
    so.CreationTime,
    '2025-08-20' AS HardCoded,
    GETDATE() AS Today
FROM Sales.Orders AS so;

/*
            -----------------------------------------------------------------------------------------------
			                               DATE PART EXTRACTIONS (YEAR, MONTH, DAY, DATETRUNC, DATENAME, DATEPART)
											  (05:28:29)
			-----------------------------------------------------------------------------------------------
*/

-- Extract various parts of CreationTime using DATETRUNC, DATENAME, DATEPART, YEAR, MONTH, and DAY.

SELECT 
	so.OrderID,
	so.CreationTime,

-- <<<<< YEAR >>>>>
	YEAR(so.CreationTime) AS 'Year',

-- <<<<< MONTH >>>>>
	MONTH(so.CreationTime) AS 'Month',

-- <<<<< DAY >>>>>
	DAY(so.CreationTime) AS 'Day',

-- <<<<< DATEPART (05:34:36) >>>>>



-- Return a specific part of the date as a number.
	DATEPART(year, so.CreationTime) AS Year1_dp,
	DATEPART(yyyy, so.CreationTime) AS Year2_dp, -- < --- Just different type to get the Year, Month, Day, and the rest.
    DATEPART(month, so.CreationTime) AS Month1_dp,
	DATEPART(mm, so.CreationTime) AS Month2_dp,
    DATEPART(day, so.CreationTime) AS Day1_dp,
	DATEPART(dd, so.CreationTime) AS Day2_dp,
    DATEPART(hour, so.CreationTime) AS Hour_dp,
    DATEPART(quarter, so.CreationTime) AS Quarter_dp,
    DATEPART(week, so.CreationTime) AS Week_dp,

-- <<<<< DATENAME (05:40:30) >>>>>
-- Returns the name (string) of a specific part of a date.
    DATENAME(month, so.CreationTime) AS Month_dn,
    DATENAME(weekday, so.CreationTime) AS Weekday_dn,
    DATENAME(day, so.CreationTime) AS Day_dn,
    DATENAME(year, so.CreationTime) AS Year_dn,

-- <<<<< DATETRUNC (05:45:05) >>>>>
-- Truncates the date to the specific part.
    DATETRUNC(year, so.CreationTime) AS Year_dt,
    DATETRUNC(day, so.CreationTime) AS Day_dt,
    DATETRUNC(minute, so.CreationTime) AS Minute_dt


FROM Sales.Orders as so;
GO

-- Aggregate orders by month (year, day) using DATETRUNC on CreationTime.
SELECT
    DATETRUNC(month, so.CreationTime) AS Creation,
    COUNT(*) AS OrderCount
FROM Sales.Orders AS so
GROUP BY DATETRUNC(month, so.CreationTime);
GO

/*
            -----------------------------------------------------------------------------------------------
											   EOMONTH()
											  (05:53:14)
			-----------------------------------------------------------------------------------------------
*/

-- Return the last day of a month.

-- Display OrderID, CreationTime, and the end-of-month date for CreationTime.
SELECT
    so.OrderID,
    so.CreationTime,
    EOMONTH(so.CreationTime) AS EndOfMonth
FROM Sales.Orders AS so;

-- Start of Month
SELECT
    so.OrderID,
    so.CreationTime,
    EOMONTH(so.CreationTime) AS EndOfMonth,
	CAST(DATETRUNC(month, so.CreationTime) AS DATE) AS StartOfMonth
FROM Sales.Orders AS so;


/*
            -----------------------------------------------------------------------------------------------
											   TASKS
											  (05:57:45)
			-----------------------------------------------------------------------------------------------
*/

-- How many orders were placed each year?
SELECT 
	YEAR(so.OrderDate) AS 'Year',
	COUNT(*) AS NrOfOrders
FROM Sales.Orders AS so
GROUP BY YEAR(so.OrderDate);
GO

-- How many orders were placed each month?
SELECT 
	MONTH(so.OrderDate) AS 'Month',
	COUNT(*) AS NrOfOrders
FROM Sales.Orders AS so
GROUP BY MONTH(so.OrderDate);
GO

-- How many orders were placed each month (using friendly month names)?
SELECT 
    DATENAME(month, so.OrderDate) AS OrderMonth, 
    COUNT(*) AS TotalOrders
FROM Sales.Orders AS so
GROUP BY DATENAME(month, so.OrderDate);
GO

-- Show all orders that were placed during the month of February.
SELECT
    *
FROM Sales.Orders AS so
WHERE MONTH(so.OrderDate) = 2; -- BEST PRACTICE: Filtering Data using an INT is faster than using STRING.
GO

/*
            -----------------------------------------------------------------------------------------------
											   DATE PARTS
											  (06:02:20)
			-----------------------------------------------------------------------------------------------
*/
-- Image

/*
            -----------------------------------------------------------------------------------------------
											   FORMAT & CONVERT
											     (06:05:40)
			-----------------------------------------------------------------------------------------------
*/
-- FORMAT:
-- Changing the format of a value from one tho another.

-- CONVERT:
-- Converts a date or time value to a different data type.

-- Format CreationTime into various string representations.
SELECT
    so.OrderID,
    so.CreationTime,
    FORMAT(so.CreationTime, 'MM-dd-yyyy') AS USA_Format,
    FORMAT(so.CreationTime, 'dd-MM-yyyy') AS EURO_Format,
    FORMAT(so.CreationTime, 'dd') AS dd,
    FORMAT(so.CreationTime, 'ddd') AS ddd,
    FORMAT(so.CreationTime, 'dddd') AS dddd,
    FORMAT(so.CreationTime, 'MM') AS MM,
    FORMAT(so.CreationTime, 'MMM') AS MMM,
    FORMAT(so.CreationTime, 'MMMM') AS MMMM
FROM Sales.Orders AS so;
GO

-- Display CreationTime using a custom format:
-- Example: Day Wed Jan Q1 2025 12:34:56 PM
SELECT
    so.OrderID,
    so.CreationTime,
    'Day ' + FORMAT(so.CreationTime, 'ddd MMM') +
    ' Q' + DATENAME(quarter, so.CreationTime) + ' ' +
    FORMAT(so.CreationTime, 'yyyy hh:mm:ss tt') AS CustomFormat
FROM Sales.Orders AS so;
GO

-- How many orders were placed each year, formatted by month and year (e.g., "Jan 25")?
SELECT
    FORMAT(so.CreationTime, 'MMM yy') AS OrderDate,
    COUNT(*) AS TotalOrders
FROM Sales.Orders AS so
GROUP BY FORMAT(so.CreationTime, 'MMM yy');
GO

-- Demonstrate conversion using CONVERT.
SELECT
    CONVERT(INT, '123') AS [String to Int CONVERT],
    CONVERT(DATE, '2025-08-20') AS [String to Date CONVERT],
    so.CreationTime,
    CONVERT(DATE, so.CreationTime) AS [Datetime to Date CONVERT],
    CONVERT(VARCHAR, so.CreationTime, 32) AS [USA Std. Style:32],
    CONVERT(VARCHAR, so.CreationTime, 34) AS [EURO Std. Style:34]
FROM Sales.Orders AS so;
GO

/*
            -----------------------------------------------------------------------------------------------
											     CAST
											  (06:10:15)
			-----------------------------------------------------------------------------------------------
*/
-- Changing the data type from one to another.

-- Convert data types using CAST.
SELECT
    CAST('123' AS INT) AS [String to Int],
    CAST(123 AS VARCHAR) AS [Int to String],
    CAST('2025-08-20' AS DATE) AS [String to Date],
    CAST('2025-08-20' AS DATETIME2) AS [String to Datetime],
    so.CreationTime,
    CAST(so.CreationTime AS DATE) AS [Datetime to Date]
FROM Sales.Orders AS so;
GO

/*
            -----------------------------------------------------------------------------------------------
										  DATEADD & DATEDIFF
											  (06:10:15)
			-----------------------------------------------------------------------------------------------
*/

-- Perform date arithmetic on OrderDate.
SELECT
    OrderID,
    OrderDate,
    DATEADD(day, -10, OrderDate) AS TenDaysBefore,
    DATEADD(month, 3, OrderDate) AS ThreeMonthsLater,
    DATEADD(year, 2, OrderDate) AS TwoYearsLater
FROM Sales.Orders;
GO

-- Calculate the age of employees.
SELECT
    se.EmployeeID,
    se.BirthDate,
    DATEDIFF(year, se.BirthDate, GETDATE()) AS Age
FROM Sales.Employees AS se;
GO

-- Find the average shipping duration in days for each month.
SELECT
    MONTH(OrderDate) AS OrderMonth,
    AVG(DATEDIFF(day, OrderDate, ShipDate)) AS AvgShip
FROM Sales.Orders
GROUP BY MONTH(OrderDate);
GO

-- Time Gap Analysis: Find the number of days between each order and the previous order.
SELECT
    OrderID,
    OrderDate AS CurrentOrderDate,
    LAG(OrderDate) OVER (ORDER BY OrderDate) AS PreviousOrderDate, -- LAG() : Access a value from the previous row (records)
    DATEDIFF(day, LAG(OrderDate) OVER (ORDER BY OrderDate), OrderDate) AS NrOfDays
FROM Sales.Orders;
GO

/*
            -----------------------------------------------------------------------------------------------
												ISDATE
											  (06:50:32)
			-----------------------------------------------------------------------------------------------
*/

-- Check if a value is date.
-- Returns 1 if the string value is a valid date, or 0 if it is not a valid date.

SELECT 
	ISDATE('123') DateCheck1,
	ISDATE('2025-08-20') DateCheck2,
	ISDATE('20-08-2025') DateCheck3,
	ISDATE('2025') DateCheck4,
	ISDATE('08') DateCheck5;
GO

SELECT
	--CAST(OrderDate AS DATE) OrderDate
	OrderDate,
	ISDATE(OrderDate),
	CASE WHEN ISDATE(OrderDate) = 1 THEN CAST(OrderDate AS DATE)
		ELSE '9999-01-01'
	END NewOrderDate
FROM
(
	SELECT '2025-08-20' AS OrderDate UNION
	SELECT '2025-08-21' UNION
	SELECT '2025-08-23' UNION
	SELECT '2025-08'
) t 
-- WHERE ISDATE(OrderDate) = 0;
GO