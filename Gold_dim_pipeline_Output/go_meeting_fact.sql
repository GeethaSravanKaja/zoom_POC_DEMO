{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, load_date, source_system) SELECT '{{ invocation_id }}', 'go_meeting_fact', 'gold_dimension_pipeline', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_DATE(), 'DBT_GOLD_PIPELINE' WHERE '{{ this.name }}' != 'go_process_audit'",
    post_hook="INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_end_time, execution_status, records_processed, load_date, source_system) SELECT '{{ invocation_id }}', 'go_meeting_fact', 'gold_dimension_pipeline', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE(), 'DBT_GOLD_PIPELINE' WHERE '{{ this.name }}' != 'go_process_audit'"
) }}

-- Gold Layer Meeting Fact Table
-- Transforms Silver layer meeting data into Gold fact table
-- Source: Silver.si_meetings

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
    WHERE meeting_id IS NOT NULL
),

-- Get participant count for each meeting
participant_counts AS (
    SELECT
        meeting_id,
        COUNT(DISTINCT user_id) AS participant_count
    FROM {{ source('silver', 'si_participants') }}
    WHERE meeting_id IS NOT NULL
    GROUP BY meeting_id
),

-- Data transformations and enrichment
meeting_transformed AS (
    SELECT
        m.meeting_id,
        COALESCE(m.host_id, 'UNKNOWN_HOST') AS host_id,
        COALESCE(TRIM(m.meeting_topic), 'No Topic') AS meeting_topic,
        m.start_time,
        m.end_time,
        COALESCE(m.duration_minutes, 0) AS duration_minutes,
        COALESCE(pc.participant_count, 0) AS participant_count,
        -- Derive meeting type based on duration and participants
        CASE 
            WHEN COALESCE(m.duration_minutes, 0) <= 30 THEN 'Short Meeting'
            WHEN COALESCE(m.duration_minutes, 0) <= 60 THEN 'Standard Meeting'
            WHEN COALESCE(m.duration_minutes, 0) <= 120 THEN 'Long Meeting'
            ELSE 'Extended Meeting'
        END AS meeting_type,
        m.load_timestamp,
        m.update_timestamp,
        m.source_system,
        m.load_date,
        m.update_date
    FROM meeting_source m
    LEFT JOIN participant_counts pc ON m.meeting_id = pc.meeting_id
),

-- Add audit columns and final transformations
meeting_final AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY meeting_id) AS meeting_fact_id,
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        participant_count,
        meeting_type,
        load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        COALESCE(load_date, CURRENT_DATE()) AS load_date,
        CURRENT_DATE() AS update_date,
        COALESCE(source_system, 'Silver.si_meetings') AS source_system,
        -- Audit columns
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at,
        'SUCCESS' AS process_status
    FROM meeting_transformed
)

SELECT * FROM meeting_final