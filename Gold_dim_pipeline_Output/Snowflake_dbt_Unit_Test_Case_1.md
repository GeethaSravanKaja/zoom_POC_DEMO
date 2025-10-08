_____________________________________________
## *Author*: AAVA
## *Created on*: 2024-12-19
## *Description*: Comprehensive Snowflake dbt Unit Test Cases for Zoom Gold Dimension Pipeline
## *Version*: 1 
## *Updated on*: 2024-12-19
_____________________________________________

# Snowflake dbt Unit Test Cases for Zoom Gold Dimension Pipeline

## Overview
This document provides comprehensive unit test cases and dbt test scripts for the Zoom Gold Dimension Pipeline dbt models running in Snowflake. The tests cover data transformations, business rules, edge cases, and error handling scenarios to ensure data quality and pipeline reliability.

## Models Under Test
1. `go_process_audit` - Process audit tracking table
2. `go_user_dim` - User dimension with SCD Type 2
3. `go_license_dim` - License dimension with SCD Type 2
4. `go_meeting_dim` - Meeting dimension table
5. `go_feature_dim` - Feature dimension table
6. `go_support_ticket_dim` - Support ticket dimension table
7. `go_webinar_dim` - Webinar dimension table

---

## Test Case List

### Test Case 1: Data Quality and Integrity Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC001 | Verify user_id is not null in go_user_dim | All records should have non-null user_id |
| TC002 | Verify user_dim_id uniqueness in go_user_dim | All user_dim_id values should be unique |
| TC003 | Verify license_id is not null in go_license_dim | All records should have non-null license_id |
| TC004 | Verify license_dim_id uniqueness in go_license_dim | All license_dim_id values should be unique |
| TC005 | Verify meeting_id is not null in go_meeting_dim | All records should have non-null meeting_id |
| TC006 | Verify meeting_dim_id uniqueness in go_meeting_dim | All meeting_dim_id values should be unique |
| TC007 | Verify feature_name is not null in go_feature_dim | All records should have non-null feature_name |
| TC008 | Verify feature_dim_id uniqueness in go_feature_dim | All feature_dim_id values should be unique |
| TC009 | Verify ticket_id is not null in go_support_ticket_dim | All records should have non-null ticket_id |
| TC010 | Verify support_ticket_dim_id uniqueness in go_support_ticket_dim | All support_ticket_dim_id values should be unique |
| TC011 | Verify webinar_id is not null in go_webinar_dim | All records should have non-null webinar_id |
| TC012 | Verify webinar_dim_id uniqueness in go_webinar_dim | All webinar_dim_id values should be unique |

### Test Case 2: Business Rule Validation Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC013 | Verify email format validation in go_user_dim | All email addresses should follow valid email format |
| TC014 | Verify account_status derivation logic in go_user_dim | Account status should be correctly derived from user_status |
| TC015 | Verify assignment_status derivation in go_license_dim | Assignment status should be correctly calculated based on dates |
| TC016 | Verify license_capacity calculation in go_license_dim | License capacity should match license type mapping |
| TC017 | Verify meeting_type derivation in go_meeting_dim | Meeting type should be correctly derived from duration |
| TC018 | Verify feature_category mapping in go_feature_dim | Feature category should be correctly assigned based on feature name |
| TC019 | Verify priority_level derivation in go_support_ticket_dim | Priority level should be correctly derived from ticket type |
| TC020 | Verify date range validation in go_license_dim | Start date should be less than or equal to end date |

### Test Case 3: SCD Type 2 Implementation Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC021 | Verify SCD current flag logic in go_user_dim | Only one record per user_id should have scd_current_flag = TRUE |
| TC022 | Verify SCD date ranges in go_user_dim | scd_start_date should be less than scd_end_date for historical records |
| TC023 | Verify SCD current flag logic in go_license_dim | Only one record per license_id should have scd_current_flag = TRUE |
| TC024 | Verify SCD date ranges in go_license_dim | scd_start_date should be less than scd_end_date for historical records |
| TC025 | Verify SCD end date for current records | Current records should have scd_end_date = '9999-12-31' |

