# Mermaid Diagram Syntax Reference

Quick reference for common Mermaid diagram types and syntax.

## Diagram Types

### Flowchart

**Use for:** Process flows, decision trees, workflows, algorithms

**Basic Syntax:**
```mermaid
flowchart TD
    A[Start] --> B{Decision}
    B -->|Yes| C[Process]
    B -->|No| D[Alternative]
    C --> E[End]
    D --> E
```

**Node Shapes:**
- `[Rectangle]` - Process/action
- `(Rounded)` - Start/end
- `{Diamond}` - Decision
- `([Stadium])` - Subprocess
- `[[Subroutine]]` - Subroutine
- `[(Database)]` - Database
- `((Circle))` - Connection point

**Directions:**
- `TD` or `TB` - Top to bottom
- `BT` - Bottom to top
- `LR` - Left to right
- `RL` - Right to left

**Example:**
```mermaid
flowchart LR
    A[User Request] --> B{Authenticated?}
    B -->|Yes| C[Process Request]
    B -->|No| D[Return 401]
    C --> E[(Database)]
    E --> F[Return Response]
```

### Sequence Diagram

**Use for:** API interactions, system communications, message flows

**Basic Syntax:**
```mermaid
sequenceDiagram
    participant A as Client
    participant B as Server
    participant C as Database
    
    A->>B: Request
    B->>C: Query
    C-->>B: Result
    B-->>A: Response
```

**Arrow Types:**
- `->` - Solid line
- `-->` - Dotted line
- `->>` - Solid arrow
- `-->>` - Dotted arrow
- `-x` - Cross at end
- `--x` - Dotted cross

**Special Features:**
```mermaid
sequenceDiagram
    participant A
    participant B
    
    A->>B: Synchronous call
    activate B
    B-->>A: Response
    deactivate B
    
    Note over A,B: This is a note
    
    alt Success
        B->>A: Success response
    else Failure
        B->>A: Error response
    end
    
    loop Every hour
        A->>B: Poll for updates
    end
```

### Class Diagram

**Use for:** Object models, data structures, entity relationships

**Basic Syntax:**
```mermaid
classDiagram
    class Customer {
        +String name
        +String email
        +placeOrder()
    }
    
    class Order {
        +String orderId
        +Date orderDate
        +calculateTotal()
    }
    
    Customer "1" --> "*" Order : places
```

**Relationships:**
- `<|--` - Inheritance
- `*--` - Composition
- `o--` - Aggregation
- `-->` - Association
- `--` - Link (solid)
- `..>` - Dependency
- `..|>` - Realization

**Visibility:**
- `+` - Public
- `-` - Private
- `#` - Protected
- `~` - Package/Internal

**Example:**
```mermaid
classDiagram
    class Animal {
        +String name
        +int age
        +makeSound()
    }
    
    class Dog {
        +String breed
        +bark()
    }
    
    class Cat {
        +String color
        +meow()
    }
    
    Animal <|-- Dog
    Animal <|-- Cat
```

### Entity Relationship Diagram (ERD)

**Use for:** Database schemas, data models

**Basic Syntax:**
```mermaid
erDiagram
    CUSTOMER ||--o{ ORDER : places
    ORDER ||--|{ ORDER_LINE : contains
    PRODUCT ||--o{ ORDER_LINE : "ordered in"
    
    CUSTOMER {
        int customer_id PK
        string name
        string email
    }
    
    ORDER {
        int order_id PK
        int customer_id FK
        date order_date
    }
```

**Cardinality:**
- `||--||` - One to one
- `||--o{` - One to many
- `}o--o{` - Many to many
- `||--|{` - One to one or more
- `}o--||` - Many to one

**Example:**
```mermaid
erDiagram
    USER ||--o{ SESSION : has
    USER {
        bigint user_id PK
        string username
        string email
        timestamp created_at
    }
    
    SESSION {
        bigint session_id PK
        bigint user_id FK
        timestamp start_time
        timestamp end_time
    }
    
    SESSION ||--o{ PAGE_VIEW : contains
    PAGE_VIEW {
        bigint page_view_id PK
        bigint session_id FK
        string url
        timestamp viewed_at
    }
```

### State Diagram

**Use for:** State machines, status transitions, lifecycle

**Basic Syntax:**
```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Processing : start
    Processing --> Complete : success
    Processing --> Failed : error
    Failed --> Idle : retry
    Complete --> [*]
```

**Features:**
```mermaid
stateDiagram-v2
    [*] --> New
    
    state "Order Processing" as process {
        [*] --> Validating
        Validating --> Approved
        Validating --> Rejected
        Approved --> [*]
        Rejected --> [*]
    }
    
    New --> process : submit
    process --> Shipping : approved
    process --> Cancelled : rejected
    Shipping --> Delivered
    Delivered --> [*]
```

### Gantt Chart

**Use for:** Project timelines, task scheduling

