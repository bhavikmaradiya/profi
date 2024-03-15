import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_widgets/app_empty_view.dart';
import '../config/app_config.dart';
import '../config/theme_config.dart';
import '../const/dimens.dart';
import '../const/strings.dart';
import '../enums/color_enums.dart';
import '../enums/currency_enum.dart';
import '../enums/payment_status_enum.dart';
import '../inward_transactions/bloc/transaction_bloc.dart';
import '../inward_transactions/model/transaction_info.dart';
import '../inward_transactions/widget/transaction_list_item.dart';
import '../project_list/fetch_projects_bloc/firebase_fetch_projects_bloc.dart';
import '../project_list/milestone_operations_bloc/milestone_operations_bloc.dart';
import '../shimmer_view/list_item_shimmer.dart';
import '../utils/color_utils.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  FirebaseFetchProjectsBloc? _projectBlocProvider;
  MilestoneOperationsBloc? _milestoneOperationBlocProvider;
  TransactionBloc? _transactionBlocProvider;

  @override
  void didChangeDependencies() {
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
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _calculationWidget(context, appLocalizations),
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
    AppLocalizations appLocalizations,
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
                  _statisticsContainer(
                    context: context,
                    label: appLocalizations.tabAmber,
                    value: _projectBlocProvider?.getPendingAmount(
                          projects: orangeList,
                          paymentStatusEnum: PaymentStatusEnum.aboutToExceed,
                          toCurrency: toCurrency,
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

  Widget _statisticsContainer({
    required BuildContext context,
    required String label,
    required String value,
    required String symbol,
    required Color bgColor,
    required Color valueTextColor,
    required double symbolSize,
  }) {
    final amountCurrency = value[0];
    final amount = value.substring(1, value.length);
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
        return ListTileTheme(
          contentPadding: EdgeInsets.zero,
          horizontalTitleGap: 0.0,
          minLeadingWidth: 0,
          minVerticalPadding: 0,
          dense: true,
          child: TransactionListItem(
            transactionInfo: transactionInfo,
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
