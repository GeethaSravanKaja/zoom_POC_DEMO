_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Gold Layer Logical Data Model for Zoom Platform Analytics System supporting medallion architecture with dimensional modeling
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Gold Layer Logical Data Model for Zoom Platform Analytics System

## 1. Gold Layer Logical Model

### 1.1 Go_User_Dim
**Description:** Dimension table containing user profile information for analytics and subscription management. Supports SCD Type 2 for historical tracking of user attribute changes.
**Table Type:** Dimension
**SCD Type:** SCD Type 2

| Column Name         | Data Type      | PII Classification | Description |
|---------------------|----------------|-------------------|-------------|
| User_Name           | STRING         | Yes               | Full name of the registered user for identification and personalization purposes |
| Email               | STRING         | Yes               | Primary email address used for account registration and communication |
| Company             | STRING         | No                | Organization name associated with the user account for business analytics and segmentation |
| Plan_Type           | STRING         | No                | Subscription tier (Free, Pro, Business, Enterprise) indicating service level and feature access |
| load_date           | TIMESTAMP      | No                | Timestamp when the record was loaded for data lineage tracking |
| update_date         | TIMESTAMP      | No                | Timestamp when the record was last updated for change tracking |
| source_system       | STRING         | No                | Source system identifier for data governance and traceability |

### 1.2 Go_Meeting_Fact
**Description:** Fact table containing meeting session data for usage analytics and platform activity tracking. Central fact table for meeting-related metrics.
**Table Type:** Fact
**SCD Type:** N/A

| Column Name         | Data Type      | PII Classification | Description |
|---------------------|----------------|-------------------|-------------|
| Meeting_Topic       | STRING         | No                | Descriptive name or subject of the meeting for identification and categorization |
| Start_Time          | TIMESTAMP      | No                | Timestamp when the meeting began for scheduling and usage pattern analysis |
| End_Time            | TIMESTAMP      | No                | Timestamp when the meeting concluded for duration calculation and resource planning |
| Duration_Minutes    | NUMBER         | No                | Total length of the meeting in minutes for usage analytics and billing purposes |
| Host_Name           | STRING         | Yes               | Name of the user who organized and hosted the meeting for host activity analysis |
| Participant_Count   | NUMBER         | No                | Total number of attendees who joined the meeting for engagement metrics |
| load_date           | TIMESTAMP      | No                | Timestamp when the record was loaded for data lineage tracking |
| update_date         | TIMESTAMP      | No                | Timestamp when the record was last updated for change tracking |
| source_system       | STRING         | No                | Source system identifier for data governance and traceability |

### 1.3 Go_Participant_Fact
**Description:** Fact table containing meeting participation data for attendance analytics and engagement metrics. Tracks individual participant behavior.
**Table Type:** Fact
**SCD Type:** N/A

| Column Name         | Data Type      | PII Classification | Description |
|---------------------|----------------|-------------------|-------------|
| Meeting_Topic       | STRING         | No                | Meeting identifier for linking participation to specific meetings |
| Participant_Name    | STRING         | Yes               | Name of the person who participated in the meeting for attendance tracking |
| Join_Time           | TIMESTAMP      | No                | Timestamp when the participant entered the meeting for engagement analysis |
| Leave_Time          | TIMESTAMP      | No                | Timestamp when the participant left the meeting for participation duration calculation |
| Attendance_Duration | NUMBER         | No                | Total time the participant spent in the meeting for engagement metrics |
| load_date           | TIMESTAMP      | No                | Timestamp when the record was loaded for data lineage tracking |
| update_date         | TIMESTAMP      | No                | Timestamp when the record was last updated for change tracking |
| source_system       | STRING         | No                | Source system identifier for data governance and traceability |

### 1.4 Go_Feature_Usage_Fact
**Description:** Fact table containing feature utilization data for feature adoption analysis and product development decisions. Tracks platform feature engagement.
**Table Type:** Fact
**SCD Type:** N/A

| Column Name         | Data Type      | PII Classification | Description |
|---------------------|----------------|-------------------|-------------|
| Meeting_Topic       | STRING         | No                | Meeting identifier for linking feature usage to specific meetings |
| Feature_Name        | STRING         | No                | Specific platform feature used (Screen Share, Recording, Chat, Breakout Rooms) for adoption analysis |
| Usage_Count         | NUMBER         | No                | Number of times the feature was utilized during the meeting for engagement metrics |
| Usage_Date          | DATE           | No                | Date when the feature was used for temporal analysis and trend identification |
| Usage_Duration      | NUMBER         | No                | Total time the feature was active during the meeting for detailed usage analytics |
| load_date           | TIMESTAMP      | No                | Timestamp when the record was loaded for data lineage tracking |
| update_date         | TIMESTAMP      | No                | Timestamp when the record was last updated for change tracking |
| source_system       | STRING         | No                | Source system identifier for data governance and traceability |

