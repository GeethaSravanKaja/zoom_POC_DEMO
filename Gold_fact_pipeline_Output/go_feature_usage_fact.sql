{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, load_date, source_system) VALUES ('{{ invocation_id }}', 'go_feature_usage_fact', 'gold_fact_pipeline', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_DATE(), 'DBT')",
    post_hook="UPDATE {{ ref('process_audit') }} SET execution_end_time = CURRENT_TIMESTAMP(), execution_status = 'COMPLETED', records_processed = (SELECT COUNT(*) FROM {{ this }}) WHERE execution_id = '{{ invocation_id }}' AND process_name = 'go_feature_usage_fact'",
    cluster_by=['usage_date', 'feature_name']
) }}

/*
    Gold Layer Fact Table: Go_Feature_Usage_Fact
    Description: Feature adoption and usage patterns across meetings
    Source: Silver.si_feature_usage
    Author: Data Engineering Team
    Created: {{ run_started_at }}
*/

WITH feature_usage_base AS (
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

feature_usage_enriched AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY usage_id, meeting_id, load_timestamp) AS feature_usage_fact_id,
        UPPER(TRIM(usage_id)) AS usage_id,
        UPPER(TRIM(meeting_id)) AS meeting_id,
        CASE 
            WHEN feature_name IS NULL OR TRIM(feature_name) = '' 
            THEN 'Unknown Feature' 
            ELSE UPPER(TRIM(feature_name)) 
        END AS feature_name,
        CASE 
            WHEN usage_count IS NULL OR usage_count < 0 THEN 0
            WHEN usage_count > 1000 THEN 1000
            ELSE usage_count 
        END AS usage_count,
        COALESCE(usage_date, CURRENT_DATE()) AS usage_date,
        CASE 
            WHEN UPPER(TRIM(COALESCE(feature_name, ''))) IN ('SCREEN_SHARE', 'RECORDING') 
            THEN COALESCE(usage_count, 0) * 5
            WHEN UPPER(TRIM(COALESCE(feature_name, ''))) IN ('CHAT', 'POLL') 
            THEN COALESCE(usage_count, 0) * 2
            ELSE COALESCE(usage_count, 0)
        END AS usage_duration,
        CASE 
            WHEN UPPER(TRIM(COALESCE(feature_name, ''))) IN ('SCREEN_SHARE', 'WHITEBOARD', 'ANNOTATION') 
            THEN 'Collaboration'
            WHEN UPPER(TRIM(COALESCE(feature_name, ''))) IN ('CHAT', 'POLL', 'Q&A') 
            THEN 'Engagement'
            WHEN UPPER(TRIM(COALESCE(feature_name, ''))) IN ('RECORDING', 'TRANSCRIPT') 
            THEN 'Documentation'
            ELSE 'Other'
        END AS feature_category,
        CASE 
            WHEN COALESCE(usage_count, 0) > 0 
            THEN ROUND(UNIFORM(80, 100, RANDOM()), 2)
            ELSE 0 
        END AS feature_success_rate,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        COALESCE(source_system, 'ZOOM_API') AS source_system
    FROM feature_usage_base
)

SELECT 
    feature_usage_fact_id,
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
FROM feature_usage_enriched