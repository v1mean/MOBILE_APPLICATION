import { registerUser, loginUser, forgotPassword, checkUserExists, resetPassword } from "../services/auth.service.js";
import { supabase, supabaseAdmin } from "../config/supabase.js";

export async function register(req, res) {
  try {
    const { email, password, fullName } = req.body;

    if (!email || !password || !fullName) {
      return res.status(400).json({
        success: false,
        message: "Email, password and full name are required.",
      });
    }

    if (password.length < 8) {
      return res.status(400).json({
        success: false,
        message: "Password must be at least 8 characters.",
      });
    }

    const userExists = await checkUserExists(email);
    if (userExists === true) {
      return res.status(409).json({
        success: false,
        message: "An account with this email already exists. Please log in.",
      });
    }

    const result = await registerUser({
      email,
      password,
      fullName,
      role: "student",
    });

    return res.status(201).json({
      success: true,
      message: result.session
        ? "Account created successfully."
        : "Account created. Please check your email to verify your account.",
      user: result.user,
      session: result.session,
    });
  } catch (error) {
    console.error("REGISTER ERROR:", error);

    // In case Supabase still throws an already registered error
    if (error.message.includes("already registered")) {
      return res.status(409).json({
        success: false,
        message: "An account with this email already exists. Please log in.",
      });
    }

    return res.status(400).json({
      success: false,
      message: error.message,
    });
  }
}

export async function login(req, res) {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email and password are required.",
      });
    }

    const userExists = await checkUserExists(email);
    if (userExists === false) {
      return res.status(404).json({
        success: false,
        message: "No account found with this email. Please register first.",
      });
    }

    const result = await loginUser({
      email,
      password,
    });

    return res.status(200).json({
      success: true,
      message: "Login Successful",
      user: result.user,
      session: result.session,
    });
  } catch (error) {
    console.error("LOGIN ERROR:", error);

    if (error.message.includes("Email not confirmed")) {
      return res.status(403).json({
        success: false,
        message: "Email not confirmed",
      });
    }

    if (error.message.includes("Invalid login credentials") || error.message.includes("password")) {
      return res.status(401).json({
        success: false,
        message: "Incorrect password. Please try again.",
      });
    }

    return res.status(401).json({
      success: false,
      message: "Invalid email or password.",
    });
  }
}

export async function forgotPasswordController(req, res) {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: "Email is required.",
      });
    }

    await forgotPassword(email);

    return res.status(200).json({
      success: true,
      message:
        "If an account exists for that email, a password reset link has been sent.",
    });
  } catch (error) {
    console.error("FORGOT PASSWORD ERROR:", error);

    // Don't reveal whether the email exists.
    return res.status(200).json({
      success: true,
      message:
        "If an account exists for that email, a password reset link has been sent.",
    });
  }
}

export async function updatePasswordController(req, res) {
  try {
    const { newPassword } = req.body;
    
    if (!newPassword) {
      return res.status(400).json({
        success: false,
        message: "New password is required.",
      });
    }

    if (newPassword.length < 8) {
      return res.status(400).json({
        success: false,
        message: "Password must be at least 8 characters.",
      });
    }

    // Ensure we are using the user's current session provided via token
    const authHeader = req.headers.authorization;
    const accessToken = authHeader && authHeader.split(" ")[1];

    if (accessToken) {
      // In a stateless backend, we must set the session first if using the global client
      // or we can use the admin client. But as requested, we use auth.updateUser:
      await supabase.auth.setSession({
        access_token: accessToken,
        refresh_token: "", 
      });
    }

    const { error } = await supabase.auth.updateUser({ password: newPassword });
    
    if (error) {
      throw new Error(error.message);
    }

    return res.status(200).json({
      success: true,
      message: "Password updated successfully.",
    });
  } catch (error) {
    console.error("UPDATE PASSWORD ERROR:", error);
    return res.status(400).json({
      success: false,
      message: error.message || "Failed to update password.",
    });
  }
}

export async function googleSyncController(req, res) {
  try {
    const user = req.user;
    const isNewUser = !user.app_metadata?.role;

    // ── Step 1: Set the role in Supabase Auth app_metadata ──────────────────
    // This is checked by requireRole() middleware and is the source of truth
    // for access control across the entire backend.
    if (isNewUser) {
      const { error: metaError } = await supabaseAdmin.auth.admin.updateUserById(
        user.id,
        { app_metadata: { role: "student" } }
      );
      if (metaError) {
        console.warn("Could not set app_metadata role:", metaError.message);
      }
    }

    // ── Step 2: Upsert a row in the public.profiles table ───────────────────
    // Uses ignoreDuplicates:true so existing profiles are never overwritten.
    // All fields are null-coalesced to handle Google privacy settings where
    // the user may have hidden their name or email from the app.
    const { error: profileError } = await supabaseAdmin
      .from("profiles")
      .upsert(
        {
          id: user.id,
          // Some Google accounts hide their email — fall back to empty string
          email: user.email ?? user.user_metadata?.email ?? "",
          // Name can come from different metadata keys depending on the provider
          full_name:
            user.user_metadata?.full_name ||
            user.user_metadata?.name ||
            user.user_metadata?.given_name ||
            null,
          avatar_url:
            user.user_metadata?.avatar_url ||
            user.user_metadata?.picture ||
            null,
          role: "student",
          created_at: new Date().toISOString(),
        },
        {
          onConflict: "id",       // id is the primary key
          ignoreDuplicates: true, // Do NOT overwrite fields on returning users
        }
      );

    if (profileError) {
      // Log but don't fail the request — the user is already authenticated
      console.warn("Profile upsert warning:", profileError.message);
    }

    return res.status(200).json({
      success: true,
      message: isNewUser ? "New user synced with student role." : "Existing user verified.",
      isNewUser,
    });
  } catch (error) {
    console.error("SOCIAL SYNC ERROR:", error);
    return res.status(500).json({ success: false, message: "Sync failed." });
  }
}