**Basic Syntax:**
```mermaid
gantt
    title Project Timeline
    dateFormat YYYY-MM-DD
    
    section Phase 1
    Task 1          :a1, 2024-01-01, 30d
    Task 2          :after a1, 20d
    
    section Phase 2
    Task 3          :2024-02-01, 15d
    Task 4          :2024-02-15, 10d
```

### Git Graph

**Use for:** Git branching strategies, version control flows

**Basic Syntax:**
```mermaid
gitGraph
    commit
    branch develop
    checkout develop
    commit
    branch feature
    checkout feature
    commit
    commit
    checkout develop
    merge feature
    checkout main
    merge develop
```

### Pie Chart

**Use for:** Distribution, percentages, composition

**Basic Syntax:**
```mermaid
pie title Website Traffic
    "Direct" : 40
    "Organic Search" : 30
    "Paid Ads" : 20
    "Social Media" : 10
```

### Journey Map

**Use for:** User journeys, customer experience flows

**Basic Syntax:**
```mermaid
journey
    title User Booking Journey
    section Browse
      Search flights: 5: User
      View results: 4: User
    section Select
      Choose flight: 5: User
      Review details: 4: User
    section Purchase
      Enter payment: 3: User
      Confirm booking: 5: User, System
```

## Best Practices

### 1. No Colors or Styling
Never use color specifications to ensure compatibility:
```mermaid
❌ BAD:
flowchart TD
    A[Start]
    style A fill:#f9f,stroke:#333

✅ GOOD:
flowchart TD
    A[Start]
```

### 2. Clear Node Labels
Use descriptive, concise labels:
```mermaid
✅ GOOD:
flowchart LR
    A[Validate Input] --> B[Process Request]
    B --> C[Return Response]

❌ BAD:
flowchart LR
    A[Step 1] --> B[Step 2]
    B --> C[Step 3]
```

### 3. Logical Flow Direction
Choose direction based on content:
- Top-down (`TD`): Hierarchies, process flows
- Left-right (`LR`): Timelines, sequences
- Use consistent direction within diagram

### 4. Group Related Elements
Use subgraphs for organization:
```mermaid
flowchart TD
    subgraph Frontend
        A[React App]
        B[API Client]
    end
    
    subgraph Backend
        C[API Server]
        D[Database]
    end
    
    B --> C
    C --> D
```

### 5. Keep It Simple
- One diagram per concept
- Limit nodes to 15-20 per diagram
- Break complex flows into multiple diagrams
- Use notes for additional context

### 6. Meaningful Relationships
Label edges when relationship isn't obvious:
```mermaid
flowchart LR
    A[User] -->|submits| B[Form]
    B -->|validates| C[Server]
    C -->|stores| D[Database]
```

## Common Patterns

### API Request Flow
```mermaid
sequenceDiagram
    participant Client
    participant API
    participant Auth
    participant DB
    
    Client->>API: POST /endpoint
    API->>Auth: Validate token
    Auth-->>API: Token valid
    API->>DB: Query data
    DB-->>API: Results
    API-->>Client: 200 OK
```

### Data Pipeline
```mermaid
flowchart LR
    A[(Source DB)] --> B[Extract]
    B --> C[Transform]
    C --> D[Validate]
    D --> E[Load]
    E --> F[(Target DB)]
```

### Dimensional Model
```mermaid
erDiagram
    DIM_CUSTOMER ||--o{ FACT_SALES : "customer_id"
    DIM_PRODUCT ||--o{ FACT_SALES : "product_id"
    DIM_DATE ||--o{ FACT_SALES : "date_key"
    
    FACT_SALES {
        bigint sales_key PK
        bigint customer_id FK
        bigint product_id FK
        bigint date_key FK
        decimal amount
    }
```

### Class Hierarchy
```mermaid
classDiagram
    class BaseModel {
        <<abstract>>
        +id: int
        +created_at: timestamp
        +save()
        +delete()
    }
    
    class User {
        +username: string
        +email: string
        +authenticate()
    }
    
    class Product {
        +name: string
        +price: decimal
        +calculateTax()
    }
    
    BaseModel <|-- User
    BaseModel <|-- Product
```

### State Machine
```mermaid
stateDiagram-v2
    [*] --> Draft
    Draft --> Review : submit
    Review --> Approved : approve
    Review --> Rejected : reject
    Rejected --> Draft : revise
    Approved --> Published : publish
    Published --> Archived : archive
    Archived --> [*]
```

## Troubleshooting

### Common Errors

**Invalid syntax:**
- Check for missing quotes around labels with spaces
- Verify all arrows are properly formed
- Ensure proper use of brackets/parentheses for node shapes

**Diagram not rendering:**
- Verify Mermaid code block has correct language identifier
- Check for balanced brackets
- Ensure no special characters breaking syntax

**Complex diagrams:**
- Split into multiple smaller diagrams
- Use subgraphs to organize
- Consider different diagram type

## Resources

- [Mermaid Live Editor](https://mermaid.live/) - Test and export diagrams
- [Mermaid Documentation](https://mermaid.js.org/) - Official docs
- [Mermaid CLI](https://github.com/mermaid-js/mermaid-cli) - Command-line tool
