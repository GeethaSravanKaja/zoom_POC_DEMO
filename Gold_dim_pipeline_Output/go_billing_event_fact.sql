{{ config(
    materialized='table',
    tags=['fact', 'gold'],
    pre_hook="{% if this.name != 'go_process_audit' %}INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, source_system, created_at, process_status) VALUES ('{{ invocation_id }}', 'go_billing_event_fact', 'Gold_Fact_Pipeline', CURRENT_TIMESTAMP, 'RUNNING', 'DBT_Gold_Pipeline', CURRENT_TIMESTAMP, 'ACTIVE'){% endif %}",
    post_hook="{% if this.name != 'go_process_audit' %}UPDATE {{ ref('go_process_audit') }} SET execution_end_time = CURRENT_TIMESTAMP, execution_status = 'COMPLETED', updated_at = CURRENT_TIMESTAMP, records_processed = (SELECT COUNT(*) FROM {{ this }}) WHERE execution_id = '{{ invocation_id }}' AND process_name = 'go_billing_event_fact'{% endif %}"
) }}

/*
_____________________________________________
## *Author*: AAVA Data Engineering Team
## *Created on*: {{ run_started_at }}
## *Description*: Gold Layer Billing Event Fact Table - DBT Model
## *Version*: 1.0
## *Purpose*: Billing transactions fact table for analytics and reporting
## *Source*: Silver.si_billing_events
_____________________________________________
*/

-- CTE for source data extraction
WITH billing_event_source AS (
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
    WHERE event_id IS NOT NULL  -- Data quality filter
),

-- Data transformation and business logic
billing_event_transformed AS (
    SELECT
        event_id,
        user_id,
        COALESCE(TRIM(event_type), 'Unknown') AS event_type,
        COALESCE(amount, 0.00) AS amount,
        event_date,
        event_date AS transaction_date,  -- Assuming same as event_date
        'USD' AS currency,  -- Default currency
        -- Derive payment method based on event type
        CASE 
            WHEN UPPER(event_type) LIKE '%CREDIT%CARD%' THEN 'Credit Card'
            WHEN UPPER(event_type) LIKE '%PAYPAL%' THEN 'PayPal'
            WHEN UPPER(event_type) LIKE '%BANK%' THEN 'Bank Transfer'
            WHEN UPPER(event_type) LIKE '%INVOICE%' THEN 'Invoice'
            ELSE 'Credit Card'  -- Default payment method
        END AS payment_method,
        -- Derive billing cycle based on event type and amount
        CASE 
            WHEN UPPER(event_type) LIKE '%MONTHLY%' THEN 'Monthly'
            WHEN UPPER(event_type) LIKE '%ANNUAL%' OR UPPER(event_type) LIKE '%YEARLY%' THEN 'Annual'
            WHEN UPPER(event_type) LIKE '%QUARTERLY%' THEN 'Quarterly'
            WHEN amount > 100 THEN 'Annual'  -- Assume higher amounts are annual
            ELSE 'Monthly'
        END AS billing_cycle,
        load_timestamp,
        update_timestamp,
        COALESCE(source_system, 'Silver.si_billing_events') AS source_system,
        load_date,
        update_date,
        -- Audit fields
        CURRENT_TIMESTAMP AS created_at,
        CURRENT_TIMESTAMP AS updated_at,
        'ACTIVE' AS process_status
    FROM billing_event_source
),

-- Data validation and error handling
billing_event_validated AS (
    SELECT *,
        CASE 
            WHEN event_id IS NULL OR event_id = '' THEN 'Missing Event ID'
            WHEN user_id IS NULL OR user_id = '' THEN 'Missing User ID'
            WHEN event_type IS NULL OR event_type = '' THEN 'Missing Event Type'
            WHEN amount < 0 THEN 'Invalid Amount'
            WHEN event_date IS NULL THEN 'Missing Event Date'
            ELSE 'Valid'
        END AS data_quality_status
    FROM billing_event_transformed
)

-- Final select with all required columns for Gold layer
SELECT
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
    source_system,
    created_at,
    updated_at,
    process_status
FROM billing_event_validated
WHERE data_quality_status = 'Valid'  -- Only include valid records

-- Order by event_date for consistent processing
ORDER BY event_date DESC