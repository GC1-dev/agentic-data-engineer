# Data Domains Reference

Guidance for organizing and managing data domains in the Medallion Architecture.

## What is a Data Domain?

A **data domain** is a logical grouping of related datasets within the Medallion data architecture. Data domains establish clear boundaries, ownership, and relationships between datasets, enabling effective data management, discoverability, and governance.

**Scope**: Limited to Medallion architecture (Bronze, Silver, Gold, Silicon layers)

**Hierarchy**: `Catalog → Schema (Domain) → Tables`

Example: `prod_trusted_bronze.internal.web_events`
- Catalog: `prod_trusted_bronze`
- Domain/Schema: `internal`
- Table: `web_events`

---

## Why Data Domains?

### 1. Clear Ownership

Each domain owned by a single squad:
- Squad takes responsibility for data quality
- Builds domain knowledge over time
- Easier for consumers to identify point of contact
- Enables accountability for SLAs

### 2. Data Discoverability

Aid navigation and collaboration:
- Groups related datasets with clear naming
- Uses long-lived business terminology
- 10s of domains, 100s of datasets
- Easy to find related tables across layers

### 3. Business Concepts

Reflect business purposes, not team boundaries:
- Domain named after business concept (redirect, booking, partner)
- Not a dumping ground for squad's tables
- Logical grouping based on business concepts
- Enables cross-squad collaboration

---

## Domain Requirements

### Must Have

All domains must satisfy:

✅ **Unique within layer**: Each domain name unique in Bronze, Silver, Gold, Silicon

✅ **Single owner squad**: One squad owns domain; responsible for quality

✅ **If multiple squads needed**: Split into separate domains (e.g., two partners teams → two partner domains)

✅ **Ownership handover documented**: If squad changes focus, document handover

✅ **SLA support matches consumer needs**: 5-15 min updates vs daily vs quarterly

✅ **Definition and purpose documented**: Clear business definition

✅ **Data contracts for all datasets**: SLA, schema, quality rules

✅ **Data health guidelines compliance**: Quality checks, monitoring

✅ **Naming convention adherence**: Follow layer-specific patterns

### Should Have

✅ **Data lineage documented**: Where data comes from, where it goes

✅ **Consumers identified**: Who uses this domain, for what

✅ **Governance practices**: Access control, change management

✅ **Monitoring & alerting**: Quality and freshness alerts

---

## Domain Anti-Patterns

### ❌ Group datasets by convenience

**Bad**: "Ziggy squad owns internal_events, internal_sessions, internal_users"
**Good**: "Internal domain contains all 1st party events; Ziggy squad owns some datasets"

**Why**: Convenience groupings don't reflect business concepts

### ❌ Name domains after squads

**Bad**: `ziggy_data`, `mobile_tables`, `data_tribe_lake`
**Good**: `internal`, `booking`, `session`

**Why**: Domains should outlive team changes

### ❌ Make copies of datasets for minor changes

**Bad**: Create `redirect_events_v1`, `redirect_events_v2` for different use cases
**Good**: One clean Silver entity; multiple Gold-level aggregations

**Why**: Duplication creates confusion, maintenance burden, inconsistency

### ❌ Merge data before it lands in Bronze

**Bad**: Combine multiple sources in Staging, land in Bronze as single table
**Good**: Each source gets Bronze table (even if merged later in Silver)

**Why**: Bronze must be source of truth; combining loses audit trail

---

## Organizing Domains by Layer

### Bronze Layer Domains

**Data Mesh Equivalent**: Source-aligned domains

**Principle**: One domain per distinct data source or ingestion pattern

#### Bronze Domain Types

| Source Type | Domain Pattern | Examples |
|-------------|----------------|----------|
| **1st Party Events** | `internal` | All first-party events centralized |
| **1st Party Batch** | `<system_name>` | `casc`, `human_curated_data` |
| **3rd Party Custom** | `<system_name>` | `amadeus`, `revenue_scrapers` |
| **Fivetran** | `fivetran_<system>` | `fivetran_zendesk`, `fivetran_qualtrics` |
| **Lakeflow Connect** | `lfc_<system>` | `lfc_content_platform` |
| **Multi-Squad** | `<system>_<use_case>` | `google_ads_paid_marketing` |

#### Bronze Domain Characteristics

- Maps directly to source system (1:1)
- No transformations applied
- Datasets within domain may have different owners
- Example: `prod_trusted_bronze.internal` owns multiple event types

### Silver Layer Domains

**Data Mesh Equivalent**: Business concepts/objects

