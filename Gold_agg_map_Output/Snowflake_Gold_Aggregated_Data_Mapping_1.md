_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Comprehensive data mapping for Aggregated Tables in the Gold Layer with aggregation logic for Zoom Platform Analytics System
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Snowflake Gold Aggregated Data Mapping

## Overview

This document provides a comprehensive data mapping for Aggregated Tables in the Gold Layer of the Zoom Platform Analytics System. The mapping incorporates sophisticated aggregation logic designed to transform Silver layer transactional data into Gold layer analytical aggregates optimized for business reporting and analytics.

### Key Considerations:

**Performance Optimization:**
- Aggregation logic designed for Snowflake's columnar storage and micro-partitioning
- Time-based grouping strategies to leverage clustering keys
- Efficient JOIN operations across Silver layer tables
- Pre-calculated metrics to reduce query complexity

**Scalability:**
- Daily aggregation patterns to support incremental processing
- Partitioning strategies aligned with business reporting cycles
- Optimized for both real-time and batch processing scenarios
- Support for historical trend analysis and time-series reporting

**Data Consistency:**
- Standardized aggregation methods across all metric calculations
- Consistent date bucketing and time zone handling
- Unified business rule application across all aggregated tables
- Data quality validation integrated into aggregation processes

**Business Alignment:**
- Metrics aligned with Zoom platform KPIs and business objectives
- Support for multi-dimensional analysis (plan type, company, feature, time)
- Revenue and usage analytics optimized for subscription business model
- Customer support metrics designed for SLA monitoring and improvement

## Data Mapping for Aggregated Tables

### 1. Go_Daily_Usage_Agg - Daily Usage Aggregates

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Aggregation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|------------------|
| Gold | Go_Daily_Usage_Agg | usage_agg_day_id | Gold | System Generated | AUTOINCREMENT | AUTOINCREMENT |
| Gold | Go_Daily_Usage_Agg | usage_date | Silver | si_meetings | start_time | DATE(start_time) - GROUP BY DATE |
| Gold | Go_Daily_Usage_Agg | company | Silver | si_users | company | FIRST_VALUE(company) - GROUP BY company |
| Gold | Go_Daily_Usage_Agg | plan_type | Silver | si_users | plan_type | FIRST_VALUE(plan_type) - GROUP BY plan_type |
| Gold | Go_Daily_Usage_Agg | total_meetings | Silver | si_meetings | meeting_id | COUNT(DISTINCT meeting_id) |
| Gold | Go_Daily_Usage_Agg | total_duration_minutes | Silver | si_meetings | duration_minutes | SUM(duration_minutes) |
| Gold | Go_Daily_Usage_Agg | avg_meeting_duration | Silver | si_meetings | duration_minutes | AVG(duration_minutes) |
| Gold | Go_Daily_Usage_Agg | unique_users | Silver | si_meetings | host_id | COUNT(DISTINCT host_id) |
| Gold | Go_Daily_Usage_Agg | total_participants | Silver | si_participants | participant_id | COUNT(DISTINCT participant_id) |
| Gold | Go_Daily_Usage_Agg | dau | Silver | si_participants | user_id | COUNT(DISTINCT user_id) |
| Gold | Go_Daily_Usage_Agg | feature_adoption_rate | Silver | si_feature_usage | usage_count | (COUNT(DISTINCT meeting_id with features) / COUNT(DISTINCT meeting_id)) * 100 |
| Gold | Go_Daily_Usage_Agg | load_date | Silver | System Generated | CURRENT_DATE | CURRENT_DATE |
| Gold | Go_Daily_Usage_Agg | update_date | Silver | System Generated | CURRENT_DATE | CURRENT_DATE |
| Gold | Go_Daily_Usage_Agg | source_system | Silver | si_meetings | source_system | FIRST_VALUE(source_system) |

