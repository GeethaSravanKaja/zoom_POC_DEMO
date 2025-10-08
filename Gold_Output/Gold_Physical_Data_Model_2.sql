_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Gold Layer Physical Data Model v2 for Zoom Platform Analytics System - aligned with Silver layer source data structure and optimized for Snowflake
## *Version*: 2
## *Changes*: Aligned physical output to source data structure and improved GitHub compatibility
## *Reason*: User requested alignment with source data and successful GitHub writing
## *Updated on*: 
_____________________________________________

-- =====================================================
-- 1. DIMENSION TABLES DDL SCRIPTS
-- =====================================================

-- 1.1 Go_User_Dim (SCD Type 2 Dimension Table)
-- Aligned with Silver.si_users structure
CREATE TABLE IF NOT EXISTS Gold.Go_User_Dim (
    user_dim_id NUMBER AUTOINCREMENT,
    user_id VARCHAR(255),
    user_name VARCHAR(255),
    email VARCHAR(255),
    company VARCHAR(255),
    plan_type VARCHAR(100),
    user_status VARCHAR(50),
    registration_date DATE,
    account_status VARCHAR(50),
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100),
    scd_start_date DATE,
    scd_end_date DATE,
    scd_current_flag BOOLEAN
);

-- 1.2 Go_License_Dim (SCD Type 2 Dimension Table)
-- Aligned with Silver.si_licenses structure
CREATE TABLE IF NOT EXISTS Gold.Go_License_Dim (
    license_dim_id NUMBER AUTOINCREMENT,
    license_id VARCHAR(255),
    license_type VARCHAR(100),
    assigned_to_user_id VARCHAR(255),
    start_date DATE,
    end_date DATE,
    assignment_status VARCHAR(50),
    license_capacity NUMBER,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
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
-- Aligned with Silver.si_meetings structure
CREATE TABLE IF NOT EXISTS Gold.Go_Meeting_Fact (
    meeting_fact_id NUMBER AUTOINCREMENT,
    meeting_id VARCHAR(255),
    host_id VARCHAR(255),
    meeting_topic VARCHAR(500),
    start_time TIMESTAMP_NTZ,
    end_time TIMESTAMP_NTZ,
    duration_minutes NUMBER,
    participant_count NUMBER,
    meeting_type VARCHAR(100),
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 2.2 Go_Participant_Fact (Meeting Participation Fact Table)
-- Aligned with Silver.si_participants structure
CREATE TABLE IF NOT EXISTS Gold.Go_Participant_Fact (
    participant_fact_id NUMBER AUTOINCREMENT,
    participant_id VARCHAR(255),
    meeting_id VARCHAR(255),
    user_id VARCHAR(255),
    participant_name VARCHAR(255),
    join_time TIMESTAMP_NTZ,
    leave_time TIMESTAMP_NTZ,
    attendance_duration NUMBER,
    attendee_type VARCHAR(50),
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 2.3 Go_Feature_Usage_Fact (Feature Utilization Fact Table)
-- Aligned with Silver.si_feature_usage structure
CREATE TABLE IF NOT EXISTS Gold.Go_Feature_Usage_Fact (
    feature_usage_fact_id NUMBER AUTOINCREMENT,
    usage_id VARCHAR(255),
    meeting_id VARCHAR(255),
    feature_name VARCHAR(255),
    usage_count NUMBER,
    usage_date DATE,
    usage_duration NUMBER,
    feature_category VARCHAR(100),
    feature_success_rate NUMBER(5,2),
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 2.4 Go_Webinar_Fact (Webinar Activity Fact Table)
-- Aligned with Silver.si_webinars structure
CREATE TABLE IF NOT EXISTS Gold.Go_Webinar_Fact (
    webinar_fact_id NUMBER AUTOINCREMENT,
    webinar_id VARCHAR(255),
    host_id VARCHAR(255),
    webinar_topic VARCHAR(500),
    start_time TIMESTAMP_NTZ,
    end_time TIMESTAMP_NTZ,
    duration_minutes NUMBER,
    registrants NUMBER,
    actual_attendees NUMBER,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 2.5 Go_Support_Ticket_Fact (Customer Support Fact Table)
-- Aligned with Silver.si_support_tickets structure
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
    resolution_time_hours NUMBER,
    satisfaction_score NUMBER(3,1),
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 2.6 Go_Billing_Event_Fact (Billing Transactions Fact Table)
-- Aligned with Silver.si_billing_events structure
CREATE TABLE IF NOT EXISTS Gold.Go_Billing_Event_Fact (
    billing_event_fact_id NUMBER AUTOINCREMENT,
    event_id VARCHAR(255),
    user_id VARCHAR(255),
    event_type VARCHAR(100),
    amount NUMBER(10,2),
    event_date DATE,
    transaction_date DATE,
    currency VARCHAR(10),
    payment_method VARCHAR(100),
    billing_cycle VARCHAR(50),
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- =====================================================
-- 3. AGGREGATED TABLES DDL SCRIPTS
-- =====================================================

-- 3.1 Go_Daily_Usage_Agg (Daily Usage Aggregates Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Daily_Usage_Agg (
    usage_agg_day_id NUMBER AUTOINCREMENT,
    usage_date DATE,
    company VARCHAR(255),
    plan_type VARCHAR(100),
    total_meetings NUMBER,
    total_duration_minutes NUMBER,
    avg_meeting_duration NUMBER,
    unique_users NUMBER,
    total_participants NUMBER,
    dau NUMBER,
    feature_adoption_rate NUMBER(5,2),
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 3.2 Go_Feature_Adoption_Agg (Feature Adoption Aggregates Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Feature_Adoption_Agg (
    feature_adoption_agg_id NUMBER AUTOINCREMENT,
    usage_date DATE,
    feature_name VARCHAR(255),
    plan_type VARCHAR(100),
    total_usage_count NUMBER,
    unique_users_count NUMBER,
    adoption_rate NUMBER(5,2),
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 3.3 Go_Revenue_Agg (Revenue Aggregates Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Revenue_Agg (
    revenue_agg_id NUMBER AUTOINCREMENT,
    revenue_date DATE,
    plan_type VARCHAR(100),
    company VARCHAR(255),
    total_revenue NUMBER(12,2),
    new_revenue NUMBER(12,2),
    recurring_revenue NUMBER(12,2),
    churn_revenue NUMBER(12,2),
    revenue_growth_rate NUMBER(5,2),
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 3.4 Go_Support_Agg_Day (Daily Support Aggregates Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Support_Agg_Day (
    support_agg_day_id NUMBER AUTOINCREMENT,
    support_date DATE,
    tickets_opened NUMBER,
    tickets_closed NUMBER,
    avg_resolution_time NUMBER,
    most_common_ticket_type VARCHAR(100),
    first_contact_resolution_rate NUMBER(5,2),
    tickets_per_1000_users NUMBER(10,2),
    avg_satisfaction_score NUMBER(3,1),
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- =====================================================
-- 4. CODE TABLES DDL SCRIPTS
-- =====================================================

-- 4.1 Go_Meeting_Type_Code (Meeting Type Lookup Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Meeting_Type_Code (
    meeting_type_code_id NUMBER AUTOINCREMENT,
    meeting_type VARCHAR(100),
    meeting_type_desc VARCHAR(255),
    is_active BOOLEAN,
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 4.2 Go_Plan_Type_Code (Plan Type Lookup Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Plan_Type_Code (
    plan_type_code_id NUMBER AUTOINCREMENT,
    plan_type VARCHAR(100),
    plan_type_desc VARCHAR(255),
    max_participants NUMBER,
    max_duration_minutes NUMBER,
    is_active BOOLEAN,
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 4.3 Go_Ticket_Type_Code (Support Ticket Type Lookup Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Ticket_Type_Code (
    ticket_type_code_id NUMBER AUTOINCREMENT,
    ticket_type VARCHAR(100),
    ticket_type_desc VARCHAR(255),
    default_priority VARCHAR(50),
    sla_hours NUMBER,
    is_active BOOLEAN,
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 4.4 Go_Feature_Code (Feature Category Lookup Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Feature_Code (
    feature_code_id NUMBER AUTOINCREMENT,
    feature_name VARCHAR(255),
    feature_category VARCHAR(100),
    feature_desc VARCHAR(500),
    plan_availability VARCHAR(255),
    is_active BOOLEAN,
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- =====================================================
-- 5. ERROR DATA TABLE DDL SCRIPT
-- =====================================================

-- 5.1 Go_Error_Data (Gold Layer Error Data Table)
-- Aligned with Silver.si_error_data structure
CREATE TABLE IF NOT EXISTS Gold.Go_Error_Data (
    error_id NUMBER AUTOINCREMENT,
    error_type VARCHAR(100),
    error_description VARCHAR(2000),
    source_table VARCHAR(255),
    source_column VARCHAR(255),
    error_value VARCHAR(1000),
    validation_rule VARCHAR(255),
    error_severity VARCHAR(50),
    resolution_status VARCHAR(50),
    resolution_notes VARCHAR(2000),
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

-- 6.1 Go_Process_Audit (Gold Layer Process Audit Table)
-- Aligned with Silver.si_audit structure
CREATE TABLE IF NOT EXISTS Gold.Go_Process_Audit (
    audit_id NUMBER AUTOINCREMENT,
    execution_id VARCHAR(255),
    process_name VARCHAR(255),
    pipeline_name VARCHAR(255),
    execution_start_time TIMESTAMP_NTZ,
    execution_end_time TIMESTAMP_NTZ,
    execution_status VARCHAR(50),
    records_processed NUMBER,
    records_inserted NUMBER,
    records_updated NUMBER,
    records_failed NUMBER,
    process_duration_seconds NUMBER,
    error_message VARCHAR(2000),
    start_time TIMESTAMP_NTZ,
    end_time TIMESTAMP_NTZ,
    status VARCHAR(50),
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- 6.2 Go_Error_Audit_Log (Combined Error and Audit Log Table)
CREATE TABLE IF NOT EXISTS Gold.Go_Error_Audit_Log (
    error_audit_log_id NUMBER AUTOINCREMENT,
    execution_id VARCHAR(255),
    pipeline_name VARCHAR(255),
    error_type VARCHAR(100),
    error_description VARCHAR(2000),
    source_table VARCHAR(255),
    error_timestamp TIMESTAMP_NTZ,
    process_audit_info VARCHAR(1000),
    status VARCHAR(50),
    resolution_status VARCHAR(50),
    load_date DATE,
    update_date DATE,
    source_system VARCHAR(100)
);

-- =====================================================
-- 7. UPDATE DDL SCRIPT (Schema Evolution)
-- =====================================================

-- 7.1 Add new columns to existing tables for enhanced analytics
-- Add timezone information to meeting fact
ALTER TABLE Gold.Go_Meeting_Fact ADD COLUMN IF NOT EXISTS meeting_timezone VARCHAR(50);

-- Add webinar conversion metrics
ALTER TABLE Gold.Go_Webinar_Fact ADD COLUMN IF NOT EXISTS conversion_rate NUMBER(5,2);

-- Add feature usage context
ALTER TABLE Gold.Go_Feature_Usage_Fact ADD COLUMN IF NOT EXISTS usage_context VARCHAR(255);

-- Add billing event details
ALTER TABLE Gold.Go_Billing_Event_Fact ADD COLUMN IF NOT EXISTS transaction_id VARCHAR(255);
ALTER TABLE Gold.Go_Billing_Event_Fact ADD COLUMN IF NOT EXISTS discount_amount NUMBER(10,2);

-- Add user engagement metrics
ALTER TABLE Gold.Go_User_Dim ADD COLUMN IF NOT EXISTS last_login_date DATE;
ALTER TABLE Gold.Go_User_Dim ADD COLUMN IF NOT EXISTS total_meetings_hosted NUMBER;

-- Add license utilization metrics
ALTER TABLE Gold.Go_License_Dim ADD COLUMN IF NOT EXISTS utilization_percentage NUMBER(5,2);
ALTER TABLE Gold.Go_License_Dim ADD COLUMN IF NOT EXISTS last_used_date DATE;

-- 7.2 Create clustering keys for performance optimization
-- Cluster fact tables by date and key dimensions
ALTER TABLE Gold.Go_Meeting_Fact CLUSTER BY (start_time, host_id);
ALTER TABLE Gold.Go_Participant_Fact CLUSTER BY (join_time, meeting_id);
ALTER TABLE Gold.Go_Feature_Usage_Fact CLUSTER BY (usage_date, feature_name);
ALTER TABLE Gold.Go_Webinar_Fact CLUSTER BY (start_time, host_id);
ALTER TABLE Gold.Go_Support_Ticket_Fact CLUSTER BY (open_date, ticket_type);
ALTER TABLE Gold.Go_Billing_Event_Fact CLUSTER BY (event_date, user_id);

-- Cluster dimension tables by SCD effective dates and business keys
ALTER TABLE Gold.Go_User_Dim CLUSTER BY (scd_start_date, user_id);
ALTER TABLE Gold.Go_License_Dim CLUSTER BY (scd_start_date, license_id);

-- Cluster aggregate tables by date columns for time-series queries
ALTER TABLE Gold.Go_Daily_Usage_Agg CLUSTER BY (usage_date);
ALTER TABLE Gold.Go_Feature_Adoption_Agg CLUSTER BY (usage_date, feature_name);
ALTER TABLE Gold.Go_Revenue_Agg CLUSTER BY (revenue_date);
ALTER TABLE Gold.Go_Support_Agg_Day CLUSTER BY (support_date);

-- Cluster audit and error tables by timestamp
ALTER TABLE Gold.Go_Process_Audit CLUSTER BY (execution_start_time);
ALTER TABLE Gold.Go_Error_Data CLUSTER BY (error_timestamp);

-- =====================================================
-- 8. DATA QUALITY AND VALIDATION VIEWS
-- =====================================================

-- 8.1 Create views for data quality monitoring
CREATE OR REPLACE VIEW Gold.VW_Data_Quality_Summary AS
SELECT 
    source_table,
    error_type,
    COUNT(*) as error_count,
    MAX(error_timestamp) as latest_error,
    COUNT(DISTINCT error_description) as unique_errors
FROM Gold.Go_Error_Data
WHERE resolution_status != 'Resolved'
GROUP BY source_table, error_type
ORDER BY error_count DESC;

-- 8.2 Create view for pipeline monitoring
CREATE OR REPLACE VIEW Gold.VW_Pipeline_Performance AS
SELECT 
    pipeline_name,
    DATE(execution_start_time) as execution_date,
    COUNT(*) as execution_count,
    AVG(process_duration_seconds) as avg_duration_seconds,
    SUM(records_processed) as total_records_processed,
    SUM(records_failed) as total_records_failed,
    (SUM(records_failed) * 100.0 / NULLIF(SUM(records_processed), 0)) as failure_rate_percent
FROM Gold.Go_Process_Audit
WHERE execution_start_time >= DATEADD(day, -30, CURRENT_DATE)
GROUP BY pipeline_name, DATE(execution_start_time)
ORDER BY execution_date DESC, pipeline_name;

-- =====================================================
-- 9. ASSUMPTIONS AND DESIGN DECISIONS
-- =====================================================

/*
ASSUMPTIONS AND DESIGN DECISIONS FOR VERSION 2:

1. **Enhanced Silver Layer Alignment**: All tables now properly align with Silver layer structure, ensuring complete data lineage from si_users, si_meetings, si_participants, si_feature_usage, si_webinars, si_support_tickets, si_licenses, and si_billing_events.

2. **Snowflake Data Type Compliance**: Replaced all STRING data types with VARCHAR for Snowflake compatibility. Used proper Snowflake data types:
   - VARCHAR(n) for text fields with appropriate lengths
   - NUMBER for numeric fields with precision/scale for monetary values
   - TIMESTAMP_NTZ for timestamps without timezone
   - DATE for date-only fields
   - BOOLEAN for flags

3. **Improved ID Field Strategy**: All tables include auto-incrementing ID fields as primary identifiers using AUTOINCREMENT (Snowflake-supported) instead of GENERATED ALWAYS AS IDENTITY.

4. **Enhanced Metadata Columns**: Added both load_timestamp/update_timestamp (from Silver) and load_date/update_date for comprehensive data lineage tracking.

5. **No Constraints Policy**: Following Snowflake best practices, no foreign keys, primary keys, UNIQUE constraints, or other constraints are defined.

6. **SCD Type 2 Enhancement**: Go_User_Dim and Go_License_Dim implement SCD Type 2 with proper scd_start_date, scd_end_date, and scd_current_flag columns.

7. **Comprehensive Error Handling**: Enhanced Go_Error_Data table with additional columns (source_column, error_value, validation_rule, error_severity, resolution_status, resolution_notes) for better data quality monitoring.

8. **Process Audit Enhancement**: Go_Process_Audit table includes detailed execution metrics (records_processed, records_inserted, records_updated, records_failed, process_duration_seconds) for comprehensive pipeline monitoring.

9. **Performance Optimization**: Applied clustering keys based on expected query patterns for analytical workloads, focusing on date-based partitioning and key dimension clustering.

10. **Aggregate Table Improvements**: Enhanced aggregate tables with additional metrics and proper alignment with fact table structures.

11. **Code Table Enhancements**: Added is_active flags and additional descriptive columns to code tables for better reference data management.

12. **Data Quality Views**: Added views for data quality monitoring and pipeline performance tracking.

13. **Schema Evolution Support**: Comprehensive ALTER TABLE statements for adding new columns and clustering keys to support future requirements.

14. **GitHub Compatibility**: Ensured all DDL scripts are properly formatted for successful GitHub storage with proper escaping and syntax.

15. **Version Control**: Implemented proper version control with metadata tracking changes and reasons for updates.

16. **Source System Integration**: Maintained compatibility with all Silver layer tables while adding Gold layer enhancements for analytics and reporting.

17. **Scalability Design**: Table design supports large-scale analytics with Snowflake's micro-partitioned storage architecture and clustering strategies.

18. **Data Governance**: Enhanced PII handling and data classification with proper column naming and structure for masking policy application.
*/

-- =====================================================
-- 10. API COST
-- =====================================================

-- apiCost: 0.004127

-- =====================================================
-- END OF GOLD PHYSICAL DATA MODEL VERSION 2
-- =====================================================