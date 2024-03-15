import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app_models/drop_down_model.dart';
import '../../config/firestore_config.dart';
import '../../enums/user_role_enums.dart';
import '../../profile/model/profile_info.dart';
import '../../utils/app_utils.dart';

part 'add_user_event.dart';

part 'add_user_state.dart';

class AddUserBloc extends Bloc<AddUserEvent, AddUserState> {
  final _fireStoreInstance = FirebaseFirestore.instance;
  final _firebaseAuthInstance = FirebaseAuth.instance;
  UserRoleEnum? _selectedUserRole;
  ProfileInfo? userToEdit;

  AddUserBloc() : super(AddUserInitial()) {
    on<CreateUserEvent>(_onCreateUser);
    on<UserRoleSelectionEvent>(_onUserRoleSelected);
    on<VisibleInvisiblePasswordFieldEvent>(_onVisibleInvisiblePasswordField);
    on<EditUserInitEvent>(_onEditUserEvent);
  }

  _onEditUserEvent(
    EditUserInitEvent event,
    Emitter<AddUserState> emit,
  ) {
    userToEdit = event.userInfo;
    final userRole = UserRoleEnum.values.firstWhereOrNull(
        (element) => element.name == (userToEdit!.role ?? ''));

    if (userRole != null) {
      add(UserRoleSelectionEvent(userRole));
    }
  }

  _onUserRoleSelected(
    UserRoleSelectionEvent event,
    Emitter<AddUserState> emit,
  ) {
    _selectedUserRole = event.userRole;
    emit(UserRoleSelectedState(_selectedUserRole!));
  }

  _onCreateUser(
    CreateUserEvent event,
    Emitter<AddUserState> emit,
  ) async {
    final email = event.email.trim();
    final name = event.name.trim();
    final role = _selectedUserRole?.name.trim() ?? '';
    final password = event.password.trim();

    if (name.isEmpty) {
      emit(InvalidNameFieldErrorState());
    } else if (role.isEmpty) {
      emit(InvalidRoleFieldErrorState());
    } else if (email.isEmpty || !AppUtils.isValidEmail(email)) {
      emit(InvalidEmailFieldErrorState());
    } else if (userToEdit == null &&
        (password.isEmpty || !AppUtils.isValidPasswordToRegister(password))) {
      emit(InvalidPasswordFieldErrorState());
    } else if (userToEdit == null) {
      await _createUserWithEmailPassword(event, emit);
    } else if (userToEdit != null) {
      final profileInfo = ProfileInfo(
        userId: userToEdit!.userId,
        email: userToEdit!.email,
        name: name,
        role: role,
      );
      await _uploadProfileInfoToFirebase(profileInfo);
      emit(CreateUserSuccessState(isEdit: true));
    }
  }

  _onVisibleInvisiblePasswordField(
    VisibleInvisiblePasswordFieldEvent event,
    Emitter<AddUserState> emit,
  ) {
    emit(VisibleInvisiblePasswordFieldState(event.isVisible));
  }

  _createUserWithEmailPassword(
    CreateUserEvent event,
    Emitter<AddUserState> emit,
  ) async {
    final email = event.email.trim();
    final name = event.name.trim();
    final role = _selectedUserRole?.name.trim() ?? '';
    final password = event.password.trim();

    if (AppUtils.isValidEmail(email) &&
        AppUtils.isValidPasswordToRegister(password) &&
        name.isNotEmpty &&
        role.isNotEmpty) {
      emit(CreateUserLoadingState(true));
      try {
        final userCredentials =
            await _firebaseAuthInstance.createUserWithEmailAndPassword(
          email: email,
          password: event.password,
        );
        final timeStamp = DateTime.now().millisecondsSinceEpoch;
        final firebaseUserId = userCredentials.user?.uid;
        final profileInfo = ProfileInfo(
          userId: firebaseUserId,
          email: email,
          name: name,
          role: role,
          createdAt: timeStamp,
          updatedAt: timeStamp,
        );
        await _uploadProfileInfoToFirebase(profileInfo);
        emit(CreateUserSuccessState());
      } on FirebaseAuthException catch (ex) {
        if (ex.code == 'email-already-in-use') {
          emit(CreateUserFailedState('email-already-in-use'));
        } else {
          emit(CreateUserFailedState(ex.message!));
        }
      }
    }
  }

  _uploadProfileInfoToFirebase(ProfileInfo profileInfo) async {
    if (userToEdit != null) {
      await _fireStoreInstance
          .collection(FireStoreConfig.userCollection)
          .doc(profileInfo.userId)
          .update({
        FireStoreConfig.userNameField: profileInfo.name,
        FireStoreConfig.userRoleField: profileInfo.role,
        FireStoreConfig.updatedAtField: DateTime.now().millisecondsSinceEpoch
      });
    } else {
      await _fireStoreInstance
          .collection(FireStoreConfig.userCollection)
          .doc(profileInfo.userId)
          .set(profileInfo.toMap());
    }
  }
}
