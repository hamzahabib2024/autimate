import 'package:flutter/material.dart';

/// Motion tokens and the single resolver every animation in the app must
/// pass through.
///
/// Two things suppress motion, and both matter for this audience:
/// the in-app sensory mode, and the operating system's own "remove
/// animations" accessibility setting exposed as
/// `MediaQuery.disableAnimations`. Honouring the OS switch means a child
/// whose device is already configured for reduced motion gets it here
/// without a caregiver having to find the toggle.
///
/// Curves are always decelerating. Nothing in this app overshoots,
/// bounces, or springs — anticipation and rebound read as unpredictable.
class AppMotion {
  const AppMotion._();

  /// Press feedback, chip selection.
  static const Duration fast = Duration(milliseconds: 120);

  /// The default: card entry, cross-fades, list insertion.
  static const Duration base = Duration(milliseconds: 240);

  /// Deliberate transitions the child is meant to notice.
  static const Duration slow = Duration(milliseconds: 400);

  /// Reward moments — long enough to register, short enough not to block.
  static const Duration reward = Duration(milliseconds: 600);

  /// One breathing cycle in the calming activity.
  static const Duration breath = Duration(seconds: 4);

  static const Curve curve = Curves.easeOutCubic;
  static const Curve curveIn = Curves.easeInCubic;

  /// True when motion must be suppressed for this frame.
  static bool reduced(BuildContext context, {required bool sensoryMode}) =>
      sensoryMode || MediaQuery.of(context).disableAnimations;

  /// Resolves a duration against sensory mode and the OS setting.
  ///
  /// Transform-based motion collapses to zero. Callers that only cross-fade
  /// may pass [keepFade] so the opacity change still reads as a change of
  /// state rather than a jump cut.
  static Duration resolve(
    BuildContext context, {
    required bool sensoryMode,
    Duration duration = base,
    bool keepFade = false,
  }) {
    if (!reduced(context, sensoryMode: sensoryMode)) return duration;
    return keepFade ? const Duration(milliseconds: 200) : Duration.zero;
  }
}
