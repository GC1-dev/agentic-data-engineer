---
name: skyscanner-data-shared-utils
description: Work with Skyscanner's data-shared-utils library for PySpark data transformations including DataFrame operations, currency conversion, time formatting, data cleaning, and business logic utilities. Use when users need DataFrame utilities, transformation functions, or common data operations.
---

# Skyscanner Data Shared Utils Skill

Work with Skyscanner's data-shared-utils library for PySpark transformations and data operations.

## Overview

The `skyscanner-data-shared-utils` library (v1.0.4+) provides utilities for Databricks data engineering:

- **DataFrame Utilities**: Read tables, union DataFrames, schema operations
- **Transformation Utilities**: Currency conversion, time formatting, data cleaning, geo operations
- **General Utilities**: Byte conversion and formatting

## When to Use This Skill

Trigger when users request:
- "read table", "union dataframes", "schema operations"
- "currency conversion", "price conversion", "exchange rates"
- "time conversion", "timestamp formatting", "duration formatting"
- "data transformation", "data cleaning", "filter invalid data"
- "pyspark utilities", "dataframe operations"
- "business data transformations"

## Installation

```bash
# Install from Artifactory
pip install skyscanner-data-shared-utils

# Poetry
poetry add skyscanner-data-shared-utils
```

**Dependencies:**
- `PySpark ^3.2`

## Package Structure

```
data_shared_utils/
├── dataframe_utils/      # DataFrame read/write operations
├── transformation_utils/ # Business data transformations
└── general_utils/        # Byte conversion utilities
```

## Quick Start

### Import from Top-Level Package

```python
# Import commonly used functions from top level
from data_shared_utils import (
    # DataFrame utilities
    read_table,
    union_dataframes,
    schema_to_structtype_code,
    get_table_struct_schema,
    # Transformation utilities
    convert_price_to_decimals,
    convert_weight_to_kg,
    duration_second_to_human_readable,
    filter_invalid_ids,
    # General utilities
    bytes_to_gb,
    bytes_to_human_readable,
)
```

## DataFrame Utilities

### Read Table with Date Partition

```python
from data_shared_utils import read_table
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType

# Define schema
schema = StructType([
    StructField("booking_id", StringType(), False),
    StructField("customer_id", StringType(), False),
    StructField("amount", IntegerType(), True),
    StructField("dt", StringType(), False),
])

# Read table filtered by date partition
spark = SparkSession.builder.getOrCreate()
df = read_table(spark, "catalog.schema.bookings", schema, "2024-01-15")

# Only columns in schema are selected
df.show()
```

**Key Features:**
- Filters by `dt` partition automatically
- Projects only columns specified in schema
- Returns empty DataFrame if partition doesn't exist (no exception)

### Union Multiple DataFrames

```python
from data_shared_utils.dataframe_utils import union_dataframes
from pyspark.sql import SparkSession

spark = SparkSession.builder.getOrCreate()

# Create sample DataFrames
df1 = spark.createDataFrame([(1, "Alice"), (2, "Bob")], ["id", "name"])
df2 = spark.createDataFrame([(3, "Charlie"), (4, "David")], ["id", "name"])
df3 = spark.createDataFrame([(5, "Eve"), (6, "Frank")], ["id", "name"])

# Union multiple DataFrames
result = union_dataframes([df1, df2, df3])

result.show()
# +---+-------+
# | id|   name|
# +---+-------+
# |  1|  Alice|
# |  2|    Bob|
# |  3|Charlie|
# |  4|  David|
# |  5|    Eve|
# |  6|  Frank|
# +---+-------+
```

### Select Columns in Schema Order

```python
from data_shared_utils.dataframe_utils import select_columns_in_schema_order
from pyspark.sql.types import StructType, StructField, StringType, IntegerType

# Define desired schema order
target_schema = StructType([
    StructField("id", IntegerType(), False),
    StructField("name", StringType(), True),
    StructField("age", IntegerType(), True),
])

# DataFrame with different column order
df = spark.createDataFrame(
    [(25, "Alice", 1), (30, "Bob", 2)],
    ["age", "name", "id"]
)

# Reorder columns to match schema
ordered_df = select_columns_in_schema_order(df, target_schema)
ordered_df.printSchema()
# root
#  |-- id: integer (nullable = false)
#  |-- name: string (nullable = true)
#  |-- age: integer (nullable = true)
```

### Generate Schema Code

```python
from data_shared_utils import schema_to_structtype_code
from pyspark.sql import SparkSession

spark = SparkSession.builder.getOrCreate()
df = spark.createDataFrame(
    [(1, "Alice", 25), (2, "Bob", 30)],
    ["id", "name", "age"]
)

# Generate StructType code from DataFrame schema
code = schema_to_structtype_code(df.schema)
print(code)
```

