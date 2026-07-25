/*
===============================================================================
Stored Procedure: Load Bronze Customers
===============================================================================

Description:
    Loads the customers_raw.csv file into bronze.customers.

Actions:
    1. Truncates the Bronze table.
    2. Loads the CSV file using BULK INSERT.
    3. Displays rows loaded and execution time.

Usage:
    EXEC bronze.load_customers;

===============================================================================
*/

USE DWH;
GO

CREATE OR ALTER PROCEDURE bronze.load_customers
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE
        @StartTime DATETIME2(0),
        @EndTime DATETIME2(0),
        @FilePath NVARCHAR(500),
        @RowsLoaded INT,
        @SqlCommand NVARCHAR(MAX);

    SET @FilePath = N'D:\data pipeline projrct\retail_dwh_project\bronze\';

    BEGIN TRY

        SET @StartTime = SYSDATETIME();

        PRINT '------------------------------------------------------------';
        PRINT 'Loading bronze.customers';
        PRINT '------------------------------------------------------------';

        TRUNCATE TABLE bronze.customers;

        SET @SqlCommand = N'
        BULK INSERT bronze.customers
        FROM ''' + @FilePath + 'customers_raw.csv''
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR='','',
            ROWTERMINATOR=''0x0A'',
            TABLOCK
        );';

        EXEC sp_executesql @SqlCommand;

        -- Get number of rows loaded
        SELECT @RowsLoaded = COUNT(*)
        FROM bronze.customers;

        SET @EndTime = SYSDATETIME();

        PRINT 'Rows Loaded : ' + CAST(@RowsLoaded AS NVARCHAR(20));

        PRINT 'Duration    : '
            + CAST(DATEDIFF(MILLISECOND,@StartTime,@EndTime) AS NVARCHAR(20))
            + ' Seconds';

        PRINT 'Customers Loaded Successfully';
        PRINT '------------------------------------------------------------';

    END TRY

    BEGIN CATCH

        PRINT 'Error Loading bronze.customers';
        PRINT ERROR_MESSAGE();

        THROW;

    END CATCH

END;
GO
