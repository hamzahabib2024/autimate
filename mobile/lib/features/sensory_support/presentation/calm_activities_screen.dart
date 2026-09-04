import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;

import '../../../core/services/app_services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/ambient_sound.dart';
import '../domain/breathing_pattern.dart';

/// Guided breathing: a slow pace circle expanding on the inhale, holding,
/// then contracting on the exhale. No haptics anywhere. Sensory mode slows
/// the whole cycle and keeps the visuals softer.
class BreathingScreen extends StatefulWidget {
  const BreathingScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;
  bool _running = false;
  bool _starAwarded = false;
  int _cyclesCompleted = 0;

  static const double _minScale = 0.6;

  /// The chosen rhythm, slowed in sensory mode.
  ///
  /// Scaling rather than swapping matters: the inhale-to-exhale ratio *is*
  /// the pattern, and a calmer version that flattened it would be a
  /// different exercise wearing the same name.
  BreathingPattern get _pattern => widget.appState.sensoryMode
      ? widget.appState.breathingPattern.scaled(1.35)
      : widget.appState.breathingPattern;

  Duration get _cycleDuration => _pattern.cycle;

  @override
  void initState() {
    super.initState();
    // A raw ticker keeps an accumulated clock, so cycle counting survives
    // arbitrarily long frame gaps (unlike comparing consecutive values).
    _ticker = createTicker(_onElapsed);
  }

  @override
  void dispose() {
    if (_ticker.isActive) _ticker.stop();
    _ticker.dispose();
    super.dispose();
  }

  void _onElapsed(Duration elapsed) {
    final cycles =
        elapsed.inMilliseconds ~/ _cycleDuration.inMilliseconds;
    if (cycles > _cyclesCompleted) _cyclesCompleted = cycles;
    setState(() => _elapsed = elapsed);
  }

  double get _cycleValue =>
      (_elapsed.inMilliseconds % _cycleDuration.inMilliseconds) /
      _cycleDuration.inMilliseconds;

  ({String label, double scale}) _phaseFor(
    double value,
    AppLocalizations l10n,
  ) {
    final pattern = _pattern;
    final phase = pattern.phaseAt(
      Duration(
        milliseconds: (value * pattern.cycle.inMilliseconds).round(),
      ),
    );
    final eased = phase.isHold
        // A held phase keeps the circle still. A circle that drifts during
        // a hold teaches the wrong timing.
        ? phase.openness
        : Curves.easeInOut.transform(phase.openness.clamp(0.0, 1.0));
    return (
      label: switch (phase.id) {
        'inhale' => l10n.breathPhaseInhale,
        'holdIn' => l10n.breathPhaseHoldIn,
        'exhale' => l10n.breathPhaseExhale,
        _ => l10n.breathPhaseHoldOut,
      },
      scale: _minScale + (1 - _minScale) * eased,
    );
  }

  static String patternLabel(AppLocalizations l10n, BreathingPattern pattern) =>
      switch (pattern.id) {
        'box' => l10n.breathingPatternBox,
        'fourSevenEight' => l10n.breathingPatternFourSevenEight,
        _ => l10n.breathingPatternGentle,
      };

