part of pwa_worker;

/// Common request handler strategies for caches.
abstract class PwaCacheMixin {
  /// Handles the request only if it is able to serve from the cache.
  Future<Response> cacheOnly(Request request);

  /// Handles the request only if it is able to serve through the network.
  Future<Response> networkOnly(Request request) => fetch(request);

  /// Tries to handle the request from the cache first, than falls back to fetch
  /// it through the network.
  Future<Response> cacheFirst(Request request) =>
      joinHandlers([cacheOnly, networkOnly])(request);

  /// Tries to fetch from the network first, and if we are offline, it falls
  /// back to cache.
  Future<Response> networkFirst(Request request) =>
      joinHandlers([networkOnly, cacheOnly])(request);

  /// Issues both a network request and a cache lookup, and serves whichever
  /// completes first.
  Future<Response> fastest(Request request) =>
      raceHandlers([cacheOnly, networkOnly])(request);
}

/// An all-or-nothing cache that is ideal for offline-enabled PWAs.
///
/// The underlying cache name is derived as `pwa-block-[name]-[timestamp]`.
class BlockCache extends PwaCacheMixin {
  /// The name of the block.
  final String name;
  String _cachePrefix;

  Future _initializeFuture;
  bool _initialized = false;
  String _cacheName;
  Cache _cache;

  /// Initialize the [BlockCache].
  BlockCache(this.name) {
    _cachePrefix = 'pwa-block-$name-';
    _initializeFuture = _init();
  }

  @override
  Future<Response> cacheOnly(Request request) async {
    Cache cache = await _openCache();
    if (cache == null) return null;
    return cache.match(request);
  }

  /// Creates a new block cache instance and puts all of the urls inside it.
  Future precache(List<String> urls) async {
    if (!_initialized) {
      await _initializeFuture;
    }
    String cacheName =
        '$_cachePrefix${new DateTime.now().millisecondsSinceEpoch}';
    Cache cache = await caches.open(cacheName);
    await cache.addAll(urls);
    String oldCacheName = _cacheName;
    _cache = null;
    _cacheName = cacheName;
    if (oldCacheName != null) {
      await caches.delete(oldCacheName);
    }
  }

  Future _init() async {
    List<String> cacheNames = await caches.keys();
    List<String> obsolete = [];
    int lastTimestamp = 0;
    for (String cacheName in cacheNames) {
      if (cacheName.startsWith(_cachePrefix)) {
        String ts = cacheName.substring(_cachePrefix.length);
        try {
          int tsvalue = int.parse(ts);
          if (lastTimestamp < tsvalue) {
            lastTimestamp = tsvalue;
            if (_cacheName != null) {
              obsolete.add(_cacheName);
            }
            _cacheName = cacheName;
          } else {
            obsolete.add(cacheName);
          }
        } catch (e) {
          obsolete.add(cacheName);
        }
      }
    }
    for (String cacheName in obsolete) {
      await caches.delete(cacheName);
    }
    _initialized = true;
  }

  Future<Cache> _openCache() async {
    if (!_initialized) {
      await _initializeFuture;
    }
    if (_cacheName == null) return null;
    if (_cache == null) {
      _cache = await caches.open(_cacheName);
    }
    return _cache;
  }
}

/// A dynamic, best-effort cache with limits for the age or the number of
/// entries inside the cache.
///
/// The underlying cache name is derived as `pwa-dyn-[name]`.
class DynamicCache extends PwaCacheMixin {
  /// The name of the cache.
  final String name;

  /// The maximum age of the matched entries.
  final Duration maxAge;

  /// The maximum number of entries.
  final int maxEntries;

  /// The network fetch handler.
  Handler _networkHandler;

  String _cacheName;

  /// Initialize a new [DynamicCache] instance. Provide reasonable constraint
  /// over the [maxAge] and [maxEntries], do not put millions of entries inside.
  DynamicCache(
    this.name, {
    this.maxAge: const Duration(days: 7),
    this.maxEntries: 20,

    /// When set, it will force the network fetch to skip any caching.
    bool noNetworkCaching: false,
  }) {
    _cacheName = 'pwa-dyn-$name';
    _networkHandler =
        noNetworkCaching ? noCacheNetworkFetch : defaultFetchHandler;
    // do not block normal initialization path with async cleanup
    // ignore: unawaited_futures
    _removeOldAndExcessEntries();
  }

  @override
  Future<Response> cacheOnly(Request request) async {
    Cache cache = await _openCache();
    Response response = await cache.match(request.clone());
    if (response != null && maxAge != null) {
      Duration age = _getAge(response?.headers);
      if (age != null && age > maxAge) {
        // do not block normal handler path with async cleanup
        // ignore: unawaited_futures
        cache.delete(request.url);
        return null;
      }
    }
    return response;
  }

  @override
  Future<Response> networkOnly(Request request) {
    Future<Response> f = _networkHandler(request.clone());
    f = f.then((Response response) {
      if (isValidResponse(response)) {
        _add(request, response.clone());
      }
      return response;
    });
    return f;
  }

  Future<Cache> _openCache() => caches.open(_cacheName);

  Duration _getAge(Headers headers) {
    DateTime dt = _getDateHeaderValue(headers);
    if (dt == null) return null;
    Duration diff = new DateTime.now().difference(dt);
    return diff;
  }

  DateTime _getDateHeaderValue(Headers headers) {
    if (headers == null) return null;
    String dateHeader = headers['date'];
    if (dateHeader == null) return null;
    try {
      return DateTime.parse(dateHeader);
    } catch (e) {
      // ignore malformed date header
    }
    return null;
  }

  Future _add(Request request, Response response) async {
    Cache cache = await _openCache();

//    Response old = await cache.match(request);
//    if (old != null) {
//      String etag = response.headers['etag'];
//      if (etag != null && old.headers['etag'] == etag) {
//        // same entry, do not update
//        return false;
//      }
//    }

    await cache.put(request, response);
    await _removeOldAndExcessEntries();
  }

  Future _removeOldAndExcessEntries() async {
    Cache cache = await _openCache();
    if (maxAge != null || maxEntries != null) {
      List<Request> keys = await cache.keys();
      List<Request> remaining = [];
      for (Request rq in keys) {
        Response rs = await cache.match(rq);
        Duration age = _getAge(rs?.headers);
        if (age != null && age > maxAge) {
          await cache.delete(rq);
        } else {
          remaining.add(rq);
        }
      }
      if (maxEntries != null && maxEntries > 0) {
        while (remaining.length > maxEntries) {
          await cache.delete(remaining.removeLast());
        }
      }
    }
  }
}
