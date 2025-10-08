{{ config(
    materialized='table',
    pre_hook="INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, load_date, source_system) SELECT '{{ invocation_id }}', 'go_billing_event_fact', 'gold_dimension_pipeline', CURRENT_TIMESTAMP(), 'STARTED', CURRENT_DATE(), 'DBT_GOLD_PIPELINE' WHERE '{{ this.name }}' != 'go_process_audit'",
    post_hook="INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_end_time, execution_status, records_processed, load_date, source_system) SELECT '{{ invocation_id }}', 'go_billing_event_fact', 'gold_dimension_pipeline', CURRENT_TIMESTAMP(), 'COMPLETED', (SELECT COUNT(*) FROM {{ this }}), CURRENT_DATE(), 'DBT_GOLD_PIPELINE' WHERE '{{ this.name }}' != 'go_process_audit'"
) }}

-- Gold Layer Billing Event Fact Table
-- Transforms Silver layer billing event data into Gold fact table
-- Source: Silver.si_billing_events

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
    WHERE event_id IS NOT NULL
),

-- Data transformations and enrichment
billing_event_transformed AS (
    SELECT
        event_id,
        COALESCE(user_id, 'UNKNOWN_USER') AS user_id,
        COALESCE(TRIM(event_type), 'Unknown') AS event_type,
        COALESCE(amount, 0.00) AS amount,
        event_date,
        event_date AS transaction_date, -- Same as event_date for now
        'USD' AS currency, -- Default currency
        -- Derive payment method based on event type
        CASE 
            WHEN UPPER(event_type) LIKE '%CREDIT%CARD%' THEN 'Credit Card'
            WHEN UPPER(event_type) LIKE '%PAYPAL%' THEN 'PayPal'
            WHEN UPPER(event_type) LIKE '%BANK%' THEN 'Bank Transfer'
            WHEN UPPER(event_type) LIKE '%INVOICE%' THEN 'Invoice'
            ELSE 'Other'
        END AS payment_method,
        -- Derive billing cycle based on amount ranges
        CASE 
            WHEN amount <= 20 THEN 'Monthly'
            WHEN amount <= 200 THEN 'Annual'
            WHEN amount > 200 THEN 'Enterprise'
            ELSE 'Unknown'
        END AS billing_cycle,
        load_timestamp,
        update_timestamp,
        source_system,
        load_date,
        update_date
    FROM billing_event_source
),

-- Add audit columns and final transformations
billing_event_final AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY event_id) AS billing_event_fact_id,
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
        CURRENT_TIMESTAMP() AS update_timestamp,
        COALESCE(load_date, CURRENT_DATE()) AS load_date,
        CURRENT_DATE() AS update_date,
        COALESCE(source_system, 'Silver.si_billing_events') AS source_system,
        -- Audit columns
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at,
        'SUCCESS' AS process_status
    FROM billing_event_transformed
)

SELECT * FROM billing_event_final