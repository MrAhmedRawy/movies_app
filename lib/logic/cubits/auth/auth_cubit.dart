import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthCubit() : super(AuthInitial());

  Future<void> loginWithEmail(String email, String password) async {
    emit(AuthLoading());
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      emit(AuthSuccess());
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Authentication failed";
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = "wrong-email-or-password";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address is badly formatted.";
      } else if (e.code == 'user-disabled') {
        errorMessage = "This user has been disabled.";
      }
      emit(AuthError(errorMessage));
    } catch (e) {
      emit(AuthError("An unexpected error occurred"));
    }
  }

  Future<void> loginWithGoogle() async {
    emit(AuthLoading());
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        emit(AuthInitial());
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      final user = userCredential.user!;
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': user.displayName ?? "User",
          'email': user.email,
          'phone': user.phoneNumber,
          'avatar': user.photoURL ?? "assets/avatars/avtr01.png",
          'uid': user.uid,
        });
      }
      
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError("Google Login failed"));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String avatar,
  }) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'avatar': avatar,
        'uid': userCredential.user!.uid,
      });

      emit(AuthSuccess());
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Registration failed";
      if (e.code == 'weak-password') {
        errorMessage = "The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "The account already exists for that email.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address is badly formatted.";
      }
      emit(AuthError(errorMessage));
    } catch (e) {
      emit(AuthError("An unexpected error occurred"));
    }
  }

  Future<void> resetPassword(String email) async {
    emit(AuthLoading());
    try {
      await _auth.sendPasswordResetEmail(email: email);
      emit(AuthSuccess());
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Failed to send reset email";
      if (e.code == 'user-not-found') {
        errorMessage = "user-not-found";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address is badly formatted.";
      }
      emit(AuthError(errorMessage));
    } catch (e) {
      emit(AuthError("An unexpected error occurred"));
    }
  }

  Future<void> fetchUserData() async {
    emit(AuthLoading());
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          emit(UserDataLoaded(doc.data()!));
        } else {
          // If Firestore data is missing but user is authenticated, recreate it with Auth info
          final data = {
            'name': user.displayName ?? "User",
            'email': user.email,
            'phone': user.phoneNumber,
            'avatar': user.photoURL ?? "assets/avatars/avtr01.png",
            'uid': user.uid,
          };
          await _firestore.collection('users').doc(user.uid).set(data);
          emit(UserDataLoaded(data));
        }
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    emit(AuthInitial());
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String avatar,
  }) async {
    emit(AuthLoading());
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'name': name,
          'phone': phone,
          'avatar': avatar,
        });
        await fetchUserData();
      }
    } catch (e) {
      emit(AuthError("Failed to update profile"));
    }
  }

  Future<void> deleteAccount() async {
    emit(AuthLoading());
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
        await _googleSignIn.signOut();
        emit(AuthInitial());
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        emit(AuthError("re-authenticate-required"));
      } else {
        emit(AuthError(e.message ?? "Failed to delete account"));
      }
    } catch (e) {
      emit(AuthError("An unexpected error occurred"));
    }
  }
}

