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

    ------------------------------------------------------------
    -- Customers
    ------------------------------------------------------------
    PRINT '';
    PRINT 'Customers';

    SELECT COUNT(*) AS TotalRows
    FROM silver.customers;

    ------------------------------------------------------------
    -- Products
    ------------------------------------------------------------
    PRINT '';
    PRINT 'Products';

    SELECT COUNT(*) AS TotalRows
    FROM silver.products;

    ------------------------------------------------------------
    -- Stores
    ------------------------------------------------------------
    PRINT '';
    PRINT 'Stores';

    SELECT COUNT(*) AS TotalRows
    FROM silver.stores;

    ------------------------------------------------------------
    -- Sales
    ------------------------------------------------------------
    PRINT '';
    PRINT 'Sales';

    SELECT COUNT(*) AS TotalRows
    FROM silver.sales;

    PRINT '';
    PRINT 'Silver Validation Completed Successfully';

END;
GO
