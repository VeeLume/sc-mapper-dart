import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:sc_mapper_dart/activation_modes.dart';
import 'package:sc_mapper_dart/constants.dart';
import 'package:sc_mapper_dart/utils.dart';
import 'package:xml/xml.dart';

typedef ActionId = String;
typedef ActionMapName = String;
typedef ActionName = String;

bool isModifier(String key) {
  return key == 'lshift' ||
      key == 'rshift' ||
      key == 'lctrl' ||
      key == 'rctrl' ||
      key == 'lalt' ||
      key == 'ralt';
}

ActivationMode? _parseActivationMode(
  XmlElement node,
  List<ActivationMode> activationModes,
  bool includeName,
) {
  final activationModeName = node.getAttribute('activationMode');
  if (activationModeName == null || activationModeName.isEmpty) {
    // Some binds might not have an activation mode defined
    // Instead they have onPress, onHold, onRelease, retriggerable attributes
    // So we try to parse with fromXml
    if (!ActivationMode.hasValidAttributes(node)) {
      return null; // No valid activation mode attributes found
    }
    try {
      return ActivationMode.fromXml(node, includeName);
    } catch (e) {
      print('Error parsing activation mode from XML: $e');
    }
    return null;
  }
  return activationModes.firstWhereOrNull(
    (am) => am.name == activationModeName,
  );
}

Map<String, Set<String>> buildFullCategoryGroups({
  Map<String, Set<String>> explicitGroups = const {},
  List<Set<String>> contextGroups = const [],
}) {
  final result = <String, Set<String>>{};

  // Merge explicit group definitions
  for (final entry in explicitGroups.entries) {
    final combined = <String>{entry.key, ...entry.value};
    for (final cat in combined) {
      result[cat] = combined;
    }
  }

  // Merge possible context sets
  for (final group in contextGroups) {
    for (final cat in group) {
      result[cat] = group;
    }
  }

  return result;
}

Set<String> _resolveDisallowedModifiers(
  String category,
  Map<String, Set<String>> fullCategoryGroups,
  Map<String, Set<String>> disallowedModifiersPerCategory,
) {
  final group = fullCategoryGroups[category] ?? {category};
  return group.fold<Set<String>>({}, (acc, cat) {
    final disallowed = disallowedModifiersPerCategory[cat];
    if (disallowed != null) acc.addAll(disallowed);
    return acc;
  });
}

Iterable<Set<String>> _generateModifierCombos(Set<String> modifiers) sync* {
  final mods = modifiers.toList();
  final total = 1 << mods.length;
  for (int i = 0; i < total; i++) {
    final combo = <String>{};
    for (int j = 0; j < mods.length; j++) {
      if ((i & (1 << j)) != 0) combo.add(mods[j]);
    }
    yield combo;
  }
}

class Bind {
  final String mainkey;
  final Set<String> modifiers;
  final ActivationMode? activationMode;

  const Bind({
    required this.mainkey,
    required this.modifiers,
    this.activationMode,
  });

  static Bind? fromString(String? input, ActivationMode? activationMode) {
    if (input == null || input.trim().isEmpty) return null;

    // Splits the device prefix if present
    final deviceSplit = input.split('_');
    // Splits the parts after the device prefix
    final parts = deviceSplit.last.split('+').map((s) => s.trim()).toList();

    final modifers = <String>{};
    final notModifiers = <String>{};

    for (final part in parts) {
      if (isModifier(part)) {
        modifers.add(part);
      } else {
        notModifiers.add(part);
      }
    }

    // If notModifiers is empty and there is a a single modifier, we assume it's a modifier bind
    if (notModifiers.isEmpty && modifers.length == 1) {
      return Bind(
        mainkey: modifers.first,
        modifiers: {},
        activationMode: activationMode,
      );
    } else if (notModifiers.isEmpty) {
      return null; // No main key found
    } else if (notModifiers.length == 1) {
      return Bind(
        mainkey: notModifiers.first,
        modifiers: modifers,
        activationMode: activationMode,
      );
    } else {
      // Not a valid bind, more than one main key
      return null;
    }
  }

  @override
  String toString() {
    final modStr = modifiers.isNotEmpty ? '${modifiers.join('+')}+' : '';
    return '$modStr$mainkey';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    final Bind otherBind = other as Bind;
    return mainkey == otherBind.mainkey &&
        const SetEquality<String>().equals(modifiers, otherBind.modifiers);
  }

