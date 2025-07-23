import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:sc_mapper_dart/action_handlers/generic.dart';
import 'package:sc_mapper_dart/app_state.dart';
import 'package:sc_mapper_dart/utils.dart';

// This class handles the generation of binds for the SC Mapper plugin.
// On a short key press, it will generate the necessary binds with the custom bindings.
// On a long key press, it will generate the binds with the default bindings.
class GenerateBindsKey extends ActionHandler {
  GenerateBindsKey(super.channel);

  static String get action => 'icu.veelume.sc-mapper.generatebinds';

  bool _longFired = false;
  Timer? _longPressTimer;

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
    _longFired = false;
    _longPressTimer = Timer(const Duration(milliseconds: 500), () async {
      _longFired = true;
      await log(
        channel,
        'Long press detected, generating binds with default bindings',
      );
      final appState = GetIt.I<AppState>();
      final success = await appState.parseActionBindings(
        GameInstallType.live,
        false,
      );
      if (success) {
        appState.createFullProfileXml(
          GameInstallType.live,
          'SC Mapper with Default',
        );
        await log(channel, 'Binds generated successfully');
        showOk(context);
      } else {
        await log(channel, 'Failed to generate binds');
        showAlert(context);
      }
    });
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

    await log(
      channel,
      'Short press detected, generating binds with custom bindings',
    );
    final appState = GetIt.I<AppState>();
    final success = await appState.parseActionBindings(
      GameInstallType.live,
      true,
    );

    if (success) {
      appState.createFullProfileXml(
        GameInstallType.live,
        'SC Mapper with Custom',
      );
      await log(channel, 'Binds generated successfully');
      showOk(context);
    } else {
      await log(channel, 'Failed to generate binds');
      showAlert(context);
    }
  }
}
