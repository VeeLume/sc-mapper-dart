import 'dart:convert';

import 'package:sc_mapper_dart/action_handlers/data_source.dart';
import 'package:web_socket_channel/io.dart';

class KeyCoordinates {
  final int column;
  final int row;

  KeyCoordinates(this.column, this.row);
}

abstract class ActionHandler {
  static String get action => 'icu.veelume.sc-mapper';
  final IOWebSocketChannel channel;

  ActionHandler(this.channel);

  Future<void> onMessage(
    IOWebSocketChannel channel,
    Map<String, dynamic> msg,
  ) async {
    final event = msg['event'] as String;
    final context = msg['context'] as String;
    final payload = msg['payload'] as Map<String, dynamic>?;

    switch (event) {
      case 'dialDown':
        final device = msg['device'] as String;
        final coordinates = KeyCoordinates(
          payload!['coordinates']['column'] as int,
          payload['coordinates']['row'] as int,
        );
        final settings = payload['settings'] as Map<String, dynamic>;
        await onDialDown(context, device, coordinates, settings);
      case 'dialRotate':
        final device = msg['device'] as String;
        final coordinates = KeyCoordinates(
          payload!['coordinates']['column'] as int,
          payload['coordinates']['row'] as int,
        );
        final pressed = payload['pressed'] as bool;
        final settings = payload['settings'] as Map<String, dynamic>;
        final ticks = payload['ticks'] as int;
        await onDialRotate(
          context,
          device,
          coordinates,
          pressed,
          settings,
          ticks,
        );
      case 'dialUp':
        final device = msg['device'] as String;
        final coordinates = KeyCoordinates(
          payload!['coordinates']['column'] as int,
          payload['coordinates']['row'] as int,
        );
        final settings = payload['settings'] as Map<String, dynamic>;
        await onDialUp(context, device, coordinates, settings);
      case 'sendToPlugin':
        final payloadEvent = payload?['event'] as String?;
        final isRefresh = payload?['isRefresh'] as bool?;
        await onDidReceivePropertyInspectorMessage(
          context,
          payloadEvent!,
          isRefresh,
        );
      case 'didReceiveSettings':
        final device = msg['device'] as String;
        final controller = payload!['controller'] as String;
        final isInMultiAction = payload['isInMultiAction'] as bool;
        final coordinates = payload['coordinates'] != null
            ? KeyCoordinates(
                payload['coordinates']['column'] as int,
                payload['coordinates']['row'] as int,
              )
            : null;
        final settings = payload['settings'] as Map<String, dynamic>;
        final state = payload['state'] as int?;
        await onDidReceiveSettings(
          context,
          device,
          controller,
          isInMultiAction,
          coordinates,
          settings,
          state,
        );
      case 'keyDown':
        final device = msg['device'] as String;
        final isInMultiAction = payload!['isInMultiAction'] as bool;
        final coordinates = payload['coordinates'] != null
            ? KeyCoordinates(
                payload['coordinates']['column'] as int,
                payload['coordinates']['row'] as int,
              )
            : null;
        final settings = payload['settings'] as Map<String, dynamic>;
        final state = payload['state'] as int?;
        final userDesiredState = payload['userDesiredState'] as int?;
        await onKeyDown(
          context,
          device,
          isInMultiAction,
          coordinates,
          settings,
          state,
          userDesiredState,
        );
      case 'keyUp':
        final device = msg['device'] as String;
        final isInMultiAction = payload!['isInMultiAction'] as bool;
        final coordinates = payload['coordinates'] != null
            ? KeyCoordinates(
                payload['coordinates']['column'] as int,
                payload['coordinates']['row'] as int,
              )
            : null;
        final settings = payload['settings'] as Map<String, dynamic>;
        final state = payload['state'] as int?;
        await onKeyUp(
          context,
          device,
          isInMultiAction,
          coordinates,
          settings,
          state,
        );
      case 'propertyInspectorDidAppear':
        final device = msg['device'] as String;
        await onPropertyInspectorDidAppear(context, device);
      case 'propertyInspectorDidDisappear':
        final device = msg['device'] as String;
        await onPropertyInspectorDidDisappear(context, device);
      case 'titleParametersDidChange':
        final device = msg['device'] as String;
        final controller = payload!['controller'] as String;
        final coordinates = KeyCoordinates(
          payload['coordinates']['column'] as int,
          payload['coordinates']['row'] as int,
        );
        final settings = payload['settings'] as Map<String, dynamic>;
        final state = payload['state'] as int?;
        final title = payload['title'] as String;
        final titleParameters =
            payload['titleParameters'] as Map<String, dynamic>;
        final fontFamily = titleParameters['fontFamily'] as String;
        final fontSize = titleParameters['fontSize'] as int;
        final fontStyle = titleParameters['fontStyle'] as String;
        final fontUnderline = titleParameters['fontUnderline'] as bool;
        final showTitle = titleParameters['showTitle'] as bool;
        final titleAlignment = titleParameters['titleAlignment'] as String;
        final titleColor = titleParameters['titleColor'] as String;
        await onTitleParametersDidChange(
          context,
          device,
          controller,
          coordinates,
          settings,
          state,
          title,
          fontFamily,
          fontSize,
          fontStyle,
          fontUnderline,
          showTitle,
          titleAlignment,
          titleColor,
        );
      case 'touchTab':
        final device = msg['device'] as String;
        final coordinates = KeyCoordinates(
          payload!['coordinates']['column'] as int,
          payload['coordinates']['row'] as int,
        );
        final hold = payload['hold'] as bool;
        final settings = payload['settings'] as Map<String, dynamic>;
        final tabPos = payload['tabPos'] as List<dynamic>;
        final tabCoordinates = (tabPos[0] as int, tabPos[1] as int);
        await onTouchTab(
          context,
          device,
          coordinates,
          hold,
          settings,
          tabCoordinates,
        );
      case 'willAppear':
        final device = msg['device'] as String;
        final controller = payload!['controller'] as String;
        final isInMultiAction = payload['isInMultiAction'] as bool;
        final coordinates = payload['coordinates'] != null
            ? KeyCoordinates(
                payload['coordinates']['column'] as int,
                payload['coordinates']['row'] as int,
              )
            : null;
        final settings = payload['settings'] as Map<String, dynamic>;
        final state = payload['state'] as int?;
        await onWillAppear(
          context,
          device,
          controller,
          isInMultiAction,
          coordinates,
          settings,
          state,
        );
      case 'willDisappear':
        final device = msg['device'] as String;
        final controller = payload!['controller'] as String;
        final isInMultiAction = payload['isInMultiAction'] as bool;
        final coordinates = payload['coordinates'] != null
            ? KeyCoordinates(
                payload['coordinates']['column'] as int,
                payload['coordinates']['row'] as int,
              )
            : null;
        final settings = payload['settings'] as Map<String, dynamic>;
        final state = payload['state'] as int?;
        await onWillDisappear(
          context,
          device,
          controller,
          isInMultiAction,
          coordinates,
          settings,
          state,
        );
    }
  }

