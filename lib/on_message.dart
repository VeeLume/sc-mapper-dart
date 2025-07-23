import 'dart:convert';

import 'package:sc_mapper_dart/action_handlers/action.dart';
import 'package:sc_mapper_dart/action_handlers/generate_binds.dart';
import 'package:sc_mapper_dart/action_handlers/generic.dart';
import 'package:sc_mapper_dart/utils.dart';
import 'package:web_socket_channel/io.dart';

// Used for general events that are not directly related to actions
const Map<
  String,
  Future<void> Function(IOWebSocketChannel, Map<String, dynamic>)
>
eventHandlers = {};

final Map<String, ActionHandler Function(IOWebSocketChannel)>
actionHandlerFactories = {
  GenerateBindsKey.action: (channel) => GenerateBindsKey(channel),
  ActionKey.action: (channel) => ActionKey(channel),
};

// Used for all events that are connected to actions
final Map<String, ActionHandler> actionHandlers = {};

void initializeActionHandlers(IOWebSocketChannel channel) {
  for (final entry in actionHandlerFactories.entries) {
    actionHandlers[entry.key] = entry.value(channel);
  }
}

Future<void> onMessage(IOWebSocketChannel channel, dynamic message) async {
  final msg = jsonDecode(message as String);

  final action = msg['action'] as String?;
  final event = msg['event'] as String?;

  await log(channel, '📥 Received message: $msg');

  if (action != null) {
    await actionHandlers[action]?.onMessage(channel, msg);
  } else if (event != null) {
    await eventHandlers[event]?.call(channel, msg);
  }
}
