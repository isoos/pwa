import 'interface.dart';

Client createPwaClient({String scriptUrl}) => NativeClient();

class NativeClient implements Client {
  @override
  Future<PushPermission> getPushPermission({bool subscribeIfNeeded = false}) {}

  @override
  bool get isSupported => false;
}
