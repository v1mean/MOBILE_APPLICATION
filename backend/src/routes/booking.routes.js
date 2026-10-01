import express from "express";
import { requireAuth } from "../middleware/auth.middleware.js";
import {
  createBooking,
  getTeacherBookings,
  updateBookingStatus,
} from "../controllers/booking.controller.js";

const router = express.Router();

// POST /api/bookings/create
router.post("/create", requireAuth, createBooking);
// GET /api/bookings/teachers
router.get("/teachers", requireAuth, getTeacherBookings);

router.patch(
    "/:id/status",
    requireAuth,
    updateBookingStatus
  );

export default router;

