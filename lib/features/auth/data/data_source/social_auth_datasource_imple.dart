import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_store/features/auth/data/data_source/social_auth_datasource.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../common/errors/exceptions.dart';
import '../../../../common/network/firebase/auth_client.dart';
import '../../../settings/data/models/user_model.dart';

class SocialAuthDataSourceImpl implements SocialAuthDatasource {
  final AuthClient _authClient;
  final GoogleSignIn _googleSignIn;
  bool _isInitialized = false;

  SocialAuthDataSourceImpl({
    required this._authClient,
    required this._googleSignIn,
  });

  Future<void> ensureInitialized() async {
    if (_isInitialized) return;

    await _googleSignIn.initialize(
      serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID']!,
    );

    _isInitialized = true;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      await ensureInitialized();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final response = await _authClient.signInWithCredential(credential);

      final user = response.user;

      if (user == null) {
        throw AuthException('فشل تسجيل الدخول بواسطة Google');
      }

      return UserModel.fromFirebaseUser(user: user);
    } on GoogleSignInException catch (e) {
      throw AuthException(_mapGoogleSignInError(e.code));
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code, provider: 'Google'));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw ServerException('حدث خطأ في الخادم، يرجى المحاولة لاحقاً');
    }
  }

  String _mapGoogleSignInError(GoogleSignInExceptionCode code) {
    switch (code) {
      case GoogleSignInExceptionCode.canceled:
        return 'تم إلغاء تسجيل الدخول';

      case GoogleSignInExceptionCode.clientConfigurationError:
        return 'خطأ في إعدادات Google Sign In';

      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'إعدادات Google غير صحيحة';

      case GoogleSignInExceptionCode.uiUnavailable:
        return 'واجهة تسجيل الدخول غير متاحة حالياً';

      case GoogleSignInExceptionCode.userMismatch:
        return 'حدث تعارض في الحساب المستخدم';

      default:
        return 'فشل تسجيل الدخول بواسطة Google';
    }
  }

  String _mapFirebaseAuthError(String code, {required String provider}) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'يوجد حساب مرتبط بهذا البريد الإلكتروني بطريقة تسجيل دخول مختلفة';

      case 'invalid-credential':
        return 'بيانات تسجيل الدخول غير صالحة';

      case 'credential-already-in-use':
        return 'بيانات تسجيل الدخول مستخدمة بالفعل';

      case 'user_bloc-disabled':
        return 'تم تعطيل هذا الحساب';

      case 'operation-not-allowed':
        return 'تسجيل الدخول بواسطة $provider غير مفعل حالياً';

      case 'network-request-failed':
        return 'تعذر الاتصال بالإنترنت، تحقق من الشبكة';

      case 'too-many-requests':
        return 'تم تجاوز عدد المحاولات المسموح بها، حاول لاحقاً';

      default:
        return 'تعذر تسجيل الدخول بواسطة $provider';
    }
  }
}
