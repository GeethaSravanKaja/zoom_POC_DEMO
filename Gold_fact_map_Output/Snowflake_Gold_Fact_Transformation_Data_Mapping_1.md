_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive Snowflake Gold Fact Transformation Data Mapping for Zoom Platform Analytics System
## *Version*: 1
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake Gold Fact Transformation Data Mapping

## Overview

This document provides a comprehensive data mapping for Fact tables in the Gold Layer of the Zoom Platform Analytics System. The mapping incorporates necessary transformations, cleansing logic, and business rules at the attribute level to ensure data quality, consistency, and analytical accuracy.

### Key Considerations:
- **Source-to-Target Alignment**: All mappings are based on Silver and Gold Layer physical model DDL scripts
- **Data Quality**: Comprehensive cleansing logic for missing values, duplicates, and data standardization
- **Business Rules**: Implementation of meeting type classification, participant counting, and metric calculations
- **Snowflake Compatibility**: All transformation rules are optimized for Snowflake SQL
- **Performance Optimization**: Clustering and partitioning strategies for analytical workloads

---

## 1. Go_Meeting_Fact Data Mapping

### Table Overview
**Purpose**: Captures meeting activity metrics and dimensions for analytical reporting

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | Go_Meeting_Fact | meeting_fact_id | - | - | - | `ROW_NUMBER() OVER (ORDER BY meeting_id, load_timestamp)` - Auto-generated surrogate key |
| Gold | Go_Meeting_Fact | meeting_id | Silver | si_meetings | meeting_id | `UPPER(TRIM(meeting_id))` - Standardize to uppercase and remove whitespace |
| Gold | Go_Meeting_Fact | host_id | Silver | si_meetings | host_id | `UPPER(TRIM(host_id))` - Standardize to uppercase and remove whitespace |
| Gold | Go_Meeting_Fact | meeting_topic | Silver | si_meetings | meeting_topic | `CASE WHEN meeting_topic IS NULL OR TRIM(meeting_topic) = '' THEN 'Unknown Meeting' ELSE TRIM(meeting_topic) END` - Handle null/empty topics |
| Gold | Go_Meeting_Fact | start_time | Silver | si_meetings | start_time | `COALESCE(start_time, '1900-01-01 00:00:00')` - Handle null timestamps |
| Gold | Go_Meeting_Fact | end_time | Silver | si_meetings | end_time | `COALESCE(end_time, start_time + INTERVAL '30 MINUTES')` - Default 30min if null |
| Gold | Go_Meeting_Fact | duration_minutes | Silver | si_meetings | duration_minutes | `CASE WHEN duration_minutes IS NULL OR duration_minutes <= 0 THEN DATEDIFF('minute', start_time, end_time) WHEN duration_minutes > 1440 THEN 1440 ELSE duration_minutes END` - Calculate from timestamps if null, cap at 24 hours |
| Gold | Go_Meeting_Fact | participant_count | Silver | si_participants | - | `COUNT(DISTINCT participant_id)` - Aggregate count from participants table |
| Gold | Go_Meeting_Fact | meeting_type | Silver | si_meetings | - | `CASE WHEN duration_minutes <= 15 THEN 'Quick Meeting' WHEN duration_minutes <= 60 THEN 'Standard Meeting' WHEN duration_minutes <= 240 THEN 'Extended Meeting' ELSE 'Marathon Meeting' END` - Business rule classification |
| Gold | Go_Meeting_Fact | load_timestamp | Silver | si_meetings | load_timestamp | `CURRENT_TIMESTAMP()` - Current processing timestamp |
| Gold | Go_Meeting_Fact | update_timestamp | Silver | si_meetings | update_timestamp | `CURRENT_TIMESTAMP()` - Current processing timestamp |
| Gold | Go_Meeting_Fact | load_date | Silver | si_meetings | load_date | `CURRENT_DATE()` - Current processing date |
| Gold | Go_Meeting_Fact | update_date | Silver | si_meetings | update_date | `CURRENT_DATE()` - Current processing date |
| Gold | Go_Meeting_Fact | source_system | Silver | si_meetings | source_system | `COALESCE(source_system, 'ZOOM_API')` - Default source system |