### 1.5 Go_Webinar_Fact
**Description:** Fact table containing webinar session data for webinar analytics and event management. Specialized fact table for webinar events.
**Table Type:** Fact
**SCD Type:** N/A

| Column Name         | Data Type      | PII Classification | Description |
|---------------------|----------------|-------------------|-------------|
| Webinar_Topic       | STRING         | No                | Topic or title of the webinar for identification and categorization |
| Host_Name           | STRING         | Yes               | Name of the webinar host for host activity analysis |
| Start_Time          | TIMESTAMP      | No                | Timestamp when the webinar began for scheduling and usage pattern analysis |
| End_Time            | TIMESTAMP      | No                | Timestamp when the webinar ended for duration calculation and resource planning |
| Registrants         | NUMBER         | No                | Total number of users who registered for the webinar for engagement metrics |
| Actual_Attendees    | NUMBER         | No                | Total number of users who actually attended the webinar |
| load_date           | TIMESTAMP      | No                | Timestamp when the record was loaded for data lineage tracking |
| update_date         | TIMESTAMP      | No                | Timestamp when the record was last updated for change tracking |
| source_system       | STRING         | No                | Source system identifier for data governance and traceability |

### 1.6 Go_Support_Ticket_Fact
**Description:** Fact table containing customer support data for service quality analysis and issue tracking. Tracks support interaction metrics.
**Table Type:** Fact
**SCD Type:** N/A

| Column Name         | Data Type      | PII Classification | Description |
|---------------------|----------------|-------------------|-------------|
| User_Name           | STRING         | Yes               | Name of the user who created the support ticket |
| Ticket_Type         | STRING         | No                | Category of the support request (Technical Issue, Billing Question, Feature Request) for issue classification |
| Resolution_Status   | STRING         | No                | Current state of the ticket (Open, In Progress, Resolved, Closed) for workflow tracking |
| Open_Date           | DATE           | No                | Date when the support ticket was initially created for response time analysis |
| Close_Date          | DATE           | No                | Date when the ticket was resolved and closed for resolution time calculation |
| Priority_Level      | STRING         | No                | Urgency classification (Low, Medium, High, Critical) for resource allocation |
| Resolution_Time_Hours | NUMBER       | No                | Time taken to resolve the ticket in hours for SLA tracking |
| load_date           | TIMESTAMP      | No                | Timestamp when the record was loaded for data lineage tracking |
| update_date         | TIMESTAMP      | No                | Timestamp when the record was last updated for change tracking |
| source_system       | STRING         | No                | Source system identifier for data governance and traceability |

### 1.7 Go_License_Dim
**Description:** Dimension table containing license assignment data for license utilization analysis and renewal planning. Supports SCD Type 2 for license history.
**Table Type:** Dimension
**SCD Type:** SCD Type 2

| Column Name         | Data Type      | PII Classification | Description |
|---------------------|----------------|-------------------|-------------|
| License_Type        | STRING         | No                | Category of software license (Pro, Business, Enterprise, Education) indicating feature access level |
| Assigned_User_Name  | STRING         | Yes               | Name of the user to whom the license is assigned |
| Start_Date          | DATE           | No                | Date when the license became active for usage tracking and compliance |
| End_Date            | DATE           | No                | Date when the license expires for renewal planning and revenue forecasting |
| Assignment_Status   | STRING         | No                | Current state of license assignment (Assigned, Unassigned, Expired) for utilization analysis |
| License_Capacity    | NUMBER         | No                | Maximum number of users or features allowed under the license for capacity planning |
| load_date           | TIMESTAMP      | No                | Timestamp when the record was loaded for data lineage tracking |
| update_date         | TIMESTAMP      | No                | Timestamp when the record was last updated for change tracking |
| source_system       | STRING         | No                | Source system identifier for data governance and traceability |

### 1.8 Go_Billing_Event_Fact
**Description:** Fact table containing billing transaction data for revenue analysis and financial reporting. Central fact table for financial metrics.
**Table Type:** Fact
**SCD Type:** N/A

