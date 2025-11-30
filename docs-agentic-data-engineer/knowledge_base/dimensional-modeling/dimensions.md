# Dimension Design Reference

## Core Principles

Dimensions provide business context for measurements. They answer "who, what, where, when, why, and how" about facts.

### Key Characteristics

- **Descriptive attributes**: Rich, textual context for analysis
- **Slowly changing**: Values change over time but not frequently  
- **Denormalized**: Flat structure optimized for query performance
- **Surrogate keys**: BIGINT primary keys independent of source systems
- **Natural keys**: Business keys from source systems retained as attributes

## Standard Spark SQL Data Types

- **Keys**: `BIGINT` for surrogate keys, `STRING` for natural/business keys
- **Names/Descriptions**: `STRING` (unbounded text)
- **Codes**: `STRING` (even numeric codes, to preserve leading zeros)
- **Flags**: `BOOLEAN`
- **Dates**: `DATE` for calendar dates, `TIMESTAMP` for date-times
- **Numbers**: `DECIMAL(precision, scale)` for amounts, `INT`/`BIGINT` for counts
- **Arrays**: `ARRAY<type>` sparingly, only when justified
- **Structs**: Avoid in dimensions, prefer flattening

## Dimension Types

### Conformed Dimensions

Dimensions shared across multiple fact tables with identical structure and content.

**Benefits:**
- Consistent reporting across business processes
- Drill-across queries between fact tables
- Reduced development and maintenance

**Examples:**
- `dim_date` - Shared across all fact tables
- `dim_customer` - Used by sales, support, marketing facts
- `dim_product` - Used by inventory, sales, returns facts

**Naming:** Use singular form (e.g., `dim_customer` not `dim_customers`)

**Example:**
```sql
CREATE TABLE gold.dim_date (
    date_key BIGINT NOT NULL,
    date_value DATE NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    month INT NOT NULL,
    month_name STRING NOT NULL,
    week_of_year INT NOT NULL,
    day_of_month INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name STRING NOT NULL,
    is_weekend BOOLEAN NOT NULL,
    is_holiday BOOLEAN NOT NULL,
    holiday_name STRING,
    fiscal_year INT NOT NULL,
    fiscal_quarter INT NOT NULL,
    fiscal_period INT NOT NULL
)
USING DELTA
PARTITIONED BY (year, quarter)
TBLPROPERTIES (
    'delta.enableChangeDataFeed' = 'true'
)
COMMENT 'Conformed date dimension used across all fact tables';
```

### Junk Dimensions

Consolidate multiple low-cardinality flags and indicators into a single dimension to avoid dimension explosion.

**When to use:**
- Many transaction flags/indicators (Y/N, True/False)
- Low cardinality attributes (< 50 distinct values each)
- Attributes that don't warrant separate dimensions

**Example:**
```sql
CREATE TABLE gold.dim_order_profile (
    order_profile_key BIGINT NOT NULL,
    is_online_order BOOLEAN NOT NULL,
    is_express_shipping BOOLEAN NOT NULL,
    is_gift_wrapped BOOLEAN NOT NULL,
    is_first_purchase BOOLEAN NOT NULL,
    requires_signature BOOLEAN NOT NULL,
    payment_type STRING NOT NULL,
    order_source STRING NOT NULL
)
USING DELTA
COMMENT 'Junk dimension for order transaction flags';
```

### Degenerate Dimensions

Dimension keys that exist in fact tables without corresponding dimension tables.

**Characteristics:**
- Simple identifiers without descriptive attributes
- Stored directly in fact table
- Often transaction numbers or order IDs

**Usage in Fact Table:**
```sql
CREATE TABLE gold.fact_order_line (
    order_line_key BIGINT NOT NULL,
    order_number STRING NOT NULL,
    invoice_number STRING NOT NULL,
    customer_key BIGINT NOT NULL,
    product_key BIGINT NOT NULL,
    order_date_key BIGINT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(18,2) NOT NULL,
    line_total DECIMAL(18,2) NOT NULL
)
USING DELTA
PARTITIONED BY (order_date_key);
```

