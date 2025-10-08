-- Gold Process Audit Table
-- Author: AAVA Data Engineering Team
-- Description: Audit table for tracking all gold layer processes and transformations
-- Version: 1.0
-- Dependencies: None (Base audit table)

{{ config(
    materialized='table',
    tags=['audit', 'gold'],
    pre_hook=None,
    post_hook=None
) }}

-- This model creates the audit table structure
-- It should be created first before any other models run

WITH audit_base AS (
    SELECT 
        1 AS audit_id,
        'INIT' AS execution_id,
        'go_process_audit' AS process_name,
        'zoom_gold_dimension_pipeline' AS pipeline_name,
        CURRENT_TIMESTAMP AS execution_start_time,
        CURRENT_TIMESTAMP AS execution_end_time,
        'SUCCESS' AS execution_status,
        0 AS records_processed,
        1 AS records_inserted,
        0 AS records_updated,
        0 AS records_failed,
        0 AS process_duration_seconds,
        'Initial audit table creation' AS error_message,
        CURRENT_TIMESTAMP AS start_time,
        CURRENT_TIMESTAMP AS end_time,
        'COMPLETED' AS status,
        CURRENT_DATE AS load_date,
        CURRENT_DATE AS update_date,
        'DBT_GOLD_PIPELINE' AS source_system
    WHERE FALSE  -- This ensures no initial record is inserted
)

SELECT 
    audit_id,
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
FROM audit_base