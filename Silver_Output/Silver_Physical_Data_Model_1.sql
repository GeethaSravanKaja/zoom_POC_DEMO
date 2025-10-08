_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Silver Layer Physical Data Model for Zoom Platform Analytics System supporting medallion architecture
## *Version*: 1 
## *Updated on*: 
_____________________________________________

-- 1. Silver Layer DDL Scripts

-- 1.1 Si_Users Table
CREATE TABLE IF NOT EXISTS Silver.si_users (
    user_id STRING,
    user_name STRING,
    email STRING,
    company STRING,
    plan_type STRING,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING,
    load_date DATE,
    update_date DATE
);

-- 1.2 Si_Meetings Table
CREATE TABLE IF NOT EXISTS Silver.si_meetings (
    meeting_id STRING,
    host_id STRING,
    meeting_topic STRING,
    start_time TIMESTAMP_NTZ,
    end_time TIMESTAMP_NTZ,
    duration_minutes NUMBER,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING,
    load_date DATE,
    update_date DATE
);

-- 1.3 Si_Participants Table
CREATE TABLE IF NOT EXISTS Silver.si_participants (
    participant_id STRING,
    meeting_id STRING,
    user_id STRING,
    join_time TIMESTAMP_NTZ,
    leave_time TIMESTAMP_NTZ,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING,
    load_date DATE,
    update_date DATE
);

-- 1.4 Si_Feature_Usage Table
CREATE TABLE IF NOT EXISTS Silver.si_feature_usage (
    usage_id STRING,
    meeting_id STRING,
    feature_name STRING,
    usage_count NUMBER,
    usage_date DATE,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING,
    load_date DATE,
    update_date DATE
);

-- 1.5 Si_Webinars Table
CREATE TABLE IF NOT EXISTS Silver.si_webinars (
    webinar_id STRING,
    host_id STRING,
    webinar_topic STRING,
    start_time TIMESTAMP_NTZ,
    end_time TIMESTAMP_NTZ,
    registrants NUMBER,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING,
    load_date DATE,
    update_date DATE
);

-- 1.6 Si_Support_Tickets Table
CREATE TABLE IF NOT EXISTS Silver.si_support_tickets (
    ticket_id STRING,
    user_id STRING,
    ticket_type STRING,
    resolution_status STRING,
    open_date DATE,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING,
    load_date DATE,
    update_date DATE
);

-- 1.7 Si_Licenses Table
CREATE TABLE IF NOT EXISTS Silver.si_licenses (
    license_id STRING,
    license_type STRING,
    assigned_to_user_id STRING,
    start_date DATE,
    end_date DATE,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING,
    load_date DATE,
    update_date DATE
);

-- 1.8 Si_Billing_Events Table
CREATE TABLE IF NOT EXISTS Silver.si_billing_events (
    event_id STRING,
    user_id STRING,
    event_type STRING,
    amount NUMBER(10,2),
    event_date DATE,
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING,
    load_date DATE,
    update_date DATE
);

-- 1.9 Si_Error_Data Table
CREATE TABLE IF NOT EXISTS Silver.si_error_data (
    error_id NUMBER,
    error_type STRING,
    error_description STRING,
    source_table STRING,
    error_timestamp TIMESTAMP_NTZ,
    process_audit_info STRING,
    status STRING,
    load_date DATE,
    update_date DATE,
    source_system STRING
);

-- 1.10 Si_Audit Table
CREATE TABLE IF NOT EXISTS Silver.si_audit (
    execution_id STRING,
    pipeline_name STRING,
    start_time TIMESTAMP_NTZ,
    end_time TIMESTAMP_NTZ,
    status STRING,
    error_message STRING,
    load_date DATE,
    update_date DATE,
    source_system STRING
);

-- 1.11 Update DDL Script (Schema Evolution Example)
-- Add new column to Si_Users (example)
ALTER TABLE Silver.si_users ADD COLUMN IF NOT EXISTS user_status STRING;

-- 2. API Cost
-- apiCost: 0.000123

-- 3. Assumptions and Design Decisions
-- 1. All columns from Bronze layer are retained in Silver layer for full lineage.
-- 2. Metadata columns (load_date, update_date, source_system) added to every table.
-- 3. No constraints, foreign keys, or primary keys are defined (Snowflake best practice).
-- 4. All data types are Snowflake-supported (STRING, NUMBER, DATE, TIMESTAMP_NTZ).
-- 5. Error Data Table and Audit Table are included for compliance and monitoring.
-- 6. Storage is Snowflake native micro-partitioned.
-- 7. DDL scripts are organized for easy implementation in Snowflake.
-- 8. Update DDL script included for schema evolution.
-- 9. No clustering keys defined as no explicit performance requirement provided.
-- 10. All scripts use CREATE TABLE IF NOT EXISTS for safe deployment.
