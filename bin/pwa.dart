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

  List<String> offlineUrls = await scanOfflineUrls(argv);
  String offlineUrlsFile = '${argv['lib-dir']}/offline_urls.g.dart';
  await writeOfflineUrls(offlineUrls, offlineUrlsFile);

  String libInclude = await detectLibInclude(argv);
  if (libInclude == null) {
    print('Unable to detect library include prefix. '
        'Run script from the root of the project or specify lib-include.');
    exit(-1);
  }
  await generateWorkerScript(argv, libInclude);
}

/// Scans all of the directories and returns the URLs derived from the files.
Future<List<String>> scanOfflineUrls(ArgResults argv) async {
  List<String> offlineDirs = argv['offline'];
  String indexHtml = argv['index-html'];
  List<String> excludes = argv['exclude'];
  bool excludeDefaults = argv['exclude-defaults'] == 'true';

  List<Glob> excludeGlobs = [];
  if (excludeDefaults) {
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
  excludeGlobs.addAll(excludes.map((s) => new Glob(s)));

  Set<String> urls = new Set();
  for (String dirName in offlineDirs) {
    Directory dir = new Directory(dirName);
    var list = await dir.list(recursive: true).toList();
    for (FileSystemEntity fse in list) {
      if (fse is! File) continue;
      String name = fse.path.substring(dir.path.length);
      if (excludeGlobs.any((glob) => glob.matches(name.substring(1)))) continue;
      if (name.endsWith('/$indexHtml')) {
        name = name.substring(0, name.length - indexHtml.length);
      }
      urls.add(name);
    }
  }

  return urls.toList()..sort();
}

/// Updates the offline_urls.g.dart file.
Future writeOfflineUrls(List<String> urls, String fileName) async {
  String listItems = urls.map((s) => '\'$s\',').join();
  String src = '''
    /// URLs for offline cache.
    final List<String> offlineUrls = [$listItems];
  ''';
  src = new DartFormatter().format(src);
  await _updateIfNeeded(fileName, src);
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
  bool hasWorkerConfig = new File('$libDir/worker.dart').existsSync();

  String customImport = 'import \'package:$libInclude/pwa/offline_urls.g.dart\' as offline;';
  String createWorker = 'PwaConfig worker = new PwaWorker()..offlineUrls = offline.offlineUrls;';
  if (hasWorkerConfig) {
    customImport = 'import \'package:$libInclude/pwa/worker.dart\' as custom;';
    createWorker = 'PwaWorker worker = custom.createWorker();';
  }

  String src = '''import 'package:pwa/worker.dart';
  $customImport

  /// Starts the PWA in the worker scope.
  void main() {
    $createWorker
    worker.run();
  }
  ''';
  src = new DartFormatter().format(src);

  await _updateIfNeeded('${argv['web-dir']}/pwa.g.dart', src);
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
  print('Updating $fileName.');
  await file.writeAsString(content);
}
