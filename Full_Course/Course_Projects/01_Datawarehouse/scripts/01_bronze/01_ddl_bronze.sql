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

-- ================================================================
--							Bronze Layer
--							(1:00:32:54)
-- ================================================================

-- <<<<< Analyse Source System (1:00:34:15) >>>>>

-- Business Context & Ownership:
-- Who owns the data?
-- What Business Process it supports?
-- System & Data documentation
-- Data Model & Data Catalog

-- Architecture & Technology:
-- How is data stored? (SQL Server, Oracle, AWS, Azure, ...)
-- What are the integration capabilities? (API, Kafka, File Extract, Direct DB, ...)

-- Extract & Load:
-- Incremental vs Full load?
-- Data Scope & Historical needs
-- What is the expected size of the extracts?
-- Are there any data volume limitations?
-- How to avoid impacting the source system's performance?
-- Authentication and authoriztaion (Tokens, SSH keys, VPN, IP whitelisting, ...)

USE DataWarehouse;
GO

-- <<<<< Create DDL for Tables (1:00:38:20) >>>>>

-- CRM:
-- Short form:
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info(
	cst_id				INT,
	cst_key				NVARCHAR(50),
	cst_firstname		NVARCHAR(50),
	cst_lastname		NVARCHAR(50),
	cst_marital_status	NVARCHAR(50),
	cst_gndr			NVARCHAR(50),
	cst_create_date		DATE
);
GO

-- Long form:
--IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
--	BEGIN
--		DROP TABLE bronze.crm_cust_info;
--	END
--ELSE
--	BEGIN
--		CREATE TABLE bronze.crm_cust_info(
--			cst_id				INT,
--			cst_key				NVARCHAR(50),
--			cst_firstname		NVARCHAR(50),
--			cst_lastname		NVARCHAR(50),
--			cst_marital_status	NVARCHAR(50),
--			cst_gndr			NVARCHAR(50),
--			cst_create_date		DATE
--		);
--	END

--GO

IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info(
	prd_id				INT,
	prd_key				NVARCHAR(50),
	prd_nm				NVARCHAR(50),
	prd_cost			INT,
	prd_line			NVARCHAR(50),
	prd_start_dt		DATETIME,
	prd_end_dt			DATETIME
);
GO

IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details(
	sls_ord_num			NVARCHAR(50),
	sls_prd_key			NVARCHAR(50),
	sls_cust_id			INT,
	sls_order_dt		INT,
	sls_ship_dt			INT,
	sls_due_dt			INT,
	sls_sales			INT,
	sls_quantity		INT,
	sls_price			INT
);
GO


-- ERP:
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12(
	cid					NVARCHAR(50),
	bdate				DATE,
	gen					NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101(
	cid					NVARCHAR(50),
	cntry				NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
	DROP TABLE bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2(
	id					NVARCHAR(50),
	cat					NVARCHAR(50),
	subcat				NVARCHAR(50),
	maintenance			NVARCHAR(50)
);
GO
