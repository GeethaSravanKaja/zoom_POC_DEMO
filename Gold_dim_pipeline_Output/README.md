# Zoom Gold Dimension Pipeline - DBT Project

## Overview
This DBT project transforms data from the Silver Layer into Gold Layer dimension tables within a Snowflake environment for the Zoom Platform Analytics System. The pipeline implements production-ready data transformations with comprehensive audit trails, error handling, and data quality monitoring.

## Author
**AAVA Data Engineering Team**

## Project Structure
```
zoom_gold_dimension_pipeline/
├── dbt_project.yml          # DBT project configuration
├── packages.yml             # Required DBT packages
├── README.md               # This file
├── models/
│   ├── schema.yml          # Sources and models documentation
│   └── gold_dimensions/
│       ├── go_process_audit.sql    # Audit table (created first)
│       ├── go_user_dim.sql         # User dimension (SCD Type 2)
│       ├── go_license_dim.sql      # License dimension (SCD Type 2)
│       └── go_error_data.sql       # Error tracking table
└── macros/
    └── generate_audit_columns.sql  # Reusable audit macros
```

## Features

### 🔄 Data Transformation
- **1:1 Data Mapping**: Direct mapping from Silver to Gold layer with transformations
- **SCD Type 2**: Slowly Changing Dimensions implementation for historical tracking
- **Data Quality**: Comprehensive validation and cleansing rules
- **Error Handling**: Robust error detection and logging mechanisms

### 📊 Audit & Monitoring
- **Process Audit**: Complete execution tracking with pre/post hooks
- **Error Tracking**: Detailed error logging and resolution status
- **Data Lineage**: Full traceability from Silver to Gold layer
- **Performance Metrics**: Execution time and record count tracking

### 🛠️ Production Features
- **Modular Design**: Reusable macros and standardized patterns
- **Incremental Processing**: Optimized for large-scale data processing
- **Data Quality Tests**: Comprehensive testing framework
- **Documentation**: Complete column and table documentation

## Source Tables (Silver Layer)

| Table Name | Description | Key Columns |
|------------|-------------|-------------|
| `si_users` | User master data | user_id, user_name, email, company, plan_type |
| `si_licenses` | License information | license_id, license_type, assigned_to_user_id |
| `si_error_data` | Error tracking data | error_id, error_type, source_table |

## Target Tables (Gold Layer)

| Table Name | Type | Description | SCD Type |
|------------|------|-------------|----------|
| `go_process_audit` | Audit | Process execution tracking | N/A |
| `go_user_dim` | Dimension | User dimension table | Type 2 |
| `go_license_dim` | Dimension | License dimension table | Type 2 |
| `go_error_data` | Monitoring | Error and data quality tracking | N/A |

## Data Transformations

### User Dimension (`go_user_dim`)
- **Email Standardization**: Lowercase and format validation
- **Company Normalization**: Remove special characters
- **Plan Type Mapping**: Standardize to Basic/Pro/Enterprise
- **Account Status Derivation**: Map user_status to business-friendly values
- **SCD Type 2**: Track historical changes with effective dates

### License Dimension (`go_license_dim`)
- **License Type Mapping**: Standardize license categories
- **Assignment Status**: Derive status based on date ranges
- **Capacity Calculation**: Set capacity based on license type
- **Date Validation**: Ensure valid date ranges
- **SCD Type 2**: Track license assignment history

## Installation & Setup

### Prerequisites
- DBT Core 1.0+ or DBT Cloud
- Snowflake account with appropriate permissions
- Access to Silver layer schema

### Installation Steps

1. **Clone/Download the project files**

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
         account: your_account
         user: your_user
         password: your_password
         role: your_role
         database: your_database
         warehouse: your_warehouse
         schema: gold
         threads: 4
   ```

4. **Set up variables in dbt_project.yml or via CLI**
   ```yaml
   vars:
     silver_schema: 'silver'
     gold_schema: 'gold'
   ```

## Execution

### Full Refresh
```bash
# Run all models with full refresh
dbt run --full-refresh

# Run specific model
dbt run --models go_user_dim --full-refresh
```

### Incremental Run
```bash
# Run all models incrementally
dbt run

# Run only dimension models
dbt run --models tag:dimension
```

### Testing
```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --models go_user_dim
```

### Documentation
```bash
# Generate and serve documentation
dbt docs generate
dbt docs serve
```

## Model Dependencies

```
go_process_audit (runs first - no dependencies)
    ↓
go_user_dim (depends on go_process_audit for audit hooks)
    ↓
go_license_dim (depends on go_process_audit for audit hooks)
    ↓
go_error_data (depends on go_process_audit for audit hooks)
```

## Audit Trail

Every model execution is tracked in `go_process_audit` with:
- Execution ID and timestamps
- Record counts (processed, inserted, updated, failed)
- Execution duration
- Success/failure status
- Error messages (if any)

## Error Handling

The pipeline includes comprehensive error handling:
- **Data Validation**: Check for null values, data types, and business rules
- **Error Logging**: All errors logged to `go_error_data` table
- **Graceful Degradation**: Invalid records are excluded but logged
- **Monitoring**: Error severity levels and resolution tracking

## Data Quality Tests

- **Not Null**: Critical fields must have values
- **Unique**: Business keys must be unique
- **Accepted Values**: Enumerated fields validated against allowed values
- **Referential Integrity**: Foreign key relationships validated
- **Custom Tests**: Business-specific validation rules

## Performance Optimization

- **Incremental Models**: Process only changed records
- **Clustering**: Tables clustered on frequently queried columns
- **Partitioning**: Date-based partitioning for time-series data
- **Materialization**: Optimized materialization strategies

## Monitoring & Alerting

Monitor the pipeline using:
- `go_process_audit` table for execution metrics
- `go_error_data` table for data quality issues
- DBT test results for validation failures
- Snowflake query history for performance monitoring

## Troubleshooting

### Common Issues

1. **Permission Errors**
   - Ensure proper Snowflake roles and permissions
   - Verify schema access for both Silver and Gold layers

2. **Source Table Not Found**
   - Check Silver schema configuration
   - Verify table names match source definitions

3. **Audit Hook Failures**
   - Ensure `go_process_audit` table exists and is accessible
   - Check for circular dependencies

4. **Data Quality Failures**
   - Review `go_error_data` table for specific issues
   - Check source data quality in Silver layer

### Debug Commands

```bash
# Debug specific model
dbt run --models go_user_dim --debug

# Compile without running
dbt compile --models go_user_dim

# Show model dependencies
dbt list --models go_user_dim --output name
```

## Version History

| Version | Date | Changes |
|---------|------|----------|
| 1.0 | 2024 | Initial production release |

## Support

For questions or issues:
1. Check the troubleshooting section
2. Review audit logs in `go_process_audit`
3. Contact the AAVA Data Engineering Team

## License

This project is proprietary to AAVA and intended for internal use only.

---

**Note**: This pipeline is designed for production use with comprehensive error handling, audit trails, and data quality monitoring. Always test in a development environment before deploying to production.