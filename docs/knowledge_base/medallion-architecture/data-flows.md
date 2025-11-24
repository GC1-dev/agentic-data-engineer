# Data Flows Reference

Valid and invalid data movement patterns in the Medallion Architecture.

## Valid Data Flows

### Primary Flow: Staging → Bronze → Silver → Gold

The ideal, most common flow for business data:

```
Data Source → Staging → Bronze → Silver → Gold
                (raw)    (raw)  (clean)  (agg)
```

**Characteristics**:
- Raw files staged in Staging layer (optional)
- Bronze ingests raw data with minimal transformation
- Silver applies cleaning, deduplication, enrichment
- Gold creates business aggregations and dimensional models
- Each layer adds value progressively

**Use Cases**: Transactional data, event data, third-party integrations

---

### ML Training Flow: Silver → Silicon

Data flowing from Silver to ML training datasets:

```
Silver → Silicon
(clean)   (features)
```

**Characteristics**:
- Source only from Silver (cleaned, validated data)
- Apply ML-specific feature engineering in Silicon
- Keep ML transformations separate from business logic
- Shorter retention (6mo vs 7yr) fits ML lifecycle

**Use Cases**: ML model training, feature engineering, predictions

---

### Inter-Silver Processing: Silver → Silver (with Cyclic Dependency Checks)

Processing within Silver layer:

```
Silver (Entity A) → Silver (Entity B) → Silver (Entity C)
```

**Characteristics**:
- Read from existing Silver entities
- Write new enriched Silver entities
- Must check for cyclic dependencies
- Maintains single source of truth at Silver level

**Use Cases**: Derived business concepts, joined entities, complex enrichments

**Important**: Cyclic dependencies must be detected and prevented:
- A reads from B, B reads from A = Invalid
- A reads from B, B reads from C, C reads from A = Invalid

---

### Direct Ingestion: Source → Bronze (Skipping Staging)

Some sources ingest directly to Bronze without Staging:

```
Data Source → Bronze
```

**Characteristics**:
- Used for streaming data or direct API ingestion
- Trusted pipeline ingestion creates external tables
- Avoids unnecessary staging overhead
- Still maintains 5-15 min update frequency

**Use Cases**: Real-time event streams, direct API integrations

---

### Reference Table Exception: Bronze (Reference) → Gold

Reference tables may skip Silver when strictly for classification:

```
Bronze (Reference) → Gold (Dimension)
```

**Characteristics**:
- Only for static/slowly changing reference data
- Partner codes, carrier lists, airport codes, etc.
- Must be true reference data (no business transformation)
- Document why Silver skip was necessary

**Conditions**:
- ✅ Static or slowly changing data
- ✅ Used purely for dimensional attributes
- ✅ No business logic transformation
- ✅ Clear documentation of necessity

**Examples Valid**: Airport codes, partner IDs, currency codes
**Examples Invalid**: Redirect events, booking data, user attributes

---

### Silver Direct to Tools (Reverse ETL): Silver → Amplitude/Druid/etc.

Business tools consuming Silver directly:

```
Silver → Business Tools
        (Amplitude, Druid, Dr.Jekyll)
```

**Characteristics**:
- Datasets from Silver consumed as-is by tools
- No Gold-level aggregation applied
- Tools handle their own aggregations/filtering

**Use Cases**: Event analytics, user segmentation, real-time insights

---

## Invalid Data Flows

### ❌ Skip Bronze: Staging → Silver

**Why Invalid**:
- Loses source of truth for replay
- Cannot rebuild if Silver transformation fails
- Violates replay capability principle
- Makes auditing impossible

**Rule**: Every data path must flow through Bronze layer

**Exception**: Direct streaming to Bronze (still goes through Bronze)

---

### ❌ Skip Silver (General): Bronze → Gold

**Why Invalid**:
- Violates source of truth principle
- No business validation/cleaning
- Cannot support multiple business representations
- Fact tables have no definition of clean data

**Rule**: All tables must read from Silver (except static references)

**Exception**: Reference tables only (`Bronze → Gold` for dimension lookups)

---

### ❌ Fact to Fact: Gold Fact → Gold Fact

**Why Invalid**:
- Violates source of truth (Silver is source)
- Adds SLA dependencies (fact tables are large)
- Risk of cyclic dependencies
- Different grain levels cause duplication
- Hard to track dependencies

**Problematic Pattern**:
```
Fact A → Fact B → Fact C
```

Results in:
- Fact B depends on Fact A freshness
- If Fact A fails, Fact B and C cascade
- If Fact C changes, hard to trace root cause

**Solution**: Use bridge tables

```
Silver (Base Data) → Bridge Table → Fact A, Fact B, Fact C
```

Bridge table:
- Joins data at appropriate grain
- All facts read from bridge independently
- Easier to rebuild if needed
- Clearer dependencies

---

### ❌ Gold to Bronze/Silver: Reverse Flow

**Why Invalid**:
- Gold is derived data, not source data
- Creates circular dependencies
- Violates layer hierarchy
- Confuses source of truth

**Rule**: Data flows forward through layers, never backward

---

### ❌ Silicon to Silicon: Model → Model

**Why Invalid**: Depends on use case - TBD by architecture team

---

### ❌ Cross-Domain Shortcuts

