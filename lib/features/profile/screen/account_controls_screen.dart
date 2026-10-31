import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/router/app_router.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_logout_dialog.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/profile_subpage_scaffold.dart';

class AccountControlsScreen extends StatelessWidget {
  const AccountControlsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final cubit = context.read<ProfileCubit>();
        final user = state.user;
        return ProfileSubpageScaffold(
          title: 'Account controls',
          body: ListView(
            padding: const .fromLTRB(20, 8, 20, 28),
            children: [
              const ProfileSectionTitle('Sign-in and security'),
              10.h,
              ProfileMenuCard(
                children: [
                  ProfileMenuTile(
                    icon: Icons.lock_outline_rounded,
                    label: 'Change password',
                    trailing: user?.passwordUpdatedLabel.isEmpty ?? true
                        ? null
                        : user!.passwordUpdatedLabel,
                    onTap: () => context.push(AppRoutes.changePassword),
                  ),
                  ProfileMenuTile(
                    icon: Icons.mail_outline,
                    label: 'Email',
                    trailing: user?.emailVerified == true ? 'Verified' : 'Pending',
                    onTap: () {},
                  ),
                  ProfileMenuTile(
                    icon: Icons.phone_outlined,
                    label: 'Phone number',
                    trailing: user?.phoneVerified == true ? 'Verified' : 'Pending',
                    onTap: () {},
                  ),
                  ProfileMenuTile(
                    icon: Icons.link_rounded,
                    label: 'Linked accounts',
                    trailing: user?.provider == 'google' ? 'Google' : null,
                    onTap: () {},
                  ),
                ],
              ),
              14.h,
              ProfileMenuCard(
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: const .symmetric(horizontal: 14),
                    secondary: const Icon(
                      Icons.verified_user_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      'Two-step verification',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: .w700,
                      ),
                    ),
                    subtitle: Text(
                      'Ask for a code when you log in on a new device.',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    value: user?.twoStepEnabled ?? false,
                    activeThumbColor: AppColors.accent,
                    activeTrackColor: AppColors.primary,
                    onChanged: cubit.setTwoStep,
                  ),
                ],
              ),
              AppSizes.spaceLg.h,
              const ProfileSectionTitle('Your data'),
              10.h,
              ProfileMenuCard(
                children: [
                  ProfileMenuTile(
                    icon: Icons.download_outlined,
                    label: 'Download my data',
                    trailing: 'Request',
                    onTap: () async {
                      await cubit.requestDownloadData();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'We will email your data export shortly',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
              AppSizes.spaceLg.h,
              const ProfileSectionTitle('Delete account'),
              10.h,
              ProfileMenuCard(
                children: [
                  ProfileMenuTile(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete my account',
                    destructive: true,
                    onTap: () async {
                      final ok = await showDeleteAccountDialog(context);
                      if (!ok || !context.mounted) return;
                      final deleted = await cubit.deleteAccount();
                      if (!context.mounted) return;
                      if (deleted) {
                        context.go(AppRoutes.splash);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              state.errorMessage.isEmpty
                                  ? 'Could not delete account'
                                  : cubit.state.errorMessage,
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
