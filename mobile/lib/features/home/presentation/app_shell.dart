import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../authentication/presentation/auth_screen.dart';
import '../../communication/presentation/aac_screen.dart';
import '../../emotion_recognition/presentation/emotion_screen.dart';
import '../../gamification/presentation/gamification_screen.dart';
import '../../learning/presentation/learning_path_screen.dart';
import '../../parent_dashboard/presentation/dashboard_screen.dart';
import '../../routines/presentation/routines_screen.dart';
import '../../sensory_support/presentation/sensory_support_screen.dart';
import '../../settings/presentation/parent_gate_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../social_communication/presentation/social_stories_screen.dart';

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

  /// The child's landing surface.
  ///
  /// Module accents do the wayfinding here: a child learns "the green tile
  /// is my routine" well before they can read the label, so each module
  /// keeps its colour on every surface it owns.
  Widget _home(BuildContext context, AppLocalizations l10n) {
    final palette = context.palette;
    return ChildTextScale(
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text('AutiMate'),
              floating: true,
              actions: [
                IconButton(
                  tooltip: l10n.settingsTooltip,
                  onPressed: _openSettings,
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _summaryCard(context, l10n),
                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(
                    title: l10n.homeToday,
                    accent: palette.communicate,
                  ),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 0.98,
                    children: [
                      ChildActionCard(
                        title: l10n.emotionPracticeTileTitle,
                        subtitle: l10n.emotionPracticeTileSubtitle,
                        icon: Icons.emoji_emotions_outlined,
                        accent: palette.emotions,
                        onTap: () => _push(
                          EmotionScreen(appState: widget.appState),
                        ),
                      ),
                      ChildActionCard(
                        title: l10n.socialStoriesTileTitle,
                        subtitle: l10n.socialStoriesTileSubtitle,
                        icon: Icons.auto_stories_outlined,
                        accent: palette.routine,
                        onTap: () => _push(
                          SocialStoriesScreen(appState: widget.appState),
                        ),
                      ),
                      ChildActionCard(
                        title: l10n.learningPathTileTitle,
                        subtitle: l10n.learningPathTileSubtitle,
                        icon: Icons.lightbulb_outline,
                        accent: palette.learning,
                        onTap: () => _push(
                          LearningPathScreen(appState: widget.appState),
                        ),
                      ),
                      ChildActionCard(
                        title: l10n.gamificationTileTitle,
                        subtitle: l10n.gamificationTileSubtitle,
                        icon: Icons.stars_outlined,
                        accent: palette.progress,
                        onTap: () => _push(
                          GamificationScreen(appState: widget.appState),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FeatureTile(
                    title: l10n.sensorySupportTileTitle,
                    subtitle: l10n.sensorySupportTileSubtitle,
                    icon: Icons.spa_outlined,
                    accent: palette.sensory,
                    onTap: () => _push(
                      SensorySupportScreen(appState: widget.appState),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _push(Widget screen) => Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => screen),
  );

  /// Profile header: who is using the app, and how they are doing.
  Widget _summaryCard(BuildContext context, AppLocalizations l10n) {
    final palette = context.palette;
    return Semantics(
      label: l10n.greetingChild(widget.appState.selectedChild.name),
      child: Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.accentTint(palette.communicate, 0.86),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: palette.communicate, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeGreeting,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  widget.appState.selectedChild.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  l10n.homeTagline,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: palette.progress,
                      size: 26,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      l10n.starsEarned(widget.appState.stars),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Mascot(size: 92),
        ],
      ),
      ),
    );
  }
}
