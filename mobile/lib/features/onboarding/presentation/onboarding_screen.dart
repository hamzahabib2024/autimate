import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/app_services.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_widgets.dart';

/// First-run setup: language, child profile, and the caregiver PIN.
///
/// `AutiMateApp` swaps this screen for the shell once
/// [AppState.onboarded] flips, so no manual navigation is needed.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _pin = TextEditingController();
  Locale _locale = const Locale('en');
  String _supportLevel = 'Beginner';

  @override
  void initState() {
    super.initState();
    _locale = widget.appState.locale;
  }

  @override
  void dispose() {
    _name.dispose();
    _pin.dispose();
    super.dispose();
  }

  bool get _valid =>
      _name.text.trim().isNotEmpty &&
      RegExp(r'^\d{4}$').hasMatch(_pin.text);

  Future<void> _start(AppLocalizations l10n) async {
    await widget.appState.completeOnboarding(
      childName: _name.text.trim(),
      supportLevel: _supportLevel,
      locale: _locale,
      parentPin: _pin.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: Mascot(size: 120)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.onboardingTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.onboardingSubtitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    DropdownButtonFormField<Locale>(
                      key: const ValueKey('onboard-language'),
                      initialValue: _locale,
                      decoration: InputDecoration(
                        labelText: l10n.chooseLanguageLabel,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.language),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: const Locale('en'),
                          child: Text(l10n.languageEnglish),
                        ),
                        DropdownMenuItem(
                          value: const Locale('ur'),
                          child: Text(l10n.languageUrdu),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _locale = value);
                        widget.appState.setLocale(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      key: const ValueKey('onboard-name'),
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.childNameLabel,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.child_care_outlined),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 20),
                    Text(l10n.supportLevel,
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final level in const [
                          'Beginner',
                          'Intermediate',
                          'Advanced',
                        ])
                          ChoiceChip(
                            key: ValueKey('onboard-level-$level'),
                            // A chip cannot wrap, so at a large system text
                            // scale the longest label ("Intermediate support
                            // level") is wider than a 320dp screen. Bounding
                            // it lets the chip ellipsize instead of pushing
                            // past the edge.
                            label: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.sizeOf(context).width - 120,
                              ),
                              child: Text(
                                _levelLabel(l10n, level),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            selected: _supportLevel == level,
                            onSelected: (_) =>
                                setState(() => _supportLevel = level),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      key: const ValueKey('onboard-pin'),
                      controller: _pin,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: l10n.createPinLabel,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        counterText: '',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 24),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: AppTouch.child,
                      ),
                      child: FilledButton.icon(
                        key: const ValueKey('onboard-start'),
                        onPressed: _valid ? () => _start(l10n) : null,
                        icon: const Icon(Icons.arrow_forward),
                        // maxLines with ellipsis, and no Flexible of our
                        // own: FilledButton.icon already wraps its label in
                        // one, and a second competing ParentDataWidget on
                        // the same render object is an error. Letting the
                        // text ellipsize gives that existing Flexible the
                        // give it needs at a large system text scale.
                        label: Text(
                          l10n.getStarted,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _levelLabel(AppLocalizations l10n, String level) => switch (level) {
    'Intermediate' => l10n.intermediateSupportLevel,
    'Advanced' => l10n.advancedSupportLevel,
    _ => l10n.beginnerSupportLevel,
  };
}
