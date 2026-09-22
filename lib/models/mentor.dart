class Mentor {
  final String id;
  final String name;
  final String subject;
  final String experience;
  final String timeSlot;
  final String avatarUrl;
  final double rating;
  final int students;
  final int classes;
  final int followers;
  final double bookingPrice;
  final String bio;
  final List<Course> courses;

  const Mentor({
    required this.id,
    required this.name,
    required this.subject,
    required this.experience,
    required this.timeSlot,
    required this.avatarUrl,
    required this.rating,
    required this.students,
    required this.classes,
    required this.followers,
    required this.bookingPrice,
    required this.bio,
    required this.courses,
  });

  factory Mentor.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    // Also support old shape for backwards compat
    final users = user ?? (json['Users'] as Map<String, dynamic>? ?? {});

    // Extract subjects from tutor_subjects array or subject column
    final rawSubject = json['subject'] as String? ?? json['category'] as String?;
    final tutorSubjects = json['tutor_subjects'] as List<dynamic>? ?? [];
    final subjectNames = tutorSubjects
        .map((ts) {
          final subj = ts['Subjects'] as Map<String, dynamic>?;
          return subj?['name'] as String? ?? '';
        })
        .where((s) => s.isNotEmpty)
        .toList();

    String subject;
    if (rawSubject != null && rawSubject.isNotEmpty && rawSubject != 'General') {
      subject = rawSubject;
    } else if (subjectNames.isNotEmpty) {
      subject = subjectNames.first;
    } else {
      subject = inferMentorSubject(json['bio'], json['education']);
    }

    // Extract availability days
    final availList = json['availability'] as List<dynamic>? ?? [];
    final availDays = availList
        .where((a) => a['is_available'] == true)
        .map((a) {
          final day = a['day_of_week'] as String? ?? '';
          return day.length >= 3 ? day.substring(0, 3) : day; // 'Monday' -> 'Mon'
        })
        .toList();
    final availText = availDays.isNotEmpty ? availDays.join(', ') : 'Flexible';

    return Mentor(
      id: json['tutor_id'] as String? ?? '',
      name: users['name'] as String? ?? 'Unknown Mentor',
      subject: subject,
      experience: '${json['experience_years'] ?? 0} yrs exp',
      timeSlot: availText,
      avatarUrl: users['profile_image'] as String? ?? 'https://api.dicebear.com/9.x/avataaars/png?seed=fallback',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      students: (json['total_students'] as num?)?.toInt() ?? 0,
      classes: 0,
      followers: (json['review_count'] as num?)?.toInt() ?? 0,
      bookingPrice: (json['hourly_rate'] as num?)?.toDouble() ?? 0.0,
      bio: json['bio'] as String? ?? 'No bio provided.',
      courses: [],
    );
  }

  static String inferMentorSubject(dynamic bio, dynamic edu) {
    final text = '${bio ?? ''} ${edu ?? ''}'.toLowerCase();
    if (text.contains('math') || text.contains('calculus')) return 'Math';
    if (text.contains('physic')) return 'Physic';
    if (text.contains('khmer')) return 'Khmer';
    if (text.contains('english')) return 'English';
    if (text.contains('chinese')) return 'Chinese';
    if (text.contains('spanish')) return 'Spanish';
    if (text.contains('primary')) return 'Primary School';
    if (text.contains('high school')) return 'High School';
    if (text.contains('gym') || text.contains('fitness')) return 'Gym Trainer';
    if (text.contains('volleyball')) return 'Volleyball Coach';
    if (text.contains('football') || text.contains('soccer')) return 'Football Coach';
    if (text.contains('swimming')) return 'Swimming Coach';
    if (text.contains('driving')) return 'Teach Driving';
    if (text.contains('badminton')) return 'Badminton Coach';
    return 'General';
  }
}

class Course {
  final int id;
  final String? tutorId;
  final String title;
  final String description;
  final double rating;
  final int durationHours;
  final bool isFavorited;
  final bool isLive;
  final int? minutesRemaining;
  final double? progress;
  final String cardColor; // 'pink' or 'blue'
  final String category;

  const Course({
    required this.id,
    this.tutorId,
    required this.title,
    required this.description,
    required this.rating,
    required this.durationHours,
    this.isFavorited = false,
    this.isLive = false,
    this.minutesRemaining,
    this.progress,
    this.cardColor = 'pink',
    this.category = 'General',
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int? ?? 0,
      tutorId: json['tutor_id'] as String?,
      title: json['title'] as String? ?? 'Untitled Course',
      description: json['description'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      durationHours: json['duration_hours'] as int? ?? 0,
      isFavorited: json['is_favorited'] as bool? ?? false,
      isLive: json['is_live'] as bool? ?? false,
      minutesRemaining: json['minutes_remaining'] as int?,
      progress: (json['progress'] as num?)?.toDouble(),
      cardColor: json['card_color'] as String? ?? 'pink',
      category: json['category'] as String? ?? 'General',
    );
  }
}

class FeaturedCourse {
  final int id;
  final String mentorName;
  final String subject;
  final String cardColor;
  final String imageUrl;

  const FeaturedCourse({
    required this.id,
    required this.mentorName,
    required this.subject,
    required this.cardColor,
    required this.imageUrl,
  });

  factory FeaturedCourse.fromJson(Map<String, dynamic> json) {
    final users = json['Users'] as Map<String, dynamic>? ?? {};
    final title = json['title'] as String? ?? '';
    final rawCategory = json['category'] as String? ?? json['subject'] as String? ?? '';

    String subject = rawCategory;
    if (subject.isEmpty || subject == 'General') {
      final t = title.toLowerCase();
      if (t.contains('math') || t.contains('calculus')) {
        subject = 'Math';
      } else if (t.contains('physic')) {
        subject = 'Physic';
      } else if (t.contains('khmer')) {
        subject = 'Khmer';
      } else if (t.contains('english')) {
        subject = 'English';
      } else if (t.contains('chinese')) {
        subject = 'Chinese';
      } else if (t.contains('spanish')) {
        subject = 'Spanish';
      } else if (t.contains('primary')) {
        subject = 'Primary School';
      } else if (t.contains('high school')) {
        subject = 'High School';
      } else if (t.contains('gym') || t.contains('fitness')) {
        subject = 'Gym Trainer';
      } else if (t.contains('volleyball')) {
        subject = 'Volleyball Coach';
      } else if (t.contains('football') || t.contains('soccer')) {
        subject = 'Football Coach';
      } else if (t.contains('swimming')) {
        subject = 'Swimming Coach';
      } else if (t.contains('driving')) {
        subject = 'Teach Driving';
      } else if (t.contains('badminton')) {
        subject = 'Badminton Coach';
      } else if (t.contains('geography')) {
        subject = 'General';
      } else if (t.contains('chemistry')) {
        subject = 'Physic';
      } else if (t.contains('history')) {
        subject = 'High School';
      } else if (t.contains('biology')) {
        subject = 'High School';
      } else {
        subject = 'General';
      }
    }

    return FeaturedCourse(
      id: json['id'] as int? ?? 0,
      mentorName: users['name'] as String? ?? 'Unknown Mentor',
      subject: subject,
      cardColor: json['card_color'] as String? ?? 'orange',
      imageUrl: json['image_url'] as String? ?? 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=200&q=80',
    );
  }
}
