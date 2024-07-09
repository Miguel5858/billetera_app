import 'package:FAB/feactures/auth/models/user/user_model.dart';

abstract class AuthServiceInterface {
  Future<User?> login(String email, String password);
  Future<void> logout();
  Future<User?> getUser();
}