  @override
  int get hashCode {
    return mainkey.hashCode ^ const SetEquality<String>().hash(modifiers);
  }

  factory Bind.fromJson(Map<String, dynamic> json) {
    final mainkey = json.getString('mainkey');
    final modifiers = json
        .getList('modifiers', defaultValue: [])
        .map((e) => e.toString())
        .toSet();
    final activationMode = json['activationMode'] != null
        ? ActivationMode.fromJson(json.getMap('activationMode'))
        : null;

    return Bind(
      mainkey: mainkey,
      modifiers: modifiers,
      activationMode: activationMode,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'mainkey': mainkey,
      'modifiers': modifiers.toList(),
      'activationMode': activationMode?.toJson(),
    };
  }
}

class Binds {
  final List<Bind> keyboard;
  final List<Bind> mouse;

  bool get isEmpty => keyboard.isEmpty && mouse.isEmpty;
  bool get isNotEmpty => !isEmpty;

  Binds({required this.keyboard, required this.mouse});

  factory Binds.fromJson(Map<String, dynamic> json) {
    final keyboard = json
        .getList('keyboard', defaultValue: [])
        .map((e) => Bind.fromJson(e))
        .whereType<Bind>()
        .toList();
    final mouse = json
        .getList('mouse', defaultValue: [])
        .map((e) => Bind.fromJson(e))
        .whereType<Bind>()
        .toList();

    return Binds(keyboard: keyboard, mouse: mouse);
  }

  static List<Bind> _parseBind(
    XmlElement node,
    List<ActivationMode> activationModes,
    String deviceType,
  ) {
    final bindsList = <Bind>[];
    final flatActivationMode = _parseActivationMode(
      node,
      activationModes,
      false,
    );
    final bindFlat = node.getAttribute(deviceType)?.trim();
    if (bindFlat != null && bindFlat.isNotEmpty) {
      final binds = Bind.fromString(bindFlat, flatActivationMode);
      if (binds != null) {
        bindsList.add(binds);
      }
    }

    // Some action nodes have a 'keyboard' element with multiple inputdata elements or a single input attribute
    for (final subNode in node.findElements(deviceType)) {
      // If the keyboard node has an 'input' attribute, we parse it directly
      final input = subNode.getAttribute('input');
      if (input != null && input.trim().isNotEmpty) {
        final bind = Bind.fromString(
          input.trim(),
          _parseActivationMode(subNode, activationModes, true) ??
              flatActivationMode,
        );
        if (bind != null) {
          bindsList.add(bind);
        }
      }

      for (final inputData in subNode.findElements('inputdata')) {
        final input = inputData.getAttribute('input')?.trim();
        if (input != null && input.isNotEmpty) {
          final bind = Bind.fromString(
            input.trim(),
            flatActivationMode, // So far there dont seem custom activation modes for inputdata binds
          );
          if (bind != null) {
            bindsList.add(bind);
          }
        }
      }
    }

    return bindsList;
  }

  factory Binds.fromDefaultProfile(
    XmlElement node,
    List<ActivationMode> activationModes,
  ) {
    final keyboard = _parseBind(node, activationModes, 'keyboard');
    final mouse = _parseBind(node, activationModes, 'mouse');
    return Binds(keyboard: keyboard, mouse: mouse);
  }

  Map<String, dynamic> toJson() {
    return {
      'keyboard': keyboard.map((e) => e.toJson()).toList(),
      'mouse': mouse.map((e) => e.toJson()).toList(),
    };
  }
}

class ActionBinding {
  final ActionId actionId;
  final ActionName actionName;

  final String? uiLabel;
  final String? uiDescription;
  final String? category;

  final Binds defaultBinds;
  Binds? customBinds;
  final ActivationMode? activationMode;

  ActionBinding({
    required this.actionId,
    required this.actionName,
    this.uiLabel,
    this.uiDescription,
    this.category,
    required this.defaultBinds,
    this.customBinds,
    this.activationMode,
  });

