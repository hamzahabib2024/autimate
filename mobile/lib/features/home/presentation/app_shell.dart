import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../authentication/presentation/auth_screen.dart';
import '../../communication/presentation/aac_screen.dart';
import '../../emotion_recognition/presentation/emotion_screen.dart';
import '../../gamification/presentation/gamification_screen.dart';
import '../../parent_dashboard/presentation/dashboard_screen.dart';
import '../../routines/presentation/routines_screen.dart';
import '../../sensory_support/presentation/sensory_support_screen.dart';
import '../../settings/presentation/parent_gate_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../social_communication/presentation/social_stories_screen.dart';
import 'feature_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({required this.appState, super.key});

  final AppState appState;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  Future<bool> _unlockCaregiverArea() async {
    if (!widget.appState.childMode) return true;
    final unlocked = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ParentGateScreen(appState: widget.appState),
      ),
    );
    return unlocked ?? false;
  }

  Future<void> _openSettings() async {
    if (!await _unlockCaregiverArea()) return;
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(appState: widget.appState),
      ),
    );
  }

  Future<void> _selectDestination(int value) async {
    const caregiverTabs = {3};
    if (caregiverTabs.contains(value)) {
      if (!await _unlockCaregiverArea()) return;
    }
    setState(() => _index = value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!widget.appState.signedIn) return AuthScreen(appState: widget.appState);
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) => _buildShell(context, l10n),
    );
  }

  Widget _buildShell(BuildContext context, AppLocalizations l10n) {
    final pages = [
      _home(context, l10n),
      AacScreen(appState: widget.appState),
      RoutinesScreen(appState: widget.appState),
      DashboardScreen(appState: widget.appState),
    ];
    return Scaffold(
      body: Column(
        children: [
          if (widget.appState.offline)
            OfflineBanner(message: l10n.offlineBanner),
          Expanded(
            child: IndexedStack(index: _index, children: pages),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _selectDestination,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.forum_outlined),
            selectedIcon: const Icon(Icons.forum),
            label: l10n.navCommunicate,
          ),
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: const Icon(Icons.today),
            label: l10n.navRoutine,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights),
            label: l10n.navProgress,
          ),
        ],
      ),
    );
  }

  Widget _home(BuildContext context, AppLocalizations l10n) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('AutiMate'),
            actions: [
              IconButton(
                tooltip: l10n.settingsTooltip,
                onPressed: _openSettings,
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  l10n.homeGreeting,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(l10n.homeTagline),
                const SizedBox(height: 20),
                _summaryCard(context, l10n),
                const SizedBox(height: 20),
                Text(l10n.homeToday, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                FeatureTile(
                  title: l10n.emotionPracticeTileTitle,
                  subtitle: l10n.emotionPracticeTileSubtitle,
                  icon: Icons.emoji_emotions_outlined,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EmotionScreen(appState: widget.appState),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FeatureTile(
                  title: l10n.socialStoriesTileTitle,
                  subtitle: l10n.socialStoriesTileSubtitle,
                  icon: Icons.auto_stories_outlined,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SocialStoriesScreen(
                        appState: widget.appState,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FeatureTile(
                  title: l10n.learningPathTileTitle,
                  subtitle: l10n.learningPathTileSubtitle,
                  icon: Icons.lightbulb_outline,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FeatureScreen(
                        title: l10n.learningPathTileTitle,
                        description: l10n.interestLearningDescription,
                        icon: Icons.lightbulb_outline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FeatureTile(
                  title: l10n.gamificationTileTitle,
                  subtitle: l10n.gamificationTileSubtitle,
                  icon: Icons.stars_outlined,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          GamificationScreen(appState: widget.appState),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FeatureTile(
                  title: l10n.sensorySupportTileTitle,
                  subtitle: l10n.sensorySupportTileSubtitle,
                  icon: Icons.spa_outlined,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          SensorySupportScreen(appState: widget.appState),
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

  Widget _summaryCard(BuildContext context, AppLocalizations l10n) {
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
                    widget.appState.selectedChild.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(l10n.beginnerSupportLevel),
                  const SizedBox(height: 14),
                  Text(
                    l10n.starsEarned(widget.appState.stars),
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
