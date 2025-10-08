_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Silver Layer Data Mapping for Zoom Platform Analytics System
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# 1. Overview
The Silver Layer Data Mapping for the Zoom Platform Analytics System provides a comprehensive mapping from the Bronze Layer to the Silver Layer, ensuring data cleansing, validation, and business rule enforcement at the attribute level. This mapping is designed for Snowflake and incorporates recommendations from the initial Silver Layer Data Quality document.

# 2. Data Mapping for the Silver Layer
Below is the detailed mapping for each table, showing how Bronze Layer fields are transformed and validated in the Silver Layer. All rules are compatible with Snowflake SQL.

## 2.1 Users Table
| # | Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|---|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|---------------------|
| 1 | Silver | si_users | user_id | Bronze | bz_users | user_id | Not null, Unique | Direct mapping |
| 2 | Silver | si_users | user_name | Bronze | bz_users | user_name | None | Direct mapping |
| 3 | Silver | si_users | email | Bronze | bz_users | email | Not null, Unique, Valid format (@ and .) | Lowercase, trim spaces |
| 4 | Silver | si_users | company | Bronze | bz_users | company | None | Direct mapping |
| 5 | Silver | si_users | plan_type | Bronze | bz_users | plan_type | Not null, Domain ('Free','Basic','Pro','Business','Enterprise') | Direct mapping |
| 6 | Silver | si_users | load_timestamp | Bronze | bz_users | load_timestamp | None | Direct mapping |
| 7 | Silver | si_users | update_timestamp | Bronze | bz_users | update_timestamp | None | Direct mapping |
| 8 | Silver | si_users | source_system | Bronze | bz_users | source_system | None | Direct mapping |
| 9 | Silver | si_users | load_date | Derived | bz_users | load_timestamp | Not null | CAST(load_timestamp AS DATE) |
| 10 | Silver | si_users | update_date | Derived | bz_users | update_timestamp | None | CAST(update_timestamp AS DATE) |

## 2.2 Meetings Table
| # | Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|---|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|---------------------|
| 1 | Silver | si_meetings | meeting_id | Bronze | bz_meetings | meeting_id | Not null, Unique | Direct mapping |
| 2 | Silver | si_meetings | host_id | Bronze | bz_meetings | host_id | Not null, Referential Integrity (si_users.user_id) | Direct mapping |
| 3 | Silver | si_meetings | meeting_topic | Bronze | bz_meetings | meeting_topic | None | Direct mapping |
| 4 | Silver | si_meetings | start_time | Bronze | bz_meetings | start_time | Not null | Direct mapping |
| 5 | Silver | si_meetings | end_time | Bronze | bz_meetings | end_time | end_time > start_time | Direct mapping |
| 6 | Silver | si_meetings | duration_minutes | Bronze | bz_meetings | duration_minutes | Not null, Range (0-1440) | Direct mapping |
| 7 | Silver | si_meetings | load_timestamp | Bronze | bz_meetings | load_timestamp | None | Direct mapping |
| 8 | Silver | si_meetings | update_timestamp | Bronze | bz_meetings | update_timestamp | None | Direct mapping |
| 9 | Silver | si_meetings | source_system | Bronze | bz_meetings | source_system | None | Direct mapping |
| 10 | Silver | si_meetings | load_date | Derived | bz_meetings | load_timestamp | Not null | CAST(load_timestamp AS DATE) |
| 11 | Silver | si_meetings | update_date | Derived | bz_meetings | update_timestamp | None | CAST(update_timestamp AS DATE) |

