import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralised text styles — eliminates inline GoogleFonts.inter(...) calls
/// duplicated across every screen. Import and use instead of raw TextStyle.
///
/// Example:
///   Text('Hello', style: AppTextStyles.h1)
class AppTextStyles {
  AppTextStyles._();

  // ── Headings (on dark background) ─────────────────────────────────────
  static TextStyle get h1 => GoogleFonts.inter(
        fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.white);

  static TextStyle get h2 => GoogleFonts.inter(
        fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.white);

  static TextStyle get h3 => GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.white);

  // ── Section labels (on light background) ─────────────────────────────
  static TextStyle get sectionTitle => GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary);

  static TextStyle get sectionSubtitle => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary);

  // ── User header row (avatar + name + role) ────────────────────────────
  static TextStyle get userHeaderName => GoogleFonts.inter(
        fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.white);

  static TextStyle get userHeaderRole => GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textWhite70);

  // ── Body text ─────────────────────────────────────────────────────────
  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary);

  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textPrimary);

  static TextStyle get bodyMdMuted => GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textSecondary);

  static TextStyle get bodySmMuted => GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary);

  // ── White / on-dark body variants ────────────────────────────────────
  static TextStyle get bodySmWhite70 => GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textWhite70);

  static TextStyle get captionWhite70 => GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textWhite70);

  // ── Interactive text ─────────────────────────────────────────────────
  static TextStyle get link => GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accentBlue);

  // ── Buttons ───────────────────────────────────────────────────────────
  static TextStyle get primaryButton => GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w800);

  // ── Input field text ─────────────────────────────────────────────────
  static TextStyle get inputText => GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.white);
}
