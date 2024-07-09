import 'package:shared_preferences/shared_preferences.dart';

class LogoutAuthService {
  SharedPreferences? _prefs;

  Future<void> logout() async {
    _prefs ??= await SharedPreferences.getInstance();
    // Eliminar todas las preferencias relacionadas con la sesión del usuario
    await _prefs!.remove('token');
    await _prefs!.remove('userId');
    await _prefs!.remove('userName');
    await _prefs!.remove('userRole');

    // Opcional: eliminar otras preferencias relacionadas con la sesión
    // await _prefs!.remove('otherSessionDataKey');
  }
}
