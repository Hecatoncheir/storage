import 'package:storage/read_writers.dart';
import 'package:storage/storage.dart';
import 'package:storage/stores.dart';
import 'package:test/test.dart';

void main() {
  group('KVStorage', () {
    InMemory readWriter;
    KVStore<int, String> kvStore;

    setUp(() {
      readWriter = InMemory();
      kvStore = KVStore<int, String>(readWriter);
    });

    test('create', () {
      expect(readWriter.read(), isEmpty);

      final testEntity = Entity<Map<int, String>>(data: {0: 'value'});
      final id = kvStore.create(testEntity);

      expect(id, isNotNull);
      expect(id, isNotEmpty);

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
