import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import './bloc/transaction_bloc.dart';
import './model/transaction_info.dart';
import './widget/transaction_list_item.dart';
import '../../config/app_config.dart';
import '../app_widgets/app_empty_view.dart';
import '../app_widgets/app_search_view.dart';
import '../app_widgets/app_tool_bar.dart';
import '../const/dimens.dart';
import '../enums/color_enums.dart';
import '../project_list/fetch_projects_bloc/firebase_fetch_projects_bloc.dart';
import '../shimmer_view/list_item_shimmer.dart';
import '../utils/color_utils.dart';

class InwardTransactions extends StatefulWidget {
  const InwardTransactions({Key? key}) : super(key: key);

  @override
  State<InwardTransactions> createState() => _InwardTransactionsState();
}

class _InwardTransactionsState extends State<InwardTransactions> {
  AppLocalizations? appLocalizations;
  TransactionBloc? _transactionBlocProvider;
  FirebaseFetchProjectsBloc? _firebaseFetchProjectsBloc;
  String? projectId;
  late ScrollController _scrollController;
  bool isInitialized = false;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(
      () {
        if (_scrollController.position.maxScrollExtent ==
            _scrollController.offset) {
          if (!_isDisabledPullToRefreshLoadMore()) {
            _transactionBlocProvider?.add(FetchTransactionEvent());
          }
        }
      },
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    projectId ??= ModalRoute.of(context)!.settings.arguments as String?;
    appLocalizations ??= AppLocalizations.of(context)!;
    _firebaseFetchProjectsBloc = BlocProvider.of<FirebaseFetchProjectsBloc>(
      context,
      listen: false,
    );
    _transactionBlocProvider ??= BlocProvider.of<TransactionBloc>(
      context,
      listen: false,
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!isInitialized) {
        isInitialized = true;
        if ((_transactionBlocProvider?.transactionCount ?? 0) <=
            AppConfig.transactionPaginationLoadLimit) {
          _transactionBlocProvider?.add(FetchTransactionEvent());
        }
      }
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Stack(
          children: [
            ToolBar(
              title: appLocalizations!.inwardTransactions,
              onInwardSearch: () {
                _transactionBlocProvider?.add(SearchInitializeEvent());
              },
            ),
            _searchWidget(projectId, _transactionBlocProvider),
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
            if (state is TransactionLoadingState && !state.isPagination) {
              return _loadingWidget();
            } else if (state is TransactionDataState ||
                state is TransactionLoadingState) {
              List<TransactionInfo> data;
              bool hasMoreData = true;
              if (state is TransactionDataState) {
                data = state.transactions;
                hasMoreData = state.hasMoreTransaction;
              } else {
                data = _transactionBlocProvider?.getAllTransactions() ?? [];
              }
              final filterData = _filterData(projectId, data);
              if (filterData.isNotEmpty) {
                return _dataWidget(
                  filterData,
                  hasMoreTransaction: hasMoreData,
                  isLoading:
                      state is TransactionLoadingState && state.isPagination,
                );
              }
            } else if (state is TransactionEmptyState) {
              return _emptyWidget(appLocalizations!.transactionsNotFound);
            } else if (state is SearchDataState) {
              final searchedList = state.transactions;
              if (searchedList.isNotEmpty) {
                return _dataWidget(searchedList);
              } else {
                return _emptyWidget(appLocalizations!.noRecordWithSearch);
              }
            } else if (state is SearchCompletedState) {
              final data = state.transactions;
              final filterData = _filterData(projectId, data);
              if (filterData.isNotEmpty) {
                return _dataWidget(
                  filterData,
                  hasMoreTransaction: state.hasMoreTransaction,
                );
              }
            }
            return _emptyWidget(appLocalizations!.transactionsNotFound);
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

  bool _isDisabledPullToRefreshLoadMore() {
    return _transactionBlocProvider?.isPaginationDisabled ?? false;
  }

  Widget _dataWidget(
    List<TransactionInfo> transactions, {
    bool? hasMoreTransaction,
    bool? isLoading,
  }) {
    return ScrollConfiguration(
      behavior: const MaterialScrollBehavior().copyWith(
        overscroll: false,
      ),
      child: RefreshIndicator(
        onRefresh: _isDisabledPullToRefreshLoadMore()
            ? () => Future.value()
            : () async {
                _transactionBlocProvider
                    ?.add(FetchTransactionEvent(loadInitial: true));
              },
        notificationPredicate:
            _isDisabledPullToRefreshLoadMore() ? (_) => false : (_) => true,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          controller: _scrollController,
          itemCount: transactions.length + 1,
          itemBuilder: (context, index) {
            if (index < transactions.length) {
              final transactionInfo = transactions[index];
              final milestoneInfo = _firebaseFetchProjectsBloc
                  ?.getMilestoneInfo(transactionInfo.milestoneId);
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
            } else {
              if (_isDisabledPullToRefreshLoadMore() ||
                  (hasMoreTransaction ?? false) == false) {
                return const SizedBox();
              }
              if (hasMoreTransaction == true && isLoading == true) {
                return LinearProgressIndicator(
                  color: ColorUtils.getColor(
                    context,
                    ColorEnums.themeColor,
                  ),
                );
              }
            }
            return const SizedBox();
          },
          separatorBuilder: (context, index) {
            if (index < transactions.length &&
                index != transactions.length - 1) {
              return Divider(
                height: 0,
                color: ColorUtils.getColor(
                  context,
                  ColorEnums.grayD9Color,
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _emptyWidget(String message) {
    return RefreshIndicator(
      onRefresh: _isDisabledPullToRefreshLoadMore()
          ? () => Future.value()
          : () async {
              _transactionBlocProvider
                  ?.add(FetchTransactionEvent(loadInitial: true));
            },
      notificationPredicate:
          _isDisabledPullToRefreshLoadMore() ? (_) => false : (_) => true,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.screenHorizontalMargin.w,
          vertical: Dimens.homeEmptyViewVerticalPadding.h,
        ),
        child: AppEmptyView(
          message: message,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _transactionBlocProvider?.add(
      SearchCloseEvent(),
    );
    super.dispose();
  }
}
