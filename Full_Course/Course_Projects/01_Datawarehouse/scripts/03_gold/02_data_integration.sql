/*
            ----------------------------------------------------------------------------------------------
					DOC: 11_SQL_Projects.pdf
					CONNECTION: DataWarehouse

											 DataWarehouse
										      (23:21:04)

					"Organize, Structure, Prepare":
					- ETL/ELT Processing
					- Data Architecture
					- Data Integration
					- Data Cleansing
					- Data Load
					- Data Modeling
			-----------------------------------------------------------------------------------------------
*/

USE DataWarehouse;
GO

-- <<<<< Data integration (1:03:04:40) >>>>>
-- Q: Which source is the master for these values?
-- A: The master source of the customer data is CRM!
SELECT DISTINCT
	ci.cst_gndr,
	ca.gen,
	CASE
		WHEN ci.cst_gndr != 'n/a' 
			THEN ci.cst_gndr -- CRM is the master for gender info
		ELSE COALESCE(ca.gen, 'n/a')
	END AS new_gen
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
	ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
	ON ci.cst_key = la.cid
ORDER BY 1, 2;
GO