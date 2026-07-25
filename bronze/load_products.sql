/*
===============================================================================
Stored Procedure: Load Bronze Products
===============================================================================

Description:
    Loads the products_raw.csv file into bronze.products.

Actions:
    1. Truncates the Bronze table.
    2. Loads the CSV file using BULK INSERT.
    3. Displays rows loaded and execution time.

Usage:
    EXEC bronze.load_products;

===============================================================================
*/

USE DWH;
GO

CREATE OR ALTER PROCEDURE bronze.load_products
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @StartTime   DATETIME2(0),
        @EndTime     DATETIME2(0),
        @FilePath    NVARCHAR(500),
        @RowsLoaded  INT,
        @SqlCommand  NVARCHAR(MAX);

    SET @FilePath = N'D:\data pipeline projrct\retail_dwh_project\bronze\';

    BEGIN TRY

        SET @StartTime = SYSDATETIME();

        PRINT '------------------------------------------------------------';
        PRINT 'Loading bronze.products';
        PRINT '------------------------------------------------------------';

        -- Remove existing data
        TRUNCATE TABLE bronze.products;

        -- Build BULK INSERT command
        SET @SqlCommand = N'
            BULK INSERT bronze.products
            FROM ''' + @FilePath + 'products_raw.csv''
            WITH
            (
                FIRSTROW = 2,
                FIELDTERMINATOR = '','',
                ROWTERMINATOR = ''0x0A'',
                TABLOCK
            );';

        -- Execute BULK INSERT
        EXEC sp_executesql @SqlCommand;

        -- Count rows loaded
        SELECT
            @RowsLoaded = COUNT(*)
        FROM bronze.products;

        SET @EndTime = SYSDATETIME();

        PRINT 'Rows Loaded : ' + CAST(@RowsLoaded AS NVARCHAR(20));
        PRINT 'Duration    : '
            + CAST(DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS NVARCHAR(20))
            + ' ms';

        -- Log successful execution
        INSERT INTO etl.etl_log
        (
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
            'Bronze Load',
            'Products',
            @RowsLoaded,
            @StartTime,
            @EndTime,
            DATEDIFF(MILLISECOND, @StartTime, @EndTime),
            'SUCCESS'
        );

        PRINT 'Products Loaded Successfully';
        PRINT '------------------------------------------------------------';

    END TRY
    BEGIN CATCH

        -- Log error details
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
            OBJECT_NAME(@@PROCID),
            ERROR_NUMBER(),
            ERROR_MESSAGE(),
            ERROR_LINE(),
            ERROR_STATE()
        );

        PRINT 'Error Loading bronze.products';
        PRINT ERROR_MESSAGE();

        THROW;

    END CATCH

END;
GO
