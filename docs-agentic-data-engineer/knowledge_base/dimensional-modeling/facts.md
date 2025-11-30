# Fact Table Design Reference

## Core Principles

Fact tables store measurements or metrics about business processes. They answer "how many" or "how much."

### Key Characteristics

- **Numeric measures**: Quantitative data (amounts, quantities, counts)
- **Foreign keys**: References to dimension tables
- **Grain**: Level of detail at which facts are recorded
- **Additive**: Measures that can be summed across dimensions
- **Large volume**: Typically the largest tables in the data warehouse

## Standard Spark SQL Data Types for Facts

- **Keys**: `BIGINT` for surrogate keys and dimension FKs
- **Measures**: `DECIMAL(precision, scale)` for amounts, `INT`/`BIGINT` for counts
- **Degenerate dimensions**: `STRING` for transaction IDs
- **Dates/Timestamps**: `DATE` or `TIMESTAMP` for event times
- **Avoid**: `STRING` for measures, `BOOLEAN` flags (use junk dimensions)

## Fact Table Grain

The grain defines the level of detail of each fact table row.

**Best practices:**
- Declare grain explicitly in documentation
- One grain per fact table
- Atomic grain is preferred (most detailed level)
- Consistent grain across all measures in the table

**Example grains:**
- One row per order line item
- One row per customer per day
- One row per flight segment
- One row per account per month

## Fact Table Types

### Transaction Fact Tables

Record one row per business event or transaction. Most common fact table type.

**Characteristics:**
- Atomic grain (one row per transaction)
- Typically sparse (not every combination exists)
- Grow continuously
- Most detailed level

**Example:**
```sql
CREATE TABLE gold.fact_sales (
    sales_key BIGINT NOT NULL,
    order_number STRING NOT NULL,
    customer_key BIGINT NOT NULL,
    product_key BIGINT NOT NULL,
    store_key BIGINT NOT NULL,
    order_date_key BIGINT NOT NULL,
    ship_date_key BIGINT NOT NULL,
    order_profile_key BIGINT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(18,2) NOT NULL,
    discount_amount DECIMAL(18,2) NOT NULL,
    tax_amount DECIMAL(18,2) NOT NULL,
    total_amount DECIMAL(18,2) NOT NULL,
    cost_amount DECIMAL(18,2) NOT NULL,
    profit_amount DECIMAL(18,2) NOT NULL,
    created_timestamp TIMESTAMP NOT NULL
)
USING DELTA
PARTITIONED BY (order_date_key)
TBLPROPERTIES (
    'delta.enableChangeDataFeed' = 'true'
)
COMMENT 'Transaction fact table - one row per order line item';
```

### Periodic Snapshot Fact Tables

Record state of business at regular intervals (daily, weekly, monthly).

**Characteristics:**
- Dense (row for every combination at each period)
- Predictable row count
- Show status at point in time
- Good for trend analysis

**Example:**
```sql
CREATE TABLE gold.fact_inventory_daily (
    inventory_snapshot_key BIGINT NOT NULL,
    snapshot_date_key BIGINT NOT NULL,
    product_key BIGINT NOT NULL,
    warehouse_key BIGINT NOT NULL,
    quantity_on_hand INT NOT NULL,
    quantity_allocated INT NOT NULL,
    quantity_available INT NOT NULL,
    reorder_point INT NOT NULL,
    reorder_quantity INT NOT NULL,
    unit_cost DECIMAL(18,2) NOT NULL,
    inventory_value DECIMAL(18,2) NOT NULL,
    days_on_hand INT NOT NULL,
    created_timestamp TIMESTAMP NOT NULL
)
USING DELTA
PARTITIONED BY (snapshot_date_key)
COMMENT 'Periodic snapshot fact table - one row per product per warehouse per day';
```

### Accumulating Snapshot Fact Tables

Track milestones in a process with defined beginning and end.

**Characteristics:**
- One row per process instance
- Multiple date columns for milestones
- Rows are updated as process progresses
- Good for lag analysis

**Example:**
```sql
CREATE TABLE gold.fact_order_fulfillment (
    order_key BIGINT NOT NULL,
    order_number STRING NOT NULL,
    customer_key BIGINT NOT NULL,
    product_key BIGINT NOT NULL,
    -- Milestone dates as separate columns
    order_date_key BIGINT NOT NULL,
    payment_date_key BIGINT,
    shipment_date_key BIGINT,
    delivery_date_key BIGINT,
    return_date_key BIGINT,
    -- Lag measures (calculated during updates)
    days_to_payment INT,
    days_to_shipment INT,
    days_to_delivery INT,
    days_to_return INT,
    -- Measures
    order_amount DECIMAL(18,2) NOT NULL,
    fulfillment_cost DECIMAL(18,2),
    -- Status
    order_status STRING NOT NULL,
    created_timestamp TIMESTAMP NOT NULL,
    updated_timestamp TIMESTAMP NOT NULL
)
USING DELTA
PARTITIONED BY (order_date_key)
COMMENT 'Accumulating snapshot - one row per order tracking fulfillment milestones';
```

