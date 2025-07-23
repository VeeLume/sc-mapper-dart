import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:sc_mapper_dart/action_bindings.dart';
import 'package:sc_mapper_dart/constants.dart';
import 'package:win32/win32.dart';

extension ActionBindingSimulation on ActionBinding {
  Future<void> simulate() async {
    final bind =
        (customBinds?.keyboard.firstOrNull ??
        defaultBinds.keyboard.firstOrNull ??
        customBinds?.mouse.firstOrNull ??
        defaultBinds.mouse.firstOrNull);

    if (bind == null) {
      print('⚠️ No available bind to simulate for $actionId');
      return;
    }

    await simulateActionInput(bind);
  }
}

Future<void> simulateActionInput(
  Bind bind, {
  Duration? holdDurationOverride,
}) async {
  final mode = bind.activationMode;
  if (mode == null) {
    print('⚠️ No activation mode specified — defaulting to tap.');
    await sendInputComboBatch(bind);
    return;
  }

  // final name = mode.name.toLowerCase();
  final onHold = mode.onHold;
  final onPress = mode.onPress;
  final onRelease = mode.onRelease;
  final multiTap = mode.multiTap;
  final pressThreshold = mode.pressTriggerThreshold;

  // 💡 Double tap modes
  if (multiTap > 1) {
    for (var i = 0; i < 2; i++) {
      await sendInputComboBatch(bind);
      if (i == 0) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    return;
  }

  // ⏱ Hold mode (e.g., hold, delayed_press, delayed_hold, etc)
  if (onHold || pressThreshold > 0) {
    final delayMs = pressThreshold > 0
        ? (pressThreshold * 1000).round()
        : (mode.holdTriggerDelay > 0
              ? (mode.holdTriggerDelay * 1000).round()
              : 260);

    final duration =
        holdDurationOverride ??
        Duration(milliseconds: delayMs.clamp(100, 2000));

    await sendInputComboBatch(bind, holdDuration: duration);
    return;
  }

  // 🖐 Tap / release-triggered (e.g., "tap" which only fires on key release)
  if (onRelease && !onHold && !onPress) {
    // We can't simulate a release-only press in Windows, so just do a standard tap
    await sendInputComboBatch(bind);
    return;
  }

  // 🧱 Fallback: treat as normal press/release
  await sendInputComboBatch(bind);
}

class _KeyEvent {
  final String key;
  final bool down;
  _KeyEvent(this.key, {required this.down});
}

/// Sends a batch of key events to Windows
void _sendKeyEventsBatch(List<_KeyEvent> events) {
  final inputArray = calloc<INPUT>(events.length);

  for (var i = 0; i < events.length; i++) {
    final e = events[i];
    final scan = getScanCode(e.key);
    if (scan == null) {
      print('❌ Unknown scan code for key: ${e.key}');
      continue;
    }

    inputArray[i].type = INPUT_KEYBOARD;
    inputArray[i].ki
      ..wVk = 0
      ..wScan = scan
      ..dwFlags = KEYEVENTF_SCANCODE | (e.down ? 0 : KEYEVENTF_KEYUP)
      ..time = 0
      ..dwExtraInfo = 0;

    if (isExtendedKey(e.key)) {
      inputArray[i].ki.dwFlags |= KEYEVENTF_EXTENDEDKEY;
    }
  }

  SendInput(events.length, inputArray, sizeOf<INPUT>());
  calloc.free(inputArray);
}

/// Converts a string key to a scan code.
/// This must match your `keyToScanCode` map elsewhere.
int? getScanCode(String key) => keyToScanCode[key.toLowerCase()];

/// Determines if a key is an extended key on Windows
bool isExtendedKey(String k) => {
  'rctrl',
  'ralt',
  'insert',
  'delete',
  'home',
  'end',
  'pgup',
  'pgdn',
  'right',
  'left',
  'down',
  'up',
  'np_divide',
}.contains(k);

/// Sends a full combo (modifiers + main key) as a sequence of inputs.
Future<void> sendInputComboBatch(Bind bind, {Duration? holdDuration}) async {
  final keysDown = <_KeyEvent>[];
  final keysUp = <_KeyEvent>[];

  // Modifiers first
  for (final mod in bind.modifiers) {
    keysDown.add(_KeyEvent(mod, down: true));
    keysUp.add(_KeyEvent(mod, down: false));
  }

  final mainKeyDown = _KeyEvent(bind.mainkey, down: true);
  final mainKeyUp = _KeyEvent(bind.mainkey, down: false);

  // If hold mode, press + wait + release manually
  if (holdDuration != null) {
    _sendKeyEventsBatch([...keysDown, mainKeyDown]);
    await Future.delayed(holdDuration);
    _sendKeyEventsBatch([mainKeyUp, ...keysUp.reversed]);
    return;
  }

  // Standard tap combo: mod down -> key down -> key up -> mod up
  _sendKeyEventsBatch([
    ...keysDown,
    mainKeyDown,
    mainKeyUp,
    ...keysUp.reversed,
  ]);
}
