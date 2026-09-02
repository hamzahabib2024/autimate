import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/theme/app_spacing.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }
  bool loading = false;
  String? error;

  Future<void> _signIn() async {
    setState(() {
      loading = true;
      error = null;
    });
    final valid = await widget.appState.authRepository.signIn(
      email.text,
      password.text,
    );
    if (!mounted) return;
    setState(() {
      loading = false;
      error = valid ? null : AppLocalizations.of(context).authErrorRequired;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.connect_without_contact, size: 64),
                const SizedBox(height: 20),
                Text(
                  l10n.authWelcome,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.authTagline,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: l10n.parentEmail),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.password),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: FilledButton(
                    onPressed: loading ? null : _signIn,
                    child: Text(loading ? l10n.signingIn : l10n.signIn),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {},
                  child: Text(l10n.createParentAccount),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