## 2.3 Participants Table
| # | Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|---|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|---------------------|
| 1 | Silver | si_participants | participant_id | Bronze | bz_participants | participant_id | Not null, Unique | Direct mapping |
| 2 | Silver | si_participants | meeting_id | Bronze | bz_participants | meeting_id | Not null, Referential Integrity (si_meetings.meeting_id) | Direct mapping |
| 3 | Silver | si_participants | user_id | Bronze | bz_participants | user_id | Referential Integrity (si_users.user_id) | Direct mapping |
| 4 | Silver | si_participants | join_time | Bronze | bz_participants | join_time | Not null | Direct mapping |
| 5 | Silver | si_participants | leave_time | Bronze | bz_participants | leave_time | leave_time >= join_time | Direct mapping |
| 6 | Silver | si_participants | load_timestamp | Bronze | bz_participants | load_timestamp | None | Direct mapping |
| 7 | Silver | si_participants | update_timestamp | Bronze | bz_participants | update_timestamp | None | Direct mapping |
| 8 | Silver | si_participants | source_system | Bronze | bz_participants | source_system | None | Direct mapping |
| 9 | Silver | si_participants | load_date | Derived | bz_participants | load_timestamp | Not null | CAST(load_timestamp AS DATE) |
| 10 | Silver | si_participants | update_date | Derived | bz_participants | update_timestamp | None | CAST(update_timestamp AS DATE) |

## 2.4 Feature Usage Table
| # | Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|---|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|---------------------|
| 1 | Silver | si_feature_usage | usage_id | Bronze | bz_feature_usage | usage_id | Not null, Unique | Direct mapping |
| 2 | Silver | si_feature_usage | meeting_id | Bronze | bz_feature_usage | meeting_id | Referential Integrity (si_meetings.meeting_id) | Direct mapping |
| 3 | Silver | si_feature_usage | feature_name | Bronze | bz_feature_usage | feature_name | Domain ('Screen_Share','Recording','Chat','Breakout_Rooms','Whiteboard','Polls','Virtual Background') | Direct mapping |
| 4 | Silver | si_feature_usage | usage_count | Bronze | bz_feature_usage | usage_count | usage_count > 0 | Direct mapping |
| 5 | Silver | si_feature_usage | usage_date | Bronze | bz_feature_usage | usage_date | Not null | Direct mapping |
| 6 | Silver | si_feature_usage | load_timestamp | Bronze | bz_feature_usage | load_timestamp | None | Direct mapping |
| 7 | Silver | si_feature_usage | update_timestamp | Bronze | bz_feature_usage | update_timestamp | None | Direct mapping |
| 8 | Silver | si_feature_usage | source_system | Bronze | bz_feature_usage | source_system | None | Direct mapping |
| 9 | Silver | si_feature_usage | load_date | Derived | bz_feature_usage | load_timestamp | Not null | CAST(load_timestamp AS DATE) |
| 10 | Silver | si_feature_usage | update_date | Derived | bz_feature_usage | update_timestamp | None | CAST(update_timestamp AS DATE) |

## 2.5 Webinars Table
| # | Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|---|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|---------------------|
| 1 | Silver | si_webinars | webinar_id | Bronze | bz_webinars | webinar_id | Not null, Unique | Direct mapping |
| 2 | Silver | si_webinars | host_id | Bronze | bz_webinars | host_id | Referential Integrity (si_users.user_id) | Direct mapping |
| 3 | Silver | si_webinars | webinar_topic | Bronze | bz_webinars | webinar_topic | None | Direct mapping |
| 4 | Silver | si_webinars | start_time | Bronze | bz_webinars | start_time | Not null | Direct mapping |
| 5 | Silver | si_webinars | end_time | Bronze | bz_webinars | end_time | end_time > start_time | Direct mapping |
| 6 | Silver | si_webinars | registrants | Bronze | bz_webinars | registrants | registrants >= 0 | Direct mapping |
| 7 | Silver | si_webinars | load_timestamp | Bronze | bz_webinars | load_timestamp | None | Direct mapping |
| 8 | Silver | si_webinars | update_timestamp | Bronze | bz_webinars | update_timestamp | None | Direct mapping |
| 9 | Silver | si_webinars | source_system | Bronze | bz_webinars | source_system | None | Direct mapping |
| 10 | Silver | si_webinars | load_date | Derived | bz_webinars | load_timestamp | Not null | CAST(load_timestamp AS DATE) |
| 11 | Silver | si_webinars | update_date | Derived | bz_webinars | update_timestamp | None | CAST(update_timestamp AS DATE) |

