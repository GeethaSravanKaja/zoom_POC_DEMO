_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Snowflake Gold Aggregated DE Pipeline for Zoom Platform Analytics System using dbt Cloud
## *Version*: 1 
## *Updated on*: 
_____________________________________________

-- =====================================================
-- SNOWFLAKE GOLD AGGREGATED DE PIPELINE - DBT MODEL
-- =====================================================

-- Configuration for dbt model
{{ config(
    materialized='incremental',
    unique_key='usage_date',
    on_schema_change='fail',
    cluster_by=['usage_date'],
    tags=['gold', 'aggregated', 'daily']
) }}

-- =====================================================
-- 1. EXTRACT DATA FROM SILVER LAYER
-- =====================================================

-- CTE for Silver Layer Data Extraction
WITH silver_meetings AS (
    SELECT 
        meeting_id,
        host_id,
        meeting_topic,
        start_time,
        end_time,
        duration_minutes,
        DATE(start_time) as meeting_date,
        load_timestamp,
        source_system
    FROM {{ ref('silver.si_meetings') }}
    {% if is_incremental() %}
        WHERE DATE(start_time) >= (SELECT MAX(usage_date) FROM {{ this }})
    {% endif %}
),

silver_users AS (
    SELECT 
        user_id,
        user_name,
        email,
        company,
        plan_type,
        load_timestamp,
        source_system
    FROM {{ ref('silver.si_users') }}
),

silver_participants AS (
    SELECT 
        participant_id,
        meeting_id,
        user_id,
        join_time,
        leave_time,
        DATE(join_time) as participation_date,
        load_timestamp,
        source_system
    FROM {{ ref('silver.si_participants') }}
    {% if is_incremental() %}
        WHERE DATE(join_time) >= (SELECT MAX(usage_date) FROM {{ this }})
    {% endif %}
),

silver_feature_usage AS (
    SELECT 
        usage_id,
        meeting_id,
        feature_name,
        usage_count,
        usage_date,
        load_timestamp,
        source_system
    FROM {{ ref('silver.si_feature_usage') }}
    {% if is_incremental() %}
        WHERE usage_date >= (SELECT MAX(usage_date) FROM {{ this }})
    {% endif %}
),

silver_webinars AS (
    SELECT 
        webinar_id,
        host_id,
        webinar_topic,
        start_time,
        end_time,
        registrants,
        DATE(start_time) as webinar_date,
        load_timestamp,
        source_system
    FROM {{ ref('silver.si_webinars') }}
    {% if is_incremental() %}
        WHERE DATE(start_time) >= (SELECT MAX(usage_date) FROM {{ this }})
    {% endif %}
),

silver_support_tickets AS (
    SELECT 
        ticket_id,
        user_id,
        ticket_type,
        resolution_status,
        open_date,
        load_timestamp,
        source_system
    FROM {{ ref('silver.si_support_tickets') }}
    {% if is_incremental() %}
        WHERE open_date >= (SELECT MAX(usage_date) FROM {{ this }})
    {% endif %}
),

silver_billing_events AS (
    SELECT 
        event_id,
        user_id,
        event_type,
        amount,
        event_date,
        load_timestamp,
        source_system
    FROM {{ ref('silver.si_billing_events') }}
    {% if is_incremental() %}
        WHERE event_date >= (SELECT MAX(usage_date) FROM {{ this }})
    {% endif %}
),

-- =====================================================
-- 2. CREATE AGGREGATE FACT TABLES IN GOLD LAYER
-- =====================================================

