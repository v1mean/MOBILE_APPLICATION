import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'repositories/auth_repository.dart';
import 'repositories/booking_repository.dart';
import 'repositories/course_repository.dart';
import 'repositories/mentor_repository.dart';
import 'repositories/payment_repository.dart';
import 'repositories/user_repository.dart';

/// App-wide dependencies, placed above the router so every screen and every
/// view model can reach them.
///
/// Repositories are the only layer that talks to Supabase or the backend.
/// View models receive the repositories they need when the router creates
/// them (see router.dart).
List<SingleChildWidget> buildAppProviders() {
  return [
    Provider<AuthRepository>(create: (_) => AuthRepository()),
    Provider<UserRepository>(create: (_) => UserRepository()),
    Provider<MentorRepository>(create: (_) => MentorRepository()),
    Provider<CourseRepository>(create: (_) => CourseRepository()),
    Provider<BookingRepository>(create: (_) => BookingRepository()),
    Provider<PaymentRepository>(create: (_) => PaymentRepository()),
  ];
}
