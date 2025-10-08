{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, load_date, source_system) VALUES ('{{ invocation_id }}', 'go_billing_event_fact', 'gold_fact_pipeline', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_DATE(), 'DBT')",
    post_hook="UPDATE {{ ref('process_audit') }} SET execution_end_time = CURRENT_TIMESTAMP(), execution_status = 'COMPLETED', records_processed = (SELECT COUNT(*) FROM {{ this }}) WHERE execution_id = '{{ invocation_id }}' AND process_name = 'go_billing_event_fact'",
    cluster_by=['event_date', 'user_id']
) }}

/*
    Gold Layer Fact Table: Go_Billing_Event_Fact
    Description: Financial transactions and billing events for revenue analytics
    Source: Silver.si_billing_events
    Author: Data Engineering Team
    Created: {{ run_started_at }}
*/

WITH billing_event_base AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        amount,
        event_date,
        load_timestamp,
        update_timestamp,
        source_system,
        load_date,
        update_date
    FROM {{ source('silver', 'si_billing_events') }}
    WHERE event_id IS NOT NULL
),

billing_event_enriched AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY event_id, load_timestamp) AS billing_event_fact_id,
        UPPER(TRIM(event_id)) AS event_id,
        UPPER(TRIM(user_id)) AS user_id,
        CASE 
            WHEN event_type IS NULL OR TRIM(event_type) = '' 
            THEN 'Unknown' 
            ELSE UPPER(TRIM(event_type)) 
        END AS event_type,
        CASE 
            WHEN amount IS NULL OR amount < 0 THEN 0.00
            WHEN amount > 100000 THEN 100000.00
            ELSE ROUND(amount, 2) 
        END AS amount,
        COALESCE(event_date, CURRENT_DATE()) AS event_date,
        COALESCE(event_date, CURRENT_DATE()) AS transaction_date,
        'USD' AS currency,
        CASE 
            WHEN UPPER(TRIM(COALESCE(event_type, ''))) IN ('SUBSCRIPTION', 'RENEWAL') THEN 'Credit Card'
            WHEN UPPER(TRIM(COALESCE(event_type, ''))) = 'REFUND' THEN 'Refund'
            ELSE 'Other'
        END AS payment_method,
        CASE 
            WHEN UPPER(TRIM(COALESCE(event_type, ''))) IN ('SUBSCRIPTION', 'RENEWAL') THEN 'Monthly'
            WHEN UPPER(TRIM(COALESCE(event_type, ''))) = 'ANNUAL' THEN 'Annual'
            ELSE 'One-time'
        END AS billing_cycle,
        CURRENT_TIMESTAMP() AS load_timestamp,
        CURRENT_TIMESTAMP() AS update_timestamp,
        CURRENT_DATE() AS load_date,
        CURRENT_DATE() AS update_date,
        COALESCE(source_system, 'ZOOM_BILLING') AS source_system
    FROM billing_event_base
)

SELECT 
    billing_event_fact_id,
    event_id,
    user_id,
    event_type,
    amount,
    event_date,
    transaction_date,
    currency,
    payment_method,
    billing_cycle,
    load_timestamp,
    update_timestamp,
    load_date,
    update_date,
    source_system
FROM billing_event_enriched