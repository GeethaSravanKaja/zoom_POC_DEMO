____________________________________________
## *Author*: AAVA
## *Created on*:   
## *Description*: Model Data Constraints for Zoom Platform Analytics System defining data expectations, constraints, and business rules
## *Version*: 1 
## *Updated on*: 
_____________________________________________

# Zoom Platform Analytics System - Model Data Constraints

## 1. Data Expectations

### 1.1 User Data Expectations
1. **User_ID**: Must be unique, non-null identifier for each user
2. **Plan_Type**: Expected values include 'Free', 'Basic', 'Pro', 'Business', 'Enterprise'
3. **Email**: Must follow valid email format (user@domain.com)
4. **User_Name**: Should be non-empty string, properly formatted
5. **Company**: Optional field, but when present should be non-empty
6. **Registration_Date**: Must be valid timestamp, cannot be future date

### 1.2 Meeting Data Expectations
1. **Meeting_ID**: Must be unique, non-null identifier for each meeting
2. **Host_ID**: Must reference valid User_ID from Users table
3. **Duration_Minutes**: Expected to be non-negative integer, reasonable upper bound (e.g., ≤ 1440 minutes/24 hours)
4. **Start_Time**: Must be valid timestamp
5. **End_Time**: Must be valid timestamp, should be after Start_Time
6. **Meeting_Type**: Expected values include 'Scheduled', 'Instant', 'Recurring', 'Webinar'

### 1.3 Attendee Data Expectations
1. **Meeting_ID**: Must reference valid Meeting_ID from Meetings table
2. **User_ID**: Must reference valid User_ID from Users table
3. **Join_Time**: Must be valid timestamp, should be >= Meeting Start_Time
4. **Leave_Time**: Must be valid timestamp, should be >= Join_Time and <= Meeting End_Time

### 1.4 Features Usage Data Expectations
1. **Meeting_ID**: Must reference valid Meeting_ID from Meetings table
2. **Feature_Name**: Expected values include 'Screen_Share', 'Recording', 'Chat', 'Breakout_Rooms', 'Whiteboard', 'Polls'
3. **Usage_Count**: Must be positive integer
4. **Usage_Duration**: When applicable, must be non-negative integer

### 1.5 Support Tickets Data Expectations
1. **Ticket_ID**: Must be unique, non-null identifier
2. **User_ID**: Must reference valid User_ID from Users table
3. **Ticket_Type**: Expected values include 'Audio_Issues', 'Video_Issues', 'Connectivity', 'Login_Problems', 'Billing', 'Feature_Request'
4. **Resolution_Status**: Expected values include 'Open', 'In_Progress', 'Resolved', 'Closed', 'Escalated'
5. **Open_Date**: Must be valid timestamp, cannot be future date
6. **Close_Date**: When present, must be valid timestamp >= Open_Date

### 1.6 Billing Events Data Expectations
1. **Event_ID**: Must be unique, non-null identifier
2. **User_ID**: Must reference valid User_ID from Users table
3. **Event_Type**: Expected values include 'Subscription', 'Upgrade', 'Downgrade', 'Cancellation', 'Payment', 'Refund'
4. **Amount**: Must be positive decimal number for charges, negative for refunds
5. **Event_Date**: Must be valid timestamp
6. **Currency**: Expected values include 'USD', 'EUR', 'GBP', etc.

### 1.7 Licenses Data Expectations
1. **License_ID**: Must be unique, non-null identifier
2. **License_Type**: Expected values include 'Basic', 'Pro', 'Business', 'Enterprise', 'Developer'
3. **Assigned_To_User_ID**: When assigned, must reference valid User_ID from Users table
4. **Start_Date**: Must be valid date
5. **End_Date**: Must be valid date >= Start_Date
6. **Status**: Expected values include 'Active', 'Expired', 'Suspended', 'Available'

## 2. Constraints

### 2.1 Primary Key Constraints
1. **Users.User_ID**: PRIMARY KEY, NOT NULL, UNIQUE
2. **Meetings.Meeting_ID**: PRIMARY KEY, NOT NULL, UNIQUE
3. **Support_Tickets.Ticket_ID**: PRIMARY KEY, NOT NULL, UNIQUE
4. **Billing_Events.Event_ID**: PRIMARY KEY, NOT NULL, UNIQUE
5. **Licenses.License_ID**: PRIMARY KEY, NOT NULL, UNIQUE
6. **Attendees**: COMPOSITE PRIMARY KEY (Meeting_ID, User_ID)
7. **Features_Usage**: COMPOSITE PRIMARY KEY (Meeting_ID, Feature_Name)

