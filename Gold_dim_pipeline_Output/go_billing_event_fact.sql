-- =====================================================
-- Go_Billing_Event_Fact Model
-- Description: Gold Layer Billing Event Fact Table
-- Source: Silver.si_billing_events
-- Author: Data Engineer
-- =====================================================

{{ config(
    materialized='table',
    tags=['fact', 'gold', 'billing'],
    on_schema_change='append_new_columns',
    pre_hook="{% if this.name != 'go_process_audit' %}INSERT INTO {{ ref('go_process_audit') }} (execution_id, process_name, pipeline_name, execution_start_time, execution_status, records_processed, start_time, status, load_date, update_date, source_system) VALUES ('{{ invocation_id }}', 'go_billing_event_fact', 'gold_dimension_pipeline', CURRENT_TIMESTAMP, 'RUNNING', 0, CURRENT_TIMESTAMP, 'ACTIVE', CURRENT_DATE, CURRENT_DATE, 'DBT_PIPELINE'){% endif %}",
    post_hook="{% if this.name != 'go_process_audit' %}UPDATE {{ ref('go_process_audit') }} SET execution_end_time = CURRENT_TIMESTAMP, execution_status = 'COMPLETED', records_processed = (SELECT COUNT(*) FROM {{ this }}), records_inserted = (SELECT COUNT(*) FROM {{ this }}), process_duration_seconds = DATEDIFF(second, execution_start_time, CURRENT_TIMESTAMP), end_time = CURRENT_TIMESTAMP WHERE execution_id = '{{ invocation_id }}' AND process_name = 'go_billing_event_fact'{% endif %}"
) }}

-- CTE for data transformation and cleansing
WITH source_data AS (
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
    WHERE event_id IS NOT NULL -- Data quality check
),

-- Data transformation with business rules
transformed_data AS (
    SELECT
        event_id,
        user_id,
        COALESCE(event_type, 'Unknown') AS event_type,
        COALESCE(amount, 0.00) AS amount,
        event_date,
        
        -- Set transaction date same as event date
        event_date AS transaction_date,
        
        -- Set default currency
        'USD' AS currency,
        
        -- Derive payment method based on event type
        CASE
            WHEN UPPER(event_type) LIKE '%CREDIT%CARD%' THEN 'Credit Card'
            WHEN UPPER(event_type) LIKE '%PAYPAL%' THEN 'PayPal'
            WHEN UPPER(event_type) LIKE '%BANK%' THEN 'Bank Transfer'
            WHEN UPPER(event_type) LIKE '%INVOICE%' THEN 'Invoice'
            ELSE 'Credit Card'
        END AS payment_method,
        
        -- Derive billing cycle based on amount
        CASE
            WHEN amount >= 100 THEN 'Annual'
            WHEN amount >= 10 THEN 'Monthly'
            WHEN amount > 0 THEN 'One-time'
            ELSE 'Free'
        END AS billing_cycle,
        
        -- Audit fields
        load_timestamp,
        update_timestamp,
        load_date,
        update_date,
        source_system
    FROM source_data
)

-- Final SELECT with all required fields for Go_Billing_Event_Fact
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
    update_timestamp,
    load_date,
    update_date,
    source_system
FROM transformed_data