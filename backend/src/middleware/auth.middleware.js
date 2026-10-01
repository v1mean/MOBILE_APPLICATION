import { supabase } from "../config/supabase.js";
import { getAccountKind } from "../services/auth.service.js";

export async function requireAuth(req, res, next) {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader) {
      return res.status(401).json({
        success: false,
        message: "Authorization header is missing.",
      });
    }

    if (!authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        success: false,
        message: "Invalid authorization format.",
      });
    }

    const token = authHeader.substring(7);

    const {
      data: { user },
      error,
    } = await supabase.auth.getUser(token);

    if (error || !user) {
      return res.status(401).json({
        success: false,
        message: "Invalid or expired token.",
      });
    }

    req.user = user;

    next();
  } catch (error) {
    console.error("AUTH MIDDLEWARE ERROR:", error);

    return res.status(401).json({
      success: false,
      message: "Authentication failed.",
    });
  }
}

// For teacher-only actions. Turns away accounts on record as students; an
// account with no role on record is let through so older accounts keep working.
export async function requireTeacher(req, res, next) {
  if ((await getAccountKind(req.user)) === "student") {
    return res.status(403).json({
      success: false,
      message: "Only teacher accounts can do this.",
    });
  }

  next();
}

export function requireRole(requiredRole) {
  return (req, res, next) => {
    const role = req.user?.app_metadata?.role;

    if (!role) {
      return res.status(403).json({
        success: false,
        message: "User role is not assigned.",
      });
    }

    if (role !== requiredRole) {
      return res.status(403).json({
        success: false,
        message: "You do not have permission to access this resource.",
      });
    }

    next();
  };
}