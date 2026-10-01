import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../widgets/course_card.dart';
import '../../viewmodels/student/mentor_profile_view_model.dart';
import '../../theme/app_colors.dart';

class MentorProfileScreen extends StatefulWidget {
  const MentorProfileScreen({super.key});

  @override
  State<MentorProfileScreen> createState() => _MentorProfileScreenState();
}

class _MentorProfileScreenState extends State<MentorProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final MentorProfileViewModel _vm;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _vm = context.read<MentorProfileViewModel>();
    _vm.load().then((resumeBooking) {
      // Back from a paid Stripe Checkout: go straight to picking a slot.
      if (resumeBooking && mounted) _showBookingSheet();
    });
  }

  Future<void> _showBookingSheet() async {
    if (_vm.mentor == null) return;
    DateTime? selectedDate;
    String? selectedTime;
    final timeSlots = [
      '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM',
      '12:00 PM', '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM'
    ];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Book Session',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate == null
                            ? 'Select Date'
                            : '${selectedDate!.toLocal()}'.split(' ')[0],
                        style: GoogleFonts.inter(fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(
                              const Duration(days: 1),
                            ),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 60),
                            ),
                          );
                          if (date != null) {
                            setSheetState(() => selectedDate = date);
                          }
                        },
                        child: const Text('Pick Date'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Time Slot',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: timeSlots.map((slot) {
                      return ChoiceChip(
                        label: Text(slot),
                        selected: selectedTime == slot,
                        onSelected: (selected) {
                          setSheetState(
                            () => selectedTime = selected ? slot : null,
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          (selectedDate != null &&
                              selectedTime != null &&
                              !_vm.isBooking)
                          ? () {
                              Navigator.pop(context);
                              _confirmBooking(selectedDate!, selectedTime!);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Confirm Booking',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleInitialPayment() async {
    final outcome = await _vm.startPayment();
    if (!mounted) return;

    switch (outcome) {
      case PaymentStart.notLoggedIn:
        context.go('/login');
      case PaymentStart.redirecting:
        // The browser is leaving for Stripe Checkout; the booking sheet
        // opens when it comes back with a paid session.
        break;
      case PaymentStart.paid:
        _showBookingSheet();
      case PaymentStart.cancelled:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment failed or was cancelled.')),
        );
      case PaymentStart.error:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error initializing payment.')),
        );
    }
  }

  Future<void> _confirmBooking(DateTime date, String time) async {
    final result = await _vm.confirmBooking(date, time);
    if (!mounted) return;

    switch (result.status) {
      case BookingStatus.notLoggedIn:
        context.go('/login');
      case BookingStatus.booked:
        context.go('/courses');
      case BookingStatus.rejected:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Failed to book'),
            backgroundColor: Colors.red,
          ),
        );
      case BookingStatus.error:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error connecting to server'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatCount(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<MentorProfileViewModel>();
    if (_vm.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.pageBg,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final m = _vm.mentor;
    if (m == null) {
      return const Scaffold(
        backgroundColor: AppColors.pageBg,
        body: Center(child: Text('Mentor not found.')),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Close Icon
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 24,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // 3D Avatar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: SizedBox(
                        width: 98,
                        height: 98,
                        child: Image.network(
                          m.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: const Color(0xFFDFE2E6),
                                child: const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Name
                    // Name & Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          m.name,
                          style: GoogleFonts.inter(
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 28,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              m.rating.toStringAsFixed(1),
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Bio
                    Text(
                      m.bio,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.slateTextDark,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Action Buttons: Book Class vs Follow
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            onPressed: _vm.isBooking ? null : _handleInitialPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            child: _vm.isBooking
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Book Class | \$${m.bookingPrice.toInt()}',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _vm.toggleFollowing,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.border,
                              foregroundColor: AppColors.textPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            child: Text(
                              _vm.isFollowing ? 'Following' : 'Follow',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Stats Row
                    Row(
                      children: [
                        _StatItem(
                          label: 'Students',
                          value: _formatCount(m.students),
                        ),
                        _divider(),
                        _StatItem(
                          label: 'Classes',
                          value: _formatCount(m.classes),
                        ),
                        _divider(),
                        _StatItem(
                          label: 'Followers',
                          value: _formatCount(m.followers),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    // Tab Bar Container
                    Container(
                      height: 48,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFE2E6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                        unselectedLabelStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        labelColor: AppColors.textPrimary,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(12),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        tabs: const [
                          Tab(text: 'Courses'),
                          Tab(text: 'Source Files'),
                          Tab(text: 'Reviews'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tab Content
                    if (_tabController.index == 0)
                      // Courses List
                      ...m.courses.map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CourseCard(course: c),
                        ),
                      )
                    else if (_tabController.index == 2)
                      // Reviews List
                      _vm.reviews.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.rate_review_outlined,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No reviews yet.\nBe the first to leave one!',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        color: Colors.grey.shade500,
                                        fontSize: 15,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Column(
                              children: _vm.reviews.map((r) {
                                final user = r['Users'] ?? r['profiles'] ?? {};
                                final name = user['name'] ?? user['full_name'] ?? 'Student';
                                final avatar = user['profile_image'] ?? user['avatar_url'];
                                final initial = name.isNotEmpty
                                    ? name[0].toUpperCase()
                                    : 'S';

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor: const Color(
                                              0xFFFFD5DC,
                                            ),
                                            backgroundImage: avatar != null
                                                ? NetworkImage(avatar)
                                                : null,
                                            child: avatar == null
                                                ? Text(
                                                    initial,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.black,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              name,
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star_rounded,
                                                color: Colors.amber,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${r['rating']}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (r['comment'] != null &&
                                          r['comment']
                                              .toString()
                                              .trim()
                                              .isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        Text(
                                          r['comment'],
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: AppColors.slateTextDark,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }).toList(),
                            )
                    else
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No source files attached.',
                            style: GoogleFonts.inter(color: Colors.grey),
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 38, color: const Color(0xFFD1D5DB));
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

