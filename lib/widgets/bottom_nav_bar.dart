import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with SingleTickerProviderStateMixin {
  static int _globalIndex = -1;

  late AnimationController _controller;
  late Animation<double> _animation;
  late int _fromIndex;
  late int _toIndex;

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.search_rounded, activeIcon: Icons.search_rounded, label: 'Search'),
    _NavItem(icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book_rounded, label: 'Course'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
    _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: 'Settings'),
  ];

  static const List<double> _activeWidths = [94.0, 102.0, 102.0, 98.0, 108.0];
  static const double _inactiveWidth = 46.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    final target = widget.currentIndex.clamp(0, _items.length - 1);

    if (_globalIndex == -1 || _globalIndex == target) {
      _fromIndex = target;
      _toIndex = target;
      _globalIndex = target;
      _controller.value = 1.0;
    } else {
      _fromIndex = _globalIndex.clamp(0, _items.length - 1);
      _toIndex = target;
      _globalIndex = target;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(covariant BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = widget.currentIndex.clamp(0, _items.length - 1);
    if (oldWidget.currentIndex != target) {
      _fromIndex = oldWidget.currentIndex.clamp(0, _items.length - 1);
      _toIndex = target;
      _globalIndex = target;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<double> _widthsForActive(int activeIdx) {
    final list = List<double>.filled(_items.length, _inactiveWidth);
    list[activeIdx] = _activeWidths[activeIdx];
    return list;
  }

  List<double> _leftsForWidths(List<double> widths, double totalWidth) {
    final sumWidths = widths.reduce((a, b) => a + b);
    final gap = (totalWidth - sumWidths) / (widths.length - 1);
    final lefts = <double>[];
    double cur = 0.0;
    for (int i = 0; i < widths.length; i++) {
      lefts.add(cur);
      cur += widths[i] + gap;
    }
    return lefts;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF6F7F9),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalW = constraints.maxWidth;

            final fromWidths = _widthsForActive(_fromIndex);
            final fromLefts = _leftsForWidths(fromWidths, totalW);

            final toWidths = _widthsForActive(_toIndex);
            final toLefts = _leftsForWidths(toWidths, totalW);

            return SizedBox(
              height: 44,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final t = _animation.value;

                  // Positions for the 5 background buttons
                  final currentWidths = List<double>.generate(
                    _items.length,
                    (i) => lerpDouble(fromWidths[i], toWidths[i], t)!,
                  );
                  final currentLefts = List<double>.generate(
                    _items.length,
                    (i) => lerpDouble(fromLefts[i], toLefts[i], t)!,
                  );

                  // Position and width of the sliding black pill
                  final startPillLeft = fromLefts[_fromIndex];
                  final startPillWidth = fromWidths[_fromIndex];

                  final endPillLeft = toLefts[_toIndex];
                  final endPillWidth = toWidths[_toIndex];

                  final pillLeft = lerpDouble(startPillLeft, endPillLeft, t)!;
                  final pillWidth = lerpDouble(startPillWidth, endPillWidth, t)!;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 5 White background buttons
                      for (int i = 0; i < _items.length; i++)
                        Positioned(
                          left: currentLefts[i],
                          top: 0,
                          width: currentWidths[i],
                          height: 44,
                          child: GestureDetector(
                            onTap: () => widget.onTap(i),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(8),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                _items[i].icon,
                                color: const Color(0xFF111827),
                                size: 20,
                              ),
                            ),
                          ),
                        ),

                      // Sliding Black Pill
                      Positioned(
                        left: pillLeft,
                        top: 0,
                        width: pillWidth,
                        height: 44,
                        child: GestureDetector(
                          onTap: () => widget.onTap(_toIndex),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(30),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: ClipRect(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (_fromIndex != _toIndex)
                                    Opacity(
                                      opacity: (1.0 - (t * 2.0)).clamp(0.0, 1.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _items[_fromIndex].activeIcon,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _items[_fromIndex].label,
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Opacity(
                                    opacity: _fromIndex == _toIndex
                                        ? 1.0
                                        : ((t - 0.5) * 2.0).clamp(0.0, 1.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _items[_toIndex].activeIcon,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _items[_toIndex].label,
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}