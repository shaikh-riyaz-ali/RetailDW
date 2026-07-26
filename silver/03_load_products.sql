/*
===============================================================================
Stored Procedure: Load Silver Products
===============================================================================

Description:
    Cleans and transforms product data from bronze.products into
    silver.products.

Actions:
    1. Removes duplicate products.
    2. Trims leading/trailing spaces.
    3. Standardizes category and sub-category.
    4. Converts Unit Price to DECIMAL.
    5. Converts Discontinued to BIT.
    6. Replaces NULL/blank values.
    7. Loads clean data into silver.products.
    8. Writes ETL log.

Usage:
    EXEC silver.load_products @BatchId;

===============================================================================
*/

USE DWH;
GO

CREATE OR ALTER PROCEDURE silver.load_products
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
        PRINT 'Loading Table : silver.products';
        PRINT 'Batch ID      : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT '------------------------------------------------------------';

        -----------------------------------------------------------------------
        -- Remove Previous Load
        -----------------------------------------------------------------------

        TRUNCATE TABLE silver.products;

        -----------------------------------------------------------------------
        -- Clean Products
        -----------------------------------------------------------------------

        ;WITH CleanProducts AS
        (
            SELECT

                product_id,
                TRIM(product_name) AS product_name,
                TRIM(category) AS category,
                TRIM(sub_category) AS sub_category,
                TRIM(unit_price) AS unit_price,
                TRIM(supplier) AS supplier,
                TRIM(discontinued) AS discontinued,

                ROW_NUMBER() OVER
                (
                    PARTITION BY product_id
                    ORDER BY product_id
                ) AS rn

            FROM bronze.products
        )

        INSERT INTO silver.products
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

            CASE
                WHEN product_name IS NULL
                  OR product_name = ''
                THEN 'Unknown'
                ELSE product_name
            END,

            CASE
                WHEN category IS NULL
                  OR category = ''
                THEN 'Unknown'
                ELSE category
            END,

            CASE
                WHEN sub_category IS NULL
                  OR sub_category = ''
                THEN 'Unknown'
                ELSE sub_category
            END,

            ISNULL
            (
                TRY_CONVERT(DECIMAL(10,2), unit_price),
                0.00
            ),

            CASE
                WHEN supplier IS NULL
                  OR supplier = ''
                THEN 'Unknown'
                ELSE supplier
            END,

            CASE
                WHEN UPPER(discontinued) IN
                (
                    'YES',
                    'Y',
                    'TRUE',
                    '1'
                )
                THEN 1

                WHEN UPPER(discontinued) IN
                (
                    'NO',
                    'N',
                    'FALSE',
                    '0'
                )
                THEN 0

                ELSE 0
            END

        FROM CleanProducts

        WHERE rn = 1;

        -----------------------------------------------------------------------
        -- Row Count
        -----------------------------------------------------------------------

        SELECT
            @RowsLoaded = COUNT(*)
        FROM silver.products;

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
            'Products',
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
            procedure_name,
            error_number,
            error_message,
            error_line,
            error_state
        )

        VALUES
        (
            OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
            ERROR_NUMBER(),
            ERROR_MESSAGE(),
            ERROR_LINE(),
            ERROR_STATE()
        );

        THROW;

    END CATCH

END;
GO
