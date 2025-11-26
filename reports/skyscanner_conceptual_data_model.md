# Skyscanner Conceptual Data Model
## Bronze Layer Analysis: prod_trusted_bronze.internal

**Schema**: prod_trusted_bronze.internal
**Total Tables**: 804
**Analysis Date**: 2025-11-25
**Data Format**: Delta Lake (External Tables)

---

## Executive Summary

The Skyscanner bronze layer represents a comprehensive **event-driven data architecture** supporting a multi-vertical travel marketplace. The 804 tables capture real-time user behavior, transactions, and operational metrics across **Flights** (primary), **Hotels**, **Car Hire**, **Packages**, and **Rail** verticals.

### Key Characteristics:
- **Event-Driven**: ~98% are event/fact tables (not traditional dimensions)
- **Multi-Platform**: iOS (100 tables), Android (91 tables), Web (50+ tables)
- **User-Centric**: UTID (Unique Traveller ID) present in 787/804 tables
- **Real-Time Processing**: Grappler SDK + Slipstream ingestion pipeline
- **Mobile-First**: 158 "mini" mobile event patterns + 191 iOS/Android tables

---

## Core Business Domains

### 1. FLIGHTS (Primary Vertical)
**~170 tables (21% of total)**

#### Major Sub-Domains:
- **Search & Discovery**: Search events, results, autosuggest, browse features
- **Pricing & Quotes**: FPS (Flight Pricing Service) sessions, quote management, cache status
- **Booking & Checkout**: 21 direct booking tables, checkout flow, validation, errors
- **Fare Configuration**: Fare families, configuration UI across platforms

#### Key Entity Concepts:
```
FLIGHT SEARCH SESSION
├─ Search Parameters (origin, destination, dates, passengers)
├─ Search Results (itineraries, options, pricing)
├─ User Actions (filters, sorts, selections)
└─ Search Outcome (redirect, abandon, view details)

FLIGHT PRICING SESSION
├─ FPS Session (pricing_session_id)
├─ Quote Generation (quotes, cache consistency)
├─ Live Updates (price changes, availability)
└─ Pricing Finalization

FLIGHT BOOKING
├─ Checkout Configuration (session, page views)
├─ Fare Family Selection (options, features)
├─ Optional Extras/Ancillaries
├─ Payment Processing
└─ Booking Confirmation/Error
```

---

### 2. HOTELS (Secondary Vertical)
**~50 tables (6% of total)**

#### Major Sub-Domains:
- **Search & Results**: Hotel search events, combined search, price events
- **Frontend Actions**: Comprehensive action tables (103 columns) across platforms
- **Booking & Quotes**: Direct booking events, quote providers, room pricing
- **Discovery**: Cross-sell widgets, carousels, open text search (AI features)

#### Key Entity Concepts:
```
HOTEL SEARCH
├─ Search Criteria (location, dates, guests, rooms)
├─ Hotel Results (impressions, prices, availability)
├─ Price Comparison (quote providers)
└─ Hotel Selection

HOTEL IMPRESSION
├─ Hotel Details View
├─ Room Options
├─ Price Events
└─ User Actions (save, share, compare)

HOTEL BOOKING
├─ Direct Booking Flow
├─ Partner Redirect
└─ Booking Confirmation
```

---

### 3. CAR HIRE
**~35 tables (4% of total)**

#### Major Sub-Domains:
- **Search & Quotes**: Quote search, indicative pricing, scheduled searches
- **Booking Lifecycle**: Confirmed, pending, failed, cancelled bookings
- **Discovery**: Homepage, map interactions, filters, offices

#### Key Entity Concepts:
```
CAR HIRE SEARCH
├─ Search Parameters (pickup/dropoff location & time)
├─ Vehicle Options (car groups, providers)
├─ Quotes & Pricing
└─ Filter Results

CAR HIRE BOOKING
├─ Quote Selection
├─ Booking Submission
├─ Booking Status (pending → confirmed/failed/cancelled)
└─ Confirmation Details
```

---

### 4. PACKAGES & COMBINED SEARCH
**~15 tables (2% of total)**

Multi-vertical searches combining flights + hotels, or other vertical combinations.

