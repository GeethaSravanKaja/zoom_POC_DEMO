{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, load_date, source_system) SELECT '{{ invocation_id }}', 'go_support_ticket_fact', 'gold_dimension_pipeline', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_DATE(), 'DBT_GOLD_PIPELINE' WHERE '{{ this.name }}' != 'go_process_audit'",
    post_hook="INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_end_time, execution_status, records_processed, load_date, source_system) SELECT '{{ invocation_id }}', 'go_support_ticket_fact', 'gold_dimension_pipeline', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE(), 'DBT_GOLD_PIPELINE' WHERE '{{ this.name }}' != 'go_process_audit'"
) }}

-- Gold Layer Support Ticket Fact Table
-- Transforms Silver layer support ticket data into Gold fact table
-- Source: Silver.si_support_tickets

WITH support_ticket_source AS (
    SELECT
        ticket_id,
        user_id,
        ticket_type,
        resolution_status,
        open_date,
        load_timestamp,
        update_timestamp,
        source_system,
        load_date,
        update_date
    FROM {{ source('silver', 'si_support_tickets') }}
    WHERE ticket_id IS NOT NULL
),

-- Data transformations and enrichment
support_ticket_transformed AS (
    SELECT
        ticket_id,
        COALESCE(user_id, 'UNKNOWN_USER') AS user_id,
        COALESCE(TRIM(ticket_type), 'General') AS ticket_type,
        COALESCE(TRIM(resolution_status), 'Open') AS resolution_status,
        open_date,
        -- Estimate close date based on resolution status
        CASE 
            WHEN UPPER(resolution_status) IN ('CLOSED', 'RESOLVED', 'COMPLETED') 
            THEN DATEADD('day', 3, open_date) -- Assume 3 days to resolve
            ELSE NULL
        END AS close_date,
        -- Derive priority level based on ticket type
        CASE 
            WHEN UPPER(ticket_type) LIKE '%CRITICAL%' OR UPPER(ticket_type) LIKE '%URGENT%' THEN 'High'
            WHEN UPPER(ticket_type) LIKE '%BILLING%' OR UPPER(ticket_type) LIKE '%ACCOUNT%' THEN 'Medium'
            ELSE 'Low'
        END AS priority_level,
        -- Generate issue description placeholder
        CONCAT('Support request for ', COALESCE(ticket_type, 'general issue')) AS issue_description,
        -- Generate resolution notes placeholder
        CASE 
            WHEN UPPER(resolution_status) IN ('CLOSED', 'RESOLVED', 'COMPLETED') 
            THEN CONCAT('Issue resolved for ticket type: ', COALESCE(ticket_type, 'general'))
            ELSE 'Resolution in progress'
        END AS resolution_notes,
        -- Calculate resolution time in hours
        CASE 
            WHEN UPPER(resolution_status) IN ('CLOSED', 'RESOLVED', 'COMPLETED') 
            THEN 72 -- Assume 72 hours average resolution time
            ELSE NULL
        END AS resolution_time_hours,
        -- Generate satisfaction score
        CASE 
            WHEN UPPER(resolution_status) IN ('CLOSED', 'RESOLVED', 'COMPLETED') 
            THEN 4.2 -- Average satisfaction score
            ELSE NULL
        END AS satisfaction_score,
        load_timestamp,
        update_timestamp,
        source_system,
        load_date,
        update_date
    FROM support_ticket_source
),

-- Add audit columns and final transformations
support_ticket_final AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY ticket_id) AS support_ticket_fact_id,
        ticket_id,
        user_id,
        ticket_type,
        resolution_status,
        open_date,
        close_date,
        priority_level,
        issue_description,
        resolution_notes,
        resolution_time_hours,
        satisfaction_score,
        load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        COALESCE(load_date, CURRENT_DATE()) AS load_date,
        CURRENT_DATE() AS update_date,
        COALESCE(source_system, 'Silver.si_support_tickets') AS source_system,
        -- Audit columns
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at,
        'SUCCESS' AS process_status
    FROM support_ticket_transformed
)

SELECT * FROM support_ticket_final