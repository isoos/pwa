import 'interface.dart';

BaseClient createPwaClient({String scriptUrl}) => NativeClient();

class NativeClient implements BaseClient {
  @override
  Future<PushPermission> getPushPermission({bool subscribeIfNeeded = false}) {}

  @override
  bool get isSupported => false;
}
