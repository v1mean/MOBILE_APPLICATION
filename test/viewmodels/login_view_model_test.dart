import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_application/viewmodels/auth/login_view_model.dart';

import '../helpers/fakes.dart';

void main() {
  Future<dynamic> login(FakeAuthRepository auth, {String role = 'student'}) {
    final vm = LoginViewModel(authRepository: auth);
    addTearDown(vm.dispose);
    return vm.login(email: 'a@b.c', password: 'secret12', role: role);
  }

  test('a student login succeeds and opens the student home', () async {
    final result = await login(
      FakeAuthRepository(
        loginResponse: {'success': true, 'message': 'Login Successful'},
      ),
    );

    expect(result.success, isTrue);
    expect(result.message, 'Login Successful');
    expect(result.isTeacher, isFalse);
  });

  test('the stored role wins over the login screen that was used', () async {
    final result = await login(
      FakeAuthRepository(
        loginResponse: {'success': true},
        storedRole: 'mentor',
      ),
      role: 'student',
    );

    expect(result.success, isTrue);
    expect(result.isTeacher, isTrue);
  });

  test('an unconfirmed email gets a clearer message', () async {
    final result = await login(
      FakeAuthRepository(
        loginResponse: {'success': false, 'message': 'Email not confirmed'},
      ),
    );

    expect(result.success, isFalse);
    expect(
      result.message,
      'Please confirm your email address before logging in.',
    );
  });

  test('a rejected login passes on the backend message', () async {
    final result = await login(
      FakeAuthRepository(
        loginResponse: {
          'success': false,
          'message': 'Incorrect password. Please try again.',
        },
      ),
    );

    expect(result.success, isFalse);
    expect(result.message, 'Incorrect password. Please try again.');
  });

  test('a network failure is reported, and the busy flag is cleared', () async {
    final vm = LoginViewModel(
      authRepository: FakeAuthRepository(loginError: Exception('offline')),
    );
    addTearDown(vm.dispose);

    final result = await vm.login(
      email: 'a@b.c',
      password: 'secret12',
      role: 'student',
    );

    expect(result.success, isFalse);
    expect(result.message, startsWith('Error connecting to server:'));
    expect(vm.isBusy, isFalse);
  });
}
