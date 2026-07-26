/*
===============================================================================
Script: Validate Silver Layer
===============================================================================

Description:
    Performs data quality validation checks on all Silver tables.

Checks Performed:

    Customers
        • Duplicate Customer IDs
        • Invalid Emails
        • Missing Customer Names

    Products
        • Duplicate Product IDs
        • Negative Prices

    Stores
        • Duplicate Store IDs
        • Missing Store Names

    Sales
        • Duplicate Transactions
        • Invalid Dates
        • Invalid Quantity
        • Invalid Unit Price
        • Invalid Discount
        • Invalid Customer
        • Invalid Product
        • Invalid Store

Usage:
    Execute after Silver Load.

===============================================================================
*/

USE DWH;
GO

PRINT '============================================================';
PRINT 'VALIDATING SILVER LAYER';
PRINT '============================================================';





/******************************************************************************
    CUSTOMERS
******************************************************************************/

PRINT '';
PRINT 'Customers Validation';
PRINT '------------------------------------------------------------';

-- Duplicate Customers

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM silver.customers
GROUP BY customer_id
HAVING COUNT(*) > 1;



-- Invalid Email

SELECT *
FROM silver.customers
WHERE email NOT LIKE '%_@_%._%';



-- Missing Names

SELECT *
FROM silver.customers
WHERE first_name='Unknown'
   OR last_name='Unknown';





/******************************************************************************
    PRODUCTS
******************************************************************************/

PRINT '';
PRINT 'Products Validation';
PRINT '------------------------------------------------------------';

-- Duplicate Products

SELECT
    product_id,
    COUNT(*) AS duplicate_count
FROM silver.products
GROUP BY product_id
HAVING COUNT(*) > 1;



-- Invalid Price

SELECT *
FROM silver.products
WHERE unit_price <= 0;





/******************************************************************************
    STORES
******************************************************************************/

PRINT '';
PRINT 'Stores Validation';
PRINT '------------------------------------------------------------';

-- Duplicate Stores

SELECT
    store_id,
    COUNT(*) AS duplicate_count
FROM silver.stores
GROUP BY store_id
HAVING COUNT(*) > 1;



-- Missing Store Name

SELECT *
FROM silver.stores
WHERE store_name='Unknown';





/******************************************************************************
    SALES
******************************************************************************/

PRINT '';
PRINT 'Sales Validation';
PRINT '------------------------------------------------------------';

-- Duplicate Transactions

SELECT
    transaction_id,
    COUNT(*) AS duplicate_count
FROM silver.sales
GROUP BY transaction_id
HAVING COUNT(*) > 1;



-- Invalid Order Date

SELECT *
FROM silver.sales
WHERE order_date IS NULL;



-- Ship Date Earlier Than Order Date

SELECT *
FROM silver.sales
WHERE ship_date < order_date;



-- Invalid Quantity

SELECT *
FROM silver.sales
WHERE quantity <= 0;



-- Invalid Unit Price

SELECT *
FROM silver.sales
WHERE unit_price <= 0;



-- Invalid Discount

SELECT *
FROM silver.sales
WHERE discount_pct < 0
   OR discount_pct > 1;



-- Customer Not Found

SELECT s.*
FROM silver.sales s
LEFT JOIN silver.customers c
       ON s.customer_id = c.customer_id
WHERE c.customer_id IS NULL;



-- Product Not Found

SELECT s.*
FROM silver.sales s
LEFT JOIN silver.products p
       ON s.product_id = p.product_id
WHERE p.product_id IS NULL;



-- Store Not Found

SELECT s.*
FROM silver.sales s
LEFT JOIN silver.stores st
       ON s.store_id = st.store_id
WHERE st.store_id IS NULL;





PRINT '';
PRINT '============================================================';
PRINT 'SILVER VALIDATION COMPLETED';
PRINT '============================================================';
GO
