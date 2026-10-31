import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/router/app_router.dart';
import '../model/legal_doc.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/profile_subpage_scaffold.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileSubpageScaffold(
      title: 'Legal and information',
      body: ListView(
        padding: const .fromLTRB(20, 8, 20, 28),
        children: [
          ProfileMenuCard(
            children: [
              for (final type in LegalDocType.values)
                ProfileMenuTile(
                  icon: Icons.description_outlined,
                  label: type.title,
                  onTap: () => context.push(
                    '${AppRoutes.legalDoc}/${type.path}',
                  ),
                ),
            ],
          ),
          18.h,
          Text(
            'Pitchside is operated for players booking sports courts across Pakistan.',
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