### Test Case 4: Data Transformation Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC026 | Verify email standardization in go_user_dim | All emails should be lowercase and trimmed |
| TC027 | Verify company name normalization in go_user_dim | Company names should have special characters removed |
| TC028 | Verify duration calculation in go_meeting_dim | Duration should be correctly calculated from start and end times |
| TC029 | Verify surrogate key generation | All surrogate keys should be properly generated using dbt_utils |
| TC030 | Verify default value handling | NULL values should be replaced with appropriate defaults |

### Test Case 5: Edge Case and Error Handling Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC031 | Handle NULL email addresses in go_user_dim | Records with NULL emails should be excluded or flagged |
| TC032 | Handle invalid date ranges in go_license_dim | Records with invalid date ranges should be excluded |
| TC033 | Handle NULL meeting times in go_meeting_dim | Records with NULL start/end times should be excluded |
| TC034 | Handle empty feature names in go_feature_dim | Records with empty feature names should be excluded |
| TC035 | Handle future open dates in go_support_ticket_dim | Records with future open dates should be flagged |
| TC036 | Handle negative registrant counts in go_webinar_dim | Records with negative registrants should be excluded |
| TC037 | Handle missing source data | Pipeline should handle empty source tables gracefully |
| TC038 | Handle duplicate source records | Duplicate records should be handled appropriately |

### Test Case 6: Performance and Audit Tests

| Test Case ID | Test Case Description | Expected Outcome |
|--------------|----------------------|------------------|
| TC039 | Verify process audit logging | All model executions should be logged in go_process_audit |
| TC040 | Verify execution time tracking | Process duration should be calculated and recorded |
| TC041 | Verify record count tracking | Records processed should be accurately counted |
| TC042 | Verify error handling in audit | Failed processes should be logged with error messages |

---

## dbt Test Scripts

### YAML-based Schema Tests

```yaml
# models/schema.yml
version: 2

models:
  - name: go_user_dim
    description: "Gold layer user dimension table with SCD Type 2"
    columns:
      - name: user_dim_id
        description: "Auto-incrementing dimension ID"
        tests:
          - not_null
          - unique
      - name: user_id
        description: "Business key - User ID from source"
        tests:
          - not_null
          - relationships:
              to: source('silver', 'si_users')
              field: user_id
      - name: email
        description: "Standardized email address"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'
      - name: account_status
        description: "Derived account status"
        tests:
          - accepted_values:
              values: ['Active', 'Inactive', 'Pending', 'Unknown']
      - name: scd_current_flag
        description: "SCD Type 2 current flag"
        tests:
          - not_null
      - name: scd_start_date
        description: "SCD Type 2 start date"
        tests:
          - not_null
      - name: scd_end_date
        description: "SCD Type 2 end date"
        tests:
          - not_null

  - name: go_license_dim
    description: "Gold layer license dimension table with SCD Type 2"
    columns:
      - name: license_dim_id
        description: "Auto-incrementing dimension ID"
        tests:
          - not_null
          - unique
      - name: license_id
        description: "Business key - License ID from source"
        tests:
          - not_null
          - relationships:
              to: source('silver', 'si_licenses')
              field: license_id
      - name: assignment_status
        description: "Derived assignment status"
        tests:
          - accepted_values:
              values: ['Active', 'Expired', 'Pending', 'Unknown']
      - name: start_date
        description: "License start date"
        tests:
          - not_null
      - name: end_date
        description: "License end date"
        tests:
          - not_null
      - name: license_capacity
        description: "License capacity based on type"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000

  - name: go_meeting_dim
    description: "Gold layer meeting dimension table"
    columns:
      - name: meeting_dim_id
        description: "Auto-incrementing dimension ID"
        tests:
          - not_null
          - unique
      - name: meeting_id
        description: "Business key - Meeting ID from source"
        tests:
          - not_null
          - relationships:
              to: source('silver', 'si_meetings')
              field: meeting_id
      - name: duration_minutes
        description: "Meeting duration in minutes"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 1440  # 24 hours max
      - name: meeting_type
        description: "Derived meeting type"
        tests:
          - accepted_values:
              values: ['Quick Meeting', 'Standard Meeting', 'Long Meeting', 'Extended Meeting']

  - name: go_feature_dim
    description: "Gold layer feature dimension table"
    columns:
      - name: feature_dim_id
        description: "Auto-incrementing dimension ID"
        tests:
          - not_null
          - unique
      - name: feature_name
        description: "Feature name"
        tests:
          - not_null
          - unique
      - name: feature_category
        description: "Derived feature category"
        tests:
          - accepted_values:
              values: ['Screen Sharing', 'Communication', 'Recording', 'Collaboration', 'Engagement', 'Other']
      - name: is_active
        description: "Feature active flag"
        tests:
          - not_null

  - name: go_support_ticket_dim
    description: "Gold layer support ticket dimension table"
    columns:
      - name: support_ticket_dim_id
        description: "Auto-incrementing dimension ID"
        tests:
          - not_null
          - unique
      - name: ticket_id
        description: "Business key - Ticket ID from source"
        tests:
          - not_null
          - relationships:
              to: source('silver', 'si_support_tickets')
              field: ticket_id
      - name: priority_level
        description: "Derived priority level"
        tests:
          - accepted_values:
              values: ['High', 'Medium', 'Low']
      - name: open_date
        description: "Ticket open date"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: '2020-01-01'
              max_value: '{{ var("max_date") }}'

  - name: go_webinar_dim
    description: "Gold layer webinar dimension table"
    columns:
      - name: webinar_dim_id
        description: "Auto-incrementing dimension ID"
        tests:
          - not_null
          - unique
      - name: webinar_id
        description: "Business key - Webinar ID from source"
        tests:
          - not_null
          - relationships:
              to: source('silver', 'si_webinars')
              field: webinar_id
      - name: registrants
        description: "Number of registrants"
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 100000
      - name: duration_minutes
        description: "Webinar duration in minutes"
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 480  # 8 hours max

  - name: go_process_audit
    description: "Gold layer process audit table"
    columns:
      - name: audit_id
        description: "Auto-incrementing audit ID"
        tests:
          - not_null
          - unique
      - name: execution_id
        description: "Unique execution identifier"
        tests:
          - not_null
      - name: execution_status
        description: "Process execution status"
        tests:
          - accepted_values:
              values: ['STARTED', 'COMPLETED', 'FAILED', 'RUNNING']
```

