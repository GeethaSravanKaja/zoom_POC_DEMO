-- =====================================================
-- Go_Feature_Usage_Fact Model
-- Description: Gold Layer Feature Usage Fact Table
-- Source: Silver.si_feature_usage
-- Author: Data Engineer
-- =====================================================

{{ config(
    materialized='table',
    tags=['fact', 'gold', 'feature_usage'],
    on_schema_change='append_new_columns',
    pre_hook="{% if this.name != 'go_process_audit' %}INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, records_processed, start_time, status, load_date, update_date, source_system) VALUES ('{{ invocation_id }}', 'go_feature_usage_fact', 'gold_dimension_pipeline', CURRENT_TIMESTAMP, 'RUNNING', 0, CURRENT_TIMESTAMP, 'ACTIVE', CURRENT_DATE, CURRENT_DATE, 'DBT_PIPELINE'){% endif %}",
    post_hook="{% if this.name != 'go_process_audit' %}UPDATE {{ ref('go_process_audit') }} SET execution_end_time = CURRENT_TIMESTAMP, execution_status = 'COMPLETED', records_processed = (SELECT COUNT(*) FROM {{ this }}), records_inserted = (SELECT COUNT(*) FROM {{ this }}), process_duration_seconds = DATEDIFF(second, execution_start_time, CURRENT_TIMESTAMP), end_time = CURRENT_TIMESTAMP WHERE execution_id = '{{ invocation_id }}' AND process_name = 'go_feature_usage_fact'{% endif %}"
) }}

-- CTE for data transformation and cleansing
WITH source_data AS (
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
    WHERE usage_id IS NOT NULL -- Data quality check
),

-- Data transformation with business rules
transformed_data AS (
    SELECT
        usage_id,
        meeting_id,
        COALESCE(feature_name, 'Unknown Feature') AS feature_name,
        COALESCE(usage_count, 0) AS usage_count,
        usage_date,
        
        -- Derive usage duration (placeholder - would need actual duration data)
        CASE
            WHEN usage_count > 10 THEN usage_count * 2
            WHEN usage_count > 5 THEN usage_count * 1.5
            ELSE usage_count * 1
        END AS usage_duration,
        
        -- Derive feature category based on feature name
        CASE
            WHEN UPPER(feature_name) LIKE '%SCREEN%SHARE%' THEN 'Screen Sharing'
            WHEN UPPER(feature_name) LIKE '%CHAT%' THEN 'Communication'
            WHEN UPPER(feature_name) LIKE '%RECORD%' THEN 'Recording'
            WHEN UPPER(feature_name) LIKE '%BREAKOUT%' THEN 'Collaboration'
            WHEN UPPER(feature_name) LIKE '%POLL%' OR UPPER(feature_name) LIKE '%SURVEY%' THEN 'Engagement'
            WHEN UPPER(feature_name) LIKE '%WHITEBOARD%' THEN 'Collaboration'
            ELSE 'Other'
        END AS feature_category,
        
        -- Calculate feature success rate (placeholder - would need actual success/failure data)
        CASE
            WHEN usage_count > 0 THEN 95.0
            ELSE 0.0
        END AS feature_success_rate,
        
        -- Audit fields
        load_timestamp,
        update_timestamp,
        load_date,
        update_date,
        source_system
    FROM source_data
)

-- Final SELECT with all required fields for Go_Feature_Usage_Fact
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
    update_timestamp,
    load_date,
    update_date,
    source_system
FROM transformed_data