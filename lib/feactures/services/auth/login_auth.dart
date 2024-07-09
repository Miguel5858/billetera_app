import 'dart:convert';
import 'package:FAB/feactures/auth/models/user/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginAuthService {
  static late String apiUrl;

  LoginAuthService() {
    apiUrl = dotenv.env['API_URL'] ?? '';
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      var response = await http.post(
        Uri.parse('$apiUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        // Guardar el ID del usuario como un entero
        int userId = data['user']['id'];
        await prefs.setInt('userId', userId);

        await prefs.setString(
            'userName', data['user']['name']); // Guardar nombre del usuario

        String role = data['user']['role'];
        await prefs.setString('userRole', role);

        return {'success': true, 'user': User.fromJson(data)};
      } else if (response.statusCode == 422) {
        // Código de manejo de errores de validación
      } else {
        // Código de manejo de otros errores
      }
    } catch (e) {
      // Código de manejo de excepciones
    }

    return {'success': false, 'message': 'Error al iniciar sesión'};
  }
}
