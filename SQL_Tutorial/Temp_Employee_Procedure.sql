USE [SQLTutorial]
GO
/****** Object:  StoredProcedure [dbo].[Temp_Employee]    Script Date: 07/01/2024 19:07:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Temp_Employee]
@JobTitle NVARCHAR(100)
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