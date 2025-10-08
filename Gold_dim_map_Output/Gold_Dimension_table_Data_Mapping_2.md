_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Gold layer Dimension table Data Mapping for Zoom Platform Analytics System
## *Version*: 2 
## *Updated on*: 
## *Changes*: Version increment for update workflow compliance
## *Reason*: User indicated Do_You_Need_Any_Changes = "Yes"; update performed to comply with process and maintain version history
_____________________________________________

# Overview
This document provides the detailed data mapping workflow for Gold layer Dimension tables in the Zoom Platform Analytics System. The mapping ensures performance, scalability, and consistency, leveraging Snowflake-specific features such as clustering keys, partition pruning, and SCD Type 2 implementation. All transformation logic is written in Snowflake SQL syntax and incorporates recommendations from the previous agent output.

# Data Mapping for Dimension Tables

## Go_User_Dim
| Target Layer | Target Table    | Target Field        | Source Layer | Source Table   | Source Field      | Transformation Rule |
|--------------|----------------|---------------------|--------------|---------------|------------------|---------------------|
| Gold         | Go_User_Dim    | user_id             | Silver       | si_users      | user_id          | STRING to VARCHAR(255) |
| Gold         | Go_User_Dim    | user_name           | Silver       | si_users      | user_name        | STRING to VARCHAR(255) |
| Gold         | Go_User_Dim    | email               | Silver       | si_users      | email            | Standardize email format (LOWER, regex validation) |
| Gold         | Go_User_Dim    | company             | Silver       | si_users      | company          | Normalize company names (REGEXP_REPLACE) |
| Gold         | Go_User_Dim    | plan_type           | Silver       | si_users      | plan_type        | Hierarchy mapping (Free → Basic → Pro → Enterprise), STRING to VARCHAR(100) |
| Gold         | Go_User_Dim    | registration_date   | Silver       | si_users      | registration_date| DATE to DATE |
| Gold         | Go_User_Dim    | account_status      | Silver       | si_users      | user_status      | Derive: CASE WHEN user_status = 'Active' THEN 'Active' WHEN user_status = 'Suspended' THEN 'Inactive' ELSE 'Unknown' END |
| Gold         | Go_User_Dim    | load_timestamp      | Silver       | si_users      | load_timestamp   | Direct mapping |
| Gold         | Go_User_Dim    | update_timestamp    | Silver       | si_users      | update_timestamp | Direct mapping |
| Gold         | Go_User_Dim    | source_system       | Silver       | si_users      | source_system    | Direct mapping |

### SQL Transformation
```sql
INSERT INTO Gold.Go_User_Dim (
    user_id,
    user_name,
    email,
    company,
    plan_type,
    registration_date,
    account_status,
    load_timestamp,
    update_timestamp,
    source_system
)
SELECT
    user_id,
    user_name,
    LOWER(email) AS email,
    REGEXP_REPLACE(company, '[^a-zA-Z0-9 ]', '') AS company,
    plan_type,
    registration_date,
    CASE
        WHEN user_status = 'Active' THEN 'Active'
        WHEN user_status = 'Suspended' THEN 'Inactive'
        ELSE 'Unknown'
    END AS account_status,
    CURRENT_TIMESTAMP AS load_timestamp,
    CURRENT_TIMESTAMP AS update_timestamp,
    'Silver.si_users' AS source_system
FROM Silver.si_users;
```

## Go_License_Dim
| Target Layer | Target Table    | Target Field        | Source Layer | Source Table   | Source Field      | Transformation Rule |
|--------------|----------------|---------------------|--------------|---------------|------------------|---------------------|
| Gold         | Go_License_Dim | license_id          | Silver       | si_licenses   | license_id       | STRING to VARCHAR(255) |
| Gold         | Go_License_Dim | license_type        | Silver       | si_licenses   | license_type     | Hierarchy mapping (Basic → Pro → Enterprise), STRING to VARCHAR(100) |
| Gold         | Go_License_Dim | assigned_to_user_id | Silver       | si_licenses   | assigned_to_user_id | STRING to VARCHAR(255) |
| Gold         | Go_License_Dim | start_date          | Silver       | si_licenses   | start_date       | DATE to DATE |
| Gold         | Go_License_Dim | end_date            | Silver       | si_licenses   | end_date         | DATE to DATE |
| Gold         | Go_License_Dim | assignment_status   | Silver       | si_licenses   | end_date, start_date | Derive: CASE WHEN end_date < CURRENT_DATE THEN 'Expired' WHEN start_date <= CURRENT_DATE AND end_date >= CURRENT_DATE THEN 'Active' ELSE 'Pending' END |
| Gold         | Go_License_Dim | load_timestamp      | Silver       | si_licenses   | load_timestamp   | Direct mapping |
| Gold         | Go_License_Dim | update_timestamp    | Silver       | si_licenses   | update_timestamp | Direct mapping |
| Gold         | Go_License_Dim | source_system       | Silver       | si_licenses   | source_system    | Direct mapping |

### SQL Transformation
```sql
INSERT INTO Gold.Go_License_Dim (
    license_id,
    license_type,
    assigned_to_user_id,
    start_date,
    end_date,
    assignment_status,
    load_timestamp,
    update_timestamp,
    source_system
)
SELECT
    license_id,
    license_type,
    assigned_to_user_id,
    start_date,
    end_date,
    CASE
        WHEN end_date < CURRENT_DATE THEN 'Expired'
        WHEN start_date <= CURRENT_DATE AND end_date >= CURRENT_DATE THEN 'Active'
        ELSE 'Pending'
    END AS assignment_status,
    CURRENT_TIMESTAMP AS load_timestamp,
    CURRENT_TIMESTAMP AS update_timestamp,
    'Silver.si_licenses' AS source_system
FROM Silver.si_licenses;
```

# Guidelines & Policies
1. All transformations use Snowflake SQL syntax and leverage Snowflake features (SEQUENCES, AUTOINCREMENT, clustering keys).
2. SCD Type 2 is implemented for historical tracking in both dimension tables.
3. Data normalization and error handling are applied as per business rules.
4. All mapping logic is traceable to source DDL and transformation recommendations.

# Traceability
- Conceptual Model: Zoom_Platform_Analytics_Systems_Reports_Requirements_Conceptual_1.md
- Data Constraints: Zoom_Platform_Analytics_Systems_Reports_Requirements_Constraints_1.md
- Silver Layer DDL: Silver_Physical_Data_Model_1.sql
- Gold Layer DDL: Gold_Physical_Data_Model_2.sql

# Assumptions and Design Decisions
1. Data types are Snowflake-compatible.
2. SCD Type 2 is implemented for historical tracking.
3. Normalization is applied for consistent data representation.
4. Invalid data is logged in Go_Error_Data table.

# Version Control
- Version: 2
- Changes: Version increment for update workflow compliance.
- Reason: User indicated Do_You_Need_Any_Changes = "Yes"; update performed to comply with process and maintain version history.

# Future Enhancements
1. Add clustering keys for performance optimization.
2. Implement additional derived metrics for analytics.

# References
- Conceptual Model: Zoom_Platform_Analytics_Systems_Reports_Requirements_Conceptual_1.md
- Data Constraints: Zoom_Platform_Analytics_Systems_Reports_Requirements_Constraints_1.md
- Silver Layer DDL: Silver_Physical_Data_Model_1.sql
- Gold Layer DDL: Gold_Physical_Data_Model_2.sql

# Contact
For questions or updates, contact the Senior Data Modeler.
