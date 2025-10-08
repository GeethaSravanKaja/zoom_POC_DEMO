# Zoom Gold Layer Pipeline - DBT Project

## Overview

This DBT project transforms data from the Silver Layer into Gold Layer dimension and fact tables within a Snowflake environment for the Zoom Platform Analytics System. The project implements a medallion architecture pattern with comprehensive audit logging, error handling, and data quality monitoring.

## Project Structure

```
zoom_gold_pipeline/
├── dbt_project.yml          # DBT project configuration
├── packages.yml             # External package dependencies
├── profiles.yml             # Database connection profiles
├── schema.yml               # Source and model definitions
├── README.md                # This documentation
├── audit_helper_macros.sql  # Custom macros for transformations
└── models/
    ├── go_process_audit.sql      # Audit table (must run first)
    ├── go_user_dim.sql           # User dimension (SCD Type 2)
    ├── go_license_dim.sql        # License dimension (SCD Type 2)
    ├── go_meeting_fact.sql       # Meeting fact table
    ├── go_participant_fact.sql   # Participant fact table
    ├── go_feature_usage_fact.sql # Feature usage fact table
    ├── go_webinar_fact.sql       # Webinar fact table
    ├── go_support_ticket_fact.sql # Support ticket fact table
    ├── go_billing_event_fact.sql # Billing event fact table
    └── go_error_data.sql         # Error data table
```

## Data Architecture

### Source Layer (Silver)
- **si_users**: User information
- **si_meetings**: Meeting details
- **si_participants**: Meeting participation data
- **si_feature_usage**: Feature utilization tracking
- **si_webinars**: Webinar information
- **si_support_tickets**: Customer support tickets
- **si_licenses**: License assignments
- **si_billing_events**: Billing transactions
- **si_error_data**: Error logging
- **si_audit**: Process audit information

### Target Layer (Gold)

#### Dimension Tables
- **go_user_dim**: User dimension with SCD Type 2 implementation
- **go_license_dim**: License dimension with SCD Type 2 implementation

#### Fact Tables
- **go_meeting_fact**: Meeting activity metrics
- **go_participant_fact**: Participation analytics
- **go_feature_usage_fact**: Feature utilization metrics
- **go_webinar_fact**: Webinar performance data
- **go_support_ticket_fact**: Support ticket analytics
- **go_billing_event_fact**: Billing transaction data

#### Support Tables
- **go_process_audit**: Pipeline execution audit log
- **go_error_data**: Data quality and error tracking

## Key Features

### 1. Audit Logging
- Comprehensive process audit tracking
- Pre-hook and post-hook implementations
- Execution status monitoring
- Performance metrics collection

### 2. Data Quality
- Built-in data validation
- Error handling and logging
- Data quality status tracking
- Invalid record filtering

### 3. SCD Type 2 Implementation
- Historical data tracking for dimensions
- Effective date management
- Current record flagging

### 4. Business Logic
- Data standardization and normalization
- Derived metrics and calculations
- Business rule implementations
- Data enrichment

## Setup Instructions

