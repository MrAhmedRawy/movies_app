import 'package:flutter_bloc/flutter_bloc.dart';

// Basic states for you to expand
abstract class AuthState {}
class AuthInitial extends AuthState {}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  // TODO: Add Firebase Auth methods here (signIn, signOut, etc.)
}
