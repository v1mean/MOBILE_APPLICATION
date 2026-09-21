import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Centralised permission handling for photo library and camera.
/// Handles the full flow: check → request → guide to Settings if permanently denied.
class PermissionService {
  // ── Photo Library ─────────────────────────────────────────────────────────
  /// Returns true if the permission was granted (or limited on iOS).
  /// Shows a native OS dialog on first request.
  /// If permanently denied, shows an in-app dialog directing the user to Settings.
  static Future<bool> requestPhotoPermission(BuildContext context) async {
    // On Android 13+ use Permission.photos; on older Android use Permission.storage.
    // permission_handler picks the right one internally when you use Permission.photos.
    PermissionStatus status = await Permission.photos.status;

    if (status.isGranted || status.isLimited) return true;

    if (status.isDenied) {
      status = await Permission.photos.request();
      if (status.isGranted || status.isLimited) return true;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showSettingsDialog(
          context,
          title: 'Photo Access Required',
          message:
              'Jomnes needs access to your photo library to update your profile picture.\n\nPlease go to Settings → Jomnes → Photos and enable access.',
        );
      }
      return false;
    }

    return false;
  }

  // ── Camera ────────────────────────────────────────────────────────────────
  static Future<bool> requestCameraPermission(BuildContext context) async {
    PermissionStatus status = await Permission.camera.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      status = await Permission.camera.request();
      if (status.isGranted) return true;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showSettingsDialog(
          context,
          title: 'Camera Access Required',
          message:
              'Jomnes needs camera access to let you take a profile photo.\n\nPlease go to Settings → Jomnes → Camera and enable access.',
        );
      }
      return false;
    }

    return false;
  }

  // ── Settings dialog ───────────────────────────────────────────────────────
  static Future<void> _showSettingsDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.lock_outline_rounded,
                color: Color(0xFF3B82F6), size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Not Now',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings(); // opens iOS/Android Settings for this app
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Open Settings',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

