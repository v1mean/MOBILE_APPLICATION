import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  int _selectedCard = 0;

  final List<Map<String, dynamic>> _cards = [
    {
      'type': 'VISA',
      'last4': '4242',
      'expiry': '08/27',
      'color1': const Color(0xFF2563EB),
      'color2': const Color(0xFF4F46E5),
      'holder': 'VI MEAN',
    },
    {
      'type': 'Mastercard',
      'last4': '8891',
      'expiry': '12/26',
      'color1': const Color(0xFF0F172A),
      'color2': const Color(0xFF1E293B),
      'holder': 'VI MEAN',
    },
  ];

  void _showAddCardDialog() {
    final numberController = TextEditingController();
    final nameController = TextEditingController(text: 'VI MEAN');
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add Payment Card',
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A))),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildSheetField(
                controller: numberController,
                label: 'Card Number',
                hint: '4111 2222 3333 4444',
                icon: Icons.credit_card_rounded,
                type: TextInputType.number,
              ),
              const SizedBox(height: 14),
              _buildSheetField(
                controller: nameController,
                label: 'Cardholder Name',
                hint: 'VI MEAN',
                icon: Icons.person_rounded,
                type: TextInputType.name,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildSheetField(
                      controller: expiryController,
                      label: 'Expiry Date',
                      hint: 'MM/YY',
                      icon: Icons.calendar_today_rounded,
                      type: TextInputType.datetime,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildSheetField(
                      controller: cvvController,
                      label: 'Security CVV',
                      hint: '123',
                      icon: Icons.lock_rounded,
                      type: TextInputType.number,
                      obscure: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    final num = numberController.text.replaceAll(' ', '');
                    if (num.length < 4) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Please enter a valid card number'),
                          backgroundColor: AppColors.liveRed,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    Navigator.pop(ctx);

                    final isVisa = num.startsWith('4');
                    final brand = isVisa ? 'VISA' : 'Mastercard';
                    final color1 = isVisa ? const Color(0xFF0284C7) : const Color(0xFFDC2626);
                    final color2 = isVisa ? const Color(0xFF0369A1) : const Color(0xFF991B1B);

                    setState(() {
                      _cards.add({
                        'type': brand,
                        'last4': num.substring(num.length - 4),
                        'expiry': expiryController.text.isNotEmpty ? expiryController.text : '12/28',
                        'color1': color1,
                        'color2': color2,
                        'holder': nameController.text.toUpperCase().isNotEmpty
                            ? nameController.text.toUpperCase()
                            : 'VI MEAN',
                      });
                      _selectedCard = _cards.length - 1;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Text('Payment card added successfully!',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: AppColors.accentBlue.withAlpha(100),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Add Card',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteCard(int index) {
    if (_cards.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('At least one payment card must be maintained.'),
          backgroundColor: AppColors.liveRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final card = _cards[index];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Remove Card?',
            style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
        content: Text(
          'Remove ${card['type']} card ending in •••• ${card['last4']} from your wallet?',
          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: const Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _cards.removeAt(index);
                if (_selectedCard >= _cards.length) {
                  _selectedCard = 0;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Payment card removed.'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.liveRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Remove', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Column(
        children: [
          // Header Bar
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withAlpha(25)),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payment Methods',
                          style: GoogleFonts.inter(
                              fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white)),
                      Text('Saved cards & billing',
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.white60)),
                    ],
                  ),
                  const Spacer(),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _showAddCardDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withAlpha(30)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.add_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text('Add Card',
                                style: GoogleFonts.inter(
                                    color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body Content
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Your Saved Cards',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF64748B),
                                letterSpacing: 0.4)),
                        Text('Tap to set default',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF94A3B8))),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Cards List
                    ..._cards.asMap().entries.map((entry) {
                      final i = entry.key;
                      final card = entry.value;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCard = i);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${card['type']} ending in ${card['last4']} set as default'),
                              duration: const Duration(milliseconds: 1400),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        child: _buildCreditCard(card, _selectedCard == i, i),
                      ).animate(delay: Duration(milliseconds: 60 * i)).fadeIn().slideY(begin: 0.15);
                    }),
                    const SizedBox(height: 16),

                    // Add Card Button
                    InkWell(
                      onTap: _showAddCardDialog,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(6),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.accentBlue.withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add_rounded, color: AppColors.accentBlue, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Text('Add Another Payment Card',
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accentBlue)),
                          ],
                        ),
                      ),
                    ).animate(delay: 120.ms).fadeIn(),

                    const SizedBox(height: 30),

                    // Accepted Payment Methods Card
                    Text('Accepted Payment Methods',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.4)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildPaymentBadge('VISA', const Color(0xFF1A1F71)),
                              _buildPaymentBadge('Mastercard', const Color(0xFFEB001B)),
                              _buildPaymentBadge('ABA Pay', const Color(0xFF005F73)),
                              _buildPaymentBadge('Wing Bank', const Color(0xFF65A30D)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.verified_user_rounded, size: 16, color: Color(0xFF10B981)),
                              const SizedBox(width: 8),
                              Text('256-Bit SSL Encrypted & PCI-DSS Certified',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF475569))),
                            ],
                          ),
                        ],
                      ),
                    ).animate(delay: 180.ms).fadeIn(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCard(Map<String, dynamic> card, bool isSelected, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 195,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [card['color1'] as Color, card['color2'] as Color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (card['color1'] as Color).withAlpha(100),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: isSelected
            ? Border.all(color: Colors.white, width: 2.5)
            : Border.all(color: Colors.white.withAlpha(40), width: 1),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -25,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -50,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withAlpha(230),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.wifi_rounded, color: Colors.white70, size: 20),
                      ],
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                size: 14, color: AppColors.accentBlue),
                            const SizedBox(width: 4),
                            Text('Default',
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.accentBlue)),
                          ],
                        ),
                      )
                    else
                      Text(card['type'],
                          style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1)),
                  ],
                ),
                const Spacer(),
                Text('•••• •••• •••• ${card['last4']}',
                    style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 3.5)),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CARD HOLDER',
                            style: GoogleFonts.inter(
                                fontSize: 9, color: Colors.white60, letterSpacing: 1)),
                        const SizedBox(height: 1),
                        Text(card['holder'],
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EXPIRES',
                            style: GoogleFonts.inter(
                                fontSize: 9, color: Colors.white60, letterSpacing: 1)),
                        const SizedBox(height: 1),
                        Text(card['expiry'],
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
                    ),
                    IconButton(
                      onPressed: () => _deleteCard(index),
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Colors.white70, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.5)),
    );
  }

  Widget _buildSheetField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType type,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: type,
            obscureText: obscure,
            style: GoogleFonts.inter(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13.5),
              filled: true,
              fillColor: Colors.transparent,
              prefixIcon: Container(
                margin: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.accentBlue, size: 18),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.accentBlue, width: 1.8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
