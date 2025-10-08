{{ config(
    materialized='table',
    cluster_by=['execution_start_time']
) }}

/*
    Gold Layer Process Audit Table: Process_Audit
    Description: Tracks execution metrics and audit information for all DBT processes
    Author: Data Engineering Team
    Created: {{ run_started_at }}
*/

WITH audit_base AS (
    SELECT 
        execution_id,
        process_name,
        pipeline_name,
        execution_start_time,
        execution_end_time,
        execution_status,
        records_processed,
        records_inserted,
        records_updated,
        records_failed,
        process_duration_seconds,
        error_message,
        start_time,
        end_time,
        status,
        load_date,
        update_date,
        source_system
    FROM (
        -- Initialize with empty structure for first run
        SELECT 
            CAST(NULL AS VARCHAR(255)) AS execution_id,
            CAST(NULL AS VARCHAR(255)) AS process_name,
            CAST(NULL AS VARCHAR(255)) AS pipeline_name,
            CAST(NULL AS TIMESTAMP_NTZ) AS execution_start_time,
            CAST(NULL AS TIMESTAMP_NTZ) AS execution_end_time,
            CAST(NULL AS VARCHAR(50)) AS execution_status,
            CAST(NULL AS NUMBER) AS records_processed,
            CAST(NULL AS NUMBER) AS records_inserted,
            CAST(NULL AS NUMBER) AS records_updated,
            CAST(NULL AS NUMBER) AS records_failed,
            CAST(NULL AS NUMBER) AS process_duration_seconds,
            CAST(NULL AS VARCHAR(2000)) AS error_message,
            CAST(NULL AS TIMESTAMP_NTZ) AS start_time,
            CAST(NULL AS TIMESTAMP_NTZ) AS end_time,
            CAST(NULL AS VARCHAR(50)) AS status,
            CAST(NULL AS DATE) AS load_date,
            CAST(NULL AS DATE) AS update_date,
            CAST(NULL AS VARCHAR(100)) AS source_system
        WHERE 1=0  -- This ensures no rows are returned on first run
    )
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY execution_start_time) AS audit_id,
    execution_id,
    process_name,
    pipeline_name,
    execution_start_time,
    execution_end_time,
    execution_status,
    COALESCE(records_processed, 0) AS records_processed,
    COALESCE(records_inserted, 0) AS records_inserted,
    COALESCE(records_updated, 0) AS records_updated,
    COALESCE(records_failed, 0) AS records_failed,
    COALESCE(DATEDIFF('second', execution_start_time, execution_end_time), 0) AS process_duration_seconds,
    error_message,
    start_time,
    end_time,
    status,
    load_date,
    update_date,
    source_system
FROM audit_base