import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../settings/presentation/parent_gate_screen.dart';
import '../data/image_source_service.dart';
import '../data/voice_recording_service.dart';
import '../domain/aac_catalog.dart';
import '../domain/custom_card_repository.dart';
import '../domain/sentence_realiser.dart';

/// Caregiver surface for building this child's own vocabulary cards.
///
/// Caregiver tier, so it sits behind the parent gate: a child tapping
/// around the board must not be able to delete their own words.
class CustomCardsScreen extends StatefulWidget {
  const CustomCardsScreen({
    required this.appState,
    required this.imageSource,
    this.voiceRecorder = const UnavailableVoiceRecordingService(),
    super.key,
  });

  final AppState appState;
  final ImageSourceService imageSource;
  final VoiceRecordingService voiceRecorder;

  /// Opens the editor behind the parent lock.
  static Future<void> openGated(
    BuildContext context,
    AppState appState,
    ImageSourceService imageSource, {
    VoiceRecordingService voiceRecorder =
        const UnavailableVoiceRecordingService(),
  }) async {
    if (appState.childMode) {
      final unlocked = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => ParentGateScreen(appState: appState),
        ),
      );
      if (unlocked != true) return;
    }
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomCardsScreen(
          appState: appState,
          imageSource: imageSource,
          voiceRecorder: voiceRecorder,
        ),
      ),
    );
  }

  @override
  State<CustomCardsScreen> createState() => _CustomCardsScreenState();
}

class _CustomCardsScreenState extends State<CustomCardsScreen> {
  @override
  void initState() {
    super.initState();
    widget.appState.loadCustomCards(force: true);
  }

  bool get _urdu => widget.appState.locale.languageCode == 'ur';

  Future<void> _delete(CustomCard card, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteCustomCard),
        content: Text(l10n.confirmDeleteCard),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const ValueKey('confirm-delete-card'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteCustomCard),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final path = card.imagePath;
    final clips = card.audioPaths;
    await widget.appState.deleteCustomCard(card.id);
    if (path != null) await widget.imageSource.deleteStored(path);
    // Orphaned audio would sit in app storage forever otherwise.
    for (final clip in clips) {
      await widget.voiceRecorder.delete(clip);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final cards = widget.appState.customCards;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.customCardsTitle)),
          floatingActionButton: FloatingActionButton.extended(
            key: const ValueKey('add-custom-card'),
            onPressed: () => _openEditor(l10n, null),
            icon: const Icon(Icons.add),
            label: Text(l10n.addCustomCard),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              96,
            ),
            children: [
              Text(
                l10n.customCardsSubtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              if (cards.isEmpty)
                EmptyState(
                  message: l10n.myCardsEmpty,
                  icon: Icons.add_photo_alternate_outlined,
                )
              else
                for (final card in cards)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Card(
                      key: ValueKey('custom-card-${card.id}'),
                      child: ListTile(
                        leading: _thumbnail(card),
                        title: Text(_urdu ? card.labelUr : card.labelEn),
                        subtitle: Text(_urdu ? card.labelEn : card.labelUr),
                        onTap: () => _openEditor(l10n, card),
                        trailing: IconButton(
                          key: ValueKey('delete-custom-card-${card.id}'),
                          tooltip: l10n.deleteCustomCard,
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _delete(card, l10n),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _thumbnail(CustomCard card) {
    final palette = context.palette;
    final path = card.imagePath;
    return Container(
      width: 52,
      height: 52,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.accentTint(palette.communicate, 0.82),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: path == null
          ? Icon(Icons.image_outlined, color: palette.communicate)
          : Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.broken_image_outlined, color: palette.communicate),
            ),
    );
  }

  Future<void> _openEditor(AppLocalizations l10n, CustomCard? existing) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _CardEditor(
          appState: widget.appState,
          imageSource: widget.imageSource,
          voiceRecorder: widget.voiceRecorder,
          existing: existing,
        ),
      ),
    );
  }
}

class _CardEditor extends StatefulWidget {
  const _CardEditor({
    required this.appState,
    required this.imageSource,
    required this.voiceRecorder,
    this.existing,
  });

  final AppState appState;
  final ImageSourceService imageSource;
  final VoiceRecordingService voiceRecorder;
  final CustomCard? existing;

  @override
  State<_CardEditor> createState() => _CardEditorState();
}

class _CardEditorState extends State<_CardEditor> {
  late final TextEditingController _en =
      TextEditingController(text: widget.existing?.labelEn);
  late final TextEditingController _ur =
      TextEditingController(text: widget.existing?.labelUr);
  late final TextEditingController _spokenEn =
      TextEditingController(text: widget.existing?.spokenEn);
  late final TextEditingController _spokenUr =
      TextEditingController(text: widget.existing?.spokenUr);

