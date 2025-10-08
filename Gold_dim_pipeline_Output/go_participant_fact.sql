-- =====================================================
-- Go_Participant_Fact Model
-- Description: Gold Layer Participant Fact Table
-- Source: Silver.si_participants
-- Author: Data Engineer
-- =====================================================

{{ config(
    materialized='table',
    tags=['fact', 'gold', 'participant'],
    on_schema_change='append_new_columns',
    pre_hook="{% if this.name != 'go_process_audit' %}INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, records_processed, start_time, status, load_date, update_date, source_system) VALUES ('{{ invocation_id }}', 'go_participant_fact', 'gold_dimension_pipeline', CURRENT_TIMESTAMP, 'RUNNING', 0, CURRENT_TIMESTAMP, 'ACTIVE', CURRENT_DATE, CURRENT_DATE, 'DBT_PIPELINE'){% endif %}",
    post_hook="{% if this.name != 'go_process_audit' %}UPDATE {{ ref('go_process_audit') }} SET execution_end_time = CURRENT_TIMESTAMP, execution_status = 'COMPLETED', records_processed = (SELECT COUNT(*) FROM {{ this }}), records_inserted = (SELECT COUNT(*) FROM {{ this }}), process_duration_seconds = DATEDIFF(second, execution_start_time, CURRENT_TIMESTAMP), end_time = CURRENT_TIMESTAMP WHERE execution_id = '{{ invocation_id }}' AND process_name = 'go_participant_fact'{% endif %}"
) }}

-- CTE for data transformation and cleansing
WITH source_data AS (
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
    WHERE participant_id IS NOT NULL -- Data quality check
),

-- Data transformation with business rules
transformed_data AS (
    SELECT
        participant_id,
        meeting_id,
        user_id,
        
        -- Derive participant name (placeholder - would need join with users table)
        COALESCE('Participant_' || user_id, 'Unknown Participant') AS participant_name,
        
        join_time,
        leave_time,
        
        -- Calculate attendance duration in minutes
        CASE
            WHEN join_time IS NOT NULL AND leave_time IS NOT NULL
            THEN DATEDIFF(minute, join_time, leave_time)
            ELSE 0
        END AS attendance_duration,
        
        -- Derive attendee type based on attendance duration
        CASE
            WHEN DATEDIFF(minute, join_time, leave_time) >= 60 THEN 'Full Attendee'
            WHEN DATEDIFF(minute, join_time, leave_time) >= 30 THEN 'Partial Attendee'
            WHEN DATEDIFF(minute, join_time, leave_time) >= 5 THEN 'Brief Attendee'
            WHEN DATEDIFF(minute, join_time, leave_time) < 5 THEN 'Drop-in'
            ELSE 'Unknown'
        END AS attendee_type,
        
        -- Audit fields
        load_timestamp,
        update_timestamp,
        load_date,
        update_date,
        source_system
    FROM source_data
)

-- Final SELECT with all required fields for Go_Participant_Fact
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
    update_timestamp,
    load_date,
    update_date,
    source_system
FROM transformed_data