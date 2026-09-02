import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/app_services.dart';
import '../../../features/communication/domain/card_ranker.dart';
import '../../../features/communication/domain/custom_card_repository.dart';
import '../../../features/routines/domain/routine_repository.dart';
import '../../../features/progress/domain/progress_models.dart';
import 'profile_backup.dart';

/// Reads and writes profile backups.
///
/// Split from the file plumbing so the assembly and application of a backup
/// can be tested without a filesystem or a picker — the parts most likely to
/// silently lose a child's data are the ones that must be covered.
class BackupService {
  const BackupService({
    required this.appState,
    required this.customCards,
    required this.routines,
  });

  final AppState appState;
  final CustomCardRepository customCards;
  final RoutineRepository routines;

  /// Gathers everything on the device into a snapshot.
  ///
  /// Progress is read per child rather than wholesale, because the
  /// repository interface is child-scoped and inventing a bulk read here
  /// would mean a second code path that could drift from the first.
  Future<ProfileBackup> build({DateTime Function()? clock}) async {
    final children = appState.children;
    final cards = <CustomCard>[];
    final sessions = <ProgressRecord>[];
    final usage = <CardUsageEvent>[];
    final notes = <ObservationNote>[];

    for (final child in children) {
      cards.addAll(await customCards.cardsFor(child.id));
      sessions.addAll(await appState.progressRepository.getSessions(child.id));
      usage.addAll(await appState.progressRepository.getCardUsage(child.id));
      notes.addAll(
        await appState.progressRepository.getObservations(child.id),
      );
    }

    return ProfileBackup(
      version: ProfileBackup.currentVersion,
      exportedAt: (clock ?? DateTime.now)(),
      children: children,
      selectedChildId: appState.selectedChild.id,
      customCards: cards,
      routineSteps: await routines.getSteps(),
      sessions: sessions,
      cardUsage: usage,
      observations: notes,
      settings: {
        'language': appState.locale.languageCode,
        'sensoryMode': appState.sensoryMode,
        'themeMode': appState.themeMode.name,
        'symbolScale': appState.symbolScale.name,
        'transitionLeadMinutes': appState.transitionLeadMinutes,
        // Deliberately absent: the caregiver PIN hash. A backup must not be
        // a way around the parent lock.
      },
    );
  }

  /// Applies a snapshot to this device.
  ///
  /// [ImportMode.merge] is the default because it cannot lose anything
  /// already here. Replace is genuinely destructive and the UI confirms it
  /// separately.
  ///
  /// Returns the number of children brought in.
  Future<int> apply(
    ProfileBackup backup, {
    ImportMode mode = ImportMode.merge,
  }) async {
    if (mode == ImportMode.replace) {
      for (final existing in [...appState.children]) {
        for (final card in await customCards.cardsFor(existing.id)) {
          await customCards.delete(card.id);
        }
      }
      appState.replaceChildren(backup.children);
    } else {
      final known = {for (final child in appState.children) child.id};
      for (final child in backup.children) {
        if (known.contains(child.id)) {
          appState.updateChild(
            id: child.id,
            name: child.name,
            supportLevel: child.supportLevel,
          );
        } else {
          appState.addChildProfile(child);
        }
      }
    }

    for (final card in backup.customCards) {
      await customCards.save(card);
    }
    if (backup.routineSteps.isNotEmpty) {
      await routines.saveSteps(backup.routineSteps);
    }
    for (final record in backup.sessions) {
      await appState.progressRepository.recordSession(record.result);
    }
    for (final event in backup.cardUsage) {
      await appState.progressRepository.recordCardUsage(event);
    }
    for (final note in backup.observations) {
      await appState.progressRepository.recordObservation(note);
    }

    await appState.loadCustomCards(force: true);
    return backup.children.length;
  }

  /// Writes the backup to a shareable file and returns its path.
  Future<String> writeToFile(ProfileBackup backup) async {
    final documents = await getApplicationDocumentsDirectory();
    final stamp = backup.exportedAt
        .toIso8601String()
        .substring(0, 19)
        .replaceAll(':', '-');
    final file = File('${documents.path}/autimate-backup-$stamp.json');
    await file.writeAsString(backup.encode());
    return file.path;
  }

  /// Hands the file to whatever the caregiver already uses — email, Drive,
  /// a cable. Inventing a transfer mechanism would mean maintaining one.
  Future<void> share(String path) async {
    try {
      await Share.shareXFiles(
        [XFile(path)],
        subject: 'AutiMate backup',
      );
    } catch (error) {
      debugPrint('Could not share backup: $error');
    }
  }

  /// Opens the document picker and parses the chosen file.
  ///
  /// Returns null when the caregiver cancelled. Throws
  /// [BackupFormatException] for a file we cannot use, so the UI can explain
  /// which of the several distinct problems occurred.
  Future<ProfileBackup?> pickAndDecode() async {
    final FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
        withData: true,
      );
    } catch (error) {
      debugPrint('File picker failed: $error');
      throw const BackupFormatException(BackupError.unreadable);
    }
    if (result == null || result.files.isEmpty) return null;

    final picked = result.files.first;
    String raw;
    try {
      final bytes = picked.bytes;
      if (bytes != null) {
        raw = String.fromCharCodes(bytes);
      } else {
        final path = picked.path;
        if (path == null) {
          throw const BackupFormatException(BackupError.unreadable);
        }
        raw = await File(path).readAsString();
      }
    } on BackupFormatException {
      rethrow;
    } catch (error) {
      debugPrint('Could not read backup: $error');
      throw const BackupFormatException(BackupError.unreadable);
    }
    return ProfileBackup.decode(raw);
  }
}