**Output:**
```python
StructType([
    StructField("id", LongType(), True),
    StructField("name", StringType(), True),
    StructField("age", LongType(), True),
])
```

### Get Table Schema as StructType

```python
from data_shared_utils import get_table_struct_schema

# Get schema from existing table
schema = get_table_struct_schema(spark, "catalog.schema.table_name")

# Use schema for reading with projection
df = read_table(spark, "catalog.schema.table_name", schema, "2024-01-15")
```

## Transformation Utilities

### Currency Conversion

```python
from data_shared_utils.transformation_utils import (
    find_currency_conversion_latest_date,
    convert_price_to_decimals,
)
from pyspark.sql import SparkSession

spark = SparkSession.builder.getOrCreate()

# Find latest exchange rate date within 7 days
exchange_rate_df = spark.table("catalog.schema.exchange_rates")
latest_date = find_currency_conversion_latest_date(
    df=exchange_rate_df,
    target_date="2024-01-15",
    date_col="date",
    max_age_days=7
)
print(f"Using exchange rates from: {latest_date}")

# Convert prices to decimals with proper precision
bookings_df = spark.table("catalog.schema.bookings")
converted_df = convert_price_to_decimals(
    df=bookings_df,
    price_col="total_amount",
    precision=10,
    scale=2
)
converted_df.show()
```

**Key Functions:**
- `find_currency_conversion_latest_date()`: Find closest exchange rate date
- `convert_price_to_decimals()`: Convert numeric to DecimalType
- `convert_price_with_currency()`: Convert with currency lookup

### Time Conversions

```python
from data_shared_utils.transformation_utils import (
    duration_second_to_minutes,
    duration_second_to_human_readable,
    convert_timestamp_to_date,
    convert_unix_millis_to_timestamp,
    normalize_timestamp_precision,
)
from pyspark.sql import functions as F

# Convert duration seconds to minutes
df = df.withColumn("flight_duration_minutes",
    duration_second_to_minutes(F.col("flight_duration_sec")))

# Convert to human-readable format (e.g., "2h 30m")
df = df.withColumn("duration_readable",
    duration_second_to_human_readable(F.col("flight_duration_sec")))

# Convert timestamp to date
df = df.withColumn("booking_date",
    convert_timestamp_to_date(F.col("booking_timestamp")))

# Convert Unix milliseconds to timestamp
df = df.withColumn("event_timestamp",
    convert_unix_millis_to_timestamp(F.col("event_time_millis")))

# Normalize timestamp precision (handle microseconds vs milliseconds)
df = df.withColumn("normalized_ts",
    normalize_timestamp_precision(F.col("raw_timestamp")))
```

### Data Quality Transformations

```python
from data_shared_utils.transformation_utils import (
    filter_invalid_ids,
    convert_weight_to_kg,
    trim_and_nullify,
)
from pyspark.sql import functions as F

# Filter out invalid booking IDs (null, empty, whitespace)
clean_df = filter_invalid_ids(df, "booking_id")

# Convert weight from various units to kg
df = df.withColumn("weight_kg",
    convert_weight_to_kg(F.col("weight"), F.col("weight_unit")))

# Trim strings and convert empty/whitespace to null
df = df.withColumn("customer_name",
    trim_and_nullify(F.col("raw_customer_name")))
```

### Geographic Transformations

```python
from data_shared_utils.transformation_utils import add_origin_destination_columns
from pyspark.sql import functions as F

# Add origin and destination info from location lookup
flights_df = spark.table("catalog.schema.flights")
locations_df = spark.table("catalog.schema.airport_locations")

enriched_df = add_origin_destination_columns(
    flights_df,
    locations_df,
    origin_col="origin_airport_code",
    destination_col="dest_airport_code"
)

enriched_df.show()
```

### IP-Based User Identification

```python
from data_shared_utils.transformation_utils import add_is_internal_user

# Mark internal users based on IP ranges
sessions_df = spark.table("catalog.schema.user_sessions")

# Add is_internal_user boolean column
flagged_df = add_is_internal_user(
    sessions_df,
    ip_col="user_ip_address"
)

# Filter external users only
external_users = flagged_df.filter(F.col("is_internal_user") == False)
```

## General Utilities

### Byte Conversion

```python
from data_shared_utils import bytes_to_gb, bytes_to_human_readable

# Convert bytes to gigabytes
file_size_bytes = 5368709120
size_gb = bytes_to_gb(file_size_bytes)
print(f"Size: {size_gb:.2f} GB")  # Size: 5.00 GB

# Convert to human-readable format
readable_size = bytes_to_human_readable(file_size_bytes)
print(f"Size: {readable_size}")  # Size: 5.00 GB

# Works with different scales
small_file = 1024
print(bytes_to_human_readable(small_file))  # 1.00 KB

large_file = 1099511627776
print(bytes_to_human_readable(large_file))  # 1.00 TB
```

