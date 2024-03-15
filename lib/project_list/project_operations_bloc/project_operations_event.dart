part of 'project_operations_bloc.dart';

abstract class ProjectOperationsEvent {}

class ProjectOperationsStartEvent extends ProjectOperationsEvent {
  final ProjectInfo projectInfo;

  ProjectOperationsStartEvent(this.projectInfo);
}

class ProjectDeleteOperationEvent extends ProjectOperationsEvent {}

class ProjectOperationCompleteEvent extends ProjectOperationsEvent {}

class DeleteProjectEvent extends ProjectOperationsEvent {
  final ProjectInfo? projectInfo;

  DeleteProjectEvent(this.projectInfo);
}
