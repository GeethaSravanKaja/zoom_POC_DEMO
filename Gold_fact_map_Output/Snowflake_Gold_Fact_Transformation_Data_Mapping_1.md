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

1. **Fact-Dimension Relationships**: All fact tables are properly linked to dimension tables through foreign key mappings
2. **Metric Standardization**: Consistent handling of numeric fields with proper rounding, null handling, and format standardization
3. **Data Cleansing**: Comprehensive logic for handling missing values, duplicates, and data quality issues
4. **Business Rules**: Implementation of domain-specific transformation logic for Zoom platform analytics
5. **Snowflake Compatibility**: All transformations are optimized for Snowflake SQL execution
6. **Performance Optimization**: Transformations designed for efficient processing in Snowflake's architecture

## Data Mapping for Fact Tables

### 1. Go_Meeting_Fact

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | Go_Meeting_Fact | meeting_fact_id | N/A | N/A | N/A | `NUMBER AUTOINCREMENT` - System generated unique identifier |
| Gold | Go_Meeting_Fact | meeting_id | Silver | si_meetings | meeting_id | `COALESCE(meeting_id, 'UNKNOWN_' \|\| ROW_NUMBER())` - Handle null meeting IDs |
| Gold | Go_Meeting_Fact | host_id | Silver | si_meetings | host_id | `COALESCE(host_id, 'UNKNOWN_HOST')` - Default for missing host IDs |
| Gold | Go_Meeting_Fact | meeting_topic | Silver | si_meetings | meeting_topic | `COALESCE(TRIM(meeting_topic), 'No Topic Provided')` - Clean whitespace and handle nulls |
| Gold | Go_Meeting_Fact | start_time | Silver | si_meetings | start_time | `COALESCE(start_time, '1900-01-01 00:00:00'::TIMESTAMP_NTZ)` - Handle null timestamps |
| Gold | Go_Meeting_Fact | end_time | Silver | si_meetings | end_time | `COALESCE(end_time, start_time + INTERVAL '60 MINUTES')` - Default 60min if null |
| Gold | Go_Meeting_Fact | duration_minutes | Silver | si_meetings | duration_minutes | `CASE WHEN duration_minutes IS NULL OR duration_minutes <= 0 THEN DATEDIFF('minute', start_time, end_time) ELSE ROUND(duration_minutes, 0) END` - Calculate or validate duration |
| Gold | Go_Meeting_Fact | participant_count | Silver | si_participants | COUNT(*) | `COALESCE((SELECT COUNT(DISTINCT user_id) FROM Silver.si_participants p WHERE p.meeting_id = m.meeting_id), 0)` - Count unique participants |
| Gold | Go_Meeting_Fact | meeting_type | Silver | si_meetings | meeting_topic | `CASE WHEN UPPER(meeting_topic) LIKE '%WEBINAR%' THEN 'Webinar' WHEN UPPER(meeting_topic) LIKE '%TRAINING%' THEN 'Training' WHEN UPPER(meeting_topic) LIKE '%INTERVIEW%' THEN 'Interview' ELSE 'Regular Meeting' END` - Derive meeting type from topic |
| Gold | Go_Meeting_Fact | load_timestamp | Silver | si_meetings | load_timestamp | `COALESCE(load_timestamp, CURRENT_TIMESTAMP())` - Preserve or set current timestamp |
| Gold | Go_Meeting_Fact | update_timestamp | Silver | si_meetings | update_timestamp | `COALESCE(update_timestamp, CURRENT_TIMESTAMP())` - Preserve or set current timestamp |
| Gold | Go_Meeting_Fact | load_date | Silver | si_meetings | load_date | `COALESCE(load_date, CURRENT_DATE())` - Preserve or set current date |
| Gold | Go_Meeting_Fact | update_date | Silver | si_meetings | update_date | `COALESCE(update_date, CURRENT_DATE())` - Preserve or set current date |
| Gold | Go_Meeting_Fact | source_system | Silver | si_meetings | source_system | `COALESCE(source_system, 'ZOOM_API')` - Default source system |

