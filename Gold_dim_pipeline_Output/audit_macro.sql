-- =====================================================
-- Audit Macro for Gold Dimension Pipeline
-- Description: Reusable macro for generating audit information
-- Author: Data Engineer
-- =====================================================

{% macro generate_audit_fields() %}
    CURRENT_TIMESTAMP AS load_timestamp,
    CURRENT_TIMESTAMP AS update_timestamp,
    CURRENT_DATE AS load_date,
    CURRENT_DATE AS update_date,
    'DBT_PIPELINE' AS source_system
{% endmacro %}

{% macro generate_scd_fields() %}
    CURRENT_DATE AS scd_start_date,
    '9999-12-31'::DATE AS scd_end_date,
    TRUE AS scd_current_flag
{% endmacro %}

{% macro safe_divide(numerator, denominator) %}
    CASE 
        WHEN {{ denominator }} = 0 OR {{ denominator }} IS NULL 
        THEN NULL 
        ELSE {{ numerator }} / {{ denominator }} 
    END
{% endmacro %}

{% macro standardize_email(email_field) %}
    LOWER(TRIM({{ email_field }}))
{% endmacro %}

{% macro normalize_text(text_field) %}
    REGEXP_REPLACE(COALESCE({{ text_field }}, 'Unknown'), '[^a-zA-Z0-9 ]', '')
{% endmacro %}

{% macro derive_status(status_field, active_value='Active', inactive_values=['Suspended', 'Inactive']) %}
    CASE
        WHEN {{ status_field }} = '{{ active_value }}' THEN 'Active'
        {% for inactive_val in inactive_values %}
        WHEN {{ status_field }} = '{{ inactive_val }}' THEN 'Inactive'
        {% endfor %}
        WHEN {{ status_field }} = 'Pending' THEN 'Pending'
        ELSE 'Unknown'
    END
{% endmacro %}