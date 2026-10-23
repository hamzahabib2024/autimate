import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/services/app_services.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../ai/domain/ai_contracts.dart';
import '../../ai/domain/expression_practice_engine.dart';

enum ExpressionPhase {
  checking,
  unsupported,
  permissionDenied,
  permissionPermanentlyDenied,
  cameraBusy,
  loading,
  error,
  practicing,
  complete,
}

class ExpressionPracticeScreen extends ConsumerStatefulWidget {
  const ExpressionPracticeScreen({
    required this.appState,
    this.service,
    this.engine,
    this.permissions,
    super.key,
  });

  final AppState appState;

  /// Overridable for tests. In the app the ML Kit adapter comes from
  /// [expressionPracticeServiceProvider].
  final ExpressionPracticeService? service;

  /// Overridable for tests so time-dependent holds are deterministic.
  final ExpressionSessionEngine? engine;

  /// Overridable for tests. In the app the real OS permission service comes
  /// from [cameraPermissionServiceProvider].
  final CameraPermissionService? permissions;

  @override
  ConsumerState<ExpressionPracticeScreen> createState() =>
      _ExpressionPracticeScreenState();
}

class _ExpressionPracticeScreenState
    extends ConsumerState<ExpressionPracticeScreen>
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
    _service = widget.service ?? ref.read(expressionPracticeServiceProvider);
    _engine = widget.engine ?? ExpressionSessionEngine();
    _permissions =
        widget.permissions ?? ref.read(cameraPermissionServiceProvider);
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
        _onResumed();
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

  /// Returns from background. A paused practice reattaches its stream; a
  /// permission screen re-checks the OS (the caregiver may just have
  /// granted access in Settings), so no restart is needed.
  void _onResumed() {
    final wasPaused = _cameraPausedByLifecycle;
    _cameraPausedByLifecycle = false;
    if (!mounted) return;

    if (wasPaused && _phase == ExpressionPhase.practicing) {
      unawaited(_attachStream());
      return;
    }
    if (_phase == ExpressionPhase.permissionDenied ||
        _phase == ExpressionPhase.permissionPermanentlyDenied) {
      unawaited(_recheckPermission());
    }
  }

  /// Re-reads permission without prompting, which is what a return from
  /// Settings needs. A still-denied state stays calm and unchanged.
  Future<void> _recheckPermission() async {
    try {
      final status = await _permissions.status();
      if (!mounted) return;
      switch (status) {
        case CameraPermissionStatus.granted:
          setState(() => _phase = ExpressionPhase.loading);
        case CameraPermissionStatus.permanentlyDenied:
          setState(() => _phase = ExpressionPhase.permissionPermanentlyDenied);
        case CameraPermissionStatus.restricted:
          setState(() => _phase = ExpressionPhase.unsupported);
        case CameraPermissionStatus.denied:
        case CameraPermissionStatus.unsupported:
          break;
      }
    } catch (_) {
      // A failed re-check must not turn a calm screen into an error.
    }
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
    CameraPermissionStatus status;
    try {
      status = await _permissions.status();
    } catch (_) {
      if (mounted) setState(() => _phase = ExpressionPhase.unsupported);
      return;
    }
    if (!mounted) return;

    switch (status) {
      case CameraPermissionStatus.granted:
        setState(() => _phase = ExpressionPhase.loading);
      case CameraPermissionStatus.permanentlyDenied:
        setState(() => _phase = ExpressionPhase.permissionPermanentlyDenied);
      case CameraPermissionStatus.restricted:
      case CameraPermissionStatus.unsupported:
        setState(() => _phase = ExpressionPhase.unsupported);
      case CameraPermissionStatus.denied:
        await _requestPermission();
    }
  }

  /// Asks once, then resolves to a terminal state. Re-prompting after a
  /// permanent denial is a no-op on both platforms, so that case routes to
  /// Settings instead of looping the dialog.
  Future<void> _requestPermission() async {
    final result = await _showRationaleDialog();
    if (!mounted) return;
    if (result == null) {
      setState(() => _phase = ExpressionPhase.permissionDenied);
      return;
    }
    switch (result) {
      case CameraPermissionStatus.granted:
        setState(() => _phase = ExpressionPhase.loading);
      case CameraPermissionStatus.permanentlyDenied:
        setState(() => _phase = ExpressionPhase.permissionPermanentlyDenied);
      case CameraPermissionStatus.restricted:
      case CameraPermissionStatus.unsupported:
        setState(() => _phase = ExpressionPhase.unsupported);
      case CameraPermissionStatus.denied:
        setState(() => _phase = ExpressionPhase.permissionDenied);
    }
  }

  /// Opens this app's settings so a caregiver can undo a permanent denial.
  /// The resume observer re-checks the permission when they come back.
  Future<void> _openSettings() async {
    await _permissions.openSettings();
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
      // Cancel the old subscription *before* opening a new session: its
      // onCancel calls stop(), which must not race the new stream.
      await _subscription?.cancel();
      _subscription = null;
      final frames = _service.start();
      _subscription = frames.listen(
        _onReading,
        onError: (Object error) {
          if (mounted) setState(() => _phase = _phaseForFailure(error));
        },
      );
    } catch (error) {
      if (mounted) setState(() => _phase = _phaseForFailure(error));
    }
  }

  /// Maps a typed service failure onto a calm screen. Unknown errors still
  /// land somewhere recoverable rather than escaping to Flutter's error UI.
  ExpressionPhase _phaseForFailure(Object error) {
    final reason = error is ExpressionPracticeException ? error.reason : null;
    return switch (reason) {
      ExpressionCameraFailure.permissionDenied =>
        ExpressionPhase.permissionDenied,
      ExpressionCameraFailure.noCamera => ExpressionPhase.unsupported,
      ExpressionCameraFailure.cameraInUse => ExpressionPhase.cameraBusy,
      ExpressionCameraFailure.initialisationFailed => ExpressionPhase.error,
      null => ExpressionPhase.error,
    };
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
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          switch (_phase) {
            ExpressionPhase.checking => const Center(
              child: CircularProgressIndicator(),
            ),
            ExpressionPhase.loading => Column(
              children: [
                StatePanel(
                  accent: context.palette.emotions,
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
              accent: context.palette.emotions,
              key: const ValueKey('permission-unsupported-panel'),
              title: l10n.expressionTitle,
              message: l10n.expressionUnsupported,
              icon: Icons.videocam_off_outlined,
            ),
            ExpressionPhase.permissionDenied => Column(
              children: [
                StatePanel(
                  accent: context.palette.emotions,
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
            ExpressionPhase.permissionPermanentlyDenied => Column(
              children: [
                StatePanel(
                  accent: context.palette.emotions,
                  key: const ValueKey('permission-permanently-denied-panel'),
                  title: l10n.expressionTitle,
                  message: l10n.expressionPermissionPermanentlyDenied,
                  icon: Icons.no_photography_outlined,
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 64),
                  child: FilledButton(
                    key: const ValueKey('permission-open-settings'),
                    onPressed: _openSettings,
                    child: Text(l10n.expressionOpenSettings),
                  ),
                ),
              ],
            ),
            ExpressionPhase.cameraBusy => Column(
              children: [
                StatePanel(
                  accent: context.palette.emotions,
                  key: const ValueKey('camera-busy-panel'),
                  title: l10n.expressionTitle,
                  message: l10n.expressionCameraBusy,
                  icon: Icons.videocam_off_outlined,
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 64),
                  child: OutlinedButton(
                    onPressed: _start,
                    child: Text(l10n.expressionTryAgain),
                  ),
                ),
              ],
            ),
            ExpressionPhase.error => Column(
              children: [
                StatePanel(
                  accent: context.palette.emotions,
                  title: l10n.expressionTitle,
                  message: l10n.expressionCameraError,
                  icon: Icons.error_outline,
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 64),
                  child: OutlinedButton(
                    onPressed: _start,
                    child: Text(l10n.expressionTryAgain),
                  ),
                ),
              ],
            ),
            ExpressionPhase.complete => Column(
              children: [
                StatePanel(
                  accent: context.palette.emotions,
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
                _cameraPreview(context, l10n),
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
            accent: context.palette.emotions,
            title: l10n.expressionPrivacyTitle,
            message: l10n.expressionPrivacyNote,
            icon: Icons.shield_outlined,
          ),
        ],
      ),
    );
  }

  /// Shows the live camera when the service supports it, otherwise the warm
  /// icon placeholder. Presentation only sees [CameraPreviewSource], never the
  /// camera plugin itself.
  Widget _cameraPreview(BuildContext context, AppLocalizations l10n) {
    final placeholder = Center(
      child: AnimatedScale(
        scale: _holding ? 1.15 : 1,
        duration: const Duration(milliseconds: 200),
        child: Icon(
          Icons.sentiment_very_satisfied,
          size: 110,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
    Widget? preview;
    if (_service case final CameraPreviewSource source) {
      preview = source.buildPreview(placeholder: placeholder);
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: Semantics(
          label: l10n.expressionPreviewLabel,
          image: true,
          child: preview ?? placeholder,
        ),
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
