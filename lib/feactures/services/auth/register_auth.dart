import 'dart:convert';
import 'package:FAB/feactures/auth/models/user/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class RegisterAuthService {
  static late String apiUrl;

  RegisterAuthService() {
    apiUrl = dotenv.env['API_URL'] ?? ''; // Obtener la URL de la API desde .env
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      var response = await http.post(
        Uri.parse('$apiUrl/register'), // URL de la API para registro
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        // Cambia a 201 para éxito
        var data = json.decode(response.body);
        return {
          'success': true,
          'user': User.fromJson(data)
        }; // Devuelve el usuario registrado
      } else if (response.statusCode == 422) {
        // Error de validación en la respuesta de la API
        var errors =
            json.decode(response.body)['errors'] as Map<String, dynamic>;
        // Aseguramos que cada valor en el mapa de errores sea una lista de strings
        var formattedErrors =
            errors.map((key, value) => MapEntry(key, List<String>.from(value)));
        return {'success': false, 'errors': formattedErrors};
      } else {
        // Otro tipo de error en la respuesta de la API
        print('Error en la respuesta de la API: ${response.statusCode}');
        return {'success': false, 'message': 'Error en la respuesta de la API'};
      }
    } catch (e) {
      // Error en la solicitud o comunicación con la API
      print('Error al registrar: $e');
      return {'success': false, 'message': 'Error al registrar: $e'};
    }
  }
}