### Factless Fact Tables

Record events or relationships without measures.

**Characteristics:**
- Only foreign keys and dates
- Track relationships or coverage
- Used for event tracking

**Types:**

**Event tracking:**
```sql
CREATE TABLE gold.fact_student_attendance (
    attendance_key BIGINT NOT NULL,
    student_key BIGINT NOT NULL,
    class_key BIGINT NOT NULL,
    date_key BIGINT NOT NULL,
    instructor_key BIGINT NOT NULL,
    created_timestamp TIMESTAMP NOT NULL
)
USING DELTA
PARTITIONED BY (date_key)
COMMENT 'Factless fact table - tracks student class attendance events';
```

**Coverage tracking:**
```sql
CREATE TABLE gold.fact_product_promotion_eligibility (
    eligibility_key BIGINT NOT NULL,
    product_key BIGINT NOT NULL,
    promotion_key BIGINT NOT NULL,
    store_key BIGINT NOT NULL,
    start_date_key BIGINT NOT NULL,
    end_date_key BIGINT NOT NULL,
    created_timestamp TIMESTAMP NOT NULL
)
USING DELTA
PARTITIONED BY (start_date_key)
COMMENT 'Factless fact table - tracks which products are eligible for promotions';
```

## Measure Types

### Additive Measures

Can be summed across all dimensions. Most common and useful.

**Examples:**
- `quantity`
- `sales_amount`
- `cost_amount`
- `profit_amount`

```sql
CREATE TABLE gold.fact_sales (
    sales_key BIGINT NOT NULL,
    product_key BIGINT NOT NULL,
    date_key BIGINT NOT NULL,
    quantity INT NOT NULL,              -- Additive
    sales_amount DECIMAL(18,2) NOT NULL, -- Additive
    cost_amount DECIMAL(18,2) NOT NULL   -- Additive
)
USING DELTA;
```

### Semi-Additive Measures

Can be summed across some dimensions but not all (typically not across time).

**Examples:**
- `account_balance` - cannot sum across time
- `inventory_quantity` - cannot sum across time
- `headcount` - cannot sum across time

```sql
CREATE TABLE gold.fact_account_balance_daily (
    balance_snapshot_key BIGINT NOT NULL,
    account_key BIGINT NOT NULL,
    date_key BIGINT NOT NULL,
    beginning_balance DECIMAL(18,2) NOT NULL,  -- Semi-additive
    ending_balance DECIMAL(18,2) NOT NULL,     -- Semi-additive
    average_balance DECIMAL(18,2) NOT NULL     -- Non-additive
)
USING DELTA
PARTITIONED BY (date_key);
```

### Non-Additive Measures

Cannot be summed across any dimension. Must use averages or other calculations.

**Examples:**
- `unit_price`
- `temperature`
- `percentages`
- `ratios`

```sql
CREATE TABLE gold.fact_product_performance (
    performance_key BIGINT NOT NULL,
    product_key BIGINT NOT NULL,
    date_key BIGINT NOT NULL,
    unit_price DECIMAL(18,2) NOT NULL,        -- Non-additive
    profit_margin_pct DECIMAL(5,2) NOT NULL,  -- Non-additive
    quantity_sold INT NOT NULL,                -- Additive
    total_revenue DECIMAL(18,2) NOT NULL      -- Additive
)
USING DELTA;
```

## Fact Table Design Patterns

### Degenerate Dimensions

Store transaction identifiers directly in fact tables:

```sql
CREATE TABLE gold.fact_sales (
    sales_key BIGINT NOT NULL,
    order_number STRING NOT NULL,      -- Degenerate dimension
    line_number INT NOT NULL,          -- Degenerate dimension
    invoice_number STRING NOT NULL,    -- Degenerate dimension
    customer_key BIGINT NOT NULL,
    product_key BIGINT NOT NULL,
    date_key BIGINT NOT NULL,
    quantity INT NOT NULL,
    amount DECIMAL(18,2) NOT NULL
)
USING DELTA
PARTITIONED BY (date_key);
```

### Junk Dimension Foreign Keys

Reference junk dimensions for transaction flags:

