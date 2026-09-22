import express from "express";
import { requireAuth } from "../middleware/auth.middleware.js";
import { createBooking } from "../controllers/booking.controller.js";

const router = express.Router();

// POST /api/bookings/create
router.post("/create", requireAuth, createBooking);

export default router;

