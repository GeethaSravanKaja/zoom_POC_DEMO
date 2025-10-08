{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, load_date, source_system) SELECT '{{ invocation_id }}', 'go_feature_usage_fact', 'gold_dimension_pipeline', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_DATE(), 'DBT_GOLD_PIPELINE' WHERE '{{ this.name }}' != 'go_process_audit'",
    post_hook="INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_end_time, execution_status, records_processed, load_date, source_system) SELECT '{{ invocation_id }}', 'go_feature_usage_fact', 'gold_dimension_pipeline', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE(), 'DBT_GOLD_PIPELINE' WHERE '{{ this.name }}' != 'go_process_audit'"
) }}

-- Gold Layer Feature Usage Fact Table
-- Transforms Silver layer feature usage data into Gold fact table
-- Source: Silver.si_feature_usage

WITH feature_usage_source AS (
    SELECT
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        load_timestamp,
        update_timestamp,
        source_system,
        load_date,
        update_date
    FROM {{ source('silver', 'si_feature_usage') }}
    WHERE usage_id IS NOT NULL
),

-- Data transformations and enrichment
feature_usage_transformed AS (
    SELECT
        usage_id,
        COALESCE(meeting_id, 'UNKNOWN_MEETING') AS meeting_id,
        COALESCE(TRIM(feature_name), 'Unknown Feature') AS feature_name,
        COALESCE(usage_count, 0) AS usage_count,
        usage_date,
        -- Derive usage duration (estimated based on usage count)
        CASE 
            WHEN usage_count > 0 THEN usage_count * 2 -- Assume 2 minutes per usage
            ELSE 0
        END AS usage_duration,
        -- Categorize features
        CASE 
            WHEN UPPER(feature_name) LIKE '%SCREEN%SHARE%' OR UPPER(feature_name) LIKE '%SHARE%SCREEN%' THEN 'Screen Sharing'
            WHEN UPPER(feature_name) LIKE '%CHAT%' OR UPPER(feature_name) LIKE '%MESSAGE%' THEN 'Communication'
            WHEN UPPER(feature_name) LIKE '%RECORD%' THEN 'Recording'
            WHEN UPPER(feature_name) LIKE '%WHITEBOARD%' OR UPPER(feature_name) LIKE '%ANNOTATION%' THEN 'Collaboration'
            WHEN UPPER(feature_name) LIKE '%BREAKOUT%' THEN 'Breakout Rooms'
            WHEN UPPER(feature_name) LIKE '%POLL%' OR UPPER(feature_name) LIKE '%QUIZ%' THEN 'Engagement'
            ELSE 'Other'
        END AS feature_category,
        -- Calculate feature success rate (simplified)
        CASE 
            WHEN usage_count > 0 THEN 95.0 -- Assume 95% success rate for used features
            ELSE 0.0
        END AS feature_success_rate,
        load_timestamp,
        update_timestamp,
        source_system,
        load_date,
        update_date
    FROM feature_usage_source
),

-- Add audit columns and final transformations
feature_usage_final AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY usage_id) AS feature_usage_fact_id,
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        usage_duration,
        feature_category,
        feature_success_rate,
        load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        COALESCE(load_date, CURRENT_DATE()) AS load_date,
        CURRENT_DATE() AS update_date,
        COALESCE(source_system, 'Silver.si_feature_usage') AS source_system,
        -- Audit columns
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at,
        'SUCCESS' AS process_status
    FROM feature_usage_transformed
)

SELECT * FROM feature_usage_final