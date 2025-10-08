{{ config(
    materialized='table',
    tags=['dimension', 'scd2', 'gold'],
    pre_hook="{% if this.name != 'go_process_audit' %}INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, source_system, created_at, process_status) VALUES ('{{ invocation_id }}', 'go_user_dim', 'Gold_Dimension_Pipeline', CURRENT_TIMESTAMP, 'RUNNING', 'DBT_Gold_Pipeline', CURRENT_TIMESTAMP, 'ACTIVE'){% endif %}",
    post_hook="{% if this.name != 'go_process_audit' %}UPDATE {{ ref('go_process_audit') }} SET execution_end_time = CURRENT_TIMESTAMP, execution_status = 'COMPLETED', updated_at = CURRENT_TIMESTAMP, records_processed = (SELECT COUNT(*) FROM {{ this }}) WHERE execution_id = '{{ invocation_id }}' AND process_name = 'go_user_dim'{% endif %}"
) }}

/*
_____________________________________________
## *Author*: AAVA Data Engineering Team
## *Created on*: {{ run_started_at }}
## *Description*: Gold Layer User Dimension Table - DBT Model
## *Version*: 1.0
## *Purpose*: SCD Type 2 User Dimension for analytics and reporting
## *Source*: Silver.si_users
_____________________________________________
*/

-- CTE for source data extraction and cleansing
WITH user_source AS (
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
    WHERE user_id IS NOT NULL  -- Data quality filter
),

-- Data transformation and standardization
user_transformed AS (
    SELECT
        user_id,
        COALESCE(TRIM(user_name), 'Unknown User') AS user_name,
        LOWER(TRIM(email)) AS email,  -- Standardize email format
        REGEXP_REPLACE(COALESCE(TRIM(company), 'Unknown Company'), '[^a-zA-Z0-9 ]', '') AS company,  -- Normalize company names
        CASE 
            WHEN UPPER(plan_type) IN ('FREE', 'BASIC', 'PRO', 'ENTERPRISE') 
            THEN UPPER(plan_type)
            ELSE 'UNKNOWN'
        END AS plan_type,
        CASE
            WHEN UPPER(user_status) = 'ACTIVE' THEN 'Active'
            WHEN UPPER(user_status) IN ('SUSPENDED', 'INACTIVE') THEN 'Inactive'
            WHEN UPPER(user_status) = 'PENDING' THEN 'Pending'
            ELSE 'Unknown'
        END AS account_status,
        user_status,
        COALESCE(load_date, CURRENT_DATE) AS registration_date,
        load_timestamp,
        update_timestamp,
        COALESCE(source_system, 'Silver.si_users') AS source_system,
        load_date,
        update_date,
        -- SCD Type 2 fields
        COALESCE(load_date, CURRENT_DATE) AS scd_start_date,
        '9999-12-31'::DATE AS scd_end_date,
        TRUE AS scd_current_flag,
        -- Audit fields
        CURRENT_TIMESTAMP AS created_at,
        CURRENT_TIMESTAMP AS updated_at,
        'ACTIVE' AS process_status
    FROM user_source
),

-- Data validation and error handling
user_validated AS (
    SELECT *,
        CASE 
            WHEN email IS NULL OR email = '' THEN 'Missing Email'
            WHEN NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN 'Invalid Email Format'
            WHEN user_name IS NULL OR user_name = '' THEN 'Missing User Name'
            ELSE 'Valid'
        END AS data_quality_status
    FROM user_transformed
)

-- Final select with all required columns for Gold layer
SELECT
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
    scd_current_flag,
    created_at,
    updated_at,
    process_status
FROM user_validated
WHERE data_quality_status = 'Valid'  -- Only include valid records

-- Order by user_id for consistent processing
ORDER BY user_id