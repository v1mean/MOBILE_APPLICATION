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

final List<Mentor> defaultMentors = [
  Mentor(
    id: '1',
    name: 'Ms. Sok ChanNara',
    subject: 'Geography',
    experience: 'Experience in teaching for 10years',
    timeSlot: '10:00 AM - 11:00 AM',
    avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&fit=crop&crop=faces',
    rating: 4.8,
    students: 120128,
    classes: 2330128,
    followers: 5350738,
    bookingPrice: 300,
    bio: "I've been teaching Geography for about 10 years now. Experienced in helping students achieve top scores in their Bac II examinations.",
    courses: sampleCourses,
  ),
  Mentor(
    id: '2',
    name: 'Pro. Sok Thavy',
    subject: 'Chemistry',
    experience: 'Experience in teaching for 10years',
    timeSlot: '2:00 PM - 3:00 PM',
    avatarUrl: 'https://images.unsplash.com/photo-1580894732444-8ecded7900cd?w=400&fit=crop&crop=faces',
    rating: 4.9,
    students: 95420,
    classes: 1820000,
    followers: 4200000,
    bookingPrice: 300,
    bio: "I've been teaching Chemistry for about 10 years now. Specializing in organic chemistry formulas and Bac II test preparation.",
    courses: sampleCourses,
  ),
  Mentor(
    id: '3',
    name: 'Pro. Sopheap',
    subject: 'Math',
    experience: 'Experience in teaching for 8years',
    timeSlot: '9:00 AM - 10:00 AM',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&fit=crop&crop=faces',
    rating: 4.7,
    students: 80000,
    classes: 1200000,
    followers: 3800000,
    bookingPrice: 250,
    bio: 'Passionate math educator with 8 years of experience helping students excel in advanced algebra, trigonometry, and calculus.',
    courses: sampleCourses,
  ),
  Mentor(
    id: '4',
    name: 'Pro. Dara',
    subject: 'Geography',
    experience: 'Experience in teaching for 6years',
    timeSlot: '11:00 AM - 12:00 PM',
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&fit=crop&crop=faces',
    rating: 4.6,
    students: 65000,
    classes: 900000,
    followers: 2500000,
    bookingPrice: 200,
    bio: 'Geography expert with 6 years of academic teaching experience focusing on regional geography and spatial analysis.',
    courses: sampleCourses,
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
