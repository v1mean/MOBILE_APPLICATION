import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_application/viewmodels/teacher/teacher_students_view_model.dart';

import '../helpers/fakes.dart';

void main() {
  TeacherStudentsViewModel build({
    FakeAuthRepository? auth,
    FakeBookingRepository? bookings,
    FakeUserRepository? users,
  }) {
    final vm = TeacherStudentsViewModel(
      authRepository: auth ?? FakeAuthRepository(userId: 't1', token: 'tok'),
      userRepository: users ?? FakeUserRepository(),
      bookingRepository: bookings ?? FakeBookingRepository(),
    );
    addTearDown(vm.dispose);
    return vm;
  }

  test('lists each student once, however many bookings they made', () async {
    final vm = build(
      bookings: FakeBookingRepository(
        bookings: [
          {'student_id': 's1', 'student_name': 'Sok', 'student_city': 'PP'},
          {'student_id': 's1', 'student_name': 'Sok', 'student_city': 'PP'},
          {'student_id': 's2', 'student_name': 'Pich'},
          {'student_id': null, 'student_name': 'Nobody'},
        ],
      ),
    );

    await vm.loadStudents();

    expect(vm.isLoading, isFalse);
    expect(vm.error, isNull);
    expect(vm.students.map((s) => s.name), ['Sok', 'Pich']);
    expect(vm.students.first.location, 'PP');
    expect(vm.students.last.location, 'No Location');
  });

  test('reports a failure to load', () async {
    final vm = build(
      bookings: FakeBookingRepository(error: Exception('offline')),
    );

    await vm.loadStudents();

    expect(vm.isLoading, isFalse);
    expect(vm.error, 'Failed to load students.');
    expect(vm.students, isEmpty);
  });

  test('stops loading when nobody is signed in', () async {
    final vm = build(auth: FakeAuthRepository());

    await vm.loadStudents();

    expect(vm.isLoading, isFalse);
    expect(vm.students, isEmpty);
  });

  test('header shows the teacher name, with no avatar when it is blank',
      () async {
    final vm = build(
      users: FakeUserRepository(
        profileRow: {'full_name': 'Thyrak', 'avatar_url': ''},
      ),
    );
    expect(vm.userName, 'Teacher');

    await vm.loadHeader();

    expect(vm.userName, 'Thyrak');
    expect(vm.avatarUrl, isNull);
  });
}
