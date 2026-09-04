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
    final users = json['Users'] as Map<String, dynamic>? ?? {};
    
    return Mentor(
      id: json['tutor_id'] as String? ?? '',
      name: users['name'] as String? ?? 'Unknown Mentor',
      subject: 'General', 
      experience: '${json['experience_years'] ?? 0} years experience',
      timeSlot: 'Flexible',
      avatarUrl: users['profile_image'] as String? ?? 'https://api.dicebear.com/9.x/avataaars/png?seed=fallback',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      students: 120, // UI fallback since not in schema yet
      classes: 50,
      followers: 300,
      bookingPrice: (json['hourly_rate'] as num?)?.toDouble() ?? 0.0,
      bio: json['bio'] as String? ?? 'No bio provided.',
      courses: [], // Mock courses handled separately
    );
  }
}

class Course {
  final int id;
  final String title;
  final String description;
  final double rating;
  final int durationHours;
  final bool isFavorited;
  final bool isLive;
  final int? minutesRemaining;
  final double? progress;
  final String cardColor; // 'pink' or 'blue'

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.rating,
    required this.durationHours,
    this.isFavorited = false,
    this.isLive = false,
    this.minutesRemaining,
    this.progress,
    this.cardColor = 'pink',
  });
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
}