## Complete Pipeline Example

### Bronze to Silver with Transformations

```python
from data_shared_utils import (
    read_table,
    convert_price_to_decimals,
    filter_invalid_ids,
    duration_second_to_minutes,
    bytes_to_human_readable,
)
from pyspark.sql import SparkSession, functions as F
from pyspark.sql.types import StructType, StructField, StringType, IntegerType

# Get existing Spark session (assume already created)
spark = SparkSession.builder.getOrCreate()

# Define schema
bronze_schema = StructType([
    StructField("booking_id", StringType(), False),
    StructField("customer_id", StringType(), False),
    StructField("total_amount", IntegerType(), True),
    StructField("flight_duration_sec", IntegerType(), True),
    StructField("dt", StringType(), False),
])

# Read from Bronze with date partition
bronze_df = read_table(
    spark,
    "catalog.bronze.raw_bookings",
    bronze_schema,
    "2024-01-15"
)

print(f"Loaded {bronze_df.count()} records from Bronze")

# Apply transformations
silver_df = bronze_df

# 1. Filter invalid IDs
silver_df = filter_invalid_ids(silver_df, "booking_id")

# 2. Convert prices to decimals
silver_df = convert_price_to_decimals(
    silver_df,
    price_col="total_amount",
    precision=10,
    scale=2
)

# 3. Convert duration to minutes
silver_df = silver_df.withColumn(
    "flight_duration_minutes",
    duration_second_to_minutes(F.col("flight_duration_sec"))
)

# 4. Add processing metadata
silver_df = silver_df \
    .withColumn("processed_timestamp", F.current_timestamp()) \
    .withColumn("source_layer", F.lit("bronze"))

# Write to Silver
silver_df.write \
    .format("delta") \
    .mode("overwrite") \
    .partitionBy("dt") \
    .saveAsTable("catalog.silver.bookings")

print(f"Written {silver_df.count()} records to Silver")

# Get table size
table_info = spark.sql("DESCRIBE DETAIL catalog.silver.bookings").collect()[0]
table_size_bytes = table_info['sizeInBytes']
print(f"Table size: {bytes_to_human_readable(table_size_bytes)}")
```

## Import Patterns

### Top-Level Imports (Recommended)

```python
# Import commonly used functions from package root
from data_shared_utils import (
    read_table,
    union_dataframes,
    convert_price_to_decimals,
    filter_invalid_ids,
    bytes_to_gb,
)
```

### Submodule Imports

```python
# Import from specific submodules
from data_shared_utils.dataframe_utils import (
    read_table,
    union_dataframes,
    select_columns_in_schema_order,
    schema_to_structtype_code,
)

from data_shared_utils.transformation_utils import (
    convert_price_to_decimals,
    duration_second_to_human_readable,
    filter_invalid_ids,
    add_origin_destination_columns,
)

from data_shared_utils.general_utils import (
    bytes_to_gb,
    bytes_to_human_readable,
)
```

## Available Functions by Module

### dataframe_utils

| Function | Description |
|----------|-------------|
| `read_table()` | Read table with date partition and schema projection |
| `union_dataframes()` | Union multiple DataFrames |
| `select_columns_in_schema_order()` | Reorder columns to match schema |
| `schema_to_structtype_code()` | Generate StructType code from schema |
| `get_table_struct_schema()` | Get table schema as StructType |

### transformation_utils (Currency)

| Function | Description |
|----------|-------------|
| `find_currency_conversion_latest_date()` | Find closest exchange rate date |
| `convert_price_to_decimals()` | Convert price to DecimalType |
| `convert_price_with_currency()` | Convert with currency lookup |

### transformation_utils (Time)

| Function | Description |
|----------|-------------|
| `duration_second_to_minutes()` | Convert seconds to minutes |
| `duration_second_to_human_readable()` | Format as "2h 30m" |
| `convert_timestamp_to_date()` | Extract date from timestamp |
| `convert_unix_millis_to_timestamp()` | Convert Unix millis to timestamp |
| `normalize_timestamp_precision()` | Handle timestamp precision issues |

### transformation_utils (Data Quality)

| Function | Description |
|----------|-------------|
| `filter_invalid_ids()` | Remove null/empty IDs |
| `convert_weight_to_kg()` | Standardize weight units |
| `trim_and_nullify()` | Clean string data |

### transformation_utils (Geographic/IP)

| Function | Description |
|----------|-------------|
| `add_origin_destination_columns()` | Enrich with location data |
| `add_is_internal_user()` | Flag internal IP ranges |

### general_utils