### 2.2 Foreign Key Constraints
1. **Meetings.Host_ID** → **Users.User_ID** (CASCADE ON UPDATE, RESTRICT ON DELETE)
2. **Attendees.Meeting_ID** → **Meetings.Meeting_ID** (CASCADE ON DELETE)
3. **Attendees.User_ID** → **Users.User_ID** (CASCADE ON UPDATE, RESTRICT ON DELETE)
4. **Features_Usage.Meeting_ID** → **Meetings.Meeting_ID** (CASCADE ON DELETE)
5. **Support_Tickets.User_ID** → **Users.User_ID** (CASCADE ON UPDATE, RESTRICT ON DELETE)
6. **Billing_Events.User_ID** → **Users.User_ID** (CASCADE ON UPDATE, RESTRICT ON DELETE)
7. **Licenses.Assigned_To_User_ID** → **Users.User_ID** (CASCADE ON UPDATE, SET NULL ON DELETE)

### 2.3 Data Type Constraints
1. **Duration_Minutes**: INTEGER, CHECK (Duration_Minutes >= 0 AND Duration_Minutes <= 1440)
2. **Usage_Count**: INTEGER, CHECK (Usage_Count > 0)
3. **Amount**: DECIMAL(10,2), CHECK (Amount != 0)
4. **Email**: VARCHAR(255), CHECK (Email LIKE '%@%.%')
5. **Start_Time, End_Time, Event_Date, Open_Date, Close_Date**: TIMESTAMP
6. **Start_Date, End_Date**: DATE

### 2.4 Check Constraints
1. **Meetings**: CHECK (End_Time > Start_Time)
2. **Attendees**: CHECK (Leave_Time >= Join_Time)
3. **Support_Tickets**: CHECK (Close_Date IS NULL OR Close_Date >= Open_Date)
4. **Licenses**: CHECK (End_Date >= Start_Date)
5. **Billing_Events**: CHECK ((Event_Type IN ('Payment', 'Subscription', 'Upgrade') AND Amount > 0) OR (Event_Type IN ('Refund', 'Cancellation') AND Amount < 0))

### 2.5 Uniqueness Constraints
1. **Users.Email**: UNIQUE (one email per user account)
2. **Meetings.Meeting_ID**: UNIQUE across all meeting records
3. **Support_Tickets.Ticket_ID**: UNIQUE across all support tickets

### 2.6 Mandatory Field Constraints
1. **Users**: User_ID, Email, Plan_Type, Registration_Date must be NOT NULL
2. **Meetings**: Meeting_ID, Host_ID, Start_Time, Duration_Minutes must be NOT NULL
3. **Attendees**: Meeting_ID, User_ID, Join_Time must be NOT NULL
4. **Features_Usage**: Meeting_ID, Feature_Name, Usage_Count must be NOT NULL
5. **Support_Tickets**: Ticket_ID, User_ID, Ticket_Type, Resolution_Status, Open_Date must be NOT NULL
6. **Billing_Events**: Event_ID, User_ID, Event_Type, Amount, Event_Date must be NOT NULL
7. **Licenses**: License_ID, License_Type, Start_Date, End_Date, Status must be NOT NULL

### 2.7 Referential Integrity Constraints
1. All Meeting_ID references in Attendees and Features_Usage must exist in Meetings table
2. All User_ID references must exist in Users table
3. Host_ID in Meetings must reference valid User_ID
4. Assigned_To_User_ID in Licenses must reference valid User_ID when not null

## 3. Business Rules

### 3.1 User Management Business Rules
1. **BR001**: A user can only have one active account per email address
2. **BR002**: Free plan users are limited to meetings with maximum 40 minutes duration for group meetings
3. **BR003**: User registration date cannot be in the future
4. **BR004**: User plan type determines feature access and meeting limitations
5. **BR005**: Users must have valid email addresses for account creation and communication
6. **BR006**: User account status must be tracked for lifecycle analysis

