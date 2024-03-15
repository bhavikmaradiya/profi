part of 'project_operations_bloc.dart';

abstract class ProjectOperationsState {}

class ProjectOperationsInitialState extends ProjectOperationsState {}

class ProjectOperationStartedState extends ProjectOperationsState {
  final ProjectInfo projectInfo;

  ProjectOperationStartedState(this.projectInfo);
}

class ProjectOperationCompletedState extends ProjectOperationsState {}

class ProjectDeletedState extends ProjectOperationsState {}
