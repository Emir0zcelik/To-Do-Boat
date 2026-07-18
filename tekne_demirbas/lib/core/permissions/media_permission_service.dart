import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ancyra_sailing/l10n/app_translations.dart';
import 'package:ancyra_sailing/utils/appstyles.dart';

/// Kamera ve galeri erişiminden önce kullanıcıya açıklama gösterir,
/// ardından sistem izin diyaloğunu tetikler.
class MediaPermissionService {
  MediaPermissionService._();

  static final MediaPermissionService instance = MediaPermissionService._();

  Future<bool> ensureGalleryAccess(
    BuildContext context, {
    bool forVideo = false,
  }) {
    final permissions = <Permission>[
      Permission.photos,
      if (Platform.isAndroid && forVideo) Permission.videos,
    ];

    return _ensurePermissions(
      context,
      permissions: permissions,
      titleKey: 'galleryPermissionTitle',
      messageKey: 'galleryPermissionMessage',
    );
  }

  Future<bool> ensureCameraAccess(
    BuildContext context, {
    bool forVideo = false,
  }) {
    final permissions = <Permission>[
      Permission.camera,
      if (forVideo) Permission.microphone,
    ];

    return _ensurePermissions(
      context,
      permissions: permissions,
      titleKey: 'cameraPermissionTitle',
      messageKey: forVideo
          ? 'microphonePermissionMessage'
          : 'cameraPermissionMessage',
    );
  }

  Future<bool> _ensurePermissions(
    BuildContext context, {
    required List<Permission> permissions,
    required String titleKey,
    required String messageKey,
  }) async {
    if (permissions.isEmpty) return true;

    for (final permission in permissions) {
      final status = await permission.status;
      if (_isGranted(status)) continue;

      if (status.isPermanentlyDenied) {
        await _showOpenSettingsDialog(context);
        return false;
      }
    }

    final needsRationale = await _needsRationale(permissions);
    if (needsRationale && context.mounted) {
      final confirmed = await _showRationaleDialog(
        context,
        titleKey: titleKey,
        messageKey: messageKey,
      );
      if (!confirmed) return false;
    }

    for (final permission in permissions) {
      final status = await permission.status;
      if (_isGranted(status)) continue;

      final result = await permission.request();
      if (_isGranted(result)) continue;

      if (!context.mounted) return false;

      if (result.isPermanentlyDenied) {
        await _showOpenSettingsDialog(context);
      } else {
        _showDeniedSnackBar(context);
      }
      return false;
    }

    return true;
  }

  bool _isGranted(PermissionStatus status) {
    return status.isGranted || status.isLimited;
  }

  Future<bool> _needsRationale(List<Permission> permissions) async {
    for (final permission in permissions) {
      final status = await permission.status;
      if (!_isGranted(status) && !status.isPermanentlyDenied) {
        return true;
      }
    }
    return false;
  }

  Future<bool> _showRationaleDialog(
    BuildContext context, {
    required String titleKey,
    required String messageKey,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          titleKey == 'galleryPermissionTitle'
              ? Icons.photo_library
              : Icons.camera_alt,
          color: Appstyles.primaryBlue,
          size: 40,
        ),
        title: Text(
          AppTranslations.t(context, titleKey),
          style: Appstyles.titleTextStyle,
          textAlign: TextAlign.center,
        ),
        content: Text(
          AppTranslations.t(context, messageKey),
          style: Appstyles.normalTextStyle,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppTranslations.t(context, 'cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Appstyles.primaryBlue,
              foregroundColor: Appstyles.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppTranslations.t(context, 'allow')),
          ),
        ],
      ),
    );

    return result == true;
  }

  Future<void> _showOpenSettingsDialog(BuildContext context) async {
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppTranslations.t(context, 'permissionDenied')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppTranslations.t(context, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              openAppSettings();
            },
            child: Text(AppTranslations.t(context, 'openSettings')),
          ),
        ],
      ),
    );
  }

  void _showDeniedSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppTranslations.t(context, 'permissionDenied')),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
