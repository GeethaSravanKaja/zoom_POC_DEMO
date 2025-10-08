_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Gold Layer Logical Data Model for Zoom Platform Analytics System supporting medallion architecture, advanced analytics, and reporting
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Gold Layer Logical Data Model for Zoom Platform Analytics System

## 1. Gold Layer Logical Model

### Table Classification & SCD Types

| Table Name         | Table Type   | SCD Type | Description |
|--------------------|-------------|----------|-------------|
| Go_User_Dim        | Dimension   | Type 2   | User profile and subscription details, tracks user changes over time |
| Go_Meeting_Fact    | Fact        | N/A      | Meeting activity and engagement metrics |
| Go_Attendee_Fact   | Fact        | N/A      | Meeting attendance and participation metrics |
| Go_Feature_Usage_Fact | Fact     | N/A      | Feature utilization metrics per meeting |
| Go_Support_Ticket_Fact | Fact    | N/A      | Customer support interactions and ticket lifecycle |
| Go_Billing_Event_Fact | Fact     | N/A      | Billing transactions and revenue events |
| Go_License_Dim     | Dimension   | Type 2   | License assignment and validity details |
| Go_Meeting_Type_Code | Code      | N/A      | Lookup for meeting types |
| Go_Plan_Type_Code  | Code        | N/A      | Lookup for plan types |
| Go_Ticket_Type_Code| Code        | N/A      | Lookup for support ticket types |
| Go_Feature_Code    | Code        | N/A      | Lookup for feature categories |
| Go_Error_Audit_Log | Audit/Error | N/A      | Process audit and error tracking |
| Go_Usage_Agg_Day   | Aggregate   | N/A      | Daily usage aggregates (DAU, meeting minutes, etc.) |
| Go_Support_Agg_Day | Aggregate   | N/A      | Daily support ticket aggregates |
| Go_Revenue_Agg_Month | Aggregate | N/A      | Monthly revenue and license aggregates |

---

### 1.1 Go_User_Dim (Dimension, SCD Type 2)

| Column Name         | Data Type   | Description | PII |
|---------------------|------------|-------------|-----|
| User_Name           | STRING     | Full name of the registered user | Yes |
| Email               | STRING     | Primary email address | Yes |
| Plan_Type           | STRING     | Subscription tier (Free, Basic, Pro, Business, Enterprise) | No |
| Registration_Date   | DATE       | Date of account creation | No |
| Company             | STRING     | Organization name | No |
| Account_Status      | STRING     | Current status (Active, Suspended, Cancelled) | No |
| load_date           | DATE       | Date record loaded | No |
| update_date         | DATE       | Date record updated | No |
| source_system       | STRING     | Source system identifier | No |
| scd_start_date      | DATE       | SCD2: Record effective start date | No |
| scd_end_date        | DATE       | SCD2: Record effective end date | No |
| scd_current_flag    | BOOLEAN    | SCD2: Is current record | No |

---

### 1.2 Go_Meeting_Fact (Fact)

| Column Name         | Data Type   | Description | PII |
|---------------------|------------|-------------|-----|
| Meeting_Title       | STRING     | Meeting subject/title | No |
| Start_Time          | TIMESTAMP  | Meeting start time | No |
| End_Time            | TIMESTAMP  | Meeting end time | No |
| Duration_Minutes    | NUMBER     | Meeting duration in minutes | No |
| Host_Name           | STRING     | Host user name | Yes |
| Meeting_Type        | STRING     | Meeting type (Scheduled, Instant, Recurring) | No |
| Participant_Count   | NUMBER     | Number of attendees | No |
| load_date           | DATE       | Date record loaded | No |
| update_date         | DATE       | Date record updated | No |
| source_system       | STRING     | Source system identifier | No |

---

### 1.3 Go_Attendee_Fact (Fact)

| Column Name         | Data Type   | Description | PII |
|---------------------|------------|-------------|-----|
| Meeting_Title       | STRING     | Meeting subject/title | No |
| Attendee_Name       | STRING     | Name of attendee | Yes |
| Join_Time           | TIMESTAMP  | Attendee join time | No |
| Leave_Time          | TIMESTAMP  | Attendee leave time | No |
| Attendance_Duration | NUMBER     | Duration attended (minutes) | No |
| Attendee_Type       | STRING     | Internal, External, Guest | No |
| load_date           | DATE       | Date record loaded | No |
| update_date         | DATE       | Date record updated | No |
| source_system       | STRING     | Source system identifier | No |

