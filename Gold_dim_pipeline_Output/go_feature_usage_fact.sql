{{ config(
    materialized='table',
    tags=['fact', 'gold'],
    pre_hook="{% if this.name != 'go_process_audit' %}INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, source_system, created_at, process_status) VALUES ('{{ invocation_id }}', 'go_feature_usage_fact', 'Gold_Fact_Pipeline', CURRENT_TIMESTAMP, 'RUNNING', 'DBT_Gold_Pipeline', CURRENT_TIMESTAMP, 'ACTIVE'){% endif %}",
    post_hook="{% if this.name != 'go_process_audit' %}UPDATE {{ ref('go_process_audit') }} SET execution_end_time = CURRENT_TIMESTAMP, execution_status = 'COMPLETED', updated_at = CURRENT_TIMESTAMP, records_processed = (SELECT COUNT(*) FROM {{ this }}) WHERE execution_id = '{{ invocation_id }}' AND process_name = 'go_feature_usage_fact'{% endif %}"
) }}

/*
_____________________________________________
## *Author*: AAVA Data Engineering Team
## *Created on*: {{ run_started_at }}
## *Description*: Gold Layer Feature Usage Fact Table - DBT Model
## *Version*: 1.0
## *Purpose*: Feature utilization fact table for analytics and reporting
## *Source*: Silver.si_feature_usage
_____________________________________________
*/

-- CTE for source data extraction
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
    WHERE usage_id IS NOT NULL  -- Data quality filter
),

-- Data transformation and business logic
feature_usage_transformed AS (
    SELECT
        usage_id,
        meeting_id,
        COALESCE(TRIM(feature_name), 'Unknown Feature') AS feature_name,
        COALESCE(usage_count, 0) AS usage_count,
        usage_date,
        -- Calculate usage duration (estimated based on feature type)
        CASE 
            WHEN UPPER(feature_name) LIKE '%SCREEN%SHARE%' THEN usage_count * 5  -- 5 minutes per usage
            WHEN UPPER(feature_name) LIKE '%CHAT%' THEN usage_count * 1         -- 1 minute per usage
            WHEN UPPER(feature_name) LIKE '%RECORDING%' THEN usage_count * 30    -- 30 minutes per usage
            WHEN UPPER(feature_name) LIKE '%BREAKOUT%' THEN usage_count * 15     -- 15 minutes per usage
            ELSE usage_count * 2  -- Default 2 minutes per usage
        END AS usage_duration,
        -- Categorize features
        CASE 
            WHEN UPPER(feature_name) LIKE '%SCREEN%SHARE%' OR UPPER(feature_name) LIKE '%SHARE%' THEN 'Collaboration'
            WHEN UPPER(feature_name) LIKE '%CHAT%' OR UPPER(feature_name) LIKE '%MESSAGE%' THEN 'Communication'
            WHEN UPPER(feature_name) LIKE '%RECORDING%' OR UPPER(feature_name) LIKE '%RECORD%' THEN 'Recording'
            WHEN UPPER(feature_name) LIKE '%BREAKOUT%' OR UPPER(feature_name) LIKE '%ROOM%' THEN 'Room Management'
            WHEN UPPER(feature_name) LIKE '%POLL%' OR UPPER(feature_name) LIKE '%SURVEY%' THEN 'Engagement'
            WHEN UPPER(feature_name) LIKE '%WHITEBOARD%' OR UPPER(feature_name) LIKE '%ANNOTATION%' THEN 'Annotation'
            ELSE 'Other'
        END AS feature_category,
        -- Calculate feature success rate (assumed 95% for most features)
        CASE 
            WHEN usage_count > 0 THEN 95.0
            ELSE 0.0
        END AS feature_success_rate,
        load_timestamp,
        update_timestamp,
        COALESCE(source_system, 'Silver.si_feature_usage') AS source_system,
        load_date,
        update_date,
        -- Audit fields
        CURRENT_TIMESTAMP AS created_at,
        CURRENT_TIMESTAMP AS updated_at,
        'ACTIVE' AS process_status
    FROM feature_usage_source
),

-- Data validation and error handling
feature_usage_validated AS (
    SELECT *,
        CASE 
            WHEN usage_id IS NULL OR usage_id = '' THEN 'Missing Usage ID'
            WHEN meeting_id IS NULL OR meeting_id = '' THEN 'Missing Meeting ID'
            WHEN feature_name IS NULL OR feature_name = '' THEN 'Missing Feature Name'
            WHEN usage_count < 0 THEN 'Invalid Usage Count'
            WHEN usage_date IS NULL THEN 'Missing Usage Date'
            ELSE 'Valid'
        END AS data_quality_status
    FROM feature_usage_transformed
)

-- Final select with all required columns for Gold layer
SELECT
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
    source_system,
    created_at,
    updated_at,
    process_status
FROM feature_usage_validated
WHERE data_quality_status = 'Valid'  -- Only include valid records

-- Order by usage_date for consistent processing
ORDER BY usage_date DESC, feature_name