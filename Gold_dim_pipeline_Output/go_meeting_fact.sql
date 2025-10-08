-- =====================================================
-- Go_Meeting_Fact Model
-- Description: Gold Layer Meeting Fact Table
-- Source: Silver.si_meetings
-- Author: Data Engineer
-- =====================================================

{{ config(
    materialized='table',
    tags=['fact', 'gold', 'meeting'],
    on_schema_change='append_new_columns',
    pre_hook="{% if this.name != 'go_process_audit' %}INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, records_processed, start_time, status, load_date, update_date, source_system) VALUES ('{{ invocation_id }}', 'go_meeting_fact', 'gold_dimension_pipeline', CURRENT_TIMESTAMP, 'RUNNING', 0, CURRENT_TIMESTAMP, 'ACTIVE', CURRENT_DATE, CURRENT_DATE, 'DBT_PIPELINE'){% endif %}",
    post_hook="{% if this.name != 'go_process_audit' %}UPDATE {{ ref('go_process_audit') }} SET execution_end_time = CURRENT_TIMESTAMP, execution_status = 'COMPLETED', records_processed = (SELECT COUNT(*) FROM {{ this }}), records_inserted = (SELECT COUNT(*) FROM {{ this }}), process_duration_seconds = DATEDIFF(second, execution_start_time, CURRENT_TIMESTAMP), end_time = CURRENT_TIMESTAMP WHERE execution_id = '{{ invocation_id }}' AND process_name = 'go_meeting_fact'{% endif %}"
) }}

-- CTE for data transformation and cleansing
WITH source_data AS (
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
    WHERE meeting_id IS NOT NULL -- Data quality check
),

-- Data transformation with business rules
transformed_data AS (
    SELECT
        meeting_id,
        host_id,
        COALESCE(meeting_topic, 'Untitled Meeting') AS meeting_topic,
        start_time,
        end_time,
        COALESCE(duration_minutes, 0) AS duration_minutes,
        
        -- Calculate participant count (placeholder - would need join with participants table)
        0 AS participant_count,
        
        -- Derive meeting type based on duration and topic
        CASE
            WHEN duration_minutes <= 15 THEN 'Quick Meeting'
            WHEN duration_minutes <= 60 THEN 'Standard Meeting'
            WHEN duration_minutes <= 120 THEN 'Long Meeting'
            WHEN duration_minutes > 120 THEN 'Extended Meeting'
            ELSE 'Unknown'
        END AS meeting_type,
        
        -- Audit fields
        load_timestamp,
        update_timestamp,
        load_date,
        update_date,
        source_system
    FROM source_data
)

-- Final SELECT with all required fields for Go_Meeting_Fact
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
    update_timestamp,
    load_date,
    update_date,
    source_system
FROM transformed_data