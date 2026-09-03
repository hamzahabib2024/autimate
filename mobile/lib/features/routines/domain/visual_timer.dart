
/// How the passage of time is drawn.
///
/// The tension this enum exists to resolve: a continuously depleting timer
/// is the single most useful representation of waiting, and it is also
/// exactly the ambient motion the design system otherwise forbids. Rather
/// than pick one, the caregiver picks — and sensory mode picks for them.
enum TimerStyle {
  /// A smoothly depleting ring. The clearest, and the most motion.
  smooth,

  /// The ring steps down in discrete blocks. Still shows time shrinking,
  /// but changes a handful of times rather than sixty times a second.
  stepped,

  /// No animation. The remaining time is a number that updates each second.
  /// Least useful, and the right default for a child who fixates on motion.
  still,
}

/// A countdown a child can see.
///
/// Deliberately not tied to a widget: the state is testable on its own, and
/// the same timer can drive a ring, a bar, or a bare number.
///
/// It counts *down* to zero rather than up, because "how much is left" is
/// the question a waiting child is actually asking.
class VisualTimer {
  VisualTimer({
    required this.duration,
    this.style = TimerStyle.stepped,
    this.steps = 12,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       assert(steps > 0, 'a stepped timer needs at least one step');

  final Duration duration;
  final TimerStyle style;

  /// Number of discrete blocks in [TimerStyle.stepped].
  final int steps;

  final DateTime Function() _clock;

  DateTime? _startedAt;
  Duration _elapsedBeforePause = Duration.zero;
  bool _running = false;

  bool get isRunning => _running;
  bool get hasStarted => _startedAt != null || _elapsedBeforePause > Duration.zero;

  Duration get elapsed {
    final started = _startedAt;
    if (!_running || started == null) return _elapsedBeforePause;
    return _elapsedBeforePause + _clock().difference(started);
  }

  Duration get remaining {
    final left = duration - elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  bool get isComplete => remaining == Duration.zero && hasStarted;

  /// 0..1 of the way through. Used directly by the ring.
  double get progress {
    if (duration.inMilliseconds <= 0) return 1;
    return (elapsed.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  /// Progress quantised for the current style.
  ///
  /// This is what a widget should draw. Quantising here rather than in the
  /// widget means the "how much motion" decision lives in one place and is
  /// testable without pumping frames.
  double get displayProgress => switch (style) {
    TimerStyle.smooth => progress,
    TimerStyle.stepped => (progress * steps).floor() / steps,
    // `still` still reports true progress; the widget simply does not
    // animate between values.
    TimerStyle.still => progress,
  };

  /// How often a widget needs to rebuild for this style. A still timer
  /// updating sixty times a second would be pure waste.
  Duration get tickInterval => switch (style) {
    TimerStyle.smooth => const Duration(milliseconds: 60),
    TimerStyle.stepped => Duration(
      milliseconds: (duration.inMilliseconds / steps).clamp(200, 60000).round(),
    ),
    TimerStyle.still => const Duration(seconds: 1),
  };

  void start() {
    if (_running || isComplete) return;
    _startedAt = _clock();
    _running = true;
  }

  void pause() {
    if (!_running) return;
    _elapsedBeforePause = elapsed;
    _startedAt = null;
    _running = false;
  }

  void reset() {
    _startedAt = null;
    _elapsedBeforePause = Duration.zero;
    _running = false;
  }

  /// Adds time to a timer already running.
  ///
  /// "One more minute" is the most common real request at the end of a
  /// wait, and refusing it is a good way to cause the meltdown the timer
  /// existed to prevent.
  VisualTimer extendedBy(Duration extra) {
    final extended = VisualTimer(
      duration: duration + extra,
      style: style,
      steps: steps,
      clock: _clock,
    )
      .._elapsedBeforePause = _elapsedBeforePause
      .._startedAt = _startedAt
      .._running = _running;
    return extended;
  }
}

/// Common wait lengths, so a caregiver picks rather than types.
///
/// Capped at fifteen minutes on purpose: a visual timer is a support for a
/// wait a child can hold in mind, and beyond that it becomes a source of
/// anxiety rather than a relief from it.
class TimerPresets {
  const TimerPresets._();

  static const List<Duration> values = [
    Duration(minutes: 1),
    Duration(minutes: 2),
    Duration(minutes: 5),
    Duration(minutes: 10),
    Duration(minutes: 15),
  ];

  static const Duration defaultWait = Duration(minutes: 2);
}
