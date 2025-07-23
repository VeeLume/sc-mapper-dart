import 'dart:async';
import 'dart:io';

class FileLogger {
  final File file;
  IOSink? _sink;
  final bool alsoPrint;
  bool _isInitialized = false;

  FileLogger(String path, {this.alsoPrint = true}) : file = File(path);

  Future<void> _init() async {
    if (_isInitialized) return;
    // Open the file in append mode
    _sink = file.openWrite(mode: FileMode.append);
    _isInitialized = true;
  }

  Future<void> log(String message) async {
    await _init();
    final timestamp = DateTime.now().toIso8601String();
    final logMsg = '[$timestamp] $message';
    _sink?.writeln(logMsg);
    if (alsoPrint) print(logMsg);
  }

  Future<void> close() async {
    await _sink?.flush();
    await _sink?.close();
    _isInitialized = false;
  }
}
