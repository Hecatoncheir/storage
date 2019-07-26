import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:storage/read_writers.dart';

class InJSONFile extends InFile {
  @override
  File file;

  @override
  String memories;

  /// Constructor.
  InJSONFile(this.file, {this.memories}) : super(file, memories: memories) {
    final extension = path.extension(file.path);
    if (extension != '.json') throw ArgumentError('Only json format support');

    memories ??= file.readAsStringSync();
    memories.isEmpty ? memories = '[]' : null;
  }

  @override
  ReadWriterError write(List<int> bytes) {
    // TODO: implement write
    return super.write(bytes);
  }
}
