import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/app_services.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/theme/app_spacing.dart';

/// Numeric PIN gate in front of every caregiver surface.
///
/// Pops with `true` when the entered PIN matches the stored hash. With no
/// PIN configured the gate opens immediately so first-run setup stays
/// frictionless.
class ParentGateScreen extends StatefulWidget {
  const ParentGateScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<ParentGateScreen> createState() => _ParentGateScreenState();
}

class _ParentGateScreenState extends State<ParentGateScreen> {
  String _entry = '';
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    if (!widget.appState.hasParentPin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop(true);
      });
    }
  }

  void _appendDigit(int digit) {
    if (_entry.length >= 4) return;
    HapticFeedback.selectionClick();
    setState(() {
      _failed = false;
      _entry = '$_entry$digit';
    });
    if (_entry.length == 4) _submit();
  }

  void _deleteDigit() {
    if (_entry.isEmpty) return;
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  Future<void> _submit() async {
    if (widget.appState.verifyParentPin(_entry)) {
      if (!mounted) return;
      Navigator.of(context).pop(true);
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    setState(() {
      _failed = true;
      _entry = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.parentLockTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.enterParentPin,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 32,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < 4; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            i < _entry.length
                                ? Icons.circle
                                : Icons.circle_outlined,
                            size: i < _entry.length ? 20 : 18,
                            color: _failed
                                ? Theme.of(context).colorScheme.error
                                : null,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  key: const ValueKey('gate-error'),
                  l10n.pinIncorrect,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _failed
                        ? Theme.of(context).colorScheme.error
                        : Colors.transparent,
                  ),
                ),
                const SizedBox(height: 16),
                _pad(context),
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: TextButton.icon(
                    key: const ValueKey('gate-cancel'),
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close),
                    label: Text(l10n.cancel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pad(BuildContext context) {
    // Sized from the width this widget is actually given, not the screen's.
    //
    // It previously measured `MediaQuery.sizeOf(context).width`, which is
    // wider than the padded column the pad sits in — so on a wide phone the
    // three keys added up to more than the row could hold and Flutter
    // reported an overflow. LayoutBuilder asks the parent instead, which is
    // correct at any width and inside any padding.
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 6.0;
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        // Three keys, each with `gap` padding on both sides.
        final extent = ((available - gap * 6) / 3).clamp(56.0, 132.0);
        final height = (extent * 0.62).clamp(56.0, 72.0);

        Widget slot({Widget? child, Key? key}) => Padding(
          padding: const EdgeInsets.all(gap),
          child: SizedBox(width: extent, height: height, child: child),
        );

        Widget keyButton(int digit) => slot(
          child: FilledButton.tonal(
            key: ValueKey('pin-digit-$digit'),
            onPressed: () => _appendDigit(digit),
            child: FittedBox(
              // The glyph shrinks rather than clipping when a large system
              // text scale meets a small key.
              child: Text('$digit', style: const TextStyle(fontSize: 22)),
            ),
          ),
        );

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final row in const [
              [1, 2, 3],
              [4, 5, 6],
              [7, 8, 9],
            ])
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [for (final digit in row) keyButton(digit)],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Empty slot keeps zero centred under the 8.
                slot(),
                keyButton(0),
                slot(
                  child: IconButton.filledTonal(
                    key: const ValueKey('pin-delete'),
                    onPressed: _deleteDigit,
                    icon: const Icon(Icons.backspace_outlined),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
