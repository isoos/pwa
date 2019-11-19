An absolute bare-bones web app.

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

Run this example first to make sure all your tooling is working.

If you already know what `webdev` and have Dart SDK, you may just be able to directly run the example. If you are confused, here is one possible route to making this example work.

## Detailed instructions (as of Nov2019), mostly for Android Studio on Mac OSX

0. Clone the github repo for the `pwa` package.
1. Install the Dart SDK (https://dart.dev/get-dart) (if you haven't already). This is different from the Flutter SDK.
2. OPTIONAL: Confirm you installed correctly. On mac OSX: Run `brew info dart` in terminal and confirm no errors. Note the path to the Dart SDK. On mac OSX, this was `/usr/local/opt/dart/libexec`; Or, note where your Dart SDK is installed if you used another method.
3. In Android Studio, open up the `simple-web` folder as a project. (Not just navigating to it from the main package).
4. In terminal, get your dependencies by running `pub get`. If you are in Android Studio: Open `pubspec.yaml`. Run `Get dependencies` which is on the top options. If needed, you might need to specify where the Dart SDK is. Use what you wrote down in step #2.
5. This only needs to be run once forever on your development system. If you haven't already: In terminal, run `pub global activate webdev`. If you want to know more, goto https://dart.dev/tools/webdev
6. In terminal, `cd` to the `simple-web` directory and then run `webdev build`.
7. Then run `webdev serve`.
8. Open the link to your localhost where the build directory is being served. In my case, it is described by a line that says`[INFO] Serving `web` on http://127.0.0.1:8080`
9. If everything worked, it should show a page that says "Your Dart app is running."
10. *Check that Service Workers are working*   You can also confirm this by opening "Developer Tools" in Chrome, going to the "Application" tab. You should have one service worker with source = `pwa.dart.js`

