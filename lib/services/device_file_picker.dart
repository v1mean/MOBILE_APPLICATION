import 'dart:typed_data';
import 'device_file_picker_stub.dart'
    if (dart.library.html) 'device_file_picker_web.dart';

class PickedFileResult {
  final String name;
  final int size;
  final Uint8List? bytes;

  PickedFileResult({
    required this.name,
    required this.size,
    this.bytes,
  });
}

class DeviceFilePicker {
  static Future<PickedFileResult?> pickImage() => pickImageImpl();
  static Future<PickedFileResult?> pickVideo() => pickVideoImpl();
  static Future<PickedFileResult?> pickDocument() => pickDocumentImpl();
}
