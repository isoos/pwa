import 'package:pwa/worker.dart';
import 'offline_urls.g.dart' show offlineUrls;

List<String> _additionalUrls = new List.from([
  'https://i.ytimg.com/vi/JXcNqXbCa0E/mqdefault.jpg',
  'https://i.ytimg.com/vi/oH6czEQwHdE/mqdefault.jpg',
  'https://i.ytimg.com/vi/b0b5FtnB3vE/mqdefault.jpg',
  'https://i.ytimg.com/vi/8ixOkJOXdMo/mqdefault.jpg',
  'https://i.ytimg.com/vi/JXcNqXbCa0E/mqdefault.jpg',
]);

/// Creates the PWA worker.
PwaWorker createWorker() {
  List<String> extendedUrls = new List.from(offlineUrls)
    ..addAll(_additionalUrls);
  return new PwaWorker()..offlineUrls = extendedUrls;
}