**Principle**: One domain per distinct business concept or entity

#### Silver Domain Types

| Concept Type | Pattern | Purpose |
|-------------|---------|---------|
| **Business Entity** | `<entity_name>` | Core business concepts |
| **Reference Data** | `<reference_type>` | Static/slowly changing |

#### Business Entity Examples

- `redirect`: User searches and redirects to partners
- `booking`: Completed travel transactions
- `user_complaint`: Customer complaints/feedback
- `session`: User session context and lifecycle
- `payment`: Payment transactions and history
- `accommodation`: Property and accommodation data
- `user_journey`: User behavior paths and conversions

#### Reference Data Examples

- `partner`: Partner/vendor information (static lookup)
- `carrier`: Airline company data (static lookup)
- `geo_entity`: Geographic location hierarchy (slowly changing)
- `currency`: Currency definitions and rates (slowly changing)
- `payment_method`: Payment types and rules (rarely changing)

#### Silver Domain Characteristics

- Long-lived, stable naming
- Business-understandable
- Joinable by design
- Typically owned by UDM or business team
- Contains Data Entity Tables and/or Reference Tables

### Gold Layer Domains

**Data Mesh Equivalent**: Consumer/purpose-aligned domains

**Principle**: One domain per reporting/analytics use case or business area

#### Gold Domain Types

| Use Case | Pattern | Purpose |
|----------|---------|---------|
| **Business Concept** | `<concept>` | Business facts and dimensions |
| **BAR Reporting** | `bar_<area>` | Pre-aggregated wide tables |
| **Metrics** | `<area>_metrics` | Performance KPIs |

#### Business Concept Examples

- `revenue`: Revenue facts and dimensions
- `conversion`: Conversion funnel facts
- `user_engagement`: User engagement metrics
- `marketplace_health`: Marketplace fact tables

#### BAR Reporting Examples

- `bar_understand`: User understanding and segmentation
- `bar_audience`: Audience and traffic analysis
- `bar_roi`: ROI and performance metrics

#### Metrics Examples

- `session_metrics`: Session-level performance KPIs
- `conversion_funnel_metrics`: Funnel progression metrics
- `search_metrics`: Search quality and performance
- `booking_metrics`: Booking conversion metrics

#### Gold Domain Characteristics

- Contains fact tables, dimension tables, wide tables
- Multiple tables within domain (facts + dimensions)
- Consumer/purpose-focused
- Typically owned by Analytics team or Data Tribe

### Silicon Layer Domains

**Data Mesh Equivalent**: Consumer/purpose-aligned domains (Data Science)

**Principle**: One domain per ML use case or model

#### Silicon Domain Examples

- `ranking_model`: Hotel ranking model features and predictions
- `recommendation_features`: Recommendation engine features
- `churn_prediction`: Customer churn model datasets
- `price_optimization`: Dynamic pricing model features

#### Silicon Domain Characteristics

- Named after ML use case or model
- Feature engineering contained here
- 6-month retention (shorter ML lifecycle)
- Owned by Data Science team
- Not for business reporting

---

## Unity Catalog Structure with Data Domains

### Single Environment Example

```
Catalog: prod_trusted_bronze
├── Schema: internal (domain)
│   ├── web_events (table)
│   ├── app_events (table)
│   └── api_events (table)
├── Schema: casc (domain)
│   ├── accommodation_rates (table)
│   └── carrier_schedules (table)
├── Schema: fivetran_zendesk (domain)
│   ├── tickets (table)
│   └── articles (table)
└── Schema: fivetran_qualtrics (domain)
    └── survey_responses (table)

Catalog: prod_trusted_silver
├── Schema: redirect (domain)
│   └── events (table, cleaned)
├── Schema: booking (domain)
│   ├── transactions (table)
│   └── cancellations (table)
├── Schema: session (domain)
│   └── context (table)
├── Schema: partner (domain - reference)
│   └── properties (table)
└── Schema: geo_entity (domain - reference)
    ├── countries (table)
    └── cities (table)

Catalog: prod_trusted_gold
├── Schema: revenue (domain)
│   ├── f_booking (fact)
│   ├── f_redirect (fact)
│   ├── d_partner (dimension)
│   ├── d_carrier (dimension)
│   └── d_currency (dimension)
├── Schema: bar_understand (domain)
│   ├── user_cohorts (wide table)
│   └── user_segments (wide table)
├── Schema: conversion (domain)
│   ├── f_funnel_event (fact)
│   └── d_funnel_step (dimension)
└── Schema: session_metrics (domain)
    ├── hourly_summary (aggregated)
    └── daily_summary (aggregated)

Catalog: prod_trusted_silicon
├── Schema: ranking_model (domain)
│   ├── training_features (table)
│   ├── predictions (table)
│   └── model_metadata (table)
├── Schema: recommendation_features (domain)
│   ├── user_history (table)
│   └── item_features (table)
└── Schema: churn_prediction (domain)
    ├── training_data (table)
    └── model_scores (table)
```

