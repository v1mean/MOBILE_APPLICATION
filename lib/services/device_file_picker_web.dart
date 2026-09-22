// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'device_file_picker.dart';

Future<PickedFileResult?> _pickFileWithInput(String accept) async {
  final completer = Completer<PickedFileResult?>();
  final input = html.FileUploadInputElement()..accept = accept;
  input.click();

  input.onChange.listen((event) {
    final files = input.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((_) {
        final result = reader.result;
        Uint8List? bytes;
        if (result is Uint8List) {
          bytes = result;
        } else if (result is ByteBuffer) {
          bytes = Uint8List.view(result);
        } else if (result is List<int>) {
          bytes = Uint8List.fromList(result);
        }
        completer.complete(PickedFileResult(
          name: file.name,
          size: file.size,
          bytes: bytes,
        ));
      });
      reader.onError.listen((_) {
        completer.complete(null);
      });
    } else {
      completer.complete(null);
    }
  });

  return completer.future;
}

Future<PickedFileResult?> pickImageImpl() => _pickFileWithInput('image/*');
Future<PickedFileResult?> pickVideoImpl() => _pickFileWithInput('video/*');
Future<PickedFileResult?> pickDocumentImpl() => _pickFileWithInput('.pdf,.doc,.docx,.ppt,.pptx,.txt,.xlsx,.zip');
