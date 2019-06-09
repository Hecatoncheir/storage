import 'dart:convert' show json;

import 'package:logging/logging.dart' show Logger;
import 'package:uuid/uuid.dart' show Uuid;

import 'package:storage/read_writers/read_writer.dart'
    show ReadWriter, ReadWriterError;

import 'store.dart' show Entity, Store, StoreDeleteError, StoreUpdateError;

abstract class StorageKey {
  Object value;
  StorageKey.fromJson(String source);
  void fromJson(String source);
  String toJson();
}

abstract class StorageValue {
  Object value;
  StorageValue.fromJson(String source);

  void fromJson(String source);
  String toJson();
}

class KVEntity<StorageKey, StorageValue> {
  StorageKey key;
  StorageValue value;

  KVEntity(this.key, this.value);

  KVEntity.fromMap(Map<StorageKey, StorageValue> source) {
    key = source.keys.first;
    value = source.values.first;
  }

  Map<StorageKey, StorageValue> toMap() => {key: value};

  Map<String, String> toJson() =>
      {(key as dynamic).toJson(): (value as dynamic).toJson()};
}

/// KVStore - storage for save with key-value pair
class KVStore<StorageKey, StorageValue> implements Store {
  @override
  ReadWriter readWriter;

  /// log - for write some logs
  Logger log;

  Map<String, KVEntity<StorageKey, StorageValue>> _cache;

  /// Constructor
  KVStore(this.readWriter, {this.log}) {
    log ??= Logger('KVStore');

    _cache = Map<String, KVEntity<StorageKey, StorageValue>>();

    try {
      final content = readWriter.read();
      if (content.isNotEmpty) {
        final encodedCache = json.decode(String.fromCharCodes(content));
        updateCache(encodedCache);
      }
    } on Exception catch (exception) {
      log.warning(exception);
    }
  }

  /// operator for get value from cache
  Map<StorageKey, StorageValue> operator [](String id) => _cache[id].toMap();

  /// operator for set value to cache
  void operator []=(String key, Map<StorageKey, StorageValue> value) =>
      _cache[key] = KVEntity.fromMap({value.keys.first: value.values.first});

  @override
  String create(Entity entity) {
    final id = Uuid().v4();
    _cache[id] = KVEntity.fromMap(entity.data);
    _updateReadWriter(_cache);
    return id;
  }

  @override
  Entity read(String id) {
    final entity = _cache[id];
    final data = {
      (entity.key as dynamic).value: (entity.value as dynamic).value
    };
    return Entity(id: id, data: data);
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

  void updateCache(Map sourceCache) {
    Map<String, Map<String, String>> encodedCache = sourceCache;
  }

  void _updateReadWriter(
      Map<String, KVEntity<StorageKey, StorageValue>> cache) {
    try {
      final cacheForEncode = Map<String, Map<String, String>>();

      for (String id in cache.keys) {
        final kvEntity = cache[id];

        final Map<StorageKey, StorageValue> entity = {
          kvEntity.key: kvEntity.value
        };

        final StorageKey storageKey = entity.keys.first;
        final StorageValue storageValue = entity.values.first;

        cacheForEncode[id] = {
          (storageKey as dynamic).toJson(): (storageValue as dynamic).toJson()
        };
      }

      final ReadWriterError error =
          readWriter.reWrite(json.encode(cacheForEncode).codeUnits);

      if (error != null) {
        log.warning(error);
      }
    } on Exception catch (exception) {
      log.warning(exception);
    }
  }
}