---

### 1.4 Go_Feature_Usage_Fact (Fact)

| Column Name         | Data Type   | Description | PII |
|---------------------|------------|-------------|-----|
| Meeting_Title       | STRING     | Meeting subject/title | No |
| Feature_Name        | STRING     | Feature used (Screen Share, Recording, etc.) | No |
| Usage_Count         | NUMBER     | Number of times feature used | No |
| Usage_Duration      | NUMBER     | Total duration feature used (minutes) | No |
| Feature_Category    | STRING     | Feature grouping | No |
| load_date           | DATE       | Date record loaded | No |
| update_date         | DATE       | Date record updated | No |
| source_system       | STRING     | Source system identifier | No |

---

### 1.5 Go_Support_Ticket_Fact (Fact)

| Column Name         | Data Type   | Description | PII |
|---------------------|------------|-------------|-----|
| Ticket_Type         | STRING     | Support request category | No |
| Resolution_Status   | STRING     | Ticket status | No |
| Open_Date           | DATE       | Ticket creation date | No |
| Close_Date          | DATE       | Ticket closure date | No |
| Priority_Level      | STRING     | Ticket urgency | No |
| Issue_Description   | STRING     | Description of issue | No |
| Resolution_Notes    | STRING     | Resolution summary | No |
| User_Name           | STRING     | User who created ticket | Yes |
| load_date           | DATE       | Date record loaded | No |
| update_date         | DATE       | Date record updated | No |
| source_system       | STRING     | Source system identifier | No |

---

### 1.6 Go_Billing_Event_Fact (Fact)

| Column Name         | Data Type   | Description | PII |
|---------------------|------------|-------------|-----|
| Event_Type          | STRING     | Billing transaction type | No |
| Amount              | NUMBER(10,2)| Transaction amount | No |
| Transaction_Date    | DATE       | Date of transaction | No |
| Currency            | STRING     | Currency code | No |
| Payment_Method      | STRING     | Payment method | No |
| Billing_Cycle       | STRING     | Billing frequency | No |
| User_Name           | STRING     | User associated with event | Yes |
| load_date           | DATE       | Date record loaded | No |
| update_date         | DATE       | Date record updated | No |
| source_system       | STRING     | Source system identifier | No |

---

### 1.7 Go_License_Dim (Dimension, SCD Type 2)

| Column Name         | Data Type   | Description | PII |
|---------------------|------------|-------------|-----|
| License_Type        | STRING     | License category | No |
| Start_Date          | DATE       | License start date | No |
| End_Date            | DATE       | License end date | No |
| Assignment_Status   | STRING     | Assigned, Unassigned, Expired | No |
| License_Capacity    | NUMBER     | Max users/features allowed | No |
| User_Name           | STRING     | User assigned license | Yes |
| load_date           | DATE       | Date record loaded | No |
| update_date         | DATE       | Date record updated | No |
| source_system       | STRING     | Source system identifier | No |
| scd_start_date      | DATE       | SCD2: Record effective start date | No |
| scd_end_date        | DATE       | SCD2: Record effective end date | No |
| scd_current_flag    | BOOLEAN    | SCD2: Is current record | No |

---

### 1.8 Go_Meeting_Type_Code (Code Table)

| Column Name         | Data Type   | Description |
|---------------------|------------|-------------|
| Meeting_Type        | STRING     | Meeting type value |
| Meeting_Type_Desc   | STRING     | Description of meeting type |

---

### 1.9 Go_Plan_Type_Code (Code Table)

| Column Name         | Data Type   | Description |
|---------------------|------------|-------------|
| Plan_Type           | STRING     | Plan type value |
| Plan_Type_Desc      | STRING     | Description of plan type |

---

### 1.10 Go_Ticket_Type_Code (Code Table)

| Column Name         | Data Type   | Description |
|---------------------|------------|-------------|
| Ticket_Type         | STRING     | Ticket type value |
| Ticket_Type_Desc    | STRING     | Description of ticket type |

---

### 1.11 Go_Feature_Code (Code Table)

| Column Name         | Data Type   | Description |
|---------------------|------------|-------------|
| Feature_Name        | STRING     | Feature value |
| Feature_Category    | STRING     | Feature grouping |
| Feature_Desc        | STRING     | Description of feature |

