{{ config(
    materialized='table',
    tags=['fact', 'gold'],
    pre_hook="{% if this.name != 'go_process_audit' %}INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, source_system, created_at, process_status) VALUES ('{{ invocation_id }}', 'go_webinar_fact', 'Gold_Fact_Pipeline', CURRENT_TIMESTAMP, 'RUNNING', 'DBT_Gold_Pipeline', CURRENT_TIMESTAMP, 'ACTIVE'){% endif %}",
    post_hook="{% if this.name != 'go_process_audit' %}UPDATE {{ ref('go_process_audit') }} SET execution_end_time = CURRENT_TIMESTAMP, execution_status = 'COMPLETED', updated_at = CURRENT_TIMESTAMP, records_processed = (SELECT COUNT(*) FROM {{ this }}) WHERE execution_id = '{{ invocation_id }}' AND process_name = 'go_webinar_fact'{% endif %}"
) }}

/*
_____________________________________________
## *Author*: AAVA Data Engineering Team
## *Created on*: {{ run_started_at }}
## *Description*: Gold Layer Webinar Fact Table - DBT Model
## *Version*: 1.0
## *Purpose*: Webinar activity fact table for analytics and reporting
## *Source*: Silver.si_webinars
_____________________________________________
*/

-- CTE for source data extraction
WITH webinar_source AS (
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
    WHERE webinar_id IS NOT NULL  -- Data quality filter
),

-- Data transformation and business logic
webinar_transformed AS (
    SELECT
        webinar_id,
        host_id,
        COALESCE(TRIM(webinar_topic), 'No Topic') AS webinar_topic,
        start_time,
        end_time,
        -- Calculate duration
        CASE 
            WHEN end_time IS NOT NULL AND start_time IS NOT NULL 
            THEN DATEDIFF('minute', start_time, end_time)
            ELSE 0
        END AS duration_minutes,
        COALESCE(registrants, 0) AS registrants,
        -- Estimate actual attendees (typically 60-70% of registrants)
        CASE 
            WHEN registrants > 0 THEN ROUND(registrants * 0.65)
            ELSE 0
        END AS actual_attendees,
        load_timestamp,
        update_timestamp,
        COALESCE(source_system, 'Silver.si_webinars') AS source_system,
        load_date,
        update_date,
        -- Audit fields
        CURRENT_TIMESTAMP AS created_at,
        CURRENT_TIMESTAMP AS updated_at,
        'ACTIVE' AS process_status
    FROM webinar_source
),

-- Data validation and error handling
webinar_validated AS (
    SELECT *,
        CASE 
            WHEN webinar_id IS NULL OR webinar_id = '' THEN 'Missing Webinar ID'
            WHEN host_id IS NULL OR host_id = '' THEN 'Missing Host ID'
            WHEN start_time IS NULL THEN 'Missing Start Time'
            WHEN end_time IS NOT NULL AND end_time < start_time THEN 'Invalid Time Range'
            WHEN registrants < 0 THEN 'Invalid Registrant Count'
            ELSE 'Valid'
        END AS data_quality_status
    FROM webinar_transformed
)

-- Final select with all required columns for Gold layer
SELECT
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
    source_system,
    created_at,
    updated_at,
    process_status
FROM webinar_validated
WHERE data_quality_status = 'Valid'  -- Only include valid records

-- Order by start_time for consistent processing
ORDER BY start_time DESC