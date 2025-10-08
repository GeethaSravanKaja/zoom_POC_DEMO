# Zoom Gold Dimension Pipeline - DBT Project

## Overview
This DBT project transforms data from the Silver Layer into Gold Layer dimension and fact tables within a Snowflake environment for the Zoom Platform Analytics System. The pipeline follows medallion architecture best practices and implements robust error handling, audit logging, and data quality checks.

## Project Structure
```
Gold_dim_pipeline_Output/
├── README.md                    # This documentation file
├── dbt_project.yml             # DBT project configuration
├── packages.yml                # External package dependencies
├── schema.yml                  # Source and model definitions
├── audit_macro.sql             # Reusable macros for audit and transformations
├── go_process_audit.sql        # Audit table model (foundation)
├── go_user_dim.sql             # User dimension table (SCD Type 2)
├── go_license_dim.sql          # License dimension table (SCD Type 2)
├── go_meeting_fact.sql         # Meeting fact table
├── go_participant_fact.sql     # Participant fact table
├── go_feature_usage_fact.sql   # Feature usage fact table
├── go_webinar_fact.sql         # Webinar fact table
├── go_support_ticket_fact.sql  # Support ticket fact table
└── go_billing_event_fact.sql   # Billing event fact table
```

## Data Flow
1. **Silver Layer Sources**: Clean, validated data from Bronze layer
2. **Gold Layer Dimensions**: Business-ready dimension tables with SCD Type 2
3. **Gold Layer Facts**: Aggregated and enriched fact tables for analytics
4. **Audit & Error Handling**: Comprehensive logging and error tracking

## Models Description

### Foundation Models
- **go_process_audit**: Tracks pipeline execution, performance metrics, and audit information

### Dimension Models (SCD Type 2)
- **go_user_dim**: User profiles with historical tracking
- **go_license_dim**: License assignments with status derivation

### Fact Models
- **go_meeting_fact**: Meeting activities and metrics
- **go_participant_fact**: Meeting participation details
- **go_feature_usage_fact**: Feature utilization analytics
- **go_webinar_fact**: Webinar performance metrics
- **go_support_ticket_fact**: Customer support analytics
- **go_billing_event_fact**: Revenue and billing transactions

## Key Features

### 1. Audit & Error Handling
- Pre-hook and post-hook audit logging for all models
- Process execution tracking with start/end times
- Record count validation and error reporting
- Conditional hook execution to prevent audit table conflicts

### 2. Data Quality & Transformations
- Null value handling and data cleansing
- Email standardization and text normalization
- Business rule implementation for derived fields
- Data type conversions and validations

### 3. SCD Type 2 Implementation
- Historical tracking for dimension tables
- Effective date management
- Current flag maintenance

### 4. Performance Optimization
- Incremental loading strategies
- Proper indexing and clustering recommendations
- Efficient SQL with CTEs for readability

## Configuration

### Variables
```yaml
vars:
  source_database: 'ZOOM_DB'
  source_schema: 'SILVER'
  target_schema: 'GOLD'
  scd_end_date: '9999-12-31'
  audit_enabled: true
```

### Sources
- **Silver.si_users**: User profile data
- **Silver.si_licenses**: License assignment data
- **Silver.si_meetings**: Meeting information
- **Silver.si_participants**: Meeting participation
- **Silver.si_feature_usage**: Feature utilization
- **Silver.si_webinars**: Webinar data
- **Silver.si_support_tickets**: Support tickets
- **Silver.si_billing_events**: Billing transactions

## Installation & Setup

### 1. Install Dependencies
```bash
dbt deps
```

### 2. Configure Profile
Create/update your `profiles.yml` with Snowflake connection details:
```yaml
zoom_gold_dimension_pipeline:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: [your_account]
      user: [your_user]
      password: [your_password]
      role: [your_role]
      database: ZOOM_DB
      warehouse: [your_warehouse]
      schema: GOLD
      threads: 4
```

### 3. Test Connection
```bash
dbt debug
```

### 4. Run Models
```bash
# Run all models
dbt run

# Run specific model
dbt run --select go_user_dim

# Run with full refresh
dbt run --full-refresh
```

### 5. Run Tests
```bash
dbt test
```

## Execution Order
The models are designed to run in the following order:
1. `go_process_audit` (foundation)
2. Dimension models (`go_user_dim`, `go_license_dim`)
3. Fact models (all fact tables)

## Data Lineage
```
Silver Layer → Gold Dimensions → Gold Facts → Analytics/BI
     ↓              ↓              ↓
  Cleansed    Business Rules   Aggregated
   Data        Applied         Metrics
```

## Monitoring & Maintenance

### Audit Queries
```sql
-- Check pipeline execution status
SELECT * FROM GOLD.go_process_audit 
WHERE execution_start_time >= CURRENT_DATE - 7
ORDER BY execution_start_time DESC;

-- Monitor data quality
SELECT 
    process_name,
    AVG(records_processed) as avg_records,
    AVG(process_duration_seconds) as avg_duration
FROM GOLD.go_process_audit 
WHERE execution_status = 'COMPLETED'
GROUP BY process_name;
```

### Performance Monitoring
- Monitor execution times in audit table
- Track record counts and processing rates
- Review error logs for data quality issues

## Best Practices Implemented

1. **Modular Design**: Each model is self-contained with clear dependencies
2. **Error Handling**: Comprehensive audit logging and error tracking
3. **Data Quality**: Input validation and cleansing rules
4. **Documentation**: Extensive comments and metadata
5. **Testing**: Built-in data quality tests
6. **Performance**: Optimized SQL and materialization strategies
7. **Maintainability**: Clear naming conventions and structure

## Troubleshooting

### Common Issues
1. **Audit table conflicts**: Ensure `go_process_audit` runs first
2. **Source data missing**: Verify Silver layer table availability
3. **Permission errors**: Check Snowflake role permissions
4. **Performance issues**: Review warehouse sizing and clustering

### Debug Commands
```bash
# Compile models without running
dbt compile

# Run specific model with debug
dbt run --select go_user_dim --debug

# Check model dependencies
dbt list --select +go_user_dim+
```

## Support
For questions or issues:
1. Check the audit logs in `go_process_audit` table
2. Review DBT logs in `target/` directory
3. Validate source data in Silver layer
4. Contact the Data Engineering team

## Version History
- **v1.0.0**: Initial release with core dimension and fact models
- Includes comprehensive audit logging and error handling
- Implements SCD Type 2 for dimension tables
- Production-ready with full documentation