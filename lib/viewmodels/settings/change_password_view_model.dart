import '../../repositories/auth_repository.dart';
import '../base_view_model.dart';

class ChangePasswordViewModel extends BaseViewModel {
  ChangePasswordViewModel({required AuthRepository authRepository})
    : _auth = authRepository;

  final AuthRepository _auth;

  /// Changes the signed-in user's password. Returns an error message to show,
  /// or null when it was changed.
  Future<String?> changePassword(String newPassword) async {
    setBusy(true);
    try {
      await _auth.updatePassword(newPassword);
      return null;
    } catch (e) {
      return 'Failed: $e';
    } finally {
      setBusy(false);
    }
  }
}
