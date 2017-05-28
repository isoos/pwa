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

Articles about this packages:
- [Making a Dart web app offline-capable: 3 lines of code](https://medium.com/dartlang/making-a-dart-web-app-offline-capable-3-lines-of-code-e980010a7815)

## Tutorial and Examples

**Getting started**

- Getting started: [pwa_defaults](https://github.com/isoos/pwa/tree/master/examples/pwa_defaults)
  - Shows you how to use the `pwa` package and what it does.
  - Enables offline asset caching for you web app out-of-the-box. 

- Additional offline urls: [additional_offline_urls](https://github.com/isoos/pwa/tree/master/examples/additional_offline_urls)
  - Show you how to create the entry point for customization.
  - Gives you the ability to add additional URLs for the offline cache.

**Customize caching**

- Custom routes: [custom_routes](https://github.com/isoos/pwa/tree/master/examples/custom_routes)
  - Familiarize yourself with caching and routes.
  - Customize cache behavior for different parts of your app.

**Push notification**

- Push notification: [push_notification](https://github.com/isoos/pwa/tree/master/examples/push_notification)
  - Check and/or request Push permission.
  - Trigger and handle push event, show notification.

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
