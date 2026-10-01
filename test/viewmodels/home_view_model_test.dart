import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_application/constants/course_categories.dart';
import 'package:mobile_application/models/mentor.dart';
import 'package:mobile_application/viewmodels/student/home_view_model.dart';

import '../helpers/fakes.dart';

void main() {
  HomeViewModel build({
    FakeAuthRepository? auth,
    FakeUserRepository? users,
    FakeCourseRepository? courses,
  }) {
    final vm = HomeViewModel(
      authRepository: auth ?? FakeAuthRepository(),
      userRepository: users ?? FakeUserRepository(),
      mentorRepository: FakeMentorRepository([mentor(id: '1', name: 'Alice')]),
      courseRepository: courses ?? FakeCourseRepository(),
    );
    addTearDown(vm.dispose);
    return vm;
  }

  const robotics = FeaturedCourse(
    id: 9,
    mentorName: 'Bob',
    subject: 'Robotics',
    cardColor: 'blue',
    imageUrl: '',
  );

  test('every standard category gets a featured card', () async {
    final vm = build();
    await vm.load();

    expect(vm.isLoadingFeatured, isFalse);
    expect(vm.featuredCourses.map((c) => c.subject), kCourseCategories);
    // No real course behind them yet, so they are placeholders.
    expect(vm.featuredCourses.every((c) => c.id == -1), isTrue);
  });

  test('a real featured course replaces its category placeholder', () async {
    final real = FeaturedCourse(
      id: 7,
      mentorName: 'Alice',
      subject: kCourseCategories.first,
      cardColor: 'orange',
      imageUrl: '',
    );
    final vm = build(courses: FakeCourseRepository(featured: [real]));
    await vm.load();

    expect(vm.featuredCourses.first.id, 7);
    expect(vm.featuredCourses.length, kCourseCategories.length);
  });

  test('a course in an unlisted category is added after the standard ones',
      () async {
    final vm = build(courses: FakeCourseRepository(featured: [robotics]));
    await vm.load();

    expect(vm.featuredCourses.length, kCourseCategories.length + 1);
    expect(vm.featuredCourses.last.subject, 'Robotics');
  });

  test('still shows the standard categories when the database fails',
      () async {
    final vm = build(
      courses: FakeCourseRepository(featuredError: Exception('offline')),
    );
    await vm.load();

    expect(vm.isLoadingFeatured, isFalse);
    expect(vm.featuredCourses.map((c) => c.subject), kCourseCategories);
  });

  test('loads the popular mentors', () async {
    final vm = build();
    expect(vm.isLoadingMentors, isTrue);

    await vm.load();

    expect(vm.isLoadingMentors, isFalse);
    expect(vm.popularMentors.single.name, 'Alice');
  });

  group('display name', () {
    test('uses the saved profile name first', () async {
      final vm = build(
        auth: FakeAuthRepository(userId: 'u1', name: 'From Google'),
        users: FakeUserRepository(
          userRow: {'user_id': 'u1', 'name': 'Saved Name', 'role': 'student'},
        ),
      );
      await vm.load();

      expect(vm.displayName, 'Saved Name');
      expect(vm.role, 'student');
    });

    test('falls back to the sign-in name', () async {
      final vm = build(auth: FakeAuthRepository(userId: 'u1', name: 'Dara'));
      await vm.load();

      expect(vm.displayName, 'Dara');
    });

    test('shows Guest in guest mode', () async {
      final vm = build(auth: FakeAuthRepository(guest: true));
      await vm.load();

      expect(vm.displayName, 'Guest');
      expect(vm.displayAvatar, isNull);
    });
  });
}