```
COMBINED SEARCH
├─ Multi-Vertical Query
├─ Unfocused Results (multiple verticals)
├─ Pill Selection (vertical switching)
└─ Combined Booking Flow
```

---

### 5. RAIL
**~4 tables (<1% of total)**

Emerging vertical with limited event coverage.

---

## Cross-Cutting Domains

### 6. USER & IDENTITY
**~20 tables (2.5% of total)**

#### Core Concepts:
```
TRAVELLER (UTID-based)
├─ Identity
│  ├─ UTID (Unique Traveller Identifier) - primary key across platform
│  ├─ Account Login Events
│  ├─ Anonymous Identity
│  └─ Authentication Provider
│
├─ Profile
│  ├─ Profile Completion Progress
│  ├─ Profile Settings (query/update)
│  └─ User Preferences (language, currency, notifications)
│
└─ Consent & Privacy
   ├─ Privacy Consent
   ├─ Marketing Opt-in Consent
   └─ Login Consent
```

**Key Identifier**: `utid` appears in 787/804 tables (98%)

---

### 7. SESSION & CONTEXT
**~100 tables explicitly track sessions**

```
SESSION
├─ Session ID (552 tables)
├─ Platform/Device Context
├─ Geographic Context (city, country, market, locale)
├─ Experiment Allocations
└─ Event Sequence (sequence_number in header)
```

**Key Identifiers**:
- `session_id` (552 tables)
- `guid` (event-level, 785 tables)
- `dt` (partition by date, all tables)

---

### 8. MARKETING & ACQUISITION
**~30 tables (4% of total)**

#### Core Concepts:
```
USER ACQUISITION
├─ Acquisition Event
│  ├─ UTM Parameters (source, medium, campaign)
│  ├─ Referral URL
│  ├─ Landing Page
│  └─ First Touch Attribution
│
├─ Marketing Consent
│  ├─ Email Capture
│  ├─ Price Alerts Opt-in
│  └─ Marketing Preferences
│
└─ Communication
   ├─ Email Events (sent, opened, clicked, bounced)
   ├─ Campaign Actions
   └─ Alert Events
```

---

### 9. ADVERTISING
**~30 tables (4% of total)**

#### Core Concepts:
```
ADVERTISEMENT
├─ Ad Delivery
│  ├─ Ad Response (placement, creatives)
│  ├─ Ad Impression
│  ├─ Ad View (viewability)
│  ├─ Ad Engagement (click, interact)
│  └─ Ad Refresh Updates
│
├─ Sponsored Content
│  ├─ Sponsored Search Results
│  ├─ Sponsored Articles
│  ├─ Sponsored Flights Widget
│  └─ Video Events
│
└─ Affiliate Tracking
   ├─ Affiliate Gateway Redirects
   ├─ Affiliate Link API Redirects
   └─ Partner Attribution
```

**Key Identifiers**: `response_id`, `impression_id`, `creative_id`, `campaign_id`

---

### 10. TRIPS & SAVED ITEMS
**~40 tables (5% of total)**

#### Core Concepts:
```
TRIP
├─ Trip Management
│  ├─ Trip View (list of saved itineraries)
│  ├─ Trip Actions (create, update, delete, share)
│  └─ Trip Deeplinks
│
├─ Saved Itinerary
│  ├─ Save Action
│  ├─ Save Status Change
│  └─ Save Notifications
│
└─ Price Alerts
   ├─ Saved Route Alert (generic route monitoring)
   ├─ Saved Itinerary Alert (specific itinerary monitoring)
   ├─ Alert Checked (price evaluation)
   ├─ Alert Published (notification sent)
   └─ Subscription Management
```

---

### 11. ANCILLARIES & ADD-ONS
**~10 tables (1% of total)**

```
ANCILLARY
├─ Ancillary Quote (baggage, seats, meals, insurance)
├─ Ancillary Purchase
├─ Insurance Component Interaction
└─ Optional Extras (upsells during checkout)
```

---

### 12. PAYMENT & BOOKING SERVICES
**~20 tables (2.5% of total)**