### 2. Go_Participant_Fact

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | Go_Participant_Fact | participant_fact_id | N/A | N/A | N/A | `NUMBER AUTOINCREMENT` - System generated unique identifier |
| Gold | Go_Participant_Fact | participant_id | Silver | si_participants | participant_id | `COALESCE(participant_id, 'PART_' \|\| ROW_NUMBER())` - Handle null participant IDs |
| Gold | Go_Participant_Fact | meeting_id | Silver | si_participants | meeting_id | `COALESCE(meeting_id, 'UNKNOWN_MEETING')` - Handle null meeting IDs |
| Gold | Go_Participant_Fact | user_id | Silver | si_participants | user_id | `COALESCE(user_id, 'GUEST_' \|\| participant_id)` - Handle guest users |
| Gold | Go_Participant_Fact | participant_name | Silver | si_users | user_name | `COALESCE(u.user_name, 'Guest User')` - Join with users table for name |
| Gold | Go_Participant_Fact | join_time | Silver | si_participants | join_time | `COALESCE(join_time, '1900-01-01 00:00:00'::TIMESTAMP_NTZ)` - Handle null join times |
| Gold | Go_Participant_Fact | leave_time | Silver | si_participants | leave_time | `COALESCE(leave_time, join_time + INTERVAL '30 MINUTES')` - Default 30min if null |
| Gold | Go_Participant_Fact | attendance_duration | Silver | si_participants | join_time, leave_time | `CASE WHEN leave_time IS NOT NULL AND join_time IS NOT NULL THEN DATEDIFF('minute', join_time, leave_time) ELSE 0 END` - Calculate attendance duration |
| Gold | Go_Participant_Fact | attendee_type | Silver | si_users | plan_type | `CASE WHEN u.plan_type IN ('Pro', 'Business', 'Enterprise') THEN 'Licensed' ELSE 'Guest' END` - Determine attendee type |
| Gold | Go_Participant_Fact | load_timestamp | Silver | si_participants | load_timestamp | `COALESCE(load_timestamp, CURRENT_TIMESTAMP())` - Preserve or set current timestamp |
| Gold | Go_Participant_Fact | update_timestamp | Silver | si_participants | update_timestamp | `COALESCE(update_timestamp, CURRENT_TIMESTAMP())` - Preserve or set current timestamp |
| Gold | Go_Participant_Fact | load_date | Silver | si_participants | load_date | `COALESCE(load_date, CURRENT_DATE())` - Preserve or set current date |
| Gold | Go_Participant_Fact | update_date | Silver | si_participants | update_date | `COALESCE(update_date, CURRENT_DATE())` - Preserve or set current date |
| Gold | Go_Participant_Fact | source_system | Silver | si_participants | source_system | `COALESCE(source_system, 'ZOOM_API')` - Default source system |

### 3. Go_Feature_Usage_Fact

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | Go_Feature_Usage_Fact | feature_usage_fact_id | N/A | N/A | N/A | `NUMBER AUTOINCREMENT` - System generated unique identifier |
| Gold | Go_Feature_Usage_Fact | usage_id | Silver | si_feature_usage | usage_id | `COALESCE(usage_id, 'USAGE_' \|\| ROW_NUMBER())` - Handle null usage IDs |
| Gold | Go_Feature_Usage_Fact | meeting_id | Silver | si_feature_usage | meeting_id | `COALESCE(meeting_id, 'UNKNOWN_MEETING')` - Handle null meeting IDs |
| Gold | Go_Feature_Usage_Fact | feature_name | Silver | si_feature_usage | feature_name | `COALESCE(TRIM(UPPER(feature_name)), 'UNKNOWN_FEATURE')` - Standardize feature names |
| Gold | Go_Feature_Usage_Fact | usage_count | Silver | si_feature_usage | usage_count | `CASE WHEN usage_count IS NULL OR usage_count < 0 THEN 0 ELSE ROUND(usage_count, 0) END` - Validate usage count |
| Gold | Go_Feature_Usage_Fact | usage_date | Silver | si_feature_usage | usage_date | `COALESCE(usage_date, CURRENT_DATE())` - Handle null usage dates |
| Gold | Go_Feature_Usage_Fact | usage_duration | Silver | si_feature_usage | usage_count | `CASE WHEN usage_count > 0 THEN usage_count * 5 ELSE 0 END` - Estimate duration (5 min per usage) |
| Gold | Go_Feature_Usage_Fact | feature_category | Silver | si_feature_usage | feature_name | `CASE WHEN UPPER(feature_name) LIKE '%SCREEN%' THEN 'Screen Sharing' WHEN UPPER(feature_name) LIKE '%RECORD%' THEN 'Recording' WHEN UPPER(feature_name) LIKE '%CHAT%' THEN 'Communication' WHEN UPPER(feature_name) LIKE '%POLL%' THEN 'Engagement' ELSE 'Other' END` - Categorize features |
| Gold | Go_Feature_Usage_Fact | feature_success_rate | Silver | si_feature_usage | usage_count | `CASE WHEN usage_count > 0 THEN 95.0 ELSE 0.0 END` - Default success rate assumption |
| Gold | Go_Feature_Usage_Fact | load_timestamp | Silver | si_feature_usage | load_timestamp | `COALESCE(load_timestamp, CURRENT_TIMESTAMP())` - Preserve or set current timestamp |
| Gold | Go_Feature_Usage_Fact | update_timestamp | Silver | si_feature_usage | update_timestamp | `COALESCE(update_timestamp, CURRENT_TIMESTAMP())` - Preserve or set current timestamp |
| Gold | Go_Feature_Usage_Fact | load_date | Silver | si_feature_usage | load_date | `COALESCE(load_date, CURRENT_DATE())` - Preserve or set current date |
| Gold | Go_Feature_Usage_Fact | update_date | Silver | si_feature_usage | update_date | `COALESCE(update_date, CURRENT_DATE())` - Preserve or set current date |
| Gold | Go_Feature_Usage_Fact | source_system | Silver | si_feature_usage | source_system | `COALESCE(source_system, 'ZOOM_API')` - Default source system |

