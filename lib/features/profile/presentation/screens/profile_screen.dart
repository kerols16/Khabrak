import 'package:flutter/material.dart';
import 'package:khabark/core/constants/app_spacing.dart';
import 'package:khabark/core/theme/app_colors.dart';
import 'package:khabark/core/theme/app_text_styles.dart';


class ProfileScreen extends StatelessWidget {
  final String? displayName;
  final String email;
  final String? photoUrl;
  final String signInMethod; 
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    this.displayName,
    required this.email,
    this.photoUrl,
    required this.signInMethod,
    required this.onLogout,
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
          'Are you sure you want to log out?',
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
        title: Text('Profile', style: AppTextStyles.titleMedium),
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

                  if (displayName != null && displayName!.isNotEmpty) ...[
                    Text(displayName!, style: AppTextStyles.headlineSmall),
                    const SizedBox(height: AppSpacing.xs),
                  ],

                  Text(email, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: AppSpacing.s),

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

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppSpacing.cardBorderRadius,
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppSpacing.cardShadow,
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.textSecondary,
                      ),
                      title: Text(
                        'About Khabark',
                        style: AppTextStyles.titleMedium,
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
                      ),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Khabark',
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}