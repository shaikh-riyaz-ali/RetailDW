/*
===============================================================================
Stored Procedure: Load Silver Sales
===============================================================================

Description:
    Cleans and transforms sales data from bronze.sales into
    silver.sales.

Actions:
    1. Removes duplicate transactions.
    2. Converts dates.
    3. Converts numeric columns.
    4. Standardizes payment methods.
    5. Standardizes order status.
    6. Replaces NULL/blank values.
    7. Loads clean data into silver.sales.
    8. Writes ETL log.

Usage:
    EXEC silver.load_sales @BatchId;

===============================================================================
*/

USE DWH;
GO

CREATE OR ALTER PROCEDURE silver.load_sales
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
        PRINT 'Loading Table : silver.sales';
        PRINT 'Batch ID      : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT '------------------------------------------------------------';

        -----------------------------------------------------------------------
        -- Remove Previous Load
        -----------------------------------------------------------------------

        TRUNCATE TABLE silver.sales;

        -----------------------------------------------------------------------
        -- Clean Sales
        -----------------------------------------------------------------------

        ;WITH CleanSales AS
        (
            SELECT

                transaction_id,
                TRIM(order_date) AS order_date,
                TRIM(ship_date) AS ship_date,
                TRIM(customer_id) AS customer_id,
                TRIM(product_id) AS product_id,
                TRIM(store_id) AS store_id,
                TRIM(quantity) AS quantity,
                TRIM(unit_price) AS unit_price,
                TRIM(discount_pct) AS discount_pct,
                TRIM(payment_method) AS payment_method,
                TRIM(order_status) AS order_status,

                ROW_NUMBER() OVER
                (
                    PARTITION BY transaction_id
                    ORDER BY transaction_id
                ) AS rn

            FROM bronze.sales
        )

        INSERT INTO silver.sales
        (
            transaction_id,
            order_date,
            ship_date,
            customer_id,
            product_id,
            store_id,
            quantity,
            unit_price,
            discount_pct,
            payment_method,
            order_status
        )

        SELECT

            transaction_id,

            -------------------------------------------------------------------
            -- Order Date
            -------------------------------------------------------------------

            COALESCE
            (
                TRY_CONVERT(DATE,order_date,101),
                TRY_CONVERT(DATE,order_date,23)
            ),

            -------------------------------------------------------------------
            -- Ship Date
            -------------------------------------------------------------------

            COALESCE
            (
                TRY_CONVERT(DATE,ship_date,101),
                TRY_CONVERT(DATE,ship_date,23)
            ),

            -------------------------------------------------------------------
            -- Customer
            -------------------------------------------------------------------

            CASE
                WHEN customer_id IS NULL OR customer_id=''
                THEN 'Unknown'
                ELSE customer_id
            END,

            -------------------------------------------------------------------
            -- Product
            -------------------------------------------------------------------

            CASE
                WHEN product_id IS NULL OR product_id=''
                THEN 'Unknown'
                ELSE product_id
            END,

            -------------------------------------------------------------------
            -- Store
            -------------------------------------------------------------------

            CASE
                WHEN store_id IS NULL OR store_id=''
                THEN 'Unknown'
                ELSE store_id
            END,

            -------------------------------------------------------------------
            -- Quantity
            -------------------------------------------------------------------

            ISNULL
            (
                TRY_CONVERT(INT,quantity),
                0
            ),

            -------------------------------------------------------------------
            -- Unit Price
            -------------------------------------------------------------------

            ISNULL
            (
                TRY_CONVERT(DECIMAL(10,2),unit_price),
                0.00
            ),

            -------------------------------------------------------------------
            -- Discount
            -------------------------------------------------------------------

            ISNULL
            (
                TRY_CONVERT(DECIMAL(5,2),discount_pct),
                0.00
            ),

            -------------------------------------------------------------------
            -- Payment Method
            -------------------------------------------------------------------

            CASE
                WHEN payment_method IS NULL
                     OR payment_method=''
                THEN 'Unknown'

                ELSE payment_method
            END,

            -------------------------------------------------------------------
            -- Order Status
            -------------------------------------------------------------------

            CASE

                WHEN UPPER(order_status)='DELIVERED'
                THEN 'Delivered'

                WHEN UPPER(order_status)='SHIPPED'
                THEN 'Shipped'

                WHEN UPPER(order_status)='PROCESSING'
                THEN 'Processing'

                WHEN UPPER(order_status)='CANCELLED'
                THEN 'Cancelled'

                WHEN UPPER(order_status)='RETURNED'
                THEN 'Returned'

                ELSE 'Unknown'

            END

        FROM CleanSales

        WHERE rn = 1;

        -----------------------------------------------------------------------
        -- Row Count
        -----------------------------------------------------------------------

        SELECT
            @RowsLoaded = COUNT(*)
        FROM silver.sales;

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
            'Silver Load',
            'Sales',
            @RowsLoaded,
            @StartTime,
            @EndTime,
            @DurationMs,
            'SUCCESS'
        );

        PRINT 'Rows Loaded : ' + CAST(@RowsLoaded AS NVARCHAR(20));
        PRINT 'Duration    : ' + CAST(@DurationMs AS NVARCHAR(20)) + ' ms';
        PRINT 'Status      : SUCCESS';

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
            'Silver Load',
            OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID),
            'Sales',
            ERROR_NUMBER(),
            ERROR_MESSAGE(),
            ERROR_LINE(),
            ERROR_STATE()
        );

        THROW;

    END CATCH

END;
GO
