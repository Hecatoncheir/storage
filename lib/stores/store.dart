import 'package:storage/read_writers.dart' show ReadWriter;

abstract class Store {
  ReadWriter readWriter;
  Store(this.readWriter);
}
