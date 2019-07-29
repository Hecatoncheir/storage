import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:storage/read_writers.dart';

class InJSONFile extends InFile {
  @override
  File file;

  List<Map> _memories;

  @override
  String memories;

  /// Constructor.
  InJSONFile(this.file, {this.memories}) : super(file, memories: memories) {
    final extension = path.extension(file.path);
    if (extension != '.json') throw ArgumentError('Only json format support');

    _memories = [];
    memories ??= file.readAsStringSync();
    memories.isEmpty ? memories = '[]' : null;
  }

  @override
  ReadWriterError write(List<int> bytes) {
    ReadWriterError status;

    if (bytes.isEmpty) {
      status = ReadWriterError.cannotBeWrite;
    } else {
      _memories.add(json.decode(String.fromCharCodes(bytes)));
      memories = json.encode(_memories);
    }

    file.writeAsStringSync(memories);

    return status;
  }

  @override
  ReadWriterError reWrite(List<int> bytes) {
    // TODO: implement reWrite
    return super.reWrite(bytes);
  }
}