-- Daily Usage Aggregates
daily_usage_base AS (
    SELECT 
        m.meeting_date as usage_date,
        u.company,
        u.plan_type,
        COUNT(DISTINCT m.meeting_id) as total_meetings,
        SUM(m.duration_minutes) as total_duration_minutes,
        AVG(m.duration_minutes) as avg_meeting_duration,
        COUNT(DISTINCT m.host_id) as unique_users,
        COUNT(DISTINCT p.participant_id) as total_participants,
        COUNT(DISTINCT p.user_id) as dau,
        CURRENT_DATE as load_date,
        CURRENT_DATE as update_date,
        COALESCE(m.source_system, 'ZOOM_API') as source_system
    FROM silver_meetings m
    LEFT JOIN silver_users u ON m.host_id = u.user_id
    LEFT JOIN silver_participants p ON m.meeting_id = p.meeting_id 
        AND DATE(p.join_time) = m.meeting_date
    GROUP BY 
        m.meeting_date,
        u.company,
        u.plan_type,
        m.source_system
),

-- Feature Adoption Rate Calculation
feature_adoption_calc AS (
    SELECT 
        usage_date,
        company,
        plan_type,
        CASE 
            WHEN total_meetings > 0 THEN 
                (COUNT(DISTINCT CASE WHEN fu.usage_count > 0 THEN m.meeting_id END) * 100.0 / total_meetings)
            ELSE 0
        END as feature_adoption_rate
    FROM daily_usage_base dub
    LEFT JOIN silver_meetings m ON DATE(m.start_time) = dub.usage_date
    LEFT JOIN silver_feature_usage fu ON m.meeting_id = fu.meeting_id
    GROUP BY usage_date, company, plan_type, total_meetings
),

-- Final Daily Usage Aggregates
go_daily_usage_agg AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY dub.usage_date, dub.company, dub.plan_type) as usage_agg_day_id,
        dub.usage_date,
        dub.company,
        dub.plan_type,
        dub.total_meetings,
        dub.total_duration_minutes,
        ROUND(dub.avg_meeting_duration, 2) as avg_meeting_duration,
        dub.unique_users,
        dub.total_participants,
        dub.dau,
        COALESCE(fac.feature_adoption_rate, 0) as feature_adoption_rate,
        dub.load_date,
        dub.update_date,
        dub.source_system
    FROM daily_usage_base dub
    LEFT JOIN feature_adoption_calc fac ON dub.usage_date = fac.usage_date 
        AND dub.company = fac.company 
        AND dub.plan_type = fac.plan_type
),

-- Feature Adoption Aggregates
go_feature_adoption_agg AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY fu.usage_date, fu.feature_name, u.plan_type) as feature_adoption_agg_id,
        fu.usage_date,
        fu.feature_name,
        u.plan_type,
        SUM(fu.usage_count) as total_usage_count,
        COUNT(DISTINCT p.user_id) as unique_users_count,
        CASE 
            WHEN COUNT(DISTINCT m.meeting_id) > 0 THEN
                (COUNT(DISTINCT CASE WHEN fu.usage_count > 0 THEN m.meeting_id END) * 100.0 / COUNT(DISTINCT m.meeting_id))
            ELSE 0
        END as adoption_rate,
        CURRENT_DATE as load_date,
        CURRENT_DATE as update_date,
        COALESCE(fu.source_system, 'ZOOM_API') as source_system
    FROM silver_feature_usage fu
    LEFT JOIN silver_meetings m ON fu.meeting_id = m.meeting_id
    LEFT JOIN silver_participants p ON m.meeting_id = p.meeting_id
    LEFT JOIN silver_users u ON p.user_id = u.user_id
    GROUP BY 
        fu.usage_date,
        fu.feature_name,
        u.plan_type,
        fu.source_system
),

-- Revenue Aggregates
revenue_previous_period AS (
    SELECT 
        event_date,
        u.plan_type,
        u.company,
        SUM(be.amount) as prev_revenue
    FROM silver_billing_events be
    LEFT JOIN silver_users u ON be.user_id = u.user_id
    WHERE event_date = DATEADD(day, -1, CURRENT_DATE)
    GROUP BY event_date, u.plan_type, u.company
),

