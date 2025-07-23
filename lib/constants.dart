import 'package:sc_mapper_dart/action_bindings.dart';
import 'package:win32/win32.dart';

/// List of actionmap names to skip (exceptions)
const skipActionmaps = {
  'IFCS_controls', // Unknown controls, probably for the future
  'debug', // Debug actions
  'zero_gravity_traversal', // Zero-G traversal actions, currently not ingame
  'hacking', // Hacking actions, currently not ingame
  'RemoteRigidEntityController', // Unknown, probably for the future
  'character_customizer', // Character editor
  'flycam', // Flycam controls, not used in normal gameplay
  'stopwatch', // Stopwatch actions, probably could use the actionmapUICategories
  'spaceship_auto_weapons', // PDCs?
  'server_renderer', // Server-side rendering actions, not used in normal gameplay
  'vehicle_mobiglas', // Empty in the game settings
};

/// Map of actionmap names to their UICategory, if not specified in XML
const actionmapUICategories = {
  'mining': '@ui_CCFPS',
  'vehicle_mfd': '@ui_CG_MFDs',
  'mapui': '@ui_Map', // This category is made up, used for map actions
  'stopwatch': '@ui_CGStopWatch',
  'ui_textfield': '@uiCGUIGeneral', // Text input fields
};

/// Set of candidate keys for auto-assignment
const candidateKeys = {
  'f1',
  'f2',
  'f3',
  'f4',
  'f5',
  'f6',
  'f7',
  'f8',
  'f9',
  'f10',
  'f11',
  'f12',
  'np_0',
  'np_1',
  'np_2',
  'np_3',
  'np_4',
  'np_5',
  'np_6',
  'np_7',
  'np_8',
  'np_9',
  'np_add',
  'np_subtract',
  'np_multiply',
  'np_divide',
  'np_period',
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '0',
  'insert',
  'delete',
  'home',
  'end',
  'pgup',
  'pgdn',
  'u',
  'i',
  'o',
  'p',
  'j',
  'k',
  'l',
};

/// Set of candidate modifiers for auto-assignment
const candidateModifiers = {
  'lshift',
  'rshift',
  'lctrl',
  'rctrl',
  'lalt',
  'ralt',
};

/// Set of denied combos that should not be assigned to actions
final denyCombos = {
  // Always available combos in Star Citizen
  const Bind(mainkey: 'f1', modifiers: {}),
  const Bind(mainkey: 'f2', modifiers: {}),
  const Bind(mainkey: 'f11', modifiers: {}),
  const Bind(mainkey: 'f12', modifiers: {}),
  // Nivida Overlay Binds
  const Bind(mainkey: 'f4', modifiers: {'lalt'}),
  const Bind(mainkey: 'f9', modifiers: {'lalt'}),
  const Bind(mainkey: 'f10', modifiers: {'lalt', 'lshift'}),
  const Bind(mainkey: 'f1', modifiers: {'lalt'}),
};

const disallowedModifiersPerCategory = {
  '@ui_CCSpaceFlight': {'lshift', 'lctrl', 'rshift'},
  '@ui_CCFPS': {'lctrl', 'lalt', 'lshift'},
};

final Set<Set<String>> categoryGroups = {
  {
    '@ui_CCSpaceFlight',
    '@ui_CGLightControllerDesc',
    '@ui_CCSeatGeneral',
    '@ui_CG_MFDs',
    '@ui_CGUIGeneral',
    '@ui_CGOpticalTracking',
    '@ui_CGInteraction',
  },
  {
    '@ui_CCVehicle',
    '@ui_CGLightControllerDesc',
    '@ui_CG_MFDs',
    '@ui_CGUIGeneral',
    '@ui_CGOpticalTracking',
    '@ui_CGInteraction',
  },
  {
    '@ui_CCTurrets',
    '@ui_CGUIGeneral',
    '@ui_CGOpticalTracking',
    '@ui_CGInteraction',
  },
  {
    '@ui_CCFPS',
    '@ui_CCEVA',
    '@ui_CGUIGeneral',
    '@ui_CGOpticalTracking',
    '@ui_CGInteraction',
  },
  {'@ui_Map', '@ui_CGUIGeneral'},
  {'@ui_CGEASpectator', '@ui_CGUIGeneral'},
  {'@ui_CCCamera', '@ui_CGUIGeneral'},
};

