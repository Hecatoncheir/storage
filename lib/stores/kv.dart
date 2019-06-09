import 'dart:convert' show json;

import 'package:logging/logging.dart' show Logger;
import 'package:uuid/uuid.dart' show Uuid;

import 'package:storage/read_writers/read_writer.dart'
    show ReadWriter, ReadWriterError;

import 'store.dart' show Entity, Store, StoreDeleteError, StoreUpdateError;

/// KVEntity - entity for KVStore
class KVEntity<K, V> {
  K key;
  V value;

  KVEntity(this.key, this.value);

  KVEntity.fromMap(Map<K, V> map) {
    this.key = map.keys.first;
    this.value = map.values.first;
  }

  Map<K, V> toMap() => {key: value};
  Map<String, V> toJson() => {'$key': value};
}

/// KVStore - storage for save with key-value pair
class KVStore<K, V> implements Store {
  @override
  ReadWriter readWriter;

  /// log - for write some logs
  Logger log;

  Map<String, KVEntity<K, V>> _cache;

  /// Constructor
  KVStore(this.readWriter, {this.log}) {
    log ??= Logger('KVStore');

    _cache = Map<String, KVEntity<K, V>>();

    try {
      final content = readWriter.read();
      if (content.isNotEmpty) {
        _cache = json.decode(String.fromCharCodes(content));
      }
    } on Exception catch (exception) {
      log.warning(exception);
    }
  }

  /// operator for get value from cache
  Map<K, V> operator [](String id) => _cache[id].toMap();

  /// operator for set value to cache
  void operator []=(String key, Map<K, V> value) =>
      _cache[key] = KVEntity.fromMap(value);

  @override
  String create(Entity entity) {
    final id = Uuid().v4();
    _cache[id] = KVEntity.fromMap(entity.data);
    _updateReadWriter(_cache);
    return id;
  }

  @override
  Entity read(String id) {
    final kvEntity = _cache[id];
    return Entity(id: id, data: {kvEntity.key: kvEntity.value});
  }

  @override
  StoreUpdateError update(Entity entity) {
    if (entity.id == null) return StoreUpdateError.cannotBeUpdate;
    _cache[entity.id] = KVEntity.fromMap(entity.data);
    _updateReadWriter(_cache);
    return null;
  }

  @override
  StoreDeleteError delete(String id) {
    if (id == null) return StoreDeleteError.cannotBeDelete;
    _cache.remove(id);
    _updateReadWriter(_cache);
    return null;
  }

  void _updateReadWriter(Map<String, KVEntity<K, V>> cache) {
    try {
      final ReadWriterError error =
          readWriter.reWrite(json.encode(cache).codeUnits);

      if (error != null) {
        log.warning(error);
      }
    } on Exception catch (exception) {
      log.warning(exception);
    }
  }
}
