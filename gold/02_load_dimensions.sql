/*
===============================================================================
Stored Procedure : Load Gold Dimensions
===============================================================================

Description:
    Master procedure responsible for loading all Gold dimension tables.

Actions:
    1. Receives Batch ID from gold.load_gold.
    2. Executes all dimension load procedures.
    3. Measures execution time.
    4. Logs any errors.

Usage:
    EXEC gold.load_dimensions @BatchId;

===============================================================================
*/

USE DWH;
GO

CREATE OR ALTER PROCEDURE gold.load_dimensions
(
    @BatchId UNIQUEIDENTIFIER
)
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE
        @StartTime DATETIME2(7),
        @EndTime   DATETIME2(7);

    BEGIN TRY

        SET @StartTime = SYSDATETIME();

        PRINT '============================================================';
        PRINT 'LOADING GOLD DIMENSIONS';
        PRINT 'Batch ID   : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT 'Start Time : ' + CONVERT(VARCHAR(23), @StartTime, 121);
        PRINT '============================================================';

        -----------------------------------------------------------------------
        -- Customer Dimension
        -----------------------------------------------------------------------

        EXEC gold.load_dim_customers @BatchId;

        -----------------------------------------------------------------------
        -- Product Dimension
        -----------------------------------------------------------------------

        EXEC gold.load_dim_products @BatchId;

        -----------------------------------------------------------------------
        -- Store Dimension
        -----------------------------------------------------------------------

        EXEC gold.load_dim_stores @BatchId;

        -----------------------------------------------------------------------
        -- Summary
        -----------------------------------------------------------------------

        SET @EndTime = SYSDATETIME();

        PRINT '============================================================';
        PRINT 'GOLD DIMENSIONS COMPLETED';
        PRINT 'Batch ID       : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT 'End Time       : ' + CONVERT(VARCHAR(23), @EndTime, 121);
        PRINT 'Total Duration : '
            + CAST(DATEDIFF(MILLISECOND, @StartTime, @EndTime) AS NVARCHAR(20))
            + ' ms';
        PRINT 'Status         : SUCCESS';
        PRINT '============================================================';

    END TRY

    BEGIN CATCH

        SET @EndTime = SYSDATETIME();

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
            'Dimensions',
            ERROR_NUMBER(),
            ERROR_MESSAGE(),
            ERROR_LINE(),
            ERROR_STATE()
        );

        PRINT '============================================================';
        PRINT 'GOLD DIMENSION LOAD FAILED';
        PRINT 'Batch ID      : ' + CAST(@BatchId AS NVARCHAR(36));
        PRINT 'End Time      : ' + CONVERT(VARCHAR(23), @EndTime, 121);
        PRINT 'Error Number  : ' + CAST(ERROR_NUMBER() AS NVARCHAR(20));
        PRINT 'Error Message : ' + ERROR_MESSAGE();
        PRINT '============================================================';

        THROW;

    END CATCH

END;
GO
