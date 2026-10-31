import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_icons.dart';
import '../../../core/utils/app_haptics.dart';

class ProfileSubpageScaffold extends StatelessWidget {
  const ProfileSubpageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottomBar,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: 8,
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: Material(
              color: AppColors.surface,
              shape: const CircleBorder(
                side: BorderSide(color: AppColors.border),
              ),
              elevation: 0,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  AppHaptics.selection();
                  context.pop();
                },
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    AppIcons.back,
                    color: AppColors.text,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: bottomBar,
    );
  }
}
