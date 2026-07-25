/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================

Description:
    Creates the Silver layer tables.

Purpose:
    - Stores cleaned and standardized data.
    - Uses appropriate SQL Server data types.
    - Adds audit column (dwh_create_date).

===============================================================================
*/

USE DWH;
GO

/*==============================================================================
    Customers
==============================================================================*/

IF OBJECT_ID('silver.customers','U') IS NOT NULL
    DROP TABLE silver.customers;
GO

CREATE TABLE silver.customers
(
    customer_id        NVARCHAR(50)    NOT NULL,
    first_name         NVARCHAR(100)   NOT NULL,
    last_name          NVARCHAR(100)   NOT NULL,
    email              NVARCHAR(255)   NOT NULL,
    phone              NVARCHAR(50)    NULL,
    signup_date        DATE            NULL,
    city               NVARCHAR(100)   NOT NULL,
    state              NVARCHAR(100)   NOT NULL,
    country            NVARCHAR(100)   NOT NULL,
    customer_segment   NVARCHAR(50)    NOT NULL,

    dwh_create_date    DATETIME2(7) NOT NULL
        DEFAULT SYSDATETIME()
);
GO

/*==============================================================================
    Products
==============================================================================*/

IF OBJECT_ID('silver.products','U') IS NOT NULL
    DROP TABLE silver.products;
GO

CREATE TABLE silver.products
(
    product_id         NVARCHAR(50)    NOT NULL,
    product_name       NVARCHAR(255)   NOT NULL,
    category           NVARCHAR(100)   NOT NULL,
    sub_category       NVARCHAR(100)   NOT NULL,
    unit_price         DECIMAL(10,2)   NOT NULL,
    supplier           NVARCHAR(200)   NOT NULL,
    discontinued       BIT             NOT NULL,

    dwh_create_date    DATETIME2(7) NOT NULL
        DEFAULT SYSDATETIME()
);
GO

/*==============================================================================
    Stores
==============================================================================*/

IF OBJECT_ID('silver.stores','U') IS NOT NULL
    DROP TABLE silver.stores;
GO

CREATE TABLE silver.stores
(
    store_id           NVARCHAR(50)    NOT NULL,
    store_name         NVARCHAR(200)   NOT NULL,
    region             NVARCHAR(100)   NOT NULL,
    city               NVARCHAR(100)   NOT NULL,
    state              NVARCHAR(100)   NOT NULL,
    country            NVARCHAR(100)   NOT NULL,
    store_type         NVARCHAR(50)    NOT NULL,
    opened_date        DATE            NULL,

    dwh_create_date    DATETIME2(7) NOT NULL
        DEFAULT SYSDATETIME()
);
GO

/*==============================================================================
    Sales
==============================================================================*/

IF OBJECT_ID('silver.sales','U') IS NOT NULL
    DROP TABLE silver.sales;
GO

CREATE TABLE silver.sales
(
    transaction_id     NVARCHAR(50)    NOT NULL,
    order_date         DATE            NULL,
    ship_date          DATE            NULL,
    customer_id        NVARCHAR(50)    NOT NULL,
    product_id         NVARCHAR(50)    NOT NULL,
    store_id           NVARCHAR(50)    NOT NULL,
    quantity           INT             NOT NULL,
    unit_price         DECIMAL(10,2)   NOT NULL,
    discount_pct       DECIMAL(5,2)    NOT NULL,
    payment_method     NVARCHAR(50)    NOT NULL,
    order_status       NVARCHAR(50)    NOT NULL,

    dwh_create_date    DATETIME2(7) NOT NULL
        DEFAULT SYSDATETIME()
);
GO

PRINT '============================================================';
PRINT 'Silver Tables Created Successfully';
PRINT '============================================================';
GO
