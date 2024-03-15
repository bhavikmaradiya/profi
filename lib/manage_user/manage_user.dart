import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import './bloc/manage_user_bloc.dart';
import './widget/user_list_item.dart';
import '../app_widgets/app_empty_view.dart';
import '../app_widgets/app_tool_bar.dart';
import '../app_widgets/floating_action_btn.dart';
import '../const/dimens.dart';
import '../enums/color_enums.dart';
import '../profile/model/profile_info.dart';
import '../routes.dart';
import '../shimmer_view/list_item_shimmer.dart';
import '../utils/color_utils.dart';

class ManageUser extends StatelessWidget {
  const ManageUser({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final manageUsersBlocProvider = BlocProvider.of<ManageUserBloc>(
      context,
      listen: false,
    );
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ToolBar(
          title: appLocalizations.manageUser,
        ),
      ),
      floatingActionButton: FloatingActionBtn(
        onPressed: () {
          Navigator.pushNamed(
            context,
            Routes.addUser,
          );
        },
      ),
      body: SafeArea(
        child: BlocBuilder<ManageUserBloc, ManageUserState>(
          buildWhen: (prev, current) =>
              prev != current &&
              (current is UsersLoadingState ||
                  current is UsersLoadedState ||
                  current is NoUsersFoundState),
          builder: (context, state) {
            if (state is UsersLoadingState) {
              return _loadingWidget();
            } else if (state is UsersLoadedState) {
              final usersList = state.usersList;
              if (usersList.isNotEmpty) {
                return _listWidget(usersList);
              } else {
                return _emptyWidget(appLocalizations.usersNotFound);
              }
            }
            return _emptyWidget(appLocalizations.usersNotFound);
          },
        ),
      ),
    );
  }

  Widget _emptyWidget(String message) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.screenHorizontalMargin.w,
        vertical: Dimens.homeEmptyViewVerticalPadding.h,
      ),
      child: AppEmptyView(
        message: message,
      ),
    );
  }

  _listWidget(List<ProfileInfo> usersList) {
    return ListView.separated(
      itemCount: usersList.length,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemBuilder: (_, index) {
        return Column(
          children: [
            UserListItem(
              profileInfo: usersList[index],
            ),
            if (index == (usersList.length - 1))
              SizedBox(
                height: Dimens.userListFloatingBtnContainerSize.h,
              ),
          ],
        );
      },
      separatorBuilder: (context, index) {
        return Divider(
          height: 0,
          color: ColorUtils.getColor(
            context,
            ColorEnums.grayD9Color,
          ),
        );
      },
    );
  }

  Widget _loadingWidget() {
    return const ListItemShimmer(
      shimmerItemCount: 10,
    );
  }
}