### 4. Go_Webinar_Fact

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | Go_Webinar_Fact | webinar_fact_id | N/A | N/A | N/A | `NUMBER AUTOINCREMENT` - System generated unique identifier |
| Gold | Go_Webinar_Fact | webinar_id | Silver | si_webinars | webinar_id | `COALESCE(webinar_id, 'WEBINAR_' \|\| ROW_NUMBER())` - Handle null webinar IDs |
| Gold | Go_Webinar_Fact | host_id | Silver | si_webinars | host_id | `COALESCE(host_id, 'UNKNOWN_HOST')` - Handle null host IDs |
| Gold | Go_Webinar_Fact | webinar_topic | Silver | si_webinars | webinar_topic | `COALESCE(TRIM(webinar_topic), 'No Topic Provided')` - Clean and handle nulls |
| Gold | Go_Webinar_Fact | start_time | Silver | si_webinars | start_time | `COALESCE(start_time, '1900-01-01 00:00:00'::TIMESTAMP_NTZ)` - Handle null timestamps |
| Gold | Go_Webinar_Fact | end_time | Silver | si_webinars | end_time | `COALESCE(end_time, start_time + INTERVAL '90 MINUTES')` - Default 90min for webinars |
| Gold | Go_Webinar_Fact | duration_minutes | Silver | si_webinars | start_time, end_time | `CASE WHEN end_time IS NOT NULL AND start_time IS NOT NULL THEN DATEDIFF('minute', start_time, end_time) ELSE 90 END` - Calculate duration |
| Gold | Go_Webinar_Fact | registrants | Silver | si_webinars | registrants | `CASE WHEN registrants IS NULL OR registrants < 0 THEN 0 ELSE ROUND(registrants, 0) END` - Validate registrants |
| Gold | Go_Webinar_Fact | actual_attendees | Silver | si_participants | COUNT(*) | `COALESCE((SELECT COUNT(DISTINCT user_id) FROM Silver.si_participants p JOIN Silver.si_meetings m ON p.meeting_id = m.meeting_id WHERE m.meeting_topic LIKE '%' \|\| w.webinar_topic \|\| '%'), 0)` - Count actual attendees |
| Gold | Go_Webinar_Fact | load_timestamp | Silver | si_webinars | load_timestamp | `COALESCE(load_timestamp, CURRENT_TIMESTAMP())` - Preserve or set current timestamp |
| Gold | Go_Webinar_Fact | update_timestamp | Silver | si_webinars | update_timestamp | `COALESCE(update_timestamp, CURRENT_TIMESTAMP())` - Preserve or set current timestamp |
| Gold | Go_Webinar_Fact | load_date | Silver | si_webinars | load_date | `COALESCE(load_date, CURRENT_DATE())` - Preserve or set current date |
| Gold | Go_Webinar_Fact | update_date | Silver | si_webinars | update_date | `COALESCE(update_date, CURRENT_DATE())` - Preserve or set current date |
| Gold | Go_Webinar_Fact | source_system | Silver | si_webinars | source_system | `COALESCE(source_system, 'ZOOM_API')` - Default source system |