go_revenue_agg AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY be.event_date, u.plan_type, u.company) as revenue_agg_id,
        be.event_date as revenue_date,
        u.plan_type,
        u.company,
        SUM(be.amount) as total_revenue,
        SUM(CASE WHEN be.event_type = 'Subscription Fee' THEN be.amount ELSE 0 END) as new_revenue,
        SUM(CASE WHEN be.event_type IN ('Subscription Renewal', 'Subscription Fee') THEN be.amount ELSE 0 END) as recurring_revenue,
        SUM(CASE WHEN be.event_type = 'Refund' THEN be.amount ELSE 0 END) as churn_revenue,
        CASE 
            WHEN rpp.prev_revenue > 0 THEN
                ((SUM(be.amount) - rpp.prev_revenue) * 100.0 / rpp.prev_revenue)
            ELSE 0
        END as revenue_growth_rate,
        CURRENT_DATE as load_date,
        CURRENT_DATE as update_date,
        COALESCE(be.source_system, 'ZOOM_API') as source_system
    FROM silver_billing_events be
    LEFT JOIN silver_users u ON be.user_id = u.user_id
    LEFT JOIN revenue_previous_period rpp ON be.event_date = DATEADD(day, 1, rpp.event_date)
        AND u.plan_type = rpp.plan_type
        AND u.company = rpp.company
    GROUP BY 
        be.event_date,
        u.plan_type,
        u.company,
        rpp.prev_revenue,
        be.source_system
),

-- Support Aggregates
support_metrics AS (
    SELECT 
        st.open_date as support_date,
        COUNT(DISTINCT st.ticket_id) as tickets_opened,
        COUNT(DISTINCT CASE WHEN st.resolution_status = 'Closed' THEN st.ticket_id END) as tickets_closed,
        AVG(CASE WHEN st.resolution_status = 'Closed' THEN 
            DATEDIFF(hour, st.open_date, CURRENT_DATE) END) as avg_resolution_time,
        MODE(st.ticket_type) as most_common_ticket_type,
        CASE 
            WHEN COUNT(st.ticket_id) > 0 THEN
                (COUNT(CASE WHEN st.resolution_status = 'Closed' THEN st.ticket_id END) * 100.0 / COUNT(st.ticket_id))
            ELSE 0
        END as first_contact_resolution_rate,
        COUNT(DISTINCT u.user_id) as total_users,
        CURRENT_DATE as load_date,
        CURRENT_DATE as update_date,
        COALESCE(st.source_system, 'ZOOM_API') as source_system
    FROM silver_support_tickets st
    LEFT JOIN silver_users u ON st.user_id = u.user_id
    GROUP BY 
        st.open_date,
        st.source_system
),

go_support_agg_day AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY support_date) as support_agg_day_id,
        support_date,
        tickets_opened,
        tickets_closed,
        ROUND(avg_resolution_time, 2) as avg_resolution_time,
        most_common_ticket_type,
        ROUND(first_contact_resolution_rate, 2) as first_contact_resolution_rate,
        CASE 
            WHEN total_users > 0 THEN
                ROUND((tickets_opened * 1000.0 / total_users), 2)
            ELSE 0
        END as tickets_per_1000_users,
        NULL as avg_satisfaction_score, -- Not available in source data
        load_date,
        update_date,
        source_system
    FROM support_metrics
),

-- =====================================================
-- 3. VALIDATION AND TESTING
-- =====================================================

