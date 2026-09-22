import express from "express";
import { requireAuth } from "../middleware/auth.middleware.js";
import { createReview, getMentorReviews } from "../controllers/review.controller.js";

const router = express.Router();

router.post("/", requireAuth, createReview);
router.get("/mentor/:id", getMentorReviews);

export default router;
