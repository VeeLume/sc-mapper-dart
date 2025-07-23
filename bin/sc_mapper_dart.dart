import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:sc_mapper_dart/logger.dart';
import 'package:sc_mapper_dart/startup.dart';
import 'package:sc_mapper_dart/utils.dart';
import 'package:web_socket_channel/io.dart';

Future<void> main(List<String> args) async {
  final appDir = await ensureAppDir();
  final logFile = p.join(appDir.path, 'sc_mapper_dart.log');
  GetIt.I.registerSingleton<FileLogger>(FileLogger(logFile, alsoPrint: true));

  await runPlugin(
    args: args,
    connect: (url) => IOWebSocketChannel.connect(url),
    getResourceDir: getResourceDir,
  );
}
