# ai-native-data-engineering-process Development Guidelines

Auto-generated from all feature plans. Last updated: 2025-11-21

## Active Technologies
- Python 3.10 and 3.11 (multi-version support required) (002-spark-session-utilities)
- Configuration via YAML files (local filesystem), no database required (002-spark-session-utilities)
- Python 3.10, 3.11 + Pydantic 2.0+, PyYAML (already in spark-session-utilities) (002-spark-session-utilities)
- N/A (configuration only) (002-spark-session-utilities)
- Python 3.10+ + PySpark 3.4+, Pydantic 2.0+, databricks-shared-utilities (existing), scipy/numpy (for statistics) (004-dqx-utilities)
- Delta Lake tables (for baseline persistence), optional cloud storage for validation reports (004-dqx-utilities)
- Python 3.10+ (existing codebase standard) (005-separate-utilities)
- N/A (utilities library packages - no persistent storage) (005-separate-utilities)

- Python 3.10+ (Databricks Runtime compatibility) (001-ai-native-data-eng-process)

## Project Structure

```text
src/
tests/
```

## Commands

cd src [ONLY COMMANDS FOR ACTIVE TECHNOLOGIES][ONLY COMMANDS FOR ACTIVE TECHNOLOGIES] pytest [ONLY COMMANDS FOR ACTIVE TECHNOLOGIES][ONLY COMMANDS FOR ACTIVE TECHNOLOGIES] ruff check .

## Code Style

Python 3.10+ (Databricks Runtime compatibility): Follow standard conventions

## Recent Changes
- 005-separate-utilities: Added Python 3.10+ (existing codebase standard)
- 004-dqx-utilities: Added Python 3.10+ + PySpark 3.4+, Pydantic 2.0+, databricks-shared-utilities (existing), scipy/numpy (for statistics)
- 002-spark-session-utilities: Added Python 3.10, 3.11 + Pydantic 2.0+, PyYAML (already in spark-session-utilities)


<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
