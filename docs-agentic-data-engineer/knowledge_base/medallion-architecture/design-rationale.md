# Design Rationale Reference

Reasoning behind key Medallion Architecture design decisions at Skyscanner.

## 1. Table Access Only (Bronze Onwards)

**Decision**: All data in Bronze and above must be accessed via tables (no direct S3/DBFS access)

### Benefits

1. **Common Access Pattern**
   - Standard SQL queries work across all data
   - BI tools have native table support
   - No custom S3 access logic needed

2. **Visibility via Metadata**
   - Unity Catalog tracks all tables
   - Data discovery and lineage tracking
   - Column-level information available
   - Owner/purpose documented in metadata

3. **Enables Team Reuse**
   - Teams can find and use tables easily
   - No need to understand S3 paths
   - Discoverable through catalogs
   - Reduces duplication

4. **Elegant Access Control**
   - Table-level permissions via UC
   - No dual control (S3 + table permissions)
   - Simpler governance model
   - Audit trail clear

5. **Unity Catalog Lineage**
   - UC lineage tracking requires tables
   - Cannot track S3-to-table lineage
   - Essential for data governance

### Trade-offs

**Against**: Direct S3 access can be faster for bulk export
**Mitigated by**: External tables option for Fivetran/bulk exports

---

## 2. Delta Tables (Bronze Onwards)

**Decision**: All tables in Bronze and above must be Delta format

### Benefits

1. **Prevent Data Corruption**
   - ACID transactions prevent partial writes
   - Failed ETL jobs don't corrupt existing data
   - Rollback capability on errors
   - Transaction log ensures consistency

   **Example**: ETL fails halfway through → Data remains uncorrupted

2. **Faster Queries**
   - Transaction log serves as manifest file
   - No expensive LIST operations on S3
   - File skipping based on statistics
   - Column-level statistics for pruning
   - Performance: 10-100x faster than Parquet lists

   **Without Delta**: Query must LIST all files to verify they're valid
   **With Delta**: Transaction log already has file list

3. **Increase Data Freshness**
   - Auto-optimize during writes
   - Compaction reduces file count
   - Better partitioning automatically
   - Faster incremental updates
   - Z-ordering improves cache hits

4. **Achieve Compliance**
   - **GDPR Support**: DELETE removes data (not just marked deleted)
   - **CCPA Support**: UPDATE modifies personal info in-place
   - **Audit Trail**: Transaction history available
   - **Data Retention**: Clear deletion not just TTL

   **Example GDPR**: `DELETE FROM table WHERE user_id = X` actually removes data

### Technical Advantages

| Feature | Delta | Parquet |
|---------|-------|---------|
| ACID Transactions | ✅ | ❌ |
| Schema Evolution | ✅ | ⚠️ |
| Time Travel | ✅ | ❌ |
| Unified Batch/Stream | ✅ | ❌ |
| Compliance (DELETE) | ✅ | ❌ |
| Update Operations | ✅ | ❌ |
| Manifest (no LIST) | ✅ | ❌ |

### Trade-offs

**Against**: Delta has slight storage overhead
**Mitigated by**: Gains far outweigh minor overhead; compression similar

---

## 3. Separate S3 Bucket per Layer

**Decision**: Bronze, Silver, Gold, Silicon each use separate S3 buckets

### Benefits

1. **S3 Bucket Policy Limits**
   - AWS S3 policy maximum: 20KB
   - Single large bucket might exceed limit
   - Multiple buckets: One policy per layer
   - Avoids hard blocker on scale

2. **Different Security Policies**
   - Bronze: Minimal access (ingestion only)
   - Silver: Team-specific access
   - Gold: Broader business access
   - Silicon: Data science access
   - Each layer has appropriate bucket policy

3. **Easier Policy Management**
   - Per-layer policies clear and separate
   - Different retention/lifecycle rules
   - Audit simpler (who has access to which layer?)
   - Changes don't cascade across layers

4. **Phased Maintenance Activities**
   - Can perform maintenance on Bronze without affecting Silver
   - Bucket versioning per layer
   - Separate replication/backup strategies
   - Easier rollback if needed

5. **Future Migration Flexibility**
   - Can move layer to different storage provider
   - Can split layer into multiple buckets if needed
   - No tight coupling between layers
   - Future AWS offerings easier to adopt

### Example Policies

**Bronze Bucket Policy**: Only Fivetran/Databricks ingestion
```json
{
  "Principal": "arn:aws:iam::ACCOUNT:role/fivetran-role",
  "Action": ["s3:GetObject", "s3:PutObject"],
  "Resource": "arn:aws:s3:::prod-trusted-bronze/*"
}
```

