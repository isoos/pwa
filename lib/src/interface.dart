/// PWA client that is running in the window scope.
abstract class BaseClient {
  /// Initializes a PWA client instance, also triggering the registration of
  /// the ServiceWorker on the given [scriptUrl].
  BaseClient({String scriptUrl: './pwa.dart.js'});

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

  /// The client keys that can be used to send encrypted data in push
  /// notifications.
  ///
  /// Returns an empty map if no keys are present.
  Map<String, String> get clientKeys;

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
