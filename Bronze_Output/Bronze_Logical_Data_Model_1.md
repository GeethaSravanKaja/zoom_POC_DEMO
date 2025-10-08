_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Layer Logical Data Model for Zoom Platform Analytics System supporting medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Bronze Layer Logical Data Model for Zoom Platform Analytics System

## 1. PII Classification

### 1.1 Column Names and PII Reasons

| Column Name | Table | PII Classification | Reason |
|-------------|-------|-------------------|--------|
| User_Name | Bz_Users | PII | Contains full name of individual users which directly identifies a person and is considered personally identifiable information under GDPR and other privacy regulations |
| Email | Bz_Users | PII | Email addresses are unique identifiers that can be used to contact and identify specific individuals, making them sensitive personal data requiring protection |
| Company | Bz_Users | Non-PII | Organization names are business entities and do not directly identify individuals |
| Plan_Type | Bz_Users | Non-PII | Subscription tier information is business data and does not identify individuals |
| Meeting_Topic | Bz_Meetings | Non-PII | Meeting subjects are business content and do not contain personal identification |
| Start_Time | Bz_Meetings | Non-PII | Timestamps are operational data and do not identify individuals |
| End_Time | Bz_Meetings | Non-PII | Timestamps are operational data and do not identify individuals |
| Duration_Minutes | Bz_Meetings | Non-PII | Numeric duration values are operational metrics and do not identify individuals |
| Join_Time | Bz_Participants | Non-PII | Timestamps are operational data and do not identify individuals |
| Leave_Time | Bz_Participants | Non-PII | Timestamps are operational data and do not identify individuals |
| Feature_Name | Bz_Feature_Usage | Non-PII | Feature names are system functionality labels and do not identify individuals |
| Usage_Count | Bz_Feature_Usage | Non-PII | Numeric usage metrics are operational data and do not identify individuals |
| Usage_Date | Bz_Feature_Usage | Non-PII | Dates are operational data and do not identify individuals |
| Webinar_Topic | Bz_Webinars | Non-PII | Webinar subjects are business content and do not contain personal identification |
| Registrants | Bz_Webinars | Non-PII | Numeric count values are operational metrics and do not identify individuals |
| Ticket_Type | Bz_Support_Tickets | Non-PII | Support categories are business classifications and do not identify individuals |
| Resolution_Status | Bz_Support_Tickets | Non-PII | Status values are operational states and do not identify individuals |
| Open_Date | Bz_Support_Tickets | Non-PII | Dates are operational data and do not identify individuals |
| License_Type | Bz_Licenses | Non-PII | License categories are business classifications and do not identify individuals |
| Start_Date | Bz_Licenses | Non-PII | Dates are operational data and do not identify individuals |
| End_Date | Bz_Licenses | Non-PII | Dates are operational data and do not identify individuals |
| Event_Type | Bz_Billing_Events | Non-PII | Billing categories are business classifications and do not identify individuals |
| Amount | Bz_Billing_Events | Non-PII | Financial amounts are business metrics and do not identify individuals |
| Event_Date | Bz_Billing_Events | Non-PII | Dates are operational data and do not identify individuals |

## 2. Bronze Layer Logical Model

### 2.1 Bz_Users
**Description:** Bronze layer table containing user profile information mirrored from source Users table, supporting user analytics and subscription management.

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| User_Name | VARCHAR(255) | Full name of the registered user for identification and personalization purposes |
| Email | VARCHAR(255) | Primary email address used for account registration and communication |
| Company | VARCHAR(255) | Organization name associated with the user account for business analytics and segmentation |
| Plan_Type | VARCHAR(50) | Subscription tier (Free, Pro, Business, Enterprise) indicating service level and feature access |
| load_timestamp | TIMESTAMP | Timestamp when the record was loaded into Bronze layer for data lineage tracking |
| update_timestamp | TIMESTAMP | Timestamp when the record was last updated in Bronze layer for change tracking |
| source_system | VARCHAR(100) | Source system identifier for data governance and traceability |

### 2.2 Bz_Meetings
**Description:** Bronze layer table containing meeting session data mirrored from source Meetings table, supporting usage analytics and platform activity tracking.

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| Meeting_Topic | VARCHAR(255) | Descriptive name or subject of the meeting for identification and categorization |
| Start_Time | TIMESTAMP | Timestamp when the meeting began for scheduling and usage pattern analysis |
| End_Time | TIMESTAMP | Timestamp when the meeting concluded for duration calculation and resource planning |
| Duration_Minutes | INTEGER | Total length of the meeting in minutes for usage analytics and billing purposes |
| load_timestamp | TIMESTAMP | Timestamp when the record was loaded into Bronze layer for data lineage tracking |
| update_timestamp | TIMESTAMP | Timestamp when the record was last updated in Bronze layer for change tracking |
| source_system | VARCHAR(100) | Source system identifier for data governance and traceability |

