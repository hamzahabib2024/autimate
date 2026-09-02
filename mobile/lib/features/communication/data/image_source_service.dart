import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Where a caregiver's custom-card picture comes from.
enum CardImageSource { gallery, camera }

/// Boundary over the platform image picker.
///
/// The UI depends on this, never on `image_picker` directly, so widget tests
/// can supply a fake and the AAC screen stays runnable with no camera —
/// the same pattern `SimulatedExpressionService` uses for the camera
/// pipeline.
abstract interface class ImageSourceService {
  /// True when the device can supply an image at all.
  bool get isSupported;

  /// Returns an absolute path to a copy of the chosen image inside the app
  /// documents directory, or null when the caregiver cancelled.
  ///
  /// The file is *copied*, not referenced: gallery and camera URIs are not
  /// durable across restarts, and an offline-first card must still resolve
  /// its picture next week.
  Future<String?> pickAndStore(CardImageSource source);

  /// Removes a stored image. Safe to call for a path that no longer exists.
  Future<void> deleteStored(String path);
}

/// Real implementation over `image_picker` plus the documents directory.
class PlatformImageSourceService implements ImageSourceService {
  PlatformImageSourceService({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  bool get isSupported =>
      Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

  @override
  Future<String?> pickAndStore(CardImageSource source) async {
    final picked = await _picker.pickImage(
      source: source == CardImageSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      // Cards render at roughly 180 dp; anything larger is wasted storage
      // on a device that may be low-end.
      maxWidth: 720,
      maxHeight: 720,
      imageQuality: 85,
    );
    if (picked == null) return null;

    final documents = await getApplicationDocumentsDirectory();
    final folder = Directory('${documents.path}/aac_cards');
    if (!await folder.exists()) await folder.create(recursive: true);
    final extension = picked.path.split('.').last;
    final target =
        '${folder.path}/card_${DateTime.now().microsecondsSinceEpoch}.$extension';
    await File(picked.path).copy(target);
    return target;
  }

  @override
  Future<void> deleteStored(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}

/// No-op source used when no platform picker is available (tests, desktop
/// runs). Keeps the custom-card flow reachable so the caregiver can still
/// create a symbol-only card.
class UnavailableImageSourceService implements ImageSourceService {
  const UnavailableImageSourceService();

  @override
  bool get isSupported => false;

  @override
  Future<String?> pickAndStore(CardImageSource source) async => null;

  @override
  Future<void> deleteStored(String path) async {}
}
