import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the MVVM layering:
///
///   views / widgets  →  view models  →  repositories  →  services
///
/// Only repositories and services may talk to Supabase or the backend.
void main() {
  List<File> dartFilesIn(String dir) {
    return Directory(dir)
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();
  }

  List<String> importsOf(File file) {
    return file
        .readAsLinesSync()
        .map((line) => line.trim())
        .where((line) => line.startsWith('import '))
        .toList();
  }

  /// Every `file: import` pair under [dir] whose import contains one of
  /// [forbidden].
  List<String> violations(String dir, List<String> forbidden) {
    final found = <String>[];
    for (final file in dartFilesIn(dir)) {
      for (final import in importsOf(file)) {
        if (forbidden.any(import.contains)) {
          found.add('${file.path}: $import');
        }
      }
    }
    return found;
  }

  const dataSources = [
    'package:supabase_flutter',
    'package:http',
    'services/api_service.dart',
    'services/supabase_service.dart',
    'services/auth_service.dart',
    'main.dart',
  ];

  test('views do not reach data sources or repositories', () {
    expect(
      violations('lib/views', [...dataSources, 'repositories/', 'services/']),
      isEmpty,
    );
  });

  test('shared widgets do not reach data sources or repositories', () {
    expect(
      violations('lib/widgets', [...dataSources, 'repositories/', 'services/']),
      isEmpty,
    );
  });

  test('view models get data only through repositories', () {
    expect(violations('lib/viewmodels', dataSources), isEmpty);
  });

  test('view models do not depend on views or widgets', () {
    expect(violations('lib/viewmodels', ['views/', 'widgets/']), isEmpty);
  });

  test('repositories do not depend on views or view models', () {
    expect(
      violations('lib/repositories', ['views/', 'viewmodels/', 'widgets/']),
      isEmpty,
    );
  });
}
