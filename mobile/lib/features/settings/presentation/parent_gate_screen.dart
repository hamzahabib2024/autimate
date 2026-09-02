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
    final width = MediaQuery.sizeOf(context).width;
    final buttonExtent =
        ((width.clamp(240.0, 420.0) - 48) / 3).toDouble();
    Widget keyButton(int digit) => Padding(
          padding: const EdgeInsets.all(6),
          child: SizedBox(
            width: buttonExtent,
            height: 64,
            child: FilledButton.tonal(
              key: ValueKey('pin-digit-$digit'),
              onPressed: () => _appendDigit(digit),
              child: Text('$digit', style: const TextStyle(fontSize: 22)),
            ),
          ),
        );

    return Column(
      children: [
        for (final row in const [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [for (final digit in row) keyButton(digit)],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(6),
              child: SizedBox(width: buttonExtent, height: 64),
            ),
            keyButton(0),
            Padding(
              padding: const EdgeInsets.all(6),
              child: SizedBox(
                width: buttonExtent,
                height: 64,
                child: IconButton.filledTonal(
                  key: const ValueKey('pin-delete'),
                  onPressed: _deleteDigit,
                  icon: const Icon(Icons.backspace_outlined),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
