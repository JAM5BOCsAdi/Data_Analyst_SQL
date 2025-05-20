/*
            -----------------------------------------------------------------------------------------------
			        DOC: 06_Row_Level_Functions.pdf
					CONNECTION: SalesBD

                                           SQL Numeric Functions
										      (05:18:42)

					This document provides an overview of SQL number functions, which allow 
					performing mathematical operations and formatting numerical values.

					Table of Contents:
					1. Rounding Functions
					- ROUND
					2. Absolute Value Function
					- ABS
			-----------------------------------------------------------------------------------------------
*/

USE SalesDB;
GO

/*
            -----------------------------------------------------------------------------------------------
			                                   ROUND() - Rounding Numbers
											  (05:18:46)
			-----------------------------------------------------------------------------------------------
*/

-- Demonstrate rounding a number to different decimal places
SELECT 
    3.516 AS original_number,
    ROUND(3.516, 2) AS round_2,
    ROUND(3.516, 1) AS round_1,
    ROUND(3.516, 0) AS round_0

/*
            -----------------------------------------------------------------------------------------------
			                                   ABS() - Absolute Value
											  (05:21:46)
			-----------------------------------------------------------------------------------------------
*/

-- Demonstrate absolute value function
SELECT 
    -10 AS original_number,
    ABS(-10) AS absolute_value_negative,
    ABS(10) AS absolute_value_positive