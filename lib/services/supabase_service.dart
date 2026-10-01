import 'package:supabase_flutter/supabase_flutter.dart';

/// The app's Supabase client. Only repositories and services use it; views
/// and view models go through a repository instead.
SupabaseClient get supabaseClient => Supabase.instance.client;
