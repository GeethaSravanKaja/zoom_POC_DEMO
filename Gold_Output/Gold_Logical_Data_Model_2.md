_____________________________________________
## *Author*: AAVA
## *Version*: 2
## *Description*: Gold Layer Logical Data Model for Zoom Platform Analytics System supporting medallion architecture, aligned with Silver layer, including facts, dimensions, aggregates, process audit, and error tracking structures. Supports KPIs: Daily/Weekly/Monthly Active Users, Meeting Minutes, Feature Adoption Rate, Ticket Resolution Time, Monthly Recurring Revenue, License Utilization Rate.
_____________________________________________

# Gold Layer Logical Data Model for Zoom Platform Analytics System

## 1. Metadata
- Author: AAVA
- Version: 2
- Description: Gold Layer Logical Data Model for Zoom Platform Analytics System supporting medallion architecture, aligned with Silver layer, including facts, dimensions, aggregates, process audit, and error tracking structures. Supports KPIs: Daily/Weekly/Monthly Active Users, Meeting Minutes, Feature Adoption Rate, Ticket Resolution Time, Monthly Recurring Revenue, License Utilization Rate.

---

## 2. Table Classification & SCD Types
- **Fact Tables**: Go_Fact_Meeting_Usage, Go_Fact_Feature_Usage, Go_Fact_Webinar_Usage, Go_Fact_Support_Ticket, Go_Fact_Billing, Go_Fact_License_Utilization
- **Dimension Tables**: Go_Dim_User (SCD Type 2), Go_Dim_Meeting (SCD Type 1), Go_Dim_Feature (SCD Type 1), Go_Dim_Webinar (SCD Type 1), Go_Dim_Ticket_Type (SCD Type 1), Go_Dim_License_Type (SCD Type 1), Go_Dim_Billing_Event_Type (SCD Type 1)
- **Aggregate Tables**: Go_Agg_Active_Users, Go_Agg_Meeting_Minutes, Go_Agg_Feature_Adoption, Go_Agg_Ticket_Resolution, Go_Agg_MRR, Go_Agg_License_Utilization
- **Process Audit & Error Tables**: Go_Process_Audit_Log, Go_Error_Audit_Log
- **Code Tables**: Go_Code_Resolution_Status, Go_Code_Plan_Type

---

## 3. Gold Layer Logical Model (Tables)

### 3.1 Go_Dim_User (Dimension, SCD Type 2)
| Column Name      | Data Type | Description | PII |
|------------------|-----------|-------------|-----|
| User_Name        | STRING    | Full name of the registered user | Yes |
| Email            | STRING    | Primary email address | Yes |
| Company          | STRING    | Organization name | No |
| Plan_Type        | STRING    | Subscription tier | No |
| load_date        | DATE      | Date record loaded | No |
| update_date      | DATE      | Date record updated | No |
| source_system    | STRING    | Source system identifier | No |

### 3.2 Go_Dim_Meeting (Dimension, SCD Type 1)
| Column Name      | Data Type | Description | PII |
|------------------|-----------|-------------|-----|
| Meeting_Topic    | STRING    | Meeting subject/title | No |
| load_date        | DATE      | Date record loaded | No |
| update_date      | DATE      | Date record updated | No |
| source_system    | STRING    | Source system identifier | No |

### 3.3 Go_Dim_Feature (Dimension, SCD Type 1)
| Column Name      | Data Type | Description | PII |
|------------------|-----------|-------------|-----|
| Feature_Name     | STRING    | Platform feature name | No |
| load_date        | DATE      | Date record loaded | No |
| update_date      | DATE      | Date record updated | No |
| source_system    | STRING    | Source system identifier | No |

### 3.4 Go_Dim_Webinar (Dimension, SCD Type 1)
| Column Name      | Data Type | Description | PII |
|------------------|-----------|-------------|-----|
| Webinar_Topic    | STRING    | Webinar subject/title | No |
| load_date        | DATE      | Date record loaded | No |
| update_date      | DATE      | Date record updated | No |
| source_system    | STRING    | Source system identifier | No |