#### Core Concepts:
```
BOOKING SERVICES (BWS)
├─ Anonymous Booking Re-ownership
├─ Booking Details View
├─ Booking Updates
├─ Help Centre
├─ In-app Care
└─ Cancellation Flow

PAYMENT SERVICES
├─ Saved Payment Methods
│  ├─ Card Management (edit, save, delete)
│  ├─ Card Validation Errors
│  └─ Payment API Requests
│
└─ 3DS Authentication
   ├─ 3DS Two Requests
   ├─ 3DS Two Stored
   └─ Validation Errors
```

---

### 13. DEALS & INSPIRATION
**~20 tables (2.5% of total)**

```
DEAL
├─ Deal Identification
├─ Deal Message Badges
├─ Falcon Flight Deals
└─ Deal Component Events

INSPIRATION
├─ Inspiration Shelf (loaded, panel click, results)
├─ Inspire Map Page
├─ Explore Trips Widget
└─ Trips Search Response
```

---

### 14. AGORA (MARGIN OPTIMIZATION)
**~5 tables (<1% of total)**

```
MARGIN MANAGEMENT
├─ Margin Calculation (agora_margins - 19 columns)
├─ Margin Apply Results
├─ Redirects with Margin Data
└─ Day View Result
```

Internal pricing and margin optimization system.

---

### 15. EXPERIMENTS & PERSONALIZATION
**~10 tables (1% of total)**

```
EXPERIMENT
├─ Experiment Allocation (per user/session)
├─ User Context
├─ Custom Chokepoints
└─ Smart Metrics
```

A/B testing and feature flagging infrastructure.

---

## Platform Architecture

### Platform Segregation

```
PLATFORMS
├─ iOS (100 tables)
│  ├─ ios_* (native events)
│  └─ public_ios_* (public events)
│
├─ Android (91 tables)
│  ├─ android_* (native events)
│  └─ public_android_* (public events)
│
├─ Web/Frontend (50+ tables)
│  ├─ frontend_* (React web app)
│  ├─ banana_* (mobile web)
│  ├─ acorn_* (DayView - desktop)
│  └─ blackbird_* (modern web platform)
│
└─ Backend/Service (30+ tables)
   ├─ backend_mini_event_*
   ├─ prod_* (production services)
   └─ Service-specific tables
```

### "Mini" Event Pattern
**158 occurrences across platforms**

The "mini" pattern represents mobile-optimized event schemas:
- `*_mini_search`
- `*_mini_view`
- `*_mini_acquisition`
- `*_mini_user_preferences`
- etc.

These are lightweight, mobile-first event structures with streamlined payloads.

---

## Event Tracking Patterns

### Event Categories by Function

#### 1. View/Impression Events (57 occurrences)
**Pattern**: `*_view`, `*_page_loaded`, `*_element_impression`, `*_loaded`

Tracks when a user sees a page or component.

```
VIEW EVENT
├─ View GUID (unique impression ID)
├─ View Timestamp
├─ Page/Component Details
└─ Context (session, user, platform)
```

#### 2. Action/Interaction Events (40 occurrences)
**Pattern**: `*_action`, `*_interaction`, `*_click`, `*_tap`, `*_selected`

Tracks user engagement and interactions.

```
INTERACTION EVENT
├─ Interaction Type (click, tap, swipe, etc.)
├─ Element Impression GUID (links to view)
├─ Interaction Details
└─ Outcome (navigation, state change)
```

#### 3. Funnel Events (46 tables)
**Pattern**: `*_funnel_events_*`, `*_funnel_step*`

Tracks user journey through conversion funnels.

```
FUNNEL EVENT
├─ Funnel Name
├─ Step Name
├─ Step Order
├─ Previous Event ID
└─ Outcome (continue, abandon)
```

#### 4. Search Events (77 tables)
**Pattern**: `*_search*`

Comprehensive search tracking across all verticals.

```
SEARCH EVENT
├─ Search Parameters
├─ Search GUID
├─ Results Metadata
└─ Search Performance
```

#### 5. Booking Events (72 tables)
**Pattern**: `*_booking_*`

Booking lifecycle from initiation to completion/failure.

```
BOOKING EVENT
├─ Booking ID
├─ Booking Status
├─ Partner Information
├─ Price Details
└─ Timestamp
```