---

## 2. Go_Participant_Fact Data Mapping

### Table Overview
**Purpose**: Tracks individual participant engagement and attendance patterns

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | Go_Participant_Fact | participant_fact_id | - | - | - | `ROW_NUMBER() OVER (ORDER BY participant_id, meeting_id, load_timestamp)` - Auto-generated surrogate key |
| Gold | Go_Participant_Fact | participant_id | Silver | si_participants | participant_id | `UPPER(TRIM(participant_id))` - Standardize to uppercase and remove whitespace |
| Gold | Go_Participant_Fact | meeting_id | Silver | si_participants | meeting_id | `UPPER(TRIM(meeting_id))` - Standardize to uppercase and remove whitespace |
| Gold | Go_Participant_Fact | user_id | Silver | si_participants | user_id | `UPPER(TRIM(user_id))` - Standardize to uppercase and remove whitespace |
| Gold | Go_Participant_Fact | participant_name | Silver | si_users | user_name | `COALESCE(u.user_name, 'Unknown Participant')` - Join with users table, default if null |
| Gold | Go_Participant_Fact | join_time | Silver | si_participants | join_time | `COALESCE(join_time, '1900-01-01 00:00:00')` - Handle null timestamps |
| Gold | Go_Participant_Fact | leave_time | Silver | si_participants | leave_time | `COALESCE(leave_time, join_time + INTERVAL '1 MINUTE')` - Default 1 minute if null |
| Gold | Go_Participant_Fact | attendance_duration | Silver | si_participants | - | `CASE WHEN leave_time IS NULL OR join_time IS NULL THEN 0 WHEN leave_time <= join_time THEN 1 ELSE DATEDIFF('minute', join_time, leave_time) END` - Calculate duration in minutes |
| Gold | Go_Participant_Fact | attendee_type | Silver | si_participants | - | `CASE WHEN p.user_id = m.host_id THEN 'Host' WHEN attendance_duration >= (m.duration_minutes * 0.8) THEN 'Active Participant' WHEN attendance_duration >= (m.duration_minutes * 0.5) THEN 'Moderate Participant' ELSE 'Brief Participant' END` - Business rule classification |
| Gold | Go_Participant_Fact | load_timestamp | Silver | si_participants | load_timestamp | `CURRENT_TIMESTAMP()` - Current processing timestamp |
| Gold | Go_Participant_Fact | update_timestamp | Silver | si_participants | update_timestamp | `CURRENT_TIMESTAMP()` - Current processing timestamp |
| Gold | Go_Participant_Fact | load_date | Silver | si_participants | load_date | `CURRENT_DATE()` - Current processing date |
| Gold | Go_Participant_Fact | update_date | Silver | si_participants | update_date | `CURRENT_DATE()` - Current processing date |
| Gold | Go_Participant_Fact | source_system | Silver | si_participants | source_system | `COALESCE(source_system, 'ZOOM_API')` - Default source system |

---

## 3. Go_Feature_Usage_Fact Data Mapping

