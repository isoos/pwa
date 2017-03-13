import 'package:angular2/di.dart';
import 'package:angular2/platform/browser.dart';

import 'package:pwa/client.dart';
import 'package:pwa_example/app/app_component.dart';

void main() {
  bootstrap(AppComponent, [
    new Provider(PwaClient, useValue: new PwaClient()),
  ]);
}
