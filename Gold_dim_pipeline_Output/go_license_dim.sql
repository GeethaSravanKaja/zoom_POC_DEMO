-- =====================================================
-- Go_License_Dim Model
-- Description: Gold Layer License Dimension Table with SCD Type 2
-- Source: Silver.si_licenses
-- Author: Data Engineer
-- =====================================================

{{ config(
    materialized='table',
    tags=['dimension', 'gold', 'scd2'],
    on_schema_change='append_new_columns',
    pre_hook="{% if this.name != 'go_process_audit' %}INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, records_processed, start_time, status, load_date, update_date, source_system) VALUES ('{{ invocation_id }}', 'go_license_dim', 'gold_dimension_pipeline', CURRENT_TIMESTAMP, 'RUNNING', 0, CURRENT_TIMESTAMP, 'ACTIVE', CURRENT_DATE, CURRENT_DATE, 'DBT_PIPELINE'){% endif %}",
    post_hook="{% if this.name != 'go_process_audit' %}UPDATE {{ ref('go_process_audit') }} SET execution_end_time = CURRENT_TIMESTAMP, execution_status = 'COMPLETED', records_processed = (SELECT COUNT(*) FROM {{ this }}), records_inserted = (SELECT COUNT(*) FROM {{ this }}), process_duration_seconds = DATEDIFF(second, execution_start_time, CURRENT_TIMESTAMP), end_time = CURRENT_TIMESTAMP WHERE execution_id = '{{ invocation_id }}' AND process_name = 'go_license_dim'{% endif %}"
) }}

-- CTE for data transformation and cleansing
WITH source_data AS (
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
    WHERE license_id IS NOT NULL -- Data quality check
),

-- Data transformation with business rules
transformed_data AS (
    SELECT
        license_id,
        COALESCE(license_type, 'Unknown') AS license_type,
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
        
        -- Calculate license capacity based on license type
        CASE
            WHEN UPPER(license_type) LIKE '%BASIC%' THEN 100
            WHEN UPPER(license_type) LIKE '%PRO%' THEN 500
            WHEN UPPER(license_type) LIKE '%ENTERPRISE%' THEN 1000
            ELSE 50
        END AS license_capacity,
        
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

-- Final SELECT with all required fields for Go_License_Dim
SELECT
    ROW_NUMBER() OVER (ORDER BY license_id) AS license_dim_id,
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
FROM transformed_data