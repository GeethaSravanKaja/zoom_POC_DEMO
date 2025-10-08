{{ config(
    materialized='table',
    tags=['audit', 'gold'],
    pre_hook="",
    post_hook=""
) }}

/*
_____________________________________________
## *Author*: AAVA Data Engineering Team
## *Created on*: {{ run_started_at }}
## *Description*: Gold Layer Process Audit Table - DBT Model
## *Version*: 1.0
## *Purpose*: Centralized audit logging for all Gold layer processes
_____________________________________________
*/

-- CTE for audit data transformation
WITH audit_source AS (
    SELECT
        execution_id,
        pipeline_name,
        start_time,
        end_time,
        status,
        error_message,
        load_date,
        update_date,
        source_system
    FROM {{ ref('silver_si_audit') }}
),

-- Enhanced audit information with additional metrics
audit_enhanced AS (
    SELECT
        execution_id,
        COALESCE(pipeline_name, 'Unknown Pipeline') AS process_name,
        pipeline_name,
        start_time AS execution_start_time,
        end_time AS execution_end_time,
        COALESCE(status, 'Unknown') AS execution_status,
        0 AS records_processed,  -- Will be updated by hooks
        0 AS records_inserted,   -- Will be updated by hooks
        0 AS records_updated,    -- Will be updated by hooks
        0 AS records_failed,     -- Will be updated by hooks
        CASE 
            WHEN end_time IS NOT NULL AND start_time IS NOT NULL 
            THEN DATEDIFF('second', start_time, end_time)
            ELSE 0
        END AS process_duration_seconds,
        error_message,
        start_time,
        end_time,
        status,
        COALESCE(load_date, CURRENT_DATE) AS load_date,
        COALESCE(update_date, CURRENT_DATE) AS update_date,
        COALESCE(source_system, 'DBT_Gold_Pipeline') AS source_system,
        CURRENT_TIMESTAMP AS created_at,
        CURRENT_TIMESTAMP AS updated_at,
        'ACTIVE' AS process_status
    FROM audit_source
)

-- Final select with all required columns
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
    source_system,
    created_at,
    updated_at,
    process_status
FROM audit_enhanced

-- Data quality filters
WHERE execution_id IS NOT NULL
  AND process_name IS NOT NULL