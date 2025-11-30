# Kimball Dimensional Modeling Reference

Guide to Kimball data modeling techniques for Gold layer fact and dimension tables.

## Kimball Modeling Principles

Kimball modeling is the standard approach for designing fact tables and dimensions in the Gold layer.

### Core Concept: Star Schema

```
       d_partner
           ↑
           |
d_carrier ← f_booking → d_date
           |
           ↓
       d_user
```

**Characteristics**:
- Central fact table (f_booking)
- Surrounding dimension tables (d_partner, d_carrier, d_date, d_user)
- Facts reference dimensions via foreign keys
- Supports efficient SQL queries and BI tool performance

---

## Fact Tables

### Definition

A fact table contains measurements/facts of a business process:
- **Grain**: What does 1 row represent?
- **Facts**: Numeric measures (amounts, counts, durations)
- **Foreign Keys**: Links to dimensions
- **Attributes**: Descriptive info that should be in dimensions instead

### Designing a Fact Table

**Step 1: Identify the Business Process**
- What key event/transaction are we measuring?
- Examples: booking, redirect, payment, refund

**Step 2: Define the Grain**
- What does 1 row represent?
- Be as atomic as possible (event-level is better than aggregated)
- Examples:
  - 1 row = 1 booking transaction
  - 1 row = 1 user redirect event
  - 1 row = 1 day-user combination

**Step 3: Identify the Facts**
- What numeric measures do we capture?
- Must be numeric and additive (safe to sum)
- Examples:
  - `booking_amount`: Total revenue from booking
  - `commission_amount`: Commission earned
  - `discount_amount`: Discount applied
  - `duration_minutes`: Duration of event

**Step 4: Identify the Dimensions**
- What describes/contextualizes the facts?
- Foreign keys to dimension tables
- Examples:
  - `partner_id` (FK to d_partner)
  - `user_id` (FK to d_user)
  - `date_id` (FK to d_date)
  - `currency_id` (FK to d_currency)

**Step 5: Add Grain Keys**
- Primary key(s) that uniquely identify a row
- Must align with grain definition
- Examples:
  - `f_booking`: PK = `booking_id`
  - `f_daily_summary`: PK = `date_id, partner_id, user_segment_id`

### Fact Table Types

#### Transaction Fact Tables

**Definition**: One row per business transaction or event

**Characteristics**:
- Atomic/event-level grain
- High detail
- Often large (millions/billions of rows)
- Most common type

**Example**:
```
f_booking
├── booking_id (PK)
├── date_id (FK) → d_date
├── partner_id (FK) → d_partner
├── user_id (FK) → d_user
├── hotel_id (FK) → d_hotel
├── currency_id (FK) → d_currency
├── booking_amount (fact)
├── commission_amount (fact)
├── discount_amount (fact)
├── is_completed (flag)
└── booking_timestamp
```

**Use Cases**: User transactions, events, operational records

#### Snapshot Fact Tables

**Definition**: One row per entity at a specific point in time

**Characteristics**:
- Periodic/scheduled grain (daily, weekly, monthly)
- Pre-aggregated measures
- Predictable size

**Example**:
```
f_daily_user_summary
├── date_id (PK, FK) → d_date
├── user_id (PK, FK) → d_user
├── total_bookings (fact, SUM)
├── total_revenue (fact, SUM)
├── avg_booking_value (fact, AVG)
├── status (snapshot: ACTIVE, CHURNED, INACTIVE)
└── snapshot_date
```

**Use Cases**: Daily/weekly summaries, user cohort snapshots

#### Accumulating Fact Tables

**Definition**: Single row per process instance, updated as process progresses

**Characteristics**:
- One row per entity/process
- Multiple date columns (order date, ship date, delivery date)
- Updated as lifecycle progresses
- Tracks process completion

**Example**:
```
f_booking_lifecycle
├── booking_id (PK)
├── user_id (FK) → d_user
├── booking_date_id (FK) → d_date
├── payment_date_id (FK) → d_date
├── confirmation_date_id (FK) → d_date
├── cancellation_date_id (FK) → d_date (NULL if not cancelled)
├── booking_amount (fact)
├── refund_amount (fact)
└── lifecycle_status (ACTIVE, COMPLETED, CANCELLED)
```

