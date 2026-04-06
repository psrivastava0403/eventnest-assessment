# Terminal Log — EventNest Assessment

## Project Setup

Cloned the repository and started the application using Docker.

docker compose up --build

Containers started successfully:

* web
* db

Application accessible on:

http://localhost:3000

---

## Database Setup

Prepared database:

docker compose exec web bin/rails db:prepare

Migrations ran successfully and seed data loaded.

---

## Initial Test Run (Before Fixes)

Ran full test suite:

docker compose exec web bundle exec rspec

Output:

30 examples, 10 failures

Major failures observed:

* Events API returning 403 Forbidden
* Orders API authorization failures
* Redis connection error in Order model
* Background job execution failing
* Search API failing tests

This confirmed multiple authorization and architecture issues.

---

## Fixes Applied

* Added proper authorization in Orders controller
* Fixed host authorization blocking requests
* Moved CRM sync logic to background job
* Extracted order logic into service objects
* Fixed N+1 queries using includes
* Added bookmark feature with uniqueness constraint
* Added attendee-only bookmark authorization
* Added request specs for bookmark feature

---

## Bookmark Feature Demo

### Create Bookmark - Response: 201 Created {"message":"Bookmarked"}

curl.exe -i -X POST "http://localhost:3000/api/v1/events/1/bookmark" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozLCJleHAiOjE3NzU1ODQ4MTd9.EgeuM_avWRaYnA6k2KQrGdG7m-Azar6lvWwg15Yne4c" -H "Content-Type: application/json"
HTTP/1.1 201 Created
x-frame-options: SAMEORIGIN
x-xss-protection: 0
x-content-type-options: nosniff
x-permitted-cross-domain-policies: none
referrer-policy: strict-origin-when-cross-origin
content-type: application/json; charset=utf-8
vary: Accept, Origin
etag: W/"74ea690ba5cea69e491e6f8f454c8bc7"
cache-control: max-age=0, private, must-revalidate
x-request-id: 7467058b-2415-4d40-8f86-dbf338df6508
x-runtime: 0.667112
server-timing: start_processing.action_controller;dur=0.04, sql.active_record;dur=61.87, instantiation.active_record;dur=53.70, transaction.active_record;dur=48.92, process_action.action_controller;dur=457.55
Content-Length: 24

{"message":"Bookmarked"}

---

### Duplicate Bookmark

curl.exe -i -X POST "http://localhost:3000/api/v1/events/1/bookmark" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozLCJleHAiOjE3NzU1ODQ4MTd9.EgeuM_avWRaYnA6k2KQrGdG7m-Azar6lvWwg15Yne4c"
HTTP/1.1 422 Unprocessable Content
content-type: application/json; charset=UTF-8
x-request-id: c2f610c4-f0ee-4251-8798-1fa0c673400a
x-runtime: 0.155623
server-timing: start_processing.action_controller;dur=0.01, sql.active_record;dur=3.83, instantiation.active_record;dur=0.28, transaction.active_record;dur=4.47, process_action.action_controller;dur=15.55
vary: Origin
Content-Length: 22885

{"status":422,"error":"Unprocessable Content"}

---

### List Bookmarks

curl.exe -i "http://localhost:3000/api/v1/bookmarks" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozLCJleHAiOjE3NzU1ODQ4MTd9.EgeuM_avWRaYnA6k2KQrGdG7m-Azar6lvWwg15Yne4c"
HTTP/1.1 200 OK
x-frame-options: SAMEORIGIN
x-xss-protection: 0
x-content-type-options: nosniff
x-permitted-cross-domain-policies: none
referrer-policy: strict-origin-when-cross-origin
content-type: application/json; charset=utf-8
vary: Accept, Origin
etag: W/"a4cd9243dd29a2e41f00d6da094b07e0"
cache-control: max-age=0, private, must-revalidate
x-request-id: 42f291a3-d32c-42fe-8480-fd3dd246261b
x-runtime: 0.199337
server-timing: start_processing.action_controller;dur=0.01, sql.active_record;dur=1.75, instantiation.active_record;dur=1.07, process_action.action_controller;dur=94.84 
Content-Length: 69

