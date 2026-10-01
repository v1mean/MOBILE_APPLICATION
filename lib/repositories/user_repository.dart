import '../services/api_service.dart';
import '../services/supabase_service.dart';

/// Account details. The app keeps them in two tables: `Users` (name, phone,
/// location, profile image) and `profiles` (full name and avatar, filled by
/// social sign-in).
class UserRepository {
  Future<Map<String, dynamic>?> fetchUserRow(
    String userId, {
    String columns = '*',
  }) => supabaseClient
      .from('Users')
      .select(columns)
      .eq('user_id', userId)
      .maybeSingle();

  Future<Map<String, dynamic>?> fetchProfileRow(
    String userId, {
    String columns = '*',
  }) =>
      supabaseClient.from('profiles').select(columns).eq('id', userId).maybeSingle();

  Future<Map<String, dynamic>> updateProfile({
    required String accessToken,
    required String name,
    String? phone,
    String? location,
    String? role,
    String? profileImage,
  }) => ApiService.updateProfile(
    accessToken: accessToken,
    name: name,
    phone: phone,
    location: location,
    role: role,
    profileImage: profileImage,
  );

  Future<Map<String, dynamic>> uploadAvatar(
    String filePath,
    String accessToken,
  ) => ApiService.uploadAvatar(filePath, accessToken);
}
