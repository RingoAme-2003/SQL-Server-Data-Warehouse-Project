/*
================================================================================
SILVER TABLES QUALITY CHECKS
================================================================================
Script Purpose :
	This script performs various quality checks for Data Consistency, Accuracy,
	and Standardization across the 'silver' schemas.
	It includes checks for :
	- Null or Duplicate Primary Keys.
	- Unwanted Spaces in String Fields.
	- Data Standardization and Consistency.
	- Invalid Date Ranges and Orders.
	- Data Consistency between Related Fields.

Usage Notes :
	- Run these checks after data loading Silver Layer.
	- Investigate and resolve any discrepancies found during the checks.
================================================================================
*/

--------------------------------------------------------------------------------
-- Quality Check : silver.crm_prd_info
--------------------------------------------------------------------------------

	-- 1. Check for NULLs or Duplicates in Primary Key
	-- Expectation : No Result

	SELECT
		cst_id,
		COUNT(*) 
	FROM silver.crm_cust_info
	GROUP BY cst_id
	HAVING COUNT(*) > 1 OR cst_id IS NULL;
	-- COUNT(*) > 1, filters duplicates. cst_id IS NULL filters all NULLs


	-- 2. Check for Unwanted Spaces
	-- Expectation : No Results

	SELECT 
		cst_firstname
	FROM silver.crm_cust_info
	WHERE cst_firstname != TRIM(cst_firstname);

	SELECT 
		cst_lastname
	FROM silver.crm_cust_info
	WHERE cst_lastname != TRIM(cst_lastname);


	-- 3. Data Standardization & Consistency

	SELECT 
		DISTINCT cst_marital_status
		-- NULL = n/a, M = Married, S = Single
	FROM silver.crm_cust_info;

	SELECT 
		DISTINCT cst_gndr
		-- NULL = n/a, M = Male, F = Female
	FROM silver.crm_cust_info;


--------------------------------------------------------------------------------
-- Quality Check : silver.crm_prd_info
--------------------------------------------------------------------------------
	
	-- 1. Check for NULLs or Duplicates in Primary Key
	-- Expectation : No Result

	SELECT 
		prd_id,
		COUNT(*)
	FROM silver.crm_prd_info
	GROUP BY prd_id
	HAVING COUNT(*) > 1 OR prd_id IS NULL;


	-- 2. Check for Unwanted Spaces
	-- Expectation : No Results

	SELECT 
		prd_nm
	FROM silver.crm_prd_info
	WHERE prd_nm != TRIM(prd_nm);


	-- 3. Check for NULLs or Negative Numbers
	-- Expectation : No Results

	SELECT 
		prd_cost
	FROM silver.crm_prd_info
	WHERE prd_cost < 0 OR prd_cost IS NULL;


	-- 4. Data Standardization & Consistency

	SELECT DISTINCT prd_line 
	FROM silver.crm_prd_info;


	-- 5. Check for Invalid Date Orders

	SELECT *
	FROM silver.crm_prd_info
	WHERE prd_start_dt > prd_end_dt;


--------------------------------------------------------------------------------
-- Quality Check : silver.crm_sales_details
--------------------------------------------------------------------------------

	-- 1. Check for Unwanted Spaces
	-- Expectation : No Results

	SELECT
		sls_ord_num
	FROM silver.crm_sales_details
	WHERE sls_ord_num != TRIM(sls_ord_num);


	-- 2. Check for Invalid Date Orders
	-- Expectation : No Result

	SELECT 
		*
	FROM silver.crm_sales_details
	WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;


	-- 3. Check Data Consistency : Between Sales, Quantity, and Price
	-- >> Sales = Quantity * Price
	-- >> Values must not be NULL, zero, or Negative.

	SELECT DISTINCT
		sls_sales,
		sls_quantity,
		sls_price
	FROM silver.crm_sales_details
	WHERE sls_sales != sls_quantity * sls_price
	OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
	OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0;

	SELECT * FROM silver.crm_sales_details;


--------------------------------------------------------------------------------
-- Quality Check : silver.erp_cust_az12
--------------------------------------------------------------------------------

	-- 1. Identify Out-of-Range Dates
	-- Expectation : No Result

	SELECT DISTINCT
		bdate 
	FROM silver.erp_cust_az12
	WHERE bdate < '1924-01-01' OR bdate > GETDATE();

	-- 2. Data Standardization & Consistency

	SELECT DISTINCT
		gen 
	FROM silver.erp_cust_az12;

	SELECT * FROM silver.erp_cust_az12;


--------------------------------------------------------------------------------
-- Quality Check : silver.erp_loc_a101
--------------------------------------------------------------------------------

	-- 1. Checking Primary Key Connection
	-- Expectation : No Result

	SELECT
		cid
	FROM silver.erp_loc_a101
	WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);

	-- 2. Data Standardization & Consistency

	SELECT DISTINCT
		cntry
	FROM silver.erp_loc_a101

	SELECT * FROM silver.erp_loc_a101;


--------------------------------------------------------------------------------
-- Quality Check : silver.erp_px_cat_g1v2
--------------------------------------------------------------------------------

	-- 1. Check for Unwanted Spaces 
	-- Expectation : No Result

	SELECT
		cat
	FROM silver.erp_px_cat_g1v2
	WHERE cat != TRIM(cat);

	SELECT
		subcat
	FROM silver.erp_px_cat_g1v2
	WHERE subcat != TRIM(subcat);

	SELECT
		maintenance
	FROM silver.erp_px_cat_g1v2
	WHERE maintenance != TRIM(maintenance);


	-- 2. Data Standardization & Consistency

	SELECT DISTINCT
		cat 
	FROM silver.erp_px_cat_g1v2;

	SELECT DISTINCT
		subcat 
	FROM silver.erp_px_cat_g1v2;

	SELECT DISTINCT
		maintenance 
	FROM silver.erp_px_cat_g1v2;

	SELECT * FROM silver.erp_px_cat_g1v2;