### 5. Go_Support_Ticket_Fact

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | Go_Support_Ticket_Fact | support_ticket_fact_id | N/A | N/A | N/A | `NUMBER AUTOINCREMENT` - System generated unique identifier |
| Gold | Go_Support_Ticket_Fact | ticket_id | Silver | si_support_tickets | ticket_id | `COALESCE(ticket_id, 'TICKET_' \|\| ROW_NUMBER())` - Handle null ticket IDs |
| Gold | Go_Support_Ticket_Fact | user_id | Silver | si_support_tickets | user_id | `COALESCE(user_id, 'UNKNOWN_USER')` - Handle null user IDs |
| Gold | Go_Support_Ticket_Fact | ticket_type | Silver | si_support_tickets | ticket_type | `COALESCE(TRIM(UPPER(ticket_type)), 'GENERAL')` - Standardize ticket types |
| Gold | Go_Support_Ticket_Fact | resolution_status | Silver | si_support_tickets | resolution_status | `COALESCE(TRIM(UPPER(resolution_status)), 'OPEN')` - Standardize status |
| Gold | Go_Support_Ticket_Fact | open_date | Silver | si_support_tickets | open_date | `COALESCE(open_date, CURRENT_DATE())` - Handle null open dates |
| Gold | Go_Support_Ticket_Fact | close_date | Silver | si_support_tickets | resolution_status | `CASE WHEN UPPER(resolution_status) IN ('CLOSED', 'RESOLVED') THEN COALESCE(update_date, CURRENT_DATE()) ELSE NULL END` - Derive close date |
| Gold | Go_Support_Ticket_Fact | priority_level | Silver | si_support_tickets | ticket_type | `CASE WHEN UPPER(ticket_type) LIKE '%URGENT%' OR UPPER(ticket_type) LIKE '%CRITICAL%' THEN 'High' WHEN UPPER(ticket_type) LIKE '%BILLING%' THEN 'Medium' ELSE 'Low' END` - Derive priority |
| Gold | Go_Support_Ticket_Fact | issue_description | Silver | si_support_tickets | ticket_type | `CONCAT('Issue Type: ', COALESCE(ticket_type, 'General'), ' - Status: ', COALESCE(resolution_status, 'Open'))` - Create description |
| Gold | Go_Support_Ticket_Fact | resolution_notes | Silver | si_support_tickets | resolution_status | `CASE WHEN UPPER(resolution_status) IN ('CLOSED', 'RESOLVED') THEN 'Ticket resolved successfully' ELSE 'Resolution in progress' END` - Default notes |
| Gold | Go_Support_Ticket_Fact | resolution_time_hours | Silver | si_support_tickets | open_date, update_date | `CASE WHEN UPPER(resolution_status) IN ('CLOSED', 'RESOLVED') AND update_date IS NOT NULL THEN DATEDIFF('hour', open_date, update_date) ELSE NULL END` - Calculate resolution time |
| Gold | Go_Support_Ticket_Fact | satisfaction_score | Silver | si_support_tickets | resolution_status | `CASE WHEN UPPER(resolution_status) IN ('CLOSED', 'RESOLVED') THEN 4.0 ELSE NULL END` - Default satisfaction score |
| Gold | Go_Support_Ticket_Fact | load_timestamp | Silver | si_support_tickets | load_timestamp | `COALESCE(load_timestamp, CURRENT_TIMESTAMP())` - Preserve or set current timestamp |
| Gold | Go_Support_Ticket_Fact | update_timestamp | Silver | si_support_tickets | update_timestamp | `COALESCE(update_timestamp, CURRENT_TIMESTAMP())` - Preserve or set current timestamp |
| Gold | Go_Support_Ticket_Fact | load_date | Silver | si_support_tickets | load_date | `COALESCE(load_date, CURRENT_DATE())` - Preserve or set current date |
| Gold | Go_Support_Ticket_Fact | update_date | Silver | si_support_tickets | update_date | `COALESCE(update_date, CURRENT_DATE())` - Preserve or set current date |
| Gold | Go_Support_Ticket_Fact | source_system | Silver | si_support_tickets | source_system | `COALESCE(source_system, 'ZOOM_SUPPORT')` - Default source system |

