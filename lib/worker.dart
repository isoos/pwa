library pwa_worker;

import 'dart:async';

import 'package:func/func.dart';
import 'package:service_worker/worker.dart';

part 'src/cache.dart';
part 'src/handler.dart';
part 'src/router.dart';

/// PWA Worker object.
///
/// To start the worker, call method: `run()`.
class PwaWorker {
  /// The router for the fetch events.
  final Router router = new Router();

  /// These URLs will be pre-cached and kept up-to-date
  /// for each deployed version of the application.
  List<String> offlineUrls;

  /// Whether to cache web fonts loaded from common third-party websites.
  /// These resources will be cached after the first time they are accessed on
  /// the network, and will be available for offline use.
  ///
  /// The default is using a network-first approach, always updating the cache
  /// with new versions if they become available. The eviction policy is
  /// generous: entries are evicted after a year or after 256 items.
  bool cacheCommonWebFonts = true;

  /// Whether the new SW version should be installed immediately, instead of
  /// waiting for the older versions to be stopped and unregistered.
  bool skipWaiting = true;

  /// Method that will get called on installing the PWA.
  Future onInstall() => null;

  /// Method that will get called on activating the PWA.
  Future onActivate() => null;

  /// Start the PWA (in the ServiceWorker scope).
  void run() => _run(this);
}

bool _isRunning = false;

void _run(PwaWorker worker) {
  if (_isRunning) {
    throw new Exception('PWA must be initalized only once.');
  }
  _isRunning = true;

  BlockCache offline =
      worker.offlineUrls == null ? null : new BlockCache('offline');

  DynamicCache commonWebFonts;
  if (worker.cacheCommonWebFonts) {
    commonWebFonts = new DynamicCache('common-webfonts',
        maxAge: new Duration(days: 365), maxEntries: 256);
    for (String prefix in _commonWebFontPrefixes) {
      worker.router.get(prefix, commonWebFonts.networkFirst);
    }
  }

  Func0<Future> installCallback = () async {
    if (offline != null) {
      await offline.precache(worker.offlineUrls);
    }
    Future f = worker.onInstall();
    if (f != null) await f;
  };
  onInstall.listen((InstallEvent event) {
    event.waitUntil(installCallback());
  });

  Func0<Future> activateCallback = () async {
    Future f = worker.onActivate();
    if (f != null) await f;
  };
  onActivate.listen((ExtendableEvent event) {
    event.waitUntil(activateCallback());
  });

  onFetch.listen((FetchEvent event) {
    Handler handler = worker.router.match(event.request);
    handler ??= defaultFetchHandler;
    if (offline != null) {
      handler = joinHandlers([handler, offline.cacheFirst]);
    }
    event.respondWith(handler(event.request));
  });

  if (worker.skipWaiting) {
    skipWaiting();
  }
}

final List<String> _commonWebFontPrefixes = [
  // Google Web Fonts
  'https://fonts.google.com/',
  'https://fonts.googleapis.com/',
  'https://fonts.gstatic.com/',
];
