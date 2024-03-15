import 'dart:async';
import 'dart:isolate';

import './model/milestone_info.dart';
import './model/weekly_milestone_input.dart';
import '../utils/app_utils.dart';

class GenerateWeeklyMilestones {
  static Isolate? _isolate;
  static bool isRunning = false;

  static _isIsolateRunning() {
    return _isolate != null && isRunning;
  }

  static _terminateIsolate() {
    if (_isolate != null) {
      _isolate!.kill(priority: Isolate.immediate);
      _isolate = null;
    }
  }

  static Stream<List<MilestoneInfo>> callIsolateToGenerateWeeklyMilestones(
    WeeklyMilestoneInput input,
  ) async* {
    if (_isIsolateRunning()) {
      _terminateIsolate();
    }
    isRunning = true;
    final controller = StreamController<List<MilestoneInfo>>();

    final ReceivePort receivePort = ReceivePort();
    _isolate = await Isolate.spawn(
      _weekBasedMilestones,
      input..sendPort = receivePort.sendPort,
    );
    receivePort.listen(
      (message) {
        isRunning = false;
        if (message is List<MilestoneInfo>) {
          controller.add(message);
        }
      },
    ).onDone(
      () {
        controller.close();
      },
    );
    yield* controller.stream;
  }

  static _weekBasedMilestones(WeeklyMilestoneInput input) {
    double tempCollectedAmount = 0;
    final totalWeek = input.totalWeek;
    final totalAmount = input.totalAmount;
    final projectStartDate = input.projectStartDate;
    final milestones = input.milestones;
    final double hourlyRate = input.hourlyRates;
    final double weeklyHours = input.weeklyHours;
    final SendPort? sendPort = input.sendPort;

    for (int i = 0; i < totalWeek; i++) {
      DateTime projectDateTime = projectStartDate;
      if (milestones.isNotEmpty && milestones.last.dateTime != null) {
        projectDateTime = milestones.last.dateTime!;
      }
      double amount = hourlyRate * weeklyHours;
      tempCollectedAmount += amount;
      if (tempCollectedAmount > totalAmount) {
        amount = totalAmount - (tempCollectedAmount - amount);
      }
      final dateTime = AppUtils.getNextWeekDate(projectDateTime);
      final timeStamp = DateTime.now().millisecondsSinceEpoch;
      int id = milestones.length;
      /*if (milestones.isNotEmpty) {
        id = (milestones.last.id) + 1;
      }*/
      milestones.add(
        MilestoneInfo(
          id: id,
          dateTime: dateTime,
          milestoneAmount: amount,
          createdAt: timeStamp,
          updatedAt: timeStamp,
        ),
      );
    }

    if (milestones.isNotEmpty) {
      milestones.sort(
        (a, b) {
          if (a.dateTime != null && b.dateTime != null) {
            return a.dateTime!.compareTo(b.dateTime!);
          }
          return -1;
        },
      );
      // Updating sequence of milestone.
      // This will be used when drag and drop feature with milestone list
      for (int i = 0; i < milestones.length; i++) {
        milestones[i].sequence = i;
      }
    }
    sendPort?.send(milestones);
  }
}
