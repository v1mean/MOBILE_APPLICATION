import { test, before, after, beforeEach } from "node:test";
import assert from "node:assert/strict";
import { startFakeSupabase } from "./fake-supabase.js";

// Runs the real Express app against a fake Supabase, so nothing here reaches
// the project's database or Stripe.

const STUDENT = { id: "11111111-1111-4111-8111-111111111111", email: "student@test.dev", password: "password-s", token: "token-student" };
const TEACHER = { id: "22222222-2222-4222-8222-222222222222", email: "teacher@test.dev", password: "password-t", token: "token-teacher" };
const OTHER = { id: "33333333-3333-4333-8333-333333333333", email: "other@test.dev", password: "password-o", token: "token-other" };

let fake;
let server;
let api;

before(async () => {
  fake = await startFakeSupabase();

  // Set before the app is imported: its config reads these at load time.
  process.env.SUPABASE_URL = fake.url;
  process.env.SUPABASE_ANON_KEY = "anon-key";
  process.env.SUPABASE_SERVICE_ROLE_KEY = "service-key";
  process.env.STRIPE_SECRET_KEY = "sk_test_not_a_real_key";
  process.env.CORS_ORIGINS = "http://allowed.test";
  delete process.env.REQUIRE_PAYMENT_PROOF;

  const { default: app } = await import("../src/app.js");
  server = app.listen(0, "127.0.0.1");
  await new Promise((resolve) => server.once("listening", resolve));
  api = `http://127.0.0.1:${server.address().port}/api`;
});

after(async () => {
  await new Promise((resolve) => server.close(resolve));
  await fake.close();
});

beforeEach(() => {
  fake.state.calls.length = 0;
  fake.state.users = [structuredClone(STUDENT), structuredClone(TEACHER), structuredClone(OTHER)];
  fake.state.tables = {
    profiles: [
      { id: STUDENT.id, role: "student", full_name: "Sok Student" },
      { id: TEACHER.id, role: "mentor", full_name: "Thy Teacher" },
      { id: OTHER.id, role: "student", full_name: "Other Student" },
    ],
    Users: [
      { user_id: STUDENT.id, role: "Student" },
      { user_id: TEACHER.id, role: "mentor" },
    ],
    tutor_profiles: [{ tutor_id: TEACHER.id, user_id: TEACHER.id, hourly_rate: 25 }],
    bookings: [],
    reviews: [],
    notifications: [],
    courses: [],
    user_courses: [],
  };
});

