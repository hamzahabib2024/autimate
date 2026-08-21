import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../ai/data/simulated_expression_service.dart';
import '../../ai/domain/ai_contracts.dart';
import '../../ai/domain/expression_practice_engine.dart';

enum ExpressionPhase {
  checking,
  unsupported,
  permissionDenied,
  loading,
  error,
  practicing,
  complete,
}

class ExpressionPracticeScreen extends StatefulWidget {
  const ExpressionPracticeScreen({
    required this.appState,
    this.service,
    this.engine,
    this.permissions,
    super.key,
  });

  final AppState appState;

  /// Overridable for tests; defaults to the offline simulated source until
  /// the ML Kit camera adapter lands on physical hardware.
  final ExpressionPracticeService? service;

  /// Overridable for tests so time-dependent holds are deterministic.
  final ExpressionSessionEngine? engine;

  /// Overridable for tests; defaults to always-granted so the simulated
  /// flow needs no OS interaction.
  final CameraPermissionService? permissions;

  @override
  State<ExpressionPracticeScreen> createState() =>
      _ExpressionPracticeScreenState();
}

class _ExpressionPracticeScreenState extends State<ExpressionPracticeScreen>
    with WidgetsBindingObserver {
  late final ExpressionPracticeService _service;
  late final ExpressionSessionEngine _engine;
  late final CameraPermissionService _permissions;

  StreamSubscription<ExpressionReading>? _subscription;
  ExpressionPhase _phase = ExpressionPhase.checking;
  double _smoothedSmile = 0;
  bool _holding = false;
  bool _faceDetected = true;
  bool _eyesClosed = false;
  double _headTiltDeg = 0;
  bool _cameraPausedByLifecycle = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _service = widget.service ?? SimulatedExpressionService();
    _engine = widget.engine ?? ExpressionSessionEngine();
    _permissions = widget.permissions ?? const AutoGrantCameraPermissions();
    _checkSupport();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    unawaited(_service.stop());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        _pauseCamera();
      case AppLifecycleState.resumed:
        _resumeCamera();
      case AppLifecycleState.detached:
        break;
    }
  }

  /// Stops the camera whenever the app leaves the foreground so frames
  /// are never captured in the background.
  void _pauseCamera() {
    if (_phase != ExpressionPhase.practicing) return;
    _cameraPausedByLifecycle = true;
    unawaited(_subscription?.cancel());
    _subscription = null;
    unawaited(_service.stop());
  }

  /// Reattaches the stream without resetting session progress.
  void _resumeCamera() {
    final wasPaused = _cameraPausedByLifecycle;
    _cameraPausedByLifecycle = false;
    if (!wasPaused ||
        !mounted ||
        _phase != ExpressionPhase.practicing) {
      return;
    }
    unawaited(_attachStream());
  }

  Future<void> _checkSupport() async {
    setState(() => _phase = ExpressionPhase.checking);
    try {
      final supported = await _service.isSupported();
      if (!mounted) return;
      if (!supported) {
        setState(() => _phase = ExpressionPhase.unsupported);
        return;
      }
      await _resolvePermission();
    } catch (_) {
      if (mounted) setState(() => _phase = ExpressionPhase.error);
    }
  }

  Future<void> _resolvePermission() async {
    var status = await _permissions.status();
    // The rationale loop keeps showing until the child/caregiver grants
    // access or opts out; denial lands in [ExpressionPhase.permissionDenied].
    while (status != CameraPermissionStatus.granted && mounted) {
      if (status == CameraPermissionStatus.unsupported) {
        setState(() => _phase = ExpressionPhase.permissionDenied);
        return;
      }
      final afterRequest = await _showRationaleDialog();
      if (!mounted) return;
      if (afterRequest == null) {
        setState(() => _phase = ExpressionPhase.permissionDenied);
        return;
      }
      status = afterRequest;
    }
    if (mounted) setState(() => _phase = ExpressionPhase.loading);
  }

  /// Explains why the camera is needed and returns the resulting status,
  /// or null when the user declines ("Not now" or back-dismiss).
  Future<CameraPermissionStatus?> _showRationaleDialog() {
    final l10n = AppLocalizations.of(context);
    return showDialog<CameraPermissionStatus>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.expressionRationaleTitle),
        content: Text(l10n.expressionRationaleBody),
        actions: [
          TextButton(
            key: const ValueKey('permission-not-now'),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.expressionNotNow),
          ),
          FilledButton(
            key: const ValueKey('permission-allow'),
            onPressed: () async {
              final requested = await _permissions.request();
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop(requested);
              }
            },
            child: Text(l10n.expressionAllowCamera),
          ),
        ],
      ),
    );
  }

  void markPermissionDenied() {
    if (mounted) setState(() => _phase = ExpressionPhase.permissionDenied);
  }

  Future<void> _start() async {
    setState(() {
      _phase = ExpressionPhase.practicing;
      _engine.restart();
      _smoothedSmile = 0;
      _holding = false;
      _faceDetected = true;
      _eyesClosed = false;
      _headTiltDeg = 0;
    });
    await _attachStream();
  }

  Future<void> _attachStream() async {
    try {
      final frames = _service.start();
      await _subscription?.cancel();
      _subscription = frames.listen(
        _onReading,
        onError: (Object _) {
          if (mounted) setState(() => _phase = ExpressionPhase.error);
        },
      );
    } catch (_) {
      if (mounted) setState(() => _phase = ExpressionPhase.error);
    }
  }

  void _onReading(ExpressionReading reading) {
    final feedback = _engine.feed(reading);
    if (!mounted) return;
    setState(() {
      _smoothedSmile = feedback.smoothedSmile;
      _holding = feedback.holding;
      _faceDetected = feedback.faceDetected;
      _eyesClosed = feedback.eyesClosed;
      _headTiltDeg = feedback.headTiltedDeg;
    });
    if (feedback.starAwarded) widget.appState.awardStars(1);
    if (feedback.sessionComplete) {
      unawaited(_subscription?.cancel());
      unawaited(_service.stop());
      setState(() => _phase = ExpressionPhase.complete);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.expressionTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          switch (_phase) {
            ExpressionPhase.checking => const Center(
              child: CircularProgressIndicator(),
            ),
            ExpressionPhase.loading => Column(
              children: [
                StatePanel(
                  title: l10n.expressionTitle,
                  message: l10n.expressionHoldSmile,
                  icon: Icons.sentiment_very_satisfied_outlined,
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 64),
                  child: FilledButton(
                    onPressed: _start,
                    child: Text(l10n.expressionStart),
                  ),
                ),
              ],
            ),
            ExpressionPhase.unsupported => StatePanel(
              title: l10n.expressionTitle,
              message: l10n.expressionUnsupported,
              icon: Icons.videocam_off_outlined,
            ),
            ExpressionPhase.permissionDenied => Column(
              children: [
                StatePanel(
                  key: const ValueKey('permission-denied-panel'),
                  title: l10n.expressionTitle,
                  message: l10n.expressionPermissionDenied,
                  icon: Icons.no_photography_outlined,
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 64),
                  child: OutlinedButton(
                    onPressed: _checkSupport,
                    child: Text(l10n.expressionAllowCamera),
                  ),
                ),
              ],
            ),
            ExpressionPhase.error => StatePanel(
              title: l10n.expressionTitle,
              message: l10n.expressionCameraError,
              icon: Icons.error_outline,
            ),
            ExpressionPhase.complete => Column(
              children: [
                StatePanel(
                  title: l10n.expressionSessionComplete(_engine.starsEarned),
                  message: l10n.expressionPrivacyNote,
                  icon: Icons.stars_outlined,
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 64),
                  child: FilledButton(
                    onPressed: _start,
                    child: Text(l10n.practiseAgain),
                  ),
                ),
              ],
            ),
            ExpressionPhase.practicing => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.expressionHoldSmile,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                Card(
                  child: SizedBox(
                    height: 160,
                    child: Center(
                      child: AnimatedScale(
                        scale: _holding ? 1.15 : 1,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.sentiment_very_satisfied,
                          size: 110,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: l10n.expressionHoldSmile,
                  value: '${(_smoothedSmile * 100).round()}%',
                  child: LinearProgressIndicator(
                    value: _smoothedSmile.clamp(0, 1),
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.expressionSmileProgress(
                    _engine.starsEarned,
                    _engine.config.repsTarget,
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (!_faceDetected)
                  _postureHint(context, l10n.expressionComeCloserHint)
                else if (_eyesClosed)
                  _postureHint(context, l10n.expressionEyesHint)
                else if (_headTiltDeg.abs() >
                    ExpressionSessionEngine.headTiltThresholdDeg)
                  _postureHint(context, l10n.expressionLookStraightHint),
              ],
            ),
          },
          const SizedBox(height: 24),
          StatePanel(
            title: l10n.expressionPrivacyTitle,
            message: l10n.expressionPrivacyNote,
            icon: Icons.shield_outlined,
          ),
        ],
      ),
    );
  }

  Widget _postureHint(BuildContext context, String message) {
    return Padding(
      key: const ValueKey('expression-hint'),
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