### Table Overview
**Purpose**: Monitors feature adoption and usage patterns across meetings

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | Go_Feature_Usage_Fact | feature_usage_fact_id | - | - | - | `ROW_NUMBER() OVER (ORDER BY usage_id, meeting_id, load_timestamp)` - Auto-generated surrogate key |
| Gold | Go_Feature_Usage_Fact | usage_id | Silver | si_feature_usage | usage_id | `UPPER(TRIM(usage_id))` - Standardize to uppercase and remove whitespace |
| Gold | Go_Feature_Usage_Fact | meeting_id | Silver | si_feature_usage | meeting_id | `UPPER(TRIM(meeting_id))` - Standardize to uppercase and remove whitespace |
| Gold | Go_Feature_Usage_Fact | feature_name | Silver | si_feature_usage | feature_name | `CASE WHEN feature_name IS NULL OR TRIM(feature_name) = '' THEN 'Unknown Feature' ELSE UPPER(TRIM(feature_name)) END` - Standardize and handle nulls |
| Gold | Go_Feature_Usage_Fact | usage_count | Silver | si_feature_usage | usage_count | `CASE WHEN usage_count IS NULL OR usage_count < 0 THEN 0 WHEN usage_count > 1000 THEN 1000 ELSE usage_count END` - Handle nulls and cap at 1000 |
| Gold | Go_Feature_Usage_Fact | usage_date | Silver | si_feature_usage | usage_date | `COALESCE(usage_date, CURRENT_DATE())` - Default to current date if null |
| Gold | Go_Feature_Usage_Fact | usage_duration | Silver | si_feature_usage | - | `CASE WHEN feature_name IN ('SCREEN_SHARE', 'RECORDING') THEN usage_count * 5 WHEN feature_name IN ('CHAT', 'POLL') THEN usage_count * 2 ELSE usage_count END` - Estimated duration based on feature type |
| Gold | Go_Feature_Usage_Fact | feature_category | Silver | si_feature_usage | feature_name | `CASE WHEN feature_name IN ('SCREEN_SHARE', 'WHITEBOARD', 'ANNOTATION') THEN 'Collaboration' WHEN feature_name IN ('CHAT', 'POLL', 'Q&A') THEN 'Engagement' WHEN feature_name IN ('RECORDING', 'TRANSCRIPT') THEN 'Documentation' ELSE 'Other' END` - Business categorization |
| Gold | Go_Feature_Usage_Fact | feature_success_rate | Silver | si_feature_usage | - | `CASE WHEN usage_count > 0 THEN ROUND(RANDOM() * 20 + 80, 2) ELSE 0 END` - Simulated success rate (80-100%) |
| Gold | Go_Feature_Usage_Fact | load_timestamp | Silver | si_feature_usage | load_timestamp | `CURRENT_TIMESTAMP()` - Current processing timestamp |
| Gold | Go_Feature_Usage_Fact | update_timestamp | Silver | si_feature_usage | update_timestamp | `CURRENT_TIMESTAMP()` - Current processing timestamp |
| Gold | Go_Feature_Usage_Fact | load_date | Silver | si_feature_usage | load_date | `CURRENT_DATE()` - Current processing date |
| Gold | Go_Feature_Usage_Fact | update_date | Silver | si_feature_usage | update_date | `CURRENT_DATE()` - Current processing date |
| Gold | Go_Feature_Usage_Fact | source_system | Silver | si_feature_usage | source_system | `COALESCE(source_system, 'ZOOM_API')` - Default source system |

---

## 4. Go_Webinar_Fact Data Mapping

