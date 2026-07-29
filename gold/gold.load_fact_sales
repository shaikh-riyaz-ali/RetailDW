/*
===============================================================================
Stored Procedure: Load Gold Fact Sales
===============================================================================

Description:
    Loads sales transactions from silver.sales into gold.fact_sales.

Actions:
    1. Truncates the fact table.
    2. Looks up surrogate keys from dimensions.
    3. Calculates Gross Sales, Discount Amount and Net Sales.
    4. Loads the fact table.
    5. Writes ETL log.
    6. Logs errors.

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
            date_key,
            customer_key,
            product_key,
            store_key,
            quantity,
            unit_price,
            discount_pct,
            gross_sales,
            discount_amount,
            net_sales,
            payment_method,
            order_status
        )

        SELECT

            s.transaction_id,

            d.date_key,

            c.customer_key,

            p.product_key,

            st.store_key,

            s.quantity,

            s.unit_price,

            s.discount_pct,

            -------------------------------------------------------------------
            -- Gross Sales
            -------------------------------------------------------------------

            s.quantity * s.unit_price,

            -------------------------------------------------------------------
            -- Discount Amount
            -------------------------------------------------------------------

            (s.quantity * s.unit_price) * s.discount_pct,

            -------------------------------------------------------------------
            -- Net Sales
            -------------------------------------------------------------------

            (s.quantity * s.unit_price)
                -
            ((s.quantity * s.unit_price) * s.discount_pct),

            s.payment_method,

            s.order_status

            FROM silver.sales s
            
            INNER JOIN gold.dim_customer c
                ON s.customer_id = c.customer_id
            
            INNER JOIN gold.dim_product p
                ON s.product_id = p.product_id
            
            INNER JOIN gold.dim_store st
                ON s.store_id = st.store_id
            
            INNER JOIN gold.dim_date d
                ON s.order_date = d.calendar_date;

        -----------------------------------------------------------------------
        -- Statistics
        -----------------------------------------------------------------------

        SELECT
            @RowsLoaded = COUNT(*)
        FROM gold.fact_sales;

        SET @EndTime = SYSDATETIME();

        SET @DurationMs =
            DATEDIFF(MILLISECOND, @StartTime, @EndTime);

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
