import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;

import '../../../core/services/app_services.dart';
import '../../../l10n/generated/app_localizations.dart';

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

  Duration get _cycleDuration =>
      widget.appState.sensoryMode
          ? const Duration(seconds: 16)
          : const Duration(seconds: 12);

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
    if (value < 1 / 3) {
      final t = Curves.easeInOut.transform(value * 3);
      return (
        label: l10n.breatheIn,
        scale: _minScale + (1 - _minScale) * t,
      );
    }
    if (value < 2 / 3) {
      return (label: l10n.breatheHold, scale: 1.0);
    }
    final t = Curves.easeInOut.transform((value - 2 / 3) * 3);
    return (
      label: l10n.breatheOut,
      scale: 1.0 - (1 - _minScale) * t,
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
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
    final service = widget.appState.ambientSoundService;
    service.isPlaying ? await service.stop() : await service.play();
    if (mounted) setState(() {});
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
