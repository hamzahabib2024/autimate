import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../authentication/presentation/auth_screen.dart';
import '../../communication/presentation/aac_screen.dart';
import '../../emotion_recognition/presentation/emotion_screen.dart';
import '../../parent_dashboard/presentation/dashboard_screen.dart';
import '../../routines/presentation/routines_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import 'feature_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({required this.appState, super.key});

  final AppState appState;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    if (!widget.appState.signedIn) return AuthScreen(appState: widget.appState);
    final pages = [
      _home(context),
      const AacScreen(),
      const RoutinesScreen(),
      const DashboardScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'Communicate',
          ),
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Routine',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Progress',
          ),
        ],
      ),
    );
  }

  Widget _home(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('AutiMate'),
            actions: [
              IconButton(
                tooltip: 'Settings',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(appState: widget.appState),
                  ),
                ),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Good morning, caregiver',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'A calm place to communicate, learn, and practise together.',
                ),
                const SizedBox(height: 20),
                _summaryCard(context),
                const SizedBox(height: 20),
                Text('Today', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                FeatureTile(
                  title: 'Emotion practice',
                  subtitle: 'Learn six everyday expressions',
                  icon: Icons.emoji_emotions_outlined,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EmotionScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                FeatureTile(
                  title: 'Social stories',
                  subtitle: 'Designed and documented for the next phase',
                  icon: Icons.auto_stories_outlined,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FeatureScreen(
                        title: 'Social stories',
                        description:
                            'Short illustrated stories and guided comprehension checks will live here.',
                        icon: Icons.auto_stories_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FeatureTile(
                  title: 'Learning path',
                  subtitle: 'Interest-based activities are coming next',
                  icon: Icons.lightbulb_outline,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FeatureScreen(
                        title: 'Interest-based learning',
                        description:
                            'Deterministic interest-to-topic mapping will power this learning path.',
                        icon: Icons.lightbulb_outline,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.appState.children.first.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('Beginner support level'),
                  const SizedBox(height: 14),
                  Text(
                    '${widget.appState.stars} stars earned',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const CircleAvatar(
              radius: 32,
              child: Icon(Icons.child_care, size: 34),
            ),
          ],
        ),
      ),
    );
  }
}
