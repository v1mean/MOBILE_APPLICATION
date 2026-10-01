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

  bool get isTeacher => isTeacherRole(role);
}

bool isTeacherRole(String? role) => role == 'teacher' || role == 'mentor';

/// What to tell someone who signed in from the other role's login screen.
/// An account has one role, so the app opens that role's home whichever
/// screen was used. Null when the chosen role matches the account.
String? roleMismatchNotice({
  required String chosenRole,
  required String accountRole,
}) {
  final accountIsTeacher = isTeacherRole(accountRole);
  if (isTeacherRole(chosenRole) == accountIsTeacher) return null;

  return accountIsTeacher
      ? 'This account is registered as a teacher, so the teacher view was opened.'
      : 'This account is registered as a student, so the student view was opened.';
}
