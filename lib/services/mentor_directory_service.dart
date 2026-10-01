import 'package:flutter/foundation.dart';
import '../constants/mock_data.dart';
import '../main.dart';
import '../models/mentor.dart';

/// Single source for the mentor lists on the Home and Search screens.
class MentorDirectoryService {
  static const _fallbackAvatar =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&fit=crop';

  /// Mentors that own at least one course, followed by the mock mentors so
  /// every subject is represented.
  ///
  /// `tutor_search_view` only carries the name, avatar and course columns, so
  /// price, rating, experience and student count come from `tutor_profiles` —
  /// the same table the mentor profile page reads.
  static Future<List<Mentor>> fetchMentors() async {
    final Map<String, Mentor> uniqueMentors = {};

    try {
      final rows =
          await JomnesDB.from(
                'tutor_search_view',
              ).select().order('course_id', ascending: false)
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

  static Future<Map<String, Map<String, dynamic>>> _fetchTutorProfiles(
    List<String> tutorIds,
  ) async {
    if (tutorIds.isEmpty) return {};

    try {
      final data =
          await JomnesDB.from('tutor_profiles')
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
}