---

## Key Relationships

### Primary Linking Patterns

```
RELATIONSHIP MODEL

TRAVELLER (utid)
├─ has many → SESSIONS (session_id)
│  ├─ has many → EVENTS (guid)
│  └─ has many → SEARCHES (search_guid)
│     ├─ has many → SEARCH RESULTS
│     └─ may have → PRICING SESSIONS (fps_session_id)
│        └─ may have → BOOKINGS (booking_id)
│
├─ has many → SAVED ITEMS / TRIPS
│  ├─ SAVED ITINERARY (saved_itinerary_id)
│  └─ PRICE ALERTS (alert_id)
│
└─ has → PROFILE
   ├─ Preferences
   ├─ Consent
   └─ Authentication
```

### Common Foreign Keys

| Field | Occurrences | Purpose |
|-------|-------------|---------|
| `utid` | 787 tables | User identifier (primary key) |
| `guid` | 785 tables | Event identifier (unique per event) |
| `session_id` | 552 tables | Session identifier |
| `search_guid` | 113 tables | Search session identifier |
| `fps_session_id` | ~30 tables | Flight pricing session |
| `booking_id` | ~50 tables | Booking identifier |
| `impression_id` | ~30 tables | Ad/element impression |
| `partner_id` | ~40 tables | Partner/supplier identifier |

---

## Technical Metadata Patterns

### Grappler SDK Header
**Present in all tables**

```
header (STRUCT)
├─ guid (STRING) - event identifier
├─ event_timestamp (TIMESTAMP) - when event emitted
├─ service_name (STRING) - emitting service
├─ event_name (STRING) - event type
├─ sequence_number (INT) - event order
└─ service_instance_fingerprint (STRING) - service instance
```

### Slipstream Ingestion
**Present in all tables**

```
grappler_receive_timestamp (STRUCT)
├─ timestamp (TIMESTAMP) - when Slipstream received event
└─ timezone (STRING)
```

### Common Metadata Fields

```
COMMON FIELDS (present in 500+ tables)
├─ dt (STRING) - partition by date (YYYY-MM-DD)
├─ origin_topic (STRING) - source Kafka topic
├─ city_name (STRING) - user city
├─ country_name (STRING) - user country
└─ session_id (STRING) - session identifier
```

---

## Data Quality & Governance

### Partitioning Strategy
All tables partitioned by `dt` (date derived from `grappler_receive_timestamp`).

### Delta Lake Features
- **Column Mapping**: Many tables use `delta.columnMapping.mode: name`
- **External Tables**: All tables stored as external Delta tables
- **Data Format**: Delta Lake (parquet-based, ACID transactions)

### Comments & Documentation
Most tables have:
- Column-level comments explaining meaning
- Table-level comments describing purpose and granularity
- Note: "Created automatically by trusted-table-creator job"

---

## Conceptual Entity Relationship Diagram

### Core Entities

```
┌─────────────────────────────────────────────────────────────────┐
│                      TRAVELLER (utid)                           │
│  - Unique Traveller Identifier                                 │
│  - Profile                                                      │
│  - Preferences                                                  │
│  - Consent                                                      │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ has many
             │
┌────────────▼────────────────────────────────────────────────────┐
│                     SESSION (session_id)                        │
│  - Device/Platform Context                                      │
│  - Geographic Context                                           │
│  - Experiment Allocations                                       │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ has many
             │
     ┌───────┴────────┬────────────┬────────────┐
     │                │            │            │
     ▼                ▼            ▼            ▼
┌─────────┐    ┌──────────┐  ┌─────────┐  ┌──────────┐
│  VIEW   │    │ SEARCH   │  │ BOOKING │  │   AD     │
│ EVENTS  │    │ EVENTS   │  │ EVENTS  │  │ EVENTS   │
└─────────┘    └────┬─────┘  └─────────┘  └──────────┘
                    │
                    │ may trigger
                    │
          ┌─────────┴──────────┐
          │                    │
          ▼                    ▼
    ┌──────────┐         ┌──────────┐
    │ PRICING  │         │  RESULTS │
    │ SESSION  │         │          │
    └────┬─────┘         └──────────┘
         │
         │ may lead to
         │
         ▼
    ┌──────────┐
    │ BOOKING  │
    └──────────┘
```