  String getBindLabel() {
    final binds = customBinds ?? defaultBinds;
    final keyboard = binds.keyboard.isNotEmpty
        ? binds.keyboard.map((b) => b.toString()).join(', ')
        : null;
    final mouse = binds.mouse.isNotEmpty
        ? binds.mouse.map((b) => b.toString()).join(', ')
        : null;
    return [
      if (keyboard != null) keyboard,
      if (mouse != null) mouse,
    ].join(' | ');
  }

  String getLabel(Map<String, String> translations) {
    return getTranslation(uiLabel ?? actionName, translations);
  }

  factory ActionBinding.fromDefaultProfile(
    XmlElement node,
    String actionMapName,
    List<ActivationMode> activationModes,
  ) {
    final actionName = node.getAttribute('name') ?? 'Unknown';

    final uiLabel = node.getAttribute('UILabel')?.nullIfBlank;
    final uiDescription = node.getAttribute('UIDescription')?.nullIfBlank;
    final category = node.getAttribute('Category')?.nullIfBlank;

    final defaultBinds = Binds.fromDefaultProfile(node, activationModes);
    final activationMode = _parseActivationMode(node, activationModes, false);

    return ActionBinding(
      actionId: '$actionMapName.$actionName',
      actionName: actionName,
      uiLabel: uiLabel,
      uiDescription: uiDescription,
      category: category,
      defaultBinds: defaultBinds,
      activationMode: activationMode,
    );
  }

  factory ActionBinding.fromJson(Map<String, dynamic> json) {
    final actionId = json.getString('actionId');
    final actionName = json.getString('actionName');
    final uiLabel = json.tryGetString('uiLabel');
    final uiDescription = json.tryGetString('uiDescription');
    final category = json.tryGetString('category');
    final defaultBinds = Binds.fromJson(json.getMap('defaultBinds'));
    final customBinds = json['customBinds'] != null
        ? Binds.fromJson(json.getMap('customBinds'))
        : null;
    final activationMode = json['activationMode'] != null
        ? ActivationMode.fromJson(json.getMap('activationMode'))
        : null;

    return ActionBinding(
      actionId: actionId,
      actionName: actionName,
      uiLabel: uiLabel,
      uiDescription: uiDescription,
      category: category,
      defaultBinds: defaultBinds,
      customBinds: customBinds,
      activationMode: activationMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actionId': actionId,
      'actionName': actionName,
      'uiLabel': uiLabel,
      'uiDescription': uiDescription,
      'category': category,
      'defaultBinds': defaultBinds.toJson(),
      'customBinds': customBinds?.toJson(),
      'activationMode': activationMode?.toJson(),
    };
  }
}

class ActionMap {
  final String name;
  final int version;
  final String? uiLabel;
  final String? uiCategory;
  final Map<ActionName, ActionBinding> actions;

  ActionMap({
    required this.name,
    required this.version,
    this.uiLabel,
    this.uiCategory,
    required this.actions,
  });

  String getLabel(Map<String, String> translations) {
    return getTranslation(uiLabel ?? uiCategory ?? name, translations);
  }

  factory ActionMap.fromDefaultProfile(
    XmlElement node,
    List<ActivationMode> activationModes,
  ) {
    final name = node.getAttribute('name') ?? 'Unknown';
    final version = int.tryParse(node.getAttribute('version') ?? '0') ?? 0;
    final uiLabel = node.getAttribute('UILabel')?.nullIfBlank;
    final uiCategory =
        node.getAttribute('UICategory')?.nullIfBlank ??
        actionmapUICategories[name];
    final actions = node
        .findElements('action')
        // Filter out actions that do not have a keyboard bind
        // These are axis actions
        .where(
          (node) =>
              node.getAttribute('keyboard') != null ||
              node.findElements('keyboard').isNotEmpty,
        )
        .map(
          (actionNode) => ActionBinding.fromDefaultProfile(
            actionNode,
            name,
            activationModes,
          ),
        )
        .fold<Map<ActionName, ActionBinding>>({}, (map, binding) {
          map[binding.actionName] = binding;
          return map;
        });

    return ActionMap(
      name: name,
      version: version,
      uiLabel: uiLabel,
      uiCategory: uiCategory,
      actions: actions,
    );
  }

