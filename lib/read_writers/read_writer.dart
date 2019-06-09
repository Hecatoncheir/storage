enum ReadWriterError { cannotBeWrite }

abstract class ReadWriter {
  List<int> read();
  ReadWriterError write(List<int> bytes);
  ReadWriterError reWrite(List<int> bytes);
  ReadWriterError writeLine(List<int> bytes);
}
