import '../../add_project/model/milestone_info.dart';
import '../../add_project/model/project_info.dart';
import '../../enums/color_enums.dart';
import '../../enums/payment_status_enum.dart';

class MilestoneUtils {
  static const keyPendingTotalAmount = 'totalAmount';
  static const keyPendingAmountWithin5Days = '5days';
  static const keyPendingAmountWithin10Days = '10days';
  static const keyPendingAmountWithin15Days = '15days';
  static const keyPendingAmountWithinThisMonth = 'thisMonth';
  static const keyPendingAmountWithinNextMonth = 'nextMonth';

  static bool isValidMilestone(MilestoneInfo? milestoneInfo) {
    return milestoneInfo != null &&
        (milestoneInfo.dateTime != null ||
            milestoneInfo.milestoneAmount != null);
  }

  static bool isFullyPaidMilestone(MilestoneInfo milestoneInfo) {
    return milestoneInfo.paymentStatus == PaymentStatusEnum.fullyPaid.name;
  }

  static bool isPartiallyPaidMilestone(MilestoneInfo milestoneInfo) {
    return milestoneInfo.paymentStatus == PaymentStatusEnum.partiallyPaid.name;
  }

  static bool isMilestoneWithinPaymentCycle(MilestoneInfo milestoneInfo) {
    return milestoneInfo.paymentStatus == PaymentStatusEnum.aboutToExceed.name;
  }

  static bool isMilestonePaymentCycleExceed(MilestoneInfo milestoneInfo) {
    return milestoneInfo.paymentStatus == PaymentStatusEnum.exceeded.name;
  }

  static bool isMultipleMilestonesPaymentPending(
    List<MilestoneInfo> milestones,
  ) {
    final items = milestones.where(
      (element) => element.paymentStatus == PaymentStatusEnum.exceeded.name,
    );
    return items.length > 1;
  }

  static ColorEnums getMilestoneBlockColor(
    MilestoneInfo? milestoneInfo, {
    bool? isApplicableForGrayColor,
  }) {
    if (milestoneInfo != null) {
      if (isFullyPaidMilestone(milestoneInfo)) {
        return ColorEnums.milestoneFullyPaidColor;
      } else if (isPartiallyPaidMilestone(milestoneInfo)) {
        return ColorEnums.milestonePartiallyPaidColor;
      } else if (isMilestonePaymentCycleExceed(milestoneInfo)) {
        return ColorEnums.milestoneExceededColor;
      } else if (isMilestoneWithinPaymentCycle(milestoneInfo)) {
        return ColorEnums.milestoneAboutToExceedColor;
      }
    }
    if (isApplicableForGrayColor ?? false) {
      return ColorEnums.upcomingMilestoneColor;
    }
    return ColorEnums.whiteColor;
  }

  static PaymentStatusEnum getMilestonePaymentStatus(
    ProjectInfo projectInfo,
    MilestoneInfo milestoneInfo,
  ) {
    return getPaymentStatusFromMilestoneInfo(
      projectInfo: projectInfo,
      milestoneAmount: milestoneInfo.milestoneAmount ?? 0,
      milestoneReceivedAmount: milestoneInfo.receivedAmount ?? 0,
      milestoneDateTime: milestoneInfo.dateTime,
    );
  }

  static PaymentStatusEnum getPaymentStatusFromMilestoneInfo({
    required ProjectInfo projectInfo,
    required double milestoneAmount,
    required double milestoneReceivedAmount,
    required DateTime? milestoneDateTime,
  }) {
    if (milestoneReceivedAmount >= milestoneAmount) {
      return PaymentStatusEnum.fullyPaid;
    } else if (milestoneReceivedAmount > 0) {
      return PaymentStatusEnum.partiallyPaid;
    }
    return _getPaymentCycleStatus(
      projectInfo.paymentCycle,
      milestoneDateTime,
    );
  }

