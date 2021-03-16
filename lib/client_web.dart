import 'dart:async';

import 'package:pwa/interface.dart';
import 'package:service_worker/window.dart' as sw;

class Client implements BaseClient {
  Future<sw.ServiceWorkerRegistration> _registration;

  /// Initializes a PWA client instance, also triggering the registration of
  /// the ServiceWorker on the given [scriptUrl].
  Client({String scriptUrl: './pwa.dart.js'}) {
    if (isSupported) {
      try {
        _unregisterOldGPwa();
      } catch (_) {}
      _registration = _triggerRegister(scriptUrl);
    }
  }

  @override
  bool get isSupported => sw.isSupported;

  @override
  Future<PushPermission> getPushPermission(
      {bool subscribeIfNeeded: false}) async {
    var reg = await _registration;
    PushPermissionStatus permStatus = PushPermissionStatus.denied;
    sw.PushSubscription subscription;

    var subscriptionOptions =
        new sw.PushSubscriptionOptions(userVisibleOnly: true);
    String status = await reg.pushManager.permissionState(subscriptionOptions);
    if (status == 'prompt' || status == 'default') {
      permStatus = PushPermissionStatus.prompt;
    } else if (status == 'denied') {
      permStatus = PushPermissionStatus.denied;
    } else if (status == 'granted') {
      subscription = await reg.pushManager.getSubscription();
      permStatus = subscription == null
          ? PushPermissionStatus.granted
          : PushPermissionStatus.subscribed;
    }

    if (subscribeIfNeeded &&
        subscription == null &&
        (permStatus == PushPermissionStatus.prompt ||
            permStatus == PushPermissionStatus.granted)) {
      try {
        await reg.pushManager.subscribe(subscriptionOptions);
      } catch (_) {}
      return getPushPermission(subscribeIfNeeded: false);
    }

    return new _PushPermission(permStatus, subscription);
  }

  Future<sw.ServiceWorkerRegistration> _triggerRegister(String url) async {
    var reg = await sw.register(url);
    // Workaround for a bug in Chrome: ServiceWorkerContainer.ready may not
    // complete in certain cases (for no apparent reason). Added a timeout of
    // two seconds and return the registered SW instance.
    // TODO: Investigate why ready does not complete.
    return await sw.ready
        .timeout(const Duration(seconds: 2), onTimeout: () => reg);
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

class _PushPermission extends PushPermission {
  PushPermissionStatus _status;
  sw.PushSubscription _subscription;

  _PushPermission(this._status, this._subscription);

  @override
  PushPermissionStatus get status => _status;

  @override
  String get endpointUrl =>
      _subscription == null ? null : _subscription.endpoint?.toString();

  @override
  Map<String, String> get clientKeys =>
      _subscription == null ? {} : _subscription.getKeysAsString();

  @override
  Future unsubscribe() async {
    if (_subscription == null) return;
    await _subscription.unsubscribe();
    _subscription = null;
    _status = PushPermissionStatus.granted;
  }
}