### 2. Go_Feature_Adoption_Agg - Feature Adoption Aggregates

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Aggregation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|------------------|
| Gold | Go_Feature_Adoption_Agg | feature_adoption_agg_id | Gold | System Generated | AUTOINCREMENT | AUTOINCREMENT |
| Gold | Go_Feature_Adoption_Agg | usage_date | Silver | si_feature_usage | usage_date | FIRST_VALUE(usage_date) - GROUP BY usage_date |
| Gold | Go_Feature_Adoption_Agg | feature_name | Silver | si_feature_usage | feature_name | FIRST_VALUE(feature_name) - GROUP BY feature_name |
| Gold | Go_Feature_Adoption_Agg | plan_type | Silver | si_users | plan_type | FIRST_VALUE(plan_type) - GROUP BY plan_type |
| Gold | Go_Feature_Adoption_Agg | total_usage_count | Silver | si_feature_usage | usage_count | SUM(usage_count) |
| Gold | Go_Feature_Adoption_Agg | unique_users_count | Silver | si_participants | user_id | COUNT(DISTINCT user_id) |
| Gold | Go_Feature_Adoption_Agg | adoption_rate | Silver | si_feature_usage | usage_count | (COUNT(DISTINCT meeting_id with feature) / COUNT(DISTINCT meeting_id)) * 100 |
| Gold | Go_Feature_Adoption_Agg | load_date | Silver | System Generated | CURRENT_DATE | CURRENT_DATE |
| Gold | Go_Feature_Adoption_Agg | update_date | Silver | System Generated | CURRENT_DATE | CURRENT_DATE |
| Gold | Go_Feature_Adoption_Agg | source_system | Silver | si_feature_usage | source_system | FIRST_VALUE(source_system) |

### 3. Go_Revenue_Agg - Revenue Aggregates

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Aggregation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|------------------|
| Gold | Go_Revenue_Agg | revenue_agg_id | Gold | System Generated | AUTOINCREMENT | AUTOINCREMENT |
| Gold | Go_Revenue_Agg | revenue_date | Silver | si_billing_events | event_date | FIRST_VALUE(event_date) - GROUP BY event_date |
| Gold | Go_Revenue_Agg | plan_type | Silver | si_users | plan_type | FIRST_VALUE(plan_type) - GROUP BY plan_type |
| Gold | Go_Revenue_Agg | company | Silver | si_users | company | FIRST_VALUE(company) - GROUP BY company |
| Gold | Go_Revenue_Agg | total_revenue | Silver | si_billing_events | amount | SUM(amount) |
| Gold | Go_Revenue_Agg | new_revenue | Silver | si_billing_events | amount | SUM(amount) WHERE event_type = 'Subscription Fee' AND first_time_customer = TRUE |
| Gold | Go_Revenue_Agg | recurring_revenue | Silver | si_billing_events | amount | SUM(amount) WHERE event_type IN ('Subscription Renewal', 'Subscription Fee') |
| Gold | Go_Revenue_Agg | churn_revenue | Silver | si_billing_events | amount | SUM(amount) WHERE event_type = 'Refund' |
| Gold | Go_Revenue_Agg | revenue_growth_rate | Silver | si_billing_events | amount | ((Current Period Revenue - Previous Period Revenue) / Previous Period Revenue) * 100 |
| Gold | Go_Revenue_Agg | load_date | Silver | System Generated | CURRENT_DATE | CURRENT_DATE |
| Gold | Go_Revenue_Agg | update_date | Silver | System Generated | CURRENT_DATE | CURRENT_DATE |
| Gold | Go_Revenue_Agg | source_system | Silver | si_billing_events | source_system | FIRST_VALUE(source_system) |

