import 'dart:async';

import 'package:service_worker/window.dart' as sw;

/// PWA client that is running in the window scope.
abstract class Client {
  /// Initializes a PWA client instance, also triggering the registration of
  /// the ServiceWorker on the given [scriptUrl].
  factory Client({String scriptUrl: './pwa.dart.js'}) => new _Client(scriptUrl);

  /// Whether the PWA is supported on this client.
  bool get isSupported;
}

class _Client implements Client {
  // Future<sw.ServiceWorkerRegistration> _registration;

  _Client(String scriptUrl) {
    if (isSupported) {
      _unregisterOldGPwa();
      // _registration =
      _triggerRegister(scriptUrl);
    }
  }

  @override
  bool get isSupported => sw.isSupported;

  Future<sw.ServiceWorkerRegistration> _triggerRegister(String url) async {
    var reg = await sw.register(url);
    // Workaround for a bug in Chrome: ServiceWorkerContainer.ready may not
    // complete in certain cases (for no apparent reason). Added a timeout of
    // two seconds and return the registered SW instance.
    // TODO: Investigate why ready does not complete.
    return await sw.ready
        .timeout(new Duration(seconds: 2), onTimeout: () => reg);
  }

  Future _unregisterOldGPwa() async {
    List<sw.ServiceWorkerRegistration> registrations =
        await sw.getRegistrations();
    if (registrations == null) return;
    for (var reg in registrations) {
      sw.ServiceWorker worker = reg.active;
      if (worker != null && worker.scriptURL.endsWith('/pwa.dart.g.js')) {
        await reg.unregister();
      }
    }
  }
}