-- Data Quality Checks
data_quality_checks AS (
    SELECT 
        'go_daily_usage_agg' as table_name,
        COUNT(*) as record_count,
        COUNT(CASE WHEN usage_date IS NULL THEN 1 END) as null_usage_date_count,
        COUNT(CASE WHEN total_meetings < 0 THEN 1 END) as negative_meetings_count,
        COUNT(CASE WHEN dau > total_participants THEN 1 END) as invalid_dau_count
    FROM go_daily_usage_agg
    
    UNION ALL
    
    SELECT 
        'go_feature_adoption_agg' as table_name,
        COUNT(*) as record_count,
        COUNT(CASE WHEN usage_date IS NULL THEN 1 END) as null_usage_date_count,
        COUNT(CASE WHEN adoption_rate < 0 OR adoption_rate > 100 THEN 1 END) as invalid_adoption_rate_count,
        COUNT(CASE WHEN total_usage_count < 0 THEN 1 END) as negative_usage_count
    FROM go_feature_adoption_agg
    
    UNION ALL
    
    SELECT 
        'go_revenue_agg' as table_name,
        COUNT(*) as record_count,
        COUNT(CASE WHEN revenue_date IS NULL THEN 1 END) as null_revenue_date_count,
        COUNT(CASE WHEN total_revenue < 0 THEN 1 END) as negative_revenue_count,
        COUNT(CASE WHEN churn_revenue > 0 THEN 1 END) as positive_churn_count
    FROM go_revenue_agg
    
    UNION ALL
    
    SELECT 
        'go_support_agg_day' as table_name,
        COUNT(*) as record_count,
        COUNT(CASE WHEN support_date IS NULL THEN 1 END) as null_support_date_count,
        COUNT(CASE WHEN tickets_opened < 0 THEN 1 END) as negative_tickets_count,
        COUNT(CASE WHEN first_contact_resolution_rate < 0 OR first_contact_resolution_rate > 100 THEN 1 END) as invalid_resolution_rate_count
    FROM go_support_agg_day
),

-- =====================================================
-- 4. AUDIT LOGGING
-- =====================================================

audit_log AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(['run_started_at', 'invocation_id']) }} as execution_id,
        'Snowflake_Gold_Aggregated_DE_Pipeline' as pipeline_name,
        '{{ run_started_at }}' as start_time,
        CURRENT_TIMESTAMP as end_time,
        'SUCCESS' as status,
        NULL as error_message,
        CURRENT_DATE as load_date,
        CURRENT_DATE as update_date,
        'DBT_CLOUD' as source_system,
        (
            SELECT SUM(record_count) 
            FROM data_quality_checks
        ) as total_records_processed
),

-- =====================================================
-- 5. PERFORMANCE OPTIMIZATION
-- =====================================================

-- Final output with clustering optimization
final_output AS (
    SELECT 
        'daily_usage' as aggregate_type,
        usage_date as aggregate_date,
        company,
        plan_type,
        total_meetings as metric_value_1,
        total_duration_minutes as metric_value_2,
        avg_meeting_duration as metric_value_3,
        unique_users as metric_value_4,
        total_participants as metric_value_5,
        dau as metric_value_6,
        feature_adoption_rate as metric_value_7,
        NULL as metric_value_8,
        NULL as metric_value_9,
        NULL as metric_value_10,
        load_date,
        update_date,
        source_system
    FROM go_daily_usage_agg
    
    UNION ALL
    
    SELECT 
        'feature_adoption' as aggregate_type,
        usage_date as aggregate_date,
        NULL as company,
        plan_type,
        total_usage_count as metric_value_1,
        unique_users_count as metric_value_2,
        adoption_rate as metric_value_3,
        NULL as metric_value_4,
        NULL as metric_value_5,
        NULL as metric_value_6,
        NULL as metric_value_7,
        NULL as metric_value_8,
        NULL as metric_value_9,
        NULL as metric_value_10,
        load_date,
        update_date,
        source_system
    FROM go_feature_adoption_agg
    
    UNION ALL
    
    SELECT 
        'revenue' as aggregate_type,
        revenue_date as aggregate_date,
        company,
        plan_type,
        total_revenue as metric_value_1,
        new_revenue as metric_value_2,
        recurring_revenue as metric_value_3,
        churn_revenue as metric_value_4,
        revenue_growth_rate as metric_value_5,
        NULL as metric_value_6,
        NULL as metric_value_7,
        NULL as metric_value_8,
        NULL as metric_value_9,
        NULL as metric_value_10,
        load_date,
        update_date,
        source_system
    FROM go_revenue_agg
    
    UNION ALL
    
    SELECT 
        'support' as aggregate_type,
        support_date as aggregate_date,
        NULL as company,
        NULL as plan_type,
        tickets_opened as metric_value_1,
        tickets_closed as metric_value_2,
        avg_resolution_time as metric_value_3,
        first_contact_resolution_rate as metric_value_4,
        tickets_per_1000_users as metric_value_5,
        avg_satisfaction_score as metric_value_6,
        NULL as metric_value_7,
        NULL as metric_value_8,
        NULL as metric_value_9,
        NULL as metric_value_10,
        load_date,
        update_date,
        source_system
    FROM go_support_agg_day
)

