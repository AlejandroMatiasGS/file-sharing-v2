import 'dart:typed_data';

List<int> intToBytes(int n) {
  ByteData byteData = ByteData(4);
  byteData.setInt32(0, n, Endian.little);
  return byteData.buffer.asUint8List();
}
