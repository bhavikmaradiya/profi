import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/app_utils.dart';

part 'auth_field_validation_event.dart';

part 'auth_field_validation_state.dart';

class AuthFieldValidationBloc
    extends Bloc<AuthFieldValidationEvent, AuthFieldValidationState> {
  AuthFieldValidationBloc() : super(AuthFieldValidationInitialState()) {
    on<EmailIdFieldTextChangeEvent>(_onEmailIdFieldTextChange);
    on<PasswordFieldTextChangeEvent>(_onPasswordFieldTextChange);
    on<VisiblePasswordFieldEvent>(_onVisiblePasswordField);
    on<InVisiblePasswordFieldEvent>(_onInVisiblePasswordField);
  }

  _onEmailIdFieldTextChange(
    EmailIdFieldTextChangeEvent event,
    Emitter<AuthFieldValidationState> emit,
  ) {
    if (AppUtils.isValidEmail(event.emailId.trim())) {
      emit(ValidEmailFieldState());
    } else {
      emit(InvalidEmailFieldErrorState());
    }
  }

  _onPasswordFieldTextChange(
    PasswordFieldTextChangeEvent event,
    Emitter<AuthFieldValidationState> emit,
  ) {
    if (AppUtils.isValidPasswordLength(event.password)) {
      emit(ValidPasswordFieldState());
    } else {
      emit(InvalidPasswordFieldErrorState());
    }
  }

  _onVisiblePasswordField(
    VisiblePasswordFieldEvent event,
    Emitter<AuthFieldValidationState> emit,
  ) {
    emit(VisiblePasswordFieldState());
  }

  _onInVisiblePasswordField(
    InVisiblePasswordFieldEvent event,
    Emitter<AuthFieldValidationState> emit,
  ) {
    emit(InVisiblePasswordFieldState());
  }
}