**Use Cases**: Order/booking lifecycle tracking

### Additive, Semi-Additive, Non-Additive Facts

**Additive Facts** (✅ Preferred)
- Safe to sum across all dimensions
- Example: `booking_amount`, `commission_amount`
- Can aggregate across dimensions without issue

**Semi-Additive Facts**
- Safe to sum across some dimensions, not others
- Example: `balance` (safe to sum by customer, not across dates)
- Requires careful aggregation logic

**Non-Additive Facts**
- Should NOT be summed
- Example: `percentage`, `ratio`, `rate`
- Convert to additive components (numerator, denominator)

### Fact Table Design Best Practices

1. **Keep facts atomic**: One row per grain, not pre-aggregated (unless snapshot)
2. **Use surrogate keys**: FK to dimensions using surrogate IDs, not business keys
3. **Include degenerate dimensions**: Attributes that don't belong in separate dimension (e.g., `order_number`)
4. **Avoid slowly-changing attributes**: If attribute changes, put in dimension and use SCD Type 2
5. **Document grain clearly**: Comment exactly what 1 row represents
6. **Use additive facts**: Avoid percentages and ratios; store numerator/denominator

---

## Dimension Tables

### Definition

A dimension table contains descriptive attributes:
- **Context**: Describes fact measurements
- **Attributes**: Business descriptors
- **Keys**: Surrogate ID (PK) and business key
- **Time-varying**: May track changes via SCD

### Designing a Dimension Table

**Step 1: Identify the Dimension Subject**
- What entity are we describing?
- Examples: Partner, User, Date, Hotel, Currency

**Step 2: Define the Primary Key**
- Surrogate key: System-generated unique ID
- Example: `partner_id = 1, 2, 3, ...`
- Keep simple (single column, numeric)

**Step 3: Gather Descriptive Attributes**
- All business attributes related to entity
- Include multiple perspectives
- Example (d_partner):
  - `partner_name`, `partner_type`, `status`
  - `country`, `region`, `city`
  - `rating`, `category`, `size`

**Step 4: Add Business Key (optional)**
- Natural identifier from source system
- Example: `partner_code` in source = Business key
- Include if needed for debugging/traceability

**Step 5: Determine Slowly Changing Strategy**
- How to handle attribute changes?
- SCD Type 1 (overwrite) or SCD Type 2 (track history)?
- Add effective/expiration dates if Type 2

**Step 6: Add Metadata**
- `created_date`, `modified_date`
- `source_system`
- `is_current` flag (if SCD Type 2)

### Common Dimensions

#### Date Dimension (d_date)

**Purpose**: Enable time-based analysis

**Typical Columns**:
```
d_date
├── date_id (PK, surrogate): 20250101, 20250102, ...
├── calendar_date: 2025-01-01, 2025-01-02, ...
├── year: 2025, 2025, ...
├── quarter: 1, 1, ...
├── month: 1, 1, ...
├── day_of_month: 1, 2, ...
├── day_of_week: 1 (Monday), 2 (Tuesday), ...
├── week_of_year: 1, 1, ...
├── is_weekday: true, false, ...
├── is_holiday: false, false, ...
├── holiday_name: NULL, NULL, ...
└── fiscal_quarter: Q1, Q1, ...
```

**Benefits**:
- Pre-calculated time attributes
- Holiday/fiscal calendar logic
- Day-of-week analysis

#### User Dimension (d_user)

**Purpose**: Describe user characteristics

**Typical Columns**:
```
d_user
├── user_id (PK, surrogate)
├── source_user_id (business key)
├── user_segment: PREMIUM, STANDARD, BUDGET
├── signup_date_id (FK) → d_date
├── country: US, UK, DE, ...
├── device_type: MOBILE, DESKTOP, ...
├── traffic_source: ORGANIC, PAID, REFERRAL, ...
├── status: ACTIVE, DORMANT, CHURNED
├── effective_date_id (FK) → d_date
├── expiration_date_id (FK) → d_date
└── is_current: true/false
```

#### Partner Dimension (d_partner)

**Purpose**: Describe partner/vendor characteristics

