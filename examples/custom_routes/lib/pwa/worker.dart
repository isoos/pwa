import 'package:pwa/worker.dart';
import 'offline_urls.g.dart';

/// Creates the PWA worker.
Worker createWorker() {
  Worker worker = new Worker()..offlineUrls = offlineUrls;

  DynamicCache youtubeThumbnails =
      new DynamicCache('youtube', maxEntries: 10, skipDiskCache: true);

  worker.router.get('https://i.ytimg.com/vi/', youtubeThumbnails.cacheFirst);
  return worker;
}
