import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import './model/wallet_info.dart';
import '../../dialog/show_dialog_utils.dart';
import '../app_widgets/app_empty_view.dart';
import '../config/app_config.dart';
import '../config/theme_config.dart';
import '../const/dimens.dart';
import '../const/strings.dart';
import '../enums/color_enums.dart';
import '../enums/currency_enum.dart';
import '../enums/payment_status_enum.dart';
import '../enums/wallet_enums.dart';
import '../home/bloc/wallet_bloc.dart';
import '../inward_transactions/bloc/transaction_bloc.dart';
import '../inward_transactions/model/transaction_info.dart';
import '../inward_transactions/widget/transaction_list_item.dart';
import '../project_list/fetch_projects_bloc/firebase_fetch_projects_bloc.dart';
import '../project_list/milestone_operations_bloc/milestone_operations_bloc.dart';
import '../project_list/utils/milestone_utils.dart';
import '../shimmer_view/list_item_shimmer.dart';
import '../utils/app_utils.dart';
import '../utils/color_utils.dart';
import '../utils/currency_converter_utils.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  FirebaseFetchProjectsBloc? _projectBlocProvider;
  MilestoneOperationsBloc? _milestoneOperationBlocProvider;
  TransactionBloc? _transactionBlocProvider;
  WalletBloc? _walletBlocProvider;
  late AppLocalizations appLocalizations;

  @override
  void didChangeDependencies() {
    appLocalizations = AppLocalizations.of(context)!;
    _projectBlocProvider ??= BlocProvider.of<FirebaseFetchProjectsBloc>(
      context,
      listen: false,
    );
    _milestoneOperationBlocProvider ??=
        BlocProvider.of<MilestoneOperationsBloc>(
      context,
      listen: false,
    );
    _transactionBlocProvider ??= BlocProvider.of<TransactionBloc>(
      context,
      listen: false,
    );
    _walletBlocProvider ??= BlocProvider.of<WalletBloc>(
      context,
      listen: false,
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _calculationWidget(context),
            _recentTransactionsHeaderWidget(
              context,
              appLocalizations,
            ),
            _recentTransactionsListWidget(
              context,
              appLocalizations,
            ),
            SizedBox(
              height: Dimens.addProjectSaveContainerSize.h,
            ),
          ],
        ),
      ),
    );
  }

  Widget _calculationWidget(
    BuildContext context,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.screenHorizontalMargin.w,
      ),
      child: BlocBuilder<FirebaseFetchProjectsBloc, FirebaseFetchProjectsState>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          return BlocBuilder<MilestoneOperationsBloc, MilestoneOperationsState>(
            buildWhen: (previous, current) =>
                previous != current ||
                current is FirebaseMilestoneInfoChangedState,
            builder: (context, state) {
              CurrencyEnum toCurrency =
                  _milestoneOperationBlocProvider?.getSelectedCurrency() ??
                      AppConfig.defaultCurrencyEnum;
              final orangeList = _projectBlocProvider?.getOrangeProjects(
                    isProjectFilterRequired: false,
                  ) ??
                  [];
              final redList = _projectBlocProvider?.getRedProjects(
                    isProjectFilterRequired: false,
                  ) ??
                  [];
              return Column(
                children: [
                  SizedBox(
                    height: Dimens.appBarContentVerticalPadding.h,
                  ),
                  _statisticsContainer(
                    context: context,
                    label: appLocalizations.green,
                    value: _projectBlocProvider?.getInwardAmount(
                          toCurrency: toCurrency,
                        ) ??
                        '',
                    bgColor: ColorUtils.getColor(
                      context,
                      ColorEnums.greenF2FCF3Color,
                    ),
                    valueTextColor: ColorUtils.getColor(
                      context,
                      ColorEnums.greenColor,
                    ),
                    symbol: Strings.homeGreenSymbol,
                    symbolSize: Dimens.homeStatisticsGreenSymbolIconSize,
                  ),
                  SizedBox(
                    height: Dimens.homeStatisticsContainerOuterSpacing.h,
                  ),
                  _walletInfoWidgets(),
                  SizedBox(
                    height: Dimens.homeStatisticsContainerOuterSpacing.h,
                  ),
                  _statisticsContainer(
                    context: context,
                    label: appLocalizations.tabAmber,
                    value: _projectBlocProvider?.getPendingAmount(
                          projects: orangeList,
                          paymentStatusEnum: PaymentStatusEnum.aboutToExceed,
                          toCurrency: toCurrency,
                          separateWithinDays: true,
                        ) ??
                        '',
                    bgColor: ColorUtils.getColor(
                      context,
                      ColorEnums.amberF59032Color,
                    ).withOpacity(0.05),
                    valueTextColor: ColorUtils.getColor(
                      context,
                      ColorEnums.amberF59032Color,
                    ),
                    symbol: Strings.homeAmberSymbol,
                    symbolSize: Dimens.homeStatisticsAmberSymbolIconSize,
                  ),
                  SizedBox(
                    height: Dimens.homeStatisticsContainerOuterSpacing.h,
                  ),
                  _statisticsContainer(
                    context: context,
                    label: appLocalizations.tabRed,
                    value: _projectBlocProvider?.getPendingAmount(
                          projects: redList,
                          paymentStatusEnum: PaymentStatusEnum.exceeded,
                          toCurrency: toCurrency,
                        ) ??
                        '',
                    bgColor: ColorUtils.getColor(
                      context,
                      ColorEnums.redFFE3E3Color,
                    ),
                    valueTextColor: ColorUtils.getColor(
                      context,
                      ColorEnums.redColor,
                    ),
                    symbol: Strings.homeRedSymbol,
                    symbolSize: Dimens.homeStatisticsRedSymbolIconSize,
                  ),
                  SizedBox(
                    height: Dimens.homeStatisticsContainerOuterSpacing.h,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  _walletInfoWidgets() {
    CurrencyEnum toCurrency =
        _milestoneOperationBlocProvider?.getSelectedCurrency() ??
            AppConfig.defaultCurrencyEnum;
    return BlocBuilder<WalletBloc, WalletState>(
      buildWhen: (prev, current) =>
          prev != current && current is WalletInfoChangedState,
      builder: (_, state) {
        WalletInfo? walletInfo;
        String walletAAmount = '0';
        String walletBAmount = '0';
        bool isWalletAStarted = false;
        bool isWalletBStarted = false;
        if (state is WalletInfoChangedState) {
          walletInfo = state.walletInfo;
          isWalletAStarted = walletInfo?.walletAIsStarted ?? false;
          isWalletBStarted = walletInfo?.walletBIsStarted ?? false;
          final convertedAAmount = CurrencyConverterUtils.convert(
            walletInfo?.walletAAmount ?? 0,
            AppConfig.defaultCurrencyEnum.name,
            toCurrency.name,
          );
          walletAAmount = AppUtils.amountWithCurrencyFormatter(
            amount: convertedAAmount,
            toCurrency: toCurrency,
          );
          final convertedBAmount = CurrencyConverterUtils.convert(
            walletInfo?.walletBAmount ?? 0,
            AppConfig.defaultCurrencyEnum.name,
            toCurrency.name,
          );
          walletBAmount = AppUtils.amountWithCurrencyFormatter(
            amount: convertedBAmount,
            toCurrency: toCurrency,
          );
        }
        return Row(
          children: [
            _walletItemWidget(
              title: appLocalizations.walletAName,
              amountValue: walletAAmount,
              isWalletStarted: isWalletAStarted,
              onTap: () {
                if (walletInfo != null) {
                  ShowDialogUtils.showWalletOperationDialog(
                    context: context,
                    walletInfo: walletInfo,
                    walletType: WalletEnums.walletA,
                  );
                }
              },
              onButtonTap: () {
                if (walletInfo != null) {
                  if (!walletInfo.walletAIsStarted) {
                    ShowDialogUtils.showWalletOperationDialog(
                      context: context,
                      walletInfo: walletInfo,
                      walletType: WalletEnums.walletA,
                    );
                  } else {
                    _walletBlocProvider?.add(
                      ToggleWalletEvent(
                        WalletEnums.walletA,
                      ),
                    );
                  }
                }
              },
            ),
            SizedBox(
              width: Dimens.homeStatisticsWalletContainerBetweenSpacing.w,
            ),
            _walletItemWidget(
              title: appLocalizations.walletBName,
              amountValue: walletBAmount,
              isWalletStarted: isWalletBStarted,
              onTap: () {
                if (walletInfo != null) {
                  ShowDialogUtils.showWalletOperationDialog(
                    context: context,
                    walletInfo: walletInfo,
                    walletType: WalletEnums.walletB,
                  );
                }
              },
              onButtonTap: () {
                if (walletInfo != null) {
                  if (!walletInfo.walletBIsStarted) {
                    ShowDialogUtils.showWalletOperationDialog(
                      context: context,
                      walletInfo: walletInfo,
                      walletType: WalletEnums.walletB,
                    );
                  } else {
                    _walletBlocProvider?.add(
                      ToggleWalletEvent(
                        WalletEnums.walletB,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  _walletItemWidget({
    required String title,
    required String amountValue,
    required bool isWalletStarted,
    required Function onTap,
    required Function onButtonTap,
  }) {
    final amountCurrency = amountValue[0];
    final amount = amountValue.substring(1, amountValue.length);
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            Dimens.homeStatisticsContainerRadius.r,
          ),
          border: Border.all(
            color: ColorUtils.getColor(
              context,
              ColorEnums.grayE0Color,
            ),
            width: Dimens.homeStatisticsContainerWidth.w,
          ),
          color: ColorUtils.getColor(
            context,
            ColorEnums.greenF2FCF3Color,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(
              Dimens.homeStatisticsContainerRadius.r,
            ),
            onTap: () => onTap(),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.homeStatisticsContainerHorizontalSpacing.w,
                vertical: Dimens.homeStatisticsContainerVerticalSpacing.h,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: ColorUtils.getColor(
                              context,
                              ColorEnums.black33Color,
                            ),
                            fontSize: Dimens.homeStatisticsLabelTextSize.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        RichText(
                          text: TextSpan(
                            text: amountCurrency,
                            style: TextStyle(
                              color: ColorUtils.getColor(
                                context,
                                ColorEnums.greenColor,
                              ),
                              fontSize: Dimens
                                  .homeWalletStatisticsCurrencyTextSize.sp,
                              fontFamily: ThemeConfig.notoSans,
                            ),
                            children: [
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Text(
                                  amount,
                                  style: TextStyle(
                                    color: ColorUtils.getColor(
                                      context,
                                      ColorEnums.greenColor,
                                    ),
                                    fontSize: Dimens
                                        .homeWalletStatisticsValueTextSize.sp,
                                    fontFamily: ThemeConfig.appFonts,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: ColorUtils.getColor(
                        context,
                        ColorEnums.whiteColor,
                      ),
                      borderRadius: BorderRadius.circular(
                        Dimens.homeStatisticsContainerRadius.r,
                      ),
                      border: Border.all(
                        color: ColorUtils.getColor(
                          context,
                          ColorEnums.grayE0Color,
                        ),
                        width: Dimens.homeStatisticsContainerWidth.w,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          Dimens.homeStatisticsContainerRadius.r,
                        ),
                        onTap: () => onButtonTap(),
                        child: Icon(
                          isWalletStarted ? Icons.stop : Icons.play_arrow,
                          color: ColorUtils.getColor(
                            context,
                            ColorEnums.gray6CColor,
                          ),
                          size: Dimens.homeStatisticsWalletButtonIconSize.w,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statisticsContainer({
    required BuildContext context,
    required String label,
    required dynamic value,
    required String symbol,
    required Color bgColor,
    required Color valueTextColor,
    required double symbolSize,
  }) {
    String amountCurrency = '';
    String amount = '';
    String _5DaysAmount = '';
    String _10DaysAmount = '';
    String _15DaysAmount = '';
    String _thisMonthAmount = '';
    String _nextMonthAmount = '';
    if (value is String) {
      amountCurrency = value[0];
      amount = value.substring(1, value.length);
    } else if (value is Map) {
      if (value.containsKey(MilestoneUtils.keyPendingTotalAmount)) {
        final totalAmountValue = value[MilestoneUtils.keyPendingTotalAmount];
        amountCurrency = totalAmountValue[0];
        amount = totalAmountValue?.substring(1, totalAmountValue.length) ?? '';
      }
      if (value.containsKey(MilestoneUtils.keyPendingAmountWithin5Days)) {
        final _5DaysAmountValue =
            value[MilestoneUtils.keyPendingAmountWithin5Days];
        _5DaysAmount =
            _5DaysAmountValue?.substring(1, _5DaysAmountValue.length) ?? '';
      }
      if (value.containsKey(MilestoneUtils.keyPendingAmountWithin10Days)) {
        final _10DaysAmountValue =
            value[MilestoneUtils.keyPendingAmountWithin10Days];
        _10DaysAmount =
            _10DaysAmountValue?.substring(1, _10DaysAmountValue.length) ?? '';
      }
      if (value.containsKey(MilestoneUtils.keyPendingAmountWithin15Days)) {
        final _15DaysAmountValue =
            value[MilestoneUtils.keyPendingAmountWithin15Days];
        _15DaysAmount =
            _15DaysAmountValue?.substring(1, _15DaysAmountValue.length) ?? '';
      }
      if (value.containsKey(MilestoneUtils.keyPendingAmountWithinThisMonth)) {
        final _thisMonthAmountValue =
            value[MilestoneUtils.keyPendingAmountWithinThisMonth];
        _thisMonthAmount =
            _thisMonthAmountValue?.substring(1, _thisMonthAmountValue.length) ??
                '';
      }
      if (value.containsKey(MilestoneUtils.keyPendingAmountWithinNextMonth)) {
        final _nextMonthAmountValue =
            value[MilestoneUtils.keyPendingAmountWithinNextMonth];
        _nextMonthAmount =
            _nextMonthAmountValue?.substring(1, _nextMonthAmountValue.length) ??
                '';
      }
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          Dimens.homeStatisticsContainerRadius.r,
        ),
        border: Border.all(
          color: ColorUtils.getColor(
            context,
            ColorEnums.grayE0Color,
          ),
          width: Dimens.homeStatisticsContainerWidth.w,
        ),
        color: bgColor,
      ),
      child: Material(
        color: ColorUtils.getColor(
          context,
          ColorEnums.transparentColor,
        ),
        child: InkWell(
          onTap: () {
            BlocProvider.of<MilestoneOperationsBloc>(
              context,
              listen: false,
            ).add(MilestoneCurrencyChangeEvent());
          },
          borderRadius: BorderRadius.circular(
            Dimens.homeStatisticsContainerRadius.r,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimens.homeStatisticsContainerHorizontalSpacing.w,
              vertical: Dimens.homeStatisticsContainerVerticalSpacing.h,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: ColorUtils.getColor(
                            context,
                            ColorEnums.black33Color,
                          ),
                          fontSize: Dimens.homeStatisticsLabelTextSize.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      RichText(
                        text: TextSpan(
                          text: amountCurrency,
                          style: TextStyle(
                            color: valueTextColor,
                            fontSize: Dimens.homeStatisticsCurrencyTextSize.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: ThemeConfig.notoSans,
                          ),
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Text(
                                amount,
                                style: TextStyle(
                                  color: valueTextColor,
                                  fontSize:
                                      Dimens.homeStatisticsValueTextSize.sp,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: ThemeConfig.appFonts,
                                ),
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_5DaysAmount.trim().isNotEmpty)
                        _amountWithinDaysWidget(
                          context,
                          currency: amountCurrency,
                          postfix: appLocalizations.amountWithinDays(5),
                          amount: _5DaysAmount,
                          valueTextColor: valueTextColor,
                        ),
                      if (_10DaysAmount.trim().isNotEmpty)
                        _amountWithinDaysWidget(
                          context,
                          currency: amountCurrency,
                          postfix: appLocalizations.amountWithinDays(10),
                          amount: _10DaysAmount,
                          valueTextColor: valueTextColor,
                        ),
                      if (_15DaysAmount.trim().isNotEmpty)
                        _amountWithinDaysWidget(
                          context,
                          currency: amountCurrency,
                          postfix: appLocalizations.amountWithinDays(15),
                          amount: _15DaysAmount,
                          valueTextColor: valueTextColor,
                        ),
                      if (_thisMonthAmount.trim().isNotEmpty)
                        _amountWithinDaysWidget(
                          context,
                          currency: amountCurrency,
                          postfix: appLocalizations.amountWithinThisMonth,
                          amount: _thisMonthAmount,
                          valueTextColor: valueTextColor,
                        ),
                      if (_nextMonthAmount.trim().isNotEmpty)
                        _amountWithinDaysWidget(
                          context,
                          currency: amountCurrency,
                          postfix: appLocalizations.amountWithinNextMonth,
                          amount: _nextMonthAmount,
                          valueTextColor: valueTextColor,
                        ),
                    ],
                  ),
                ),
                SvgPicture.asset(
                  symbol,
                  width: symbolSize.w,
                  height: symbolSize.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  RichText _amountWithinDaysWidget(
    BuildContext context, {
    required String currency,
    required Color valueTextColor,
    required String amount,
    required String postfix,
  }) {
    return RichText(
      text: TextSpan(
        text: currency,
        style: TextStyle(
          color: valueTextColor,
          fontSize: Dimens.homeAmberSecondaryCurrencyTextSize.sp,
          fontFamily: ThemeConfig.notoSans,
        ),
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Text(
              amount,
              style: TextStyle(
                color: valueTextColor,
                fontSize: Dimens.homeAmberSecondaryValueTextSize.sp,
                fontFamily: ThemeConfig.appFonts,
              ),
            ),
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Text(
              ' $postfix',
              style: TextStyle(
                color: ColorUtils.getColor(
                  context,
                  ColorEnums.black33Color,
                ),
                fontStyle: FontStyle.italic,
                fontSize: Dimens.homeStatisticsValuePostfixTextSize.sp,
                fontFamily: ThemeConfig.appFonts,
              ),
            ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _recentTransactionsHeaderWidget(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.screenHorizontalMargin.w,
        vertical: Dimens.homeRecentTransactionVerticalPadding.h,
      ),
      color: ColorUtils.getColor(
        context,
        ColorEnums.grayF5Color,
      ),
      child: Text(
        appLocalizations.recentTransactions,
        style: TextStyle(
          fontSize: Dimens.homeRecentTransactionTextSize.sp,
          color: ColorUtils.getColor(
            context,
            ColorEnums.black33Color,
          ),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _recentTransactionsListWidget(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      buildWhen: (previous, current) =>
          previous != current &&
          (current is TransactionLoadingState ||
              current is TransactionDataState ||
              current is TransactionEmptyState),
      builder: (context, state) {
        if (state is TransactionLoadingState) {
          return _loadingWidget();
        } else if (state is TransactionDataState) {
          final data = state.transactions;
          return _dataWidget(data);
        } else if (state is TransactionEmptyState) {
          return _emptyWidget(appLocalizations);
        }
        final data = _transactionBlocProvider?.getAllTransactions();
        if (data != null && data.isNotEmpty) {
          return _dataWidget(data);
        } else {
          return _emptyWidget(appLocalizations);
        }
      },
    );
  }

  Widget _loadingWidget() {
    return const ListItemShimmer(
      shimmerItemCount: 5,
      isTransactionShimmerView: true,
    );
  }

  Widget _dataWidget(List<TransactionInfo> transactions) {
    int length = AppConfig.recentTransactionLength;
    if (transactions.length < AppConfig.recentTransactionLength) {
      length = transactions.length;
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: length,
      itemBuilder: (context, index) {
        final transactionInfo = transactions[index];
        final milestoneInfo =
            _projectBlocProvider?.getMilestoneInfo(transactionInfo.milestoneId);
        return ListTileTheme(
          contentPadding: EdgeInsets.zero,
          horizontalTitleGap: 0.0,
          minLeadingWidth: 0,
          minVerticalPadding: 0,
          dense: true,
          child: TransactionListItem(
            transactionInfo: transactionInfo,
            milestoneInfo: milestoneInfo,
          ),
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

  Widget _emptyWidget(AppLocalizations appLocalizations) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.screenHorizontalMargin.w,
        vertical: Dimens.homeEmptyViewVerticalPadding.h,
      ),
      child: AppEmptyView(
        message: appLocalizations.transactionsNotFound,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
