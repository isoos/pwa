## 0.0.2

- Fix default codegen.
- Call skipWaiting() by default (can be disabled through flag).
- The generated offline URLs and the SW registration is changed to relative URLS,
  we can put the application in any directory.
- DynamicCache evicts older entries first (previously it was random).
- DynamicCache doesn't evicts old entries on initialization, which enables
  offline-aware caches to outlive the set expiration until the next successful
  network event.
- Support for caching common web fonts. 

## 0.0.1

Experimental release, looking for feedback.
