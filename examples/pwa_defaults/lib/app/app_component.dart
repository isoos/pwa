import 'dart:async';
import 'dart:html';

import 'package:angular/angular.dart';

import 'deferred_component.dart' deferred as dc;

/// Main component
@Component(
  selector: 'app-component',
  templateUrl: 'app_component.html',
)
class AppComponent {
  final DynamicComponentLoader _loader;
  final ViewContainerRef _location;
  bool _isLoaded = false;

  /// Injecting dynamic loader and the parent container.
  AppComponent(this._loader, this._location);

  /// Loads the deferred component if not already loaded.
  void loadDeferred(MouseEvent event) {
    event.preventDefault();
    _loadIfNeeded();
  }

  Future<Null> _loadIfNeeded() async {
    if (_isLoaded) return;
    await dc.loadLibrary();
    await _loader.loadNextToLocation(dc.DeferredComponent, _location);
    _isLoaded = true;
  }
}
