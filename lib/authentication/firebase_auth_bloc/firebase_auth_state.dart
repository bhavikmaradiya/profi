part of 'firebase_auth_bloc.dart';

abstract class FirebaseAuthState {}

class FirebaseAuthInitialState extends FirebaseAuthState {}

class FirebaseAuthLoadingState extends FirebaseAuthState {}

class FirebaseRegisterSuccessState extends FirebaseAuthState {}

class FirebaseRegisterEmailAlreadyInUseState extends FirebaseAuthState {}

class FirebaseRegisterFailedState extends FirebaseAuthState {
  final String? errorMessage;

  FirebaseRegisterFailedState(this.errorMessage);
}

class FirebaseLoginSuccessProfileState extends FirebaseAuthState {}

class FirebaseLoginSuccessHomeState extends FirebaseAuthState {}

class FirebaseLoginInvalidUserState extends FirebaseAuthState {}

class FirebaseLoginInvalidPasswordState extends FirebaseAuthState {}

class FirebaseLoginFailedState extends FirebaseAuthState {
  final String? errorMessage;

  FirebaseLoginFailedState(this.errorMessage);
}

class FirebaseLoggedOutState extends FirebaseAuthState {}