### Role-Playing Dimensions

Single physical dimension used multiple times in same fact table for different purposes.

**Example:**
```sql
-- Physical dimension
CREATE TABLE gold.dim_date (
    date_key BIGINT NOT NULL,
    date_value DATE NOT NULL,
    year INT NOT NULL,
    month INT NOT NULL,
    day_of_month INT NOT NULL,
    day_name STRING NOT NULL
)
USING DELTA;

-- Fact table using the dimension in multiple roles
CREATE TABLE gold.fact_order (
    order_key BIGINT NOT NULL,
    order_date_key BIGINT NOT NULL,
    ship_date_key BIGINT NOT NULL,
    delivery_date_key BIGINT NOT NULL,
    customer_key BIGINT NOT NULL,
    order_amount DECIMAL(18,2) NOT NULL
)
USING DELTA
PARTITIONED BY (order_date_key);
```

### Outrigger Dimensions

Secondary dimensions referenced by primary dimensions. Use sparingly to avoid snowflaking.

**Example:**
```sql
-- Outrigger dimension
CREATE TABLE gold.dim_brand (
    brand_key BIGINT NOT NULL,
    brand_code STRING NOT NULL,
    brand_name STRING NOT NULL,
    brand_description STRING,
    parent_company STRING,
    country_of_origin STRING,
    effective_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    is_current BOOLEAN NOT NULL
)
USING DELTA;

-- Primary dimension referencing outrigger
CREATE TABLE gold.dim_product (
    product_key BIGINT NOT NULL,
    product_id STRING NOT NULL,
    product_name STRING NOT NULL,
    product_description STRING,
    category STRING NOT NULL,
    subcategory STRING NOT NULL,
    brand_key BIGINT NOT NULL,
    unit_cost DECIMAL(18,2) NOT NULL,
    unit_price DECIMAL(18,2) NOT NULL,
    effective_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    is_current BOOLEAN NOT NULL
)
USING DELTA;
```

## Slowly Changing Dimensions (SCD)

### Type 0: Retain Original

Never changes. Original value is permanent.

**Example:**
```sql
CREATE TABLE gold.dim_original_customer (
    customer_key BIGINT NOT NULL,
    customer_id STRING NOT NULL,
    original_signup_date DATE NOT NULL,
    original_country STRING NOT NULL,
    original_source STRING NOT NULL,
    original_campaign STRING
)
USING DELTA;
```

### Type 1: Overwrite

Update attribute in place, no history tracking.

**Example:**
```sql
CREATE TABLE gold.dim_customer_type1 (
    customer_key BIGINT NOT NULL,
    customer_id STRING NOT NULL,
    customer_name STRING NOT NULL,
    email STRING NOT NULL,
    phone STRING NOT NULL,
    preferred_contact STRING NOT NULL,
    updated_timestamp TIMESTAMP NOT NULL
)
USING DELTA;

-- Update example
MERGE INTO gold.dim_customer_type1 AS target
USING source_customer_updates AS source
ON target.customer_id = source.customer_id
WHEN MATCHED THEN UPDATE SET
    target.email = source.email,
    target.phone = source.phone,
    target.updated_timestamp = current_timestamp();
```

### Type 2: Add New Row (Most Common)

Create new row with new surrogate key when attribute changes.

**Implementation:**
```sql
CREATE TABLE gold.dim_customer (
    customer_key BIGINT NOT NULL,
    customer_id STRING NOT NULL,
    customer_name STRING NOT NULL,
    email STRING NOT NULL,
    phone STRING NOT NULL,
    address STRING NOT NULL,
    city STRING NOT NULL,
    state STRING NOT NULL,
    postal_code STRING NOT NULL,
    country STRING NOT NULL,
    customer_segment STRING NOT NULL,
    effective_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    is_current BOOLEAN NOT NULL,
    created_timestamp TIMESTAMP NOT NULL,
    updated_timestamp TIMESTAMP NOT NULL
)
USING DELTA;
```