---

### 1.12 Go_Error_Audit_Log (Audit/Error Table)

| Column Name         | Data Type   | Description |
|---------------------|------------|-------------|
| error_type          | STRING     | Type of error (Data Quality, Validation, Processing) |
| error_description   | STRING     | Detailed error description |
| source_table        | STRING     | Table where error occurred |
| error_timestamp     | TIMESTAMP  | When error was logged |
| process_audit_info  | STRING     | Pipeline execution audit info |
| status              | STRING     | Error status (Open, Resolved, In Progress) |
| load_date           | DATE       | Date record loaded |
| update_date         | DATE       | Date record updated |
| source_system       | STRING     | Source system identifier |

---

### 1.13 Go_Usage_Agg_Day (Aggregate Table)

| Column Name         | Data Type   | Description |
|---------------------|------------|-------------|
| Usage_Date          | DATE       | Date of usage |
| DAU                 | NUMBER     | Daily active users |
| Total_Meeting_Minutes | NUMBER   | Total meeting minutes per day |
| Avg_Meeting_Duration | NUMBER    | Average meeting duration |
| Meetings_Created    | NUMBER     | Meetings created per day |
| Feature_Adoption_Rate | NUMBER   | % users using features |
| load_date           | DATE       | Date record loaded |
| update_date         | DATE       | Date record updated |
| source_system       | STRING     | Source system identifier |

---

### 1.14 Go_Support_Agg_Day (Aggregate Table)

| Column Name         | Data Type   | Description |
|---------------------|------------|-------------|
| Support_Date        | DATE       | Date of support activity |
| Tickets_Opened      | NUMBER     | Tickets opened per day |
| Avg_Resolution_Time | NUMBER     | Average ticket resolution time (hours) |
| Most_Common_Ticket_Type | STRING | Most frequent ticket type |
| First_Contact_Resolution_Rate | NUMBER | % tickets resolved at first contact |
| Tickets_per_1000_Users | NUMBER | Support tickets per 1,000 active users |
| load_date           | DATE       | Date record loaded |
| update_date         | DATE       | Date record updated |
| source_system       | STRING     | Source system identifier |

---

### 1.15 Go_Revenue_Agg_Month (Aggregate Table)

| Column Name         | Data Type   | Description |
|---------------------|------------|-------------|
| Revenue_Month       | STRING     | Month of revenue |
| MRR                 | NUMBER     | Monthly recurring revenue |
| Revenue_by_Plan_Type| NUMBER     | Revenue per plan type |
| License_Utilization_Rate | NUMBER | % licenses actively used |
| License_Expiration_Count | NUMBER | Licenses expired in month |
| Revenue_per_User    | NUMBER     | Average revenue per user |
| load_date           | DATE       | Date record loaded |
| update_date         | DATE       | Date record updated |
| source_system       | STRING     | Source system identifier |

---

## 2. Conceptual Data Model Diagram (Tabular Format)

| Source Entity | Relationship Type | Target Entity | Key Field | Relationship Description |
|---------------|-------------------|---------------|-----------|-------------------------|
| Go_User_Dim   | One-to-Many       | Go_Meeting_Fact | Host_Name | A user can host multiple meetings |
| Go_Meeting_Fact | One-to-Many     | Go_Attendee_Fact | Meeting_Title | A meeting can have multiple attendees |
| Go_Meeting_Fact | One-to-Many     | Go_Feature_Usage_Fact | Meeting_Title | A meeting can have multiple feature usage records |
| Go_User_Dim   | One-to-Many       | Go_Support_Ticket_Fact | User_Name | A user can create multiple support tickets |
| Go_User_Dim   | One-to-Many       | Go_Billing_Event_Fact | User_Name | A user can have multiple billing events |
| Go_User_Dim   | One-to-Many       | Go_License_Dim | User_Name | A user can be assigned multiple licenses |
| Go_Support_Ticket_Fact | Many-to-One | Go_Meeting_Fact | Meeting_Title | Support tickets may reference specific meetings |
| Go_Error_Audit_Log | Many-to-One   | All Tables    | source_table | Error/audit records reference source tables |

---

## 3. ER Diagram (Block Diagram Format)

