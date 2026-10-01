import 'package:flutter/foundation.dart';

/// Base class for view models. A view model holds the state a screen shows
/// and the actions it can take; it gets data from repositories and never
/// touches widgets.
abstract class BaseViewModel extends ChangeNotifier {
  bool _disposed = false;

  bool get isDisposed => _disposed;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // Async work can finish after the screen has been closed; notifying a
  // disposed ChangeNotifier throws, so those late updates are dropped.
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }
}
