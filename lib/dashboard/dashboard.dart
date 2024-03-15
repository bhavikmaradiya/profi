import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import './app_tab_bar.dart';
import './bloc/dashboard_bloc.dart';
import './drawer_item.dart';
import './model/dashboard_drawer_menu.dart';
import '../../notification/notification_token_helper.dart';
import '../app_widgets/app_empty_view.dart';
import '../app_widgets/floating_action_btn.dart';
import '../app_widgets/snack_bar_view.dart';
import '../config/app_config.dart';
import '../config/theme_config.dart';
import '../const/dimens.dart';
import '../const/strings.dart';
import '../enums/color_enums.dart';
import '../enums/drawer_menu_enum.dart';
import '../enums/payment_status_enum.dart';
import '../home/home.dart';
import '../inward_transactions/bloc/transaction_bloc.dart';
import '../project_list/fetch_projects_bloc/firebase_fetch_projects_bloc.dart';
import '../project_list/milestone_operations_bloc/milestone_operations_bloc.dart';
import '../project_list/project_list.dart';
import '../project_list/project_operations_bloc/project_operations_bloc.dart';
import '../routes.dart';
import '../settings/bloc/settings_bloc.dart';
import '../utils/app_utils.dart';
import '../utils/color_utils.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  SettingsBloc? _settingsBlocProvider;
  DashboardBloc? _dashboardBlocProvider;
  FirebaseFetchProjectsBloc? _firebaseFetchProjectsBloc;
  TransactionBloc? _transactionBloc;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? _tabController;
  final tabLength = AppConfig.isTempTabEnabled ? 5 : 4;
  int _selectedTabIndex = 1;

  @override
  void initState() {
    _tabController = TabController(
      length: tabLength,
      vsync: this,
      initialIndex: _selectedTabIndex,
    );
    _tabController!.addListener(
      () {
        setState(() {
          _selectedTabIndex = _tabController!.index;
        });
      },
    );
    NotificationTokenHelper.uploadFcmToken();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_settingsBlocProvider == null) {
      _settingsBlocProvider ??= BlocProvider.of<SettingsBloc>(
        context,
        listen: false,
      );
      _settingsBlocProvider?.add(SettingsInitialEvent());
    }
    _dashboardBlocProvider ??= BlocProvider.of<DashboardBloc>(
      context,
      listen: false,
    );
    _firebaseFetchProjectsBloc ??= BlocProvider.of<FirebaseFetchProjectsBloc>(
      context,
      listen: false,
    );
    _transactionBloc ??= BlocProvider.of<TransactionBloc>(
      context,
      listen: false,
    );

    if (AppUtils.isUserLoginAfterLogOut) {
      AppUtils.isUserLoginAfterLogOut = false;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _firebaseFetchProjectsBloc?.add(FirebaseFetchProjectsDetailsEvent());
        _transactionBloc?.add(FetchTransactionEvent());
      });
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return MultiBlocListener(
      listeners: [
        BlocListener<DashboardBloc, DashboardState>(
          listenWhen: (previous, current) =>
              previous != current && current is LogoutSuccessState,
          listener: (context, state) async {
            if (state is LogoutSuccessState) {
              await _unSubscribingFirebaseEvents();
              _onLogout();
            }
          },
        ),
        BlocListener<ProjectOperationsBloc, ProjectOperationsState>(
          listenWhen: (previous, current) =>
              previous != current && current is ProjectDeletedState,
          listener: (context, state) {
            if (state is ProjectDeletedState) {
              _listenToProjectOperationsState(
                context,
                appLocalizations,
                state,
              );
            }
          },
        ),
        BlocListener<MilestoneOperationsBloc, MilestoneOperationsState>(
          listenWhen: (previous, current) =>
              previous != current &&
              (current is MilestonePaidSuccessState ||
                  current is MilestoneUnPaidSuccessState ||
                  current is MilestoneUpdatedState ||
                  current is MilestoneInvoicedChangeState ||
                  current is MilestoneDeletedState),
          listener: (context, state) {
            _listenToMilestoneOperationState(
              context,
              appLocalizations,
              state,
            );
          },
        ),
      ],
      child: DefaultTabController(
        length: tabLength,
        child: Scaffold(
          key: _scaffoldKey,
          floatingActionButton: FloatingActionBtn(
            onPressed: () {
              Navigator.pushNamed(
                context,
                Routes.addEditProject,
              );
            },
          ),
          appBar: AppBar(
            backgroundColor: ColorUtils.getColor(
              context,
              ColorEnums.whiteColor,
            ),
            centerTitle: false,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            leading: InkWell(
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              borderRadius: BorderRadius.circular(
                Dimens.hamburgerIconRippleRadius.r,
              ),
              child: UnconstrainedBox(
                child: SvgPicture.asset(
                  Strings.hamburger,
                  width: Dimens.hamburgerIconWidth.w,
                  height: Dimens.hamburgerIconHeight.h,
                ),
              ),
            ),
            title: Text(
              appLocalizations.appName,
              style: TextStyle(
                color: ColorUtils.getColor(
                  context,
                  ColorEnums.black33Color,
                ),
                fontWeight: FontWeight.w700,
                fontSize: Dimens.homeTitleTextSize.sp,
                fontFamily: ThemeConfig.appFonts,
              ),
            ),
            actions: [
              if (_selectedTabIndex != 0)
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, Routes.filter);
                  },
                  borderRadius: BorderRadius.circular(
                    Dimens.homeFilterIconRippleRadius.r,
                  ),
                  child: UnconstrainedBox(
                    child: Padding(
                      padding: EdgeInsets.all(
                        Dimens.homeFilterIconPadding.w,
                      ),
                      child: BlocBuilder<FirebaseFetchProjectsBloc,
                          FirebaseFetchProjectsState>(
                        buildWhen: (previous, current) =>
                            previous != current &&
                            current is FilterChangedState,
                        builder: (context, state) {
                          return SvgPicture.asset(
                            _firebaseFetchProjectsBloc?.getAppliedFilter() ==
                                    null
                                ? Strings.defaultFilter
                                : Strings.filter,
                            width: Dimens.homeFilterIconSize.w,
                            height: Dimens.homeFilterIconSize.h,
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: AppTabBar(
                appLocalizations: appLocalizations,
                selectedTabIndex: _selectedTabIndex,
                tabController: _tabController,
                tabLength: tabLength,
              ),
            ),
          ),
          drawer: Drawer(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: DrawerItem(
              onCloseIconClicked: () {
                _closeDrawer();
              },
              onMenuClicked: (DashboardDrawerMenu menu) {
                _handleMenuOperations(
                  context,
                  menu,
                );
              },
            ),
          ),
          onDrawerChanged: (isOpened) {
            if (isOpened) {
              _dashboardBlocProvider?.add(
                GenerateProfileAndMenuEvent(
                  appLocalizations,
                ),
              );
            }
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              const Home(),
              const ProjectList(
                key: ValueKey(1),
              ),
              const ProjectList(
                key: ValueKey(2),
                statusEnum: PaymentStatusEnum.aboutToExceed,
              ),
              const ProjectList(
                key: ValueKey(3),
                statusEnum: PaymentStatusEnum.exceeded,
              ),
              if (AppConfig.isTempTabEnabled)
                AppEmptyView(
                  message: appLocalizations.comingSoon,
                ),
            ],
          ),
        ),
      ),
    );
  }

  _listenToProjectOperationsState(
    BuildContext context,
    AppLocalizations appLocalizations,
    ProjectOperationsState state,
  ) {
    if (state is ProjectDeletedState) {
      SnackBarView.showSnackBar(
        context,
        appLocalizations.projectDeletedSuccess,
        backgroundColor: ColorUtils.getColor(
          context,
          ColorEnums.redColor,
        ),
      );
    }
  }

  _listenToMilestoneOperationState(
    BuildContext context,
    AppLocalizations appLocalizations,
    MilestoneOperationsState state,
  ) {
    if (state is MilestonePaidSuccessState) {
      SnackBarView.showSnackBar(
        context,
        appLocalizations.milestonePaidSuccess,
        backgroundColor: ColorUtils.getColor(
          context,
          ColorEnums.greenColor,
        ),
      );
    } else if (state is MilestoneUnPaidSuccessState) {
      SnackBarView.showSnackBar(
        context,
        appLocalizations.milestoneUnPaidSuccess,
        backgroundColor: ColorUtils.getColor(
          context,
          ColorEnums.greenColor,
        ),
      );
    } else if (state is MilestoneUpdatedState) {
      SnackBarView.showSnackBar(
        context,
        state.isNewMilestoneCreated
            ? appLocalizations.milestoneCreatedSuccess
            : appLocalizations.milestoneUpdatedSuccess,
        backgroundColor: ColorUtils.getColor(
          context,
          ColorEnums.greenColor,
        ),
      );
    } else if (state is MilestoneDeletedState) {
      SnackBarView.showSnackBar(
        context,
        appLocalizations.milestoneDeletedSuccess,
        backgroundColor: ColorUtils.getColor(
          context,
          ColorEnums.redColor,
        ),
      );
    } else if (state is MilestoneInvoicedChangeState) {
      final isInvoiced = state.isInvoiced;
      SnackBarView.showSnackBar(
        context,
        isInvoiced
            ? appLocalizations.milestoneInvoicedSuccess
            : appLocalizations.milestoneInvoicedCancelled,
        backgroundColor: ColorUtils.getColor(
          context,
          isInvoiced ? ColorEnums.greenColor : ColorEnums.redColor,
        ),
      );
    }
  }

  _closeDrawer() {
    _scaffoldKey.currentState?.closeDrawer();
  }

  _handleMenuOperations(BuildContext context, DashboardDrawerMenu menu) {
    switch (menu.menuEnum) {
      case DrawerMenuEnum.dashboard:
        _closeDrawer();
        _tabController?.animateTo(0);
        break;
      case DrawerMenuEnum.inwardTransaction:
        _closeDrawer();
        Navigator.pushNamed(
          context,
          Routes.inwardTransactions,
        );
        break;
      case DrawerMenuEnum.settings:
        _closeDrawer();
        Navigator.pushNamed(
          context,
          Routes.settings,
        );
        break;
      case DrawerMenuEnum.logout:
        _closeDrawer();
        BlocProvider.of<DashboardBloc>(
          context,
          listen: false,
        ).add(
          LogoutEvent(),
        );
        break;
      case DrawerMenuEnum.manageUser:
        _closeDrawer();
        Navigator.pushNamed(
          context,
          Routes.manageUsers,
        );
        break;
    }
  }

  _onLogout() {
    AppUtils.isUserLoginAfterLogOut = true;
    // navigate to Auth screen
    Navigator.pushReplacementNamed(
      context,
      Routes.authentication,
    );
  }

  _unSubscribingFirebaseEvents() async {
    await _settingsBlocProvider?.onLogout();
    await _firebaseFetchProjectsBloc?.onLogout();
    await _transactionBloc?.onLogout();
    await FirebaseAuth.instance.signOut();
    await FirebaseMessaging.instance.deleteToken();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}
