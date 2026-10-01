import express from "express";
import { requireAuth } from "../middleware/auth.middleware.js";
import {
  getNotifications,
  markNotificationRead,
  markAllNotificationsRead,
} from "../controllers/notification.controller.js";

const router = express.Router();

// GET /api/notifications
router.get("/", requireAuth, getNotifications);
// PATCH /api/notifications/read-all (must come before /:id/read)
router.patch("/read-all", requireAuth, markAllNotificationsRead);
// PATCH /api/notifications/:id/read
router.patch("/:id/read", requireAuth, markNotificationRead);

export default router;
