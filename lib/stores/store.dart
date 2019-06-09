import 'package:storage/read_writers.dart' show ReadWriter;

class Entity<T> {
  String id;
  T data;
  Entity({this.id, this.data});
}

enum StoreUpdateError { cannotBeUpdate }
enum StoreDeleteError { cannotBeDelete }

abstract class Store<T> {
  ReadWriter readWriter;
  Store(this.readWriter);

  String create(Entity<T> entity);
  Entity read(String id);
  StoreUpdateError update(Entity entity);
  StoreDeleteError delete(String id);
}
