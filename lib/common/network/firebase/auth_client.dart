
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthClient {
  Future<UserCredential> signUp({required String email, required String password});
  Future<bool> isEmailVerified();
  Future<UserCredential> signIn({required String email, required String password});
  Future<UserCredential> signInWithCredential(AuthCredential credential);
  Future<void> sendPasswordResetEmail({required String email});
  Future<void> deleteAccount();
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
  });
  Future<UserCredential> linkWithPhoneCredential({required PhoneAuthCredential credential});
  Future<void> sendEmailVerification();
  Future<void> updatePassword({required String newPassword});
  Future<void> signOut();
  Future<void> reAuthenticateWithEmailAndPassword({
    required String email,
    required String password,
  });
}