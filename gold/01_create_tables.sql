/*
===============================================================================
DDL Script : Create Gold Tables
===============================================================================

Description:
    Creates Dimension and Fact tables for the Gold layer.

Tables:
    1. gold.dim_customer
    2. gold.dim_product
    3. gold.dim_store
    4. gold.dim_date
    5. gold.fact_sales

===============================================================================
*/

USE DWH;
GO

/*===========================================================================
    Drop Existing Tables
===========================================================================*/

IF OBJECT_ID('gold.fact_sales','U') IS NOT NULL
    DROP TABLE gold.fact_sales;
GO

IF OBJECT_ID('gold.dim_customer','U') IS NOT NULL
    DROP TABLE gold.dim_customer;
GO

IF OBJECT_ID('gold.dim_product','U') IS NOT NULL
    DROP TABLE gold.dim_product;
GO

IF OBJECT_ID('gold.dim_store','U') IS NOT NULL
    DROP TABLE gold.dim_store;
GO

IF OBJECT_ID('gold.dim_date','U') IS NOT NULL
    DROP TABLE gold.dim_date;
GO

/*===========================================================================
    Customer Dimension
===========================================================================*/

CREATE TABLE gold.dim_customer
(
    customer_key       INT IDENTITY(1,1) PRIMARY KEY,

    customer_id        NVARCHAR(50) NOT NULL,
    first_name         NVARCHAR(100),
    last_name          NVARCHAR(100),
    full_name          NVARCHAR(250),
    email              NVARCHAR(255),
    phone              NVARCHAR(50),
    signup_date        DATE,
    city               NVARCHAR(100),
    state              NVARCHAR(100),
    country            NVARCHAR(100),
    customer_segment   NVARCHAR(100),

    dwh_create_date    DATETIME2 DEFAULT SYSDATETIME()
);
GO

/*===========================================================================
    Product Dimension
===========================================================================*/

CREATE TABLE gold.dim_product
(
    product_key        INT IDENTITY(1,1) PRIMARY KEY,

    product_id         NVARCHAR(50) NOT NULL,
    product_name       NVARCHAR(255),
    category           NVARCHAR(100),
    sub_category       NVARCHAR(100),
    supplier           NVARCHAR(150),
    unit_price         DECIMAL(10,2),
    discontinued       BIT,

    dwh_create_date    DATETIME2 DEFAULT SYSDATETIME()
);
GO

/*===========================================================================
    Store Dimension
===========================================================================*/

CREATE TABLE gold.dim_store
(
    store_key          INT IDENTITY(1,1) PRIMARY KEY,

    store_id           NVARCHAR(50) NOT NULL,
    store_name         NVARCHAR(200),
    region             NVARCHAR(100),
    city               NVARCHAR(100),
    state              NVARCHAR(100),
    country            NVARCHAR(100),
    store_type         NVARCHAR(100),
    opened_date        DATE,

    dwh_create_date    DATETIME2 DEFAULT SYSDATETIME()
);
GO

/*===========================================================================
    Date Dimension
===========================================================================*/

CREATE TABLE gold.dim_date
(
    date_key           INT PRIMARY KEY,

    calendar_date      DATE NOT NULL,

    day_number         TINYINT,
    day_name           NVARCHAR(20),

    week_number        TINYINT,

    month_number       TINYINT,
    month_name         NVARCHAR(20),

    quarter_number     TINYINT,

    year_number        SMALLINT,

    is_weekend         BIT,

    dwh_create_date    DATETIME2 DEFAULT SYSDATETIME()
);
GO

/*===========================================================================
    Sales Fact
===========================================================================*/

CREATE TABLE gold.fact_sales
(
    sales_key          BIGINT IDENTITY(1,1) PRIMARY KEY,

    transaction_id     NVARCHAR(50),

    date_key           INT NOT NULL,
    customer_key       INT NOT NULL,
    product_key        INT NOT NULL,
    store_key          INT NOT NULL,

    quantity           INT,
    unit_price         DECIMAL(10,2),
    discount_pct       DECIMAL(5,2),

    gross_sales        DECIMAL(18,2),
    discount_amount    DECIMAL(18,2),
    net_sales          DECIMAL(18,2),

    payment_method     NVARCHAR(50),
    order_status       NVARCHAR(50),

    dwh_create_date    DATETIME2 DEFAULT SYSDATETIME()
);
GO

/*===========================================================================
    Foreign Keys
===========================================================================*/

ALTER TABLE gold.fact_sales
ADD CONSTRAINT FK_fact_customer
FOREIGN KEY (customer_key)
REFERENCES gold.dim_customer(customer_key);
GO

ALTER TABLE gold.fact_sales
ADD CONSTRAINT FK_fact_product
FOREIGN KEY (product_key)
REFERENCES gold.dim_product(product_key);
GO

ALTER TABLE gold.fact_sales
ADD CONSTRAINT FK_fact_store
FOREIGN KEY (store_key)
REFERENCES gold.dim_store(store_key);
GO

ALTER TABLE gold.fact_sales
ADD CONSTRAINT FK_fact_date
FOREIGN KEY (date_key)
REFERENCES gold.dim_date(date_key);
GO

PRINT '============================================================';
PRINT 'Gold Tables Created Successfully';
PRINT '============================================================';
GO