**Example rows:**
```
customer_key | customer_id | address      | city       | effective_date | expiration_date | is_current
-------------|-------------|--------------|------------|----------------|-----------------|------------
1001         | CUST123     | 123 Old St   | Boston     | 2020-01-01     | 2023-05-31      | FALSE
1002         | CUST123     | 456 New Ave  | New York   | 2023-06-01     | 9999-12-31      | TRUE
```

**Type 2 SCD Merge Logic:**
```sql
-- Step 1: Expire changed records
MERGE INTO gold.dim_customer AS target
USING source_customer_updates AS source
ON target.customer_id = source.customer_id 
   AND target.is_current = TRUE
WHEN MATCHED AND (
    target.address != source.address OR
    target.city != source.city OR
    target.state != source.state OR
    target.customer_segment != source.customer_segment
) THEN UPDATE SET
    target.expiration_date = current_date() - INTERVAL 1 DAY,
    target.is_current = FALSE,
    target.updated_timestamp = current_timestamp();

-- Step 2: Insert new current records
INSERT INTO gold.dim_customer
SELECT 
    monotonically_increasing_id() AS customer_key,
    source.customer_id,
    source.customer_name,
    source.email,
    source.phone,
    source.address,
    source.city,
    source.state,
    source.postal_code,
    source.country,
    source.customer_segment,
    current_date() AS effective_date,
    DATE '9999-12-31' AS expiration_date,
    TRUE AS is_current,
    current_timestamp() AS created_timestamp,
    current_timestamp() AS updated_timestamp
FROM source_customer_updates source
INNER JOIN gold.dim_customer target
    ON source.customer_id = target.customer_id
WHERE target.is_current = FALSE
  AND target.expiration_date = current_date() - INTERVAL 1 DAY;
```

### Type 3: Add New Column

Add new column for current value, keep old value in separate column.

**Example:**
```sql
CREATE TABLE gold.dim_product_type3 (
    product_key BIGINT NOT NULL,
    product_id STRING NOT NULL,
    product_name STRING NOT NULL,
    current_category STRING NOT NULL,
    previous_category STRING,
    category_change_date DATE,
    current_price DECIMAL(18,2) NOT NULL,
    previous_price DECIMAL(18,2),
    price_change_date DATE
)
USING DELTA;
```

### Type 4: Mini-Dimension

Separate rapidly changing attributes into a separate mini-dimension.

**Example:**
```sql
-- Main dimension (slowly changing)
CREATE TABLE gold.dim_customer_profile (
    customer_profile_key BIGINT NOT NULL,
    customer_id STRING NOT NULL,
    customer_name STRING NOT NULL,
    birth_date DATE,
    gender STRING,
    signup_date DATE NOT NULL,
    effective_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    is_current BOOLEAN NOT NULL
)
USING DELTA;

-- Mini-dimension (rapidly changing)
CREATE TABLE gold.dim_customer_behavior (
    customer_behavior_key BIGINT NOT NULL,
    customer_segment STRING NOT NULL,
    loyalty_tier STRING NOT NULL,
    credit_score_band STRING NOT NULL,
    effective_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    is_current BOOLEAN NOT NULL
)
USING DELTA;

-- Fact table references both
CREATE TABLE gold.fact_transaction (
    transaction_key BIGINT NOT NULL,
    customer_profile_key BIGINT NOT NULL,
    customer_behavior_key BIGINT NOT NULL,
    transaction_date_key BIGINT NOT NULL,
    amount DECIMAL(18,2) NOT NULL
)
USING DELTA
PARTITIONED BY (transaction_date_key);
```

## Dimension Design Best Practices

### Surrogate Keys

Always use BIGINT surrogate keys:
```sql
CREATE TABLE gold.dim_product (
    product_key BIGINT NOT NULL,
    product_id STRING NOT NULL,
    product_name STRING NOT NULL
)
USING DELTA;
```

### Natural Keys