**Typical Columns**:
```
d_partner
├── partner_id (PK, surrogate)
├── partner_code (business key)
├── partner_name
├── partner_type: HOTEL, FLIGHT, CAR_RENTAL, ...
├── country
├── region
├── status: ACTIVE, INACTIVE, SUSPENDED
├── rating: 1-5 stars
├── tier: GOLD, SILVER, BRONZE
├── created_date_id (FK) → d_date
├── effective_date_id (FK) → d_date
├── expiration_date_id (FK) → d_date
└── is_current: true/false
```

### Slowly Changing Dimensions (SCD)

**SCD Type 1: Overwrite**

```
Before:
partner_id | partner_name | status | effective_date
100        | Hotel XYZ    | ACTIVE | 2020-01-01
100        | Hotel XYZ    | SUSPENDED | 2025-01-01

After Change (Partner goes inactive):
100 | Hotel XYZ (Inactive) | INACTIVE | 2025-01-15
```

**When to use**: Corrections, non-critical changes, status updates

**SQL Pattern**:
```sql
MERGE INTO d_partner t
USING source s
ON t.partner_id = s.partner_id
WHEN MATCHED THEN
  UPDATE SET t.status = s.status, t.modified_date = CURRENT_DATE
```

---

**SCD Type 2: Track History**

```
Before:
partner_id | partner_name | status | effective_date | expiration_date | is_current
100        | Hotel XYZ    | ACTIVE | 2020-01-01     | NULL            | true

After Change (Status changes):
partner_id | partner_name | status   | effective_date | expiration_date | is_current
100        | Hotel XYZ    | ACTIVE   | 2020-01-01     | 2025-01-14      | false
100        | Hotel XYZ    | INACTIVE | 2025-01-15     | NULL            | true
```

**When to use**: Business-critical attributes, need historical context

**SQL Pattern**:
```sql
-- Expire old record
UPDATE d_partner
SET expiration_date = CURRENT_DATE - 1, is_current = false
WHERE partner_id = 100 AND is_current = true

-- Insert new record
INSERT INTO d_partner
VALUES (100, 'Hotel XYZ', 'INACTIVE', CURRENT_DATE, NULL, true)
```

### Dimension Design Best Practices

1. **Use surrogate keys**: Not business keys, enables SCD, protects joins
2. **Denormalize**: Include all attributes, don't normalize into sub-dimensions
3. **Include many attributes**: Supports diverse analytical needs
4. **Avoid null values**: Use defaults (Unknown, N/A) if needed
5. **Document changes**: SCD strategy, effective dates, change history
6. **Version for audit**: If tracking changes, maintain complete history

---

## Star Schema Design

### Simple Star

```
                d_date
                  ↑
                  |
d_partner ←---- f_booking ---→ d_user
                  |
                  ↓
              d_currency
```

**Characteristics**:
- One fact table, multiple dimensions
- Simple, easy to query
- Suitable for single business process

### Snowflake Schema

```
        d_city ← d_country
           ↑        ↑
           |        |
       d_location (denormalized)
           |
           ↑
      f_booking
           |
        ↙     ↘
     d_user   d_hotel
```

**Characteristics**:
- Dimensions normalized into sub-dimensions
- Saves dimension storage (rarely needed)
- More complex queries
- Generally avoid for dimensional modeling

**Recommendation**: Use star schema (denormalized dimensions) for Kimball modeling. Snowflake is over-engineered for analytics.

### Conformed Dimension

Same dimension used by multiple fact tables:

```
d_date ← f_booking
   ↑
   |
d_date ← f_redirect
   ↑
   |
d_date ← f_search
```

**Benefits**: Consistent business logic, single source of dimension

**Implementation**: Single d_date dimension referenced by all time-based facts

---

## Fact-Dimension Relationships

### One-to-Many (Most Common)

```
1 Partner → Many Bookings
d_partner.partner_id → f_booking.partner_id
```

**Example**:
```
d_partner:         f_booking:
100 | Hotel XYZ    100 | 50000 (booking 1)
                   100 | 75000 (booking 2)
                   100 | 60000 (booking 3)
```

### One-to-One

```
1 Booking → 1 User
d_user.user_id → f_booking.user_id
```

**Design Note**: One-to-one relationships are normal; don't combine them

### Many-to-Many (Use Bridge Table)

```
1 Booking → Many Services
              ↓
         Bridge Table
              ↓
         Many Services
```