**Silver Bucket Policy**: Data engineers + analytics
```json
{
  "Principal": "arn:aws:iam::ACCOUNT:role/databricks",
  "Action": ["s3:*"],
  "Resource": "arn:aws:s3:::prod-trusted-silver/*"
}
```

### Trade-offs

**Against**: More buckets to manage (cost, complexity)
**Mitigated by**: AWS provides infrastructure-as-code; minimal manual overhead

---

## 4. No Data Processing in Bronze

**Decision**: Bronze layer stores raw data with zero/minimal transformation

### Benefits

1. **Maintains Source of Truth**
   - Raw data never lost to transformations
   - Original state always recoverable
   - Changes to transformation logic don't affect Bronze

2. **Enables Replay Capability**
   - On Silver/Gold error, can replay from Bronze
   - Entire pipeline can be reprocessed cleanly
   - No need to ask source systems for data again

   **Example Scenario**:
   ```
   Silver transformation logic changed
   → Can re-run Silver from Bronze
   → Without waiting for next ingestion from source
   → Saves hours
   ```

3. **No Latency During Ingestion**
   - Processing blocked on transformation complexity
   - Raw ingestion can be very fast (5-15 min)
   - Heavy processing moves to Silver
   - Bronze updates stay fresh

4. **Audit Trail Preserved**
   - Original data format intact
   - Can trace issues back to source
   - Know what source system actually sent
   - Easier compliance/debugging

5. **Multiple Representations**
   - Different dedup rules → different Silver tables
   - All feed from same Bronze source
   - Consistent source
   - Easy to compare approaches

### Example: Retry Scenario

**With processing in Bronze**:
```
Source sends bad data → Bronze processes it (applies dedup)
→ Bad data propagates to Silver/Gold
→ Must rebuild from source (call them, get new dump, etc.)
→ Hours of work
```

**Without processing in Bronze**:
```
Source sends bad data → Bronze stores raw
→ Discover problem in Silver
→ Fix Silver transformation logic
→ Re-run Silver from Bronze (minutes)
→ Problem solved
```

### Trade-offs

**Against**: May need to store more data (uncompressed raw)
**Mitigated by**: Storage is cheap; flexibility is valuable

---

## 5. Silver as Source of Truth

**Decision**: Silver layer is the definitive business source of truth; Gold reads from Silver

### Benefits

1. **Enables Multiple Representations**
   - One clean Silver entity
   - Multiple Gold aggregations without duplication
   - Different fact tables serve different needs
   - All consistent (same source)

2. **Fact-to-Fact Reads Prevented**
   - Facts can't read other facts (rule)
   - Must read from Silver
   - Ensures consistency
   - Prevents cascading failures

   **Example**: Revenue fact + Session fact both read from Silver
   ```
   Silver.booking → Gold.f_booking
                 → Gold.f_daily_summary
   ```

3. **Clear Ownership**
   - Silver owner owns data quality
   - Gold tables don't need to validate independently
   - Single point of fix
   - Easier accountability

4. **Decoupling**
   - Gold layers independent of each other
   - Changes to one fact don't affect others
   - Can add new facts without touching existing ones
   - Easy parallel work

### Counterexample (Why Not Facts from Facts)