```sql
CREATE TABLE gold.fact_order (
    order_key BIGINT NOT NULL,
    customer_key BIGINT NOT NULL,
    product_key BIGINT NOT NULL,
    date_key BIGINT NOT NULL,
    order_profile_key BIGINT NOT NULL,  -- FK to junk dimension
    quantity INT NOT NULL,
    amount DECIMAL(18,2) NOT NULL
)
USING DELTA;
```

### Multiple Date Foreign Keys

Use role-playing dimensions for different date contexts:

```sql
CREATE TABLE gold.fact_order (
    order_key BIGINT NOT NULL,
    customer_key BIGINT NOT NULL,
    order_date_key BIGINT NOT NULL,     -- FK to dim_date
    ship_date_key BIGINT NOT NULL,      -- FK to dim_date
    delivery_date_key BIGINT NOT NULL,  -- FK to dim_date
    amount DECIMAL(18,2) NOT NULL
)
USING DELTA
PARTITIONED BY (order_date_key);
```

### Null Foreign Keys

Handle missing dimension values:

```sql
-- Use -1 for unknown dimension values
CREATE TABLE gold.fact_sales (
    sales_key BIGINT NOT NULL,
    customer_key BIGINT NOT NULL DEFAULT -1,
    product_key BIGINT NOT NULL DEFAULT -1,
    store_key BIGINT NOT NULL DEFAULT -1,
    date_key BIGINT NOT NULL,
    amount DECIMAL(18,2) NOT NULL
)
USING DELTA;
```

### Audit Columns

Include standard tracking columns:

```sql
CREATE TABLE gold.fact_sales (
    sales_key BIGINT NOT NULL,
    customer_key BIGINT NOT NULL,
    product_key BIGINT NOT NULL,
    date_key BIGINT NOT NULL,
    quantity INT NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    created_timestamp TIMESTAMP NOT NULL,
    updated_timestamp TIMESTAMP NOT NULL,
    source_system STRING NOT NULL,
    batch_id BIGINT NOT NULL
)
USING DELTA;
```

## Partitioning Strategies

### Date-Based Partitioning

Most common pattern for fact tables:

```sql
CREATE TABLE gold.fact_sales (
    sales_key BIGINT NOT NULL,
    order_date_key BIGINT NOT NULL,
    customer_key BIGINT NOT NULL,
    product_key BIGINT NOT NULL,
    quantity INT NOT NULL,
    amount DECIMAL(18,2) NOT NULL
)
USING DELTA
PARTITIONED BY (order_date_key);
```

### Multi-Level Partitioning

For very large fact tables:

```sql
CREATE TABLE gold.fact_web_events (
    event_key BIGINT NOT NULL,
    event_date_key BIGINT NOT NULL,
    customer_key BIGINT NOT NULL,
    event_type STRING NOT NULL,
    event_timestamp TIMESTAMP NOT NULL
)
USING DELTA
PARTITIONED BY (event_date_key, event_type);
```

## Fact Table Best Practices

### Surrogate Keys

Use generated surrogate keys for fact tables:

```sql
CREATE TABLE gold.fact_sales (
    sales_key BIGINT NOT NULL,  -- Generated surrogate key
    order_number STRING NOT NULL,
    line_number INT NOT NULL,
    -- Other columns
)
USING DELTA;
```

### Foreign Key Constraints

Document foreign key relationships in comments:

```sql
CREATE TABLE gold.fact_sales (
    sales_key BIGINT NOT NULL,
    customer_key BIGINT NOT NULL,    -- FK to dim_customer
    product_key BIGINT NOT NULL,     -- FK to dim_product
    date_key BIGINT NOT NULL,        -- FK to dim_date
    quantity INT NOT NULL,
    amount DECIMAL(18,2) NOT NULL
)
USING DELTA
COMMENT 'Sales transaction facts with FKs to customer, product, and date dimensions';
```

### Consistent Grain

All measures must match the declared grain:

```sql
-- Good: All measures are at order line level
CREATE TABLE gold.fact_order_line (
    order_line_key BIGINT NOT NULL,
    order_number STRING NOT NULL,
    line_number INT NOT NULL,
    customer_key BIGINT NOT NULL,
    product_key BIGINT NOT NULL,
    date_key BIGINT NOT NULL,
    line_quantity INT NOT NULL,       -- Line level
    line_amount DECIMAL(18,2) NOT NULL -- Line level
)
USING DELTA;

-- Bad: Mixing order and line level measures
-- Don't do this - create separate fact tables instead
```

### Null Handling

Use -1 for unknown dimensions, never NULL for FKs:

```sql
-- Insert with unknown customer
INSERT INTO gold.fact_sales 
SELECT 
    sales_key,
    COALESCE(customer_key, -1) AS customer_key,  -- Use -1 for unknown
    product_key,
    date_key,
    quantity,
    amount
FROM source_sales;
```

### Derived Measures

