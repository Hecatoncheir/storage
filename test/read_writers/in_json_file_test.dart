import 'dart:convert';
import 'dart:io';

import 'package:storage/read_writers.dart';
import 'package:test/test.dart';

void main() {
  group('InJSONFile ReadWriter', () {
    File file;
    InJSONFile inFile;

    setUp(() {
      file = File('test/read_writers/in_json_file.json')..createSync();
      inFile = InJSONFile(file);
    });

    tearDown(() => file.deleteSync());

    test('read', () {
      expect(inFile.read(), equals('[]'.codeUnits));
      expect(inFile.write(json.encode({'test key': 'test value'}).codeUnits),
          isNull);
      expect(
          json.decode(String.fromCharCodes(inFile.read())),
          equals([
            {'test key': 'test value'}
          ]));
    });

    test('write', () {
      expect(inFile.write(json.encode({'key': 'value'}).codeUnits), isNull);
    });

    test('write with error', () {
      expect(inFile.write(''.codeUnits), equals(ReadWriterError.cannotBeWrite));
    });

    test('reWrite', () {
      final testMap = {'key': 'value'};
      expect(inFile.write(json.encode(testMap).codeUnits), isNull);
      expect(inFile.read(), equals(json.encode([testMap]).codeUnits));

      final List<Map> secondTestMap = [
        {'second key': 'second value'}
      ];

      expect(inFile.reWrite(json.encode(secondTestMap).codeUnits), isNull);
      expect(inFile.read(), equals(json.encode(secondTestMap).codeUnits));
    });

    test('reWrite with error', () {
      expect(
          inFile.reWrite(''.codeUnits), equals(ReadWriterError.cannotBeWrite));
    });

    test('write line', () {
      expect(
          inFile.writeLine(
              json.encode({'first line key': 'first line value'}).codeUnits),
          isNull);

      expect(
          inFile.writeLine(
              json.encode({'second line key': 'second line value'}).codeUnits),
          isNull);

      expect(
          inFile.read(),
          equals(json.encode([
            {'first line key': 'first line value'},
            {'second line key': 'second line value'}
          ]).codeUnits));
    });

    test('write line with error', () {
      expect(inFile.writeLine(''.codeUnits),
          equals(ReadWriterError.cannotBeWrite));
    });
  });
}
