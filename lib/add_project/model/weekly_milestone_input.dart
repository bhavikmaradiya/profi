import 'dart:isolate';

import './milestone_info.dart';

class WeeklyMilestoneInput {
  final double weeklyHours;
  final double hourlyRates;
  final int totalWeek;
  final double totalAmount;
  final DateTime projectStartDate;
  final List<MilestoneInfo> milestones;
  SendPort? sendPort;

  WeeklyMilestoneInput({
    required this.weeklyHours,
    required this.hourlyRates,
    required this.totalWeek,
    required this.totalAmount,
    required this.projectStartDate,
    required this.milestones,
    this.sendPort,
  });
}
