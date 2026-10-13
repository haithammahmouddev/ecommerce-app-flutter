import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_store/common/errors/exceptions.dart';
import 'package:fit_store/common/network/firebase/auth_client.dart';
import 'package:fit_store/features/auth/data/data_source/reset_password_datasource.dart';

class ResetPasswordDatasourceImple implements ResetPasswordDatasource{
  final AuthClient _authClient;
  ResetPasswordDatasourceImple({required this._authClient});
  @override
  sendPasswordResetEmail({required String email}) async{
   try{
     await _authClient.sendPasswordResetEmail(email: email);
   }on FirebaseAuthException catch(e){
     throw AuthException(e.toString());
   }catch (e){
     throw ServerException(e.toString());
   }
  }
}