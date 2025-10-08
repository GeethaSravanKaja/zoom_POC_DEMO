{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, load_date, source_system) SELECT '{{ invocation_id }}', 'go_user_dim', 'gold_dimension_pipeline', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_DATE(), 'DBT_GOLD_PIPELINE' WHERE '{{ this.name }}' != 'go_process_audit'",
    post_hook="INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_end_time, execution_status, records_processed, load_date, source_system) SELECT '{{ invocation_id }}', 'go_user_dim', 'gold_dimension_pipeline', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE(), 'DBT_GOLD_PIPELINE' WHERE '{{ this.name }}' != 'go_process_audit'"
) }}

-- Gold Layer User Dimension Table
-- Transforms Silver layer user data into Gold dimension with SCD Type 2
-- Source: Silver.si_users

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
    WHERE user_id IS NOT NULL
),

-- Data quality checks and transformations
user_transformed AS (
    SELECT
        user_id,
        COALESCE(TRIM(user_name), 'Unknown User') AS user_name,
        -- Email standardization and validation
        CASE 
            WHEN email IS NOT NULL AND email LIKE '%@%' 
            THEN LOWER(TRIM(email))
            ELSE 'unknown@domain.com'
        END AS email,
        -- Company name normalization
        CASE 
            WHEN company IS NOT NULL AND TRIM(company) != ''
            THEN REGEXP_REPLACE(TRIM(company), '[^a-zA-Z0-9 ]', '')
            ELSE 'Unknown Company'
        END AS company,
        -- Plan type hierarchy mapping
        CASE 
            WHEN UPPER(plan_type) IN ('FREE', 'BASIC') THEN 'Basic'
            WHEN UPPER(plan_type) IN ('PRO', 'PROFESSIONAL') THEN 'Pro'
            WHEN UPPER(plan_type) IN ('ENTERPRISE', 'BUSINESS') THEN 'Enterprise'
            ELSE 'Unknown'
        END AS plan_type,
        -- Account status derivation
        CASE
            WHEN UPPER(user_status) = 'ACTIVE' THEN 'Active'
            WHEN UPPER(user_status) IN ('SUSPENDED', 'INACTIVE') THEN 'Inactive'
            WHEN UPPER(user_status) = 'PENDING' THEN 'Pending'
            ELSE 'Unknown'
        END AS account_status,
        user_status,
        load_timestamp,
        update_timestamp,
        source_system,
        load_date,
        update_date,
        -- SCD Type 2 fields
        COALESCE(load_date, CURRENT_DATE()) AS scd_start_date,
        '9999-12-31'::DATE AS scd_end_date,
        TRUE AS scd_current_flag
    FROM user_source
),

-- Add audit columns and final transformations
user_final AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY user_id) AS user_dim_id,
        user_id,
        user_name,
        email,
        company,
        plan_type,
        account_status,
        COALESCE(load_date, CURRENT_DATE()) AS registration_date,
        load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        COALESCE(load_date, CURRENT_DATE()) AS load_date,
        CURRENT_DATE() AS update_date,
        COALESCE(source_system, 'Silver.si_users') AS source_system,
        scd_start_date,
        scd_end_date,
        scd_current_flag,
        -- Audit columns
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at,
        'SUCCESS' AS process_status
    FROM user_transformed
)

SELECT * FROM user_final