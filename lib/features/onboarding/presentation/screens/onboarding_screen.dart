import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gradient_button.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  static const _totalPages = 3;

  static const _icons = [Icons.touch_app, Icons.timer, Icons.emoji_events];
  static const _gradients = [
    AppTheme.primaryGradient,
    AppTheme.secondaryGradient,
    AppTheme.accentGradient,
  ];

  List<String> _titles(AppLocalizations l10n) => [
        l10n.onboardingTitle1,
        l10n.onboardingTitle2,
        l10n.onboardingTitle3,
      ];

  List<String> _subtitles(AppLocalizations l10n) => [
        l10n.onboardingSubtitle1,
        l10n.onboardingSubtitle2,
        l10n.onboardingSubtitle3,
      ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLast = _currentPage == _totalPages - 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: widget.onComplete,
                  child: Text(
                    l10n.skip,
                    style: AppTheme.bodyM.copyWith(color: AppTheme.textSecondary),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _totalPages,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    final titles = _titles(l10n);
                    final subtitles = _subtitles(l10n);
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingXL,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: _gradients[index],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _icons[index],
                              size: 56,
                              color: Colors.white,
                            ),
                          )
                              .animate()
                              .scale(
                                begin: const Offset(0.5, 0.5),
                                end: const Offset(1.0, 1.0),
                                duration: 600.ms,
                                curve: Curves.elasticOut,
                              )
                              .fadeIn(duration: 400.ms),
                          const SizedBox(height: AppTheme.spacingXL),
                          Text(
                            titles[index],
                            style: AppTheme.headingL,
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                          const SizedBox(height: AppTheme.spacingM),
                          Text(
                            subtitles[index],
                            style: AppTheme.bodyL.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(delay: 400.ms),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _totalPages,
                  (i) => AnimatedContainer(
                    duration: AppDurations.normal,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      gradient:
                          _currentPage == i ? AppTheme.primaryGradient : null,
                      color: _currentPage == i
                          ? null
                          : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingXL),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingXL,
                ),
                child: GradientButton(
                  text: isLast ? l10n.letsGo : l10n.next,
                  icon: isLast ? Icons.celebration : Icons.arrow_forward,
                  onPressed: () {
                    if (isLast) {
                      widget.onComplete();
                    } else {
                      _controller.nextPage(
                        duration: AppDurations.normal,
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: AppTheme.spacingXL),
            ],
          ),
        ),
      ),
    );
  }
}
