/*
===============================================================================
Script: Create Gold Reporting Views
===============================================================================

Description:
    Creates reporting views for Power BI dashboards.

Views:
    1. vw_sales_summary
    2. vw_customer_sales
    3. vw_product_sales
    4. vw_store_sales

===============================================================================
*/

USE DWH;
GO

/*==============================================================================
1. Sales Summary View
==============================================================================*/

CREATE OR ALTER VIEW gold.vw_sales_summary
AS

SELECT

    fs.sales_key,
    fs.transaction_id,

    dd.calendar_date,
    dd.day_name,
    dd.month_name,
    dd.month_number,
    dd.quarter_number,
    dd.year_number,

    dc.customer_id,
    dc.full_name,
    dc.customer_segment,
    dc.city AS customer_city,
    dc.state AS customer_state,

    dp.product_id,
    dp.product_name,
    dp.category,
    dp.sub_category,

    ds.store_id,
    ds.store_name,
    ds.region,
    ds.city AS store_city,
    ds.state AS store_state,

    fs.quantity,
    fs.unit_price,
    fs.discount_pct,
    fs.gross_sales,
    fs.discount_amount,
    fs.net_sales,

    fs.payment_method,
    fs.order_status

FROM gold.fact_sales fs

INNER JOIN gold.dim_date dd
    ON fs.date_key = dd.date_key

INNER JOIN gold.dim_customer dc
    ON fs.customer_key = dc.customer_key

INNER JOIN gold.dim_product dp
    ON fs.product_key = dp.product_key

INNER JOIN gold.dim_store ds
    ON fs.store_key = ds.store_key;

GO


/*==============================================================================
2. Customer Sales View
==============================================================================*/

CREATE OR ALTER VIEW gold.vw_customer_sales
AS

SELECT

    dc.customer_id,
    dc.full_name,
    dc.customer_segment,
    dc.city,
    dc.state,

    COUNT(fs.sales_key) AS total_orders,

    SUM(fs.quantity) AS total_quantity,

    SUM(fs.gross_sales) AS gross_sales,

    SUM(fs.discount_amount) AS total_discount,

    SUM(fs.net_sales) AS net_sales

FROM gold.fact_sales fs

INNER JOIN gold.dim_customer dc
    ON fs.customer_key = dc.customer_key

GROUP BY

    dc.customer_id,
    dc.full_name,
    dc.customer_segment,
    dc.city,
    dc.state;

GO


/*==============================================================================
3. Product Sales View
==============================================================================*/

CREATE OR ALTER VIEW gold.vw_product_sales
AS

SELECT

    dp.product_id,
    dp.product_name,
    dp.category,
    dp.sub_category,

    COUNT(fs.sales_key) AS total_orders,

    SUM(fs.quantity) AS quantity_sold,

    SUM(fs.gross_sales) AS gross_sales,

    SUM(fs.discount_amount) AS total_discount,

    SUM(fs.net_sales) AS net_sales

FROM gold.fact_sales fs

INNER JOIN gold.dim_product dp
    ON fs.product_key = dp.product_key

GROUP BY

    dp.product_id,
    dp.product_name,
    dp.category,
    dp.sub_category;

GO


/*==============================================================================
4. Store Sales View
==============================================================================*/

CREATE OR ALTER VIEW gold.vw_store_sales
AS

SELECT

    ds.store_id,
    ds.store_name,
    ds.region,
    ds.city,
    ds.state,
    ds.store_type,

    COUNT(fs.sales_key) AS total_orders,

    SUM(fs.quantity) AS quantity_sold,

    SUM(fs.gross_sales) AS gross_sales,

    SUM(fs.discount_amount) AS total_discount,

    SUM(fs.net_sales) AS net_sales

FROM gold.fact_sales fs

INNER JOIN gold.dim_store ds
    ON fs.store_key = ds.store_key

GROUP BY

    ds.store_id,
    ds.store_name,
    ds.region,
    ds.city,
    ds.state,
    ds.store_type;

GO
