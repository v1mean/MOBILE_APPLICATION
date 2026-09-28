const fs = require('fs');

const file = 'lib/screens/teacher_students_screen.dart';
let content = fs.readFileSync(file, 'utf8');

// Replace the static mock data block
const targetMock = `  static final _students = [
    _StudentItem(
      'Srey Pich',
      '098 765 432',
      'Preak Leab',
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
    ),
    _StudentItem(
      'Bros Sok',
      '056 789 123',
      'Orussey',
      'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150&auto=format&fit=crop&q=80',
    ),
    _StudentItem(
      'Socheatre',
      '012 345 678',
      'Chroy Chongva',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
    ),
    _StudentItem(
      'Ni Ta',
      '099 887 766',
      'Toul Kork',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
    ),
  ];`;

const replacementState = `  List<_StudentItem> _students = [];
  bool _isLoading = true;
  String? _error;`;

content = content.replace(targetMock, replacementState);

// Replace initState to include _fetchStudents
const targetInit = `  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }`;

const replacementInit = `  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _fetchStudents();
  }`;

content = content.replace(targetInit, replacementInit);

// Insert _fetchStudents function
const targetFetch = `  Future<void> _fetchProfile() async {`;

const replacementFetch = `  Future<void> _fetchStudents() async {
    try {
      final session = JomnesDB.auth.currentSession;
      if (session == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final bookings = await ApiService.fetchTeacherBookings(session.accessToken);
      
      final Map<String, _StudentItem> uniqueStudents = {};
      
      for (final b in bookings) {
        final sId = b['student_id'] as String?;
        if (sId == null || uniqueStudents.containsKey(sId)) continue;
        
        uniqueStudents[sId] = _StudentItem(
          b['student_name'] as String? ?? 'Unknown Student',
          b['student_phone'] as String? ?? '',
          b['student_city'] as String? ?? 'No Location',
          b['student_avatar'] as String? ?? '',
        );
      }

      if (mounted) {
        setState(() {
          _students = uniqueStudents.values.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load students.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchProfile() async {`;

content = content.replace(targetFetch, replacementFetch);

// Replace body with loading/empty state handling
const targetList = `                      ..._students.map((s) => _StudentCard(student: s)),`;

const replacementList = `                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: CircularProgressIndicator(color: AppColors.accentBlue),
                          ),
                        )
                      else if (_error != null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Text(_error!, style: GoogleFonts.inter(color: Colors.red)),
                          ),
                        )
                      else if (_students.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: Column(
                              children: [
                                Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
                                const SizedBox(height: 16),
                                Text(
                                  "No students yet",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._students.map((s) => _StudentCard(student: s)),`;

content = content.replace(targetList, replacementList);

fs.writeFileSync(file, content);