  factory ActionMap.fromJson(Map<String, dynamic> json) {
    final name = json.getString('name');
    final version = json.getInt('version');
    final uiLabel = json.tryGetString('uiLabel');
    final uiCategory = json.tryGetString('uiCategory');
    final actions = (json.getList('actions', defaultValue: []))
        .map((e) => ActionBinding.fromJson(e))
        .fold<Map<ActionName, ActionBinding>>({}, (map, binding) {
          map[binding.actionName] = binding;
          return map;
        });

    return ActionMap(
      name: name,
      version: version,
      uiLabel: uiLabel,
      uiCategory: uiCategory,
      actions: actions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'version': version,
      'uiLabel': uiLabel,
      'uiCategory': uiCategory,
      'actions': actions.values.map((e) => e.toJson()).toList(),
    };
  }
}

class ActionBindings {
  Future<void> Function(String msg) log;

  final Map<ActionMapName, ActionMap> _actionMaps = {};
  final List<ActivationMode> _activationModes = [];

  Map<ActionMapName, ActionMap> get actionMaps => _actionMaps;
  Map<ActionId, ActionBinding> get bindings => _actionMaps.values
      .expand((map) => map.actions.values)
      .fold<Map<ActionId, ActionBinding>>({}, (map, binding) {
        map[binding.actionId] = binding;
        return map;
      });

  ActionBindings({required this.log});

  ActionBinding? getBindingById(ActionId id) {
    final parts = id.split('.');
    if (parts.length < 2) return null; // Invalid ID format
    final actionMapName = parts[0];
    final actionName = parts[1];
    final actionMap = _actionMaps[actionMapName];
    if (actionMap == null) return null; // Action map not found
    return actionMap.actions[actionName];
  }

  Future<void> writeJson(File jsonFile) async {
    final content = jsonEncode(
      _actionMaps.values.map((e) => e.toJson()).toList(),
    );
    await jsonFile.writeAsString(content);
    log('Action bindings saved to ${jsonFile.path}');
  }

  Future<void> loadJson(File jsonFile) async {
    final content = await jsonFile.readAsString();
    final List<dynamic> jsonList = jsonDecode(content);
    for (var actionmap in jsonList) {
      final actionMapName = actionmap['name'] as String;

      final actionMap = ActionMap.fromJson(actionmap);
      _actionMaps[actionMapName] = actionMap;
    }
    log('Action bindings loaded from ${jsonFile.path}');
  }

  Future<void> loadDefaultProfile(
    File defaultProfileFile,
    Set<String> skipActionmaps,
  ) async {
    final doc = XmlDocument.parse(await defaultProfileFile.readAsString());

    for (final node in doc.findAllElements('ActivationMode')) {
      _activationModes.add(ActivationMode.fromXml(node, true));
    }

    for (final node in doc.findAllElements('actionmap')) {
      final actionMapName = node.getAttribute('name');
      if (actionMapName == null || skipActionmaps.contains(actionMapName)) {
        continue; // Skip action maps that are in the skip list
      }
      final actionMap = ActionMap.fromDefaultProfile(node, _activationModes);
      _actionMaps[actionMap.name] = actionMap;
    }
  }

  Future<void> applyCustomProfile(File customProfileFile) async {
    final doc = XmlDocument.parse(await customProfileFile.readAsString());

    for (final am in doc.findAllElements('actionmap')) {
      final actionMapName = am.getAttribute('name');
      if (actionMapName == null) {
        continue;
      }

      for (final ab in am.findAllElements('action')) {
        final actionName = ab.getAttribute('name');
        if (actionName == null) {
          continue;
        }

        final rebinds = <Binds>{};
        for (final rebindNode in ab.findElements('rebind')) {
          final input = rebindNode.getAttribute('input');
          final deviceType = input?.substring(0, 3) ?? '';
          final activationMode =
              rebindNode.getAttribute('activationMode') != null
              ? _activationModes.firstWhereOrNull(
                  (am) => am.name == rebindNode.getAttribute('activationMode')!,
                )
              : null;

          if (input != null && input.isNotEmpty) {
            final bind = Bind.fromString(
              input.substring(3).trim(),
              activationMode,
            );
            if (bind != null) {
              rebinds.add(
                Binds(
                  keyboard: deviceType == 'kb1' ? [bind] : [],
                  mouse: deviceType == 'mo1' ? [bind] : [],
                ),
              );
            }
          }
        }

        // Rebinds should be either empty or contain one Binds object

        if (rebinds.isNotEmpty) {
          final customBinds = rebinds.first;
          // Update the existing binding
          final existingActionBinding =
              _actionMaps[actionMapName]?.actions[actionName];

          if (existingActionBinding == null) {
            continue; // No existing binding found
          }

          existingActionBinding.customBinds = customBinds;
          log(
            'Updated custom binds for ${existingActionBinding.actionId}: '
            '${customBinds.keyboard.join(', ')} | ${customBinds.mouse.join(', ')}',
          );
        }
      }
    }
  }

