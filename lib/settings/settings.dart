import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './bloc/settings_bloc.dart';
import '../app_widgets/app_text_field.dart';
import '../app_widgets/app_tool_bar.dart';
import '../config/app_config.dart';
import '../config/preference_config.dart';
import '../const/dimens.dart';
import '../enums/color_enums.dart';
import '../enums/currency_enum.dart';
import '../enums/user_role_enums.dart';
import '../utils/app_utils.dart';
import '../utils/color_utils.dart';
import '../utils/currency_converter_utils.dart';
import '../utils/decimal_text_input_formatter.dart';

class Settings extends StatelessWidget {
  final _dollarToInrTextEditingController = TextEditingController(
    text: CurrencyConverterUtils.exchangeRates[CurrencyEnum.dollars.name]
        .toString(),
  );
  final dollarToInrFieldFocusNode = Platform.isIOS ? FocusNode() : null;

  Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final settingsBlocProvider = BlocProvider.of<SettingsBloc>(
      context,
      listen: false,
    );
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ToolBar(
          title: appLocalizations.settings,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(
              left: Dimens.screenHorizontalMargin.w,
              right: Dimens.screenHorizontalMargin.w,
              top: Dimens.appBarContentVerticalPadding.h,
              bottom: Dimens.appBarContentVerticalPadding.h,
            ),
            child: Column(
              children: [
                _dollarToInrField(
                  context,
                  appLocalizations,
                  settingsBlocProvider,
                  dollarToInrFieldFocusNode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dollarToInrField(
    BuildContext context,
    AppLocalizations appLocalizations,
    SettingsBloc? settingsBlocProvider,
    FocusNode? focusNode,
  ) {
    return FutureBuilder(
        future: _getUserRole(),
        builder: (context, snapshot) {
          bool isEnable = false;
          if (snapshot.hasData) {
            isEnable = snapshot.data == UserRoleEnum.admin.name;
          }
          return AbsorbPointer(
            absorbing: !isEnable,
            child: AppTextField(
              title: appLocalizations.dollarToInr,
              hint: 'ie. ${AppConfig.defaultDollarToInr}',
              hintStyle: TextStyle(
                color: ColorUtils.getColor(
                  context,
                  ColorEnums.grayA8Color,
                ),
                fontSize: Dimens.settingsDollarToInrHintTextSize.sp,
              ),
              keyboardAction: TextInputAction.done,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              focusNode: focusNode,
              textEditingController: _dollarToInrTextEditingController,
              isReadOnly: !isEnable,
              fieldBgColor:
                  isEnable ? ColorEnums.whiteColor : ColorEnums.grayF5Color,
              inputFormatter: [
                FilteringTextInputFormatter.deny(
                  AppUtils.regexToDenyComma,
                ),
                DecimalTextInputFormatter(
                  decimalRange: AppConfig.decimalTextFieldInputLength,
                ),
              ],
              onTextChange: (value) {
                settingsBlocProvider?.add(OnDollarToInrChangeEvent(value));
              },
            ),
          );
        });
  }

  Future<String?> _getUserRole() async {
    final preference = await SharedPreferences.getInstance();
    return preference.getString(PreferenceConfig.userRolePref);
  }
}
