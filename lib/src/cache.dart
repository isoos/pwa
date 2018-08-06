part of pwa_worker;

/// Common fetch request handler strategies that combine caching with network
/// requests.
abstract class FetchStrategy {
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

String _defaultCachePrefixValue;
String get _defaultCachePrefix {
  if (_defaultCachePrefixValue == null) {
    String name = location.pathname;
    if (name.endsWith('.js')) name = name.substring(0, name.length - 3);
    if (name.endsWith('.dart')) name = name.substring(0, name.length - 5);
    if (name.endsWith('.g')) name = name.substring(0, name.length - 2);
    if (name.startsWith('/')) name = name.substring(1);
    name = name.replaceAll('-', '--').replaceAll('/', '-');
    _defaultCachePrefixValue = name;
  }
  return _defaultCachePrefixValue;
}

/// An all-or-nothing cache that is ideal for offline-enabled PWAs.
///
/// The underlying cache name is derived as `pwa-block-[name]-[timestamp]`.
class BlockCache extends FetchStrategy {
  String _cachePrefix;

  Future _initializeFuture;
  bool _initialized = false;
  String _cacheName;
  Cache _cache;

  /// Initialize the [BlockCache].
  BlockCache(
    /// The name of the block.
    String name, {

    /// The cache prefix. Caches are global and may be shared between
    /// different applications (service workers) on the same domain. This
    /// value defaults to a path-specific prefix, that will be derived from
    /// the path of the SW and because of that unique to the scope of it.
    ///
    /// If not specified, the service worker's path name will be used to
    /// derive the prefix. In the default setup this will be `pwa`.
    String prefix,
  }) {
    prefix ??= _defaultCachePrefix;
    _cachePrefix = '$prefix-block-$name-';
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
    _cache ??= await caches.open(_cacheName);
    return _cache;
  }
}

/// A dynamic, best-effort cache with limits for the age or the number of
/// entries inside the cache.
///
/// The underlying cache name is derived as `pwa-dyn-[name]`.
class DynamicCache extends FetchStrategy {
  final Duration _maxAge;
  final int _maxEntries;

  /// The network fetch handler.
  RequestHandler _networkHandler;

  String _cacheName;

  /// Initialize a new [DynamicCache] instance. Provide reasonable constraint
  /// over the [maxAge] and [maxEntries], do not put millions of entries inside.
  DynamicCache(
    /// The name of the cache.
    String name, {

    /// The maximum age of the matched entries.
    Duration maxAge: const Duration(days: 7),

    /// The maximum number of entries.
    int maxEntries: 20,

    /// When set, it will force the network fetch to skip any caching.
    bool skipDiskCache: false,

    /// The cache prefix. Caches are global and may be shared between
    /// different applications (service workers) on the same domain. This
    /// value defaults to a path-specific prefix, that will be derived from
    /// the path of the SW and because of that unique to the scope of it.
    ///
    /// If not specified, the service worker's path name will be used to
    /// derive the prefix. In the default setup this will be `pwa`.
    String prefix,
  })  : _maxAge = maxAge,
        _maxEntries = maxEntries {
    prefix ??= _defaultCachePrefix;
    _cacheName = '$prefix-dyn-$name';
    _networkHandler =
        skipDiskCache ? noCacheNetworkRequestHandler : defaultRequestHandler;
  }

  @override
  Future<Response> cacheOnly(Request request) async {
    Cache cache = await _openCache();
    Response response = await cache.match(request.clone());
    if (response != null && _maxAge != null) {
      Duration age = _getAge(response?.headers);
      if (age != null && age > _maxAge) {
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
    if (_maxAge != null || _maxEntries != null) {
      List<Request> keys = await cache.keys();
      List<_RequestResponse> entries = [];
      for (Request rq in keys) {
        Response rs = await cache.match(rq);
        Duration age = _getAge(rs?.headers);
        if (age != null && age > _maxAge) {
          await cache.delete(rq);
        } else {
          entries.add(new _RequestResponse(rq, rs, age));
        }
      }
      // Remove the older entries first.
      if (entries.length > _maxEntries) {
        entries.sort((a, b) {
          if (a.age == null) return 1;
          if (b.age == null) return -1;
          return a.age.compareTo(b.age);
        });
        // ignore: invariant_booleans
        while (entries.length > _maxEntries) {
          await cache.delete(entries.removeLast().request);
        }
      }
    }
  }
}

class _RequestResponse {
  final Request request;
  final Response response;
  final Duration age;
  _RequestResponse(this.request, this.response, this.age);
}
