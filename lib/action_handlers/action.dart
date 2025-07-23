import 'dart:async';

import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:get_it/get_it.dart';
import 'package:sc_mapper_dart/action_handlers/data_source.dart';
import 'package:sc_mapper_dart/action_handlers/generic.dart';
import 'package:sc_mapper_dart/app_state.dart';
import 'package:sc_mapper_dart/keyboard_input.dart';
import 'package:sc_mapper_dart/utils.dart';

class Settings {
  String? actionShort;
  bool enableLongPress;
  String? actionLong;
  int longPressPeriod;

  Settings({
    this.actionShort,
    this.enableLongPress = false,
    this.actionLong,
    this.longPressPeriod = 200,
  });

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
    actionShort: json.tryGetString('actionShort'),
    enableLongPress: json.getBool('enableLongPress', defaultValue: false),
    actionLong: json.tryGetString('actionLong'),
    longPressPeriod: json.getInt('longPressPeriod', defaultValue: 200),
  );
  Map<String, dynamic> toJson() {
    return {
      'actionShort': actionShort,
      'enableLongPress': enableLongPress,
      'actionLong': actionLong,
      'longPressPeriod': longPressPeriod,
    };
  }
}

class ActionKey extends ActionHandler {
  ActionKey(super.channel);

  static String get action => 'icu.veelume.sc-mapper.action';

  bool _longFired = false;
  Timer? _longPressTimer;

  @override
  Future<void> onDidReceiveSettings(
    String context,
    String device,
    String controller,
    bool isInMultiAction,
    KeyCoordinates? coordinates,
    Map<String, dynamic> settings,
    int? state,
  ) async {
    final conf = Settings.fromJson(settings);

    const Map<String, String> suffixes = {
      '_on': '_off',
      '_up': '_down',
      '_increment': '_decrement',
      '_deploy': '_retract',
      '_enable_long': '_disable_long',
      '_enable_short': '_disable_short',
      '_enable': '_disable',
      '_fwd': '_back',
      '_left': '_right',
      '_next': '_prev',
      '_increase': '_decrease',
      '_forward': '_backward',
    };

    // If actionShort is set to an action with one of the suffix, search for an action with the same name but with one of the matching suffix
    // actionLong needs to be null for this to trigger
    if (conf.actionShort != null && conf.actionLong == null) {
      final actionShort = conf.actionShort!;
      final actionBindings =
          GetIt.I<AppState>().actionBindings[GameInstallType.live]!;
      for (final suffix in suffixes.keys) {
        if (actionShort.endsWith(suffix)) {
          final newAction = actionShort.replaceAll(suffix, suffixes[suffix]!);
          if (actionBindings.bindings.containsKey(newAction)) {
            conf.actionLong = newAction;
            await log(channel, 'Found matching long action: $newAction');
            setSettings(context, conf.toJson());
            break;
          }
        }
      }
    }
  }

  @override
  Future<void> onKeyDown(
    String context,
    String device,
    bool isInMultiAction,
    KeyCoordinates? coordinates,
    Map<String, dynamic> settings,
    int? state,
    int? userDesiredState,
  ) async {
    final conf = Settings.fromJson(settings);

    _longFired = false;
    if (conf.enableLongPress && conf.actionLong != null) {
      _longPressTimer = Timer(
        Duration(milliseconds: conf.longPressPeriod),
        () async {
          _longFired = true;
          await log(channel, 'Long press detected, executing long action');
          await sendKey(conf.actionLong!);
        },
      );
    }
  }

  @override
  Future<void> onKeyUp(
    String context,
    String device,
    bool isInMultiAction,
    KeyCoordinates? coordinates,
    Map<String, dynamic> settings,
    int? state,
  ) async {
    _longPressTimer?.cancel();

    if (_longFired) {
      await log(channel, 'Long press ended, no action taken');
      return;
    }

    final conf = Settings.fromJson(settings);
    if (conf.actionShort != null) {
      await log(channel, 'Short press detected, executing short action');
      await sendKey(conf.actionShort!);
    } else {
      await log(channel, 'No action configured for short press');
    }
  }

  Future<void> sendKey(String id) async {
    final appState = GetIt.I<AppState>();
    final actionBindings = appState.actionBindings[GameInstallType.live];
    if (actionBindings == null) {
      await log(channel, 'No action bindings found for live game');
      return;
    }

    final action = actionBindings.getBindingById(id);
    if (action == null) {
      await log(channel, 'Action $id not found in bindings');
      return;
    }

    await action.simulate();
  }

  @override
  Future<void> onDidReceivePropertyInspectorMessage(
    String context,
    String event,
    bool? isRefresh,
  ) async {
    if (event == 'getActions') {
      // Check if cache is available
      if (GetIt.I<AppState>().cachedDataSourceItems[GameInstallType.live] !=
          null) {
        await log(channel, 'Using cached data source items');
        sendToPropertyInspector(
          context,
          DataSourcePayload(
            event: 'getActions',
            items: GetIt.I<AppState>()
                .cachedDataSourceItems[GameInstallType.live]!,
          ),
        );
        return;
      }

      await log(channel, 'Fetching actions from action bindings');
      final actionBindings =
          GetIt.I<AppState>().actionBindings[GameInstallType.live];
      if (actionBindings == null) {
        await log(channel, 'No action bindings found for live game');
        return;
      }

      final Map<String, String> translations =
          GetIt.I<AppState>().translations[GameInstallType.live] ?? {};

      log(channel, 'Translations loaded: ${translations.length} entries');

      final items = actionBindings.actionMaps.values
          .map(
            (actionmap) => ItemGroup(
              label: actionmap.getLabel(translations),
              children: actionmap.actions.values
                  .map(
                    (action) => Item(
                      disabled: false,
                      label:
                          '${action.getLabel(translations)} [${action.getBindLabel()}]',
                      value: action.actionId,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList();
      log(channel, 'Fetched ${items.length} categories with actions');

      // Cache the items
      GetIt.I<AppState>().cachedDataSourceItems[GameInstallType.live] = items;

      final payload = DataSourcePayload(event: 'getActions', items: items);
      sendToPropertyInspector(context, payload);
    } else {
      await log(channel, 'Unknown event: $event');
    }
  }
}
