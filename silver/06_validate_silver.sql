/*
===============================================================================
Stored Procedure : Validate Silver Layer
===============================================================================

Description:
    Validates data loaded into the Silver layer.

Usage:
    EXEC silver.validate_silver @BatchId;
===============================================================================
*/

USE DWH;
GO

CREATE OR ALTER PROCEDURE silver.validate_silver
(
    @BatchId UNIQUEIDENTIFIER
)
AS
BEGIN

    SET NOCOUNT ON;

    PRINT '============================================================';
    PRINT 'VALIDATING SILVER LAYER';
    PRINT 'Batch ID : ' + CAST(@BatchId AS NVARCHAR(36));
    PRINT '============================================================';

    SELECT
        'Customers' AS TableName,
        COUNT(*) AS TotalRows,
        CASE
            WHEN COUNT(*) > 0 THEN 'PASS'
            ELSE 'FAIL'
        END AS ValidationStatus
    FROM silver.customers

    UNION ALL

    SELECT
        'Products',
        COUNT(*),
        CASE
            WHEN COUNT(*) > 0 THEN 'PASS'
            ELSE 'FAIL'
        END
    FROM silver.products

    UNION ALL

    SELECT
        'Stores',
        COUNT(*),
        CASE
            WHEN COUNT(*) > 0 THEN 'PASS'
            ELSE 'FAIL'
        END
    FROM silver.stores

    UNION ALL

    SELECT
        'Sales',
        COUNT(*),
        CASE
            WHEN COUNT(*) > 0 THEN 'PASS'
            ELSE 'FAIL'
        END
    FROM silver.sales;

    PRINT '';
    PRINT '============================================================';
    PRINT 'SILVER VALIDATION COMPLETED';
    PRINT '============================================================';

END;
GO