  Future<void> onDialDown(
    String context,
    String device,
    KeyCoordinates coordinates,
    Map<String, dynamic> settings,
  ) async {}
  Future<void> onDialRotate(
    String context,
    String device,
    KeyCoordinates coordinates,
    bool pressed,
    Map<String, dynamic> settings,
    int ticks,
  ) async {}
  Future<void> onDialUp(
    String context,
    String device,
    KeyCoordinates coordinates,
    Map<String, dynamic> settings,
  ) async {}
  Future<void> onDidReceivePropertyInspectorMessage(
    String context,
    String event,
    bool? isRefresh,
  ) async {}
  Future<void> onDidReceiveSettings(
    String context,
    String device,
    String controller,
    bool isInMultiAction,
    KeyCoordinates? coordinates,
    Map<String, dynamic> settings,
    int? state,
  ) async {}
  Future<void> onKeyDown(
    String context,
    String device,
    bool isInMultiAction,
    KeyCoordinates? coordinates,
    Map<String, dynamic> settings,
    int? state,
    int? userDesiredState,
  ) async {}
  Future<void> onKeyUp(
    String context,
    String device,
    bool isInMultiAction,
    KeyCoordinates? coordinates,
    Map<String, dynamic> settings,
    int? state,
  ) async {}
  Future<void> onPropertyInspectorDidAppear(
    String context,
    String device,
  ) async {}
  Future<void> onPropertyInspectorDidDisappear(
    String context,
    String device,
  ) async {}
  Future<void> onTitleParametersDidChange(
    String context,
    String device,
    String controller,
    KeyCoordinates coordinates,
    Map<String, dynamic> settings,
    int? state,
    String title,
    String fontFamily,
    int fontSize,
    String fontStyle,
    bool fontUnderline,
    bool showTitle,
    String titleAlignment,
    String titleColor,
  ) async {}
  Future<void> onTouchTab(
    String context,
    String device,
    KeyCoordinates coordinates,
    bool hold,
    Map<String, dynamic> settings,
    (int, int) tabPos,
  ) async {}
  Future<void> onWillAppear(
    String context,
    String device,
    String controller,
    bool isInMultiAction,
    KeyCoordinates? coordinates,
    Map<String, dynamic> settings,
    int? state,
  ) async {}
  Future<void> onWillDisappear(
    String context,
    String device,
    String controller,
    bool isInMultiAction,
    KeyCoordinates? coordinates,
    Map<String, dynamic> settings,
    int? state,
  ) async {}
  void getSettings(String context) {
    channel.sink.add(jsonEncode({'event': 'getSettings', 'context': context}));
  }

