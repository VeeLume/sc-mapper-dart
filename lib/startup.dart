import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:sc_mapper_dart/app_state.dart';
import 'package:sc_mapper_dart/on_message.dart';
import 'package:sc_mapper_dart/utils.dart';
import 'package:web_socket_channel/io.dart';

Future<void> runPlugin({
  required List<String> args,
  required IOWebSocketChannel Function(String url) connect,
  required Directory Function() getResourceDir,
}) async {
  final port = args[args.indexOf('-port') + 1];
  final pluginUUID = args[args.indexOf('-pluginUUID') + 1];
  final registerEvent = args[args.indexOf('-registerEvent') + 1];

  final url = 'ws://127.0.0.1:$port';
  final channel = connect(url);
  await channel.ready;
  channel.sink.add(jsonEncode({'event': registerEvent, 'uuid': pluginUUID}));

  try {
    final resourceDir = getResourceDir();
    GetIt.I.registerSingletonAsync<AppState>(() async {
      final appState = AppState(resourceDir: resourceDir, channel: channel);
      await appState.initialize();
      return appState;
    });
  } catch (e) {
    await log(channel, 'Error initializing AppState: $e');
    await channel.sink.close();
    exit(1);
  }

  await GetIt.I.allReady();
  await log(channel, 'Plugin started and connected to $url');
  initializeActionHandlers(channel);
  await log(channel, '${actionHandlers.keys.join(', ')} registered');

  runZonedGuarded(
    () async {
      await listenForMessages(channel);
    },
    (error, stackTrace) async {
      await log(channel, 'Error in main zone: $error\n$stackTrace');
      await channel.sink.close();
      exit(1);
    },
  );
}

Future<void> listenForMessages(IOWebSocketChannel channel) async {
  await for (final message in channel.stream) {
    try {
      await onMessage(channel, message);
    } catch (e) {
      await log(channel, 'Error processing message: $e');
    }
  }
}
