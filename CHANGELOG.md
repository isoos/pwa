# Changelog

## 0.0.5

*API refactoring*:

- Remove `Pwa` class name prefix (not immediately breaking, added deprecated notes)
  - `PwaClient` -> `Client`
  - `PwaWorker` -> `Worker`
  - `PwaCacheMixin` -> `FetchStrategy`

- Renamed ambiguous items related to the Fetch API (not immediately breaking, added deprecated notes)
  - `Handler` -> `RequestHandler`
  - `Matcher` -> `RequestMatcher`
  - `Router` -> `FetchRouter`
  - `defaultFetchHandler` -> `defaultRequestHandler`
  - `noCacheNetworkFetch` -> `noCacheNetworkRequestHandler`

## 0.0.4

- Fix path separators on Windows.
- Updated examples:
  - Added `pwa_defaults`.
  - Moved `example` into `examples/custom_routes`.
- Execute `pub build` when the project has no `build/web` directory yet.

## 0.0.3

*Breaking changes*:

- (API) `BlockCache` and `DynamicCache` don't expose their initialization
  parameters. This is a minor change, it is unlikely to affect anybody.
  
- (behavior) `BlockCache` and `DynamicCache` use path-specific cache prefixes,
  in order to prevent collision between apps that are installed on the same domain.
  
  This fixes unintended cache collisions, but also breaks if you were building on
  sharing the caches between apps. In this case, use the new `prefix` optional
  argument when instantiating caches.
  
  If you have used only a single application in the root of the domain, you are not affected by this change.

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