async function call(method, path, { token, body, headers } = {}) {
  const response = await fetch(`${api}${path}`, {
    method,
    headers: {
      ...(body ? { "content-type": "application/json" } : {}),
      ...(token ? { authorization: `Bearer ${token}` } : {}),
      ...headers,
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  return { status: response.status, json: await response.json() };
}

const login = (user, role) =>
  call("POST", "/auth/login", { body: { email: user.email, password: user.password, role } });

const password = (user) => fake.state.users.find((u) => u.id === user.id).password;

// ── Password change ──────────────────────────────────────────────────────────

test("a password change applies to the account that asked for it", async () => {
  // Someone else logs in first. The old code kept that session on a client
  // shared by every request, and the next password change landed on it.
  await login(OTHER, "student");

  const result = await call("PATCH", "/auth/update-password", {
    token: STUDENT.token,
    body: { newPassword: "brand-new-password" },
  });

  assert.equal(result.status, 200);
  assert.equal(password(STUDENT), "brand-new-password");
  assert.equal(password(OTHER), OTHER.password);
});

test("a password change needs a valid token", async () => {
  const result = await call("PATCH", "/auth/update-password", {
    token: "not-a-token",
    body: { newPassword: "brand-new-password" },
  });

  assert.equal(result.status, 401);
  assert.equal(password(STUDENT), STUDENT.password);
});

// ── Login ────────────────────────────────────────────────────────────────────

test("login finds an account that is past the first page of users", async () => {
  const filler = Array.from({ length: 1200 }, (_, i) => ({
    id: `filler-${i}`,
    email: `filler${i}@test.dev`,
    password: "x",
    token: `filler-token-${i}`,
  }));
  fake.state.users = [...filler, structuredClone(STUDENT)];

  const result = await login(STUDENT, "student");

  assert.equal(result.status, 200);
  assert.equal(result.json.message, "Login Successful");
});

test("login from the other role's screen explains which view opens", async () => {
  const teacherOnStudentScreen = await login(TEACHER, "student");
  assert.equal(
    teacherOnStudentScreen.json.message,
    "This account is registered as a teacher, so the teacher view was opened."
  );

  const studentOnTeacherScreen = await login(STUDENT, "teacher");
  assert.equal(
    studentOnTeacherScreen.json.message,
    "This account is registered as a student, so the student view was opened."
  );

  const teacherOnTeacherScreen = await login(TEACHER, "teacher");
  assert.equal(teacherOnTeacherScreen.json.message, "Login Successful");
});

test("login reports an unknown email and a wrong password", async () => {
  const unknown = await call("POST", "/auth/login", {
    body: { email: "nobody@test.dev", password: "whatever1" },
  });
  assert.equal(unknown.status, 404);

  const wrong = await call("POST", "/auth/login", {
    body: { email: STUDENT.email, password: "wrong-password" },
  });
  assert.equal(wrong.status, 401);
  assert.equal(wrong.json.message, "Incorrect password. Please try again.");
});

// ── Profile ──────────────────────────────────────────────────────────────────

const savedHeadline = (user) =>
  fake.state.calls.findLast((c) => c.method === "POST" && c.path === "/rest/v1/Users")?.body?.role;

test("a student cannot list themselves as a mentor through their headline", async () => {
  const result = await call("PATCH", "/users/profile", {
    token: STUDENT.token,
    body: { name: "Sok", role: "mentor" },
  });

  assert.equal(result.status, 200);
  assert.equal(savedHeadline(STUDENT), "Student");
});

test("a teacher keeps a mentor headline, and anyone can use a free-text one", async () => {
  await call("PATCH", "/users/profile", { token: TEACHER.token, body: { name: "Thy", role: "mentor" } });
  assert.equal(savedHeadline(TEACHER), "mentor");

  await call("PATCH", "/users/profile", { token: STUDENT.token, body: { name: "Sok", role: "Grade 12" } });
  assert.equal(savedHeadline(STUDENT), "Grade 12");
});

test("a profile picture must be a web address", async () => {
  await call("PATCH", "/users/profile", {
    token: STUDENT.token,
    body: { name: "Sok", profileImage: "javascript:alert(1)" },
  });

  const saved = fake.state.calls.findLast((c) => c.method === "POST" && c.path === "/rest/v1/Users").body;
  assert.equal(saved.profile_image, undefined);
});

// ── Reviews ──────────────────────────────────────────────────────────────────

test("a review needs a rating from 1 to 5 and cannot be for yourself", async () => {
  const tooHigh = await call("POST", "/reviews", {
    token: STUDENT.token,
    body: { mentor_id: TEACHER.id, rating: 500 },
  });
  assert.equal(tooHigh.status, 400);

  const negative = await call("POST", "/reviews", {
    token: STUDENT.token,
    body: { mentor_id: TEACHER.id, rating: -3 },
  });
  assert.equal(negative.status, 400);

  const self = await call("POST", "/reviews", {
    token: TEACHER.token,
    body: { mentor_id: TEACHER.id, rating: 5 },
  });
  assert.equal(self.status, 400);

  assert.equal(fake.state.tables.reviews.length, 0);
});

test("a valid review is saved and the mentor is notified", async () => {
  const result = await call("POST", "/reviews", {
    token: STUDENT.token,
    body: { mentor_id: TEACHER.id, rating: 4.5, comment: "  Clear explanations.  " },
  });

  assert.equal(result.status, 200);
  assert.equal(fake.state.tables.reviews[0].rating, 4.5);
  assert.equal(fake.state.tables.reviews[0].comment, "Clear explanations.");
  assert.equal(fake.state.tables.notifications[0].user_id, TEACHER.id);
});

// ── Bookings ─────────────────────────────────────────────────────────────────

test("a booking records the tutor's rate, not the price the client sent", async () => {
  const result = await call("POST", "/bookings/create", {
    token: STUDENT.token,
    body: { tutor_id: TEACHER.id, hourly_rate: 0.01, total_price: 0.01, booking_date: "2026-10-05" },
  });

  assert.equal(result.status, 200);
  assert.equal(fake.state.tables.bookings[0].hourly_rate, 25);
  assert.equal(fake.state.tables.bookings[0].total_price, 25);
  assert.equal(fake.state.tables.bookings[0].student_id, STUDENT.id);
});

test("a user cannot book themselves", async () => {
  const result = await call("POST", "/bookings/create", {
    token: TEACHER.token,
    body: { tutor_id: TEACHER.id },
  });

  assert.equal(result.status, 400);
  assert.equal(fake.state.tables.bookings.length, 0);
});

test("a teacher can only change the status of their own bookings", async () => {
  fake.state.tables.bookings.push({ id: "b1", tutor_id: TEACHER.id, student_id: STUDENT.id, status: "pending" });

  const stranger = await call("PATCH", "/bookings/b1/status", {
    token: OTHER.token,
    body: { status: "canceled" },
  });
  assert.notEqual(stranger.status, 200);
  assert.equal(fake.state.tables.bookings[0].status, "pending");

  const owner = await call("PATCH", "/bookings/b1/status", {
    token: TEACHER.token,
    body: { status: "confirmed" },
  });
  assert.equal(owner.status, 200);
  assert.equal(fake.state.tables.bookings[0].status, "confirmed");
});

// ── Course upload ────────────────────────────────────────────────────────────

function courseForm(fileName) {
  const form = new FormData();
  form.set("title", "Algebra basics");
  form.set("category", "Math");
  if (fileName) form.set("material", new Blob(["content"]), fileName);
  return form;
}

async function upload(user, form) {
  const response = await fetch(`${api}/courses/upload`, {
    method: "POST",
    headers: { authorization: `Bearer ${user.token}` },
    body: form,
  });
  return { status: response.status, json: await response.json() };
}

test("a student account cannot upload a course", async () => {
  const result = await upload(STUDENT, courseForm());

  assert.equal(result.status, 403);
  assert.equal(fake.state.tables.courses.length, 0);
});

test("a teacher can upload a course, but not a file that runs in a browser", async () => {
  const blocked = await upload(TEACHER, courseForm("notes.html"));
  assert.equal(blocked.status, 400);
  assert.equal(fake.state.tables.courses.length, 0);

  const allowed = await upload(TEACHER, courseForm("notes.pdf"));
  assert.equal(allowed.status, 200);
  assert.equal(fake.state.tables.courses[0].tutor_id, TEACHER.id);
});

// ── Access and errors ────────────────────────────────────────────────────────

test("protected routes turn away requests without a valid token", async () => {
  for (const [method, path] of [
    ["GET", "/notifications"],
    ["GET", "/bookings/teachers"],
    ["POST", "/bookings/create"],
    ["POST", "/reviews"],
    ["PATCH", "/users/profile"],
    ["POST", "/payments/create-intent"],
  ]) {
    const result = await call(method, path, { body: method === "GET" ? undefined : {} });
    assert.equal(result.status, 401, `${method} ${path}`);
  }
});

test("notifications are only marked read for their owner", async () => {
  fake.state.tables.notifications.push({ id: "n1", user_id: TEACHER.id, is_read: false });

  await call("PATCH", "/notifications/n1/read", { token: STUDENT.token });
  assert.equal(fake.state.tables.notifications[0].is_read, false);

  await call("PATCH", "/notifications/n1/read", { token: TEACHER.token });
  assert.equal(fake.state.tables.notifications[0].is_read, true);
});

test("errors outside a controller come back as JSON", async () => {
  const blockedOrigin = await call("GET", "/health", { headers: { origin: "http://evil.test" } });
  assert.equal(blockedOrigin.status, 403);
  assert.equal(blockedOrigin.json.success, false);

  const response = await fetch(`${api}/auth/login`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: "{not json",
  });
  assert.equal(response.status, 400);
  assert.deepEqual(await response.json(), { success: false, message: "Invalid request body." });
});
