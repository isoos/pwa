import 'package:pwa/worker.dart';
import 'package:pwa_example/pwa/worker.dart' as custom;

/// Starts the PWA in the worker scope.
void main() {
  PwaWorker worker = custom.createWorker();
  worker.run();
}
