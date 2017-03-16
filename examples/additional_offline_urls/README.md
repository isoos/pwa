# PWA example: additional offline URLs

This tutorial assumes that you are familiar with the PWA basics from the following:
- [pwa_defaults](https://github.com/isoos/pwa/tree/master/examples/pwa_defaults)

## Update the project

The generated list of offline URLs can be easily extended with additional
static URLs. Instead of setting `offline.offlineUrls`, you shall create a
new list like the following in `pwa.dart`:

````dart
  List<String> additionalUrls = new List.from([
    'https://i.ytimg.com/vi/JXcNqXbCa0E/mqdefault.jpg',
    'https://i.ytimg.com/vi/oH6czEQwHdE/mqdefault.jpg',
    'https://i.ytimg.com/vi/b0b5FtnB3vE/mqdefault.jpg',
    'https://i.ytimg.com/vi/8ixOkJOXdMo/mqdefault.jpg',
    'https://i.ytimg.com/vi/JXcNqXbCa0E/mqdefault.jpg',
  ]);

  worker.offlineUrls = new List.from(offline.offlineUrls)
    ..addAll(additionalUrls);
````
