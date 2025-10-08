_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Comprehensive data mapping for Gold Layer aggregated tables in Zoom Platform Analytics System with detailed aggregation rules
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Snowflake Gold Aggregated Data Mapping

## Overview

This document provides a comprehensive data mapping for the four critical aggregated tables in the Gold Layer of the Zoom Platform Analytics System. The mapping follows a medallion architecture approach, transforming data from Silver Layer source tables into Gold Layer aggregated tables optimized for analytical reporting and business intelligence.

### Key Considerations:

- **Performance**: Aggregations are designed to pre-calculate metrics at daily grain to optimize query performance
- **Scalability**: Time-based partitioning and clustering strategies support large-scale data processing
- **Consistency**: Standardized aggregation methods ensure consistent metrics across all reporting layers
- **Snowflake Compatibility**: All aggregation rules use Snowflake-native SQL functions and data types
- **Business Alignment**: Aggregations support key business metrics including usage analytics, feature adoption, revenue tracking, and support performance

### Aggregation Strategy:

1. **Time Bucketization**: Daily aggregations with DATE grouping for consistent time-series analysis
2. **Dimensional Grouping**: Aggregations by company, plan_type, feature_name, and other key business dimensions
3. **Metric Calculations**: SUM, COUNT, AVERAGE, DISTINCT COUNT, MAX, MIN functions for comprehensive analytics
4. **Data Quality**: Proper handling of NULL values and data validation in aggregation logic

## Data Mapping for Aggregated Tables

### 1. Go_Daily_Usage_Agg - Daily Usage Aggregates Table

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Aggregation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|------------------|
| Gold | Go_Daily_Usage_Agg | usage_agg_day_id | Gold | - | - | AUTOINCREMENT |
| Gold | Go_Daily_Usage_Agg | usage_date | Silver | si_meetings | DATE(start_time) | GROUP BY DATE(start_time) |
| Gold | Go_Daily_Usage_Agg | company | Silver | si_users | company | GROUP BY company (via JOIN on host_id) |
| Gold | Go_Daily_Usage_Agg | plan_type | Silver | si_users | plan_type | GROUP BY plan_type (via JOIN on host_id) |
| Gold | Go_Daily_Usage_Agg | total_meetings | Silver | si_meetings | meeting_id | COUNT(DISTINCT meeting_id) |
| Gold | Go_Daily_Usage_Agg | total_duration_minutes | Silver | si_meetings | duration_minutes | SUM(duration_minutes) |
| Gold | Go_Daily_Usage_Agg | avg_meeting_duration | Silver | si_meetings | duration_minutes | AVG(duration_minutes) |
| Gold | Go_Daily_Usage_Agg | unique_users | Silver | si_meetings | host_id | COUNT(DISTINCT host_id) |
| Gold | Go_Daily_Usage_Agg | total_participants | Silver | si_participants | participant_id | COUNT(participant_id) (via JOIN on meeting_id) |
| Gold | Go_Daily_Usage_Agg | dau | Silver | si_participants | user_id | COUNT(DISTINCT user_id) (Daily Active Users) |
| Gold | Go_Daily_Usage_Agg | feature_adoption_rate | Silver | si_feature_usage | usage_count | (COUNT(DISTINCT feature_name) / total_features) * 100 |
| Gold | Go_Daily_Usage_Agg | load_date | System | - | - | CURRENT_DATE |
| Gold | Go_Daily_Usage_Agg | update_date | System | - | - | CURRENT_DATE |
| Gold | Go_Daily_Usage_Agg | source_system | Silver | si_meetings | source_system | MAX(source_system) |

### 2. Go_Feature_Adoption_Agg - Feature Adoption Aggregates Table

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Aggregation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|------------------|
| Gold | Go_Feature_Adoption_Agg | feature_adoption_agg_id | Gold | - | - | AUTOINCREMENT |
| Gold | Go_Feature_Adoption_Agg | usage_date | Silver | si_feature_usage | usage_date | GROUP BY usage_date |
| Gold | Go_Feature_Adoption_Agg | feature_name | Silver | si_feature_usage | feature_name | GROUP BY feature_name |
| Gold | Go_Feature_Adoption_Agg | plan_type | Silver | si_users | plan_type | GROUP BY plan_type (via JOIN on meeting_id->host_id) |
| Gold | Go_Feature_Adoption_Agg | total_usage_count | Silver | si_feature_usage | usage_count | SUM(usage_count) |
| Gold | Go_Feature_Adoption_Agg | unique_users_count | Silver | si_meetings | host_id | COUNT(DISTINCT host_id) (via JOIN on meeting_id) |
| Gold | Go_Feature_Adoption_Agg | adoption_rate | Silver | si_feature_usage | usage_count | (unique_users_count / total_active_users) * 100 |
| Gold | Go_Feature_Adoption_Agg | load_date | System | - | - | CURRENT_DATE |
| Gold | Go_Feature_Adoption_Agg | update_date | System | - | - | CURRENT_DATE |
| Gold | Go_Feature_Adoption_Agg | source_system | Silver | si_feature_usage | source_system | MAX(source_system) |

