/*
===============================================================================
Stored Procedure: Load Silver Stores
===============================================================================

Description:
    Cleans and transforms store data from bronze.stores into
    silver.stores.

Actions:
    1. Removes duplicate stores.
    2. Trims leading/trailing spaces.
    3. Converts opened_date to DATE.
    4. Standardizes state names.
    5. Standardizes Region.
    6. Replaces NULL/blank values.
    7. Loads clean data into silver.stores.
    8. Writes ETL log.

Usage:
    EXEC silver.load_stores @BatchId;

===============================================================================
*/

USE DWH;
GO

CREATE OR ALTER PROCEDURE silver.load_stores
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
        PRINT 'Loading Table : silver.stores';
        PRINT 'Batch ID      : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT '------------------------------------------------------------';

        -----------------------------------------------------------------------
        -- Remove Previous Load
        -----------------------------------------------------------------------

        TRUNCATE TABLE silver.stores;

        -----------------------------------------------------------------------
        -- Clean Stores
        -----------------------------------------------------------------------

        ;WITH CleanStores AS
        (
            SELECT

                store_id,
                TRIM(store_name) AS store_name,
                TRIM(region) AS region,
                TRIM(city) AS city,
                TRIM(state) AS state,
                TRIM(country) AS country,
                TRIM(store_type) AS store_type,
                TRIM(opened_date) AS opened_date,

                ROW_NUMBER() OVER
                (
                    PARTITION BY store_id
                    ORDER BY store_id
                ) AS rn

            FROM bronze.stores
        )

        INSERT INTO silver.stores
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

            CASE
                WHEN store_name IS NULL
                  OR store_name = ''
                THEN 'Unknown'
                ELSE store_name
            END,

            CASE
                WHEN region IS NULL
                  OR region = ''
                THEN 'Unknown'
                ELSE region
            END,

            CASE
                WHEN city IS NULL
                  OR city = ''
                THEN 'Unknown'
                ELSE city
            END,

            CASE UPPER(state)

                WHEN 'AB'  THEN 'Alberta'
                WHEN 'AZ'  THEN 'Arizona'
                WHEN 'BC'  THEN 'British Columbia'
                WHEN 'BE'  THEN 'Berlin'
                WHEN 'BY'  THEN 'Bavaria'
                WHEN 'CA'  THEN 'California'
                WHEN 'CO'  THEN 'Colorado'
                WHEN 'DL'  THEN 'Delhi'
                WHEN 'ENG' THEN 'England'
                WHEN 'HE'  THEN 'Hesse'
                WHEN 'HH'  THEN 'Hamburg'
                WHEN 'IL'  THEN 'Illinois'
                WHEN 'KA'  THEN 'Karnataka'
                WHEN 'MA'  THEN 'Massachusetts'
                WHEN 'MH'  THEN 'Maharashtra'
                WHEN 'NY'  THEN 'New York'
                WHEN 'ON'  THEN 'Ontario'
                WHEN 'PA'  THEN 'Pennsylvania'
                WHEN 'QC'  THEN 'Quebec'
                WHEN 'SCT' THEN 'Scotland'
                WHEN 'TG'  THEN 'Telangana'
                WHEN 'TN'  THEN 'Tamil Nadu'
                WHEN 'TX'  THEN 'Texas'
                WHEN 'WA'  THEN 'Washington'
                WHEN 'WB'  THEN 'West Bengal'
                ELSE 'Unknown'

            END,

            CASE
                WHEN country IS NULL
                  OR country = ''
                THEN 'Unknown'
                ELSE country
            END,

            CASE
                WHEN store_type IS NULL
                  OR store_type = ''
                THEN 'Unknown'
                ELSE store_type
            END,

            COALESCE
            (
                TRY_CONVERT(DATE, opened_date, 101),   -- MM/DD/YYYY
                TRY_CONVERT(DATE, opened_date, 23)     -- YYYY-MM-DD
            )

        FROM CleanStores

        WHERE rn = 1;

        -----------------------------------------------------------------------
        -- Row Count
        -----------------------------------------------------------------------

        SELECT
            @RowsLoaded = COUNT(*)
        FROM silver.stores;

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
            'Stores',
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
            'Stores',
            ERROR_NUMBER(),
            ERROR_MESSAGE(),
            ERROR_LINE(),
            ERROR_STATE()
        );

        THROW;

    END CATCH

END;
GO
