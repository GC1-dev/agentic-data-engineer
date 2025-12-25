---
name: dbdiagram
description: Generate database diagrams using DBML (Database Markup Language) for dbdiagram.io. Use when users request database schema diagrams, ERDs, dimensional models, star schemas, data model visualizations, or need to embed database diagrams in documentation. Creates valid DBML syntax that can be viewed at dbdiagram.io or embedded in web pages.
---

# DBDiagram Embed

Generate database diagrams using DBML syntax for dbdiagram.io visualization and embedding.

## DBML Syntax Reference

### Table Definition

```dbml
Table table_name {
  column_name type [constraints]
}
```

**Common Types:** `int`, `bigint`, `varchar`, `text`, `boolean`, `date`, `timestamp`, `decimal`, `float`, `json`

**Constraints:**
- `pk` - Primary key
- `not null` - Required field
- `unique` - Unique constraint
- `default: value` - Default value
- `note: 'description'` - Column documentation
- `ref: > other_table.column` - Inline foreign key

**Example:**
```dbml
Table users {
  id bigint [pk, not null]
  email varchar [unique, not null]
  name varchar
  created_at timestamp [default: `now()`]
  status varchar [note: 'active, inactive, pending']
}
```

### Relationships

**Syntax:** `Ref: table1.column <relationship> table2.column`

**Relationship Types:**
- `>` - Many-to-one
- `<` - One-to-many
- `-` - One-to-one
- `<>` - Many-to-many

**Examples:**
```dbml
// Many orders belong to one customer
Ref: orders.customer_id > customers.id

// One user has many posts
Ref: users.id < posts.user_id

// One-to-one profile
Ref: users.id - profiles.user_id
```

### Table Groups

```dbml
TableGroup group_name {
  table1
  table2
}
```

### Enums

```dbml
Enum order_status {
  pending
  processing
  shipped
  delivered
  cancelled
}

Table orders {
  id bigint [pk]
  status order_status
}
```

### Indexes

```dbml
Table products {
  id bigint [pk]
  name varchar
  category_id bigint
  price decimal
  
  indexes {
    category_id
    (category_id, price) [name: 'idx_category_price']
    name [unique]
  }
}
```

### Notes and Documentation

```dbml
Table users [note: 'Stores user account information'] {
  id bigint [pk, note: 'Auto-incrementing primary key']
}

// Project-level note
Note project_notes {
  'This is a multi-line
  project documentation note'
}
```

## Common Patterns

### Star Schema (Dimensional Model)

```dbml
// Fact Table
Table fact_sales {
  sales_key bigint [pk]
  customer_key bigint [ref: > dim_customer.customer_key]
  product_key bigint [ref: > dim_product.product_key]
  date_key bigint [ref: > dim_date.date_key]
  quantity int
  amount decimal
  discount decimal
}

// Dimension Tables
Table dim_customer {
  customer_key bigint [pk]
  customer_id varchar [note: 'Natural key']
  customer_name varchar
  email varchar
  segment varchar
}

Table dim_product {
  product_key bigint [pk]
  product_id varchar [note: 'Natural key']
  product_name varchar
  category varchar
  subcategory varchar
}

Table dim_date {
  date_key bigint [pk]
  full_date date
  year int
  quarter int
  month int
  week int
  day_of_week int
}

TableGroup facts {
  fact_sales
}

TableGroup dimensions {
  dim_customer
  dim_product
  dim_date
}
```

### Medallion Architecture

```dbml
// Bronze Layer
Table bronze_events [note: 'Raw event data from source'] {
  event_id varchar [pk]
  event_type varchar
  payload json
  ingested_at timestamp
}

// Silver Layer
Table silver_events [note: 'Cleaned and validated events'] {
  event_id varchar [pk, ref: > bronze_events.event_id]
  event_type varchar
  user_id bigint
  event_data json
  processed_at timestamp
}

// Gold Layer
Table gold_user_activity [note: 'Aggregated user metrics'] {
  user_id bigint [pk]
  total_events int
  last_event_date date
  activity_score decimal
}

TableGroup bronze {
  bronze_events
}

TableGroup silver {
  silver_events
}

TableGroup gold {
  gold_user_activity
}
```

### SCD Type 2

```dbml
Table dim_customer_scd2 [note: 'Slowly Changing Dimension Type 2'] {
  customer_sk bigint [pk, note: 'Surrogate key']
  customer_id varchar [not null, note: 'Natural/Business key']
  customer_name varchar
  email varchar
  address varchar
  effective_from date [not null]
  effective_to date
  is_current boolean [default: true]
  
  indexes {
    customer_id
    (customer_id, is_current)
  }
}
```

## Embedding Options

### Option 1: Share URL

Generate DBML, then direct user to paste at: `https://dbdiagram.io/d`

The URL format after saving: `https://dbdiagram.io/d/[diagram-id]`

### Option 2: Embed Iframe

```html
<iframe 
  width="100%" 
  height="500" 
  src="https://dbdiagram.io/embed/[diagram-id]">
</iframe>
```

### Option 3: Export Image

From dbdiagram.io, users can export as PNG, PDF, or SQL.

## Output Format

Present DBML in a code block with `dbml` or `sql` language identifier:

````markdown
```dbml
Table users {
  id bigint [pk]
  name varchar
}
```
````

## Best Practices

1. **Use meaningful names** - `customer_key` not `ck`
2. **Document with notes** - Add context for complex fields
3. **Group related tables** - Use TableGroup for organization
4. **Show cardinality** - Use correct relationship symbols
5. **Include natural keys** - Mark them with notes for dimensional models
6. **Keep diagrams focused** - Split large schemas into logical groups

## Quality Checklist

- [ ] Valid DBML syntax
- [ ] All relationships defined
- [ ] Primary keys marked
- [ ] Foreign keys reference valid tables
- [ ] Meaningful column/table names
- [ ] Notes added for non-obvious fields