### Dev/Prod Environments

Same structure repeated in dev catalogs:

```
Catalog: dev_trusted_bronze
├── Schema: internal (same domains as prod)
├── Schema: casc
├── Schema: fivetran_zendesk
└── [etc.]

Catalog: dev_trusted_silver
├── Schema: redirect (same domains as prod)
├── Schema: booking
├── [etc.]

[Dev Gold, Dev Silicon, etc.]
```

**No unified preview**: Different catalogs for dev/prod, prevents cross-environment impacts

---

## Domain Ownership Guidelines

### Single Squad Ownership

Most common model:

```
Domain: booking
Owner: Booking Squad
Datasets:
  - silver.booking.transactions (owned by Booking Squad)
  - gold.revenue.f_booking (owned by Booking Squad)
```

**Advantages**:
- Clear accountability
- Consistent quality standards
- Unified roadmap

### Multi-Squad Collaboration (Same Domain)

When multiple squads contribute to one domain:

```
Domain: internal
Owner: All contributing squads collectively
Datasets:
  - internal.web_events (owned by Ziggy Squad)
  - internal.app_events (owned by Mobile Squad)
  - internal.api_events (owned by API Squad)
  - silver.session.context (owned by Session Squad)
```

**Requirements**:
- Clear governance for quality standards
- Documented collaboration process
- Single point person for external inquiries
- Regular sync meetings

**When this works**:
- Domain is large and complex (internal events)
- Squads have overlapping domain knowledge
- Collaboration is natural and frequent

### Squad Changes Focus

When squad stops maintaining domain:

```
Transition Process:
1. Document handover requirements (SLA, quality, etc.)
2. Identify new owner squad
3. Create transition period (2-4 weeks of overlap)
4. New squad validates and takes ownership
5. Original squad steps back from daily ops
6. Update domain documentation
```

**Critical**: Never leave domain unmaintained

---

## Domain Governance Checklist

When creating or reviewing a domain:

### Setup Phase

- [ ] **Domain name decided**: Follows layer conventions
- [ ] **Owner squad identified**: Clear primary contact
- [ ] **Business purpose documented**: Why does this domain exist
- [ ] **Consumers identified**: Who will use these datasets
- [ ] **SLA requirements defined**: Update frequency, availability

### Implementation Phase

- [ ] **Datasets created**: Following table naming conventions
- [ ] **Data contracts written**: Schema, quality rules, SLA
- [ ] **Quality checks implemented**: Monitoring and alerting
- [ ] **Access control configured**: Unity Catalog permissions
- [ ] **Documentation completed**: Owner, contacts, purpose

### Ongoing Phase

- [ ] **Quality metrics tracked**: Freshness, completeness, accuracy
- [ ] **Incidents logged and resolved**: Root causes documented
- [ ] **Consumer communication**: Updates on changes/issues
- [ ] **Regular reviews**: Quarterly domain health review
- [ ] **Roadmap maintained**: Future enhancements documented

---

## Domain Lifecycle

### Phase 1: Inception

- Business need identified
- Data source/concept identified
- Owner squad assigned
- Naming decided

### Phase 2: Development

- Initial datasets created (Bronze → Silver → Gold)
- Data contracts defined
- Quality checks implemented
- Documentation written

### Phase 3: Growth

- New datasets added to domain
- Consumers expand
- SLAs tightened
- Optimization work

### Phase 4: Maturity

- Stable, well-understood domain
- High data quality
- Predictable SLAs
- Established consumer base

### Phase 5: Evolution/Sunset

- Domain may merge with related domain (consolidation)
- Domain may split into multiple domains (specialization)
- Domain may sunset if no longer needed
- Clear transition plan needed

---

## Common Domain Patterns

### Pattern 1: Single Source System

Simple 1:1 mapping from source to consumers

```
Bronze Source → Silver Entity → Gold Facts/Dimensions → Consumers
Single domain per layer
```

### Pattern 2: Multi-Source Business Concept

Multiple sources converge to single business entity

