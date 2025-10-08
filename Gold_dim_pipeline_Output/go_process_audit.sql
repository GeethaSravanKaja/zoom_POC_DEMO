-- =====================================================
-- Go_Process_Audit Model
-- Description: Gold Layer Process Audit Table for tracking DBT pipeline execution
-- Author: Data Engineer
-- =====================================================

{{ config(
    materialized='table',
    tags=['audit', 'gold'],
    on_schema_change='append_new_columns'
) }}

-- This model creates the audit table that will be used by other models
-- It should be created first before any other gold models run

SELECT
    ROW_NUMBER() OVER (ORDER BY CURRENT_TIMESTAMP) AS audit_id,
    'INITIAL_SETUP' AS execution_id,
    'go_process_audit' AS process_name,
    'gold_dimension_pipeline' AS pipeline_name,
    CURRENT_TIMESTAMP AS execution_start_time,
    CURRENT_TIMESTAMP AS execution_end_time,
    'COMPLETED' AS execution_status,
    0 AS records_processed,
    0 AS records_inserted,
    0 AS records_updated,
    0 AS records_failed,
    0 AS process_duration_seconds,
    'Initial audit table setup' AS error_message,
    CURRENT_TIMESTAMP AS start_time,
    CURRENT_TIMESTAMP AS end_time,
    'ACTIVE' AS status,
    CURRENT_DATE AS load_date,
    CURRENT_DATE AS update_date,
    'DBT_PIPELINE' AS source_system
WHERE FALSE -- This ensures no actual records are inserted during initial setup