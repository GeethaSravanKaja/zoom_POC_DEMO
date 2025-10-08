_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Layer Data Mapping for Zoom Platform Analytics System supporting medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Data Mapping for Zoom Platform Analytics System

## Overview

This document provides comprehensive data mapping specifications for the Bronze layer implementation in Snowflake as part of the Medallion architecture. The Bronze layer serves as the raw data ingestion layer, preserving the original structure of source data while adding essential metadata for data lineage and governance.

## Data Mapping Specifications

### Table 1: Users Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-------------------|
| Bronze | bz_users | user_id | Source | Users | User_ID | 1-1 Mapping |
| Bronze | bz_users | user_name | Source | Users | User_Name | 1-1 Mapping |
| Bronze | bz_users | email | Source | Users | Email | 1-1 Mapping |
| Bronze | bz_users | company | Source | Users | Company | 1-1 Mapping |
| Bronze | bz_users | plan_type | Source | Users | Plan_Type | 1-1 Mapping |
| Bronze | bz_users | load_timestamp | System | System | System Generated | System Generated |
| Bronze | bz_users | update_timestamp | System | System | System Generated | System Generated |
| Bronze | bz_users | source_system | System | System | System Generated | System Generated |

### Table 2: Meetings Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-------------------|
| Bronze | bz_meetings | meeting_id | Source | Meetings | Meeting_ID | 1-1 Mapping |
| Bronze | bz_meetings | host_id | Source | Meetings | Host_ID | 1-1 Mapping |
| Bronze | bz_meetings | meeting_topic | Source | Meetings | Meeting_Topic | 1-1 Mapping |
| Bronze | bz_meetings | start_time | Source | Meetings | Start_Time | 1-1 Mapping |
| Bronze | bz_meetings | end_time | Source | Meetings | End_Time | 1-1 Mapping |
| Bronze | bz_meetings | duration_minutes | Source | Meetings | Duration_Minutes | 1-1 Mapping |
| Bronze | bz_meetings | load_timestamp | System | System | System Generated | System Generated |
| Bronze | bz_meetings | update_timestamp | System | System | System Generated | System Generated |
| Bronze | bz_meetings | source_system | System | System | System Generated | System Generated |

### Table 3: Participants Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-------------------|
| Bronze | bz_participants | participant_id | Source | Participants | Participant_ID | 1-1 Mapping |
| Bronze | bz_participants | meeting_id | Source | Participants | Meeting_ID | 1-1 Mapping |
| Bronze | bz_participants | user_id | Source | Participants | User_ID | 1-1 Mapping |
| Bronze | bz_participants | join_time | Source | Participants | Join_Time | 1-1 Mapping |
| Bronze | bz_participants | leave_time | Source | Participants | Leave_Time | 1-1 Mapping |
| Bronze | bz_participants | load_timestamp | System | System | System Generated | System Generated |
| Bronze | bz_participants | update_timestamp | System | System | System Generated | System Generated |
| Bronze | bz_participants | source_system | System | System | System Generated | System Generated |

### Table 4: Feature Usage Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-------------------|
| Bronze | bz_feature_usage | usage_id | Source | Feature_Usage | Usage_ID | 1-1 Mapping |
| Bronze | bz_feature_usage | meeting_id | Source | Feature_Usage | Meeting_ID | 1-1 Mapping |
| Bronze | bz_feature_usage | feature_name | Source | Feature_Usage | Feature_Name | 1-1 Mapping |
| Bronze | bz_feature_usage | usage_count | Source | Feature_Usage | Usage_Count | 1-1 Mapping |
| Bronze | bz_feature_usage | usage_date | Source | Feature_Usage | Usage_Date | 1-1 Mapping |
| Bronze | bz_feature_usage | load_timestamp | System | System | System Generated | System Generated |
| Bronze | bz_feature_usage | update_timestamp | System | System | System Generated | System Generated |
| Bronze | bz_feature_usage | source_system | System | System | System Generated | System Generated |

### Table 5: Webinars Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-------------------|
| Bronze | bz_webinars | webinar_id | Source | Webinars | Webinar_ID | 1-1 Mapping |
| Bronze | bz_webinars | host_id | Source | Webinars | Host_ID | 1-1 Mapping |
| Bronze | bz_webinars | webinar_topic | Source | Webinars | Webinar_Topic | 1-1 Mapping |
| Bronze | bz_webinars | start_time | Source | Webinars | Start_Time | 1-1 Mapping |
| Bronze | bz_webinars | end_time | Source | Webinars | End_Time | 1-1 Mapping |
| Bronze | bz_webinars | registrants | Source | Webinars | Registrants | 1-1 Mapping |
| Bronze | bz_webinars | load_timestamp | System | System | System Generated | System Generated |
| Bronze | bz_webinars | update_timestamp | System | System | System Generated | System Generated |
| Bronze | bz_webinars | source_system | System | System | System Generated | System Generated |

