import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
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
      error = valid ? null : 'Enter an email and password to continue.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.connect_without_contact, size: 64),
                const SizedBox(height: 20),
                Text(
                  'Welcome to AutiMate',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'A calm communication and learning space for children and caregivers.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Parent email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
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
                FilledButton(
                  onPressed: loading ? null : _signIn,
                  child: Text(loading ? 'Loading...' : 'Sign in'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {},
                  child: const Text('Create a parent account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
