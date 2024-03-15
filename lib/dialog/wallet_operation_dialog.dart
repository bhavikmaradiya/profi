import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_widgets/app_outline_button.dart';
import '../app_widgets/app_text_field.dart';
import '../config/app_config.dart';
import '../const/dimens.dart';
import '../const/strings.dart';
import '../enums/color_enums.dart';
import '../enums/wallet_enums.dart';
import '../home/bloc/wallet_bloc.dart';
import '../home/model/wallet_info.dart';
import '../keyboard_action/keyboard_actions.dart';
import '../utils/app_utils.dart';
import '../utils/color_utils.dart';
import '../utils/decimal_text_input_formatter.dart';

class WalletOperationDialog extends StatefulWidget {
  final WalletEnums whichWallet;
  final WalletInfo walletInfo;

  const WalletOperationDialog({
    Key? key,
    required this.whichWallet,
    required this.walletInfo,
  }) : super(key: key);

  @override
  State<WalletOperationDialog> createState() => _WalletOperationDialogState();
}

class _WalletOperationDialogState extends State<WalletOperationDialog> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final amountFieldFocusNode = Platform.isIOS ? FocusNode() : null;
  WalletBloc? _walletBlocProvider;
  late WalletEnums _walletType;
  late WalletInfo _walletInfo;
  AppLocalizations? appLocalizations;

  @override
  void initState() {
    _walletType = widget.whichWallet;
    _walletInfo = widget.walletInfo;
    double amount = 0;
    if (_walletType == WalletEnums.walletA &&
        _walletInfo.walletAAmount != null) {
      amount = _walletInfo.walletAAmount!;
    } else if (_walletType == WalletEnums.walletB &&
        _walletInfo.walletBAmount != null) {
      amount = _walletInfo.walletBAmount!;
    }
    _amountController.text = AppUtils.removeTrailingZero(amount);
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    appLocalizations ??= AppLocalizations.of(context)!;
    _walletBlocProvider ??= BlocProvider.of<WalletBloc>(
      context,
      listen: false,
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  Dimens.dialogRadius.r,
                ),
              ),
              color: ColorUtils.getColor(
                context,
                ColorEnums.whiteColor,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _headerView(
                  context,
                ),
                _contentView(
                  context,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Material(
              color: ColorUtils.getColor(
                context,
                ColorEnums.transparentColor,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(
                  (Dimens.drawerCloseIconSize * 3).w,
                ),
                child: SizedBox(
                  width: (Dimens.drawerCloseIconSize * 3).w,
                  height: (Dimens.drawerCloseIconSize * 3).w,
                  child: Padding(
                    padding: EdgeInsets.all(
                      Dimens.drawerCloseIconSize.w,
                    ),
                    child: SvgPicture.asset(
                      Strings.close,
                      colorFilter: ColorFilter.mode(
                        ColorUtils.getColor(
                          context,
                          ColorEnums.gray99Color,
                        ),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerView(
    BuildContext context,
  ) {
    final String title = _walletType == WalletEnums.walletA
        ? appLocalizations!.walletAName
        : _walletType == WalletEnums.walletB
            ? appLocalizations!.walletBName
            : '';
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            Dimens.dialogRadius.r,
          ),
          topRight: Radius.circular(
            Dimens.dialogRadius.r,
          ),
        ),
        color: ColorUtils.getColor(
          context,
          ColorEnums.greenF2FCF3Color,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: (Dimens.dialogHorizontalPadding * 2).w,
        vertical: Dimens.dialogVerticalPadding.w,
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: Dimens.dialogTitleTextSize.sp,
          fontWeight: FontWeight.w500,
          color: ColorUtils.getColor(
            context,
            ColorEnums.black33Color,
          ),
        ),
      ),
    );
  }

  Widget _contentView(
    BuildContext context,
  ) {
    final bool isWalletStarted = _walletType == WalletEnums.walletA
        ? (_walletInfo.walletAIsStarted)
        : _walletType == WalletEnums.walletB
            ? (_walletInfo.walletBIsStarted)
            : false;
    return Padding(
      padding: EdgeInsets.only(
        left: Dimens.dialogHorizontalPadding.w,
        right: Dimens.dialogHorizontalPadding.w,
        bottom: Dimens.dialogHorizontalPadding.h,
      ),
      child: Column(
        children: [
          SizedBox(
            height: Dimens.dialogTitleAmountSpacing.h,
          ),
          Container(
            width: Dimens.dialogAmountFieldWidth.w,
            height: Dimens.dialogAmountFieldHeight.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                Dimens.fieldBorderRadius.r,
              ),
              border: Border.all(
                color: ColorUtils.getColor(
                  context,
                  ColorEnums.black33Color,
                ),
              ),
            ),
            alignment: Alignment.center,
            child: KeyboardActions(
              tapOutsideBehavior: TapOutsideBehavior.none,
              disableScroll: true,
              enable: true,
              config: KeyboardActionsConfig(
                nextFocus: false,
                keyboardBarElevation: 0,
                keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
                actions: [
                  KeyboardActionsItem(
                    focusNode: amountFieldFocusNode ?? FocusNode(),
                    displayArrows: false,
                    displayDoneButton: true,
                  ),
                ],
              ),
              child: TextField(
                textAlign: TextAlign.center,
                focusNode: amountFieldFocusNode,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                    AppUtils.regexToDenyComma,
                  ),
                  DecimalTextInputFormatter(
                    decimalRange: AppConfig.decimalTextFieldInputLength,
                  ),
                  LengthLimitingTextInputFormatter(
                    AppConfig.amountInputLengthLimit,
                  ),
                ],
                style: TextStyle(
                  color: ColorUtils.getColor(
                    context,
                    ColorEnums.black33Color,
                  ),
                  fontSize: Dimens.dialogAmountFieldTextSize.sp,
                  fontWeight: FontWeight.w700,
                ),
                cursorColor: ColorUtils.getColor(
                  context,
                  ColorEnums.black33Color,
                ),
                controller: _amountController,
                cursorWidth: 1,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                decoration: null,
                onChanged: (value) {},
              ),
            ),
          ),
          SizedBox(
            height: Dimens.dialogNoteFieldSpacing.h,
          ),
          AppTextField(
            title: null,
            keyboardAction: TextInputAction.next,
            isMultiLine: true,
            maxLine: 2,
            hint: appLocalizations!.notes,
            textEditingController: _noteController,
            hintStyle: TextStyle(
              fontSize: Dimens.dialogNoteHintTextSize.sp,
              color: ColorUtils.getColor(
                context,
                ColorEnums.gray99Color,
              ),
            ),
            fieldBgColor: ColorEnums.transparentColor,
            onTextChange: (notes) {},
          ),
          SizedBox(
            height: Dimens.dialogNoteFieldSpacing.h,
          ),
          Row(
            children: [
              Expanded(
                child: AppOutlineButton(
                  title: isWalletStarted
                      ? appLocalizations!.saveWallet
                      : appLocalizations!.startWallet,
                  textColorEnum: ColorEnums.black33Color,
                  onButtonPressed: () {
                    final note = _noteController.text.toString().trim();
                    final amount = _amountController.text.toString().trim();
                    double parsedAmount = 0;
                    if (amount.isNotEmpty) {
                      parsedAmount = double.tryParse(amount) ?? 0;
                    }
                    _walletBlocProvider?.add(
                      ToggleWalletEvent(
                        _walletType,
                        amountToUpdate: parsedAmount,
                        shouldToggle: !isWalletStarted,
                        note: note,
                      ),
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
              if (isWalletStarted)
                SizedBox(
                  width: Dimens.dialogButtonSpacing.w,
                ),
              if (isWalletStarted)
                Expanded(
                  child: AppOutlineButton(
                    title: appLocalizations!.stopWallet,
                    textColorEnum: ColorEnums.redColor,
                    onButtonPressed: () {
                      final note = _noteController.text.toString().trim();
                      final amount = _amountController.text.toString().trim();
                      double parsedAmount = 0;
                      if (amount.isNotEmpty) {
                        parsedAmount = double.tryParse(amount) ?? 0;
                      }
                      _walletBlocProvider?.add(
                        ToggleWalletEvent(
                          _walletType,
                          amountToUpdate: parsedAmount,
                          note: note,
                        ),
                      );
                      Navigator.pop(context);
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
