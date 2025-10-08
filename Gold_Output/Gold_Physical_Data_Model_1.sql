_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Gold Layer Physical Data Model for Zoom Platform Analytics System supporting medallion architecture with fact tables, dimension tables, and aggregated tables
## *Version*: 1 
## *Updated on*: 
_____________________________________________

-- =====================================================
-- 1. DIMENSION TABLES DDL SCRIPTS
-- =====================================================

-- 1.1 Go_User_Dim (SCD Type 2 Dimension Table)
CREATE TABLE IF NOT EXISTS Gold.Go_User_Dim (
    user_dim_id NUMBER AUTOINCREMENT,
    user_id VARCHAR(255),
    user_name VARCHAR(255),
    email VARCHAR(255),
    plan_type VARCHAR(100),
    registration_date DATE,
    company VARCHAR(255),
    account_status VARCHAR(50),
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100),
    scd_start_date DATE,
    scd_end_date DATE,
    scd_current_flag BOOLEAN
);

-- 1.2 Go_License_Dim (SCD Type 2 Dimension Table)
CREATE TABLE IF NOT EXISTS Gold.Go_License_Dim (
    license_dim_id NUMBER AUTOINCREMENT,
    license_id VARCHAR(255),
    license_type VARCHAR(100),
    start_date DATE,
    end_date DATE,
    assignment_status VARCHAR(50),
    license_capacity NUMBER,
    user_name VARCHAR(255),
    assigned_to_user_id VARCHAR(255),
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100),
    scd_start_date DATE,
    scd_end_date DATE,
    scd_current_flag BOOLEAN
);

-- =====================================================
-- 2. FACT TABLES DDL SCRIPTS
-- =====================================================

