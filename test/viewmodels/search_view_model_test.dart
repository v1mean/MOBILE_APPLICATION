import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_application/viewmodels/student/search_view_model.dart';

import '../helpers/fakes.dart';

void main() {
  late SearchViewModel vm;

  setUp(() async {
    vm = SearchViewModel(
      authRepository: FakeAuthRepository(),
      userRepository: FakeUserRepository(),
      mentorRepository: FakeMentorRepository([
        mentor(id: '1', name: 'Alice', subject: 'Math', price: 20),
        mentor(id: '2', name: 'Bob', subject: 'Physic', price: 60),
        mentor(
          id: '3',
          name: 'Chenda',
          subject: 'English',
          price: 150,
          bio: 'IELTS coach',
        ),
      ]),
    );
    vm.load();
    await pumpEventQueue();
  });

  tearDown(() => vm.dispose());

  test('shows every mentor once loaded', () {
    expect(vm.isLoading, isFalse);
    expect(vm.mentors.map((m) => m.name), ['Alice', 'Bob', 'Chenda']);
    expect(vm.hasActiveFilters, isFalse);
  });

  test('offers "All" plus every course category as a subject filter', () {
    expect(vm.isLoadingSubjects, isFalse);
    expect(vm.subjects.first, {'name': 'All', 'id': null});
    expect(vm.subjects.length, greaterThan(1));
  });

  test('filters by subject', () {
    vm.selectSubject('Physic', 'Physic');

    expect(vm.mentors.map((m) => m.name), ['Bob']);
    expect(vm.hasActiveFilters, isTrue);
  });

  test('filters by price range', () {
    vm.setPriceRange(50, 200);

    expect(vm.mentors.map((m) => m.name), ['Bob', 'Chenda']);
  });

  test('search text matches name, subject or bio after typing pauses', () async {
    vm.setQuery('ielts');
    expect(vm.query, 'ielts');
    // Filtering is debounced, so nothing has changed yet.
    expect(vm.mentors.length, 3);

    await Future<void>.delayed(const Duration(milliseconds: 300));

    expect(vm.mentors.map((m) => m.name), ['Chenda']);
  });

  test('toggling the same day twice clears the day filter', () {
    vm.toggleDay('Mon');
    expect(vm.filterDay, 'Mon');

    vm.toggleDay('Mon');
    expect(vm.filterDay, isNull);
  });

  test('clearing all filters brings every mentor back', () {
    vm.selectSubject('Math', 'Math');
    vm.setPriceRange(0, 10);
    expect(vm.mentors, isEmpty);

    vm.clearAllFilters();

    expect(vm.mentors.length, 3);
    expect(vm.hasActiveFilters, isFalse);
    expect(vm.minPrice, SearchViewModel.priceFloor);
    expect(vm.maxPrice, SearchViewModel.priceCeiling);
  });

  test('falls back to the sign-in name when there is no saved profile', () {
    final named = SearchViewModel(
      authRepository: FakeAuthRepository(name: 'Dara'),
      userRepository: FakeUserRepository(),
      mentorRepository: FakeMentorRepository(const []),
    );
    addTearDown(named.dispose);

    expect(named.displayName, 'Dara');
    expect(vm.displayName, 'User');
  });
}
