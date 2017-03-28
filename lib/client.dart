import 'dart:async';

import 'package:service_worker/window.dart' as sw;

/// PWA client that is running in the window scope.
abstract class Client {
  /// Initializes a PWA client instance, also triggering the registration of
  /// the ServiceWorker on the given [scriptUrl].
  factory Client({String scriptUrl: './pwa.dart.js'}) => new _Client(scriptUrl);

  /// Whether the PWA is supported on this client.
  bool get isSupported;

  /// Returns the current Push API permission, and the endpoint details.
  ///
  /// If there is no current subscription, and the permission was not denied by
  /// the user, using the [subscribeIfNeeded] flag will request a new
  /// subscription, prompting the user if needed.
  Future<PushPermission> getPushPermission({bool subscribeIfNeeded: false});
}

/// The granted permission of the Push notification API.
abstract class PushPermission {
  /// Gets the current push per status.
  PushPermissionStatus get status;

  /// Whether the permission is prompt.
  bool get isPrompt => status == PushPermissionStatus.prompt;

  /// Whether the permission is denied.
  bool get isDenied => status == PushPermissionStatus.denied;

  /// Whether the permission is granted but not subscribed.
  bool get isGranted => status == PushPermissionStatus.granted;

  /// Whether the permission is granted and subscribed.
  bool get isSubscribed => status == PushPermissionStatus.subscribed;

  /// Whether the permission is granted or subscribed.
  bool get isEnabled => isGranted || isSubscribed;

  /// The endpoint URL that the subscription can use.
  String get endpointUrl;

  /// Unsubscribes from the current push notification subscription.
  Future unsubscribe();
}

/// The push notification permission status on the current page.
enum PushPermissionStatus {
  /// The browser will prompt a dialog asking for approval.
  prompt,

  /// Notifications are granted but no subscription is active.
  granted,

  /// Notifications are granted and a subscription is active.
  subscribed,

  /// Notifications are denied.
  denied
}

class _Client implements Client {
  Future<sw.ServiceWorkerRegistration> _registration;

  _Client(String scriptUrl) {
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
  Future unsubscribe() async {
    if (_subscription == null) return;
    await _subscription.unsubscribe();
    _subscription = null;
    _status = PushPermissionStatus.granted;
  }
}
