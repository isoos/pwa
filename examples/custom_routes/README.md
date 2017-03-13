# PWA example: custom routes

This tutorial assumes that you are familiar with the PWA basics from the following:
- [pwa_defaults](https://github.com/isoos/pwa/tree/master/examples/pwa_defaults)
- [additional_offline_urls](https://github.com/isoos/pwa/tree/master/examples/additional_offline_urls)

## Caching basics

`pwa` provides a dynamic cache that will keep the number of items being cached
within certain bounds:

````dart
var cache = new DynamicCache(
    'my-cache',
    maxAge: new Duration(days: 7),
    maxEntries: 20,
);
````

Caches in `pwa` provide a few basic fetch strategies:

- `cacheOnly`: handles the request only if it is able to serve from the cache.
- `networkOnly`: handles the request only if it is able to serve through the network.
- `cacheFirst`: tries to handle the request from the cache first, than falls back to
  fetch it through the network.
- `networkFirst`: tries to fetch from the network first, and if we are offline, it
  falls back to cache.
- `fastest`: issues both a network request and a cache lookup, and serves whichever
  completes first.

These strategies are exposed as methods on the cache instance:

````dart
var cache = new DynamicCache('my-cache');
var fetchHandler = cache.networkFirst;
````

## How routing works

When the `pwa` ServiceWorker receives a fetch request, it can:
- try to serve it from a cache,
- try to fetch it from the network,
- a combination of the above.

`PwaWorker.router` enables a simple chain of rules that will determine
how each of the URLs will be served. It intercepts the fetch requests,
determines the first matching handler for it, and runs the request through
the handler.

In the following case, we can serve the Youtube image thumbnails from the
cache first, and if there is no match there, it will fetch them over the
network.

````dart
  PwaWorker worker = new PwaWorker()
    ..offlineUrls = offlineUrls;

  DynamicCache youtubeThumbnails = new DynamicCache('youtube', maxEntries: 10);

  worker.router.get('https://i.ytimg.com/vi/', youtubeThumbnails.cacheFirst);
````