### Vertical-Specific Relationships

```
FLIGHTS VERTICAL
├─ Flight Search → Flight Pricing Session → Flight Booking
├─ Flight Browse → Flight Results → Flight Redirect
└─ Fare Configuration → Optional Extras → Payment

HOTELS VERTICAL
├─ Hotel Search → Hotel Results → Hotel Impression
└─ Hotel Impression → Hotel Actions → Hotel Booking/Redirect

CAR HIRE VERTICAL
├─ Car Hire Search → Car Hire Quotes → Car Hire Filter
└─ Car Hire Quote → Car Hire Booking

SAVED/TRIPS
├─ Traveller → Saved Itinerary → Price Alert
└─ Traveller → Trip → Trip Items
```

---

## Business Process Flows

### 1. Flight Search-to-Book Journey

```
┌────────────┐
│   SEARCH   │ - User enters search criteria
└──────┬─────┘
       │
       ▼
┌────────────┐
│  RESULTS   │ - Search results displayed (itineraries)
└──────┬─────┘
       │
       ▼
┌────────────┐
│   SELECT   │ - User selects itinerary → triggers pricing
└──────┬─────┘
       │
       ▼
┌────────────┐
│   PRICE    │ - FPS generates live quotes
└──────┬─────┘
       │
       ▼
┌────────────┐
│   CONFIG   │ - User configures (fare families, seats, bags)
└──────┬─────┘
       │
       ▼
┌────────────┐
│  CHECKOUT  │ - Payment, passenger details
└──────┬─────┘
       │
       ▼
┌────────────┐
│  BOOKING   │ - Booking confirmed or failed
└────────────┘
```

### 2. Ad Monetization Flow

```
┌────────────┐
│ AD REQUEST │ - User views page
└──────┬─────┘
       │
       ▼
┌────────────┐
│AD RESPONSE │ - Ad server returns creative
└──────┬─────┘
       │
       ▼
┌────────────┐
│ IMPRESSION │ - Ad rendered on page
└──────┬─────┘
       │
       ▼
┌────────────┐
│    VIEW    │ - Ad in viewport (viewable)
└──────┬─────┘
       │
       ▼
┌────────────┐
│   ENGAGE   │ - User clicks ad
└──────┬─────┘
       │
       ▼
┌────────────┐
│  REDIRECT  │ - User redirected to partner
└────────────┘
```

### 3. Price Alerts Flow

```
┌────────────┐
│   SEARCH   │ - User performs search
└──────┬─────┘
       │
       ▼
┌────────────┐
│    SAVE    │ - User saves itinerary/route
└──────┬─────┘
       │
       ▼
┌────────────┐
│   ALERT    │ - Price alert created (subscription)
└──────┬─────┘
       │
       ▼
┌────────────┐
│   CHECK    │ - System checks price (scheduled)
└──────┬─────┘
       │
       ▼
┌────────────┐
│  PUBLISH   │ - If price change → notification sent
└──────┬─────┘
       │
       ▼
┌────────────┐
│   CLICK    │ - User clicks notification → return to search
└────────────┘
```

---

## Key Insights for Data Modeling

### 1. Bronze = Raw Events (Not Traditional Dimensions)
The bronze layer is **not** normalized or dimensional. It's a raw event stream optimized for:
- Real-time ingestion
- Append-only writes
- Event replay capability
- Schema evolution

### 2. User-Centric Design
- UTID is the **anchor entity** (787/804 tables)
- Session-based tracking (552/804 tables)
- All events tie back to a traveller journey

### 3. Multi-Vertical Complexity
Each vertical (Flights, Hotels, Car Hire) has:
- Independent search patterns
- Unique pricing mechanisms
- Vertical-specific user actions
- Shared infrastructure (sessions, users, ads)

### 4. Platform Divergence
iOS, Android, and Web have:
- Platform-specific event schemas
- Different feature sets
- Separate instrumentation
- Requires cross-platform stitching for unified views