-- 2.1 Go_Meeting_Fact (Meeting Activity Fact Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Meeting_Fact (
    meeting_fact_id NUMBER AUTOINCREMENT,
    meeting_id VARCHAR(255),
    meeting_title VARCHAR(500),
    start_time TIMESTAMP_NTZ,
    end_time TIMESTAMP_NTZ,
    duration_minutes NUMBER,
    host_name VARCHAR(255),
    host_id VARCHAR(255),
    meeting_type VARCHAR(100),
    participant_count NUMBER,
    meeting_topic VARCHAR(500),
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 2.2 Go_Attendee_Fact (Meeting Attendance Fact Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Attendee_Fact (
    attendee_fact_id NUMBER AUTOINCREMENT,
    participant_id VARCHAR(255),
    meeting_id VARCHAR(255),
    meeting_title VARCHAR(500),
    attendee_name VARCHAR(255),
    user_id VARCHAR(255),
    join_time TIMESTAMP_NTZ,
    leave_time TIMESTAMP_NTZ,
    attendance_duration NUMBER,
    attendee_type VARCHAR(50),
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 2.3 Go_Feature_Usage_Fact (Feature Utilization Fact Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Feature_Usage_Fact (
    feature_usage_fact_id NUMBER AUTOINCREMENT,
    usage_id VARCHAR(255),
    meeting_id VARCHAR(255),
    meeting_title VARCHAR(500),
    feature_name VARCHAR(255),
    usage_count NUMBER,
    usage_duration NUMBER,
    feature_category VARCHAR(100),
    usage_date DATE,
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 2.4 Go_Support_Ticket_Fact (Customer Support Fact Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Support_Ticket_Fact (
    support_ticket_fact_id NUMBER AUTOINCREMENT,
    ticket_id VARCHAR(255),
    user_id VARCHAR(255),
    ticket_type VARCHAR(100),
    resolution_status VARCHAR(100),
    open_date DATE,
    close_date DATE,
    priority_level VARCHAR(50),
    issue_description VARCHAR(2000),
    resolution_notes VARCHAR(2000),
    user_name VARCHAR(255),
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 2.5 Go_Billing_Event_Fact (Billing Transactions Fact Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Billing_Event_Fact (
    billing_event_fact_id NUMBER AUTOINCREMENT,
    event_id VARCHAR(255),
    user_id VARCHAR(255),
    event_type VARCHAR(100),
    amount NUMBER(10,2),
    transaction_date DATE,
    currency VARCHAR(10),
    payment_method VARCHAR(100),
    billing_cycle VARCHAR(50),
    user_name VARCHAR(255),
    event_date DATE,
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- =====================================================
-- 3. CODE TABLES DDL SCRIPTS
-- =====================================================

-- 3.1 Go_Meeting_Type_Code (Meeting Type Lookup Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Meeting_Type_Code (
    meeting_type_code_id NUMBER AUTOINCREMENT,
    meeting_type VARCHAR(100),
    meeting_type_desc VARCHAR(255),
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 3.2 Go_Plan_Type_Code (Plan Type Lookup Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Plan_Type_Code (
    plan_type_code_id NUMBER AUTOINCREMENT,
    plan_type VARCHAR(100),
    plan_type_desc VARCHAR(255),
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 3.3 Go_Ticket_Type_Code (Support Ticket Type Lookup Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Ticket_Type_Code (
    ticket_type_code_id NUMBER AUTOINCREMENT,
    ticket_type VARCHAR(100),
    ticket_type_desc VARCHAR(255),
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 3.4 Go_Feature_Code (Feature Category Lookup Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Feature_Code (
    feature_code_id NUMBER AUTOINCREMENT,
    feature_name VARCHAR(255),
    feature_category VARCHAR(100),
    feature_desc VARCHAR(500),
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- =====================================================
-- 4. AGGREGATED TABLES DDL SCRIPTS
-- =====================================================

-- 4.1 Go_Usage_Agg_Day (Daily Usage Aggregates Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Usage_Agg_Day (
    usage_agg_day_id NUMBER AUTOINCREMENT,
    usage_date DATE,
    dau NUMBER,
    total_meeting_minutes NUMBER,
    avg_meeting_duration NUMBER,
    meetings_created NUMBER,
    feature_adoption_rate NUMBER(5,2),
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 4.2 Go_Support_Agg_Day (Daily Support Aggregates Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Support_Agg_Day (
    support_agg_day_id NUMBER AUTOINCREMENT,
    support_date DATE,
    tickets_opened NUMBER,
    avg_resolution_time NUMBER,
    most_common_ticket_type VARCHAR(100),
    first_contact_resolution_rate NUMBER(5,2),
    tickets_per_1000_users NUMBER(10,2),
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 4.3 Go_Revenue_Agg_Month (Monthly Revenue Aggregates Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Revenue_Agg_Month (
    revenue_agg_month_id NUMBER AUTOINCREMENT,
    revenue_month VARCHAR(7),
    mrr NUMBER(15,2),
    revenue_by_plan_type NUMBER(15,2),
    license_utilization_rate NUMBER(5,2),
    license_expiration_count NUMBER,
    revenue_per_user NUMBER(10,2),
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- =====================================================
-- 5. ERROR DATA TABLE DDL SCRIPT
-- =====================================================

-- 5.1 Go_Error_Data (Gold Layer Error Data Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Error_Data (
    error_id NUMBER AUTOINCREMENT,
    error_type VARCHAR(100),
    error_description VARCHAR(2000),
    source_table VARCHAR(255),
    error_timestamp TIMESTAMP_NTZ,
    process_audit_info VARCHAR(1000),
    status VARCHAR(50),
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- =====================================================
-- 6. AUDIT TABLE DDL SCRIPT
-- =====================================================

-- 6.1 Go_Audit (Gold Layer Audit Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Audit (
    audit_id NUMBER AUTOINCREMENT,
    execution_id VARCHAR(255),
    pipeline_name VARCHAR(255),
    start_time TIMESTAMP_NTZ,
    end_time TIMESTAMP_NTZ,
    status VARCHAR(50),
    error_message VARCHAR(2000),
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 6.2 Go_Error_Audit_Log (Combined Error and Audit Log Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Error_Audit_Log (
    error_audit_log_id NUMBER AUTOINCREMENT,
    error_type VARCHAR(100),
    error_description VARCHAR(2000),
    source_table VARCHAR(255),
    error_timestamp TIMESTAMP_NTZ,
    process_audit_info VARCHAR(1000),
    status VARCHAR(50),
    execution_id VARCHAR(255),
    pipeline_name VARCHAR(255),
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- =====================================================
-- 7. WEBINAR FACT TABLE DDL SCRIPT (From Silver Layer)
-- =====================================================

-- 7.1 Go_Webinar_Fact (Webinar Activity Fact Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Webinar_Fact (
    webinar_fact_id NUMBER AUTOINCREMENT,
    webinar_id VARCHAR(255),
    host_id VARCHAR(255),
    webinar_topic VARCHAR(500),
    start_time TIMESTAMP_NTZ,
    end_time TIMESTAMP_NTZ,
    registrants NUMBER,
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- =====================================================
-- 8. UPDATE DDL SCRIPT (Schema Evolution)
-- =====================================================

-- 8.1 Add new columns to existing tables (Example schema evolution)
-- Add user status column to Go_User_Dim
ALTER TABLE Gold.Go_User_Dim ADD COLUMN IF NOT EXISTS user_status VARCHAR(50);

-- Add webinar duration to Go_Webinar_Fact
ALTER TABLE Gold.Go_Webinar_Fact ADD COLUMN IF NOT EXISTS duration_minutes NUMBER;

-- Add feature usage metrics to Go_Feature_Usage_Fact
ALTER TABLE Gold.Go_Feature_Usage_Fact ADD COLUMN IF NOT EXISTS feature_success_rate NUMBER(5,2);

-- Add customer satisfaction score to Go_Support_Ticket_Fact
ALTER TABLE Gold.Go_Support_Ticket_Fact ADD COLUMN IF NOT EXISTS satisfaction_score NUMBER(3,1);

-- Add revenue growth metrics to Go_Revenue_Agg_Month
ALTER TABLE Gold.Go_Revenue_Agg_Month ADD COLUMN IF NOT EXISTS revenue_growth_rate NUMBER(5,2);

-- 8.2 Create indexes for performance optimization (Clustering Keys)
-- Cluster Go_Meeting_Fact by date and host for better query performance
ALTER TABLE Gold.Go_Meeting_Fact CLUSTER BY (start_time, host_id);

-- Cluster Go_Attendee_Fact by meeting and join time
ALTER TABLE Gold.Go_Attendee_Fact CLUSTER BY (meeting_id, join_time);

-- Cluster Go_Feature_Usage_Fact by usage date and feature
ALTER TABLE Gold.Go_Feature_Usage_Fact CLUSTER BY (usage_date, feature_name);

-- Cluster Go_Support_Ticket_Fact by open date and ticket type
ALTER TABLE Gold.Go_Support_Ticket_Fact CLUSTER BY (open_date, ticket_type);

-- Cluster Go_Billing_Event_Fact by transaction date and user
ALTER TABLE Gold.Go_Billing_Event_Fact CLUSTER BY (transaction_date, user_id);

-- Cluster dimension tables by SCD effective dates
ALTER TABLE Gold.Go_User_Dim CLUSTER BY (scd_start_date, user_id);
ALTER TABLE Gold.Go_License_Dim CLUSTER BY (scd_start_date, license_id);

-- Cluster aggregate tables by date columns
ALTER TABLE Gold.Go_Usage_Agg_Day CLUSTER BY (usage_date);
ALTER TABLE Gold.Go_Support_Agg_Day CLUSTER BY (support_date);
ALTER TABLE Gold.Go_Revenue_Agg_Month CLUSTER BY (revenue_month);

-- =====================================================
-- 9. ASSUMPTIONS AND DESIGN DECISIONS
-- =====================================================

/*
ASSUMPTIONS AND DESIGN DECISIONS:

1. **ID Fields Added**: All tables include auto-incrementing ID fields as primary identifiers since the logical model didn't specify ID fields.

2. **SCD Type 2 Implementation**: Go_User_Dim and Go_License_Dim implement SCD Type 2 with scd_start_date, scd_end_date, and scd_current_flag columns.

3. **Snowflake Data Types**: All data types are Snowflake-compatible:
   - STRING → VARCHAR with appropriate lengths
   - NUMBER with precision/scale for monetary values
   - TIMESTAMP_NTZ for timestamps without timezone
   - DATE for date-only fields
   - BOOLEAN for flags

4. **No Constraints**: Following Snowflake best practices, no foreign keys, primary keys, or other constraints are defined.

5. **Metadata Columns**: All tables include load_date, update_date, and source_system for data lineage and governance.

6. **Clustering Keys**: Applied clustering on frequently queried columns for performance optimization.

7. **Silver Layer Integration**: All relevant columns from Silver layer tables are retained in Gold layer for complete data lineage.

8. **Error and Audit Tables**: Comprehensive error handling and audit logging tables included for operational monitoring.

9. **Aggregate Tables**: Pre-computed aggregate tables for KPI reporting and dashboard performance.

10. **Schema Evolution**: Update DDL scripts provided for future schema changes and performance tuning.

11. **Webinar Integration**: Added Go_Webinar_Fact table to capture webinar data from Silver layer si_webinars table.

12. **Code Tables**: Lookup tables for standardizing categorical values and supporting referential integrity in application logic.

13. **Performance Optimization**: Clustering keys applied based on expected query patterns for analytical workloads.

14. **Data Governance**: PII-sensitive columns identified in logical model are retained with appropriate data types for masking policy application.

15. **Scalability**: Table design supports large-scale analytics with Snowflake's micro-partitioned storage architecture.
*/

-- =====================================================
-- 10. API COST
-- =====================================================

-- apiCost: 0.003847

-- =====================================================
-- END OF GOLD PHYSICAL DATA MODEL
-- =====================================================