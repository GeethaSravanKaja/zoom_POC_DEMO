# Zoom Platform Analytics System - Model Data Constraints

**Author:** AAVA  
**Version:** 1  
**Date:** 2024  
**Purpose:** Define data expectations, constraints, and business rules for the Zoom Platform Analytics System to ensure data integrity, compliance, and accurate reporting.

---

## 1. DATA EXPECTATIONS

### 1.1 User Data Expectations
- **User_ID**: Must be unique, non-null identifier for each user
- **Plan_Type**: Expected values include 'Free', 'Basic', 'Pro', 'Business', 'Enterprise'
- **Email**: Must follow valid email format (user@domain.com)
- **User_Name**: Should be non-empty string, properly formatted
- **Company**: Optional field, but when present should be non-empty
- **Registration_Date**: Must be valid timestamp, cannot be future date

### 1.2 Meeting Data Expectations
- **Meeting_ID**: Must be unique, non-null identifier for each meeting
- **Host_ID**: Must reference valid User_ID from Users table
- **Duration_Minutes**: Expected to be non-negative integer, reasonable upper bound (e.g., ≤ 1440 minutes/24 hours)
- **Start_Time**: Must be valid timestamp
- **End_Time**: Must be valid timestamp, should be after Start_Time
- **Meeting_Type**: Expected values include 'Scheduled', 'Instant', 'Recurring', 'Webinar'

### 1.3 Attendee Data Expectations
- **Meeting_ID**: Must reference valid Meeting_ID from Meetings table
- **User_ID**: Must reference valid User_ID from Users table
- **Join_Time**: Must be valid timestamp, should be >= Meeting Start_Time
- **Leave_Time**: Must be valid timestamp, should be >= Join_Time and <= Meeting End_Time

### 1.4 Features Usage Data Expectations
- **Meeting_ID**: Must reference valid Meeting_ID from Meetings table
- **Feature_Name**: Expected values include 'Screen_Share', 'Recording', 'Chat', 'Breakout_Rooms', 'Whiteboard', 'Polls'
- **Usage_Count**: Must be positive integer
- **Usage_Duration**: When applicable, must be non-negative integer

### 1.5 Support Tickets Data Expectations
- **Ticket_ID**: Must be unique, non-null identifier
- **User_ID**: Must reference valid User_ID from Users table
- **Ticket_Type**: Expected values include 'Audio_Issues', 'Video_Issues', 'Connectivity', 'Login_Problems', 'Billing', 'Feature_Request'
- **Resolution_Status**: Expected values include 'Open', 'In_Progress', 'Resolved', 'Closed', 'Escalated'
- **Open_Date**: Must be valid timestamp, cannot be future date
- **Close_Date**: When present, must be valid timestamp >= Open_Date

### 1.6 Billing Events Data Expectations
- **Event_ID**: Must be unique, non-null identifier
- **User_ID**: Must reference valid User_ID from Users table
- **Event_Type**: Expected values include 'Subscription', 'Upgrade', 'Downgrade', 'Cancellation', 'Payment', 'Refund'
- **Amount**: Must be positive decimal number for charges, negative for refunds
- **Event_Date**: Must be valid timestamp
- **Currency**: Expected values include 'USD', 'EUR', 'GBP', etc.

### 1.7 Licenses Data Expectations
- **License_ID**: Must be unique, non-null identifier
- **License_Type**: Expected values include 'Basic', 'Pro', 'Business', 'Enterprise', 'Developer'
- **Assigned_To_User_ID**: When assigned, must reference valid User_ID from Users table
- **Start_Date**: Must be valid date
- **End_Date**: Must be valid date >= Start_Date
- **Status**: Expected values include 'Active', 'Expired', 'Suspended', 'Available'

---

## 2. CONSTRAINTS