### Prerequisites
- DBT Core 1.0+ or DBT Cloud
- Snowflake account with appropriate permissions
- Python 3.7+ (for DBT Core)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd zoom_gold_pipeline
   ```

2. **Install DBT and dependencies**
   ```bash
   pip install dbt-snowflake
   dbt deps
   ```

3. **Configure profiles.yml**
   - Copy `profiles.yml` to `~/.dbt/profiles.yml`
   - Update connection parameters for your Snowflake environment
   - Set required environment variables

4. **Set environment variables**
   ```bash
   export SNOWFLAKE_ACCOUNT="your-account"
   export SNOWFLAKE_USER="your-username"
   export SNOWFLAKE_PASSWORD="your-password"
   export SNOWFLAKE_ROLE="TRANSFORMER"
   export SNOWFLAKE_DATABASE="ZOOM_DB"
   export SNOWFLAKE_WAREHOUSE="COMPUTE_WH"
   export SNOWFLAKE_SCHEMA="GOLD"
   ```

### Execution

1. **Test connection**
   ```bash
   dbt debug
   ```

2. **Install packages**
   ```bash
   dbt deps
   ```

3. **Run models**
   ```bash
   # Run all models
   dbt run
   
   # Run specific model
   dbt run --models go_user_dim
   
   # Run models with specific tags
   dbt run --models tag:dimension
   ```

4. **Run tests**
   ```bash
   dbt test
   ```

5. **Generate documentation**
   ```bash
   dbt docs generate
   dbt docs serve
   ```

## Model Dependencies

The models have the following execution order:

1. **go_process_audit** (must run first - no dependencies)
2. **Dimension tables** (go_user_dim, go_license_dim)
3. **Fact tables** (all fact tables can run in parallel)
4. **go_error_data** (can run independently)

## Configuration

### Variables
The project uses the following variables (defined in `dbt_project.yml`):

- `source_database`: Source database name (default: 'ZOOM_DB')
- `source_schema`: Source schema name (default: 'SILVER')
- `target_schema`: Target schema name (default: 'GOLD')
- `enable_audit_logging`: Enable audit logging (default: true)
- `enable_error_handling`: Enable error handling (default: true)
- `data_quality_threshold`: Data quality threshold (default: 0.95)

### Materialization
- All models are materialized as **tables** for optimal query performance
- Incremental materialization can be implemented for large fact tables if needed

## Data Quality & Testing

### Built-in Tests
- Not null constraints on key fields
- Uniqueness tests on primary keys
- Referential integrity checks
- Data format validations

### Custom Data Quality
- Invalid record filtering
- Data standardization
- Business rule validation
- Error logging and tracking

## Monitoring & Observability

### Audit Logging
- Process execution tracking
- Performance metrics
- Record counts and processing statistics
- Error and failure tracking

### Error Handling
- Comprehensive error logging
- Data quality issue tracking
- Resolution status management
- Error severity classification

## Performance Optimization

### Snowflake Optimizations
- Clustering keys on large tables
- Proper data types for storage efficiency
- Query optimization through CTEs
- Partition pruning strategies

### DBT Optimizations
- Efficient model dependencies
- Parallel execution where possible
- Incremental processing capabilities
- Resource allocation management

## Troubleshooting

### Common Issues

1. **Connection Issues**
   - Verify Snowflake credentials
   - Check network connectivity
   - Validate role permissions

2. **Model Failures**
   - Check audit logs in `go_process_audit`
   - Review error details in `go_error_data`
   - Validate source data availability

3. **Performance Issues**
   - Monitor warehouse utilization
   - Review query execution plans
   - Consider clustering key optimization

### Debugging Commands

```bash
# Debug connection
dbt debug

# Run with verbose logging
dbt run --log-level debug

# Compile models without running
dbt compile

# Show model lineage
dbt docs generate && dbt docs serve
```

## Contributing

### Development Guidelines
1. Follow SQL style guide
2. Include comprehensive comments
3. Implement proper error handling
4. Add appropriate tests
5. Update documentation

### Code Review Checklist
- [ ] SQL syntax and style
- [ ] Data quality validations
- [ ] Error handling implementation
- [ ] Performance considerations
- [ ] Documentation updates
- [ ] Test coverage

## Support

For questions or issues:
1. Check the troubleshooting section
2. Review audit logs and error data
3. Contact the Data Engineering team
4. Create an issue in the repository

## Version History

- **v1.0.0**: Initial release with core dimension and fact tables
  - User and License dimensions with SCD Type 2
  - Meeting, Participant, Feature Usage, Webinar, Support Ticket, and Billing fact tables
  - Comprehensive audit logging and error handling
  - Data quality validations and monitoring

## License

This project is proprietary to AAVA and is intended for internal use only.

---

**Generated by AAVA Data Engineering Team**  
**Last Updated**: Current Date  
**DBT Version**: 1.0+  
**Snowflake Compatible**: Yes