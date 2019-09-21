import 'dart:html';

import 'package:pwa/client.dart' as pwa;
void main() {
  pwa.Client();
  querySelector('#output').text = 'Your Dart app is running.';
}
