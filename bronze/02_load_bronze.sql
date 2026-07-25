/*
===============================================================================
Master Procedure : Load Bronze Layer
===============================================================================
*/

USE DWH;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE

        @BatchStart DATETIME2(0),
        @BatchEnd DATETIME2(0);

    BEGIN TRY

        SET @BatchStart = SYSDATETIME();

        PRINT '====================================================';
        PRINT 'STARTING BRONZE LAYER';
        PRINT '====================================================';

        EXEC bronze.load_customers;

        EXEC bronze.load_products;

        EXEC bronze.load_stores;

        EXEC bronze.load_sales;

        SET @BatchEnd = SYSDATETIME();

        PRINT '====================================================';
        PRINT 'BRONZE LAYER COMPLETED';
        PRINT 'Total Duration : '
            + CAST(DATEDIFF(SECOND,@BatchStart,@BatchEnd) AS NVARCHAR(20))
            + ' Seconds';
        PRINT '====================================================';

    END TRY

    BEGIN CATCH

        PRINT '====================================================';
        PRINT 'BRONZE LAYER FAILED';
        PRINT ERROR_MESSAGE();
        PRINT '====================================================';

        THROW;

    END CATCH

END;
GO
