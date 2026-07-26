/*
===============================================================================
Stored Procedure: Load Bronze Customers
===============================================================================

Description:
    Loads the customers_raw.csv file into bronze.customers.

Usage:
    EXEC bronze.load_customers @BatchId;

===============================================================================
*/

USE DWH;
GO

CREATE OR ALTER PROCEDURE bronze.load_customers
(
    @BatchId UNIQUEIDENTIFIER
)
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE
        @StartTime   DATETIME2(7),
        @EndTime     DATETIME2(7),
        @DurationMs  INT,
        @RowsLoaded  INT,
        @FilePath    NVARCHAR(500),
        @SqlCommand  NVARCHAR(MAX);

    SET @FilePath = N'D:\data pipeline projrct\retail_dwh_project\bronze\';

    BEGIN TRY

        SET @StartTime = SYSDATETIME();

        PRINT '------------------------------------------------------------';
        PRINT 'Loading Table : bronze.customers';
        PRINT 'Batch ID      : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT 'Start Time    : ' + CONVERT(VARCHAR(23), @StartTime, 121);
        PRINT '------------------------------------------------------------';

        -----------------------------------------------------------------------
        -- Remove Existing Data
        -----------------------------------------------------------------------

        TRUNCATE TABLE bronze.customers;

        -----------------------------------------------------------------------
        -- Bulk Load CSV
        -----------------------------------------------------------------------

        SET @SqlCommand = N'
            BULK INSERT bronze.customers
            FROM ''' + @FilePath + 'customers_raw.csv''
            WITH
            (
                FIRSTROW = 2,
                FIELDTERMINATOR = '','',
                ROWTERMINATOR = ''0x0A'',
                TABLOCK
            );';

        EXEC sp_executesql @SqlCommand;

        -----------------------------------------------------------------------
        -- Row Count
        -----------------------------------------------------------------------

        SELECT
            @RowsLoaded = COUNT(*)
        FROM bronze.customers;

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
            'Bronze Load',
            'Customers',
            @RowsLoaded,
            @StartTime,A
            @EndTime,
            @DurationMs,
            'SUCCESS'
        );

        -----------------------------------------------------------------------
        -- Print Status
        -----------------------------------------------------------------------

        PRINT 'Rows Loaded   : ' + CAST(@RowsLoaded AS NVARCHAR(20));
        PRINT 'End Time      : ' + CONVERT(VARCHAR(23), @EndTime, 121);
        PRINT 'Duration      : ' + CAST(@DurationMs AS NVARCHAR(20)) + ' ms';
        PRINT 'Status        : SUCCESS';
        PRINT '------------------------------------------------------------';

    END TRY

    BEGIN CATCH

        -----------------------------------------------------------------------
        -- Error Log
        -----------------------------------------------------------------------

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
            'Bronze Load',
            OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID),
            'Customers',
            ERROR_NUMBER(),
            ERROR_MESSAGE(),
            ERROR_LINE(),
            ERROR_STATE()
        );

        -----------------------------------------------------------------------
        -- Print Error
        -----------------------------------------------------------------------

        PRINT '------------------------------------------------------------';
        PRINT 'Loading Failed';
        PRINT 'Batch ID      : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT 'Error Number  : ' + CAST(ERROR_NUMBER() AS NVARCHAR(20));
        PRINT 'Error Line    : ' + CAST(ERROR_LINE() AS NVARCHAR(20));
        PRINT 'Error Message : ' + ERROR_MESSAGE();
        PRINT '------------------------------------------------------------';

        THROW;

    END CATCH

END;
GO