### 2.3 Bz_Participants
**Description:** Bronze layer table containing meeting participation data mirrored from source Participants table, supporting attendance analytics and engagement metrics.

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| Join_Time | TIMESTAMP | Timestamp when the participant entered the meeting for engagement analysis |
| Leave_Time | TIMESTAMP | Timestamp when the participant left the meeting for participation duration calculation |
| load_timestamp | TIMESTAMP | Timestamp when the record was loaded into Bronze layer for data lineage tracking |
| update_timestamp | TIMESTAMP | Timestamp when the record was last updated in Bronze layer for change tracking |
| source_system | VARCHAR(100) | Source system identifier for data governance and traceability |

### 2.4 Bz_Feature_Usage
**Description:** Bronze layer table containing feature utilization data mirrored from source Feature_Usage table, supporting feature adoption analysis and product development decisions.

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| Feature_Name | VARCHAR(100) | Specific platform feature used (Screen Share, Recording, Chat, Breakout Rooms) for adoption analysis |
| Usage_Count | INTEGER | Number of times the feature was utilized during the meeting for engagement metrics |
| Usage_Date | DATE | Date when the feature was used for temporal analysis and trend identification |
| load_timestamp | TIMESTAMP | Timestamp when the record was loaded into Bronze layer for data lineage tracking |
| update_timestamp | TIMESTAMP | Timestamp when the record was last updated in Bronze layer for change tracking |
| source_system | VARCHAR(100) | Source system identifier for data governance and traceability |

### 2.5 Bz_Webinars
**Description:** Bronze layer table containing webinar session data mirrored from source Webinars table, supporting webinar analytics and event management.

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| Webinar_Topic | VARCHAR(255) | Topic or title of the webinar for identification and categorization |
| Start_Time | TIMESTAMP | Timestamp when the webinar began for scheduling and usage pattern analysis |
| End_Time | TIMESTAMP | Timestamp when the webinar ended for duration calculation and resource planning |
| Registrants | INTEGER | Total number of users who registered for the webinar for engagement metrics |
| load_timestamp | TIMESTAMP | Timestamp when the record was loaded into Bronze layer for data lineage tracking |
| update_timestamp | TIMESTAMP | Timestamp when the record was last updated in Bronze layer for change tracking |
| source_system | VARCHAR(100) | Source system identifier for data governance and traceability |

### 2.6 Bz_Support_Tickets
**Description:** Bronze layer table containing customer support data mirrored from source Support_Tickets table, supporting service quality analysis and issue tracking.

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| Ticket_Type | VARCHAR(100) | Category of the support request (Technical Issue, Billing Question, Feature Request) for issue classification |
| Resolution_Status | VARCHAR(50) | Current state of the ticket (Open, In Progress, Resolved, Closed) for workflow tracking |
| Open_Date | DATE | Date when the support ticket was initially created for response time analysis |
| load_timestamp | TIMESTAMP | Timestamp when the record was loaded into Bronze layer for data lineage tracking |
| update_timestamp | TIMESTAMP | Timestamp when the record was last updated in Bronze layer for change tracking |
| source_system | VARCHAR(100) | Source system identifier for data governance and traceability |

### 2.7 Bz_Licenses
**Description:** Bronze layer table containing license assignment data mirrored from source Licenses table, supporting license utilization analysis and renewal planning.

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| License_Type | VARCHAR(50) | Category of software license (Pro, Business, Enterprise, Education) indicating feature access level |
| Start_Date | DATE | Date when the license became active for usage tracking and compliance |
| End_Date | DATE | Date when the license expires for renewal planning and revenue forecasting |
| load_timestamp | TIMESTAMP | Timestamp when the record was loaded into Bronze layer for data lineage tracking |
| update_timestamp | TIMESTAMP | Timestamp when the record was last updated in Bronze layer for change tracking |
| source_system | VARCHAR(100) | Source system identifier for data governance and traceability |

### 2.8 Bz_Billing_Events
**Description:** Bronze layer table containing billing transaction data mirrored from source Billing_Events table, supporting revenue analysis and financial reporting.

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| Event_Type | VARCHAR(100) | Type of billing transaction (Subscription Fee, Subscription Renewal, Add-on Purchase, Refund) for revenue categorization |
| Amount | DECIMAL(10,2) | Monetary value of the transaction for revenue calculation and financial reporting |
| Event_Date | DATE | Date when the billing event occurred for revenue recognition and trend analysis |
| load_timestamp | TIMESTAMP | Timestamp when the record was loaded into Bronze layer for data lineage tracking |
| update_timestamp | TIMESTAMP | Timestamp when the record was last updated in Bronze layer for change tracking |
| source_system | VARCHAR(100) | Source system identifier for data governance and traceability |

## 3. Audit Table Design

