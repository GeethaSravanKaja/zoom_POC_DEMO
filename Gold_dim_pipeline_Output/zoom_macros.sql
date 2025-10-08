-- Macros for Zoom Gold Dimension Pipeline
-- This file contains reusable macros for data transformations

{% macro standardize_email(email_column) %}
  CASE 
    WHEN {{ email_column }} IS NOT NULL AND {{ email_column }} LIKE '%@%' 
    THEN LOWER(TRIM({{ email_column }}))
    ELSE 'unknown@domain.com'
  END
{% endmacro %}

{% macro normalize_company_name(company_column) %}
  CASE 
    WHEN {{ company_column }} IS NOT NULL AND TRIM({{ company_column }}) != ''
    THEN REGEXP_REPLACE(TRIM({{ company_column }}), '[^a-zA-Z0-9 ]', '')
    ELSE 'Unknown Company'
  END
{% endmacro %}

{% macro standardize_plan_type(plan_type_column) %}
  CASE 
    WHEN UPPER({{ plan_type_column }}) IN ('FREE', 'BASIC') THEN 'Basic'
    WHEN UPPER({{ plan_type_column }}) IN ('PRO', 'PROFESSIONAL') THEN 'Pro'
    WHEN UPPER({{ plan_type_column }}) IN ('ENTERPRISE', 'BUSINESS') THEN 'Enterprise'
    ELSE 'Unknown'
  END
{% endmacro %}

{% macro derive_account_status(status_column) %}
  CASE
    WHEN UPPER({{ status_column }}) = 'ACTIVE' THEN 'Active'
    WHEN UPPER({{ status_column }}) IN ('SUSPENDED', 'INACTIVE') THEN 'Inactive'
    WHEN UPPER({{ status_column }}) = 'PENDING' THEN 'Pending'
    ELSE 'Unknown'
  END
{% endmacro %}

{% macro derive_license_status(start_date_column, end_date_column) %}
  CASE
    WHEN {{ end_date_column }} < CURRENT_DATE() THEN 'Expired'
    WHEN {{ start_date_column }} <= CURRENT_DATE() AND ({{ end_date_column }} >= CURRENT_DATE() OR {{ end_date_column }} IS NULL) THEN 'Active'
    WHEN {{ start_date_column }} > CURRENT_DATE() THEN 'Pending'
    ELSE 'Unknown'
  END
{% endmacro %}

{% macro add_audit_columns() %}
  CURRENT_TIMESTAMP() AS created_at,
  CURRENT_TIMESTAMP() AS updated_at,
  'SUCCESS' AS process_status
{% endmacro %}