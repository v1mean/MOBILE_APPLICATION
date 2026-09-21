import express from "express";
import { requireAuth } from "../middleware/auth.middleware.js";
import {
  searchMentors,
  uploadAvatar,
  uploadAvatarMiddleware,
  updateProfile,
  getFilteredMentors,
  getSubjects,
} from "../controllers/user.controller.js";

const router = express.Router();

// ── User / Profile ─────────────────────────────────────────────────────────
router.get("/me", requireAuth, (req, res) => {
  res.json({ success: true, user: req.user });
});

// PATCH /api/users/profile  — admin upsert to bypass Users table RLS
router.patch("/profile", requireAuth, updateProfile);

// POST /api/users/upload-avatar
router.post(
  "/upload-avatar",
  requireAuth,
  uploadAvatarMiddleware,
  uploadAvatar
);

// ── Mentor search ──────────────────────────────────────────────────────────
router.get("/mentors/subjects", getSubjects);
router.get("/mentors", getFilteredMentors);
router.get("/mentors/search", searchMentors);

export default router;