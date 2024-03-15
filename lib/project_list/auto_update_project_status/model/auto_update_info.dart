import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';

import '../../../add_project/model/milestone_info.dart';
import '../../../add_project/model/project_info.dart';

class AutoUpdateInfo {
  final RootIsolateToken token;
  final FirebaseOptions firebaseOptions;
  final int timestamp;
  final List<MilestoneInfo> milestones;
  final List<ProjectInfo> projects;

  const AutoUpdateInfo({
    required this.token,
    required this.firebaseOptions,
    required this.timestamp,
    required this.milestones,
    required this.projects,
  });
}
