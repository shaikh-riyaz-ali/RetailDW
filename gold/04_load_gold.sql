/*
===============================================================================
Stored Procedure : Load Gold Layer
===============================================================================

Description:
    Master procedure responsible for loading the Gold layer.

Actions:
    1. Generates a Batch ID.
    2. Loads Gold Dimension tables.
    3. Loads Gold Fact table.
    4. Measures execution time.
    5. Displays execution summary.
    6. Logs errors.

Usage:
    EXEC gold.load_gold;

===============================================================================
*/

USE DWH;
GO

CREATE OR ALTER PROCEDURE gold.load_gold
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
        PRINT 'STARTING GOLD LAYER';
        PRINT 'Batch ID      : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT 'Start Time    : ' + CONVERT(VARCHAR(23), @BatchStart, 121);
        PRINT '============================================================';

        -----------------------------------------------------------------------
        -- Load Gold Dimensions
        -----------------------------------------------------------------------

        EXEC gold.load_dimensions @BatchId;

        -----------------------------------------------------------------------
        -- Load Gold Fact Table
        -----------------------------------------------------------------------

        EXEC gold.load_fact_sales @BatchId;

        -----------------------------------------------------------------------
        -- Batch Summary
        -----------------------------------------------------------------------

        SET @BatchEnd = SYSDATETIME();

        PRINT '============================================================';
        PRINT 'GOLD LAYER COMPLETED';
        PRINT 'Batch ID      : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT 'End Time      : ' + CONVERT(VARCHAR(23), @BatchEnd, 121);
        PRINT 'Total Duration: '
              + CAST(DATEDIFF(MILLISECOND, @BatchStart, @BatchEnd) AS NVARCHAR(20))
              + ' ms';
        PRINT 'Status        : SUCCESS';
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
            'Gold Load',
            OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID),
            'Gold Layer',
            ERROR_NUMBER(),
            ERROR_MESSAGE(),
            ERROR_LINE(),
            ERROR_STATE()
        );

        PRINT '============================================================';
        PRINT 'GOLD LAYER FAILED';
        PRINT 'Batch ID      : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT 'End Time      : ' + CONVERT(VARCHAR(23), @BatchEnd, 121);
        PRINT 'Error Number  : ' + CAST(ERROR_NUMBER() AS NVARCHAR(20));
        PRINT 'Error Line    : ' + CAST(ERROR_LINE() AS NVARCHAR(20));
        PRINT 'Error Message : ' + ERROR_MESSAGE();
        PRINT '============================================================';

        THROW;

    END CATCH

END;
GO
