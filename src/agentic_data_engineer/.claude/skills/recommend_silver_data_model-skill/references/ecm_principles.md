# Entity-Centric Modeling (ECM) Principles for Silver Layer

## Overview

Entity-Centric Modeling focuses on business entities and their relationships in the Silver layer, following Third Normal Form (3NF) and Medallion Architecture principles.

## Core Principles

### 1. Entity Identification

**Business Entity:** A thing of significance about which information needs to be stored.

**Characteristics:**
- Represents real-world business concepts
- Has a unique identifier (business key)
- Contains descriptive attributes
- Participates in relationships

**Examples:**
- Customer, Product, Order, Payment, Session, Booking

### 2. Normalization (3NF)

**First Normal Form (1NF):**
- Atomic values only (no arrays or nested structures)
- Each column contains single value
- Each row is unique

**Second Normal Form (2NF):**
- Must be in 1NF
- No partial dependencies on composite keys
- All non-key attributes depend on entire key

**Third Normal Form (3NF):**
- Must be in 2NF
- No transitive dependencies
- Non-key attributes depend only on primary key

**Example:**
```
❌ BAD (Denormalized):
customer_order {
    order_id,
    customer_id,
    customer_name,
    customer_email,
    customer_address
}

✅ GOOD (Normalized to 3NF):
customer {
    customer_sk,        -- Surrogate key
    customer_id,        -- Business key
    customer_name,
    customer_email,
    customer_address
}

order {
    order_sk,           -- Surrogate key
    order_id,           -- Business key
    customer_sk         -- Foreign key
}
```

### 3. Key Strategy

#### Surrogate Keys
- System-generated unique identifier
- BIGINT data type
- Independent of business logic
- Never exposed to users
- Naming: `<entity>_sk` (e.g., `customer_sk`)

#### Business Keys
- Natural identifier from source system
- One or more attributes
- May change over time
- User-visible
- Naming: `<entity>_id` or `<entity>_code`

**Example:**
```sql
CREATE TABLE silver.customer (
    customer_sk BIGINT NOT NULL,        -- Surrogate key
    customer_id STRING NOT NULL,         -- Business key
    customer_uuid STRING,                -- Alternative business key
    customer_name STRING NOT NULL,
    customer_email STRING,
    effective_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    is_current BOOLEAN NOT NULL
)
USING DELTA;
```

### 4. Slowly Changing Dimensions (SCD)

#### Type 1: Overwrite
- No history tracking
- Updates overwrite previous values
- Use for: Corrections, non-critical attributes

**When to use:**
- Data quality fixes
- Attributes that don't impact analytics
- Operational data

#### Type 2: Add New Row (Recommended)
- Full history tracking
- New row for each change
- Effective/expiration dates
- Use for: Most Silver entities

**When to use:**
- Tracking historical changes
- Audit requirements
- Analytical needs

**Implementation:**
```sql
CREATE TABLE silver.customer (
    customer_sk BIGINT NOT NULL,
    customer_id STRING NOT NULL,
    customer_name STRING NOT NULL,
    customer_address STRING NOT NULL,    -- Tracked attribute
    customer_tier STRING NOT NULL,       -- Tracked attribute
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
customer_sk | customer_id | address      | tier   | effective_date | expiration_date | is_current
------------|-------------|--------------|--------|----------------|-----------------|------------
1001        | CUST001     | 123 Old St   | Silver | 2023-01-01     | 2024-06-30      | FALSE
1002        | CUST001     | 456 New Ave  | Gold   | 2024-07-01     | 9999-12-31      | TRUE
```

#### Type 3: Add New Column
- Track one previous value
- Limited history
- Use for: Rare changes, need both old and new

### 5. Relationship Modeling

#### One-to-One (1:1)
- Rare in Silver layer
- Consider merging entities
- Use when: Security, optional attributes

**Example:**
```
customer (1) --- (1) customer_profile
```

#### One-to-Many (1:N)
- Most common relationship
- Parent entity has many children
- Foreign key in child table

**Example:**
```
customer (1) --- (N) order
```

**Implementation:**
```sql
CREATE TABLE silver.order (
    order_sk BIGINT NOT NULL,
    order_id STRING NOT NULL,
    customer_sk BIGINT NOT NULL,     -- FK to customer
    order_date DATE NOT NULL,
    order_amount DECIMAL(18,2) NOT NULL
)
USING DELTA;
```

#### Many-to-Many (M:N)
- Requires bridge table
- Two foreign keys in bridge
- Additional attributes in bridge

**Example:**
```
product (N) --- (N) category
```

**Implementation:**
```sql
CREATE TABLE silver.product_category_bridge (
    product_category_sk BIGINT NOT NULL,
    product_sk BIGINT NOT NULL,      -- FK to product
    category_sk BIGINT NOT NULL,     -- FK to category
    assigned_date DATE NOT NULL,
    is_primary BOOLEAN NOT NULL,
    effective_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    is_current BOOLEAN NOT NULL
)
USING DELTA;
```

### 6. Lifecycle Fields

Every Silver entity should include:

