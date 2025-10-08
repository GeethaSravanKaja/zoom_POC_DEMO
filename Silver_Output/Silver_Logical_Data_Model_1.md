_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Silver Layer Logical Data Model for Zoom Platform Analytics System supporting medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Silver Layer Logical Data Model for Zoom Platform Analytics System

## 1. Silver Layer Logical Model

### 1.1 Si_Users
**Description:** Silver layer table containing user profile information for analytics and subscription management. Mirrors Bronze structure, removes all ID fields and unique identifiers, standardizes data types, and applies consistent naming convention.

| Column Name         | Data Type      | Description |
|---------------------|---------------|-------------|
| User_Name           | STRING        | Full name of the registered user for identification and personalization purposes |
| Email               | STRING        | Primary email address used for account registration and communication |
| Company             | STRING        | Organization name associated with the user account for business analytics and segmentation |
| Plan_Type           | STRING        | Subscription tier (Free, Pro, Business, Enterprise) indicating service level and feature access |
| load_timestamp      | TIMESTAMP     | Timestamp when the record was loaded for data lineage tracking |
| update_timestamp    | TIMESTAMP     | Timestamp when the record was last updated for change tracking |
| source_system       | STRING        | Source system identifier for data governance and traceability |

### 1.2 Si_Meetings
**Description:** Silver layer table containing meeting session data for usage analytics and platform activity tracking. Mirrors Bronze structure, removes all ID fields and unique identifiers, standardizes data types, and applies consistent naming convention.

| Column Name         | Data Type      | Description |
|---------------------|---------------|-------------|
| Meeting_Topic       | STRING        | Descriptive name or subject of the meeting for identification and categorization |
| Start_Time          | TIMESTAMP     | Timestamp when the meeting began for scheduling and usage pattern analysis |
| End_Time            | TIMESTAMP     | Timestamp when the meeting concluded for duration calculation and resource planning |
| Duration_Minutes    | NUMBER        | Total length of the meeting in minutes for usage analytics and billing purposes |
| load_timestamp      | TIMESTAMP     | Timestamp when the record was loaded for data lineage tracking |
| update_timestamp    | TIMESTAMP     | Timestamp when the record was last updated for change tracking |
| source_system       | STRING        | Source system identifier for data governance and traceability |

### 1.3 Si_Participants
**Description:** Silver layer table containing meeting participation data for attendance analytics and engagement metrics. Mirrors Bronze structure, removes all ID fields and unique identifiers, standardizes data types, and applies consistent naming convention.

| Column Name         | Data Type      | Description |
|---------------------|---------------|-------------|
| Join_Time           | TIMESTAMP     | Timestamp when the participant entered the meeting for engagement analysis |
| Leave_Time          | TIMESTAMP     | Timestamp when the participant left the meeting for participation duration calculation |
| load_timestamp      | TIMESTAMP     | Timestamp when the record was loaded for data lineage tracking |
| update_timestamp    | TIMESTAMP     | Timestamp when the record was last updated for change tracking |
| source_system       | STRING        | Source system identifier for data governance and traceability |

### 1.4 Si_Feature_Usage
**Description:** Silver layer table containing feature utilization data for feature adoption analysis and product development decisions. Mirrors Bronze structure, removes all ID fields and unique identifiers, standardizes data types, and applies consistent naming convention.

| Column Name         | Data Type      | Description |
|---------------------|---------------|-------------|
| Feature_Name        | STRING        | Specific platform feature used (Screen Share, Recording, Chat, Breakout Rooms) for adoption analysis |
| Usage_Count         | NUMBER        | Number of times the feature was utilized during the meeting for engagement metrics |
| Usage_Date          | DATE          | Date when the feature was used for temporal analysis and trend identification |
| load_timestamp      | TIMESTAMP     | Timestamp when the record was loaded for data lineage tracking |
| update_timestamp    | TIMESTAMP     | Timestamp when the record was last updated for change tracking |
| source_system       | STRING        | Source system identifier for data governance and traceability |

### 1.5 Si_Webinars
**Description:** Silver layer table containing webinar session data for webinar analytics and event management. Mirrors Bronze structure, removes all ID fields and unique identifiers, standardizes data types, and applies consistent naming convention.

