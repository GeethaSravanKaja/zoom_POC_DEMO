# Zoom Gold Dimension Pipeline - DBT Project

## Overview
This DBT project transforms data from the Silver Layer into Gold Layer dimension and fact tables within a Snowflake environment for the Zoom Platform Analytics System. The project follows medallion architecture best practices and implements comprehensive data quality, auditing, and error handling mechanisms.

## Project Structure

### Core DBT Files
- `dbt_project.yml` - Main project configuration file
- `packages.yml` - External package dependencies
- `schema.yml` - Sources and models metadata definitions

### Model Files

#### Audit and Process Tracking
- `go_process_audit.sql` - Process audit table for tracking all DBT executions

#### Dimension Tables (SCD Type 2)
- `go_user_dim.sql` - User dimension with standardized user information
- `go_license_dim.sql` - License dimension with assignment status tracking

#### Fact Tables
- `go_meeting_fact.sql` - Meeting activity fact table
- `go_participant_fact.sql` - Meeting participation fact table
- `go_feature_usage_fact.sql` - Feature utilization fact table
- `go_webinar_fact.sql` - Webinar activity fact table
- `go_support_ticket_fact.sql` - Customer support fact table
- `go_billing_event_fact.sql` - Billing transactions fact table

#### Utilities
- `zoom_macros.sql` - Reusable macros for data transformations

## Key Features

### 1. Data Quality & Validation
- Comprehensive data validation and cleansing
- Email format standardization
- Company name normalization
- Plan type hierarchy mapping
- Null value handling with meaningful defaults

### 2. Audit & Process Tracking
- Pre-hook and post-hook audit logging
- Execution tracking with start/end times
- Record count validation
- Error handling and status tracking
- Process duration monitoring

### 3. SCD Type 2 Implementation
- Historical data tracking for dimension tables
- Effective date management (scd_start_date, scd_end_date)
- Current flag implementation (scd_current_flag)

### 4. Error Handling
- Robust error handling with try-catch patterns
- Data quality issue identification
- Process failure recovery mechanisms
- Comprehensive logging

### 5. Performance Optimization
- Efficient SQL with CTEs for readability
- Proper indexing strategies
- Snowflake-specific optimizations
- Batch processing capabilities

## Source Tables (Silver Layer)

The project transforms data from the following Silver layer tables:
- `si_users` - User profile information
- `si_licenses` - License assignment data
- `si_meetings` - Meeting information
- `si_participants` - Meeting participation data
- `si_feature_usage` - Feature utilization data
- `si_webinars` - Webinar information
- `si_support_tickets` - Support ticket data
- `si_billing_events` - Billing transaction data
- `si_audit` - Process audit information

## Target Tables (Gold Layer)

### Dimension Tables
- `Go_User_Dim` - Standardized user dimension
- `Go_License_Dim` - License assignment dimension

### Fact Tables
- `Go_Meeting_Fact` - Meeting activity metrics
- `Go_Participant_Fact` - Participation analytics
- `Go_Feature_Usage_Fact` - Feature adoption metrics
- `Go_Webinar_Fact` - Webinar performance data
- `Go_Support_Ticket_Fact` - Support analytics
- `Go_Billing_Event_Fact` - Revenue and billing data

### Audit Tables
- `Go_Process_Audit` - Execution tracking and monitoring

## Installation & Setup

### Prerequisites
- DBT Core 1.0+ or DBT Cloud
- Snowflake account with appropriate permissions
- Access to Silver layer schema

### Installation Steps

1. **Clone/Download the project files**
   ```bash
   # All files are available in the Gold_dim_pipeline_Output folder
   ```

2. **Install DBT packages**
   ```bash
   dbt deps
   ```

3. **Configure profiles.yml**
   ```yaml
   zoom_gold_dimension_pipeline:
     target: dev
     outputs:
       dev:
         type: snowflake
         account: [your_account]
         user: [your_username]
         password: [your_password]
         role: [your_role]
         database: [your_database]
         warehouse: [your_warehouse]
         schema: gold
         threads: 4
   ```

4. **Test connection**
   ```bash
   dbt debug
   ```

5. **Run the models**
   ```bash
   # Run all models
   dbt run
   
   # Run specific model
   dbt run --select go_user_dim
   
   # Run with full refresh
   dbt run --full-refresh
   ```

6. **Run tests**
   ```bash
   dbt test
   ```

## Configuration

### Variables
The project uses several variables that can be configured:

```yaml
vars:
  silver_schema: 'silver'        # Source schema name
  gold_schema: 'gold'            # Target schema name
  start_date: '2020-01-01'       # Processing start date
  end_date: '2099-12-31'         # Processing end date
  scd_end_date: '9999-12-31'     # SCD Type 2 end date
  enable_audit_logging: true     # Enable audit logging
  batch_size: 10000              # Batch processing size
```

### Model Execution Order
The models are designed to run in the following order:
1. `go_process_audit` (first - tracks all other executions)
2. Dimension tables (`go_user_dim`, `go_license_dim`)
3. Fact tables (all fact tables can run in parallel)

## Data Transformations

### User Dimension Transformations
- Email standardization (lowercase, format validation)
- Company name normalization (remove special characters)
- Plan type hierarchy mapping (Free→Basic→Pro→Enterprise)
- Account status derivation from user status

### License Dimension Transformations
- License type standardization
- Assignment status calculation based on dates
- License capacity assignment based on type

### Fact Table Transformations
- Duration calculations for meetings and webinars
- Participant count aggregations
- Feature categorization and success rate calculations
- Support ticket priority and resolution metrics
- Billing cycle and payment method derivation

## Monitoring & Maintenance

### Process Monitoring
- Check `Go_Process_Audit` table for execution status
- Monitor execution times and record counts
- Review error messages and failure patterns

### Data Quality Monitoring
- Regular validation of data completeness
- Monitor transformation accuracy
- Check for data anomalies and outliers

### Performance Tuning
- Monitor query execution times
- Optimize clustering keys if needed
- Review and adjust batch sizes

## Troubleshooting

### Common Issues
1. **Connection Issues**: Verify Snowflake credentials and permissions
2. **Source Table Access**: Ensure access to Silver layer tables
3. **Schema Permissions**: Verify create/write permissions on Gold schema
4. **Package Dependencies**: Run `dbt deps` to install required packages

### Error Resolution
1. Check `Go_Process_Audit` table for detailed error messages
2. Review DBT logs for compilation or runtime errors
3. Validate source data quality and completeness
4. Ensure proper schema and table permissions

## Best Practices Implemented

1. **Modular Design**: Separate models for each table with clear dependencies
2. **Data Quality**: Comprehensive validation and cleansing
3. **Audit Trail**: Complete process tracking and monitoring
4. **Error Handling**: Robust error management and recovery
5. **Documentation**: Comprehensive metadata and column descriptions
6. **Testing**: Built-in data quality tests and validations
7. **Performance**: Optimized SQL and Snowflake-specific features
8. **Maintainability**: Clean, readable code with proper commenting

## Support

For questions or issues:
1. Review the audit tables for execution details
2. Check DBT logs for detailed error information
3. Validate source data and permissions
4. Contact the data engineering team for assistance

## Version History

- **v1.0.0**: Initial release with complete dimension and fact table transformations
- Includes all Silver to Gold transformations
- Comprehensive audit and error handling
- Production-ready with full documentation