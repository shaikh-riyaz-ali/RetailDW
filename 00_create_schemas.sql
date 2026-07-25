/*
===============================================================================
Script: Create Schemas
===============================================================================

Script Purpose:
    Creates the schemas required for the Data Warehouse.

Schemas:
    - bronze : Raw data layer
    - silver : Cleaned and transformed data layer
    - gold   : Business-ready reporting layer
    - etl    : ETL procedures, logs, and configuration

Usage:
    Run this script after creating the DWH database and before creating tables.

===============================================================================
*/

USE DWH;
GO

/*==============================================================================
    Create Bronze Schema
==============================================================================*/
IF SCHEMA_ID('bronze') IS NULL
BEGIN
    EXEC ('CREATE SCHEMA bronze');
    PRINT 'Schema [bronze] created successfully.';
END
ELSE
BEGIN
    PRINT 'Schema [bronze] already exists.';
END
GO

/*==============================================================================
    Create Silver Schema
==============================================================================*/
IF SCHEMA_ID('silver') IS NULL
BEGIN
    EXEC ('CREATE SCHEMA silver');
    PRINT 'Schema [silver] created successfully.';
END
ELSE
BEGIN
    PRINT 'Schema [silver] already exists.';
END
GO

/*==============================================================================
    Create Gold Schema
==============================================================================*/
IF SCHEMA_ID('gold') IS NULL
BEGIN
    EXEC ('CREATE SCHEMA gold');
    PRINT 'Schema [gold] created successfully.';
END
ELSE
BEGIN
    PRINT 'Schema [gold] already exists.';
END
GO

/*==============================================================================
    Create ETL Schema
==============================================================================*/
IF SCHEMA_ID('etl') IS NULL
BEGIN
    EXEC ('CREATE SCHEMA etl');
    PRINT 'Schema [etl] created successfully.';
END
ELSE
BEGIN
    PRINT 'Schema [etl] already exists.';
END
GO

PRINT '====================================================';
PRINT 'All required schemas are ready.';
PRINT '====================================================';
GO