  Future<void> generateMissingBinds({
    required Set<String> availableKeys,
    required Set<String> availableModifiers,
    required Set<Bind> bannedBinds,
    required Set<Set<String>> categoryGroups,
    required Map<String, Set<String>> disallowedModifiersPerCategory,
  }) async {
    // Merge groups
    final Map<String, Set<String>> fullCategoryGroups = {};

    for (final group in categoryGroups) {
      for (final cat in group) {
        fullCategoryGroups.putIfAbsent(cat, () => <String>{}).addAll(group);
      }
    }

    final activationModePress = _activationModes.firstWhereOrNull(
      (am) => am.name == 'press',
    );
    final usedBindsByGroup = <String, Set<Bind>>{};

    // First pass: Register all existing binds
    for (final actionMap in _actionMaps.values) {
      final category = actionMap.uiCategory ?? 'default';
      final group = fullCategoryGroups[category] ?? {category};

      for (final binding in actionMap.actions.values) {
        final allBinds = [
          ...binding.defaultBinds.keyboard,
          ...binding.defaultBinds.mouse,
          ...?binding.customBinds?.keyboard,
          ...?binding.customBinds?.mouse,
        ];

        for (final g in group) {
          usedBindsByGroup.putIfAbsent(g, () => {}).addAll(allBinds);
        }
      }
    }

    for (final actionMap in _actionMaps.values) {
      final category = actionMap.uiCategory ?? 'default';
      final group = fullCategoryGroups[category] ?? {category};

      for (final binding in actionMap.actions.values) {
        final hasDefault = binding.defaultBinds.isNotEmpty;
        final hasCustom = binding.customBinds?.isNotEmpty ?? false;

        // Skip if already bound
        if (hasDefault || hasCustom) continue;

        final disallowedMods = _resolveDisallowedModifiers(
          category,
          fullCategoryGroups,
          disallowedModifiersPerCategory,
        );
        final allowedMods = availableModifiers.difference(disallowedMods);

        Bind? generated;

        for (final key in availableKeys) {
          for (final modSet in _generateModifierCombos(allowedMods)) {
            final candidate = Bind(
              mainkey: key,
              modifiers: modSet,
              activationMode: activationModePress,
            );

            final isUsed = group.any(
              (g) => usedBindsByGroup[g]?.contains(candidate) ?? false,
            );

            if (bannedBinds.contains(candidate) || isUsed) {
              continue;
            }

            for (final g in group) {
              usedBindsByGroup[g]?.add(candidate);
            }

            generated = candidate;
            break;
          }
          if (generated != null) break;
        }

        if (generated != null) {
          binding.customBinds = Binds(keyboard: [generated], mouse: []);

          await log('✅ Generated bind for ${binding.actionId}: $generated');
        } else {
          await log('⚠️ No available bind for ${binding.actionId}');
        }
      }
    }
  }

