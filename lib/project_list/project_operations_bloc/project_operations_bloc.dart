import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../add_project/model/project_info.dart';
import '../../config/firestore_config.dart';

part 'project_operations_event.dart';

part 'project_operations_state.dart';

class ProjectOperationsBloc
    extends Bloc<ProjectOperationsEvent, ProjectOperationsState> {
  final _fireStoreInstance = FirebaseFirestore.instance;
  late ProjectInfo? _projectInfo;

  ProjectOperationsBloc() : super(ProjectOperationsInitialState()) {
    on<ProjectOperationsStartEvent>(_onOperationsInitialized);
    on<ProjectOperationCompleteEvent>(_onOperationCompleted);
    on<DeleteProjectEvent>(_onDeleteProject);
  }

  _onOperationsInitialized(
    ProjectOperationsStartEvent event,
    Emitter<ProjectOperationsState> emit,
  ) {
    _projectInfo = event.projectInfo;
    emit(ProjectOperationStartedState(_projectInfo!));
  }

  _onOperationCompleted(
    ProjectOperationCompleteEvent event,
    Emitter<ProjectOperationsState> emit,
  ) {
    _projectInfo = null;
    emit(ProjectOperationCompletedState());
  }

  _onDeleteProject(
    DeleteProjectEvent event,
    Emitter<ProjectOperationsState> emit,
  ) async {
    final projectId = event.projectInfo!.projectId!;
    final milestoneId = event.projectInfo!.milestoneId!;
    final batch = _fireStoreInstance.batch();
    final projectRef = _createProjectReference(projectId);
    batch.delete(projectRef);
    final milestoneSnapshot = await _createMilestoneReference(milestoneId);
    final milestonesDocument = milestoneSnapshot.docs;
    if (milestonesDocument.isNotEmpty) {
      for (var document in milestonesDocument) {
        batch.delete(document.reference);
      }
    }
    final transactionsSnapshot = await _createTransactionReference(projectId);
    final transactionDocument = transactionsSnapshot.docs;
    if (transactionDocument.isNotEmpty) {
      for (var document in transactionDocument) {
        batch.delete(document.reference);
      }
    }
    await batch.commit();
    emit(ProjectDeletedState());
  }

  DocumentReference _createProjectReference(String projectId) {
    return _fireStoreInstance
        .collection(FireStoreConfig.projectCollection)
        .doc(projectId);
  }

  Future<QuerySnapshot> _createMilestoneReference(String milestoneId) {
    return _fireStoreInstance
        .collection(FireStoreConfig.milestonesCollection)
        .doc(milestoneId)
        .collection(FireStoreConfig.milestoneInfoCollection)
        .get();
  }

  Future<QuerySnapshot> _createTransactionReference(String projectId) async {
    return await _fireStoreInstance
        .collection(FireStoreConfig.transactionsCollection)
        .where(FireStoreConfig.transactionProjectIdField, isEqualTo: projectId)
        .get();
  }
}
