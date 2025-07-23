import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:xml/xml.dart';

abstract class ActivationModeBase {
  String? get name;
  bool get onPress;
  bool get onHold;
  bool get onRelease;
  int get multiTap;
  bool get multiTapBlock;
  double get pressTriggerThreshold;
  double get releaseTriggerThreshold;
  double get releaseTriggerDelay;
  bool get retriggerable;
  double get holdTriggerDelay;
  double get holdRepeatDelay;
}

class ActivationMode implements ActivationModeBase {
  @override
  final String? name;
  @override
  final bool onPress;
  @override
  final bool onHold;
  @override
  final bool onRelease;
  @override
  final int multiTap;
  @override
  final bool multiTapBlock;
  @override
  final double pressTriggerThreshold;
  @override
  final double releaseTriggerThreshold;
  @override
  final double releaseTriggerDelay;
  @override
  final bool retriggerable;
  @override
  final double holdTriggerDelay;
  @override
  final double holdRepeatDelay;

  ActivationMode({
    this.name,
    required this.onPress,
    required this.onHold,
    required this.onRelease,
    required this.multiTap,
    required this.multiTapBlock,
    required this.pressTriggerThreshold,
    required this.releaseTriggerThreshold,
    required this.releaseTriggerDelay,
    required this.retriggerable,
    required this.holdTriggerDelay,
    required this.holdRepeatDelay,
  });

  static bool hasValidAttributes(XmlElement node) {
    // Return true if the node has at least one of the activation attributes
    return node.getAttribute('onPress').isNotNull ||
        node.getAttribute('onHold').isNotNull ||
        node.getAttribute('onRelease').isNotNull ||
        node.getAttribute('multiTap').isNotNull ||
        node.getAttribute('multiTapBlock').isNotNull ||
        node.getAttribute('pressTriggerThreshold').isNotNull ||
        node.getAttribute('releaseTriggerThreshold').isNotNull ||
        node.getAttribute('releaseTriggerDelay').isNotNull ||
        node.getAttribute('retriggerable').isNotNull ||
        node.getAttribute('holdTriggerDelay').isNotNull ||
        node.getAttribute('holdRepeatDelay').isNotNull;
  }

  factory ActivationMode.fromXml(XmlElement node, bool includeName) {
    return ActivationMode(
      name: includeName ? node.getAttribute('name') : null,
      onPress: node.getAttribute('onPress') == '1',
      onHold: node.getAttribute('onHold') == '1',
      onRelease: node.getAttribute('onRelease') == '1',
      multiTap: int.tryParse(node.getAttribute('multiTap') ?? '1') ?? 1,
      multiTapBlock: node.getAttribute('multiTapBlock') == '1',
      pressTriggerThreshold:
          double.tryParse(node.getAttribute('pressTriggerThreshold') ?? '-1') ??
          -1,
      releaseTriggerThreshold:
          double.tryParse(
            node.getAttribute('releaseTriggerThreshold') ?? '-1',
          ) ??
          -1,
      releaseTriggerDelay:
          double.tryParse(node.getAttribute('releaseTriggerDelay') ?? '0') ?? 0,
      retriggerable: node.getAttribute('retriggerable') == '1',
      holdTriggerDelay:
          double.tryParse(node.getAttribute('holdTriggerDelay') ?? '-1') ?? -1,
      holdRepeatDelay:
          double.tryParse(node.getAttribute('holdRepeatDelay') ?? '-1') ?? -1,
    );
  }

  factory ActivationMode.fromJson(Map<String, dynamic> json) {
    return ActivationMode(
      name: json.tryGetString('name'),
      onPress: json.getBool('onPress', defaultValue: false),
      onHold: json.getBool('onHold', defaultValue: false),
      onRelease: json.getBool('onRelease', defaultValue: false),
      multiTap: json.getInt('multiTap', defaultValue: 1),
      multiTapBlock: json.getBool('multiTapBlock', defaultValue: false),
      pressTriggerThreshold: json.getDouble(
        'pressTriggerThreshold',
        defaultValue: -1,
      ),
      releaseTriggerThreshold: json.getDouble(
        'releaseTriggerThreshold',
        defaultValue: -1,
      ),
      releaseTriggerDelay: json.getDouble(
        'releaseTriggerDelay',
        defaultValue: 0,
      ),
      retriggerable: json.getBool('retriggerable', defaultValue: false),
      holdTriggerDelay: json.getDouble('holdTriggerDelay', defaultValue: -1),
      holdRepeatDelay: json.getDouble('holdRepeatDelay', defaultValue: -1),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'onPress': onPress,
      'onHold': onHold,
      'onRelease': onRelease,
      'multiTap': multiTap,
      'multiTapBlock': multiTapBlock,
      'pressTriggerThreshold': pressTriggerThreshold,
      'releaseTriggerThreshold': releaseTriggerThreshold,
      'releaseTriggerDelay': releaseTriggerDelay,
      'retriggerable': retriggerable,
      'holdTriggerDelay': holdTriggerDelay,
      'holdRepeatDelay': holdRepeatDelay,
    };
  }
}
