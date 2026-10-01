import 'package:flutter/foundation.dart';

/// Tracks "Continue as guest" so the router can re-evaluate its redirects.
class GuestModeNotifier extends ChangeNotifier {
  bool _isGuest = false;
  bool get isGuest => _isGuest;

  void setGuest(bool value) {
    if (_isGuest != value) {
      _isGuest = value;
      notifyListeners();
    }
  }
}

final guestModeNotifier = GuestModeNotifier();

bool get isGuestMode => guestModeNotifier.isGuest;
set isGuestMode(bool value) => guestModeNotifier.setGuest(value);