Always retain natural/business keys:
```sql
CREATE TABLE gold.dim_customer (
    customer_key BIGINT NOT NULL,
    customer_id STRING NOT NULL,
    crm_customer_id STRING,
    customer_name STRING NOT NULL
)
USING DELTA;
```

### Default Rows

Every dimension must include default rows to handle missing or invalid foreign key references from fact tables.

#### Unknown Row

The 'Unknown' row must be present in every dimension and will be joined whenever fact table attributes don't match any valid row within the dimension.

**Purpose:** Handle legitimate missing references (data not yet available, late-arriving dimensions)

**Standards for Unknown Row Attributes:**

| Data Type | Standard Value | Example |
|-----------|---------------|---------|
| **String** | `'Unknown'` | `customer_name = 'Unknown'` |
| **Date** | `DATE '2999-12-31'` | `birth_date = DATE '2999-12-31'` |
| **Timestamp** | `TIMESTAMP '2999-12-31T00:00:00.000+0000'` | `created_timestamp = TIMESTAMP '2999-12-31T00:00:00.000+0000'` |
| **Valid From (Date)** | `DATE '1970-01-01'` | `effective_date = DATE '1970-01-01'` |
| **Valid From (Timestamp)** | `TIMESTAMP '1970-01-01T00:00:00.000+0000'` | `effective_timestamp = TIMESTAMP '1970-01-01T00:00:00.000+0000'` |
| **Numeric (full range valid)** | Minimum possible value | `INT: -2147483648`, `BIGINT: -9223372036854775808` |
| **Numeric (>= 0 only)** | First value out of range: `-1` | `quantity = -1`, `count = -1` |
| **Code values (fixed length)** | `'UNKN'` | `country_code = 'UNKN'` (4 chars) |
| **Boolean** | `NULL` | `is_active = NULL` (both true/false are valid) |

**Example - Unknown Row:**
```sql
INSERT INTO gold.dim_customer VALUES (
    -1,                                      -- customer_key (surrogate key = -1)
    'UNKNOWN',                               -- customer_id (natural key)
    'Unknown',                               -- customer_name
    'unknown@unknown.com',                   -- email
    '',                                      -- phone
    'Unknown',                               -- address
    'Unknown',                               -- city
    'Unknown',                               -- state
    '',                                      -- postal_code
    'Unknown',                               -- country
    'Unknown',                               -- customer_segment
    DATE '1970-01-01',                       -- effective_date (valid_from)
    DATE '2999-12-31',                       -- expiration_date
    TRUE,                                    -- is_current
    TIMESTAMP '1970-01-01T00:00:00.000+0000', -- created_timestamp
    TIMESTAMP '1970-01-01T00:00:00.000+0000'  -- updated_timestamp
);
```

**Example - Unknown Row with Numeric/Boolean:**
```sql
INSERT INTO gold.dim_product VALUES (
    -1,                          -- product_key (surrogate key = -1)
    'UNKNOWN',                   -- product_id
    'Unknown',                   -- product_name
    'Unknown',                   -- product_description
    'UNKN',                      -- brand_code (fixed 4 chars)
    'Unknown',                   -- category
    -1,                          -- quantity_on_hand (numeric >= 0, use -1)
    -2147483648,                 -- internal_id (full range valid, use min)
    NULL,                        -- is_featured (boolean, use NULL)
    DATE '1970-01-01',           -- effective_date
    DATE '2999-12-31',           -- expiration_date
    TRUE                         -- is_current
);
```

#### Not Applicable Row

The 'Not Applicable' row should be present in dimensions where the source fact data could contain invalid or not applicable values for the dimension itself.

**Purpose:** Handle cases where dimension is logically not applicable to the fact (e.g., shipping address for digital products)

**Standards for Not Applicable Row Attributes:**

