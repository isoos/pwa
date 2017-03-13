import 'package:pwa/worker.dart';
import 'offline_urls.g.dart';

/// Creates the PWA worker.
PwaWorker createWorker() {
  PwaWorker worker = new PwaWorker()
    ..offlineUrls = offlineUrls;

  DynamicCache youtubeThumbnails =
      new DynamicCache('youtube', maxEntries: 10, noNetworkCaching: true);

  worker.router.get('https://i.ytimg.com/vi/', youtubeThumbnails.cacheFirst);
  return worker;
}
