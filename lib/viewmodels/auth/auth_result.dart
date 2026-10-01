/// What an auth action produced, for the view to act on: a message to show
/// and, after a successful sign-in, which role's home screen to open.
class AuthResult {
  const AuthResult.success({this.message, this.role, this.hasSession = true})
    : success = true;

  const AuthResult.failure(this.message)
    : success = false,
      role = null,
      hasSession = false;

  final bool success;
  final String? message;

  /// The account's role ('student', 'mentor', 'teacher').
  final String? role;

  /// False when registration succeeded but the email must be confirmed
  /// before the user can log in.
  final bool hasSession;

  bool get isTeacher => role == 'teacher' || role == 'mentor';
}