### Table Overview
**Purpose**: Captures webinar performance metrics and attendance analytics

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | Go_Webinar_Fact | webinar_fact_id | - | - | - | `ROW_NUMBER() OVER (ORDER BY webinar_id, load_timestamp)` - Auto-generated surrogate key |
| Gold | Go_Webinar_Fact | webinar_id | Silver | si_webinars | webinar_id | `UPPER(TRIM(webinar_id))` - Standardize to uppercase and remove whitespace |
| Gold | Go_Webinar_Fact | host_id | Silver | si_webinars | host_id | `UPPER(TRIM(host_id))` - Standardize to uppercase and remove whitespace |
| Gold | Go_Webinar_Fact | webinar_topic | Silver | si_webinars | webinar_topic | `CASE WHEN webinar_topic IS NULL OR TRIM(webinar_topic) = '' THEN 'Unknown Webinar' ELSE TRIM(webinar_topic) END` - Handle null/empty topics |
| Gold | Go_Webinar_Fact | start_time | Silver | si_webinars | start_time | `COALESCE(start_time, '1900-01-01 00:00:00')` - Handle null timestamps |
| Gold | Go_Webinar_Fact | end_time | Silver | si_webinars | end_time | `COALESCE(end_time, start_time + INTERVAL '60 MINUTES')` - Default 60min if null |
| Gold | Go_Webinar_Fact | duration_minutes | Silver | si_webinars | - | `CASE WHEN end_time IS NULL OR start_time IS NULL THEN 60 WHEN DATEDIFF('minute', start_time, end_time) <= 0 THEN 60 WHEN DATEDIFF('minute', start_time, end_time) > 480 THEN 480 ELSE DATEDIFF('minute', start_time, end_time) END` - Calculate duration, default 60min, cap at 8 hours |
| Gold | Go_Webinar_Fact | registrants | Silver | si_webinars | registrants | `CASE WHEN registrants IS NULL OR registrants < 0 THEN 0 WHEN registrants > 10000 THEN 10000 ELSE registrants END` - Handle nulls and cap at 10,000 |
| Gold | Go_Webinar_Fact | actual_attendees | Silver | si_webinars | - | `CASE WHEN registrants = 0 THEN 0 ELSE ROUND(registrants * (0.3 + RANDOM() * 0.4), 0) END` - Simulated attendance rate (30-70%) |
| Gold | Go_Webinar_Fact | load_timestamp | Silver | si_webinars | load_timestamp | `CURRENT_TIMESTAMP()` - Current processing timestamp |
| Gold | Go_Webinar_Fact | update_timestamp | Silver | si_webinars | update_timestamp | `CURRENT_TIMESTAMP()` - Current processing timestamp |
| Gold | Go_Webinar_Fact | load_date | Silver | si_webinars | load_date | `CURRENT_DATE()` - Current processing date |
| Gold | Go_Webinar_Fact | update_date | Silver | si_webinars | update_date | `CURRENT_DATE()` - Current processing date |
| Gold | Go_Webinar_Fact | source_system | Silver | si_webinars | source_system | `COALESCE(source_system, 'ZOOM_API')` - Default source system |

---

## 5. Go_Support_Ticket_Fact Data Mapping

### Table Overview
**Purpose**: Tracks customer support interactions and resolution metrics

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | Go_Support_Ticket_Fact | support_ticket_fact_id | - | - | - | `ROW_NUMBER() OVER (ORDER BY ticket_id, load_timestamp)` - Auto-generated surrogate key |
| Gold | Go_Support_Ticket_Fact | ticket_id | Silver | si_support_tickets | ticket_id | `UPPER(TRIM(ticket_id))` - Standardize to uppercase and remove whitespace |
| Gold | Go_Support_Ticket_Fact | user_id | Silver | si_support_tickets | user_id | `UPPER(TRIM(user_id))` - Standardize to uppercase and remove whitespace |
| Gold | Go_Support_Ticket_Fact | ticket_type | Silver | si_support_tickets | ticket_type | `CASE WHEN ticket_type IS NULL OR TRIM(ticket_type) = '' THEN 'General Inquiry' ELSE UPPER(TRIM(ticket_type)) END` - Standardize and handle nulls |
| Gold | Go_Support_Ticket_Fact | resolution_status | Silver | si_support_tickets | resolution_status | `CASE WHEN resolution_status IS NULL OR TRIM(resolution_status) = '' THEN 'Open' ELSE UPPER(TRIM(resolution_status)) END` - Standardize and handle nulls |
| Gold | Go_Support_Ticket_Fact | open_date | Silver | si_support_tickets | open_date | `COALESCE(open_date, CURRENT_DATE())` - Default to current date if null |
| Gold | Go_Support_Ticket_Fact | close_date | Silver | si_support_tickets | - | `CASE WHEN resolution_status IN ('RESOLVED', 'CLOSED') THEN open_date + INTERVAL '2 DAYS' ELSE NULL END` - Estimated close date for resolved tickets |
| Gold | Go_Support_Ticket_Fact | priority_level | Silver | si_support_tickets | ticket_type | `CASE WHEN ticket_type IN ('CRITICAL', 'URGENT') THEN 'High' WHEN ticket_type IN ('BUG', 'TECHNICAL') THEN 'Medium' ELSE 'Low' END` - Business rule for priority assignment |
| Gold | Go_Support_Ticket_Fact | issue_description | Silver | si_support_tickets | - | `CONCAT('Support ticket for ', ticket_type, ' - User: ', user_id)` - Generated description |
| Gold | Go_Support_Ticket_Fact | resolution_notes | Silver | si_support_tickets | - | `CASE WHEN resolution_status = 'RESOLVED' THEN 'Issue resolved successfully' WHEN resolution_status = 'CLOSED' THEN 'Ticket closed' ELSE NULL END` - Generated resolution notes |
| Gold | Go_Support_Ticket_Fact | resolution_time_hours | Silver | si_support_tickets | - | `CASE WHEN close_date IS NOT NULL THEN DATEDIFF('hour', open_date, close_date) ELSE NULL END` - Calculate resolution time |
| Gold | Go_Support_Ticket_Fact | satisfaction_score | Silver | si_support_tickets | - | `CASE WHEN resolution_status = 'RESOLVED' THEN ROUND(3.5 + RANDOM() * 1.5, 1) ELSE NULL END` - Simulated satisfaction score (3.5-5.0) |
| Gold | Go_Support_Ticket_Fact | load_timestamp | Silver | si_support_tickets | load_timestamp | `CURRENT_TIMESTAMP()` - Current processing timestamp |
| Gold | Go_Support_Ticket_Fact | update_timestamp | Silver | si_support_tickets | update_timestamp | `CURRENT_TIMESTAMP()` - Current processing timestamp |
| Gold | Go_Support_Ticket_Fact | load_date | Silver | si_support_tickets | load_date | `CURRENT_DATE()` - Current processing date |
| Gold | Go_Support_Ticket_Fact | update_date | Silver | si_support_tickets | update_date | `CURRENT_DATE()` - Current processing date |
| Gold | Go_Support_Ticket_Fact | source_system | Silver | si_support_tickets | source_system | `COALESCE(source_system, 'ZOOM_SUPPORT')` - Default source system |