| Function | Description |
|----------|-------------|
| `bytes_to_gb()` | Convert bytes to gigabytes |
| `bytes_to_human_readable()` | Format bytes as KB/MB/GB/TB |

## Best Practices

### 1. Use Schema Projection for Performance

```python
# GOOD - Read only needed columns
schema = StructType([
    StructField("id", StringType()),
    StructField("name", StringType()),
])
df = read_table(spark, "catalog.schema.table", schema, "2024-01-15")

# AVOID - Reading all columns
df = spark.table("catalog.schema.table").filter("dt = '2024-01-15'")
```

### 2. Handle Currency with Proper Precision

```python
# GOOD - Use DecimalType for money
df = convert_price_to_decimals(df, "amount", precision=10, scale=2)

# AVOID - Using Float/Double for currency
df = df.withColumn("amount", F.col("amount").cast("double"))
```

### 3. Validate IDs Before Processing

```python
# GOOD - Filter invalid IDs early
df = filter_invalid_ids(df, "booking_id")
result = process_bookings(df)

# AVOID - Processing invalid data
result = process_bookings(df)  # May fail on nulls
```

### 4. Use Human-Readable Formats for Reports

```python
# GOOD - Format for readability
df = df.withColumn("size", bytes_to_human_readable(F.col("size_bytes")))
df = df.withColumn("duration", duration_second_to_human_readable(F.col("seconds")))

# AVOID - Raw numbers in reports
df.select("size_bytes", "seconds").show()
```

## Troubleshooting

### Issue: SparkSessionFactory/ConfigLoader Not Found

```python
# ERROR: cannot import name 'SparkSessionFactory' from 'data_shared_utils'
# ERROR: cannot import name 'ConfigLoader' from 'data_shared_utils'

# SOLUTION: Spark session management is in spark-session-utils package
# Use the skyscanner-spark-session-utils-skill for session management
from spark_session_utils import SparkSessionFactory, ConfigLoader
```

### Issue: read_table Returns Empty DataFrame

```python
# ISSUE: read_table returns no data

# CHECK: Verify partition exists
spark.sql("SHOW PARTITIONS catalog.schema.table").show()

# CHECK: Verify date format (must be YYYY-MM-DD)
df = read_table(spark, "table", schema, "2024-01-15")  # Correct
# df = read_table(spark, "table", schema, "01/15/2024")  # Wrong format
```

### Issue: Currency Conversion Date Not Found

```python
# ERROR: No currency conversion data found within 7 days

# SOLUTION: Increase max_age_days or verify data exists
latest_date = find_currency_conversion_latest_date(
    df=exchange_rate_df,
    target_date="2024-01-15",
    max_age_days=14  # Increase from default 7
)
```

## Quick Reference

| Task | Function |
|------|----------|
| Read partitioned table | `read_table(spark, table, schema, date)` |
| Union DataFrames | `union_dataframes([df1, df2, df3])` |
| Generate schema code | `schema_to_structtype_code(df.schema)` |
| Convert currency | `convert_price_to_decimals(df, "price", 10, 2)` |
| Find exchange rate | `find_currency_conversion_latest_date(df, "2024-01-15")` |
| Format duration | `duration_second_to_human_readable(col("seconds"))` |
| Clean IDs | `filter_invalid_ids(df, "id_column")` |
| Format bytes | `bytes_to_human_readable(file_size)` |

## Success Criteria

A successful implementation using data-shared-utils includes:
1. **Schema projection** - Read only needed columns for performance
2. **Data validation** - Filter invalid IDs and null values early
3. **Type safety** - Use DecimalType for currency, proper timestamp handling
4. **Readable output** - Format durations, bytes, and other values for humans
5. **Partition filtering** - Use date partitions effectively
6. **Reusable transformations** - Leverage utility functions instead of custom logic

## Tips

- Use `read_table()` for efficient partition-filtered reads with projection
- Always use `DecimalType` for currency via `convert_price_to_decimals()`
- Filter invalid IDs early with `filter_invalid_ids()` to prevent null propagation
- Format output for reports using `bytes_to_human_readable()` and `duration_second_to_human_readable()`
- Union multiple DataFrames efficiently with `union_dataframes()`
- Generate schema code for documentation with `schema_to_structtype_code()`

## Related Libraries

- **spark-session-utils**: Spark session management with SparkSessionFactory and ConfigLoader
- **data-quality-utils**: Data quality validation and profiling
- **data-observability-utils**: Monte Carlo integration for monitoring
- **data-catalog-utils**: Unity Catalog operations without Spark

## Additional Resources

- Artifactory: [skyscanner-data-shared-utils](https://artifactory.skyscannertools.net/artifactory/api/pypi/pypi/simple/skyscanner-data-shared-utils/)
- Version: 1.0.2+
- Dependencies: PySpark ^3.2
