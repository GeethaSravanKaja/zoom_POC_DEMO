_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Bronze Layer Physical Data Model for Zoom Platform Analytics System aligned with source process tables
## *Version*: 2 
## *Updated on*: 
## *Changes*: Aligned with source process tables
## *Reason*: Updated to match source table structure with all ID fields and Snowflake data types
_____________________________________________

# Bronze Layer Physical Data Model - Zoom Platform Analytics System

## 1. Bronze Layer DDL Scripts

### 1.1 Users Table
```sql
CREATE TABLE IF NOT EXISTS Bronze.bz_users (
    user_id STRING,
    user_name STRING,
    email STRING,
    company STRING,
    plan_type STRING,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);
```

### 1.2 Meetings Table
```sql
CREATE TABLE IF NOT EXISTS Bronze.bz_meetings (
    meeting_id STRING,
    host_id STRING,
    meeting_topic STRING,
    start_time TIMESTAMP_NTZ,
    end_time TIMESTAMP_NTZ,
    duration_minutes NUMBER,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);
```

### 1.3 Participants Table
```sql
CREATE TABLE IF NOT EXISTS Bronze.bz_participants (
    participant_id STRING,
    meeting_id STRING,
    user_id STRING,
    join_time TIMESTAMP_NTZ,
    leave_time TIMESTAMP_NTZ,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);
```

### 1.4 Feature Usage Table
```sql
CREATE TABLE IF NOT EXISTS Bronze.bz_feature_usage (
    usage_id STRING,
    meeting_id STRING,
    feature_name STRING,
    usage_count NUMBER,
    usage_date DATE,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);
```

### 1.5 Webinars Table
```sql
CREATE TABLE IF NOT EXISTS Bronze.bz_webinars (
    webinar_id STRING,
    host_id STRING,
    webinar_topic STRING,
    start_time TIMESTAMP_NTZ,
    end_time TIMESTAMP_NTZ,
    registrants NUMBER,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);
```

### 1.6 Support Tickets Table
```sql
CREATE TABLE IF NOT EXISTS Bronze.bz_support_tickets (
    ticket_id STRING,
    user_id STRING,
    ticket_type STRING,
    resolution_status STRING,
    open_date DATE,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);
```

### 1.7 Licenses Table
```sql
CREATE TABLE IF NOT EXISTS Bronze.bz_licenses (
    license_id STRING,
    license_type STRING,
    assigned_to_user_id STRING,
    start_date DATE,
    end_date DATE,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);
```

### 1.8 Billing Events Table
```sql
CREATE TABLE IF NOT EXISTS Bronze.bz_billing_events (
    event_id STRING,
    user_id STRING,
    event_type STRING,
    amount NUMBER(10,2),
    event_date DATE,
    -- Metadata columns
    load_timestamp TIMESTAMP_NTZ,
    update_timestamp TIMESTAMP_NTZ,
    source_system STRING
);
```

### 1.9 Audit Log Table
```sql
CREATE TABLE IF NOT EXISTS Bronze.bz_audit_log (
    record_id NUMBER AUTOINCREMENT,
    source_table STRING,
    load_timestamp TIMESTAMP_NTZ,
    processed_by STRING,
    processing_time NUMBER,
    status STRING
);
```

## 2. Table Descriptions

### 2.1 Bronze.bz_users
- **Purpose**: Stores raw user account information from the Zoom platform
- **Source**: Users table from source system
- **Key Fields**: user_id (unique identifier), plan_type (subscription level)
- **Data Volume**: Expected to grow with new user registrations

### 2.2 Bronze.bz_meetings
- **Purpose**: Stores raw meeting session data including timing and host information
- **Source**: Meetings table from source system
- **Key Fields**: meeting_id (unique identifier), host_id (links to users)
- **Data Volume**: High volume table with continuous meeting data ingestion

### 2.3 Bronze.bz_participants
- **Purpose**: Stores raw participant attendance data for meetings
- **Source**: Participants table from source system
- **Key Fields**: participant_id (unique identifier), meeting_id, user_id
- **Data Volume**: Very high volume with multiple participants per meeting

