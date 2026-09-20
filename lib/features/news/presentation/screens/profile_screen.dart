
import 'package:flutter/material.dart';
import 'package:khabark/core/constants/app_spacing.dart';
import 'package:khabark/core/theme/app_colors.dart';
import 'package:khabark/core/theme/app_text_styles.dart';




/// these fields in.
class ProfileScreen extends StatelessWidget {
  final String? displayName;
  final String email;
  final String? photoUrl;
  final String signInMethod; 
  final VoidCallback onLogout;
  final VoidCallback? onBack;

  const ProfileScreen({
    super.key,
    this.displayName,
    required this.email,
    this.photoUrl,
    required this.signInMethod,
    required this.onLogout,
    this.onBack,
  });

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.cardBorderRadius,
        ),
        title: Text('Log out?', style: AppTextStyles.headlineSmall),
        content: Text(
          'Are you sure you want to log out of Khabark?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Log out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String initial = (displayName != null && displayName!.isNotEmpty)
        ? displayName![0].toUpperCase()
        : (email.isNotEmpty ? email[0].toUpperCase() : 'U');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: onBack != null
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textPrimary,
                ),
                onPressed: onBack,
              )
            : null,
        title: Text('Profile & Settings', style: AppTextStyles.titleMedium),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.m,
              ),
              child: Column(
                children: [
                  // User Avatar
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage:
                        photoUrl != null ? NetworkImage(photoUrl!) : null,
                    child: photoUrl == null
                        ? Text(
                            initial,
                            style: AppTextStyles.headlineLarge.copyWith(
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.m),

                  // Display Name
                  if (displayName != null && displayName!.isNotEmpty) ...[
                    Text(displayName!, style: AppTextStyles.headlineSmall),
                    const SizedBox(height: AppSpacing.xs),
                  ],

                  // Email Address
                  Text(email, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: AppSpacing.s),

                  // Sign-in method badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppSpacing.chipBorderRadius,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          signInMethod.toLowerCase() == 'google'
                              ? Icons.g_mobiledata_rounded
                              : Icons.mail_outline_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Signed in with $signInMethod',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),

                  // Settings Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppSpacing.cardBorderRadius,
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppSpacing.cardShadow,
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.textSecondary,
                          ),
                          title: Text(
                            'About Khabark',
                            style: AppTextStyles.titleMedium,
                          ),
                          subtitle: Text(
                            'v1.2.0 • Independent journalism',
                            style: AppTextStyles.bodySmall,
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondary,
                          ),
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.privacy_tip_outlined,
                            color: AppColors.textSecondary,
                          ),
                          title: Text(
                            'Privacy Policy',
                            style: AppTextStyles.titleMedium,
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondary,
                          ),
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.description_outlined,
                            color: AppColors.textSecondary,
                          ),
                          title: Text(
                            'Terms of Service',
                            style: AppTextStyles.titleMedium,
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondary,
                          ),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Outlined Red Log Out Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      label: Text(
                        'Log out',
                        style: AppTextStyles.button
                            .copyWith(color: AppColors.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.error,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppSpacing.buttonBorderRadius,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),

                  // Editorial Footer note
                  Text(
                    '“Clarity in a world of noise.”\nKhabark Publishing Group',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}