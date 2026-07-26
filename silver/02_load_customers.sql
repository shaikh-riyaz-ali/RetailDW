/*
===============================================================================
Stored Procedure: Load Silver Customers
===============================================================================

Description:
    Cleans and transforms customer data from bronze.customers into
    silver.customers.

Actions:
    1. Removes duplicate customers.
    2. Trims leading/trailing spaces.
    3. Standardizes names.
    4. Validates email addresses.
    5. Converts signup date.
    6. Standardizes states.
    7. Standardizes customer segments.
    8. Loads clean data into silver.customers.
    9. Writes ETL log.

Usage:
    EXEC silver.load_customers @BatchId;

===============================================================================
*/

USE DWH;
GO

CREATE OR ALTER PROCEDURE silver.load_customers
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
        PRINT 'Loading Table : silver.customers';
        PRINT 'Batch ID      : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT '------------------------------------------------------------';

        -----------------------------------------------------------------------
        -- Remove Previous Load
        -----------------------------------------------------------------------

        TRUNCATE TABLE silver.customers;

        -----------------------------------------------------------------------
        -- Load Clean Data
        -----------------------------------------------------------------------

        ;WITH CleanCustomers AS
        (
            SELECT
                customer_id,
                TRIM(first_name) AS first_name,
                TRIM(last_name) AS last_name,
                TRIM(email) AS email,
                TRIM(phone) AS phone,
                signup_date,
                TRIM(city) AS city,
                TRIM(state) AS state,
                TRIM(country) AS country,
                TRIM(customer_segment) AS customer_segment,

                ROW_NUMBER() OVER
                (
                    PARTITION BY customer_id
                    ORDER BY customer_id
                ) AS rn

            FROM bronze.customers
        )

        INSERT INTO silver.customers
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

            CASE
                WHEN first_name IS NULL OR first_name='' THEN 'Unknown'
                ELSE first_name
            END,

            CASE
                WHEN last_name IS NULL OR last_name='' THEN 'Unknown'
                ELSE last_name
            END,

            CASE
                WHEN email IS NULL
                     OR email=''
                     OR email NOT LIKE '%_@_%._%'
                THEN 'Unknown'
                ELSE LOWER(email)
            END,

            CASE
                WHEN phone IS NULL OR phone=''
                THEN 'Unknown'
                ELSE phone
            END,

            COALESCE
            (
                TRY_CONVERT(DATE,signup_date,101),
                TRY_CONVERT(DATE,signup_date,23)
            ),

            CASE
                WHEN city IS NULL OR city=''
                THEN 'Unknown'
                ELSE city
            END,

            CASE UPPER(state)

                WHEN 'AB' THEN 'Alberta'
                WHEN 'AZ' THEN 'Arizona'
                WHEN 'BC' THEN 'British Columbia'
                WHEN 'BE' THEN 'Berlin'
                WHEN 'BY' THEN 'Bavaria'
                WHEN 'CA' THEN 'California'
                WHEN 'CO' THEN 'Colorado'
                WHEN 'DL' THEN 'Delhi'
                WHEN 'ENG' THEN 'England'
                WHEN 'HE' THEN 'Hesse'
                WHEN 'HH' THEN 'Hamburg'
                WHEN 'IL' THEN 'Illinois'
                WHEN 'KA' THEN 'Karnataka'
                WHEN 'MA' THEN 'Massachusetts'
                WHEN 'MH' THEN 'Maharashtra'
                WHEN 'NY' THEN 'New York'
                WHEN 'ON' THEN 'Ontario'
                WHEN 'PA' THEN 'Pennsylvania'
                WHEN 'QC' THEN 'Quebec'
                WHEN 'SCT' THEN 'Scotland'
                WHEN 'TG' THEN 'Telangana'
                WHEN 'TN' THEN 'Tamil Nadu'
                WHEN 'TX' THEN 'Texas'
                WHEN 'WA' THEN 'Washington'
                WHEN 'WB' THEN 'West Bengal'

                ELSE 'Unknown'

            END,

            CASE
                WHEN country IS NULL OR country=''
                THEN 'Unknown'
                ELSE country
            END,

            CASE

                WHEN customer_segment IS NULL
                     OR customer_segment=''
                THEN 'Unknown'

                WHEN UPPER(customer_segment)='CONSUMER'
                THEN 'Consumer'

                WHEN UPPER(customer_segment)='CORPORATE'
                THEN 'Corporate'

                WHEN UPPER(customer_segment)='HOME OFFICE'
                THEN 'Home Office'

                ELSE 'Unknown'

            END

        FROM CleanCustomers
        WHERE rn=1;

        -----------------------------------------------------------------------
        -- Row Count
        -----------------------------------------------------------------------

        SELECT
            @RowsLoaded = COUNT(*)
        FROM silver.customers;

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
            'Customers',
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
            'Customers',
            ERROR_NUMBER(),
            ERROR_MESSAGE(),
            ERROR_LINE(),
            ERROR_STATE()
        );

        THROW;

    END CATCH

END;
GO
