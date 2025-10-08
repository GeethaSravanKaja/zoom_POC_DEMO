{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, load_date, source_system) SELECT '{{ invocation_id }}', 'go_license_dim', 'gold_dimension_pipeline', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_DATE(), 'DBT_GOLD_PIPELINE' WHERE '{{ this.name }}' != 'go_process_audit'",
    post_hook="INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_end_time, execution_status, records_processed, load_date, source_system) SELECT '{{ invocation_id }}', 'go_license_dim', 'gold_dimension_pipeline', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE(), 'DBT_GOLD_PIPELINE' WHERE '{{ this.name }}' != 'go_process_audit'"
) }}

-- Gold Layer License Dimension Table
-- Transforms Silver layer license data into Gold dimension with SCD Type 2
-- Source: Silver.si_licenses

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
    WHERE license_id IS NOT NULL
),

-- Data quality checks and transformations
license_transformed AS (
    SELECT
        license_id,
        -- License type hierarchy mapping
        CASE 
            WHEN UPPER(license_type) IN ('BASIC', 'FREE') THEN 'Basic'
            WHEN UPPER(license_type) IN ('PRO', 'PROFESSIONAL') THEN 'Pro'
            WHEN UPPER(license_type) IN ('ENTERPRISE', 'BUSINESS') THEN 'Enterprise'
            ELSE 'Unknown'
        END AS license_type,
        COALESCE(assigned_to_user_id, 'UNASSIGNED') AS assigned_to_user_id,
        start_date,
        end_date,
        -- Assignment status derivation
        CASE
            WHEN end_date < CURRENT_DATE() THEN 'Expired'
            WHEN start_date <= CURRENT_DATE() AND (end_date >= CURRENT_DATE() OR end_date IS NULL) THEN 'Active'
            WHEN start_date > CURRENT_DATE() THEN 'Pending'
            ELSE 'Unknown'
        END AS assignment_status,
        -- License capacity based on type
        CASE 
            WHEN UPPER(license_type) IN ('BASIC', 'FREE') THEN 100
            WHEN UPPER(license_type) IN ('PRO', 'PROFESSIONAL') THEN 500
            WHEN UPPER(license_type) IN ('ENTERPRISE', 'BUSINESS') THEN 1000
            ELSE 0
        END AS license_capacity,
        load_timestamp,
        update_timestamp,
        source_system,
        load_date,
        update_date,
        -- SCD Type 2 fields
        COALESCE(load_date, CURRENT_DATE()) AS scd_start_date,
        '9999-12-31'::DATE AS scd_end_date,
        TRUE AS scd_current_flag
    FROM license_source
),

-- Add audit columns and final transformations
license_final AS (
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
        CURRENT_TIMESTAMP() AS update_timestamp,
        COALESCE(load_date, CURRENT_DATE()) AS load_date,
        CURRENT_DATE() AS update_date,
        COALESCE(source_system, 'Silver.si_licenses') AS source_system,
        scd_start_date,
        scd_end_date,
        scd_current_flag,
        -- Audit columns
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at,
        'SUCCESS' AS process_status
    FROM license_transformed
)

SELECT * FROM license_final