part of 'firebase_add_project_bloc.dart';

abstract class FirebaseAddProjectState {}

class FirebaseAddProjectInitialState extends FirebaseAddProjectState {}

class FirebaseAddEditProjectSuccessState extends FirebaseAddProjectState {
  final bool isAddedNewProject;

  FirebaseAddEditProjectSuccessState(this.isAddedNewProject);
}

class ProjectCodeAlreadyTakenState extends FirebaseAddProjectState {}

class FirebaseAddEditProjectFailedState extends FirebaseAddProjectState {}
