/*
===============================================================================
Stored Procedure: Load Gold Fact Sales
===============================================================================

Description:
    Loads sales transactions from silver.sales into gold.fact_sales.

Actions:
    1. Truncates the fact table.
    2. Looks up surrogate keys from dimensions.
    3. Loads the fact table.
    4. Writes ETL log.
    5. Logs errors.

Usage:
    EXEC gold.load_fact_sales @BatchId;

===============================================================================
*/

USE DWH;
GO

CREATE OR ALTER PROCEDURE gold.load_fact_sales
(
    @BatchId UNIQUEIDENTIFIER
)
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE
        @StartTime DATETIME2(7),
        @EndTime DATETIME2(7),
        @DurationMs INT,
        @RowsLoaded INT;

    BEGIN TRY

        SET @StartTime = SYSDATETIME();

        PRINT '------------------------------------------------------------';
        PRINT 'Loading Table : gold.fact_sales';
        PRINT 'Batch ID      : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT '------------------------------------------------------------';

        -----------------------------------------------------------------------
        -- Remove Existing Data
        -----------------------------------------------------------------------

        TRUNCATE TABLE gold.fact_sales;

        -----------------------------------------------------------------------
        -- Load Fact Table
        -----------------------------------------------------------------------

        INSERT INTO gold.fact_sales
        (
            transaction_id,
            customer_key,
            product_key,
            store_key,
            order_date,
            ship_date,
            quantity,
            unit_price,
            discount_pct,
            payment_method,
            order_status
        )

        SELECT

            s.transaction_id,

            dc.customer_key,

            dp.product_key,

            ds.store_key,

            s.order_date,
            s.ship_date,

            s.quantity,
            s.unit_price,
            s.discount_pct,

            s.payment_method,
            s.order_status

        FROM silver.sales s

        INNER JOIN gold.dim_customers dc
            ON s.customer_id = dc.customer_id

        INNER JOIN gold.dim_products dp
            ON s.product_id = dp.product_id

        INNER JOIN gold.dim_stores ds
            ON s.store_id = ds.store_id;

        -----------------------------------------------------------------------
        -- Statistics
        -----------------------------------------------------------------------

        SELECT
            @RowsLoaded = COUNT(*)
        FROM gold.fact_sales;

        SET @EndTime = SYSDATETIME();

        SET @DurationMs =
            DATEDIFF(MILLISECOND,@StartTime,@EndTime);

        -----------------------------------------------------------------------
        -- ETL Log
        -----------------------------------------------------------------------

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
            'Fact Sales',
            @RowsLoaded,
            @StartTime,
            @EndTime,
            @DurationMs,
            'SUCCESS'
        );

        PRINT 'Rows Loaded : ' + CAST(@RowsLoaded AS NVARCHAR(20));
        PRINT 'Duration    : ' + CAST(@DurationMs AS NVARCHAR(20)) + ' ms';
        PRINT 'Status      : SUCCESS';
        PRINT '------------------------------------------------------------';

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
            OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID),
            'Fact Sales',
            ERROR_NUMBER(),
            ERROR_MESSAGE(),
            ERROR_LINE(),
            ERROR_STATE()
        );

        PRINT '------------------------------------------------------------';
        PRINT 'FACT SALES LOAD FAILED';
        PRINT 'Batch ID      : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT 'Error Number  : ' + CAST(ERROR_NUMBER() AS NVARCHAR(20));
        PRINT 'Error Message : ' + ERROR_MESSAGE();
        PRINT '------------------------------------------------------------';

        THROW;

    END CATCH

END;
GO
