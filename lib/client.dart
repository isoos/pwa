import 'dart:async';

import 'package:service_worker/window.dart' as sw;

/// PWA client that is running in the window scope.
abstract class PwaClient {
  /// Initializes a PWA client instance, also triggering the registration of
  /// the ServiceWorker on the given [scriptUrl].
  factory PwaClient({String scriptUrl: '/pwa.g.dart.js'}) =>
      new _PwaClient(scriptUrl);

  /// Whether the PWA is supported on this client.
  bool get isSupported;
}

class _PwaClient implements PwaClient {
  // Future<sw.ServiceWorkerRegistration> _registration;

  _PwaClient(String scriptUrl) {
    if (isSupported) {
      // _registration =
      _register(scriptUrl);
    }
  }

  @override
  bool get isSupported => sw.isSupported;

  Future<sw.ServiceWorkerRegistration> _register(String url) async {
    await sw.register(url);
    return await sw.ready;
  }
}