### 2.1 Primary Key Constraints
- **Users.User_ID**: PRIMARY KEY, NOT NULL, UNIQUE
- **Meetings.Meeting_ID**: PRIMARY KEY, NOT NULL, UNIQUE
- **Support_Tickets.Ticket_ID**: PRIMARY KEY, NOT NULL, UNIQUE
- **Billing_Events.Event_ID**: PRIMARY KEY, NOT NULL, UNIQUE
- **Licenses.License_ID**: PRIMARY KEY, NOT NULL, UNIQUE
- **Attendees**: COMPOSITE PRIMARY KEY (Meeting_ID, User_ID)
- **Features_Usage**: COMPOSITE PRIMARY KEY (Meeting_ID, Feature_Name)

### 2.2 Foreign Key Constraints
- **Meetings.Host_ID** → **Users.User_ID** (CASCADE ON UPDATE, RESTRICT ON DELETE)
- **Attendees.Meeting_ID** → **Meetings.Meeting_ID** (CASCADE ON DELETE)
- **Attendees.User_ID** → **Users.User_ID** (CASCADE ON UPDATE, RESTRICT ON DELETE)
- **Features_Usage.Meeting_ID** → **Meetings.Meeting_ID** (CASCADE ON DELETE)
- **Support_Tickets.User_ID** → **Users.User_ID** (CASCADE ON UPDATE, RESTRICT ON DELETE)
- **Billing_Events.User_ID** → **Users.User_ID** (CASCADE ON UPDATE, RESTRICT ON DELETE)
- **Licenses.Assigned_To_User_ID** → **Users.User_ID** (CASCADE ON UPDATE, SET NULL ON DELETE)

### 2.3 Data Type Constraints
- **Duration_Minutes**: INTEGER, CHECK (Duration_Minutes >= 0 AND Duration_Minutes <= 1440)
- **Usage_Count**: INTEGER, CHECK (Usage_Count > 0)
- **Amount**: DECIMAL(10,2), CHECK (Amount != 0)
- **Email**: VARCHAR(255), CHECK (Email LIKE '%@%.%')
- **Start_Time, End_Time, Event_Date, Open_Date, Close_Date**: TIMESTAMP
- **Start_Date, End_Date**: DATE

### 2.4 Check Constraints
- **Meetings**: CHECK (End_Time > Start_Time)
- **Attendees**: CHECK (Leave_Time >= Join_Time)
- **Support_Tickets**: CHECK (Close_Date IS NULL OR Close_Date >= Open_Date)
- **Licenses**: CHECK (End_Date >= Start_Date)
- **Billing_Events**: CHECK ((Event_Type IN ('Payment', 'Subscription', 'Upgrade') AND Amount > 0) OR (Event_Type IN ('Refund', 'Cancellation') AND Amount < 0))

### 2.5 Unique Constraints
- **Users.Email**: UNIQUE (one email per user account)
- **Meetings.Meeting_ID**: UNIQUE across all meeting records
- **Support_Tickets.Ticket_ID**: UNIQUE across all support tickets

### 2.6 Not Null Constraints
- **Users**: User_ID, Email, Plan_Type, Registration_Date
- **Meetings**: Meeting_ID, Host_ID, Start_Time, Duration_Minutes
- **Attendees**: Meeting_ID, User_ID, Join_Time
- **Features_Usage**: Meeting_ID, Feature_Name, Usage_Count
- **Support_Tickets**: Ticket_ID, User_ID, Ticket_Type, Resolution_Status, Open_Date
- **Billing_Events**: Event_ID, User_ID, Event_Type, Amount, Event_Date
- **Licenses**: License_ID, License_Type, Start_Date, End_Date, Status

---

## 3. BUSINESS RULES

### 3.1 User Management Rules
- **BR001**: A user can only have one active account per email address
- **BR002**: Free plan users are limited to meetings with maximum 40 minutes duration
- **BR003**: User registration date cannot be in the future
- **BR004**: User plan type determines feature access and meeting limitations
- **BR005**: Users must have valid email addresses for account creation and communication

### 3.2 Meeting Management Rules
- **BR006**: Meeting duration must be calculated as the difference between End_Time and Start_Time
- **BR007**: A meeting host must be a registered user in the system
- **BR008**: Meeting attendees cannot join before the meeting starts or after it ends
- **BR009**: Meeting duration for Free users cannot exceed 40 minutes for group meetings (>2 participants)
- **BR010**: Recurring meetings must maintain consistent Meeting_ID pattern for tracking
- **BR011**: Meeting End_Time must be after Start_Time