[{"id":1,"title":"Mumbai Indie Music Festival 2025","city":"Mumbai"}]

---

### Remove Bookmark - Response: 204 No Content

curl.exe -i -X DELETE "http://localhost:3000/api/v1/events/1/bookmark" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozLCJleHAiOjE3NzU1ODQ4MTd9.EgeuM_avWRaYnA6k2KQrGdG7m-Azar6lvWwg15Yne4c"
HTTP/1.1 204 No Content
x-frame-options: SAMEORIGIN
x-xss-protection: 0
x-content-type-options: nosniff
x-permitted-cross-domain-policies: none
referrer-policy: strict-origin-when-cross-origin
cache-control: no-cache
x-request-id: e9aa59cd-825c-47fe-afc5-c045944dff7b
x-runtime: 0.114530
server-timing: start_processing.action_controller;dur=0.01, sql.active_record;dur=10.17, instantiation.active_record;dur=0.34, transaction.active_record;dur=14.70, process_action.action_controller;dur=26.13
vary: Origin

---

### Verify Removal

 curl.exe -i "http://localhost:3000/api/v1/bookmarks" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozLCJleHAiOjE3NzU1ODQ4MTd9.EgeuM_avWRaYnA6k2KQrGdG7m-Azar6lvWwg15Yne4c"
HTTP/1.1 200 OK
x-frame-options: SAMEORIGIN
x-xss-protection: 0
x-content-type-options: nosniff
x-permitted-cross-domain-policies: none
referrer-policy: strict-origin-when-cross-origin
content-type: application/json; charset=utf-8
vary: Accept, Origin
etag: W/"4f53cda18c2baa0c0354bb5f9a3ecbe5"
cache-control: max-age=0, private, must-revalidate
x-request-id: f056f307-9cea-4cf3-b404-3e265a07cfdf
x-runtime: 0.168953
server-timing: start_processing.action_controller;dur=0.01, sql.active_record;dur=0.95, instantiation.active_record;dur=0.08, process_action.action_controller;dur=6.78
Content-Length: 2

response: []

---

## Final Test Run (After Fixes)

docker compose exec web bundle exec rspec

Output:

PS C:\Users\lslal\Downloads\eventnest-assessment-main\eventnest-assessment-main> docker-compose exec web bundle exec rspec
time="2026-04-06T23:13:39+05:30" level=warning msg="C:\\Users\\lslal\\Downloads\\eventnest-assessment-main\\eventnest-assessment-main\\docker-co`version` is obsolete, it will be ignored, please remove it to avoid potential confusion"
........................./usr/local/bundle/gems/actionpack-7.1.6/lib/action_dispatch/middleware/exception_wrapper.rb:174: warning: Status code :unprocessable_entity is deprecated and will be removed in a future version of Rack. Please use :unprocessable_content instead.
/usr/local/bundle/gems/actionpack-7.1.6/lib/action_dispatch/middleware/exception_wrapper.rb:174: warning: Status code :unprocessable_entity is deprecated and will be removed in a future version of Rack. Please use :unprocessable_content instead.
/usr/local/bundle/gems/actionpack-7.1.6/lib/action_dispatch/middleware/exception_wrapper.rb:174: warning: Status code :unprocessable_entity is deprecated and will be removed in a future version of Rack. Please use :unprocessable_content instead.
/usr/local/bundle/gems/actionpack-7.1.6/lib/action_dispatch/middleware/exception_wrapper.rb:174: warning: Status code :unprocessable_entity is deprecated and will be removed in a future version of Rack. Please use :unprocessable_content instead.
/usr/local/bundle/gems/rspec-rails-6.1.5/lib/rspec/rails/matchers/have_http_status.rb:219: warning: Status code :unprocessable_entity is deprecated and will be removed in a future version of Rack. Please use :unprocessable_content instead.
............

Finished in 23.01 seconds (files took 19.35 seconds to load)
37 examples, 0 failures

---

## Summary

* Initial failures: 10
* Final failures: 0
* Bookmark feature implemented
* Authorization fixed
* N+1 queries resolved
* Service objects added
* Background job separated
* Curl demo verified
* Full test suite passing
