-- Gold License Dimension Table
-- Author: AAVA Data Engineering Team
-- Description: SCD Type 2 License dimension table transformed from Silver layer
-- Version: 1.0
-- Source: Silver.si_licenses
-- Target: Gold.Go_License_Dim

{{ config(
    materialized='table',
    tags=['gold', 'dimension', 'scd2'],
    unique_key='license_id'
) }}

-- CTE for data extraction and transformation from Silver layer
WITH silver_licenses AS (
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
    WHERE license_id IS NOT NULL
),

-- Data quality and transformation layer
transformed_licenses AS (
    SELECT 
        license_id,
        -- License type hierarchy mapping
        CASE 
            WHEN UPPER(license_type) = 'BASIC' THEN 'Basic'
            WHEN UPPER(license_type) = 'PRO' THEN 'Pro'
            WHEN UPPER(license_type) = 'ENTERPRISE' THEN 'Enterprise'
            WHEN UPPER(license_type) = 'PREMIUM' THEN 'Enterprise'
            ELSE COALESCE(license_type, 'Unknown')
        END AS license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        -- Assignment status derivation based on dates
        CASE 
            WHEN end_date IS NULL THEN 'Active'
            WHEN end_date < CURRENT_DATE THEN 'Expired'
            WHEN start_date <= CURRENT_DATE AND end_date >= CURRENT_DATE THEN 'Active'
            WHEN start_date > CURRENT_DATE THEN 'Pending'
            ELSE 'Unknown'
        END AS assignment_status,
        -- License capacity based on type
        CASE 
            WHEN UPPER(license_type) = 'BASIC' THEN 100
            WHEN UPPER(license_type) = 'PRO' THEN 500
            WHEN UPPER(license_type) = 'ENTERPRISE' THEN 1000
            ELSE 0
        END AS license_capacity,
        load_timestamp,
        update_timestamp,
        source_system,
        load_date,
        update_date
    FROM silver_licenses
),

-- Error detection and logging
error_records AS (
    SELECT 
        *,
        CASE 
            WHEN start_date IS NULL THEN 'NULL_START_DATE'
            WHEN start_date > COALESCE(end_date, '9999-12-31'::DATE) THEN 'INVALID_DATE_RANGE'
            WHEN LENGTH(license_type) > 100 THEN 'LICENSE_TYPE_TOO_LONG'
            WHEN LENGTH(assigned_to_user_id) > 255 THEN 'USER_ID_TOO_LONG'
            ELSE NULL
        END AS error_type
    FROM transformed_licenses
),

-- Valid records only (no errors)
valid_licenses AS (
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
        source_system
    FROM error_records
    WHERE error_type IS NULL
),

-- Final dimension table with SCD Type 2 columns
final_license_dim AS (
    SELECT 
        -- Business key
        license_id,
        -- Dimension attributes
        license_type,
        assigned_to_user_id,
        start_date,
        end_date,
        assignment_status,
        license_capacity,
        -- Audit columns
        load_timestamp,
        update_timestamp,
        load_date,
        update_date,
        source_system,
        -- SCD Type 2 columns
        {{ generate_scd_columns() }}
    FROM valid_licenses
)

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
    scd_current_flag
FROM final_license_dim

-- Data quality checks for incremental processing
{% if is_incremental() %}
    WHERE update_timestamp > (SELECT MAX(update_timestamp) FROM {{ this }})
{% endif %}