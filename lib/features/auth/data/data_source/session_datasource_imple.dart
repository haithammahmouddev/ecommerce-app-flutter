import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_store/common/network/firebase/auth_client.dart';
import 'package:fit_store/features/auth/data/data_source/session_datasource.dart';

import '../../../../common/errors/exceptions.dart';

class SessionDatasourceImple implements SessionDataSource{
  final AuthClient _authClient;
  SessionDatasourceImple({required this._authClient});

  @override
  Future<void> signOut() async {
    try {
      if(FirebaseAuth.instance.currentUser != null) {
       await _authClient.signOut();
      }else{
        throw AuthException('user_not_found');
      }
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to sign out: ${e.toString()}');
    }
  }
}