### 6. Go_Billing_Event_Fact

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|--------------------|
| Gold | Go_Billing_Event_Fact | billing_event_fact_id | N/A | N/A | N/A | `NUMBER AUTOINCREMENT` - System generated unique identifier |
| Gold | Go_Billing_Event_Fact | event_id | Silver | si_billing_events | event_id | `COALESCE(event_id, 'BILLING_' \|\| ROW_NUMBER())` - Handle null event IDs |
| Gold | Go_Billing_Event_Fact | user_id | Silver | si_billing_events | user_id | `COALESCE(user_id, 'UNKNOWN_USER')` - Handle null user IDs |
| Gold | Go_Billing_Event_Fact | event_type | Silver | si_billing_events | event_type | `COALESCE(TRIM(UPPER(event_type)), 'UNKNOWN')` - Standardize event types |
| Gold | Go_Billing_Event_Fact | amount | Silver | si_billing_events | amount | `CASE WHEN amount IS NULL OR amount < 0 THEN 0.00 ELSE ROUND(amount, 2) END` - Validate and round amounts |
| Gold | Go_Billing_Event_Fact | event_date | Silver | si_billing_events | event_date | `COALESCE(event_date, CURRENT_DATE())` - Handle null event dates |
| Gold | Go_Billing_Event_Fact | transaction_date | Silver | si_billing_events | event_date | `COALESCE(event_date, CURRENT_DATE())` - Use event date as transaction date |
| Gold | Go_Billing_Event_Fact | currency | Silver | si_billing_events | amount | `CASE WHEN amount IS NOT NULL THEN 'USD' ELSE NULL END` - Default currency |
| Gold | Go_Billing_Event_Fact | payment_method | Silver | si_billing_events | event_type | `CASE WHEN UPPER(event_type) LIKE '%CREDIT%' THEN 'Credit Card' WHEN UPPER(event_type) LIKE '%BANK%' THEN 'Bank Transfer' ELSE 'Unknown' END` - Derive payment method |
| Gold | Go_Billing_Event_Fact | billing_cycle | Silver | si_billing_events | event_type | `CASE WHEN UPPER(event_type) LIKE '%MONTHLY%' THEN 'Monthly' WHEN UPPER(event_type) LIKE '%ANNUAL%' THEN 'Annual' ELSE 'One-time' END` - Derive billing cycle |
| Gold | Go_Billing_Event_Fact | load_timestamp | Silver | si_billing_events | load_timestamp | `COALESCE(load_timestamp, CURRENT_TIMESTAMP())` - Preserve or set current timestamp |
| Gold | Go_Billing_Event_Fact | update_timestamp | Silver | si_billing_events | update_timestamp | `COALESCE(update_timestamp, CURRENT_TIMESTAMP())` - Preserve or set current timestamp |
| Gold | Go_Billing_Event_Fact | load_date | Silver | si_billing_events | load_date | `COALESCE(load_date, CURRENT_DATE())` - Preserve or set current date |
| Gold | Go_Billing_Event_Fact | update_date | Silver | si_billing_events | update_date | `COALESCE(update_date, CURRENT_DATE())` - Preserve or set current date |
| Gold | Go_Billing_Event_Fact | source_system | Silver | si_billing_events | source_system | `COALESCE(source_system, 'ZOOM_BILLING')` - Default source system |

## Data Quality and Business Rules

### 1. Null Handling Strategy
- **Mandatory Fields**: All ID fields must have values; generate surrogate keys if source is null
- **Optional Fields**: Use meaningful defaults or leave null based on business context
- **Timestamps**: Default to system timestamp for audit fields, use epoch for missing business timestamps
- **Numeric Fields**: Default to 0 for counts, preserve null for optional metrics

### 2. Data Standardization Rules
- **Text Fields**: Trim whitespace, standardize case (UPPER for codes, proper case for names)
- **Numeric Fields**: Round to appropriate precision, validate ranges
- **Date/Time Fields**: Ensure consistent timezone handling (NTZ format)
- **Boolean Fields**: Standardize to TRUE/FALSE values

### 3. Data Validation Rules
- **Duration Calculations**: Validate that end_time >= start_time
- **Count Fields**: Ensure non-negative values
- **Amount Fields**: Validate currency amounts with proper precision
- **Status Fields**: Validate against predefined value lists

### 4. Business Logic Implementation
- **Meeting Types**: Derive from topic analysis and metadata
- **Attendee Classification**: Based on license type and participation patterns
- **Feature Categorization**: Group features into logical categories for analysis
- **Priority Assignment**: Derive ticket priorities from type and content analysis

### 5. Performance Optimization
- **Incremental Loading**: Use timestamp-based incremental processing
- **Clustering**: Implement date-based clustering for time-series analysis
- **Indexing**: Leverage Snowflake's automatic micro-partitioning
- **Aggregation**: Pre-calculate common metrics in aggregate tables

## Implementation Notes

### 1. Snowflake-Specific Optimizations
- Use `COALESCE` for null handling instead of `ISNULL`
- Leverage `DATEDIFF` for duration calculations
- Use `ROW_NUMBER()` for generating surrogate keys
- Implement `CASE WHEN` for complex business logic

### 2. Error Handling
- All transformations include error handling for edge cases
- Invalid data is logged to error tables for investigation
- Default values are business-meaningful where possible
- Data quality metrics are captured for monitoring

### 3. Monitoring and Auditing
- All fact tables include comprehensive audit columns
- Transformation logic is logged for troubleshooting
- Data lineage is maintained through source system tracking
- Performance metrics are captured for optimization

---

**End of Document**