### Table 6: Support Tickets Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-------------------|
| Bronze | bz_support_tickets | ticket_id | Source | Support_Tickets | Ticket_ID | 1-1 Mapping |
| Bronze | bz_support_tickets | user_id | Source | Support_Tickets | User_ID | 1-1 Mapping |
| Bronze | bz_support_tickets | ticket_type | Source | Support_Tickets | Ticket_Type | 1-1 Mapping |
| Bronze | bz_support_tickets | resolution_status | Source | Support_Tickets | Resolution_Status | 1-1 Mapping |
| Bronze | bz_support_tickets | open_date | Source | Support_Tickets | Open_Date | 1-1 Mapping |
| Bronze | bz_support_tickets | load_timestamp | System | System | System Generated | System Generated |
| Bronze | bz_support_tickets | update_timestamp | System | System | System Generated | System Generated |
| Bronze | bz_support_tickets | source_system | System | System | System Generated | System Generated |

### Table 7: Licenses Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-------------------|
| Bronze | bz_licenses | license_id | Source | Licenses | License_ID | 1-1 Mapping |
| Bronze | bz_licenses | license_type | Source | Licenses | License_Type | 1-1 Mapping |
| Bronze | bz_licenses | assigned_to_user_id | Source | Licenses | Assigned_To_User_ID | 1-1 Mapping |
| Bronze | bz_licenses | start_date | Source | Licenses | Start_Date | 1-1 Mapping |
| Bronze | bz_licenses | end_date | Source | Licenses | End_Date | 1-1 Mapping |
| Bronze | bz_licenses | load_timestamp | System | System | System Generated | System Generated |
| Bronze | bz_licenses | update_timestamp | System | System | System Generated | System Generated |
| Bronze | bz_licenses | source_system | System | System | System Generated | System Generated |

### Table 8: Billing Events Data Mapping

| Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Transformation Rule |
|--------------|--------------|--------------|--------------|--------------|--------------|-------------------|
| Bronze | bz_billing_events | event_id | Source | Billing_Events | Event_ID | 1-1 Mapping |
| Bronze | bz_billing_events | user_id | Source | Billing_Events | User_ID | 1-1 Mapping |
| Bronze | bz_billing_events | event_type | Source | Billing_Events | Event_Type | 1-1 Mapping |
| Bronze | bz_billing_events | amount | Source | Billing_Events | Amount | 1-1 Mapping |
| Bronze | bz_billing_events | event_date | Source | Billing_Events | Event_Date | 1-1 Mapping |
| Bronze | bz_billing_events | load_timestamp | System | System | System Generated | System Generated |
| Bronze | bz_billing_events | update_timestamp | System | System | System Generated | System Generated |
| Bronze | bz_billing_events | source_system | System | System | System Generated | System Generated |

## Data Type Mappings

### Source to Target Data Type Conversions

| Source Data Type | Target Data Type | Notes |
|------------------|------------------|-------|
| VARCHAR(50) | STRING | Primary keys and foreign keys |
| VARCHAR(255) | STRING | Text fields like names, topics, emails |
| VARCHAR(100) | STRING | Medium text fields |
| DATETIME | TIMESTAMP_NTZ | Timestamp without timezone |
| INT | NUMBER | Integer values |
| DATE | DATE | Date values preserved |
| DECIMAL(10,2) | NUMBER(10,2) | Monetary amounts with precision |

## Metadata Management

### System-Generated Fields

All Bronze layer tables include the following metadata fields:

- **load_timestamp**: TIMESTAMP_NTZ - Records when the data was first loaded into the Bronze layer
- **update_timestamp**: TIMESTAMP_NTZ - Records when the data was last updated in the Bronze layer
- **source_system**: STRING - Identifies the source system from which the data originated

### Data Validation Rules

1. **Primary Key Validation**: All primary key fields must be non-null and unique
2. **Foreign Key Validation**: Foreign key references are preserved but not enforced at Bronze layer
3. **Data Type Validation**: All fields must conform to target data types
4. **Timestamp Validation**: All timestamp fields must be valid datetime values
5. **Null Handling**: Null values from source are preserved in Bronze layer

## Data Ingestion Process

### Ingestion Strategy
- **Full Load**: Initial load captures all historical data
- **Incremental Load**: Subsequent loads capture only changed/new records
- **Change Data Capture**: Utilizes CDC mechanisms where available
- **Batch Processing**: Data ingested in scheduled batches

### Data Quality Checks
- Row count validation between source and target
- Data type conformity checks
- Primary key uniqueness validation
- Referential integrity monitoring (logged but not enforced)

## Summary

This Bronze layer data mapping document provides complete field-level mapping for all 8 source tables to their corresponding Bronze layer targets in Snowflake. The mapping preserves data integrity while adding essential metadata for downstream processing and governance. All transformations follow the 1-1 mapping principle appropriate for the Bronze layer in the Medallion architecture.