  static PaymentStatusEnum _getPaymentCycleStatus(
    int? projectPaymentCycle,
    DateTime? milestoneDateTime,
  ) {
    final paymentCycle = projectPaymentCycle ?? 0;
    final dateTimeNow = DateTime.now();
    final currentDate = DateTime(
      dateTimeNow.year,
      dateTimeNow.month,
      dateTimeNow.day,
    );
    DateTime milestoneDate = currentDate;
    if (milestoneDateTime != null) {
      milestoneDate = DateTime(
        milestoneDateTime.year,
        milestoneDateTime.month,
        milestoneDateTime.day,
      );
    }
    int dateDiffWithCurrentDate = milestoneDate.difference(currentDate).inDays;
    if (paymentCycle > 0) {
      final maxMilestoneDate = milestoneDate.add(
        Duration(
          days: paymentCycle,
        ),
      );
      dateDiffWithCurrentDate = maxMilestoneDate.difference(currentDate).inDays;
    } else if (paymentCycle < 0) {
      final minMilestoneDate = milestoneDate.subtract(
        Duration(
          days: paymentCycle.abs(),
        ),
      );
      dateDiffWithCurrentDate = currentDate.difference(minMilestoneDate).inDays;
    }

    if (!paymentCycle.isNegative) {
      if (dateDiffWithCurrentDate >= 0 &&
          dateDiffWithCurrentDate < paymentCycle) {
        return PaymentStatusEnum.aboutToExceed;
      } else if (dateDiffWithCurrentDate < paymentCycle) {
        return PaymentStatusEnum.exceeded;
      } else if (dateDiffWithCurrentDate > paymentCycle) {
        // grey one will come here,
        return PaymentStatusEnum.upcoming;
      }
    } else {
      if (dateDiffWithCurrentDate >= 0 &&
          dateDiffWithCurrentDate < paymentCycle.abs()) {
        return PaymentStatusEnum.aboutToExceed;
      } else if (dateDiffWithCurrentDate > paymentCycle.abs()) {
        return PaymentStatusEnum.exceeded;
      } else if (dateDiffWithCurrentDate < paymentCycle.abs()) {
        // grey one will come here,
        return PaymentStatusEnum.upcoming;
      }
    }
    return PaymentStatusEnum.upcoming;
  }

  static int getFocusedMilestoneIndex(List<MilestoneInfo> milestoneList) {
    int focusedMilestoneIndex = milestoneList.indexWhere((element) =>
        element.paymentStatus == PaymentStatusEnum.exceeded.name ||
        element.paymentStatus == PaymentStatusEnum.aboutToExceed.name);
    if (focusedMilestoneIndex == -1) {
      final nearestMilestone = _findNearestFutureDateMilestone(milestoneList);
      focusedMilestoneIndex = milestoneList.indexWhere(
        (element) => element.milestoneId == nearestMilestone?.milestoneId,
      );
      focusedMilestoneIndex = _upcomingMilestones(
        milestoneList,
        focusedMilestoneIndex,
      );
    }
    return focusedMilestoneIndex;
  }

  static int getNearestWhiteMilestoneIndex(List<MilestoneInfo> milestoneList) {
    final nearestMilestone = _findNearestFutureDateMilestone(milestoneList);
    int nearestIndex = milestoneList.indexWhere(
      (element) => element.milestoneId == nearestMilestone?.milestoneId,
    );
    nearestIndex = _upcomingMilestones(milestoneList, nearestIndex);
    return nearestIndex;
  }

  // In case of Red, Orange, Green
  // -> nearest milestone index will update
  // As Next milestone will become white color
  // or
  // it will become nearest or upcoming milestone
  static int _upcomingMilestones(
    List<MilestoneInfo> milestoneList,
    int nearestIndex,
  ) {
    if (nearestIndex != -1 && nearestIndex < milestoneList.length) {
      if (milestoneList[nearestIndex].paymentStatus !=
              PaymentStatusEnum.upcoming.name &&
          milestoneList[nearestIndex].paymentStatus !=
              PaymentStatusEnum.partiallyPaid.name) {
        if (milestoneList.length > (nearestIndex + 1)) {
          nearestIndex += 1;
          // check next index is also no case of Red, Orange, Green
          nearestIndex = _upcomingMilestones(milestoneList, nearestIndex);
        }
      }
    }
    return nearestIndex;
  }

  static MilestoneInfo? _findNearestFutureDateMilestone(
    List<MilestoneInfo> milestoneList,
  ) {
    // Get the current date without time components
    DateTime currentDate = DateTime.now();
    currentDate = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );
    // Filter out past dates and dates equal to the current date
    List<MilestoneInfo> futureDates = milestoneList.where((milestone) {
      return milestone.dateTime!.isAfter(currentDate) ||
          milestone.dateTime!.isAtSameMomentAs(currentDate);
    }).toList();
    if (futureDates.isEmpty) {
      return null; // No future dates found
    }
    // Sort the list of future dates in ascending order
    futureDates.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
    return futureDates.first; // Return the nearest first future date
  }

  static bool isValidMilestoneDate({
    required DateTime? projectStartDate,
    required DateTime? milestoneDate,
  }) {
    if (projectStartDate == null || milestoneDate == null) {
      return false;
    }
    final mDate = DateTime(
      milestoneDate.year,
      milestoneDate.month,
      milestoneDate.day,
    );
    final pDate = DateTime(
      projectStartDate.year,
      projectStartDate.month,
      projectStartDate.day,
    );
    return mDate.isAfter(pDate) || mDate.isAtSameMomentAs(pDate);
  }
}
