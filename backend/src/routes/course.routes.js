import { Router } from "express";
import { requireAuth, requireTeacher } from "../middleware/auth.middleware.js";
import { uploadCourse, uploadCourseMiddleware } from "../controllers/course.controller.js";

const router = Router();

// POST /api/courses/upload
// The role check runs before the files are read, so a student account cannot
// make the server buffer an upload.
router.post("/upload", requireAuth, requireTeacher, uploadCourseMiddleware, uploadCourse);

export default router;
