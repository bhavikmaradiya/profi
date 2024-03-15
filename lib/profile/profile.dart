import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import './model/profile_info.dart';
import './profile_bloc/profile_bloc.dart';
import '../app_widgets/snack_bar_view.dart';
import '../enums/user_role_enums.dart';
import '../routes.dart';

class Profile extends StatelessWidget {
  final _nameTextEditingController = TextEditingController();
  final _emailTextEditingController = TextEditingController();

  Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: BlocListener<ProfileBloc, ProfileState>(
          listenWhen: (previous, current) =>
              previous != current && current is! ProfileInitialState,
          listener: (context, state) {
            _handleProfileState(context, state, appLocalizations);
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _nameTextEditingController,
                  decoration: InputDecoration(
                    hintText: appLocalizations.profileNameFieldHint,
                  ),
                  onChanged: (name) {},
                ),
                TextField(
                  controller: _emailTextEditingController,
                  decoration: const InputDecoration(
                    enabled: false,
                  ),
                  onChanged: (password) {},
                ),
                OutlinedButton(
                  onPressed: () {
                    _onProfileSaveBtnClick(context);
                  },
                  child: Text(
                    appLocalizations.profileSaveBtn,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _handleProfileState(
    BuildContext context,
    ProfileState state,
    AppLocalizations appLocalizations,
  ) {
    if (state is ProfileInfoUpdatedState) {
      _onProfileUpdatedListener(state.profileInfo);
    } else if (state is ProfileSuccessState) {
      _onProfileSaveListener(context, state, appLocalizations);
    }
  }

  _onProfileUpdatedListener(ProfileInfo profileInfo) {
    _nameTextEditingController.text = profileInfo.name ?? '';
    _emailTextEditingController.text = profileInfo.email ?? '';
  }

  _onProfileSaveBtnClick(BuildContext context) async {
    final profileBlocProvider = BlocProvider.of<ProfileBloc>(
      context,
      listen: false,
    );
    final email = _emailTextEditingController.text.toString().trim();
    final name = _nameTextEditingController.text.toString().trim();
    final timeStamp = DateTime.now().millisecondsSinceEpoch;
    final firebaseUserId = await profileBlocProvider.getFirebaseUserId();
    profileBlocProvider.add(
      ProfileSaveEvent(
        ProfileInfo(
          userId: firebaseUserId,
          email: email,
          name: name,
          role: UserRoleEnum.admin.name,
          createdAt: timeStamp,
          updatedAt: timeStamp,
        ),
      ),
    );
  }

  _onProfileSaveListener(
    BuildContext context,
    ProfileState state,
    AppLocalizations appLocalizations,
  ) {
    if (state is ProfileSuccessState) {
      Navigator.pushReplacementNamed(context, Routes.dashboard);
    } else if (state is ProfileFailedState) {
      SnackBarView.showSnackBar(
        context,
        state.errorMessage,
      );
    }
  }
}
