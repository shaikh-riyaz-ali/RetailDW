/*
===============================================================================
Stored Procedure: Load Gold Date Dimension
===============================================================================

Description:
    Populates gold.dim_date using the date range from silver.sales.

Actions:
    1. Removes existing records.
    2. Generates one row per calendar date.
    3. Creates date attributes.
    4. Writes ETL log.
    5. Logs errors.

Usage:
    EXEC gold.load_dim_date @BatchId;

===============================================================================
*/

USE DWH;
GO

CREATE OR ALTER PROCEDURE gold.load_dim_date
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
        @RowsLoaded INT,
        @MinDate DATE,
        @MaxDate DATE;

    BEGIN TRY

        SET @StartTime = SYSDATETIME();

        PRINT '------------------------------------------------------------';
        PRINT 'Loading Table : gold.dim_date';
        PRINT 'Batch ID      : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT '------------------------------------------------------------';

        -----------------------------------------------------------------------
        -- Get Date Range
        -----------------------------------------------------------------------

        SELECT
            @MinDate = MIN(order_date),
            @MaxDate = MAX(order_date)
        FROM silver.sales;

        -----------------------------------------------------------------------
        -- Remove Existing Data
        -----------------------------------------------------------------------

        DELETE FROM gold.dim_date;

        -----------------------------------------------------------------------
        -- Generate Dates
        -----------------------------------------------------------------------

        ;WITH DateSeries AS
        (
            SELECT @MinDate AS calendar_date

            UNION ALL

            SELECT DATEADD(DAY,1,calendar_date)
            FROM DateSeries
            WHERE calendar_date < @MaxDate
        )

        INSERT INTO gold.dim_date
        (
            date_key,
            calendar_date,
            day_number,
            day_name,
            week_number,
            month_number,
            month_name,
            quarter_number,
            year_number,
            is_weekend
        )

        SELECT

            CONVERT(INT,FORMAT(calendar_date,'yyyyMMdd')),

            calendar_date,

            DAY(calendar_date),

            DATENAME(WEEKDAY,calendar_date),

            DATEPART(WEEK,calendar_date),

            MONTH(calendar_date),

            DATENAME(MONTH,calendar_date),

            DATEPART(QUARTER,calendar_date),

            YEAR(calendar_date),

            CASE
                WHEN DATENAME(WEEKDAY,calendar_date) IN ('Saturday','Sunday')
                THEN 1
                ELSE 0
            END

        FROM DateSeries
        OPTION (MAXRECURSION 32767);

        -----------------------------------------------------------------------
        -- Statistics
        -----------------------------------------------------------------------

        SELECT
            @RowsLoaded = COUNT(*)
        FROM gold.dim_date;

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
            'Dim Date',
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
            OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
            'Dim Date',
            ERROR_NUMBER(),
            ERROR_MESSAGE(),
            ERROR_LINE(),
            ERROR_STATE()
        );

        PRINT '------------------------------------------------------------';
        PRINT 'DATE DIMENSION LOAD FAILED';
        PRINT 'Batch ID      : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT 'Error Number  : ' + CAST(ERROR_NUMBER() AS NVARCHAR(20));
        PRINT 'Error Message : ' + ERROR_MESSAGE();
        PRINT '------------------------------------------------------------';

        THROW;

    END CATCH

END;
GO
