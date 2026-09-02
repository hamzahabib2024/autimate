import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../domain/visual_timer.dart';

/// The waiting board.
///
/// Waiting is one of the hardest moments in an autistic child's day, and
/// most of the difficulty is that time is invisible. This makes it visible:
/// a ring that empties, a plain number, and — the part that matters most —
/// **what happens when the wait ends**.
///
/// That last element is why this is not merely a countdown widget. A timer
/// alone says "not yet". A waiting board says "not yet, and then *this*",
/// which is a fundamentally easier thing to hold on to.
class WaitingScreen extends StatefulWidget {
  const WaitingScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  late VisualTimer _timer = VisualTimer(
    duration: TimerPresets.defaultWait,
    style: _styleForMode,
  );
  Timer? _ticker;
  bool _announced = false;

  /// Sensory mode forces the quietest representation. A caregiver can still
  /// choose a livelier one, but not by accident.
  TimerStyle get _styleForMode =>
      widget.appState.sensoryMode ? TimerStyle.still : TimerStyle.stepped;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _restartTicker() {
    _ticker?.cancel();
    if (!_timer.isRunning) return;
    _ticker = Timer.periodic(_timer.tickInterval, (_) {
      if (!mounted) return;
      setState(() {});
      if (_timer.isComplete && !_announced) {
        _announced = true;
        _ticker?.cancel();
        _onComplete();
      }
    });
  }

  void _onComplete() {
    final l10n = AppLocalizations.of(context);
    // Spoken, because a child watching the ring may not be reading, and a
    // finished wait that nobody announces is just a stopped ring.
    widget.appState.ttsService.speak(
      l10n.waitingDone,
      widget.appState.locale,
    );
  }

  void _setDuration(Duration duration) {
    setState(() {
      _timer = VisualTimer(duration: duration, style: _styleForMode);
      _announced = false;
    });
    _restartTicker();
  }

  void _setStyle(TimerStyle style) {
    setState(() {
      _timer = VisualTimer(duration: _timer.duration, style: style);
      _announced = false;
    });
    _restartTicker();
  }

  void _toggle() {
    setState(() {
      _timer.isRunning ? _timer.pause() : _timer.start();
    });
    _restartTicker();
  }

  void _reset() {
    setState(() {
      _timer.reset();
      _announced = false;
    });
    _ticker?.cancel();
  }

  void _extend() {
    setState(() {
      _timer = _timer.extendedBy(const Duration(minutes: 1));
      _announced = false;
    });
    _restartTicker();
  }

  String _clockText(Duration remaining) {
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final reduced = AppMotion.reduced(
      context,
      sensoryMode: widget.appState.sensoryMode,
    );
    final remaining = _timer.remaining;
    final done = _timer.isComplete;

    return ChildTextScale(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.waitingTitle)),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              done ? l10n.waitingDone : l10n.waitingSubtitle,
              key: const ValueKey('waiting-headline'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: done ? palette.success : null,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Center(
              child: ProgressRing(
                key: const ValueKey('waiting-ring'),
                // Drawn from the *remaining* fraction so the ring empties
                // rather than fills: a child is watching it run out.
                progress: 1 - _timer.displayProgress,
                size: 210,
                strokeWidth: 18,
                color: done ? palette.success : palette.routine,
                // The ring's own tween is suppressed for the stepped and
                // still styles — the quantisation is the point, and letting
                // it interpolate between steps would undo it.
                animate: !reduced && _timer.style == TimerStyle.smooth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _clockText(remaining),
                      key: const ValueKey('waiting-clock'),
                      style: Theme.of(context).textTheme.displaySmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: done ? palette.success : palette.routine,
                          ),
                    ),
                    Text(
                      l10n.waitingMinutesLeft,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            PrimaryActionButton(
              key: const ValueKey('waiting-toggle'),
              label: _timer.isRunning ? l10n.waitingPause : l10n.waitingStart,
              icon: _timer.isRunning ? Icons.pause : Icons.play_arrow,
              accent: palette.routine,
              onPressed: done ? null : _toggle,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const ValueKey('waiting-extend'),
                    onPressed: _extend,
                    icon: const Icon(Icons.add),
                    // "One more minute" is the commonest real request at the
                    // end of a wait; refusing it causes the meltdown the
                    // timer existed to prevent.
                    label: Text(l10n.waitingOneMore),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: OutlinedButton.icon(
                    key: const ValueKey('waiting-reset'),
                    onPressed: _reset,
                    icon: const Icon(Icons.restart_alt),
                    label: Text(l10n.waitingReset),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),
            SectionHeader(
              title: l10n.waitingHowLong,
              accent: palette.routine,
            ),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final preset in TimerPresets.values)
                  ChoiceChip(
                    key: ValueKey('waiting-preset-${preset.inMinutes}'),
                    label: Text(l10n.waitingMinutes(preset.inMinutes)),
                    selected: _timer.duration == preset,
                    onSelected: (_) => _setDuration(preset),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),
            SectionHeader(
              title: l10n.waitingStyleTitle,
              accent: palette.routine,
            ),
            Text(
              l10n.waitingStyleSubtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final entry in <(TimerStyle, String)>[
                  (TimerStyle.smooth, l10n.waitingStyleSmooth),
                  (TimerStyle.stepped, l10n.waitingStyleStepped),
                  (TimerStyle.still, l10n.waitingStyleStill),
                ])
                  ChoiceChip(
                    key: ValueKey('waiting-style-${entry.$1.name}'),
                    label: Text(entry.$2),
                    selected: _timer.style == entry.$1,
                    onSelected: (_) => _setStyle(entry.$1),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