| Column Name         | Data Type      | PII Classification | Description |
|---------------------|----------------|-------------------|-------------|
| User_Name           | STRING         | Yes               | Name of the user associated with the billing event |
| Event_Type          | STRING         | No                | Type of billing transaction (Subscription Fee, Subscription Renewal, Add-on Purchase, Refund) for revenue categorization |
| Amount              | NUMBER(10,2)   | No                | Monetary value of the transaction for revenue calculation and financial reporting |
| Event_Date          | DATE           | No                | Date when the billing event occurred for revenue recognition and trend analysis |
| Currency            | STRING         | No                | Currency denomination of the transaction for international revenue analysis |
| Payment_Method      | STRING         | No                | Method used for payment (Credit Card, Bank Transfer, Invoice) for payment analytics |
| Billing_Cycle       | STRING         | No                | Frequency of recurring charges (Monthly, Annual) for revenue forecasting |
| load_date           | TIMESTAMP      | No                | Timestamp when the record was loaded for data lineage tracking |
| update_date         | TIMESTAMP      | No                | Timestamp when the record was last updated for change tracking |
| source_system       | STRING         | No                | Source system identifier for data governance and traceability |

### 1.9 Go_Daily_Usage_Agg
**Description:** Aggregated table containing daily usage metrics for reporting and analytics. Pre-calculated metrics for performance optimization.
**Table Type:** Aggregated
**SCD Type:** N/A

| Column Name         | Data Type      | PII Classification | Description |
|---------------------|----------------|-------------------|-------------|
| Usage_Date          | DATE           | No                | Date for which usage metrics are aggregated |
| Company             | STRING         | No                | Company name for business-level aggregation |
| Plan_Type           | STRING         | No                | Subscription plan type for plan-level analysis |
| Total_Meetings      | NUMBER         | No                | Total number of meetings held on the date |
| Total_Duration_Minutes | NUMBER      | No                | Total meeting duration in minutes for the date |
| Unique_Users        | NUMBER         | No                | Number of unique users who hosted meetings |
| Total_Participants  | NUMBER         | No                | Total number of meeting participants |
| load_date           | TIMESTAMP      | No                | Timestamp when the record was loaded for data lineage tracking |
| update_date         | TIMESTAMP      | No                | Timestamp when the record was last updated for change tracking |
| source_system       | STRING         | No                | Source system identifier for data governance and traceability |

### 1.10 Go_Feature_Adoption_Agg
**Description:** Aggregated table containing feature adoption metrics for product analytics. Pre-calculated feature usage statistics.
**Table Type:** Aggregated
**SCD Type:** N/A

| Column Name         | Data Type      | PII Classification | Description |
|---------------------|----------------|-------------------|-------------|
| Usage_Date          | DATE           | No                | Date for which feature adoption is measured |
| Feature_Name        | STRING         | No                | Name of the platform feature |
| Plan_Type           | STRING         | No                | Subscription plan type for feature access analysis |
| Total_Usage_Count   | NUMBER         | No                | Total number of times the feature was used |
| Unique_Users_Count  | NUMBER         | No                | Number of unique users who used the feature |
| Adoption_Rate       | NUMBER(5,2)    | No                | Percentage of eligible users who used the feature |
| load_date           | TIMESTAMP      | No                | Timestamp when the record was loaded for data lineage tracking |
| update_date         | TIMESTAMP      | No                | Timestamp when the record was last updated for change tracking |
| source_system       | STRING         | No                | Source system identifier for data governance and traceability |

### 1.11 Go_Revenue_Agg
**Description:** Aggregated table containing revenue metrics for financial reporting and analysis. Pre-calculated financial KPIs.
**Table Type:** Aggregated
**SCD Type:** N/A

| Column Name         | Data Type      | PII Classification | Description |
|---------------------|----------------|-------------------|-------------|
| Revenue_Date        | DATE           | No                | Date for which revenue is calculated |
| Plan_Type           | STRING         | No                | Subscription plan type for revenue segmentation |
| Company             | STRING         | No                | Company name for business-level revenue analysis |
| Total_Revenue       | NUMBER(12,2)   | No                | Total revenue amount for the date and segment |
| New_Revenue         | NUMBER(12,2)   | No                | Revenue from new subscriptions |
| Recurring_Revenue   | NUMBER(12,2)   | No                | Revenue from recurring subscriptions |
| Churn_Revenue       | NUMBER(12,2)   | No                | Revenue lost due to cancellations |
| load_date           | TIMESTAMP      | No                | Timestamp when the record was loaded for data lineage tracking |
| update_date         | TIMESTAMP      | No                | Timestamp when the record was last updated for change tracking |
| source_system       | STRING         | No                | Source system identifier for data governance and traceability |

