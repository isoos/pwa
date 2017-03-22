import 'package:pwa/worker.dart';
import 'package:pwa_example/pwa/offline_urls.g.dart' as offline;

/// The Progressive Web Application's entry point.
void main() {
  // The Worker handles the low-level code for initialization, fetch API
  // routing and (later) messaging.
  Worker worker = new Worker();

  // The static assets that need to be in the cache for offline mode.
  // By default it uses the automatically generated list from the output of
  // `pub build`. To refresh this list, run `pub run pwa` after each new build.
  worker.offlineUrls = offline.offlineUrls;

  // The above list can be extended with additional URLs:
  //
  // List<String> offlineUrls = new List.from(offline.offlineUrls);
  // offlineUrls.addAll(['https://www.example.org/custom/resource/']);
  // worker.offlineUrls = offlineUrls;

  // Fine-tune the caching and network fetch with dynamic caches and cache
  // strategies on the url-prefixed network routes:
  //
  // DynamicCache cache = new DynamicCache('images');
  // worker.router.registerGetUrl('https://cdn.example.com/', cache.networkFirst);

  DynamicCache youtubeThumbnails =
      new DynamicCache('youtube', maxEntries: 10, skipDiskCache: true);

  worker.router
      .registerGetUrl('https://i.ytimg.com/vi/', youtubeThumbnails.cacheFirst);

  // Start the worker.
  worker.run(version: offline.lastModified);
}
