import 'package:angular/angular.dart';

/// Deferred component
@Component(
  selector: 'deferred-component',
  templateUrl: 'deferred_component.html',
  directives: [coreDirectives],
)
class DeferredComponent {
  ///
  List<String> images = new List.from(_dartSummitPreviews)..shuffle();
}

List<String> _dartSummitPreviews = [
  'https://i.ytimg.com/vi/JXcNqXbCa0E/mqdefault.jpg',
  'https://i.ytimg.com/vi/oH6czEQwHdE/mqdefault.jpg',
  'https://i.ytimg.com/vi/b0b5FtnB3vE/mqdefault.jpg',
  'https://i.ytimg.com/vi/8ixOkJOXdMo/mqdefault.jpg',
  'https://i.ytimg.com/vi/JXcNqXbCa0E/mqdefault.jpg',
  'https://i.ytimg.com/vi/naNr0F6mHjw/mqdefault.jpg',
  'https://i.ytimg.com/vi/oH6czEQwHdE/mqdefault.jpg',
  'https://i.ytimg.com/vi/DKG5CMyol9U/mqdefault.jpg',
  'https://i.ytimg.com/vi/aIonwL-8hdE/mqdefault.jpg',
  'https://i.ytimg.com/vi/BlAS1mlYRlA/mqdefault.jpg',
  'https://i.ytimg.com/vi/vAUUOwBJetg/mqdefault.jpg',
  'https://i.ytimg.com/vi/Mx-AllVZ1VY/mqdefault.jpg',
  'https://i.ytimg.com/vi/lqE4u8s8Iik/mqdefault.jpg',
  'https://i.ytimg.com/vi/iPlPk43RbpA/mqdefault.jpg',
  'https://i.ytimg.com/vi/IMNUiC2O9M8/mqdefault.jpg',
  'https://i.ytimg.com/vi/twr3cDFCeo4/mqdefault.jpg',
  'https://i.ytimg.com/vi/zZnGUknpFMM/mqdefault.jpg',
  'https://i.ytimg.com/vi/ekBD-_jRjds/mqdefault.jpg',
  'https://i.ytimg.com/vi/WScypD5E-AM/mqdefault.jpg',
  'https://i.ytimg.com/vi/JXcNqXbCa0E/mqdefault.jpg',
  'https://i.ytimg.com/vi/naNr0F6mHjw/mqdefault.jpg',
];