  void sendToPropertyInspector(String context, DataSourcePayload payload) {
    channel.sink.add(
      jsonEncode({
        'event': 'sendToPropertyInspector',
        'context': context,
        'payload': payload.toJson(),
      }),
    );
  }

  void setFeedback(String context, Map<String, dynamic> payload) {
    channel.sink.add(
      jsonEncode({
        'event': 'setFeedback',
        'context': context,
        'layout': payload,
      }),
    );
  }

  void setFeedbackLayout(String context, String layout) {
    channel.sink.add(
      jsonEncode({
        'event': 'setFeedbackLayout',
        'context': context,
        'layout': layout,
      }),
    );
  }

  void setImage(String context, String? image, int? state, String? target) {
    channel.sink.add(
      jsonEncode({
        'event': 'setImage',
        'context': context,
        'payload': {'image': image, 'state': state, 'target': target},
      }),
    );
  }

  void setSettings(String context, Map<String, dynamic> settings) {
    channel.sink.add(
      jsonEncode({
        'event': 'setSettings',
        'context': context,
        'payload': settings,
      }),
    );
  }

  void setState(String context, int state) {
    channel.sink.add(
      jsonEncode({
        'event': 'setState',
        'context': context,
        'payload': {'state': state},
      }),
    );
  }

  void setTitle(String context, int? state, String? target, String? title) {
    channel.sink.add(
      jsonEncode({
        'event': 'setTitle',
        'context': context,
        'payload': {'state': state, 'target': target, 'title': title},
      }),
    );
  }

  void setTriggerDescription(
    String context,
    String? longTouch,
    String? push,
    String? rotate,
    String? touch,
  ) {
    channel.sink.add(
      jsonEncode({
        'event': 'setTriggerDescription',
        'context': context,
        'payload': {
          'longTouch': longTouch,
          'push': push,
          'rotate': rotate,
          'touch': touch,
        },
      }),
    );
  }

  void showAlert(String context) {
    channel.sink.add(jsonEncode({'event': 'showAlert', 'context': context}));
  }

  void showOk(String context) {
    channel.sink.add(jsonEncode({'event': 'showOk', 'context': context}));
  }
}
