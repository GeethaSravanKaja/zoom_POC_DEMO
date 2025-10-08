{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, load_date, source_system) VALUES ('{{ invocation_id }}', 'go_participant_fact', 'gold_fact_pipeline', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_DATE(), 'DBT')",
    post_hook="UPDATE {{ ref('process_audit') }} SET execution_end_time = CURRENT_TIMESTAMP(), execution_status = 'COMPLETED', records_processed = (SELECT COUNT(*) FROM {{ this }}) WHERE execution_id = '{{ invocation_id }}' AND process_name = 'go_participant_fact'",
    cluster_by=['join_time', 'meeting_id']
) }}

/*
    Gold Layer Fact Table: Go_Participant_Fact
    Description: Individual participant engagement and attendance patterns
    Source: Silver.si_participants, Silver.si_users, Silver.si_meetings
    Author: Data Engineering Team
    Created: {{ run_started_at }}
*/

WITH participant_base AS (
    SELECT 
        participant_id,
        meeting_id,
        user_id,
        join_time,
        leave_time,
        load_timestamp,
        update_timestamp,
        source_system,
        load_date,
        update_date
    FROM {{ source('silver', 'si_participants') }}
    WHERE participant_id IS NOT NULL
),

user_info AS (
    SELECT 
        user_id,
        user_name
    FROM {{ source('silver', 'si_users') }}
    WHERE user_id IS NOT NULL
),

meeting_info AS (
    SELECT 
        meeting_id,
        host_id,
        duration_minutes
    FROM {{ source('silver', 'si_meetings') }}
    WHERE meeting_id IS NOT NULL
),

participant_enriched AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY p.participant_id, p.meeting_id, p.load_timestamp) AS participant_fact_id,
        UPPER(TRIM(p.participant_id)) AS participant_id,
        UPPER(TRIM(p.meeting_id)) AS meeting_id,
        UPPER(TRIM(p.user_id)) AS user_id,
        COALESCE(u.user_name, 'Unknown Participant') AS participant_name,
        COALESCE(p.join_time, '1900-01-01 00:00:00'::TIMESTAMP_NTZ) AS join_time,
        COALESCE(p.leave_time, p.join_time + INTERVAL '1 MINUTE') AS leave_time,
        CASE 
            WHEN p.leave_time IS NULL OR p.join_time IS NULL THEN 0
            WHEN p.leave_time <= p.join_time THEN 1
            ELSE DATEDIFF('minute', p.join_time, p.leave_time)
        END AS attendance_duration,
        CASE 
            WHEN p.user_id = m.host_id THEN 'Host'
            WHEN CASE 
                WHEN p.leave_time IS NULL OR p.join_time IS NULL THEN 0
                WHEN p.leave_time <= p.join_time THEN 1
                ELSE DATEDIFF('minute', p.join_time, p.leave_time)
            END >= (COALESCE(m.duration_minutes, 60) * 0.8) THEN 'Active Participant'
            WHEN CASE 
                WHEN p.leave_time IS NULL OR p.join_time IS NULL THEN 0
                WHEN p.leave_time <= p.join_time THEN 1
                ELSE DATEDIFF('minute', p.join_time, p.leave_time)
            END >= (COALESCE(m.duration_minutes, 60) * 0.5) THEN 'Moderate Participant'
            ELSE 'Brief Participant'
        END AS attendee_type,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        COALESCE(p.source_system, 'ZOOM_API') AS source_system
    FROM participant_base p
    LEFT JOIN user_info u ON p.user_id = u.user_id
    LEFT JOIN meeting_info m ON p.meeting_id = m.meeting_id
)

SELECT 
    participant_fact_id,
    participant_id,
    meeting_id,
    user_id,
    participant_name,
    join_time,
    leave_time,
    attendance_duration,
    attendee_type,
    load_timestamp,
    update_timestamp,
    load_date,
    update_date,
    source_system
FROM participant_enriched