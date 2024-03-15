import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import './bloc/transaction_bloc.dart';
import './model/transaction_info.dart';
import './widget/transaction_list_item.dart';
import '../app_widgets/app_empty_view.dart';
import '../app_widgets/app_search_view.dart';
import '../app_widgets/app_tool_bar.dart';
import '../const/dimens.dart';
import '../enums/color_enums.dart';
import '../shimmer_view/list_item_shimmer.dart';
import '../utils/color_utils.dart';

class InwardTransactions extends StatefulWidget {
  const InwardTransactions({Key? key}) : super(key: key);

  @override
  State<InwardTransactions> createState() => _InwardTransactionsState();
}

class _InwardTransactionsState extends State<InwardTransactions> {
  TransactionBloc? transactionBlocProvider;

  @override
  Widget build(BuildContext context) {
    final projectId = ModalRoute.of(context)!.settings.arguments as String?;
    final appLocalizations = AppLocalizations.of(context)!;
    transactionBlocProvider = BlocProvider.of<TransactionBloc>(
      context,
      listen: false,
    );
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Stack(
          children: [
            ToolBar(
              title: appLocalizations.inwardTransactions,
              onInwardSearch: () {
                transactionBlocProvider?.add(SearchInitializeEvent());
              },
            ),
            _searchWidget(projectId, transactionBlocProvider),
          ],
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<TransactionBloc, TransactionState>(
          buildWhen: (previous, current) =>
              previous != current &&
              (current is TransactionLoadingState ||
                  current is TransactionDataState ||
                  current is TransactionEmptyState ||
                  current is SearchDataState ||
                  current is SearchCompletedState),
          builder: (context, state) {
            if (state is TransactionLoadingState) {
              return _loadingWidget();
            } else if (state is TransactionDataState) {
              final data = state.transactions;
              final filterData = _filterData(projectId, data);
              if (filterData.isNotEmpty) {
                return _dataWidget(filterData);
              }
            } else if (state is TransactionEmptyState) {
              return _emptyWidget(appLocalizations.transactionsNotFound);
            } else if (state is SearchDataState) {
              final searchedList = state.transactions;
              if (searchedList.isNotEmpty) {
                return _dataWidget(searchedList);
              } else {
                return _emptyWidget(appLocalizations.noRecordWithSearch);
              }
            } else if (state is SearchCompletedState) {
              final data = state.transactions;
              final filterData = _filterData(projectId, data);
              if (filterData.isNotEmpty) {
                return _dataWidget(filterData);
              }
            }
            return _emptyWidget(appLocalizations.transactionsNotFound);
          },
        ),
      ),
    );
  }

  List<TransactionInfo> _filterData(
    String? projectId,
    List<TransactionInfo> data,
  ) {
    final List<TransactionInfo> filterData = [];
    if (projectId != null) {
      filterData.addAll(
        data.where(
          (element) => element.projectId == projectId,
        ),
      );
    } else {
      filterData.addAll(data);
    }
    return filterData;
  }

  Widget _searchWidget(
    String? projectId,
    TransactionBloc? transactionBlocProvider,
  ) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      buildWhen: (previous, current) =>
          previous != current &&
          (current is SearchInitializedState ||
              current is SearchDataState ||
              current is SearchCompletedState),
      builder: (context, state) {
        if (state is SearchInitializedState || state is SearchDataState) {
          return SafeArea(
            child: Container(
              height: double.infinity,
              margin: EdgeInsets.only(
                left: (Dimens.screenHorizontalMargin * 2.95).w,
              ),
              child: AppSearchView(
                onTextChange: (searchBy) {
                  transactionBlocProvider?.add(
                    SearchTextChangedEvent(
                      projectId,
                      searchBy,
                    ),
                  );
                },
                onCloseSearch: () {
                  transactionBlocProvider?.add(
                    SearchCloseEvent(),
                  );
                },
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _loadingWidget() {
    return const ListItemShimmer(
      shimmerItemCount: 10,
      isTransactionShimmerView: true,
    );
  }

  Widget _dataWidget(List<TransactionInfo> transactions) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: transactions.length,
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

  @override
  void dispose() {
    transactionBlocProvider?.add(
      SearchCloseEvent(),
    );
    super.dispose();
  }
}