| Data Type | Standard Value | Example |
|-----------|---------------|---------|
| **String** | `'Not Applicable'` | `customer_name = 'Not Applicable'` |
| **Date** | `DATE '2999-12-31'` | `birth_date = DATE '2999-12-31'` |
| **Timestamp** | `TIMESTAMP '2999-12-31T00:00:00.000+0000'` | `created_timestamp = TIMESTAMP '2999-12-31T00:00:00.000+0000'` |
| **Valid From (Date)** | `DATE '1970-01-01'` | `effective_date = DATE '1970-01-01'` |
| **Valid From (Timestamp)** | `TIMESTAMP '1970-01-01T00:00:00.000+0000'` | `effective_timestamp = TIMESTAMP '1970-01-01T00:00:00.000+0000'` |
| **Numeric (full range valid)** | Minimum possible value | `INT: -2147483648`, `BIGINT: -9223372036854775808` |
| **Numeric (>= 0 only)** | First value out of range: `-1` | `quantity = -1`, `count = -1` |
| **Code values (fixed length)** | `'NTAP'` | `country_code = 'NTAP'` (4 chars) |
| **Boolean** | `NULL` | `is_active = NULL` (both true/false are valid) |

**Example - Not Applicable Row:**
```sql
INSERT INTO gold.dim_shipping_address VALUES (
    -2,                                      -- shipping_address_key (surrogate key = -2)
    'NOT_APPLICABLE',                        -- address_id (natural key)
    'Not Applicable',                        -- address_line1
    'Not Applicable',                        -- city
    'Not Applicable',                        -- state
    '',                                      -- postal_code
    'Not Applicable',                        -- country
    DATE '1970-01-01',                       -- effective_date
    DATE '2999-12-31',                       -- expiration_date
    TRUE,                                    -- is_current
    TIMESTAMP '1970-01-01T00:00:00.000+0000', -- created_timestamp
    TIMESTAMP '1970-01-01T00:00:00.000+0000'  -- updated_timestamp
);
```

#### When to Use Each Default Row

**Use Unknown (-1):**
- Foreign key reference is missing in source data
- Dimension record hasn't arrived yet (late-arriving dimension)
- Data quality issue - reference should exist but doesn't
- Legitimate NULL foreign keys in source

**Use Not Applicable (-2):**
- Dimension is logically not applicable to the fact
- Business rule: dimension doesn't apply in this context
- Optional dimension that isn't relevant for this fact row

**Example Usage in Fact Table:**
```sql
-- Fact table with both Unknown and Not Applicable handling
CREATE TABLE gold.fact_order (
    order_key BIGINT NOT NULL,
    customer_key BIGINT NOT NULL,              -- Always required
    shipping_address_key BIGINT NOT NULL,      -- May be N/A for digital goods
    billing_address_key BIGINT NOT NULL,       -- Always required
    -- other columns
);

-- Insert with Unknown customer (data issue)
INSERT INTO gold.fact_order VALUES (
    1001,
    -1,     -- customer_key = Unknown (customer not found)
    100,    -- shipping_address_key = valid address
    200,    -- billing_address_key = valid address
    -- other values
);

-- Insert with Not Applicable shipping (digital product)
INSERT INTO gold.fact_order VALUES (
    1002,
    500,    -- customer_key = valid customer
    -2,     -- shipping_address_key = Not Applicable (digital download)
    200,    -- billing_address_key = valid address
    -- other values
);
```

#### Implementation Checklist

For every dimension table:
- [ ] Insert Unknown row with surrogate key = -1
- [ ] Insert Not Applicable row with surrogate key = -2 (if applicable)
- [ ] Use standard values for each data type
- [ ] Test fact table inserts with -1 and -2 foreign keys
- [ ] Document when to use Unknown vs Not Applicable
- [ ] Include in dimension load scripts
- [ ] Verify in data quality checks

### Dimension Hierarchies

Flatten hierarchies in dimensions:
```sql
CREATE TABLE gold.dim_geography (
    geography_key BIGINT NOT NULL,
    postal_code STRING NOT NULL,
    city STRING NOT NULL,
    state STRING NOT NULL,
    state_abbreviation STRING NOT NULL,
    region STRING NOT NULL,
    country STRING NOT NULL,
    country_code STRING NOT NULL,
    continent STRING NOT NULL
)
USING DELTA;
```

