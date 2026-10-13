import 'package:firebase_auth/firebase_auth.dart';
import 'auth_client.dart';

class AuthClientImpl implements AuthClient {
  final FirebaseAuth client;
  AuthClientImpl(this.client);

  @override
  Future<UserCredential> signUp({required String email, required String password}) async =>
      await client.createUserWithEmailAndPassword(
          email: email,
          password: password,
      );

  @override
  Future<UserCredential> signIn({required String email, required String password}) async =>
      await client.signInWithEmailAndPassword(email: email, password: password);

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) async =>
      await client.signInWithCredential(credential);

  @override
  Future<void> sendPasswordResetEmail({required String email}) async =>
      await client.sendPasswordResetEmail(email: email);

  @override
  Future<void> deleteAccount() async =>
      await client.currentUser!.delete();

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
  }) async {
    await client.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  @override
  Future<UserCredential> linkWithPhoneCredential({required PhoneAuthCredential credential}) async =>
      await client.currentUser!.linkWithCredential(credential);

  @override
  Future<void> sendEmailVerification() async =>
      await client.currentUser!.sendEmailVerification();

  @override
  Future<bool> isEmailVerified() async {
    final user = client.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'user-not-found');
    await user.reload();
    return client.currentUser?.emailVerified ?? false;
  }

  @override
  Future<void> updatePassword({required String newPassword}) async =>
      await client.currentUser!.updatePassword(newPassword);

  @override
  Future<void> signOut() async =>
      await client.signOut();

  @override
  Future<void> reAuthenticateWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final user = client.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'user-not-found');

    final credential =
    EmailAuthProvider.credential(email: email, password: password);
    await user.reauthenticateWithCredential(credential);
  }
}