### 3.5 Go_Dim_Ticket_Type (Dimension, SCD Type 1)
| Column Name      | Data Type | Description | PII |
|------------------|-----------|-------------|-----|
| Ticket_Type      | STRING    | Support ticket category | No |
| load_date        | DATE      | Date record loaded | No |
| update_date      | DATE      | Date record updated | No |
| source_system    | STRING    | Source system identifier | No |

### 3.6 Go_Dim_License_Type (Dimension, SCD Type 1)
| Column Name      | Data Type | Description | PII |
|------------------|-----------|-------------|-----|
| License_Type     | STRING    | License category | No |
| load_date        | DATE      | Date record loaded | No |
| update_date      | DATE      | Date record updated | No |
| source_system    | STRING    | Source system identifier | No |

### 3.7 Go_Dim_Billing_Event_Type (Dimension, SCD Type 1)
| Column Name      | Data Type | Description | PII |
|------------------|-----------|-------------|-----|
| Event_Type       | STRING    | Billing event type | No |
| load_date        | DATE      | Date record loaded | No |
| update_date      | DATE      | Date record updated | No |
| source_system    | STRING    | Source system identifier | No |

### 3.8 Go_Fact_Meeting_Usage (Fact)
| Column Name      | Data Type | Description | PII |
|------------------|-----------|-------------|-----|
| User_Name        | STRING    | Meeting host | Yes |
| Meeting_Topic    | STRING    | Meeting subject/title | No |
| Start_Time       | TIMESTAMP | Meeting start time | No |
| End_Time         | TIMESTAMP | Meeting end time | No |
| Duration_Minutes | NUMBER    | Meeting duration in minutes | No |
| load_date        | DATE      | Date record loaded | No |
| update_date      | DATE      | Date record updated | No |
| source_system    | STRING    | Source system identifier | No |

### 3.9 Go_Fact_Feature_Usage (Fact)
| Column Name      | Data Type | Description | PII |
|------------------|-----------|-------------|-----|
| Meeting_Topic    | STRING    | Meeting subject/title | No |
| Feature_Name     | STRING    | Platform feature name | No |
| Usage_Count      | NUMBER    | Number of times feature used | No |
| Usage_Date       | DATE      | Date feature used | No |
| load_date        | DATE      | Date record loaded | No |
| update_date      | DATE      | Date record updated | No |
| source_system    | STRING    | Source system identifier | No |

### 3.10 Go_Fact_Webinar_Usage (Fact)
| Column Name      | Data Type | Description | PII |
|------------------|-----------|-------------|-----|
| Webinar_Topic    | STRING    | Webinar subject/title | No |
| Start_Time       | TIMESTAMP | Webinar start time | No |
| End_Time         | TIMESTAMP | Webinar end time | No |
| Registrants      | NUMBER    | Number of webinar registrants | No |
| load_date        | DATE      | Date record loaded | No |
| update_date      | DATE      | Date record updated | No |
| source_system    | STRING    | Source system identifier | No |

### 3.11 Go_Fact_Support_Ticket (Fact)
| Column Name      | Data Type | Description | PII |
|------------------|-----------|-------------|-----|
| User_Name        | STRING    | Ticket creator | Yes |
| Ticket_Type      | STRING    | Support ticket category | No |
| Resolution_Status| STRING    | Ticket status | No |
| Open_Date        | DATE      | Ticket creation date | No |
| load_date        | DATE      | Date record loaded | No |
| update_date      | DATE      | Date record updated | No |
| source_system    | STRING    | Source system identifier | No |

### 3.12 Go_Fact_Billing (Fact)
| Column Name      | Data Type | Description | PII |
|------------------|-----------|-------------|-----|
| User_Name        | STRING    | User associated with billing event | Yes |
| Event_Type       | STRING    | Billing event type | No |
| Amount           | NUMBER(10,2)| Transaction amount | No |
| Event_Date       | DATE      | Billing event date | No |
| load_date        | DATE      | Date record loaded | No |
| update_date      | DATE      | Date record updated | No |
| source_system    | STRING    | Source system identifier | No |

