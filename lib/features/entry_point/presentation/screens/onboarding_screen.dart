import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khabark/core/constants/app_spacing.dart';
import 'package:khabark/core/theme/app_colors.dart';
import 'package:khabark/core/theme/app_text_styles.dart';
import 'package:khabark/core/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onGetStarted;

  const OnboardingScreen({super.key, required this.onGetStarted});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _startAnimation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _startAnimation = true);
    });
  }

  Widget _buildAnimatedStep({required int index, required Widget child}) {
    return AnimatedSlide(
      offset: _startAnimation ? Offset.zero : const Offset(0, 0.25),
      duration: Duration(milliseconds: 600 + (index * 150)),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _startAnimation ? 1.0 : 0.0,
        duration: Duration(milliseconds: 600 + (index * 150)),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.l,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSpacing.m),

                  _buildAnimatedStep(
                    index: 0,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Khabark',
                              style: GoogleFonts.merriweather(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          'Stay informed. Stay ahead.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  _buildAnimatedStep(
                    index: 1,
                    child: const _FeatureRow(
                      icon: Icons.newspaper_rounded,
                      text: 'Top headlines from trusted sources',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  _buildAnimatedStep(
                    index: 2,
                    child: const _FeatureRow(
                      icon: Icons.tune_rounded,
                      text: 'Search and filter by category',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  _buildAnimatedStep(
                    index: 3,
                    child: const _FeatureRow(
                      icon: Icons.menu_book_rounded,
                      text: 'Read the full story in one tap',
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  _buildAnimatedStep(
                    index: 4,
                    child: PrimaryButton(
                      text: 'Get started',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: widget.onGetStarted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.cardBorderRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: AppSpacing.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.titleMedium.copyWith(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
