import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_loading_handler.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_subpage_scaffold.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadHelp();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final cubit = context.read<ProfileCubit>();
        return ProfileSubpageScaffold(
          title: 'Help and support',
          body: AppLoadingHandler(
            status: state.status,
            errorMessage: state.errorMessage,
            onRetry: cubit.loadHelp,
            child: ListView(
              padding: const .fromLTRB(20, 8, 20, 28),
              children: [
                Text(
                  'Frequently asked',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: .w800,
                  ),
                ),
                10.h,
                for (final faq in state.faqs) ...[
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const .only(bottom: 10),
                    title: Text(
                      faq.question,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: .w700,
                      ),
                    ),
                    children: [
                      Text(
                        faq.answer,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ).align(alignment: .centerLeft),
                    ],
                  ),
                  const Divider(color: AppColors.outline),
                ],
                AppSizes.spaceLg.h,
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                  child: Padding(
                    padding: const .all(18),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          'Still need help?',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: .w800,
                          ),
                        ),
                        6.h,
                        Text(
                          'Our team replies within a few minutes, 9 AM to 11 PM.',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onPrimary.withValues(alpha: 0.84),
                          ),
                        ),
                        16.h,
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: () {
                                  AppHaptics.selection();
                                  context.go(AppRoutes.messages);
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: AppColors.onAccent,
                                ),
                                child: const Text('Chat with us'),
                              ),
                            ),
                            10.w,
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  AppHaptics.selection();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('+92 300 0000000'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.onPrimary,
                                  side: const BorderSide(
                                    color: AppColors.onPrimary,
                                  ),
                                ),
                                child: const Text('Call us'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