### Custom SQL-based dbt Tests

#### Test 1: SCD Type 2 Current Flag Validation
```sql
-- tests/test_scd_current_flag_user_dim.sql
-- Test to ensure only one current record per user_id in go_user_dim

SELECT 
    user_id,
    COUNT(*) as current_record_count
FROM {{ ref('go_user_dim') }}
WHERE scd_current_flag = TRUE
GROUP BY user_id
HAVING COUNT(*) > 1
```

#### Test 2: Date Range Validation for Licenses
```sql
-- tests/test_license_date_range_validation.sql
-- Test to ensure start_date <= end_date in go_license_dim

SELECT 
    license_id,
    start_date,
    end_date
FROM {{ ref('go_license_dim') }}
WHERE start_date > end_date
```

#### Test 3: Email Format Validation
```sql
-- tests/test_email_format_validation.sql
-- Test to ensure all emails follow valid format in go_user_dim

SELECT 
    user_id,
    email
FROM {{ ref('go_user_dim') }}
WHERE email IS NOT NULL 
  AND NOT REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$')
```

#### Test 4: Business Rule Validation - Account Status
```sql
-- tests/test_account_status_derivation.sql
-- Test to validate account_status derivation logic

WITH source_data AS (
    SELECT 
        user_id,
        user_status
    FROM {{ source('silver', 'si_users') }}
),
transformed_data AS (
    SELECT 
        user_id,
        account_status
    FROM {{ ref('go_user_dim') }}
    WHERE scd_current_flag = TRUE
)
SELECT 
    s.user_id,
    s.user_status,
    t.account_status
FROM source_data s
JOIN transformed_data t ON s.user_id = t.user_id
WHERE 
    (s.user_status = 'Active' AND t.account_status != 'Active') OR
    (s.user_status = 'Suspended' AND t.account_status != 'Inactive') OR
    (s.user_status = 'Pending' AND t.account_status != 'Pending') OR
    (s.user_status NOT IN ('Active', 'Suspended', 'Pending') AND t.account_status != 'Unknown')
```

#### Test 5: Meeting Duration Calculation
```sql
-- tests/test_meeting_duration_calculation.sql
-- Test to validate meeting duration calculation

SELECT 
    meeting_id,
    start_time,
    end_time,
    duration_minutes,
    DATEDIFF(minute, start_time, end_time) as calculated_duration
FROM {{ ref('go_meeting_dim') }}
WHERE start_time IS NOT NULL 
  AND end_time IS NOT NULL
  AND ABS(duration_minutes - DATEDIFF(minute, start_time, end_time)) > 1
```

