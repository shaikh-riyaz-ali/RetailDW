/*
===============================================================================
Stored Procedure: Load Gold Dimensions
===============================================================================

Description:
    Loads all Gold Dimension tables from the Silver layer.

Dimensions:
    • dim_customers
    • dim_products
    • dim_stores

Usage:
    EXEC gold.load_dimensions @BatchId;

===============================================================================
*/

USE DWH;
GO

CREATE OR ALTER PROCEDURE gold.load_dimensions
(
    @BatchId UNIQUEIDENTIFIER
)
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE
        @StartTime DATETIME2(7),
        @EndTime DATETIME2(7),
        @DurationMs INT;

    BEGIN TRY

        SET @StartTime = SYSDATETIME();

        PRINT '============================================================';
        PRINT 'LOADING GOLD DIMENSIONS';
        PRINT 'Batch ID : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT '============================================================';

        -----------------------------------------------------------------------
        -- Customer Dimension
        -----------------------------------------------------------------------

        PRINT '';
        PRINT 'Loading gold.dim_customers...';

        TRUNCATE TABLE gold.dim_customers;

        INSERT INTO gold.dim_customers
        (
            customer_id,
            first_name,
            last_name,
            email,
            phone,
            signup_date,
            city,
            state,
            country,
            customer_segment
        )

        SELECT
            customer_id,
            first_name,
            last_name,
            email,
            phone,
            signup_date,
            city,
            state,
            country,
            customer_segment
        FROM silver.customers;

        PRINT 'Customers Loaded : ' + CAST(@@ROWCOUNT AS NVARCHAR(20));

        -----------------------------------------------------------------------
        -- Product Dimension
        -----------------------------------------------------------------------

        PRINT '';
        PRINT 'Loading gold.dim_products...';

        TRUNCATE TABLE gold.dim_products;

        INSERT INTO gold.dim_products
        (
            product_id,
            product_name,
            category,
            sub_category,
            unit_price,
            supplier,
            discontinued
        )

        SELECT
            product_id,
            product_name,
            category,
            sub_category,
            unit_price,
            supplier,
            discontinued
        FROM silver.products;

        PRINT 'Products Loaded : ' + CAST(@@ROWCOUNT AS NVARCHAR(20));

        -----------------------------------------------------------------------
        -- Store Dimension
        -----------------------------------------------------------------------

        PRINT '';
        PRINT 'Loading gold.dim_stores...';

        TRUNCATE TABLE gold.dim_stores;

        INSERT INTO gold.dim_stores
        (
            store_id,
            store_name,
            region,
            city,
            state,
            country,
            store_type,
            opened_date
        )

        SELECT
            store_id,
            store_name,
            region,
            city,
            state,
            country,
            store_type,
            opened_date
        FROM silver.stores;

        PRINT 'Stores Loaded : ' + CAST(@@ROWCOUNT AS NVARCHAR(20));

        -----------------------------------------------------------------------
        -- ETL Log
        -----------------------------------------------------------------------

        SET @EndTime = SYSDATETIME();

        SET @DurationMs =
            DATEDIFF(MILLISECOND,@StartTime,@EndTime);

        INSERT INTO etl.etl_log
        (
            batch_id,
            process_name,
            table_name,
            rows_loaded,
            start_time,
            end_time,
            duration_ms,
            status
        )
        VALUES
        (
            @BatchId,
            'Gold Load',
            'Dimensions',
            (
                (SELECT COUNT(*) FROM gold.dim_customers)
              + (SELECT COUNT(*) FROM gold.dim_products)
              + (SELECT COUNT(*) FROM gold.dim_stores)
            ),
            @StartTime,
            @EndTime,
            @DurationMs,
            'SUCCESS'
        );

        PRINT '';
        PRINT 'Gold Dimensions Loaded Successfully';

    END TRY

    BEGIN CATCH

        INSERT INTO etl.error_log
        (
            batch_id,
            process_name,
            procedure_name,
            table_name,
            error_number,
            error_message,
            error_line,
            error_state
        )
        VALUES
        (
            @BatchId,
            'Gold Load',
            OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
            'Dimensions',
            ERROR_NUMBER(),
            ERROR_MESSAGE(),
            ERROR_LINE(),
            ERROR_STATE()
        );

        THROW;

    END CATCH

END;
GO
