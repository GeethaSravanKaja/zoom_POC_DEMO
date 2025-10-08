-- =====================================================
-- Go_Webinar_Fact Model
-- Description: Gold Layer Webinar Fact Table
-- Source: Silver.si_webinars
-- Author: Data Engineer
-- =====================================================

{{ config(
    materialized='table',
    tags=['fact', 'gold', 'webinar'],
    on_schema_change='append_new_columns',
    pre_hook="{% if this.name != 'go_process_audit' %}INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, records_processed, start_time, status, load_date, update_date, source_system) VALUES ('{{ invocation_id }}', 'go_webinar_fact', 'gold_dimension_pipeline', CURRENT_TIMESTAMP, 'RUNNING', 0, CURRENT_TIMESTAMP, 'ACTIVE', CURRENT_DATE, CURRENT_DATE, 'DBT_PIPELINE'){% endif %}",
    post_hook="{% if this.name != 'go_process_audit' %}UPDATE {{ ref('go_process_audit') }} SET execution_end_time = CURRENT_TIMESTAMP, execution_status = 'COMPLETED', records_processed = (SELECT COUNT(*) FROM {{ this }}), records_inserted = (SELECT COUNT(*) FROM {{ this }}), process_duration_seconds = DATEDIFF(second, execution_start_time, CURRENT_TIMESTAMP), end_time = CURRENT_TIMESTAMP WHERE execution_id = '{{ invocation_id }}' AND process_name = 'go_webinar_fact'{% endif %}"
) }}

-- CTE for data transformation and cleansing
WITH source_data AS (
    SELECT
        webinar_id,
        host_id,
        webinar_topic,
        start_time,
        end_time,
        registrants,
        load_timestamp,
        update_timestamp,
        source_system,
        load_date,
        update_date
    FROM {{ source('silver', 'si_webinars') }}
    WHERE webinar_id IS NOT NULL -- Data quality check
),

-- Data transformation with business rules
transformed_data AS (
    SELECT
        webinar_id,
        host_id,
        COALESCE(webinar_topic, 'Untitled Webinar') AS webinar_topic,
        start_time,
        end_time,
        
        -- Calculate duration in minutes
        CASE
            WHEN start_time IS NOT NULL AND end_time IS NOT NULL
            THEN DATEDIFF(minute, start_time, end_time)
            ELSE 0
        END AS duration_minutes,
        
        COALESCE(registrants, 0) AS registrants,
        
        -- Estimate actual attendees (placeholder - would need actual attendance data)
        -- Assuming 70% attendance rate on average
        ROUND(COALESCE(registrants, 0) * 0.7) AS actual_attendees,
        
        -- Audit fields
        load_timestamp,
        update_timestamp,
        load_date,
        update_date,
        source_system
    FROM source_data
)

-- Final SELECT with all required fields for Go_Webinar_Fact
SELECT
    ROW_NUMBER() OVER (ORDER BY webinar_id) AS webinar_fact_id,
    webinar_id,
    host_id,
    webinar_topic,
    start_time,
    end_time,
    duration_minutes,
    registrants,
    actual_attendees,
    load_timestamp,
    update_timestamp,
    load_date,
    update_date,
    source_system
FROM transformed_data