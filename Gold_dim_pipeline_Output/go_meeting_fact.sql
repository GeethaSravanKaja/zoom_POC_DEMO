{{ config(
    materialized='table',
    tags=['fact', 'gold'],
    pre_hook="{% if this.name != 'go_process_audit' %}INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, source_system, created_at, process_status) VALUES ('{{ invocation_id }}', 'go_meeting_fact', 'Gold_Fact_Pipeline', CURRENT_TIMESTAMP, 'RUNNING', 'DBT_Gold_Pipeline', CURRENT_TIMESTAMP, 'ACTIVE'){% endif %}",
    post_hook="{% if this.name != 'go_process_audit' %}UPDATE {{ ref('go_process_audit') }} SET execution_end_time = CURRENT_TIMESTAMP, execution_status = 'COMPLETED', updated_at = CURRENT_TIMESTAMP, records_processed = (SELECT COUNT(*) FROM {{ this }}) WHERE execution_id = '{{ invocation_id }}' AND process_name = 'go_meeting_fact'{% endif %}"
) }}

/*
_____________________________________________
## *Author*: AAVA Data Engineering Team
## *Created on*: {{ run_started_at }}
## *Description*: Gold Layer Meeting Fact Table - DBT Model
## *Version*: 1.0
## *Purpose*: Meeting activity fact table for analytics and reporting
## *Source*: Silver.si_meetings
_____________________________________________
*/

-- CTE for source data extraction
WITH meeting_source AS (
    SELECT
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        load_timestamp,
        update_timestamp,
        source_system,
        load_date,
        update_date
    FROM {{ source('silver', 'si_meetings') }}
    WHERE meeting_id IS NOT NULL  -- Data quality filter
),

-- Get participant count for each meeting
participant_counts AS (
    SELECT
        meeting_id,
        COUNT(DISTINCT participant_id) AS participant_count
    FROM {{ source('silver', 'si_participants') }}
    WHERE meeting_id IS NOT NULL
    GROUP BY meeting_id
),

-- Data transformation and business logic
meeting_transformed AS (
    SELECT
        m.meeting_id,
        m.host_id,
        COALESCE(TRIM(m.meeting_topic), 'No Topic') AS meeting_topic,
        m.start_time,
        m.end_time,
        COALESCE(m.duration_minutes, 
            CASE 
                WHEN m.end_time IS NOT NULL AND m.start_time IS NOT NULL 
                THEN DATEDIFF('minute', m.start_time, m.end_time)
                ELSE 0
            END
        ) AS duration_minutes,
        COALESCE(p.participant_count, 0) AS participant_count,
        -- Derive meeting type based on duration and participants
        CASE 
            WHEN COALESCE(p.participant_count, 0) = 1 THEN 'Personal'
            WHEN COALESCE(p.participant_count, 0) BETWEEN 2 AND 10 THEN 'Small Group'
            WHEN COALESCE(p.participant_count, 0) BETWEEN 11 AND 50 THEN 'Medium Group'
            WHEN COALESCE(p.participant_count, 0) > 50 THEN 'Large Group'
            ELSE 'Unknown'
        END AS meeting_type,
        m.load_timestamp,
        m.update_timestamp,
        COALESCE(m.source_system, 'Silver.si_meetings') AS source_system,
        m.load_date,
        m.update_date,
        -- Audit fields
        CURRENT_TIMESTAMP AS created_at,
        CURRENT_TIMESTAMP AS updated_at,
        'ACTIVE' AS process_status
    FROM meeting_source m
    LEFT JOIN participant_counts p ON m.meeting_id = p.meeting_id
),

-- Data validation and error handling
meeting_validated AS (
    SELECT *,
        CASE 
            WHEN meeting_id IS NULL OR meeting_id = '' THEN 'Missing Meeting ID'
            WHEN host_id IS NULL OR host_id = '' THEN 'Missing Host ID'
            WHEN start_time IS NULL THEN 'Missing Start Time'
            WHEN end_time IS NOT NULL AND end_time < start_time THEN 'Invalid Time Range'
            WHEN duration_minutes < 0 THEN 'Invalid Duration'
            ELSE 'Valid'
        END AS data_quality_status
    FROM meeting_transformed
)

-- Final select with all required columns for Gold layer
SELECT
    meeting_id,
    host_id,
    meeting_topic,
    start_time,
    end_time,
    duration_minutes,
    participant_count,
    meeting_type,
    load_timestamp,
    update_timestamp,
    load_date,
    update_date,
    source_system,
    created_at,
    updated_at,
    process_status
FROM meeting_validated
WHERE data_quality_status = 'Valid'  -- Only include valid records

-- Order by start_time for consistent processing
ORDER BY start_time DESC