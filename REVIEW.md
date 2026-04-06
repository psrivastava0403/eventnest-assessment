# Code Review

## issues 1: SQL Injection in Event Search 
-File: app/controllers/api/v1/events_controller.rb
-Category: Security
-Severity: Critical

Description:
User input is directly interpolated into the SQL query using string interpolation. This allows attackers to manipulate the query and bypass filters.

Proof: ## 1
Normal Request:
curl "http://localhost:3000/api/v1/events?search=Music"

Normal Request Response:
Returns only filtered events matching "Music".

Injection Request:
curl "http://localhost:3000/api/v1/events?search=%25' OR '1'='1"

Injection Resquest Response:
returns all events, ingnoring the search filter.

Impact: 
Attackers can bypass filtering and retrivieve all unintended data from the database.

Fix: 
Use parameterized queries:
events.where("title ILIKE ? OR description ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")

-----------------------------------------------------------------------------------------------------------

## Issue 2: 