### 3.13 Go_Fact_License_Utilization (Fact)
| Column Name      | Data Type | Description | PII |
|------------------|-----------|-------------|-----|
| User_Name        | STRING    | User assigned license | Yes |
| License_Type     | STRING    | License category | No |
| Start_Date       | DATE      | License start date | No |
| End_Date         | DATE      | License end date | No |
| load_date        | DATE      | Date record loaded | No |
| update_date      | DATE      | Date record updated | No |
| source_system    | STRING    | Source system identifier | No |

### 3.14 Go_Agg_Active_Users (Aggregate)
| Column Name      | Data Type | Description | PII |
|------------------|-----------|-------------|-----|
| Activity_Date    | DATE      | Date of activity | No |
| Active_User_Count| NUMBER    | Number of active users | No |
| Period_Type      | STRING    | Aggregation period (Daily/Weekly/Monthly) | No |
| load_date        | DATE      | Date record loaded | No |
| source_system    | STRING    | Source system identifier | No |

### 3.15 Go_Agg_Meeting_Minutes (Aggregate)
| Column Name      | Data Type | Description | PII |
|------------------|-----------|-------------|-----|
| Activity_Date    | DATE      | Date of activity | No |
| Total_Meeting_Minutes | NUMBER | Total meeting minutes | No |
| Period_Type      | STRING    | Aggregation period | No |
| load_date        | DATE      | Date record loaded | No |
| source_system    | STRING    | Source system identifier | No |

### 3.16 Go_Agg_Feature_Adoption (Aggregate)
| Column Name      | Data Type | Description | PII |
|------------------|-----------|-------------|-----|
| Feature_Name     | STRING    | Platform feature name | No |
| Adoption_Rate    | NUMBER    | Feature adoption rate (%) | No |
| Period_Type      | STRING    | Aggregation period | No |
| load_date        | DATE      | Date record loaded | No |
| source_system    | STRING    | Source system identifier | No |

### 3.17 Go_Agg_Ticket_Resolution (Aggregate)
| Column Name      | Data Type | Description | PII |
|------------------|-----------|-------------|-----|
| Ticket_Type      | STRING    | Support ticket category | No |
| Avg_Resolution_Time | NUMBER | Average ticket resolution time (hours) | No |
| Period_Type      | STRING    | Aggregation period | No |
| load_date        | DATE      | Date record loaded | No |
| source_system    | STRING    | Source system identifier | No |

### 3.18 Go_Agg_MRR (Aggregate)
| Column Name      | Data Type | Description | PII |
|------------------|-----------|-------------|-----|
| Activity_Month   | STRING    | Month of activity (YYYY-MM) | No |
| Monthly_Recurring_Revenue | NUMBER | Total MRR | No |
| load_date        | DATE      | Date record loaded | No |
| source_system    | STRING    | Source system identifier | No |

### 3.19 Go_Agg_License_Utilization (Aggregate)
| Column Name      | Data Type | Description | PII |
|------------------|-----------|-------------|-----|
| License_Type     | STRING    | License category | No |
| Utilization_Rate | NUMBER    | License utilization rate (%) | No |
| Period_Type      | STRING    | Aggregation period | No |
| load_date        | DATE      | Date record loaded | No |
| source_system    | STRING    | Source system identifier | No |

### 3.20 Go_Process_Audit_Log (Process Audit Table)
| Column Name      | Data Type | Description | PII |
|------------------|-----------|-------------|-----|
| process_name     | STRING    | Name of the ETL/process | No |
| execution_time   | TIMESTAMP | Time of execution | No |
| status           | STRING    | Status of process (Success/Failure) | No |
| record_count     | NUMBER    | Number of records processed | No |
| error_count      | NUMBER    | Number of errors encountered | No |
| audit_details    | STRING    | Additional audit info | No |
| load_date        | DATE      | Date record loaded | No |
| source_system    | STRING    | Source system identifier | No |

