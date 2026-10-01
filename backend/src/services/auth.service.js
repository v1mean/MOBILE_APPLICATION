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

  try {
    const { error: insertError } = await supabaseAdmin.from('Users').insert({
      user_id: data.user.id,
      email: email,
      name: fullName,
      role: role,
      phone: '',
      profile_image: '',
      location: ''
    });

    if (insertError) {
      console.warn("Could not insert user profile:", insertError.message);
    }
  } catch (err) {
    console.warn("Could not insert user profile catch:", err.message);
  }

  if (role === 'mentor') {
    try {
      const { error: tutorError } = await supabaseAdmin.from('tutor_profiles').insert({
        tutor_id: data.user.id,
        user_id: data.user.id,
        bio: 'New mentor profile',
        hourly_rate: 0,
        experience_years: 0,
        teaching_mode: 'online',
        location: '',
        rating: 5.0,
        is_available: true,
      });
      if (tutorError) console.warn("Could not insert tutor profile:", tutorError.message);
    } catch (err) {
      console.warn("Could not insert tutor profile catch:", err.message);
    }
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