# PWA example: additional offline URLs

This tutorial assumes that you are familiar with the PWA basics from the following:
- [pwa_defaults](https://github.com/isoos/pwa/tree/master/examples/pwa_defaults)

## Prepare the project

- Create `lib/pwa/worker.dart` with this content:

````dart
import 'package:pwa/worker.dart';

/// Creates the PWA worker.
Worker createWorker() {
  return new Worker();
}
````

- Run `pub build` and `pub run pwa`, which will generate the `offline_urls.g.dart`,
  and also your `web/pwa.g.dart`. The later will now use your `worker.dart` to
  initialize the `Worker`.

- Update your `lib/pwa/worker.dart` with your additional urls:

````dart
import 'offline_urls.g.dart' show offlineUrls;

List<String> _additionalUrls = new List.from([
  'https://i.ytimg.com/vi/JXcNqXbCa0E/mqdefault.jpg',
  'https://i.ytimg.com/vi/oH6czEQwHdE/mqdefault.jpg',
  'https://i.ytimg.com/vi/b0b5FtnB3vE/mqdefault.jpg',
  'https://i.ytimg.com/vi/8ixOkJOXdMo/mqdefault.jpg',
  'https://i.ytimg.com/vi/JXcNqXbCa0E/mqdefault.jpg',
]);
````

And use in in the `Worker`:

````dart
Worker createWorker() {
  List<String> extendedUrls = new List.from(offlineUrls)
    ..addAll(_additionalUrls);
  return new Worker()..offlineUrls = extendedUrls;
}
````
