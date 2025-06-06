/*
            ----------------------------------------------------------------------------------------------
					DOC: Project_Notes_Sketches.pdf
					CONNECTION: DataWarehouse

											 Advanced Data Analytics
										      (1:04:30:35)

					"Answer Business Questions"
					- Complex Queries
					- Window Functions
					- CTE
					- Subqueries
					- Reports
			-----------------------------------------------------------------------------------------------
*/


USE DataWarehouse;
GO

-- ================================================================
--						  Advanced Analytics
--							(1:04:23:15)
-- ================================================================
-- Order the values of Dimensions by Measure.
-- Top N performers | Bottom N performers

-- Rank [Dimension] by <aggr.>[Measure]
-- Rank Countries by TotalSales
-- Top5 Products by Quantity
-- ...
