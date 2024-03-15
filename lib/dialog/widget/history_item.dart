import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../config/app_config.dart';
import '../../const/dimens.dart';
import '../../enums/color_enums.dart';
import '../../enums/logs_enum.dart';
import '../../logs/model/log_info.dart';
import '../../utils/app_utils.dart';
import '../../utils/color_utils.dart';

class HistoryItem extends StatelessWidget {
  final LogInfo log;
  final String? currentUserId;

  const HistoryItem({
    Key? key,
    required this.log,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final logContent = getLogContent(appLocalizations, log);
    if (logContent.trim().isEmpty) {
      return const SizedBox();
    }
    final logTitle = getLogTitle(appLocalizations, log);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.historyContentHorizontalPadding.w,
        vertical: Dimens.historyContentVerticalPadding.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            logTitle,
            style: TextStyle(
              fontSize: Dimens.historyItemTitleTextSize.sp,
              color: ColorUtils.getColor(
                context,
                ColorEnums.black33Color,
              ),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(
            height: Dimens.historyItemTitleDescPadding.h,
          ),
          Text(
            logContent,
            style: TextStyle(
              fontSize: Dimens.historyItemDescTextSize.sp,
              color: ColorUtils.getColor(
                context,
                ColorEnums.gray6CColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getLogTitle(AppLocalizations appLocalizations, LogInfo log) {
    StringBuffer buffer = StringBuffer();
    buffer.write(
      DateFormat(AppConfig.milestoneInfoDateFormat).format(
        DateTime.fromMillisecondsSinceEpoch(
          log.createdAt ?? 0,
        ),
      ),
    );
    buffer.write(' - ');
    if (log.generatedByUserId == currentUserId) {
      buffer.write(appLocalizations.you);
    } else {
      buffer.write(log.generatedByUserName);
    }
    buffer.write(' - ');
    if (log.on == LogsEnum.onCreate.name) {
      buffer.write(appLocalizations.logMilestoneCreated);
    } else if (log.on == LogsEnum.onInfo.name) {
      buffer.write(appLocalizations.logMilestoneChanged);
    } else if (log.on == LogsEnum.onPaid.name) {
      buffer.write(appLocalizations.logPaid);
    } else if (log.on == LogsEnum.onUnPaid.name) {
      buffer.write(appLocalizations.logUnPaid);
    } else if (log.on == LogsEnum.onInvoiced.name) {
      buffer.write(appLocalizations.invoiced);
    }
    return buffer.isEmpty ? '' : buffer.toString().trim();
  }

  String getLogContent(AppLocalizations appLocalizations, LogInfo log) {
    String content = '';
    if (log.on == LogsEnum.onCreate.name) {
      content = _generateCreateLog(
        appLocalizations: appLocalizations,
        log: log,
      );
    } else if (log.on == LogsEnum.onInfo.name) {
      content = _generateInfoLog(
        appLocalizations: appLocalizations,
        log: log,
      );
    } else if (log.on == LogsEnum.onPaid.name ||
        log.on == LogsEnum.onUnPaid.name) {
      content = _generatePaidUnPaidLog(
        appLocalizations: appLocalizations,
        log: log,
      );
    } else if (log.on == LogsEnum.onInvoiced.name) {
      content = _generateInvoicedLog(
        appLocalizations: appLocalizations,
        log: log,
      );
    }
    return content;
  }

  String _generateCreateLog({
    required AppLocalizations appLocalizations,
    required LogInfo log,
  }) {
    final newAmount = log.newAmount;
    final newDate = log.newDate;
    final notes = log.notes;
    if (newAmount != null ||
        newDate != null ||
        (notes != null && notes.trim().isNotEmpty)) {
      StringBuffer buffer = StringBuffer();

      if (newAmount != null) {
        buffer.write('${appLocalizations.logAmount} ');
        buffer.write(AppUtils.removeTrailingZero(newAmount));
      }

      if (newDate != null) {
        if (buffer.toString().trim().isNotEmpty) {
          buffer.writeln();
        }
        buffer.write('${appLocalizations.logDate} ');
        buffer.write(
          DateFormat(AppConfig.milestoneInfoDateFormat).format(
            DateTime.fromMillisecondsSinceEpoch(
              newDate,
            ),
          ),
        );
      }

      if (notes != null && notes.trim().isNotEmpty) {
        if (buffer.toString().trim().isNotEmpty) {
          buffer.writeln();
        }
        buffer.write('"${notes.trim()}"');
      }

      return buffer.isEmpty ? '' : buffer.toString().trim();
    }
    return '';
  }

  String _generateInfoLog({
    required AppLocalizations appLocalizations,
    required LogInfo log,
  }) {
    final oldAmount = log.oldAmount;
    final newAmount = log.newAmount;
    final oldDate = log.oldDate;
    final newDate = log.newDate;
    final notes = log.notes;
    if (oldAmount != null ||
        newAmount != null ||
        oldDate != null ||
        newDate != null ||
        (notes != null && notes.trim().isNotEmpty)) {
      StringBuffer buffer = StringBuffer();

      if (oldAmount != newAmount) {
        buffer.write('${appLocalizations.logAmount} ');
        buffer.write(AppUtils.removeTrailingZero(oldAmount ?? 0));
        buffer.write(' ${appLocalizations.logTo} ');
        buffer.write(AppUtils.removeTrailingZero(newAmount ?? 0));
      }

      if (oldDate != newDate) {
        if (buffer.toString().trim().isNotEmpty) {
          buffer.writeln();
        }
        buffer.write('${appLocalizations.logDate} ');
        buffer.write(
          DateFormat(AppConfig.milestoneInfoDateFormat).format(
            DateTime.fromMillisecondsSinceEpoch(
              oldDate ?? 0,
            ),
          ),
        );
        buffer.write(' ${appLocalizations.logTo} ');
        buffer.write(
          DateFormat(AppConfig.milestoneInfoDateFormat).format(
            DateTime.fromMillisecondsSinceEpoch(
              newDate ?? 0,
            ),
          ),
        );
      }

      if (notes != null && notes.trim().isNotEmpty) {
        if (buffer.toString().trim().isNotEmpty) {
          buffer.writeln();
        }
        buffer.write('"${notes.trim()}"');
      }

      return buffer.isEmpty ? '' : buffer.toString().trim();
    }
    return '';
  }

  String _generatePaidUnPaidLog({
    required AppLocalizations appLocalizations,
    required LogInfo log,
  }) {
    final transaction = log.transaction;
    final notes = log.notes;
    if (transaction != null || (notes != null && notes.trim().isNotEmpty)) {
      StringBuffer buffer = StringBuffer();
      if (log.on == LogsEnum.onPaid.name) {
        buffer.write('${appLocalizations.logPaid} ');
      } else if (log.on == LogsEnum.onUnPaid.name) {
        buffer.write('${appLocalizations.logUnPaid} ');
      }
      buffer.write(AppUtils.removeTrailingZero(transaction));
      if (notes != null && notes.trim().isNotEmpty) {
        if (buffer.toString().trim().isNotEmpty) {
          buffer.writeln();
        }
        buffer.write('"${notes.trim()}"');
      }
      return buffer.isEmpty ? '' : buffer.toString().trim();
    }
    return '';
  }

  String _generateInvoicedLog({
    required AppLocalizations appLocalizations,
    required LogInfo log,
  }) {
    final invoiced = log.invoiced;
    if (invoiced == true) {
      return appLocalizations.logMilestoneInvoiced;
    } else if (invoiced == false) {
      return appLocalizations.logMilestoneInvoicedCanceled;
    }
    return '';
  }
}
