part of 'firebase_auth_bloc.dart';

abstract class FirebaseAuthEvent {}

class VerifyFirebaseAuthEvent extends FirebaseAuthEvent {
  final String email;
  final String password;

  VerifyFirebaseAuthEvent(this.email, this.password);
}