Include commonly used calculated measures:

```sql
CREATE TABLE gold.fact_sales (
    sales_key BIGINT NOT NULL,
    customer_key BIGINT NOT NULL,
    product_key BIGINT NOT NULL,
    date_key BIGINT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(18,2) NOT NULL,
    discount_amount DECIMAL(18,2) NOT NULL,
    gross_amount DECIMAL(18,2) NOT NULL,
    net_amount DECIMAL(18,2) NOT NULL,
    cost_amount DECIMAL(18,2) NOT NULL,
    profit_amount DECIMAL(18,2) NOT NULL,  -- Derived: net_amount - cost_amount
    margin_pct DECIMAL(5,2) NOT NULL       -- Derived: profit/net_amount * 100
)
USING DELTA;
```

## Common Fact Table Patterns

### Sales Fact Table

```sql
CREATE TABLE gold.fact_sales (
    sales_key BIGINT NOT NULL,
    order_number STRING NOT NULL,
    line_number INT NOT NULL,
    customer_key BIGINT NOT NULL,
    product_key BIGINT NOT NULL,
    store_key BIGINT NOT NULL,
    employee_key BIGINT NOT NULL,
    order_date_key BIGINT NOT NULL,
    ship_date_key BIGINT NOT NULL,
    order_profile_key BIGINT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(18,2) NOT NULL,
    discount_amount DECIMAL(18,2) NOT NULL,
    tax_amount DECIMAL(18,2) NOT NULL,
    shipping_amount DECIMAL(18,2) NOT NULL,
    gross_amount DECIMAL(18,2) NOT NULL,
    net_amount DECIMAL(18,2) NOT NULL,
    cost_amount DECIMAL(18,2) NOT NULL,
    profit_amount DECIMAL(18,2) NOT NULL,
    created_timestamp TIMESTAMP NOT NULL,
    source_system STRING NOT NULL
)
USING DELTA
PARTITIONED BY (order_date_key)
COMMENT 'Sales transaction fact table - one row per order line';
```

### Inventory Snapshot Fact Table

```sql
CREATE TABLE gold.fact_inventory_daily (
    inventory_snapshot_key BIGINT NOT NULL,
    snapshot_date_key BIGINT NOT NULL,
    product_key BIGINT NOT NULL,
    warehouse_key BIGINT NOT NULL,
    quantity_on_hand INT NOT NULL,
    quantity_allocated INT NOT NULL,
    quantity_available INT NOT NULL,
    quantity_on_order INT NOT NULL,
    reorder_point INT NOT NULL,
    reorder_quantity INT NOT NULL,
    unit_cost DECIMAL(18,2) NOT NULL,
    inventory_value DECIMAL(18,2) NOT NULL,
    days_on_hand INT NOT NULL,
    stockout_flag BOOLEAN NOT NULL,
    created_timestamp TIMESTAMP NOT NULL
)
USING DELTA
PARTITIONED BY (snapshot_date_key)
COMMENT 'Daily inventory snapshot - one row per product per warehouse per day';
```

### Customer Activity Fact Table

```sql
CREATE TABLE gold.fact_customer_activity_daily (
    activity_key BIGINT NOT NULL,
    customer_key BIGINT NOT NULL,
    activity_date_key BIGINT NOT NULL,
    page_views INT NOT NULL,
    sessions INT NOT NULL,
    items_viewed INT NOT NULL,
    items_added_to_cart INT NOT NULL,
    items_purchased INT NOT NULL,
    purchase_amount DECIMAL(18,2) NOT NULL,
    avg_session_duration_seconds INT NOT NULL,
    created_timestamp TIMESTAMP NOT NULL
)
USING DELTA
PARTITIONED BY (activity_date_key)
COMMENT 'Daily customer activity aggregation';
```

### Financial Transaction Fact Table

```sql
CREATE TABLE gold.fact_financial_transaction (
    transaction_key BIGINT NOT NULL,
    transaction_id STRING NOT NULL,
    account_key BIGINT NOT NULL,
    customer_key BIGINT NOT NULL,
    transaction_date_key BIGINT NOT NULL,
    transaction_type_key BIGINT NOT NULL,
    transaction_amount DECIMAL(18,2) NOT NULL,
    balance_after_transaction DECIMAL(18,2) NOT NULL,
    transaction_fee DECIMAL(18,2) NOT NULL,
    currency_code STRING NOT NULL,
    exchange_rate DECIMAL(10,4) NOT NULL,
    amount_in_usd DECIMAL(18,2) NOT NULL,
    created_timestamp TIMESTAMP NOT NULL
)
USING DELTA
PARTITIONED BY (transaction_date_key)
COMMENT 'Financial transaction fact table';
```
