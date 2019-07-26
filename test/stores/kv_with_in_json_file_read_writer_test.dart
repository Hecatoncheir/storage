import 'dart:convert';
import 'dart:io';

import 'package:storage/read_writers.dart';
import 'package:storage/storage.dart';
import 'package:storage/stores.dart';
import 'package:test/test.dart';

void main() {
  group('KVStorage', () {
    test('can prepare cache from readwriter content', () {
      InFile readWriter;
      KVStore<int, String> kvStore;

      final file = File('test/stores/kv_with_in_file_read_writer.json')
        ..createSync();

      readWriter = InJSONFile(file)
        ..write(json.encode({
          '0': {'0': 'value'}
        }).codeUnits);

      kvStore = KVStore<int, String>(readWriter,
          keyToJson: (key) => key.toString(),
          keyFromJson: int.parse,
          valueToJson: (value) => value,
          valueFromJson: (value) => value);

      final entity = kvStore.read('0');
      expect(entity.data.keys.first, equals(0));
      expect(entity.data.values.first, equals('value'));

      file.deleteSync();
    });
  });

  group('KVStorage', () {
    InJSONFile readWriter;
    KVStore<int, String> kvStore;

    File file;

    setUp(() {
      file = File('test/stores/kv_with_in_file_read_writer.json')..createSync();
      readWriter = InJSONFile(file);
      kvStore = KVStore<int, String>(readWriter,
          keyToJson: (key) => key.toString(),
          keyFromJson: int.parse,
          valueToJson: (value) => value,
          valueFromJson: (value) => value);
    });

    tearDown(() => file.deleteSync());

    test('create', () {
      expect(readWriter.read(), equals('{}'.codeUnits));

      final testEntity = Entity<Map<int, String>>(data: {0: 'value'});
      final id = kvStore.create(testEntity);

      expect(id, isNotNull);
      expect(id, isNotEmpty);

      print(String.fromCharCodes(readWriter.read()));
      expect(readWriter.read(), isNotEmpty);
    });

    test('read', () {
      final testEntity = Entity<Map<int, String>>(data: {0: 'value'});
      final id = kvStore.create(testEntity);

      final entity = kvStore.read(id);
      expect(entity.id, equals(id));
      expect(entity.data, equals({0: 'value'}));
    });

    test('update', () {
      final testEntity = Entity<Map<int, String>>(data: {0: 'value'});
      final id = kvStore.create(testEntity);

      final entity = kvStore.read(id);
      expect(entity.id, equals(id));
      expect(entity.data, equals({0: 'value'}));

      final content = kvStore.readWriter.read();
      expect(content, isNotEmpty);

      final error = kvStore.update(Entity(id: id, data: {0: 'updated value'}));
      expect(error, isNull);

      final updatedEntity = kvStore.read(id);
      expect(updatedEntity.id, equals(id));
      expect(updatedEntity.data, equals({0: 'updated value'}));

      final updatedContent = kvStore.readWriter.read();
      expect(content != updatedContent, isTrue);
    });

    test('update with error', () {
      expect(kvStore.update(Entity(id: null)),
          equals(StoreUpdateError.cannotBeUpdate));
    });

    test('delete with error ', () {
      final testEntity = Entity<Map<int, String>>(data: {0: 'value'});
      final id = kvStore.create(testEntity);

      final entity = kvStore.read(id);
      expect(entity.id, equals(id));
      expect(entity.data, equals({0: 'value'}));

      final content = kvStore.readWriter.read();
      expect(content, isNotEmpty);

      final error = kvStore.delete(id);
      expect(error, isNull);

      final updatedContent = kvStore.readWriter.read();
      expect(content != updatedContent, isTrue);
      expect(String.fromCharCodes(updatedContent), equals('{}\n'));
    });

    test('delete with error ', () {
      expect(kvStore.delete(null), equals(StoreDeleteError.cannotBeDelete));
    });
  });
}
