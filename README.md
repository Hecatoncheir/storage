# storage
Storage for dart projects.

### Key value storage with readWriter:
```dart
void main(){
  final file = File('/in_file.txt')..createSync();
  final readWriter = InFile(file);
      // or
  // final readWriter = InMemory();
  final kvStore = KVStore<int, String>(readWriter,
      keyToJson: (key) => key.toString(),
      keyFromJson: int.parse,
      valueToJson: (value) => value,
      valueFromJson: (value) => value);
  
      final entityForCreate = Entity<Map<int, String>>(data: {0: 'value'});
      final id = kvStore.create(entityForCreate);
      
      
      final entity = kvStore.read(id);
      /// expect(entity.data, equals({0: 'value'}));
      
      final error = kvStore.update(Entity(id: id, data: {0: 'updated value'}));
      /// expect(error, isNull);
      /// or
      /// enum StoreUpdateError { cannotBeUpdate }
      
      final error = kvStore.delete(id);
      /// expect(error, isNull);
      /// or
      /// enum StoreDeleteError { cannotBeDelete }
}
```

### GraphQL
See tests in /tests/stores/graphql_test.dart