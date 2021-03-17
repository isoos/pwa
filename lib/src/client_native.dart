import 'interface.dart';

BaseClient getClient({String scriptUrl}) => NativeClient();

class NativeClient implements BaseClient {
  @override
  Future<PushPermission> getPushPermission({bool subscribeIfNeeded = false}) {}

  @override
  bool get isSupported => false;
}
