/*
===============================================================================
Script: Validate Bronze Layer
===============================================================================

Description:
    Validates the Bronze layer after data loading.

Validation Checks:
    1. Row Counts
    2. Duplicate Primary Keys
    3. NULL Primary Keys
    4. Empty Tables

Usage:
    EXEC bronze.load_bronze;
    Then run:
    03_validate_bronze.sql

===============================================================================
*/

USE DWH;
GO

PRINT '============================================================';
PRINT 'BRONZE LAYER VALIDATION';
PRINT '============================================================';

-------------------------------------------------------------------------------
-- 1. Row Counts
-------------------------------------------------------------------------------
PRINT '';
PRINT '1. ROW COUNTS';
PRINT '------------------------------------------------------------';

SELECT 'Customers' AS Table_Name, COUNT(*) AS Rows_Loaded
FROM bronze.customers

UNION ALL

SELECT 'Products', COUNT(*)
FROM bronze.products

UNION ALL

SELECT 'Stores', COUNT(*)
FROM bronze.stores

UNION ALL

SELECT 'Sales', COUNT(*)
FROM bronze.sales;

-------------------------------------------------------------------------------
-- 2. Duplicate Customer IDs
-------------------------------------------------------------------------------
PRINT '';
PRINT '2. DUPLICATE CUSTOMER IDs';
PRINT '------------------------------------------------------------';

SELECT
    customer_id,
    COUNT(*) AS Duplicate_Count
FROM bronze.customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-------------------------------------------------------------------------------
-- 3. Duplicate Product IDs
-------------------------------------------------------------------------------
PRINT '';
PRINT '3. DUPLICATE PRODUCT IDs';
PRINT '------------------------------------------------------------';

SELECT
    product_id,
    COUNT(*) AS Duplicate_Count
FROM bronze.products
GROUP BY product_id
HAVING COUNT(*) > 1;

-------------------------------------------------------------------------------
-- 4. Duplicate Store IDs
-------------------------------------------------------------------------------
PRINT '';
PRINT '4. DUPLICATE STORE IDs';
PRINT '------------------------------------------------------------';

SELECT
    store_id,
    COUNT(*) AS Duplicate_Count
FROM bronze.stores
GROUP BY store_id
HAVING COUNT(*) > 1;

-------------------------------------------------------------------------------
-- 5. Duplicate Transaction IDs
-------------------------------------------------------------------------------
PRINT '';
PRINT '5. DUPLICATE TRANSACTION IDs';
PRINT '------------------------------------------------------------';

SELECT
    transaction_id,
    COUNT(*) AS Duplicate_Count
FROM bronze.sales
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-------------------------------------------------------------------------------
-- 6. NULL Primary Keys
-------------------------------------------------------------------------------
PRINT '';
PRINT '6. NULL PRIMARY KEYS';
PRINT '------------------------------------------------------------';

SELECT
    'Customers' AS Table_Name,
    COUNT(*) AS Null_Primary_Keys
FROM bronze.customers
WHERE customer_id IS NULL
   OR TRIM(customer_id) = ''

UNION ALL

SELECT
    'Products',
    COUNT(*)
FROM bronze.products
WHERE product_id IS NULL
   OR TRIM(product_id) = ''

UNION ALL

SELECT
    'Stores',
    COUNT(*)
FROM bronze.stores
WHERE store_id IS NULL
   OR TRIM(store_id) = ''

UNION ALL

SELECT
    'Sales',
    COUNT(*)
FROM bronze.sales
WHERE transaction_id IS NULL
   OR TRIM(transaction_id) = '';

-------------------------------------------------------------------------------
-- 7. Empty Tables
-------------------------------------------------------------------------------
PRINT '';
PRINT '7. EMPTY TABLE CHECK';
PRINT '------------------------------------------------------------';

SELECT
    'Customers' AS Table_Name,
    CASE
        WHEN EXISTS (SELECT 1 FROM bronze.customers)
            THEN 'PASS'
        ELSE 'FAIL'
    END AS Status

UNION ALL

SELECT
    'Products',
    CASE
        WHEN EXISTS (SELECT 1 FROM bronze.products)
            THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

SELECT
    'Stores',
    CASE
        WHEN EXISTS (SELECT 1 FROM bronze.stores)
            THEN 'PASS'
        ELSE 'FAIL'
    END

UNION ALL

SELECT
    'Sales',
    CASE
        WHEN EXISTS (SELECT 1 FROM bronze.sales)
            THEN 'PASS'
        ELSE 'FAIL'
    END;

-------------------------------------------------------------------------------
-- Validation Completed
-------------------------------------------------------------------------------
PRINT '';
PRINT '============================================================';
PRINT 'BRONZE VALIDATION COMPLETED';
PRINT '============================================================';
GO
