import 'dart:async';
import '../../constants/course_categories.dart';
import '../../models/mentor.dart';
import '../../models/user_profile.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/mentor_repository.dart';
import '../../repositories/user_repository.dart';
import '../base_view_model.dart';

class SearchViewModel extends BaseViewModel {
  SearchViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required MentorRepository mentorRepository,
  }) : _auth = authRepository,
       _users = userRepository,
       _mentorRepo = mentorRepository;

  static const double priceFloor = 0;
  static const double priceCeiling = 200;

  final AuthRepository _auth;
  final UserRepository _users;
  final MentorRepository _mentorRepo;

  // ── Filter state ──────────────────────────────────────────────────────────
  String _query = '';
  String? _selectedSubjectId;
  String? _selectedSubjectName;
  String? _filterDay;
  String? _filterCity;
  double _minPrice = priceFloor;
  double _maxPrice = priceCeiling;

  // ── Data ──────────────────────────────────────────────────────────────────
  List<Mentor> _allMentors = [];
  List<Mentor> _mentors = [];
  List<Map<String, dynamic>> _subjects = [];
  bool _isLoading = false;
  bool _isLoadingSubjects = true;
  UserProfile? _userProfile;
  Timer? _debounce;

  String get query => _query;
  String? get selectedSubjectId => _selectedSubjectId;
  String? get selectedSubjectName => _selectedSubjectName;
  String? get filterDay => _filterDay;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;

  /// The mentors that match the current search text and filters.
  List<Mentor> get mentors => _mentors;
  List<Map<String, dynamic>> get subjects => _subjects;
  bool get isLoading => _isLoading;
  bool get isLoadingSubjects => _isLoadingSubjects;

  bool get hasActiveFilters =>
      (_selectedSubjectId != null) ||
      (_filterDay != null) ||
      (_filterCity?.isNotEmpty ?? false) ||
      _minPrice > priceFloor ||
      _maxPrice < priceCeiling;

  String? get displayAvatar {
    if (_userProfile?.profileImage != null &&
        _userProfile!.profileImage.isNotEmpty) {
      return _userProfile!.profileImage;
    }
    final metaAvatar = _auth.metadataAvatar;
    if (metaAvatar != null && metaAvatar.isNotEmpty) {
      return metaAvatar;
    }
    return null;
  }

  String get displayName {
    if (_userProfile?.name != null && _userProfile!.name.isNotEmpty) {
      return _userProfile!.name;
    }
    return _auth.metadataName ?? 'User';
  }

  void load() {
    loadUserProfile();
    _loadSubjects();
    _initialLoad();
  }

  Future<void> loadUserProfile() async {
    final userId = _auth.currentUserId;
    if (userId == null) return;

    try {
      final data = await _users.fetchUserRow(userId);
      if (data != null) {
        _userProfile = UserProfile.fromJson(data);
        notifyListeners();
        return;
      }
    } catch (_) {}

    try {
      final data2 = await _users.fetchProfileRow(userId);
      if (data2 != null) {
        _userProfile = UserProfile(
          userId: data2['id'],
          createdAt: DateTime.now(),
          name: data2['full_name'] ?? '',
          email: data2['email'] ?? '',
          phone: data2['phone'] ?? '',
          role: data2['role'] ?? 'Student',
          profileImage: data2['avatar_url'] ?? '',
          location: data2['city'] ?? '',
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  void _loadSubjects() {
    // Populate all course categories as subject filter chips
    _subjects = <Map<String, dynamic>>[
      {'name': 'All', 'id': null},
      ...kCourseCategories.map((c) => {'name': c, 'id': c}),
    ];
    _isLoadingSubjects = false;
    notifyListeners();
  }

  Future<void> _initialLoad() async {
    _isLoading = true;
    notifyListeners();
    _allMentors = await _mentorRepo.fetchMentorDirectory();
    _applyFilter();
  }

  /// Reloads the mentor list and re-applies the current filters.
  Future<void> refresh() async {
    _allMentors = await _mentorRepo.fetchMentorDirectory();
    _applyFilter();
  }

  /// Updates the search text; filtering waits until typing pauses.
  void setQuery(String value) {
    _query = value;
    notifyListeners();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _applyFilter);
  }

  void selectSubject(String? id, String label) {
    _selectedSubjectId = id;
    _selectedSubjectName = id == null ? null : label;
    _applyFilter();
  }

  void clearSubject() {
    _selectedSubjectId = null;
    _selectedSubjectName = null;
    _applyFilter();
  }

  /// Selects [day], or clears the day filter if it is already selected.
  void toggleDay(String day) {
    _filterDay = _filterDay == day ? null : day;
    _applyFilter();
  }

  void clearDay() {
    _filterDay = null;
    _applyFilter();
  }

  void setPriceRange(double min, double max) {
    _minPrice = min;
    _maxPrice = max;
    _applyFilter();
  }

  void resetPriceRange() => setPriceRange(priceFloor, priceCeiling);

  void clearAllFilters() {
    _selectedSubjectId = null;
    _selectedSubjectName = null;
    _filterDay = null;
    _filterCity = null;
    _minPrice = priceFloor;
    _maxPrice = priceCeiling;
    _query = '';
    _applyFilter();
  }

  void _applyFilter() {
    if (isDisposed) return;

    final q = _query.trim().toLowerCase();
    _mentors = _allMentors.where((m) {
      // 1. Text Search: name, subject, or bio
      if (q.isNotEmpty) {
        final nameMatch = m.name.toLowerCase().contains(q);
        final subjectMatch = m.subject.toLowerCase().contains(q);
        final bioMatch = m.bio.toLowerCase().contains(q);
        if (!nameMatch && !subjectMatch && !bioMatch) {
          return false;
        }
      }

      // 2. Subject filter
      if (_selectedSubjectName != null &&
          _selectedSubjectName != 'All' &&
          _selectedSubjectName!.isNotEmpty) {
        final selSub = _selectedSubjectName!.toLowerCase();
        final mSub = m.subject.toLowerCase();
        if (!mSub.contains(selSub) && !selSub.contains(mSub)) {
          return false;
        }
      }

      // 3. Price filter
      if (m.bookingPrice < _minPrice || m.bookingPrice > _maxPrice) {
        return false;
      }

      return true;
    }).toList();

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
