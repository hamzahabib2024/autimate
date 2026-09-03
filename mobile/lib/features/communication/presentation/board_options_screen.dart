import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../settings/presentation/parent_gate_screen.dart';
import '../data/board_printer.dart';
import '../domain/aac_catalog.dart';
import '../domain/phrase_bank.dart';
import '../domain/sentence_realiser.dart';
import '../domain/symbol_scale.dart';

/// Caregiver controls for the communication board: layout, suggestions,
/// saved phrases, and the paper copy.
///
/// Behind the parent lock. Every option here changes where words sit or how
/// the board behaves, and a child rearranging their own board by tapping
/// around would undo the motor learning it depends on.
class BoardOptionsScreen extends StatefulWidget {
  const BoardOptionsScreen({
    required this.appState,
    this.printer = const BoardPrinter(),
    super.key,
  });

  final AppState appState;
  final BoardPrinter printer;

  static Future<void> openGated(
    BuildContext context,
    AppState appState, {
    BoardPrinter printer = const BoardPrinter(),
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
        builder: (_) =>
            BoardOptionsScreen(appState: appState, printer: printer),
      ),
    );
  }

  static String shapeLabel(AppLocalizations l10n, GridShape shape) =>
      switch (shape) {
        GridShape.flowing => l10n.gridShapeFlowing,
        GridShape.twoByTwo => l10n.gridShapeTwoByTwo,
        GridShape.threeByTwo => l10n.gridShapeThreeByTwo,
        GridShape.threeByThree => l10n.gridShapeThreeByThree,
        GridShape.fourByThree => l10n.gridShapeFourByThree,
        GridShape.fiveByFour => l10n.gridShapeFiveByFour,
        GridShape.sixByEight => l10n.gridShapeSixByEight,
      };

  @override
  State<BoardOptionsScreen> createState() => _BoardOptionsScreenState();
}

class _BoardOptionsScreenState extends State<BoardOptionsScreen> {
  bool _printing = false;
  String? _printError;

  @override
  void initState() {
    super.initState();
    widget.appState.loadPhrases(force: true);
  }

  Future<void> _print() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _printing = true;
      _printError = null;
    });
    try {
      final custom = {
        for (final card in widget.appState.customCards) card.id: card,
      };
      final deck = [
        ...aacDeck,
        ...widget.appState.customCards.map((card) => card.toAacCard()),
      ];
      final bytes = await widget.printer.build(
        deck: deck,
        customCards: custom,
        language: widget.appState.locale.languageCode == 'ur'
            ? AppLanguage.ur
            : AppLanguage.en,
        shape: widget.appState.gridShape,
        childName: widget.appState.selectedChild.name,
      );
      await widget.printer.present(bytes);
      if (mounted) setState(() => _printing = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _printing = false;
        _printError = l10n.printBoardFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.coreWords)),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // --- layout ---------------------------------------------------
            SectionHeader(
              title: l10n.gridShapeLabel,
              accent: palette.communicate,
            ),
            Text(
              l10n.gridShapeSubtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final shape in GridShape.values)
                  ChoiceChip(
                    key: ValueKey('grid-shape-${shape.name}'),
                    label: Text(BoardOptionsScreen.shapeLabel(l10n, shape)),
                    selected: widget.appState.gridShape == shape,
                    onSelected: (_) => widget.appState.setGridShape(shape),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            // The honest caveat: a fixed shape is groundwork for motor
            // planning, not a delivery of it, while the filter still moves
            // cards around.
            Text(
              l10n.gridShapeNote,
              key: const ValueKey('grid-shape-note'),
              style: Theme.of(context).textTheme.labelSmall,
            ),

            // --- suggestions ----------------------------------------------
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(
              title: l10n.predictionLabel,
              accent: palette.communicate,
            ),
            SwitchListTile(
              key: const ValueKey('prediction-toggle'),
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.predictionLabel),
              subtitle: Text(l10n.predictionSubtitle),
              isThreeLine: true,
              value: widget.appState.wordPredictionEnabled,
              onChanged: widget.appState.setWordPrediction,
            ),

            // --- saved phrases --------------------------------------------
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(
              title: l10n.phraseBankTitle,
              accent: palette.communicate,
            ),
            Text(
              l10n.phraseBankSubtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Card(
              color: palette.accentTint(palette.attention, 0.9),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: palette.attention,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        l10n.phraseBankCaution,
                        key: const ValueKey('phrase-caution'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            if (widget.appState.savedPhrases.isEmpty)
              EmptyState(
                message: l10n.phraseBankEmpty,
                icon: Icons.chat_bubble_outline,
              )
            else
              for (final phrase in widget.appState.savedPhrases)
                _PhraseRow(
                  key: ValueKey('phrase-row-${phrase.id}'),
                  phrase: phrase,
                  urdu: widget.appState.locale.languageCode == 'ur',
                  onChanged: widget.appState.savePhrase,
                  onDelete: () => widget.appState.deletePhrase(phrase.id),
                ),

            // --- print -----------------------------------------------------
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(
              title: l10n.printBoardTitle,
              accent: palette.communicate,
            ),
            Text(
              l10n.printBoardSubtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton.icon(
              key: const ValueKey('print-board'),
              onPressed: _printing ? null : _print,
              icon: const Icon(Icons.print_outlined),
              label: Text(
                _printing ? l10n.printBoardWorking : l10n.printBoardAction,
              ),
            ),
            if (_printError != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  _printError!,
                  key: const ValueKey('print-error'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.attention,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One saved phrase, with its two switches.
class _PhraseRow extends StatelessWidget {
  const _PhraseRow({
    required this.phrase,
    required this.urdu,
    required this.onChanged,
    required this.onDelete,
    super.key,
  });

  final SavedPhrase phrase;
  final bool urdu;
  final Future<void> Function(SavedPhrase) onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    urdu ? phrase.labelUr : phrase.labelEn,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  key: ValueKey('phrase-delete-${phrase.id}'),
                  tooltip: l10n.phraseBankDelete,
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            SwitchListTile(
              key: ValueKey('phrase-urgent-${phrase.id}'),
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.phraseBankUrgent),
              subtitle: Text(l10n.phraseBankUrgentHint),
              value: phrase.urgent,
              onChanged: (value) =>
                  onChanged(phrase.copyWith(urgent: value)),
            ),
            SwitchListTile(
              key: ValueKey('phrase-speak-${phrase.id}'),
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.phraseBankSpeakNow),
              subtitle: Text(l10n.phraseBankSpeakNowHint),
              value: phrase.speakImmediately,
              onChanged: (value) =>
                  onChanged(phrase.copyWith(speakImmediately: value)),
            ),
          ],
        ),
      ),
    );
  }
}
