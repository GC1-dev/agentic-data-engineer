---
name: json-formatter
description: Format, validate, and manipulate JSON data. Use when users need to pretty-print JSON, minify JSON, validate JSON syntax, convert between JSON and other formats, extract values from JSON, or work with malformed JSON. Handles nested structures, large files, and provides clear error messages for invalid JSON.
---

# JSON Formatter Skill

Format, validate, and manipulate JSON data with ease.

## Overview

This skill helps format, validate, and work with JSON data. It handles pretty-printing, minification, validation, and common JSON operations.

## When to Use This Skill

Trigger when users request:
- "format JSON", "pretty print JSON", "beautify JSON"
- "validate JSON", "check JSON syntax", "fix JSON"
- "minify JSON", "compact JSON", "compress JSON"
- "parse JSON", "extract from JSON"
- Any JSON formatting or manipulation task

## Quick Operations

### Pretty Print JSON

```python
import json

# Compact JSON
compact = '{"name":"John","age":30,"city":"New York"}'

# Pretty print with 2-space indent
formatted = json.dumps(json.loads(compact), indent=2)
print(formatted)
```

**Output:**
```json
{
  "name": "John",
  "age": 30,
  "city": "New York"
}
```

### Minify JSON

```python
import json

# Pretty JSON
pretty = '''
{
  "name": "John",
  "age": 30,
  "city": "New York"
}
'''

# Minify (remove whitespace)
minified = json.dumps(json.loads(pretty), separators=(',', ':'))
print(minified)
```

**Output:**
```json
{"name":"John","age":30,"city":"New York"}
```

### Validate JSON

```python
import json

def validate_json(json_string):
    try:
        json.loads(json_string)
        return True, "Valid JSON"
    except json.JSONDecodeError as e:
        return False, f"Invalid JSON: {e.msg} at line {e.lineno}, column {e.colno}"

# Test
result, message = validate_json('{"name": "John", "age": 30}')
print(f"Valid: {result}, Message: {message}")
```

## Common Operations

### Sort Keys

```python
import json

data = {
    "zebra": 1,
    "apple": 2,
    "banana": 3
}

# Sort keys alphabetically
sorted_json = json.dumps(data, indent=2, sort_keys=True)
print(sorted_json)
```

**Output:**
```json
{
  "apple": 2,
  "banana": 3,
  "zebra": 1
}
```

### Custom Indentation

```python
import json

data = {"name": "John", "age": 30}

# 4-space indent
print(json.dumps(data, indent=4))

# Tab indent
print(json.dumps(data, indent='\t'))
```

### Handle Special Characters

```python
import json

data = {
    "message": "Hello \"World\"",
    "path": "C:\\Users\\John\\Documents",
    "unicode": "Hello 世界"
}

# Escape special characters
formatted = json.dumps(data, indent=2, ensure_ascii=False)
print(formatted)
```

**Output:**
```json
{
  "message": "Hello \"World\"",
  "path": "C:\\Users\\John\\Documents",
  "unicode": "Hello 世界"
}
```

### Extract Values

```python
import json

json_string = '''
{
  "user": {
    "name": "John",
    "email": "john@example.com",
    "address": {
      "city": "New York",
      "zip": "10001"
    }
  }
}
'''

data = json.loads(json_string)

# Extract nested values
name = data['user']['name']
city = data['user']['address']['city']

print(f"Name: {name}, City: {city}")
```

### Safe Value Extraction

```python
import json

def safe_get(data, *keys, default=None):
    """Safely extract nested values from JSON"""
    for key in keys:
        try:
            data = data[key]
        except (KeyError, TypeError, IndexError):
            return default
    return data

json_data = {"user": {"name": "John"}}

# Safe extraction
name = safe_get(json_data, "user", "name", default="Unknown")
email = safe_get(json_data, "user", "email", default="No email")

print(f"Name: {name}, Email: {email}")
```

## Working with Files

### Read and Format JSON File

```python
import json

# Read JSON file
with open('data.json', 'r') as f:
    data = json.load(f)

# Format and save
with open('formatted.json', 'w') as f:
    json.dump(data, f, indent=2, sort_keys=True)
```

### Handle Large JSON Files

```python
import json

# Stream large JSON file
with open('large_data.json', 'r') as f:
    # Load incrementally
    for line in f:
        try:
            record = json.loads(line)
            # Process record
            print(record)
        except json.JSONDecodeError:
            continue
```

### Save with Pretty Print

```python
import json

data = {
    "users": [
        {"name": "Alice", "age": 25},
        {"name": "Bob", "age": 30}
    ]
}

with open('output.json', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
```

## Fixing Common Issues

