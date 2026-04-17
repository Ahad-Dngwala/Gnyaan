import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gnyaan/core/theme/app_colors.dart';
import 'package:gnyaan/core/theme/app_text_styles.dart';
import 'package:gnyaan/core/constants/app_constants.dart';
import 'package:gnyaan/shared/widgets/app_buttons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  int _currentPage = 0;

  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: LucideIcons.brain,
      gradient: [AppColors.brandLight, AppColors.brand],
      title: 'Ask. Don\'t Search.',
      subtitle:
          'Upload any PDF, DOCX, or TXT. Gnyaan creates a semantic memory of your documents so you can jump straight to the answers.',
      badge: 'Grounded AI',
      badgeColor: AppColors.brand,
    ),
    _OnboardingPage(
      icon: LucideIcons.search,
      gradient: [AppColors.accentLight, AppColors.accent],
      title: 'Exact Paragraphs.\nSourced Answers.',
      subtitle:
          'Our retrieval engine fetches the precise context for your question. Every single answer cites its exact source.',
      badge: 'RAG Engine',
      badgeColor: AppColors.accent,
    ),
    _OnboardingPage(
      icon: LucideIcons.fileText,
      gradient: [AppColors.brand, AppColors.accentDark],
      title: 'Instant Summaries.',
      subtitle:
          'Get TL;DRs, key concepts, and a glossary the moment you add a file to your Knowledge Base.',
      badge: '< 30 seconds',
      badgeColor: AppColors.success,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bg800,
      body: Stack(
        children: [
          // ── Animated background particles ─────────────────────────────
          AnimatedBuilder(
            animation: _particleController,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _ParticlePainter(
                progress: _particleController.value,
                pageIndex: _currentPage,
              ),
            ),
          ),

          // ── Hero glow orb ─────────────────────────────────────────────
          Positioned(
            top: -80,
            left: size.width * 0.15,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Container(
                width: size.width * 0.7,
                height: size.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _pages[_currentPage].gradient[0]
                          .withOpacity(0.12 + _pulseController.value * 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Main content ──────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // App branding
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.brain,
                          size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AppConstants.appName,
                      style: AppTextStyles.h2.copyWith(
                        background: Paint()
                          ..shader = AppColors.brandGradient.createShader(
                            const Rect.fromLTWH(0, 0, 100, 30),
                          ),
                        color: Colors.transparent,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.3, end: 0),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _pages.length,
                    itemBuilder: (_, i) => _PageContent(page: _pages[i]),
                  ),
                ),

                // Page indicators
                _PageIndicators(
                  count: _pages.length,
                  currentIndex: _currentPage,
                ),
                const SizedBox(height: 32),

                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding),
                  child: _currentPage < _pages.length - 1
                      ? Row(
                          children: [
                            GhostButton(
                              label: 'Skip',
                              onPressed: _goToApp,
                            ),
                            const Spacer(),
                            PrimaryButton(
                              label: 'Next',
                              icon: LucideIcons.arrowRight,
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: AppDurations.slow,
                                  curve: Curves.easeInOut,
                                );
                              },
                              width: 140,
                            ),
                          ],
                        )
                      : PrimaryButton(
                          label: 'Start Exploring',
                          icon: LucideIcons.sparkles,
                          onPressed: _goToApp,
                          width: double.infinity,
                          gradient: LinearGradient(
                            colors: _pages[_currentPage].gradient,
                          ),
                        ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _goToApp() {
    Navigator.of(context).pushReplacementNamed('/home');
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _PageContent extends StatelessWidget {
  const _PageContent({required this.page});
  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding * 1.5),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Hero icon box
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: page.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: page.gradient.first.withOpacity(0.4),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(page.icon, size: 52, color: Colors.white),
          )
              .animate()
              .scale(
                begin: const Offset(0.7, 0.7),
                end: const Offset(1.0, 1.0),
                curve: Curves.elasticOut,
                duration: 700.ms,
              )
              .fadeIn(duration: 400.ms),

          const SizedBox(height: 32),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: page.badgeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: page.badgeColor.withOpacity(0.3)),
            ),
            child: Text(
              page.badge,
              style: AppTextStyles.overline.copyWith(
                color: page.badgeColor,
                letterSpacing: 1.0,
              ),
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 20),

          // Title
          Text(
            page.title,
            style: AppTextStyles.displayLg,
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 500.ms)
              .slideY(begin: 0.3, end: 0, delay: 300.ms),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            page.subtitle,
            style: AppTextStyles.bodyLg.copyWith(
              color: AppColors.textMuted,
              height: 1.7,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 450.ms, duration: 500.ms),
        ],
      ),
    );
  }
}

class _PageIndicators extends StatelessWidget {
  const _PageIndicators({required this.count, required this.currentIndex});
  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        children: [
          Text(
            '0${currentIndex + 1}',
            style: AppTextStyles.h2.copyWith(color: AppColors.text),
          ),
          Text(
            ' / 0$count',
            style: AppTextStyles.h2.copyWith(color: AppColors.textPlaceholder),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border200,
                borderRadius: BorderRadius.circular(2),
              ),
              alignment: Alignment.centerLeft,
              child: AnimatedFractionallySizedBox(
                duration: AppDurations.normal,
                curve: Curves.easeOutCubic,
                widthFactor: (currentIndex + 1) / count,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data model ─────────────────────────────────────────────────────────────────

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
  });
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
}

// ── Custom painter for floating particles ──────────────────────────────────────

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.progress, required this.pageIndex});
  final double progress;
  final int pageIndex;

  static const List<List<Color>> _palettes = [
    [AppColors.brand, AppColors.violet],
    [AppColors.accent, AppColors.brand],
    [AppColors.success, AppColors.accent],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final colors = _palettes[pageIndex % _palettes.length];
    final rng = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < 20; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = 0.3 + rng.nextDouble() * 0.7;
      final y = (baseY - progress * speed * size.height) % size.height;
      final radius = 1.5 + rng.nextDouble() * 2.5;
      final opacity = 0.1 + rng.nextDouble() * 0.25;
      final color = i % 2 == 0 ? colors[0] : colors[1];

      paint.color = color.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) =>
      old.progress != progress || old.pageIndex != pageIndex;
}
