-- Gold Error Data Table
-- Author: AAVA Data Engineering Team
-- Description: Error tracking and data quality monitoring for Gold layer
-- Version: 1.0
-- Source: Silver.si_error_data + DBT validation errors
-- Target: Gold.Go_Error_Data

{{ config(
    materialized='table',
    tags=['gold', 'error', 'data_quality']
) }}

-- CTE for Silver layer error data
WITH silver_errors AS (
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
),

-- Transform and enhance error data
transformed_errors AS (
    SELECT 
        error_id,
        COALESCE(error_type, 'UNKNOWN_ERROR') AS error_type,
        COALESCE(error_description, 'No description provided') AS error_description,
        COALESCE(source_table, 'UNKNOWN_TABLE') AS source_table,
        'UNKNOWN_COLUMN' AS source_column,
        'N/A' AS error_value,
        'Data validation rule' AS validation_rule,
        CASE 
            WHEN UPPER(error_type) LIKE '%CRITICAL%' THEN 'CRITICAL'
            WHEN UPPER(error_type) LIKE '%HIGH%' THEN 'HIGH'
            WHEN UPPER(error_type) LIKE '%MEDIUM%' THEN 'MEDIUM'
            ELSE 'LOW'
        END AS error_severity,
        CASE 
            WHEN UPPER(status) = 'RESOLVED' THEN 'Resolved'
            WHEN UPPER(status) = 'PENDING' THEN 'Pending'
            WHEN UPPER(status) = 'IN_PROGRESS' THEN 'In Progress'
            ELSE 'Open'
        END AS resolution_status,
        NULL AS resolution_notes,
        error_timestamp,
        process_audit_info,
        status,
        load_date,
        update_date,
        source_system
    FROM silver_errors
),

-- Add DBT-specific error tracking
dbt_errors AS (
    SELECT 
        999999 AS error_id,  -- High number to avoid conflicts
        'DBT_VALIDATION' AS error_type,
        'DBT pipeline validation and transformation errors' AS error_description,
        'DBT_MODELS' AS source_table,
        'MULTIPLE' AS source_column,
        'N/A' AS error_value,
        'DBT data quality checks' AS validation_rule,
        'MEDIUM' AS error_severity,
        'Monitoring' AS resolution_status,
        'Automated DBT error tracking' AS resolution_notes,
        CURRENT_TIMESTAMP AS error_timestamp,
        'DBT Gold Pipeline Error Tracking' AS process_audit_info,
        'ACTIVE' AS status,
        CURRENT_DATE AS load_date,
        CURRENT_DATE AS update_date,
        'DBT_GOLD_PIPELINE' AS source_system
    WHERE FALSE  -- Only include when actual errors occur
),

-- Combine all error sources
all_errors AS (
    SELECT * FROM transformed_errors
    UNION ALL
    SELECT * FROM dbt_errors
),

-- Final error data with audit columns
final_error_data AS (
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
        source_system
    FROM all_errors
)

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
    source_system
FROM final_error_data
ORDER BY error_timestamp DESC