### 3.3 Feature Usage Rules
- **BR012**: Feature usage can only be recorded for active meetings
- **BR013**: Screen sharing and recording features may be restricted based on user plan type
- **BR014**: Feature adoption rate calculations must exclude deleted or inactive users
- **BR015**: Usage count must be positive and realistic (e.g., screen share count ≤ meeting duration in minutes)

### 3.4 Support Ticket Rules
- **BR016**: Support tickets can only be created by registered users
- **BR017**: Ticket resolution time calculation excludes weekends and holidays
- **BR018**: Escalated tickets must have been open for minimum 24 hours
- **BR019**: Closed tickets cannot be reopened; new tickets must be created for follow-up issues
- **BR020**: Ticket types must align with predefined categories for proper routing

### 3.5 Billing and Revenue Rules
- **BR021**: Billing events must be associated with valid user accounts
- **BR022**: Subscription upgrades must result in positive amount billing events
- **BR023**: Refunds must be negative amounts and cannot exceed original payment
- **BR024**: Monthly Recurring Revenue (MRR) calculations must exclude one-time charges
- **BR025**: Currency must be consistent within user's billing region
- **BR026**: Payment events must precede service activation

### 3.6 License Management Rules
- **BR027**: License assignment requires active user account
- **BR028**: License end date must be after start date
- **BR029**: Expired licenses cannot be assigned to users
- **BR030**: License utilization rate calculation includes only assignable licenses
- **BR031**: Users cannot hold multiple licenses of the same type simultaneously
- **BR032**: License downgrades must respect existing meeting commitments

### 3.7 Data Quality Rules
- **BR033**: All timestamp fields must use consistent timezone (UTC recommended)
- **BR034**: Calculated metrics must be refreshed within defined SLA timeframes
- **BR035**: Data retention policies must be enforced (e.g., support tickets archived after 2 years)
- **BR036**: Personal data must be anonymized or masked for non-authorized users
- **BR037**: Audit trails must be maintained for all data modifications

### 3.8 Reporting and Analytics Rules
- **BR038**: Active user calculations must use consistent definition across all reports
- **BR039**: Feature adoption rates must be calculated against eligible user base only
- **BR040**: Revenue recognition must follow accounting standards and billing cycles
- **BR041**: Dashboard data must be refreshed at least daily for operational reports
- **BR042**: Historical data comparisons must account for plan changes and feature updates
- **BR043**: Access control must be enforced at the data level, not just UI level

### 3.9 Performance and Scalability Rules
- **BR044**: Query performance for reports must not exceed 30 seconds for standard timeframes
- **BR045**: Data aggregations must be pre-calculated for frequently accessed metrics
- **BR046**: Archive old data to maintain optimal query performance
- **BR047**: Index maintenance must be performed regularly on high-traffic tables

### 3.10 Security and Compliance Rules
- **BR048**: Role-based access control must be implemented for all sensitive data
- **BR049**: Data encryption must be applied to PII and financial information
- **BR050**: Audit logs must capture all data access and modification activities
- **BR051**: Data export capabilities must include appropriate access controls
- **BR052**: Compliance with data protection regulations (GDPR, CCPA) must be maintained

---

## IMPLEMENTATION NOTES

### Data Validation Priority
1. **Critical**: Primary keys, foreign keys, and referential integrity
2. **High**: Business rule violations that affect revenue or user experience
3. **Medium**: Data quality issues that impact reporting accuracy
4. **Low**: Formatting and standardization improvements

### Monitoring and Alerting
- Implement automated data quality checks for constraint violations
- Set up alerts for business rule violations that require immediate attention
- Monitor data freshness and completeness for critical reporting tables
- Track constraint violation trends to identify systemic issues

### Exception Handling
- Define clear procedures for handling constraint violations
- Establish data correction workflows for business rule exceptions
- Maintain documentation of approved exceptions and their justifications
- Regular review of exceptions to identify process improvements

This document serves as the foundation for ensuring data integrity and compliance within the Zoom Platform Analytics System, supporting accurate reporting and reliable business decision-making.