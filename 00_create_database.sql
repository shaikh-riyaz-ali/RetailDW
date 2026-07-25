/*
===============================================================================
Script: Create Database
===============================================================================

Script Purpose:
    Creates the Data Warehouse database (DWH).

Actions Performed:
    - Checks if the database already exists.
    - Drops the database (Development Environment Only).
    - Creates a new database.
    - Sets the database context.

Usage:
    Run this script before creating schemas and tables.

===============================================================================
*/

USE master;
GO

-- Drop the database if it already exists (Development Only)
IF DB_ID('DWH') IS NOT NULL
BEGIN
    ALTER DATABASE DWH
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE DWH;
END;
GO

-- Create Database
CREATE DATABASE DWH;
GO

-- Use the Database
USE DWH;
GO

PRINT '====================================================';
PRINT 'Database [DWH] created successfully.';
PRINT '====================================================';
GO