### 3.1 Bz_Audit_Log
**Description:** Audit table to track all data loading and processing activities in the Bronze layer for compliance and monitoring purposes.

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| record_id | VARCHAR(50) | Unique identifier for each audit record for tracking individual load operations |
| source_table | VARCHAR(100) | Name of the source table from which data was ingested for traceability |
| load_timestamp | TIMESTAMP | Timestamp when the data loading process was initiated for temporal tracking |
| processed_by | VARCHAR(100) | Identifier of the process, job, or user who performed the data load for accountability |
| processing_time | INTEGER | Time taken in seconds to complete the data loading process for performance monitoring |
| status | VARCHAR(50) | Status of the data loading operation (Success, Failed, In Progress) for operational monitoring |

## 4. Conceptual Data Model Diagram

### 4.1 Block Diagram Format - Entity Relationships

```
┌─────────────────────┐       ┌─────────────────────┐       ┌─────────────────────┐
│     Bz_Users        │       │    Bz_Meetings      │       │   Bz_Participants   │
│                     │       │                     │       │                     │
│ • User_Name (PII)   │◄──────┤ • Meeting_Topic     │◄──────┤ • Join_Time         │
│ • Email (PII)       │       │ • Start_Time        │       │ • Leave_Time        │
│ • Company           │       │ • End_Time          │       │                     │
│ • Plan_Type         │       │ • Duration_Minutes  │       │                     │
└─────────────────────┘       └─────────────────────┘       └─────────────────────┘
           │                             │                             │
           │                             │                             │
           │                             ▼                             │
           │                  ┌─────────────────────┐                  │
           │                  │  Bz_Feature_Usage   │                  │
           │                  │                     │                  │
           │                  │ • Feature_Name      │                  │
           │                  │ • Usage_Count       │                  │
           │                  │ • Usage_Date        │                  │
           │                  └─────────────────────┘                  │
           │                                                           │
           ▼                                                           ▼
┌─────────────────────┐       ┌─────────────────────┐       ┌─────────────────────┐
│    Bz_Webinars      │       │ Bz_Support_Tickets  │       │    Bz_Licenses      │
│                     │       │                     │       │                     │
│ • Webinar_Topic     │       │ • Ticket_Type       │       │ • License_Type      │
│ • Start_Time        │       │ • Resolution_Status │       │ • Start_Date        │
│ • End_Time          │       │ • Open_Date         │       │ • End_Date          │
│ • Registrants       │       │                     │       │                     │
└─────────────────────┘       └─────────────────────┘       └─────────────────────┘
                                         │                             │
                                         │                             │
                                         ▼                             ▼
                              ┌─────────────────────┐       ┌─────────────────────┐
                              │  Bz_Billing_Events  │       │    Bz_Audit_Log     │
                              │                     │       │                     │
                              │ • Event_Type        │       │ • record_id         │
                              │ • Amount            │       │ • source_table      │
                              │ • Event_Date        │       │ • load_timestamp    │
                              └─────────────────────┘       │ • processed_by      │
                                                            │ • processing_time   │
                                                            │ • status            │
                                                            └─────────────────────┘
```

### 4.2 Table Relationship Connections

1. **Bz_Users** connects to **Bz_Meetings** through User_Name field (logical relationship for host identification)
2. **Bz_Meetings** connects to **Bz_Participants** through Meeting_Topic field (logical relationship for meeting attendance)
3. **Bz_Meetings** connects to **Bz_Feature_Usage** through Meeting_Topic field (logical relationship for feature usage during meetings)
4. **Bz_Users** connects to **Bz_Webinars** through User_Name field (logical relationship for webinar hosting)
5. **Bz_Users** connects to **Bz_Support_Tickets** through User_Name field (logical relationship for ticket creation)
6. **Bz_Users** connects to **Bz_Licenses** through User_Name field (logical relationship for license assignment)
7. **Bz_Users** connects to **Bz_Billing_Events** through User_Name field (logical relationship for billing transactions)
8. **Bz_Audit_Log** connects to all tables through source_table field (audit relationship for all data loading activities)

### 4.3 Key Design Decisions and Assumptions

1. **Primary and Foreign Key Removal**: All primary key and foreign key fields have been removed from the Bronze layer tables as per requirements, maintaining only business data fields.

2. **Naming Convention**: All table names use the 'Bz_' prefix to clearly identify Bronze layer tables in the medallion architecture.

3. **Metadata Columns**: Standard metadata columns (load_timestamp, update_timestamp, source_system) have been added to all tables for data lineage and governance.

4. **PII Classification**: Only User_Name and Email fields are classified as PII based on GDPR and privacy regulation standards.

5. **Data Types**: Data types have been selected to accommodate the expected data volumes and precision requirements for the Zoom platform analytics.

6. **Audit Strategy**: A comprehensive audit table tracks all data loading activities for compliance and operational monitoring.

7. **Source Alignment**: The model exactly mirrors the source process tables structure while adapting to Bronze layer requirements.