USE DWH;
GO

IF OBJECT_ID('etl.etl_log','U') IS NOT NULL
    DROP TABLE etl.etl_log;
GO

CREATE TABLE etl.etl_log
(
    log_id           INT IDENTITY(1,1) PRIMARY KEY,

    process_name     NVARCHAR(100),

    table_name       NVARCHAR(100),

    rows_loaded      INT,

    start_time       DATETIME2,

    end_time         DATETIME2,

    duration_ms      INT,

    status           NVARCHAR(20),

    created_date     DATETIME2
        DEFAULT GETDATE()
);
GO
