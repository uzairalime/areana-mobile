import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/extensions/extensions.dart';
import '../model/legal_doc.dart';
import '../widgets/profile_subpage_scaffold.dart';

class LegalDocScreen extends StatelessWidget {
  const LegalDocScreen({super.key, required this.type});

  final LegalDocType type;

  @override
  Widget build(BuildContext context) {
    final doc = LegalDoc.of(type);
    return ProfileSubpageScaffold(
      title: doc.title,
      body: ListView(
        padding: const .fromLTRB(20, 8, 20, 28),
        children: [
          if (doc.updatedLabel.isNotEmpty) ...[
            Text(
              doc.updatedLabel,
              style: context.textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: .w600,
              ),
            ),
            16.h,
          ],
          for (final section in doc.sections) ...[
            Text(
              section.heading,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: .w800,
              ),
            ),
            8.h,
            Text(
              section.body,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textBody,
                height: 1.45,
              ),
            ),
            18.h,
          ],
        ],
      ),
    );
  }
}
