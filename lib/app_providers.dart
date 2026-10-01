import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'repositories/auth_repository.dart';
import 'repositories/booking_repository.dart';
import 'repositories/course_repository.dart';
import 'repositories/mentor_repository.dart';
import 'repositories/payment_repository.dart';
import 'repositories/student_notification_repository.dart';
import 'repositories/teacher_course_store.dart';
import 'repositories/teacher_notification_repository.dart';
import 'repositories/user_repository.dart';
import 'viewmodels/student/student_notifications_view_model.dart';
import 'viewmodels/teacher/teacher_notifications_view_model.dart';

/// App-wide dependencies, placed above the router so every screen and every
/// view model can reach them.
///
/// Repositories are the only layer that talks to Supabase or the backend.
/// View models receive the repositories they need when the router creates
/// them (see router.dart). The two notification view models are created here
/// instead because the bells that show them appear on several screens.
List<SingleChildWidget> buildAppProviders({
  StudentNotificationRepository? studentNotifications,
}) {
  return [
    Provider<AuthRepository>(create: (_) => AuthRepository()),
    Provider<UserRepository>(create: (_) => UserRepository()),
    Provider<MentorRepository>(create: (_) => MentorRepository()),
    Provider<CourseRepository>(create: (_) => CourseRepository()),
    Provider<BookingRepository>(create: (_) => BookingRepository()),
    Provider<PaymentRepository>(create: (_) => PaymentRepository()),
    Provider<TeacherNotificationRepository>(
      create: (_) => TeacherNotificationRepository(),
    ),
    ChangeNotifierProvider<TeacherCourseStore>(
      create: (_) => TeacherCourseStore(),
    ),
    if (studentNotifications != null)
      ChangeNotifierProvider<StudentNotificationRepository>.value(
        value: studentNotifications,
      )
    else
      ChangeNotifierProvider<StudentNotificationRepository>(
        create: (_) => StudentNotificationRepository()..init(),
      ),
    ChangeNotifierProvider<StudentNotificationsViewModel>(
      create: (context) => StudentNotificationsViewModel(
        repository: context.read<StudentNotificationRepository>(),
      ),
    ),
    ChangeNotifierProvider<TeacherNotificationsViewModel>(
      create: (context) => TeacherNotificationsViewModel(
        authRepository: context.read<AuthRepository>(),
        notificationRepository: context.read<TeacherNotificationRepository>(),
      ),
    ),
  ];
}