### Remove Trailing Commas

```python
import re
import json

def fix_trailing_commas(json_string):
    """Remove trailing commas before } or ]"""
    # Remove comma before }
    json_string = re.sub(r',\s*}', '}', json_string)
    # Remove comma before ]
    json_string = re.sub(r',\s*]', ']', json_string)
    return json_string

malformed = '''
{
  "name": "John",
  "age": 30,
}
'''

fixed = fix_trailing_commas(malformed)
data = json.loads(fixed)
print(json.dumps(data, indent=2))
```

### Handle Single Quotes

```python
import json

def fix_single_quotes(json_string):
    """Convert single quotes to double quotes"""
    return json_string.replace("'", '"')

malformed = "{'name': 'John', 'age': 30}"
fixed = fix_single_quotes(malformed)
data = json.loads(fixed)
print(json.dumps(data, indent=2))
```

### Fix Unquoted Keys

```python
import re
import json

def fix_unquoted_keys(json_string):
    """Add quotes around unquoted keys"""
    # Pattern: word followed by colon (not already quoted)
    pattern = r'(\w+)(?=\s*:)'
    fixed = re.sub(pattern, r'"\1"', json_string)
    return fixed

malformed = "{name: 'John', age: 30}"
fixed = fix_unquoted_keys(malformed)
fixed = fix_single_quotes(fixed)
data = json.loads(fixed)
print(json.dumps(data, indent=2))
```

## Conversion

### JSON to CSV

```python
import json
import csv

# JSON array of objects
json_data = '''
[
  {"name": "Alice", "age": 25, "city": "New York"},
  {"name": "Bob", "age": 30, "city": "Los Angeles"}
]
'''

data = json.loads(json_data)

# Write to CSV
with open('output.csv', 'w', newline='') as f:
    if data:
        writer = csv.DictWriter(f, fieldnames=data[0].keys())
        writer.writeheader()
        writer.writerows(data)
```

### JSON to YAML

```python
import json
import yaml

json_data = '''
{
  "name": "John",
  "age": 30,
  "hobbies": ["reading", "coding"]
}
'''

data = json.loads(json_data)

# Convert to YAML
yaml_string = yaml.dump(data, default_flow_style=False)
print(yaml_string)
```

### JSON to Python Dict

```python
import json

json_string = '{"name": "John", "age": 30}'

# Parse to Python dictionary
data = json.loads(json_string)

# Access as dict
print(f"Name: {data['name']}")
print(f"Age: {data['age']}")

# Convert back to JSON
json_output = json.dumps(data, indent=2)
```

## Advanced Formatting

### Custom Serialization

```python
import json
from datetime import datetime, date
from decimal import Decimal

class CustomEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, (datetime, date)):
            return obj.isoformat()
        if isinstance(obj, Decimal):
            return float(obj)
        if isinstance(obj, set):
            return list(obj)
        return super().default(obj)

data = {
    "timestamp": datetime.now(),
    "date": date.today(),
    "amount": Decimal("123.45"),
    "tags": {"python", "json", "formatting"}
}

formatted = json.dumps(data, cls=CustomEncoder, indent=2)
print(formatted)
```

### Format with Color (Terminal)

```python
import json
from pygments import highlight
from pygments.lexers import JsonLexer
from pygments.formatters import TerminalFormatter

data = {"name": "John", "age": 30}
json_string = json.dumps(data, indent=2)

# Syntax highlighting for terminal
colored = highlight(json_string, JsonLexer(), TerminalFormatter())
print(colored)
```

### Compact Arrays

```python
import json

data = {
    "name": "John",
    "scores": [95, 87, 92, 88, 91],
    "tags": ["python", "json", "data"]
}

# Custom formatting: compact arrays
def custom_format(obj, indent=0):
    if isinstance(obj, dict):
        lines = ['{']
        items = list(obj.items())
        for i, (key, value) in enumerate(items):
            comma = ',' if i < len(items) - 1 else ''
            if isinstance(value, (list, dict)):
                lines.append(f'  {json.dumps(key)}: {custom_format(value, indent + 2)}{comma}')
            else:
                lines.append(f'  {json.dumps(key)}: {json.dumps(value)}{comma}')
        lines.append('}')
        return '\n'.join(lines)
    elif isinstance(obj, list):
        return json.dumps(obj)  # Keep arrays compact
    else:
        return json.dumps(obj)

print(custom_format(data))
```

## Error Handling

### Detailed Error Messages

