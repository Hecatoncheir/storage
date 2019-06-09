import 'package:storage/read_writers.dart';
import 'package:storage/storage.dart';
import 'package:storage/stores.dart';
import 'package:test/test.dart';

class SomeStorageKey implements StorageKey {
  int key;

  SomeStorageKey(this.key);

  SomeStorageKey.fromJson(String source) {
    key = int.parse(source);
  }

  @override
  String toJson() => key.toString();
}

class SomeStorageValue implements StorageValue {
  String value;

  SomeStorageValue(this.value);

  SomeStorageValue.fromJson(this.value);

  @override
  String toJson() => value;
}

void main() {
  group('KVStorage', () {
    InMemory readWriter;
    KVStore<SomeStorageKey, SomeStorageValue> kvStore;

    Entity<Map<SomeStorageKey, SomeStorageValue>> testEntityForWrite;

    setUp(() {
      testEntityForWrite = Entity<Map<SomeStorageKey, SomeStorageValue>>(
          data: {SomeStorageKey(0): SomeStorageValue('value')});

      readWriter = InMemory();
      kvStore = KVStore<SomeStorageKey, SomeStorageValue>(readWriter);
    });

    test('create', () {
      expect(readWriter.read(), isEmpty);

      final id = kvStore.create(testEntityForWrite);

      expect(id, isNotNull);
      expect(id, isNotEmpty);

      expect(readWriter.read(), isNotEmpty);
    });

    test('read', () {
      final id = kvStore.create(testEntityForWrite);

      final entity = kvStore.read(id);
      expect(entity.id, equals(id));
      expect(
          entity.data, equals({SomeStorageKey(0): SomeStorageValue('value')}));
    });

    test('update', () {
      final id = kvStore.create(testEntityForWrite);

      final entity = kvStore.read(id);
      expect(entity.id, equals(id));
      expect(
          entity.data, equals({SomeStorageKey(0): SomeStorageValue('value')}));

      final content = kvStore.readWriter.read();
      expect(content, isNotEmpty);

      final updatedTestEntityForWrite =
          Entity<Map<SomeStorageKey, SomeStorageValue>>(
              data: {SomeStorageKey(0): SomeStorageValue('updated value')});

      final error = kvStore.update(updatedTestEntityForWrite);
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
      final id = kvStore.create(testEntityForWrite);

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