```
┌─────────────────────┐       ┌─────────────────────┐       ┌─────────────────────┐
│    Go_User_Dim      │◄──────┤  Go_Meeting_Fact    │◄──────┤ Go_Attendee_Fact   │
│                     │       │                     │       │                    │
│ • User_Name         │       │ • Meeting_Title     │       │ • Attendee_Name    │
│ • Email             │       │ • Host_Name         │       │ • Join_Time        │
│ • Plan_Type         │       │ • Start_Time        │       │ • Leave_Time       │
│ • Company           │       │ • End_Time          │       │ • Attendance_Duration│
│ • Account_Status    │       │ • Duration_Minutes  │       │ • Attendee_Type    │
└─────────────────────┘       └─────────────────────┘       └─────────────────────┘
           │                             │                             │
           │                             ▼                             │
           │                  ┌─────────────────────┐                  │
           │                  │ Go_Feature_Usage_Fact│                 │
           │                  │                     │                  │
           │                  │ • Feature_Name      │                  │
           │                  │ • Usage_Count       │                  │
           │                  │ • Usage_Duration    │                  │
           │                  │ • Feature_Category  │                  │
           │                  └─────────────────────┘                  │
           │                                                           │
           ▼                                                           ▼
┌─────────────────────┐       ┌─────────────────────┐       ┌─────────────────────┐
│ Go_Support_Ticket_Fact│     │ Go_Billing_Event_Fact│      │ Go_License_Dim     │
│                     │       │                     │       │                    │
│ • Ticket_Type       │       │ • Event_Type        │       │ • License_Type     │
│ • Resolution_Status │       │ • Amount            │       │ • Start_Date       │
│ • Open_Date         │       │ • Transaction_Date  │       │ • End_Date         │
│ • Close_Date        │       │ • Currency          │       │ • Assignment_Status│
│ • Priority_Level    │       │ • Payment_Method    │       │ • License_Capacity │
│ • User_Name         │       │ • User_Name         │       │ • User_Name        │
└─────────────────────┘       └─────────────────────┘       └─────────────────────┘
                                         │                             │
                                         │                             │
                                         ▼                             ▼
                              ┌─────────────────────┐       ┌─────────────────────┐
                              │ Go_Error_Audit_Log  │       │ Go_Usage_Agg_Day    │
                              │                     │       │ Go_Support_Agg_Day  │
                              │ • error_type        │       │ Go_Revenue_Agg_Month│
                              │ • error_description │       └─────────────────────┘
                              │ • source_table      │
                              │ • error_timestamp   │
                              │ • process_audit_info│
                              │ • status            │
                              └─────────────────────┘
```

---

## 4. Table Relationships

- **Go_User_Dim** is the central dimension, referenced by facts and dimensions for host, attendee, ticket, billing, and license assignment.
- **Go_Meeting_Fact** is the main activity fact, referenced by attendee and feature usage facts.
- **Go_Attendee_Fact** and **Go_Feature_Usage_Fact** provide granular analytics for meetings.
- **Go_Support_Ticket_Fact**, **Go_Billing_Event_Fact**, **Go_License_Dim** are transactional/analytic facts and dimensions linked to users.
- **Code tables** standardize categorical values for reporting and analytics.
- **Aggregate tables** support KPI and dashboard reporting.
- **Go_Error_Audit_Log** provides cross-table audit and error tracking for compliance and operational monitoring.

---

## 5. Rationale for Design Decisions

- **Fact/Dimension/Code Table Classification**: Follows Kimball methodology for star schema, supporting efficient analytics and reporting.
- **SCD Type 2 for Dimensions**: Enables historical tracking of user and license changes, supporting time-travel analytics.
- **No ID Fields**: Complies with business requirement to avoid physical keys, using business attributes for joins.
- **Metadata Columns**: Ensures data lineage, governance, and auditability.
- **Aggregate Tables**: Pre-compute KPIs for performance and scalability.
- **Error/Audit Table**: Centralizes process audit and error tracking for compliance and operational reliability.
- **Column Descriptions & PII Classification**: Supports data governance, privacy, and regulatory compliance.
- **Relationships**: Documented for logical joins and business context, not enforced physically.
- **Business Rules & Constraints**: Incorporated via data types, SCD, and aggregate logic, supporting platform policies and reporting accuracy.

---

## 6. apiCost

apiCost: 0.002345

---