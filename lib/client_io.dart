import 'package:pwa/interface.dart';

class Client implements BaseClient {
  @override
  Future<PushPermission> getPushPermission({bool subscribeIfNeeded = false}) {}

  @override
  bool get isSupported => false;
}
