import 'package:storage/read_writers.dart';
import 'package:storage/read_writers/read_writer.dart';
import 'package:test/test.dart';

void main() {
  group('InMemory ReadWriter', () {
    InMemory inMemory;

    setUp(() {
      inMemory = InMemory();
    });

    test('read', () {
      expect(inMemory.read(), isEmpty);
      expect(inMemory.write('test'.codeUnits), isNull);
      expect(inMemory.read(), equals('test\n'.codeUnits));
    });

    test('write', () {
      expect(inMemory.write('test'.codeUnits), isNull);
    });

    test('write with error', () {
      expect(
          inMemory.write(''.codeUnits), equals(ReadWriterError.cannotBeWrite));
    });

    test('reWrite', () {
      expect(inMemory.write('test'.codeUnits), isNull);
      expect(inMemory.read(), equals('test\n'.codeUnits));
      expect(inMemory.reWrite('second test'.codeUnits), isNull);
      expect(inMemory.read(), equals('second test\n'.codeUnits));
    });

    test('reWrite with error', () {
      expect(inMemory.reWrite(''.codeUnits),
          equals(ReadWriterError.cannotBeWrite));
    });

    test('write line', () {
      expect(inMemory.writeLine('first line'.codeUnits), isNull);
      expect(inMemory.writeLine('second line'.codeUnits), isNull);
      expect(String.fromCharCodes(inMemory.read()),
          equals('''first line\nsecond line\n'''));
    });

    test('write line with error', () {
      expect(inMemory.writeLine(''.codeUnits),
          equals(ReadWriterError.cannotBeWrite));
    });
  });
}