  Future<void> generateMappingXml({
    required File outputFile,
    List<Map<String, String>>? devices,
    String profileName = 'GeneratedProfile',
  }) async {
    final allBindings = bindings.values.where((b) {
      return b.customBinds?.isNotEmpty ?? false;
    }).toList();

    final byActionmap = <String, List<ActionBinding>>{};
    for (final binding in allBindings) {
      final actionMapName = binding.actionId.split('.').first.trim();
      byActionmap.putIfAbsent(actionMapName, () => []).add(binding);
    }

    final defaultDevices = [
      {'type': 'keyboard', 'instance': '1'},
    ];

    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="utf-8"');
    builder.element(
      'ActionMaps',
      nest: () {
        builder.attribute('version', '1');
        builder.attribute('optionsVersion', '2');
        builder.attribute('rebindVersion', '2');
        builder.attribute('profileName', profileName);

        builder.element(
          'CustomisationUIHeader',
          nest: () {
            builder.attribute('label', profileName);
            builder.attribute('description', '');
            builder.attribute('image', '');

            builder.element(
              'devices',
              nest: () {
                for (final dev in (devices ?? defaultDevices)) {
                  builder.element(
                    dev['type']!,
                    nest: () {
                      builder.attribute('instance', dev['instance']!);
                    },
                  );
                }
              },
            );
          },
        );

        builder.element('modifiers');

        for (final entry in byActionmap.entries) {
          final actionMapName = entry.key;
          final actions = entry.value;

          builder.element(
            'actionmap',
            nest: () {
              builder.attribute('name', actionMapName);

              for (final action in actions) {
                final custom = action.customBinds!;
                final hasKeyboard = custom.keyboard.isNotEmpty;
                final hasMouse = custom.mouse.isNotEmpty;

                builder.element(
                  'action',
                  nest: () {
                    builder.attribute('name', action.actionName);

                    if (hasKeyboard) {
                      for (final bind in custom.keyboard) {
                        builder.element(
                          'rebind',
                          nest: () {
                            builder.attribute('device', 'keyboard');
                            // Set activation mode to 'press' by default
                            // This makes it easier to handle
                            builder.attribute('activationMode', 'press');
                            builder.attribute('input', 'kb1_$bind');
                          },
                        );
                      }
                    }

                    if (hasMouse) {
                      for (final bind in custom.mouse) {
                        builder.element(
                          'rebind',
                          nest: () {
                            builder.attribute('device', 'mouse');
                            // Set activation mode to 'press' by default
                            // This makes it easier to handle
                            builder.attribute('activationMode', 'press');
                            builder.attribute('input', 'mo1_$bind');
                          },
                        );
                      }
                    }
                  },
                );
              }
            },
          );
        }
      },
    );

    final xmlString = builder.buildDocument().toXmlString(pretty: true);
    await outputFile.writeAsString(xmlString);

    await log('✅ Wrote mapping XML to ${outputFile.path}');
  }
}

Future<void> main() async {
  final defaultFilePath =
      'E:\\vscode\\dart\\sc-mapper-dart\\icu.veelume.sc-mapper.sdPlugin\\defaultProfile.xml';
  final defaultProfileFile = File(defaultFilePath);

  if (!await defaultProfileFile.exists()) {
    print('Default profile file not found at $defaultFilePath');
    return;
  }

  final actionBindings = ActionBindings(log: (msg) async => print(msg));

  await actionBindings.loadDefaultProfile(defaultProfileFile, skipActionmaps);

  print('Loaded action maps: ${actionBindings._actionMaps.keys}');

  final customProfilePath =
      'C:\\Games\\StarCitizen\\LIVE\\user\\client\\0\\Profiles\\default\\actionmaps.xml';
  // await actionBindings.applyCustomProfile(
  //   File(customProfilePath),
  //   (msg) async => print(msg),
  // );

  print('Applied custom profile from $customProfilePath');

  // Generate missing binds
  await actionBindings.generateMissingBinds(
    availableKeys: candidateKeys,
    availableModifiers: candidateModifiers,
    bannedBinds: denyCombos,
    categoryGroups: categoryGroups,
    disallowedModifiersPerCategory: disallowedModifiersPerCategory,
  );

  // Write json output
  final jsonOutput = jsonEncode(
    actionBindings._actionMaps.values.map((e) => e.toJson()).toList(),
  );

  final outputFile = File('action_maps.json');
  await outputFile.writeAsString(jsonOutput);

  print('Wrote action maps to ${outputFile.path}');

  // Generate mapping XML
  final xmlOutputFile = File('generated_action_maps.xml');
  await actionBindings.generateMappingXml(
    outputFile: xmlOutputFile,
    profileName: 'GeneratedProfile',
  );

  print('Generated mapping XML at ${xmlOutputFile.path}');

  // Text loading json
  final jsonFile = File('action_maps.json');
  if (await jsonFile.exists()) {
    final loadedActions = ActionBindings(log: (msg) async => print(msg));
    await loadedActions.loadJson(jsonFile);
    print('Loaded action bindings from ${jsonFile.path}');
    print('Available actions: ${loadedActions.actionMaps.length}');
  } else {
    print('JSON file not found at ${jsonFile.path}');
  }
}
