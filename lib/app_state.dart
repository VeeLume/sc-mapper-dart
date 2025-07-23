import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sc_mapper_dart/action_bindings.dart';
import 'package:sc_mapper_dart/action_handlers/data_source.dart';
import 'package:sc_mapper_dart/constants.dart';
import 'package:sc_mapper_dart/utils.dart';
import 'package:web_socket_channel/io.dart';

enum GameInstallType { live, ptu, techPreview }

const Map<String, String> translationOverrides = {};

class AppState {
  final IOWebSocketChannel channel;
  final Directory resourceDir;
  final Map<GameInstallType, String?> gamePaths = {
    GameInstallType.live: null,
    GameInstallType.ptu: null,
    GameInstallType.techPreview: null,
  };

  late final Map<GameInstallType, ActionBindings> actionBindings;

  final Map<GameInstallType, Map<String, String>> translations = {
    GameInstallType.live: {},
    GameInstallType.ptu: {},
    GameInstallType.techPreview: {},
  };

  final Map<GameInstallType, List<DataSourceResult>?> cachedDataSourceItems = {
    GameInstallType.live: null,
    GameInstallType.ptu: null,
    GameInstallType.techPreview: null,
  };

  AppState({required this.resourceDir, required this.channel})
    : actionBindings = {
        GameInstallType.live: ActionBindings(log: (msg) => log(channel, msg)),
        GameInstallType.ptu: ActionBindings(log: (msg) => log(channel, msg)),
        GameInstallType.techPreview: ActionBindings(
          log: (msg) => log(channel, msg),
        ),
      };

  Future<void> initialize() async {
    await log(
      channel,
      'Initializing AppState with resourceDir: ${resourceDir.path}',
    );
    await loadGamePaths();
    log(channel, 'Game paths loaded: $gamePaths');
    await loadTranslations(GameInstallType.live);
    await loadTranslations(GameInstallType.ptu);
    await loadTranslations(GameInstallType.techPreview);
    await loadActionBindings(GameInstallType.live);
    await loadActionBindings(GameInstallType.ptu);
    await loadActionBindings(GameInstallType.techPreview);
  }

  Future<void> loadGamePaths() async {
    final installs = await findUserFolderFromLog();
    gamePaths[GameInstallType.live] = installs.live;
    gamePaths[GameInstallType.ptu] = installs.ptu;
    gamePaths[GameInstallType.techPreview] = installs.techPreview;
  }

  Future<void> loadTranslations(GameInstallType type) async {
    final path = gamePaths[type];
    if (path == null) {
      log(
        channel,
        'Game path for $type is not set, skipping translations load',
      );
      return;
    }

    final translationFile = File(p.join(resourceDir.path, 'global.ini'));

    if (!translationFile.existsSync()) {
      log(channel, 'Translation file not found at ${translationFile.path}');
      return;
    }

    try {
      final tranlations = await parseTranslations(translationFile.path);

      // Include overrides
      tranlations.addAll(translationOverrides);

      translations[type] = tranlations;
    } catch (e) {
      log(channel, 'Error parsing translations for $type: $e');
      return;
    }
    log(channel, 'Translations for $type loaded');
  }

  String getTranslation(GameInstallType type, String key) {
    final cleanKey = key.startsWith('@') ? key.substring(1) : key;
    return translations[type]?[cleanKey] ?? key;
  }

  Future<void> loadActionBindings(GameInstallType type) async {
    try {
      final appDir = await ensureAppDir();
      final bindingsFile = File(
        p.join(appDir.path, 'bindings_${type.name}.json'),
      );

      if (!bindingsFile.existsSync()) {
        log(channel, 'Bindings file not found at ${bindingsFile.path}');
        return;
      }

      await actionBindings[type]?.loadJson(bindingsFile);
      cachedDataSourceItems[type] = null;

      final test = ActionBindings(log: (msg) => log(channel, msg));
      await test.loadJson(bindingsFile);
      log(channel, 'Test action bindings loaded from ${bindingsFile.path}');
      log(channel, 'Available actions: ${test.actionMaps.length}');

      log(
        channel,
        'Action bindings for $type loaded from ${bindingsFile.path}',
      );
      log(
        channel,
        'Available actions: ${actionBindings[type]?.actionMaps.length}',
      );
    } catch (e) {
      log(channel, 'Error loading action bindings for $type: $e');
      return;
    }
  }

  Future<bool> parseActionBindings(
    GameInstallType type,
    bool withCustom,
  ) async {
    final path = gamePaths[type];
    if (path == null) return false;

    final defaultBindingsFile = File(
      p.join(resourceDir.path, 'defaultProfile.xml'),
    );

    if (!defaultBindingsFile.existsSync()) {
      log(channel, 'Default profile not found at ${defaultBindingsFile.path}');
      return false;
    }

    final customBindingsFile = File(
      p.join(
        path,
        'user',
        'client',
        '0',
        'profiles',
        'default',
        'actionmaps.xml',
      ),
    );

    if (withCustom && !customBindingsFile.existsSync()) {
      log(channel, 'Custom profile not found at ${customBindingsFile.path}');
      return false;
    }

    try {
      log(channel, 'Parsing default profile: ${defaultBindingsFile.path}');
      await actionBindings[type]?.loadDefaultProfile(
        defaultBindingsFile,
        skipActionmaps,
      );
    } catch (e) {
      log(channel, 'Error parsing default profile: $e');
      return false;
    }

    if (withCustom) {
      try {
        log(channel, 'Parsing custom profile: ${customBindingsFile.path}');
        await actionBindings[type]?.applyCustomProfile(customBindingsFile);
      } catch (e) {
        log(channel, 'Error applying custom profile: $e');
        return false;
      }
    }

    try {
      log(channel, 'Auto-assigning bindings for $type');
      await actionBindings[type]?.generateMissingBinds(
        availableKeys: candidateKeys,
        availableModifiers: candidateModifiers,
        bannedBinds: denyCombos,
        categoryGroups: categoryGroups,
        disallowedModifiersPerCategory: disallowedModifiersPerCategory,
      );
    } catch (e) {
      log(channel, 'Error auto-assigning bindings: $e');
      return false;
    }

    cachedDataSourceItems[type] = null;

    try {
      log(channel, 'Saving action bindings for $type');
      final appDir = await ensureAppDir();
      final bindingsFile = File(
        p.join(appDir.path, 'bindings_${type.name}.json'),
      );
      await actionBindings[type]?.writeJson(bindingsFile);
      log(channel, 'Action bindings for $type saved to ${bindingsFile.path}');
      return true;
    } catch (e) {
      log(channel, 'Error saving action bindings for $type: $e');
      return false;
    }
  }

  Future<bool> createFullProfileXml(
    GameInstallType type,
    String profileName,
  ) async {
    final bindings = actionBindings[type];
    if (bindings == null) {
      return false;
    }

    final path = gamePaths[type];
    if (path == null) {
      log(channel, 'Game path for $type is not set');
      return false;
    }

    final outputPath = p.join(
      path,
      'user',
      'client',
      '0',
      'controls',
      'mappings',
      'icu.veelume.sc-mapper.xml',
    );

    await bindings.generateMappingXml(
      outputFile: File(outputPath),
      profileName: profileName,
    );
    log(channel, 'Full profile XML for $type written to $outputPath');
    return true;
  }
}
