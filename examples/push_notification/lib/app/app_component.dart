import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:angular2/angular2.dart';
import 'package:pwa/client.dart' as pwa;

/// Main component
@Component(
  selector: 'app-component',
  templateUrl: 'app_component.html',
)
class AppComponent {
  pwa.Client _pwaClient;
  pwa.PushPermission _permission;

  /// Injecting PWA client.
  AppComponent(@Inject('pwa.Client') this._pwaClient) {
    _initStatus();
  }

  bool get isPwaSupported => _pwaClient.isSupported;

  String get status => _permission == null
      ? '[waiting for initialization]'
      : _permission.status.toString();

  bool get showStatusDenied => _permission?.isDenied;
  bool get showStatusGranted => _permission?.isGranted;
  bool get showStatusSubscribed => _permission?.isSubscribed;
  bool get showStatusPrompt => _permission?.isPrompt;

  String get endpointUrl => _permission.endpointUrl;
  String get clientKeys => json.encode(_permission.clientKeys);

  bool get isFirefoxEndpoint =>
      endpointUrl.contains('//updates.push.services.mozilla.com/');

  bool get isChromeEndpoint =>
      endpointUrl.contains('//android.googleapis.com/');

  Future _initStatus() async {
    _permission = await _pwaClient.getPushPermission();
  }

  Future subscribe(MouseEvent event) async {
    event.preventDefault();
    _permission = await _pwaClient.getPushPermission(subscribeIfNeeded: true);
  }

  Future unsubscribe(MouseEvent event) async {
    event.preventDefault();
    await _permission.unsubscribe();
  }
}
