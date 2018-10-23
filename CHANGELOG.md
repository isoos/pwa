## 0.1.12

- Updated dependency.

## 0.1.11

- Support Dart 2 stable.

## 0.1.10

- Support the latest version of `package:service_worker`.

## 0.1.9+1

- Support `args: ">=0.13.7 <2.0.0"`.

## 0.1.9

- Remove `package:func` dependency.

## 0.1.8

- Better `pub.exe` detection on Windows.
- Do not abort if project build fails.

## 0.1.7

- Generate `manifest.json`.

## 0.1.6

- Do not include `.scss` files in generated offline URLs.

## 0.1.5

- Console logging to uncover install/activation issues. That also causes a
  behavior change: errors during install won't interrupt the setup of the SW.
- Updated code generator:
  - **Breaking change:** `--lib-dir` will refer to the `lib` directory of the
    project, while its previous purpose will be handled by `--pwa-lib-dir`.
    Most users won't be affected (when using the defaults).
  - Invoke `pub build` not only on empty `build/` directory, but also when changes were detected.

## 0.1.4

- Expose `clientKeys` in `PushPermission`.

## 0.1.3

- Workaround for a bug in Chrome: ServiceWorkerContainer.ready may not complete
  in certain cases (for no apparent reason). Added a timeout of two seconds and
  return the registered SW instance.

- Added higher-level API helpers for checking Push permission and handling push events.

## 0.1.2

- Filter offline URLs:
  - `dart2js` debug outputs (`.dart.info.json`)
  - `package:test` and `package:package_resolver` assets

## 0.1.1

- Generating `lastModified` timestamp (in String) for offline URLs.
- Encouraging (but not yet enforcing) to use a version String in `Worker.run()`.
- The generated `pwa.dart` uses `offline.lastModified` as the version.

## 0.1.0

**Breaking changes:**

- Remove deprecated methods and classes (see changes in version 0.0.5).

- Changed the initialization of the Service Worker:
  - `pwa.g.dart` -> `pwa.dart` (source code generation is one-time only)
  - `Client` unregisters old version (ANY ServiceWorker ending with `/pwa.g.dart.js`)

- `Worker.onInstall` and `Worker.onActicate` became fields (instead of being methods).

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

- Renamed `DynamicCache`'s `noNetworkCaching` -> `skipDiskCache` (not immediately breaking, added deprecated notes).

- Updated methods in `FetchRouter` (not immediately breaking, added deprecated notes)
  - `add` -> `registerMatcher`
  - new method: `registerUrl` (will make `urlPrefixMatcher` internal)
  - `get` -> `registerGetUrl`
  - `post` -> `registerPostUrl`

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
