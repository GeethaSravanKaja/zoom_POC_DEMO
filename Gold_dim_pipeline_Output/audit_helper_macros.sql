/*
_____________________________________________
## *Author*: AAVA Data Engineering Team
## *Created on*: Current Date
## *Description*: Custom macros for audit and data quality functions
## *Version*: 1.0
## *Purpose*: Reusable macros for Gold layer transformations
_____________________________________________
*/

-- Macro to generate audit log entry
{% macro log_audit_entry(process_name, execution_status, records_count=0) %}
    INSERT INTO {{ ref('go_process_audit') }} (
        execution_id,
        process_name,
        pipeline_name,
        execution_start_time,
        execution_status,
        records_processed,
        source_system,
        created_at,
        process_status
    ) VALUES (
        '{{ invocation_id }}',
        '{{ process_name }}',
        'Gold_Pipeline',
        CURRENT_TIMESTAMP,
        '{{ execution_status }}',
        {{ records_count }},
        'DBT_Gold_Pipeline',
        CURRENT_TIMESTAMP,
        'ACTIVE'
    )
{% endmacro %}

-- Macro to update audit log entry
{% macro update_audit_entry(process_name, execution_status, records_count=0) %}
    UPDATE {{ ref('go_process_audit') }}
    SET 
        execution_end_time = CURRENT_TIMESTAMP,
        execution_status = '{{ execution_status }}',
        records_processed = {{ records_count }},
        updated_at = CURRENT_TIMESTAMP
    WHERE execution_id = '{{ invocation_id }}'
      AND process_name = '{{ process_name }}'
{% endmacro %}

-- Macro to standardize email format
{% macro standardize_email(email_column) %}
    LOWER(TRIM({{ email_column }}))
{% endmacro %}

-- Macro to normalize company names
{% macro normalize_company_name(company_column) %}
    REGEXP_REPLACE(
        COALESCE(TRIM({{ company_column }}), 'Unknown Company'),
        '[^a-zA-Z0-9 ]',
        ''
    )
{% endmacro %}

-- Macro to calculate duration in minutes
{% macro calculate_duration_minutes(start_time, end_time) %}
    CASE 
        WHEN {{ end_time }} IS NOT NULL AND {{ start_time }} IS NOT NULL 
        THEN DATEDIFF('minute', {{ start_time }}, {{ end_time }})
        ELSE 0
    END
{% endmacro %}

-- Macro to derive plan type hierarchy
{% macro derive_plan_hierarchy(plan_type_column) %}
    CASE 
        WHEN UPPER({{ plan_type_column }}) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') 
        THEN UPPER({{ plan_type_column }})
        ELSE 'UNKNOWN'
    END
{% endmacro %}

-- Macro to generate SCD Type 2 fields
{% macro generate_scd2_fields(effective_date_column='load_date') %}
    COALESCE({{ effective_date_column }}, CURRENT_DATE) AS scd_start_date,
    '9999-12-31'::DATE AS scd_end_date,
    TRUE AS scd_current_flag
{% endmacro %}

-- Macro to generate audit fields
{% macro generate_audit_fields() %}
    CURRENT_TIMESTAMP AS created_at,
    CURRENT_TIMESTAMP AS updated_at,
    'ACTIVE' AS process_status
{% endmacro %}

-- Macro to validate data quality
{% macro validate_data_quality(table_name, required_columns) %}
    {% set validation_sql %}
        SELECT 
            '{{ table_name }}' AS table_name,
            {% for column in required_columns %}
            SUM(CASE WHEN {{ column }} IS NULL THEN 1 ELSE 0 END) AS {{ column }}_null_count
            {%- if not loop.last -%},{%- endif -%}
            {% endfor %}
        FROM {{ table_name }}
    {% endset %}
    
    {{ return(validation_sql) }}
{% endmacro %}

-- Macro to log data quality issues
{% macro log_data_quality_issue(error_type, error_description, source_table, source_column='Unknown') %}
    INSERT INTO {{ ref('go_error_data') }} (
        error_type,
        error_description,
        source_table,
        source_column,
        error_timestamp,
        process_audit_info,
        status,
        load_date,
        source_system,
        created_at,
        updated_at,
        process_status
    ) VALUES (
        '{{ error_type }}',
        '{{ error_description }}',
        '{{ source_table }}',
        '{{ source_column }}',
        CURRENT_TIMESTAMP,
        'DBT Gold Pipeline - {{ invocation_id }}',
        'Open',
        CURRENT_DATE,
        'DBT_Gold_Pipeline',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        'ACTIVE'
    )
{% endmacro %}

-- Macro to generate feature category
{% macro categorize_feature(feature_name_column) %}
    CASE 
        WHEN UPPER({{ feature_name_column }}) LIKE '%SCREEN%SHARE%' OR UPPER({{ feature_name_column }}) LIKE '%SHARE%' THEN 'Collaboration'
        WHEN UPPER({{ feature_name_column }}) LIKE '%CHAT%' OR UPPER({{ feature_name_column }}) LIKE '%MESSAGE%' THEN 'Communication'
        WHEN UPPER({{ feature_name_column }}) LIKE '%RECORDING%' OR UPPER({{ feature_name_column }}) LIKE '%RECORD%' THEN 'Recording'
        WHEN UPPER({{ feature_name_column }}) LIKE '%BREAKOUT%' OR UPPER({{ feature_name_column }}) LIKE '%ROOM%' THEN 'Room Management'
        WHEN UPPER({{ feature_name_column }}) LIKE '%POLL%' OR UPPER({{ feature_name_column }}) LIKE '%SURVEY%' THEN 'Engagement'
        WHEN UPPER({{ feature_name_column }}) LIKE '%WHITEBOARD%' OR UPPER({{ feature_name_column }}) LIKE '%ANNOTATION%' THEN 'Annotation'
        ELSE 'Other'
    END
{% endmacro %}

-- Macro to derive meeting type
{% macro derive_meeting_type(participant_count_column) %}
    CASE 
        WHEN {{ participant_count_column }} = 1 THEN 'Personal'
        WHEN {{ participant_count_column }} BETWEEN 2 AND 10 THEN 'Small Group'
        WHEN {{ participant_count_column }} BETWEEN 11 AND 50 THEN 'Medium Group'
        WHEN {{ participant_count_column }} > 50 THEN 'Large Group'
        ELSE 'Unknown'
    END
{% endmacro %}

-- Macro to derive priority level
{% macro derive_priority_level(ticket_type_column) %}
    CASE 
        WHEN UPPER({{ ticket_type_column }}) LIKE '%CRITICAL%' OR UPPER({{ ticket_type_column }}) LIKE '%URGENT%' THEN 'Critical'
        WHEN UPPER({{ ticket_type_column }}) LIKE '%HIGH%' THEN 'High'
        WHEN UPPER({{ ticket_type_column }}) LIKE '%MEDIUM%' THEN 'Medium'
        WHEN UPPER({{ ticket_type_column }}) LIKE '%LOW%' THEN 'Low'
        ELSE 'Medium'
    END
{% endmacro %}

-- Macro to generate unique execution ID
{% macro generate_execution_id() %}
    {{ return(invocation_id) }}
{% endmacro %}

-- Macro for safe division to avoid divide by zero
{% macro safe_divide(numerator, denominator, default_value=0) %}
    CASE 
        WHEN {{ denominator }} = 0 OR {{ denominator }} IS NULL THEN {{ default_value }}
        ELSE {{ numerator }} / {{ denominator }}
    END
{% endmacro %}