import 'dart:convert';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:pwa/client.dart' as pwa;

// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [coreDirectives],
  providers: [ClassProvider(pwa.Client)],
)

@Injectable()
class AppComponent implements OnInit {
  // Nothing here yet. All logic is in TodoListComponent.
  pwa.Client _pwaClient;
  pwa.PushPermission _permission;

  /// Injecting PWA client.
  AppComponent(this._pwaClient) {
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
  String get clientKeys => jsonEncode(_permission.clientKeys);

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

  @override
  void ngOnInit() {
    // TODO: implement ngOnInit
  }
}