### Audit Columns

Include standard audit columns:
```sql
CREATE TABLE gold.dim_customer (
    customer_key BIGINT NOT NULL,
    customer_id STRING NOT NULL,
    customer_name STRING NOT NULL,
    effective_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    is_current BOOLEAN NOT NULL,
    created_timestamp TIMESTAMP NOT NULL,
    updated_timestamp TIMESTAMP NOT NULL,
    source_system STRING NOT NULL
)
USING DELTA;
```

### Handling NULL Values

Avoid NULLs in dimensions, use defaults:
```sql
CREATE TABLE gold.dim_customer (
    customer_key BIGINT NOT NULL,
    customer_id STRING NOT NULL,
    customer_name STRING NOT NULL,
    middle_name STRING DEFAULT '',
    address2 STRING DEFAULT '',
    customer_segment STRING DEFAULT 'Unassigned'
)
USING DELTA;
```

## Common Dimension Patterns

### Customer Dimension
```sql
CREATE TABLE gold.dim_customer (
    customer_key BIGINT NOT NULL,
    customer_id STRING NOT NULL,
    customer_name STRING NOT NULL,
    email STRING NOT NULL,
    phone STRING NOT NULL,
    address STRING NOT NULL,
    address2 STRING DEFAULT '',
    city STRING NOT NULL,
    state STRING NOT NULL,
    postal_code STRING NOT NULL,
    country STRING NOT NULL,
    customer_segment STRING NOT NULL,
    customer_status STRING NOT NULL,
    signup_date DATE NOT NULL,
    birth_date DATE,
    gender STRING,
    effective_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    is_current BOOLEAN NOT NULL,
    created_timestamp TIMESTAMP NOT NULL,
    updated_timestamp TIMESTAMP NOT NULL,
    source_system STRING NOT NULL
)
USING DELTA;
```

### Product Dimension
```sql
CREATE TABLE gold.dim_product (
    product_key BIGINT NOT NULL,
    product_id STRING NOT NULL,
    product_name STRING NOT NULL,
    product_description STRING,
    brand STRING NOT NULL,
    category STRING NOT NULL,
    subcategory STRING NOT NULL,
    department STRING NOT NULL,
    product_line STRING NOT NULL,
    size STRING,
    color STRING,
    weight DECIMAL(10,2),
    unit_of_measure STRING NOT NULL,
    unit_cost DECIMAL(18,2) NOT NULL,
    unit_price DECIMAL(18,2) NOT NULL,
    is_active BOOLEAN NOT NULL,
    effective_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    is_current BOOLEAN NOT NULL,
    created_timestamp TIMESTAMP NOT NULL,
    updated_timestamp TIMESTAMP NOT NULL
)
USING DELTA;
```

### Geography Dimension
```sql
CREATE TABLE gold.dim_geography (
    geography_key BIGINT NOT NULL,
    postal_code STRING NOT NULL,
    city STRING NOT NULL,
    county STRING,
    state STRING NOT NULL,
    state_abbreviation STRING NOT NULL,
    region STRING NOT NULL,
    country STRING NOT NULL,
    country_code STRING NOT NULL,
    continent STRING NOT NULL,
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    timezone STRING,
    is_current BOOLEAN NOT NULL
)
USING DELTA;
```

### Employee Dimension
```sql
CREATE TABLE gold.dim_employee (
    employee_key BIGINT NOT NULL,
    employee_id STRING NOT NULL,
    employee_name STRING NOT NULL,
    email STRING NOT NULL,
    job_title STRING NOT NULL,
    department STRING NOT NULL,
    division STRING NOT NULL,
    manager_employee_key BIGINT,
    manager_name STRING,
    hire_date DATE NOT NULL,
    termination_date DATE,
    is_active BOOLEAN NOT NULL,
    effective_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    is_current BOOLEAN NOT NULL,
    created_timestamp TIMESTAMP NOT NULL,
    updated_timestamp TIMESTAMP NOT NULL
)
USING DELTA;
```
