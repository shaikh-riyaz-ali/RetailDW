/*
===============================================================================
Stored Procedure: Load Bronze Sales
===============================================================================

Description:
    Loads the sales_raw.csv file into bronze.sales.

Actions:
    1. Truncates the Bronze table.
    2. Loads the CSV file using BULK INSERT.
    3. Logs execution details into ETL log.
    4. Logs errors into Error log.

Usage:
    EXEC bronze.load_sales @BatchId;

===============================================================================
*/

USE DWH;
GO

CREATE OR ALTER PROCEDURE bronze.load_sales
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
        PRINT 'Loading Table : bronze.sales';
        PRINT 'Batch ID      : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT 'Start Time    : ' + CONVERT(VARCHAR(23), @StartTime, 121);
        PRINT '------------------------------------------------------------';

        -----------------------------------------------------------------------
        -- Remove Existing Data
        -----------------------------------------------------------------------
        TRUNCATE TABLE bronze.sales;

        -----------------------------------------------------------------------
        -- Build BULK INSERT Statement
        -----------------------------------------------------------------------
        SET @SqlCommand = N'
        BULK INSERT bronze.sales
        FROM ''' + @FilePath + 'sales_raw.csv''
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''0x0A'',
            TABLOCK
        );';

        -----------------------------------------------------------------------
        -- Execute BULK INSERT
        -----------------------------------------------------------------------
        EXEC sp_executesql @SqlCommand;

        -----------------------------------------------------------------------
        -- Count Rows Loaded
        -----------------------------------------------------------------------
        SELECT
            @RowsLoaded = COUNT(*)
        FROM bronze.sales;

        -----------------------------------------------------------------------
        -- Calculate Duration
        -----------------------------------------------------------------------
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
            'Sales',
            @RowsLoaded,
            @StartTime,
            @EndTime,
            @DurationMs,
            'SUCCESS'
        );

        -----------------------------------------------------------------------
        -- Console Output
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
            procedure_name,
            error_number,
            error_message,
            error_line,
            error_state
        )
        VALUES
        (
            OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID),
            ERROR_NUMBER(),
            ERROR_MESSAGE(),
            ERROR_LINE(),
            ERROR_STATE()
        );

        -----------------------------------------------------------------------
        -- Console Output
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
