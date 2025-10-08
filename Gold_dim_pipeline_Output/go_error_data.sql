{{ config(
    materialized='table',
    tags=['error', 'gold'],
    pre_hook="{% if this.name != 'go_process_audit' %}INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, source_system, created_at, process_status) VALUES ('{{ invocation_id }}', 'go_error_data', 'Gold_Error_Pipeline', CURRENT_TIMESTAMP, 'RUNNING', 'DBT_Gold_Pipeline', CURRENT_TIMESTAMP, 'ACTIVE'){% endif %}",
    post_hook="{% if this.name != 'go_process_audit' %}UPDATE {{ ref('go_process_audit') }} SET execution_end_time = CURRENT_TIMESTAMP, execution_status = 'COMPLETED', updated_at = CURRENT_TIMESTAMP, records_processed = (SELECT COUNT(*) FROM {{ this }}) WHERE execution_id = '{{ invocation_id }}' AND process_name = 'go_error_data'{% endif %}"
) }}

/*
_____________________________________________
## *Author*: AAVA Data Engineering Team
## *Created on*: {{ run_started_at }}
## *Description*: Gold Layer Error Data Table - DBT Model
## *Version*: 1.0
## *Purpose*: Centralized error logging and data quality monitoring
## *Source*: Silver.si_error_data
_____________________________________________
*/

-- CTE for source data extraction
WITH error_source AS (
    SELECT
        error_id,
        error_type,
        error_description,
        source_table,
        error_timestamp,
        process_audit_info,
        status,
        load_date,
        update_date,
        source_system
    FROM {{ source('silver', 'si_error_data') }}
    WHERE error_id IS NOT NULL  -- Data quality filter
),

-- Data transformation and enhancement
error_transformed AS (
    SELECT
        error_id,
        COALESCE(TRIM(error_type), 'Unknown Error') AS error_type,
        COALESCE(TRIM(error_description), 'No description provided') AS error_description,
        COALESCE(TRIM(source_table), 'Unknown Table') AS source_table,
        -- Extract source column from error description if available
        CASE 
            WHEN error_description LIKE '%column%' THEN 
                REGEXP_SUBSTR(error_description, 'column\s+(\w+)', 1, 1, 'i', 1)
            ELSE 'Unknown Column'
        END AS source_column,
        -- Extract error value from description if available
        CASE 
            WHEN error_description LIKE '%value%' THEN 
                REGEXP_SUBSTR(error_description, 'value\s+["\']?([^"\',\s]+)["\']?', 1, 1, 'i', 1)
            ELSE 'Unknown Value'
        END AS error_value,
        -- Derive validation rule based on error type
        CASE 
            WHEN UPPER(error_type) LIKE '%NULL%' THEN 'NOT NULL Constraint'
            WHEN UPPER(error_type) LIKE '%FORMAT%' THEN 'Format Validation'
            WHEN UPPER(error_type) LIKE '%RANGE%' THEN 'Range Validation'
            WHEN UPPER(error_type) LIKE '%DUPLICATE%' THEN 'Uniqueness Constraint'
            WHEN UPPER(error_type) LIKE '%REFERENCE%' THEN 'Referential Integrity'
            ELSE 'Data Quality Rule'
        END AS validation_rule,
        -- Assign error severity
        CASE 
            WHEN UPPER(error_type) LIKE '%CRITICAL%' OR UPPER(error_type) LIKE '%FATAL%' THEN 'Critical'
            WHEN UPPER(error_type) LIKE '%WARNING%' THEN 'Warning'
            WHEN UPPER(error_type) LIKE '%INFO%' THEN 'Info'
            ELSE 'Medium'
        END AS error_severity,
        -- Set initial resolution status
        CASE 
            WHEN UPPER(status) = 'RESOLVED' THEN 'Resolved'
            WHEN UPPER(status) = 'IN_PROGRESS' THEN 'In Progress'
            ELSE 'Open'
        END AS resolution_status,
        -- Generate resolution notes
        CASE 
            WHEN UPPER(status) = 'RESOLVED' THEN 'Error has been resolved and data corrected'
            WHEN UPPER(status) = 'IN_PROGRESS' THEN 'Error is currently being investigated'
            ELSE 'Error requires investigation and resolution'
        END AS resolution_notes,
        error_timestamp,
        COALESCE(process_audit_info, 'No audit information available') AS process_audit_info,
        COALESCE(status, 'Open') AS status,
        load_date,
        update_date,
        COALESCE(source_system, 'Silver.si_error_data') AS source_system,
        -- Audit fields
        CURRENT_TIMESTAMP AS created_at,
        CURRENT_TIMESTAMP AS updated_at,
        'ACTIVE' AS process_status
    FROM error_source
),

-- Data validation
error_validated AS (
    SELECT *,
        CASE 
            WHEN error_id IS NULL THEN 'Missing Error ID'
            WHEN error_type IS NULL OR error_type = '' THEN 'Missing Error Type'
            WHEN source_table IS NULL OR source_table = '' THEN 'Missing Source Table'
            WHEN error_timestamp IS NULL THEN 'Missing Error Timestamp'
            ELSE 'Valid'
        END AS data_quality_status
    FROM error_transformed
)

-- Final select with all required columns for Gold layer
SELECT
    error_id,
    error_type,
    error_description,
    source_table,
    source_column,
    error_value,
    validation_rule,
    error_severity,
    resolution_status,
    resolution_notes,
    error_timestamp,
    process_audit_info,
    status,
    load_date,
    update_date,
    source_system,
    created_at,
    updated_at,
    process_status
FROM error_validated
WHERE data_quality_status = 'Valid'  -- Only include valid records

-- Order by error_timestamp for consistent processing
ORDER BY error_timestamp DESC