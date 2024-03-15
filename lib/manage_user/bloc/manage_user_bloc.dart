import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/firestore_config.dart';
import '../../profile/model/profile_info.dart';

part 'manage_user_event.dart';
part 'manage_user_state.dart';

class ManageUserBloc extends Bloc<ManageUserEvent, ManageUserState> {
  final _fireStoreInstance = FirebaseFirestore.instance;
  StreamSubscription? _userListSubscription;

  ManageUserBloc() : super(ManageUserInitial()) {
    on<FetchUserListEvent>(_fetchUsersList);
    add(FetchUserListEvent());
  }

  _fetchUsersList(
    FetchUserListEvent event,
    Emitter<ManageUserState> emit,
  ) async {
    emit(UsersLoadingState());
    _userListSubscription = _fireStoreInstance
        .collection(FireStoreConfig.userCollection)
        .snapshots()
        .listen((event) {
      final usersList =
          event.docs.map((e) => ProfileInfo.fromSnapshot(e)).toList();
      if (usersList.isNotEmpty) {
        emit(UsersLoadedState(usersList));
      } else {
        emit(NoUsersFoundState());
      }
    });
    await _userListSubscription?.asFuture();
  }

  @override
  Future<void> close() async {
    await _userListSubscription?.cancel();
    return super.close();
  }
}
