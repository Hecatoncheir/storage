# storage
Storage for dart projects.

Данные которые получены с сервера (бд) нужно где-то держать что бы они были доступны при выключенном соединении, и их можно тем же запросом запрашивать уже офлайн обращаясь к своим ресолверам а не к серверным. Тот же самый запрос graphql может использоваться на клиенте как для состояния когда приложение находится в сети и доступен сервер так и когда данные есть только на устройстве офлайн.

### Key value storage with readWriter:
```dart
void main(){
  final file = File('/in_file.txt')..createSync();
  final readWriter = InFile(file, memories: file.readAsStringSync());
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
See tests in `/tests/stores/graphql_test.dart`
