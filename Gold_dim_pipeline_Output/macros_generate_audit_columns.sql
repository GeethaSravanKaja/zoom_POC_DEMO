-- Macro for generating audit columns
-- Author: AAVA Data Engineering Team
-- Description: Standardized audit column generation for all gold tables
-- Version: 1.0

{% macro generate_audit_columns() %}
    CURRENT_TIMESTAMP AS load_timestamp,
    CURRENT_TIMESTAMP AS update_timestamp,
    CURRENT_DATE AS load_date,
    CURRENT_DATE AS update_date,
    'DBT_GOLD_PIPELINE' AS source_system
{% endmacro %}

{% macro generate_scd_columns() %}
    CURRENT_DATE AS scd_start_date,
    '9999-12-31'::DATE AS scd_end_date,
    TRUE AS scd_current_flag
{% endmacro %}

{% macro generate_error_handling(table_name, source_query) %}
    -- Error handling wrapper macro
    WITH error_check AS (
        SELECT 
            *,
            CASE 
                WHEN user_id IS NULL THEN 'NULL_USER_ID'
                WHEN email IS NULL OR email = '' THEN 'INVALID_EMAIL'
                WHEN LENGTH(user_name) > 255 THEN 'NAME_TOO_LONG'
                ELSE NULL
            END AS error_type
        FROM ({{ source_query }})
    ),
    valid_records AS (
        SELECT * FROM error_check WHERE error_type IS NULL
    ),
    error_records AS (
        SELECT 
            ROW_NUMBER() OVER (ORDER BY load_timestamp) AS error_id,
            error_type,
            'Data validation failed for ' || error_type AS error_description,
            '{{ table_name }}' AS source_table,
            'Multiple' AS source_column,
            COALESCE(user_id, 'N/A') AS error_value,
            'NOT NULL and LENGTH validation' AS validation_rule,
            'HIGH' AS error_severity,
            'PENDING' AS resolution_status,
            NULL AS resolution_notes,
            CURRENT_TIMESTAMP AS error_timestamp,
            'DBT Pipeline Validation' AS process_audit_info,
            'ACTIVE' AS status,
            CURRENT_DATE AS load_date,
            CURRENT_DATE AS update_date,
            'DBT_GOLD_PIPELINE' AS source_system
        FROM error_records
        WHERE error_type IS NOT NULL
    )
    SELECT * FROM valid_records
{% endmacro %}