**Bad Pattern** (why we don't allow it):
```
f_booking reads → f_redirect (WRONG)
    ↓
If f_redirect fails/is delayed:
- f_booking can't refresh
- Cascading dependency
- Hard to debug (which layer has the problem?)
- Can't replay independently
```

**Good Pattern** (what we do):
```
f_booking reads → Silver (correct)
f_redirect reads → Silver (correct)
    ↓
Each independent
Either can be reprocessed without affecting the other
```

---

## 6. Daily Updates for Silver/Gold

**Decision**: Silver and Gold update once per day (not real-time)

### Benefits

1. **Cost-Effective**
   - Avoid continuous cluster overhead
   - Batch processing more efficient than streaming
   - Compute resources used efficiently
   - 1/24th the cost vs hourly

2. **Operational Simplicity**
   - Scheduled pipelines easier to manage
   - Single job per layer per day
   - Easier troubleshooting
   - Consistent SLA

3. **Quality Opportunity**
   - Can run comprehensive quality checks
   - Backfill errors caught before publication
   - Full-day data available for validation
   - Better accuracy than incremental

4. **Data Freshness Sufficient**
   - Most analytics can wait until morning
   - BI reports show "as of yesterday"
   - Faster for decision-making than manual
   - Real-time rarely needed for BI

### Why Not Real-Time?

**Cost**: Real-time streaming 24/7 cluster costs ~$100k+/year
**Complexity**: Stream processing has gotchas (out-of-order, late data, state management)
**Usage**: Most analytics run business hours (data from yesterday sufficient)

### Trade-offs

**Against**: Real-time insights (not available until next morning)
**Mitigated by**: Real-time needs served by streaming layer (not medallion); most BI satisfied with daily

---

## 7. Deduplication in Silver

**Decision**: Deduplication happens in Silver, not Bronze

### Benefits

1. **Flexibility**
   - Different use cases need different dedup rules
   - Not a one-size-fits-all decision
   - Can create multiple Silver representations

2. **Transparency**
   - Dedup logic visible in Silver transformation
   - Easy to audit and change
   - Documentation clear
   - Easy to compare different dedup rules

3. **No Bronze Modification**
   - Bronze stays immutable
   - Can experiment with new dedup approaches
   - Preserve original data

### Example: Multiple Dedup Rules

```
Bronze: raw_redirect_events (all events including duplicates)
        ↓
Silver - Dedup Variant 1: Keep first occurrence
Silver - Dedup Variant 2: Keep most recent occurrence
Silver - Dedup Variant 3: Keep aggregated count

Gold: f_redirect (uses Silver Dedup Variant 1)
```

### Trade-offs

**Against**: Duplicates remain in Bronze (doesn't match data warehouse norms)
**Benefit**: Flexibility and auditability outweigh familiarity

---

## 8. Data Domains & Ownership

**Decision**: Organize data by business concept domains with single owner squad per domain

### Benefits

1. **Clear Accountability**
   - One squad owns quality
   - Easy to escalate issues
   - SLA clear (domain X owner responsible)
   - No finger-pointing

2. **Domain Knowledge**
   - Squad builds expertise over time
   - Understands business concept deeply
   - Can make good design decisions
   - Evolves domain thoughtfully

3. **Scaling**
   - Multiple squads work independently
   - Minimal coordination needed
   - Each owns their domain end-to-end
   - Parallel development possible

4. **Data Discoverability**
   - Related datasets grouped logically
   - Easy to find all Booking data
   - Names reflect business (not tech)
   - Discoverable by business users

### Alternative (Why Not Team-Based)?

**If named by team**: `ziggy_domain`, `mobile_domain`
- Problem: Squad reorganizes, domain name wrong
- Problem: Squad focus changes, domain becomes dumping ground
- Problem: Data outlives team

**Named by concept**: `redirect`, `booking`, `session`
- Domain outlives any team ownership
- Team can change, domain stable
- Business focused (clear to consumers)

---

## 9. 7-Year Retention for Core Layers

**Decision**: Bronze, Silver, Gold default to 7-year retention

### Benefits

1. **Enables Year-over-Year Analysis**
   - Can compare this year vs last year
   - Multi-year trends visible
   - Seasonal analysis possible
   - Growth tracking over years

2. **Compliance Flexibility**
   - Regulatory often requires 5-7 years
   - Insurance/audit may need historical
   - Covers most jurisdictions
   - No gaps in coverage

3. **Reprocessing Capability**
   - If logic changes after 1 year, can reprocess
   - Historical results have continuity
   - Easier to fix systemic issues
   - More time to discover problems

### Why Not Longer?

**Cost**: 10-year retention ~$50k/year storage (rough)
**Usage**: Rarely need data beyond 7 years for analytics
**Regulation**: Most regs require 5-7, not 10

### Why 6 Months for Silicon?

**ML Lifecycle**: Models deprecate quickly
- New training data supersedes old
- Model versions change frequently
- 6 months typically covers 2-3 model generations
- Reduces storage cost

---

## 10. External Tables for Trusted Pipeline

**Decision**: Fivetran/Lakeflow ingestion creates external tables in Bronze

### Benefits

1. **Avoids Large Data Movement**
   - Fivetran writes to S3 location
   - Databricks creates table (no copy)
   - Saves ingestion time
   - Saves networking costs

2. **Access Control**
   - Fivetran writes to specific location
   - Databricks creates managed table on top
   - UC controls table access (not S3)
   - Cleaner governance

3. **Preserves Immutability**
   - External table maps to immutable location
   - Source system (Fivetran) can't change
   - Databricks can't accidentally delete
   - Bronze data protected

### Trade-offs

**Against**: External table requires both S3 + UC permissions
**Mitigated by**: Clear separation of concerns; simpler overall

---

## Summary: Design Philosophy

The Medallion Architecture at Skyscanner emphasizes:

1. **Auditability**: Keep raw data, enable replay
2. **Flexibility**: Support multiple representations
3. **Scalability**: Enable independent team work
4. **Clarity**: Clear business concepts, ownership
5. **Compliance**: Support regulatory requirements
6. **Cost-Effectiveness**: Balance flexibility with operational costs

Each design decision trades off against alternatives; this set of decisions optimizes for Skyscanner's needs: rapid business changes, regulatory compliance, and multi-team coordination.

---

## References

- Layer specifications: See `layer-specifications.md`
- Data flows: See `data-flows.md`
- Technical standards: See `technical-standards.md`
