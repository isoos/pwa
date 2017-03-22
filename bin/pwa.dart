import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:yaml/yaml.dart' as yaml;

Future main(List<String> args) async {
  ArgResults argv = (new ArgParser()
        ..addOption('offline', allowMultiple: true, defaultsTo: 'build/web')
        ..addOption('index-html', defaultsTo: 'index.html')
        ..addOption('exclude', allowMultiple: true)
        ..addOption('exclude-defaults', defaultsTo: 'true')
        ..addOption('lib-dir', defaultsTo: 'lib/pwa')
        ..addOption('lib-include')
        ..addOption('web-dir', defaultsTo: 'web'))
      .parse(args);

  List<String> offlineDirs = argv['offline'];
  await buildProjectIfEmpty(offlineDirs);
  var urlScanner = new _OfflineUrlScanner.fromArgv(argv);
  await urlScanner.scan();
  String offlineUrlsFile = '${argv['lib-dir']}/offline_urls.g.dart';
  await urlScanner.writeToFile(offlineUrlsFile);

  String libInclude = await detectLibInclude(argv);
  if (libInclude == null) {
    print('Unable to detect library include prefix. '
        'Run script from the root of the project or specify lib-include.');
    exit(-1);
  }
  await generateWorkerScript(argv, libInclude);
}

/// If build/web is empty, run `pub build`.
Future buildProjectIfEmpty(List<String> offlineDirs) async {
  // This works only with the default value.
  if (offlineDirs.length == 1 && offlineDirs.first == 'build/web') {
    Directory dir = new Directory('build/web');
    if (dir.existsSync() && dir.listSync().isNotEmpty) return;
    print('Running pub build the first time:');
    String executable = Platform.isWindows ? 'pub.exe' : 'pub';
    print('$executable build');
    print('-----');
    Process process = await Process.start(executable, ['build']);
    Future f1 = stdout.addStream(process.stdout);
    Future f2 = stderr.addStream(process.stderr);
    await Future.wait([f1, f2]);
    int exitCode = await process.exitCode;
    print('-----');
    String status = exitCode == 0 ? 'OK' : 'Some error happened.';
    print('Pub build exited with code $exitCode ($status).');
  }
}

/// Scans all of the directories and returns the URLs derived from the files.
class _OfflineUrlScanner {
  List<String> _offlineDirs;
  String _indexHtml;
  List<String> _excludes;
  bool _excludeDefaults;

  List<String> offlineUrls;
  DateTime lastModified;

  _OfflineUrlScanner.fromArgv(ArgResults argv) {
    _offlineDirs = argv['offline'];
    _indexHtml = argv['index-html'];
    _excludes = argv['exclude'];
    _excludeDefaults = argv['exclude-defaults'] == 'true';
  }

  Future scan() async {
    List<Glob> excludeGlobs = [];
    if (_excludeDefaults) {
      excludeGlobs.addAll([
        // Dart Analyzer
        '**/format.fbs',
        // Angular
        '**.ng_meta.json',
        '**.ng_summary.json',
        '**/README.txt',
        '**/README.md',
        '**/LICENSE',
        // PWA
        'pwa.dart.js',
        'pwa.g.dart.js',
      ].map((s) => new Glob(s)));
    }
    excludeGlobs.addAll(_excludes.map((s) => new Glob(s)));

    Set<String> urls = new Set();
    for (String dirName in _offlineDirs) {
      Directory dir = new Directory(dirName);
      var list = await dir.list(recursive: true).toList();
      for (FileSystemEntity fse in list) {
        if (fse is File) {
          DateTime m = fse.statSync().modified;
          if (lastModified == null || lastModified.isBefore(m)) {
            lastModified = m;
          }
          String name = fse.path.substring(dir.path.length);
          if (Platform.isWindows) {
            // replace windows file separators to URI separator as per rfc3986
            name = name.replaceAll(Platform.pathSeparator, '/');
          }
          if (excludeGlobs.any((glob) => glob.matches(name.substring(1))))
            continue;
          if (name.endsWith('/$_indexHtml')) {
            name = name.substring(0, name.length - _indexHtml.length);
          }
          // making URLs relative
          name = '.$name';
          urls.add(name);
        }
      }
    }
    offlineUrls = urls.toList()..sort();
    // fallback if no file was detected
    lastModified ??= new DateTime.now();
  }

  /// Updates the offline_urls.g.dart file.
  Future writeToFile(String fileName) async {
    String listItems = offlineUrls.map((s) => '\'$s\',').join();
    String lastModifiedText = lastModified.toUtc().toIso8601String();
    String src = '''
    /// URLs for offline cache.
    final List<String> offlineUrls = [$listItems];

    /// Last modified timestamp of the files
    final String lastModified = '$lastModifiedText';
  ''';
    src = new DartFormatter().format(src);
    await _updateIfNeeded(fileName, src);
  }
}

/// Detects the package name if lib-include is not set.
Future<String> detectLibInclude(ArgResults argv) async {
  String libInclude = argv['lib-include'];
  if (libInclude != null) return libInclude;
  File pubspec = new File('pubspec.yaml');
  if (pubspec.existsSync()) {
    var data = yaml.loadYaml(await pubspec.readAsString());
    if (data is Map) {
      return data['name'];
    }
  }
  return null;
}

/// Generates the PWA's worker script.
Future generateWorkerScript(ArgResults argv, String libInclude) async {
  String libDir = argv['lib-dir'];
  bool hasLibWorker = new File('$libDir/worker.dart').existsSync();

  File oldPwaGDart = new File('${argv['web-dir']}/pwa.g.dart');
  File pwaDart = new File('${argv['web-dir']}/pwa.dart');

  String oldLibWorkerMessage = '';
  String oldPwaGDartMessage = '';
  if (hasLibWorker) {
    print('WARN: migrate custom initiation from $libDir/worker.dart');
    oldLibWorkerMessage =
        '// TODO: migrate your custom initialization from $libDir/worker.dart\n'
        '    // This is probably a leftover (custom library from pre-0.1 versions).';
  }
  if (oldPwaGDart.existsSync()) {
    print('WARN: remove ${oldPwaGDart.path}');
    oldPwaGDartMessage = '// TODO: remove ${oldPwaGDart.path}\n'
        '    // This is probably a leftover (generated source from pre-0.1 versions).';
  }

  String src = '''
  import 'package:pwa/worker.dart';
  import 'package:$libInclude/pwa/offline_urls.g.dart' as offline;

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

    $oldLibWorkerMessage

    $oldPwaGDartMessage

    // Start the worker.
    worker.run(version: offline.lastModified);
  }
  ''';
  src = new DartFormatter().format(src);

  if (pwaDart.existsSync()) {
    print('INFO: ${pwaDart.path} exists, no change has been made.');
    List<String> oldLines = await pwaDart.readAsLines();
    if (!oldLines.contains('void main() {')) {
      print(
          'WARN: Entry point in ${pwaDart.path} changed its signature, potential error. '
          'Do not use async before calling run().');
    }
  } else {
    print('INFO: Creating file: ${pwaDart.path}');
    pwaDart.parent.createSync(recursive: true);
    await pwaDart.writeAsString(src);
  }
}

Future _updateIfNeeded(String fileName, String content) async {
  File file = new File(fileName);
  if (file.existsSync()) {
    String oldContent = await file.readAsString();
    if (oldContent == content) {
      // No need to override the file
      return;
    }
  } else {
    await file.parent.create(recursive: true);
  }
  print('INFO: Updating file: $fileName');
  await file.writeAsString(content);
}
