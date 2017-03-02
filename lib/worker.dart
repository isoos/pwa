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

  /// Offline URLs (if any).
  List<String> offlineUrls;

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
      // TODO: re-enable offline first?
//      if (config.isOfflineFirst) {
//        handler = joinHandlers([offline.cacheOnly, handler]);
//      } else {
      handler = joinHandlers([handler, offline.cacheFirst]);
//      }
    }
    event.respondWith(handler(event.request));
  });
}