### 5. Event-Time vs Processing-Time
- `header.event_timestamp`: when event occurred (client-side)
- `grappler_receive_timestamp`: when event ingested (server-side)
- `dt`: partition based on ingestion time

### 6. Sparse Schemas
Many tables have nullable structs for optional features:
- `flights_search_result_option.car_hire_option` (mostly null)
- `acorn_funnel_events_search.hotel_search` (deprecated)
- Platform-specific fields (iOS vs Android)

---

## Silver Layer Recommendations

To transform this bronze event stream into a usable **Silver layer**, consider:

### 1. Core Dimensional Entities
```
DIM_TRAVELLER (SCD Type 2)
├─ utid (business key)
├─ profile_attributes
├─ preferences
├─ consent_flags
└─ valid_from/valid_to

DIM_SESSION (SCD Type 1)
├─ session_id (business key)
├─ utid (FK)
├─ platform
├─ device_type
├─ geographic_context
└─ experiment_allocations

DIM_PARTNER (SCD Type 2)
├─ partner_id (business key)
├─ partner_name
├─ partner_type
├─ vertical
└─ valid_from/valid_to

DIM_DATE (Type 1)
DIM_TIME (Type 1)
DIM_LOCATION (SCD Type 1) - airports, cities, countries
```

### 2. Core Fact Tables
```
FACT_SEARCH
├─ search_guid (business key)
├─ utid (FK)
├─ session_id (FK)
├─ search_timestamp
├─ vertical
├─ search_parameters
└─ search_results_count

FACT_PRICING_SESSION
├─ fps_session_id (business key)
├─ search_guid (FK)
├─ pricing_started_at
├─ pricing_completed_at
├─ quotes_returned
└─ final_price

FACT_BOOKING
├─ booking_id (business key)
├─ utid (FK)
├─ session_id (FK)
├─ search_guid (FK)
├─ partner_id (FK)
├─ booking_timestamp
├─ booking_status
├─ price
└─ currency

FACT_AD_IMPRESSION
├─ impression_id (business key)
├─ session_id (FK)
├─ response_id (FK)
├─ impression_timestamp
├─ viewable
└─ engaged

FACT_AD_CLICK
├─ impression_id (FK)
├─ click_timestamp
└─ redirect_url
```

### 3. Bridge Tables for M:N Relationships
```
BRIDGE_SEARCH_RESULTS (search_guid, itinerary_id)
BRIDGE_TRIP_ITEMS (trip_id, saved_itinerary_id)
```

### 4. Aggregated Fact Tables
```
FACT_DAILY_USER_ACTIVITY (utid, dt, metrics...)
FACT_DAILY_SEARCH_VOLUME (vertical, market, dt, search_count)
FACT_DAILY_BOOKING_REVENUE (vertical, partner_id, dt, bookings, revenue)
```

---

## Conclusion

The Skyscanner bronze layer is a **mature, event-driven data platform** capturing comprehensive user behavior and operational metrics across a complex multi-vertical travel marketplace.

### Strengths:
- ✅ Comprehensive event coverage (804 tables)
- ✅ Strong user identity (UTID across 98% of tables)
- ✅ Multi-platform support (iOS, Android, Web)
- ✅ Real-time ingestion (Grappler + Slipstream)
- ✅ Rich attribution (UTM, experiments, campaigns)
- ✅ Vertical diversity (Flights, Hotels, Car Hire, Rail, Packages)

### Opportunities for Silver Layer:
- Denormalize and deduplicate events
- Create dimensional user/session/partner entities
- Standardize event schemas across platforms
- Build aggregated metrics for analytics/ML
- Implement SCD Type 2 for slowly changing dimensions
- Create unified views across verticals

### Next Steps:
1. Profile sample events from key tables (e.g., `acorn_funnel_events_search`, `direct_booking_frontend_checkout_booking_status`)
2. Define Silver entity models (Dimensional vs Entity-Centric)
3. Design incremental load patterns (CDC, watermark-based)
4. Build data quality rules and validation
5. Implement Gold-layer aggregations for specific use cases

---

**Document prepared by**: Agentic Data Engineer
**Source**: prod_trusted_bronze.internal (804 tables)
**Methodology**: Automated schema analysis via Databricks SDK
