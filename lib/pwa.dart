library pwa;

export 'src/client_stub.dart' //
    if (dart.library.io) 'src/client_native.dart'
    if (dart.library.html) 'src/client_web.dart';
export 'src/interface.dart';