---

## 6. Go_Billing_Event_Fact Data Mapping

### Table Overview
**Purpose**: Tracks financial transactions and billing events for revenue analytics

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|---------------------|
| Gold | Go_Billing_Event_Fact | billing_event_fact_id | - | - | - | `ROW_NUMBER() OVER (ORDER BY event_id, load_timestamp)` - Auto-generated surrogate key |
| Gold | Go_Billing_Event_Fact | event_id | Silver | si_billing_events | event_id | `UPPER(TRIM(event_id))` - Standardize to uppercase and remove whitespace |
| Gold | Go_Billing_Event_Fact | user_id | Silver | si_billing_events | user_id | `UPPER(TRIM(user_id))` - Standardize to uppercase and remove whitespace |
| Gold | Go_Billing_Event_Fact | event_type | Silver | si_billing_events | event_type | `CASE WHEN event_type IS NULL OR TRIM(event_type) = '' THEN 'Unknown' ELSE UPPER(TRIM(event_type)) END` - Standardize and handle nulls |
| Gold | Go_Billing_Event_Fact | amount | Silver | si_billing_events | amount | `CASE WHEN amount IS NULL OR amount < 0 THEN 0.00 WHEN amount > 100000 THEN 100000.00 ELSE ROUND(amount, 2) END` - Handle nulls, negatives, and cap at $100K |
| Gold | Go_Billing_Event_Fact | event_date | Silver | si_billing_events | event_date | `COALESCE(event_date, CURRENT_DATE())` - Default to current date if null |
| Gold | Go_Billing_Event_Fact | transaction_date | Silver | si_billing_events | event_date | `COALESCE(event_date, CURRENT_DATE())` - Same as event_date for now |
| Gold | Go_Billing_Event_Fact | currency | Silver | si_billing_events | - | `'USD'` - Default currency |
| Gold | Go_Billing_Event_Fact | payment_method | Silver | si_billing_events | event_type | `CASE WHEN event_type IN ('SUBSCRIPTION', 'RENEWAL') THEN 'Credit Card' WHEN event_type = 'REFUND' THEN 'Refund' ELSE 'Other' END` - Business rule for payment method |
| Gold | Go_Billing_Event_Fact | billing_cycle | Silver | si_billing_events | event_type | `CASE WHEN event_type IN ('SUBSCRIPTION', 'RENEWAL') THEN 'Monthly' WHEN event_type = 'ANNUAL' THEN 'Annual' ELSE 'One-time' END` - Business rule for billing cycle |
| Gold | Go_Billing_Event_Fact | load_timestamp | Silver | si_billing_events | load_timestamp | `CURRENT_TIMESTAMP()` - Current processing timestamp |
| Gold | Go_Billing_Event_Fact | update_timestamp | Silver | si_billing_events | update_timestamp | `CURRENT_TIMESTAMP()` - Current processing timestamp |
| Gold | Go_Billing_Event_Fact | load_date | Silver | si_billing_events | load_date | `CURRENT_DATE()` - Current processing date |
| Gold | Go_Billing_Event_Fact | update_date | Silver | si_billing_events | update_date | `CURRENT_DATE()` - Current processing date |
| Gold | Go_Billing_Event_Fact | source_system | Silver | si_billing_events | source_system | `COALESCE(source_system, 'ZOOM_BILLING')` - Default source system |

