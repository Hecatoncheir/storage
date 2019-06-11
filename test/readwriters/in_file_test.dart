import 'dart:io';

import 'package:storage/read_writers.dart';
import 'package:test/test.dart';

void main() {
  group('InFile ReadWriter', () {
    File file;
    InFile inFile;

    setUp(() {
      file = File('test/readwriters/in_file.txt')..createSync();
      inFile = InFile(file);
    });

    tearDown(() => file.deleteSync());

    test('read', () {
      expect(inFile.read(), isEmpty);
      expect(inFile.write('test'.codeUnits), isNull);
      expect(inFile.read(), equals('test\n'.codeUnits));
    });

    test('write', () {
      expect(inFile.write('test'.codeUnits), isNull);
    });

    test('write with error', () {
      expect(inFile.write(''.codeUnits), equals(ReadWriterError.cannotBeWrite));
    });

    test('reWrite', () {
      expect(inFile.write('test'.codeUnits), isNull);
      expect(inFile.read(), equals('test\n'.codeUnits));
      expect(inFile.reWrite('second test'.codeUnits), isNull);
      expect(inFile.read(), equals('second test\n'.codeUnits));
    });

    test('reWrite with error', () {
      expect(
          inFile.reWrite(''.codeUnits), equals(ReadWriterError.cannotBeWrite));
    });

    test('write line', () {
      expect(inFile.writeLine('first line'.codeUnits), isNull);
      expect(inFile.writeLine('second line'.codeUnits), isNull);
      expect(String.fromCharCodes(inFile.read()),
          equals('''first line\nsecond line\n'''));
    });

    test('write line with error', () {
      expect(inFile.writeLine(''.codeUnits),
          equals(ReadWriterError.cannotBeWrite));
    });
  });
}