## 2.6 Support Tickets Table
| # | Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|---|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|---------------------|
| 1 | Silver | si_support_tickets | ticket_id | Bronze | bz_support_tickets | ticket_id | Not null, Unique | Direct mapping |
| 2 | Silver | si_support_tickets | user_id | Bronze | bz_support_tickets | user_id | Referential Integrity (si_users.user_id) | Direct mapping |
| 3 | Silver | si_support_tickets | ticket_type | Bronze | bz_support_tickets | ticket_type | Domain ('Audio_Issue','Video_Issue','Connectivity','Billing_Inquiry','Feature_Request','Account_Access') | Direct mapping |
| 4 | Silver | si_support_tickets | resolution_status | Bronze | bz_support_tickets | resolution_status | Domain ('Open','In Progress','Pending Customer','Closed','Resolved') | Direct mapping |
| 5 | Silver | si_support_tickets | open_date | Bronze | bz_support_tickets | open_date | open_date <= CURRENT_DATE() | Direct mapping |
| 6 | Silver | si_support_tickets | load_timestamp | Bronze | bz_support_tickets | load_timestamp | None | Direct mapping |
| 7 | Silver | si_support_tickets | update_timestamp | Bronze | bz_support_tickets | update_timestamp | None | Direct mapping |
| 8 | Silver | si_support_tickets | source_system | Bronze | bz_support_tickets | source_system | None | Direct mapping |
| 9 | Silver | si_support_tickets | load_date | Derived | bz_support_tickets | load_timestamp | Not null | CAST(load_timestamp AS DATE) |
| 10 | Silver | si_support_tickets | update_date | Derived | bz_support_tickets | update_timestamp | None | CAST(update_timestamp AS DATE) |

## 2.7 Licenses Table
| # | Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|---|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|---------------------|
| 1 | Silver | si_licenses | license_id | Bronze | bz_licenses | license_id | Not null, Unique | Direct mapping |
| 2 | Silver | si_licenses | license_type | Bronze | bz_licenses | license_type | Domain ('Pro','Business','Enterprise','Education','Developer') | Direct mapping |
| 3 | Silver | si_licenses | assigned_to_user_id | Bronze | bz_licenses | assigned_to_user_id | Referential Integrity (si_users.user_id) | Direct mapping |
| 4 | Silver | si_licenses | start_date | Bronze | bz_licenses | start_date | Not null | Direct mapping |
| 5 | Silver | si_licenses | end_date | Bronze | bz_licenses | end_date | end_date >= start_date | Direct mapping |
| 6 | Silver | si_licenses | load_timestamp | Bronze | bz_licenses | load_timestamp | None | Direct mapping |
| 7 | Silver | si_licenses | update_timestamp | Bronze | bz_licenses | update_timestamp | None | Direct mapping |
| 8 | Silver | si_licenses | source_system | Bronze | bz_licenses | source_system | None | Direct mapping |
| 9 | Silver | si_licenses | load_date | Derived | bz_licenses | load_timestamp | Not null | CAST(load_timestamp AS DATE) |
| 10 | Silver | si_licenses | update_date | Derived | bz_licenses | update_timestamp | None | CAST(update_timestamp AS DATE) |

