/*
            ----------------------------------------------------------------------------------------------
					DOC: 10_AI_and_SQL.pdf
					CONNECTION: SalesDB

											 AI Prompts for SQL
										      (22:24:20)
				
				    This script contains a series of prompts designed to help both SQL developers 
				    and anyone interested in learning SQL improve their skills in writing, 
				    optimizing, and understanding SQL queries. The prompts cover a variety of 
				    topics, including solving SQL tasks, enhancing query readability, performance 
				    optimization, debugging, and interview/exam preparation. Each section provides 
				    clear instructions and sample code to facilitate self-learning and practical 
				    application in real-world scenarios.

				    Table of Contents:
					  1. Solve an SQL Task
					  2. Improve the Readability
					  3. Optimize the Performance Query
				   	  4. Optimize Execution Plan
					  5. Debugging
					  6. Explain the Result
					  7. Styling & Formatting
					  8. Documentations & Comments
					  9. Improve Database DDL
					 10. Generate Test Dataset
					 11. Create SQL Course
					 12. Understand SQL Concept
					 13. Comparing SQL Concepts
					 14. SQL Questions with Options
					 15. Prepare for a SQL Interview
					 16. Prepare for a SQL Exam
			-----------------------------------------------------------------------------------------------
*/


USE SalesDB;
GO

--			********************************************************************************************
--													Pre-Things
--													(22:24:20)
--			********************************************************************************************

-- CTRL + I to ask Copilot [INLINE CHAT] 
-- CTRL + ALT + I to ask Copilot [NORMAL CHAT]
SELECT TOP 10 * FROM Sales.Customers;

SELECT TOP 10 c.*, o.*
FROM Sales.Customers c
JOIN Sales.Orders o ON c.CustomerID = o.CustomerID;

-- -----------------------------------------------------------------------------------------------
--                                   Recursive CTE Example
--                                   (Understanding Recursion in SQL)
-- -----------------------------------------------------------------------------------------------
-- Suppose you have a table Sales.Employees with columns:
--   EmployeeID, Name, ManagerID
-- You want to get the hierarchy (all subordinates) under a specific manager (e.g., ManagerID = 1)

-- Recursive CTE to get all employees under a manager
WITH EmployeeHierarchy AS (
    -- Anchor member: select the top-level manager
    SELECT e.EmployeeID, e.FirstName, e.ManagerID, 0 AS Level
    FROM Sales.Employees e
    WHERE ManagerID IS NULL  -- or WHERE EmployeeID = 1 for a specific manager

    UNION ALL

    -- Recursive member: select employees who report to employees already found
    SELECT e.EmployeeID, e.FirstName, e.ManagerID, eh.Level + 1
    FROM Sales.Employees e
    INNER JOIN EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID
)
SELECT * FROM EmployeeHierarchy;

-- Explanation:
-- 1. The anchor member finds the top-level manager(s).
-- 2. The recursive member finds employees who report to those managers, and so on.
-- 3. The recursion continues until no more subordinates are found.
-- 4. The 'Level' column shows the depth in the hierarchy.
--
-- You can modify the anchor WHERE clause to start from a specific manager.
--
-- Recursive CTEs are useful for hierarchical data: org charts, folder trees, etc.
--
-- Note: For large hierarchies, consider performance and MAXRECURSION settings.


