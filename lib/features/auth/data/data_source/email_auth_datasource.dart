import '../../../settings/data/models/user_model.dart';

abstract class EmailAuthDatasource {
  Future<UserModel> signUp({
    required String userName,
    required String email,
    required String password,
    required String phoneNumber,
  });

  Future<UserModel> login({
    required String email,
    required String password,
  });

}