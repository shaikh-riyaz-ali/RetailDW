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
    5. Logs any batch-level errors.
    6. Displays execution summary.

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
        @BatchId       UNIQUEIDENTIFIER,
        @BatchStart    DATETIME2(7),
        @BatchEnd      DATETIME2(7),
        @DurationMs    INT;

    --------------------------------------------------------------------------
    -- Generate Batch ID
    --------------------------------------------------------------------------

    SET @BatchId = NEWID();

    BEGIN TRY

        SET @BatchStart = SYSDATETIME();

        PRINT '============================================================';
        PRINT 'STARTING SILVER LAYER';
        PRINT 'Batch ID   : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT 'Start Time : ' + CONVERT(VARCHAR(23), @BatchStart, 121);
        PRINT '============================================================';

        ----------------------------------------------------------------------
        -- Load Customers
        ----------------------------------------------------------------------

        EXEC silver.load_customers @BatchId;

        ----------------------------------------------------------------------
        -- Load Products
        ----------------------------------------------------------------------

        EXEC silver.load_products @BatchId;

        ----------------------------------------------------------------------
        -- Load Stores
        ----------------------------------------------------------------------

        EXEC silver.load_stores @BatchId;

        ----------------------------------------------------------------------
        -- Load Sales
        ----------------------------------------------------------------------

        EXEC silver.load_sales @BatchId;

        ----------------------------------------------------------------------
        -- Validate Silver Layer
        ----------------------------------------------------------------------

        EXEC silver.validate_silver @BatchId;

        ----------------------------------------------------------------------
        -- Batch Summary
        ----------------------------------------------------------------------

        SET @BatchEnd = SYSDATETIME();

        SET @DurationMs =
            DATEDIFF(MILLISECOND, @BatchStart, @BatchEnd);

        PRINT '';
        PRINT '============================================================';
        PRINT 'SILVER LAYER COMPLETED SUCCESSFULLY';
        PRINT '============================================================';
        PRINT 'Batch ID       : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT 'Start Time     : ' + CONVERT(VARCHAR(23), @BatchStart, 121);
        PRINT 'End Time       : ' + CONVERT(VARCHAR(23), @BatchEnd, 121);
        PRINT 'Duration       : ' + CAST(@DurationMs AS NVARCHAR(20)) + ' ms';
        PRINT 'Status         : SUCCESS';
        PRINT '============================================================';

    END TRY

    BEGIN CATCH

        SET @BatchEnd = SYSDATETIME();

        SET @DurationMs =
            DATEDIFF(MILLISECOND, @BatchStart, @BatchEnd);

        ----------------------------------------------------------------------
        -- Log Batch Error
        ----------------------------------------------------------------------

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

        ----------------------------------------------------------------------
        -- Print Error
        ----------------------------------------------------------------------

        PRINT '';
        PRINT '============================================================';
        PRINT 'SILVER LAYER FAILED';
        PRINT '============================================================';
        PRINT 'Batch ID      : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT 'Start Time    : ' + CONVERT(VARCHAR(23), @BatchStart, 121);
        PRINT 'End Time      : ' + CONVERT(VARCHAR(23), @BatchEnd, 121);
        PRINT 'Duration      : ' + CAST(@DurationMs AS NVARCHAR(20)) + ' ms';
        PRINT 'Error Number  : ' + CAST(ERROR_NUMBER() AS NVARCHAR(20));
        PRINT 'Error Line    : ' + CAST(ERROR_LINE() AS NVARCHAR(20));
        PRINT 'Error Message : ' + ERROR_MESSAGE();
        PRINT 'Status        : FAILED';
        PRINT '============================================================';

        THROW;

    END CATCH

END;
GO