| Column Name         | Data Type      | Description |
|---------------------|---------------|-------------|
| Webinar_Topic       | STRING        | Topic or title of the webinar for identification and categorization |
| Start_Time          | TIMESTAMP     | Timestamp when the webinar began for scheduling and usage pattern analysis |
| End_Time            | TIMESTAMP     | Timestamp when the webinar ended for duration calculation and resource planning |
| Registrants         | NUMBER        | Total number of users who registered for the webinar for engagement metrics |
| load_timestamp      | TIMESTAMP     | Timestamp when the record was loaded for data lineage tracking |
| update_timestamp    | TIMESTAMP     | Timestamp when the record was last updated for change tracking |
| source_system       | STRING        | Source system identifier for data governance and traceability |

### 1.6 Si_Support_Tickets
**Description:** Silver layer table containing customer support data for service quality analysis and issue tracking. Mirrors Bronze structure, removes all ID fields and unique identifiers, standardizes data types, and applies consistent naming convention.

| Column Name         | Data Type      | Description |
|---------------------|---------------|-------------|
| Ticket_Type         | STRING        | Category of the support request (Technical Issue, Billing Question, Feature Request) for issue classification |
| Resolution_Status   | STRING        | Current state of the ticket (Open, In Progress, Resolved, Closed) for workflow tracking |
| Open_Date           | DATE          | Date when the support ticket was initially created for response time analysis |
| load_timestamp      | TIMESTAMP     | Timestamp when the record was loaded for data lineage tracking |
| update_timestamp    | TIMESTAMP     | Timestamp when the record was last updated for change tracking |
| source_system       | STRING        | Source system identifier for data governance and traceability |

### 1.7 Si_Licenses
**Description:** Silver layer table containing license assignment data for license utilization analysis and renewal planning. Mirrors Bronze structure, removes all ID fields and unique identifiers, standardizes data types, and applies consistent naming convention.

| Column Name         | Data Type      | Description |
|---------------------|---------------|-------------|
| License_Type        | STRING        | Category of software license (Pro, Business, Enterprise, Education) indicating feature access level |
| Start_Date          | DATE          | Date when the license became active for usage tracking and compliance |
| End_Date            | DATE          | Date when the license expires for renewal planning and revenue forecasting |
| load_timestamp      | TIMESTAMP     | Timestamp when the record was loaded for data lineage tracking |
| update_timestamp    | TIMESTAMP     | Timestamp when the record was last updated for change tracking |
| source_system       | STRING        | Source system identifier for data governance and traceability |

### 1.8 Si_Billing_Events
**Description:** Silver layer table containing billing transaction data for revenue analysis and financial reporting. Mirrors Bronze structure, removes all ID fields and unique identifiers, standardizes data types, and applies consistent naming convention.

| Column Name         | Data Type      | Description |
|---------------------|---------------|-------------|
| Event_Type          | STRING        | Type of billing transaction (Subscription Fee, Subscription Renewal, Add-on Purchase, Refund) for revenue categorization |
| Amount              | NUMBER(10,2)  | Monetary value of the transaction for revenue calculation and financial reporting |
| Event_Date          | DATE          | Date when the billing event occurred for revenue recognition and trend analysis |
| load_timestamp      | TIMESTAMP     | Timestamp when the record was loaded for data lineage tracking |
| update_timestamp    | TIMESTAMP     | Timestamp when the record was last updated for change tracking |
| source_system       | STRING        | Source system identifier for data governance and traceability |

### 1.9 Si_Error_Audit_Log
**Description:** Silver layer table to hold both error data from data quality checks, validation, and process audit data from pipeline execution. This table is designed for error tracking, audit, and process validation.

| Column Name         | Data Type      | Description |
|---------------------|---------------|-------------|
| error_id            | NUMBER        | Unique identifier for each error record |
| error_type          | STRING        | Type of error encountered (Data Quality, Validation, Processing) |
| error_description   | STRING        | Detailed description of the error |
| source_table        | STRING        | Name of the source table where error occurred |
| error_timestamp     | TIMESTAMP     | Timestamp when the error was logged |
| process_audit_info  | STRING        | Additional audit information from pipeline execution |
| status              | STRING        | Status of the error record (Open, Resolved, In Progress) |

