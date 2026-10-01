export function isTeacherRole(role) {
  return role === "mentor" || role === "teacher";
}

// An account has one role, and the app opens that role's home whichever login
// screen was used. Returns what to tell someone who signed in from the other
// role's screen, or null when the roles match or either one is unknown.
export function roleMismatchNotice(chosenRole, accountRole) {
  if (!chosenRole || !accountRole) return null;
  if (isTeacherRole(chosenRole) === isTeacherRole(accountRole)) return null;

  return isTeacherRole(accountRole)
    ? "This account is registered as a teacher, so the teacher view was opened."
    : "This account is registered as a student, so the student view was opened.";
}
