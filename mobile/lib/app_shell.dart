import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gnyaan/core/theme/app_colors.dart';
import 'package:gnyaan/core/theme/app_text_styles.dart';
import 'package:gnyaan/core/constants/app_constants.dart';
import 'package:gnyaan/features/knowledge_base/presentation/screens/knowledge_hub_screen.dart';
import 'package:gnyaan/features/chat/presentation/screens/chat_screen.dart';
import 'package:gnyaan/features/summary/presentation/screens/summary_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabController;

  static const List<_NavItem> _navItems = [
    _NavItem(
      icon: LucideIcons.layoutDashboard,
      activeIcon: LucideIcons.layoutDashboard,
      label: 'Hub',
    ),
    _NavItem(
      icon: LucideIcons.messageSquare,
      activeIcon: LucideIcons.messageSquare,
      label: 'Chat',
    ),
    _NavItem(
      icon: LucideIcons.fileText,
      activeIcon: LucideIcons.fileText,
      label: 'Summary',
    ),
    _NavItem(
      icon: LucideIcons.settings2,
      activeIcon: LucideIcons.settings2,
      label: 'Settings',
    ),
  ];

  final List<Widget> _screens = const [
    KnowledgeHubScreen(),
    ChatScreen(),
    SummaryScreen(),
    _SettingsPlaceholder(),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    )..forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg800,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _BottomNav(
        items: _navItems,
        selectedIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ── Bottom Navigation ─────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg700,
        border: const Border(top: BorderSide(color: AppColors.border200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((e) {
              return _NavButton(
                item: e.value,
                isSelected: e.key == selectedIndex,
                onTap: () => onTap(e.key),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppDurations.normal,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 18 : 12,
          vertical: 8,
        ),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.brand.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.brand.withOpacity(0.25)),
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              size: 20,
              color: isSelected ? AppColors.brand : AppColors.iconSubtle,
            ),
            AnimatedSize(
              duration: AppDurations.normal,
              curve: Curves.easeInOut,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        item.label,
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.brand,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data ──────────────────────────────────────────────────────────────────────

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

// ─── Settings placeholder ──────────────────────────────────────────────────────

class _SettingsPlaceholder extends StatelessWidget {
  const _SettingsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg800,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('Settings', style: AppTextStyles.h1),
              const SizedBox(height: 24),
              _SettingsSection(
                title: 'Intelligence Capabilities',
                children: [
                  _SettingsTile(
                    icon: LucideIcons.cpu,
                    title: 'LLM Reasoner',
                    subtitle: 'Determines the core analytical logic',
                    value: 'Claude-3.5-Sonnet',
                    color: AppColors.brand,
                  ),
                  _SettingsTile(
                    icon: LucideIcons.layers,
                    title: 'Explainability Level',
                    subtitle: 'Detail of answer breakdowns',
                    value: 'Standard Mode',
                    color: AppColors.violet,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SettingsSection(
                title: 'Retrieval Engine',
                children: [
                  _SettingsTile(
                    icon: LucideIcons.scissors,
                    title: 'Chunk Size Boundary',
                    subtitle: 'Granularity of document splits',
                    value: '400 Tokens',
                    color: AppColors.warning,
                  ),
                  _SettingsTile(
                    icon: LucideIcons.gitMerge,
                    title: 'Context Overlap',
                    subtitle: 'Continuity between document chunks',
                    value: '50 Tokens',
                    color: AppColors.success,
                  ),
                  _SettingsTile(
                    icon: LucideIcons.target,
                    title: 'Strictness Threshold',
                    subtitle: 'Minimum required cosine similarity',
                    value: '0.30 Alpha',
                    color: AppColors.accent,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SettingsSection(
                title: 'Environment Profile',
                children: [
                  _SettingsTile(
                    icon: LucideIcons.info,
                    title: 'Core Framework',
                    subtitle: 'Current build signature',
                    value: 'v${AppConstants.version}',
                    color: AppColors.iconSubtle,
                  ),
                  _SettingsTile(
                    icon: LucideIcons.shield,
                    title: 'Operating Mode',
                    subtitle: 'Network status & telemetry',
                    value: 'API — Online',
                    color: AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.overline.copyWith(
              color: AppColors.textSubtle,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bg600,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border200),
          ),
          child: Column(
            children: children.asMap().entries.map((e) {
              final isLast = e.key == children.length - 1;
              return Column(
                children: [
                  e.value,
                  if (!isLast)
                    const Divider(
                        height: 1, indent: 56, color: AppColors.border100),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTextStyles.labelLg),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSubtle, height: 1.3),
                  ),
                ],
              ],
            ),
          ),
          Text(
            value,
            style:
                AppTextStyles.labelMd.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(width: 8),
          const Icon(LucideIcons.chevronRight,
              size: 14, color: AppColors.iconSubtle),
        ],
      ),
    );
  }
}
