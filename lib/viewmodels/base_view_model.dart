import 'package:flutter/foundation.dart';

/// Base class for view models. A view model holds the state a screen shows
/// and the actions it can take; it gets data from repositories and never
/// touches widgets.
abstract class BaseViewModel extends ChangeNotifier {
  bool _disposed = false;
  bool _isBusy = false;

  bool get isDisposed => _disposed;

  /// True while an action the user started (log in, save, upload) is running.
  bool get isBusy => _isBusy;

  @protected
  void setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }

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
