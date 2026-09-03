import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Records and plays back a caregiver's own voice for an AAC card.
///
/// **Why this is worth a second sensitive permission.** A parent's real
/// voice is more motivating than synthesis, and — the practical reason for
/// this project — it sidesteps Urdu TTS quality entirely. Offline Urdu
/// voices on low-end Android devices are often poor or absent, which is a
/// live risk for the intended users; a recorded label is immune to it.
///
/// **Consent.** The recorded voice should be the caregiver's, not the
/// child's. The editor UI says so explicitly. A child cannot meaningfully
/// consent to their voice being stored, and nothing here needs it: the card
/// is a thing the child *says*, so it should be modelled in an adult voice
/// they can imitate.
///
/// Files live in app-private storage and are never uploaded. Deleting a card
/// deletes its audio, which is why [delete] exists rather than leaving
/// orphans behind.
abstract interface class VoiceRecordingService {
  /// True when this device can record at all.
  Future<bool> isSupported();

  /// True when the microphone permission is already granted.
  Future<bool> hasPermission();

  /// Requests the microphone. Returns whether it was granted.
  Future<bool> requestPermission();

  bool get isRecording;

  /// Starts recording. Returns false when it could not start — a denied
  /// permission, a busy microphone, an unsupported device.
  Future<bool> start();

  /// Stops and returns the stored file path, or null if nothing was
  /// captured.
  Future<String?> stop();

  /// Abandons the take and removes any partial file.
  Future<void> cancel();

  Future<void> play(String path);
  Future<void> stopPlayback();

  /// Removes a stored clip. Safe for a path that no longer exists.
  Future<void> delete(String path);

  Future<void> dispose();
}

/// Real implementation over `record` plus `audioplayers`.
class PlatformVoiceRecordingService implements VoiceRecordingService {
  PlatformVoiceRecordingService({
    AudioRecorder? recorder,
    AudioPlayer? player,
  }) : _recorder = recorder ?? AudioRecorder(),
       _player = player ?? AudioPlayer();

  final AudioRecorder _recorder;
  final AudioPlayer _player;

  String? _activePath;
  bool _recording = false;

  @override
  bool get isRecording => _recording;

  @override
  Future<bool> isSupported() async {
    if (!(Platform.isAndroid || Platform.isIOS)) return false;
    try {
      return await _recorder.hasPermission() || true;
    } catch (error) {
      debugPrint('Recording unsupported: $error');
      return false;
    }
  }

  @override
  Future<bool> hasPermission() async {
    try {
      return await _recorder.hasPermission();
    } catch (error) {
      debugPrint('Microphone permission check failed: $error');
      return false;
    }
  }

  @override
  Future<bool> requestPermission() => hasPermission();

  @override
  Future<bool> start() async {
    if (_recording) return false;
    try {
      if (!await _recorder.hasPermission()) return false;
      final documents = await getApplicationDocumentsDirectory();
      final folder = Directory('${documents.path}/card_audio');
      if (!await folder.exists()) await folder.create(recursive: true);
      final path =
          '${folder.path}/voice_${DateTime.now().microsecondsSinceEpoch}.m4a';
      await _recorder.start(
        // AAC in an m4a container: small, and playable by audioplayers on
        // both platforms without extra codecs. A single-word label at
        // 64 kbps mono is a few kilobytes.
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          numChannels: 1,
        ),
        path: path,
      );
      _activePath = path;
      _recording = true;
      return true;
    } catch (error) {
      debugPrint('Could not start recording: $error');
      _recording = false;
      return false;
    }
  }

  @override
  Future<String?> stop() async {
    if (!_recording) return null;
    _recording = false;
    try {
      final path = await _recorder.stop() ?? _activePath;
      _activePath = null;
      if (path == null) return null;
      // A zero-length take is a mis-tap, not a recording.
      final file = File(path);
      if (!await file.exists() || await file.length() < 512) {
        await delete(path);
        return null;
      }
      return path;
    } catch (error) {
      debugPrint('Could not stop recording: $error');
      return null;
    }
  }

  @override
  Future<void> cancel() async {
    if (!_recording) return;
    _recording = false;
    final path = _activePath;
    _activePath = null;
    try {
      await _recorder.stop();
    } catch (error) {
      debugPrint('Cancel recording: $error');
    }
    if (path != null) await delete(path);
  }

  @override
  Future<void> play(String path) async {
    try {
      await _player.stop();
      await _player.play(DeviceFileSource(path));
    } catch (error) {
      debugPrint('Could not play clip: $error');
    }
  }

  @override
  Future<void> stopPlayback() async {
    try {
      await _player.stop();
    } catch (error) {
      debugPrint('Could not stop playback: $error');
    }
  }

  @override
  Future<void> delete(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (error) {
      debugPrint('Could not delete clip: $error');
    }
  }

  @override
  Future<void> dispose() async {
    await cancel();
    try {
      await _recorder.dispose();
      await _player.dispose();
    } catch (error) {
      debugPrint('Recorder dispose: $error');
    }
  }
}

/// No-op source for tests, desktop runs, and devices with no microphone.
///
/// Reports unsupported rather than pretending, so the editor shows its
/// explanatory state instead of a record button that does nothing.
class UnavailableVoiceRecordingService implements VoiceRecordingService {
  const UnavailableVoiceRecordingService();

  @override
  bool get isRecording => false;

  @override
  Future<bool> isSupported() async => false;

  @override
  Future<bool> hasPermission() async => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<bool> start() async => false;

  @override
  Future<String?> stop() async => null;

  @override
  Future<void> cancel() async {}

  @override
  Future<void> play(String path) async {}

  @override
  Future<void> stopPlayback() async {}

  @override
  Future<void> delete(String path) async {}

  @override
  Future<void> dispose() async {}
}
