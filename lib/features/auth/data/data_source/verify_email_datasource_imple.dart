import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_store/common/errors/exceptions.dart';
import 'package:fit_store/common/network/firebase/auth_client.dart';
import 'package:fit_store/features/auth/data/data_source/verify_email_datasource.dart';

class VerifyEmailDatasourceImple implements VerifyEmailDatasource{
  final AuthClient _authClient;
  VerifyEmailDatasourceImple({required this._authClient});
  @override
  Future<void> sendEmailVerification() async{
   try{
   await _authClient.sendEmailVerification();
   } on FirebaseAuthException catch(e){
      throw AuthException(e.toString());
   }catch(e){
     throw ServerException(e.toString());
   }
  }

}