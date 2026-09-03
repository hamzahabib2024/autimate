import 'package:flutter/material.dart';

import '../../../core/data/backup/backup_service.dart';
import '../../../core/data/backup/profile_backup.dart';
import '../../../core/services/app_services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_widgets.dart';
import 'parent_gate_screen.dart';

/// Backup, restore, and profile transfer.
///
/// Caregiver tier and behind the parent lock: an export contains a child's
/// name and history, and an import can overwrite everything.
class BackupScreen extends StatefulWidget {
  const BackupScreen({
    required this.appState,
    required this.service,
    super.key,
  });

  final AppState appState;
  final BackupService service;

  static Future<void> openGated(
    BuildContext context,
    AppState appState,
    BackupService service,
  ) async {
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
        builder: (_) => BackupScreen(appState: appState, service: service),
      ),
    );
  }

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _busy = false;
  String? _status;
  bool _statusIsError = false;

  void _report(String message, {bool error = false}) {
    if (!mounted) return;
    setState(() {
      _status = message;
      _statusIsError = error;
      _busy = false;
    });
  }

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final backup = await widget.service.build();
      final path = await widget.service.writeToFile(backup);
      await widget.service.share(path);
      _report(l10n.backupExported(backup.summary.childCount));
    } catch (error) {
      _report(l10n.backupFailed, error: true);
    }
  }

  String _errorText(AppLocalizations l10n, BackupError error) =>
      switch (error) {
        BackupError.notJson => l10n.backupErrorNotJson,
        BackupError.notAutiMate => l10n.backupErrorNotOurs,
        BackupError.tooNew => l10n.backupErrorTooNew,
        BackupError.unreadable => l10n.backupErrorUnreadable,
      };

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _status = null;
    });
    final ProfileBackup? backup;
    try {
      backup = await widget.service.pickAndDecode();
    } on BackupFormatException catch (failure) {
      _report(_errorText(l10n, failure.error), error: true);
      return;
    } catch (error) {
      _report(l10n.backupFailed, error: true);
      return;
    }
    if (backup == null) {
      setState(() => _busy = false);
      return;
    }
    if (!mounted) return;

    // Nothing is applied until the caregiver has seen what is in the file
    // and chosen how to apply it. Import is the one action here that can
    // destroy data.
    final mode = await showDialog<ImportMode>(
      context: context,
      builder: (_) => _ImportConfirmDialog(summary: backup!.summary),
    );
    if (mode == null || !mounted) {
      setState(() => _busy = false);
      return;
    }
    try {
      final count = await widget.service.apply(backup, mode: mode);
      _report(l10n.backupImported(count));
    } catch (error) {
      _report(l10n.backupFailed, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            l10n.backupSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),

          SectionHeader(
            title: l10n.backupExportTitle,
            accent: palette.communicate,
          ),
          Text(
            l10n.backupExportSubtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton.icon(
            key: const ValueKey('backup-export'),
            onPressed: _busy ? null : _export,
            icon: const Icon(Icons.ios_share),
            label: Text(l10n.backupExportAction),
          ),

          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: l10n.backupImportTitle,
            accent: palette.communicate,
          ),
          Text(
            l10n.backupImportSubtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            key: const ValueKey('backup-import'),
            onPressed: _busy ? null : _import,
            icon: const Icon(Icons.file_open_outlined),
            label: Text(l10n.backupImportAction),
          ),

          if (_busy)
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              child: LinearProgressIndicator(),
            ),
          if (_status != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Card(
                color: _statusIsError
                    ? palette.accentTint(palette.attention, 0.86)
                    : palette.accentTint(palette.success, 0.86),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(
                        _statusIsError
                            ? Icons.error_outline
                            : Icons.check_circle_outline,
                        color: _statusIsError
                            ? palette.attention
                            : palette.success,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _status!,
                          key: const ValueKey('backup-status'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.xl),
          // The privacy cost of the feature, stated where the decision is
          // made rather than in a policy nobody opens.
          Card(
            color: palette.accentTint(palette.attention, 0.9),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.privacy_tip_outlined,
                    size: 20,
                    color: palette.attention,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.backupPrivacyWarning,
                      key: const ValueKey('backup-privacy'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows what is in the file, then asks how to apply it.
class _ImportConfirmDialog extends StatefulWidget {
  const _ImportConfirmDialog({required this.summary});

  final BackupSummary summary;

  @override
  State<_ImportConfirmDialog> createState() => _ImportConfirmDialogState();
}

class _ImportConfirmDialogState extends State<_ImportConfirmDialog> {
  ImportMode _mode = ImportMode.merge;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summary = widget.summary;
    return AlertDialog(
      title: Text(l10n.backupConfirmTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.backupConfirmContents(
              summary.childNames.join(', '),
              summary.cardCount,
              summary.sessionCount,
            ),
          ),
          if (summary.mediaCount > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            // Media is referenced, not embedded — say so before the import,
            // not after the cards come back without their photos.
            Text(
              l10n.backupMediaNote(summary.mediaCount),
              key: const ValueKey('backup-media-note'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          RadioGroup<ImportMode>(
            groupValue: _mode,
            onChanged: (value) {
              if (value == null) return;
              setState(() => _mode = value);
            },
            child: Column(
              children: [
                RadioListTile<ImportMode>(
                  key: const ValueKey('backup-mode-merge'),
                  value: ImportMode.merge,
                  title: Text(l10n.backupModeMerge),
                  subtitle: Text(l10n.backupModeMergeHint),
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<ImportMode>(
                  key: const ValueKey('backup-mode-replace'),
                  value: ImportMode.replace,
                  title: Text(l10n.backupModeReplace),
                  subtitle: Text(l10n.backupModeReplaceHint),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const ValueKey('backup-confirm'),
          onPressed: () => Navigator.of(context).pop(_mode),
          child: Text(l10n.backupImportAction),
        ),
      ],
    );
  }
}
