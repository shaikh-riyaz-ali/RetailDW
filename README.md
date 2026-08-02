Retail Sales Analytics Data Warehouse & Power BI Dashboard
📌 Project Overview

This project demonstrates an end-to-end Retail Sales Analytics solution using the Medallion Architecture (Bronze → Silver → Gold) in SQL Server and an interactive Power BI dashboard for business reporting.

The project simulates a real-world Business Intelligence workflow by ingesting raw CSV files, transforming and validating data through ETL stored procedures, building a dimensional data warehouse, and creating executive dashboards for decision-making.

🚀 Tech Stack
SQL Server
T-SQL
SQL Server Management Studio (SSMS)
Power BI Desktop
DAX
Star Schema
Git & GitHub
📂 Project Architecture
Retail Sales Analytics
│
├── Bronze Layer
│   ├── Raw CSV Import
│   ├── Stored Procedures
│   ├── ETL Logging
│   └── Error Logging
│
├── Silver Layer
│   ├── Data Cleaning
│   ├── Data Standardization
│   ├── Duplicate Removal
│   ├── Validation
│   └── ETL Logging
│
├── Gold Layer
│   ├── Dimension Tables
│   ├── Fact Table
│   ├── Star Schema
│   ├── Analytical Views
│   └── ETL Logging
│
└── Power BI
    ├── Executive Dashboard
    ├── Customer Analytics
    ├── Product Performance
    └── Store Performance
🏗️ Data Warehouse Architecture
CSV Files
     │
     ▼
Bronze Layer
(Raw Data)
     │
     ▼
Silver Layer
(Clean Data)
     │
     ▼
Gold Layer
(Star Schema)
     │
     ▼
Power BI Dashboard
📁 Folder Structure
Retail-Sales-Analytics
│
├── data
│   ├── customers.csv
│   ├── products.csv
│   ├── stores.csv
│   └── sales.csv
│
├── bronze
│   ├── 01_create_tables.sql
│   ├── 02_load_customers.sql
│   ├── 03_load_products.sql
│   ├── 04_load_stores.sql
│   ├── 05_load_sales.sql
│   └── 06_load_bronze.sql
│
├── silver
│   ├── 01_create_tables.sql
│   ├── 02_load_customers.sql
│   ├── 03_load_products.sql
│   ├── 04_load_stores.sql
│   ├── 05_load_sales.sql
│   ├── 06_validate_silver.sql
│   └── 07_load_silver.sql
│
├── gold
│   ├── 01_create_tables.sql
│   ├── 02_load_dimensions.sql
│   ├── 03_load_fact_sales.sql
│   ├── 04_load_gold.sql
│   └── 05_create_views.sql
│
├── powerbi
│   └── Retail Sales Analytics.pbix
│
├── screenshots
│
└── README.md
📊 Data Model
Dimension Tables
Dim Customer
Dim Product
Dim Store
Dim Date
Fact Table
Fact Sales

The project follows a Star Schema optimized for reporting and analytics.

🔄 ETL Pipeline
Bronze Layer
Purpose

Load raw CSV files into SQL Server without applying business transformations.

Features
BULK INSERT
Stored Procedures
Batch ID Generation
ETL Logging
Error Logging

Tables

bronze.customers
bronze.products
bronze.stores
bronze.sales
Silver Layer
Purpose

Clean and standardize raw data.

Transformations
Remove duplicates
Trim spaces
Convert data types
Handle NULL values
Standardize text
Validate business rules
ETL Logging
Error Logging

Tables

silver.customers
silver.products
silver.stores
silver.sales
Gold Layer
Purpose

Create an analytical data warehouse using a Star Schema.

Dimension Tables

gold.dim_customer
gold.dim_product
gold.dim_store
gold.dim_date

Fact Table

gold.fact_sales
⭐ Gold Layer Features
Surrogate Keys
Foreign Key Relationships
Date Dimension
Sales Fact Table
Star Schema
Analytical Views
📈 Power BI Dashboard

The report contains 4 interactive pages.

1️⃣ Executive Overview

KPIs

Gross Sales
Net Sales
Total Orders
Customers
Average Order Value
Discount Amount

Visuals

Monthly Sales Trend
Sales by Category
Sales by Region
Top Products
Order Status Distribution
2️⃣ Customer Analytics

KPIs

Total Customers
Net Sales
Average Customer Value
Total Orders
Average Quantity

Visuals

Revenue by Customer Segment
Top Customers
Monthly Customer Sales Trend
Revenue by State
Customer Performance Matrix
3️⃣ Product Performance

KPIs

Total Products
Net Sales
Quantity Sold
Average Product Price
Discount Amount

Visuals

Sales by Category
Top Products
Quantity Sold
Sales by Sub-Category
Product Performance Matrix
4️⃣ Store Performance

KPIs

Total Stores
Net Sales
Total Orders
Average Store Sales
Average Order Value

Visuals

Sales by Region
Top Stores
Monthly Sales Trend
Sales by Store Type
Store Performance Matrix
📊 Key Metrics
Gross Sales
Net Sales
Discount Amount
Quantity Sold
Total Orders
Average Order Value (AOV)
Average Customer Value
Average Store Sales
📌 SQL Features Used
Stored Procedures
Common Table Expressions (CTEs)
Window Functions
CASE Expressions
TRY_CONVERT
COALESCE
ISNULL
MERGE / INSERT
BULK INSERT
Error Handling (TRY...CATCH)
Transactions
Dynamic SQL
ETL Logging
📌 Power BI Features
Star Schema
DAX Measures
Interactive Slicers
Bookmarks
Page Navigation
Conditional Formatting
Drill-through
Tooltips
KPI Cards
Matrix Visuals
Custom Theme
📌 Project Workflow
CSV Files
      │
      ▼
Bronze Layer
(Raw Load)
      │
      ▼
Silver Layer
(Clean & Transform)
      │
      ▼
Gold Layer
(Data Warehouse)
      │
      ▼
Power BI Dashboard
      │
      ▼
Business Insights
📷 Dashboard Preview

Add screenshots in the screenshots/ folder and reference them here.

Executive Overview
screenshots/executive_overview.png
Customer Analytics
screenshots/customer_analytics.png
Product Performance
screenshots/product_performance.png
Store Performance
screenshots/store_performance.png
🚀 How to Run the Project
Clone this repository.
Open SQL Server Management Studio.
Create the DWH database.
Execute scripts in the following order:
00_create_database.sql

01_create_schemas.sql

Bronze/
    01_create_tables.sql
    02_load_customers.sql
    03_load_products.sql
    04_load_stores.sql
    05_load_sales.sql
    06_load_bronze.sql

Silver/
    01_create_tables.sql
    02_load_customers.sql
    03_load_products.sql
    04_load_stores.sql
    05_load_sales.sql
    06_validate_silver.sql
    07_load_silver.sql

Gold/
    01_create_tables.sql
    02_load_dimensions.sql
    03_load_fact_sales.sql
    04_load_gold.sql
    05_create_views.sql
Refresh the Power BI report.
📈 Business Outcomes
Built a complete SQL Server data warehouse using the Medallion Architecture.
Automated ETL workflows with stored procedures, batch processing, logging, and error handling.
Implemented a Star Schema to optimize analytical queries.
Developed an interactive four-page Power BI dashboard for executive reporting.
Delivered insights into sales, customers, products, and store performance to support data-driven decision-making.
👨‍💻 Author

Shaikh Riyaz Ali