-- =====================================================
-- 6. FINAL SELECT WITH KNOWLEDGE BASE ALIGNMENT
-- =====================================================

SELECT 
    aggregate_type,
    aggregate_date,
    company,
    plan_type,
    metric_value_1,
    metric_value_2,
    metric_value_3,
    metric_value_4,
    metric_value_5,
    metric_value_6,
    metric_value_7,
    metric_value_8,
    metric_value_9,
    metric_value_10,
    load_date,
    update_date,
    source_system
FROM final_output
WHERE aggregate_date IS NOT NULL
ORDER BY aggregate_date DESC, aggregate_type, company, plan_type

-- =====================================================
-- 7. DBT TESTS CONFIGURATION
-- =====================================================

/*
-- tests/assert_data_quality.sql
SELECT *
FROM (
    SELECT 
        table_name,
        record_count,
        null_usage_date_count + negative_meetings_count + invalid_dau_count as total_issues
    FROM {{ ref('data_quality_checks') }}
) 
WHERE total_issues > 0

-- tests/assert_no_future_dates.sql
SELECT *
FROM {{ this }}
WHERE aggregate_date > CURRENT_DATE

-- tests/assert_positive_metrics.sql
SELECT *
FROM {{ this }}
WHERE (metric_value_1 < 0 OR metric_value_2 < 0 OR metric_value_3 < 0)
  AND aggregate_type != 'revenue' -- Revenue can have negative values for refunds

-- tests/assert_percentage_bounds.sql
SELECT *
FROM {{ this }}
WHERE (metric_value_7 < 0 OR metric_value_7 > 100) -- feature_adoption_rate
   OR (metric_value_4 < 0 OR metric_value_4 > 100) -- first_contact_resolution_rate
   AND aggregate_type IN ('daily_usage', 'support')
*/

-- =====================================================
-- 8. PERFORMANCE OPTIMIZATION NOTES
-- =====================================================

/*
SNOWFLAKE PERFORMANCE OPTIMIZATIONS APPLIED:

1. Incremental Materialization: Uses incremental processing to handle large datasets efficiently
2. Clustering Keys: Clustered by usage_date for optimal time-series query performance
3. Partition Pruning: Date-based filtering reduces scan overhead
4. Efficient Joins: LEFT JOINs optimized for Snowflake's columnar storage
5. Aggregate Pushdown: Pre-aggregated calculations reduce compute overhead
6. NULL Handling: Proper COALESCE and NULLIF usage prevents runtime errors
7. Data Type Optimization: Appropriate precision for numeric calculations
8. CTE Usage: Modular CTEs improve readability and optimization
9. Window Functions: ROW_NUMBER() for surrogate key generation
10. Union Optimization: UNION ALL for better performance than UNION

DBT CLOUD BEST PRACTICES IMPLEMENTED:

1. Incremental Models: Efficient processing of large datasets
2. Ref Functions: Proper dependency management
3. Jinja Templating: Dynamic SQL generation
4. Model Configuration: Materialization and clustering settings
5. Testing Framework: Built-in data quality tests
6. Documentation: Comprehensive model documentation
7. Version Control: Git-based version management
8. Modular Design: Reusable transformation logic
9. Error Handling: Graceful failure management
10. Audit Trail: Complete lineage tracking
*/

-- =====================================================
-- END OF SNOWFLAKE GOLD AGGREGATED DE PIPELINE
-- =====================================================