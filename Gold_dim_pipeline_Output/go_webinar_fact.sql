{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, load_date, source_system) SELECT '{{ invocation_id }}', 'go_webinar_fact', 'gold_dimension_pipeline', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_DATE(), 'DBT_GOLD_PIPELINE' WHERE '{{ this.name }}' != 'go_process_audit'",
    post_hook="INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_end_time, execution_status, records_processed, load_date, source_system) SELECT '{{ invocation_id }}', 'go_webinar_fact', 'gold_dimension_pipeline', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE(), 'DBT_GOLD_PIPELINE' WHERE '{{ this.name }}' != 'go_process_audit'"
) }}

-- Gold Layer Webinar Fact Table
-- Transforms Silver layer webinar data into Gold fact table
-- Source: Silver.si_webinars

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
    WHERE webinar_id IS NOT NULL
),

-- Data transformations and enrichment
webinar_transformed AS (
    SELECT
        webinar_id,
        COALESCE(host_id, 'UNKNOWN_HOST') AS host_id,
        COALESCE(TRIM(webinar_topic), 'No Topic') AS webinar_topic,
        start_time,
        end_time,
        -- Calculate duration in minutes
        CASE 
            WHEN start_time IS NOT NULL AND end_time IS NOT NULL 
            THEN DATEDIFF('minute', start_time, end_time)
            ELSE 0
        END AS duration_minutes,
        COALESCE(registrants, 0) AS registrants,
        -- Estimate actual attendees (typically 60-80% of registrants)
        CASE 
            WHEN registrants > 0 THEN ROUND(registrants * 0.7, 0)
            ELSE 0
        END AS actual_attendees,
        load_timestamp,
        update_timestamp,
        source_system,
        load_date,
        update_date
    FROM webinar_source
),

-- Add audit columns and final transformations
webinar_final AS (
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
        CURRENT_TIMESTAMP() AS update_timestamp,
        COALESCE(load_date, CURRENT_DATE()) AS load_date,
        CURRENT_DATE() AS update_date,
        COALESCE(source_system, 'Silver.si_webinars') AS source_system,
        -- Audit columns
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at,
        'SUCCESS' AS process_status
    FROM webinar_transformed
)

SELECT * FROM webinar_final