```sql
effective_date DATE NOT NULL,           -- When record became active
expiration_date DATE NOT NULL,          -- When record expired (9999-12-31 for current)
is_current BOOLEAN NOT NULL,            -- True for current records
created_timestamp TIMESTAMP NOT NULL,   -- When record was created
updated_timestamp TIMESTAMP NOT NULL,   -- When record was last updated
source_system STRING NOT NULL           -- Source system identifier
```

### 7. Naming Conventions

**Entity Names:**
- Singular form: `customer` not `customers`
- Lowercase with underscores: `customer_order`
- Business terminology: `booking` not `reservation`

**Attribute Names:**
- Descriptive: `customer_email` not `email`
- snake_case: `order_date` not `orderDate`
- Prefix with entity: `customer_name` not `name`

**Surrogate Keys:**
- Pattern: `<entity>_sk`
- Examples: `customer_sk`, `order_sk`, `product_sk`

**Business Keys:**
- Pattern: `<entity>_id` or `<entity>_code`
- Examples: `customer_id`, `product_code`, `order_uuid`

**Foreign Keys:**
- Same name as referenced surrogate key
- Example: `customer_sk` in order table references `customer_sk` in customer table

## Data Quality Rules

### Per Entity

**Customer Example:**
```python
dq_rules = {
    "customer_id": "Must be unique and not null",
    "customer_email": "Must be valid email format",
    "customer_phone": "Must be valid phone format",
    "customer_status": "Must be in ['ACTIVE', 'INACTIVE', 'SUSPENDED']",
    "created_timestamp": "Must be <= current timestamp"
}
```

### Cross-Entity

**Referential Integrity:**
- All foreign keys must reference valid surrogate keys
- Orphaned records not allowed
- Use -1 for unknown references

## Common Patterns

### Customer Entity

```sql
CREATE TABLE silver.customer (
    customer_sk BIGINT NOT NULL,
    customer_id STRING NOT NULL,
    customer_name STRING NOT NULL,
    customer_email STRING,
    customer_phone STRING,
    customer_address STRING,
    customer_city STRING,
    customer_state STRING,
    customer_postal_code STRING,
    customer_country STRING,
    customer_status STRING NOT NULL,
    customer_tier STRING,
    effective_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    is_current BOOLEAN NOT NULL,
    created_timestamp TIMESTAMP NOT NULL,
    updated_timestamp TIMESTAMP NOT NULL,
    source_system STRING NOT NULL
)
USING DELTA;
```

### Order Entity

```sql
CREATE TABLE silver.order (
    order_sk BIGINT NOT NULL,
    order_id STRING NOT NULL,
    customer_sk BIGINT NOT NULL,
    order_date DATE NOT NULL,
    order_status STRING NOT NULL,
    order_amount DECIMAL(18,2) NOT NULL,
    order_currency STRING NOT NULL,
    effective_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    is_current BOOLEAN NOT NULL,
    created_timestamp TIMESTAMP NOT NULL,
    updated_timestamp TIMESTAMP NOT NULL,
    source_system STRING NOT NULL
)
USING DELTA;
```

### Product Entity

```sql
CREATE TABLE silver.product (
    product_sk BIGINT NOT NULL,
    product_id STRING NOT NULL,
    product_name STRING NOT NULL,
    product_description STRING,
    product_category STRING NOT NULL,
    product_brand STRING,
    unit_price DECIMAL(18,2) NOT NULL,
    product_status STRING NOT NULL,
    effective_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    is_current BOOLEAN NOT NULL,
    created_timestamp TIMESTAMP NOT NULL,
    updated_timestamp TIMESTAMP NOT NULL,
    source_system STRING NOT NULL
)
USING DELTA;
```

### Bridge Table Pattern

```sql
CREATE TABLE silver.student_course_bridge (
    enrollment_sk BIGINT NOT NULL,
    student_sk BIGINT NOT NULL,
    course_sk BIGINT NOT NULL,
    enrollment_date DATE NOT NULL,
    completion_date DATE,
    grade STRING,
    status STRING NOT NULL,
    effective_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    is_current BOOLEAN NOT NULL,
    created_timestamp TIMESTAMP NOT NULL,
    updated_timestamp TIMESTAMP NOT NULL
)
USING DELTA;
```

## Silver vs Gold Layer

### Silver Layer (Entity-Centric)
- Third Normal Form (3NF)
- Entity-centric design
- Surrogate keys
- SCD Type 2 for history
- Referential integrity
- Business entity focus

### Gold Layer (Use-Case Centric)
- Star schema (denormalized)
- Fact and dimension tables
- Optimized for analytics
- Pre-aggregated
- BI tool friendly
- Use-case specific

**Flow:**
```
Bronze → Silver (Normalized entities) → Gold (Star schemas)
```

## Best Practices

1. **One business concept per entity**
2. **Always use surrogate keys**
3. **Retain all business keys**
4. **Default to SCD Type 2**
5. **Include lifecycle fields**
6. **Enforce referential integrity**
7. **Document relationships**
8. **Define data quality rules**
9. **Use consistent naming**
10. **Plan for scalability**