// https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes#scan-codes
const keyToScanCode = {
  // Letter keys (same for lower/uppercase)
  'a': 0x1E, 'b': 0x30, 'c': 0x2E, 'd': 0x20, 'e': 0x12, 'f': 0x21,
  'g': 0x22, 'h': 0x23, 'i': 0x17, 'j': 0x24, 'k': 0x25, 'l': 0x26,
  'm': 0x32, 'n': 0x31, 'o': 0x18, 'p': 0x19, 'q': 0x10, 'r': 0x13,
  's': 0x1F, 't': 0x14, 'u': 0x16, 'v': 0x2F, 'w': 0x11, 'x': 0x2D,
  'y': 0x15, 'z': 0x2C,
  // Number row
  '1': 0x02, '2': 0x03, '3': 0x04, '4': 0x05, '5': 0x06,
  '6': 0x07, '7': 0x08, '8': 0x09, '9': 0x0A, '0': 0x0B,
  // F-keys
  'f1': 0x3B, 'f2': 0x3C, 'f3': 0x3D, 'f4': 0x3E, 'f5': 0x3F, 'f6': 0x40,
  'f7': 0x41, 'f8': 0x42, 'f9': 0x43, 'f10': 0x44, 'f11': 0x57, 'f12': 0x58,
  'f13': 0x64,
  'f14': 0x65,
  'f15': 0x66,
  'f16': 0x67,
  'f17': 0x68,
  'f18': 0x69,
  'f19': 0x6A,
  'f20': 0x6B,
  'f21': 0x6C,
  'f22': 0x6D,
  'f23': 0x6E,
  'f24': 0x76,
  // Modifiers
  'lshift': 0x2A,
  'rshift': 0x36,
  'lctrl': 0x1D,
  'rctrl': 0x1D, // rctrl with extended
  'lalt': 0x38, 'ralt': 0x38, // ralt with extended
  // Misc
  'space': 0x39, 'tab': 0x0F, 'enter': 0x1C,
  'escape': 0x01,
  'backspace': 0x0E,
  'up': 0x48, 'down': 0x50, 'left': 0x4B, 'right': 0x4D,
  'pgup': 0x49, 'pgdn': 0x51, 'home': 0x47, 'end': 0x4F,
  'insert': 0x52, 'delete': 0x53,
  // Brackets and common symbols
  '[': 0x1A, ']': 0x1B, 'comma': 0x33,
  // Numpad
  'np_0': 0x52, 'np_1': 0x4F, 'np_2': 0x50, 'np_3': 0x51, 'np_4': 0x4B,
  'np_5': 0x4C, 'np_6': 0x4D, 'np_7': 0x47, 'np_8': 0x48, 'np_9': 0x49,
  'np_add': 0x4E,
  'np_subtract': 0x4A,
  'np_multiply': 0x37,
  'np_divide': 0x35,
  'np_period': 0x53,
};

const mouseActionMap = {
  'mouse1': {'down': MOUSEEVENTF_LEFTDOWN, 'up': MOUSEEVENTF_LEFTUP},
  'mouse2': {'down': MOUSEEVENTF_RIGHTDOWN, 'up': MOUSEEVENTF_RIGHTUP},
  'mouse3': {'down': MOUSEEVENTF_MIDDLEDOWN, 'up': MOUSEEVENTF_MIDDLEUP},
  'mwheel_up': {'wheel': 120}, // 120 is default wheel delta
  'mwheel_down': {'wheel': -120},
};
