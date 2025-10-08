# Zoom Gold Fact Pipeline - DBT Implementation

## Overview

This DBT project transforms data from the Silver Layer into Gold Layer fact tables within a Snowflake environment for the Zoom Platform Analytics System. The pipeline follows medallion architecture principles and implements comprehensive data quality, performance optimization, and adherence to DBT best practices.

## Project Structure

```
Gold_fact_pipeline_Output/
├── dbt_project.yml              # DBT project configuration
├── schema.yml                   # Sources and models metadata with tests
├── process_audit.sql            # Process audit table for execution tracking
├── go_meeting_fact.sql          # Meeting activity fact table
├── go_participant_fact.sql      # Participant engagement fact table
├── go_feature_usage_fact.sql    # Feature usage analytics fact table
├── go_webinar_fact.sql          # Webinar performance fact table
├── go_support_ticket_fact.sql   # Support ticket resolution fact table
├── go_billing_event_fact.sql    # Billing events and revenue fact table
└── README.md                    # This documentation file
```

## Fact Tables Overview

### 1. Go_Meeting_Fact
- **Purpose**: Meeting activity metrics and dimensions for analytical reporting
- **Source**: Silver.si_meetings, Silver.si_participants
- **Key Features**:
  - Meeting duration validation and capping
  - Participant count aggregation
  - Business rule-based meeting type classification
  - Comprehensive null handling

### 2. Go_Participant_Fact
- **Purpose**: Individual participant engagement and attendance patterns
- **Source**: Silver.si_participants, Silver.si_users, Silver.si_meetings
- **Key Features**:
  - Attendance duration calculation
  - Attendee type classification based on engagement
  - User information enrichment
  - Host identification logic

### 3. Go_Feature_Usage_Fact
- **Purpose**: Feature adoption and usage patterns across meetings
- **Source**: Silver.si_feature_usage
- **Key Features**:
  - Feature categorization (Collaboration, Engagement, Documentation)
  - Usage duration estimation based on feature type
  - Success rate simulation
  - Usage count validation and capping

### 4. Go_Webinar_Fact
- **Purpose**: Webinar performance metrics and attendance analytics
- **Source**: Silver.si_webinars
- **Key Features**:
  - Duration calculation and validation
  - Attendance rate simulation (30-70%)
  - Registrant count validation
  - Comprehensive timestamp handling

### 5. Go_Support_Ticket_Fact
- **Purpose**: Customer support interactions and resolution metrics
- **Source**: Silver.si_support_tickets
- **Key Features**:
  - Priority level derivation from ticket type
  - Resolution time calculation
  - Satisfaction score simulation
  - Status-based close date estimation

### 6. Go_Billing_Event_Fact
- **Purpose**: Financial transactions and billing events for revenue analytics
- **Source**: Silver.si_billing_events
- **Key Features**:
  - Amount validation and capping
  - Payment method derivation
  - Billing cycle classification
  - Currency standardization (USD)

## Data Quality Features

### Transformation Rules
- **Null Handling**: Comprehensive null value management with business-appropriate defaults
- **Data Standardization**: UPPER(TRIM()) for text fields, ROUND() for numeric precision
- **Validation**: Range checks, data type validation, and business rule enforcement
- **Calculated Fields**: Duration calculations, aggregations, and business classifications

### Data Tests
- **Uniqueness**: Surrogate key uniqueness validation
- **Not Null**: Critical field null checks
- **Accepted Values**: Enumerated value validation
- **Range Validation**: Numeric range checks with configurable thresholds
- **Referential Integrity**: Source data availability validation

## Performance Optimization

### Snowflake-Specific Features
- **Clustering Keys**: Applied on date and key dimension fields for optimal query performance
- **Materialization**: All fact tables materialized as tables for analytical workloads
- **Micro-Partitioning**: Leverages Snowflake's automatic micro-partitioning
- **Data Types**: Optimized Snowflake data types (VARCHAR, NUMBER, TIMESTAMP_NTZ)

### Query Optimization
- **CTEs**: Modular transformation logic using Common Table Expressions
- **Efficient Joins**: LEFT JOINs for dimension enrichment
- **Aggregation**: Pre-calculated metrics for improved query performance

## Audit and Monitoring

### Process Audit Table
- **Execution Tracking**: Complete pipeline execution monitoring
- **Performance Metrics**: Duration, record counts, success/failure tracking
- **Error Handling**: Comprehensive error logging and status tracking
- **Lineage**: Full data lineage through load timestamps and execution IDs

### Pre/Post Hooks
- **Pre-Hook**: Execution start logging with process metadata
- **Post-Hook**: Completion logging with record counts and status updates
- **Error Handling**: Automatic failure detection and logging

