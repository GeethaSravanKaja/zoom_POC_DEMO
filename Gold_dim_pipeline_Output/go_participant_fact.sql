{{ config(
    materialized='table',
    tags=['fact', 'gold'],
    pre_hook="{% if this.name != 'go_process_audit' %}INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, source_system, created_at, process_status) VALUES ('{{ invocation_id }}', 'go_participant_fact', 'Gold_Fact_Pipeline', CURRENT_TIMESTAMP, 'RUNNING', 'DBT_Gold_Pipeline', CURRENT_TIMESTAMP, 'ACTIVE'){% endif %}",
    post_hook="{% if this.name != 'go_process_audit' %}UPDATE {{ ref('go_process_audit') }} SET execution_end_time = CURRENT_TIMESTAMP, execution_status = 'COMPLETED', updated_at = CURRENT_TIMESTAMP, records_processed = (SELECT COUNT(*) FROM {{ this }}) WHERE execution_id = '{{ invocation_id }}' AND process_name = 'go_participant_fact'{% endif %}"
) }}

/*
_____________________________________________
## *Author*: AAVA Data Engineering Team
## *Created on*: {{ run_started_at }}
## *Description*: Gold Layer Participant Fact Table - DBT Model
## *Version*: 1.0
## *Purpose*: Meeting participation fact table for analytics and reporting
## *Source*: Silver.si_participants
_____________________________________________
*/

-- CTE for source data extraction
WITH participant_source AS (
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
    WHERE participant_id IS NOT NULL  -- Data quality filter
),

-- Get participant names from user dimension
user_info AS (
    SELECT
        user_id,
        user_name
    FROM {{ source('silver', 'si_users') }}
    WHERE user_id IS NOT NULL
),

-- Data transformation and business logic
participant_transformed AS (
    SELECT
        p.participant_id,
        p.meeting_id,
        p.user_id,
        COALESCE(u.user_name, 'Unknown Participant') AS participant_name,
        p.join_time,
        p.leave_time,
        -- Calculate attendance duration
        CASE 
            WHEN p.leave_time IS NOT NULL AND p.join_time IS NOT NULL 
            THEN DATEDIFF('minute', p.join_time, p.leave_time)
            ELSE 0
        END AS attendance_duration,
        -- Determine attendee type based on join/leave patterns
        CASE 
            WHEN p.leave_time IS NULL THEN 'Still Connected'
            WHEN DATEDIFF('minute', p.join_time, p.leave_time) < 5 THEN 'Brief Attendee'
            WHEN DATEDIFF('minute', p.join_time, p.leave_time) BETWEEN 5 AND 30 THEN 'Short Attendee'
            WHEN DATEDIFF('minute', p.join_time, p.leave_time) > 30 THEN 'Full Attendee'
            ELSE 'Unknown'
        END AS attendee_type,
        p.load_timestamp,
        p.update_timestamp,
        COALESCE(p.source_system, 'Silver.si_participants') AS source_system,
        p.load_date,
        p.update_date,
        -- Audit fields
        CURRENT_TIMESTAMP AS created_at,
        CURRENT_TIMESTAMP AS updated_at,
        'ACTIVE' AS process_status
    FROM participant_source p
    LEFT JOIN user_info u ON p.user_id = u.user_id
),

-- Data validation and error handling
participant_validated AS (
    SELECT *,
        CASE 
            WHEN participant_id IS NULL OR participant_id = '' THEN 'Missing Participant ID'
            WHEN meeting_id IS NULL OR meeting_id = '' THEN 'Missing Meeting ID'
            WHEN user_id IS NULL OR user_id = '' THEN 'Missing User ID'
            WHEN join_time IS NULL THEN 'Missing Join Time'
            WHEN leave_time IS NOT NULL AND leave_time < join_time THEN 'Invalid Time Range'
            WHEN attendance_duration < 0 THEN 'Invalid Duration'
            ELSE 'Valid'
        END AS data_quality_status
    FROM participant_transformed
)

-- Final select with all required columns for Gold layer
SELECT
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
    source_system,
    created_at,
    updated_at,
    process_status
FROM participant_validated
WHERE data_quality_status = 'Valid'  -- Only include valid records

-- Order by join_time for consistent processing
ORDER BY join_time DESC