import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/models/country_dial_code.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_form_listener.dart';
import '../../../core/widgets/app_phone_field.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/sport_filter_chip.dart';
import '../../home/model/sport_game.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/edit_profile_avatar.dart';
import '../widgets/profile_photo_sheet.dart';
import '../widgets/profile_sliver_header.dart';
import '../widgets/profile_subpage_scaffold.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  CountryDialCode _country = CountryDialCode.pakistan;
  String? _localPhotoPath;
  bool _phoneSynced = false;

  void _syncPhone(ProfileCubit cubit, String? phone) {
    if (_phoneSynced || phone == null) return;
    _phoneSynced = true;
    final country = CountryDialCode.fromPhone(phone);
    final national = CountryDialCode.nationalNumber(phone, country);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _country = country);
      cubit.phoneController.text = national;
    });
  }

  Future<void> _changePhoto() async {
    final file = await showProfilePhotoSheet(context);
    if (!mounted || file == null) return;
    setState(() => _localPhotoPath = file.path);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final cubit = context.read<ProfileCubit>();
        final user = state.user;
        _syncPhone(cubit, user?.phone);

        return AppFormListener(
          status: state.saveStatus,
          errorMessage: state.errorMessage,
          loadingTitle: 'Saving profile',
          errorTitle: 'Update failed',
          onSuccess: () {
            cubit.clearSaveStatus();
            if (context.canPop()) context.pop();
          },
          onErrorDismissed: cubit.clearSaveStatus,
          child: ProfileSubpageScaffold(
            title: 'Edit profile',
            bottomBar: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.outline),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const .fromLTRB(20, 12, 20, 12),
                  child: AppButton(
                    label: 'Save changes',
                    showArrow: false,
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      cubit.saveProfile(
                        phone: _country.compose(cubit.phoneController.text),
                      );
                    },
                  ),
                ),
              ),
            ),
            body: Form(
              key: cubit.formKey,
              child: ListView(
                padding: const .fromLTRB(20, 8, 20, 24),
                children: [
                  EditProfileAvatar(
                    name: user?.name.isEmpty ?? true ? 'Player' : user!.name,
                    networkUrl: user?.avatarUrl,
                    localPath: _localPhotoPath,
                    heroTag: user == null
                        ? null
                        : profileAvatarHeroTag(user.id),
                    onCameraTap: _changePhoto,
                  ).center(),
                  AppSizes.spaceLg.h,
                  AppTextField(
                    label: 'Full name',
                    controller: cubit.nameController,
                    icon: Icons.person_outline_rounded,
                    hint: 'Enter your name',
                    validator: (value) => AppValidators.requiredField(
                      value,
                      message: 'Enter your name',
                    ),
                  ),
                  AppSizes.spaceMd.h,
                  AppPhoneField(
                    controller: cubit.phoneController,
                    country: _country,
                    onCountryChanged: (next) => setState(() => _country = next),
                    validator: AppValidators.nationalPhone,
                  ),
                  AppSizes.spaceMd.h,
                  AppTextField(
                    label: 'Email',
                    controller: cubit.emailController,
                    icon: Icons.mail_outline_rounded,
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: AppValidators.email,
                  ),
                  AppSizes.spaceMd.h,
                  AppTextField(
                    label: 'City',
                    controller: cubit.cityController,
                    icon: Icons.location_on_outlined,
                    hint: 'Karachi',
                    validator: (value) => AppValidators.requiredField(
                      value,
                      message: 'Enter your city',
                    ),
                  ),
                  AppSizes.spaceLg.h,
                  Text(
                    'Favourite sports',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: AppColors.textBody,
                      fontWeight: .w700,
                    ),
                  ),
                  10.h,
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final sport in SportGame.profileFavourites)
                        SportFilterChip(
                          sport: sport,
                          selected: state.selectedSports.contains(sport.id),
                          onTap: () => cubit.toggleSport(sport.id),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
