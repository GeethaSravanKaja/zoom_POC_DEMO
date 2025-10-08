-- Gold User Dimension Table
-- Author: AAVA Data Engineering Team
-- Description: SCD Type 2 User dimension table transformed from Silver layer
-- Version: 1.0
-- Source: Silver.si_users
-- Target: Gold.Go_User_Dim

{{ config(
    materialized='table',
    tags=['gold', 'dimension', 'scd2'],
    unique_key='user_id'
) }}

-- CTE for data extraction and transformation from Silver layer
WITH silver_users AS (
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

-- Data quality and transformation layer
transformed_users AS (
    SELECT 
        user_id,
        COALESCE(user_name, 'Unknown User') AS user_name,
        -- Email standardization and validation
        CASE 
            WHEN email IS NULL OR email = '' THEN 'no-email@unknown.com'
            ELSE LOWER(TRIM(email))
        END AS email,
        -- Company name normalization
        CASE 
            WHEN company IS NULL OR company = '' THEN 'Unknown Company'
            ELSE REGEXP_REPLACE(TRIM(company), '[^a-zA-Z0-9 ]', '') 
        END AS company,
        -- Plan type hierarchy mapping
        CASE 
            WHEN UPPER(plan_type) = 'FREE' THEN 'Basic'
            WHEN UPPER(plan_type) = 'BASIC' THEN 'Basic'
            WHEN UPPER(plan_type) = 'PRO' THEN 'Pro'
            WHEN UPPER(plan_type) = 'ENTERPRISE' THEN 'Enterprise'
            ELSE 'Unknown'
        END AS plan_type,
        -- Account status derivation
        CASE 
            WHEN UPPER(user_status) = 'ACTIVE' THEN 'Active'
            WHEN UPPER(user_status) = 'SUSPENDED' THEN 'Inactive'
            WHEN UPPER(user_status) = 'INACTIVE' THEN 'Inactive'
            ELSE 'Unknown'
        END AS account_status,
        -- Registration date (derived from load_date if not available)
        COALESCE(load_date, CURRENT_DATE) AS registration_date,
        load_timestamp,
        update_timestamp,
        load_date,
        update_date,
        source_system
    FROM silver_users
),

-- Error detection and logging
error_records AS (
    SELECT 
        *,
        CASE 
            WHEN LENGTH(user_name) > 255 THEN 'USER_NAME_TOO_LONG'
            WHEN LENGTH(email) > 255 THEN 'EMAIL_TOO_LONG'
            WHEN LENGTH(company) > 255 THEN 'COMPANY_NAME_TOO_LONG'
            WHEN NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN 'INVALID_EMAIL_FORMAT'
            ELSE NULL
        END AS error_type
    FROM transformed_users
),

-- Valid records only (no errors)
valid_users AS (
    SELECT 
        user_id,
        user_name,
        email,
        company,
        plan_type,
        account_status,
        registration_date,
        load_timestamp,
        update_timestamp,
        load_date,
        update_date,
        source_system
    FROM error_records
    WHERE error_type IS NULL
),

-- Final dimension table with SCD Type 2 columns
final_user_dim AS (
    SELECT 
        -- Business key
        user_id,
        -- Dimension attributes
        user_name,
        email,
        company,
        plan_type,
        account_status,
        registration_date,
        -- Audit columns
        load_timestamp,
        update_timestamp,
        load_date,
        update_date,
        source_system,
        -- SCD Type 2 columns
        {{ generate_scd_columns() }}
    FROM valid_users
)

SELECT 
    user_id,
    user_name,
    email,
    company,
    plan_type,
    account_status,
    registration_date,
    load_timestamp,
    update_timestamp,
    load_date,
    update_date,
    source_system,
    scd_start_date,
    scd_end_date,
    scd_current_flag
FROM final_user_dim

-- Data quality checks
{% if is_incremental() %}
    WHERE update_timestamp > (SELECT MAX(update_timestamp) FROM {{ this }})
{% endif %}