## 2.8 Billing Events Table
| # | Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|---|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|---------------------|
| 1 | Silver | si_billing_events | event_id | Bronze | bz_billing_events | event_id | Not null, Unique | Direct mapping |
| 2 | Silver | si_billing_events | user_id | Bronze | bz_billing_events | user_id | Referential Integrity (si_users.user_id) | Direct mapping |
| 3 | Silver | si_billing_events | event_type | Bronze | bz_billing_events | event_type | Domain ('Subscription Fee','Subscription Renewal','Add-on Purchase','Refund') | Direct mapping |
| 4 | Silver | si_billing_events | amount | Bronze | bz_billing_events | amount | amount >= 0 (unless event_type = 'Refund') | Direct mapping |
| 5 | Silver | si_billing_events | event_date | Bronze | bz_billing_events | event_date | event_date <= CURRENT_DATE() | Direct mapping |
| 6 | Silver | si_billing_events | load_timestamp | Bronze | bz_billing_events | load_timestamp | None | Direct mapping |
| 7 | Silver | si_billing_events | update_timestamp | Bronze | bz_billing_events | update_timestamp | None | Direct mapping |
| 8 | Silver | si_billing_events | source_system | Bronze | bz_billing_events | source_system | None | Direct mapping |
| 9 | Silver | si_billing_events | load_date | Derived | bz_billing_events | load_timestamp | Not null | CAST(load_timestamp AS DATE) |
| 10 | Silver | si_billing_events | update_date | Derived | bz_billing_events | update_timestamp | None | CAST(update_timestamp AS DATE) |

## 2.9 Error Data Table
| # | Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|---|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|---------------------|
| 1 | Silver | si_error_data | error_id | Derived | - | - | Unique | Sequence/Autoincrement |
| 2 | Silver | si_error_data | error_type | Derived | - | - | Not null | Derived from DQ checks |
| 3 | Silver | si_error_data | error_description | Derived | - | - | Not null | Derived from DQ checks |
| 4 | Silver | si_error_data | source_table | Derived | - | - | Not null | Derived from DQ checks |
| 5 | Silver | si_error_data | error_timestamp | Derived | - | - | Not null | CURRENT_TIMESTAMP() |
| 6 | Silver | si_error_data | process_audit_info | Derived | - | - | None | Derived from audit process |
| 7 | Silver | si_error_data | status | Derived | - | - | None | Derived from DQ checks |
| 8 | Silver | si_error_data | load_date | Derived | - | - | Not null | CURRENT_DATE() |
| 9 | Silver | si_error_data | update_date | Derived | - | - | None | CURRENT_DATE() |
| 10 | Silver | si_error_data | source_system | Derived | - | - | None | Derived from audit process |

## 2.10 Audit Table
| # | Target Layer | Target Table | Target Field | Source Layer | Source Table | Source Field | Validation Rule | Transformation Rule |
|---|--------------|--------------|--------------|--------------|--------------|--------------|-----------------|---------------------|
| 1 | Silver | si_audit | execution_id | Derived | - | - | Not null, Unique | Derived from pipeline execution |
| 2 | Silver | si_audit | pipeline_name | Derived | - | - | Not null | Derived from pipeline execution |
| 3 | Silver | si_audit | start_time | Derived | - | - | Not null | Derived from pipeline execution |
| 4 | Silver | si_audit | end_time | Derived | - | - | Not null | Derived from pipeline execution |
| 5 | Silver | si_audit | status | Derived | - | - | Not null | Derived from pipeline execution |
| 6 | Silver | si_audit | error_message | Derived | - | - | None | Derived from pipeline execution |
| 7 | Silver | si_audit | load_date | Derived | - | - | Not null | CURRENT_DATE() |
| 8 | Silver | si_audit | update_date | Derived | - | - | None | CURRENT_DATE() |
| 9 | Silver | si_audit | source_system | Derived | - | - | None | Derived from pipeline execution |

# 3. Explanations for Complex Rules
- Email validation uses Snowflake LIKE operator for format checks.
- Referential integrity is enforced via JOIN checks in DQ pipelines, not physical constraints.
- Domain checks use IN clauses for allowed values.
- Date and timestamp logic is validated using Snowflake date functions.
- Error and audit tables are populated by DQ and pipeline processes for traceability.

# 4. Recommendations for Error Handling and Logging
1. All failed validations should be logged in si_error_data with error type, description, source table, and timestamp.
2. All pipeline executions should be logged in si_audit for traceability.
3. Use Snowflake Streams and Tasks for automated error and audit logging.

# 5. Metadata
_____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Silver Layer Data Mapping for Zoom Platform Analytics System
## *Version*: 1 
## *Updated on*: 
_____________________________________________
