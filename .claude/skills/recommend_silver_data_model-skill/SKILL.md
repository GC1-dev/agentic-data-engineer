---
name: suggest_silver_data_model
description: Suggest Silver-layer Entity-Centric data models following Medallion Architecture, Third Normal Form (3NF), and Entity-Centric Modeling principles. Use when designing normalized Silver entities from business requirements, Bronze data, or raw entities. Provides surrogate/business key strategies, SCD pattern recommendations, relationship modeling (1:1, 1:N, M:N), bridge tables, lifecycle fields, and data quality rules. Outputs conceptual models, not DDL code.
---

# Silver Data Modeling Skill

Suggest normalized Entity-Centric data models for the Silver layer following Medallion Architecture principles.

## Overview

This skill helps design Silver-layer data models that are:
- **Normalized to 3NF** - Third Normal Form for data integrity
- **Entity-Centric** - Focused on business entities and relationships
- **Properly keyed** - Surrogate and business key strategies
- **Historically tracked** - SCD patterns for temporal data
- **Quality-focused** - Data quality rules per entity

## When to Use This Skill

Trigger when users request:
- "Design Silver model for..."
- "Suggest Silver entities for..."
- "Normalize this data for Silver layer"
- "What entities should I create in Silver?"
- "Model relationships between..."
- Any Silver layer entity design task

## Input Format

Provide entities with their attributes:

```json
[
  {
    "name": "Customer",
    "attributes": [
      {"name": "customer_id", "type": "STRING", "is_key": true, "description": "Unique customer identifier"},
      {"name": "customer_name", "type": "STRING", "is_key": false, "description": "Customer full name"},
      {"name": "customer_email", "type": "STRING", "is_key": false, "description": "Email address"},
      {"name": "customer_status", "type": "STRING", "is_key": false, "description": "Account status"}
    ]
  },
  {
    "name": "Order",
    "attributes": [
      {"name": "order_id", "type": "STRING", "is_key": true, "description": "Unique order identifier"},
      {"name": "customer_id", "type": "STRING", "is_key": false, "description": "Reference to customer"},
      {"name": "order_date", "type": "DATE", "is_key": false, "description": "Order placement date"},
      {"name": "order_amount", "type": "DECIMAL", "is_key": false, "description": "Total order amount"}
    ]
  }
]
```

## Suggestion Process

### Step 1: Identify Business Entities

Extract core business concepts from requirements or Bronze data:
- **Entities:** Things of significance (Customer, Product, Order)
- **Attributes:** Properties of entities
- **Keys:** Unique identifiers

**Questions to ask:**
- What are the main business concepts?
- What attributes describe each concept?
- How are concepts related?

### Step 2: Normalize to 3NF

Apply normalization rules:

**1NF (First Normal Form):**
- Atomic values only
- No repeating groups
- Each row unique

**2NF (Second Normal Form):**
- Must be in 1NF
- No partial dependencies
- All attributes depend on full key

**3NF (Third Normal Form):**
- Must be in 2NF
- No transitive dependencies
- Non-key attributes depend only on primary key

**Example Normalization:**
```
❌ Denormalized:
customer_order {
    order_id, customer_id, customer_name, 
    customer_email, product_id, product_name, 
    product_price, quantity
}

✅ Normalized (3NF):
customer {customer_sk, customer_id, customer_name, customer_email}
product {product_sk, product_id, product_name, product_price}
order {order_sk, order_id, customer_sk}
order_line {order_line_sk, order_sk, product_sk, quantity}
```

### Step 3: Define Key Strategy

#### Surrogate Keys
- System-generated BIGINT
- Never exposed to users
- Naming: `<entity>_sk`

#### Business Keys
- Natural identifiers from source
- May change over time
- Naming: `<entity>_id` or `<entity>_code`

**Example:**
```
customer_sk BIGINT          -- Surrogate key
customer_id STRING          -- Business key
customer_uuid STRING        -- Alternative business key
```

### Step 4: Recommend SCD Pattern

Determine appropriate Slowly Changing Dimension type:

**Type 1 (Overwrite):**
- Use for: Corrections, non-critical changes
- No history tracking

**Type 2 (Add New Row) - Recommended:**
- Use for: Most Silver entities
- Full history tracking
- Effective/expiration dates

**Type 3 (Add Column):**
- Use for: One previous value needed
- Limited history

**Decision criteria:**
```python
if entity has stateful attributes (status, tier, address):
    recommend Type 2
elif entity is purely operational:
    recommend Type 1
else:
    recommend Type 2 (safer default)
```

### Step 5: Model Relationships

Identify relationships between entities:

**One-to-One (1:1):**
```
customer (1) --- (1) customer_profile
```
- Consider merging entities
- Use when: Security, optional attributes

**One-to-Many (1:N):**
```
customer (1) --- (N) order
```
- Most common relationship
- Foreign key in child table

**Many-to-Many (M:N):**
```
product (N) --- (N) category
```
- Requires bridge table
- Two foreign keys in bridge

### Step 6: Define Lifecycle Fields

Add to every entity:
```sql
effective_date DATE NOT NULL
expiration_date DATE NOT NULL
is_current BOOLEAN NOT NULL
created_timestamp TIMESTAMP NOT NULL
updated_timestamp TIMESTAMP NOT NULL
source_system STRING NOT NULL
```

### Step 7: Specify Data Quality Rules

Define validation rules per entity:

**Examples:**
- `customer_id`: Must be unique and not null
- `customer_email`: Must be valid email format
- `order_amount`: Must be >= 0
- `order_date`: Must be valid date
- `customer_status`: Must be in ['ACTIVE', 'INACTIVE', 'SUSPENDED']

## Output Format

The suggestion includes:

```json
{
  "silver_entities": [
    {
      "entity_name": "Customer",
      "surrogate_key": "customer_sk",
      "business_keys": ["customer_id"],
      "attributes": [
        {"name": "customer_name", "type": "STRING", "is_nullable": false},
        {"name": "customer_email", "type": "STRING", "is_nullable": true}
      ],
      "lifecycle_fields": [
        {"name": "effective_date", "type": "DATE"},
        {"name": "expiration_date", "type": "DATE"},
        {"name": "is_current", "type": "BOOLEAN"}
      ]
    }
  ],
  "relationships": [
    {
      "parent": "Customer",
      "child": "Order",
      "relationship_type": "1:N",
      "shared_keys": ["customer_id"],
      "rationale": "One customer can have many orders"
    }
  ],
  "bridge_tables": [
    {
      "bridge_name": "product_category_bridge",
      "entities": ["Product", "Category"],
      "foreign_keys": ["product_sk", "category_sk"],
      "rationale": "Many-to-many relationship requires bridge"
    }
  ],
  "scd_recommendations": {
    "Customer": {
      "scd_type": "Type 2",
      "rationale": "Customer has status and tier attributes that change over time",
      "tracked_attributes": ["customer_status", "customer_tier", "customer_address"]
    }
  },
  "entity_quality_rules": {
    "Customer": [
      "customer_id must be unique and not null",
      "customer_email must be valid email format",
      "customer_status must be in ['ACTIVE', 'INACTIVE', 'SUSPENDED']"
    ]
  }
}
```

## Common Patterns

### Customer Entity Suggestion

**Input:**
```
Customer with: id, name, email, phone, address, status, tier
```

**Suggestion:**
```
Entity: customer
Surrogate Key: customer_sk
Business Keys: customer_id
SCD Type: Type 2 (tracks status, tier, address changes)

Attributes:
- customer_sk BIGINT (surrogate key)
- customer_id STRING (business key)
- customer_name STRING
- customer_email STRING
- customer_phone STRING
- customer_address STRING
- customer_city STRING
- customer_state STRING
- customer_status STRING (tracked)
- customer_tier STRING (tracked)
- effective_date DATE
- expiration_date DATE
- is_current BOOLEAN
- created_timestamp TIMESTAMP
- updated_timestamp TIMESTAMP
- source_system STRING

DQ Rules:
- customer_id: unique, not null
- customer_email: valid email format
- customer_status: in ['ACTIVE', 'INACTIVE', 'SUSPENDED']
```