**Example** (Hotel booking with multiple room types):

```
Bridge: bridge_booking_room_type
├── booking_id
├── room_type_id
└── quantity

f_booking → bridge_booking_room_type → d_room_type
```

**Why**: Avoids fact duplication, maintains one row per booking grain

---

## Common Modeling Patterns

### Pattern 1: Degenerate Dimension

Non-key attribute that belongs in fact, not separate dimension:

```
f_booking
├── booking_id (PK)
├── booking_reference_number (degenerate dim)
├── order_comments (degenerate dim)
├── partner_id (FK) → d_partner
└── [other facts, dimensions...]
```

**When to use**: Low-cardinality attributes tied to grain

### Pattern 2: Junk Dimension

Multiple low-cardinality flags combined:

```
Instead of:
├── is_completed (FK) → d_is_completed
├── is_paid (FK) → d_is_paid
├── is_exported (FK) → d_is_exported

Use:
└── completion_flag_id (FK) → d_completion_flags

d_completion_flags:
├── completion_flag_id
├── is_completed: true/false
├── is_paid: true/false
└── is_exported: true/false
```

**Benefits**: Reduces dimension count, cleaner schema

### Pattern 3: Role-Playing Dimension

Same dimension used multiple times with different roles:

```
d_date used as:
├── order_date_id
├── ship_date_id
└── delivery_date_id

All FKs point to same d_date table
```

**Implementation**: Multiple FK columns in fact, all reference d_date

### Pattern 4: Conformed Fact

Same fact calculated and stored in multiple fact tables:

```
f_daily_summary:
├── total_bookings (sum from f_booking)

f_booking:
├── booking_count = 1 (additive fact)
```

**Benefits**: Enables cross-fact comparison, consistency

---

## Modeling Common Scenarios

### Scenario: Product with Multiple Attributes

**Challenge**: Product has many slowly-changing attributes

**Solution**: Use SCD Type 2 in d_product dimension

```
d_product (SCD Type 2)
├── product_id (surrogate key)
├── product_code (business key)
├── product_name
├── category
├── price_tier
├── effective_date
├── expiration_date
├── is_current
```

### Scenario: Transaction with Line Items

**Challenge**: One booking can have multiple room types

**Solution**: Bridge table or normalize fact table

**Option A** (Bridge):
```
f_booking (1 row per booking)
  ↓
bridge_booking_room (many rows per booking)
  ↓
d_room_type
```

**Option B** (Normalized):
```
f_booking_line_item (1 row per line)
├── booking_id
├── line_number
├── room_type_id
└── line_amount
```

### Scenario: Event with No Facts

**Challenge**: Need to track events (e.g., click) without numeric measures

**Solution**: Use count = 1

```
f_click
├── click_id (PK)
├── partner_id (FK) → d_partner
├── event_date_id (FK) → d_date
├── click_count = 1 (additive fact)
```

**Query Example**:
```sql
SELECT d_partner.partner_name, SUM(f_click.click_count)
FROM f_click
JOIN d_partner ON f_click.partner_id = d_partner.partner_id
GROUP BY d_partner.partner_name
```

---

## Kimball Checklist

When designing fact/dimension tables:

**Fact Table**:
- [ ] Grain clearly defined: 1 row = ?
- [ ] Primary key(s) chosen and documented
- [ ] Foreign keys to all dimensions defined
- [ ] Facts are additive (or documented if not)
- [ ] Attributes moved to dimensions
- [ ] Degenerate dimensions documented
- [ ] Update strategy documented

**Dimension Table**:
- [ ] Subject clearly identified
- [ ] Surrogate key (PK) assigned
- [ ] Business key included (if applicable)
- [ ] All relevant attributes included
- [ ] SCD strategy documented (Type 1 or 2)
- [ ] Effective/expiration dates (if SCD Type 2)
- [ ] No null values (use Unknown/N/A)

**Star Schema**:
- [ ] All dimensions connected to fact
- [ ] No dangling dimensions
- [ ] Conformed dimensions shared appropriately
- [ ] Documentation complete

---

## References

- Kimball Group: https://www.kimballgroup.com/
- Table categories: See `table-categories.md`
- Layer specifications: See `layer-specifications.md`
- Data modeling examples: See `references/table-categories.md` fact/dimension examples