## 2. Conceptual Data Model Diagram (Block Diagram Format)

```
┌─────────────────────┐       ┌─────────────────────┐       ┌─────────────────────┐
│     Si_Users        │       │    Si_Meetings      │       │   Si_Participants   │
│                     │       │                     │       │                     │
│ • User_Name         │◄──────┤ • Meeting_Topic     │◄──────┤ • Join_Time         │
│ • Email             │       │ • Start_Time        │       │ • Leave_Time        │
│ • Company           │       │ • End_Time          │       │                     │
│ • Plan_Type         │       │ • Duration_Minutes  │       │                     │
└─────────────────────┘       └─────────────────────┘       └─────────────────────┘
           │                             │                             │
           │                             │                             │
           │                             ▼                             │
           │                  ┌─────────────────────┐                  │
           │                  │  Si_Feature_Usage   │                  │
           │                  │                     │                  │
           │                  │ • Feature_Name      │                  │
           │                  │ • Usage_Count       │                  │
           │                  │ • Usage_Date        │                  │
           │                  └─────────────────────┘                  │
           │                                                           │
           ▼                                                           ▼
┌─────────────────────┐       ┌─────────────────────┐       ┌─────────────────────┐
│    Si_Webinars      │       │ Si_Support_Tickets  │       │    Si_Licenses      │
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
                              │  Si_Billing_Events  │       │ Si_Error_Audit_Log  │
                              │                     │       │                     │
                              │ • Event_Type        │       │ • error_id          │
                              │ • Amount            │       │ • error_type        │
                              │ • Event_Date        │       │ • error_description │
                              └─────────────────────┘       │ • source_table      │
                                                            │ • error_timestamp   │
                                                            │ • process_audit_info│
                                                            │ • status            │
                                                            └─────────────────────┘
```

### Table Relationship Connections

1. **Si_Users** connects to **Si_Meetings** through User_Name field (logical relationship for host identification)
2. **Si_Meetings** connects to **Si_Participants** through Meeting_Topic field (logical relationship for meeting attendance)
3. **Si_Meetings** connects to **Si_Feature_Usage** through Meeting_Topic field (logical relationship for feature usage during meetings)
4. **Si_Users** connects to **Si_Webinars** through User_Name field (logical relationship for webinar hosting)
5. **Si_Users** connects to **Si_Support_Tickets** through User_Name field (logical relationship for ticket creation)
6. **Si_Users** connects to **Si_Licenses** through User_Name field (logical relationship for license assignment)
7. **Si_Users** connects to **Si_Billing_Events** through User_Name field (logical relationship for billing transactions)
8. **Si_Error_Audit_Log** connects to all tables through source_table field (audit relationship for all data loading activities)

### Key Design Decisions and Assumptions

1. **Primary and Foreign Key Removal**: All primary key, foreign key, unique identifiers, and ID fields have been removed from Silver layer tables as per requirements, maintaining only business data fields.
2. **Naming Convention**: All table names use the 'Si_' prefix to clearly identify Silver layer tables in the medallion architecture.
3. **Metadata Columns**: Standard metadata columns (load_timestamp, update_timestamp, source_system) have been added to all tables for data lineage and governance.
4. **Data Type Standardization**: All data types have been standardized to STRING, NUMBER, DATE, TIMESTAMP as appropriate for Snowflake compatibility and analytics use cases.
5. **Error and Audit Table**: A dedicated Silver layer table tracks both error data from data quality checks and process audit information for compliance and operational monitoring.
6. **Source Alignment**: The model exactly mirrors the source process tables structure while adapting to Silver layer requirements.
7. **Column Descriptions**: All columns include brief, clear descriptions for business and technical understanding.

---

## Numbered Summary of Silver Layer Logical Model Sections

1. Metadata Requirements
2. Silver Layer Logical Model (All Tables)
3. Conceptual Data Model Diagram (Block Format)
4. Table Relationship Connections
5. Rationale for Key Design Decisions and Assumptions

