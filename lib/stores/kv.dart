import 'dart:convert' show json;

import 'package:logging/logging.dart' show Logger;
import 'package:storage/read_writers.dart';
import 'package:uuid/uuid.dart' show Uuid;

import 'package:storage/read_writers/read_writer.dart'
    show ReadWriter, ReadWriterError;

import 'store.dart' show Entity, Store, StoreDeleteError, StoreUpdateError;

/// KVStore - storage for save with key-value pair
class KVStore<K, V> implements Store {
  @override
  ReadWriter readWriter;

  /// log - for write some logs
  Logger log;

  Map<String, Map<K, V>> _cache;

  K Function(String) keyFromJson;
  String Function(K) keyToJson;

  V Function(String) valueFromJson;
  String Function(V) valueToJson;

  /// Constructor
  KVStore(this.readWriter,
      {this.log,
      this.keyFromJson,
      this.keyToJson,
      this.valueFromJson,
      this.valueToJson}) {
    log ??= Logger('KVStore');

    _cache = Map<String, Map<K, V>>();

    try {
      final content = readWriter.read();
      if (content.isNotEmpty) {
        if (readWriter is InMemory) {
          _cache = prepareCacheFromReadWriterInFileContent(
              json.decode(String.fromCharCodes(content)));
        }

        if (readWriter is InFile) {
          _cache = prepareCacheFromReadWriterInFileContent(
              json.decode(String.fromCharCodes(content)));
        }

        if (readWriter is InJSONFile) {
          _cache = prepareCacheFromReadWriterInJSONFileContent(
              json.decode(String.fromCharCodes(content)));
        }
      }
    } on Exception catch (exception) {
      print(exception);
      log.warning(exception);
    }
  }

  /// operator for get value from cache
  Map<K, V> operator [](String id) => _cache[id];

  /// operator for set value to cache
  void operator []=(String key, Map<K, V> value) => _cache[key] = value;

  @override
  String create(Entity entity) {
    final id = Uuid().v4();
    _cache[id] = entity.data;
    _updateReadWriter(_cache);
    return id;
  }

  @override
  Entity read(String id) {
    final entity = _cache[id];
    return Entity(id: id, data: {entity.keys.first: entity.values.first});
  }

  @override
  StoreUpdateError update(Entity entity) {
    if (entity.id == null) return StoreUpdateError.cannotBeUpdate;
    _cache[entity.id] = entity.data;
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

  Map<String, Map<K, V>> prepareCacheFromReadWriterInFileContent(
      Map<String, dynamic> content) {
    final cacheForWrite = Map<String, Map<K, V>>();

    for (String id in content.keys) {
      final entity = content[id];
      cacheForWrite[id] = {
        keyFromJson(entity.keys.first): valueFromJson(entity.values.first)
      };
    }

    return cacheForWrite;
  }

  Map<String, Map<K, V>> prepareCacheFromReadWriterInJSONFileContent(
      List content) {
    final cacheForWrite = Map<String, Map<K, V>>();

    for (Map map in content) {
      final decodedMap = {};

      final Map inMap = map.values.first;
      for (dynamic key in inMap.keys) {
        print(key);
        print(inMap[key]);
        decodedMap[keyFromJson(key)] = valueFromJson(inMap[key]);
      }

      cacheForWrite[map.keys.first] = decodedMap;
    }

    return cacheForWrite;
  }

  void _updateReadWriter(Map<String, Map<K, V>> cache) {
    try {
      final cacheForWrite = Map<String, Map<String, String>>();

      for (String id in cache.keys) {
        final entity = cache[id];
        cacheForWrite[id] = {
          keyToJson(entity.keys.first): valueToJson(entity.values.first)
        };
      }

      final ReadWriterError error =
          readWriter.reWrite(json.encode(cacheForWrite).codeUnits);

      if (error != null) {
        log.warning(error);
      }
    } on Exception catch (exception) {
      log.warning(exception);
    }
  }
}
