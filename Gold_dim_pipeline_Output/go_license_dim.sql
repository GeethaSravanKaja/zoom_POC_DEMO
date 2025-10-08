{{ config(
    materialized='table',
    tags=['dimension', 'scd2', 'gold'],
    pre_hook="{% if this.name != 'go_process_audit' %}INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, source_system, created_at, process_status) VALUES ('{{ invocation_id }}', 'go_license_dim', 'Gold_Dimension_Pipeline', CURRENT_TIMESTAMP, 'RUNNING', 'DBT_Gold_Pipeline', CURRENT_TIMESTAMP, 'ACTIVE'){% endif %}",
    post_hook="{% if this.name != 'go_process_audit' %}UPDATE {{ ref('go_process_audit') }} SET execution_end_time = CURRENT_TIMESTAMP, execution_status = 'COMPLETED', updated_at = CURRENT_TIMESTAMP, records_processed = (SELECT COUNT(*) FROM {{ this }}) WHERE execution_id = '{{ invocation_id }}' AND process_name = 'go_license_dim'{% endif %}"
) }}

/*
_____________________________________________
## *Author*: AAVA Data Engineering Team
## *Created on*: {{ run_started_at }}
## *Description*: Gold Layer License Dimension Table - DBT Model
## *Version*: 1.0
## *Purpose*: SCD Type 2 License Dimension for analytics and reporting
## *Source*: Silver.si_licenses
_____________________________________________
*/

-- CTE for source data extraction and cleansing
WITH license_source AS (
    SELECT
        license_id,
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        load_timestamp,
        update_timestamp,
        source_system,
        load_date,
        update_date
    FROM {{ source('silver', 'si_licenses') }}
    WHERE license_id IS NOT NULL  -- Data quality filter
),

-- Data transformation and business logic
license_transformed AS (
    SELECT
        license_id,
        CASE 
            WHEN UPPER(license_type) IN ('BASIC', 'PRO', 'ENTERPRISE', 'FREE') 
            THEN UPPER(license_type)
            ELSE 'UNKNOWN'
        END AS license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        -- Derive assignment status based on dates
        CASE
            WHEN end_date < CURRENT_DATE THEN 'Expired'
            WHEN start_date <= CURRENT_DATE AND (end_date >= CURRENT_DATE OR end_date IS NULL) THEN 'Active'
            WHEN start_date > CURRENT_DATE THEN 'Pending'
            ELSE 'Unknown'
        END AS assignment_status,
        -- Calculate license capacity based on type
        CASE 
            WHEN UPPER(license_type) = 'FREE' THEN 100
            WHEN UPPER(license_type) = 'BASIC' THEN 500
            WHEN UPPER(license_type) = 'PRO' THEN 1000
            WHEN UPPER(license_type) = 'ENTERPRISE' THEN 10000
            ELSE 0
        END AS license_capacity,
        load_timestamp,
        update_timestamp,
        COALESCE(source_system, 'Silver.si_licenses') AS source_system,
        load_date,
        update_date,
        -- SCD Type 2 fields
        COALESCE(start_date, load_date, CURRENT_DATE) AS scd_start_date,
        '9999-12-31'::DATE AS scd_end_date,
        TRUE AS scd_current_flag,
        -- Audit fields
        CURRENT_TIMESTAMP AS created_at,
        CURRENT_TIMESTAMP AS updated_at,
        'ACTIVE' AS process_status
    FROM license_source
),

-- Data validation and error handling
license_validated AS (
    SELECT *,
        CASE 
            WHEN license_id IS NULL OR license_id = '' THEN 'Missing License ID'
            WHEN license_type IS NULL OR license_type = '' THEN 'Missing License Type'
            WHEN start_date IS NULL THEN 'Missing Start Date'
            WHEN end_date IS NOT NULL AND end_date < start_date THEN 'Invalid Date Range'
            ELSE 'Valid'
        END AS data_quality_status
    FROM license_transformed
)

-- Final select with all required columns for Gold layer
SELECT
    license_id,
    license_type,
    assigned_to_user_id,
    start_date,
    end_date,
    assignment_status,
    license_capacity,
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
FROM license_validated
WHERE data_quality_status = 'Valid'  -- Only include valid records

-- Order by license_id for consistent processing
ORDER BY license_id