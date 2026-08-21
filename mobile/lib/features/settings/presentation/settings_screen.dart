import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../home/presentation/feature_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SwitchListTile(
              title: const Text('Sensory-friendly mode'),
              subtitle: const Text(
                'Reduce motion, clutter, and sound intensity',
              ),
              value: appState.sensoryMode,
              onChanged: appState.toggleSensoryMode,
            ),
            const Divider(),
            ListTile(
              title: const Text('Language'),
              subtitle: Text(
                appState.locale.languageCode == 'ur' ? 'Urdu (RTL)' : 'English',
              ),
              trailing: DropdownButton<Locale>(
                value: appState.locale,
                items: const [
                  DropdownMenuItem(value: Locale('en'), child: Text('English')),
                  DropdownMenuItem(value: Locale('ur'), child: Text('اردو')),
                ],
                onChanged: (value) {
                  if (value != null) appState.setLocale(value);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Support level'),
              subtitle: const Text('Beginner, controlled by caregiver'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const FeatureScreen(
                    title: 'Support level',
                    description:
                        'Adaptive difficulty will be connected to the rule-based controller here.',
                    icon: Icons.tune,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy and safety'),
              subtitle: const Text(
                'No diagnosis, no child-facing open chat, camera processing stays on-device',
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: appState.signOut,
            ),
          ],
        ),
      ),
    );
  }
}
