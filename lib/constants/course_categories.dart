import 'package:flutter/material.dart';

/// The 15 standard course categories supported across Jomnes
const List<String> kCourseCategories = [
  'Math',
  'General',
  'Physic',
  'Khmer',
  'English',
  'Chinese',
  'Spanish',
  'Primary School',
  'High School',
  'Gym Trainer',
  'Volleyball Coach',
  'Football Coach',
  'Swimming Coach',
  'Teach Driving',
  'Badminton Coach',
];

/// Category theme data holding gradient colors and icon for each category
class CategoryTheme {
  final List<Color> gradient;
  final IconData icon;
  final String cardColorKey;

  const CategoryTheme({
    required this.gradient,
    required this.icon,
    required this.cardColorKey,
  });
}

/// Helper to get distinctive visuals for each category
CategoryTheme getCategoryTheme(String category) {
  final cat = category.toLowerCase().trim();

  if (cat.contains('math') || cat.contains('calculus')) {
    return const CategoryTheme(
      gradient: [Color(0xFFEA580C), Color(0xFFF97316)],
      icon: Icons.calculate_rounded,
      cardColorKey: 'orange',
    );
  } else if (cat.contains('physic')) {
    return const CategoryTheme(
      gradient: [Color(0xFF6B21A8), Color(0xFF9333EA)],
      icon: Icons.science_rounded,
      cardColorKey: 'purple',
    );
  } else if (cat.contains('khmer')) {
    return const CategoryTheme(
      gradient: [Color(0xFF9A3412), Color(0xFFEA580C)],
      icon: Icons.menu_book_rounded,
      cardColorKey: 'amber',
    );
  } else if (cat.contains('english')) {
    return const CategoryTheme(
      gradient: [Color(0xFF991B1B), Color(0xFFDC2626)],
      icon: Icons.translate_rounded,
      cardColorKey: 'red',
    );
  } else if (cat.contains('chinese')) {
    return const CategoryTheme(
      gradient: [Color(0xFF9F1239), Color(0xFFE11D48)],
      icon: Icons.auto_stories_rounded,
      cardColorKey: 'crimson',
    );
  } else if (cat.contains('spanish')) {
    return const CategoryTheme(
      gradient: [Color(0xFFB45309), Color(0xFFF59E0B)],
      icon: Icons.language_rounded,
      cardColorKey: 'amber',
    );
  } else if (cat.contains('primary')) {
    return const CategoryTheme(
      gradient: [Color(0xFF0369A1), Color(0xFF0EA5E9)],
      icon: Icons.child_care_rounded,
      cardColorKey: 'blue',
    );
  } else if (cat.contains('high school')) {
    return const CategoryTheme(
      gradient: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
      icon: Icons.school_rounded,
      cardColorKey: 'blue',
    );
  } else if (cat.contains('gym') || cat.contains('fitness')) {
    return const CategoryTheme(
      gradient: [Color(0xFF1E293B), Color(0xFF475569)],
      icon: Icons.fitness_center_rounded,
      cardColorKey: 'slate',
    );
  } else if (cat.contains('volleyball')) {
    return const CategoryTheme(
      gradient: [Color(0xFF0284C7), Color(0xFF38BDF8)],
      icon: Icons.sports_volleyball_rounded,
      cardColorKey: 'blue',
    );
  } else if (cat.contains('football') || cat.contains('soccer')) {
    return const CategoryTheme(
      gradient: [Color(0xFF15803D), Color(0xFF22C55E)],
      icon: Icons.sports_soccer_rounded,
      cardColorKey: 'green',
    );
  } else if (cat.contains('swimming')) {
    return const CategoryTheme(
      gradient: [Color(0xFF0F766E), Color(0xFF14B8A6)],
      icon: Icons.pool_rounded,
      cardColorKey: 'cyan',
    );
  } else if (cat.contains('driving')) {
    return const CategoryTheme(
      gradient: [Color(0xFF374151), Color(0xFF4B5563)],
      icon: Icons.directions_car_rounded,
      cardColorKey: 'slate',
    );
  } else if (cat.contains('badminton')) {
    return const CategoryTheme(
      gradient: [Color(0xFF047857), Color(0xFF10B981)],
      icon: Icons.sports_tennis_rounded,
      cardColorKey: 'green',
    );
  } else {
    // Default / General
    return const CategoryTheme(
      gradient: [Color(0xFF1E293B), Color(0xFF3B82F6)],
      icon: Icons.widgets_rounded,
      cardColorKey: 'blue',
    );
  }
}