**Why Invalid**:
- `Domain A (Silver) → Domain B (Gold)` directly
- Skips proper data governance
- Makes lineage unclear
- Creates unexpected dependencies

**Rule**: Follow proper layering even within domains

---

### ❌ Unsupported Formats in Upper Layers

**Why Invalid**:
- Bronze onwards requires Delta format
- Prevents ACID compliance
- Breaks Unity Catalog lineage
- No GDPR support

**Rule**: Delta format required for Bronze onwards

---

### ❌ DBFS Access/Writes

**Why Invalid**:
- Defeats access control (table-level not enforced)
- No Unity Catalog visibility
- Breaks data governance
- Creates security gaps

**Rule**: All data access through tables, never direct S3/DBFS

---

## Flow Validation Checklist

When planning a data flow, validate:

- [ ] **Layer sequence valid?** Check against valid flows above
- [ ] **Silver sourcing?** All facts/entities read from Silver (unless reference)
- [ ] **No fact-to-fact?** If fact B needs fact A, use bridge table
- [ ] **Format correct?** Delta required for Bronze onwards
- [ ] **Dependencies tracked?** Document data dependencies
- [ ] **Ownership clear?** Domain owner assigned for each table
- [ ] **SLA documented?** Update frequency and retention specified
- [ ] **No cyclics?** Cyclic dependencies detected and resolved
- [ ] **Access control?** Table-level permissions defined
- [ ] **Metadata complete?** Owner, date, purpose documented

---

## Common Flow Patterns

### Pattern 1: Single Source System

```
Source System A
    ↓ (5-15 min)
Bronze (raw_events)
    ↓ (daily)
Silver (event_entity)
    ↓ (daily)
Gold (f_event, d_user, d_product)
    ↓
BI Tools (Tableau, Looker)
```

**Setup**: 1 Bronze domain, 1 Silver domain, 1 Gold domain

---

### Pattern 2: Multi-Source Business Concept

```
Source A    Source B    Source C
  ↓           ↓           ↓
Bronze.a   Bronze.b   Bronze.c
  ↓           ↓           ↓
        Silver.user_journey
             ↓
   Gold (f_journey, d_channel)
             ↓
      BI Tools, ML Training
```

**Setup**: Multiple Bronze domains, 1-2 Silver domains, 1 Gold domain

---

### Pattern 3: Reference Data with Business Facts

```
Static Reference        Transactional Data
    Bronze.ref   →  Bronze.events
         ↓             ↓
    (skip silver)  Silver.event
         ↓             ↓
         └─ → Gold (f_event, d_ref)
               ↓
            BI Tools
```

**Setup**: Reference skips Silver, transactional follows full flow

---

### Pattern 4: ML Pipeline Integration

```
Bronze → Silver → Gold (fact tables)
                    ↓
            Silicon (feature sets)
                    ↓
            ML Model Training
                    ↓
            Silicon (predictions)
                    ↓
        Optional: Reverse to Gold/Silver
                    ↓
            Business Tools (Amplitude)
```

**Setup**: Standard flow + ML layer branching

---

### Pattern 5: Multiple Grain Facts with Bridge

```
Silver (daily_order)     Silver (hourly_click)
         ↓                      ↓
         └─→ Bridge Table ←─────┘
              (grain: daily_order)
              ↓
    Fact Tables (read from bridge)
    f_order_with_clicks
```

**Setup**: Different grain facts joined in bridge, facts read from bridge

---

## Data Movement Principles

1. **Progressive Value Addition**: Each layer adds value (cleaning, validation, aggregation)
2. **Single Source of Truth**: Silver is the source, Gold and Silicon derive from it
3. **No Backward Flows**: Data flows forward, never backward
4. **Explicit Governance**: Every flow has clear ownership and SLA
5. **Dependency Management**: Clear, trackable dependencies (no cycles)
6. **Replay Capability**: Can always replay from Bronze on errors
7. **Separation of Concerns**: Business logic (Silver) vs Analytics (Gold) vs ML (Silicon)

---

## Troubleshooting Flow Issues

**Problem**: "I need fact B to read from fact A"
**Solution**: Create bridge table that both read from (if same grain)

**Problem**: "I need to join Bronze domains in Silver"
**Solution**: Create unified Silver entity that consumes multiple Bronze domains

**Problem**: "Silver changes break Gold every day"
**Solution**: Check contract compliance; may need versioning or bridge table

**Problem**: "I can't tell which tables depend on which"
**Solution**: Document dependencies; use Unity Catalog lineage; audit Silver → Gold reads

**Problem**: "Reference data needs transformations"
**Solution**: If transformation needed, go through Silver (not reference exception)

---

## Design Rationale for Flow Rules

**Why Bronze is mandatory**: Source of truth enables replay. Without it, cannot recover from Silver/Gold errors.

**Why no fact-to-fact**: Large fact tables create slow dependencies. Bridge tables break dependency chain.

**Why Silver is source**: Ensures consistent cleaning logic. Multiple facts reading same Silver source reduces duplication.

**Why no backward flows**: Preserves acyclic dependency graph. Cycles make deployments impossible.

**Why separate Bronze/Silver**: Isolates raw data (immutable, replay) from business logic (evolving definitions).