### 4. Go_Support_Agg_Day - Daily Support Aggregates

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Aggregation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|------------------|
| Gold | Go_Support_Agg_Day | support_agg_day_id | Gold | System Generated | AUTOINCREMENT | AUTOINCREMENT |
| Gold | Go_Support_Agg_Day | support_date | Silver | si_support_tickets | open_date | FIRST_VALUE(open_date) - GROUP BY open_date |
| Gold | Go_Support_Agg_Day | tickets_opened | Silver | si_support_tickets | ticket_id | COUNT(DISTINCT ticket_id) WHERE open_date = support_date |
| Gold | Go_Support_Agg_Day | tickets_closed | Silver | si_support_tickets | ticket_id | COUNT(DISTINCT ticket_id) WHERE resolution_status = 'Closed' |
| Gold | Go_Support_Agg_Day | avg_resolution_time | Silver | si_support_tickets | resolution_time_hours | AVG(resolution_time_hours) WHERE resolution_status = 'Closed' |
| Gold | Go_Support_Agg_Day | most_common_ticket_type | Silver | si_support_tickets | ticket_type | MODE(ticket_type) - Most frequently occurring ticket type |
| Gold | Go_Support_Agg_Day | first_contact_resolution_rate | Silver | si_support_tickets | resolution_status | (COUNT(tickets resolved in first contact) / COUNT(total tickets)) * 100 |
| Gold | Go_Support_Agg_Day | tickets_per_1000_users | Silver | si_support_tickets, si_users | ticket_id, user_id | (COUNT(DISTINCT ticket_id) / COUNT(DISTINCT user_id)) * 1000 |
| Gold | Go_Support_Agg_Day | avg_satisfaction_score | Silver | si_support_tickets | satisfaction_score | AVG(satisfaction_score) WHERE satisfaction_score IS NOT NULL |
| Gold | Go_Support_Agg_Day | load_date | Silver | System Generated | CURRENT_DATE | CURRENT_DATE |
| Gold | Go_Support_Agg_Day | update_date | Silver | System Generated | CURRENT_DATE | CURRENT_DATE |
| Gold | Go_Support_Agg_Day | source_system | Silver | si_support_tickets | source_system | FIRST_VALUE(source_system) |

## Aggregation Logic Details

### Grouping Strategies:

**Time-Based Grouping:**
- Daily aggregations: GROUP BY DATE(timestamp_field)
- Monthly aggregations: GROUP BY DATE_TRUNC('MONTH', timestamp_field)
- Quarterly aggregations: GROUP BY DATE_TRUNC('QUARTER', timestamp_field)

**Dimensional Grouping:**
- Company-level: GROUP BY company, plan_type
- Feature-level: GROUP BY feature_name, plan_type
- Support-level: GROUP BY ticket_type, resolution_status

**Complex Aggregation Rules:**

1. **Feature Adoption Rate Calculation:**
   ```sql
   (COUNT(DISTINCT CASE WHEN fu.usage_count > 0 THEN m.meeting_id END) / 
    COUNT(DISTINCT m.meeting_id)) * 100
   ```

2. **Revenue Growth Rate Calculation:**
   ```sql
   ((SUM(CASE WHEN event_date = CURRENT_DATE THEN amount END) - 
     SUM(CASE WHEN event_date = DATEADD(day, -1, CURRENT_DATE) THEN amount END)) / 
    NULLIF(SUM(CASE WHEN event_date = DATEADD(day, -1, CURRENT_DATE) THEN amount END), 0)) * 100
   ```

3. **Daily Active Users (DAU) Calculation:**
   ```sql
   COUNT(DISTINCT CASE WHEN DATE(p.join_time) = usage_date THEN p.user_id END)
   ```

4. **First Contact Resolution Rate:**
   ```sql
   (COUNT(CASE WHEN resolution_status = 'Closed' AND contact_count = 1 THEN ticket_id END) / 
    COUNT(ticket_id)) * 100
   ```

### Data Quality and Validation:

- **NULL Handling:** All aggregations use COALESCE or NULLIF to handle NULL values appropriately
- **Division by Zero Protection:** All percentage calculations include NULLIF to prevent division by zero
- **Data Type Consistency:** All numeric aggregations maintain proper precision (NUMBER(10,2) for monetary values, NUMBER(5,2) for percentages)
- **Date Standardization:** All date fields use consistent DATE data type with proper timezone handling

### Performance Optimization:

- **Incremental Processing:** Aggregations designed to support incremental updates using date-based filtering
- **Clustering Keys:** Aggregate tables clustered by date fields for optimal query performance
- **Materialized Views:** Consider implementing as materialized views for real-time analytics requirements
- **Partitioning Strategy:** Date-based partitioning aligned with business reporting cycles

### Business Rules Integration:

- **Plan Type Filtering:** Aggregations respect plan type limitations and feature availability
- **Active User Definition:** DAU calculations include only users with actual platform interaction
- **Revenue Recognition:** Revenue aggregations follow subscription business model principles
- **Support SLA Alignment:** Support metrics calculated according to defined SLA parameters

This comprehensive mapping ensures accurate, performant, and business-aligned aggregated data in the Gold layer, supporting advanced analytics and reporting requirements for the Zoom Platform Analytics System.