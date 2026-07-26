/*
===============================================================================
Stored Procedure : Load Silver Sales
===============================================================================

Description:
    Cleans and transforms sales data from bronze.sales into silver.sales.

Business Rules:
    • Remove duplicate transactions.
    • Trim whitespace.
    • Convert dates to DATE datatype.
    • Standardize payment methods.
    • Standardize order status.
    • Replace invalid numeric values.
    • Log ETL execution.
    • Log errors.

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
        @StartTime  DATETIME2(7),
        @EndTime    DATETIME2(7),
        @DurationMs INT,
        @RowsLoaded INT;

    BEGIN TRY

        SET @StartTime = SYSDATETIME();

        PRINT '------------------------------------------------------------';
        PRINT 'Loading Table : silver.sales';
        PRINT 'Batch ID      : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT '------------------------------------------------------------';

        -----------------------------------------------------------------------
        -- Remove Previous Data
        -----------------------------------------------------------------------

        TRUNCATE TABLE silver.sales;

        -----------------------------------------------------------------------
        -- Clean Bronze Sales
        -----------------------------------------------------------------------

        ;WITH CleanSales AS
        (
            SELECT

                transaction_id,
                TRIM(order_date)      AS order_date,
                TRIM(ship_date)       AS ship_date,
                TRIM(customer_id)     AS customer_id,
                TRIM(product_id)      AS product_id,
                TRIM(store_id)        AS store_id,
                TRIM(quantity)        AS quantity,
                TRIM(unit_price)      AS unit_price,
                TRIM(discount_pct)    AS discount_pct,
                TRIM(payment_method)  AS payment_method,
                TRIM(order_status)    AS order_status,

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

            -------------------------------------------------------------------
            -- Transaction
            -------------------------------------------------------------------

            transaction_id,

            -------------------------------------------------------------------
            -- Order Date
            -------------------------------------------------------------------

            COALESCE
            (
                TRY_CONVERT(DATE, order_date, 101),   -- MM/DD/YYYY
                TRY_CONVERT(DATE, order_date, 23),    -- YYYY-MM-DD
                TRY_CONVERT(DATE, order_date, 106)    -- DD-MMM-YYYY
            ) AS order_date,

            -------------------------------------------------------------------
            -- Ship Date
            -------------------------------------------------------------------

            CASE

                WHEN
                    COALESCE
                    (
                        TRY_CONVERT(DATE, ship_date,101),
                        TRY_CONVERT(DATE, ship_date,23),
                        TRY_CONVERT(DATE, ship_date,106)
                    )
                    <
                    COALESCE
                    (
                        TRY_CONVERT(DATE, order_date,101),
                        TRY_CONVERT(DATE, order_date,23),
                        TRY_CONVERT(DATE, order_date,106)
                    )

                THEN NULL

                ELSE
                    COALESCE
                    (
                        TRY_CONVERT(DATE, ship_date,101),
                        TRY_CONVERT(DATE, ship_date,23),
                        TRY_CONVERT(DATE, ship_date,106)
                    )

            END,

            -------------------------------------------------------------------
            -- Customer
            -------------------------------------------------------------------

            ISNULL(NULLIF(customer_id,''),'Unknown'),

            -------------------------------------------------------------------
            -- Product
            -------------------------------------------------------------------

            ISNULL(NULLIF(product_id,''),'Unknown'),

            -------------------------------------------------------------------
            -- Store
            -------------------------------------------------------------------

            ISNULL(NULLIF(store_id,''),'Unknown'),

            -------------------------------------------------------------------
            -- Quantity
            -------------------------------------------------------------------

            CASE

                WHEN TRY_CONVERT(INT,quantity) IS NULL THEN 0
                WHEN TRY_CONVERT(INT,quantity) < 0 THEN 0
                ELSE TRY_CONVERT(INT,quantity)

            END,

            -------------------------------------------------------------------
            -- Unit Price
            -------------------------------------------------------------------

            CASE

                WHEN TRY_CONVERT(DECIMAL(10,2),unit_price) IS NULL THEN 0.00
                WHEN TRY_CONVERT(DECIMAL(10,2),unit_price) < 0 THEN 0.00
                ELSE TRY_CONVERT(DECIMAL(10,2),unit_price)

            END,

            -------------------------------------------------------------------
            -- Discount
            -------------------------------------------------------------------

            CASE

                WHEN TRY_CONVERT(DECIMAL(5,2),discount_pct) IS NULL THEN 0
                WHEN TRY_CONVERT(DECIMAL(5,2),discount_pct) < 0 THEN 0
                WHEN TRY_CONVERT(DECIMAL(5,2),discount_pct) > 1 THEN 1
                ELSE TRY_CONVERT(DECIMAL(5,2),discount_pct)

            END,

            -------------------------------------------------------------------
            -- Payment Method
            -------------------------------------------------------------------

            CASE

                WHEN payment_method IS NULL
                     OR payment_method = ''
                    THEN 'Unknown'

                WHEN UPPER(payment_method)='CREDIT CARD'
                    THEN 'Credit Card'

                WHEN UPPER(payment_method)='DEBIT CARD'
                    THEN 'Debit Card'

                WHEN UPPER(payment_method)='CASH'
                    THEN 'Cash'

                WHEN UPPER(payment_method)='COD'
                    THEN 'COD'

                WHEN UPPER(payment_method)='GIFT CARD'
                    THEN 'Gift Card'

                ELSE 'Other'

            END,

            -------------------------------------------------------------------
            -- Order Status
            -------------------------------------------------------------------

            CASE

                WHEN UPPER(order_status)='COMPLETED'
                    THEN 'Completed'

                WHEN UPPER(order_status)='RETURNED'
                    THEN 'Returned'

                WHEN UPPER(order_status)='REFUNDED'
                    THEN 'Refunded'

                WHEN UPPER(order_status)='PENDING'
                    THEN 'Pending'

                WHEN UPPER(order_status)='CANCELLED'
                    THEN 'Cancelled'

                WHEN UPPER(order_status)='PROCESSING'
                    THEN 'Processing'

                WHEN UPPER(order_status)='SHIPPED'
                    THEN 'Shipped'

                WHEN UPPER(order_status)='DELIVERED'
                    THEN 'Delivered'

                ELSE 'Unknown'

            END

        FROM CleanSales

        WHERE rn = 1;

        -----------------------------------------------------------------------
        -- ETL Statistics
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
            'Silver Load',
            OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID),
            'Sales',
            ERROR_NUMBER(),
            ERROR_MESSAGE(),
            ERROR_LINE(),
            ERROR_STATE()
        );

        PRINT '------------------------------------------------------------';
        PRINT 'Loading Failed';
        PRINT 'Table      : Sales';
        PRINT 'Batch ID   : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT 'Error      : ' + ERROR_MESSAGE();
        PRINT '------------------------------------------------------------';

        THROW;

    END CATCH

END;
GO