  late AacCategory _category =
      widget.existing?.category ?? AacCategory.objects;
  late String? _imagePath = widget.existing?.imagePath;
  late String? _audioEn = widget.existing?.audioPathEn;
  late String? _audioUr = widget.existing?.audioPathUr;
  bool _busy = false;
  bool _canRecord = false;
  bool _permissionDenied = false;

  /// Which language is being recorded right now, or null when idle.
  AppLanguage? _recordingFor;

  @override
  void initState() {
    super.initState();
    _checkRecording();
  }

  Future<void> _checkRecording() async {
    final supported = await widget.voiceRecorder.isSupported();
    if (!mounted) return;
    setState(() => _canRecord = supported);
  }

  Future<void> _toggleRecording(AppLanguage language) async {
    if (_recordingFor == language) {
      final path = await widget.voiceRecorder.stop();
      if (!mounted) return;
      setState(() {
        _recordingFor = null;
        if (path != null) {
          // Replacing a take removes the old file rather than orphaning it.
          final previous = language == AppLanguage.ur ? _audioUr : _audioEn;
          if (previous != null && previous != path) {
            unawaited(widget.voiceRecorder.delete(previous));
          }
          if (language == AppLanguage.ur) {
            _audioUr = path;
          } else {
            _audioEn = path;
          }
        }
      });
      return;
    }
    if (!await widget.voiceRecorder.hasPermission()) {
      final granted = await widget.voiceRecorder.requestPermission();
      if (!mounted) return;
      if (!granted) {
        setState(() => _permissionDenied = true);
        return;
      }
    }
    final started = await widget.voiceRecorder.start();
    if (!mounted) return;
    setState(() {
      _permissionDenied = !started;
      _recordingFor = started ? language : null;
    });
  }

  Future<void> _removeClip(AppLanguage language) async {
    final path = language == AppLanguage.ur ? _audioUr : _audioEn;
    if (path == null) return;
    await widget.voiceRecorder.delete(path);
    if (!mounted) return;
    setState(() {
      if (language == AppLanguage.ur) {
        _audioUr = null;
      } else {
        _audioEn = null;
      }
    });
  }

  @override
  void dispose() {
    // A take still running when the editor closes is abandoned, not saved:
    // the caregiver never confirmed it.
    if (_recordingFor != null) unawaited(widget.voiceRecorder.cancel());
    unawaited(widget.voiceRecorder.stopPlayback());
    _en.dispose();
    _ur.dispose();
    _spokenEn.dispose();
    _spokenUr.dispose();
    super.dispose();
  }

  bool get _valid => _en.text.trim().isNotEmpty && _ur.text.trim().isNotEmpty;

