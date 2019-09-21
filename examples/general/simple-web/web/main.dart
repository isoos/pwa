import 'dart:html';

import 'package:pwa/client.dart' as pwa;
main() {
  // register PWA ServiceWorker for offline caching.
  pwa.Client();
  querySelector('#output').text = 'Your Dart app is running.';
}
