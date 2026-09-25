import { Router } from "express";
import { requireAuth } from "../middleware/auth.middleware.js";
import { uploadCourse, uploadCourseMiddleware } from "../controllers/course.controller.js";

const router = Router();

// POST /api/courses/upload
router.post("/upload", requireAuth, uploadCourseMiddleware, uploadCourse);

export default router;
