/*
===============================================================================
Stored Procedure: Load Bronze Layer
===============================================================================

Description:
    Master procedure responsible for loading the Bronze layer.

Actions:
    1. Generates a Batch ID.
    2. Executes all Bronze load procedures.
    3. Measures total execution time.
    4. Displays execution summary.

Usage:
    EXEC bronze.load_bronze;

===============================================================================
*/

USE DWH;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE
        @BatchId UNIQUEIDENTIFIER,
        @BatchStart DATETIME2(7),
        @BatchEnd DATETIME2(7);

    SET @BatchId = NEWID();

    BEGIN TRY

        SET @BatchStart = SYSDATETIME();

        PRINT '============================================================';
        PRINT 'STARTING BRONZE LAYER';
        PRINT 'Batch ID   : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT 'Start Time : ' + CONVERT(VARCHAR(23), @BatchStart, 121);
        PRINT '============================================================';

        EXEC bronze.load_customers @BatchId;

        EXEC bronze.load_products @BatchId;

        EXEC bronze.load_stores @BatchId;

        EXEC bronze.load_sales @BatchId;

        SET @BatchEnd = SYSDATETIME();

        PRINT '============================================================';
        PRINT 'BRONZE LAYER COMPLETED';
        PRINT 'Batch ID       : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT 'End Time       : ' + CONVERT(VARCHAR(23), @BatchEnd, 121);
        PRINT 'Total Duration : '
            + CAST(DATEDIFF(MILLISECOND, @BatchStart, @BatchEnd) AS NVARCHAR(20))
            + ' ms';
        PRINT 'Status         : SUCCESS';
        PRINT '============================================================';

    END TRY

    BEGIN CATCH

        SET @BatchEnd = SYSDATETIME();

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

        PRINT '============================================================';
        PRINT 'BRONZE LAYER FAILED';
        PRINT 'Batch ID   : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT 'Error      : ' + ERROR_MESSAGE();
        PRINT '============================================================';

        THROW;

    END CATCH

END;
GO