  /// Pattern picker. Changing rhythm mid-session restarts the count, since
  /// a cycle half-finished in one pattern is not a cycle in another.
  Widget _patternPicker(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.breathingPatternLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final pattern in BreathingPattern.all)
              ChoiceChip(
                key: ValueKey('breathing-pattern-${pattern.id}'),
                label: Text(patternLabel(l10n, pattern)),
                selected: widget.appState.breathingPattern.id == pattern.id,
                onSelected: (_) {
                  widget.appState.setBreathingPattern(pattern);
                  setState(() {
                    _elapsed = Duration.zero;
                    _cyclesCompleted = 0;
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          l10n.breathingPatternNote,
          key: const ValueKey('breathing-note'),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }

  void _toggle() async {
    if (_running) {
      _ticker.stop();
      setState(() => _running = false);
      if (_cyclesCompleted > 0 && !_starAwarded) {
        widget.appState.awardStars(1);
        _starAwarded = true;
      }
      return;
    }
    await widget.appState.ttsService.speak(
      AppLocalizations.of(context).breatheIn,
      widget.appState.locale,
    );
    if (!mounted) return;
    // Loop gently until the child chooses Rest; the ticker clock counts
    // full cycles for the quiet star reward.
    setState(() {
      _running = true;
      _elapsed = Duration.zero;
      _cyclesCompleted = 0;
    });
    _ticker.start();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.breathingTitle)),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 300,
              child: Center(
                child: Builder(
                  builder: (context) {
                    final phase = _phaseFor(
                      _running ? _cycleValue : 0.0,
                      l10n,
                    );
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.scale(
                          scale:
                              _running ? phase.scale : _minScale,
                          child: Container(
                            key: const ValueKey('breathing-circle'),
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          key: const ValueKey('breathing-cue'),
                          _running ? phase.label : l10n.breathingStart,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: _patternPicker(context, l10n),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 64),
                child: FilledButton.icon(
                  key: const ValueKey('breathing-toggle'),
                  onPressed: _toggle,
                  icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                  label: Text(_running ? l10n.breathingStop : l10n.breathingStart),
                ),
              ),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }
}

/// Slow visual patterns: pastel circles drifting at a glacial pace. With
/// sensory mode on the composition is completely still. The gentle-sound
/// toggle is opt-in and off by default; it never loops automatically.
class CalmingScreen extends StatefulWidget {
  const CalmingScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<CalmingScreen> createState() => _CalmingScreenState();
}

class _CalmingScreenState extends State<CalmingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift =
      AnimationController(vsync: this, duration: const Duration(seconds: 8));

  @override
  void initState() {
    super.initState();
    if (!widget.appState.sensoryMode) {
      _drift.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  Future<void> _toggleSound() async {
    await widget.appState.toggleAmbientSound();
    if (mounted) setState(() {});
  }

  Future<void> _selectTrack(AmbientTrack track) async {
    await widget.appState.setAmbientTrack(track);
    if (mounted) setState(() {});
  }

  Future<void> _setVolume(double value) async {
    await widget.appState.setAmbientVolume(value);
    if (mounted) setState(() {});
  }

  String _trackLabel(AppLocalizations l10n, AmbientTrack track) =>
      switch (track) {
        AmbientTrack.softRain => l10n.ambientTrackSoftRain,
        AmbientTrack.slowOcean => l10n.ambientTrackSlowOcean,
        AmbientTrack.warmHum => l10n.ambientTrackWarmHum,
      };

  IconData _trackIcon(AmbientTrack track) => switch (track) {
        AmbientTrack.softRain => Icons.water_drop_outlined,
        AmbientTrack.slowOcean => Icons.waves_outlined,
        AmbientTrack.warmHum => Icons.graphic_eq,
      };

  /// Track picker and level, revealed only while the bed is playing so the
  /// resting screen stays as bare as the rest of the calm surfaces.
  Widget _soundControls(BuildContext context, AppLocalizations l10n) {
    final palette = context.palette;
    final appState = widget.appState;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        children: [
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            alignment: WrapAlignment.center,
            children: [
              for (final track in AmbientTrack.values)
                ChoiceChip(
                  key: ValueKey('ambient-track-${track.name}'),
                  avatar: Icon(_trackIcon(track), size: 18),
                  label: Text(_trackLabel(l10n, track)),
                  selected: appState.ambientTrack == track,
                  onSelected: (_) => _selectTrack(track),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(Icons.volume_mute, size: 20, color: palette.sensory),
              Expanded(
                child: Slider(
                  key: const ValueKey('ambient-volume'),
                  value: appState.ambientVolume,
                  onChanged: _setVolume,
                  label: l10n.ambientVolumeLabel,
                ),
              ),
              Icon(Icons.volume_up, size: 20, color: palette.sensory),
            ],
          ),
          Text(
            l10n.ambientVolumeHint,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = [
      Theme.of(context).colorScheme.primaryContainer,
      Theme.of(context).colorScheme.secondaryContainer,
      Theme.of(context).colorScheme.tertiaryContainer,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.calmingTitle)),
      body: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: _drift,
              builder: (context, _) {
                final t = _drift.value;
                return Stack(
                  key: const ValueKey('calm-pattern'),
                  children: [
                    for (var i = 0; i < 5; i++)
                      Positioned(
                        left: 30.0 +
                            i * 60 +
                            (widget.appState.sensoryMode
                                ? 0
                                : 20 * (t - 0.5) * (i.isEven ? 1 : -1)),
                        top: 60.0 + (i % 3) * 140,
                        child: Opacity(
                          opacity: 0.55,
                          child: Container(
                            key: ValueKey('calm-shape-$i'),
                            width: 90 + i * 12,
                            height: 90 + i * 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors[i % colors.length],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  l10n.calmingHint,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 64),
                  child: FilledButton.tonalIcon(
                    key: const ValueKey('calm-sound'),
                    onPressed: _toggleSound,
                    icon: Icon(
                      widget.appState.ambientSoundService.isPlaying
                          ? Icons.volume_up
                          : Icons.volume_off,
                    ),
                    label: Text(
                      widget.appState.ambientSoundService.isPlaying
                          ? l10n.calmSoundOn
                          : l10n.calmSoundOff,
                    ),
                  ),
                ),
                if (widget.appState.ambientSoundService.isPlaying)
                  _soundControls(context, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