```
Bronze (Source A, B, C) → Silver (Unified Entity) → Gold (Facts) → Consumers
Multiple Bronze domains → One Silver domain → One Gold domain
```

Example: Booking domain pulls from CASC, payment system, fraud detection

### Pattern 3: Reference Data Hub

Slowly changing dimensions

```
Bronze Reference → Silver Reference → Gold Dimensions → Shared use
Single reference domain shared across multiple fact domains
```

Example: Partner reference data used by Revenue, Conversion, Session domains

### Pattern 4: Subject-Area-Based

Organized around business subject areas

```
Gold (Revenue domain)
├── f_booking (fact table)
├── f_redirect (fact table)
├── d_partner (dimension)
├── d_currency (dimension)
└── d_date (dimension)
```

Multiple facts and dimensions organized by business area

---

## Cross-Domain Considerations

### Data Sharing Between Domains

**Allowed**:
- ✅ Silver entity reads from Bronze (same or different domain)
- ✅ Gold fact reads from Silver (same or different domain)
- ✅ Gold dimension reads from Silver (same or different domain)
- ✅ Silicon ML dataset reads from Silver (same or different domain)

**Not Allowed**:
- ❌ Gold fact reads from Gold fact (different domain)
- ❌ Direct consumption from Bronze by consumers

### Cross-Domain Dependencies

When managing dependencies:

1. **Document clearly**: Which domain depends on which
2. **Establish SLAs**: If domain B depends on domain A, A's SLA must be known
3. **Test together**: Integration tests between domains
4. **Communicate changes**: Notify dependent domain owners of updates
5. **Version if needed**: Schema versioning for backwards compatibility

### Example: Multi-Domain Dependency

```
Domain: booking (produces)
  ├── silver.booking.transactions
  └── gold.revenue.f_booking
         ↓ (depends on)
Domain: revenue (consumes)
  ├── gold.revenue.f_booking (depends on booking)
  ├── gold.revenue.d_partner (depends on partner domain)
  └── gold.revenue.d_currency (depends on reference domain)

Considerations:
- Booking SLA drives Revenue SLA
- Revenue pipeline runs after Booking completes
- Changes to booking fact structure require Revenue review
```

---

## Domain Metrics and Monitoring

For each domain, track:

1. **Data Quality**
   - Completeness: % records with all required fields
   - Accuracy: % records passing validation
   - Timeliness: Actual vs expected update time

2. **Operational Health**
   - Pipeline success rate: % successful runs
   - Performance: Query latency, data volume
   - Growth: New datasets, new consumers

3. **Consumer Satisfaction**
   - SLA compliance: % on-time updates
   - Incident response time
   - Consumer feedback/NPS

---

## Domain Migration and Consolidation

### Consolidating Two Domains

When two domains should become one:

```
Before:
Domain: session_v1 (legacy) → Silver
Domain: user_session (new)  → Silver

After:
Domain: user_session (unified)
  ├── session_context (merged from v1)
  ├── session_events (merged from v1)
  └── session_attributes (new)

Process:
1. Create unified domain (user_session)
2. Migrate data from v1 → unified
3. Update consumers to use unified domain
4. Deprecate v1 (set sunset date)
5. Archive v1 data
```

### Splitting a Domain

When one domain should become two:

```
Before:
Domain: accommodation
  ├── hotels
  ├── flights
  ├── packages

After:
Domain: hotel_accommodation
  ├── hotels
  ├── hotel_availability
Domain: flight_accommodation
  ├── flights
  ├── flight_availability

Process:
1. Create new domains
2. Copy/migrate data
3. Update consumers
4. Run in parallel briefly
5. Sunset old domain
```

---

## Troubleshooting Common Domain Issues

**Problem**: "Too many datasets in one domain, hard to navigate"
**Solution**: Split domain if logical separation exists; review naming

**Problem**: "No clear owner, nobody responds to issues"
**Solution**: Assign explicit owner; document contact; establish SLA

**Problem**: "Domain has data from multiple unrelated sources"
**Solution**: Check if should be split; verify business concept alignment

**Problem**: "Consumers don't know domain exists"
**Solution**: Improve documentation/metadata; add to data catalog/lineage

**Problem**: "Frequent schema changes breaking consumers"
**Solution**: Implement versioning; require consumer consultation before changes

---

## References

- Naming conventions: See `naming-conventions.md`
- Layer specifications: See `layer-specifications.md`
- Data flows: See `data-flows.md`
- UC structure: See official Databricks Unity Catalog documentation
