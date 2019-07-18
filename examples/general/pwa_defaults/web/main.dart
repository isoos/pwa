import 'package:angular/di.dart';

import 'package:pwa/client.dart' as pwa;
import 'package:pwa_example/app/app_component.dart';

void main() {
  bootstrap(AppComponent, [
    new Provider(pwa.Client, useValue: new pwa.Client()),
  ]);
}