## Configuration

### Environment Variables
```yaml
vars:
  database_name: 'ZOOM_ANALYTICS'
  silver_schema: 'SILVER'
  gold_schema: 'GOLD'
  audit_schema: 'AUDIT'
```

### Business Rule Thresholds
```yaml
vars:
  max_meeting_duration_minutes: 1440
  max_webinar_duration_minutes: 480
  max_feature_usage_count: 1000
  max_billing_amount: 100000.00
  active_participant_threshold: 0.8
  moderate_participant_threshold: 0.5
```

## Installation and Setup

### Prerequisites
- DBT Core 1.0+ or DBT Cloud
- Snowflake account with appropriate permissions
- Access to Silver Layer tables

### Setup Steps

1. **Clone Repository**
   ```bash
   git clone <repository-url>
   cd Gold_fact_pipeline_Output
   ```

2. **Configure Profile**
   Create `profiles.yml` with Snowflake connection details:
   ```yaml
   zoom_analytics:
     target: dev
     outputs:
       dev:
         type: snowflake
         account: <your-account>
         user: <your-user>
         password: <your-password>
         role: <your-role>
         database: ZOOM_ANALYTICS
         warehouse: <your-warehouse>
         schema: GOLD
         threads: 4
   ```

3. **Install Dependencies**
   ```bash
   dbt deps
   ```

4. **Test Connection**
   ```bash
   dbt debug
   ```

5. **Run Pipeline**
   ```bash
   # Full refresh
   dbt run --full-refresh
   
   # Incremental run
   dbt run
   
   # Run with tests
   dbt run && dbt test
   ```

## Usage Examples

### Running Specific Models
```bash
# Run single fact table
dbt run --select go_meeting_fact

# Run all fact tables
dbt run --select tag:fact_table

# Run with downstream dependencies
dbt run --select go_meeting_fact+
```

### Testing
```bash
# Run all tests
dbt test

# Test specific model
dbt test --select go_meeting_fact

# Test with store failures
dbt test --store-failures
```

### Documentation
```bash
# Generate documentation
dbt docs generate

# Serve documentation
dbt docs serve
```

## Monitoring and Maintenance

### Daily Operations
1. **Pipeline Execution**: Automated through scheduler (Airflow, DBT Cloud, etc.)
2. **Data Quality Monitoring**: Review test results and audit logs
3. **Performance Monitoring**: Check execution times and resource usage

### Weekly Reviews
1. **Data Volume Analysis**: Monitor record counts and growth trends
2. **Error Analysis**: Review failed records and resolution patterns
3. **Performance Optimization**: Analyze query performance and clustering effectiveness

### Monthly Maintenance
1. **Schema Evolution**: Review and implement new business requirements
2. **Performance Tuning**: Optimize clustering keys and materialization strategies
3. **Documentation Updates**: Maintain current documentation and lineage

## Troubleshooting

### Common Issues

1. **Source Table Not Found**
   - Verify Silver Layer table availability
   - Check schema and database configurations
   - Validate source permissions

2. **Data Quality Test Failures**
   - Review test results in audit schema
   - Analyze source data quality issues
   - Adjust business rules if necessary

3. **Performance Issues**
   - Review clustering key effectiveness
   - Analyze query execution plans
   - Consider materialization strategy adjustments

### Error Resolution

1. **Check Process Audit Table**
   ```sql
   SELECT * FROM GOLD.process_audit 
   WHERE execution_status = 'FAILED' 
   ORDER BY execution_start_time DESC;
   ```

2. **Review DBT Logs**
   ```bash
   dbt run --debug
   ```

3. **Validate Source Data**
   ```sql
   SELECT COUNT(*) FROM SILVER.si_meetings WHERE meeting_id IS NULL;
   ```

## Best Practices

### Development
- Use feature branches for development
- Test thoroughly in development environment
- Follow DBT naming conventions
- Document all business logic

### Production
- Implement proper CI/CD pipelines
- Monitor data quality continuously
- Maintain comprehensive logging
- Regular backup and recovery testing

### Performance
- Optimize clustering keys based on query patterns
- Monitor warehouse usage and costs
- Implement incremental loading where appropriate
- Regular performance reviews and optimizations

## Support and Contact

For technical support or questions:
- **Data Engineering Team**: [data-engineering@company.com]
- **Documentation**: [Internal Wiki Link]
- **Issue Tracking**: [JIRA Project Link]

## Version History

- **v1.0.0**: Initial implementation with all fact tables
- **Future**: Incremental loading, additional dimensions, real-time processing

---

**Last Updated**: 2024-12-19  
**Author**: Data Engineering Team  
**Review Status**: Production Ready