### 3.2 Meeting Management Business Rules
1. **BR007**: Meeting duration must be calculated as the difference between End_Time and Start_Time
2. **BR008**: A meeting host must be a registered user in the system
3. **BR009**: Meeting attendees cannot join before the meeting starts or after it ends
4. **BR010**: Meeting duration for Free users cannot exceed 40 minutes for group meetings (>2 participants)
5. **BR011**: Recurring meetings must maintain consistent Meeting_ID pattern for tracking
6. **BR012**: Meeting End_Time must be after Start_Time
7. **BR013**: Meeting capacity limits must be enforced based on plan type

### 3.3 Feature Usage Business Rules
1. **BR014**: Feature usage can only be recorded for active meetings
2. **BR015**: Screen sharing and recording features may be restricted based on user plan type
3. **BR016**: Feature adoption rate calculations must exclude deleted or inactive users
4. **BR017**: Usage count must be positive and realistic (e.g., screen share count ≤ meeting duration in minutes)
5. **BR018**: Feature usage tracking must align with meeting duration and participant count

### 3.4 Support Ticket Business Rules
1. **BR019**: Support tickets can only be created by registered users
2. **BR020**: Ticket resolution time calculation excludes weekends and holidays
3. **BR021**: Escalated tickets must have been open for minimum 24 hours
4. **BR022**: Closed tickets cannot be reopened; new tickets must be created for follow-up issues
5. **BR023**: Ticket types must align with predefined categories for proper routing
6. **BR024**: Priority levels must be assigned based on issue severity and user plan type

### 3.5 Billing and Revenue Business Rules
1. **BR025**: Billing events must be associated with valid user accounts
2. **BR026**: Subscription upgrades must result in positive amount billing events
3. **BR027**: Refunds must be negative amounts and cannot exceed original payment
4. **BR028**: Monthly Recurring Revenue (MRR) calculations must exclude one-time charges
5. **BR029**: Currency must be consistent within user's billing region
6. **BR030**: Payment events must precede service activation
7. **BR031**: Billing cycles must align with subscription terms

### 3.6 License Management Business Rules
1. **BR032**: License assignment requires active user account
2. **BR033**: License end date must be after start date
3. **BR034**: Expired licenses cannot be assigned to users
4. **BR035**: License utilization rate calculation includes only assignable licenses
5. **BR036**: Users cannot hold multiple licenses of the same type simultaneously
6. **BR037**: License downgrades must respect existing meeting commitments
7. **BR038**: License renewal notifications must be sent before expiration

### 3.7 Data Quality Business Rules
1. **BR039**: All timestamp fields must use consistent timezone (UTC recommended)
2. **BR040**: Calculated metrics must be refreshed within defined SLA timeframes
3. **BR041**: Data retention policies must be enforced (e.g., support tickets archived after 2 years)
4. **BR042**: Personal data must be anonymized or masked for non-authorized users
5. **BR043**: Audit trails must be maintained for all data modifications
6. **BR044**: Data validation must occur at point of entry and during processing

### 3.8 Reporting and Analytics Business Rules
1. **BR045**: Active user calculations must use consistent definition across all reports
2. **BR046**: Feature adoption rates must be calculated against eligible user base only
3. **BR047**: Revenue recognition must follow accounting standards and billing cycles
4. **BR048**: Dashboard data must be refreshed at least daily for operational reports
5. **BR049**: Historical data comparisons must account for plan changes and feature updates
6. **BR050**: Access control must be enforced at the data level, not just UI level

### 3.9 Performance and Scalability Business Rules
1. **BR051**: Query performance for reports must not exceed 30 seconds for standard timeframes
2. **BR052**: Data aggregations must be pre-calculated for frequently accessed metrics
3. **BR053**: Archive old data to maintain optimal query performance
4. **BR054**: Index maintenance must be performed regularly on high-traffic tables
5. **BR055**: Caching strategies must be implemented for frequently accessed data

### 3.10 Security and Compliance Business Rules
1. **BR056**: Role-based access control must be implemented for all sensitive data
2. **BR057**: Data encryption must be applied to PII and financial information
3. **BR058**: Audit logs must capture all data access and modification activities
4. **BR059**: Data export capabilities must include appropriate access controls
5. **BR060**: Compliance with data protection regulations (GDPR, CCPA) must be maintained
6. **BR061**: Data anonymization must be applied for analytics and reporting purposes