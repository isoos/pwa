library pwa;

import 'client_stub.dart' //
    if (dart.library.io) 'client_native.dart'
    if (dart.library.html) 'client_web.dart';
import 'interface.dart';
export 'interface.dart';

abstract class Client {
  /// Initializes a PWA client instance, also triggering the registration of
  /// the ServiceWorker on the given [scriptUrl].
  static BaseClient create({String scriptUrl: './pwa.dart.js'}) =>
      getClient(scriptUrl: scriptUrl);
}
