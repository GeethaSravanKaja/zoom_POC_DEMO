{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, load_date, source_system) VALUES ('{{ invocation_id }}', 'go_meeting_fact', 'gold_fact_pipeline', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_DATE(), 'DBT')",
    post_hook="UPDATE {{ ref('process_audit') }} SET execution_end_time = CURRENT_TIMESTAMP(), execution_status = 'COMPLETED', records_processed = (SELECT COUNT(*) FROM {{ this }}) WHERE execution_id = '{{ invocation_id }}' AND process_name = 'go_meeting_fact'",
    cluster_by=['start_time', 'host_id']
) }}

/*
    Gold Layer Fact Table: Go_Meeting_Fact
    Description: Meeting activity metrics and dimensions for analytical reporting
    Source: Silver.si_meetings, Silver.si_participants
    Author: Data Engineering Team
    Created: {{ run_started_at }}
*/

WITH meeting_base AS (
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
    WHERE meeting_id IS NOT NULL
),

participant_counts AS (
    SELECT 
        meeting_id,
        COUNT(DISTINCT participant_id) AS participant_count
    FROM {{ source('silver', 'si_participants') }}
    WHERE participant_id IS NOT NULL
    GROUP BY meeting_id
),

meeting_enriched AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY m.meeting_id, m.load_timestamp) AS meeting_fact_id,
        UPPER(TRIM(m.meeting_id)) AS meeting_id,
        UPPER(TRIM(m.host_id)) AS host_id,
        CASE 
            WHEN m.meeting_topic IS NULL OR TRIM(m.meeting_topic) = '' 
            THEN 'Unknown Meeting' 
            ELSE TRIM(m.meeting_topic) 
        END AS meeting_topic,
        COALESCE(m.start_time, '1900-01-01 00:00:00'::TIMESTAMP_NTZ) AS start_time,
        COALESCE(m.end_time, m.start_time + INTERVAL '30 MINUTES') AS end_time,
        CASE 
            WHEN m.duration_minutes IS NULL OR m.duration_minutes <= 0 
            THEN DATEDIFF('minute', m.start_time, m.end_time)
            WHEN m.duration_minutes > 1440 
            THEN 1440
            ELSE m.duration_minutes 
        END AS duration_minutes,
        COALESCE(pc.participant_count, 0) AS participant_count,
        CASE 
            WHEN COALESCE(m.duration_minutes, DATEDIFF('minute', m.start_time, m.end_time)) <= 15 
            THEN 'Quick Meeting'
            WHEN COALESCE(m.duration_minutes, DATEDIFF('minute', m.start_time, m.end_time)) <= 60 
            THEN 'Standard Meeting'
            WHEN COALESCE(m.duration_minutes, DATEDIFF('minute', m.start_time, m.end_time)) <= 240 
            THEN 'Extended Meeting'
            ELSE 'Marathon Meeting'
        END AS meeting_type,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        COALESCE(m.source_system, 'ZOOM_API') AS source_system
    FROM meeting_base m
    LEFT JOIN participant_counts pc ON m.meeting_id = pc.meeting_id
)

SELECT 
    meeting_fact_id,
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
    source_system
FROM meeting_enriched