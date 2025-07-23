import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:sc_mapper_dart/logger.dart';
import 'package:web_socket_channel/io.dart';

Future<void> log(IOWebSocketChannel channel, String message) async {
  await GetIt.I<FileLogger>().log(message);
  channel.sink.add(
    jsonEncode({
      'event': 'logMessage',
      'payload': {'message': message},
    }),
  );
}

Directory getResourceDir() {
  // Try script dir (works for AOT .exe)
  final scriptDir = Directory(p.dirname(Platform.script.toFilePath()));
  if (File(p.join(scriptDir.path, 'plugin.exe')).existsSync()) {
    return scriptDir;
  }
  // If not found, fall back to CWD (works for dart run)
  return Directory.current;
}

class ScInstalls {
  final String? live;
  final String? ptu;
  final String? techPreview;

  ScInstalls({
    required this.live,
    required this.ptu,
    required this.techPreview,
  });
}

Future<Directory> ensureAppDir() async {
  final appDir = Directory(
    p.join(Platform.environment['APPDATA'] ?? '', 'icu.veelume.sc-mapper'),
  );
  if (!appDir.existsSync()) {
    await appDir.create(recursive: true);
  }
  return appDir;
}

Future<ScInstalls> findUserFolderFromLog() async {
  final logDir = Directory(
    p.join(Platform.environment['APPDATA'] ?? '', 'rsilauncher', 'logs'),
  );
  if (!logDir.existsSync()) {
    return ScInstalls(live: null, ptu: null, techPreview: null);
  }

  final log = logDir.listSync().whereType<File>().firstWhereOrNull(
    (f) => f.path.endsWith('.log'),
  );
  if (log == null) return ScInstalls(live: null, ptu: null, techPreview: null);

  String? live;
  String? ptu;
  String? techPreview;

  final lines = await log.readAsLines();

  for (final line in lines) {
    // { "t":"2025-07-16 20:24:44.803", "[main][info] ": "[Launcher::launch] Launching Star Citizen LIVE from (C:\\Games\\StarCitizen\\LIVE)"  },
    if (line.contains("Launching Star Citizen LIVE")) {
      final match = RegExp(
        r'Launching Star Citizen LIVE from \((.+)\)',
      ).firstMatch(line);
      if (match != null) {
        live = match.group(1);
      }
    } else if (line.contains("Launching Star Citizen PTU")) {
      final match = RegExp(
        r'Launching Star Citizen PTU from \((.+)\)',
      ).firstMatch(line);
      if (match != null) {
        ptu = match.group(1);
      }
    } else if (line.contains("Launching Star Citizen Tech Preview")) {
      final match = RegExp(
        r'Launching Star Citizen Tech Preview from \((.+)\)',
      ).firstMatch(line);
      if (match != null) {
        techPreview = match.group(1);
      }
    }
  }

  // Test if the paths are valid directories
  if (live != null && !Directory(live).existsSync()) live = null;
  if (ptu != null && !Directory(ptu).existsSync()) ptu = null;
  if (techPreview != null && !Directory(techPreview).existsSync()) {
    techPreview = null;
  }
  return ScInstalls(live: live, ptu: ptu, techPreview: techPreview);
}

Future<Map<String, String>> parseTranslations(String iniPath) async {
  final lines = await File(iniPath).readAsLines();
  final translations = <String, String>{};
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith(';')) continue;

    // Try ',P=' split first (preferred)
    final idxP = trimmed.indexOf(',P=');
    if (idxP > 0) {
      final key = trimmed.substring(0, idxP).trim();
      final value = trimmed.substring(idxP + 3).trim();
      translations[key] = value;
      continue;
    }
    // Fallback: split on first comma or first equals
    final idxComma = trimmed.indexOf(',');
    final idxEqual = trimmed.indexOf('=');

    if (idxComma > 0 && (idxComma < idxEqual || idxEqual < 0)) {
      final key = trimmed.substring(0, idxComma).trim();
      final value = trimmed.substring(idxComma + 1).trim();
      translations[key] = value;
    } else if (idxEqual > 0) {
      final key = trimmed.substring(0, idxEqual).trim();
      final value = trimmed.substring(idxEqual + 1).trim();
      translations[key] = value;
    }
  }
  return translations;
}

String getTranslation(String key, Map<String, String> translations) {
  // Strip @ from the start if present
  final cleanKey = key.startsWith('@') ? key.substring(1) : key;
  return translations[cleanKey] ?? key;
}
