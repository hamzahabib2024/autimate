import 'dart:convert';

import '../../../features/communication/domain/custom_card_repository.dart';
import '../../../features/communication/domain/card_ranker.dart';
import '../../../features/progress/domain/progress_models.dart';
import '../../../features/routines/domain/routine_models.dart';
import '../../services/app_services.dart';
import '../firebase/progress_codec.dart';

/// A portable snapshot of everything one device holds for its children.
///
/// **Why this exists.** In this context, losing a device means a child
/// losing their vocabulary — every custom card their caregiver built, every
/// routine, the whole history. That is not an inconvenience; it is a child
/// losing the words they had. A file that can be emailed to yourself is the
/// cheapest possible insurance, and it works with no backend at all, which
/// matters because the backend is optional here.
///
/// It also solves school ↔ home transfer, which otherwise needs an account
/// on both devices.
///
/// **What it deliberately does not contain.** No caregiver PIN hash — a
/// backup should not be a route around the parent lock. No Firebase
/// credentials. Media (photos, recordings) is referenced by path rather than
/// embedded: a device-local path will not resolve on another device, and the
/// import reports that honestly rather than silently producing broken cards.
class ProfileBackup {
  const ProfileBackup({
    required this.version,
    required this.exportedAt,
    required this.children,
    required this.selectedChildId,
    required this.customCards,
    required this.routineSteps,
    required this.sessions,
    required this.cardUsage,
    required this.observations,
    required this.settings,
  });

  /// Schema version. Bumped whenever the shape changes; [migrate] carries
  /// older files forward.
  ///
  /// Once a file exists in the wild, this becomes a permanent obligation —
  /// which is a real cost of the feature and is worth stating plainly.
  static const int currentVersion = 1;

  /// Identifies the file as ours before anything is parsed.
  static const String magic = 'autimate.backup';

  final int version;
  final DateTime exportedAt;
  final List<ChildProfile> children;
  final String selectedChildId;
  final List<CustomCard> customCards;
  final List<RoutineStep> routineSteps;
  final List<ProgressRecord> sessions;
  final List<CardUsageEvent> cardUsage;
  final List<ObservationNote> observations;

  /// Device-level preferences worth carrying across: language, sensory mode,
  /// symbol size, literacy rungs. Not the PIN.
  final Map<String, dynamic> settings;

  /// Media paths referenced but not embedded.
  List<String> get referencedMedia => [
    for (final card in customCards) ...[
      if (card.imagePath?.isNotEmpty ?? false) card.imagePath!,
      ...card.audioPaths,
    ],
  ];

  Map<String, dynamic> toJson() => {
    'magic': magic,
    'version': version,
    'exportedAt': exportedAt.toIso8601String(),
    'children': [for (final child in children) child.toJson()],
    'selectedChildId': selectedChildId,
    'customCards': [for (final card in customCards) card.toJson()],
    'routineSteps': [for (final step in routineSteps) step.toMap()],
    'sessions': [
      for (final record in sessions)
        ProgressCodec.sessionToMap(record.result, recordedAt: record.recordedAt),
    ],
    'cardUsage': [
      for (final event in cardUsage) ProgressCodec.usageToMap(event),
    ],
    'observations': [
      for (final note in observations) ProgressCodec.observationToMap(note),
    ],
    'settings': settings,
  };

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());

  /// Parses a backup file.
  ///
  /// Throws [BackupFormatException] with a caregiver-readable reason rather
  /// than a raw parse error — the person importing is a parent, not a
  /// developer, and "FormatException at offset 412" helps nobody.
  static ProfileBackup decode(String raw) {
    final Object? parsed;
    try {
      parsed = jsonDecode(raw);
    } on FormatException {
      throw const BackupFormatException(BackupError.notJson);
    }
    if (parsed is! Map<String, dynamic>) {
      throw const BackupFormatException(BackupError.notJson);
    }
    if (parsed['magic'] != magic) {
      throw const BackupFormatException(BackupError.notAutiMate);
    }
    final version = (parsed['version'] as num?)?.toInt() ?? 0;
    if (version > currentVersion) {
      // A newer app wrote this. Refuse rather than guess — importing a
      // shape we do not understand risks silently dropping a child's data.
      throw const BackupFormatException(BackupError.tooNew);
    }
    return migrate(parsed, version);
  }

  /// Carries an older file forward to the current shape.
  ///
  /// Version 1 is the first, so there is nothing to migrate yet. The switch
  /// exists so the next change has an obvious home rather than being bolted
  /// on later.
  static ProfileBackup migrate(Map<String, dynamic> json, int version) {
    final maps = _listOf(json['customCards']);
    return ProfileBackup(
      version: currentVersion,
      exportedAt:
          DateTime.tryParse(json['exportedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      children: [
        for (final child in _listOf(json['children']))
          ChildProfile.fromJson(child),
      ],
      selectedChildId: json['selectedChildId'] as String? ?? '',
      customCards: [for (final card in maps) CustomCard.fromJson(card)],
      routineSteps: [
        for (final step in _listOf(json['routineSteps']))
          RoutineStep.fromMap(step),
      ],
      sessions: [
        for (final record in _listOf(json['sessions']))
          ProgressCodec.sessionFromMap(record),
      ],
      cardUsage: [
        for (final event in _listOf(json['cardUsage']))
          ProgressCodec.usageFromMap(event),
      ],
      observations: [
        for (final note in _listOf(json['observations']))
          ProgressCodec.observationFromMap(note),
      ],
      settings:
          (json['settings'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{},
    );
  }

  static List<Map<String, dynamic>> _listOf(Object? value) {
    if (value is! List) return const [];
    return value.whereType<Map<String, dynamic>>().toList();
  }

  /// A one-line summary for the confirm-before-import dialog.
  BackupSummary get summary => BackupSummary(
    exportedAt: exportedAt,
    childCount: children.length,
    childNames: [for (final child in children) child.name],
    cardCount: customCards.length,
    sessionCount: sessions.length,
    observationCount: observations.length,
    mediaCount: referencedMedia.length,
  );
}

/// What the caregiver is shown before they commit to an import.
class BackupSummary {
  const BackupSummary({
    required this.exportedAt,
    required this.childCount,
    required this.childNames,
    required this.cardCount,
    required this.sessionCount,
    required this.observationCount,
    required this.mediaCount,
  });

  final DateTime exportedAt;
  final int childCount;
  final List<String> childNames;
  final int cardCount;
  final int sessionCount;
  final int observationCount;

  /// Photos and recordings referenced but not carried in the file. Surfaced
  /// so the caregiver is not surprised when cards come back without images.
  final int mediaCount;
}

enum BackupError {
  /// Not JSON at all — the wrong file was picked.
  notJson,

  /// Valid JSON, but not one of ours.
  notAutiMate,

  /// Written by a newer version of the app.
  tooNew,

  /// The file could not be read from disk.
  unreadable,
}

class BackupFormatException implements Exception {
  const BackupFormatException(this.error);

  final BackupError error;

  @override
  String toString() => 'BackupFormatException(${error.name})';
}

/// How an import treats what is already on the device.
enum ImportMode {
  /// Add the file's children alongside the existing ones. The safe default:
  /// nothing already on the device is lost.
  merge,

  /// Replace everything. Destructive, and confirmed separately.
  replace,
}