### 3.21 Go_Error_Audit_Log (Error Table)
| Column Name      | Data Type | Description | PII |
|------------------|-----------|-------------|-----|
| error_type       | STRING    | Type of error (Data Quality, Validation, Processing) | No |
| error_description| STRING    | Detailed error description | No |
| source_table     | STRING    | Table where error occurred | No |
| error_timestamp  | TIMESTAMP | Time error logged | No |
| process_audit_info| STRING   | Audit info from pipeline | No |
| status           | STRING    | Error status (Open, Resolved, In Progress) | No |
| load_date        | DATE      | Date record loaded | No |
| source_system    | STRING    | Source system identifier | No |

### 3.22 Go_Code_Resolution_Status (Code Table)
| Column Name      | Data Type | Description | PII |
|------------------|-----------|-------------|-----|
| Resolution_Status| STRING    | Ticket resolution status | No |
| Description      | STRING    | Status description | No |

### 3.23 Go_Code_Plan_Type (Code Table)
| Column Name      | Data Type | Description | PII |
|------------------|-----------|-------------|-----|
| Plan_Type        | STRING    | Subscription plan type | No |
| Description      | STRING    | Plan type description | No |

---

## 4. Conceptual Data Model Diagram (Tabular Form)
| Domain                        | Entities/Relationships |
|-------------------------------|-----------------------|
| Platform Usage & Adoption     | Users, Meetings, Participants, Feature Usage, Webinars |
| Service Reliability & Support | Support Tickets, Process Audit, Error Audit |
| Revenue & License Management  | Billing Events, Licenses |

---

## 5. ER Diagram Visualization (Block Format)
```
┌───────────────┐      ┌───────────────┐      ┌───────────────┐
│ Go_Dim_User  │◄─────│Go_Fact_Meeting│─────►│Go_Dim_Meeting │
└───────────────┘      └───────────────┘      └───────────────┘
        │                      │                     │
        │                      ▼                     ▼
        │              ┌───────────────┐      ┌───────────────┐
        │              │Go_Fact_Feature│─────►│Go_Dim_Feature │
        │              └───────────────┘      └───────────────┘
        │                      │
        ▼                      ▼
┌───────────────┐      ┌───────────────┐
│Go_Fact_Webinar│─────►│Go_Dim_Webinar │
└───────────────┘      └───────────────┘
        │
        ▼
┌───────────────┐      ┌───────────────┐
│Go_Fact_Support│─────►│Go_Dim_Ticket  │
└───────────────┘      └───────────────┘
        │
        ▼
┌───────────────┐      ┌───────────────┐
│Go_Fact_Billing│─────►│Go_Dim_Billing │
└───────────────┘      └───────────────┘
        │
        ▼
┌───────────────┐      ┌───────────────┐
│Go_Fact_License│─────►│Go_Dim_License │
└───────────────┘      └───────────────┘

Aggregate tables (Go_Agg_*) connect to respective fact tables for KPI reporting.
Go_Process_Audit_Log and Go_Error_Audit_Log connect to all tables for audit/error tracking.
Code tables (Go_Code_*) referenced by dimensions/facts for consistent values.
```

---

## 6. apiCost
- apiCost: 2.00 USD

---

## 7. Key Design Decisions & Alignment
- All tables use 'Go_' prefix for Gold layer clarity.
- SCD Type 2 for Go_Dim_User to track user profile changes over time.
- SCD Type 1 for other dimensions for simplicity and performance.
- No primary keys, foreign keys, or ID fields included, per requirements.
- Metadata columns (load_date, update_date, source_system) included for lineage and governance.
- PII classification provided for compliance.
- Aggregate tables support required KPIs.
- Process audit and error tables included for operational monitoring and validation.
- Code tables ensure consistent values for status and plan types.
- Model is fully aligned with Silver layer structure and business domains.

---
