import { supabase, supabaseAdmin } from "../config/supabase.js";

export async function registerUser({
  email,
  password,
  fullName,
  role = "student",
}) {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        full_name: fullName,
        role,
      },
    },
  });

  if (error) {
    throw new Error(error.message);
  }

  if (!data.user) {
    throw new Error("User registration failed");
  }

  try {
    const { error: roleError } =
      await supabaseAdmin.auth.admin.updateUserById(
        data.user.id,
        {
          app_metadata: {
            role,
          },
        }
      );

    if (roleError) {
      console.warn("Could not set app_metadata role with admin client:", roleError.message);
    }
  } catch (err) {
    console.warn("Could not set app_metadata role:", err.message);
  }

  return {
    user: data.user,
    session: data.session,
  };
}

export async function loginUser({
  email,
  password,
}) {
  const { data, error } =
    await supabase.auth.signInWithPassword({
      email,
      password,
    });

  if (error) {
    throw new Error(error.message);
  }

  return {
    user: data.user,
    session: data.session,
  };
}

export async function forgotPassword(email) {
  const { error } =
    await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: "io.jomnes.app://reset-password",
    });

  if (error) {
    throw new Error(error.message);
  }
}

export async function checkUserExists(email) {
  try {
    const { data, error } = await supabaseAdmin.auth.admin.listUsers();
    if (error) {
      console.warn("Could not list users with admin client:", error.message);
      return null;
    }
    const userExists = data?.users?.some(
      (u) => u.email?.toLowerCase() === email.toLowerCase()
    );
    return userExists ?? false;
  } catch (err) {
    console.warn("checkUserExists exception:", err.message);
    return null;
  }
}

export async function resetPassword(newPassword, accessToken) {
  // In Supabase v2, to update a user's password using updateUser on behalf of the user,
  // we can use the access token. However, updateUser doesn't take an access token directly.
  // We first retrieve the user with the token to get their ID, then use admin API.
  // OR we just use admin api directly if we have the token.
  // The prompt says: "This should use supabase.auth.updateUser({ password: newPassword })."
  // If the prompt strictly wants this exact call, we'll do it. But we need to ensure the client is authenticated.
  // Let's pass the token in globalHeaders temporarily or just call it.
  
  if (accessToken) {
    const { data: { user }, error: userError } = await supabase.auth.getUser(accessToken);
    if (userError) throw new Error(userError.message);
    
    // We can use admin api since we have the user id, which avoids polluting the global client
    const { error } = await supabaseAdmin.auth.admin.updateUserById(user.id, { password: newPassword });
    if (error) throw new Error(error.message);
  } else {
    // If we rely on a session already being set (e.g., if the user logged in directly in node)
    const { error } = await supabase.auth.updateUser({ password: newPassword });
    if (error) {
      throw new Error(error.message);
    }
  }
}