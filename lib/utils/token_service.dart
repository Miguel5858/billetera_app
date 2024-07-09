import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  late SharedPreferences _prefs;

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String? getToken() {
    return _prefs.getString('token');
  }

  String? getUserName() {
    return _prefs.getString('userName');
  }

  int? getUserId() {
    return _prefs.getInt('userId');
  }

  String? getUserRole() {
    return _prefs.getString('userRole');
  }

  Future<void> saveTokenAndUserData(
      String token, String userName, int userId, String userRole) async {
    await _prefs.setString('token', token);
    await _prefs.setString('userName', userName);
    await _prefs.setInt('userId', userId);
    await _prefs.setString('userRole', userRole);
  }

  Future<void> deleteTokenAndUserData() async {
    await _prefs.remove('token');
    await _prefs.remove('userName');
    await _prefs.remove('userId');
    await _prefs.remove('userRole');
  }
}