### Order-OrderLine Pattern

**Input:**
```
Order data with: order_id, customer_id, order_date, items[]
```

**Suggestion:**
```
Normalize to two entities:

1. order entity (header):
   - order_sk, order_id, customer_sk, order_date, order_status
   - Relationship: customer (1) --- (N) order

2. order_line entity (detail):
   - order_line_sk, order_line_id, order_sk, product_sk, quantity, unit_price
   - Relationship: order (1) --- (N) order_line

Bridge: Not needed (pure 1:N relationships)
```

### Many-to-Many Pattern

**Input:**
```
Students enrolled in multiple courses, courses have multiple students
```

**Suggestion:**
```
Entities:
1. student {student_sk, student_id, student_name, ...}
2. course {course_sk, course_id, course_name, ...}

Bridge Table: student_course_bridge
- enrollment_sk BIGINT (surrogate key)
- student_sk BIGINT (FK to student)
- course_sk BIGINT (FK to course)
- enrollment_date DATE
- completion_date DATE
- grade STRING
- status STRING
- effective_date, expiration_date, is_current
- created_timestamp, updated_timestamp

Rationale: M:N relationship requires bridge table
```

## Using the Script

The skill includes a Python script for automated suggestions:

```bash
# Run suggestion script
python scripts/suggest_silver_model.py \
  --input entities.json \
  --output suggestion.json
```

**Input format (entities.json):**
```json
[
  {
    "name": "Customer",
    "attributes": [
      {"name": "customer_id", "type": "STRING", "is_key": true},
      {"name": "customer_name", "type": "STRING", "is_key": false}
    ]
  }
]
```

**Output format (suggestion.json):**
```json
{
  "silver_entities": [...],
  "relationships": [...],
  "bridge_tables": [...],
  "scd_recommendations": {...},
  "entity_quality_rules": {...}
}
```

## Best Practices

1. **Always normalize to 3NF** - Avoid redundancy
2. **Use surrogate keys** - Independent of business logic
3. **Retain business keys** - Source system identifiers
4. **Default to SCD Type 2** - Preserve history
5. **Include lifecycle fields** - Track temporal changes
6. **Model relationships explicitly** - Document all relationships
7. **Define DQ rules** - Validation per entity
8. **Use consistent naming** - Follow conventions
9. **Plan for scalability** - Consider growth
10. **Document rationale** - Explain design decisions

## Silver vs Gold

**Silver Layer (This Skill):**
- Entity-Centric Modeling
- Third Normal Form (3NF)
- Surrogate keys
- SCD Type 2
- Referential integrity
- Business entity focus

**Gold Layer:**
- Star schema
- Denormalized
- Fact and dimension tables
- Optimized for BI
- Use-case specific

**Flow:**
```
Bronze → Silver (Normalized) → Gold (Star Schema)
```

## Quality Checklist

Before finalizing Silver model:

- [ ] All entities normalized to 3NF
- [ ] Surrogate keys defined for all entities
- [ ] Business keys retained
- [ ] SCD type determined per entity
- [ ] Relationships identified and modeled
- [ ] Bridge tables created for M:N
- [ ] Lifecycle fields added
- [ ] Data quality rules defined
- [ ] Naming conventions followed
- [ ] Rationale documented

## Additional Resources

**Read ecm_principles.md for:**
- Detailed 3NF normalization guide
- Key strategy deep dive
- SCD pattern implementations
- Relationship modeling examples
- Complete entity templates
- Silver vs Gold comparison

## Success Criteria

A successful Silver model suggestion:
1. **Properly normalized** - Follows 3NF
2. **Complete keys** - Surrogate and business keys
3. **Appropriate SCD** - Right type per entity
4. **Clear relationships** - All relationships modeled
5. **Bridge tables** - Created where needed
6. **Lifecycle tracking** - Temporal fields included
7. **Quality rules** - Validation defined
8. **Well documented** - Rationale provided
