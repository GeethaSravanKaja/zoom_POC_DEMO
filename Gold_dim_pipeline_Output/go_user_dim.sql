-- =====================================================
-- Go_User_Dim Model
-- Description: Gold Layer User Dimension Table with SCD Type 2
-- Source: Silver.si_users
-- Author: Data Engineer
-- =====================================================

{{ config(
    materialized='table',
    tags=['dimension', 'gold', 'scd2'],
    on_schema_change='append_new_columns',
    pre_hook="{% if this.name != 'go_process_audit' %}INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, records_processed, start_time, status, load_date, update_date, source_system) VALUES ('{{ invocation_id }}', 'go_user_dim', 'gold_dimension_pipeline', CURRENT_TIMESTAMP, 'RUNNING', 0, CURRENT_TIMESTAMP, 'ACTIVE', CURRENT_DATE, CURRENT_DATE, 'DBT_PIPELINE'){% endif %}",
    post_hook="{% if this.name != 'go_process_audit' %}UPDATE {{ ref('go_process_audit') }} SET execution_end_time = CURRENT_TIMESTAMP, execution_status = 'COMPLETED', records_processed = (SELECT COUNT(*) FROM {{ this }}), records_inserted = (SELECT COUNT(*) FROM {{ this }}), process_duration_seconds = DATEDIFF(second, execution_start_time, CURRENT_TIMESTAMP), end_time = CURRENT_TIMESTAMP WHERE execution_id = '{{ invocation_id }}' AND process_name = 'go_user_dim'{% endif %}"
) }}

-- CTE for data transformation and cleansing
WITH source_data AS (
    SELECT
        user_id,
        user_name,
        email,
        company,
        plan_type,
        user_status,
        load_timestamp,
        update_timestamp,
        source_system,
        load_date,
        update_date
    FROM {{ source('silver', 'si_users') }}
    WHERE user_id IS NOT NULL -- Data quality check
),

-- Data transformation with business rules
transformed_data AS (
    SELECT
        user_id,
        COALESCE(user_name, 'Unknown User') AS user_name,
        LOWER(TRIM(email)) AS email, -- Standardize email format
        REGEXP_REPLACE(COALESCE(company, 'Unknown Company'), '[^a-zA-Z0-9 ]', '') AS company, -- Normalize company names
        COALESCE(plan_type, 'Unknown') AS plan_type,
        COALESCE(user_status, 'Unknown') AS user_status,
        
        -- Derive account status based on user_status
        CASE
            WHEN user_status = 'Active' THEN 'Active'
            WHEN user_status = 'Suspended' THEN 'Inactive'
            WHEN user_status = 'Pending' THEN 'Pending'
            ELSE 'Unknown'
        END AS account_status,
        
        -- Derive registration date (using load_date as proxy if not available)
        COALESCE(load_date, CURRENT_DATE) AS registration_date,
        
        -- Audit fields
        load_timestamp,
        update_timestamp,
        load_date,
        update_date,
        source_system,
        
        -- SCD Type 2 fields
        CURRENT_DATE AS scd_start_date,
        '9999-12-31'::DATE AS scd_end_date,
        TRUE AS scd_current_flag
    FROM source_data
)

-- Final SELECT with all required fields for Go_User_Dim
SELECT
    ROW_NUMBER() OVER (ORDER BY user_id) AS user_dim_id,
    user_id,
    user_name,
    email,
    company,
    plan_type,
    user_status,
    registration_date,
    account_status,
    load_timestamp,
    update_timestamp,
    load_date,
    update_date,
    source_system,
    scd_start_date,
    scd_end_date,
    scd_current_flag
FROM transformed_data