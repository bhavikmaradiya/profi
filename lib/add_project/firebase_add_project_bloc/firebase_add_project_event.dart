part of 'firebase_add_project_bloc.dart';

abstract class FirebaseAddProjectEvent {}

class FirebaseAddProjectInitEvent extends FirebaseAddProjectEvent {}

class FirebaseAddProjectSaveEvent extends FirebaseAddProjectEvent {
  final ProjectInfo? projectInfo;
  final List<MilestoneInfo>? milestoneInfo;

  FirebaseAddProjectSaveEvent(this.projectInfo, this.milestoneInfo);
}

class FirebaseEditProjectSaveEvent extends FirebaseAddProjectEvent {
  final ProjectInfo? projectInfo;
  final List<MilestoneInfo>? updatedMilestones;
  final List<MilestoneInfo>? originalMilestones;

  FirebaseEditProjectSaveEvent(
    this.projectInfo,
    this.updatedMilestones,
    this.originalMilestones,
  );
}
