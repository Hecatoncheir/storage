import 'dart:io';

import 'package:storage/read_writers.dart';
import 'package:storage/read_writers/read_writer.dart';

class InFile implements ReadWriter {
  File file;
  String memories;

  InFile(this.file, {this.memories}) {
    memories ??= file.readAsStringSync();
    memories ??= '';
  }

  @override
  List<int> read() => memories.codeUnits;

  @override
  ReadWriterError reWrite(List<int> bytes) {
    ReadWriterError status;

    if (bytes.isEmpty) {
      status = ReadWriterError.cannotBeWrite;
    } else {
      if (bytes.last != 10) {
        final List<int> updatedBytes = List.from(bytes)..add(10);
        memories = String.fromCharCodes(updatedBytes);
      } else {
        memories = String.fromCharCodes(bytes);
      }
    }

    file.writeAsStringSync(memories, flush: true);

    return status;
  }

  @override
  ReadWriterError write(List<int> bytes) {
    ReadWriterError status;

    if (bytes.isEmpty) {
      status = ReadWriterError.cannotBeWrite;
    } else {
      final List<int> updatedMemories = List.from(memories.codeUnits)
        ..addAll(bytes)
        ..add(10);

      memories = String.fromCharCodes(updatedMemories);
    }

    file.writeAsStringSync(memories);

    return status;
  }

  @override
  ReadWriterError writeLine(List<int> bytes) {
    ReadWriterError status;

    if (bytes.isEmpty) {
      status = ReadWriterError.cannotBeWrite;
    } else {
      final List<int> updatedMemories = List.from(memories.codeUnits)
        ..addAll(bytes)
        ..add(10);

      memories = String.fromCharCodes(updatedMemories);
    }

    file.writeAsStringSync(memories);

    return status;
  }
}
