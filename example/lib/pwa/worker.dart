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