### 3. Go_Revenue_Agg - Revenue Aggregates Table

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Aggregation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|------------------|
| Gold | Go_Revenue_Agg | revenue_agg_id | Gold | - | - | AUTOINCREMENT |
| Gold | Go_Revenue_Agg | revenue_date | Silver | si_billing_events | event_date | GROUP BY event_date |
| Gold | Go_Revenue_Agg | plan_type | Silver | si_users | plan_type | GROUP BY plan_type (via JOIN on user_id) |
| Gold | Go_Revenue_Agg | company | Silver | si_users | company | GROUP BY company (via JOIN on user_id) |
| Gold | Go_Revenue_Agg | total_revenue | Silver | si_billing_events | amount | SUM(amount) WHERE event_type IN ('payment', 'subscription') |
| Gold | Go_Revenue_Agg | new_revenue | Silver | si_billing_events | amount | SUM(amount) WHERE event_type = 'new_subscription' |
| Gold | Go_Revenue_Agg | recurring_revenue | Silver | si_billing_events | amount | SUM(amount) WHERE event_type = 'recurring_payment' |
| Gold | Go_Revenue_Agg | churn_revenue | Silver | si_billing_events | amount | SUM(amount) WHERE event_type = 'cancellation' |
| Gold | Go_Revenue_Agg | revenue_growth_rate | Silver | si_billing_events | amount | ((current_period_revenue - previous_period_revenue) / previous_period_revenue) * 100 |
| Gold | Go_Revenue_Agg | load_date | System | - | - | CURRENT_DATE |
| Gold | Go_Revenue_Agg | update_date | System | - | - | CURRENT_DATE |
| Gold | Go_Revenue_Agg | source_system | Silver | si_billing_events | source_system | MAX(source_system) |

### 4. Go_Support_Agg_Day - Daily Support Aggregates Table

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Aggregation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|------------------|
| Gold | Go_Support_Agg_Day | support_agg_day_id | Gold | - | - | AUTOINCREMENT |
| Gold | Go_Support_Agg_Day | support_date | Silver | si_support_tickets | open_date | GROUP BY open_date |
| Gold | Go_Support_Agg_Day | tickets_opened | Silver | si_support_tickets | ticket_id | COUNT(ticket_id) WHERE open_date = support_date |
| Gold | Go_Support_Agg_Day | tickets_closed | Silver | si_support_tickets | ticket_id | COUNT(ticket_id) WHERE resolution_status = 'Closed' |
| Gold | Go_Support_Agg_Day | avg_resolution_time | Gold | Go_Support_Ticket_Fact | resolution_time_hours | AVG(resolution_time_hours) WHERE close_date = support_date |
| Gold | Go_Support_Agg_Day | most_common_ticket_type | Silver | si_support_tickets | ticket_type | MODE(ticket_type) - Most frequent ticket type |
| Gold | Go_Support_Agg_Day | first_contact_resolution_rate | Gold | Go_Support_Ticket_Fact | resolution_time_hours | (COUNT(tickets resolved in <24hrs) / COUNT(total_tickets)) * 100 |
| Gold | Go_Support_Agg_Day | tickets_per_1000_users | Silver | si_support_tickets, si_users | ticket_id, user_id | (COUNT(tickets) / COUNT(DISTINCT active_users)) * 1000 |
| Gold | Go_Support_Agg_Day | avg_satisfaction_score | Gold | Go_Support_Ticket_Fact | satisfaction_score | AVG(satisfaction_score) WHERE satisfaction_score IS NOT NULL |
| Gold | Go_Support_Agg_Day | load_date | System | - | - | CURRENT_DATE |
| Gold | Go_Support_Agg_Day | update_date | System | - | - | CURRENT_DATE |
| Gold | Go_Support_Agg_Day | source_system | Silver | si_support_tickets | source_system | MAX(source_system) |

## Aggregation Logic Details

### Time Bucketization Rules:
- **Daily Grain**: All aggregations use DATE() function to bucket data by day
- **Date Handling**: TIMESTAMP_NTZ fields converted to DATE for grouping
- **Time Zone**: All times processed in UTC (NTZ - No Time Zone)

### Join Logic:
- **User Context**: si_users joined via user_id or host_id for company and plan_type dimensions
- **Meeting Context**: si_meetings provides the primary grain for usage aggregations
- **Feature Context**: si_feature_usage linked to meetings for adoption metrics
- **Support Context**: si_support_tickets aggregated independently with user context
- **Revenue Context**: si_billing_events aggregated by user and event type

### Data Quality Rules:
- **NULL Handling**: COALESCE() used for NULL values in aggregations
- **Division by Zero**: NULLIF() used in division operations to prevent errors
- **Data Validation**: WHERE clauses filter invalid or test data
- **Consistency**: Standardized date formats and numeric precision across all tables

### Performance Optimization:
- **Clustering**: Tables clustered by date columns for time-series queries
- **Partitioning**: Snowflake micro-partitioning leveraged for date-based filtering
- **Incremental Processing**: Aggregations designed for incremental daily updates
- **Indexing Strategy**: Clustering keys defined for optimal query performance

### Business Rules:
- **Active Users**: Users with activity in the measurement period
- **Feature Adoption**: Percentage of users utilizing specific features
- **Revenue Classification**: Events categorized by type (new, recurring, churn)
- **Support Metrics**: Industry-standard KPIs for customer support performance
- **Usage Metrics**: Comprehensive meeting and participant analytics

## Implementation Notes

1. **Incremental Updates**: All aggregations support incremental processing using date-based filtering
2. **Data Lineage**: Source system tracking maintained through all aggregation levels
3. **Audit Trail**: Load and update timestamps captured for all records
4. **Error Handling**: Robust error handling for data quality issues
5. **Scalability**: Design supports millions of records with optimal performance
6. **Monitoring**: Built-in metrics for data quality and processing performance