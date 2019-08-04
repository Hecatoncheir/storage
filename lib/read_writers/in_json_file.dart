import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:storage/read_writers.dart';

class InJSONFile implements InFile {
  @override
  File file;

  List<Map> _memories;

  @override
  String memories;

  /// Constructor.
  InJSONFile(this.file, {this.memories}) {
    final extension = path.extension(file.path);
    if (extension != '.json') throw ArgumentError('Only json format support');

    memories ??= file.readAsStringSync();

    if (memories.isEmpty) {
      _memories = [];
      memories = '[]';
    } else {
      _memories = json.decode(memories);
    }
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
    ReadWriterError status;

    if (bytes.isEmpty) {
      status = ReadWriterError.cannotBeWrite;
    } else {
      try {
        _memories.clear();
        for (Map map in json.decode(String.fromCharCodes(bytes))) {
          _memories.add(map);
        }

        memories = json.encode(_memories);
      } on Exception catch (err) {
        return status = ReadWriterError.cannotBeWrite;
      }
    }

    file.writeAsStringSync(memories, flush: true);

    return status;
  }

  @override
  ReadWriterError writeLine(List<int> bytes) {
    ReadWriterError status;

    if (bytes.isEmpty) {
      status = ReadWriterError.cannotBeWrite;
    } else {
      final map = json.decode(String.fromCharCodes(bytes));
      _memories.add(map);

      memories = json.encode(_memories);
    }

    file.writeAsStringSync(memories);

    return status;
  }

  @override
  List<int> read() => memories.codeUnits;
}
