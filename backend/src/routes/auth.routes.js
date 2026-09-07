import express from "express";
import { register, login, forgotPasswordController, updatePasswordController, googleSyncController } from "../controllers/auth.controller.js";
import { requireAuth } from "../middleware/auth.middleware.js";

const router = express.Router();

router.post("/register", register);
router.post("/login", login);
router.post("/forgot-password", forgotPasswordController);
router.patch("/update-password", requireAuth, updatePasswordController);
router.post("/google-sync", requireAuth, googleSyncController);    // Legacy — keep for safety
router.post("/social-sync", requireAuth, googleSyncController);    // New unified endpoint

export default router;