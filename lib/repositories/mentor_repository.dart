import 'package:flutter/foundation.dart';
import '../constants/mock_data.dart';
import '../models/mentor.dart';
import '../services/api_service.dart';
import '../services/supabase_service.dart';

/// Mentors, their profiles and their reviews.
class MentorRepository {
  static const _fallbackAvatar =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&fit=crop';

  /// Mentors that own at least one course, followed by the mock mentors so
  /// every subject is represented. Used by the Home and Search screens.
  ///
  /// `tutor_search_view` only carries the name, avatar and course columns, so
  /// price, rating, experience and student count come from `tutor_profiles` —
  /// the same table the mentor profile page reads.
  Future<List<Mentor>> fetchMentorDirectory() async {
    final Map<String, Mentor> uniqueMentors = {};

    try {
      final rows =
          await supabaseClient
                  .from('tutor_search_view')
                  .select()
                  .order('course_id', ascending: false)
              as List;

      final tutorIds = rows
          .map((row) => row['tutor_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      final profiles = await _fetchTutorProfiles(tutorIds);

      for (final row in rows) {
        final tutorId = row['tutor_id']?.toString() ?? '';
        if (tutorId.isEmpty || uniqueMentors.containsKey(tutorId)) continue;

        final profile = profiles[tutorId] ?? const <String, dynamic>{};
        final avatar = row['tutor_avatar']?.toString() ?? '';

        uniqueMentors[tutorId] = Mentor(
          id: tutorId,
          name: row['tutor_name'] ?? 'Mentor',
          subject: Mentor.inferMentorSubject(
            profile['bio']?.toString() ?? '',
            null,
          ),
          experience: '${profile['experience_years'] ?? 5} years experience',
          timeSlot: 'Flexible',
          avatarUrl: avatar.isNotEmpty ? avatar : _fallbackAvatar,
          rating: (profile['rating'] as num?)?.toDouble() ?? 4.8,
          students: (profile['total_students'] as num?)?.toInt() ?? 120,
          classes: 50,
          followers: 300,
          bookingPrice: (profile['hourly_rate'] as num?)?.toDouble() ?? 35.0,
          bio: profile['bio']?.toString() ?? 'Experienced mentor.',
          courses: [],
        );
      }
    } catch (err) {
      debugPrint('Error fetching mentors: $err');
    }

    for (final mock in kMockMentors) {
      uniqueMentors.putIfAbsent(mock.id, () => mock);
    }

    return uniqueMentors.values.toList();
  }

  Future<Map<String, Map<String, dynamic>>> _fetchTutorProfiles(
    List<String> tutorIds,
  ) async {
    if (tutorIds.isEmpty) return {};

    try {
      final data =
          await supabaseClient
                  .from('tutor_profiles')
                  .select(
                    'tutor_id, hourly_rate, rating, experience_years, total_students, bio',
                  )
                  .inFilter('tutor_id', tutorIds)
              as List;

      return {
        for (final row in data)
          row['tutor_id'].toString(): Map<String, dynamic>.from(row as Map),
      };
    } catch (err) {
      debugPrint('Error fetching tutor profiles: $err');
      return {};
    }
  }

  /// Every account registered as a mentor or tutor, followed by the mock
  /// mentors. Used by the course listing screen. Falls back to the mock
  /// mentors alone when the database can't be reached.
  Future<List<Mentor>> fetchMentorsByRole() async {
    try {
      final usersData = await supabaseClient
          .from('Users')
          .select()
          .or('role.eq.mentor,role.eq.tutor');

      final userList = usersData as List;
      final userIds = userList.map((u) => u['user_id']).toList();

      List<dynamic> profiles = [];
      if (userIds.isNotEmpty) {
        profiles =
            await supabaseClient
                    .from('tutor_profiles')
                    .select()
                    .filter('user_id', 'in', userIds)
                as List;
      }
      final profileMap = {for (var p in profiles) p['user_id'].toString(): p};

      final mentors = userList.map((u) {
        final uid = u['user_id'].toString();
        final p = profileMap[uid] ?? {};
        final subject = (p['subject'] as String? ?? '').isNotEmpty
            ? p['subject'] as String
            : Mentor.inferMentorSubject(p['bio'], p['education']);

        final avatar =
            (u['profile_image'] != null &&
                u['profile_image'].toString().trim().isNotEmpty)
            ? u['profile_image'].toString()
            : _fallbackAvatar;

        return Mentor(
          id: uid,
          name: u['name'] ?? 'Mentor',
          subject: subject,
          experience: '${p['experience_years'] ?? 5} years experience',
          timeSlot: 'Flexible',
          avatarUrl: avatar,
          rating: (p['rating'] as num?)?.toDouble() ?? 4.9,
          students: (p['total_students'] as num?)?.toInt() ?? 120,
          classes: 50,
          followers: 300,
          bookingPrice: (p['hourly_rate'] as num?)?.toDouble() ?? 35.0,
          bio: p['bio'] ?? 'Experienced mentor.',
          courses: [],
        );
      }).toList();

      // Combine real mentors from database with mock mentors across all subjects
      final combinedMentors = <Mentor>[...mentors];
      final seenIds = mentors.map((m) => m.id).toSet();
      for (final mockM in kMockMentors) {
        if (seenIds.add(mockM.id)) {
          combinedMentors.add(mockM);
        }
      }

      return combinedMentors;
    } catch (e) {
      return kMockMentors;
    }
  }

  /// One mentor with their courses. Returns the matching mock mentor when the
  /// id isn't in the database or the lookup fails, and null when there is no
  /// mock either.
  Future<Mentor?> fetchMentorDetail(String mentorId) async {
    try {
      var user = await supabaseClient
          .from('Users')
          .select()
          .eq('user_id', mentorId)
          .maybeSingle();
      // The avatar may live in either table (social logins only fill
      // `profiles`), so read both rather than only falling back when the
      // `Users` row is missing.
      final profileRow = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', mentorId)
          .maybeSingle();
      user ??= profileRow;

      final avatarCandidates = [
        user?['profile_image'],
        profileRow?['avatar_url'],
        user?['avatar_url'],
      ].map((value) => value?.toString() ?? '').where((url) => url.isNotEmpty);
      final avatarUrl = avatarCandidates.isNotEmpty
          ? avatarCandidates.first
          : 'https://api.dicebear.com/9.x/avataaars/png?seed=$mentorId';

      var profile = await supabaseClient
          .from('tutor_profiles')
          .select()
          .eq('user_id', mentorId)
          .maybeSingle();
      profile ??= await supabaseClient
          .from('tutor_profiles')
          .select()
          .eq('tutor_id', mentorId)
          .maybeSingle();

      final coursesData = await supabaseClient
          .from('courses')
          .select()
          .eq('tutor_id', mentorId);

      final coursesList = (coursesData as List)
          .map((c) => Course.fromJson(c))
          .toList();

      if (user == null) return getMockMentorById(mentorId);

      final p = profile ?? {};
      final rawSub = p['subject'] as String? ?? p['category'] as String?;
      final subject =
          (rawSub != null && rawSub.isNotEmpty && rawSub != 'General')
          ? rawSub
          : Mentor.inferMentorSubject(p['bio'], p['education']);

      return Mentor(
        id: mentorId,
        name: user['name'] ?? user['full_name'] ?? 'Mentor',
        subject: subject,
        experience: '${p['experience_years'] ?? 5} years experience',
        timeSlot: 'Flexible',
        avatarUrl: avatarUrl,
        rating: (p['rating'] as num?)?.toDouble() ?? 4.8,
        students: (p['total_students'] as num?)?.toInt() ?? 120,
        classes: 50,
        followers: 300,
        bookingPrice: (p['hourly_rate'] as num?)?.toDouble() ?? 250.0,
        bio: p['bio'] ?? 'Experienced mentor.',
        courses: coursesList,
      );
    } catch (e) {
      return getMockMentorById(mentorId);
    }
  }

  Future<List<Map<String, dynamic>>> fetchReviews(String mentorId) =>
      ApiService.fetchMentorReviews(mentorId);

  Future<Map<String, dynamic>> submitReview({
    required String accessToken,
    required String mentorId,
    required double rating,
    String? comment,
  }) => ApiService.submitReview(
    accessToken: accessToken,
    mentorId: mentorId,
    rating: rating,
    comment: comment,
  );
}