  Future<void> _pick(CardImageSource source) async {
    setState(() => _busy = true);
    final path = await widget.imageSource.pickAndStore(source);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (path != null) _imagePath = path;
    });
  }

  Future<void> _save() async {
    final existing = widget.existing;
    final card = CustomCard(
      id: existing?.id ??
          'custom-${DateTime.now().microsecondsSinceEpoch}',
      childId: widget.appState.selectedChild.id,
      labelEn: _en.text.trim(),
      labelUr: _ur.text.trim(),
      category: _category,
      imagePath: _imagePath,
      iconCodePoint: existing?.iconCodePoint,
      spokenEn: _spokenEn.text.trim(),
      spokenUr: _spokenUr.text.trim(),
      audioPathEn: _audioEn,
      audioPathUr: _audioUr,
    );
    await widget.appState.saveCustomCard(card);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing == null ? l10n.addCustomCard : l10n.editCustomCard,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          SectionHeader(
            title: l10n.cardPictureLabel,
            accent: palette.communicate,
          ),
          Center(
            child: Container(
              width: 160,
              height: 160,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: palette.accentTint(palette.communicate, 0.86),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: palette.communicate, width: 2),
              ),
              child: _imagePath == null
                  ? Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 56,
                      color: palette.communicate,
                    )
                  : Image.file(
                      File(_imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.broken_image_outlined,
                        size: 56,
                        color: palette.communicate,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (!widget.imageSource.isSupported)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                l10n.cameraUnavailable,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              OutlinedButton.icon(
                key: const ValueKey('pick-gallery'),
                onPressed: _busy || !widget.imageSource.isSupported
                    ? null
                    : () => _pick(CardImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(l10n.choosePhotoGallery),
              ),
              OutlinedButton.icon(
                key: const ValueKey('pick-camera'),
                onPressed: _busy || !widget.imageSource.isSupported
                    ? null
                    : () => _pick(CardImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(l10n.takePhoto),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: l10n.cardLabelEnglish,
            accent: palette.communicate,
          ),
          TextField(
            key: const ValueKey('card-label-en'),
            controller: _en,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: l10n.cardLabelEnglish),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            key: const ValueKey('card-label-ur'),
            controller: _ur,
            textDirection: TextDirection.rtl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: l10n.cardLabelUrdu),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            key: const ValueKey('card-spoken-en'),
            controller: _spokenEn,
            decoration: InputDecoration(labelText: l10n.cardSpokenEnglish),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            key: const ValueKey('card-spoken-ur'),
            controller: _spokenUr,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(labelText: l10n.cardSpokenUrdu),
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: l10n.cardVoiceLabel,
            accent: palette.communicate,
          ),
          Text(
            l10n.cardVoiceSubtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          // Consent stated in the UI, not buried in a policy: the caregiver
          // records themselves, never the child.
          Card(
            color: palette.accentTint(palette.attention, 0.88),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18, color: palette.attention),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      l10n.cardVoiceConsent,
                      key: const ValueKey('voice-consent'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (!_canRecord)
            Text(
              l10n.cardVoiceUnavailable,
              key: const ValueKey('voice-unavailable'),
              style: Theme.of(context).textTheme.bodySmall,
            )
          else ...[
            if (_permissionDenied)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  l10n.cardVoiceDenied,
                  key: const ValueKey('voice-denied'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.attention,
                  ),
                ),
              ),
            _VoiceRow(
              language: AppLanguage.en,
              label: l10n.cardLabelEnglish,
              path: _audioEn,
              recording: _recordingFor == AppLanguage.en,
              onToggle: () => _toggleRecording(AppLanguage.en),
              onPlay: () => widget.voiceRecorder.play(_audioEn!),
              onRemove: () => _removeClip(AppLanguage.en),
            ),
            const SizedBox(height: AppSpacing.xs),
            _VoiceRow(
              language: AppLanguage.ur,
              label: l10n.cardLabelUrdu,
              path: _audioUr,
              recording: _recordingFor == AppLanguage.ur,
              onToggle: () => _toggleRecording(AppLanguage.ur),
              onPlay: () => widget.voiceRecorder.play(_audioUr!),
              onRemove: () => _removeClip(AppLanguage.ur),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: l10n.cardCategoryLabel,
            accent: palette.communicate,
          ),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final category in AacCategory.values)
                ChoiceChip(
                  key: ValueKey('card-cat-${category.name}'),
                  label: Text(categoryLabel(l10n, category)),
                  selected: _category == category,
                  onSelected: (_) => setState(() => _category = category),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            key: const ValueKey('save-custom-card'),
            onPressed: _valid ? _save : null,
            icon: const Icon(Icons.check),
            label: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

/// One language's record / play / remove controls.
class _VoiceRow extends StatelessWidget {
  const _VoiceRow({
    required this.language,
    required this.label,
    required this.path,
    required this.recording,
    required this.onToggle,
    required this.onPlay,
    required this.onRemove,
  });

  final AppLanguage language;
  final String label;
  final String? path;
  final bool recording;
  final VoidCallback onToggle;
  final VoidCallback onPlay;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final has = path != null && path!.isNotEmpty;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.titleSmall),
                  Text(
                    recording
                        ? l10n.cardVoiceRecording
                        : has
                        ? l10n.cardVoiceSaved
                        : '—',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: recording ? palette.attention : null,
                    ),
                  ),
                ],
              ),
            ),
            if (has && !recording)
              IconButton(
                key: ValueKey('voice-play-${language.name}'),
                tooltip: l10n.cardVoicePlay,
                onPressed: onPlay,
                icon: const Icon(Icons.play_arrow),
              ),
            if (has && !recording)
              IconButton(
                key: ValueKey('voice-remove-${language.name}'),
                tooltip: l10n.cardVoiceDelete,
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
              ),
            FilledButton.tonalIcon(
              key: ValueKey('voice-record-${language.name}'),
              onPressed: onToggle,
              icon: Icon(recording ? Icons.stop : Icons.mic),
              label: Text(
                recording ? l10n.cardVoiceStop : l10n.cardVoiceRecord,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Localized name for an AAC category. Shared by the board filter chips and
/// the custom-card editor so the two can never drift apart.
String categoryLabel(AppLocalizations l10n, AacCategory category) =>
    switch (category) {
      AacCategory.food => l10n.aacCategoryFood,
      AacCategory.drinks => l10n.aacCategoryDrinks,
      AacCategory.emotions => l10n.aacCategoryEmotions,
      AacCategory.activities => l10n.aacCategoryActivities,
      AacCategory.people => l10n.aacCategoryPeople,
      AacCategory.places => l10n.aacCategoryPlaces,
      AacCategory.needs => l10n.aacCategoryNeeds,
      AacCategory.objects => l10n.aacCategoryObjects,
    };
