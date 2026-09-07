import '../models/mentor.dart';

final List<Course> sampleCourses = [
  Course(
    id: 1,
    title: 'Master Chemistry Formular / Bac II Preparation Course',
    description: 'Practice Exercise/ understand more about formula.',
    rating: 4.5,
    durationHours: 12,
    cardColor: 'pink',
    isLive: true,
    minutesRemaining: 30,
  ),
  Course(
    id: 2,
    title: 'Bac II Chemistry Most Practice Exercises',
    description: 'Practice Exercise/ understand more about formula.',
    rating: 4.3,
    durationHours: 10,
    cardColor: 'blue',
    progress: 0.35,
    isFavorited: true,
  ),
  Course(
    id: 3,
    title: 'Advanced Math Problem Solving',
    description: 'Deepen your understanding of algebra and calculus.',
    rating: 4.8,
    durationHours: 15,
    cardColor: 'pink',
  ),
];

final List<FeaturedCourse> featuredCourses = [
  FeaturedCourse(
    id: 1,
    mentorName: 'Pro. Sopheap',
    subject: 'Math',
    cardColor: 'orange',
    imageUrl:
        'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=200&q=80',
  ),
  FeaturedCourse(
    id: 2,
    mentorName: 'Pro. Dara',
    subject: 'Geography',
    cardColor: 'teal',
    imageUrl:
        'https://images.unsplash.com/photo-1529539795054-3c162aab037a?w=200&q=80',
  ),
  FeaturedCourse(
    id: 3,
    mentorName: 'Pro. Thavy',
    subject: 'Chemistry',
    cardColor: 'teal2',
    imageUrl:
        'https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?w=200&q=80',
  ),
];

class MockUserProfile {
  final String name;
  final String role;
  final String location;
  final String avatarUrl;

  MockUserProfile({
    required this.name,
    required this.role,
    required this.location,
    required this.avatarUrl,
  });
}

final MockUserProfile currentUserMock = MockUserProfile(
  name: 'Jessica Carl',
  role: 'Student',
  location: 'Phnom Penh, Cambodia',
  avatarUrl: 'https://api.dicebear.com/9.x/avataaars/png?seed=Jessica&backgroundColor=ffdfbf',
);
