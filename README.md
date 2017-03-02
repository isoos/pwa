# Progressive Web App (PWA) for Dart

Progressive web apps (PWA) are a hybrid of regular web pages
(or websites) and a mobile application. This new application
model attempts to combine features offered by most modern
browsers with the benefits of mobile experience.

Warning: the API is experimental, and subject to change.

## Background

PWA is using ServiceWorkers:

- [https://pub.dartlang.org/packages/service_worker](https://pub.dartlang.org/packages/service_worker)

Learn more about PWAs:

- [https://developers.google.com/web/progressive-web-apps/](https://developers.google.com/web/progressive-web-apps/)
- [https://pwa.rocks/](https://pwa.rocks/)

## Examples

Generate the list of offline URls and the PWA worker:

````
# first build populates build/web
pub build

# generates lib/pwa/offile_urls.g.dart
# generates web/pwa.g.dart
pub run pwa

# builds web/pwa.g.dart.js
pub build
````

In `lib/pwa/worker.dart`:

````dart
import 'package:pwa/worker.dart';
import 'offline_urls.g.dart';

/// Creates the PWA worker.
PwaWorker createWorker() {
  DynamicCache youtubeThumbnails =
      new DynamicCache('youtube', maxEntries: 10, noNetworkCaching: true);

  PwaWorker worker = new PwaWorker()
    ..offlineUrls = offlineUrls;

  worker.router.get('https://i.ytimg.com/vi/', youtubeThumbnails.cacheFirst);
  return worker;
}
````

If you re-run `pub run pwa` now, the generated `web/pwa.g.dart` will use
this file instead of the default settings.

## Planned features

- Typed Window <-> Worker communication, both `Streams`
  and request-reply patterns, something like:
  
  ````dart
  typedef Future<S> AsyncFunction<R, S>(R request);
  typedef S WireAdapter<R, S>(R input);
  
  abstract class MessageHub {
  
    AsyncFunction<R, S> getFunction<R, S>(String type,
        {WireAdapter<R, dynamic> encoder, WireAdapter<dynamic, S> decoder});
  
    void setHandler<R, S>(String type, AsyncFunction<R, S> handler,
        {WireAdapter<dynamic, R> decoder, WireAdapter<S, dynamic> encoder});
  
    Sink<T> getSink<T>(String type, {WireAdapter<T, dynamic> encoder});
  
    Stream<T> getStream<T>(String type, {WireAdapter<dynamic, T> decoder});
  }
  ````

- Push Notification
  
  - notification for the client app
  - one-method registration and/or status request
