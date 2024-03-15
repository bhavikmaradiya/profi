import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/preference_config.dart';
import '../../const/strings.dart';
import '../../enums/drawer_menu_enum.dart';
import '../../enums/user_role_enums.dart';
import '../../notification/notification_token_helper.dart';
import '../../profile/model/profile_info.dart';
import '../model/dashboard_drawer_menu.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  late List<DashboardDrawerMenu> _drawerMenus;
  late ProfileInfo _profileInfo;

  DashboardBloc() : super(DashboardInitialState()) {
    on<GenerateProfileAndMenuEvent>(_generateProfileAndMenuInfo);
    on<LogoutEvent>(_onLogout);
  }

  _generateProfileAndMenuInfo(
    GenerateProfileAndMenuEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    _profileInfo = ProfileInfo(
      userId: prefs.getString(PreferenceConfig.userIdPref),
      name: prefs.getString(PreferenceConfig.userNamePref),
      role: prefs.getString(PreferenceConfig.userRolePref),
      email: prefs.getString(PreferenceConfig.userEmailPref),
    );

    _drawerMenus = [];
    _drawerMenus.add(
      DashboardDrawerMenu(
        menuEnum: DrawerMenuEnum.dashboard,
        iconPath: Strings.home,
        name: event.appLocalizations.dashboard,
      ),
    );
    _drawerMenus.add(
      DashboardDrawerMenu(
        menuEnum: DrawerMenuEnum.inwardTransaction,
        iconPath: Strings.inward,
        name: event.appLocalizations.inwardTransactions,
      ),
    );
    if (_profileInfo.role == UserRoleEnum.admin.name) {
      _drawerMenus.add(
        DashboardDrawerMenu(
          menuEnum: DrawerMenuEnum.manageUser,
          iconPath: Strings.users,
          name: event.appLocalizations.manageUser,
        ),
      );
    }
    _drawerMenus.add(
      DashboardDrawerMenu(
        menuEnum: DrawerMenuEnum.settings,
        iconPath: Strings.settings,
        name: event.appLocalizations.settings,
      ),
    );
    _drawerMenus.add(
      DashboardDrawerMenu(
        menuEnum: DrawerMenuEnum.logout,
        iconPath: Strings.logout,
        name: event.appLocalizations.logout,
      ),
    );

    emit(ProfileAndMenuInfoGeneratedState(_drawerMenus, _profileInfo));
  }

  _onLogout(LogoutEvent event, Emitter<DashboardState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final firebaseUserId = prefs.getString(PreferenceConfig.userIdPref);
    await NotificationTokenHelper.removeTokenOnLogout(firebaseUserId);
    await prefs.clear();
    emit(LogoutSuccessState());
  }
}
