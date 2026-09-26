// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:typed_data';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'device_file_picker.dart';

Future<PickedFileResult?> _pickFileWithInput(String accept) {
  final completer = Completer<PickedFileResult?>();
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = accept;
  input.click();

  input.addEventListener(
    'change',
    (web.Event _) {
      final files = input.files;
      if (files == null || files.length == 0) {
        completer.complete(null);
        return;
      }
      final file = files.item(0)!;
      final reader = web.FileReader();

      reader.addEventListener(
        'loadend',
        (web.Event _) {
          Uint8List? bytes;
          try {
            final jsBuffer = reader.result as JSArrayBuffer;
            bytes = jsBuffer.toDart.asUint8List();
          } catch (_) {
            bytes = null;
          }
          completer.complete(PickedFileResult(
            name: file.name,
            size: file.size,
            bytes: bytes,
          ));
        }.toJS,
      );

      reader.addEventListener(
        'error',
        (web.Event _) {
          completer.complete(null);
        }.toJS,
      );

      reader.readAsArrayBuffer(file as web.Blob);
    }.toJS,
  );

  return completer.future;
}

Future<PickedFileResult?> pickImageImpl() => _pickFileWithInput('image/*');
Future<PickedFileResult?> pickVideoImpl() => _pickFileWithInput('video/*');
Future<PickedFileResult?> pickDocumentImpl() =>
    _pickFileWithInput('.pdf,.doc,.docx,.ppt,.pptx,.txt,.xlsx,.zip');
