USE DWH;
GO

IF OBJECT_ID('etl.error_log','U') IS NOT NULL
    DROP TABLE etl.error_log;
GO

CREATE TABLE etl.error_log
(
    error_id           INT IDENTITY(1,1) PRIMARY KEY,

    procedure_name     NVARCHAR(200),

    error_number       INT,

    error_message      NVARCHAR(MAX),

    error_line         INT,

    error_state        INT,

    error_time         DATETIME2
        DEFAULT GETDATE()
);
GO

=======================================================

INSERT INTO etl.etl_log
(
    process_name,
    table_name,
    rows_loaded,
    start_time,
    end_time,
    duration_ms,
    status
)
VALUES
(
    'Bronze Load',
    'Customers',
    @RowsLoaded,
    @StartTime,
    @EndTime,
    DATEDIFF(MILLISECOND,@StartTime,@EndTime),
    'SUCCESS'
);
