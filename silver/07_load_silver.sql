/*
===============================================================================
Stored Procedure : Load Silver Layer
===============================================================================

Description:
    Master procedure responsible for loading the Silver layer.

Actions:
    1. Generates a Batch ID.
    2. Executes all Silver load procedures.
    3. Executes Silver validation.
    4. Measures total execution time.
    5. Displays execution summary.

Usage:
    EXEC silver.load_silver;

===============================================================================
*/

USE DWH;
GO

CREATE OR ALTER PROCEDURE silver.load_silver
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
        PRINT 'STARTING SILVER LAYER';
        PRINT 'Batch ID   : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT 'Start Time : ' + CONVERT(VARCHAR(23), @BatchStart, 121);
        PRINT '============================================================';

        -----------------------------------------------------------------------
        -- Load Silver Tables
        -----------------------------------------------------------------------

        EXEC silver.load_customers @BatchId;

        EXEC silver.load_products @BatchId;

        EXEC silver.load_stores @BatchId;

        EXEC silver.load_sales @BatchId;

        -----------------------------------------------------------------------
        -- Validate Silver Layer
        -----------------------------------------------------------------------

        PRINT '';
        PRINT 'Running Silver Validation...';

        :r .\06_validate_silver.sql
        -- If your SQL tool does not support :r,
        -- simply execute 06_validate_silver.sql
        -- after running this procedure.

        -----------------------------------------------------------------------
        -- Batch Summary
        -----------------------------------------------------------------------

        SET @BatchEnd = SYSDATETIME();

        PRINT '============================================================';
        PRINT 'SILVER LAYER COMPLETED';
        PRINT 'Batch ID       : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT 'End Time       : ' + CONVERT(VARCHAR(23), @BatchEnd, 121);
        PRINT 'Total Duration : '
            + CAST(DATEDIFF(MILLISECOND,@BatchStart,@BatchEnd) AS NVARCHAR(20))
            + ' ms';
        PRINT 'Status         : SUCCESS';
        PRINT '============================================================';

    END TRY

    BEGIN CATCH

        SET @BatchEnd = SYSDATETIME();

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
            'Silver Layer',
            ERROR_NUMBER(),
            ERROR_MESSAGE(),
            ERROR_LINE(),
            ERROR_STATE()
        );

        PRINT '============================================================';
        PRINT 'SILVER LAYER FAILED';
        PRINT 'Batch ID   : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT 'Error      : ' + ERROR_MESSAGE();
        PRINT '============================================================';

        THROW;

    END CATCH

END;
GO
