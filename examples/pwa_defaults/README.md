# PWA tutorial: the default behavior

The `pwa` package uses two distinct scopes for enabling progressive features
to your web application:

- The `Client` in [client.dart](https://github.com/isoos/pwa/blob/master/lib/client.dart)
  is running alongside your (Angular) web application. It is used in `web/main.dart`,
  and will get compiled to `main.dart.js`.

- The `Worker` in [worker.dart](https://github.com/isoos/pwa/blob/master/lib/worker.dart)
  is running as a separate *Service Worker*. Package `pwa` will generate a `web/pwa.g.dart`
  file for you, which you should check-in into your source control, and it will get
  compiled to `pwa.g.dart.js`.

## Prepare the project

### PWA Client

Put the `pwa` package in your `pubspec.yaml`, and run `pub get` to update
the packages in the project.

Make sure that the `Client` is initialized in your Angular app's `web/main.dart`:

````dart
import 'package:pwa/client.dart' as pwa;

void main() {
  bootstrap(AppComponent, [
    new Provider(pwa.Client, useValue: new pwa.Client()),
  ]);
}
````

### PWA Worker

The `pwa` package can generate useful source code for you. In your console,
run the following commands:

```bash
# runs pwa code generation with default settings
# it will invoke `pub build` if it wasn't run before
pub run pwa

# seconds build
pub build
```

What is going on here?

- `pub run pwa` executes the `pwa` package's default code generator:

  - The offline assets are usually in the `web/build` directory, and they
    are the result of calling `pub build`. The script detects if it hasn't
    been run before, and invokes it. It will compile the `web/main.dart` to
    JavaScript, and it will populate the `build/web` directory with the
    compiled version and its static assets.

  - It scans the `build/web` directory for static assets, like:
    ````
    build/web/index.html
    build/web/main.dart.js
    build/web/main.dart.js_1.part.js
    ...
    [long list of files]
    ...
    build/web/styles.css
    ````
    
  - It creates (or updates) `lib/pwa/offline_urls.g.dart`, with a filtered list
    of the files above:
    
    ````dart
    /// URLs for offline cache.
    final List<String> offlineUrls = [
      './',
      './main.dart.js',
      './main.dart.js_1.part.js',
      './packages/browser/dart.js',
      './packages/browser/interop.js',
      // [list goes on...]
    ];
    ````
  
  - It creates (or updates) `web/pwa.g.dart`, which is the entry point of the
    `Worker` mentioned above.
    
    - The default behavior pulls in the `offlineUrls` from the generated file
      above, and sets them for using them as an offline cache.

- The *second* `pub build` will compile not only the `web/main.dart`, but also
  the newly create `web/pwa.g.dart` to JavaScript.

## Observe the offline behavior

- Deploy the application to your server of choice, or use any of the following
  alternatives:
  - `python -m SimpleHTTPServer`
  - `pub serve` (after `pub run pwa` has run)

- Load the web app in Chrome (e.g. http://localhost:8080/ if running `pub serve`).

- Open Chrome Developer Tools and go to the Applications tab, and select
  Service Workers on the left. Make sure that `pwa.g.dart.js` is properly
  loaded.

- In Chrome Developer Tools, and go to the Networks tab.

- Set the checkbox `Offline`.

- Reload the page. It should be able to load without network connection.