### 1.12 Go_Process_Audit
**Description:** Code table to hold process audit data from pipeline execution for monitoring and compliance. Tracks ETL process performance.
**Table Type:** Code Table
**SCD Type:** N/A

| Column Name         | Data Type      | PII Classification | Description |
|---------------------|----------------|-------------------|-------------|
| Process_Name        | STRING         | No                | Name of the ETL or data processing pipeline |
| Execution_Start_Time | TIMESTAMP     | No                | Timestamp when the process execution started |
| Execution_End_Time  | TIMESTAMP      | No                | Timestamp when the process execution completed |
| Execution_Status    | STRING         | No                | Status of the process execution (Success, Failed, Warning) |
| Records_Processed   | NUMBER         | No                | Number of records processed during execution |
| Records_Inserted    | NUMBER         | No                | Number of records successfully inserted |
| Records_Updated     | NUMBER         | No                | Number of records successfully updated |
| Records_Failed      | NUMBER         | No                | Number of records that failed processing |
| Process_Duration_Seconds | NUMBER    | No                | Total execution time in seconds |
| load_date           | TIMESTAMP      | No                | Timestamp when the record was loaded for data lineage tracking |
| update_date         | TIMESTAMP      | No                | Timestamp when the record was last updated for change tracking |
| source_system       | STRING         | No                | Source system identifier for data governance and traceability |

### 1.13 Go_Error_Data
**Description:** Code table to hold error data from data validation process for data quality monitoring. Tracks data quality issues.
**Table Type:** Code Table
**SCD Type:** N/A

| Column Name         | Data Type      | PII Classification | Description |
|---------------------|----------------|-------------------|-------------|
| Error_Type          | STRING         | No                | Category of error (Data Quality, Validation, Processing, System) |
| Error_Description   | STRING         | No                | Detailed description of the error encountered |
| Error_Timestamp     | TIMESTAMP      | No                | Timestamp when the error occurred |
| Source_Table        | STRING         | No                | Name of the source table where error was detected |
| Source_Column       | STRING         | No                | Name of the source column where error was detected |
| Error_Value         | STRING         | No                | Value that caused the error (masked if PII) |
| Validation_Rule     | STRING         | No                | Name of the validation rule that was violated |
| Error_Severity      | STRING         | No                | Severity level of the error (Critical, High, Medium, Low) |
| Resolution_Status   | STRING         | No                | Status of error resolution (Open, In Progress, Resolved) |
| Resolution_Notes    | STRING         | No                | Notes on how the error was resolved |
| load_date           | TIMESTAMP      | No                | Timestamp when the record was loaded for data lineage tracking |
| update_date         | TIMESTAMP      | No                | Timestamp when the record was last updated for change tracking |
| source_system       | STRING         | No                | Source system identifier for data governance and traceability |

## 2. Conceptual Data Model Diagram

| Source Table | Relationship Type | Target Table | Key Field | Relationship Description |
|--------------|-------------------|--------------|-----------|-------------------------|
| Go_User_Dim | One-to-Many | Go_Meeting_Fact | User_Name / Host_Name | A user can host multiple meetings; each meeting has one host |
| Go_Meeting_Fact | One-to-Many | Go_Participant_Fact | Meeting_Topic | A meeting can have multiple participants; each participation record belongs to one meeting |
| Go_Meeting_Fact | One-to-Many | Go_Feature_Usage_Fact | Meeting_Topic | A meeting can have multiple feature usage records; each usage record belongs to one meeting |
| Go_User_Dim | One-to-Many | Go_Webinar_Fact | User_Name / Host_Name | A user can host multiple webinars; each webinar has one host |
| Go_User_Dim | One-to-Many | Go_Support_Ticket_Fact | User_Name | A user can create multiple support tickets; each ticket belongs to one user |
| Go_User_Dim | One-to-Many | Go_License_Dim | User_Name / Assigned_User_Name | A user can be assigned multiple licenses; each license is assigned to one user |
| Go_User_Dim | One-to-Many | Go_Billing_Event_Fact | User_Name | A user can have multiple billing events; each billing event belongs to one user |
| Go_Meeting_Fact | Many-to-One | Go_Daily_Usage_Agg | Usage_Date | Multiple meetings aggregate to daily usage metrics |
| Go_Feature_Usage_Fact | Many-to-One | Go_Feature_Adoption_Agg | Usage_Date, Feature_Name | Multiple feature usage records aggregate to adoption metrics |
| Go_Billing_Event_Fact | Many-to-One | Go_Revenue_Agg | Event_Date / Revenue_Date | Multiple billing events aggregate to revenue metrics |

