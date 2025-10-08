{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, load_date, source_system) SELECT '{{ invocation_id }}', 'go_participant_fact', 'gold_dimension_pipeline', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_DATE(), 'DBT_GOLD_PIPELINE' WHERE '{{ this.name }}' != 'go_process_audit'",
    post_hook="INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_end_time, execution_status, records_processed, load_date, source_system) SELECT '{{ invocation_id }}', 'go_participant_fact', 'gold_dimension_pipeline', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE(), 'DBT_GOLD_PIPELINE' WHERE '{{ this.name }}' != 'go_process_audit'"
) }}

-- Gold Layer Participant Fact Table
-- Transforms Silver layer participant data into Gold fact table
-- Source: Silver.si_participants

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
    WHERE participant_id IS NOT NULL
),

-- Get user names from users table
user_names AS (
    SELECT
        user_id,
        user_name
    FROM {{ source('silver', 'si_users') }}
    WHERE user_id IS NOT NULL
),

-- Data transformations and enrichment
participant_transformed AS (
    SELECT
        p.participant_id,
        p.meeting_id,
        COALESCE(p.user_id, 'UNKNOWN_USER') AS user_id,
        COALESCE(u.user_name, 'Unknown Participant') AS participant_name,
        p.join_time,
        p.leave_time,
        -- Calculate attendance duration in minutes
        CASE 
            WHEN p.join_time IS NOT NULL AND p.leave_time IS NOT NULL 
            THEN DATEDIFF('minute', p.join_time, p.leave_time)
            ELSE 0
        END AS attendance_duration,
        -- Derive attendee type based on attendance duration
        CASE 
            WHEN DATEDIFF('minute', p.join_time, p.leave_time) IS NULL THEN 'Unknown'
            WHEN DATEDIFF('minute', p.join_time, p.leave_time) < 5 THEN 'Brief Attendee'
            WHEN DATEDIFF('minute', p.join_time, p.leave_time) < 30 THEN 'Short Attendee'
            WHEN DATEDIFF('minute', p.join_time, p.leave_time) < 60 THEN 'Regular Attendee'
            ELSE 'Long Attendee'
        END AS attendee_type,
        p.load_timestamp,
        p.update_timestamp,
        p.source_system,
        p.load_date,
        p.update_date
    FROM participant_source p
    LEFT JOIN user_names u ON p.user_id = u.user_id
),

-- Add audit columns and final transformations
participant_final AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY participant_id) AS participant_fact_id,
        participant_id,
        meeting_id,
        user_id,
        participant_name,
        join_time,
        leave_time,
        attendance_duration,
        attendee_type,
        load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        COALESCE(load_date, CURRENT_DATE()) AS load_date,
        CURRENT_DATE() AS update_date,
        COALESCE(source_system, 'Silver.si_participants') AS source_system,
        -- Audit columns
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at,
        'SUCCESS' AS process_status
    FROM participant_transformed
)

SELECT * FROM participant_final