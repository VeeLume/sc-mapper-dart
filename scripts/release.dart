import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:yaml_edit/yaml_edit.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('version', abbr: 'v', help: 'Semantic version (e.g. 1.2.3)')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage');

  final results = parser.parse(args);
  final version = results['version'];

  if (results['help'] ||
      version == null ||
      !RegExp(r'^\d+\.\d+\.\d+$').hasMatch(version)) {
    print('Usage: dart release.dart --version 1.2.3');
    exit(1);
  }

  const build = 1;
  final fullVersion = '$version.$build';
  final tag = 'v$version';

  print('🔧 Preparing release: $fullVersion');

  await updatePubspec(version, build);
  await updateManifest(fullVersion);
  await commitAndTag(version, tag);
  await push(tag);

  print('✅ Release $version complete and pushed!');
}

Future<void> updatePubspec(String version, int build) async {
  final path = 'pubspec.yaml';
  final content = await File(path).readAsString();
  final doc = YamlEditor(content);

  doc.update(['version'], '$version+$build');
  await File(path).writeAsString(doc.toString());

  print('📦 Updated pubspec.yaml version to $version+$build');
}

Future<void> updateManifest(String fullVersion) async {
  final path = p.join('icu.veelume.sc-mapper.sdPlugin', 'manifest.json');
  final file = File(path);

  if (!await file.exists()) {
    print('❌ icu.veelume.sc-mapper.sdPlugin/manifest.json not found!');
    exit(1);
  }

  final jsonContent =
      jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  jsonContent['Version'] = fullVersion;
  await file.writeAsString(JsonEncoder.withIndent('  ').convert(jsonContent));

  print('🧩 Updated manifest.json Version to $fullVersion');
}

Future<void> commitAndTag(String version, String tag) async {
  await runGit(['add', 'pubspec.yaml', 'icu.veelume.sc-mapper.sdPlugin/manifest.json']);
  await runGit(['commit', '-m', 'Release v$version']);
  await runGit(['tag', tag]);
  print('🔖 Created commit and tag $tag');
}

Future<void> push(String tag) async {
  await runGit(['push']);
  await runGit(['push', 'origin', tag]);
  print('🚀 Pushed changes and tag $tag');
}

Future<void> runGit(List<String> args) async {
  final result = await Process.run('git', args);

  if (result.exitCode != 0) {
    stderr.writeln('Git command failed: git ${args.join(' ')}');
    stderr.writeln(result.stderr);
    exit(result.exitCode);
  }
}