## 3. ER Diagram Visualization

```
                    ┌─────────────────────┐
                    │     Go_User_Dim     │
                    │   (Dimension)       │
                    │ • User_Name         │
                    │ • Email             │
                    │ • Company           │
                    │ • Plan_Type         │
                    └──────────┬──────────┘
                               │
                               │ (1:M)
                               ▼
    ┌─────────────────────┐   ┌─────────────────────┐   ┌─────────────────────┐
    │  Go_Meeting_Fact    │   │  Go_Webinar_Fact    │   │Go_Support_Ticket_Fact│
    │     (Fact)          │   │     (Fact)          │   │     (Fact)          │
    │ • Meeting_Topic     │   │ • Webinar_Topic     │   │ • Ticket_Type       │
    │ • Start_Time        │   │ • Start_Time        │   │ • Resolution_Status │
    │ • Duration_Minutes  │   │ • Registrants       │   │ • Open_Date         │
    └──────────┬──────────┘   └─────────────────────┘   └─────────────────────┘
               │
               │ (1:M)
               ▼
┌─────────────────────┐   ┌─────────────────────┐
│ Go_Participant_Fact │   │Go_Feature_Usage_Fact│
│     (Fact)          │   │     (Fact)          │
│ • Participant_Name  │   │ • Feature_Name      │
│ • Join_Time         │   │ • Usage_Count       │
│ • Leave_Time        │   │ • Usage_Date        │
└─────────────────────┘   └─────────────────────┘

    ┌─────────────────────┐   ┌─────────────────────┐
    │   Go_License_Dim    │   │Go_Billing_Event_Fact│
    │   (Dimension)       │   │     (Fact)          │
    │ • License_Type      │   │ • Event_Type        │
    │ • Start_Date        │   │ • Amount            │
    │ • End_Date          │   │ • Event_Date        │
    └─────────────────────┘   └─────────────────────┘

┌─────────────────────┐   ┌─────────────────────┐   ┌─────────────────────┐
│ Go_Daily_Usage_Agg  │   │Go_Feature_Adoption_ │   │  Go_Revenue_Agg     │
│   (Aggregate)       │   │     Agg             │   │   (Aggregate)       │
│ • Usage_Date        │   │   (Aggregate)       │   │ • Revenue_Date      │
│ • Total_Meetings    │   │ • Feature_Name      │   │ • Total_Revenue     │
│ • Total_Duration    │   │ • Adoption_Rate     │   │ • Recurring_Revenue │
└─────────────────────┘   └─────────────────────┘   └─────────────────────┘

┌─────────────────────┐   ┌─────────────────────┐
│  Go_Process_Audit   │   │   Go_Error_Data     │
│   (Code Table)      │   │   (Code Table)      │
│ • Process_Name      │   │ • Error_Type        │
│ • Execution_Status  │   │ • Error_Description │
│ • Records_Processed │   │ • Error_Timestamp   │
└─────────────────────┘   └─────────────────────┘
```

### Rationale for Key Design Decisions and Assumptions

1. **Dimensional Modeling Approach**: Applied Kimball methodology with fact and dimension tables to support analytical queries and reporting requirements.

2. **SCD Type 2 Implementation**: Go_User_Dim and Go_License_Dim use SCD Type 2 to track historical changes in user attributes and license assignments for trend analysis.

3. **Fact Table Design**: Separate fact tables for different business processes (meetings, participants, features, webinars, support, billing) to optimize query performance and maintain data granularity.

4. **Aggregate Tables**: Pre-calculated aggregate tables (Go_Daily_Usage_Agg, Go_Feature_Adoption_Agg, Go_Revenue_Agg) for improved reporting performance and common KPI calculations.

5. **Naming Convention**: Consistent 'Go_' prefix for all Gold layer tables to clearly identify the data layer in the medallion architecture.

6. **Metadata Columns**: Standard metadata columns (load_date, update_date, source_system) added to all tables for data lineage, governance, and operational monitoring.

7. **PII Classification**: Identified and classified personally identifiable information (User_Name, Email, Participant_Name) for data privacy compliance.

8. **Process and Error Tracking**: Dedicated code tables (Go_Process_Audit, Go_Error_Data) for monitoring ETL processes and data quality issues.

9. **Business Key Relationships**: Used business keys (User_Name, Meeting_Topic) instead of surrogate keys for logical relationships between tables.

10. **Data Type Optimization**: Selected appropriate data types for analytical workloads while maintaining compatibility with source systems.

apiCost: 0.0025