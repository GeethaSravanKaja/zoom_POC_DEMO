{{ config(
    materialized='table',
    pre_hook="",
    post_hook=""
) }}

-- Gold Layer Process Audit Table
-- This table tracks all DBT model executions and their status

WITH audit_base AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['execution_id', 'process_name']) }} AS audit_id,
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
    FROM {{ source('silver', 'si_audit') }}
)

SELECT
    audit_id,
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
    COALESCE(process_duration_seconds, 0) AS process_duration_seconds,
    error_message,
    start_time,
    end_time,
    status,
    COALESCE(load_date, CURRENT_DATE()) AS load_date,
    CURRENT_TIMESTAMP() AS update_date,
    COALESCE(source_system, 'DBT_GOLD_PIPELINE') AS source_system,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at,
    'SUCCESS' AS process_status
FROM audit_base