/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================

Script Purpose:
    Creates the raw Bronze tables for the Retail Data Warehouse.

Description:
    - Drops existing Bronze tables if they exist.
    - Creates raw landing tables.
    - Stores source data exactly as received from the CSV files.
    - No cleaning, no validation, no deduplication.
    - All source columns are NVARCHAR.
    - Adds dwh_create_date for audit purposes.

Usage:
    Run this script after creating the database and schemas.

===============================================================================
*/

USE DWH;
GO

/*==============================================================================
    Customers
==============================================================================*/

IF OBJECT_ID('bronze.customers', 'U') IS NOT NULL
    DROP TABLE bronze.customers;
GO

CREATE TABLE bronze.customers
(
    customer_id         NVARCHAR(50)   NULL,
    first_name          NVARCHAR(200)  NULL,
    last_name           NVARCHAR(200)  NULL,
    email               NVARCHAR(300)  NULL,
    phone               NVARCHAR(100)  NULL,
    signup_date         NVARCHAR(50)   NULL,
    city                NVARCHAR(200)  NULL,
    state               NVARCHAR(50)   NULL,
    country             NVARCHAR(100)  NULL,
    customer_segment    NVARCHAR(100)  NULL,
    dwh_create_date     DATETIME2      DEFAULT GETDATE()
);
GO

/*==============================================================================
    Products
==============================================================================*/

IF OBJECT_ID('bronze.products', 'U') IS NOT NULL
    DROP TABLE bronze.products;
GO

CREATE TABLE bronze.products
(
    product_id          NVARCHAR(50)   NULL,
    product_name        NVARCHAR(300)  NULL,
    category            NVARCHAR(100)  NULL,
    sub_category        NVARCHAR(100)  NULL,
    unit_price          NVARCHAR(50)   NULL,
    supplier            NVARCHAR(200)  NULL,
    discontinued        NVARCHAR(20)   NULL,
    dwh_create_date     DATETIME2      DEFAULT GETDATE()
);
GO

/*==============================================================================
    Stores
==============================================================================*/

IF OBJECT_ID('bronze.stores', 'U') IS NOT NULL
    DROP TABLE bronze.stores;
GO

CREATE TABLE bronze.stores
(
    store_id            NVARCHAR(50)   NULL,
    store_name          NVARCHAR(200)  NULL,
    region              NVARCHAR(50)   NULL,
    city                NVARCHAR(200)  NULL,
    state               NVARCHAR(50)   NULL,
    country             NVARCHAR(100)  NULL,
    store_type          NVARCHAR(50)   NULL,
    opened_date         NVARCHAR(50)   NULL,
    dwh_create_date     DATETIME2      DEFAULT GETDATE()
);
GO

/*==============================================================================
    Sales
==============================================================================*/

IF OBJECT_ID('bronze.sales', 'U') IS NOT NULL
    DROP TABLE bronze.sales;
GO

CREATE TABLE bronze.sales
(
    transaction_id      NVARCHAR(50)   NULL,
    order_date          NVARCHAR(50)   NULL,
    ship_date           NVARCHAR(50)   NULL,
    customer_id         NVARCHAR(50)   NULL,
    product_id          NVARCHAR(50)   NULL,
    store_id            NVARCHAR(50)   NULL,
    quantity            NVARCHAR(50)   NULL,
    unit_price          NVARCHAR(50)   NULL,
    discount_pct        NVARCHAR(50)   NULL,
    payment_method      NVARCHAR(100)  NULL,
    order_status        NVARCHAR(50)   NULL,
    dwh_create_date     DATETIME2      DEFAULT GETDATE()
);
GO

PRINT '====================================================';
PRINT 'Bronze tables created successfully.';
PRINT '====================================================';
GO