```python
import json

def parse_json_with_error(json_string):
    try:
        return json.loads(json_string), None
    except json.JSONDecodeError as e:
        # Get context around error
        lines = json_string.split('\n')
        error_line = lines[e.lineno - 1] if e.lineno <= len(lines) else ""
        
        error_msg = f"""
JSON Parsing Error:
  Message: {e.msg}
  Line: {e.lineno}
  Column: {e.colno}
  Context: {error_line}
  Pointer: {' ' * (e.colno - 1)}^
"""
        return None, error_msg

# Test with invalid JSON
invalid_json = '''
{
  "name": "John",
  "age": 30,
  "city": "New York"
  "country": "USA"
}
'''

data, error = parse_json_with_error(invalid_json)
if error:
    print(error)
```

### Try Multiple Fixes

```python
import json
import re

def smart_parse_json(json_string):
    """Try multiple methods to parse potentially malformed JSON"""
    
    # Try 1: Parse as-is
    try:
        return json.loads(json_string), "Parsed successfully"
    except json.JSONDecodeError:
        pass
    
    # Try 2: Remove trailing commas
    try:
        fixed = re.sub(r',\s*}', '}', json_string)
        fixed = re.sub(r',\s*]', ']', fixed)
        return json.loads(fixed), "Fixed trailing commas"
    except json.JSONDecodeError:
        pass
    
    # Try 3: Replace single quotes
    try:
        fixed = json_string.replace("'", '"')
        return json.loads(fixed), "Fixed single quotes"
    except json.JSONDecodeError:
        pass
    
    return None, "Could not parse JSON"

# Test
malformed = "{'name': 'John', 'age': 30,}"
data, message = smart_parse_json(malformed)
if data:
    print(f"Success: {message}")
    print(json.dumps(data, indent=2))
```

## Best Practices

### Always Use Try-Except

```python
import json

def safe_json_operation(json_string):
    try:
        data = json.loads(json_string)
        formatted = json.dumps(data, indent=2)
        return formatted, None
    except json.JSONDecodeError as e:
        return None, f"Error: {e.msg} at line {e.lineno}"
    except Exception as e:
        return None, f"Unexpected error: {str(e)}"
```

### Validate Before Processing

```python
import json

def process_json(json_string):
    # Validate first
    try:
        data = json.loads(json_string)
    except json.JSONDecodeError as e:
        print(f"Invalid JSON: {e.msg}")
        return
    
    # Now safe to process
    print(json.dumps(data, indent=2, sort_keys=True))
```

### Use Appropriate Encoding

```python
import json

# For API responses (ASCII safe)
json.dumps(data, ensure_ascii=True)

# For human-readable files (preserve Unicode)
json.dumps(data, ensure_ascii=False, indent=2)
```

## Common Use Cases

### API Response Formatting

```python
import json

# Raw API response
api_response = '{"status":"success","data":{"users":[{"id":1,"name":"Alice"},{"id":2,"name":"Bob"}]}}'

# Format for readability
parsed = json.loads(api_response)
formatted = json.dumps(parsed, indent=2)
print(formatted)
```

### Configuration File Pretty Print

```python
import json

config = {
    "database": {
        "host": "localhost",
        "port": 5432,
        "name": "mydb"
    },
    "cache": {
        "enabled": True,
        "ttl": 3600
    }
}

with open('config.json', 'w') as f:
    json.dump(config, f, indent=2, sort_keys=True)
```

### Log File JSON Extraction

```python
import json

log_line = '2024-11-24 INFO {"user": "john", "action": "login", "status": "success"}'

# Extract JSON from log line
start = log_line.find('{')
if start != -1:
    json_part = log_line[start:]
    data = json.loads(json_part)
    print(json.dumps(data, indent=2))
```

## Quick Reference

| Task | Command |
|------|---------|
| Pretty print | `json.dumps(data, indent=2)` |
| Minify | `json.dumps(data, separators=(',', ':'))` |
| Sort keys | `json.dumps(data, sort_keys=True)` |
| Parse string | `json.loads(json_string)` |
| Read file | `json.load(file_object)` |
| Write file | `json.dump(data, file_object)` |
| Validate | `try: json.loads(s) except JSONDecodeError` |
| Preserve Unicode | `json.dumps(data, ensure_ascii=False)` |

## Success Criteria

A successful JSON operation:
1. **Valid output** - Proper JSON syntax
2. **Readable format** - Appropriate indentation
3. **Preserved data** - No data loss during formatting
4. **Clear errors** - Helpful error messages for invalid JSON
5. **Consistent style** - Uniform formatting throughout

## Tips

- Always validate JSON before processing
- Use try-except for robust error handling
- Choose appropriate indentation (2 or 4 spaces)
- Sort keys for consistent output
- Preserve Unicode characters when needed
- Handle large files with streaming
- Test with edge cases (nested objects, special characters)
