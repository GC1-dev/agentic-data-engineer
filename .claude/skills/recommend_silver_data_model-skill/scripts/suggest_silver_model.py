"""
Silver Data Model Suggestion Script

Given business entities and their attributes, this script suggests a normalized
Silver-layer Entity-Centric data model following Medallion Architecture principles.

Usage:
    python suggest_silver_model.py --input entities.json --output suggestion.json
"""

import argparse
import json
from typing import Any


def suggest_silver_data_model(entities: list[dict[str, Any]]) -> dict[str, Any]:
    """
    Suggest a Silver-layer Entity-Centric target data model.

    Returns a dictionary containing:
        - silver_entities: Normalized entities with keys and attributes
        - relationships: Detected relationships between entities
        - bridge_tables: Suggested bridge tables for M:N relationships
        - entity_quality_rules: Data quality rules per entity
        - scd_recommendations: SCD type recommendations per entity
    """

    suggestions = {
        "silver_entities": [],
        "relationships": [],
        "bridge_tables": [],
        "entity_quality_rules": {},
        "scd_recommendations": {},
    }

    # 1. Normalize entities & identify keys
    for ent in entities:
        name = ent["name"]
        attrs = ent.get("attributes", [])

        # Identify business key(s)
        business_keys = [a["name"] for a in attrs if a.get("is_key")]

        # Suggest surrogate key
        surrogate_key = f"{name.lower()}_sk"

        normalized_attrs = []
        for a in attrs:
            normalized_attrs.append(
                {
                    "name": a["name"],
                    "type": a["type"],
                    "description": a.get("description", ""),
                    "is_business_key": a.get("is_key", False),
                    "is_nullable": not a.get("is_key", False),
                }
            )

        # Add lifecycle fields
        lifecycle_fields = [
            {"name": "effective_date", "type": "DATE", "description": "Record effective date"},
            {"name": "expiration_date", "type": "DATE", "description": "Record expiration date"},
            {"name": "is_current", "type": "BOOLEAN", "description": "Current record flag"},
            {"name": "created_timestamp", "type": "TIMESTAMP", "description": "Record creation time"},
            {"name": "updated_timestamp", "type": "TIMESTAMP", "description": "Last update time"},
            {"name": "source_system", "type": "STRING", "description": "Source system identifier"},
        ]

        suggestions["silver_entities"].append(
            {
                "entity_name": name,
                "surrogate_key": surrogate_key,
                "business_keys": business_keys,
                "attributes": normalized_attrs,
                "lifecycle_fields": lifecycle_fields,
            }
        )

        # 2. Recommend SCD patterns
        scd_type = (
            "Type 2"
            if any(
                a["name"].lower().endswith("_status")
                or a["name"].lower().endswith("_tier")
                or a["name"].lower().endswith("_category")
                or "address" in a["name"].lower()
                for a in attrs
            )
            else "Type 1"
        )

        suggestions["scd_recommendations"][name] = {
            "scd_type": scd_type,
            "rationale": (
                "Entity contains stateful/temporal attributes suitable for SCD Type 2."
                if scd_type == "Type 2"
                else "Entity is operational; updates overwrite previous values."
            ),
            "tracked_attributes": [
                a["name"]
                for a in attrs
                if any(
                    keyword in a["name"].lower()
                    for keyword in ["status", "tier", "category", "address", "phone", "email"]
                )
            ]
            if scd_type == "Type 2"
            else [],
        }

        # 3. Recommend DQ rules per entity
        dq_rules = []
        for a in attrs:
            if "email" in a["name"].lower():
                dq_rules.append(f"{a['name']} must be valid email format")
            if "phone" in a["name"].lower():
                dq_rules.append(f"{a['name']} must be valid phone format")
            if "amount" in a["name"].lower() or "price" in a["name"].lower():
                dq_rules.append(f"{a['name']} must be >= 0")
            if "date" in a["name"].lower():
                dq_rules.append(f"{a['name']} must be valid date")
            if a.get("is_key"):
                dq_rules.append(f"{a['name']} must be unique and not null")

        suggestions["entity_quality_rules"][name] = dq_rules

    # 4. Detect relationships based on shared business keys
    for i, ent1 in enumerate(entities):
        for ent2 in entities[i + 1 :]:
            keys1 = {a["name"] for a in ent1.get("attributes", []) if a.get("is_key")}
            keys2 = {a["name"] for a in ent2.get("attributes", []) if a.get("is_key")}

            intersection = keys1 & keys2
            if intersection:
                suggestions["relationships"].append(
                    {
                        "parent": ent1["name"],
                        "child": ent2["name"],
                        "relationship_type": "1:N",
                        "shared_keys": list(intersection),
                        "rationale": "Shared business keys suggest parent-child relationship",
                    }
                )

    # 5. Bridge Table Detection (M:N)
    for i, ent1 in enumerate(entities):
        for ent2 in entities[i + 1 :]:
            fk_in_ent1 = [a["name"] for a in ent1.get("attributes", []) if ent2["name"].lower() in a["name"].lower()]

            fk_in_ent2 = [a["name"] for a in ent2.get("attributes", []) if ent1["name"].lower() in a["name"].lower()]

            if fk_in_ent1 and fk_in_ent2:
                bridge_name = f"{ent1['name'].lower()}_{ent2['name'].lower()}_bridge"
                suggestions["bridge_tables"].append(
                    {
                        "bridge_name": bridge_name,
                        "entities": [ent1["name"], ent2["name"]],
                        "foreign_keys": [f"{ent1['name'].lower()}_sk", f"{ent2['name'].lower()}_sk"],
                        "rationale": "Mutual foreign-key attributes indicate M:N relationship",
                    }
                )

    return suggestions


def main():
    parser = argparse.ArgumentParser(description="Suggest Silver data model from entities")
    parser.add_argument("--input", required=True, help="Input JSON file with entities")
    parser.add_argument("--output", required=True, help="Output JSON file for suggestions")

    args = parser.parse_args()

    # Read input
    with open(args.input) as f:
        entities = json.load(f)

    # Generate suggestions
    suggestions = suggest_silver_data_model(entities)

    # Write output
    with open(args.output, "w") as f:
        json.dump(suggestions, f, indent=2)

    print(f"Silver data model suggestions written to {args.output}")


if __name__ == "__main__":
    main()