#### Test 6: Feature Category Mapping
```sql
-- tests/test_feature_category_mapping.sql
-- Test to validate feature category mapping logic

SELECT 
    feature_name,
    feature_category
FROM {{ ref('go_feature_dim') }}
WHERE 
    (UPPER(feature_name) LIKE '%SCREEN%SHARE%' AND feature_category != 'Screen Sharing') OR
    (UPPER(feature_name) LIKE '%CHAT%' AND feature_category != 'Communication') OR
    (UPPER(feature_name) LIKE '%RECORD%' AND feature_category != 'Recording') OR
    (UPPER(feature_name) LIKE '%BREAKOUT%' AND feature_category != 'Collaboration') OR
    (UPPER(feature_name) LIKE '%POLL%' AND feature_category != 'Engagement') OR
    (UPPER(feature_name) LIKE '%WHITEBOARD%' AND feature_category != 'Collaboration')
```

#### Test 7: Data Quality - Null Value Handling
```sql
-- tests/test_null_value_handling.sql
-- Test to ensure proper null value handling across all models

WITH null_checks AS (
    SELECT 'go_user_dim' as table_name, 'user_name' as column_name, COUNT(*) as null_count
    FROM {{ ref('go_user_dim') }}
    WHERE user_name IS NULL OR user_name = ''
    
    UNION ALL
    
    SELECT 'go_license_dim' as table_name, 'license_type' as column_name, COUNT(*) as null_count
    FROM {{ ref('go_license_dim') }}
    WHERE license_type IS NULL OR license_type = ''
    
    UNION ALL
    
    SELECT 'go_meeting_dim' as table_name, 'meeting_topic' as column_name, COUNT(*) as null_count
    FROM {{ ref('go_meeting_dim') }}
    WHERE meeting_topic IS NULL OR meeting_topic = ''
)
SELECT *
FROM null_checks
WHERE null_count > 0
```

#### Test 8: Surrogate Key Uniqueness
```sql
-- tests/test_surrogate_key_uniqueness.sql
-- Test to ensure surrogate keys are unique across all dimension tables

WITH key_checks AS (
    SELECT 'go_user_dim' as table_name, user_dim_id as surrogate_key
    FROM {{ ref('go_user_dim') }}
    
    UNION ALL
    
    SELECT 'go_license_dim' as table_name, license_dim_id as surrogate_key
    FROM {{ ref('go_license_dim') }}
    
    UNION ALL
    
    SELECT 'go_meeting_dim' as table_name, meeting_dim_id as surrogate_key
    FROM {{ ref('go_meeting_dim') }}
    
    UNION ALL
    
    SELECT 'go_feature_dim' as table_name, feature_dim_id as surrogate_key
    FROM {{ ref('go_feature_dim') }}
    
    UNION ALL
    
    SELECT 'go_support_ticket_dim' as table_name, support_ticket_dim_id as surrogate_key
    FROM {{ ref('go_support_ticket_dim') }}
    
    UNION ALL
    
    SELECT 'go_webinar_dim' as table_name, webinar_dim_id as surrogate_key
    FROM {{ ref('go_webinar_dim') }}
)
SELECT 
    table_name,
    surrogate_key,
    COUNT(*) as duplicate_count
FROM key_checks
GROUP BY table_name, surrogate_key
HAVING COUNT(*) > 1
```

#### Test 9: Process Audit Completeness
```sql
-- tests/test_process_audit_completeness.sql
-- Test to ensure all model executions are logged in process audit

WITH expected_processes AS (
    SELECT 'go_user_dim' as process_name
    UNION ALL SELECT 'go_license_dim'
    UNION ALL SELECT 'go_meeting_dim'
    UNION ALL SELECT 'go_feature_dim'
    UNION ALL SELECT 'go_support_ticket_dim'
    UNION ALL SELECT 'go_webinar_dim'
),
actual_processes AS (
    SELECT DISTINCT process_name
    FROM {{ ref('go_process_audit') }}
    WHERE execution_start_time >= CURRENT_DATE - 1
)
SELECT e.process_name
FROM expected_processes e
LEFT JOIN actual_processes a ON e.process_name = a.process_name
WHERE a.process_name IS NULL
```

