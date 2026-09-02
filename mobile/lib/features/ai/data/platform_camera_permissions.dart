import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart' as handler;

import '../domain/ai_contracts.dart';

/// Real OS camera permission, replacing the always-granted stand-in.
///
/// The distinction that matters here is **denied versus permanently
/// denied**. Re-prompting a caregiver who has permanently declined does
/// nothing — the OS suppresses the dialog — so the app must stop asking and
/// offer to open settings instead. Collapsing the two states is what
/// produces a button that silently does nothing, which is worse than no
/// button at all.
class PlatformCameraPermissionService implements CameraPermissionService {
  const PlatformCameraPermissionService();

  @override
  Future<CameraPermissionStatus> status() async {
    if (!_supportedPlatform) return CameraPermissionStatus.unsupported;
    try {
      return _map(await handler.Permission.camera.status);
    } catch (error) {
      debugPrint('Camera permission status unavailable: $error');
      return CameraPermissionStatus.unsupported;
    }
  }

  @override
  Future<CameraPermissionStatus> request() async {
    if (!_supportedPlatform) return CameraPermissionStatus.unsupported;
    try {
      final current = await handler.Permission.camera.status;
      // Asking again after a permanent denial is a no-op on both platforms.
      // Report it truthfully so the UI routes to settings.
      if (current.isPermanentlyDenied) {
        return CameraPermissionStatus.permanentlyDenied;
      }
      return _map(await handler.Permission.camera.request());
    } catch (error) {
      debugPrint('Camera permission request failed: $error');
      return CameraPermissionStatus.unsupported;
    }
  }

  /// Sends the caregiver to the OS settings page for this app. The only
  /// route out of a permanent denial.
  Future<bool> openSettings() async {
    try {
      return await handler.openAppSettings();
    } catch (error) {
      debugPrint('Could not open app settings: $error');
      return false;
    }
  }

  bool get _supportedPlatform => Platform.isAndroid || Platform.isIOS;

  CameraPermissionStatus _map(handler.PermissionStatus status) =>
      switch (status) {
        handler.PermissionStatus.granted ||
        handler.PermissionStatus.limited ||
        handler.PermissionStatus.provisional =>
          CameraPermissionStatus.granted,
        handler.PermissionStatus.permanentlyDenied =>
          CameraPermissionStatus.permanentlyDenied,
        // A device policy that blocks the camera outright is not something
        // the caregiver can resolve in settings, so it is not "denied".
        handler.PermissionStatus.restricted =>
          CameraPermissionStatus.unsupported,
        handler.PermissionStatus.denied => CameraPermissionStatus.denied,
      };
}
