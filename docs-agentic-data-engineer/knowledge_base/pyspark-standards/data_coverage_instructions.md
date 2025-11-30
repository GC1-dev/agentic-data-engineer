
# Data Coverage Dimensions for Testing

Claude must use the following dimensions when generating, reviewing, or improving tests for data pipelines, transformations, or validation logic. All tests must consider these aspects to ensure full **data coverage**, not just code coverage.

---

## 1. Schema Coverage
Tests must validate **all structural aspects** of the dataset:

- Column presence
- Data types
- Nullability constraints
- Primary/unique key constraints
- Partition columns
- Nested structures
- Schema evolution cases

---

## 2. Distribution Coverage
Ensure tests cover typical, rare, and extreme values:

- Min / max values
- Normal ranges
- Long-tail values
- Outliers
- Zero-variance columns
- Value drift scenarios

---

## 3. Logical / Domain Rule Coverage
Tests must validate business logic rules, such as:

- Eligibility logic
- Category mappings
- Unit conversions
- Derived fields
- Conditional logic
- Rule-based quality checks

---

## 4. Edge Case Coverage
Claude must always include edge-case datasets:

- Empty datasets
- Single-row datasets
- Very large datasets
- High-null columns
- Duplicate rows
- Invalid types
- Unexpected categories

---

## 5. Temporal Coverage
Time-related testing requires checking:

- Old timestamps
- Very recent timestamps
- Future timestamps
- Daylight savings transitions
- End-of-month / end-of-quarter boundaries
- Skewed event time distributions

---

## 6. Cross-Field Relationship Coverage
Tests must validate relationships across fields:

- Referential integrity
- Derived correctness
- Multi-column uniqueness
- Consistency checks  
  Example: `arrival_time > departure_time`

---

## 7. Negative Coverage (Invalid Data)
Claude must include negative test cases to ensure that the system **rejects or handles** invalid data:

- Wrong types
- Malformed records
- Missing required fields
- Constraint violations
- Corrupted payloads
- Impossible or illogical values

---

## 8. Volume Coverage
Performance-oriented test dimensions:

- Very small datasets
- Medium datasets
- Large datasets (millions of rows)
- Highly skewed partitions
- Shuffle-heavy operations

---

## 9. Environment Coverage
Tests must consider different runtime environments:

- Local execution
- Test cluster
- Production-like cluster
- Configuration variations
- Dependency version variations

---

## 10. Pipeline Coverage (End-to-End)
Claude must validate holistic pipeline behavior:

- Input ingestion
- Transformations
- Aggregations
- Output schema validation
- Data Quality (DQ) rules
- Metadata propagation
- Data contract enforcement

---

## Summary Table

| Dimension | Description |
|----------|-------------|
| Schema | Column structure, types, constraints |
| Distribution | Range, outliers, distribution drift |
| Logical | Business/domain rules |
| Edge Cases | Missing, empty, null-heavy, duplicates |
| Temporal | Time-based edge cases, DST, skew |
| Cross-field | Integrity between columns |
| Negative | Invalid/malformed data |
| Volume | Sizes from tiny to massive |
| Environment | Local vs cluster differences |
| Pipeline | Full E2E behavior |

---

## Test Dimensions Taxonomy

For systematic test case design, use these dimension categories and values when generating test data and scenarios:

### Volume/Scale Dimensions
- **CARDINALITY**: `empty` | `single` | `few` | `many`
  - Empty: 0 rows
  - Single: 1 row
  - Few: 2-10 rows
  - Many: 100+ rows

- **SCALE**: `small` | `medium` | `large` | `very_large`
  - Small: 100-1K rows
  - Medium: 1K-100K rows
  - Large: 100K-1M rows
  - Very Large: 1M+ rows

### Data Quality Dimensions
- **NULL_HANDLING**: `no_nulls` | `some_nulls` | `all_nulls` | `mixed_nulls`
  - No nulls: All columns have values
  - Some nulls: 10-50% nulls in specific columns
  - All nulls: 100% nulls in a column
  - Mixed nulls: Varying null percentages across columns

- **DATA_TYPES**: `string` | `numeric` | `date` | `boolean` | `nested` | `decimal` | `timestamp`
  - Test different data types individually and in combination
  - Include type mismatches and coercions

- **STRING_VARIANTS**: `empty_string` | `whitespace` | `special_chars` | `unicode` | `long_strings`
  - Empty: ""
  - Whitespace: "   ", "\t", "\n"
  - Special chars: "!@#$%^&*()", "quotes", "backslash"
  - Unicode: Non-ASCII characters
  - Long: Strings exceeding column size limits

### Business Logic Dimensions
- **GROUPING**: `no_groups` | `single_group` | `multiple_groups` | `skewed_groups`
  - No groups: All records belong to one logical group
  - Single group: All records in one category
  - Multiple groups: Records across 2-10 distinct groups
  - Skewed groups: 90% in one group, 10% in others

- **AGGREGATION**: `sum` | `count` | `avg` | `min` | `max` | `distinct` | `concat`
  - Test each aggregation type with various input distributions
  - Include edge cases: negative numbers, zeros, duplicates

- **TIME_PARTITIONING**: `single_date` | `multiple_dates` | `date_range` | `overlapping_ranges` | `gaps`
  - Single date: All records from one date
  - Multiple dates: 2-5 distinct dates
  - Date range: Continuous date span
  - Overlapping ranges: Multiple date ranges that overlap
  - Gaps: Date ranges with missing dates

### Edge Cases Dimensions
- **EDGE_CASES**: `duplicates` | `outliers` | `extreme_values` | `boundary_values` | `contradictions`
  - Duplicates: 100% identical rows or partial duplicates
  - Outliers: Values 3+ standard deviations from mean
  - Extreme values: Maximum/minimum representable values
  - Boundary values: Just above/below threshold limits
  - Contradictions: Logically inconsistent data (e.g., end_date < start_date)

- **SCHEMA_VARIANTS**: `all_required` | `missing_fields` | `extra_fields` | `nested_structures` | `schema_mismatch`
  - All required: Complete schema with no missing columns
  - Missing fields: Required columns absent
  - Extra fields: Additional unexpected columns
  - Nested structures: Complex/hierarchical data
  - Schema mismatch: Different data types than expected

---

## Claude Instructions

Claude must use these dimensions to:

- Generate meaningful test datasets  
- Propose missing test cases  
- Validate completeness of existing tests  
- Improve robustness of data pipelines  
- Suggest additional DQ or contract checks  
- Detect weaknesses in transformations  

When creating new code in `src/`, Claude must generate tests in `tests/` that cover **all relevant dimensions above**.

If a user requests tests, Claude must apply this checklist automatically.
