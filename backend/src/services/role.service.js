export function isTeacherRole(role) {
  return role === "mentor" || role === "teacher";
}

// "teacher" when any role on record says so, "student" when roles are on
// record and none does, null when the account has no role recorded at all.
export function accountKind(roles) {
  const known = roles.filter(Boolean);
  if (known.length === 0) return null;
  return known.some(isTeacherRole) ? "teacher" : "student";
}

// `Users.role` is the free-text headline shown under a user's name, but the
// app also lists every row whose headline is one of these words as a mentor.
const MENTOR_LISTING_WORDS = ["mentor", "tutor", "teacher"];

export function isMentorListingWord(headline) {
  return (
    typeof headline === "string" &&
    MENTOR_LISTING_WORDS.includes(headline.trim().toLowerCase())
  );
}

// The headline to store. A word that puts the row in the mentor list is kept
// only for a teacher account, or when the row already carried one.
export function safeHeadline(headline, { isTeacher, alreadyListed }) {
  const text = typeof headline === "string" ? headline.trim().slice(0, 60) : "";
  if (!text) return "Student";
  if (isMentorListingWord(text) && !isTeacher && !alreadyListed) {
    return "Student";
  }
  return text;
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
