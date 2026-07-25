/*
===============================================================================
Stored Procedure: Load Bronze sales
===============================================================================

Description:
    Loads the customers_raw.csv file into bronze.sales.

Actions:
    1. Truncates the Bronze table.
    2. Loads the CSV file using BULK INSERT.
    3. Displays rows loaded and execution time.

Usage:
    EXEC bronze.load_sales;

===============================================================================
*/

USE DWH;
GO

CREATE OR ALTER PROCEDURE bronze.load_sales
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE
        @StartTime DATETIME2(0),
        @EndTime DATETIME2(0),
        @FilePath NVARCHAR(500),
        @SqlCommand NVARCHAR(MAX);

    SET @FilePath = N'D:\data pipeline projrct\retail_dwh_project\bronze\';

    BEGIN TRY

        SET @StartTime = SYSDATETIME();

        PRINT '------------------------------------------------------------';
        PRINT 'Loading bronze.sales';
        PRINT '------------------------------------------------------------';

        TRUNCATE TABLE bronze.sales;

        SET @SqlCommand = N'
        BULK INSERT bronze.sales
        FROM ''' + @FilePath + 'sales_raw.csv''
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR='','',
            ROWTERMINATOR=''0x0A'',
            TABLOCK
        );';

        EXEC sp_executesql @SqlCommand;

        SET @EndTime = SYSDATETIME();

        PRINT 'Rows Loaded : '
            + CAST(@@ROWCOUNT AS NVARCHAR(20));

        PRINT 'Duration    : '
            + CAST(DATEDIFF(SECOND,@StartTime,@EndTime) AS NVARCHAR(20))
            + ' Seconds';

        PRINT 'sales Loaded Successfully';
        PRINT '------------------------------------------------------------';

    END TRY

    BEGIN CATCH

        PRINT 'Error Loading bronze.sales';
        PRINT ERROR_MESSAGE();

        THROW;

    END CATCH

END;
GO