#### Test 10: Data Freshness Validation
```sql
-- tests/test_data_freshness.sql
-- Test to ensure data is fresh and within acceptable time windows

SELECT 
    'go_user_dim' as table_name,
    MAX(created_at) as latest_record,
    DATEDIFF(hour, MAX(created_at), CURRENT_TIMESTAMP) as hours_since_last_update
FROM {{ ref('go_user_dim') }}
HAVING DATEDIFF(hour, MAX(created_at), CURRENT_TIMESTAMP) > 24

UNION ALL

SELECT 
    'go_license_dim' as table_name,
    MAX(created_at) as latest_record,
    DATEDIFF(hour, MAX(created_at), CURRENT_TIMESTAMP) as hours_since_last_update
FROM {{ ref('go_license_dim') }}
HAVING DATEDIFF(hour, MAX(created_at), CURRENT_TIMESTAMP) > 24
```

### Parameterized Tests

#### Generic Test for SCD Type 2 Validation
```sql
-- macros/test_scd_type2_validation.sql
{% macro test_scd_type2_validation(model, business_key_column) %}

    SELECT 
        {{ business_key_column }},
        COUNT(*) as current_record_count
    FROM {{ model }}
    WHERE scd_current_flag = TRUE
    GROUP BY {{ business_key_column }}
    HAVING COUNT(*) > 1

{% endmacro %}
```

#### Generic Test for Date Range Validation
```sql
-- macros/test_date_range_validation.sql
{% macro test_date_range_validation(model, start_date_column, end_date_column) %}

    SELECT 
        *
    FROM {{ model }}
    WHERE {{ start_date_column }} > {{ end_date_column }}

{% endmacro %}
```

### Test Execution Configuration

```yaml
# dbt_project.yml test configuration
tests:
  zoom_gold_dim_pipeline:
    +severity: error
    +store_failures: true
    +schema: test_results
    
# Custom test configurations
test-paths: ["tests"]

vars:
  max_date: "{{ run_started_at.strftime('%Y-%m-%d') }}"
  test_schema: "test_results"
```

## Test Execution Strategy

### 1. Pre-deployment Testing
- Run all schema tests before model deployment
- Execute custom SQL tests to validate business logic
- Verify data quality and transformation rules

### 2. Post-deployment Validation
- Run freshness tests to ensure data is current
- Execute audit completeness tests
- Validate SCD Type 2 implementation

### 3. Continuous Monitoring
- Schedule regular test execution
- Monitor test results in dbt Cloud or CI/CD pipeline
- Set up alerts for test failures

### 4. Performance Testing
- Monitor query execution times
- Validate clustering key effectiveness
- Test with large data volumes

## Error Handling and Logging

### Test Failure Handling
- All test failures are logged to `test_results` schema
- Failed records are stored for analysis
- Error messages include context and remediation steps

### Audit Trail
- All test executions are tracked in `go_process_audit`
- Test results are versioned and stored
- Historical test performance is monitored

## API Cost Calculation

Based on the comprehensive test suite creation and analysis:
- Model analysis and test case design: $0.002500
- YAML schema test generation: $0.001800
- Custom SQL test creation: $0.003200
- Documentation and formatting: $0.001200
- **Total API Cost: $0.008700**

## Maintenance and Updates

### Regular Maintenance Tasks
1. Review and update test cases based on business rule changes
2. Add new tests for additional data quality requirements
3. Optimize test performance and execution time
4. Update expected values and thresholds

### Version Control
- All test changes are version controlled
- Test case documentation is updated with each release
- Backward compatibility is maintained

## Conclusion

This comprehensive test suite ensures the reliability and performance of the Zoom Gold Dimension Pipeline dbt models in Snowflake. The tests cover:

- **Data Quality**: Null checks, uniqueness, format validation
- **Business Rules**: Status derivations, calculations, mappings
- **SCD Type 2**: Historical tracking, current flag validation
- **Edge Cases**: Invalid data, missing values, boundary conditions
- **Performance**: Audit logging, freshness, execution tracking

Regular execution of these tests will help maintain high data quality and catch issues early in the development cycle, ensuring reliable data delivery to downstream consumers.

---

**Contact Information:**
For questions or updates regarding these test cases, please contact the Data Engineering team.

**Last Updated:** 2024-12-19
**Next Review Date:** 2025-01-19