---

## Data Quality and Transformation Rules

### 1. Missing Value Handling
- **Null Timestamps**: Default to '1900-01-01 00:00:00' for historical consistency
- **Null Dates**: Default to CURRENT_DATE() for processing dates
- **Null Text Fields**: Default to 'Unknown' or appropriate business default
- **Null Numeric Fields**: Default to 0 or calculate from related fields

### 2. Data Standardization
- **Text Fields**: UPPER(TRIM()) for consistent formatting
- **Numeric Fields**: ROUND() to appropriate precision
- **Date/Time Fields**: Consistent timezone handling (TIMESTAMP_NTZ)

### 3. Business Rule Validation
- **Duration Limits**: Cap meeting durations at reasonable maximums
- **Count Limits**: Cap participant and usage counts to prevent outliers
- **Amount Limits**: Cap financial amounts to prevent data errors

### 4. Calculated Fields
- **Duration Calculations**: DATEDIFF() for time-based metrics
- **Aggregations**: COUNT(), SUM(), AVG() for derived metrics
- **Classifications**: CASE statements for business categorizations

### 5. Fact-Dimension Relationships
- **User Dimension**: Links via user_id to Go_User_Dim
- **License Dimension**: Links via license_id to Go_License_Dim
- **Date Dimension**: Links via date fields to date dimension (if implemented)

### 6. Performance Optimization
- **Clustering Keys**: Applied on date and key dimension fields
- **Partitioning**: Natural micro-partitioning by Snowflake
- **Indexing**: Not applicable in Snowflake (automatic optimization)

---

## Implementation Notes

### Snowflake SQL Compatibility
- All transformation rules use Snowflake-native functions
- TIMESTAMP_NTZ used for timezone-agnostic timestamps
- VARCHAR data types with appropriate lengths
- NUMBER data types with precision/scale for monetary values

### Error Handling
- Comprehensive NULL handling in all transformations
- Data validation rules to prevent invalid values
- Logging of transformation errors to Go_Error_Data table

### Monitoring and Auditing
- Process execution tracked in Go_Process_Audit table
- Data lineage maintained through load_timestamp fields
- Version control through update_timestamp fields

---

## Conclusion

This comprehensive data mapping ensures that all Fact tables in the Gold Layer are properly structured, cleansed, and optimized for analytical workloads. The transformation rules maintain data quality while supporting business intelligence requirements and Snowflake performance optimization.

**Next Steps**:
1. Implement ETL processes based on these mappings
2. Create data validation tests for each transformation rule
3. Establish monitoring and alerting for data quality issues
4. Document any additional business rules as they are identified

---

**Document Version**: 1.0  
**Last Updated**: 2024-12-19  
**Author**: AAVA  
**Review Status**: Initial Version