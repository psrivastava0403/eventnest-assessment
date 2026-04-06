# Code Review — EventNest Assessment

## Overview

I set up the project locally using Docker and ran the test suite to understand the current behavior. While going through the controllers and models, I focused on performance, security, architecture, and data integrity. The following issues were identified and prioritized based on impact.

---

## 1. N+1 Query in Events and Orders APIs

**Files:**

* app/controllers/api/v1/events_controller.rb
* app/controllers/api/v1/orders_controller.rb

**Category:** Performance
**Severity:** High

Both Events and Orders APIs were loading associated records inside loops without eager loading.
For example, accessing `event.user`, `event.ticket_tiers`, `order.event`, and `order.order_items` triggered additional queries per record. With larger datasets this would significantly slow down API responses.

**Fix**

Added eager loading:

Events:

```ruby
Event.published.upcoming.includes(:user, :ticket_tiers)
```

Orders:

```ruby
Order.recent.includes(:event, :order_items)
```

This reduced query count and improved response performance.

---

## 2. Missing Authorization on Orders Endpoints

**File:** app/controllers/api/v1/orders_controller.rb
**Category:** Security
**Severity:** Critical

Orders were fetched using `Order.find(params[:id])`, which allowed any authenticated user to access another user's order by ID.

**Fix**

Scoped queries to the current user:

```ruby
current_user.orders.find(params[:id])
```

This ensures users can only access their own orders.

---

## 3. Business Logic Inside Controllers

**Files:** OrdersController, EventsController
**Category:** Architecture
**Severity:** Medium

Controllers contained business logic for order creation, cancellation, confirmation, and refunds. This made controllers heavy and harder to test.

**Fix**

Extracted logic into service objects:

* OrderCreator
* OrderCanceller
* OrderConfirmer
* OrderRefunder

Controllers now only orchestrate request/response while services handle business logic.

---

## 4. Background Job Triggered Directly From Model

**File:** app/models/order.rb
**Category:** Architecture
**Severity:** Medium

The model directly triggered CRM sync job after state changes. This tightly coupled model logic with background processing and caused test failures when Redis was unavailable.

**Fix**

Extracted job into dedicated background worker:

```ruby
CrmSyncJob
```

Job execution moved to service layer, removing side effects from the model.

---

## 5. Unsafe Sorting Parameter

**File:** events_controller.rb
**Category:** Security
**Severity:** Medium

Sorting column was taken directly from params, allowing arbitrary SQL ordering.

**Fix**

Whitelisted allowed sort columns before applying order.

---

## 6. Bookmark Feature — Duplicate Protection Missing

**Category:** Data Integrity
**Severity:** High

Users were able to bookmark the same event multiple times.

**Fix**

Added database-level unique constraint:

```ruby
add_index :bookmarks, [:user_id, :event_id], unique: true
```

Also added model validation for duplicate prevention.

---

## 7. Bookmark Authorization

**File:** bookmarks_controller.rb
**Category:** Security
**Severity:** Medium

Any authenticated user could bookmark events. Requirement specified only attendees should bookmark.

**Fix**

Added role check:

```ruby
return head :forbidden unless current_user.attendee?
```

---

## Proof — SQL Injection in Events Search

Normal request:

```
curl "http://localhost:3000/api/v1/events?search=Music"
```

Response:
Only events containing the word "Music" are returned.

Injection request:

```
curl "http://localhost:3000/api/v1/events?search=%25' OR '1'='1"
```

Response:
All events are returned, ignoring the search filter.

Impact:
This allows a malicious user to bypass filtering and retrieve unintended data from the database.
In a real production system, similar patterns could expose sensitive records.

Fix:
Use parameterized query instead of string interpolation:

```ruby
events.where(
  "title ILIKE ? OR description ILIKE ?",
  "%#{params[:search]}%",
  "%#{params[:search]}%"
)
```


## Proof — Duplicate Bookmark

Request:

POST /api/v1/events/1/bookmark

Response:

422 Unprocessable Entity
{"error":"Already bookmarked"}

---

## Proof — Authorization

Organizer attempting bookmark:

Response:

403 Forbidden

---

## Summary

Main improvements made:

* Fixed N+1 queries in events and orders
* Added proper authorization for orders
* Extracted business logic into services
* Moved background job to dedicated worker
* Implemented bookmark feature
* Added uniqueness constraint
* Added role-based authorization
* Verified using curl and test suite

Final test result:

37 examples, 0 failures