### 2.4 Bronze.bz_feature_usage
- **Purpose**: Stores raw feature utilization data during meetings
- **Source**: Feature_Usage table from source system
- **Key Fields**: usage_id (unique identifier), meeting_id, feature_name
- **Data Volume**: High volume with multiple feature usage events per meeting

### 2.5 Bronze.bz_webinars
- **Purpose**: Stores raw webinar session data including registration information
- **Source**: Webinars table from source system
- **Key Fields**: webinar_id (unique identifier), host_id (links to users)
- **Data Volume**: Medium volume depending on webinar frequency

### 2.6 Bronze.bz_support_tickets
- **Purpose**: Stores raw customer support ticket information
- **Source**: Support_Tickets table from source system
- **Key Fields**: ticket_id (unique identifier), user_id (links to users)
- **Data Volume**: Medium volume based on support request frequency

### 2.7 Bronze.bz_licenses
- **Purpose**: Stores raw license assignment and validity information
- **Source**: Licenses table from source system
- **Key Fields**: license_id (unique identifier), assigned_to_user_id (links to users)
- **Data Volume**: Low to medium volume based on license management

### 2.8 Bronze.bz_billing_events
- **Purpose**: Stores raw billing transaction and financial event data
- **Source**: Billing_Events table from source system
- **Key Fields**: event_id (unique identifier), user_id (links to users)
- **Data Volume**: Medium volume based on billing frequency

### 2.9 Bronze.bz_audit_log
- **Purpose**: Tracks data loading and processing activities for all Bronze tables
- **Source**: System generated audit information
- **Key Fields**: record_id (auto-increment), source_table, status
- **Data Volume**: Grows with each data loading operation

## 3. Data Type Mapping

### 3.1 Source to Snowflake Data Type Conversion
- **VARCHAR(n)** → **STRING**: All variable character fields converted to Snowflake STRING type
- **INT** → **NUMBER**: Integer fields converted to Snowflake NUMBER type
- **DECIMAL(10,2)** → **NUMBER(10,2)**: Decimal fields with precision maintained
- **DATETIME** → **TIMESTAMP_NTZ**: Date-time fields converted to Snowflake timestamp without timezone
- **DATE** → **DATE**: Date fields remain as DATE type

### 3.2 Metadata Column Standards
- **load_timestamp**: TIMESTAMP_NTZ - When record was first loaded
- **update_timestamp**: TIMESTAMP_NTZ - When record was last updated
- **source_system**: STRING - Identifies the source system origin

## 4. Implementation Notes

### 4.1 Snowflake Compatibility
- All DDL scripts use **CREATE TABLE IF NOT EXISTS** syntax for safe deployment
- No primary keys, foreign keys, or constraints defined (Bronze layer best practice)
- Uses Snowflake native data types for optimal performance
- Leverages Snowflake's default micro-partitioned storage format

### 4.2 Bronze Layer Principles
- **Raw Data Storage**: Tables store data as-is from source systems
- **No Data Transformation**: Minimal processing applied at Bronze layer
- **Audit Trail**: Complete audit logging for data lineage tracking
- **Metadata Enrichment**: Standard metadata columns for operational tracking

### 4.3 Naming Conventions
- **Schema**: Bronze (dedicated schema for Bronze layer tables)
- **Table Prefix**: bz_ (identifies Bronze layer tables)
- **Column Names**: snake_case format following Snowflake conventions

## 5. Data Loading Considerations

### 5.1 Recommended Loading Patterns
- Use **COPY INTO** commands for bulk data loading from staged files
- Implement **MERGE** statements for incremental updates
- Utilize **Snowflake Streams** for change data capture from source systems
- Schedule regular **Tasks** for automated data pipeline execution

### 5.2 Performance Optimization
- Consider **clustering keys** on frequently filtered columns (date fields)
- Monitor **query performance** and adjust warehouse sizing as needed
- Implement **data retention policies** based on business requirements
- Use **result caching** for frequently accessed data patterns

### 5.3 Monitoring and Maintenance
- Regular monitoring of **data loading success rates** via audit log
- **Data quality checks** on critical business fields
- **Storage usage tracking** for cost optimization
- **Performance tuning** based on query patterns and usage analytics